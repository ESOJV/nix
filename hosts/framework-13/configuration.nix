{ config, pkgs, ... }:

# Framework 13 (Intel) — system configuration.
# Adapted from the VM practice config for the real machine. This is a SCAFFOLD:
# finish the TODOs during the actual install. User-level packages, dotfiles, git,
# firefox, fonts, etc. all come from home.nix (imported via the flake), so keep
# this file to SYSTEM-level concerns (boot, drivers, services, desktop session).

{
  imports = [ ./hardware-configuration.nix ];

  # --- Boot (Framework is UEFI) ---
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # --- Host / network ---
  networking.hostName = "framework-13";
  networking.networkmanager.enable = true;

  time.timeZone = "America/Chicago";
  i18n.defaultLocale = "en_US.UTF-8";

  # --- Intel graphics / CPU (single iGPU now; the AMD eGPU is gone) ---
  hardware.graphics = {
    enable = true;
    extraPackages = with pkgs; [ intel-media-driver ];   # VAAPI hw video decode
  };
  hardware.cpu.intel.updateMicrocode = true;
  services.thermald.enable = true;                        # Intel thermal mgmt
  services.fwupd.enable = true;                           # firmware updates

  # --- Power (pick ONE; do NOT also enable power-profiles-daemon) ---
  services.tlp.enable = true;
  services.power-profiles-daemon.enable = false;
  # TODO(sleep): for working hibernate, size swap >= RAM (32 GB) in
  # hardware-configuration.nix / disko, then consider:
  #   systemd.sleep.extraConfig = "HibernateDelaySec=45min";
  #   (and use suspend-then-hibernate) so an idle laptop stops draining.

  users.users.jose = {
    isNormalUser = true;
    description = "Jose";
    extraGroups = [ "wheel" "networkmanager" "video" "input" ];
  };

  nixpkgs.config.allowUnfree = true;   # google-chrome, spotify, obsidian, steam, …

  # --- Desktop: Hyprland + login manager ---
  programs.hyprland.enable = true;
  services.displayManager.ly.enable = true;   # TODO: confirm ly vs sddm (Arch used sddm)

  # --- Audio ---
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    pulse.enable = true;
    jack.enable = true;
  };

  # --- File manager ---
  programs.thunar = {
    enable = true;
    plugins = with pkgs.xfce; [ thunar-archive-plugin thunar-volman ];
  };
  services.gvfs.enable = true;
  services.tumbler.enable = true;

  services.openssh.enable = true;

  fonts.packages = with pkgs; [ nerd-fonts.jetbrains-mono font-awesome ];

  # --- System / desktop-session packages ---
  # User CLI tools & apps live in home.nix. Keep only compositor-session pieces
  # and things that must be system-level here.
  environment.systemPackages = with pkgs; [
    waybar wofi mako brightnessctl hyprpolkitagent
    pavucontrol easyeffects
    # TODO(migration): walker, awww, elephant are NOT in nixpkgs. Either add them
    # as flake inputs, or swap for in-repo equivalents (wofi/rofi launcher, swww
    # wallpaper daemon). Your hypr config references walker/awww today.
  ];

  system.stateVersion = "26.05";
}
