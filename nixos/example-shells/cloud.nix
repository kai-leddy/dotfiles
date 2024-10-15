{ pkgs ? import <nixpkgs> { }, unstable ? import <unstable> { } }:

let ctlptl = pkgs.callPackage /home/kai/dotfiles/nixos/pkgs/ctlptl.nix { };
in with pkgs;
mkShell {
  buildInputs = [
    ((terraform.withPlugins (plugins: [
      plugins.google
      plugins.helm
      plugins.kubernetes
    ])).overrideAttrs (_:
      let
        version = "0.12.28";
        sha256 = "05ymr6vc0sqh1sia0qawhz0mag8jdrq157mbj9bkdpsnlyv209p3";
      in {
        name = "terraform-${version}";
        src = fetchFromGitHub {
          owner = "hashicorp";
          repo = "terraform";
          rev = "v${version}";
          inherit sha256;
        };
      }))
    ctlptl
    tilt
    kind
    nodejs-14_x
    yarn
    kubernetes-helm
    kubectl
    google-cloud-sdk
  ];
}
