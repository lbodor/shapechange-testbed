/**
  Options
    - wine.enable
    - wine.env
    - wine.pkg

  Packages
    - wine-env
    - winecfg-set-dpi

  Legacy packages
    - writeWineApplication
*/
{ lib, flake-parts-lib, ... }:
let
  inherit (lib)
    concatStringsSep
    getExe
    mapAttrsToList
    mkIf
    mkOption
    optionalString
    optionals
    types
    ;
  inherit (flake-parts-lib) mkPerSystemOption;
in
{
  options = {
    perSystem = mkPerSystemOption (
      { config, pkgs, ... }:
      {
        options = {
          wine = mkOption {
            type = types.submodule {
              options = {
                enabled = mkOption {
                  type = types.bool;

                  description = ''
                    Provide wine if enabled; otherwise expect wine to be already in path.
                  '';

                  default = true;
                };

                pkg = mkOption {
                  type = types.package;

                  description = ''
                    Wine package to use
                  '';

                  default = pkgs.wineWowPackages.full;
                };

                env = mkOption {
                  type = types.attrsOf types.str;

                  description = ''
                    A set of environment variables to export before calling wine
                  '';

                  default = {
                    WINEPREFIX = "~/.wine-shapechange-testbed";

                    # Disable Wine debug output
                    WINEDEBUG = "-all";
                  };
                };
              };
            };

            default = {};
          };
        };

        config = {
          legacyPackages = {
            # Like writeShellApplication in nixpkgs, but for writing wine wrappers
            writeWineApplication =
              {
                name,
                text,
              }:
              pkgs.writeShellApplication {
                inherit name;

                runtimeInputs = optionals config.wine.enabled [
                  pkgs.wineWowPackages.full
                ];

                text = ''
                  ${optionalString config.wine.enabled ''
                    eval "$(${getExe config.packages.wine-env})"
                  ''}
                  ${text}
                '';
              };
          };

          packages = mkIf config.wine.enabled {
            # Execute `eval $(wine-env)` to export Wine environment variables
            wine-env = pkgs.writeShellApplication {
              name = "wine-env";
              text = ''
                cat <<EOF
                ${concatStringsSep "\n" (mapAttrsToList (n: v: "export ${n}=${v}") config.wine.env)}
                EOF
              '';
            };

            # Set DPI
            winecfg-set-dpi = config.legacyPackages.writeWineApplication {
              name = "winecfg-set-dpi";
              text = ''
                if [[ $# != 1 ]]; then
                  echo >&2 "Usage: winecfg-set-dpi <dpi>"
                  echo >&2 "E.g, Set DPI to 240 for resolution screens"
                  exit 1
                fi

                cmd=$(cat <<EOF
                wine reg ADD "HKLM\System\CurrentControlSet\Hardware Profiles\Current\Software\Fonts" \\
                  /v LogPixels \\
                  /t REG_DWORD \\
                  /d ''$1 \\
                  /f
                EOF
                )

                echo -e "$cmd\n"
                eval "$cmd"
              '';
            };
          };
        };
      }
    );
  };
}
