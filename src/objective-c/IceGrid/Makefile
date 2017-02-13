# **********************************************************************
#
# Copyright (c) 2003-2017 ZeroC, Inc. All rights reserved.
#
# This copy of Ice Touch is licensed to you under the terms described
# in the ICE_LICENSE file included in this distribution.
#
# **********************************************************************

top_srcdir	= ../../..

LIBNAME		= $(call mklibname,IceGridObjC)

TARGETS		= $(libdir)/$(LIBNAME)

SLICE_DIRS	= IceGrid
HEADER_DIRS	= objc/IceGrid

HEADERS		= objc/IceGrid.h

include $(top_srcdir)/config/Make.rules

SLICE2OBJCFLAGS	:= --ice --dll-export ICE_GRID_API $(SLICE2OBJCFLAGS)

install:: all
