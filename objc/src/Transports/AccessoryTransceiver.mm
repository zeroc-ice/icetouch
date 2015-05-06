// **********************************************************************
//
// Copyright (c) 2003-2014 ZeroC, Inc. All rights reserved.
//
// This copy of Ice Touch is licensed to you under the terms described in the
// ICE_TOUCH_LICENSE file included in this distribution.
//
// **********************************************************************

#include <AccessoryTransceiver.h>
#include <AccessoryEndpointI.h>

#include <Ice/LocalException.h>
#include <Ice/Instance.h>
#include <Ice/TraceLevels.h>
#include <Ice/LoggerUtil.h>
#include <Ice/Stats.h>
#include <Ice/Buffer.h>

#import <Foundation/NSRunLoop.h>
#import <Foundation/NSError.h>
#import <Foundation/NSString.h>

using namespace std;
using namespace Ice;
using namespace IceInternal;

@interface AccessoryTransceiverCallback : NSObject<NSStreamDelegate>
{
@private

    SelectorReadyCallback* callback;
}
-(id) init:(SelectorReadyCallback*)cb;
@end

@implementation AccessoryTransceiverCallback
-(id) init:(SelectorReadyCallback*)cb;
{
    if(![super init])
    {
        return nil;
    }
    callback = cb;
    return self;
}

- (void)stream:(NSStream *)stream handleEvent:(NSStreamEvent)eventCode 
{ 
    switch(eventCode) 
    {
    case NSStreamEventHasBytesAvailable:
        callback->readyCallback(SocketOperationRead);
        break;
    case NSStreamEventHasSpaceAvailable:
        callback->readyCallback(SocketOperationWrite);
        break;
    case NSStreamEventEndEncountered:
    case NSStreamEventErrorOccurred:
    case NSStreamEventOpenCompleted:
        if([[stream class] isSubclassOfClass:[NSInputStream class]])
        {
            callback->readyCallback(static_cast<SocketOperation>(SocketOperationConnect | SocketOperationRead));
        }
        else
        {
            callback->readyCallback(static_cast<SocketOperation>(SocketOperationConnect | SocketOperationWrite));
        }
        break;
    }
}
@end

IceInternal::NativeInfoPtr
IceObjC::AccessoryTransceiver::getNativeInfo()
{
    return this;
}

void
IceObjC::AccessoryTransceiver::initStreams(SelectorReadyCallback* callback)
{
    _callback = [[AccessoryTransceiverCallback alloc] init:callback];
    [_writeStream setDelegate:_callback];
    [_readStream setDelegate:_callback];
}

