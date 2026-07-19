# Use the old NDK r10e to not get internal compile error at
# https://github.com/PojavLauncherTeam/openjdk-multiarch-jdk8u/blob/aarch64-shenandoah-jdk8u272-b10/jdk/src/share/native/sun/java2d/loops/GraphicsPrimitiveMgr.c
export NDK_VERSION=r10e

if [[ -z "$BUILD_FREETYPE_VERSION" ]]
then
  export BUILD_FREETYPE_VERSION="2.13.3"
fi

if [[ -z "$JDK_DEBUG_LEVEL" ]]
then
  export JDK_DEBUG_LEVEL=release
fi

if [[ "$TARGET_JDK" == "aarch64" ]]
then
  export TARGET_SHORT=arm64
else
  export TARGET_SHORT=$TARGET_JDK
fi

if [[ "$TARGET_JDK" == "aarch32" ]] || [[ "$TARGET_JDK" == "arm" ]] || [[ "$TARGET_JDK" == "x86" ]]
then
  echo "VM variant: client"
  if [[ -z "$JVM_VARIANTS" ]]
  then
    export JVM_VARIANTS=client
  fi
else
  echo "VM variant: server"
  if [[ -z "$JVM_VARIANTS" ]]
  then
    export JVM_VARIANTS=server
  fi
fi

export JVM_PLATFORM=linux
# Set NDK
export API=21
export NDK=$(pwd)/android-ndk-$NDK_VERSION
export ANDROID_NDK_ROOT=$NDK 
export TOOLCHAIN=$NDK/generated-toolchains/android-${TARGET_SHORT}-toolchain
# export TOOLCHAIN=$NDK/toolchains/llvm/prebuilt/linux-x86_64

export ANDROID_INCLUDE=$TOOLCHAIN/sysroot/usr/include

export CPPFLAGS="-I$ANDROID_INCLUDE -I$ANDROID_INCLUDE/$TARGET" # -I/usr/include -I/usr/lib
export LDFLAGS="-L$NDK/platforms/android-$API/arch-$TARGET_SHORT/usr/lib"

# Configure and build.
export AR=$TOOLCHAIN/bin/$TARGET-ar
export AS=$TOOLCHAIN/bin/$TARGET-as
export CC=$TOOLCHAIN/bin/$TARGET-gcc
export CXX=$TOOLCHAIN/bin/$TARGET-g++
export LD=$TOOLCHAIN/bin/$TARGET-ld
export OBJCOPY=$TOOLCHAIN/bin/$TARGET-objcopy
export RANLIB=$TOOLCHAIN/bin/$TARGET-ranlib
export STRIP=$TOOLCHAIN/bin/$TARGET-strip
