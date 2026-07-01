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
    socat             # used by monitor-hotplug.sh to read Hyprland's event socket

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

  # bash — ported from your old ~/.bashrc.
  # NOTE: this generates ~/.bashrc, so it's now managed (edit here + switch),
  # unlike the live-editable dotfiles below.
  programs.bash = {
    enable = true;

    shellAliases = {
      ls = "ls --color=auto";
      grep = "grep --color=auto";
      get_idf = ". $HOME/esp/esp-idf/export.sh";
      tls = "~/scripts/tmux/tmux-ls.sh";
      orca-slicer = "flatpak run com.softfever3d.orca-slicer";
      bambu-studio = "flatpak run com.bambulab.BambuStudio";
    };

    sessionVariables = {
      PAGER = "less -R";
    };

    initExtra = ''
      # --- prompt: working dir + current git branch ---
      git_branch() {
        git branch 2>/dev/null | grep '^\*' | sed 's/\* //'
      }
      PS1='\W$(git_branch 2>/dev/null | sed "s/.*/ (&)/") > '

      # --- centered, narrower man pages ---
      man() {
        local term_width; term_width=$(tput cols)
        local width=$(( term_width * 6 / 10 ))
        local pad=$(( (term_width - width) / 2 ))
        local PAD; PAD=$(printf '%*s' "$pad" "")
        MANWIDTH=$width GROFF_NO_SGR= command man "$@" | sed "s/^/$PAD/" | less -R
      }
    '';

    # ~/.profile (sourced at login) — auto-start Hyprland on TTY1 (from old .bash_profile)
    profileExtra = ''
      if [ -z "$DISPLAY" ] && [ "$XDG_VTNR" -eq 1 ]; then
        start-hyprland
      fi
    '';
  };

  # PATH additions (were exported in your old ~/.bashrc)
  home.sessionPath = [
    "$HOME/.local/bin"
    "$HOME/.opencode/bin"
    "$HOME/bin"
  ];

  # Firefox — the browser binary from nix, with extensions installed & pinned
  # declaratively via enterprise policy (reproducible, carries to NixOS).
  programs.firefox = {
    enable = true;
    configPath = ".mozilla/firefox";   # pin legacy path (silences the 26.05 XDG-migration warning)

    profiles.jose = {
      isDefault = true;
      settings = {
        "browser.aboutConfig.showWarning" = false;
        "browser.startup.page" = 3;                                    # restore previous session
        "browser.newtabpage.activity-stream.showSponsored" = false;    # no sponsored tiles
        "browser.newtabpage.activity-stream.showSponsoredTopSites" = false;
      };
    };

    policies.ExtensionSettings = {
      # uBlock Origin — adblocker (requested)
      "uBlock0@raymondhill.net" = {
        install_url = "https://addons.mozilla.org/firefox/downloads/latest/ublock-origin/latest.xpi";
        installation_mode = "force_installed";
      };
      # Bitwarden — password manager (requested)
      "{446900e4-71c2-419f-a6a7-df9c091e268b}" = {
        install_url = "https://addons.mozilla.org/firefox/downloads/latest/bitwarden-password-manager/latest.xpi";
        installation_mode = "force_installed";
      };
      # Vimium — vim-style keyboard nav (fits your hjkl workflow)
      "{d7742d87-e61d-4b78-b8a1-b469842139fa}" = {
        install_url = "https://addons.mozilla.org/firefox/downloads/latest/vimium-ff/latest.xpi";
        installation_mode = "force_installed";
      };
      # Dark Reader — dark mode on every site
      "addon@darkreader.org" = {
        install_url = "https://addons.mozilla.org/firefox/downloads/latest/darkreader/latest.xpi";
        installation_mode = "force_installed";
      };
    };
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
