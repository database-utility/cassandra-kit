#!/bin/sh

mkdir -p Build
pushd Build

git clone https://github.com/leetal/ios-cmake.git
git clone https://github.com/datastax/cpp-driver.git

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

cd cpp-driver
git apply ../../CMakeLists.patch

for platform in ${platforms[@]}; do
  mkdir -p "build-$platform"
  pushd "build-$platform"
  cmake .. -G Xcode -DCMAKE_TOOLCHAIN_FILE=../../ios-cmake/ios.toolchain.cmake -DPLATFORM=$platform
  cmake --build . --config Release
  # cmake --install . --config Release
  popd
done

popd

mkdir -p Build/cpp-driver/build-MACCOMBINED/Release
lipo -create \
  Build/cpp-driver/build-MAC/Release/libcassandra_static.a \
  Build/cpp-driver/build-MAC_ARM64/Release/libcassandra_static.a \
  -output Build/cpp-driver/build-MACCOMBINED/Release/libcassandra_static.a

ls -l Build/cpp-driver/build-*/Release

rm -rf libcassandra.xcframework
xcodebuild -create-xcframework \
  -library Build/cpp-driver/build-OS64/Release/libcassandra_static.a \
  -headers Build/cpp-driver/include \
  -library Build/cpp-driver/build-SIMULATOR64/Release/libcassandra_static.a \
  -headers Build/cpp-driver/include \
  -library Build/cpp-driver/build-TVOS/Release/libcassandra_static.a \
  -headers Build/cpp-driver/include \
  -library Build/cpp-driver/build-SIMULATOR_TVOS/Release/libcassandra_static.a \
  -headers Build/cpp-driver/include \
  -library Build/cpp-driver/build-WATCHOSCOMBINED/Release/libcassandra_static.a \
  -headers Build/cpp-driver/include \
  -library Build/cpp-driver/build-SIMULATOR_WATCHOS/Release/libcassandra_static.a \
  -headers Build/cpp-driver/include \
  -library Build/cpp-driver/build-MACCOMBINED/Release/libcassandra_static.a \
  -headers Build/cpp-driver/include \
  -output libcassandra.xcframework

#  -library Build/cpp-driver/build-SIMULATORARM64/Release/libcassandra_static.a \
#  -headers Build/cpp-driver/include \

#xcodebuild -create-xcframework \
#  -library Build/cpp-driver/build-MAC/Release/libcassandra_static.a \
#  -headers Build/cpp-driver/include \
#  -library Build/cpp-driver/build-OS64COMBINED/Release/libcassandra_static.a \
#  -headers Build/cpp-driver/include \
#  -library Build/cpp-driver/build-TVOSCOMBINED/Release/libcassandra_static.a \
#  -headers Build/cpp-driver/include \
#  -library Build/cpp-driver/build-WATCHOSCOMBINED/Release/libcassandra_static.a \
#  -headers Build/cpp-driver/include \
#  -output libcassandra3.xcframework
