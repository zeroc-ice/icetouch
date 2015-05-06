// **********************************************************************
//
// Copyright (c) 2003-2014 ZeroC, Inc. All rights reserved.
//
// This copy of Ice Touch is licensed to you under the terms described in the
// ICE_TOUCH_LICENSE file included in this distribution.
//
// **********************************************************************

#include <EndpointI.h>
#include <Acceptor.h>
#include <Connector.h>

#include <Ice/Network.h>
#include <Ice/BasicStream.h>
#include <Ice/LocalException.h>
#include <Ice/Instance.h>
#include <Ice/DefaultsAndOverrides.h>
#include <Ice/Initialize.h>
#include <Ice/EndpointFactoryManager.h>
#include <Ice/Properties.h>
#include <Ice/HashUtil.h>

#include <IceSSL/EndpointInfo.h>

#include <CoreFoundation/CoreFoundation.h>

#include <fstream>

using namespace std;
using namespace Ice;
using namespace IceInternal;

inline CFStringRef
toCFString(const string& s)
{
    return CFStringCreateWithCString(NULL, s.c_str(), kCFStringEncodingUTF8);
}

inline int
hexValue(char c)
{
    if(c >= '0' && c <= '9')
    {
        return c - '0';
    }
    else if(c >= 'A' && c <= 'F')
    {
        return (c - 'A') + 10;
    }
    else if(c >= 'a' && c <= 'f')
    {
        return (c - 'a') + 10;
    }
    return -1;
}

inline CFDataRef
parseKey(const string& keyStr)
{
    int i = 0, j = 0;
    const char* m = keyStr.c_str();
    CFMutableDataRef data = CFDataCreateMutable(0, 160);
    unsigned char buf[160];
    while(i < (int)keyStr.size())
    {
        if(isspace(m[i]) || m[i] == ':')
        {
            ++i;
            continue;
        }
        else if(i == (int)keyStr.size() - 1)
        {
            CFRelease(data);
            return 0; // Not enough bytes.
        }

        int vh = hexValue(m[i++]);
        int vl = hexValue(m[i++]);
        if(vh < 0 || vl < 0)
        {
            CFRelease(data);
            return 0;
        }
        buf[j] = vh << 4;
        buf[j++] += vl;

        if(j == sizeof(buf))
        {
            CFDataAppendBytes(data, (UInt8*)buf, j);
            j = 0;
        }
    }

    if(j > 0)
    {
        CFDataAppendBytes(data, buf, j);
    }

    return data;
}

namespace
{

CFDataRef 
readCert(const string& defaultDir, const string& certFile)
{
    CFURLRef url = 0;
    CFBundleRef bundle = CFBundleGetMainBundle();
    if(bundle)
    {
        CFStringRef resourceName = toCFString(certFile);
        CFStringRef subDirName = toCFString(defaultDir);
        url = CFBundleCopyResourceURL(bundle, resourceName, 0, subDirName);
        CFRelease(resourceName);
        CFRelease(subDirName);
    }

    if(!url)
    {
        CFStringRef filePath = toCFString(defaultDir.empty() ? certFile : defaultDir + "/" + certFile);
        url = CFURLCreateWithFileSystemPath(0, filePath, kCFURLPOSIXPathStyle, false);
        CFRelease(filePath);
    }

    CFDataRef cert = 0;
    SInt32 error;
    if(!CFURLCreateDataAndPropertiesFromResource(0, url, &cert, 0, 0, &error))
    {
        ostringstream os;
        os << "IceSSL: unable to open file " << certFile << " (error = " << error << ")";
        throw PluginInitializationException(__FILE__, __LINE__, os.str());
    }
    CFRelease(url);
    return cert;
}

}