SocketOperation 
IceObjC::AccessoryTransceiver::registerWithRunLoop(SocketOperation op)
{
    SocketOperation readyOp = SocketOperationNone;

    if(op & SocketOperationConnect)
    {
        if([_writeStream streamStatus] != NSStreamStatusNotOpen || [_readStream streamStatus] != NSStreamStatusNotOpen)
        {
            return SocketOperationConnect;
        }

        assert(!_writeStreamRegistered);
        assert(!_readStreamRegistered);
        [_writeStream scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
        [_readStream scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
        
        _writeStreamRegistered = true; // Note: this must be set after the schedule call
        _readStreamRegistered = true; // Note: this must be set after the schedule call

        _opening = true;
        
        [_writeStream open];
        [_readStream open];
    }
    else
    {
        if(op & SocketOperationWrite)
        {
            if([_writeStream hasSpaceAvailable])
            {
                readyOp = static_cast<SocketOperation>(readyOp | SocketOperationWrite);
            }
            else if(!_writeStreamRegistered)
            {
                [_writeStream scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
                _writeStreamRegistered = true; // Note: this must be set after the schedule call
            }
        }

        if(op & SocketOperationRead)
        {
            if([_readStream hasBytesAvailable])
            {
                readyOp = static_cast<SocketOperation>(readyOp | SocketOperationRead);
            }
            else if(!_readStreamRegistered)
            {
                [_readStream scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
                _readStreamRegistered = true; // Note: this must be set after the schedule call
            }
        }
    }
    return readyOp;
}

SocketOperation
IceObjC::AccessoryTransceiver::unregisterFromRunLoop(SocketOperation op, bool error)
{
    if(op & SocketOperationWrite && _writeStreamRegistered)
    {
        error |= [_writeStream streamStatus] == NSStreamStatusError;
        [_writeStream removeFromRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
        _writeStreamRegistered = false;
    }
    
    if(op & SocketOperationRead && _readStreamRegistered)
    {
        error |= [_readStream streamStatus] == NSStreamStatusError;
        [_readStream removeFromRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
        _readStreamRegistered = false;
    }

    if(_opening && (op & SocketOperationConnect))
    {
        if(error || (!_readStreamRegistered && !_writeStreamRegistered))
        {
            _opening = false;
            return SocketOperationConnect;
        }
        else
        {
            return SocketOperationNone;
        }
    }
    return op;
}

void 
IceObjC::AccessoryTransceiver::closeStreams()
{
    [_writeStream setDelegate:nil];
    [_readStream setDelegate:nil];

    [_callback release];
    _callback = 0;
}

void
IceObjC::AccessoryTransceiver::close()
{
    if(_traceLevels->network >= 1)
    {
        Trace out(_logger, _traceLevels->networkCat);
        out << "closing accessory connection\n" << toString();
    }

    [_writeStream close];
    [_readStream close];
}

bool
IceObjC::AccessoryTransceiver::write(Buffer& buf)
{
    // Its impossible for the packetSize to be more than an Int.
    int packetSize = static_cast<int>(buf.b.end() - buf.i);

    while(buf.i != buf.b.end())
    {
        if(![_writeStream hasSpaceAvailable] && [_writeStream streamStatus] != NSStreamStatusError)
        {
            return false;
        }
        assert([_writeStream streamStatus] >= NSStreamStatusOpen);

        NSInteger ret = [_writeStream write:reinterpret_cast<const UInt8*>(&*buf.i) maxLength:packetSize];
        if(ret == SOCKET_ERROR)
        {
            assert([_writeStream streamStatus] == NSStreamStatusError);
            NSError* err = [_writeStream streamError];
            NSString* domain = [err domain];
            if([domain compare:NSPOSIXErrorDomain] == NSOrderedSame)
            {
                errno = [err code];
                [err release];
                
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
                    return false;
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
                ex.domain = [domain UTF8String];
                ex.error = [err code];
                [err release];
                throw ex;
            }
        }

        if(_traceLevels->network >= 3)
        {
            Trace out(_logger, _traceLevels->networkCat);
            out << "sent " << ret << " of " << packetSize << " bytes via accessory\n" << toString();
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
IceObjC::AccessoryTransceiver::read(Buffer& buf)
{
    // Its impossible for the packetSize to be more than an Int.
    int packetSize = static_cast<int>(buf.b.end() - buf.i);

    while(buf.i != buf.b.end())
    {
        if(![_readStream hasBytesAvailable] && [_readStream streamStatus] != NSStreamStatusError)
        {
            return false;
        }
        assert([_readStream streamStatus] >= NSStreamStatusOpen);

        NSInteger ret = [_readStream read:reinterpret_cast<UInt8*>(&*buf.i) maxLength:packetSize];
        if(ret == 0)
        {
            ConnectionLostException ex(__FILE__, __LINE__);
            ex.error = 0;
            throw ex;
        }

        if(ret == SOCKET_ERROR)
        {
            assert([_readStream streamStatus] == NSStreamStatusError);
            NSError* err = [_readStream streamError];
            NSString* domain = [err domain];
            if([domain compare:NSPOSIXErrorDomain] == NSOrderedSame)
            {
                errno = [err code];
                [err release];
                
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
                    return false;
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
                ex.domain = [domain UTF8String];
                ex.error = [err code];
                [err release];
                throw ex;
            }
        }

        if(_traceLevels->network >= 3)
        {
            Trace out(_logger, _traceLevels->networkCat);
            out << "received " << ret << " of " << packetSize << " bytes via accessory\n" << toString();
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
IceObjC::AccessoryTransceiver::type() const
{
    return "accessory";
}

string
IceObjC::AccessoryTransceiver::toString() const
{
    return _desc;
}

Ice::ConnectionInfoPtr 
IceObjC::AccessoryTransceiver::getInfo() const
{
    return 0;
}

SocketOperation
IceObjC::AccessoryTransceiver::initialize(IceInternal::Buffer& readBuffer, IceInternal::Buffer& writeBuffer)
{
    if(_state == StateNeedConnect)
    {
        _state = StateConnectPending;
        return SocketOperationConnect;
    }
    
    if(_state <= StateConnectPending)
    {
        try
        {
            if([_writeStream streamStatus] == NSStreamStatusError || [_readStream streamStatus] == NSStreamStatusError)
            {
                assert([_writeStream streamStatus] == NSStreamStatusError);
                NSError* err = [_writeStream streamError];
                NSString* domain = [err domain];
                if([domain compare:NSPOSIXErrorDomain] == NSOrderedSame)
                {
                    errno = [err code];
                    [err release];
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
                
                // Otherwise throw a generic exception.    
                CFNetworkException ex(__FILE__, __LINE__);
                ex.domain = [domain UTF8String];
                ex.error = [err code];
                [err release];
                throw ex;
            }
            if([_writeStream streamStatus] < NSStreamStatusOpen || [_readStream streamStatus] < NSStreamStatusOpen)
            {
                return SocketOperationConnect;
            }

            _state = StateConnected;
        }
        catch(const Ice::LocalException& ex)
        {
            if(_traceLevels->network >= 2)
            {
                Trace out(_logger, _traceLevels->networkCat);
                out << "failed to establish accessory connection\n" << _desc << "\n" << ex;
            }
            throw;
        }

        if(_traceLevels->network >= 1)
        {
            Trace out(_logger, _traceLevels->networkCat);
            out << "accessory connection established\n" << _desc;
        }
    }
    assert(_state == StateConnected);
    return SocketOperationNone;
}

void
IceObjC::AccessoryTransceiver::checkSendSize(const Buffer& buf, size_t messageSizeMax)
{
    if(buf.b.size() > messageSizeMax)
    {
        throw MemoryLimitException(__FILE__, __LINE__);
    }
}

IceObjC::AccessoryTransceiver::AccessoryTransceiver(const InstancePtr& instance, EASession* session) :
    StreamNativeInfo(INVALID_SOCKET),
    _traceLevels(instance->traceLevels()),
    _logger(instance->initializationData().logger),
    _stats(instance->initializationData().stats),
    _readStream([[session inputStream] retain]),
    _writeStream([[session outputStream] retain]),
    _readStreamRegistered(false),
    _writeStreamRegistered(false),
    _state(StateNeedConnect)
{
    _desc = string("name = ") + [session.accessory.name UTF8String];
}

IceObjC::AccessoryTransceiver::~AccessoryTransceiver()
{
    [_readStream release];
    [_writeStream release];
}
