xcodebuild clean -workspace MLYSDK.xcworkspace -scheme MLYSDK

xcodebuild archive \
    -workspace MLYSDK.xcworkspace \
    -scheme MLYSDK  \
    -configuration Release \
    -sdk iphonesimulator \
    -destination='generic/platform=iOS Simulator' \
    -archivePath ../archives/ios-simulator \
    ENABLE_BITCODE=NO \
    SKIP_INSTALL=NO \
    BUILD_LIBRARY_FOR_DISTRIBUTION=YES

xcodebuild archive \
    -workspace MLYSDK.xcworkspace \
    -scheme MLYSDK  \
    -configuration Release \
    -sdk iphoneos \
    -destination='generic/platform=iOS' \
    -archivePath ../archives/ios-device \
    ENABLE_BITCODE=NO \
    SKIP_INSTALL=NO \
    BUILD_LIBRARY_FOR_DISTRIBUTION=YES

xcodebuild -create-xcframework \
    -framework ../archives/ios-device.xcarchive/Products/Library/Frameworks/MLYSDK.framework \
    -framework ../archives/ios-simulator.xcarchive/Products/Library/Frameworks/MLYSDK.framework \
    -output ../archives/MLYSDK.xcframework