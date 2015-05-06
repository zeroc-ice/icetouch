// **********************************************************************
//
// Copyright (c) 2003-2014 ZeroC, Inc. All rights reserved.
//
// This copy of Ice Touch is licensed to you under the terms described in the
// ICE_TOUCH_LICENSE file included in this distribution.
//
// **********************************************************************

#ifndef ICE_OBJC_TRANSCEIVER_H
#define ICE_OBJC_TRANSCEIVER_H

#include <Ice/InstanceF.h>
#include <Ice/TraceLevelsF.h>
#include <Ice/LoggerF.h>
#include <Ice/StatsF.h>
#include <Ice/Transceiver.h>
#include <Ice/Network.h>
#include <CoreFoundation/CFStream.h>

namespace IceObjC
{

class Instance;
typedef IceUtil::Handle<Instance> InstancePtr;

class Transceiver : public IceInternal::Transceiver, public IceInternal::StreamNativeInfo
{
    enum State
    {
        StateNeedConnect,
        StateConnectPending,
        StateConnected
    };

public:

    Transceiver(const InstancePtr&, CFReadStreamRef, CFWriteStreamRef, const std::string&, Ice::Int);
    Transceiver(const InstancePtr&, CFReadStreamRef, CFWriteStreamRef, SOCKET);
    virtual ~Transceiver();

    virtual IceInternal::NativeInfoPtr getNativeInfo();

    virtual void initStreams(IceInternal::SelectorReadyCallback*);
    virtual IceInternal::SocketOperation registerWithRunLoop(IceInternal::SocketOperation);
    virtual IceInternal::SocketOperation unregisterFromRunLoop(IceInternal::SocketOperation, bool);
    virtual void closeStreams();

    virtual void close();
    virtual bool write(IceInternal::Buffer&);
    virtual bool read(IceInternal::Buffer&);
    virtual std::string type() const;
    virtual std::string toString() const;
    virtual IceInternal::SocketOperation initialize(IceInternal::Buffer&, IceInternal::Buffer&);
    virtual Ice::ConnectionInfoPtr getInfo() const;
    virtual void checkSendSize(const IceInternal::Buffer&, size_t);

private:    

    void checkCertificates();

    const InstancePtr _instance;
    const IceInternal::TraceLevelsPtr _traceLevels;
    const Ice::LoggerPtr _logger;
    const Ice::StatsPtr _stats;
    const std::string _host;
    const Ice::Int _port;
    CFReadStreamRef _readStream;
    CFWriteStreamRef _writeStream;
    bool _readStreamRegistered;
    bool _writeStreamRegistered;
    bool _opening;
    bool _checkCertificates;

    IceUtil::Mutex _mutex;
    bool _error;

    State _state;
    std::string _desc;
};

}

#endif
