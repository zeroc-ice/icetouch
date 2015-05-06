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
#include <AccessoryConnector.h>

#include <Ice/Instance.h>
#include <Ice/TraceLevels.h>
#include <Ice/LoggerUtil.h>
#include <Ice/Network.h>
#include <Ice/Exception.h>

using namespace std;
using namespace Ice;
using namespace IceInternal;

TransceiverPtr
IceObjC::AccessoryConnector::connect()
{
    if(_traceLevels->network >= 2)
    {
        Trace out(_logger, _traceLevels->networkCat);
        out << "trying to establish accessory connection to " << toString();
    }

    try
    {
        EASession* session = [[EASession alloc] initWithAccessory:_accessory forProtocol:_protocol];
        if(!session)
        {
            throw Ice::ConnectFailedException(__FILE__, __LINE__, 0);
        }
        return new AccessoryTransceiver(_instance, session);
    }
    catch(const Ice::LocalException& ex)
    {
        if(_traceLevels->network >= 2)
        {
            Trace out(_logger, _traceLevels->networkCat);
            out << "failed to establish accessory connection to " << toString() << "\n" << ex;
        }
        throw;
    }
}

Short
IceObjC::AccessoryConnector::type() const
{
    return AccessoryEndpointType;
}

string
IceObjC::AccessoryConnector::toString() const
{
    ostringstream os;
    os << [_accessory.name UTF8String];
    os << " model `" << [_accessory.modelNumber UTF8String] << "'";
    os << " made by `" << [_accessory.manufacturer UTF8String] << "'";
    os << " protocol `" << [_protocol UTF8String] << "'";
    return os.str();
}

bool
IceObjC::AccessoryConnector::operator==(const IceInternal::Connector& r) const
{
    const AccessoryConnector* p = dynamic_cast<const AccessoryConnector*>(&r);
    if(!p)
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

    if(![_accessory isEqual:p->_accessory])
    {
        return false;
    }
    
    if(![_protocol isEqual:p->_protocol])
    {
        return false;
    }

    return true;
}

bool
IceObjC::AccessoryConnector::operator!=(const IceInternal::Connector& r) const
{
    return !operator==(r);
}

bool
IceObjC::AccessoryConnector::operator<(const IceInternal::Connector& r) const
{
    const AccessoryConnector* p = dynamic_cast<const AccessoryConnector*>(&r);
    if(!p)
    {
        return type() < r.type();
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

    if([_accessory hash] < [p->_accessory hash])
    {
        return true;
    }
    else if([p->_accessory hash] < [_accessory hash])
    {
        return false;
    }

    NSInteger order = [_protocol compare:p->_protocol];
    if(order == NSOrderedAscending)
    {
        return true;
    }
    else if(order == NSOrderedDescending)
    {
        return false;
    }

    return false;
}

IceObjC::AccessoryConnector::AccessoryConnector(const IceInternal::InstancePtr& instance, 
                                                Ice::Int timeout, 
                                                const string& connectionId,
                                                NSString* protocol,
                                                EAAccessory* accessory) :
    _instance(instance),
    _traceLevels(instance->traceLevels()),
    _logger(instance->initializationData().logger),
    _timeout(timeout),
    _connectionId(connectionId),
    _protocol([protocol retain]),
    _accessory([accessory retain])
{
}

IceObjC::AccessoryConnector::~AccessoryConnector()
{
    [_protocol release];
    [_accessory release];
}
