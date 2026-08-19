{ pkgs, ... }:
let
  treesitter-batch = pkgs.tree-sitter.buildGrammar {
    language = "batch";
    version = "0.11.1";
    src = pkgs.fetchFromGitHub {
      owner = "wharflab";
      repo = "tree-sitter-batch";
      rev = "2aa22f00d7f5bbe58556b8eef0b1fc1629508603";
      hash = "sha256-Q8R5gWeEYkdoROa/elBjVEn+Vz7HydDguGDN5C6o3Zw=";
    };
    meta.homepage = "https://github.com/wharflab/tree-sitter-batch";
  };
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
  extraFiles."queries/batch/highlights.scm".text = ''
    (echo_off) @keyword
    (comment) @comment
    (label) @label

    (set_keyword) @keyword
    (variable_name) @variable
    (set_option) @constant
    (assignment_literal) @string
    (arithmetic_expression) @string

    (if_stmt) @keyword
    (for_stmt) @keyword
    (goto_stmt) @keyword
    (call_stmt) @keyword
    (setlocal_stmt) @keyword
    (endlocal_stmt) @keyword
    (exit_stmt) @keyword

    (comparison_op) @operator
    (redirect_op) @operator
    (fd_redirect) @operator

    (command_name) @function

    (variable_reference) @variable
    (for_set_literal) @string
    (for_variable) @variable.parameter
    (for_options) @constant
    (string) @string
    (integer) @number
    (command_option) @constant
    (argument_value) @string
    (redirect_target) @string.special
  '';

  plugins = {
    treesitter = {
      grammarPackages = pkgs.vimPlugins.nvim-treesitter.passthru.allGrammars ++ [
        treesitter-batch
        treesitter-poweron
      ];
      enable = true;
      languageRegister.batch = "dosbatch";
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
