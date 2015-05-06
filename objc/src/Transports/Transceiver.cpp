// **********************************************************************
//
// Copyright (c) 2003-2014 ZeroC, Inc. All rights reserved.
//
// This copy of Ice Touch is licensed to you under the terms described in the
// ICE_TOUCH_LICENSE file included in this distribution.
//
// **********************************************************************

#include <Transceiver.h>
#include <EndpointI.h>

#include <Ice/Instance.h>
#include <Ice/Properties.h>
#include <Ice/TraceLevels.h>
#include <Ice/Connection.h>
#include <Ice/LoggerUtil.h>
#include <Ice/Stats.h>
#include <Ice/Buffer.h>
#include <Ice/Network.h>
#include <IceSSL/ConnectionInfo.h>

using namespace std;
using namespace Ice;
using namespace IceInternal;

namespace
{

void selectorReadCallback(CFReadStreamRef, CFStreamEventType event, void* info)
{
    SelectorReadyCallback* callback = reinterpret_cast<SelectorReadyCallback*>(info);
    switch(event)
    {
    case kCFStreamEventOpenCompleted:
        callback->readyCallback(static_cast<SocketOperation>(SocketOperationConnect | SocketOperationRead));
        break;
    case kCFStreamEventHasBytesAvailable:
        callback->readyCallback(SocketOperationRead);
        break;        
    default:
        callback->readyCallback(static_cast<SocketOperation>(SocketOperationRead), -1); // Error
        break;
    }
}
 
void selectorWriteCallback(CFWriteStreamRef, CFStreamEventType event, void* info)
{
    SelectorReadyCallback* callback = reinterpret_cast<SelectorReadyCallback*>(info);
    switch(event)
    {
    case kCFStreamEventOpenCompleted:
        callback->readyCallback(static_cast<SocketOperation>(SocketOperationConnect | SocketOperationWrite));
        break;
    case kCFStreamEventCanAcceptBytes:
        callback->readyCallback(SocketOperationWrite);
        break;        
    default:
        callback->readyCallback(static_cast<SocketOperation>(SocketOperationWrite), -1); // Error
        break;
    }
}

}

static inline string
fromCFString(CFStringRef ref)
{
   const char* s = CFStringGetCStringPtr(ref, kCFStringEncodingUTF8);
   if(s)
   {
       return string(s);
   }

   // Not great, but is good enough for this purpose.
   char buf[1024];
   CFStringGetCString(ref, buf, sizeof(buf), kCFStringEncodingUTF8);
   return string(buf);
}

IceInternal::NativeInfoPtr
IceObjC::Transceiver::getNativeInfo()
{
    return this;
}

void
IceObjC::Transceiver::initStreams(SelectorReadyCallback* callback)
{
    CFOptionFlags events;
    CFStreamClientContext ctx = { 0, callback, 0, 0, 0 };
    events = kCFStreamEventOpenCompleted | kCFStreamEventCanAcceptBytes | kCFStreamEventErrorOccurred | 
        kCFStreamEventEndEncountered;
    CFWriteStreamSetClient(_writeStream, events, selectorWriteCallback, &ctx);
    
    events = kCFStreamEventOpenCompleted | kCFStreamEventHasBytesAvailable | kCFStreamEventErrorOccurred | 
        kCFStreamEventEndEncountered;
    CFReadStreamSetClient(_readStream, events, selectorReadCallback, &ctx);
}

