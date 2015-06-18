# Building Ice Touch on OS X

This page describes the Ice Touch source distribution, including information
about compiler requirements, third-party dependencies, and instructions for
building and testing the distribution. If you prefer, you can install a
[Homebrew][1] package instead.

## Build Requirements

### Operating Systems and Compilers

Ice Touch is supported on OS X, and was extensively tested using the operating
system and compiler versions listed for our [supported platforms][2].

### Third-Party Libraries

Ice Touch depends on [mcpp][3] 2.7.2 (with patches). To install mcpp you have a
couple of options:

- Using [Homebrew][4], install mcpp with these commands:

        $ brew tap zeroc-ice/tap
        $ brew install mcpp

- Download the mcpp source distributions and build them yourself.

### Ice Builder for Xcode

The [Ice Builder for Xcode][5] plug-in is required for building the iOS test
projects in this distribution.

## Building Ice Touch

Edit `config/Make.rules` to establish your build configuration. The comments in
the file provide more information. Pay particular attention to the variables
that define the locations of the third-party libraries.

In a command window, run `make` to build Ice Touch. 

This will build:

- the Slice-to-C++ and Slice-to-Objective-C compilers
- the C++ Xcode SDK
- the Objective-C Xcode SDK
- the C++ tests
 
The Xcode SDKs are built in the `lib/IceTouch` directory.

You should now use Xcode to build the test suite GUI located in the
following subdirectories:

- `test/cpp/iPhone/container`
- `test/objective-c/iPhone/container`

## Installing Ice Touch

Run `make install` to install Ice Touch in the directory specified by the
`prefix` variables in `config/Make.rules`.

The use Ice Touch, add one of the following directories to the `Additional SDKs`
setting in your Xcode project build settings:

- `prefix/lib/IceTouch/ObjC/$(PLATFORM_NAME).sdk` for the Objective-C SDK
- `prefix/lib/IceTouch/Cpp/$(PLATFORM_NAME).sdk` for the C++ SDK

## Running the Test Suite

Python is required to run the test suite. After a successful source build, you
can run the tests as follows:

    $ python allTests.py

If everything worked out, you should see lots of `ok` messages. In case of a
failure, the tests abort with `failed`.

For the iPhone or iPhone simulator, the test suite runs within an iPhone
application named `Test Suite`. You can run it from the Xcode project located in
the `test/cpp/iPhone/container` or `test/objective-c/iPhone/container`
directories.

[1]: https://doc.zeroc.com/display/Ice36/Using+the+Ice+Touch+Binary+Distribution
[2]: https://zeroc.com/platforms_3_6_0.html
[3]: https://github.com/zeroc-ice/mcpp
[4]: http://brew.sh
[5]: https://github.com/zeroc-ice/ice-builder-xcode
