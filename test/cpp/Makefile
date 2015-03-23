# **********************************************************************
#
# Copyright (c) 2003-2015 ZeroC, Inc. All rights reserved.
#
# This copy of Ice is licensed to you under the terms described in the
# ICE_LICENSE file included in this distribution.
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

ifeq ($(COMPILE_FOR_IPHONE),)
SUBDIRS:= $(SUBDIRS) \
		  Ice/faultTolerance
endif

.PHONY: $(EVERYTHING) $(SUBDIRS)

.PRECIOUS: %/Makefile %/run.py

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
			sed -e 's/"scripts", "TestUtil\.py"/"allTests\.py"/g' \
			    -e 's/path\[0\]/os.getenv("ICE_HOME", os.path.join(path[0], ".." , "ice-dev"))/g' > $*/run.py; \
			chmod a+x $*/run.py; \
		fi; \
	fi
	@echo "making all in $*"
	@$(MAKE) all --directory=$*

$(filter-out clean,$(EVERYTHING_EXCEPT_ALL))::
	@for subdir in $(SUBDIRS); \
	do \
		if [ -d $$subdir ]; \
		    echo "making $@ in $$subdir"; \
		    ( cd $$subdir && $(MAKE) $@ ) || exit 1; \
		fi
	done

clean::
	rm -rf Ice