SocketOperation 
IceObjC::Transceiver::registerWithRunLoop(SocketOperation op)
{
    IceUtil::Mutex::Lock sync(_mutex);
    SocketOperation readyOp = SocketOperationNone;
    if(op & SocketOperationConnect)
    {
        if(CFWriteStreamGetStatus(_writeStream) != kCFStreamStatusNotOpen ||
           CFReadStreamGetStatus(_readStream) != kCFStreamStatusNotOpen)
        {
            return SocketOperationConnect;
        }

        _opening = true;

        CFWriteStreamScheduleWithRunLoop(_writeStream, CFRunLoopGetCurrent(), kCFRunLoopDefaultMode);
        CFReadStreamScheduleWithRunLoop(_readStream, CFRunLoopGetCurrent(), kCFRunLoopDefaultMode);
        
        _writeStreamRegistered = true; // Note: this must be set after the schedule call
        _readStreamRegistered = true; // Note: this must be set after the schedule call

        CFReadStreamOpen(_readStream);
        CFWriteStreamOpen(_writeStream);
    }
    else
    {
        if(op & SocketOperationWrite)
        {
            if(CFWriteStreamCanAcceptBytes(_writeStream))
            {
                readyOp = static_cast<SocketOperation>(readyOp | SocketOperationWrite);
            }
            else if(!_writeStreamRegistered)
            {
                CFWriteStreamScheduleWithRunLoop(_writeStream, CFRunLoopGetCurrent(), kCFRunLoopDefaultMode);
                _writeStreamRegistered = true; // Note: this must be set after the schedule call
                if(CFWriteStreamCanAcceptBytes(_writeStream))
                {
                    readyOp = static_cast<SocketOperation>(readyOp | SocketOperationWrite);
                }
            }
        }

        if(op & SocketOperationRead)
        {
            if(CFReadStreamHasBytesAvailable(_readStream))
            {
                readyOp = static_cast<SocketOperation>(readyOp | SocketOperationRead);
            }
            else if(!_readStreamRegistered)
            {
                CFReadStreamScheduleWithRunLoop(_readStream, CFRunLoopGetCurrent(), kCFRunLoopDefaultMode);
                _readStreamRegistered = true; // Note: this must be set after the schedule call
                if(CFReadStreamHasBytesAvailable(_readStream))
                {
                    readyOp = static_cast<SocketOperation>(readyOp | SocketOperationRead);
                }
            }
        }
    }
    return readyOp;
}

SocketOperation
IceObjC::Transceiver::unregisterFromRunLoop(SocketOperation op, bool error)
{
    IceUtil::Mutex::Lock sync(_mutex);
    _error |= error;

    if(_opening)
    {
        // Wait for the stream to be ready for write
        if(op == SocketOperationWrite)
        {
            _writeStreamRegistered = false;
        }

        // Wait for the stream to be ready for read if it's a client connection
        if(op & SocketOperationRead && (_fd != INVALID_SOCKET || !(op & SocketOperationConnect)))
        {
            _readStreamRegistered = false;
        }

        if(error || (!_readStreamRegistered && !_writeStreamRegistered))
        {
            CFWriteStreamUnscheduleFromRunLoop(_writeStream, CFRunLoopGetCurrent(), kCFRunLoopDefaultMode);
            CFReadStreamUnscheduleFromRunLoop(_readStream, CFRunLoopGetCurrent(), kCFRunLoopDefaultMode);
            _opening = false;
            return SocketOperationConnect;
        }
        else
        {
            return SocketOperationNone;
        }
    }
    else
    {
        if(op & SocketOperationWrite && _writeStreamRegistered)
        {
            CFWriteStreamUnscheduleFromRunLoop(_writeStream, CFRunLoopGetCurrent(), kCFRunLoopDefaultMode);
            _writeStreamRegistered = false;
        }
    
        if(op & SocketOperationRead && _readStreamRegistered)
        {
            CFReadStreamUnscheduleFromRunLoop(_readStream, CFRunLoopGetCurrent(), kCFRunLoopDefaultMode);
            _readStreamRegistered = false;
        }
    }
    return op;
}

void 
IceObjC::Transceiver::closeStreams()
{
    CFReadStreamSetClient(_readStream, kCFStreamEventNone, 0, 0);
    CFWriteStreamSetClient(_writeStream, kCFStreamEventNone, 0, 0);
    
    CFReadStreamClose(_readStream);
    CFWriteStreamClose(_writeStream);
}

void
IceObjC::Transceiver::close()
{
    if(_traceLevels->network >= 1)
    {
        Trace out(_logger, _traceLevels->networkCat);
        out << "closing " << _instance->protocol() << " connection\n" << toString();
    }

    if(_fd != INVALID_SOCKET)
    {
        try
        {
            closeSocket(_fd);
            _fd = INVALID_SOCKET;
        }
        catch(const SocketException&)
        {
            _fd = INVALID_SOCKET;
            throw;
        }
    }
}

