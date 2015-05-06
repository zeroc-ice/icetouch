# **********************************************************************
#
# Copyright (c) 2003-2014 ZeroC, Inc. All rights reserved.
#
# This copy of Ice Touch is licensed to you under the terms described in the
# ICE_TOUCH_LICENSE file included in this distribution.
#
# **********************************************************************

top_srcdir	= ../../..

CLIENT		= client

TARGETS		= $(CLIENT)

OBJS		= Library.o \
		  Session.o \
		  Glacier2Session.o \
		  Client.o \
		  Grammar.o \
		  Scanner.o \
		  Parser.o \
		  RunParser.o

SRCS		= $(OBJS:.o=.m)

SLICE_SRCS	= Library.ice \
		  Session.ice \
		  Glacier2Session.ice

include $(top_srcdir)/config/Make.rules

CPPFLAGS	:= -I. $(CPPFLAGS)

#
# Flex and bison generated files doesn't support ARC.
#
Grammar.o: Grammar.m
	$(CC) -c $(CPPFLAGS) $(OBJCFLAGS) $(CFLAGS) $<

Scanner.o: Scanner.m
	$(CC) -c $(CPPFLAGS) $(OBJCFLAGS) $(CFLAGS) $<

$(CLIENT): $(ICEOBJCLIB) $(OBJS) $(CPP_OBJS)
	rm -f $@
	$(CXX) $(LDFLAGS) -o $@ $(OBJS) $(CPP_OBJS) -lGlacier2ObjC$(libsuffix) $(LIBS)

clean::
	-rm -f Grammar.m Grammar.h
	-rm -f Scanner.m

include .depend
