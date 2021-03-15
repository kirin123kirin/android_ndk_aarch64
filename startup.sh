#!/bin/bash

export HOST_ARCH=aarch64-linux-android
PREFIX=/usr/local
export NDK_ROOT=${PREFIX}/${HOST_ARCH}
TOOL_PREFIX=${NDK_ROOT}/bin/${HOST_ARCH}
SYSROOTPATH=$NDK_ROOT/sysroot

export CC=${TOOL_PREFIX}-gcc
export CXX=${TOOL_PREFIX}-g++
export LD=${TOOL_PREFIX}-ld
export AR=${TOOL_PREFIX}-ar
export AS=${TOOL_PREFIX}-as
export CPP="${TOOL_PREFIX}-g++ -E"
export RANLIB=${TOOL_PREFIX}-ranlib
export READELF=${TOOL_PREFIX}-readelf
export CPPFLAGS="--sysroot=$SYSROOTPATH"  # https://stackoverflow.com/questions/11655911/cross-compiling-libevent-for-android
#export CPPFLAGS="-nostdlib $CFLAGS" # kumikomiyou
export CPATH=$(find /usr/ -name "include" | grep -v "^/usr/include$" | tr -t "\n" ":"| sed 's/:$//')

chapi () {
    OLD_VERSION=$ANDROID_API_VERSION
    export ANDROID_API_VERSION=${1:-${ANDROID_API_VERSION}}
    TARGET_FILES="$CC $CXX ${NDK_ROOT}/bin/*android-clang* ${NDK_ROOT}/bin/clang ${NDK_ROOT}/bin/clang++"

    if [ `ls $TARGET_FILES 2>/dev/null | wc -l` -ne 0 ]; then
        LDFLAGS=`cat <<EOL | tr -t "\n" " " | sed 's/ $//'
        -L${NDK_ROOT}/lib
        -L${SYSROOTPATH}/usr/lib/${HOST_ARCH}/${ANDROID_API_VERSION}
        -L${NDK_ROOT}/sysroot/usr/lib/${HOST_ARCH}
        -L$(find ${NDK_ROOT}/lib -name "*.a" -exec dirname {} \; | grep "$HOST_ARCH.*$HOST_ARCH" | sort | uniq)
        -L$(find ${NDK_ROOT}/lib64/clang -maxdepth 1 -type d| sort -n | tail -1)/lib/linux/$(echo $HOST_ARCH|cut -d- -f1)
EOL`
        
        export LDFLAGS
        sed -i "s/android${OLD_VERSION}/android${ANDROID_API_VERSION}/g" $TARGET_FILES
    fi

}