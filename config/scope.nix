{ pkgs, ... }:
{
  nixpkgs.config.allowUnfreePredicate = pkg:
    builtins.elem (pkgs.lib.getName pkg) [
      "scope.nvim"
    ];

  plugins = {
    scope = {
      enable = true;
      luaConfig.post = ''
        require('telescope').load_extension('scope')
      '';
    };
  };
}
