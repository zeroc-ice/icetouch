# **********************************************************************
#
# Copyright (c) 2003-2014 ZeroC, Inc. All rights reserved.
#
# This copy of Ice Touch is licensed to you under the terms described in the
# ICE_TOUCH_LICENSE file included in this distribution.
#
# **********************************************************************

top_srcdir	= ../..

LIBFILENAME     = $(call mklibfilename,IceGridObjC$(libsuffix),$(VERSION))
SONAME		= $(call mksoname,IceGridObjC$(libsuffix),$(SOVERSION))
LIBNAME		= $(call mklibname,IceGridObjC$(libsuffix))

TARGETS		= $(call mklibtargets,$(libdir)/$(LIBFILENAME),$(libdir)/$(SONAME),$(libdir)/$(LIBNAME))

OBJS		= Admin.o \
		  Descriptor.o \
		  Exception.o \
		  FileParser.o \
		  Locator.o \
		  Observer.o \
		  Query.o \
		  Registry.o \
		  Session.o \
		  UserAccountMapper.o

SRCS		:= $(OBJS:.o=.m)

SLICE_SRCS	= $(SDIR)/Admin.ice \
		  $(SDIR)/Descriptor.ice \
		  $(SDIR)/Exception.ice \
		  $(SDIR)/FileParser.ice \
		  $(SDIR)/Locator.ice \
		  $(SDIR)/Observer.ice \
		  $(SDIR)/Query.ice \
		  $(SDIR)/Registry.ice \
		  $(SDIR)/Session.ice \
		  $(SDIR)/UserAccountMapper.ice

HDIR		= $(includedir)/IceGrid
SDIR		= $(slicedir)/IceGrid

all::

include $(top_srcdir)/config/Make.rules

OBJS 		:= $(addprefix $(OBJDIR)/,$(OBJS))

CPPFLAGS	:= -I.. -Iinclude -I../../include $(CPPFLAGS)
SLICE2OBJCFLAGS	:= --ice --include-dir IceGrid $(SLICE2OBJCFLAGS)
DEPENDFLAGS	= --obj-dir

LINKWITH        := $(LIBS)

ifeq ($(STATICLIBS),yes)

$(libdir)/$(LIBNAME): $(OBJS)
	rm -f $@
	$(call mklib,$@,$(OBJS))

else

LINKWITH := $(LINKWITH) -lGlacier2Objc$(libsuffix)

$(libdir)/$(LIBFILENAME): $(OBJS)
	rm -f $@
	$(call mkshlib,$@,$(SONAME),$(OBJS),$(LINKWITH))

$(libdir)/$(SONAME): $(libdir)/$(LIBFILENAME)
	rm -f $@
	ln -s $(LIBFILENAME) $@

$(libdir)/$(LIBNAME): $(libdir)/$(SONAME)
	rm -f $@
	ln -s $(SONAME) $@

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
