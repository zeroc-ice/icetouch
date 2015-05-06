# **********************************************************************
#
# Copyright (c) 2003-2014 ZeroC, Inc. All rights reserved.
#
# This copy of Ice Touch is licensed to you under the terms described in the
# ICE_TOUCH_LICENSE file included in this distribution.
#
# **********************************************************************

top_srcdir	= .

include $(top_srcdir)/config/Make.rules

all:
	xcodebuild -configuration Release

clean:
	rm -rf build/*

install: all
	if test -d "$(XCODE_PLUGIN_INSTALL_PATH)/slice2objcplugin.pbplugin"; \
		then rm -rf "$(XCODE_PLUGIN_INSTALL_PATH)/slice2objcplugin.pbplugin"; \
	fi;
	mkdir -p "$(XCODE_PLUGIN_INSTALL_PATH)"
	cp -rf "build/Release/slice2objcplugin.pbplugin" "$(XCODE_PLUGIN_INSTALL_PATH)"
