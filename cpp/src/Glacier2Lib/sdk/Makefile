# **********************************************************************
#
# Copyright (c) 2003-2014 ZeroC, Inc. All rights reserved.
#
# This copy of Ice Touch is licensed to you under the terms described in the
# ICE_TOUCH_LICENSE file included in this distribution.
#
# **********************************************************************

top_srcdir	= ../../..

STATICLIBS 	= yes

LIBNAME		= $(call mklibname,Glacier2Cpp$(libsuffix))

TARGETS		= $(libdir)/$(LIBNAME)

SDIR		= $(slicedir)/Glacier2
HDIR		= $(headerdir)/Glacier2

HEADERS_DIR	= $(top_srcdir)/include/Glacier2
SRCS_DIR	= $(top_srcdir)/src/Glacier2Lib

GLACIER2_OBJS	= SessionHelper.o

ifeq ($(COMPILE_FOR_COCOA),yes)
GLACIER2_OBJS	:= Application.o $(GLACIER2_OBJS)
endif

SLICE_SRCS	= $(SDIR)/PermissionsVerifier.ice \
		  $(SDIR)/Router.ice \
		  $(SDIR)/Session.ice \
		  $(SDIR)/SSLInfo.ice \
		  $(SDIR)/Metrics.ice

SLICE_OBJS 	:= $(patsubst $(SDIR)/%.ice, %.o,$(SLICE_SRCS))

SRCS		=  $(addprefix $(SRCS_DIR)/, $(GLACIER2_OBJS:.o=.cpp)) \
		   $(SLICE_OBJS:.o=.cpp)

OBJS 		= $(addprefix $(OBJDIR)/Glacier2Lib_,$(GLACIER2_OBJS)) \
		  $(addprefix $(OBJDIR)/,$(SLICE_OBJS))

include $(top_srcdir)/config/Make.rules

SLICE2CPPFLAGS	:= --ice --include-dir Glacier2 --dll-export GLACIER2_API $(SLICE2CPPFLAGS)

$(OBJDIR)/Glacier2Lib_%.o: ../%.cpp
	@mkdir -p $(dir $@)
	$(CXX) -c $(CPPFLAGS) $(CXXFLAGS) $< -o $@

$(libdir)/$(LIBNAME): $(OBJS)
	rm -f $@
	$(call mklib,$@,$(OBJS))

clean::
	rm -rf $(OBJDIR)

install:: all

include .depend