IceObjC::Instance::Instance(const IceInternal::InstancePtr& instance, bool secure) :
    _instance(instance),
    _type(secure ? SslEndpointType : TcpEndpointType),
    _voip(instance->initializationData().properties->getPropertyAsIntWithDefault("Ice.Voip", 0) > 0),
    _protocol(secure ? string("ssl") : string("tcp")),
    _serverSettings(0),
    _clientSettings(0),
    _proxySettings(0),
    _certificateAuthorities(0),
    _trustOnlyKeyID(0)
{
    Ice::PropertiesPtr properties = _instance->initializationData().properties;
    
    if(secure)
    {   
        _clientSettings = CFDictionaryCreateMutable(0, 1, &kCFTypeDictionaryKeyCallBacks, 
                                                    &kCFTypeDictionaryValueCallBacks);

        string defaultDir = properties->getProperty("IceSSL.DefaultDir");
        string certAuthFile = properties->getProperty("IceSSL.CertAuthFile");
        string certFile = properties->getProperty("IceSSL.CertFile");

        OSStatus err;
        if(!certAuthFile.empty())
        {
            CFDataRef cert = readCert(defaultDir, certAuthFile);
            if(!cert)
            {
                PluginInitializationException ex(__FILE__, __LINE__);
                ex.reason = "IceSSL: unable to open file " + certAuthFile;
                throw ex;
            }

            SecCertificateRef result = SecCertificateCreateWithData(0, cert);
            CFRelease(cert);
            if(!result)
            {
                PluginInitializationException ex(__FILE__, __LINE__);
                ex.reason = "IceSSL: certificate " + certAuthFile + " is not a valid DER-encoded certificate";
                throw ex;
            }

            SecCertificateRef certs[] = { result };
            _certificateAuthorities = CFArrayCreate(0, (const void**)certs, 1, &kCFTypeArrayCallBacks);
            CFRelease(result);

            // The root CA will be validated by the transceiver.
            // NOTE: on the iPhone, setting kCFStreamSSLAllowsAnyRoot = true isn't enough.
            //CFDictionarySetValue(_clientSettings, kCFStreamSSLAllowsAnyRoot, kCFBooleanTrue);
            CFDictionarySetValue(_clientSettings, kCFStreamSSLValidatesCertificateChain, kCFBooleanFalse);
        }

        if(!certFile.empty())
        {
            CFDataRef cert = readCert(defaultDir, certFile);
            if(!cert)
            {
                PluginInitializationException ex(__FILE__, __LINE__);
                ex.reason = "IceSSL: unable to open file " + certFile;
                throw ex;
            }

            CFMutableDictionaryRef settings = CFDictionaryCreateMutable(0, 1, &kCFTypeDictionaryKeyCallBacks, 
                                                                        &kCFTypeDictionaryValueCallBacks);
            CFStringRef password = toCFString(properties->getProperty("IceSSL.Password"));
            CFDictionarySetValue(settings, kSecImportExportPassphrase, password);
            CFRelease(password);

            CFArrayRef items = 0;
            err = SecPKCS12Import(cert, settings, &items);
            CFRelease(cert);
            CFRelease(settings);
            if(err != noErr)
            {
                ostringstream os;
                os << "IceSSL: unable to import certificate from file " << certFile << " (error = " << err << ")";
                throw PluginInitializationException(__FILE__, __LINE__, os.str());
            }

            SecIdentityRef identity = 0;
            if(CFArrayGetCount(items) > 0)
            {
                identity = (SecIdentityRef)CFDictionaryGetValue((CFDictionaryRef)CFArrayGetValueAtIndex(items, 0), 
                                                                kSecImportItemIdentity);
            }
            if(identity == 0)
            {
                ostringstream os;
                os << "IceSSL: couldn't find identity in file " << certFile << " (error = " << err << ")";
                throw PluginInitializationException(__FILE__, __LINE__, os.str());
            }
            CFRetain(identity);
            CFRelease(items);

            SecIdentityRef identities[] = { identity };
            items = CFArrayCreate(0, (const void**)identities, 1, &kCFTypeArrayCallBacks);
            CFDictionarySetValue(_clientSettings, kCFStreamSSLCertificates, items);
            CFRelease(identity);
            CFRelease(items);
        }

        string trustOnly = properties->getProperty("IceSSL.TrustOnly.Client");
        if(!trustOnly.empty())
        {
            if(certAuthFile.empty())
            {
                ostringstream os;
                os << "IceSSL: `IceSSL.TrustOnly.Client' can only be specified with `IceSSL.CertAuthFile'";
                throw PluginInitializationException(__FILE__, __LINE__, os.str());
            }

            _trustOnlyKeyID = parseKey(trustOnly);
            if(!_trustOnlyKeyID)
            {
                ostringstream os;
                os << "IceSSL: invalid `IceSSL.TrustOnly.Client' property value";
                throw PluginInitializationException(__FILE__, __LINE__, os.str());
            }
        }

        _serverSettings = CFDictionaryCreateMutableCopy(0, 0, _clientSettings);
        CFDictionarySetValue(_serverSettings, kCFStreamSSLIsServer, kCFBooleanTrue);
    }

    //
    // Proxy settings
    // 
    IceInternal::NetworkProxyPtr proxy = _instance->networkProxy();
    if(IceInternal::SOCKSNetworkProxyPtr::dynamicCast(proxy))
    {
#if TARGET_IPHONE_SIMULATOR != 0
        throw Ice::FeatureNotSupportedException(__FILE__, __LINE__, "SOCKs proxy");
#endif
        _proxySettings = CFDictionaryCreateMutable(0, 3, &kCFTypeDictionaryKeyCallBacks, 
                                                   &kCFTypeDictionaryValueCallBacks);

        CFStringRef host = toCFString(proxy->getHost());
        CFDictionarySetValue(_proxySettings, kCFStreamPropertySOCKSProxyHost, host);
        CFRelease(host);

        int proxyPort = proxy->getPort();
        CFNumberRef port = CFNumberCreate(0, kCFNumberSInt32Type, &proxyPort);
        CFDictionarySetValue(_proxySettings, kCFStreamPropertySOCKSProxyPort, port);
        CFRelease(port);

        CFDictionarySetValue(_proxySettings, kCFStreamPropertySOCKSVersion, kCFStreamSocketSOCKSVersion4);
    }
}

