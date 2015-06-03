# **********************************************************************
#
# Copyright (c) 2003-2015 ZeroC, Inc. All rights reserved.
#
# This copy of Ice Touch is licensed to you under the terms described
# in the ICE_LICENSE file included in this distribution.
#
# **********************************************************************

top_srcdir	= .

#
# Figure out the platforms to build, if empty we'll build all the platforms.
#
PLATFORMS := $(strip $(foreach f,IPHONE IPHONE_SIMULATOR OSX,$(if $(findstring yes,$(COMPILE_FOR_$f)),$f)))

include $(top_srcdir)/config/Make.rules

ifeq ($(USE_BIN_DIST),yes)
SUBDIRS		= test
else
SUBDIRS		= src test
endif

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

ifneq ($(USE_BIN_DIST),yes)
install all:: sdks
endif

sdks:
	if [ ! -d lib ] || [ ! -d lib/IceTouch ]; \
	then \
	    $(call mkdir,lib) ; \
	    $(call mkdir,lib/IceTouch) ; \
	    for sdk in lib/IceTouch/Cpp lib/IceTouch/ObjC; \
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
		touch lib/IceTouch; \
	fi

ifeq ($(PLATFORMS),)
clean::
	rm -rf lib
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

ifeq ($(COMPILE_FOR_OSX),yes)
test::
	@python $(top_srcdir)/allTests.py
endif

install::
	@if test ! -d $(prefix) ; \
	then \
	    echo "Creating $(prefix)..." ; \
	    $(call mkdir,$(prefix)) ; \
	fi
	@if test ! -f $(prefix)/ICE_LICENSE ; \
	then \
	    $(call installdata,$(top_srcdir)/ICE_LICENSE,$(prefix)) ; \
	fi
	@if test ! -f $(prefix)/ICE_LICENSE ; \
	then \
	    $(call installdata,$(ice_dir)/ICE_LICENSE,$(prefix)) ; \
	fi
	@if test ! -f $(prefix)/LICENSE ; \
	then \
	    $(call installdata,$(ice_dir)/LICENSE,$(prefix)) ; \
	fi
	@if test ! -d $(prefix)/lib ; \
	then \
		$(call mkdir,$(prefix)/lib); \
	fi
	@if test ! -d $(prefix)/lib/IceTouch ; \
	then \
		$(call mkdir,$(prefix)/lib/IceTouch); \
	fi
	if [ -d $(prefix)/lib/IceTouch/Cpp ]; \
	then \
		rm -rf $(prefix)/lib/IceTouch/Cpp; \
	fi
	cp -fpr $(top_srcdir)/lib/IceTouch/Cpp $(prefix)/lib/IceTouch/Cpp
	if [ -d $(prefix)/lib/IceTouch/ObjC ]; \
	then \
		rm -rf $(prefix)/lib/IceTouch/ObjC; \
	fi
	cp -fpr $(top_srcdir)/lib/IceTouch/ObjC $(prefix)/lib/IceTouch/ObjC
