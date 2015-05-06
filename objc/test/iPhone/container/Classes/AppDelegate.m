// **********************************************************************
//
// Copyright (c) 2003-2014 ZeroC, Inc. All rights reserved.
//
// This copy of Ice Touch is licensed to you under the terms described in the
// ICE_TOUCH_LICENSE file included in this distribution.
//
// **********************************************************************

#import <AppDelegate.h>
#import <TestViewController.h>
#import <Test.h>

struct TestCases
{
    NSString* __unsafe_unretained name;
    int (*startServer)(int, char**);
    int (*startClient)(int, char**);
    bool sslSupport;
    bool runWithSlicedFormat;
    bool runWith10Encoding;
};
int adapterDeactivationServer(int, char**);
int adapterDeactivationClient(int, char**);
int amiServer(int, char**);
int amiClient(int, char**);
int bindingServer(int, char**);
int bindingClient(int, char**);
int defaultServantServer(int, char**);
int defaultServantClient(int, char**);
int defaultValueClient(int, char**);
int dispatcherServer(int, char**);
int dispatcherClient(int, char**);
int enumServer(int, char**);
int enumClient(int, char**);
int exceptionsServer(int, char**);
int exceptionsClient(int, char**);
int facetsServer(int, char**);
int facetsClient(int, char**);
int holdServer(int, char**);
int holdClient(int, char**);
int inheritanceServer(int, char**);
int inheritanceClient(int, char**);
int interceptorServer(int, char**);
int interceptorClient(int, char**);
int invokeServer(int, char**);
int invokeClient(int, char**);
int locationServer(int, char**);
int locationClient(int, char**);
int objectsServer(int, char**);
int objectsClient(int, char**);
int operationsServer(int, char**);
int operationsClient(int, char**);
int optionalServer(int, char**);
int optionalClient(int, char**);
int proxyServer(int, char**);
int proxyClient(int, char**);
int retryServer(int, char**);
int retryClient(int, char**);
int streamClient(int, char**);
int timeoutServer(int, char**);
int timeoutClient(int, char**);
int slicingExceptionsServer(int, char**);
int slicingExceptionsClient(int, char**);
int hashClient(int, char**);
int infoServer(int, char**);
int infoClient(int, char**);
int metricsServer(int, char**);
int metricsClient(int, char**);
int servicesClient(int, char**);

static const struct TestCases alltests[] =
{
//
// Name | Server | Client | SSL Support | Sliced | 1.0 Encoding |
//
{ @"proxy", proxyServer, proxyClient, true, false, false },
{ @"ami", amiServer, amiClient, true, false, false },
{ @"operations", operationsServer, operationsClient, true, false, false },
{ @"exceptions", exceptionsServer, exceptionsClient, true, true, true },
{ @"inheritance", inheritanceServer, inheritanceClient, true, false, false },
{ @"invoke", invokeServer, invokeClient, true, false, false },
{ @"metrics", metricsServer, metricsClient, false, false, false},
{ @"facets", facetsServer, facetsClient, true, false, false },
{ @"objects", objectsServer, objectsClient, true, true, true },
{ @"optional", optionalServer, optionalClient, true, true, false },
{ @"interceptor", interceptorServer, interceptorClient, true, false, false },
{ @"dispatcher", dispatcherServer, dispatcherClient, true, false, false },
{ @"defaultServant", defaultServantServer, defaultServantClient, true, false, false },
{ @"defaultValue", 0, defaultValueClient, true, false, false },
{ @"binding", bindingServer, bindingClient, true, false, false },
{ @"hold", holdServer, holdClient, true, false, false },
{ @"location", locationServer, locationClient, true, false, false },
{ @"adapterDeactivation", adapterDeactivationServer, adapterDeactivationClient, true, false, false },
{ @"stream", 0, streamClient, true, false, true },
{ @"slicing/exceptions", slicingExceptionsServer, slicingExceptionsClient, true, false, true },
//
// Slicing objects will not work as both applications are linked in the same executable
// and have knowledge of the same Slice types.
//
//{ @"slicing/objects",slicingObjectsServer, slicingObjectsClient, true, false, true },
{ @"retry",retryServer, retryClient, true, false, false },
{ @"timeout",timeoutServer, timeoutClient, true, false, false },
{ @"hash", 0, hashClient, true, false, false },
{ @"info",infoServer, infoClient, true, false , false },
{ @"enums", enumServer, enumClient, true, false, true },
{ @"services", 0, servicesClient, true, false, false }
};

@implementation AppDelegate

@synthesize window;
@synthesize navigationController;
@synthesize tests;
@synthesize currentTest;
@synthesize loop;
@synthesize runAll;

static NSString* currentTestKey = @"currentTestKey";
static NSString* sslKey = @"sslKey";

+(void)initialize
{
    NSDictionary* appDefaults = [NSDictionary dictionaryWithObjectsAndKeys:
                                 @"0", currentTestKey,
                                 @"NO", sslKey,
                                 nil];
    [[NSUserDefaults standardUserDefaults] registerDefaults:appDefaults];
}

-(id)init
{
    if(self = [super init])
    {
        self->runAll = getenv("RUNALL") != NULL;

        NSMutableArray* theTests = [NSMutableArray array];
        for(int i = 0; i < sizeof(alltests)/sizeof(alltests[0]); ++i)
        {
            Test* test = [Test testWithName:alltests[i].name
                                     server:alltests[i].startServer
                                     client:alltests[i].startClient
                                 sslSupport:alltests[i].sslSupport
                        runWithSlicedFormat:alltests[i].runWithSlicedFormat
                          runWith10Encoding:alltests[i].runWith10Encoding];
            [theTests addObject:test];
        }
         tests = [theTests copy];
#if defined(__clang__) && !__has_feature(objc_arc)
        [tests retain];
#endif
        // Initialize the application defaults.
        currentTest = [[NSUserDefaults standardUserDefaults] integerForKey:currentTestKey];
        if(runAll || currentTest < 0 || currentTest > tests.count)
        {
            currentTest = 0;
        }

        ssl = [[NSUserDefaults standardUserDefaults] boolForKey:sslKey];
        loop = NO;
    }
    return self;
}

- (void)applicationDidFinishLaunching:(UIApplication *)application
{
    
    // Override point for customization after app launch    
    [window setRootViewController:navigationController];
    [window makeKeyAndVisible];
}

#if defined(__clang__) && !__has_feature(objc_arc)
- (void)dealloc
{
    [tests release];
    [navigationController release];
    [window release];
    [super dealloc];
}
#endif

-(NSInteger)currentTest
{
    return currentTest;
}

-(void)setCurrentTest:(NSInteger)test
{
    currentTest = test;

    [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInteger:currentTest] forKey:currentTestKey];
}

-(BOOL)ssl
{
    return ssl;
}

-(void)setSsl:(BOOL)v
{
    ssl = v;
    
    [[NSUserDefaults standardUserDefaults] setBool:ssl forKey:sslKey];
}

-(BOOL)testCompleted:(BOOL)success
{
    if(success)
    {
        self.currentTest = (currentTest+1) % tests.count;
        if(runAll)
        {
            if(self.currentTest == 0)
            {
                ssl = !ssl;
                if(!ssl)
                {
                    printf("%s", "\n*** Finished running all tests\n");
                    fflush(stdout);
                }
                return ssl; // Continue if running ssl tests now
            }
            return YES;
        }
        else if(loop)
        {
            return YES;
        }
    }
    return NO;
}

@end
