{
  description = "Jose's home-manager configuration";

  inputs = {
    # the package collection (unstable = newer packages)
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    # home-manager itself, pinned to follow the SAME nixpkgs as above
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { nixpkgs, home-manager, ... }:
    let
      system = "x86_64-linux";
      pkgs = nixpkgs.legacyPackages.${system};
    in {
      # "jose" is the name you switch to: home-manager switch
      homeConfigurations.jose = home-manager.lib.homeManagerConfiguration {
        inherit pkgs;
        modules = [ ./home.nix ];
      };
    };
}
