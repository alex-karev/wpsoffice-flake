{
  pkgs,
  allowNetwork ? false, # Network off by default
  scale ? null, # Set QT_SCALE_FACTOR variable
  fixIcons ? true, # Fix icons by replacing 2023 with 2019
  package ? pkgs.wpsoffice-cn, # Customize wpsoffice package
}: let
  # Define bwrap package
  bwrapPackage = pkgs.bubblewrap;

  # Construct bwrap arguments
  bwrapArgs =
    "--unshare-all "
    + "--dev /dev "
    + "--proc /proc "
    + "--die-with-parent "
    + "--new-session "
    + "--ro-bind /tmp/.X11-unix /tmp/.X11-unix "
    + "--ro-bind /nix/store /nix/store "
    + "--ro-bind /etc /etc "
    + "--ro-bind /run/current-system/sw/bin /bin "
    + "--bind /run/user/$(id -u) /run/user/$(id -u) "
    + "--bind /tmp /tmp "
    + "--bind ~ ~ "
    + "--setenv PATH /bin "
    + (
      if allowNetwork
      then "--share-net "
      else ""
    )
    + (
      if scale != null
      then "--setenv QT_SCALE_FACTOR ${scale} "
      else ""
    );

  # Define bwrap command
  mkBwrapCommand = exec: ''
    exec ${bwrapPackage}/bin/bwrap ${bwrapArgs} ${package}/bin/${exec} \"\$@\"
  '';
in
  pkgs.stdenv.mkDerivation rec {
    name = "wpsoffice-sandboxed";
    version = "1.0";

    # Dependencies
    buildInputs = [
      package
      pkgs.bubblewrap
    ];

    # No source and no build
    unpackPhase = "true";
    buildPhase = "true";

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
          cat "$file" > "$newfile"
          sed -i "s|${package}|$out|g" "$newfile"
          ${
        if fixIcons
        then "sed -i '/^Icon=/s/2023/2019/g' \"$newfile\""
        else ""
      }
        fi
      done
    '';

    # About package
    meta = {
      description = "WPS Office flake featuring bwrap and usefull options";
      homepage = "https://github.com/alex-karev/wpsoffice-flake";
    };
  }
