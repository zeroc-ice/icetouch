#!/usr/bin/env python
# **********************************************************************
#
# Copyright (c) 2003-2014 ZeroC, Inc. All rights reserved.
#
# This copy of Ice Touch is licensed to you under the terms described in the
# ICE_TOUCH_LICENSE file included in this distribution.
#
# **********************************************************************

import os, sys, shutil

#
# Show usage information.
#
def usage():
    print "Usage: " + sys.argv[0] + " [options] [cpp|java|.net]"
    print
    print "Options:"
    print "-h    Show this message."
    print "-f    Force updates to files that otherwise would be skipped."
    print "-d    Debugging output."
    print
    print "The certificates for all languages are updated if you do not specify one."

def newer(file1, file2):
    file1info = os.stat(file1)
    file2info = os.stat(file2)
    return file1info.st_mtime > file2info.st_mtime

def prepareCAHome(dir, force):
    if force and os.path.exists(dir):
        shutil.rmtree(dir)

    if not os.path.exists(dir):
        os.mkdir(dir)

    f = open(os.path.join(dir, "serial"), "w")
    f.write("01")
    f.close()

    f = open(os.path.join(dir, "index.txt"), "w")
    f.truncate(0)
    f.close()

#
# Check arguments
#
force = False
debug = False
lang = None
for x in sys.argv[1:]:
    if x == "-h":
        usage()
        sys.exit(0)
    elif x == "-f":
        force = True
    elif x == "-d":
        debug = True
    elif x.startswith("-"):
        print sys.argv[0] + ": unknown option `" + x + "'"
        print
        usage()
        sys.exit(1)
    else:
        if lang != None or x not in ["cpp", "java", ".net"]:
            usage()
            sys.exit(1)
        lang = x

certs = "."
caHome = os.path.join(certs, "openssl", "ca")

#
# Check for cakey.pem and regenerate it if it doesn't exist or if force is true.
#
caKey = os.path.join(certs, "cakey.pem")
caCert = os.path.join(certs, "cacert.pem")
if not os.path.exists(caKey) or force:

    print "Generating new CA certificate and key..."
    if os.path.exists(caKey):
        os.remove(caKey)
    if os.path.exists(caCert):
        os.remove(caCert)

    prepareCAHome(caHome, force)

    config = os.path.join(certs, "openssl", "ice_ca.cnf")
    cmd = "openssl req -config " + config + " -x509 -days 1825 -newkey rsa:1024 -out " + \
           os.path.join(caHome, "cacert.pem") + " -outform PEM -nodes"
    if debug:
        print "[debug]", cmd
    os.system(cmd)
    shutil.copyfile(os.path.join(caHome, "cakey.pem"), caKey)
    shutil.copyfile(os.path.join(caHome, "cacert.pem"), caCert)

    cmd = "openssl x509 -in " + caCert + " -outform DER -out " + os.path.join(certs, "cacert.der")
    if debug:
        print "[debug]", cmd
    os.system(cmd)

else:
    print "Skipping CA certificate and key."

#
# C++ server RSA certificate and key.
#
cppServerCert = os.path.join(certs, "s_rsa1024_pub.pem")
cppServerKey = os.path.join(certs, "s_rsa1024_priv.pem")
if force or not os.path.exists(cppServerCert) or not os.path.exists(cppServerKey) or \
   (os.path.exists(cppServerCert) and newer(caCert, cppServerCert)):

    print "Generating new C++ server RSA certificate and key..."

    if os.path.exists(cppServerCert):
        os.remove(cppServerCert)
    if os.path.exists(cppServerKey):
        os.remove(cppServerKey)

    serial = os.path.join(caHome, "serial")
    f = open(serial, "r")
    serialNum = f.read().strip()
    f.close()

    tmpKey = os.path.join(caHome, serialNum + "_key.pem")
    tmpCert = os.path.join(caHome, serialNum + "_cert.pem")
    req = os.path.join(caHome, "req.pem")
    config = os.path.join(certs, "openssl", "server.cnf")
    cmd = "openssl req -config " + config + " -newkey rsa:1024 -nodes -keyout " + tmpKey + " -keyform PEM" + \
           " -out " + req
    if debug:
        print "[debug]", cmd
    os.system(cmd)

    cmd = "openssl ca -config " + config + " -batch -in " + req
    if debug:
        print "[debug]", cmd
    os.system(cmd)
    shutil.move(os.path.join(caHome, serialNum + ".pem"), tmpCert)
    shutil.copyfile(tmpKey, cppServerKey)
    shutil.copyfile(tmpCert, cppServerCert)
    os.remove(req)
