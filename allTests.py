#!/usr/bin/env python
# **********************************************************************
#
# Copyright (c) 2003-2015 ZeroC, Inc. All rights reserved.
#
# This copy of Ice Touch is licensed to you under the terms described in the
# ICE_TOUCH_LICENSE file included in this distribution.
#
# **********************************************************************

import os, sys, re, getopt

path = [ ".", "..", "../..", "../../..", "../../../.." ]
head = os.path.dirname(sys.argv[0])
if len(head) > 0:
    path = [os.path.join(head, p) for p in path]
path = [os.path.abspath(p) for p in path if os.path.exists(os.path.join(p, "scripts", "TestUtil.py")) ]
if len(path) == 0:
    raise RuntimeError("can't find toplevel directory!")

sys.path.append(os.path.join(path[0], "scripts"))
import TestUtil

#
# List of all basic tests.
#
tests = [
     ("cpp/Ice/proxy", ["core"]),
     ("cpp/Ice/operations", ["core"]),
     ("cpp/Ice/exceptions", ["core"]),
     ("cpp/Ice/ami", ["core", "nocompress"]),
     ("cpp/Ice/info", ["core", "noipv6", "nocompress"]),
     ("cpp/Ice/inheritance", ["core"]),
     ("cpp/Ice/facets", ["core"]),
     ("cpp/Ice/objects", ["core"]),
     ("cpp/Ice/optional", ["core"]),
     ("cpp/Ice/binding", ["core"]),
     ("cpp/Ice/faultTolerance", ["core", "novalgrind"]), # valgrind reports leak with aborted servers
     ("cpp/Ice/location", ["core"]),
     ("cpp/Ice/adapterDeactivation", ["core"]),
     ("cpp/Ice/slicing/exceptions", ["core"]),
     ("cpp/Ice/slicing/objects", ["core"]),
     ("cpp/Ice/dispatcher", ["once"]),
     ("cpp/Ice/stream", ["core"]),
     ("cpp/Ice/hold", ["core"]),
     ("cpp/Ice/custom", ["core", "nossl", "nows"]),
     ("cpp/Ice/retry", ["core"]),
     ("cpp/Ice/timeout", ["core", "nocompress"]),
     ("cpp/Ice/servantLocator", ["core"]),
     ("cpp/Ice/interceptor", ["core"]),
     ("cpp/Ice/udp", ["core"]),
     ("cpp/Ice/defaultServant", ["core"]),
     ("cpp/Ice/defaultValue", ["core"]),
     ("cpp/Ice/invoke", ["core"]),
     ("cpp/Ice/hash", ["once"]),
     ("cpp/Ice/admin", ["core", "noipv6"]),
     ("cpp/Ice/metrics", ["core", "nossl", "nows", "noipv6", "nocompress", "nomingw"]),
     ("cpp/Ice/enums", ["once"]),
     ("cpp/Ice/services", ["once"]),
     ("objc/Ice/proxy", ["core"]),
     ("objc/Ice/ami", ["core", "nocompress"]),
     ("objc/Ice/operations", ["core"]),
     ("objc/Ice/exceptions", ["core"]),
     ("objc/Ice/inheritance", ["core"]),
     ("objc/Ice/invoke", ["core"]),
     ("objc/Ice/metrics", ["core", "nows", "nossl", "noipv6", "nocompress"]),
     ("objc/Ice/facets", ["core"]),
     ("objc/Ice/objects", ["core"]),
     ("objc/Ice/optional", ["core"]),
     ("objc/Ice/interceptor", ["core"]),
     ("objc/Ice/dispatcher", ["core"]),
     ("objc/Ice/defaultServant", ["core"]),
     ("objc/Ice/servantLocator", ["core"]),
     ("objc/Ice/defaultValue", ["core"]),
     ("objc/Ice/binding", ["core"]),
     ("objc/Ice/stream", ["core"]),
     ("objc/Ice/hold", ["core"]),
     ("objc/Ice/faultTolerance", ["core"]),
     ("objc/Ice/location", ["core"]),
     ("objc/Ice/adapterDeactivation", ["core"]),
     ("objc/Ice/slicing/exceptions", ["core"]),
     ("objc/Ice/slicing/objects", ["core"]),
     ("objc/Ice/retry", ["core"]),
     ("objc/Ice/timeout", ["core", "nocompress"]),
     ("objc/Ice/hash", ["core"]),
     ("objc/Ice/info", ["core", "noipv6", "nocompress"]),
     ("objc/Ice/enums", ["once"]),
     ("objc/Ice/acm", ["core"]),
    ]

if __name__ == "__main__":
    TestUtil.run(tests)
