{ config, pkgs, ... }:

{
  home.username = "jose";
  home.homeDirectory = "/home/jose";

  home.stateVersion = "25.05";

  programs.home-manager.enable = true;

  # ---------------------------------------------------------------------------
  # Packages — USER-level tools installed into your home profile via nix.
  # This same set follows you to any machine and straight onto NixOS later.
  #
  # Deliberately LEFT on pacman for now (see notes at the bottom of this file):
  #   * system-level  -> belongs in NixOS configuration.nix, not home-manager
  #   * compositor    -> hyprland/waybar/mako/wofi (+ walker/awww/elephant which
  #                      aren't in nixpkgs)
  #   * GUI apps      -> need GPU drivers not wired up on Arch (the nixGL problem)
  # ---------------------------------------------------------------------------
  home.packages = with pkgs; [
    # shell / CLI utilities
    bat
    btop
    fastfetch
    fzf
    tree
    tmux
    wget
    unzip
    ripgrep
    fd
    cowsay

    # editor (binary from nix; your config is the live-linked ./nvim below)
    neovim

    # dev / build toolchain
    cmake
    ninja
    ccache
    gdb
    strace
    gperf
    dfu-util          # flashing embedded targets
    expect
    rust-analyzer

    # wayland session helpers (invoked by your hypr keybinds / autostart)
    wl-clipboard      # wl-copy / wl-paste
    cliphist          # clipboard history store (feeds `walker -m clipboard`)
    grim              # screenshots
    slurp             # region select
    wtype             # synthetic typing

    # GPU-dependent — kept here for NixOS; needs nixGL to actually run on Arch
    moonlight-qt

    # fonts
    nerd-fonts.jetbrains-mono
    font-awesome
  ];

  fonts.fontconfig.enable = true;

  # ---------------------------------------------------------------------------
  # Programs — configured declaratively via home-manager modules
  # ---------------------------------------------------------------------------
  programs.git = {
    enable = true;
    settings.user.name = "Jose Velasco";
    settings.user.email = "josevelasco06@hotmail.com";
  };

  # ---------------------------------------------------------------------------
  # Dotfiles — live-editable, kept inside this repo, linked via out-of-store
  # symlinks. Edit them directly (no `home-manager switch` needed per edit).
  # ---------------------------------------------------------------------------
  home.file.".config/nvim".source =
    config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/.config/home-manager/nvim";

  home.file.".config/kitty".source =
    config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/.config/home-manager/kitty";

  home.file.".config/hypr".source =
    config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/.config/home-manager/hypr";

  home.file.".config/tmux".source =
    config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/.config/home-manager/tmux";
}
