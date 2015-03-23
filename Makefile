# **********************************************************************
#
# Copyright (c) 2003-2015 ZeroC, Inc. All rights reserved.
#
# This copy of Ice Touch is licensed to you under the terms described
# in the ICE_TOUCH_LICENSE file included in this distribution.
#
# **********************************************************************

top_srcdir	= .

#
# Figure out the platforms to build, if empty we'll build all the platforms.
#
PLATFORMS := $(strip $(foreach f,IPHONE IPHONE_SIMULATOR OSX,$(if $(findstring yes,$(COMPILE_FOR_$f)),$f)))

include $(top_srcdir)/config/Make.rules

SUBDIRS		= src test

INSTALL_SUBDIRS	=

install::
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

all:: sdks

install:: sdks
	$(call mkdir,$(prefix)/SDKs)

sdks:
	if [ ! -d SDKs ]; \
	then \
	    $(call mkdir,SDKs) ; \
	    for sdk in SDKs/Cpp SDKs/ObjC; \
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
	            $(call mkdir,$$platform_sdk/usr/local/include/IceGrid) ;\
	            $(call mkdir,$$platform_sdk/usr/local/include/IceStorm) ;\
	            $(call mkdir,$$platform_sdk/usr/local/lib) ;\
	            $(INSTALL_DATA) $(top_srcdir)/config/$$platform-SDKSettings.plist $$platform_sdk/SDKSettings.plist ;\
	            chmod a+r $$platform_sdk/SDKSettings.plist ;\
	        done ;\
	        for subdir in $(ice_dir)/slice/* ; \
	        do \
	            echo "Copying $$subdir to $$sdk/slice..." ; \
	            cp -fpr $$subdir $$sdk/slice ; \
	        done ;\
	    done; \
    else \
		touch SDKs; \
	fi

ifeq ($(PLATFORMS),)
clean::
	rm -rf SDKs
endif

$(EVERYTHING)::
	@for subdir in $(SUBDIRS); \
	do \
        for platform in $(if $(PLATFORMS),$(PLATFORMS),OSX IPHONE IPHONE_SIMULATOR); \
	    do \
	        echo "making COMPILE_FOR_$$platform=yes $@ in $$subdir"; \
	        ( cd $$subdir && $(MAKE) -f Makefile $@ COMPILE_FOR_$$platform=yes ) || exit 1; \
	    done; \
	done

tests:
	for platform in $(if $(PLATFORMS),$(PLATFORMS),OSX IPHONE IPHONE_SIMULATOR); \
	do \
	    echo "making COMPILE_FOR_$$platform=yes"; \
	    ( cd test && $(MAKE) -f Makefile COMPILE_FOR_$$platform=yes ) || exit 1; \
	done; \

install::
	@if test ! -d $(prefix) ; \
	then \
	    echo "Creating $(prefix)..." ; \
	    $(call mkdir,$(prefix)) ; \
	fi
	@if test ! -f $(prefix)/ICE_TOUCH_LICENSE ; \
	then \
	    $(call installdata,$(top_srcdir)/ICE_TOUCH_LICENSE,$(prefix)) ; \
	fi
	@if test ! -f $(prefix)/ICE_LICENSE ; \
	then \
	    $(call installdata,$(top_srcdir)/ice/ICE_LICENSE,$(prefix)) ; \
	fi
	@if test ! -f $(prefix)/LICENSE ; \
	then \
	    $(call installdata,$(top_srcdir)/ice/LICENSE,$(prefix)) ; \
	fi
	if [ -d $(prefix)/SDKs/Cpp ]; \
	then \
		rm -rf $(prefix)/SDKs/Cpp; \
	fi
	cp -fpr $(top_srcdir)/SDKs/Cpp $(prefix)/SDKs/Cpp
	if [ -d $(prefix)/SDKs/ObjC ]; \
	then \
		rm -rf $(prefix)/SDKs/ObjC; \
	fi
	cp -fpr $(top_srcdir)/SDKs/ObjC $(prefix)/SDKs/ObjC