bool
IceObjC::Transceiver::write(Buffer& buf)
{
    IceUtil::Mutex::Lock sync(_mutex);
    if(_error)
    {
        assert(CFWriteStreamGetStatus(_writeStream) == kCFStreamStatusError);
        CFErrorRef err = CFWriteStreamCopyError(_writeStream);
        CFStringRef domain = CFErrorGetDomain(err);
        CFNetworkException ex(__FILE__, __LINE__);
        ex.domain = fromCFString(domain);
        ex.error = CFErrorGetCode(err);
        CFRelease(err);
        throw ex;
    }

    // Its impossible for the packetSize to be more than an Int.
    int packetSize = static_cast<int>(buf.b.end() - buf.i);
    while(buf.i != buf.b.end())
    {
        if(!CFWriteStreamCanAcceptBytes(_writeStream))
        {
            return false;
        }

        if(_checkCertificates)
        {
            _checkCertificates = false;
            checkCertificates();
        }

        assert(_fd != INVALID_SOCKET);
        CFIndex ret = CFWriteStreamWrite(_writeStream, reinterpret_cast<const UInt8*>(&*buf.i), packetSize);

        if(ret == SOCKET_ERROR)
        {
            if(CFWriteStreamGetStatus(_writeStream) == kCFStreamStatusAtEnd)
            {
                ConnectionLostException ex(__FILE__, __LINE__);
                ex.error = getSocketErrno();
                throw ex;
            }

            assert(CFWriteStreamGetStatus(_writeStream) == kCFStreamStatusError);
            CFErrorRef err = CFWriteStreamCopyError(_writeStream);
            CFStringRef domain = CFErrorGetDomain(err);
            if(CFStringCompare(domain, kCFErrorDomainPOSIX, 0) == kCFCompareEqualTo)
            {
                errno = CFErrorGetCode(err);
                CFRelease(err);
                
                if(interrupted())
                {
                    continue;
                }
                
                if(noBuffers() && packetSize > 1024)
                {
                    packetSize /= 2;
                    continue;
                }
                
                if(wouldBlock())
                {
                    continue;
                }
                
                if(connectionLost())
                {
                    ConnectionLostException ex(__FILE__, __LINE__);
                    ex.error = getSocketErrno();
                    throw ex;
                }
                else
                {
                    SocketException ex(__FILE__, __LINE__);
                    ex.error = getSocketErrno();
                    throw ex;
                }
            }
            else
            { 
                CFNetworkException ex(__FILE__, __LINE__);
                ex.domain = fromCFString(domain);                    
                ex.error = CFErrorGetCode(err);
                CFRelease(err);
                throw ex;                
            }
        }

        if(_traceLevels->network >= 3)
        {
            Trace out(_logger, _traceLevels->networkCat);
            out << "sent " << ret << " of " << packetSize << " bytes via " << _instance->protocol() << "\n" << toString();
        }

        if(_stats)
        {
            _stats->bytesSent(type(), static_cast<Int>(ret));
        }

        buf.i += ret;

        if(packetSize > buf.b.end() - buf.i)
        {
            packetSize = static_cast<int>(buf.b.end() - buf.i);
        }
    }
    return true;
}

