{
  description = "Jose's NixOS + home-manager configuration (monorepo, multi-host)";

  inputs = {
    # the package collection (unstable = newer packages)
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    # home-manager itself, pinned to follow the SAME nixpkgs as above
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Hyprland pinned to the last hyprlang release (0.55+ switched to Lua config
    # and won't load dotfiles/hypr/hyprland.conf). Deliberately NOT following our
    # nixpkgs — Hyprland ships prebuilt binaries via its own cachix, and forcing
    # `inputs.nixpkgs.follows` would break that cache and rebuild from source.
    hyprland.url = "github:hyprwm/Hyprland?ref=v0.54.3";
  };

  outputs = { nixpkgs, home-manager, hyprland, ... }:
    let
      system = "x86_64-linux";
      pkgs = nixpkgs.legacyPackages.${system};
    in {
      # ---------------------------------------------------------------------
      # Standalone home-manager — used NOW on Arch (the transition period).
      #   home-manager switch --flake ~/nix#jose
      # ---------------------------------------------------------------------
      homeConfigurations.jose = home-manager.lib.homeManagerConfiguration {
        inherit pkgs;
        modules = [ ./home/home.nix ];
      };

      # ---------------------------------------------------------------------
      # NixOS systems — one output per machine, keyed by hostname.
      # Add more machines here later (e.g. nixosConfigurations.gaming-pc).
      #   sudo nixos-rebuild switch --flake ~/nix#framework-13
      #
      # NOTE: framework-13 will NOT build until you run `nixos-generate-config`
      # on the real machine to create hosts/framework-13/hardware-configuration.nix
      # (the placeholder there is a stub). Until then, only the #jose output above
      # is meant to be used.
      # ---------------------------------------------------------------------
      nixosConfigurations.framework-13 = nixpkgs.lib.nixosSystem {
        inherit system;
        modules = [
          ./hosts/framework-13/configuration.nix

          # Override the Hyprland package + portal with the pinned 0.54.3 flake so
          # the old hyprland.conf keeps working (configuration.nix still does the
          # `programs.hyprland.enable = true`).
          {
            programs.hyprland.package = hyprland.packages.${system}.hyprland;
            programs.hyprland.portalPackage =
              hyprland.packages.${system}.xdg-desktop-portal-hyprland;
          }

          # Pull home-manager into the system build so one `nixos-rebuild switch`
          # configures the system AND jose's home together.
          home-manager.nixosModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            # If a config file already exists where home-manager wants to write
            # one, rename the old one to <name>.backup instead of aborting.
            home-manager.backupFileExtension = "backup";
            home-manager.users.jose = import ./home/home.nix;
          }
        ];
      };
    };
}
