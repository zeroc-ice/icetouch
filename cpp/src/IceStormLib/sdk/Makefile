# **********************************************************************
#
# Copyright (c) 2003-2014 ZeroC, Inc. All rights reserved.
#
# This copy of Ice Touch is licensed to you under the terms described in the
# ICE_TOUCH_LICENSE file included in this distribution.
#
# **********************************************************************

top_srcdir	= ../../..

STATICLIBS	= yes

LIBNAME		= $(call mklibname,IceStormCpp$(libsuffix))

TARGETS		= $(libdir)/$(LIBNAME)

SLICE_SRCS	= $(SDIR)/IceStorm.ice \
		  $(SDIR)/Metrics.ice

SDIR		= $(slicedir)/IceStorm
HDIR		= $(headerdir)/IceStorm

HEADERS_DIR	= $(top_srcdir)/include/IceStorm

SLICE_OBJS 	:= $(patsubst $(SDIR)/%.ice, %.o, $(SLICE_SRCS))

SRCS		= $(SLICE_OBJS:.o=.cpp)

OBJS		= $(addprefix $(OBJDIR)/,$(SLICE_OBJS))

include $(top_srcdir)/config/Make.rules

SLICE2CPPFLAGS	:= --ice --include-dir IceStorm --dll-export ICESTORM_API $(SLICE2CPPFLAGS)

$(libdir)/$(LIBNAME): $(OBJS)
	rm -f $@
	$(call mklib,$@,$(OBJS))

clean::
	rm -rf $(OBJDIR)

install:: all

include .depend
