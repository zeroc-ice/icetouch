# **********************************************************************
#
# Copyright (c) 2003-2014 ZeroC, Inc. All rights reserved.
#
# This copy of Ice is licensed to you under the terms described in the
# ICE_LICENSE file included in this distribution.
#
# **********************************************************************

top_srcdir	= ..

include $(top_srcdir)/config/Make.rules

ifneq ($(COMPILE_FOR_MACOSX),yes)

SUBDIRS = Ice/sdk \
	  Glacier2Lib/sdk \
	  IceStormLib/sdk \
	  IceGridLib/sdk

Glacier2Lib/sdk IceStormLib/sdk: Ice/sdk

IceGridLib/sdk: Ice/sdk Glacier2Lib/sdk

else

SUBDIRS	= IceUtil \
	  Slice \
	  slice2cpp \
	  slice2objc

Slice: IceUtil

slice2cpp slice2objc: Slice

endif

.PHONY: $(EVERYTHING) $(SUBDIRS)

all:: $(SUBDIRS)

$(SUBDIRS):
	@echo "making all in $@"
	@$(MAKE) all --directory=$@

$(EVERYTHING_EXCEPT_ALL)::
	@for subdir in $(SUBDIRS); \
        do \
            if test -d $$subdir ; \
            then \
                echo "making $@ in $$subdir"; \
                ( cd $$subdir && $(MAKE) $@ ) || exit 1; \
            fi; \
        done

