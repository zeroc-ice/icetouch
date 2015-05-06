# **********************************************************************
#
# Copyright (c) 2003-2014 ZeroC, Inc. All rights reserved.
#
# This copy of Ice Touch is licensed to you under the terms described in the
# ICE_TOUCH_LICENSE file included in this distribution.
#
# **********************************************************************

top_srcdir	= ../..

LIBFILENAME     = $(call mklibfilename,Glacier2ObjC$(libsuffix),$(VERSION))
SONAME		= $(call mksoname,Glacier2ObjC$(libsuffix),$(SOVERSION))
LIBNAME		= $(call mklibname,Glacier2ObjC$(libsuffix))

TARGETS		= $(call mklibtargets,$(libdir)/$(LIBFILENAME),$(libdir)/$(SONAME),$(libdir)/$(LIBNAME))

OBJS		= PermissionsVerifier.o \
		  Router.o \
		  Session.o \
		  SSLInfo.o \
		  Metrics.o

SRCS		:= $(OBJS:.o=.m)

SLICE_SRCS	= $(SDIR)/PermissionsVerifier.ice \
		  $(SDIR)/Router.ice \
		  $(SDIR)/Session.ice \
		  $(SDIR)/SSLInfo.ice \
		  $(SDIR)/Metrics.ice

HDIR		= $(includedir)/Glacier2
SDIR		= $(slicedir)/Glacier2

all::

include $(top_srcdir)/config/Make.rules

OBJS 		:= $(addprefix $(OBJDIR)/,$(OBJS))

CPPFLAGS	:= -I.. -Iinclude -I../../include $(CPPFLAGS)
SLICE2OBJCFLAGS	:= --ice --include-dir Glacier2 $(SLICE2OBJCFLAGS)
DEPENDFLAGS	= --obj-dir

LINKWITH        := $(LIBS)

ifeq ($(STATICLIBS),yes)

$(libdir)/$(LIBNAME): $(OBJS)
	rm -f $@
	$(call mklib,$@,$(OBJS))

else ifeq ($(COMPILE_FOR_MACOSX),yes)

$(libdir)/$(LIBFILENAME): $(OBJS)
	rm -f $@
	$(call mkshlib,$@,$(SONAME),$(OBJS),$(LINKWITH))

$(libdir)/$(SONAME): $(libdir)/$(LIBFILENAME)
	rm -f $@
	ln -s $(LIBFILENAME) $@

$(libdir)/$(LIBNAME): $(libdir)/$(SONAME)
	rm -f $@
	ln -s $(SONAME) $@

else

$(libdir)/$(LIBNAME): $(OBJS)
	rm -f $@
	$(call mkshlib,$@,$(LIBNAME),$(OBJS),$(LINKWITH))

endif

$(OBJDIR)/%.o: %.m
	@mkdir -p $(dir $@)
	$(CC) -c $(ARCFLAGS) $(CPPFLAGS) $(OBJCFLAGS) $(CFLAGS) $< -o $@

ifeq ($(COMPILE_FOR_MACOSX),yes)
install:: all
	$(call installlib,$(install_libdir),$(libdir),$(LIBFILENAME),$(SONAME),$(LIBNAME))
else
install:: all
endif

include .depend
