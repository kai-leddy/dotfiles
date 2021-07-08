# { stdenv, lib, fetchzip, dpkg, atk, glib, pango, gdk-pixbuf, gnome2, gtk3, cairo
# , freetype, fontconfig, dbus, libXi, libXcursor, libXdamage, libXrandr
# , libXcomposite, libXext, libXfixes, libXrender, libX11, libXtst, libXScrnSaver
# , libxcb, nss, nspr, alsaLib, cups, expat, udev, libpulseaudio, at-spi2-atk }:
#
{ stdenv, lib, fetchzip, atk, glib, pango, gdk-pixbuf, gtk3, cairo, dbus, libdrm
, libXdamage, libXrandr, libXcomposite, libXext, libXfixes, libX11, libxcb
, libxshmfence, libxkbcommon, mesa, nss, nspr, alsaLib, cups, expat, udev
, libpulseaudio, at-spi2-atk, at-spi2-core }:

let
  libPath = lib.makeLibraryPath [
    stdenv.cc.cc
    atk
    glib
    pango
    gdk-pixbuf
    gtk3
    cairo
    dbus
    libdrm
    libXdamage
    libXrandr
    libXcomposite
    libXext
    libXfixes
    libX11
    libxcb
    libxshmfence
    libxkbcommon
    mesa
    nss
    nspr
    alsaLib
    cups
    expat
    udev
    libpulseaudio
    at-spi2-atk
    at-spi2-core
  ];
in with lib;
stdenv.mkDerivation rec {
  version = "0.94.1";
  pname = "flipper";

  src = fetchzip {
    url =
      "https://github.com/facebook/flipper/releases/download/v${version}/Flipper-linux.zip";
    sha256 = "01y00imsh50jc99cifvx8nc0hdfgz7lzav83cp160gzmq7zjqp1c";
    stripRoot = false;
  };

  dontConfigure = true;
  dontBuild = true;
  dontPatchELF = true;

  installPhase = ''
    mkdir -p $out/bin $out/opt/Flipper
    mv * $out/opt/Flipper/
    ln -s $out/opt/Flipper/${pname} $out/bin/${pname}
    patchelf --set-interpreter "$(cat $NIX_CC/nix-support/dynamic-linker)" --set-rpath "${libPath}:$out/opt/Flipper:\$ORIGIN" "$out/opt/Flipper/${pname}"
  '';

  meta = {
    description = "Native Debugging tool for mobile apps";
    homepage = "https://fbflipper.com/";
    license = licenses.mit;
    platforms = [ "x86_64-linux" ];
  };
}
