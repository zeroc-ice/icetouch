// **********************************************************************
//
// Copyright (c) 2003-2014 ZeroC, Inc. All rights reserved.
//
// This copy of Ice Touch is licensed to you under the terms described in the
// ICE_TOUCH_LICENSE file included in this distribution.
//
// **********************************************************************

#import <Ice/Ice.h>
#import <TestCommon.h>
#import <TimeoutTest.h>

#import <Foundation/Foundation.h>

@interface TestTimeoutCallback : NSObject
{
    BOOL called;
    NSCondition* cond;
}
-(void) check;
-(void) called;
@end

@implementation TestTimeoutCallback
-(id) init
{
    self = [super init];
    if(!self)
    {
        return nil;
    }
    cond = [[NSCondition alloc] init];
    return self;
}

#if defined(__clang__) && !__has_feature(objc_arc)
-(void) dealloc
{
    [cond release];
    [super dealloc];
}
#endif

-(void) check
{
    [cond lock];
    while(!called)
    {
        [cond wait];
    }
    called = NO;
    [cond unlock];
}
-(void) called
{
    [cond lock];
    called = YES;
    [cond signal];
    [cond unlock];
}
-(void) sendDataResponse
{
    [self called];
}
-(void) sendDataException:(ICEException*)ex
{
    test(NO);
}
-(void) sendDataExResponse
{
    test(NO);
}
-(void) sendDataExException:(ICEException*)ex
{
    test([ex isKindOfClass:[ICETimeoutException class]]);
    [self called];
}
-(void) sleepResponse
{
    [self called];
}
-(void) sleepException:(ICEException*)ex
{
    test(NO);
}
-(void) sleepExResponse
{
    test(NO);
}
-(void) sleepExException:(ICEException*)ex
{
    test([ex isKindOfClass:[ICETimeoutException class]]);
    [self called];
}
@end

