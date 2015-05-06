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
#import <TestUtil.h>

struct TestData
{
    NSString* name;
    NSString* prefix;
    NSString* client;
    NSString* server;
    NSString* serverAMD;
    NSString* collocated;
    bool sslSupport;
    bool runWithSlicedFormat;
    bool runWith10Encoding;
};

static const struct TestData alltests[] =
{
//
// | Name | lib base name | client | server | amdserver | collocated | ssl support | sliced | encoding 1.0 |
//
{ @"proxy", @"test_Ice_proxy_", @"client.bundle", @"server.bundle", @"serveramd.bundle", @"collocated.bundle", true, false, false },
{ @"operations", @"test_Ice_operations_", @"client.bundle", @"server.bundle", @"serveramd.bundle", @"collocated.bundle", true, false, false },
{ @"exceptions", @"test_Ice_exceptions_", @"client.bundle", @"server.bundle", @"serveramd.bundle", @"collocated.bundle", true, true, true },
{ @"ami", @"test_Ice_ami_", @"client.bundle", @"server.bundle", 0, 0, true, false, false },
{ @"info", @"test_Ice_info_", @"client.bundle", @"server.bundle", 0, 0, true, false, false },
{ @"inheritance", @"test_Ice_inheritance_", @"client.bundle", @"server.bundle", 0, @"collocated.bundle", true, false, false},
{ @"facets", @"test_Ice_facets_", @"client.bundle", @"server.bundle", 0, @"collocated.bundle", true, false, false },
{ @"objects", @"test_Ice_objects_", @"client.bundle", @"server.bundle", 0, @"collocated.bundle", true, true, true },
{ @"optional", @"test_Ice_optional_", @"client.bundle", @"server.bundle", 0, 0, true, true, false },
{ @"binding", @"test_Ice_binding_", @"client.bundle", @"server.bundle", 0, 0, true, false, false },
{ @"location", @"test_Ice_location_", @"client.bundle", @"server.bundle", 0, 0, true, false, false },
{ @"adapterDeactivation", @"test_Ice_adapterDeactivation_", @"client.bundle", @"server.bundle", 0, @"collocated.bundle", true, false, false },
{ @"slicing/exceptions", @"test_Ice_slicing_exceptions_", @"client.bundle", @"server.bundle", @"serveramd.bundle", 0, true, false, true },
{ @"slicing/objects", @"test_Ice_slicing_objects_", @"client.bundle", @"server.bundle", @"serveramd.bundle", 0, true, false, true },
{ @"dispatcher", @"test_Ice_dispatcher_", @"client.bundle", @"server.bundle", 0, 0, true, false, false },
{ @"checksum", @"test_Ice_checksum_", @"client.bundle", @"server_server.bundle", 0, 0, true, false, false },
{ @"stream", @"test_Ice_stream_", @"client.bundle", 0, 0, 0, true, false, false },
{ @"hold", @"test_Ice_hold_", @"client.bundle", @"server.bundle", 0, 0, true, false, false },
{ @"custom", @"test_Ice_custom_", @"client.bundle", @"server.bundle", @"serveramd.bundle", @"collocated.bundle", true, false, false },
{ @"retry", @"test_Ice_retry_", @"client.bundle", @"server.bundle", 0, 0, true, false, false },
{ @"timeout", @"test_Ice_timeout_", @"client.bundle", @"server.bundle", 0, 0, true, false, false },
{ @"interceptor", @"test_Ice_interceptor_", @"client.bundle", 0, 0, 0, true, false, false },
{ @"udp", @"test_Ice_udp_", @"client.bundle", @"server.bundle", 0, 0, true, false, false },
{ @"defaultServant", @"test_Ice_defaultServant_", @"client.bundle", 0, 0, 0, true, false, false },
{ @"defaultValue", @"test_Ice_defaultValue_", @"client.bundle", 0, 0, 0, true, false, false },
{ @"servantLocator", @"test_Ice_servantLocator_", @"client.bundle", @"server.bundle", @"serveramd.bundle", @"collocated.bundle", true, false, false },
{ @"invoke", @"test_Ice_invoke_", @"client.bundle", @"server.bundle", 0, 0, true, false, false },
{ @"hash", @"test_Ice_hash_", @"client.bundle", 0, 0, 0, true, false, false },
{ @"admin", @"test_Ice_admin_", @"client.bundle", @"server.bundle", 0, 0, true, false, false },
{ @"metrics", @"test_Ice_metrics_", @"client.bundle", @"server.bundle", 0, 0, false, false, false },
{ @"enums", @"test_Ice_enums_", @"client.bundle", @"server.bundle", 0, 0, true, false, true },
{ @"services", @"test_Ice_services_", @"client.bundle", 0, 0, 0, true, false, false },
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
            TestCase* test = [TestCase testWithName:alltests[i].name
                                             prefix:alltests[i].prefix
                                             client:alltests[i].client
                                             server:alltests[i].server
                                          serveramd:alltests[i].serverAMD
                                         collocated:alltests[i].collocated
                                         sslSupport:alltests[i].sslSupport
                                runWithSlicedFormat:alltests[i].runWithSlicedFormat
                                  runWith10Encoding:alltests[i].runWith10Encoding];
            [theTests addObject:test];
        }
        tests = [[theTests copy] retain];
        
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

- (void)dealloc
{
    [tests release];
    [navigationController release];
    [window release];
    [super dealloc];
}

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
                    std::cout << "\n*** Finished running all tests" << std::endl;
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
