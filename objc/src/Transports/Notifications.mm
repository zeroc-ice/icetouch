// **********************************************************************
//
// Copyright (c) 2003-2014 ZeroC, Inc. All rights reserved.
//
// This copy of Ice Touch is licensed to you under the terms described in the
// ICE_TOUCH_LICENSE file included in this distribution.
//
// **********************************************************************

#import <Ice/Config.h>

#if TARGET_OS_IPHONE != 0

#import <Foundation/NSObject.h>
#import <Foundation/NSNotification.h>
#import <UIKit/UIApplication.h>

#include <Ice/ConnectionFactory.h>

#include <set>

namespace IceObjC
{

bool registerForBackgroundNotification(IceInternal::IncomingConnectionFactory*);
void unregisterForBackgroundNotification(IceInternal::IncomingConnectionFactory*);

}

namespace
{

std::set<IceInternal::IncomingConnectionFactory*> factories;

}

@interface Observer : NSObject
{
    BOOL background;
}
@end

static Observer* observer = nil;

@implementation Observer
+(void) initialize
{
    observer = [[Observer alloc] init];
    observer->background = NO;

    [[NSNotificationCenter defaultCenter] addObserver:observer
                                             selector:@selector(didEnterBackground) 
                                                 name:UIApplicationDidEnterBackgroundNotification
                                               object:nil]; 

    [[NSNotificationCenter defaultCenter] addObserver:observer
                                             selector:@selector(willEnterForeground) 
                                                 name:UIApplicationWillEnterForegroundNotification
                                               object:nil];
}
+(Observer*) sharedInstance
{
    return observer;
}
-(BOOL)add:(IceInternal::IncomingConnectionFactory*)factory
{
    @synchronized(self)
    {
        factories.insert(factory);
        return self->background;
    }
}
-(void)remove:(IceInternal::IncomingConnectionFactory*)factory
{
    @synchronized(self)
    {
        factories.erase(factory);
    }
}
-(void)didEnterBackground
{
    @synchronized(self)
    {
        //
        // Notify all the incoming connection factories that we are
        // entering the background mode.
        // 
        for(std::set<IceInternal::IncomingConnectionFactory*>::const_iterator p = factories.begin(); 
            p != factories.end(); ++p)
        {
            (*p)->enterBackground();
        }
        self->background = YES;
    }
}
-(void)willEnterForeground
{
    @synchronized(self)
    {
        //
        // Notify all the incoming connection factories that we are
        // entering the foreground mode.
        // 
        self->background = NO;
        for(std::set<IceInternal::IncomingConnectionFactory*>::const_iterator p = factories.begin(); 
            p != factories.end(); ++p)
        {
            (*p)->enterForeground();
        }
    }
}
@end

bool
IceObjC::registerForBackgroundNotification(IceInternal::IncomingConnectionFactory* factory)
{
    return [[Observer sharedInstance] add:factory] == YES;
}

void
IceObjC::unregisterForBackgroundNotification(IceInternal::IncomingConnectionFactory* factory)
{
    [[Observer sharedInstance] remove:factory];
}

#endif
