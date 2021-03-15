FROM arm64v8/python:3.8-slim

ENV ANDROID_NDK_VERSION=r22
ENV ANDROIDZIPFILE=android-ndk-${ANDROID_NDK_VERSION}-linux-x86_64.zip
ENV ANDROID_API_VERSION=24

RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        curl \
        mlocate vim \
        unzip \
        xz-utils \
        git-core \
        libpython2.7-stdlib \
        libc6-dev-arm64-cross \
        #libc6-dev

WORKDIR /root
COPY startup.sh ~/.bash_profile

RUN . ~/.bash_profile \
    && curl -O https://dl.google.com/android/repository/${ANDROIDZIPFILE} \
    && unzip ${ANDROIDZIPFILE} \
    && android-ndk-${ANDROID_NDK_VERSION}/prebuilt/linux-x86_64/bin/python \
          ./android-ndk-${ANDROID_NDK_VERSION}/build/tools/make_standalone_toolchain.py \
            --arch arm64 \
            --api ${ANDROID_API_VERSION} \
            --stl=libc++ \
            --install-dir=${NDK_ROOT}  \
    && rm -rf ${ANDROIDZIPFILE} android-ndk-${ANDROID_NDK_VERSION} \

    && for x in $TOOL_PREFIX-*; do ln -sf $x $PREFIX/bin/`basename $x | sed "s:${HOST_ARCH}-::g"`; done \
    && for x in ${NDK_ROOT}/bin/clang*; do ln -sf $x $PREFIX/bin/`basename $x`; done

    && chapi $ANDROID_API_VERSION

VOLUME /root
ENTRYPOINT ["/bin/bash -l"]
