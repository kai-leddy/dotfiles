# NOTE: this is a custom derivation for the FantasqueSansMono Nerd Font
# I did this because `unstable.nerdfonts` refers to v2.1.0 which
# has outstanding issues with the font-width of various glyphs.
# https://github.com/ryanoasis/nerd-fonts/issues/442

{ stdenv, lib, fetchzip }:

let
  repo = "https://github.com/ryanoasis/nerd-fonts";
  version = "2.0.0";
in stdenv.mkDerivation {
  name = "fantasque-nerdfont";
  version = version;

  src = fetchzip {
    url = "${repo}/releases/download/v${version}/FantasqueSansMono.zip";
    sha256 = "0z54ib9s9sj0l85gc53nbcrcjncxhj14jssmryzq6bc79pyd5nkr";
    stripRoot = false;
  };

  buildCommand = ''
    install --target $out/share/fonts/truetype -D $src/*.ttf
  '';

  meta = with lib; {
    description = "Nerdfont version of Fantasque Sans Mono";
    homepage = repo;
    license = licenses.mit;
  };
}
