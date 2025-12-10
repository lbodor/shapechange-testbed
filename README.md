## ShapeChange Testbed

[ShapeChange](https://github.com/ShapeChange) is a transformation tool that processes 
UML application schemas constructed according to [ISO 19109](https://www.iso.org/standard/84700.html) and converts them
into various target formats, like XML schema, JSON schema, SQL DDL, Open API
definition, etc.

See ShapeChange [technical documentation](https://shapechange.github.io/ShapeChange) for information
about the supported
[input](https://shapechange.github.io/ShapeChange/4.0.0/application%20schemas/Application_schemas.html)
and
[outputs](https://shapechange.github.io/ShapeChange/4.0.0/targets/Output_Targets.html) formats.

The purpose of this repository is to provide installation scripts for ShapeChange and related tooling
in support of conceptual and physical modelling of application schemas.

ShapeChange is a Java application and will run natively on all platforms. However, [Enterprise Architect](https://sparxsystems.com),
the de facto standard for UML modelling in the OGC community, is a Windows application, which can run on Linux and MacOS only
with the support of [Wine](https://www.winehq.org) (Windows software compatibility layer for Unix) and/or VM hardware emulators like
[QEMU](https://www.qemu.org/docs/master/about/index.html).

Managing an installation of Enterprise Architect, which is sold as a licensed product, is outside the scope of this repository.
This repository does contain installation scripts for Enterprise Architect Lite, a free, read-only viewer of EA project files.
An installation of EA Lite is sufficient to enable ShapeChange to process EA project files.

## Installation

### Linux installation

The following instructions apply to all Linux distributions, including [WSL](https://learn.microsoft.com/en-us/windows/wsl/about).

1. Install Nix package manager.

    ```
    sh <(curl --proto '=https' --tlsv1.2 -L https://nixos.org/nix/install)
    ```

2. Enable nix subcommands and flakes.

    ```
    mkdir -p ~/.config/nix
    echo "experimental-features = nix-command flakes" >> ~/.config/nix/nix.conf
    ```

    For more info about Nix, see https://nixos.org.

3. Clone ShapeChange Testbed repository

    ```
    git clone https://github.com/lbodor/shapechange-testbed
    cd shapechange-testbed
    ```

3. Install ShapeChange Testbed packages for Linux.

    ```
    nix develop
    ```

    Command `nix develop` will create a new bash shell session with the following commands in path:

    - `shapechange` - wrapper script for running ShapeChange
    - `shapechange-ea` - wrapper script for running ShapeChange via Wine, which can read EA project files
    - `ea-lite` - read-only viewer for EA project files

    For example,

    ```
    $ nix develop
    (nix-shell) $ shapechange-ea -h

    wine /nix/store/iyvslpq0j5nj1r7hr9ppp6wkzl1mzl4x-source/bin/java.exe \
      -Dline.separator=$'\n' \
      -Djava.library.path="$(winepath --windows '/nix/store/givvxznrwwqq1xbd5mngwi90lcjc8qhp-ea-lite/Sparx Systems/EA LITE/Java API')" \
      -jar "$(winepath --windows /nix/store/rkf1yaz338j8ppkfa1klq5xx52dl3hx7-source/ShapeChange-4.0.0.jar)" \
      -h

    ShapeChange command line interface

    ShapeChange takes a ISO 19109 application schema
    from a UML model and translates it into a GML application
    schema or other implementation representations

    usage: java -jar ShapeChange.jar (options) modelfile

    options:
     -c cfgfile The location of the main configuration
                file. XInclude is supported and can be used
                to modularise the configuration. The default is
                http://shapechange.net/resources/config/minimal.xml.
     -x val rep If a configuration file contains a parameter
                with a value of 'val' then the value will be
                replaced by 'rep'. This option may occur multiple
                times.
                Example: -x '$dir$' './result/xsd' would replace.
                any parameter values '$dir$' in the configuration.
                file with './result/xsd'.
     -d         Invokes the user interface.
     -h         This help screen.
     ```

### Windows installation

1. Install Scoop package manager.

    ```
    Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
    Invoke-RestMethod -Uri https://get.scoop.sh | Invoke-Expression
    ```

    For more info about scoop, see https://scoop.sh.

2. Clone ShapeChange Testbed repository.

    ```
    git clone https://github.com/lbodor/shapechange-testbed
    cd shapechange-testbed
    ```

3. Download [EA Lite installer](https://sparxsystems.com/bin/ealite_x64.msi) into
directory `shapechange-testbed\scoop`.

4. Install ShapeChange Testbed packages for Windows.

    ```
    scoop import scoopfile.json
    ```

    You should now have the following commands in your path:

    - `shapechange` - wrapper script for running ShapeChange
    - `ea-lite` - read-only viewer for EA project files

### MacOS Installation

\[todo\]

## Example transformations

ShapeChange GitHub repository contains a test suite with over 200 EA models
and ShapeChange configuration files.

1. Clone ShapeChange source code repository.

    ```
    git clone https://github.com/ShapeChange/shapechange
    cd shapechange
    ```

2. Make ShapeChange resource files available to module `shapechange-app`, which contains the
test suite in directory `src/test/integrationtests`.

    ```
    cd shapechange-app
    cp -r ../shapechange-core/src/test/resources sc-resources
    ```

3. Run a transformation, e.g.,

    ```
    shapechange-ea -c src/integrationtests/json/jsonFgGeometry/test_json_schema_jsonFgGeometry.xml
    ```

    The output is written to `testResults/json/jsonFgGeometry`.
