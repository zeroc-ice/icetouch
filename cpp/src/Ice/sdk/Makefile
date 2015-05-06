# **********************************************************************
#
# Copyright (c) 2003-2014 ZeroC, Inc. All rights reserved.
#
# This copy of Ice Touch is licensed to you under the terms described in the
# ICE_TOUCH_LICENSE file included in this distribution.
#
# **********************************************************************

top_srcdir	= ../../..

STATICLIBS      = yes

LIBNAME		= $(call mklibname,IceCpp$(libsuffix))

TARGETS		= $(libdir)/$(LIBNAME)

ICE_OBJS	= Acceptor.o \
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
		  Exception2.o \
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
		  DispatchInterceptor.o

ICEUTIL_OBJS 	= ArgVector.o \
		  Cond.o \
		  ConvertUTF.o \
		  Exception.o \
		  FileUtil.o \
		  Random.o \
		  MutexProtocol.o \
		  Options.o \
		  RecMutex.o \
		  Shared.o \
		  StringUtil.o \
		  Thread.o \
		  ThreadException.o \
		  Time.o \
		  Timer.o \
		  Unicode.o \
		  UUID.o \
		  CountDownLatch.o

TRANSPORTS_OBJS	= Acceptor.o \
		  Connector.o \
		  Transceiver.o \
		  EndpointI.o \
		  Initialization.o

TRANSPORTS_OBJC_OBJS = \
		  AccessoryConnector.o \
		  AccessoryEndpointI.o \
		  AccessoryTransceiver.o \
		  Notifications.o

ICETCP_OBJS 	= TcpEndpointI.o \
		  TcpAcceptor.o \
		  TcpConnector.o \
		  TcpTransceiver.o

ICESSL_OBJS 	= AcceptorI.o \
		  Certificate.o \
		  ConnectorI.o \
		  EndpointI.o \
		  Instance.o \
		  PluginI.o \
		  TransceiverI.o \
		  Util.o \
		  RFC2253.o \
		  TrustManager.o

ICESSL_SLICE_OBJS = \
		  ConnectionInfo.o \
		  EndpointInfo.o

SLICE_SRCS	= $(SDIR)/BuiltinSequences.ice \
		  $(SDIR)/CommunicatorF.ice \
		  $(SDIR)/Communicator.ice \
		  $(SDIR)/ConnectionF.ice \
		  $(SDIR)/Connection.ice \
		  $(SDIR)/Current.ice \
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
		  $(SDIR)/PropertiesAdmin.ice \
		  $(SDIR)/PropertiesF.ice \
		  $(SDIR)/Properties.ice \
		  $(SDIR)/RouterF.ice \
		  $(SDIR)/Router.ice \
		  $(SDIR)/ServantLocatorF.ice \
		  $(SDIR)/ServantLocator.ice \
		  $(SDIR)/SliceChecksumDict.ice \
		  $(SDIR)/StatsF.ice \
		  $(SDIR)/Stats.ice \
		  $(SDIR)/Version.ice

ICESSL_SLICE_SRCS = \
		  $(ICESSL_SDIR)/ConnectionInfo.ice \
		  $(ICESSL_SDIR)/EndpointInfo.ice

SDIR		= $(slicedir)/Ice
HDIR		= $(headerdir)/Ice
SRCS_DIR	= $(ice_dir)/cpp/src
OBJC_SRCS_DIR	= $(ice_dir)/objc/src

ICEUTIL_HDIR	= $(headerdir)/IceUtil

ICESSL_SDIR 	= $(slicedir)/IceSSL
ICESSL_HDIR 	= $(headerdir)/IceSSL

SLICE_OBJS 	  = $(patsubst $(SDIR)/%.ice, %.o, $(patsubst %F.ice, ,$(SLICE_SRCS)))
ICESSL_SLICE_OBJS = $(patsubst $(ICESSL_SDIR)/%.ice, %.o, $(patsubst %F.ice, ,$(ICESSL_SLICE_SRCS)))

