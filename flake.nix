{
  description = "hyprnstack - N-Stack layout plugin for Hyprland";

  inputs = {
    hyprland.url = "github:hyprwm/Hyprland";
    nixpkgs.follows = "hyprland/nixpkgs";
  };

  outputs = {
    self,
    hyprland,
    nixpkgs,
    ...
  }: let
    forAllSystems = nixpkgs.lib.genAttrs (builtins.attrNames hyprland.packages);
  in {
    packages = forAllSystems (system: let
      pkgs = import nixpkgs {
        localSystem.system = system;
        overlays = [hyprland.overlays.hyprland-packages];
      };
    in {
      hyprnstack = pkgs.hyprlandPlugins.mkHyprlandPlugin pkgs.hyprland {
        pluginName = "hyprnstack";
        version = "0.1";
        src = self;

        installPhase = ''
          install -m755 -D nstackLayoutPlugin.so $out
        '';

        buildInputs = pkgs.hyprland.buildInputs;
        nativeBuildInputs = with pkgs; [gcc pkg-config];

        meta = with pkgs.lib; {
          description = "N-Stack layout for Hyprland";
          homepage = "https://github.com/zakk4223/hyprNStack";
          license = licenses.bsd3;
          platforms = platforms.linux;
        };
      };
      default = self.packages.${system}.hyprnstack;
    });

    devShells = forAllSystems (system: let
      pkgs = import nixpkgs {
        localSystem.system = system;
        overlays = [hyprland.overlays.hyprland-packages];
      };
    in {
      default = pkgs.mkShell {
        name = "hyprnstack-dev";
        inputsFrom = [self.packages.${system}.hyprnstack];
      };
    });
  };
}
