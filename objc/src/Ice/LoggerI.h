// **********************************************************************
//
// Copyright (c) 2003-2014 ZeroC, Inc. All rights reserved.
//
// This copy of Ice Touch is licensed to you under the terms described in the
// ICE_TOUCH_LICENSE file included in this distribution.
//
// **********************************************************************

#import <Ice/Logger.h>
#import <Ice/Wrapper.h>

#include <IceCpp/Logger.h>

@interface ICELogger : NSObject<ICELogger>
{
}
+(Ice::Logger*)loggerWithLogger:(id<ICELogger>)arg;
+(id) wrapperWithCxxObject:(IceUtil::Shared*)cxxObject;
@end
