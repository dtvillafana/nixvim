{ system, pkgs, ... }:
{
  dependencies = {
    direnv = {
      enable = true;
      package = pkgs.nix-direnv;
    };
    lazygit.enable = true;
  };
}