else:
    print "Skipping C++ server RSA certificate and key."

# C++ client RSA certificate and key.
#
cppClientCert = os.path.join(certs, "c_rsa1024_pub.pem")
cppClientKey = os.path.join(certs, "c_rsa1024_priv.pem")
if force or not os.path.exists(cppClientCert) or not os.path.exists(cppClientKey) or \
   (os.path.exists(cppClientCert) and newer(caCert, cppClientCert)):

    print "Generating new C++ client RSA certificate and key..."

    if os.path.exists(cppClientCert):
        os.remove(cppClientCert)
    if os.path.exists(cppClientKey):
        os.remove(cppClientKey)

    serial = os.path.join(caHome, "serial")
    f = open(serial, "r")
    serialNum = f.read().strip()
    f.close()

    tmpKey = os.path.join(caHome, serialNum + "_key.pem")
    tmpCert = os.path.join(caHome, serialNum + "_cert.pem")
    req = os.path.join(caHome, "req.pem")
    config = os.path.join(certs, "openssl", "client.cnf")
    cmd = "openssl req -config " + config + " -newkey rsa:1024 -nodes -keyout " + tmpKey + " -keyform PEM" + \
           " -out " + req
    if debug:
        print "[debug]", cmd
    os.system(cmd)

    cmd = "openssl ca -config " + config + " -batch -in " + req
    if debug:
        print "[debug]", cmd
    os.system(cmd)
    shutil.move(os.path.join(caHome, serialNum + ".pem"), tmpCert)
    shutil.copyfile(tmpKey, cppClientKey)
    shutil.copyfile(tmpCert, cppClientCert)
    os.remove(req)
else:
    print "Skipping C++ client RSA certificate and key."

#
# .NET server RSA certificate and key.
#
csServer = os.path.join(certs, "s_rsa1024.pfx")
if (lang == ".net" or lang == None) and (force or not os.path.exists(csServer) or newer(cppServerCert, csServer)):

    print "Generating new .NET server RSA certificate and key..."

    if os.path.exists(csServer):
        os.remove(csServer)

    cmd = "openssl pkcs12 -in " + cppServerCert + " -inkey " + cppServerKey + " -export -out " + csServer + \
          " -certpbe PBE-SHA1-RC4-40 -keypbe PBE-SHA1-RC4-40 -passout pass:password"
    if debug:
        print "[debug]", cmd
    os.system(cmd)
else:
    print "Skipping .NET server certificate and key."

#
# .NET client RSA certificate and key.
#
csClient = os.path.join(certs, "c_rsa1024.pfx")
if (lang == ".net" or lang == None) and (force or not os.path.exists(csClient) or \
   (os.path.exists(csClient) and newer(cppClientCert, csClient))):

    print "Generating new .NET client RSA certificate and key..."

    if os.path.exists(csClient):
        os.remove(csClient)

    cmd = "openssl pkcs12 -in " + cppClientCert + " -inkey " + cppClientKey + " -export -out " + csClient + \
          " -certpbe PBE-SHA1-RC4-40 -keypbe PBE-SHA1-RC4-40 -passout pass:password"
    if debug:
        print "[debug]", cmd
    os.system(cmd)
else:
    print "Skipping .NET client certificate and key."

#
# Done.
#
print "Done."
