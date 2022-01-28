{ stdenv, fetchurl, lib, autoPatchelfHook, wrapGAppsHook, dpkg, nodePackages
, atomEnv, cups }:

let
  oldPackages = import (fetchTarball
    "https://github.com/NixOS/nixpkgs/archive/82cdbb516a92335ea88de35f7ecc86285a49b135.tar.gz")
    { };

in stdenv.mkDerivation rec {
  pname = "myki";
  name = "myki-latest-deb";

  src = fetchurl {
    url = "https://static.myki.com/releases/da/MYKI-latest-amd64.deb";
    sha256 = "1919lznzwh6vx4yziphckx59q7whxfqh255s716kfx2s1ck2ggnk";
  };

  nativeBuildInputs = [ autoPatchelfHook wrapGAppsHook dpkg nodePackages.asar ];

  buildInputs = [ atomEnv.packages cups ];

  dontBuild = true;
  dontConfigure = true;

  unpackPhase = ''
    dpkg-deb -x $src .
  '';

  patchPhase = ''
    # autopatchelf the app asar bundle
    asar extract opt/MYKI/resources/app.asar tmp
    autoPatchelf tmp
    asar pack tmp opt/MYKI/resources/app.asar
    rm -rf tmp

    # autopatchelf the electron asar bundle
    asar extract opt/MYKI/resources/electron.asar tmp
    autoPatchelf tmp
    asar pack tmp opt/MYKI/resources/electron.asar
    rm -rf tmp
  '';

  installPhase = ''
    mkdir -p $out/bin
    cp -r opt $out/
    cp -r usr/share $out/

    # use nixpkgs electron wrapper entrypoint
    rm opt/MYKI/myki
    makeWrapper ${oldPackages.electron}/bin/electron $out/opt/MYKI/${pname} --add-flags $out/opt/MYKI/resources/app.asar
    ln -s $out/opt/MYKI/${pname} $out/bin/${pname}
  '';

  meta = with lib; {
    homepage = "https://myki.com/";
    description = "MyKi password manager";
    platforms = platforms.linux;
  };
}
