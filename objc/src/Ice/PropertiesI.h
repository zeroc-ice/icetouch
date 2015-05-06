// **********************************************************************
//
// Copyright (c) 2003-2014 ZeroC, Inc. All rights reserved.
//
// This copy of Ice Touch is licensed to you under the terms described in the
// ICE_TOUCH_LICENSE file included in this distribution.
//
// **********************************************************************

#import <Ice/Properties.h>
#import <Ice/Wrapper.h>

#include <IceCpp/Properties.h>
#include <IceCpp/NativePropertiesAdmin.h>

@interface ICEProperties : ICEInternalWrapper<ICEProperties>
{
    Ice::Properties* properties_;
}
-(Ice::Properties*)properties;
@end

@interface ICEPropertiesAdminUpdateCallback ()
-(void) setPropertiesAdminUpdateCallback:(Ice::PropertiesAdminUpdateCallback*)callback;
-(Ice::PropertiesAdminUpdateCallback*) propertiesAdminUpdateCallback;
@end

@interface ICENativePropertiesAdmin : ICEInternalWrapper<ICENativePropertiesAdmin>
@end