bool
IceObjC::Transceiver::read(Buffer& buf)
{
    IceUtil::Mutex::Lock sync(_mutex);
    if(_error)
    {
        assert(CFReadStreamGetStatus(_readStream) == kCFStreamStatusError);
        CFErrorRef err = CFReadStreamCopyError(_readStream);
        CFStringRef domain = CFErrorGetDomain(err);
        CFNetworkException ex(__FILE__, __LINE__);
        ex.domain = fromCFString(domain);
        ex.error = CFErrorGetCode(err);
        CFRelease(err);
        throw ex;
    }

    // Its impossible for the packetSize to be more than an Int.
    int packetSize = static_cast<int>(buf.b.end() - buf.i);
    while(buf.i != buf.b.end())
    {
        if(!CFReadStreamHasBytesAvailable(_readStream))
        {
            return false;
        }

        if(_checkCertificates)
        {
            _checkCertificates = false;
            checkCertificates();
        }

        assert(_fd != INVALID_SOCKET);
        CFIndex ret = CFReadStreamRead(_readStream, reinterpret_cast<UInt8*>(&*buf.i), packetSize);

        if(ret == 0)
        {
            //
            // If the connection is lost when reading data, we shut
            // down the write end of the socket. This helps to unblock
            // threads that are stuck in send() or select() while
            // sending data. Note: I don't really understand why
            // send() or select() sometimes don't detect a connection
            // loss. Therefore this helper to make them detect it.
            //
            //assert(_fd != INVALID_SOCKET);
            //shutdownSocketReadWrite(_fd);
            
            ConnectionLostException ex(__FILE__, __LINE__);
            ex.error = 0;
            throw ex;
        }

        if(ret == SOCKET_ERROR)
        {
            if(CFReadStreamGetStatus(_readStream) == kCFStreamStatusAtEnd)
            {
                ConnectionLostException ex(__FILE__, __LINE__);
                ex.error = getSocketErrno();
                throw ex;
            }

            assert(CFReadStreamGetStatus(_readStream) == kCFStreamStatusError);
            CFErrorRef err = CFReadStreamCopyError(_readStream);
            CFStringRef domain = CFErrorGetDomain(err);
            if(CFStringCompare(domain, kCFErrorDomainPOSIX, 0) == kCFCompareEqualTo)
            {
                errno = CFErrorGetCode(err);
                CFRelease(err);
                
                if(interrupted())
                {
                    continue;
                }
                
                if(noBuffers() && packetSize > 1024)
                {
                    packetSize /= 2;
                    continue;
                }
                
                if(wouldBlock())
                {
                    continue;
                }
                
                if(connectionLost())
                {
                    //
                    // See the commment above about shutting down the
                    // socket if the connection is lost while reading
                    // data.
                    //
                    //assert(_fd != INVALID_SOCKET);
                    //shutdownSocketReadWrite(_fd);
                    
                    ConnectionLostException ex(__FILE__, __LINE__);
                    ex.error = getSocketErrno();
                    throw ex;
                }
                else
                {
                    SocketException ex(__FILE__, __LINE__);
                    ex.error = getSocketErrno();
                    throw ex;
                }
            }
            else
            {
                CFNetworkException ex(__FILE__, __LINE__);
                ex.domain = fromCFString(domain);                    
                ex.error = CFErrorGetCode(err);
                CFRelease(err);
                throw ex;                
            }
        }

        if(_traceLevels->network >= 3)
        {
            Trace out(_logger, _traceLevels->networkCat);
            out << "received " << ret << " of " << packetSize << " bytes via " << _instance->protocol() << "\n" << toString();
        }

        if(_stats)
        {
            _stats->bytesReceived(type(), static_cast<Int>(ret));
        }

        buf.i += ret;

        if(packetSize > buf.b.end() - buf.i)
        {
            packetSize = static_cast<int>(buf.b.end() - buf.i);
        }
    }

    return true;
}

string
IceObjC::Transceiver::type() const
{
    return _instance->protocol();
}

string
IceObjC::Transceiver::toString() const
{
    return _desc;
}

Ice::ConnectionInfoPtr 
IceObjC::Transceiver::getInfo() const
{
    if(_instance->type() == IceObjC::TcpEndpointType)
    {
        Ice::TCPConnectionInfoPtr info = new Ice::TCPConnectionInfo();
        fdToAddressAndPort(_fd, info->localAddress, info->localPort, info->remoteAddress, info->remotePort);
        return info;
    }
    else
    {
        IceSSL::ConnectionInfoPtr info = new IceSSL::ConnectionInfo();
        fdToAddressAndPort(_fd, info->localAddress, info->localPort, info->remoteAddress, info->remotePort);
        return info;
    }
}