COMMON_SRCS 	= $(addprefix $(SRCS_DIR)/Ice/,     	$(ICE_OBJS:.o=.cpp)) \
		  $(addprefix $(SRCS_DIR)/IceUtil/, 	$(ICEUTIL_OBJS:.o=.cpp)) \
		  $(addprefix $(SRCS_DIR)/Ice/sdk/, 	$(SLICE_OBJS:.o=.cpp)) \
		  $(addprefix $(SRCS_DIR)/Ice/sdk/IceSSL/, $(ICESSL_SLICE_OBJS:.o=.cpp))

#
# NOTE: no prefix for objects created from Slice files, this isn't
# supported by dependencies (makedepend.py doesn't add the
# prefix). This is fine as long as we don't have Slice files with the
# same names in different directories.
#
COMMON_OBJS 	= $(addprefix $(OBJDIR)/IceUtil_,$(ICEUTIL_OBJS)) \
	    	  $(addprefix $(OBJDIR)/Ice_,	 $(ICE_OBJS)) \
	      	  $(addprefix $(OBJDIR)/,	 $(SLICE_OBJS)) \
		  $(addprefix $(OBJDIR)/IceSSL_, $(ICESSL_SLICE_OBJS))

ifeq ($(COMPILE_FOR_COCOA),yes)
DEPEND 		= .depend.macosx

ICEUTILOSX_OBJS = CtrlCHandler.o

ICEOSX_OBJS	= Application.o \
		  Service.o

SRCS 		= $(COMMON_SRCS) \
		  $(addprefix $(SRCS_DIR)/IceUtil/,	$(ICEUTILOSX_OBJS:.o=.cpp)) \
		  $(addprefix $(SRCS_DIR)/Ice/,		$(ICETCP_OBJS:.o=.cpp)) \
		  $(addprefix $(SRCS_DIR)/Ice/,		$(ICEOSX_OBJS:.o=.cpp)) \
		  $(addprefix $(SRCS_DIR)/IceSSL/, 	$(ICESSL_OBJS:.o=.cpp))

OBJS 		= $(COMMON_OBJS) \
	          $(addprefix $(OBJDIR)/IceUtil_,	$(ICEUTIL_OSX_OBJS)) \
	          $(addprefix $(OBJDIR)/Ice_,		$(ICETCP_OBJS)) \
	          $(addprefix $(OBJDIR)/Ice_,		$(ICE_OSX_OBJS)) \
		  $(addprefix $(OBJDIR)/IceSSL_,	$(ICESSL_OBJS))

else

DEPEND 		= .depend.ios

SRCS 		= $(COMMON_SRCS) \
	  	  $(addprefix $(OBJC_SRCS_DIR)/Transports/, $(TRANSPORTS_OBJS:.o=.cpp)) \
		  $(addprefix $(OBJC_SRCS_DIR)/Transports/, $(TRANSPORTS_OBJC_OBJS:.o=.mm))

OBJS 		= $(COMMON_OBJS) \
		  $(addprefix $(OBJDIR)/Transports_,$(TRANSPORTS_OBJS)) \
		  $(addprefix $(OBJDIR)/Transports_,$(TRANSPORTS_OBJC_OBJS))

endif

