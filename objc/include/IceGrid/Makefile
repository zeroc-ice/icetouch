# **********************************************************************
#
# Copyright (c) 2003-2014 ZeroC, Inc. All rights reserved.
#
# This copy of Ice Touch is licensed to you under the terms described in the
# ICE_TOUCH_LICENSE file included in this distribution.
#
# **********************************************************************

top_srcdir	= ../..

include $(top_srcdir)/config/Make.rules


ifeq ($(COMPILE_FOR_MACOSX),yes)
INSTALL_DIR = $(install_includedir)/IceGrid

install::
else

INSTALL_DIR = $(SDK_DIR)/usr/local/include/IceGrid

install:: all

all::
endif
	@if test ! -d $(INSTALL_DIR) ; \
	then \
	    echo "Creating $(INSTALL_DIR)..." ; \
	    $(call mkdir,$(INSTALL_DIR)) ; \
	fi

	@for i in *.h ; \
	do \
	    echo "Installing $$i" ; \
	    $(INSTALL_DATA) $$i $(INSTALL_DIR)/$$i ; \
	    chmod a+r $(INSTALL_DIR)/$$i ; \
	done

depend::
