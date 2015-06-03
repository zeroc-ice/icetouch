# **********************************************************************
#
# Copyright (c) 2003-2015 ZeroC, Inc. All rights reserved.
#
# This copy of Ice Touch is licensed to you under the terms described
# in the ICE_LICENSE file included in this distribution.
#
# **********************************************************************

top_srcdir	= ../../..

LIBNAME		= $(call mklibname,Ice$(libsuffix))

TARGETS		= $(libdir)/$(LIBNAME)

# Headers for these Slices files won't be installed in the SDK
PRIVATE_SLICE_SRCS 	= IceDiscovery/IceDiscovery.ice \
			  IceLocatorDiscovery/IceLocatorDiscovery.ice \

SLICE_DIRS		= Ice IceSSL
HEADER_DIRS	  	= IceUtil Ice IceSSL
SRC_DIRS		= IceUtil Ice IceDiscovery IceLocatorDiscovery

LOCAL_SRCS		= Notifications.mm
EXCLUDE_SRCS 		= Ice/DLLMain.cpp Ice/RegisterPlugins.cpp

ifeq ($(COMPILE_FOR_OSX),yes)

SRC_DIRS 		+= IceSSL
LOCAL_SRCS		+= RegisterPlugins.cpp

else

LOCAL_SRCS		+= $(wildcard *.cpp)
EXCLUDE_SRCS 		+= IceUtil/CtrlCHandler.cpp \
			   Ice/Application.cpp \
			   Ice/Service.cpp \
			   Ice/StreamSocket.cpp \
			   Ice/TcpEndpointI.cpp \
			   Ice/TcpAcceptor.cpp \
			   Ice/TcpConnector.cpp \
			   Ice/TcpTransceiver.cpp

endif

include $(top_srcdir)/config/Make.rules

CPPFLAGS		:= -DICE_API_EXPORTS $(CPPFLAGS)
SLICE2CPPFLAGS		:= --ice --dll-export ICE_API $(SLICE2CPPFLAGS)

ifneq ($(PLATFORM_NAME),macosx)
SLICE2CPPFLAGS		:= -DICE_USE_CFSTREAM $(SLICE2CPPFLAGS)
endif

install:: all

# Rules for local sources
$(OBJDIR)/%.o: %.cpp
	@$(call mkobj,$<,$@,-I$(cppdir)/src $(CXX_CPPFLAGS))

$(OBJDIR)/%.o: %.mm
	@$(call mkobj,$<,$@,-I$(cppdir)/src $(OBJCXX_CPPFLAGS))
