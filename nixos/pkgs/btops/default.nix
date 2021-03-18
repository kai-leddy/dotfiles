{ stdenv, fetchFromGitHub, buildGoPackage }:

buildGoPackage {
  pname = "btops";
  version = "1.0.0";
  goPackagePath = "github.com/cmschuetz/btops";

  src = fetchFromGitHub {
    owner = "cmschuetz";
    repo = "btops";
    rev = "b7f90a54af5cfc86460fc1acaa4b3fa156ad634f";
    sha256 = "1xzhbvc0lxdjh4bsc3g93fv68zbhn7rdn9m391p5fnxnxb3ikbgp";
  };

  goDeps = ./deps.nix;

  meta = with stdenv.lib; {
    description =
      "bspwm desktop management that supports dynamic appending, removing and renaming";
    homepage = "https://github.com/cmschuetz/btops";
    license = licenses.mit;
  };
}
