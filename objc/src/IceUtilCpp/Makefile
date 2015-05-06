# **********************************************************************
#
# Copyright (c) 2003-2014 ZeroC, Inc. All rights reserved.
#
# This copy of Ice Touch is licensed to you under the terms described in the
# ICE_TOUCH_LICENSE file included in this distribution.
#
# **********************************************************************

top_srcdir	= ../..

OBJS		= ArgVector.o \
		  Cond.o \
		  ConvertUTF.o \
		  Exception.o \
		  FileUtil.o \
		  Random.o \
		  MutexProtocol.o \
		  Options.o \
		  RecMutex.o \
		  Shared.o \
		  StringUtil.o \
		  Thread.o \
		  ThreadException.o \
		  Time.o \
		  Timer.o \
		  Unicode.o \
		  UUID.o \
		  CountDownLatch.o

SRCS_DIR	= $(ice_dir)/cpp/src/IceUtil

SRCS_OBJS	:= $(OBJS)
SRCS		= $(addprefix $(SRCS_DIR)/, $(SRCS_OBJS:.o=.cpp))

include $(top_srcdir)/config/Make.rules

OBJS 		:= $(addprefix $(OBJDIR)/IceUtilCpp_,$(OBJS))

CPPFLAGS        := -I$(ice_dir)/cpp/include -I$(ice_dir)/cpp/src $(CPPPLATFORMFLAGS)
DEPENDFLAGS	:= --obj-dir --obj-prefix=IceUtilCpp_

ifeq ($(COMPILE_WITH_GC),yes)
   CPPFLAGS		:= -DICE_OBJC_GC $(CPPFLAGS)
endif

all:: $(OBJS)

install:: $(OBJS)

$(OBJDIR)/IceUtilCpp_%.o: $(SRCS_DIR)/%.cpp
	$(CXX) -c $(CPPFLAGS) $(CXXFLAGS) $< -o $@

include .depend
