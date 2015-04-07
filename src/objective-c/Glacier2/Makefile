# **********************************************************************
#
# Copyright (c) 2003-2015 ZeroC, Inc. All rights reserved.
#
# This copy of Ice Touch is licensed to you under the terms described
# in the ICE_LICENSE file included in this distribution.
#
# **********************************************************************

top_srcdir	= ../../..

LIBNAME		= $(call mklibname,Glacier2ObjC)

TARGETS		= $(libdir)/$(LIBNAME)

SLICE_DIRS	= Glacier2
HEADER_DIRS	= objc/Glacier2

HEADERS		= objc/Glacier2.h

include $(top_srcdir)/config/Make.rules

SLICE2OBJCFLAGS	:= --ice --dll-export GLACIER2_API $(SLICE2OBJCFLAGS)

install:: all
