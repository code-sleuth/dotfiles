{
  description = "My Darwin system flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.11";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";
    nixpkgs-darwin.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    # Bleeding-edge master for packages whose fixes haven't reached a channel
    # yet (currently: herdr's darwin build fix).
    nixpkgs-master.url = "github:NixOS/nixpkgs";

    nix-darwin.url = "github:LnL7/nix-darwin";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs-darwin";

    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs-darwin";
  };

  outputs = { ... }@inputs:
    with inputs;
    let
      inherit (self) outputs;
      system = "aarch64-darwin";
      stateVersion = "24.05";
      libx = import ./lib { inherit inputs outputs stateVersion; };


    in
    {
      darwinConfigurations = {
        Ibrahims-Thanos = libx.mkDarwin { hostname = "Ibrahims-Thanos"; };
      };

      # Expose the package set, including overlays, for convenience.
      darwinPackages = self.darwinConfigurations.Ibrahims-Thanos.pkgs;
    };
}
