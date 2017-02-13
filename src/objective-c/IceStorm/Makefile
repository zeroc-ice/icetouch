# **********************************************************************
#
# Copyright (c) 2003-2017 ZeroC, Inc. All rights reserved.
#
# This copy of Ice Touch is licensed to you under the terms described
# in the ICE_LICENSE file included in this distribution.
#
# **********************************************************************

top_srcdir	= ../../..

LIBNAME		= $(call mklibname,IceStormObjC)

TARGETS		= $(libdir)/$(LIBNAME)

SLICE_DIRS	= IceStorm
HEADER_DIRS	= objc/IceStorm

HEADERS		= objc/IceStorm.h

include $(top_srcdir)/config/Make.rules

SLICE2OBJCFLAGS	:= --ice --dll-export ICE_STORM_API $(SLICE2OBJCFLAGS)

install:: all