SocketOperation
IceObjC::Transceiver::initialize(Buffer& readBuffer, Buffer& writeBuffer)
{
    IceUtil::Mutex::Lock sync(_mutex);
    if(_state == StateNeedConnect)
    {
        _state = StateConnectPending;
        return SocketOperationConnect;
    }

    if(_state <= StateConnectPending)
    {
        try
        {
            if(_error)
            {
                CFErrorRef err = NULL;
                if(CFWriteStreamGetStatus(_writeStream) == kCFStreamStatusError)
                {
                    err = CFWriteStreamCopyError(_writeStream);
                }
                else if(CFReadStreamGetStatus(_readStream) == kCFStreamStatusError)
                {
                    err = CFReadStreamCopyError(_readStream);
                }

                assert(err != NULL);

                CFStringRef domain = CFErrorGetDomain(err);
                if(CFStringCompare(domain, kCFErrorDomainPOSIX, 0) == kCFCompareEqualTo)
                {
                    errno = CFErrorGetCode(err);
                    CFRelease(err);
                    if(connectionRefused())
                    {
                        ConnectionRefusedException ex(__FILE__, __LINE__);
                        ex.error = getSocketErrno();
                        throw ex;
                    }
                    else if(connectFailed())
                    {
                        ConnectFailedException ex(__FILE__, __LINE__);
                        ex.error = getSocketErrno();
                        throw ex;
                    }
                    else
                    {
                        SocketException ex(__FILE__, __LINE__);
                        ex.error = getSocketErrno();
                        throw ex;
                    }
                }
                else if(CFStringCompare(domain, kCFErrorDomainCFNetwork, 0) == kCFCompareEqualTo)
                {
                    int error = CFErrorGetCode(err);
                    if(error == kCFHostErrorHostNotFound || error == kCFHostErrorUnknown)
                    {
                        int rs = 0;
                        if(error == kCFHostErrorUnknown)
                        {
                            CFDictionaryRef dict = CFErrorCopyUserInfo(err);
                            CFNumberRef d = (CFNumberRef)CFDictionaryGetValue(dict, kCFGetAddrInfoFailureKey);
                            if(d != 0)
                            {
                                CFNumberGetValue(d, kCFNumberSInt32Type, &rs);
                            }
                            CFRelease(dict);
                        }
                        
                        CFRelease(err);
                        
                        DNSException ex(__FILE__, __LINE__);
                        ex.error = rs;
                        ex.host = _host;
                        
                        throw ex;
                    }
                }
                
                // Otherwise throw a generic exception.    
                CFNetworkException ex(__FILE__, __LINE__);
                ex.domain = fromCFString(domain);                    
                ex.error = CFErrorGetCode(err);
                CFRelease(err);
                throw ex;
            }

            _state = StateConnected;
            
            if(_fd == INVALID_SOCKET)
            {
                if(!CFReadStreamSetProperty(_readStream, kCFStreamPropertyShouldCloseNativeSocket, kCFBooleanFalse) || 
                   !CFWriteStreamSetProperty(_writeStream, kCFStreamPropertyShouldCloseNativeSocket, kCFBooleanFalse))
                {
                    throw Ice::SocketException(__FILE__, __LINE__, 0);
                }
            
                CFDataRef d = (CFDataRef)CFReadStreamCopyProperty(_readStream, kCFStreamPropertySocketNativeHandle);
                CFDataGetBytes(d, CFRangeMake(0, sizeof(SOCKET)), reinterpret_cast<UInt8*>(&_fd));
                CFRelease(d);
            }

            _desc = fdToString(_fd, _instance->getProxy(), _host, _port);

            setBlock(_fd, false);
            setTcpBufSize(_fd, _instance->initializationData().properties, _logger);
        }
        catch(const Ice::LocalException& ex)
        {
            if(_traceLevels->network >= 2)
            {
                Trace out(_logger, _traceLevels->networkCat);
                out << "failed to establish " << _instance->protocol() << " connection\n" << _desc << "\n" << ex;
            }
            throw;
        }

        if(_traceLevels->network >= 1)
        {
            Trace out(_logger, _traceLevels->networkCat);
            if(_host.empty())
            {
                out << _instance->protocol() << " connection accepted\n" << _desc;
            }
            else
            {
                out << _instance->protocol() << " connection established\n" << _desc;
            }
        }
    }
    assert(_state == StateConnected);
    return SocketOperationNone;
}

