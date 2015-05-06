# **********************************************************************
#
# Copyright (c) 2003-2014 ZeroC, Inc. All rights reserved.
#
# This copy of Ice Touch is licensed to you under the terms described in the
# ICE_TOUCH_LICENSE file included in this distribution.
#
# **********************************************************************

top_srcdir	= ../..

LIBFILENAME     = $(call mklibfilename,IceObjC$(libsuffix),$(VERSION))
SONAME		= $(call mksoname,IceObjC$(libsuffix),$(SOVERSION))
LIBNAME		= $(call mklibname,IceObjC$(libsuffix))

TARGETS		= $(call mklibtargets,$(libdir)/$(LIBFILENAME),$(libdir)/$(SONAME),$(libdir)/$(LIBNAME))

OBJC_OBJS	= DispatchInterceptor.o \
		  Request.o \
		  BuiltinSequences.o \
		  Identity.o \
		  LocalException.o \
		  Locator.o \
		  Metrics.o \
		  Process.o \
		  Router.o \
		  Version.o \
		  SliceChecksumDict.o \
		  PropertiesAdmin.o

OBJCPP_OBJS	= Communicator.o \
		  Connection.o \
		  Current.o \
		  Exception.o \
		  Dispatcher.o \
		  IdentityI.o \
		  Initialize.o \
		  Logger.o \
		  Object.o \
		  ObjectAdapter.o \
		  Properties.o \
		  Proxy.o \
		  Stream.o \
		  SlicedData.o \
		  Util.o \
		  VersionI.o \
		  Wrapper.o \
		  ImplicitContext.o \
		  Endpoint.o

SRCS		= $(OBJCPP_OBJS:.o=.mm) \
		  $(OBJC_OBJS:.o=.m) \
		  $(SLICE_OBJC_OBJS:.o=.m)

SLICE_SRCS	= $(SDIR)/BuiltinSequences.ice \
		  $(SDIR)/Identity.ice \
		  $(SDIR)/LocalException.ice \
		  $(SDIR)/Locator.ice \
		  $(SDIR)/Metrics.ice \
		  $(SDIR)/Process.ice \
		  $(SDIR)/ProcessF.ice \
		  $(SDIR)/Router.ice \
		  $(SDIR)/Version.ice \
		  $(SDIR)/SliceChecksumDict.ice

HDIR		= $(includedir)/Ice
SDIR		= $(slicedir)/Ice

all::

include $(top_srcdir)/config/Make.rules

