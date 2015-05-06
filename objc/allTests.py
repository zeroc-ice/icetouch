#!/usr/bin/env python
# **********************************************************************
#
# Copyright (c) 2003-2014 ZeroC, Inc. All rights reserved.
#
# This copy of Ice Touch is licensed to you under the terms described in the
# ICE_TOUCH_LICENSE file included in this distribution.
#
# **********************************************************************

import os, sys, re, getopt

for toplevel in [".", "..", "../..", "../../..", "../../../..", "../../../../.."]:
    toplevel = os.path.abspath(toplevel)
    if os.path.exists(os.path.join(toplevel, "scripts", "TestUtil.py")):
        break
else:
    raise "can't find toplevel directory!"

sys.path.append(os.path.join(toplevel))
from scripts import *

#
# List of all basic tests.
#
tests = [ 
     ("Slice/keyword", []),
     ("Ice/proxy", ["core"]),
     ("Ice/ami", ["core"]),
     ("Ice/operations", ["core"]),
     ("Ice/exceptions", ["core"]),
     ("Ice/inheritance", ["core"]),
     ("Ice/invoke", ["core"]),
     ("Ice/metrics", ["core", "nossl", "noipv6", "nocompress"]),
     ("Ice/facets", ["core"]),
     ("Ice/objects", ["core"]),
     ("Ice/optional", ["core"]),
     ("Ice/interceptor", ["core"]),
     ("Ice/dispatcher", ["core"]),
     ("Ice/defaultServant", ["core"]),
     ("Ice/defaultValue", ["core"]),
     ("Ice/binding", ["core"]),
     ("Ice/stream", ["core"]),
     ("Ice/hold", ["core"]),
     ("Ice/faultTolerance", ["core"]),
     ("Ice/location", ["core"]),
     ("Ice/adapterDeactivation", ["core"]),
     ("Ice/slicing/exceptions", ["core"]),
     ("Ice/slicing/objects", ["core"]),
     ("Ice/retry", ["core"]),
     ("Ice/timeout", ["core"]),
     ("Ice/hash", ["core"]),
     ("Ice/info", ["core", "noipv6", "nocompress"]),
     ("Ice/enums", ["once"]),
    ]

if __name__ == "__main__":
    TestUtil.run(tests)