void
IceObjC::Transceiver::checkSendSize(const Buffer& buf, size_t messageSizeMax)
{
    if(buf.b.size() > messageSizeMax)
    {
        throw MemoryLimitException(__FILE__, __LINE__);
    }
}

IceObjC::Transceiver::Transceiver(const InstancePtr& instance, 
                                  CFReadStreamRef readStream,
                                  CFWriteStreamRef writeStream,
                                  const string& host,
                                  Ice::Int port) :
    StreamNativeInfo(INVALID_SOCKET),
    _instance(instance),
    _traceLevels(instance->traceLevels()),
    _logger(instance->initializationData().logger),
    _stats(instance->initializationData().stats),
    _host(host),
    _port(port),
    _readStream(readStream),
    _writeStream(writeStream),
    _readStreamRegistered(false),
    _writeStreamRegistered(false),
    _opening(false),
    _checkCertificates(instance->type() == SslEndpointType),
    _error(false),
    _state(StateNeedConnect)
{
    ostringstream s;
    s << "local address = <not available>";
    NetworkProxyPtr proxy = _instance->getProxy();
    if(proxy)
    {
        s << "\n" << proxy->getName() << " proxy address = " << proxy->getHost() << ":" 
          << proxy->getPort();
    }
    s << "\nremote address = " << host << ":" << port;
    _desc = s.str();
}

IceObjC::Transceiver::Transceiver(const InstancePtr& instance, 
                                  CFReadStreamRef readStream,
                                  CFWriteStreamRef writeStream,
                                  SOCKET fd) :
    StreamNativeInfo(fd),
    _instance(instance),
    _traceLevels(instance->traceLevels()),
    _logger(instance->initializationData().logger),
    _stats(instance->initializationData().stats),
    _port(0),
    _readStream(readStream),
    _writeStream(writeStream),
    _readStreamRegistered(false),
    _writeStreamRegistered(false),
    _opening(false),
    _checkCertificates(false),
    _error(false),
    _state(StateNeedConnect),
    _desc(fdToString(fd))
{
}

IceObjC::Transceiver::~Transceiver()
{
    assert(_fd == INVALID_SOCKET);
    CFRelease(_readStream);
    CFRelease(_writeStream);
}

