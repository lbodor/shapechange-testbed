/**
  Packages
    - ea-lite
*/
{
  perSystem =
    { config, pkgs, ... }:
    let
      # EA Lite distribution bundle
      installer = pkgs.fetchurl {
        name = "ealite_x64.msi";
        url = "https://sparxsystems.com/bin/ealite_x64.msi";
        hash = "sha256-Z3j5yTN5+68RcRuRkpdWsOItZfKNxbqOeBn5ImmWa+Q=";

        # These curl flags seem to be required to download the installer
        # otherwise, the download only works via a browser.
        curlOptsList = [
          "-H" "User-Agent: x"
          "-H" "Sec-Fetch-Site: x"
        ];
      };
        
      # EA Lite distribution uncompressed
      share = pkgs.runCommand "ea-lite" { buildInputs = [ pkgs.msitools ]; } ''
        msiextract -C "$out" ${installer} > /dev/null
      '';

      # Wrapper script to run EA Lite via Wine
      app = config.legacyPackages.writeWineApplication {
        name = "ea-lite";
        text = ''
          cmd=$(cat <<EOF
          wine '${share}/Sparx Systems/EA LITE/EA.exe' $@
          EOF
          )
          echo -e "$cmd\n"
          eval "$cmd"
        '';
      };
    in
    {
      packages = {
        # EA Lite distribution + wrapper script
        ea-lite = pkgs.linkFarm "ea-lite" [
          { name = "share"; path = "${share}"; }
          { name = "bin/ea-lite"; path = "${app}/bin/ea-lite"; }
        ];
      };
    };
}
