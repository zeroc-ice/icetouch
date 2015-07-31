This project builds the test container application for running tests with the
iOS simulator or on an iOS device.

You should use the "container iOS 7" target if you plan to run the tests on
an iOS 7.x device, use the "container" target otherwise. Bundles are not signed
with the iOS 7 target (iOS 7.x doesn't support loading signed bundles).
