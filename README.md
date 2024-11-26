# nixvim
This is David Villafaña's nixvim config, a neovim distribution packaged with Nix
# Requirements
You will need the nix package manager.

Good security practice would be to modfiy the below command to download the script and inspect it before running, if you've never installed nix before or don't know what it is.
## multi user installation
```sh
sh <(curl -L https://nixos.org/nix/install) --daemon
```
## single user installation
```sh
sh <(curl -L https://nixos.org/nix/install) --no-daemon
```
# running nixvim
this will take a while to install all dependencies the first time, subsequent times it will be fast
```sh
nix run github:dtvillafana/nixvim
```
# optional config
if you use orgmode or gopass/pass in flake.nix, change the orgPath and omenPath value in flake.nix, set them to null if they do not exist, the default is to disable orgmode and omen functionality