id<TestTimeoutTimeoutPrx>
timeoutAllTests(id<ICECommunicator> communicator)
{
    NSString* sref = @"timeout:default -p 12010";
    id<ICEObjectPrx> obj = [communicator stringToProxy:sref];
    test(obj);

    id<TestTimeoutTimeoutPrx> timeout = [TestTimeoutTimeoutPrx checkedCast:obj];
    test(timeout);

    tprintf("testing connect timeout... ");
    {
        //
        // Expect ConnectTimeoutException.
        //
        id<TestTimeoutTimeoutPrx> to = [TestTimeoutTimeoutPrx uncheckedCast:[obj ice_timeout:500]];
        [to holdAdapter:1000];
        [[to ice_getConnection] close:YES]; // Force a reconnect.
        @try
        {
            [to op];
            test(NO);
        }
        @catch(ICEConnectTimeoutException*)
        {
            // Expected.
        }
    }
    {
        //
        // Expect success.
        //
        [timeout op]; // Ensure adapter is active.
        id<TestTimeoutTimeoutPrx> to = [TestTimeoutTimeoutPrx uncheckedCast:[obj ice_timeout:1000]];
        [to holdAdapter:500];
        [[to ice_getConnection] close:YES]; // Force a reconnect.
        @try
        {
            [to op];
        }
        @catch(ICEConnectTimeoutException*)
        {
            test(NO);
        }
    }
    tprintf("ok\n");

    tprintf("testing read timeout... ");
    {
        //
        // Expect TimeoutException.
        //
        id<TestTimeoutTimeoutPrx> to = [TestTimeoutTimeoutPrx uncheckedCast:[obj ice_timeout:500]];
        @try
        {
            [to sleep:750];
            test(NO);
        }
        @catch(ICETimeoutException*)
        {
            // Expected.
        }
    }
    {
        //
        // Expect success.
        //
        [timeout op]; // Ensure adapter is active.
        id<TestTimeoutTimeoutPrx> to = [TestTimeoutTimeoutPrx uncheckedCast:[obj ice_timeout:1000]];
        @try
        {
            [to sleep:500];
        }
        @catch(ICETimeoutException*)
        {
            test(NO);
        }
    }
    tprintf("ok\n");

    tprintf("testing write timeout... ");
    {
        //
        // Expect TimeoutException.
        //
        id<TestTimeoutTimeoutPrx> to = [TestTimeoutTimeoutPrx uncheckedCast:[obj ice_timeout:500]];
        [to holdAdapter:2000];
        @try
        {
            TestTimeoutByteSeq* seq = [TestTimeoutMutableByteSeq dataWithLength:10000];
            [to sendData:seq];
            test(NO);
        }
        @catch(ICETimeoutException*)
        {
            // Expected.
        }
    }
    {
        //
        // Expect success.
        //
        [timeout op]; // Ensure adapter is active.
        id<TestTimeoutTimeoutPrx> to = [TestTimeoutTimeoutPrx uncheckedCast:[obj ice_timeout:1000]];
        [to holdAdapter:500];
        @try
        {
            TestTimeoutByteSeq* seq = [TestTimeoutMutableByteSeq dataWithLength:10000];
            [to sendData:seq];
        }
        @catch(ICETimeoutException*)
        {
            test(NO);
        }
    }
    tprintf("ok\n");

    tprintf("testing AMI read timeout... ");
    {
        //
        // Expect TimeoutException.
        //
        id<TestTimeoutTimeoutPrx> to = [TestTimeoutTimeoutPrx uncheckedCast:[obj ice_timeout:500]];
#if defined(__clang__) && !__has_feature(objc_arc)
        TestTimeoutCallback* cb = [[[TestTimeoutCallback alloc] init] autorelease];
#else
        TestTimeoutCallback* cb = [[TestTimeoutCallback alloc] init];
#endif
        [to begin_sleep:2000 response:^{ [cb sleepExResponse]; } 
              exception:^(ICEException* ex) { [cb sleepExException:ex]; }];
        [cb check];
    }
    {
        //
        // Expect success.
        //
        [timeout op]; // Ensure adapter is active.
        id<TestTimeoutTimeoutPrx> to = [TestTimeoutTimeoutPrx uncheckedCast:[obj ice_timeout:1000]];
#if defined(__clang__) && !__has_feature(objc_arc)
        TestTimeoutCallback* cb = [[[TestTimeoutCallback alloc] init] autorelease];
#else
        TestTimeoutCallback* cb = [[TestTimeoutCallback alloc] init];
#endif
        [to begin_sleep:500 response:^{ [cb sleepResponse]; }
              exception:^(ICEException* ex) { [cb sleepException:ex]; }];
        [cb check];
    }
    tprintf("ok\n");

    tprintf("testing AMI write timeout... ");
    {
        //
        // Expect TimeoutException.
        //
        id<TestTimeoutTimeoutPrx> to = [TestTimeoutTimeoutPrx uncheckedCast:[obj ice_timeout:500]];
        [to holdAdapter:2000];
        TestTimeoutByteSeq* seq = [TestTimeoutMutableByteSeq dataWithLength:10000];
#if defined(__clang__) && !__has_feature(objc_arc)
        TestTimeoutCallback* cb = [[[TestTimeoutCallback alloc] init] autorelease];
#else
        TestTimeoutCallback* cb = [[TestTimeoutCallback alloc] init];
#endif
        [to begin_sendData:seq response:^{ [cb sendDataExResponse]; } 
                 exception:^(ICEException* ex) { [cb sendDataExException:ex]; } ];
        [cb check];
    }
    {
        //
        // Expect success.
        //
        [timeout op]; // Ensure adapter is active.
        id<TestTimeoutTimeoutPrx> to = [TestTimeoutTimeoutPrx uncheckedCast:[obj ice_timeout:1000]];
        [to holdAdapter:500];
        TestTimeoutByteSeq* seq = [TestTimeoutMutableByteSeq dataWithLength:10000];
#if defined(__clang__) && !__has_feature(objc_arc)
        TestTimeoutCallback* cb = [[[TestTimeoutCallback alloc] init] autorelease];
#else
        TestTimeoutCallback* cb = [[TestTimeoutCallback alloc] init];
#endif
        [to begin_sendData:seq response:^{ [cb sendDataResponse]; } 
                 exception:^(ICEException* ex) { [cb sendDataException:ex]; } ];
        [cb check];
    }
    tprintf("ok\n");

    tprintf("testing timeout overrides... ");
    {
        //
        // TestTimeout Ice.Override.Timeout. This property overrides all
        // endpoint timeouts.
        //
        ICEInitializationData* initData = [ICEInitializationData initializationData];
        [initData setProperties:[[communicator getProperties] clone]];
        [[initData properties] setProperty:@"Ice.Override.Timeout" value:@"500"];
        id<ICECommunicator> comm = [ICEUtil createCommunicator:initData];
        id<TestTimeoutTimeoutPrx> to = [TestTimeoutTimeoutPrx checkedCast:[comm stringToProxy:sref]];
        @try
        {
            [to sleep:750];
            test(NO);
        }
        @catch(ICETimeoutException*)
        {
            // Expected.
        }
        //
        // Calling ice_timeout() should have no effect.
        //
        [timeout op]; // Ensure adapter is active.
        to = [TestTimeoutTimeoutPrx checkedCast:[to ice_timeout:1000]];
        @try
        {
            [to sleep:750];
            test(NO);
        }
        @catch(ICETimeoutException*)
        {
            // Expected.
        }
        [comm destroy];
    }
    {
        //
        // TestTimeout Ice.Override.ConnectTimeout.
        //
        ICEInitializationData* initData = [ICEInitializationData initializationData];
        [initData setProperties:[[communicator getProperties] clone]];
        [[initData properties] setProperty:@"Ice.Override.ConnectTimeout" value:@"750"];
        id<ICECommunicator> comm = [ICEUtil createCommunicator:initData];
        [timeout holdAdapter:1000];
        id<TestTimeoutTimeoutPrx> to = [TestTimeoutTimeoutPrx uncheckedCast:[comm stringToProxy:sref]];
        @try
        {
            [to op];
            test(NO);
        }
        @catch(ICEConnectTimeoutException*)
        {
            // Expected.
        }
        //
        // Calling ice_timeout() should have no effect on the connect timeout.
        //
        [timeout op]; // Ensure adapter is active.
        [timeout holdAdapter:1000];
        to = [TestTimeoutTimeoutPrx uncheckedCast:[to ice_timeout:1250]];
        @try
        {
            [to op];
            test(NO);
        }
        @catch(ICEConnectTimeoutException*)
        {
            // Expected.
        }
        //
        // Verify that timeout set via ice_timeout() is still used for requests.
        //
        [to op]; // Force connection.
        @try
        {
            [to sleep:1500];
            test(NO);
        }
        @catch(ICETimeoutException*)
        {
            // Expected.
        }
        [comm destroy];
    }
    tprintf("ok\n");

    return timeout;
}
