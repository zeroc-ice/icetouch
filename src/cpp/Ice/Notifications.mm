// **********************************************************************
//
// Copyright (c) 2003-2016 ZeroC, Inc. All rights reserved.
//
// This copy of Ice Touch is licensed to you under the terms described in the
// ICE_LICENSE file included in this distribution.
//
// **********************************************************************

#import <Ice/Config.h>

#if TARGET_OS_IPHONE != 0

#import <Foundation/NSObject.h>
#import <Foundation/NSNotification.h>
#import <UIKit/UIApplication.h>

#include <Ice/ConnectionFactory.h>

#include <set>

using namespace std;
using namespace IceInternal;

namespace IceInternal
{

bool registerForBackgroundNotification(IncomingConnectionFactory*);
void unregisterForBackgroundNotification(IncomingConnectionFactory*);

}

namespace
{

class Observer
{
public:

    Observer() : _background(false)
    {
        [[NSNotificationCenter defaultCenter] addObserverForName:UIApplicationDidEnterBackgroundNotification
                                                          object:nil
                                                           queue:nil
                                                      usingBlock:^(NSNotification*)
                                                                 {
                                                                     didEnterBackground();
                                                                 }];

        [[NSNotificationCenter defaultCenter] addObserverForName:UIApplicationWillEnterForegroundNotification
                                                          object:nil
                                                           queue:nil
                                                      usingBlock:^(NSNotification*)
                                                                 {
                                                                     willEnterForeground();
                                                                 }];
    }

    bool
    add(IncomingConnectionFactory* factory)
    {
        IceUtil::Mutex::Lock sync(_mutex);
        _factories.insert(factory);
        factory->__incRef();
        if(_background)
        {
            factory->stopAcceptor();
        }
        else
        {
            factory->startAcceptor();
        }
        return _background;
    }

    void
    remove(IncomingConnectionFactory* factory)
    {
        IceUtil::Mutex::Lock sync(_mutex);
        _factories.erase(factory);
        factory->__decRef();
    }

    void
    didEnterBackground()
    {
        IceUtil::Mutex::Lock sync(_mutex);
        NSLog(@"didEnterBackground");
        //
        // Notify all the incoming connection factories that we are
        // entering the background mode.
        //
        for(set<IncomingConnectionFactory*>::const_iterator p = _factories.begin(); p != _factories.end(); ++p)
        {
            (*p)->stopAcceptor();
        }
        _background = true;
    }

    void
    willEnterForeground()
    {
        IceUtil::Mutex::Lock sync(_mutex);
        NSLog(@"willEnterForeground");
        //
        // Notify all the incoming connection factories that we are
        // entering the foreground mode.
        //
        _background = false;
        for(set<IncomingConnectionFactory*>::const_iterator p = _factories.begin(); p != _factories.end(); ++p)
        {
            (*p)->startAcceptor();
        }
    }

private:

    IceUtil::Mutex _mutex;
    bool _background;
    set<IncomingConnectionFactory*> _factories;
};


}

static Observer* observer = new Observer();

bool
IceInternal::registerForBackgroundNotification(IncomingConnectionFactory* factory)
{
    return observer->add(factory);
}

void
IceInternal::unregisterForBackgroundNotification(IncomingConnectionFactory* factory)
{
    observer->remove(factory);
}

#endif
