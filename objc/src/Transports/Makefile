# **********************************************************************
#
# Copyright (c) 2003-2014 ZeroC, Inc. All rights reserved.
#
# This copy of Ice Touch is licensed to you under the terms described in the
# ICE_TOUCH_LICENSE file included in this distribution.
#
# **********************************************************************

top_srcdir	= ../..

CF_OBJS		= Acceptor.o \
		  Connector.o \
		  Transceiver.o \
		  EndpointI.o \
		  Initialization.o

OBJC_OBJS	= AccessoryConnector.o \
		  AccessoryEndpointI.o \
		  AccessoryTransceiver.o \
		  Notifications.o

SRCS_DIR	= $(ice_dir)/cpp/src/Ice

TCP_OBJS	= TcpEndpointI.o \
		  TcpAcceptor.o \
		  TcpConnector.o \
		  TcpTransceiver.o

# Copy CF_OBJS/TCP_OBJS for use with the dependency generation, since
# OBJS is later transformed.
SRCS_CF_OBJS	:= $(CF_OBJS)
SRCS_OBJC_OBJS	:= $(OBJC_OBJS)
SRCS_TCP_OBJS	:= $(TCP_OBJS)

ifeq ($(COMPILE_FOR_IPHONE_SIMULATOR),yes)
    PLATFORM_NAME = iphonesimulator
else ifeq ($(COMPILE_FOR_IPHONE),yes)
    PLATFORM_NAME = iphoneos
else ifeq ($(COMPILE_FOR_COCOA),yes)
    PLATFORM_NAME = macosx
else
    PLATFORM_NAME = macosx
endif

ifeq ($(PLATFORM_NAME), macosx)
SRCS		= $(addprefix $(SRCS_DIR)/, $(SRCS_TCP_OBJS:.o=.cpp)) \
		  $(SRCS_CF_OBJS:.o=.cpp)
DEPEND 		= .depend.macosx
else
SRCS 		= $(SRCS_CF_OBJS:.o=.cpp) \
		  $(SRCS_OBJC_OBJS:.o=.mm)
DEPEND 		= .depend.ios
endif

include $(top_srcdir)/config/Make.rules

CPPFLAGS	:= -I. -I../IceCpp/include -I../IceSSLCpp/include -I$(ice_dir)/cpp/include -I$(ice_dir)/cpp/src \
		   $(CPPPLATFORMFLAGS)
DEPENDFLAGS	= --obj-dir

ifeq ($(COMPILE_WITH_GC),yes)
   CPPFLAGS		:= -DICE_OBJC_GC $(CPPFLAGS)
endif

ifneq ($(PLATFORM_NAME),macosx)
CPPFLAGS	:= $(CPPFLAGS) -I../IceSSL/include
OBJS		:= $(addprefix $(OBJDIR)/,$(CF_OBJS))

ifeq ($(COMPILE_FOR_IPHONE),yes)
    OBJS += $(addprefix $(OBJDIR)/,$(OBJC_OBJS))
endif

$(OBJDIR)/%.o: %.cpp
	$(CXX) -c $(CPPFLAGS) $(CXXFLAGS) $< -o $@

$(OBJDIR)/%.o: %.mm
	$(CXX) -c $(CPPFLAGS) $(CXXFLAGS) $(OBJCXXFLAGS) $< -o $@

else

OBJS	:= $(addprefix $(OBJDIR)/,$(TCP_OBJS))

$(OBJDIR)/%.o: $(SRCS_DIR)/%.cpp
	$(CXX) -c $(CPPFLAGS) $(CXXFLAGS) $< -o $@

endif

ifneq ($(PLATFORM_NAME),macosx)
depend:: $(HEADERS) $(SRCS) 
	mv .depend $(DEPEND)
	@sed -e "s%\$$(ice_cpp_dir)/include/IceSSL%../IceSSL/include/IceSSL%g" -i "" $(DEPEND)
else
depend:: $(HEADERS) $(SRCS) 
	mv .depend $(DEPEND)
endif

all:: $(OBJS)

install:: $(OBJS)

include $(DEPEND)