IceObjC::Instance::~Instance()
{
    if(_trustOnlyKeyID)
    {
        CFRelease(_trustOnlyKeyID);
    }
    if(_serverSettings)
    {
        CFRelease(_serverSettings);
    }
    if(_clientSettings)
    {
        CFRelease(_clientSettings);
    }
    if(_certificateAuthorities)
    {
        CFRelease(_certificateAuthorities);
    }
    if(_proxySettings)
    {
        CFRelease(_proxySettings);
    }
}

void
IceObjC::Instance::setupStreams(CFReadStreamRef readStream, 
                                CFWriteStreamRef writeStream, 
                                bool server, 
                                const string& host) const
{
    if(_voip)
    {
#if TARGET_IPHONE_SIMULATOR == 0
        if(!CFReadStreamSetProperty(readStream, kCFStreamNetworkServiceType, kCFStreamNetworkServiceTypeVoIP) ||
           !CFWriteStreamSetProperty(writeStream, kCFStreamNetworkServiceType, kCFStreamNetworkServiceTypeVoIP))
        {
            throw Ice::SyscallException(__FILE__, __LINE__);
        }
#endif
    }

    if(!server && _proxySettings)
    {
        if(!CFReadStreamSetProperty(readStream, kCFStreamPropertySOCKSProxy, _proxySettings) ||
           !CFWriteStreamSetProperty(writeStream, kCFStreamPropertySOCKSProxy, _proxySettings))
        {
            throw Ice::SyscallException(__FILE__, __LINE__);
        }
    }

    if(_type == SslEndpointType)
    {
        CFDictionaryRef settings = server ? _serverSettings : _clientSettings;

        if(!CFReadStreamSetProperty(readStream, kCFStreamPropertySocketSecurityLevel, 
                                    kCFStreamSocketSecurityLevelNegotiatedSSL) ||
           !CFWriteStreamSetProperty(writeStream, kCFStreamPropertySocketSecurityLevel, 
                                     kCFStreamSocketSecurityLevelNegotiatedSSL))
        {
            throw Ice::SecurityException(__FILE__, __LINE__, "couldn't set security level");
        }
        
        if(!server && 
           _instance->initializationData().properties->getPropertyAsIntWithDefault("IceSSL.CheckCertName", 1))
        {
            settings = CFDictionaryCreateMutableCopy(0, 0, settings);

            CFStringRef h = toCFString(host);
            CFDictionarySetValue((CFMutableDictionaryRef)settings, kCFStreamSSLPeerName, h);
            CFRelease(h);
        }
        else
        {
            CFRetain(settings);
        }

        if(!CFReadStreamSetProperty(readStream, kCFStreamPropertySSLSettings, settings) ||
           !CFWriteStreamSetProperty(writeStream, kCFStreamPropertySSLSettings, settings))
        {
            CFRelease(settings);
            throw Ice::SecurityException(__FILE__, __LINE__, "couldn't set security options");
        }
        CFRelease(settings);
    }
}

