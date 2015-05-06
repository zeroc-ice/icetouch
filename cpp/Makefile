# **********************************************************************
#
# Copyright (c) 2003-2014 ZeroC, Inc. All rights reserved.
#
# This copy of Ice is licensed to you under the terms described in the
# ICE_LICENSE file included in this distribution.
#
# **********************************************************************

top_srcdir	= .

include $(top_srcdir)/config/Make.rules

SUBDIRS		= src test

INSTALL_SUBDIRS	= $(install_bindir)

install:: install-common
	@for subdir in $(INSTALL_SUBDIRS); \
	do \
	    if test ! -d $$subdir ; \
	    then \
		echo "Creating $$subdir..." ; \
		mkdir -p $$subdir ; \
		chmod a+rx $$subdir ; \
	    fi ; \
	done
ifeq ($(create_runpath_symlink),yes)
	@if test -h $(embedded_runpath_prefix) ; \
	then \
	     if `\rm -f $(embedded_runpath_prefix) 2>/dev/null`; \
              then echo "Removed symbolic link $(embedded_runpath_prefix)"; fi \
        fi
	@if ! test -d $(embedded_runpath_prefix) ; \
	then \
	     if `ln -s $(prefix) $(embedded_runpath_prefix) 2>/dev/null`; \
              then echo "Created symbolic link $(embedded_runpath_prefix) --> $(prefix)"; fi \
	fi
endif

ifneq ($(COMPILE_FOR_MACOSX),yes)

all:: sdks

install:: sdks

sdks: $(ice_cpp_dir)/bin/slice2cpp
	if [ ! -d SDKs ]; \
	then \
	    $(call mkdir,SDKs) ; \
	    for sdk in SDKs/Cpp; \
	    do \
	        $(call mkdir,$$sdk) ;\
	        $(call mkdir,$$sdk/bin) ;\
	        $(call mkdir,$$sdk/slice) ;\
	        for platform in macosx iphoneos iphonesimulator ; \
	        do \
	            platform_sdk=$$sdk/$$platform.sdk ;\
	            $(call mkdir,$$platform_sdk) ;\
	            $(call mkdir,$$platform_sdk/usr) ;\
	            $(call mkdir,$$platform_sdk/usr/local) ;\
	            $(call mkdir,$$platform_sdk/usr/local/include) ;\
	            $(call mkdir,$$platform_sdk/usr/local/include/IceUtil) ;\
	            $(call mkdir,$$platform_sdk/usr/local/include/Ice) ;\
	            $(call mkdir,$$platform_sdk/usr/local/include/IceSSL) ;\
	            $(call mkdir,$$platform_sdk/usr/local/include/Glacier2) ;\
	            $(call mkdir,$$platform_sdk/usr/local/include/IcePatch2) ;\
	            $(call mkdir,$$platform_sdk/usr/local/include/IceGrid) ;\
	            $(call mkdir,$$platform_sdk/usr/local/include/IceStorm) ;\
	            $(call mkdir,$$platform_sdk/usr/local/lib) ;\
	            $(INSTALL_DATA) $(top_srcdir)/../config/$$platform-SDKSettings.plist \
                                $$platform_sdk/SDKSettings.plist ;\
	            chmod a+r $$platform_sdk/SDKSettings.plist ;\
	        done ;\
	        for subdir in $(top_srcdir)/../slice/* ; \
	        do \
	            echo "Copying slice/$$subdir to $$sdk/slice..." ; \
	            cp -fpr $(top_srcdir)/../slice/$$subdir $$sdk/slice ; \
	        done ;\
	    done; \
	    $(call installprogram,$(ice_cpp_dir)/bin/slice2cpp,SDKs/Cpp/bin); \
        fi
clean::
	rm -rf SDKs

endif

$(EVERYTHING)::
	@for subdir in $(SUBDIRS); \
	do \
	    echo "making $@ in $$subdir"; \
	    ( cd $$subdir && $(MAKE) -f Makefile $@ ) || exit 1; \
	done

test::
	@python $(top_srcdir)/allTests.py
