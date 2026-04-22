{ pkgs, lib, ... }:
let
  treesitter-poweron = pkgs.tree-sitter.buildGrammar {
    language = "poweron";
    version = "0.0.1";
    generate = true;
    src = pkgs.fetchFromGitHub {
      owner = "dtvillafana";
      repo = "tree-sitter-poweron";
      rev = "main";
      hash = "sha256-AWO0BmfrKQ7Cob6nwiCl0eOH3jELrlD5yJlZ/6nHMSo=";
    };
    meta.homepage = "https://github.com/dtvillafana/tree-sitter-poweron";
  };
in
{
  plugins = {
    treesitter = {
      grammarPackages = pkgs.vimPlugins.nvim-treesitter.passthru.allGrammars ++ [
        treesitter-poweron
      ];
      enable = true;
      settings = {
        highlight = {
          enable = true;
        };
        incremental_selection = {
          enable = true;
          keymaps = {
            init_selection = " si";
            node_incremental = " sn";
            node_decremental = " sN";
            scope_incremental = " ss";
          };
        };
        indent = {
          enable = true;
          disable = [ "org" ];
        };
      };
    };
  };
  filetype = {
    extension = {
      poweron = "poweron";
      pnd = "poweron";
      PND = "poweron";
      po = "poweron";
      PO = "poweron";
      pro = "poweron";
      PRO = "poweron";
      def = "poweron";
      DEF = "poweron";
      sub = "poweron";
      SUB = "poweron";
      set = "poweron";
      SET = "poweron";
      fmp = "poweron";
      FMP = "poweron";
      fm = "poweron";
      FM = "poweron";
      inc = "poweron";
      INC = "poweron";
      symform = "poweron";
      SYMFORM = "poweron";
    };
    pattern = {
      ".*.%d%d%d" = "poweron";
      "EAR.*" = "poweron";
      "ear.*" = "poweron";
      "EMA.*" = "poweron";
      "ema.*" = "poweron";
      "ELA.*" = "poweron";
      "ela.*" = "poweron";
      ".*specfiles/*.*" = "poweron";
      ".*poweron/*.*" = "poweron";
    };
  };
}
