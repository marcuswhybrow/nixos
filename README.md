NixOS is the declaritive linux distribution composed of immutable packages defined in a functional syntax called Nix.

# New System Procedure

```
# Clone this repository 
nix profile install nixpkgs#gh --extra-experimental-features "nix-command flakes"
nix profile install github:marcuswhybrow/git --extra-experimental-features "nix-command flakes"
mkdir ~/Repos
cd ~/Repos
gh auth login
git clone git@github.com:marcuswhybrow/nixos.git

# Replace default configuration with symlink to this repo
sudo mv /etc/nixos/configuration.nix /etc/nixos/configuration.nix.old
sudo ln -s ~/Repos/nixos/flake.nix /etc/nixos/flake.nix

# For a first time install specify the exact flake and system name.
sudo nixos-rebuild switch --flake ~/Repos/nixos#SYSTEM_NAME

```
