{ config, pkgs, ... }:

{
  home.username = "jose";
  home.homeDirectory = "/home/jose";

  home.stateVersion = "25.05";

  programs.home-manager.enable = true;

  home.packages = with pkgs; [
    cowsay
    ripgrep
    fd
    moonlight-qt
  ];
}
