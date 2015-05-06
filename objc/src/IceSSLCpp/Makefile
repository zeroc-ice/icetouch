# **********************************************************************
#
# Copyright (c) 2003-2014 ZeroC, Inc. All rights reserved.
#
# This copy of Ice Touch is licensed to you under the terms described in the
# ICE_TOUCH_LICENSE file included in this distribution.
#
# **********************************************************************

top_srcdir	= ../..

OBJS      	= AcceptorI.o \
		  Certificate.o \
                  ConnectorI.o \
                  EndpointI.o \
                  Instance.o \
                  PluginI.o \
                  TransceiverI.o \
                  Util.o \
		  RFC2253.o \
		  TrustManager.o

SLICE_OBJS	= ConnectionInfo.o \
		  EndpointInfo.o

SLICECPP_SRCS	= $(SDIR)/ConnectionInfo.ice \
		  $(SDIR)/EndpointInfo.ice

SDIR		=  $(slicedir)/IceSSL

SRCS_DIR	=  $(ice_dir)/cpp/src/IceSSL

# Copy OBJS for use with the dependency generation, since OBJS is
# later transformed.
SRCS_OBJS	:= $(OBJS)
SRCS_SLICE_OBJS	:= $(SLICE_OBJS)
SRCS		=  $(addprefix $(SRCS_DIR)/, $(SRCS_OBJS:.o=.cpp)) \
		   $(SRCS_SLICE_OBJS:.o=.cpp)

include $(top_srcdir)/config/Make.rules

SLICE_OBJS 	:= $(addprefix $(OBJDIR)/IceSSLCpp_,$(SLICE_OBJS))

ifneq ($(PLATFORM_NAME),macosx)
    OBJS 	:=
else
    OBJS 	:= $(addprefix $(OBJDIR)/IceSSLCpp_,$(OBJS))
endif

CPPFLAGS	:= -Iinclude -I../IceCpp/include -I$(ice_dir)/cpp/include -I$(ice_dir)/cpp/src $(CPPPLATFORMFLAGS)
SLICE2CPPFLAGS	:= --ice --include-dir IceSSL $(SLICE2CPPFLAGS)
DEPENDFLAGS	:= --obj-dir --obj-prefix=IceSSLCpp_

ifeq ($(OPTIMIZE),yes)
   #
   # Disable all warnings to avoid OpenSSL deprecation warnings
   #
   OPENSSL_FLAGS       = -w
endif

CXXFLAGS := $(CXXFLAGS) $(OPENSSL_FLAGS)

ifeq ($(COMPILE_WITH_GC),yes)
   CPPFLAGS		:= -DICE_OBJC_GC $(CPPFLAGS)
endif

all:: $(OBJS) $(SLICE_OBJS)

$(OBJDIR)/IceSSLCpp_%.o: %.cpp
	$(CXX) -c $(CPPFLAGS) $(CXXFLAGS) $< -o $@

$(OBJDIR)/IceSSLCpp_%.o: $(SRCS_DIR)/%.cpp
	$(CXX) -c $(CPPFLAGS) $(CXXFLAGS) $< -o $@

include/IceSSL/%F.h: $(SDIR)/%F.ice $(SLICE2CPP)
	rm -f $(*F)F.h $(*F)F.cpp
	$(SLICE2CPP) $(SLICE2CPPFLAGS) $<
	rm -f $(*F)F.cpp
	mv $(*F)F.h include/IceSSL/$(*F)F.h

include/IceSSL/%.h %.cpp: $(SDIR)/%.ice $(SLICE2CPP)
	rm -f $(*F).h $(*F).cpp
	$(SLICE2CPP) $(SLICE2CPPFLAGS) $<
	mv $(*F).h include/IceSSL/$(*F).h

$(addprefix $(SRCS_DIR)/, $(OBJS:.o=.cpp)): \
	$(patsubst $(SDIR)/%.ice,include/IceSSL/%.h,$(wildcard $(SDIR)/*F.ice)) \
	$(patsubst $(SDIR)/%.ice,include/IceSSL/%.h,$(SLICECPP_SRCS))

install:: $(OBJS) $(SLICE_OBJS)

depend:: $(patsubst $(SDIR)/%.ice,include/IceSSL/%.h,$(wildcard $(SDIR)/*F.ice)) \
	 $(patsubst $(SDIR)/%.ice,include/IceSSL/%.h,$(SLICECPP_SRCS))
	if test -n "$(SLICECPP_SRCS)" ; then \
	    $(SLICE2CPP) --depend $(SLICE2CPPFLAGS) $(SLICECPP_SRCS) | \
		$(ice_dir)/config/makedepend.py include/IceSSL >> .depend; \
	fi
	$(foreach slice, $(SLICECPP_SRCS), echo '$(slice): $$(SLICE2CPP)' >> .depend;)

clean::
	rm -f $(addsuffix .cpp, $(basename $(notdir $(SLICECPP_SRCS))))
	rm -f $(addprefix include/IceSSL, $(addsuffix .h, $(basename $(subst $(SDIR),, \
	$(filter $(SDIR)/%.ice, $(SLICECPP_SRCS))))))

include .depend
