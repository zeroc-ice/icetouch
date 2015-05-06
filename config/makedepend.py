#!/usr/bin/env python
# **********************************************************************
#
# Copyright (c) 2003-2014 ZeroC, Inc. All rights reserved.
#
# This copy of Ice is licensed to you under the terms described in the
# ICE_LICENSE file included in this distribution.
#
# **********************************************************************

import sys, os, fileinput, re, string, getopt

previous = ""

commentre = re.compile("^#")

for top_srcdir in [".", "..", "../..", "../../..", "../../../.."]:
    top_srcdir = os.path.normpath(top_srcdir)
    if os.path.exists(os.path.join(top_srcdir, "..", "config", "makedepend.py")):
        break
else:
    raise RuntimeError("can't find top level source directory!")

includedirs = [ (r"^" + top_srcdir + "/include/(.*)", r"$(includedir)/\1"),
                (r"^" + top_srcdir + "/SDKs/Cpp/[\w\.]+/usr/local/include/(.*)", r"$(includedir)/\1"),
                (r"^" + top_srcdir + "/../cpp/include/(.*)", r"$(ice_cpp_dir)/include/\1") ]

srcdirs = [ top_srcdir + "/src",
            top_srcdir + "/../cpp/src",
            top_srcdir + "/../objc/src" ]

try:
    opts, args = getopt.getopt(sys.argv[1:], "n", ["nmake"])
except getopt.GetoptError:
    raise RuntimeError("invalid arguments")

platformPrefix = ""
if os.getcwd().endswith("/sdk"):
    platformPrefix = "$(OBJDIR)/"

prefix = None
if len(args) > 0:
    prefix = args[0]

cppPrefix = None
if len(args) > 1:
    cppPrefix = args[1]

nmake = False
for o, a in opts:
    if o in ("-n", "--nmake"):
        nmake = True

depend = None
if not nmake:
    depend = open(".depend", "a")
dependmak = open(".depend.mak", "a")

lang = None
for line in fileinput.input("-"):
    line = line.strip()

    if commentre.search(line, 0):
        continue;

    if len(line) == 0:
        continue

    if(previous):
        line = previous + " " + line

    if(line[-1] == "\\"):
        previous = line[:-2]
        continue
    else:
        previous = ""

    line = string.replace(line, ".o:", "$(OBJEXT):")

    if platformPrefix != "" and line.find("$(OBJEXT):") != -1:
        s = line.split()

        subdir = s[1][0:s[1].rfind('/')]
        if subdir.endswith("sdk"):
            subdir = ""
        else:
            found = False
            for d in srcdirs:
                if subdir.startswith(d):
                    subdir = subdir[len(d) + 1:]
                    found = True
            if not found:
                subdir = ""

        idx = subdir.rfind('/')
        if idx >= 0:
            subdir = subdir[idx + 1:]
        if subdir != "":
            line =  platformPrefix + subdir + "_" + line
        else:
            line =  platformPrefix + line

    i = 0
    for s in line.split():
        if(s[0] == "/"):
            continue

        if i == 0 and s.endswith(".h") and prefix != None:
            if depend:
                print >>depend, prefix + "/" + s,
            print >>dependmak, prefix + "\\" + s,
            i += 1
            continue

        if s.endswith(".cs:"):
            lang = "cs"
            s = "generated/" + s
            if depend:
                print >>depend, s,
            print >>dependmak, s,
            continue

        if s.endswith(".cpp:"):
            lang = "cpp"
            if cppPrefix != None:
                if depend:
                    print >>depend, cppPrefix + "/" + s,
                print >>dependmak, cppPrefix + "\\" + s,
                continue

        if s.endswith(".rb:") and prefix != None:
            s = prefix + "/" + s
            if depend:
                print >>depend, s,
            print >>dependmak, s,
            continue

        if s.endswith(".php:"):
            lang = "php"
            if prefix != None:
                s = prefix + "/" + s
                if depend:
                    print >>depend, s,
                print >>dependmak, s,
                continue

        match = False
        for (m,r) in includedirs:
            if re.match(m, s):
                match = True
                s = re.sub(m, r, s)
                if depend:
                    print >>depend, s,
                    print >>dependmak, '"' + s + '"',
                continue
        if match: 
            continue

        idx = s.find("./slice")
        if idx >= 0:
            s = "$(slicedir)" + s[idx + 7:]
            if depend:
                print >>depend, s,
            print >>dependmak, '"' + s + '"',
            continue

        if depend:
            print >>depend, s,
        print >>dependmak, s,

    if lang == "cpp":
        if depend:
            print >>depend, "$(SLICE2CPP) $(SLICEPARSERLIB)"
        print >>dependmak, "\"$(SLICE2CPP)\" \"$(SLICEPARSERLIB)\""
    elif lang == "cs":
        if depend:
            print >>depend, "$(SLICE2CS) $(SLICEPARSERLIB)"
        print >>dependmak, "\"$(SLICE2CS)\" \"$(SLICEPARSERLIB)\""
    elif lang == "php":
        if depend:
            print >>depend, "$(SLICE2PHP) $(SLICEPARSERLIB)"
        print >>dependmak, "\"$(SLICE2PHP)\" \"$(SLICEPARSERLIB)\""
    else:
        if depend:
            print >>depend
        print >>dependmak

if depend:
    depend.close()
dependmak.close()
