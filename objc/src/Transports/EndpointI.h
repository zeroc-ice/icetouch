// **********************************************************************
//
// Copyright (c) 2003-2014 ZeroC, Inc. All rights reserved.
//
// This copy of Ice Touch is licensed to you under the terms described in the
// ICE_TOUCH_LICENSE file included in this distribution.
//
// **********************************************************************

#ifndef ICE_OBJC_ENDPOINT_I_H
#define ICE_OBJC_ENDPOINT_I_H

#include <Ice/Instance.h>
#include <Ice/EndpointI.h>
#include <Ice/EndpointFactory.h>

#include <CoreFoundation/CFDictionary.h>
#if TARGET_OS_IPHONE
#    include <CFNetwork/CFNetwork.h>
#else
#    include <CoreServices/CoreServices.h>
#endif

#include <Security/Security.h>

namespace IceObjC
{

const Ice::Short TcpEndpointType = 1;
const Ice::Short SslEndpointType = 2;

class Instance : public IceUtil::Shared
{
public:

    Instance(const IceInternal::InstancePtr&, bool);
    virtual ~Instance();

    Ice::Short type() const { return _type; }
    const std::string& protocol() const { return _protocol; }

    CFArrayRef certificateAuthorities() const { return _certificateAuthorities; }
    CFDataRef trustOnlyKeyID() const { return _trustOnlyKeyID; }
    IceInternal::TraceLevelsPtr traceLevels() const { return _instance->traceLevels(); }
    const Ice::InitializationData& initializationData() const { return _instance->initializationData(); }
    IceInternal::ProtocolSupport protocolSupport() const { return _instance->protocolSupport(); } 
    bool preferIPv6() const { return _instance->preferIPv6(); }
    IceInternal::DefaultsAndOverridesPtr defaultsAndOverrides() const { return _instance->defaultsAndOverrides(); }
    IceInternal::EndpointHostResolverPtr endpointHostResolver() const { return _instance->endpointHostResolver(); }

    void setupStreams(CFReadStreamRef, CFWriteStreamRef, bool, const std::string&) const;

    IceInternal::NetworkProxyPtr getProxy() const { return _instance->networkProxy(); }

private:

    const IceInternal::InstancePtr _instance;
    const Ice::Short _type;
    const bool _voip;
    const std::string _protocol;
    CFMutableDictionaryRef _serverSettings;
    CFMutableDictionaryRef _clientSettings;
    CFMutableDictionaryRef _proxySettings;
    CFArrayRef _certificateAuthorities;
    CFDataRef _trustOnlyKeyID;
};
typedef IceUtil::Handle<Instance> InstancePtr;

class EndpointI : public IceInternal::EndpointI
{
public:

    EndpointI(const InstancePtr&, const std::string&, Ice::Int, Ice::Int, const std::string&, bool);
    EndpointI(const InstancePtr&, const std::string&, bool);
    EndpointI(const InstancePtr&, IceInternal::BasicStream*);

    virtual void streamWrite(IceInternal::BasicStream*) const;
    virtual std::string toString() const;
    virtual Ice::EndpointInfoPtr getInfo() const;
    virtual Ice::Short type() const;
    virtual std::string protocol() const;
    virtual Ice::Int timeout() const;
    virtual IceInternal::EndpointIPtr timeout(Ice::Int) const;
    virtual IceInternal::EndpointIPtr connectionId(const std::string&) const;
    virtual bool compress() const;
    virtual IceInternal::EndpointIPtr compress(bool) const;
    virtual bool datagram() const;
    virtual bool secure() const;
    virtual bool unknown() const;
    virtual IceInternal::TransceiverPtr transceiver(IceInternal::EndpointIPtr&) const;
    virtual std::vector<IceInternal::ConnectorPtr> connectors(Ice::EndpointSelectionType) const;
    virtual void connectors_async(Ice::EndpointSelectionType, const IceInternal::EndpointI_connectorsPtr&) const;
    virtual IceInternal::AcceptorPtr acceptor(IceInternal::EndpointIPtr&, const std::string&) const;
    virtual std::vector<IceInternal::EndpointIPtr> expand() const;
    virtual bool equivalent(const IceInternal::EndpointIPtr&) const;

    virtual bool operator==(const Ice::LocalObject&) const;
    virtual bool operator<(const Ice::LocalObject&) const;

private:

    virtual ::Ice::Int hashInit() const;

    //
    // All members are const, because endpoints are immutable.
    //
    const InstancePtr _instance;
    const std::string _host;
    const Ice::Int _port;
    const Ice::Int _timeout;
    const bool _compress;
};

class EndpointFactory : public IceInternal::EndpointFactory
{
public:

    EndpointFactory(const IceInternal::InstancePtr&, bool);

    virtual ~EndpointFactory();

    virtual Ice::Short type() const;
    virtual std::string protocol() const;
    virtual IceInternal::EndpointIPtr create(const std::string&, bool) const;
    virtual IceInternal::EndpointIPtr read(IceInternal::BasicStream*) const;
    virtual void destroy();

private:

    InstancePtr _instance;
};

}

#endif