HEADERS	= \
    $(patsubst $(top_srcdir)/include/IceUtil/%.h,$(ICEUTIL_HDIR)/%.h,$(wildcard $(top_srcdir)/include/IceUtil/*.h)) \
    $(patsubst $(top_srcdir)/include/Ice/%.h,$(HDIR)/%.h,$(wildcard $(top_srcdir)/include/Ice/*.h)) \
    $(patsubst $(top_srcdir)/include/IceSSL/%.h,$(ICESSL_HDIR)/%.h,$(wildcard $(top_srcdir)/include/IceSSL/*.h)) \
    $(patsubst $(SDIR)/%F.ice, $(HDIR)/%F.h, $(wildcard $(SDIR)/*F.ice)) \
    $(patsubst $(ICESSL_SDIR)/%F.ice, $(ICESSL_HDIR)/%F.h, $(wildcard $(ICESSL_SDIR)/*F.ice))

include $(top_srcdir)/config/Make.rules

CPPFLAGS	:= -I$(SRCS_DIR) $(CPPFLAGS)
ifneq ($(COMPILE_FOR_COCOA),yes)
CPPFLAGS	:= -I$(OBJC_SRCS_DIR)/Transports $(CPPFLAGS)
endif

SLICE2CPPFLAGS	:= --ice --include-dir Ice $(SLICE2CPPFLAGS)

$(libdir)/$(LIBNAME): $(OBJS)
	rm -f $@
	$(call mklib,$@,$(OBJS))

$(ICEUTIL_HDIR)/%.h: $(top_srcdir)/include/IceUtil/%.h
	@mkdir -p $(dir $@)
	cp $< $@
	chmod a+r $@

$(HDIR)/%.h: $(top_srcdir)/include/Ice/%.h
	@mkdir -p $(dir $@)
	cp $< $@
	chmod a+r $@

$(ICESSL_HDIR)/%.h $(SRCS_DIR)/Ice/sdk/IceSSL/%.cpp: $(ICESSL_SDIR)/%.ice $(SLICE2CPP)
	@mkdir -p IceSSL
	rm -f $(ICESSL_HDIR)/$(*F).h $(SRCS_DIR)/Ice/sdk/IceSSL/$(*F).cpp
	$(SLICE2CPP) --ice --include-dir IceSSL -I$(slicedir) --output-dir IceSSL $<
	mv IceSSL/$(*F).h $(ICESSL_HDIR)/$(*F).h

$(ICESSL_HDIR)/%.h: $(top_srcdir)/include/IceSSL/%.h
	@mkdir -p $(dir $@)
	cp $< $@
	chmod a+r $@

$(OBJDIR)/Ice_%.o: ../%.cpp
	@mkdir -p $(dir $@)
	$(CXX) -c $(CPPFLAGS) $(CXXFLAGS) $< -o $@

$(OBJDIR)/IceUtil_%.o: $(SRCS_DIR)/IceUtil/%.cpp
	@mkdir -p $(dir $@)
	$(CXX) -c $(CPPFLAGS) $(CXXFLAGS) $< -o $@

$(OBJDIR)/IceSSL_%.o: $(SRCS_DIR)/IceSSL/%.cpp
	@mkdir -p $(dir $@)
	$(CXX) -c $(CPPFLAGS) $(CXXFLAGS) $(OPENSSL_FLAGS) $< -o $@

$(OBJDIR)/IceSSL_%.o: $(SRCS_DIR)/Ice/sdk/IceSSL/%.cpp
	@mkdir -p $(dir $@)
	$(CXX) -c $(CPPFLAGS) $(CXXFLAGS) $(OPENSSL_FLAGS) $< -o $@

$(OBJDIR)/Transports_%.o: $(OBJC_SRCS_DIR)/Transports/%.cpp
	@mkdir -p $(dir $@)
	$(CXX) -c $(CPPFLAGS) $(CXXFLAGS) $< -o $@

$(OBJDIR)/Transports_%.o: $(OBJC_SRCS_DIR)/Transports/%.mm
	@mkdir -p $(dir $@)
	$(CXX) -c $(CPPFLAGS) $(CXXFLAGS) $(OBJCXXFLAGS) $< -o $@

$(TARGETS): $(HEADERS)

depend:: $(ICESSL_SLICE_SRCS)
	 $(SLICE2CPP) --ice --depend --include-dir IceSSL -I$(slicedir) --output-dir IceSSL $(ICESSL_SLICE_SRCS) | \
	 $(ice_dir)/config/makedepend.py "\$$(ICESSL_HDIR)" $(SRCS_DIR)/Ice/sdk/IceSSL;

depend:: $(HEADERS) $(SRCS) 
	mv .depend $(DEPEND)

clean::
	rm -rf $(OBJDIR)
	rm -f $(addprefix $(ICESSL_HDIR), $(addsuffix .h, $(basename $(subst $(ICESSL_SDIR),, \
		$(filter $(ICESSL_SDIR)/%.ice, $(ICESSL_SLICE_SRCS))))))
	rm -rf IceSSL
	rm -rf $(HEADERS)

install:: all

include $(DEPEND)
