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

  # --- Dotfiles: all live-editable, files kept inside this repo and linked via
  # out-of-store symlinks. Edit them directly (no `home-manager switch` needed);
  # home-manager just declares the links so they're reproducible on any machine. ---

  # nvim is its own git repo, pulled in as a SUBMODULE at ./nvim
  home.file.".config/nvim".source =
    config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/.config/home-manager/nvim";

  # kitty: plain config file kept in this repo at ./kitty
  home.file.".config/kitty".source =
    config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/.config/home-manager/kitty";

  # hyprland: config + scripts kept in this repo at ./hypr
  home.file.".config/hypr".source =
    config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/.config/home-manager/hypr";
}
