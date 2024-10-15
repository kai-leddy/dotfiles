{ pkgs ? import <nixpkgs> { config.android_sdk.accept_license = true; }
, unstable ? import <unstable> { config.android_sdk.accept_license = true; } }:

let
  BUILD_TOOLS = "29.0.3";
  AAPT_BUILD_TOOLS = "30.0.3";
  COMPILE_SDK = "30";
  NDK_VERSION = "20.1.5948944";
  androidComposition = pkgs.androidenv.composeAndroidPackages {
    buildToolsVersions = [ BUILD_TOOLS AAPT_BUILD_TOOLS ];
    includeEmulator = true;
    platformVersions = [ COMPILE_SDK ];
    includeSources = false;
    includeSystemImages = true;
    systemImageTypes = [ "google_apis_default" ];
    abiVersions = [ "x86_64" ];
    includeNDK = true;
    ndkVersions = [ NDK_VERSION ];
    useGoogleAPIs = false;
  };
in with pkgs;
mkShell rec {
  buildInputs = with unstable.nodePackages; [
    androidComposition.androidsdk
    nodejs-14_x
    yarn
    node-gyp
    python2
    gnumake
    glibc
    gcc
    openjdk8
    scrcpy
  ];
  # standard Java stuff
  ANDROID_SDK_ROOT = "${androidComposition.androidsdk}/libexec/android-sdk";
  ANDROID_NDK_ROOT = "${ANDROID_SDK_ROOT}/ndk-bundle";
  # override the aapt2 that gradle uses with the nix-shipped version
  GRADLE_OPTS =
    "-Dorg.gradle.project.android.aapt2FromMavenOverride=${ANDROID_SDK_ROOT}/build-tools/${AAPT_BUILD_TOOLS}/aapt2";
  # other optimizations
  USE_CCACHE = 1;
}
