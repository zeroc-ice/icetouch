// **********************************************************************
//
// Copyright (c) 2003-2014 ZeroC, Inc. All rights reserved.
//
// This copy of Ice Touch is licensed to you under the terms described in the
// ICE_TOUCH_LICENSE file included in this distribution.
//
// **********************************************************************

#ifndef ICE_OBJC_ACCESSORY_CONNECTOR_H
#define ICE_OBJC_ACCESSORY_CONNECTOR_H

#include <Ice/TransceiverF.h>
#include <Ice/InstanceF.h>
#include <Ice/TraceLevelsF.h>
#include <Ice/LoggerF.h>
#include <Ice/Connector.h>

#import <Foundation/Foundation.h>
#import <ExternalAccessory/ExternalAccessory.h>

namespace IceObjC
{

class AccessoryEndpointI;

class Instance;
typedef IceUtil::Handle<Instance> InstancePtr;

class AccessoryConnector : public IceInternal::Connector
{
public:
    
    virtual IceInternal::TransceiverPtr connect();

    virtual Ice::Short type() const;
    virtual std::string toString() const;

    virtual bool operator==(const IceInternal::Connector&) const;
    virtual bool operator!=(const IceInternal::Connector&) const;
    virtual bool operator<(const IceInternal::Connector&) const;

private:
    
    AccessoryConnector(const IceInternal::InstancePtr&, Ice::Int, const std::string&, NSString*, EAAccessory*);
    virtual ~AccessoryConnector();
    friend class AccessoryEndpointI;

    const IceInternal::InstancePtr _instance;
    const IceInternal::TraceLevelsPtr _traceLevels;
    const Ice::LoggerPtr _logger;
    const Ice::Int _timeout;
    const std::string _connectionId;
    NSString* _protocol;
    EAAccessory* _accessory;
};

}

#endif
