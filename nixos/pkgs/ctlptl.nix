{ stdenv, lib, pkgs, fetchzip, glib, glibc, autoPatchelfHook, ... }:

with lib;
let libPath = lib.makeLibraryPath [ glib glibc ];
in stdenv.mkDerivation rec {
  version = "0.5.5";
  pname = "ctlptl";

  src = fetchzip {
    url =
      "https://github.com/tilt-dev/ctlptl/releases/download/v${version}/ctlptl.${version}.linux.x86_64.tar.gz";
    sha256 = "0hxk8hacn9qf2v4q40axvyx2fmkss5l4ixrzjc5gqq5qc29qfryp";
    # stripRoot = false;
  };

  nativeBuildInputs = [ autoPatchelfHook ];

  # dontConfigure = true;
  # dontBuild = true;
  # dontPatchELF = true;

  installPhase = ''
    install -m755 -D ctlptl $out/bin/${pname}
  '';

  meta = {
    description = "CLI for declaratively setting up local Kubernetes clusters";
    homepage = "https://github.com/tilt-dev/ctlptl";
    license = licenses.asl20;
    platforms = [ "x86_64-linux" ];
  };
}
