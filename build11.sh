#!/bin/bash

# define JDK and repo
JDKBASE=jdk11u-dev
DEBUG_LEVEL=release
#DEBUG_LEVEL=slowdebug
## release, fastdebug, slowdebug

# define build environment
BUILD_DIR=`pwd`
pushd `dirname $0`
PATCH_DIR=`pwd`
popd
JDK_DIR=$BUILD_DIR/$JDKBASE

downloadjdk11devsrc() {
	if ! test -d "$JDK_DIR" ; then
		hg clone http://hg.openjdk.java.net/jdk-updates/$JDKBASE "$JDK_DIR"
	else
		pushd "$JDK_DIR"
		hg pull -u
		popd
	fi
}

patchjdk() {
	if test -f "$PATCH_DIR/mac-jdk11u.patch" ; then
		pushd "$JDK_DIR"
		hg import --no-commit $PATCH_DIR/mac-jdk11u.patch
		popd
	fi
}

configurejdk() {
	pushd "$JDK_DIR"
	chmod 755 ./configure
	./configure --with-toolchain-type=clang \
            --includedir=$XCODE_DEVELOPER_PREFIX/Toolchains/XcodeDefault.xctoolchain/usr/include \
            --with-debug-level=$DEBUG_LEVEL \
            --with-boot-jdk=$JAVA_HOME 
	popd
}

buildjdk() {
	pushd "$JDK_DIR"
	make images CONF=macosx-x86_64-normal-server-$DEBUG_LEVEL
	popd
}

. $PATCH_DIR/tools.sh "$BUILD_DIR/tools" autoconf mercurial bootstrap_jdk11
downloadjdk11devsrc
patchjdk
configurejdk
buildjdk
