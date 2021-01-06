#!/bin/bash
#
# Created by Zhenyong Chen, 2018/01/04, Thu
#

# This script build ios/mac/android app, given sdk binaries
# Where to download sdk binaries?
# E.g. 192.168.99.149:8086/v2.1.0/AgoraSDK/
#                      Android/testing/Agora_Native_SDK_for_Android_v2_1_0_FULL_20180104_238.zip
#                      Mac/
#                      iOS/testing/Agora_Native_SDK_for_iOS_v2_1_0_FULL_20180104_257.zip
#                      Windows/
#

#

TOPDIR=`pwd`
WORKDIR=$TOPDIR/..
SDKVER=3.0.0
if [ "$BUILD_WINDOWS" != "y" ]; then
    BUILD_IOS=y
    BUILD_MAC=y
    BUILD_ANDROID=y
fi
if [ $# == 3 ]; then
    BUILD_IOS=$1
    BUILD_MAC=$2
    BUILD_ANDROID=$3
elif [ $# == 4 ]; then
    BUILD_IOS=$1
    BUILD_MAC=$2
    BUILD_ANDROID=$3
    BUILD_WIN=$4
elif [ $# == 5 ]; then
    BUILD_IOS=$1
    BUILD_MAC=$2
    BUILD_ANDROID=$3
    BUILD_WIN=$4
    SDKVER=$5
fi
# for windows build, use export BUILD_WINDOWS=y
#BUILD_WINDOWS=n

# TODO: check sdk binaries

#######################
# build ios
#######################

if [ "$BUILD_IOS" == "y" ]; then
    FRAMEWORK=AgoraRtcKit
    INSTALLPATH=${WORKDIR}/AutoBuild/sdks_path_Ios/Agora_Native_SDK_for_iOS_FULL/libs

    # TODO: cp media_sdk3/interface/objc/

    # copy framework
#    if [ cp -r ${INSTALLPATH}/${FRAMEWORK}.framework $WORKDIR/RobotX-Apple/RobotX-iOS = "1" ]; then
#        INSTALLPATH2=${WORKDIR}/AutoBuild/sdks/Agora_Native_SDK_for_iOS_FULL_Dynamic/libs
#        cp -r ${INSTALLPATH2}/${FRAMEWORK}.framework $WORKDIR/RobotX-Apple/RobotX-iOS
#    fi
    cp -a ${INSTALLPATH}/Agorafdkaac.framework $WORKDIR/RobotX-Apple/RobotX-iOS  || exit 1
    cp -a ${INSTALLPATH}/Agoraffmpeg.framework $WORKDIR/RobotX-Apple/RobotX-iOS  || exit 1
    cp -a ${INSTALLPATH}/AgoraSoundTouch.framework $WORKDIR/RobotX-Apple/RobotX-iOS  || exit 1
    cp -a ${INSTALLPATH}/AgoraAIDenoise.framework $WORKDIR/RobotX-Apple/RobotX-iOS  || exit 1
    cp -a ${INSTALLPATH}/AgoraSuperResolution.framework $WORKDIR/RobotX-Apple/RobotX-iOS  || exit 1
    cp -a ${INSTALLPATH}/${FRAMEWORK}.framework $WORKDIR/RobotX-Apple/RobotX-iOS  || exit 1
    cp -a ${INSTALLPATH}/AgoraCore.framework $WORKDIR/RobotX-Apple/RobotX-iOS  || exit 1

    # build
    cd $TOPDIR && ./build_ipa.sh $WORKDIR/RobotX-Apple RobotX-iOS com.medialab.RobotX || exit 1
    cp -rf $TOPDIR/../AutoBuild/__archive__/release/RobotX-iOS.ipa  $TOPDIR/../AutoBuild/Results/$VERTIME/
fi

#######################
# build mac
#######################

if [ "$BUILD_MAC" == "y" ]; then
    FRAMEWORK=AgoraRtcKit
    INSTALLPATH=${WORKDIR}/AutoBuild/sdks_path_Mac/Agora_Native_SDK_for_Mac_FULL/libs

    # copy framework
    cp -a ${INSTALLPATH}/Agorafdkaac.framework $WORKDIR/RobotX-Apple/RobotX
    cp -a ${INSTALLPATH}/Agoraffmpeg.framework $WORKDIR/RobotX-Apple/RobotX
    cp -a ${INSTALLPATH}/AgoraSoundTouch.framework $WORKDIR/RobotX-Apple/RobotX
    cp -a ${INSTALLPATH}/AgoraAIDenoise.framework $WORKDIR/RobotX-Apple/RobotX
    cp -a ${INSTALLPATH}/AgoraCore.framework $WORKDIR/RobotX-Apple/RobotX
    cp -a ${INSTALLPATH}/av1.framework $WORKDIR/RobotX-Apple/RobotX
    cp -a ${INSTALLPATH}/${FRAMEWORK}.framework $WORKDIR/RobotX-Apple/RobotX
    # build
    cd $TOPDIR && ./build_dmg.sh $WORKDIR/RobotX-Apple RobotX.xcodeproj RobotX || exit 1
    cp -rf $TOPDIR/../AutoBuild/__archive__/release/RobotX/Sym/Debug/RobotX.app  $TOPDIR/../AutoBuild/Results/$VERTIME/
fi
if [ "$BUILD_WIN" == "y" ]; then
  SIGFILE=.__build__windows__
  touch $TOPDIR/$SIGFILE

fi
#######################
# build android
#######################

if [ "$BUILD_ANDROID" == "y" ]; then
    export ANDROID_NDK_ROOT=$NDK_HOME
    INSTALLPATH=${WORKDIR}/AutoBuild/sdks_path_Android/Agora_Native_SDK_for_Android_FULL/libs

    # copy .jar and .so
    cp -r ${INSTALLPATH}/ $WORKDIR/RobotX-Android/app/src/main/prebuilt/ || exit 1
#    cp ${WORKDIR}/meiyan/VideoPreProcess/bin/android/videoprp.aar $WORKDIR/AgoraRTCEngine-test/RobotX-Android/app/src/main/prebuilt/ || exit 1
    # build
    cd $WORKDIR/RobotX-Android && ./build.sh || exit 1
    cp -rf $TOPDIR/../RobotX-Android/app/build/outputs/apk/robotx.apk  $TOPDIR/../AutoBuild/Results/$VERTIME/
fi

#######################
# build windows
#######################

if [ "$BUILD_WINDOWS" == "y" ]; then
    SIGFILE=.__build__windows__
    touch $TOPDIR/$SIGFILE
    INSTALLPATH=${WORKDIR}/AutoBuild/sdks_path_Windows/Agora_Native_SDK_for_Windows_FULL
    APP_DIR=$WORKDIR/RobotX-Windows/RobotX
    ARCH=win32
    APPCONFIG=Release
    BUILDER="C:/Program Files (x86)/Microsoft Visual Studio/2019/Community/MSBuild/Current/Bin/msbuild.exe"

    # copy files
    mkdir -p $APP_DIR/PreBuilt/lib/
    mkdir -p $APP_DIR/PreBuilt/include/rtc
    mkdir -p $APP_DIR/PreBuilt/include/internal

    # binaries
    #cp ${INSTALLPATH}/dll/agora_rtc_sdk.dll        $APP_DIR/PreBuilt/lib/ || exit 1
    #cp ${INSTALLPATH}/lib/agora_rtc_sdk.lib        $APP_DIR/PreBuilt/lib/ || exit 1
    #cp ${INSTALLPATH}/libs/x86/agora_rtc_sdk.dll        $APP_DIR/PreBuilt/lib/ || exit 1
    cp ${INSTALLPATH}/libs/x86/agora_rtc_sdk.lib        $APP_DIR/PreBuilt/lib/ || exit 1

    # headers
#    cp ${INSTALLPATH}/include/IAgoraRtcEngine.h                         $APP_DIR/PreBuilt/include/rtc/ || exit 1
#    cp ${INSTALLPATH}/include/IAgoraMediaEngine.h                       $APP_DIR/PreBuilt/include/rtc/ || exit 1
#    cp ${WORKDIR}/media_sdk3/interface/cpp/internal/rtc_engine_i.h      $APP_DIR/PreBuilt/include/rtc/ || exit 1
#    cp ${WORKDIR}/media_sdk3/interface/cpp/internal/IAgoraRtcEngine2.h  $APP_DIR/PreBuilt/include/internal/ || exit 1
#    cp -r ${WORKDIR}/media_sdk3/interface/cpp/* $APP_DIR/PreBuilt/include/ || exit 1
    #cp ${INSTALLPATH}/include/*                         $APP_DIR/PreBuilt/include/ || exit 1
    cp ${INSTALLPATH}/libs/include/*                         $APP_DIR/PreBuilt/include/ || exit 1

    cd $APP_DIR || exit 1
    rm -r $APPCONFIG/
    "$BUILDER" RobotX.sln /maxcpucount:4 /target:Rebuild /property:Configuration=$APPCONFIG /property:platform=$ARCH || exit 1

    # in order to run
    #cp ${INSTALLPATH}/dll/*        $APP_DIR/$APPCONFIG/ || exit 1
    cp ${INSTALLPATH}/libs/x86/*.dll        $APP_DIR/$APPCONFIG/ || exit 1
    #cp ${INSTALLPATH}/dll/agorasdk.dll             $APP_DIR/$APPCONFIG/ || exit 1
fi

exit 0

