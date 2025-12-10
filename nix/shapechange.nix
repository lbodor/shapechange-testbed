/**
  Packages
    - shapechange
    - shapechange-ea
*/
{
  perSystem =
    { config, pkgs, ... }:
    let
      version = "4.0.0";

      # ShapeChange distribution
      shapechangeDistro = pkgs.fetchzip {
        url =
          "https://github.com/ShapeChange/ShapeChange/releases/download/${version}/"
          + "ShapeChange-${version}.zip";

        sha256 = "sha256-6u4S0R+K56fRBPr55wu9bUtP8uNyPx5MKvLAmtHfemU=";
        stripRoot = false;
      };

      # OpenJDK distribution for Windows
      jdkWin = pkgs.fetchzip {
        url =
          "https://download.java.net/java/GA/jdk21.0.2/f2283984656d49d69e91c558476027ac/13/GPL/"
          + "openjdk-21.0.2_windows-x64_bin.zip";

        sha256 = "sha256-cWrqL5kFnQmtbSfwgcK2PCesC9vzsJdymjinrwcedvI=";
      };

    in
    {
      packages = {
        # Wrapper script for running ShapeChange
        shapechange = pkgs.writeShellApplication {
          name = "shapechange";
          text = ''
            cmd=$(cat <<EOF
            ${pkgs.jdk21}/bin/java -jar ${shapechangeDistro}/ShapeChange-${version}.jar $@
            EOF
            )
            echo -e "$cmd\n"
            eval "$cmd"
          '';
        };

        # Wrapper script for running ShapeChange via Wine with support
        # for reading EA project files
        shapechange-ea = config.legacyPackages.writeWineApplication {
          name = "shapechange-ea";
          text = ''
            cmd=$(cat <<EOF
            wine ${jdkWin}/bin/java.exe \\
              -Dline.separator=\$'\n' \\
              -Djava.library.path="\$(winepath --windows '${config.packages.ea-lite}/share/Sparx Systems/EA LITE/Java API')" \\
              -jar "\$(winepath --windows ${shapechangeDistro}/ShapeChange-${version}.jar)" \\
              $@
            EOF
            )
            echo -e "''${cmd//\$\'\\n\'/\$\'\\\\n\'}\n"
            eval "$cmd"
          '';
        };

      };
    };
}
