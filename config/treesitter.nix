{ pkgs, ... }:
let
    treesitter-poweron = pkgs.tree-sitter.buildGrammar {
        language = "poweron";
        version = "0.0.1+rev=main";
        src = pkgs.fetchFromGitHub {
            owner = "dtvillafana";
            repo = "tree-sitter-poweron";
            rev = "main";
            hash = "sha256-QMPww9Fa+z6/wISQXVSIX2go6GoYdG8apHZGiRbXhms=";
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
                    additional_vim_regex_highlighting = [ "csv" ];
                    enable = true;
                    disable = ''function(lang, buf)
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
            luaConfig.post =
                ''
                local git_user = 'dtvillafana'
                local git_repo = 'tree-sitter-poweron'
                local git_repo_url = 'https://github.com/' .. git_user .. '/' .. git_repo
                local parsers = require('nvim-treesitter.parsers').get_parser_configs()
                local poweron = {
                    install_info = {
                        url = git_repo_url,
                        files = { 'src/parser.c', 'src/scanner.cc' },
                        branch = 'main',
                        generate_requires_npm = false,
                        requires_generate_from_grammar = false,
                    },
                    filetype = 'poweron'
                }
                table.insert(parsers, poweron)
                vim.treesitter.language.register('poweron', {
                    'poweron',
                    'po'
                })
                '';
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
