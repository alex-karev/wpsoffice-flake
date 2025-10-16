# WPS Office Flake

A custom NixOS flake that provides a sandboxed offline WPS Office installation with additional fonts and useful configuration options.

## Features

* **Sandboxed Execution**: Runs WPS Office in a restricted environment using `bubblewrap` (bwrap)
* **Network Control**: Network access is disabled by default
* **UI Scaling**: Supports the `QT_SCALE_FACTOR` variable for HiDPI displays
* **Icon Fixes**: Automatically fixes WPS Office 2023 icons to work with most icon themes
* **Additional Fonts**: Includes a fonts package with the necessary symbol fonts for displaying math formulas
* **Customizable**: Flexible package options and configuration settings

## Packages

* `wpsoffice` — sandboxed version of WPS Office
* `fonts` — fonts for WPS Office from [this repository](https://github.com/ferion11/ttf-wps-fonts)

## Configuration Options

| Option           | Default             | Description                                                                |
| ---------------- | ------------------- | -------------------------------------------------------------------------- |
| `allowNetwork`   | `false`             | Enable or disable network access inside the sandbox                        |
| `scale`          | `null`              | Set `QT_SCALE_FACTOR` for UI scaling (string)                              |
| `fixIcons`       | `true`              | Replace `2023` with `2019` in `.desktop` files to fix icons                |
| `package`        | `pkgs.wpsoffice-cn` | Base WPS Office package (unfree)                                           |
| `extraBwrapArgs` | `[]`                | List of extra arguments to pass to `bubblewrap` for advanced customization |

## Usage

### As a Flake Input

Add this flake to your NixOS configuration:

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
        wpsoffice-flake.packages.x86_64-linux.fonts
      ];
    };
  };
}
```

### Customize

To customize the package, use the `override` attribute:

```nix
environment.systemPackages = [
  (wpsoffice-flake.packages.x86_64-linux.default.override {
    scale = "2";
    allowNetwork = true;
    extraBwrapArgs = [
      "--ro-bind /usr/share/icons /usr/share/icons"
    ];
  })
];
```

### Run with `nix run`

You can also run WPS Office directly from the flake without installing it:

```bash
nix run github:alex-karev/wpsoffice-flake#wpsoffice-sandboxed
```

or, if you’re in the cloned flake directory:

```bash
nix run .#wpsoffice
```

## Dependencies

* `bubblewrap` — for application sandboxing
* `wpsoffice-cn` — base WPS Office package (unfree)
* Various system libraries and runtime dependencies

## License

This flake provides packages that may include unfree software.
Please ensure you comply with the respective licenses of WPS Office and the included fonts.

## Sources

* WPS Office: [Official Website](https://www.wps.com/)
* Fonts: [ferion11/ttf-wps-fonts](https://github.com/ferion11/ttf-wps-fonts)
