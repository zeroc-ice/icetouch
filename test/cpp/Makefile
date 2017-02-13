# **********************************************************************
#
# Copyright (c) 2003-2017 ZeroC, Inc. All rights reserved.
#
# This copy of Ice Touch is licensed to you under the terms described
# in the ICE_LICENSE file included in this distribution.
#
# **********************************************************************

top_srcdir	= ../..

include $(top_srcdir)/config/Make.rules

SUBDIRS	= Ice/admin \
	  Ice/ami \
	  Ice/adapterDeactivation \
	  Ice/binding \
	  Ice/defaultServant \
	  Ice/defaultValue \
	  Ice/dispatcher \
	  Ice/enums \
	  Ice/exceptions \
	  Ice/facets \
	  Ice/hash \
	  Ice/hold \
	  Ice/inheritance \
	  Ice/interceptor \
	  Ice/invoke \
	  Ice/location \
	  Ice/metrics \
	  Ice/objects \
	  Ice/operations \
	  Ice/optional \
	  Ice/proxy \
	  Ice/retry \
	  Ice/stream \
	  Ice/info \
	  Ice/timeout \
	  Ice/services \
	  Ice/slicing/objects \
	  Ice/slicing/exceptions \
	  Ice/custom \
	  Ice/servantLocator \
	  Ice/udp

ifeq ($(PLATFORM_NAME),macosx)
SUBDIRS:= $(SUBDIRS) \
	  Ice/faultTolerance
endif

.PHONY: $(EVERYTHING) $(SUBDIRS)

all:: $(addsuffix .target,$(SUBDIRS))

#
# Copy the Makefile and run.py script from the C++ source tree (fix
# the top_srcdir and remove the -I option from the Makefile)
#
%.target:
	@if [ ! -d $* ]; \
	then \
	    mkdir -p $*; \
	    cat $(testdir)/$*/Makefile | \
	    sed -e 's/^top_srcdir.*= \./top_srcdir = \.\.\/\./g' -e 's/-I[\.\/a-z]* //g' > $*/Makefile; \
	    if [ -f $(testdir)/$*/run.py ]; \
	    then \
	        cat $(testdir)/$*/run.py | \
		sed -e 's/"scripts", "TestUtil\.py"/"allTests\.py"/g' -e 's/path\[0\]/path[0], "ice"/g' > $*/run.py; \
		chmod a+x $*/run.py; \
	    fi; \
	fi
	@echo "making all in $*"
	@$(MAKE) all --directory=$*

clean::
	rm -rf Ice
