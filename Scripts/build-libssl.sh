#!/bin/sh

mkdir -p Build
pushd Build

git clone https://github.com/leetal/ios-cmake.git
#git clone https://github.com/openssl/openssl.git libssl
git clone https://github.com/janbar/openssl-cmake.git libssl

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

pushd libssl
for platform in ${platforms[@]}; do
  mkdir -p "build-$platform"
  pushd "build-$platform"
  cmake .. -G Xcode -DCMAKE_TOOLCHAIN_FILE=../../ios-cmake/ios.toolchain.cmake -DPLATFORM=$platform -DWITH_APPS=OFF
  cmake --build . --config Release
  #cmake --install . --config Release
  mkdir -p ssl/include
  cp -rv include/openssl ssl/include
  mkdir -p crypto/include
  cp -rv include/crypto crypto/include
  popd
done
popd

popd

mkdir -p Build/libssl/build-MACCOMBINED/Release
lipo -create \
  Build/libssl/build-MAC/Release/libssl_a.a \
  Build/libssl/build-MAC_ARM64/Release/libssl_a.a \
  -output Build/libssl/build-MACCOMBINED/Release/libssl_a.a

ls -l Build/libssl/build-*/Release

rm -rf ../libssl.xcframework
xcodebuild -create-xcframework \
  -library Build/libssl/build-MAC/ssl/Release/libssl.a \
  -headers Build/libssl/build-MAC/ssl/include \
  -library Build/libssl/build-OS64/ssl/Release-*/libssl.a \
  -headers Build/libssl/build-OS64/ssl/include \
  -library Build/libssl/build-SIMULATOR64/ssl/Release-*/libssl.a \
  -headers Build/libssl/build-SIMULATOR64/ssl/include \
  -library Build/libssl/build-SIMULATOR_TVOS/ssl/Release-*/libssl.a \
  -headers Build/libssl/build-SIMULATOR_TVOS/ssl/include \
  -library Build/libssl/build-SIMULATOR_WATCHOS/ssl/Release-*/libssl.a \
  -headers Build/libssl/build-SIMULATOR_WATCHOS/ssl/include \
  -library Build/libssl/build-WATCHOSCOMBINED/ssl/Release-*/libssl.a \
  -headers Build/libssl/build-WATCHOSCOMBINED/ssl/include \
  -library Build/libssl/build-TVOS/ssl/Release-*/libssl.a \
  -headers Build/libssl/build-TVOS/ssl/include \
  -output ../libssl.xcframework

rm -rf ../libcrypto.xcframework
xcodebuild -create-xcframework \
  -library Build/libssl/build-MAC/crypto/Release/libcrypto.a \
  -headers Build/libssl/build-MAC/crypto/include \
  -library Build/libssl/build-OS64/crypto/Release-*/libcrypto.a \
  -headers Build/libssl/build-OS64/crypto/include \
  -library Build/libssl/build-SIMULATOR64/crypto/Release-*/libcrypto.a \
  -headers Build/libssl/build-SIMULATOR64/crypto/include \
  -library Build/libssl/build-SIMULATOR_TVOS/crypto/Release-*/libcrypto.a \
  -headers Build/libssl/build-SIMULATOR_TVOS/crypto/include \
  -library Build/libssl/build-SIMULATOR_WATCHOS/crypto/Release-*/libcrypto.a \
  -headers Build/libssl/build-SIMULATOR_WATCHOS/crypto/include \
  -library Build/libssl/build-WATCHOSCOMBINED/crypto/Release-*/libcrypto.a \
  -headers Build/libssl/build-WATCHOSCOMBINED/crypto/include \
  -library Build/libssl/build-TVOS/crypto/Release-*/libcrypto.a \
  -headers Build/libssl/build-TVOS/crypto/include \
  -output ../libcrypto.xcframework
