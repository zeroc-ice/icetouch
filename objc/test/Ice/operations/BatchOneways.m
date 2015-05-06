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
#import <OperationsTest.h>

void
batchOneways(id<TestOperationsMyClassPrx> p)
{
    ICEByte buf1[10 * 1024];
    ICEByte buf2[99 * 1024];
    ICEByte buf3[100 * 1024];
    TestOperationsMutableByteS *bs1 = [TestOperationsMutableByteS dataWithBytes:buf1 length:sizeof(buf1)];
    TestOperationsMutableByteS *bs2 = [TestOperationsMutableByteS dataWithBytes:buf2 length:sizeof(buf2)];
    TestOperationsMutableByteS *bs3 = [TestOperationsMutableByteS dataWithBytes:buf3 length:sizeof(buf3)];

    @try
    {
        [p opByteSOneway:bs1];
    }
    @catch(ICEMemoryLimitException*)
    {
        test(NO);
    }

    @try
    {
        [p opByteSOneway:bs2];
    }
    @catch(ICEMemoryLimitException*)
    {
        test(NO);
    }
    
    @try
    {
        [p opByteSOneway:bs3];
        test(NO);
    }
    @catch(ICEMemoryLimitException*)
    {
    }
    
    id<TestOperationsMyClassPrx> batch = [TestOperationsMyClassPrx uncheckedCast:[p ice_batchOneway]];
    
    int i;

    for(i = 0 ; i < 30 ; ++i)
    {
        @try
        {
            [batch opByteSOneway:bs1];
        }
        @catch(ICEMemoryLimitException*)
        {
            test(NO);
        }
    }
    
    [[batch ice_getConnection] flushBatchRequests];
}
