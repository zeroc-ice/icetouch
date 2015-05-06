// **********************************************************************
//
// Copyright (c) 2003-2014 ZeroC, Inc. All rights reserved.
//
// This copy of Ice Touch is licensed to you under the terms described in the
// ICE_TOUCH_LICENSE file included in this distribution.
//
// **********************************************************************

#import <Ice/Initialize.h>
#import <Ice/Wrapper.h>
#import <Ice/Connection.h>

#include <IceCpp/Dispatcher.h>

@interface ICEDispatcher : NSObject
+(Ice::Dispatcher*)dispatcherWithDispatcher:(void(^)(id<ICEDispatcherCall>, id<ICEConnection>))arg;
@end

@interface ICEDispatcherCall : NSObject<ICEDispatcherCall>
{
    Ice::DispatcherCall* cxxCall_;
}
-(id) initWithCall:(Ice::DispatcherCall*)call;
@end

