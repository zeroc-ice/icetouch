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

TARGETS		= $(CLIENT)

OBJS		= Client.o \
		  AllTests.o \
		  ServicesTest.o

SRCS		= $(OBJS:.o=.m)

SLICE_SRCS	= ServicesTest.ice

include $(top_srcdir)/config/Make.rules

ifeq ($(COMPILE_WITH_GC),yes)
   CPPFLAGS		:= -DICE_OBJC_GC $(CPPFLAGS)
endif

CPPFLAGS	:= -I. -I.. -I../../include $(CPPFLAGS)
LIBS		:= $(TEST_LIBS) -lGlacier2ObjC$(libsuffix) -lIceStormObjC$(libsuffix) -lIceGridObjC$(libsuffix)

$(CLIENT): $(ICEOBJCLIB) $(OBJS)
	rm -f $@
	$(CXX) $(LDFLAGS) $(STATICLIBSTDFLAG) -o $@ $(OBJS) $(LIBS)

include .depend
