#!/bin/sh

mkdir -p Build
pushd Build

git clone https://github.com/leetal/ios-cmake.git
git clone https://github.com/datastax/cpp-driver.git

platforms=(
  OS64
  SIMULATOR64
  SIMULATORARM64
  TVOS
  SIMULATOR_TVOS
  WATCHOS
  SIMULATOR_WATCHOS
  MAC
  MAC_ARM64
  MAC_CATALYST
  MAC_CATALYST_ARM64
)

# FIXME: `COMBINED` doesn’t seem to work — only produces fat files sometimes 🥴
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
  cmake .. -G Xcode -DCMAKE_TOOLCHAIN_FILE=../../ios-cmake/ios.toolchain.cmake -DPLATFORM=$platform -DCMAKE_MACOSX_RPATH=1 -DCASS_BUILD_SHARED=OFF
  cmake --build . --config Release
  # cmake --install . --config Release
  popd
done

popd

ls -l Build/cpp-driver/build-*/Release

xcodebuild -create-xcframework \
  -library Build/cpp-driver/build-OS64/Release/libcassandra_static.a \
  -headers Build/cpp-driver/include \
  -library Build/cpp-driver/build-SIMULATOR64/Release/libcassandra_static.a \
  -headers Build/cpp-driver/include \
  -library Build/cpp-driver/build-SIMULATORARM64/Release/libcassandra_static.a \
  -headers Build/cpp-driver/include \
  -library Build/cpp-driver/build-TVOS/Release/libcassandra_static.a \
  -headers Build/cpp-driver/include \
  -library Build/cpp-driver/build-SIMULATOR_TVOS/Release/libcassandra_static.a \
  -headers Build/cpp-driver/include \
  -library Build/cpp-driver/build-WATCHOS/Release/libcassandra_static.a \
  -headers Build/cpp-driver/include \
  -library Build/cpp-driver/build-SIMULATOR_WATCHOS/Release/libcassandra_static.a \
  -headers Build/cpp-driver/include \
  -library Build/cpp-driver/build-MAC/Release/libcassandra_static.a \
  -headers Build/cpp-driver/include \
  -library Build/cpp-driver/build-MAC_ARM64/Release/libcassandra_static.a \
  -headers Build/cpp-driver/include \
  -library Build/cpp-driver/build-MAC_CATALYST/Release/libcassandra_static.a \
  -headers Build/cpp-driver/include \
  -library Build/cpp-driver/build-MAC_CATALYST_ARM64/Release/libcassandra_static.a \
  -headers Build/cpp-driver/include \
  -output Build/libcassandra.xcframework

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
