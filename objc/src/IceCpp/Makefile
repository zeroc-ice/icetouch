# **********************************************************************
#
# Copyright (c) 2003-2014 ZeroC, Inc. All rights reserved.
#
# This copy of Ice Touch is licensed to you under the terms described in the
# ICE_TOUCH_LICENSE file included in this distribution.
#
# **********************************************************************

top_srcdir	= ../..

CPP_OBJS	= Acceptor.o \
	          Base64.o \
		  Buffer.o \
		  BasicStream.o \
		  CommunicatorI.o \
		  ConnectRequestHandler.o \
		  ConnectionFactory.o \
		  ConnectionI.o \
		  ConnectionMonitor.o \
		  ConnectionRequestHandler.o \
		  Connector.o \
		  DefaultsAndOverrides.o \
		  Direct.o \
		  DynamicLibrary.o \
		  EndpointFactoryManager.o \
		  EndpointFactory.o \
		  EndpointI.o \
		  EventHandler.o \
		  Exception.o \
		  FactoryTableInit.o \
		  FactoryTable.o \
		  GC.o \
		  ImplicitContextI.o \
		  IncomingAsync.o \
		  Incoming.o \
		  Initialize.o \
		  Instance.o \
		  InstrumentationI.o \
		  LocalObject.o \
		  LocatorInfo.o \
		  LoggerI.o \
		  LoggerUtil.o \
		  MetricsAdminI.o \
		  MetricsObserverI.o \
		  Network.o \
		  ObjectAdapterFactory.o \
		  ObjectAdapterI.o \
		  ObjectFactoryManager.o \
		  Object.o \
		  ObserverHelper.o \
		  OpaqueEndpointI.o \
		  OutgoingAsync.o \
		  Outgoing.o \
		  PluginManagerI.o \
		  PropertiesAdminI.o \
		  PropertiesI.o \
		  PropertyNames.o \
		  Protocol.o \
		  ProtocolPluginFacade.o \
		  ProxyFactory.o \
		  Proxy.o \
		  ReferenceFactory.o \
		  Reference.o \
		  RetryQueue.o \
		  RequestHandler.o \
		  RouterInfo.o \
		  Selector.o \
		  ServantManager.o \
		  SliceChecksums.o \
		  SlicedData.o \
		  StreamI.o \
		  Stream.o \
	          StringConverter.o \
		  SysLoggerI.o \
		  ThreadPool.o \
		  TraceLevels.o \
		  TraceUtil.o \
		  Transceiver.o \
		  UdpConnector.o \
		  UdpEndpointI.o \
		  UdpTransceiver.o \
		  DispatchInterceptor.o \
		  Exception2.o

SLICE_OBJS	= BuiltinSequences.o \
		  Communicator.o \
		  Connection.o \
		  Current.o \
		  Endpoint.o \
		  FacetMap.o \
		  Identity.o \
		  Instrumentation.o \
		  ImplicitContext.o \
		  Metrics.o \
		  LocalException.o \
		  Locator.o \
		  Logger.o \
		  ObjectAdapter.o \
		  ObjectFactory.o \
		  Plugin.o \
		  Process.o \
		  PropertiesAdmin.o \
		  Properties.o \
		  Router.o \
		  ServantLocator.o \
		  SliceChecksumDict.o \
		  Stats.o \
		  Version.o

SLICECPP_SRCS	= $(SDIR)/BuiltinSequences.ice \
		  $(SDIR)/CommunicatorF.ice \
		  $(SDIR)/Communicator.ice \
		  $(SDIR)/ConnectionF.ice \
		  $(SDIR)/Connection.ice \
		  $(SDIR)/Current.ice \
		  $(SDIR)/EndpointF.ice \
		  $(SDIR)/Endpoint.ice \
		  $(SDIR)/EndpointTypes.ice \
		  $(SDIR)/FacetMap.ice \
		  $(SDIR)/Identity.ice \
		  $(SDIR)/InstrumentationF.ice \
		  $(SDIR)/Instrumentation.ice \
		  $(SDIR)/ImplicitContextF.ice \
		  $(SDIR)/ImplicitContext.ice \
		  $(SDIR)/LocalException.ice \
		  $(SDIR)/LocatorF.ice \
		  $(SDIR)/Locator.ice \
		  $(SDIR)/LoggerF.ice \
		  $(SDIR)/Logger.ice \
		  $(SDIR)/Metrics.ice \
		  $(SDIR)/ObjectAdapterF.ice \
		  $(SDIR)/ObjectAdapter.ice \
		  $(SDIR)/ObjectFactoryF.ice \
		  $(SDIR)/ObjectFactory.ice \
		  $(SDIR)/PluginF.ice \
		  $(SDIR)/Plugin.ice \
		  $(SDIR)/ProcessF.ice \
		  $(SDIR)/Process.ice \
		  $(SDIR)/PropertiesF.ice \
		  $(SDIR)/Properties.ice \
		  $(SDIR)/PropertiesAdmin.ice \
		  $(SDIR)/RouterF.ice \
		  $(SDIR)/Router.ice \
		  $(SDIR)/ServantLocatorF.ice \
		  $(SDIR)/ServantLocator.ice \
		  $(SDIR)/SliceChecksumDict.ice \
		  $(SDIR)/StatsF.ice \
		  $(SDIR)/Stats.ice \
		  $(SDIR)/Version.ice

