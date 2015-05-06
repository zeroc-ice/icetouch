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
#include <Acceptor.h>

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

IceInternal::NativeInfoPtr
IceObjC::Acceptor::getNativeInfo()
{
    return this;
}

void
IceObjC::Acceptor::close()
{
    if(_traceLevels->network >= 1)
    {
        Trace out(_logger, _traceLevels->networkCat);
        out << "stopping to accept " << _instance->protocol() << " connections at " << toString();
    }

    SOCKET fd = _fd;
    _fd = INVALID_SOCKET;
    closeSocket(fd);
}

void
IceObjC::Acceptor::listen()
{
    try
    {
        doListen(_fd, _backlog);
    }
    catch(...)
    {
        _fd = INVALID_SOCKET;
        throw;
    }

    if(_traceLevels->network >= 1)
    {
        Trace out(_logger, _traceLevels->networkCat);
        out << "accepting " << _instance->protocol() << " connections at " << toString();
    }
}

TransceiverPtr
IceObjC::Acceptor::accept()
{
    SOCKET fd = doAccept(_fd);
    setBlock(fd, false);
    setTcpBufSize(fd, _instance->initializationData().properties, _logger);

    if(_traceLevels->network >= 1)
    {
        Trace out(_logger, _traceLevels->networkCat);
        out << "accepting " << _instance->protocol() << " connection\n" << fdToString(fd);
    }

    //
    // Create the read/write streams
    //
    CFReadStreamRef readStream = nil;
    CFWriteStreamRef writeStream = nil;
    try
    {
        CFStreamCreatePairWithSocket(NULL, fd, &readStream, &writeStream);
        _instance->setupStreams(readStream, writeStream, true, "");
        return new Transceiver(_instance, readStream, writeStream, fd);
    }
    catch(const Ice::LocalException& ex)
    {
        if(fd != INVALID_SOCKET)
        {
            closeSocketNoThrow(fd);
        }
        if(readStream)
        {
            CFRelease(readStream);
        }
        if(writeStream)
        {
            CFRelease(writeStream);
        }
        throw;
    }
}

string
IceObjC::Acceptor::toString() const
{
    return addrToString(_addr);
}

int
IceObjC::Acceptor::effectivePort() const
{
    return getPort(_addr);
}

IceObjC::Acceptor::Acceptor(const InstancePtr& instance, const string& host, int port) :
    _instance(instance),
    _traceLevels(instance->traceLevels()),
    _logger(instance->initializationData().logger),
    _addr(getAddressForServer(host, port, instance->protocolSupport(), instance->preferIPv6()))
{
#ifdef SOMAXCONN
    _backlog = instance->initializationData().properties->getPropertyAsIntWithDefault("Ice.TCP.Backlog", SOMAXCONN);
#else
    _backlog = instance->initializationData().properties->getPropertyAsIntWithDefault("Ice.TCP.Backlog", 511);
#endif

    try
    {
        _fd = createSocket(false, _addr);
        setBlock(_fd, false);
        setTcpBufSize(_fd, _instance->initializationData().properties, _logger);
#ifndef _WIN32
        //
        // Enable SO_REUSEADDR on Unix platforms to allow re-using the
        // socket even if it's in the TIME_WAIT state. On Windows,
        // this doesn't appear to be necessary and enabling
        // SO_REUSEADDR would actually not be a good thing since it
        // allows a second process to bind to an address even it's
        // already bound by another process.
        //
        // TODO: using SO_EXCLUSIVEADDRUSE on Windows would probably
        // be better but it's only supported by recent Windows
        // versions (XP SP2, Windows Server 2003).
        //
        setReuseAddress(_fd, true);
#endif
        if(_traceLevels->network >= 2)
        {
            Trace out(_logger, _traceLevels->networkCat);
            out << "attempting to bind to " << _instance->protocol() << " socket " << toString();
        }
        const_cast<Address&>(_addr) = doBind(_fd, _addr);
    }
    catch(...)
    {
        _fd = INVALID_SOCKET;
        throw;
    }
}

IceObjC::Acceptor::~Acceptor()
{
    assert(_fd == INVALID_SOCKET);
}