IceObjC::EndpointI::EndpointI(const InstancePtr& instance, const string& ho, Int po, Int ti, const string& conId, 
                              bool co) :
    IceInternal::EndpointI(conId),
    _instance(instance),
    _host(ho),
    _port(po),
    _timeout(ti),
    _compress(co)
{
}

IceObjC::EndpointI::EndpointI(const InstancePtr& instance, const string& str, bool oaEndpoint) :
    _instance(instance),
    _port(0),
    _timeout(-1),
    _compress(false)
{
    const string delim = " \t\n\r";

    string::size_type beg;
    string::size_type end = 0;

    while(true)
    {
        beg = str.find_first_not_of(delim, end);
        if(beg == string::npos)
        {
            break;
        }
        
        end = str.find_first_of(delim, beg);
        if(end == string::npos)
        {
            end = str.length();
        }

        string option = str.substr(beg, end - beg);
        if(option.length() != 2 || option[0] != '-')
        {
            EndpointParseException ex(__FILE__, __LINE__);
            ex.str = _instance->protocol() + " " + str;
            throw ex;
        }

        string argument;
        string::size_type argumentBeg = str.find_first_not_of(delim, end);
        if(argumentBeg != string::npos && str[argumentBeg] != '-')
        {
            beg = argumentBeg;
            end = str.find_first_of(delim, beg);
            if(end == string::npos)
            {
                end = str.length();
            }
            argument = str.substr(beg, end - beg);
            if(argument[0] == '\"' && argument[argument.size() - 1] == '\"')
            {
                argument = argument.substr(1, argument.size() - 2);
            }
        }

        switch(option[1])
        {
            case 'h':
            {
                if(argument.empty())
                {
                    EndpointParseException ex(__FILE__, __LINE__);
                    ex.str = _instance->protocol() + " " + str;
                    throw ex;
                }
                const_cast<string&>(_host) = argument;
                break;
            }

            case 'p':
            {
                istringstream p(argument);
                if(!(p >> const_cast<Int&>(_port)) || !p.eof() || _port < 0 || _port > 65535)
                {
                    EndpointParseException ex(__FILE__, __LINE__);
                    ex.str = _instance->protocol() + " " + str;
                    throw ex;
                }
                break;
            }

            case 't':
            {
                istringstream t(argument);
                if(!(t >> const_cast<Int&>(_timeout)) || !t.eof())
                {
                    EndpointParseException ex(__FILE__, __LINE__);
                    ex.str = _instance->protocol() + " " + str;
                    throw ex;
                }
                break;
            }

            case 'z':
            {
                if(!argument.empty())
                {
                    EndpointParseException ex(__FILE__, __LINE__);
                    ex.str = _instance->protocol() + " " + str;
                    throw ex;
                }
                const_cast<bool&>(_compress) = true;
                break;
            }

            default:
            {
                EndpointParseException ex(__FILE__, __LINE__);
                ex.str = _instance->protocol() + " " + str;
                throw ex;
            }
        }
    }

    if(_host.empty())
    {
        const_cast<string&>(_host) = _instance->defaultsAndOverrides()->defaultHost;
    }
    else if(_host == "*")
    {
        if(oaEndpoint)
        {
            const_cast<string&>(_host) = string();
        }
        else
        {
            EndpointParseException ex(__FILE__, __LINE__);
            ex.str = _instance->protocol() + " " + str;
            throw ex;
        }
    }
}

IceObjC::EndpointI::EndpointI(const InstancePtr& instance, BasicStream* s) :
    _instance(instance),
    _port(0),
    _timeout(-1),
    _compress(false)
{
    s->startReadEncaps();
    s->read(const_cast<string&>(_host), false);
    s->read(const_cast<Int&>(_port));
    s->read(const_cast<Int&>(_timeout));
    s->read(const_cast<bool&>(_compress));
    s->endReadEncaps();
}

