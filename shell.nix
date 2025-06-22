{ pkgs ? import <nixpkgs> {} }:

pkgs.mkShell {
  buildInputs = [
    pkgs.ruby_3_1
    pkgs.bundler

    # For patching the pre-compiled sass binary
    pkgs.patchelf

    # common dependencies for building native gem extensions
    pkgs.gcc
    pkgs.gnumake
    pkgs.zlib
    pkgs.libxml2
    pkgs.libxslt
    pkgs.pkg-config
    pkgs.cacert
  ];

  shellHook = ''
    
    export SSL_CERT_FILE="${pkgs.cacert}/etc/ssl/certs/ca-bundle.crt"
    
    # configure bundler to install gems into local `.gems` directory
    export GEM_HOME=$(pwd)/.gems
    export PATH="$GEM_HOME/bin:$PATH"
    export BUNDLE_PATH="$GEM_HOME"

    bundle check || bundle install

    # patching the dynamically linked dart executable
    echo "Checking for sass-embedded executable to patch..."
    SASS_GEM_PATH=$(bundle show sass-embedded 2>/dev/null)
    if [ -d "$SASS_GEM_PATH" ]; then
      DART_EXEC_PATH="$SASS_GEM_PATH/ext/sass/dart-sass/src/dart"
      if [ -f "$DART_EXEC_PATH" ]; then
        echo "Found dart-sass executable at $DART_EXEC_PATH, patching for NixOS..."
        patchelf --set-interpreter "$(cat $NIX_CC/nix-support/dynamic-linker)" "$DART_EXEC_PATH"
        echo "Patching complete."
      else
        echo "dart-sass executable not found at expected path, skipping patch."
      fi
    else
      echo "sass-embedded gem not found, skipping patch."
    fi
  '';
}
