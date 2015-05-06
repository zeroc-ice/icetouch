# **********************************************************************
#
# Copyright (c) 2003-2014 ZeroC, Inc. All rights reserved.
#
# This copy of Ice Touch is licensed to you under the terms described in the
# ICE_TOUCH_LICENSE file included in this distribution.
#
# **********************************************************************

top_srcdir	= ../../..

CLIENT		= client
SERVER		= server

LIBNAME  	= TestHold.dylib

TARGETS_IPHONE	= $(LIBNAME)
TARGETS		= $(CLIENT) $(SERVER)

COBJS		= Client.o \
		  AllTests.o

SOBJS		= TestI.o \
		  Server.o

SHARED_OBJS	= HoldTest.o

SRCS		= $(COBJS:.o=.m) \
		  $(SOBJS:.o=.m) \
		  $(SHARED_OBJS=.o=.m)

SLICE_SRCS	= HoldTest.ice

include $(top_srcdir)/config/Make.rules

ifeq ($(COMPILE_WITH_GC),yes)
   CPPFLAGS		:= -DICE_OBJC_GC $(CPPFLAGS)
endif

CPPFLAGS	:= -I. -I.. -I../../include $(CPPFLAGS)

$(CLIENT): $(ICEOBJCLIB) $(COBJS) $(SHARED_OBJS)
	rm -f $@
	$(CXX) $(LDFLAGS) $(STATICLIBSTDFLAG) -o $@ $(COBJS) $(SHARED_OBJS) $(TEST_LIBS)

$(SERVER): $(ICEOBJCLIB) $(SOBJS) $(SHARED_OBJS)
	rm -f $@
	$(CXX) $(LDFLAGS) $(STATICLIBSTDFLAG) -o $@ $(SOBJS) $(SHARED_OBJS) $(TEST_LIBS)

include .depend
