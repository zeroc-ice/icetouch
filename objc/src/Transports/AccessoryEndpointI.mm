// **********************************************************************
//
// Copyright (c) 2003-2014 ZeroC, Inc. All rights reserved.
//
// This copy of Ice Touch is licensed to you under the terms described in the
// ICE_TOUCH_LICENSE file included in this distribution.
//
// **********************************************************************

#include <AccessoryEndpointI.h>
#include <AccessoryConnector.h>

#include <Ice/Network.h>
#include <Ice/BasicStream.h>
#include <Ice/LocalException.h>
#include <Ice/Instance.h>
#include <Ice/DefaultsAndOverrides.h>
#include <Ice/Initialize.h>
#include <Ice/EndpointFactoryManager.h>
#include <Ice/Properties.h>
#include <Ice/HashUtil.h>

#include <CoreFoundation/CoreFoundation.h>

#include <fstream>

using namespace std;
using namespace Ice;
using namespace IceInternal;

IceObjC::AccessoryEndpointI::AccessoryEndpointI(const IceInternal::InstancePtr& instance, const string& m,
                                                const string& o, const string& n, const string& p, Int ti, 
                                                const string& conId, bool co) :
    _instance(instance),
    _manufacturer(m),
    _modelNumber(o),
    _name(n),
    _protocol(p),
    _timeout(ti),
    _connectionId(conId),
    _compress(co)
{
}

IceObjC::AccessoryEndpointI::AccessoryEndpointI(const IceInternal::InstancePtr& instance, const string& str) :
    _instance(instance),
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
            ex.str = "accessory " + str;
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
            case 'm':
            {
                if(argument.empty())
                {
                    EndpointParseException ex(__FILE__, __LINE__);
                    ex.str = "accessory " + str;
                    throw ex;
                }
                const_cast<string&>(_manufacturer) = argument;
                break;
            }

            case 'o':
            {
                if(argument.empty())
                {
                    EndpointParseException ex(__FILE__, __LINE__);
                    ex.str = "accessory " + str;
                    throw ex;
                }
                const_cast<string&>(_modelNumber) = argument;
                break;
            }

            case 'n':
            {
                if(argument.empty())
                {
                    EndpointParseException ex(__FILE__, __LINE__);
                    ex.str = "accessory " + str;
                    throw ex;
                }
                const_cast<string&>(_name) = argument;
                break;
            }

            case 'p':
            {
                if(argument.empty())
                {
                    EndpointParseException ex(__FILE__, __LINE__);
                    ex.str = "accessory " + str;
                    throw ex;
                }
                const_cast<string&>(_protocol) = argument;
                break;
            }

            case 't':
            {
                istringstream t(argument);
                if(!(t >> const_cast<Int&>(_timeout)) || !t.eof())
                {
                    EndpointParseException ex(__FILE__, __LINE__);
                    ex.str = "accessory " + str;
                    throw ex;
                }
                break;
            }

            case 'z':
            {
                if(!argument.empty())
                {
                    EndpointParseException ex(__FILE__, __LINE__);
                    ex.str = "accessory " + str;
                    throw ex;
                }
                const_cast<bool&>(_compress) = true;
                break;
            }

            default:
            {
                EndpointParseException ex(__FILE__, __LINE__);
                ex.str = "accessory " + str;
                throw ex;
            }
        }
    }
}

IceObjC::AccessoryEndpointI::AccessoryEndpointI(const IceInternal::InstancePtr& instance, BasicStream* s) :
    _instance(instance),
    _timeout(-1),
    _compress(false)
{
    s->startReadEncaps();
    s->read(const_cast<string&>(_manufacturer), false);
    s->read(const_cast<string&>(_modelNumber), false);
    s->read(const_cast<string&>(_name), false);
    s->read(const_cast<Int&>(_timeout));
    s->read(const_cast<bool&>(_compress));
    s->endReadEncaps();
}

void
IceObjC::AccessoryEndpointI::streamWrite(BasicStream* s) const
{
    s->write(AccessoryEndpointType);
    s->startWriteEncaps();
    s->write(_manufacturer, false);
    s->write(_modelNumber, false);
    s->write(_name, false);
    s->write(_timeout);
    s->write(_compress);
    s->endWriteEncaps();
}