SDIR		=  $(slicedir)/Ice

SRCS_DIR	=  $(ice_dir)/cpp/src/Ice

SRCS_CPP_OBJS	:= $(CPP_OBJS:.o=.cpp)
SRCS_SLICE_OBJS	:= $(SLICE_OBJS:.o=.cpp)

SRCS		=  $(addprefix $(SRCS_DIR)/, $(SRCS_CPP_OBJS)) \
		   $(SRCS_LOCAL_OBJS) \
		   $(SRCS_SLICE_OBJS)

include $(top_srcdir)/config/Make.rules

CPP_OBJS		:= $(addprefix $(OBJDIR)/IceCpp_,$(CPP_OBJS))
SLICE_OBJS 		:= $(addprefix $(OBJDIR)/IceCpp_,$(SLICE_OBJS))
OBJS			:= $(CPP_OBJS) $(SLICE_OBJS)

CPPFLAGS		:= -Iinclude -I$(ice_dir)/cpp/include -I$(ice_dir)/cpp/src $(CPPPLATFORMFLAGS)
SLICE2CPPFLAGS		:= --ice --include-dir Ice $(SLICE2CPPFLAGS)
DEPENDFLAGS		:= --obj-dir --obj-prefix=IceCpp_

ifeq ($(COMPILE_WITH_GC),yes)
   CPPFLAGS		:= -DICE_OBJC_GC $(CPPFLAGS)
endif

all:: $(OBJS)

$(OBJDIR)/IceCpp_%.o: %.cpp
	$(CXX) -c $(CPPFLAGS) $(CXXFLAGS) $< -o $@

$(OBJDIR)/IceCpp_%.o: $(SRCS_DIR)/%.cpp
	$(CXX) -c $(CPPFLAGS) $(CXXFLAGS) $< -o $@

include/Ice/%F.h: $(SDIR)/%F.ice $(SLICE2CPP)
	rm -f $(*F)F.h $(*F)F.cpp
	$(SLICE2CPP) $(SLICE2CPPFLAGS) $<
	rm -f $(*F)F.cpp
	mv $(*F)F.h include/Ice/$(*F)F.h

include/Ice/%.h %.cpp: $(SDIR)/%.ice $(SLICE2CPP)
	rm -f $(*F).h $(*F).cpp
	$(SLICE2CPP) $(SLICE2CPPFLAGS) $<
	mv $(*F).h include/Ice/$(*F).h

$(addprefix $(SRCS_DIR)/, $(CPP_OBJS:.o=.cpp)): \
	$(patsubst $(SDIR)/%.ice,include/Ice/%.h,$(wildcard $(SDIR)/*F.ice)) \
	$(patsubst $(SDIR)/%.ice,include/Ice/%.h,$(SLICECPP_SRCS))

install:: $(OBJS)

depend:: $(patsubst $(SDIR)/%.ice,include/Ice/%.h,$(wildcard $(SDIR)/*F.ice)) \
	 $(patsubst $(SDIR)/%.ice,include/Ice/%.h,$(SLICECPP_SRCS))
	if test -n "$(SLICECPP_SRCS)" ; then \
	    $(SLICE2CPP) --depend $(SLICE2CPPFLAGS) $(SLICECPP_SRCS) | \
		$(ice_dir)/config/makedepend.py include/Ice >> .depend; \
	fi
	$(foreach slice, $(SLICECPP_SRCS), echo '$(slice): $$(SLICE2CPP)' >> .depend;)

clean::
	rm -f $(addsuffix .cpp, $(basename $(notdir $(SLICECPP_SRCS))))
	rm -f $(addprefix include/Ice, $(addsuffix .h, $(basename $(subst $(SDIR),, \
	$(filter $(SDIR)/%.ice, $(SLICECPP_SRCS))))))

include .depend
