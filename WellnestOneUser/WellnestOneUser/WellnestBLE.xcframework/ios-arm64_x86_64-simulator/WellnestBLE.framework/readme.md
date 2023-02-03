**To create xcframework run the below commands from the p`rojects root directory**

xcodebuild archive -scheme WellnestBLE -destination 'generic/platform=iOS Simulator'  -archivePath WellnestBLE-Sim SKIP_INSTALL=NO BUILD_LIBRARY_FOR_DISTRIBUTION=YES

xcodebuild archive -scheme WellnestBLE -destination generic/platform=iOS  -archivePath WellnestBLE-Device SKIP_INSTALL=NO BUILD_LIBRARY_FOR_DISTRIBUTION=YES

xcodebuild -create-xcframework -framework './WellnestBLE-Device.xcarchive/Products/Library/Frameworks/WellnestBLE.framework'  -framework './WellnestBLE-Sim.xcarchive/Products/Library/Frameworks/WellnestBLE.framework' -output WellnestBLE.xcframework

The xcframework file will be created.
