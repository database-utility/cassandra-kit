#!/bin/sh

mkdir -p Build
pushd Build

git clone https://github.com/leetal/ios-cmake.git
git clone https://github.com/libuv/libuv.git

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

pushd libuv
for platform in ${platforms[@]}; do
  mkdir -p "build-$platform"
  pushd "build-$platform"
  cmake .. -G Xcode -DCMAKE_TOOLCHAIN_FILE=../../ios-cmake/ios.toolchain.cmake -DPLATFORM=$platform -DLIBUV_BUILD_TESTS=OFF -DLIBUV_BUILD_BENCH=OFF -DCMAKE_XCODE_ATTRIBUTE_CODE_SIGNING_REQUIRED=NO
  cmake --build . --config Release --target uv_a
  # cmake --install . --config Release
  popd
done
popd

popd

mkdir -p Build/libuv/build-MACCOMBINED/Release
lipo -create \
  Build/libuv/build-MAC/Release/libuv_a.a \
  Build/libuv/build-MAC_ARM64/Release/libuv_a.a \
  -output Build/libuv/build-MACCOMBINED/Release/libuv_a.a

ls -l Build/libuv/build-*/Release

rm -rf ../libuv.xcframework
xcodebuild -create-xcframework \
  -library Build/libuv/build-SIMULATOR64/Release-*/libuv_a.a \
  -headers Build/libuv/include \
  -library Build/libuv/build-SIMULATOR_TVOS/Release-*/libuv_a.a \
  -headers Build/libuv/include \
  -library Build/libuv/build-SIMULATOR_WATCHOS/Release-*/libuv_a.a \
  -headers Build/libuv/include \
  -library Build/libuv/build-MACCOMBINED/Release/libuv_a.a \
  -headers Build/libuv/include \
  -library Build/libuv/build-OS64/Release-*/libuv_a.a \
  -headers Build/libuv/include \
  -library Build/libuv/build-TVOS/Release-*/libuv_a.a \
  -headers Build/libuv/include \
  -library Build/libuv/build-WATCHOSCOMBINED/Release-*/libuv_a.a \
  -headers Build/libuv/include \
  -output ../libuv.xcframework
