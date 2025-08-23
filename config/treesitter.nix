{ pkgs, ... }:
let
  treesitter-poweron = pkgs.tree-sitter.buildGrammar {
    language = "poweron";
    version = "0.0.1+rev=main";
    generate = true;
    src = pkgs.fetchFromGitHub {
      owner = "dtvillafana";
      repo = "tree-sitter-poweron";
      rev = "main";
      hash = "sha256-/1UDCdqbv9vjBbnj+hSKhfcTm93N67cDV3wwpHEZKTY=";
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
          disable = ''
            function(lang, buf)
                            -- Disable highlighting for CSV-related file types
                            if lang == "csv" or lang == "tsv" or lang == "bsv" or lang == "csv_pipe" or lang == "csv_whitespace" or lang == "csv_semicolon" then
                                return true
                            end

                            local max_filesize = 1000 * 1024
                            local ok, stats = pcall(vim.loop.fs_stat, vim.api.nvim_buf_get_name(buf))
                            if ok and stats and stats.size > max_filesize then
                                return true
                            end
                        end'';
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
        };
      };
      # luaConfig.post =
      #     ''
      #     do
      #         local parsers = require('nvim-treesitter.parsers').get_parser_configs()
      #         parsers.poweron = {
      #             install_info = {
      #                 url = "${builtins.trace treesitter-poweron treesitter-poweron}",
      #                 files = { 'src/parser.c', 'src/scanner.cc' },
      #                 -- branch = 'main',
      #                 generate_requires_npm = false,
      #                 requires_generate_from_grammar = true,
      #             },
      #             filetype = 'poweron'
      #         }
      #         vim.treesitter.language.register('poweron', {
      #             'poweron',
      #             'po'
      #         })
      #     end
      #     '';
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
