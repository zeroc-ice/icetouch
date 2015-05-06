// **********************************************************************
//
// Copyright (c) 2003-2014 ZeroC, Inc. All rights reserved.
//
// This copy of Ice Touch is licensed to you under the terms described in the
// ICE_TOUCH_LICENSE file included in this distribution.
//
// **********************************************************************

#ifndef ICE_OBJC_ACCEPTOR_H
#define ICE_OBJC_ACCEPTOR_H

#include <Ice/TransceiverF.h>
#include <Ice/InstanceF.h>
#include <Ice/TraceLevelsF.h>
#include <Ice/LoggerF.h>
#include <Ice/Acceptor.h>

namespace IceObjC
{

class EndpointI;

class Instance;
typedef IceUtil::Handle<Instance> InstancePtr;

class Acceptor : public IceInternal::Acceptor, public IceInternal::NativeInfo
{
public:

    virtual IceInternal::NativeInfoPtr getNativeInfo();
    virtual void close();
    virtual void listen();
    virtual IceInternal::TransceiverPtr accept();
    virtual std::string toString() const;

    int effectivePort() const;

private:

    Acceptor(const InstancePtr&, const std::string&, int);
    virtual ~Acceptor();
    friend class EndpointI;

    InstancePtr _instance;
    IceInternal::TraceLevelsPtr _traceLevels;
    Ice::LoggerPtr _logger;
    int _backlog;
    IceInternal::Address _addr;
};

}

#endif