void
IceObjC::EndpointI::streamWrite(BasicStream* s) const
{
    s->write(_instance->type());
    s->startWriteEncaps();
    s->write(_host, false);
    s->write(_port);
    s->write(_timeout);
    s->write(_compress);
    s->endWriteEncaps();
}

string
IceObjC::EndpointI::toString() const
{
    //
    // WARNING: Certain features, such as proxy validation in Glacier2,
    // depend on the format of proxy strings. Changes to toString() and
    // methods called to generate parts of the reference string could break
    // these features. Please review for all features that depend on the
    // format of proxyToString() before changing this and related code.
    //
    ostringstream s;
    s << _instance->protocol();

    if(!_host.empty())
    {
        s << " -h ";
        bool addQuote = _host.find(':') != string::npos;
        if(addQuote)
        {
            s << "\"";
        }
        s << _host;
        if(addQuote)
        {
            s << "\"";
        }
    }

    s << " -p " << _port;
    if(_timeout != -1)
    {
        s << " -t " << _timeout;
    }
    if(_compress)
    {
        s << " -z";
    }
    return s.str();
}

EndpointInfoPtr
IceObjC::EndpointI::getInfo() const
{
    if(_instance->type() == TcpEndpointType)
    {
        class TCPInfoI : public Ice::TCPEndpointInfo
        {
        public:

            TCPInfoI(Ice::Int to, bool comp, const string& host, Ice::Int port) :
                TCPEndpointInfo(to, comp, host, port)
            {
            }

            virtual Ice::Short
            type() const
            {
                return TcpEndpointType;
            }
            
            virtual bool
            datagram() const
            {
                return false;
            }

            virtual bool
            secure() const
            {
                return false;
            }
        };

        return new TCPInfoI(_timeout, _compress, _host, _port);
    }
    else
    {
        class SSLInfoI : public IceSSL::EndpointInfo
        {
        public:

            SSLInfoI(Int to, bool comp, const string& host, Int port) : 
                IceSSL::EndpointInfo(to, comp, host, port)
            {
            }

            virtual Short
            type() const
            {
                return SslEndpointType;
            }
            
            virtual bool
            datagram() const
            {
                return false;
            }

            virtual bool
            secure() const
            {
                return true;
            }
        };
        return new SSLInfoI(_timeout, _compress, _host, _port);
    }
}

Short
IceObjC::EndpointI::type() const
{
    return _instance->type();
}

std::string
IceObjC::EndpointI::protocol() const
{
    return _instance->protocol();
}

Int
IceObjC::EndpointI::timeout() const
{
    return _timeout;
}

EndpointIPtr
IceObjC::EndpointI::timeout(Int timeout) const
{
    if(timeout == _timeout)
    {
        return const_cast<EndpointI*>(this);
    }
    else
    {
        return new EndpointI(_instance, _host, _port, timeout, _connectionId, _compress);
    }
}

EndpointIPtr
IceObjC::EndpointI::connectionId(const string& connectionId) const
{
    if(connectionId == _connectionId)
    {
        return const_cast<EndpointI*>(this);
    }
    else
    {
        return new EndpointI(_instance, _host, _port, _timeout, connectionId, _compress);
    }
}

bool
IceObjC::EndpointI::compress() const
{
    return _compress;
}

EndpointIPtr
IceObjC::EndpointI::compress(bool compress) const
{
    if(compress == _compress)
    {
        return const_cast<EndpointI*>(this);
    }
    else
    {
        return new EndpointI(_instance, _host, _port, _timeout, _connectionId, compress);
    }
}

bool
IceObjC::EndpointI::datagram() const
{
    return false;
}

bool
IceObjC::EndpointI::secure() const
{
    return _instance->type() == SslEndpointType;
}

bool
IceObjC::EndpointI::unknown() const
{
    return false;
}

TransceiverPtr
IceObjC::EndpointI::transceiver(EndpointIPtr& endp) const
{
    endp = const_cast<EndpointI*>(this);
    return 0;
}

vector<ConnectorPtr>
IceObjC::EndpointI::connectors(Ice::EndpointSelectionType) const
{
    vector<ConnectorPtr> connectors;
    connectors.push_back(new IceObjC::Connector(_instance, _timeout, _connectionId, _host, _port));
    return connectors;
}

