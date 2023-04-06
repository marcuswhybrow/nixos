My personal (first try at a) NixOS configuration flake. It achieves:

1. Configures multiple machines and users.
2. Is a working example of flakes.
3. A simple (comparatively) module composition approach.
4. Home Manager, and Home Manager Modules.
5. A working example of custom `./packages`

**Here's how it works.** — `flake.nix` exposes `nixosConfigurations.marcus-laptop` which is (essentialy) composed of `./systems/marcus-laptop.nix` and `./users/marcus.nix`.

Those two nix modules make use of custom options from more modules in `./systems/options` and `./user/options`, made available to all modules in `flake.nix` (that's how modules work, they all get merged together).

I've also flaked up some custom bash scripts in `./packages`. Each flake overlays a custom package into `nixpkgs` which pops a custom bash script into the Nix Store, and provide custom options for other modules to consume. Again these packages are composed together in `flake.nix`

**My Approach** — My **first** mistake was not using (for I was not aware) Nix modules and Home Manager modules. My **second** mistake was building mega-modules that configured many smaller modules. So instead I do this.

1. Prefer using Home Manager modules to extend existing packages with new options that make changes only to that package. I.e. keep things small and self-contained.
2. Everything is just a **module**, and all the logic composition logic is entirely contained with `flake.nix`. So it's super duper simple to reason about.
