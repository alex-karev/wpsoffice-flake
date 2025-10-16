{
  pkgs,
  allowNetwork ? false, # Network off by default
  scale ? null, # Set QT_SCALE_FACTOR variable
  fixIcons ? true, # Fix icons by replacing 2023 with 2019
  package ? pkgs.wpsoffice-cn, # Customize wpsoffice package
  extraBwrapArgs ? [], # Extra arguments for bwrap
}: let
  # Define bwrap package
  bwrapPackage = pkgs.bubblewrap;

  # Construct bwrap arguments
  bwrapArgs =
    [
      "--unshare-all"
      "--dev /dev"
      "--proc /proc"
      "--tmpfs /tmp"
      "--die-with-parent"
      "--new-session"
      "--ro-bind /nix/store /nix/store"
      "--ro-bind /etc /etc"
      "--ro-bind /run/current-system/sw/bin /bin"
      "--ro-bind /tmp/.X11-unix /tmp/.X11-unix"
      "--bind ~ ~"
      "--setenv PATH /bin"
      (pkgs.lib.optionalString allowNetwork "--share-net")
      (pkgs.lib.optionalString (scale != null) "--setenv QT_SCALE_FACTOR ${scale}")
    ]
    ++ extraBwrapArgs;

  # Define bwrap command
  mkBwrapCommand = exec: ''
    #!${pkgs.bash}/bin/bash
    exec ${bwrapPackage}/bin/bwrap ${pkgs.lib.concatStringsSep " " bwrapArgs} ${package}/bin/${exec} \"\$@\"
  '';
in
  pkgs.stdenv.mkDerivation rec {
    name = "wpsoffice-sandboxed";
    version = package.version;
    dontBuild = true;
    dontUnpack = true;

    # Dependencies
    buildInputs = [
      package
      pkgs.bubblewrap
    ];

    # Generate run scripts and modify .desktop files
    installPhase = ''
      mkdir -p $out/bin
      for app in wps wpspdf wpp et; do
        echo "${mkBwrapCommand "$app"}" > "$out/bin/$app"
        chmod +x "$out/bin/$app"
      done
      mkdir -p $out/share/applications
      for file in "${package}/share/applications"/*.desktop; do
        if [ -f "$file" ]; then
          newfile="$out/share/applications/$(basename "$file")"
          cp "$file" "$newfile"
          sed -i "s|${package}|$out|g" "$newfile"
          ${pkgs.lib.optionalString fixIcons "sed -i '/^Icon=/s/2023/2019/g' \"$newfile\""}
        fi
      done
    '';

    # About package
    meta = {
      description = "WPS Office flake featuring bwrap and usefull options";
      homepage = "https://github.com/alex-karev/wpsoffice-flake";
    };
  }
