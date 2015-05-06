// **********************************************************************
//
// Copyright (c) 2003-2014 ZeroC, Inc. All rights reserved.
//
// This copy of Ice Touch is licensed to you under the terms described in the
// ICE_TOUCH_LICENSE file included in this distribution.
//
// **********************************************************************

#include <Ice/EndpointFactoryManager.h>
#include <Ice/Instance.h>

#include <EndpointI.h>
#include <AccessoryEndpointI.h>

extern "C"
{

using namespace IceInternal;

void
registerEndpointFactories(const EndpointFactoryManagerPtr& manager, const InstancePtr& instance)
{
    manager->add(new IceObjC::EndpointFactory(instance, false));
    manager->add(new IceObjC::EndpointFactory(instance, true));
    manager->add(new IceObjC::AccessoryEndpointFactory(instance));
}

}