void
IceObjC::EndpointI::connectors_async(Ice::EndpointSelectionType selType, const EndpointI_connectorsPtr& callback) const
{
    try
    {
        callback->connectors(connectors(selType));
    }
    catch(const Ice::LocalException& ex)
    {
        callback->exception(ex);
    }
}

AcceptorPtr
IceObjC::EndpointI::acceptor(EndpointIPtr& endp, const string&) const
{
    Acceptor* p = new Acceptor(_instance, _host, _port);
    endp = new EndpointI(_instance, _host, p->effectivePort(), _timeout, _connectionId, _compress);
    return p;
}

vector<EndpointIPtr>
IceObjC::EndpointI::expand() const
{
    vector<EndpointIPtr> endps;
    vector<string> hosts = getHostsForEndpointExpand(_host, _instance->protocolSupport(), false);
    if(hosts.empty())
    {
        endps.push_back(const_cast<EndpointI*>(this));
    }
    else
    {
        for(vector<string>::const_iterator p = hosts.begin(); p != hosts.end(); ++p)
        {
            endps.push_back(new EndpointI(_instance, *p, _port, _timeout, _connectionId, _compress));
        }
    }
    return endps;
}

bool
IceObjC::EndpointI::equivalent(const EndpointIPtr& endpoint) const
{
    const EndpointI* endpointI = dynamic_cast<const EndpointI*>(endpoint.get());
    if(!endpointI)
    {
        return false;
    }
    return endpointI->_host == _host && endpointI->_port == _port;
}

bool
IceObjC::EndpointI::operator==(const Ice::LocalObject& r) const
{
    const EndpointI* p = dynamic_cast<const EndpointI*>(&r);
    if(!p)
    {
        return false;
    }

    if(this == p)
    {
        return true;
    }

    if(_host != p->_host)
    {
        return false;
    }

    if(_port != p->_port)
    {
        return false;
    }

    if(_timeout != p->_timeout)
    {
        return false;
    }

    if(_connectionId != p->_connectionId)
    {
        return false;
    }

    if(_compress != p->_compress)
    {
        return false;
    }

    return true;
}

bool
IceObjC::EndpointI::operator<(const Ice::LocalObject& r) const
{
    const EndpointI* p = dynamic_cast<const EndpointI*>(&r);
    if(!p)
    {
        const IceInternal::EndpointI* e = dynamic_cast<const IceInternal::EndpointI*>(&r);
        if(!e)
        {
            return false;
        }
        return type() < e->type();
    }

    if(this == p)
    {
        return false;
    }

    if(_host < p->_host)
    {
        return true;
    }
    else if (p->_host < _host)
    {
        return false;
    }

    if(_port < p->_port)
    {
        return true;
    }
    else if(p->_port < _port)
    {
        return false;
    }

    if(_timeout < p->_timeout)
    {
        return true;
    }
    else if(p->_timeout < _timeout)
    {
        return false;
    }

    if(_connectionId < p->_connectionId)
    {
        return true;
    }
    else if(p->_connectionId < _connectionId)
    {
        return false;
    }

    if(!_compress && p->_compress)
    {
        return true;
    }
    else if(p->_compress < _compress)
    {
        return false;
    }

    return false;
}

Ice::Int
IceObjC::EndpointI::hashInit() const
{
    Ice::Int h = 0;
    hashAdd(h, _host);
    hashAdd(h, _port);
    hashAdd(h, _timeout);
    hashAdd(h, _connectionId);
    hashAdd(h, _compress);
    return h;
}
 
IceObjC::EndpointFactory::EndpointFactory(const IceInternal::InstancePtr& instance, bool secure) : 
    _instance(new Instance(instance, secure))
{
}

IceObjC::EndpointFactory::~EndpointFactory()
{
}

Short
IceObjC::EndpointFactory::type() const
{
    return _instance->type();
}

string
IceObjC::EndpointFactory::protocol() const
{
    return _instance->protocol();
}

EndpointIPtr
IceObjC::EndpointFactory::create(const string& str, bool oaEndpoint) const
{
    return new EndpointI(_instance, str, oaEndpoint);
}

EndpointIPtr
IceObjC::EndpointFactory::read(BasicStream* s) const
{
    return new EndpointI(_instance, s);
}

void
IceObjC::EndpointFactory::destroy()
{
    _instance = 0;
}

