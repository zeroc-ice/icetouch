// **********************************************************************
//
// Copyright (c) 2003-2014 ZeroC, Inc. All rights reserved.
//
// This copy of Ice Touch is licensed to you under the terms described in the
// ICE_TOUCH_LICENSE file included in this distribution.
//
// **********************************************************************

#ifndef ICE_OBJC_ACESSORY_ENDPOINT_I_H
#define ICE_OBJC_ACESSORY_ENDPOINT_I_H

#include <Ice/InstanceF.h>
#include <Ice/EndpointI.h>
#include <Ice/EndpointFactory.h>

namespace IceObjC
{

const Ice::Short AccessoryEndpointType = 4;

class AccessoryEndpointI : public IceInternal::EndpointI
{
public:

    AccessoryEndpointI(const IceInternal::InstancePtr&, const std::string&, const std::string&, const std::string&,
                       const std::string&, Ice::Int, const std::string&, bool);
    AccessoryEndpointI(const IceInternal::InstancePtr&, const std::string&);
    AccessoryEndpointI(const IceInternal::InstancePtr&, IceInternal::BasicStream*);

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
    const IceInternal::InstancePtr _instance;
    const std::string _manufacturer;
    const std::string _modelNumber;
    const std::string _name;
    const std::string _protocol;
    const Ice::Int _timeout;
    const std::string _connectionId;
    const bool _compress;
};

class AccessoryEndpointFactory : public IceInternal::EndpointFactory
{
public:

    AccessoryEndpointFactory(const IceInternal::InstancePtr&);

    virtual ~AccessoryEndpointFactory();

    virtual Ice::Short type() const;
    virtual std::string protocol() const;
    virtual IceInternal::EndpointIPtr create(const std::string&, bool) const;
    virtual IceInternal::EndpointIPtr read(IceInternal::BasicStream*) const;
    virtual void destroy();

private:

    IceInternal::InstancePtr _instance;
};

}

#endif
