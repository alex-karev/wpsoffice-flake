# WPS Office Flake

A custom NixOS flake that provides a sandboxed offline WPS Office installation with additional fonts and useful configuration options.

## Features

- **Sandboxed Execution**: Uses `bubblewrap` (bwrap) to run WPS Office in a restricted environment
- **Network Control**: Netword access is disabled by default
- **UI Scaling**: Support for QT scaling factor for HiDPI displays
- **Icon Fixes**: Automatic fixes for WPS Office 2023 icons to work with most icon themes
- **Additional Fonts**: Includes fonts package with necessary symbol fonts for math formula display
- **Customizable**: Flexible package options and configurations

## Packages

- `wpsoffice-sanboxed` - sandboxed version of WPS Office
- `wpsoffice-fonts` - fonts for WPS Office from [this](https://github.com/ferion11/ttf-wps-fonts) repo

## Configuration Options

- `allowNetwork` (default: `false`): Enable/disable network access
- `scale` (default: `null`): Set `QT_SCALE_FACTOR` for UI scaling. Should be a string
- `fixIcons` (default: `true`): Fix `.desktop` icons by replacing 2023 with 2019
- `package` (default: `pkgs.wpsoffice-cn`): Customize the base WPS Office package

## Usage

### As a Flake Input

Add this flake to your system configuration:

```nix
{
  inputs.wpsoffice-flake.url = "github:alex-karev/wpsoffice-flake";

  outputs = { self, nixpkgs, wpsoffice-flake }: {
    nixosConfigurations.your-hostname = nixpkgs.lib.nixosSystem {
      # ... your configuration
      environment.systemPackages = [
        wpsoffice-flake.packages.x86_64-linux.default
      ];
      # (Optionally) install fonts
      fonts.packages = [
        wpsoffice-flake.packages.wpsoffice-fonts.default
      ];
    };
  };
}
```

To customize the package, use override attribute:

```nix
environment.systemPackages = [
  (wpsoffice-flake.packages.x86_64-linux.default.override {
    scale = "2";
    allowNetwork = true;
  })
];
```

## Dependencies

- `bubblewrap`: For application sandboxing
- `wpsoffice-cn`: Base WPS Office package (unfree)
- Various system libraries and dependencies

## License

This flake provides packages that may contain unfree software. Please ensure you comply with the respective licenses of WPS Office and the included fonts.

## Source

- WPS Office: [Official WPS Office](https://www.wps.com/)
- Fonts: [ferion11/ttf-wps-fonts](https://github.com/ferion11/ttf-wps-fonts)
