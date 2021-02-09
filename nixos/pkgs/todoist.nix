{ fetchurl, appimageTools }:

appimageTools.wrapType2 {
  name = "todoist";

  src = fetchurl {
    url = "https://electron-dl.todoist.com/linux/Todoist-0.2.3.AppImage";
    sha256 = "11rhsg50czvpzz5y84nvbgwpwph460rc80kn66y04y82d9scl91r";
  };

  extraPkgs = pkgs: with pkgs; [ gnome3.libsecret ];
}
