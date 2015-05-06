// **********************************************************************
//
// Copyright (c) 2003-2014 ZeroC, Inc. All rights reserved.
//
// This copy of Ice Touch is licensed to you under the terms described in the
// ICE_TOUCH_LICENSE file included in this distribution.
//
// **********************************************************************

#ifndef ICE_OBJC_ACCESSORY_TRANSCEIVER_H
#define ICE_OBJC_ACCESSORY_TRANSCEIVER_H

#include <Ice/InstanceF.h>
#include <Ice/TraceLevelsF.h>
#include <Ice/LoggerF.h>
#include <Ice/StatsF.h>
#include <Ice/Transceiver.h>

#import <Foundation/Foundation.h>
#import <ExternalAccessory/ExternalAccessory.h>

@class AccessoryTransceiverCallback;

namespace IceObjC
{

class AccessoryTransceiver : public IceInternal::Transceiver, public IceInternal::StreamNativeInfo
{
    enum State
    {
        StateNeedConnect,
        StateConnectPending,
        StateConnected
    };

public:

    AccessoryTransceiver(const IceInternal::InstancePtr&, EASession*);
    virtual ~AccessoryTransceiver();

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
    

    const IceInternal::TraceLevelsPtr _traceLevels;
    const Ice::LoggerPtr _logger;
    const Ice::StatsPtr _stats;
    NSInputStream* _readStream;
    NSOutputStream* _writeStream;
    AccessoryTransceiverCallback* _callback;
    bool _readStreamRegistered;
    bool _writeStreamRegistered;
    bool _opening;

    State _state;
    std::string _desc;
};

}

#endif
