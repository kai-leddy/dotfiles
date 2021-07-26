{ fetchurl, appimageTools, lib }:

appimageTools.wrapType2 {
  name = "myki";

  src = fetchurl {
    url = "https://static.myki.com/releases/da/MYKI-latest.AppImage";
    sha256 = "0l9gxpqgrfzbpmhfka8mks5fg840hz47b9vashii97qqgx8japwz";
  };

  extraPkgs = pkgs:
    with pkgs; [
      gnome3.libsecret
      stdenv.cc.cc
      stdenv.cc.cc.lib
      libsecret
      glib
      glibc
    ];
}
