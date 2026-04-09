{ pkgs, ... }:
{
  dependencies = {
    direnv = {
      enable = true;
      package = pkgs.nix-direnv;
    };
    lazygit.enable = true;
    opencode.enable = true;
    claude-code.enable = true;
  };
}
