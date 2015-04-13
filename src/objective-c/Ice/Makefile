# **********************************************************************
#
# Copyright (c) 2003-2015 ZeroC, Inc. All rights reserved.
#
# This copy of Ice Touch is licensed to you under the terms described
# in the ICE_LICENSE file included in this distribution.
#
# **********************************************************************

top_srcdir	= ../../..

LIBNAME		= $(call mklibname,IceObjC)

TARGETS		= $(libdir)/$(LIBNAME)

SLICE_DIRS	= Ice IceSSL
HEADER_DIRS	= objc/Ice objc/IceSSL
SRC_DIRS	= Ice IceSSL

HEADERS		= objc/Ice.h objc/IceSSL.h

include $(top_srcdir)/config/Make.rules

# Add objects from the C++ SDK
OBJS		+= $(wildcard ../../cpp/Ice/$(PLATFORM_NAME)/*.o) \
		   $(wildcard ../../cpp/Ice/$(PLATFORM_NAME)/*/*.o)

$(libdir)/$(LIBNAME): $(OBJS)

CPPFLAGS	:= -I$(objcdir)/src/Ice -DICE_API_EXPORTS $(CPPFLAGS)
SLICE2OBJCFLAGS	:= --ice --dll-export ICE_API $(SLICE2CPPFLAGS)

ifneq ($(PLATFORM_NAME),macosx)
SLICE2OBJCFLAGS	:= -DICE_USE_CFSTREAM $(SLICE2OBJCFLAGS)
endif

install:: all

# Objective-C++ source
$(call mkobjtargetpattern,$(OBJDIR)/%_mm.o): $(objcdir)/src/%.mm
	@$(call mkobj,$<,$@,-I$(subst ObjC,Cpp,$(includedir)) -I$(objcdir)/src -I$(cppdir)/src $(OBJCXX_CPPFLAGS))
