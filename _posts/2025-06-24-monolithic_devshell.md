---
layout: post
title: "Monolithic Devshell (sort of)"
author: "Aditya Tejpaul"
---


### Table of Contents
1.  [Python Application Template](#org21410da)
2.  [Rust Application Template](#org492d172)
3.  [React, Nodejs and tsx Template](#orga984ef5)
4.  [Golang Template](#org9fa57fe)
5.  [Flutter + Android Emulator Template](#org09e81a5)
6.  [Jekyll Template](#org6aa8899)


All my projects are sub-directories in the Projects directory. I manage all my nix devshells through this org file, which I then write to project-specific directories.

<br>

To use any of them, set the `projectPath` variable and tangle the block.
For example, in Emacs: `C-c C-v C-t` with the cursor in the block,
and provide the path: `:projectPath "./my-new-app/flake.nix"`

<a id="org21410da"></a>

### Python Application Template

Standard setup for a Python project.
It includes:

-   Python 3.11
-   Ruff for linting + formatting
-   uv for package management
-   ty for type checking


```nix
    # flake.nix
    {
      description = "A new Python project";
    
      inputs = {
        nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
        flake-utils.url = "github:numtide/flake-utils";
      };
    
      outputs = { self, nixpkgs, flake-utils }:
        flake-utils.lib.eachDefaultSystem (system: let
          pkgs = nixpkgs.legacyPackages.${system};
        in {
          devShells.default = pkgs.mkShell {
            packages = [
              pkgs.python311
              pkgs.ty # type checker
              pkgs.uv # package installer
              pkgs.ruff # linter + formatter
            ];
    
            shellHook = ''
              export LD_LIBRARY_PATH="${stdenv.cc.cc.lib}/lib"
              unset SOURCE_DATE_EPOCH
            ''
          };
        });
    }
```

<a id="org492d172"></a>

### Rust Application Template

Standard Rust setup.

-   Stable Rust toolchain
-   rust-analyzer
-   clippy and rustfmt

```nix
    # flake.nix
    {
      description = "Rust project";
    
      inputs = {
        nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
        flake-utils.url = "github:numtide/flake-utils";
        rust-overlay.url = "github:oxalica/rust-overlay";
      };
    
      outputs = { self, nixpkgs, flake-utils, rust-overlay }:
        flake-utils.lib.eachDefaultSystem (system: let
          pkgs = import nixpkgs {
            inherit system;
            overlays = [ rust-overlay.overlays.default ];
          };
          rustToolchain = pkgs.rust-bin.stable.latest.default.withComponents [
            "rustc"
            "cargo"
            "clippy"        
            "rustfmt"       
            "rust-analyzer"
          ];
        in {
          devShells.default = pkgs.mkShell {
            packages = [
              rustToolchain
              pkgs.just
              pkgs.pkg-config
              pkgs.cargo-watch
              pkgs.openssl.dev
            ];
            
            # Make rust-analyzer available to editors
            RUST_SRC_PATH = "${rustToolchain}/lib/rustlib/src/rust/library";
          };
        });
    }
```

<a id="orga984ef5"></a>

### Web Dev Template

Standard web-dev setup

-   pnpm for package management
-   eslint and prettier for linting and formatting&#x2026;
-   &#x2026; although I mostly prefer to use biome

```nix
    # flake.nix
    {
      description = "A comprehensive development shell for a React/TypeScript project";
    
      inputs = {
        nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
        flake-utils.url = "github:numtide/flake-utils";
      };
    
      outputs = { self, nixpkgs, flake-utils }:
        flake-utils.lib.eachDefaultSystem (system:
          let
            nodejs = pkgs.nodejs_20;
            pkgs = nixpkgs.legacyPackages.${system};
          in
          {
            devShells.default = pkgs.mkShell {
              buildInputs = [
                nodejs
                pkgs.pnpm
                
                pkgs.nodePackages.typescript-language-server
                pkgs.nodePackages.typescript
    
                # Linters and formatters
                pkgs.nodePackages.eslint
                pkgs.nodePackages.prettier
                pkgs.biome
              ];
              
              shellHook = ''
                echo "✅ React/TS dev environment loaded."
                echo "Node version: $(node --version)"
                echo "pnpm version: $(pnpm --version)"
    
                # Check if node_modules exists, and if not, give a hint.
                if [ ! -d "node_modules" ]; then
                  echo "🔔 HINT: 'node_modules' not found. Run 'pnpm install' to get started."
                fi
              '';
            };
          }
        );
    }
```

<a id="org9fa57fe"></a>

### Golang Template

Standard Go Template

-   gopls and delve, lsp and debugger
-   openssl for generating certificates
-   and protobuf support

```nix
    {
      description = "A development environment for a Go project";
    
      inputs = {
        nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
        flake-utils.url = "github:numtide/flake-utils";
      };
    
      outputs = { self, nixpkgs, flake-utils }:
        flake-utils.lib.eachDefaultSystem (system:
          let
            pkgs = nixpkgs.legacyPackages.${system};
          in
          {
            devShells.default = pkgs.mkShell {
              packages = [
                pkgs.go
                pkgs.gopls     # lsp
                pkgs.delve     # debugger
              ];
    
              shellHook = ''
                echo "Go environment loaded."
                
                # Define absolute paths for Go environment variables
                export PROJECT_ROOT="$(pwd)"
                export GOPATH="''${PROJECT_ROOT}/.go"
                export GOBIN="''${GOPATH}/bin"
                export GOMODCACHE="''${GOPATH}/pkg/mod"
                export GOCACHE="$GOPATH/pkg/cache"
    
                # Create directories if they don't exist
                mkdir -p "''${GOPATH}"
                mkdir -p "''${GOBIN}"
                mkdir -p "''${GOMODCACHE}"
                mkdir -p "''${GOCACHE}"
                export PATH="''${GOBIN}:''$PATH"
    
                echo "GOPATH is set to: ''${GOPATH}"
              '';
            };
          }
        );
    }
```

<a id="org09e81a5"></a>

### Flutter + Android Emulator Template

Flutter Dev setup with android emulator

-   I took this unchanged to a great degree from [here](https://github.com/linuxmobile/flutter-flake-template/tree/main).

```nix
    {
      description = "Flutter development environment with Android Emulator";
    
      inputs = {
        nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
        systems.url = "github:nix-systems/default-linux";
        flake-parts.url = "github:hercules-ci/flake-parts";
        flake-parts.inputs.nixpkgs-lib.follows = "nixpkgs";
      };
    
      outputs = {flake-parts, ...} @ inputs:
        flake-parts.lib.mkFlake {inherit inputs;} {
          systems = import inputs.systems;
          perSystem = {
            pkgs,
            system,
            ...
          }: let
            emulatorScripts = with pkgs; {
              startEmulator = writeShellScriptBin "start-emulator" ''
                export QT_QPA_PLATFORM=xcb
                export QT_WAYLAND_DISABLE_WINDOWDECORATION=1
                export ANDROID_EMULATOR_USE_SYSTEM_LIBS=1
                export LIBGL_ALWAYS_SOFTWARE=1
    
                GPU_MODE=''${1:-swiftshader_indirect}
                echo "Starting emulator with GPU mode: $GPU_MODE"
    
                pkill -9 emulator-x86_64 2>/dev/null
    
                $ANDROID_HOME/emulator/emulator -avd flutter_emulator \
                  -gpu $GPU_MODE \
                  -accel on \
                  -memory 8192 \
                  -cores 4 \
                  -no-boot-anim \
                  -qemu -smp 4,threads=2 \
                  -enable-kvm
              '';
            };
            pkgs = import inputs.nixpkgs {
              inherit system;
              config = {
                allowUnfree = true;
                android_sdk.accept_license = true;
              };
            };
    
            androidComposition = pkgs.androidenv.composeAndroidPackages {
              cmdLineToolsVersion = "9.0";
              platformToolsVersion = "34.0.4";
              buildToolsVersions = ["31.0.0" "33.0.0" "34.0.0" "35.0.0"];
              platformVersions = ["31" "33" "34" "35"];
              abiVersions = ["x86_64"];
              systemImageTypes = ["google_apis"];
              cmakeVersions = ["3.22.1"];
              extraLicenses = ["android-googletv-license" "android-sdk-arm-dbt-license" "android-sdk-preview-license" "google-gdk-license" "mips-android-sysimage-license"];
              includeEmulator = true;
              includeSystemImages = true;
              includeNDK = true;
              ndkVersions = ["26.3.11579264"];
            };
            androidSdk = androidComposition.androidsdk;
          in {
            devShells.default = pkgs.mkShell {
              name = "flutter-android-env";
    
              shellHook = ''
                export ANDROID_HOME="${androidSdk}/libexec/android-sdk"
                export ANDROID_SDK_ROOT="${androidSdk}/libexec/android-sdk"
                export ANDROID_AVD_HOME="$HOME/.android/avd"
                export JAVA_HOME="${pkgs.jdk17.home}"
                export PATH="$PATH:$JAVA_HOME/bin"
                export PATH="$PATH:$ANDROID_HOME/emulator"
                export PATH="$PATH:$ANDROID_HOME/platform-tools"
                export PATH="$PATH:$ANDROID_HOME/cmdline-tools/latest/bin"
                export PATH="$PATH:$HOME/.pub-cache/bin"
                # Add CMake to PATH so it's discoverable
                export PATH="$PATH:$ANDROID_HOME/cmake/3.22.1/bin"
                export GRADLE_OPTS="-Dorg.gradle.project.android.aapt2FromMavenOverride=$ANDROID_HOME/build-tools/34.0.0/aapt2 -Dorg.gradle.project.android.useAndroidX=true -Dorg.gradle.project.android.enableJetifier=true"
                export FLUTTER_GRADLE_PLUGIN_VERSION="8.5.0"
                export ANDROID_GRADLE_PLUGIN_VERSION="8.5.0"
                export CHROME_EXECUTABLE="${pkgs.google-chrome}/bin/google-chrome-stable"
                
                # Prevent dynamic SDK installations - this is crucial for Nix
                export ANDROID_SDK_MANAGER_DISABLE_DYNAMIC_INSTALL=true
                export FLUTTER_GRADLE_PLUGIN_ANDROID_SDK_MANAGER_DISABLE_DYNAMIC_INSTALL=true
                export ANDROID_NDK_ROOT="$ANDROID_HOME/ndk/26.3.11579264"
                export PUB_CACHE="$HOME/.pub-cache"
                export FLUTTER_ROOT="${pkgs.flutter}"
    
                # Create emulator if it doesn't exist
                if ! avdmanager list avd | grep -q "flutter_emulator"; then
                  echo "Creating new emulator..."
                  avdmanager create avd \
                    -n flutter_emulator \
                    -k 'system-images;android-34;google_apis;x86_64' \
                    -d pixel_6
                else
                  echo "Emulator 'flutter_emulator' already exists"
                fi
    
                echo "Flutter environment ready!"
                echo "Commands available:"
                echo "  start-emulator [gpu_mode] - Start the Android emulator (default: swiftshader_indirect)"
                echo ""
                echo "CMake is available at: $ANDROID_HOME/cmake/3.22.1/bin/cmake"
              '';
    
              buildInputs = with pkgs;
                [
                  flutter
                  androidSdk
                  gradle
                  jdk17
                  scrcpy
                  mesa-demos
                  google-chrome
                  gst_all_1.gstreamer
                  gst_all_1.gstreamermm
                  gst_all_1.gst-plugins-base
                  gst_all_1.gst-plugins-good
                  gst_all_1.gst-plugins-bad
                  gst_all_1.gst-plugins-ugly
                  gst_all_1.gst-vaapi
                ]
                ++ (with emulatorScripts; [
                  startEmulator
                ]);
            };
          };
        };
    }
```

<a id="org6aa8899"></a>

### Jekyll Template

```nix
    {
      description = "Jekyll project";
    
      inputs = {
        nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
        flake-utils.url = "github:numtide/flake-utils";
      };
    
      outputs = { self, nixpkgs, flake-utils }:
        flake-utils.lib.eachDefaultSystem (system:
          let
            pkgs = nixpkgs.legacyPackages.${system};
          in
          {
            devShells.default = pkgs.mkShell {
              packages = [
                # Ruby Environment
                pkgs.ruby_3_1
                pkgs.bundler
    
                # For patching pre-compiled sass binaries.
                pkgs.patchelf
    
                # Common dependencies for building native gem extensions (e.g., nokogiri).
                pkgs.gcc
                pkgs.gnumake
                pkgs.zlib
                pkgs.libxml2
                pkgs.libxslt
                pkgs.pkg-config
              ];
    
              shellHook = ''
                echo "✅ Jekyll/Ruby environment loaded."
    
                # Configure bundler to install gems into a local `.gems` directory
                # to avoid polluting your user environment.
                export GEM_HOME=$(pwd)/.gems
                export PATH="$GEM_HOME/bin:$PATH"
                export BUNDLE_PATH="$GEM_HOME"
                echo "GEM_HOME is set to: $GEM_HOME"
    
                # Ensure all gem dependencies are installed before proceeding.
                echo "Checking for bundle consistency..."
                bundle check || bundle install
    
                # The sass-embedded gem ships with a pre-compiled 'dart' executable that is
                # dynamically linked. On NixOS, we must patch this executable to point to
                # the correct dynamic linker provided by the Nix environment.
                # We find the path to the gem using 'bundle show' and then patch the binary.
                echo "Checking for sass-embedded executable to patch..."
                SASS_GEM_PATH=$(bundle show sass-embedded 2>/dev/null)
                if [ -d "$SASS_GEM_PATH" ]; then
                  DART_EXEC_PATH="$SASS_GEM_PATH/ext/sass/dart-sass/src/dart"
                  if [ -f "$DART_EXEC_PATH" ]; then
                    echo "Found dart-sass executable at $DART_EXEC_PATH, patching for NixOS..."
                    # The $NIX_CC variable is made available by including `pkgs.gcc`.
                    patchelf --set-interpreter "$(cat $NIX_CC/nix-support/dynamic-linker)" "$DART_EXEC_PATH"
                    echo "Patching complete."
                  else
                    echo "dart-sass executable not found at expected path, skipping patch."
                  fi
                else
                  echo "sass-embedded gem not found, skipping patch."
                fi
              '';
            };
          }
        );
    }
```
### Direnv

I also use [nix-direnv](https://github.com/nix-community/nix-direnv) to automatically populate my environment with the dependencies and environment variables that the devshell lists whenever I enter that project's directory.

```sh
echo "use nix" >> .envrc
direnv allow
```