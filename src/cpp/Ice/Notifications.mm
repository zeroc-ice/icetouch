// **********************************************************************
//
// Copyright (c) 2003-2015 ZeroC, Inc. All rights reserved.
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

namespace IceInternal
{

bool registerForBackgroundNotification(IncomingConnectionFactory*);
void unregisterForBackgroundNotification(IncomingConnectionFactory*);

}

using namespace std;
using namespace IceInternal;

@interface Observer : NSObject
{
    BOOL background;
    set<IncomingConnectionFactory*> factories;
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
-(BOOL)add:(IncomingConnectionFactory*)factory
{
    @synchronized(self)
    {
        factories.insert(factory);
        if(background)
        {
            factory->stopAcceptor();
        }
        else
        {
            factory->startAcceptor();
        }
        return background;
    }
}
-(void)remove:(IncomingConnectionFactory*)factory
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
        for(set<IncomingConnectionFactory*>::const_iterator p = factories.begin(); p != factories.end(); ++p)
        {
            (*p)->stopAcceptor();
        }
        background = YES;
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
        background = NO;
        for(set<IncomingConnectionFactory*>::const_iterator p = factories.begin(); p != factories.end(); ++p)
        {
            (*p)->startAcceptor();
        }
    }
}
@end

bool
IceInternal::registerForBackgroundNotification(IncomingConnectionFactory* factory)
{
    return [[Observer sharedInstance] add:factory] == YES;
}

void
IceInternal::unregisterForBackgroundNotification(IncomingConnectionFactory* factory)
{
    [[Observer sharedInstance] remove:factory];
}

#endif
