// **********************************************************************
//
// Copyright (c) 2003-2015 ZeroC, Inc. All rights reserved.
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
    bool wsSupport;
    bool runWithSlicedFormat;
    bool runWith10Encoding;
};

static NSString* protocols[] = { @"tcp", @"ssl", @"ws", @"wss" };
const int nProtocols = sizeof(protocols) / sizeof(NSString*);

static const struct TestData alltests[] =
{
//
// | Name | lib base name | client | server | amdserver | collocated | ssl support | ws support sliced | encoding 1.0 |
//
{ @"proxy", @"Ice_proxy_", @"client.bundle", @"server.bundle", @"serveramd.bundle", @"collocated.bundle", true, true, false, false },
{ @"operations", @"Ice_operations_", @"client.bundle", @"server.bundle", @"serveramd.bundle", @"collocated.bundle", true, true, false, false },
{ @"exceptions", @"Ice_exceptions_", @"client.bundle", @"server.bundle", @"serveramd.bundle", @"collocated.bundle", true, true, true, true },
{ @"ami", @"Ice_ami_", @"client.bundle", @"server.bundle", 0, 0, true, true, false, false },
{ @"info", @"Ice_info_", @"client.bundle", @"server.bundle", 0, 0, true, true, false, false },
{ @"inheritance", @"Ice_inheritance_", @"client.bundle", @"server.bundle", 0, @"collocated.bundle", true, true, false, false},
{ @"facets", @"Ice_facets_", @"client.bundle", @"server.bundle", 0, @"collocated.bundle", true, true, false, false },
{ @"objects", @"Ice_objects_", @"client.bundle", @"server.bundle", 0, @"collocated.bundle", true, true, true, true },
{ @"optional", @"Ice_optional_", @"client.bundle", @"server.bundle", 0, 0, true, true, true, false },
{ @"binding", @"Ice_binding_", @"client.bundle", @"server.bundle", 0, 0, true, true, false, false },
{ @"location", @"Ice_location_", @"client.bundle", @"server.bundle", 0, 0, true, true, false, false },
{ @"adapterDeactivation", @"Ice_adapterDeactivation_", @"client.bundle", @"server.bundle", 0, @"collocated.bundle", true, true, false, false },
{ @"slicing/exceptions", @"Ice_slicing_exceptions_", @"client.bundle", @"server.bundle", @"serveramd.bundle", 0, true, true, false, true },
{ @"slicing/objects", @"Ice_slicing_objects_", @"client.bundle", @"server.bundle", @"serveramd.bundle", 0, true, true, false, true },
{ @"dispatcher", @"Ice_dispatcher_", @"client.bundle", @"server.bundle", 0, 0, true, true, false, false },
{ @"stream", @"Ice_stream_", @"client.bundle", 0, 0, 0, true, true, false, false },
{ @"hold", @"Ice_hold_", @"client.bundle", @"server.bundle", 0, 0, true, true, false, false },
{ @"custom", @"Ice_custom_", @"client.bundle", @"server.bundle", @"serveramd.bundle", @"collocated.bundle", true, true, false, false },
{ @"retry", @"Ice_retry_", @"client.bundle", @"server.bundle", 0, 0, true, true, false, false },
{ @"timeout", @"Ice_timeout_", @"client.bundle", @"server.bundle", 0, 0, true, true, false, false },
{ @"interceptor", @"Ice_interceptor_", @"client.bundle", 0, 0, 0, true, true, false, false },
{ @"udp", @"Ice_udp_", @"client.bundle", @"server.bundle", 0, 0, true, true, false, false },
{ @"defaultServant", @"Ice_defaultServant_", @"client.bundle", 0, 0, 0, true, true, false, false },
{ @"defaultValue", @"Ice_defaultValue_", @"client.bundle", 0, 0, 0, true, true, false, false },
{ @"servantLocator", @"Ice_servantLocator_", @"client.bundle", @"server.bundle", @"serveramd.bundle", @"collocated.bundle", true, true, false, false },
{ @"invoke", @"Ice_invoke_", @"client.bundle", @"server.bundle", 0, 0, true, true, false, false },
{ @"hash", @"Ice_hash_", @"client.bundle", 0, 0, 0, true, true, false, false },
{ @"admin", @"Ice_admin_", @"client.bundle", @"server.bundle", 0, 0, true, true, false, false },
{ @"metrics", @"Ice_metrics_", @"client.bundle", @"server.bundle", 0, 0, false, false, false, false },
{ @"enums", @"Ice_enums_", @"client.bundle", @"server.bundle", 0, 0, true, true, false, true },
{ @"services", @"Ice_services_", @"client.bundle", 0, 0, 0, true, true, false, false },
};

@implementation AppDelegate

@synthesize window;
@synthesize navigationController;
@synthesize tests;
@synthesize currentTest;
@synthesize loop;
@synthesize runAll;

static NSString* currentTestKey = @"currentTestKey";
static NSString* protocolKey = @"protocolKey";

+(void)initialize
{
    NSDictionary* appDefaults = [NSDictionary dictionaryWithObjectsAndKeys:
                                 @"0", currentTestKey,
                                 @"tcp", protocolKey,
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
                                          wsSupport:alltests[i].wsSupport
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

        protocol = [[NSUserDefaults standardUserDefaults] stringForKey:protocolKey];
        int i = 0;
        for(; i < nProtocols; ++i)
        {
            if([protocols[i] isEqualToString:protocol])
            {
                break;
            }
        }
        if(i == nProtocols)
        {
            protocol = @"tcp";
        }

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
    [protocol release];
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

-(NSString*)protocol
{
    return protocol;
}

-(void)setProtocol:(NSString*)v
{
    protocol = [v retain];
    [[NSUserDefaults standardUserDefaults] setObject:v forKey:protocolKey];
}

-(BOOL)testCompleted:(BOOL)success
{
    if(success)
    {
        self.currentTest = (currentTest+1) % tests.count;
        if(runAll || loop)
        {
            if(self.currentTest == 0)
            {
                int i = 0;
                for(; i < nProtocols; ++i)
                {
                    if([protocols[i] isEqualToString:protocol])
                    {
                        break;
                    }
                }
                
                if(++i == nProtocols && !loop)
                {
                    std::cout << "\n*** Finished running all tests" << std::endl;
                    return NO;
                }
                else
                {
                    protocol = protocols[i % nProtocols];
                    return YES;
                }
            }
            return YES;
        }
    }
    return NO;
}

@end
