# **********************************************************************
#
# Copyright (c) 2003-2014 ZeroC, Inc. All rights reserved.
#
# This copy of Ice is licensed to you under the terms described in the
# ICE_LICENSE file included in this distribution.
#
# **********************************************************************

top_srcdir	= ../..

include $(top_srcdir)/config/Make.rules

SUBDIRS		= admin \
		  ami \
		  adapterDeactivation \
		  binding \
		  defaultServant \
		  defaultValue \
		  dispatcher \
		  enums \
		  exceptions \
		  facets \
		  hash \
		  hold \
		  inheritance \
		  interceptor \
		  invoke \
		  location \
		  metrics \
		  objects \
		  operations \
		  optional \
		  proxy \
		  retry \
		  stream \
		  info \
		  timeout \
		  services \
		  slicing \
		  checksum \
		  custom \
		  servantLocator \
		  udp

ifeq ($(COMPILE_FOR_IPHONE),)
SUBDIRS		:= $(SUBDIRS) \
		   faultTolerance \
		   threadPoolPriority

ifeq ($(COMPILE_FOR_COCOA),)
SUBDIRS		:= $(SUBDIRS) \
		   gc \
		   stringConverter \
		   background \
		   properties \
		   plugin
endif

endif

.PHONY: $(EVERYTHING) $(SUBDIRS)

all:: $(SUBDIRS)

$(SUBDIRS):
	@echo "making all in $@"
	@$(MAKE) all --directory=$@

$(EVERYTHING_EXCEPT_ALL)::
	@for subdir in $(SUBDIRS); \
	do \
	    echo "making $@ in $$subdir"; \
	    ( cd $$subdir && $(MAKE) $@ ) || exit 1; \
	done
