# **********************************************************************
#
# Copyright (c) 2003-2015 ZeroC, Inc. All rights reserved.
#
# This copy of Ice Touch is licensed to you under the terms described
# in the ICE_LICENSE file included in this distribution.
#
# **********************************************************************

top_srcdir	= ../..

TARGETS			= $(top_srcdir)/SDKs/Cpp/bin/slice2cpp $(top_srcdir)/SDKs/ObjC/bin/slice2objc

# Compile sources from the the IceUtil, Slice directories
SRC_DIRS		:= IceUtil Slice

SLICE2CPP_SRCS 	:= slice2cpp/Main.cpp slice2cpp/Gen.cpp
SLICE2OBJC_SRCS := slice2objc/Main.cpp slice2objc/Gen.cpp

SRCS			:= $(SLICE2CPP_SRCS) $(SLICE2OBJC_SRCS)

# Don't compile the sources below, they aren't needed for translators.
EXCLUDE_SRCS	:= IceUtil/CountDownLatch.cpp \
				   IceUtil/StopWatch.cpp \
				   IceUtil/Timer.cpp \
				   IceUtil/Thread.cpp \
				   Slice/Grammar.cpp \
				   Slice/Scanner.cpp \
				   Slice/DotNetNames.cpp \
				   Slice/CsUtil.cpp \
				   Slice/JavaUtil.cpp \
				   Slice/Python.cpp \
				   Slice/PythonUtil.cpp \
				   Slice/PHPUtil.cpp \
				   Slice/Ruby.cpp \
				   Slice/RubyUtil.cpp

FLEXFLAGS	    := -L
BISONFLAGS		:= --name-prefix "slice_" -dvt

COMPILE_TRANSLATORS = yes

include $(top_srcdir)/config/Make.rules

SLICE2CPP_OBJS  = $(filter-out $(OBJDIR)/slice2objc/%,$(OBJS)) $(OBJDIR)/Grammar.o $(OBJDIR)/Scanner.o
SLICE2OBJC_OBJS = $(filter-out $(OBJDIR)/slice2cpp/%,$(OBJS)) $(OBJDIR)/Grammar.o $(OBJDIR)/Scanner.o

$(top_srcdir)/SDKs/Cpp/bin/slice2cpp: $(SLICE2CPP_OBJS)
	$(CXX) $(LDFLAGS) $(LDEXEFLAGS) -o $@ $(SLICE2CPP_OBJS) $(MCPP_LIBS)

$(top_srcdir)/SDKs/ObjC/bin/slice2objc: $(SLICE2OBJC_OBJS)
	$(CXX) $(LDFLAGS) $(LDEXEFLAGS) -o $@ $(SLICE2OBJC_OBJS) $(MCPP_LIBS)

%.o: %.cpp
	@$(call mkobj,$<,$@,-I$(cppdir)/src $(CPPFLAGS),$(CXX))

$(OBJDIR)/Grammar.h $(OBJDIR)/Grammar.cpp: $(cppdir)/src/Slice/Grammar.y | $(OBJDIR)
	@rm -f Grammar.h Grammar.cpp
	bison $(BISONFLAGS) $<
	@mv Grammar.tab.c $(OBJDIR)/Grammar.cpp
	@mv Grammar.tab.h $(OBJDIR)/Grammar.h
	@rm -f Grammar.output

$(OBJDIR)/Scanner.cpp: $(cppdir)/src/Slice/Scanner.l | $(OBJDIR)
	flex $(FLEXFLAGS) $<
	@rm -f $@
	@echo '#include <IceUtil/ScannerConfig.h>' >> $@
	@cat lex.yy.c >> $@
	@rm -f lex.yy.c

clean::
	rm -f Scanner.cpp Grammar.cpp Grammar.h
