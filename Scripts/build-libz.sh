#!/bin/sh

mkdir -p Build
pushd Build

git clone https://github.com/leetal/ios-cmake.git
git clone https://github.com/madler/zlib.git libz

# FIXME: `WATCHOS` doesn’t seem to work; using `WATCHOSCOMBINED` for now instead
# FIXME: `SIMULATORARM64` doesn’t seem to work
platforms=(
  OS64
  SIMULATOR64
  TVOS
  SIMULATOR_TVOS
  WATCHOSCOMBINED
  SIMULATOR_WATCHOS
  MAC
  MAC_ARM64
  MAC_CATALYST
  MAC_CATALYST_ARM64
)

# FIXME: `COMBINED` doesn’t seem to work; only produces fat files sometimes 🥴
#platforms=(
#  OS64COMBINED
#  TVOSCOMBINED
#  WATCHOSCOMBINED
#  MAC
#  MAC_ARM64
#)

pushd libz
for platform in ${platforms[@]}; do
  mkdir -p "build-$platform"
  pushd "build-$platform"
  cmake .. -G Xcode -DCMAKE_TOOLCHAIN_FILE=../../ios-cmake/ios.toolchain.cmake -DPLATFORM=$platform
  cmake --build . --config Release 2>/dev/null
  DESTDIR=`pwd`/install cmake --install .
  cmake --build . --config Release --target zlibstatic
  popd
done
popd

popd

mkdir -p Build/libz/build-MACCOMBINED/Release
lipo -create \
  Build/libz/build-MAC/Release/libz.a \
  Build/libz/build-MAC_ARM64/Release/libz.a \
  -output Build/libz/build-MACCOMBINED/Release/libz.a

ls -l Build/libz/build-*/Release

rm -rf ../libz.xcframework
xcodebuild -create-xcframework \
  -library Build/libz/build-SIMULATOR64/Release-*/libz.a \
  -headers Build/libz/build-SIMULATOR64/install/usr/local/include \
  -library Build/libz/build-SIMULATOR_TVOS/Release-*/libz.a \
  -headers Build/libz/build-SIMULATOR_TVOS/install/usr/local/include \
  -library Build/libz/build-SIMULATOR_WATCHOS/Release-*/libz.a \
  -headers Build/libz/build-SIMULATOR_WATCHOS/install/usr/local/include \
  -library Build/libz/build-MAC/Release/libz.a \
  -headers Build/libz/build-MAC/install/usr/local/include \
  -library Build/libz/build-OS64/Release-*/libz.a \
  -headers Build/libz/build-SIMULATOR64/install/usr/local/include \
  -library Build/libz/build-TVOS/Release-*/libz.a \
  -headers Build/libz/build-SIMULATOR_TVOS/install/usr/local/include \
  -library Build/libz/build-WATCHOSCOMBINED/Release-*/libz.a \
  -headers Build/libz/build-SIMULATOR_WATCHOS/install/usr/local/include \
  -output ../libz.xcframework

#  -headers Build/libz/include \
