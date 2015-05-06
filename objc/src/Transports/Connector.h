// **********************************************************************
//
// Copyright (c) 2003-2014 ZeroC, Inc. All rights reserved.
//
// This copy of Ice Touch is licensed to you under the terms described in the
// ICE_TOUCH_LICENSE file included in this distribution.
//
// **********************************************************************

#ifndef ICE_OBJC_CONNECTOR_H
#define ICE_OBJC_CONNECTOR_H

#include <Ice/TransceiverF.h>
#include <Ice/InstanceF.h>
#include <Ice/TraceLevelsF.h>
#include <Ice/LoggerF.h>
#include <Ice/Connector.h>

#ifdef _WIN32
#   include <winsock2.h>
#else
#   include <sys/socket.h>
#endif

namespace IceObjC
{

class EndpointI;

class Instance;
typedef IceUtil::Handle<Instance> InstancePtr;

class Connector : public IceInternal::Connector
{
public:
    
    virtual IceInternal::TransceiverPtr connect();

    virtual Ice::Short type() const;
    virtual std::string toString() const;

    virtual bool operator==(const IceInternal::Connector&) const;
    virtual bool operator!=(const IceInternal::Connector&) const;
    virtual bool operator<(const IceInternal::Connector&) const;

private:
    
    Connector(const InstancePtr&, Ice::Int, const std::string&, const std::string&, Ice::Int);
    virtual ~Connector();
    friend class EndpointI;

    const InstancePtr _instance;
    const IceInternal::TraceLevelsPtr _traceLevels;
    const Ice::LoggerPtr _logger;
    const Ice::Int _timeout;
    const std::string _connectionId;
    const std::string _host;
    const Ice::Int _port;
};

}

#endif
