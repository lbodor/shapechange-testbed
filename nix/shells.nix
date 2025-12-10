/**
  Dev shells
    - default
*/
{ inputs, lib, ... }:
let
  inherit (lib)
    getExe
    mkIf
    optionals
    ;
in
{
  imports = [
    inputs.make-shell.flakeModules.default
  ];

  perSystem =
    { config, ... }:
    {
      make-shells.default = {
        packages = [
          config.packages.shapechange
          config.packages.shapechange-ea
          config.packages.ea-lite
        ]
        ++ optionals config.wine.enabled [
          config.wine.pkg
          config.packages.wine-env
          config.packages.winecfg-set-dpi
        ];

        shellHook = mkIf config.wine.enabled ''
          eval "$(${getExe config.packages.wine-env})"
        '';
      };
    };
}
