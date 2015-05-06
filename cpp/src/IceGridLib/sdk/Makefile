# **********************************************************************
#
# Copyright (c) 2003-2014 ZeroC, Inc. All rights reserved.
#
# This copy of Ice Touch is licensed to you under the terms described in the
# ICE_TOUCH_LICENSE file included in this distribution.
#
# **********************************************************************

top_srcdir	= ../../..

STATICLIBS      = yes

LIBNAME		= $(call mklibname,IceGridCpp$(libsuffix))

TARGETS		= $(libdir)/$(LIBNAME)

SLICE_SRCS	= $(SDIR)/Admin.ice \
		  $(SDIR)/Exception.ice \
		  $(SDIR)/Locator.ice \
		  $(SDIR)/Query.ice \
		  $(SDIR)/Session.ice \
		  $(SDIR)/Descriptor.ice \
		  $(SDIR)/FileParser.ice \
		  $(SDIR)/Observer.ice \
		  $(SDIR)/Registry.ice \
		  $(SDIR)/UserAccountMapper.ice

SDIR		= $(slicedir)/IceGrid
HDIR		= $(headerdir)/IceGrid

HEADERS_DIR	= $(top_srcdir)/include/IceGrid

SLICE_OBJS 	:= $(patsubst $(SDIR)/%.ice, %.o, $(SLICE_SRCS))

SRCS		= $(SLICE_OBJS:.o=.cpp)

OBJS		= $(addprefix $(OBJDIR)/,$(SLICE_OBJS))

include $(top_srcdir)/config/Make.rules

SLICE2CPPFLAGS	:= --ice --include-dir IceGrid --dll-export ICEGRID_API $(SLICE2CPPFLAGS)

$(libdir)/$(LIBNAME): $(OBJS)
	rm -f $@
	$(call mklib,$@,$(OBJS))

clean::
	rm -rf $(OBJDIR)

install:: all

include .depend
