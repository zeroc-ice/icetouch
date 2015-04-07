# **********************************************************************
#
# Copyright (c) 2003-2015 ZeroC, Inc. All rights reserved.
#
# This copy of Ice Touch is licensed to you under the terms described
# in the ICE_LICENSE file included in this distribution.
#
# **********************************************************************

top_srcdir	= ../../..

LIBNAME		= $(call mklibname,IceStorm$(libsuffix))

TARGETS		= $(libdir)/$(LIBNAME)

SLICE_DIRS	= IceStorm
HEADER_DIRS	= IceStorm

include $(top_srcdir)/config/Make.rules

SLICE2CPPFLAGS	:= --ice --dll-export ICE_STORM_API $(SLICE2CPPFLAGS)

install:: all
