{ inputs
, outputs
, stateVersion
, ...
}:
{
  mkDarwin =
    { hostname
    , username ? "code"
    , system ? "aarch64-darwin"
    ,
    }:
    let
      inherit (inputs.nixpkgs) lib;
      unstablePkgs = inputs.nixpkgs-unstable.legacyPackages.${system};
      customConfPath = ./../hosts/darwin/${hostname};
      customConf = if builtins.pathExists customConfPath then (customConfPath + "/default.nix") else null;
    in
    inputs.nix-darwin.lib.darwinSystem {
      specialArgs = {
        inherit
          system
          inputs
          username
          unstablePkgs
          ;
      };
      modules = [
        ./../hosts/common/common-packages.nix
        ./../hosts/common/darwin-common.nix
        inputs.home-manager.darwinModules.home-manager
        {
          networking.hostName = hostname;
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;
          home-manager.backupFileExtension = "backup";
          home-manager.extraSpecialArgs = { inherit inputs; };
          home-manager.users.${username} = {
            imports = [ ./../home/${username}.nix ];
          };
        }
      ]
      ++ lib.optionals (customConf != null) [ customConf ];
    };
}