OBJS		:= $(addprefix $(OBJDIR)/,$(OBJC_OBJS)) \
		   $(addprefix $(OBJDIR)/,$(SLICE_OBJC_OBJS)) \
	           $(addprefix $(OBJDIR)/,$(OBJCPP_OBJS)) \
                   $(wildcard ../IceUtilCpp/$(OBJDIR)/IceUtilCpp_*.o) \
	           $(wildcard ../IceCpp/$(OBJDIR)/IceCpp_*.o) \
	 	   $(wildcard ../IceSSLCpp/$(OBJDIR)/IceSSLCpp_*.o) \
	 	   $(wildcard ../Transports/$(OBJDIR)/*.o)

CPPFLAGS	:= -I.. -Iinclude -I../../include -I../IceSSLCpp/include $(CPPFLAGS)
SLICE2OBJCFLAGS	:= --ice --include-dir Ice $(SLICE2OBJCFLAGS)
DEPENDFLAGS	= --obj-dir

ifeq ($(COMPILE_WITH_GC),yes)
   CPPFLAGS		:= -DICE_OBJC_GC $(CPPFLAGS)
endif

ifneq ($(COMPILE_FOR_IPHONE),yes)
    LINKWITH    := $(ICE_OS_LIBS) $(BASELIBS) -framework CoreServices -framework Security -lbz2 -liconv $(OPENSSL_LIBS)
else ifeq ($(COMPILE_FOR_IPHONE_SIMULATOR),yes)
    LINKWITH    := $(ICE_OS_LIBS) $(BASELIBS)
else
    LINKWITH    := $(ICE_OS_LIBS) $(BASELIBS) -framework CFNetwork -framework Security
endif

ifeq ($(STATICLIBS),yes)

$(libdir)/$(LIBNAME): $(OBJS)
	rm -f $@
	$(call mklib,$@,$(OBJS))

else

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

$(OBJDIR)/%.o: %.mm
	@mkdir -p $(dir $@)
	$(CXX) -c $(CPPFLAGS) $(CXXFLAGS) $(OBJCXXFLAGS) $< -o $@

$(OBJDIR)/%.o: %.m
	@mkdir -p $(dir $@)
	$(CC) -c $(CPPFLAGS) $(OBJCFLAGS) $(CFLAGS) $< -o $@

# Prevent generation of these files from .ice files

$(HDIR)/ImplicitContext.h ImplicitContext.m:
	

$(HDIR)/Communicator.h Communicator.m:
	

$(HDIR)/Current.h Current.m:
	

$(HDIR)/Logger.h Logger.m:
	

$(HDIR)/ObjectAdapter.h ObjectAdapter.m:
	

$(HDIR)/Properties.h Properties.m:
	

$(HDIR)/Endpoint.h Endpoint.m:
	

$(HDIR)/Connection.h Connection.m:
	

$(HDIR)/ObjectFactory.h ObjectFactory.m:
	


ice_cpp_include = $(ice_cpp_dir)/include
include/IceUtilCpp/%.h: $(ice_cpp_include)/IceUtil/%.h
	@echo Creating $@ from $<
	@sed -e "s%IceUtil/%IceUtilCpp/%g" $< > $@

include/IceCpp/%.h:  $(ice_cpp_include)/Ice/%.h
	@echo Creating $@ from $<
	@sed -e "s%IceUtil/%IceUtilCpp/%g;s%Ice/%IceCpp/%g" $< > $@

include/IceCpp/%.h:  ../IceCpp/include/Ice/%.h
	@echo Creating $@ from $<
	@sed -e "s%IceUtil/%IceUtilCpp/%g;s%Ice/%IceCpp/%g" $< > $@

include/IceSSLCpp/%.h:  ../IceSSLCpp/include/IceSSL/%.h
	@echo Creating $@ from $<
	@sed -e "s%IceUtil/%IceUtilCpp/%g;s%Ice/%IceCpp/%g;s%IceSSL/%IceSSLCpp/%g" $< > $@

$(SRCS): $(patsubst $(ice_cpp_include)/IceUtil/%.h,include/IceUtilCpp/%.h,$(wildcard $(ice_cpp_include)/IceUtil/*.h)) \
	 $(patsubst $(ice_cpp_include)/Ice/%.h,include/IceCpp/%.h,$(wildcard $(ice_cpp_include)/Ice/*.h)) \
	 $(patsubst ../IceCpp/include/Ice/%.h,include/IceCpp/%.h,$(wildcard ../IceCpp/include/Ice/*.h)) \
	 $(patsubst ../IceSSLCpp/include/IceSSL/%.h,include/IceSSLCpp/%.h,$(wildcard ../IceSSLCpp/include/IceSSL/*.h))

depend:: $(patsubst $(ice_cpp_include)/IceUtil/%.h,include/IceUtilCpp/%.h,$(wildcard $(ice_cpp_include)/IceUtil/*.h)) \
	 $(patsubst $(ice_cpp_include)/Ice/%.h,include/IceCpp/%.h,$(wildcard $(ice_cpp_include)/Ice/*.h)) \
	 $(patsubst ../IceCpp/include/Ice/%.h,include/IceCpp/%.h,$(wildcard ../IceCpp/include/Ice/*.h))

ifeq ($(COMPILE_FOR_MACOSX),yes)
install:: all
	$(call installlib,$(install_libdir),$(libdir),$(LIBFILENAME),$(SONAME),$(LIBNAME))
else
install:: all
endif

clean::
	rm -f include/IceUtilCpp/*.h
	rm -f include/IceCpp/*.h
	rm -f include/IceSSLCpp/*.h

include .depend
