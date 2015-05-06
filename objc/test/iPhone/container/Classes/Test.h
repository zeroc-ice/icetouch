// **********************************************************************
//
// Copyright (c) 2003-2014 ZeroC, Inc. All rights reserved.
//
// This copy of Ice Touch is licensed to you under the terms described in the
// ICE_TOUCH_LICENSE file included in this distribution.
//
// **********************************************************************

#import <UIKit/UIKit.h>


@interface Test : NSObject
{
@private
    int (*server)(int,char**);
    int (*client)(int,char**);
    NSString* name;
    BOOL sslSupport;
    BOOL runWithSlicedFormat;
    BOOL runWith10Encoding;
}

+(id) testWithName:(const NSString*)name
              server:(int (*)(int, char**))server
              client:(int (*)(int, char**))client
          sslSupport:(BOOL)sslSupport
 runWithSlicedFormat:(BOOL)runWithSlicedFormat
   runWith10Encoding:(BOOL)runWith10Encoding;

-(BOOL)hasServer;
-(int)server;
-(int)client;

@property (readonly) NSString* name;
@property (readonly) BOOL sslSupport;
@property (readonly) BOOL runWithSlicedFormat;
@property (readonly) BOOL runWith10Encoding;

@end