void
IceObjC::Transceiver::checkCertificates()
{
    SecTrustRef trust = (SecTrustRef)CFWriteStreamCopyProperty(_writeStream, kCFStreamPropertySSLPeerTrust);
    if(!trust)
    {
        throw Ice::SecurityException(__FILE__, __LINE__, "unable to obtain trust object");
    }

    try
    {
        SecPolicyRef policy = 0;
        if(_host.empty() ||
           _instance->initializationData().properties->getPropertyAsIntWithDefault("IceSSL.CheckCertName", 1) == 0)
        {
            policy = SecPolicyCreateBasicX509();
        }
        else
        {
            CFStringRef h = CFStringCreateWithCString(NULL, _host.c_str(), kCFStringEncodingUTF8);
            policy = SecPolicyCreateSSL(false, h);
            CFRelease(h);
        }

        OSStatus err = SecTrustSetPolicies(trust, policy);
        CFRelease(policy);
        if(err != noErr)
        {
            ostringstream os;
            os << "unable to set trust object policy (error = " << err << ")";
            throw Ice::SecurityException(__FILE__, __LINE__, os.str());
        }

        //
        // If IceSSL.CertAuthFile is set, we use the certificate authorities from this file
        // instead of the ones from the keychain.
        //
        if(_instance->certificateAuthorities() &&
           (err = SecTrustSetAnchorCertificates(trust, _instance->certificateAuthorities())) != noErr)
        {
            ostringstream os;
            os << "couldn't set root CA certificates with trust object (error = " << err << ")";
            throw Ice::SecurityException(__FILE__, __LINE__, os.str());
        }

        SecTrustResultType result = kSecTrustResultInvalid;
        if((err = SecTrustEvaluate(trust, &result)) != noErr)
        {
            ostringstream os;
            os << "unable to evaluate the peer certificate trust (error = " << err << ")";
            throw Ice::SecurityException(__FILE__, __LINE__, os.str());
        }

        //
        // The kSecTrustResultUnspecified result indicates that the user didn't set any trust
        // settings for the root CA. This is expected if the root CA is provided by the user
        // with IceSSL.CertAuthFile or if the user didn't explicitly set any trust settings
        // for the certificate.
        //
        if(result != kSecTrustResultProceed && result != kSecTrustResultUnspecified)
        {
            ostringstream os;
            os << "certificate validation failed (result = " << result << ")";
            throw Ice::SecurityException(__FILE__, __LINE__, os.str());
        }

        if(_instance->trustOnlyKeyID())
        {
            if(SecTrustGetCertificateCount(trust) < 0)
            {
                throw Ice::SecurityException(__FILE__, __LINE__, "unable to obtain peer certificate");
            }

            SecCertificateRef cert = SecTrustGetCertificateAtIndex(trust, 0);

            //
            // To check the subject key ID, we add the peer certificate to the keychain with SetItemAdd,
            // then we lookup for the cert using the kSecAttrSubjectKeyID. Then we remove the cert from
            // the keychain. NOTE: according to the Apple documentation, it should in theory be possible
            // to not add/remove the item to the keychain by specifying the kSecMatchItemList key (or 
            // kSecUseItemList?) when calling SecItemCopyMatching. Unfortunately this doesn't appear to
            // work. Similarly, it should be possible to get back the attributes of the certificate 
            // once it added by setting kSecReturnAttributes in the add query, again this doesn't seem
            // to work.
            //
            CFMutableDictionaryRef query;
            query = CFDictionaryCreateMutable(0, 1, &kCFTypeDictionaryKeyCallBacks, &kCFTypeDictionaryValueCallBacks);
            CFDictionarySetValue(query, kSecClass, kSecClassCertificate);
            CFDictionarySetValue(query, kSecValueRef, cert);
            err = SecItemAdd(query, 0);
            if(err != noErr && err != errSecDuplicateItem)
            {
                CFRelease(query);
                ostringstream os;
                os << "unable to add peer certificate to keychain (error = " << err << ")";
                throw Ice::SecurityException(__FILE__, __LINE__, os.str());
            }
            CFRelease(query);

            query = CFDictionaryCreateMutable(0, 1, &kCFTypeDictionaryKeyCallBacks, &kCFTypeDictionaryValueCallBacks);
            CFDictionarySetValue(query, kSecClass, kSecClassCertificate);
            CFDictionarySetValue(query, kSecValueRef, cert);
            CFDictionarySetValue(query, kSecAttrSubjectKeyID, _instance->trustOnlyKeyID());
            err = SecItemCopyMatching(query, 0);
            OSStatus foundErr = err;
            CFRelease(query);

            query = CFDictionaryCreateMutable(0, 1, &kCFTypeDictionaryKeyCallBacks, &kCFTypeDictionaryValueCallBacks);
            CFDictionarySetValue(query, kSecClass, kSecClassCertificate);
            CFDictionarySetValue(query, kSecValueRef, cert);
            err = SecItemDelete(query);
            if(err != noErr)
            {
                CFRelease(query);
                ostringstream os;
                os << "unable to remove peer certificate from keychain (error = " << err << ")";
                throw Ice::SecurityException(__FILE__, __LINE__, os.str());
            }
            CFRelease(query);

            if(foundErr != noErr)
            {
                ostringstream os;
                os << "the certificate subject key ID doesn't match the `IceSSL.TrustOnly.Client' property ";
                os << "(error = " << foundErr << ")";
                throw Ice::SecurityException(__FILE__, __LINE__, os.str());
            }
        }
        CFRelease(trust);
    }
    catch(...)
    {
        if(trust)
        {
            CFRelease(trust);
        }
        throw;
    }
}