string
IceObjC::AccessoryEndpointI::toString() const
{
    //
    // WARNING: Certain features, such as proxy validation in Glacier2,
    // depend on the format of proxy strings. Changes to toString() and
    // methods called to generate parts of the reference string could break
    // these features. Please review for all features that depend on the
    // format of proxyToString() before changing this and related code.
    //
    ostringstream s;
    s << "accessory";

    if(!_manufacturer.empty())
    {
        s << " -m ";
        bool addQuote = _manufacturer.find(':') != string::npos;
        if(addQuote)
        {
            s << "\"";
        }
        s << _manufacturer;
        if(addQuote)
        {
            s << "\"";
        }
    }

    if(!_modelNumber.empty())
    {
        s << " -o ";
        bool addQuote = _modelNumber.find(':') != string::npos;
        if(addQuote)
        {
            s << "\"";
        }
        s << _modelNumber;
        if(addQuote)
        {
            s << "\"";
        }
    }

    if(!_name.empty())
    {
        s << " -n ";
        bool addQuote = _name.find(':') != string::npos;
        if(addQuote)
        {
            s << "\"";
        }
        s << _name;
        if(addQuote)
        {
            s << "\"";
        }
    }

    if(!_protocol.empty())
    {
        s << " -p ";
        bool addQuote = _protocol.find(':') != string::npos;
        if(addQuote)
        {
            s << "\"";
        }
        s << _protocol;
        if(addQuote)
        {
            s << "\"";
        }
    }

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
IceObjC::AccessoryEndpointI::getInfo() const
{
    return 0;
}

Short
IceObjC::AccessoryEndpointI::type() const
{
    return AccessoryEndpointType;
}

string
IceObjC::AccessoryEndpointI::protocol() const
{
    return "accessory";
}

Int
IceObjC::AccessoryEndpointI::timeout() const
{
    return _timeout;
}

EndpointIPtr
IceObjC::AccessoryEndpointI::timeout(Int timeout) const
{
    if(timeout == _timeout)
    {
        return const_cast<AccessoryEndpointI*>(this);
    }
    else
    {
        return new AccessoryEndpointI(_instance, _manufacturer, _modelNumber, _name, _protocol, timeout,
                                      _connectionId, _compress);
    }
}

EndpointIPtr
IceObjC::AccessoryEndpointI::connectionId(const string& connectionId) const
{
    if(connectionId == _connectionId)
    {
        return const_cast<AccessoryEndpointI*>(this);
    }
    else
    {
        return new AccessoryEndpointI(_instance, _manufacturer, _modelNumber, _name, _protocol, _timeout, connectionId,
                                      _compress);
    }
}

bool
IceObjC::AccessoryEndpointI::compress() const
{
    return _compress;
}

EndpointIPtr
IceObjC::AccessoryEndpointI::compress(bool compress) const
{
    if(compress == _compress)
    {
        return const_cast<AccessoryEndpointI*>(this);
    }
    else
    {
        return new AccessoryEndpointI(_instance, _manufacturer, _modelNumber, _name, _protocol, _timeout,
                                      _connectionId, compress);
    }
}

bool
IceObjC::AccessoryEndpointI::datagram() const
{
    return false;
}

bool
IceObjC::AccessoryEndpointI::secure() const
{
    return false;
}

bool
IceObjC::AccessoryEndpointI::unknown() const
{
    return false;
}

TransceiverPtr
IceObjC::AccessoryEndpointI::transceiver(EndpointIPtr& endp) const
{
    endp = const_cast<AccessoryEndpointI*>(this);
    return 0;
}

vector<ConnectorPtr>
IceObjC::AccessoryEndpointI::connectors(Ice::EndpointSelectionType) const
{
    vector<ConnectorPtr> c;
    
    EAAccessoryManager* manager = [EAAccessoryManager sharedAccessoryManager];
    if(manager == nil)
    {
        throw Ice::ConnectFailedException(__FILE__, __LINE__, 0);
    }

    NSString* protocol = _protocol.empty() ? @"com.zeroc.ice" : [[NSString alloc] initWithUTF8String:_protocol.c_str()];
    NSArray* array = [manager connectedAccessories];
    NSEnumerator* enumerator = [array objectEnumerator];
    EAAccessory* accessory = nil;
    int lastError = 0;
    while((accessory = [enumerator nextObject]))
    { 
        if(!accessory.connected)
        {
            lastError = 1;
            continue;
        }

        if(!_manufacturer.empty() && _manufacturer != [accessory.manufacturer UTF8String])
        {
            lastError = 2;
            continue;
        }
        if(!_modelNumber.empty() && _modelNumber != [accessory.modelNumber UTF8String])
        {
            lastError = 3;
            continue;
        }
        if(!_name.empty() && _name != [accessory.name UTF8String])
        {
            lastError = 4;
            continue;
        }

        if(![accessory.protocolStrings containsObject:protocol])
        {
            lastError = 5;
            continue;
        }

        c.push_back(new AccessoryConnector(_instance, _timeout, _connectionId, protocol, accessory));
    }
    [protocol release];
    if(c.empty())
    {
        throw Ice::ConnectFailedException(__FILE__, __LINE__, 0);
    }
    return c;
}

void
IceObjC::AccessoryEndpointI::connectors_async(Ice::EndpointSelectionType selType,
                                              const EndpointI_connectorsPtr& callback) const
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
IceObjC::AccessoryEndpointI::acceptor(EndpointIPtr& endp, const string&) const
{
    assert(false);
    return 0;
}

vector<EndpointIPtr>
IceObjC::AccessoryEndpointI::expand() const
{
    vector<EndpointIPtr> endps;
    endps.push_back(const_cast<AccessoryEndpointI*>(this));
    return endps;
}

bool
IceObjC::AccessoryEndpointI::equivalent(const EndpointIPtr& endpoint) const
{
    const AccessoryEndpointI* endpointI = dynamic_cast<const AccessoryEndpointI*>(endpoint.get());
    if(!endpointI)
    {
        return false;
    }
    return endpointI->_manufacturer == _manufacturer && 
           endpointI->_modelNumber == _modelNumber &&
           endpointI->_name == _name;
}

bool
IceObjC::AccessoryEndpointI::operator==(const Ice::LocalObject& r) const
{
    const AccessoryEndpointI* p = dynamic_cast<const AccessoryEndpointI*>(&r);
    if(!p)
    {
        return false;
    }

    if(this == p)
    {
        return true;
    }

    if(_manufacturer != p->_manufacturer)
    {
        return false;
    }

    if(_modelNumber != p->_modelNumber)
    {
        return false;
    }

    if(_name != p->_name)
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
IceObjC::AccessoryEndpointI::operator<(const Ice::LocalObject& r) const
{
    const AccessoryEndpointI* p = dynamic_cast<const AccessoryEndpointI*>(&r);
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

    if(_manufacturer < p->_manufacturer)
    {
        return true;
    }
    else if(p->_manufacturer < _manufacturer)
    {
        return false;
    }

    if(_modelNumber < p->_modelNumber)
    {
        return true;
    }
    else if(p->_modelNumber < _modelNumber)
    {
        return false;
    }

    if(_name < p->_name)
    {
        return true;
    }
    else if(p->_name < _name)
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
IceObjC::AccessoryEndpointI::hashInit() const
{
    Ice::Int h = 0;
    hashAdd(h, _manufacturer);
    hashAdd(h, _modelNumber);
    hashAdd(h, _name);
    hashAdd(h, _timeout);
    hashAdd(h, _connectionId);
    return h;
}
 
IceObjC::AccessoryEndpointFactory::AccessoryEndpointFactory(const IceInternal::InstancePtr& instance) : 
    _instance(instance)
{
}

IceObjC::AccessoryEndpointFactory::~AccessoryEndpointFactory()
{
}

Short
IceObjC::AccessoryEndpointFactory::type() const
{
    return AccessoryEndpointType;
}

string
IceObjC::AccessoryEndpointFactory::protocol() const
{
    return "accessory";
}

EndpointIPtr
IceObjC::AccessoryEndpointFactory::create(const string& str, bool oaEndpoint) const
{
    if(oaEndpoint)
    {
        return 0;
    }
    return new AccessoryEndpointI(_instance, str);
}

EndpointIPtr
IceObjC::AccessoryEndpointFactory::read(BasicStream* s) const
{
    return new AccessoryEndpointI(_instance, s);
}

void
IceObjC::AccessoryEndpointFactory::destroy()
{
    _instance = 0;
}
