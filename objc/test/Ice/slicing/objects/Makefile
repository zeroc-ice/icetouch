# **********************************************************************
#
# Copyright (c) 2003-2014 ZeroC, Inc. All rights reserved.
#
# This copy of Ice Touch is licensed to you under the terms described in the
# ICE_TOUCH_LICENSE file included in this distribution.
#
# **********************************************************************

top_srcdir	= ../../../..

CLIENT		= client
SERVER		= server

TARGETS		= $(CLIENT) $(SERVER)

COBJS		= SlicingObjectsTestClient.o \
		  SlicingObjectsForwardClient.o \
		  Client.o \
		  AllTests.o

SOBJS		= SlicingObjectsTestServer.o \
		  SlicingObjectsForwardServer.o \
		  TestI.o \
		  Server.o

SRCS		= $(COBJS:.o=.m) \
		  $(SOBJS:.o=.m)

SLICE_SRCS	= SlicingObjectsTestClient.ice \
		  SlicingObjectsTestServer.ice \
		  SlicingObjectsForwardClient.ice \
		  SlicingObjectsForwardServer.ice

include $(top_srcdir)/config/Make.rules

ifeq ($(COMPILE_WITH_GC),yes)
   CPPFLAGS		:= -DICE_OBJC_GC $(CPPFLAGS)
endif

CPPFLAGS	:= -I. -I../.. -I../../../include $(CPPFLAGS)
SLICE2OBJCFLAGS := -I. $(SLICE2OBJCFLAGS)

$(CLIENT): $(ICEOBJCLIB) $(COBJS)
	rm -f $@
	$(CXX) $(LDFLAGS) $(STATICLIBSTDFLAG) -o $@ $(COBJS) $(TEST_LIBS)

$(SERVER): $(ICEOBJCLIB) $(SOBJS)
	rm -f $@
	$(CXX) $(LDFLAGS) $(STATICLIBSTDFLAG) -o $@ $(SOBJS) $(TEST_LIBS)

include .depend
