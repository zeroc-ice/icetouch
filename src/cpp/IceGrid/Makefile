# **********************************************************************
#
# Copyright (c) 2003-2016 ZeroC, Inc. All rights reserved.
#
# This copy of Ice Touch is licensed to you under the terms described
# in the ICE_LICENSE file included in this distribution.
#
# **********************************************************************

top_srcdir	= ../../..

LIBNAME		= $(call mklibname,IceGrid$(libsuffix))

TARGETS		= $(libdir)/$(LIBNAME)

SLICE_DIRS	= IceGrid
HEADER_DIRS	= IceGrid

include $(top_srcdir)/config/Make.rules

SLICE2CPPFLAGS	:= --ice --dll-export ICE_GRID_API $(SLICE2CPPFLAGS)

install:: all
