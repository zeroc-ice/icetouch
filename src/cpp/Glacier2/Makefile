# **********************************************************************
#
# Copyright (c) 2003-2015 ZeroC, Inc. All rights reserved.
#
# This copy of Ice Touch is licensed to you under the terms described
# in the ICE_TOUCH_LICENSE file included in this distribution.
#
# **********************************************************************

top_srcdir	= ../../..

LIBNAME		= $(call mklibname,Glacier2$(libsuffix))

TARGETS		= $(libdir)/$(LIBNAME)

SLICE_DIRS	= Glacier2
HEADER_DIRS	= Glacier2

SRCS		= Glacier2Lib/SessionHelper.cpp \
			  Glacier2Lib/NullPermissionsVerifier.cpp

include $(top_srcdir)/config/Make.rules

SLICE2CPPFLAGS	:= --ice --dll-export GLACIER2_API $(SLICE2CPPFLAGS)

install:: all
