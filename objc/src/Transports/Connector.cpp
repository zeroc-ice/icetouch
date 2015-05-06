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
#include <Connector.h>

#include <Ice/Instance.h>
#include <Ice/TraceLevels.h>
#include <Ice/LoggerUtil.h>
#include <Ice/Network.h>
#include <Ice/Exception.h>
#include <Ice/Properties.h>

#include <CoreFoundation/CoreFoundation.h>

using namespace std;
using namespace Ice;
using namespace IceInternal;

TransceiverPtr
IceObjC::Connector::connect()
{
    if(_traceLevels->network >= 2)
    {
        Trace out(_logger, _traceLevels->networkCat);
        out << "trying to establish " << _instance->protocol() << " connection to " << toString();
    }

    CFReadStreamRef readStream = nil;
    CFWriteStreamRef writeStream = nil;
    try
    {
        CFStringRef h = CFStringCreateWithCString(NULL, _host.c_str(), kCFStringEncodingUTF8);
        CFHostRef host = CFHostCreateWithName(NULL, h);
        CFRelease(h);
        CFStreamCreatePairWithSocketToCFHost(NULL, host, _port, &readStream, &writeStream);
        CFRelease(host);

        _instance->setupStreams(readStream, writeStream, false, _host);
        return new Transceiver(_instance, readStream, writeStream, _host, _port);
    }
    catch(const Ice::LocalException& ex)
    {
        if(readStream)
        {
            CFRelease(readStream);
        }
        if(writeStream)
        {
            CFRelease(writeStream);
        }
        if(_traceLevels->network >= 2)
        {
            Trace out(_logger, _traceLevels->networkCat);
            out << "failed to establish " << _instance->protocol() << " connection to " << toString() << "\n" << ex;
        }
        throw;
    }
}

Short
IceObjC::Connector::type() const
{
    return _instance->type();
}

string
IceObjC::Connector::toString() const
{
    ostringstream os;
    IceInternal::NetworkProxyPtr proxy = _instance->getProxy();
    if(!proxy)
    {
        os << _host << ":" << _port;
    }
    else
    {
        os << proxy->getHost() << ":" << proxy->getPort();
    }
    return os.str();
}

bool
IceObjC::Connector::operator==(const IceInternal::Connector& r) const
{
    const Connector* p = dynamic_cast<const Connector*>(&r);
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

    if(_host != p->_host)
    {
        return false;
    }

    if(_port != p->_port)
    {
        return false;
    }

    return true;
}

bool
IceObjC::Connector::operator!=(const IceInternal::Connector& r) const
{
    return !operator==(r);
}

bool
IceObjC::Connector::operator<(const IceInternal::Connector& r) const
{
    const Connector* p = dynamic_cast<const Connector*>(&r);
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

    if(_host < p->_host)
    {
        return true;
    }
    else if(p->_host < _host)
    {
        return false;
    }

    return _port < p->_port;
}

IceObjC::Connector::Connector(const InstancePtr& instance, 
                              Ice::Int timeout, 
                              const string& connectionId,
                              const string& host,
                              Ice::Int port) :
    _instance(instance),
    _traceLevels(instance->traceLevels()),
    _logger(instance->initializationData().logger),
    _timeout(timeout),
    _connectionId(connectionId),
    _host(host.empty() ? string("127.0.0.1") : host),
    _port(port)
{
}

IceObjC::Connector::~Connector()
{
}
