#!/usr/bin/env python
# **********************************************************************
#
# Copyright (c) 2003-2016 ZeroC, Inc. All rights reserved.
#
# This copy of Ice Touch is licensed to you under the terms described
# in the ICE_LICENSE file included in this distribution.
#
# **********************************************************************

import os, sys, re, getopt

sys.path.append(os.path.join(os.path.dirname(__file__), "ice", "scripts"))
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
     ("objective-c/Ice/proxy", ["core"]),
     ("objective-c/Ice/ami", ["core", "nocompress"]),
     ("objective-c/Ice/operations", ["core"]),
     ("objective-c/Ice/exceptions", ["core"]),
     ("objective-c/Ice/inheritance", ["core"]),
     ("objective-c/Ice/invoke", ["core"]),
     ("objective-c/Ice/metrics", ["core", "nows", "nossl", "noipv6", "nocompress"]),
     ("objective-c/Ice/facets", ["core"]),
     ("objective-c/Ice/objects", ["core"]),
     ("objective-c/Ice/optional", ["core"]),
     ("objective-c/Ice/interceptor", ["core"]),
     ("objective-c/Ice/dispatcher", ["core"]),
     ("objective-c/Ice/defaultServant", ["core"]),
     ("objective-c/Ice/servantLocator", ["core"]),
     ("objective-c/Ice/defaultValue", ["core"]),
     ("objective-c/Ice/binding", ["core"]),
     ("objective-c/Ice/stream", ["core"]),
     ("objective-c/Ice/hold", ["core"]),
     ("objective-c/Ice/faultTolerance", ["core"]),
     ("objective-c/Ice/location", ["core"]),
     ("objective-c/Ice/adapterDeactivation", ["core"]),
     ("objective-c/Ice/slicing/exceptions", ["core"]),
     ("objective-c/Ice/slicing/objects", ["core"]),
     ("objective-c/Ice/retry", ["core"]),
     ("objective-c/Ice/timeout", ["core", "nocompress"]),
     ("objective-c/Ice/hash", ["core"]),
     ("objective-c/Ice/info", ["core", "noipv6", "nocompress"]),
     ("objective-c/Ice/enums", ["once"]),
     ("objective-c/Ice/acm", ["core"]),
    ]

# Run tests relative to ice sub-directory.
tests = [ (os.path.join("..", "test", x), y) for x, y in tests ]
if __name__ == "__main__":
    TestUtil.run(tests, True)
