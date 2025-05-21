{ system, pkgs, ... }:
{
    plugins = {
        telescope.keymaps = {
            "<leader>lf" = "lsp_references";
            "<leader>lg" = "lsp_definitions";
            "<leader>lci" = "lsp_incoming_calls";
            "<leader>lco" = "lsp_outgoing_calls";
        };
        direnv = {
            enable = true;
            settings = {
                direnv_silent_reload = 0;
            };
        };
        lsp = {
            enable = true;

            keymaps = {
                silent = true;
                diagnostic = {
                    # Navigate in diagnostics
                    "<leader>lde" = "open_float";
                };

                extra = [
                    { mode = "n"; key = "<leader>lr"; action = "<CMD>Lspsaga rename<CR>"; }
                    { mode = "n"; key = "<leader>lp"; action = "<CMD>Lspsaga peek_definition<CR>"; }
                    { mode = "n"; key = "<leader>lh"; action = "<CMD>Lspsaga hover_doc<CR>"; }
                    { mode = "n"; key = "<leader>lt"; action = "<CMD>Lspsaga goto_type_definition<CR>"; }
                    { mode = "n"; key = "<leader>lo"; action = "<CMD>Lspsaga outline<CR>"; }
                    { mode = "n"; key = "<leader>la"; action = "<CMD>Lspsaga code_action<CR>"; }
                    { mode = "n"; key = "<leader>ldj"; action = "<CMD>Lspsaga diagnostic_jump_next<CR>"; }
                    { mode = "n"; key = "<leader>ldk"; action = "<CMD>Lspsaga diagnostic_jump_prev<CR>"; }
                    { mode = "n"; key = "<leader>lx"; action = "<CMD>lua vim.g.type_checking = not vim.g.type_checking; require('lspconfig').basedpyright.setup({settings = { basedpyright = { analysis = { typeCheckingMode = vim.g.type_checking and 'on' or 'off' }}}})<CR>"; }
                ];
            };
            servers = {
                ansiblels = {
                    enable = true;
                    filetypes = [
                        "yaml.ansible"
                    ];
                    settings.ansible = {
                        ansible = {
                            path = "ansible";
                            useFullyQualifiedCollectionNames = true;
                        };
                        executionEnvironment.enabled = false;
                        python = {
                            interpreterPath = "python"; # Will use the first python in PATH, which should be the one from direnv
                            envKind = "auto";
                        };
                    };
                };
                elixirls.enable = true;
                jdtls.enable = true;
                svelte.enable = true;
                nixd = {
                    enable = true;
                    settings = {
                        formatting.command = [ "alejandra" ];
                        options.nixvim.expr = ''(builtins.getFlake ../. ).packages.${system}.neovimNixvim.options''; 
                    };
                };
                lua_ls = {
                    enable = true;
                    settings = {
                        telemetry.enable = false;
                        diagnostics = {
                            globals = [
                                "vim"
                            ];
                        };
                    };
                };
                basedpyright = {
                    enable = true;
                };
                bashls = {
                    enable = true;
                    filetypes = [
                        "zsh"
                        "sh"
                        "bash"
                        "ksh"
                    ];
                };
                cmake.enable = true;
                html.enable = true;
                jsonls.enable = true;
                lemminx.enable = true;
                tailwindcss = {
                    enable = true;
                    filetypes = [
                        "aspnetcorerazor"
                        "astro"
                        "astro-markdown"
                        "blade"
                        "clojure"
                        "django-html"
                        "htmldjango"
                        "edge"
                        "eelixir"
                        "elixir"
                        "ejs"
                        "erb"
                        "eruby"
                        "gohtml"
                        "gohtmltmpl"
                        "haml"
                        "handlebars"
                        "hbs"
                        "htmlangular"
                        "html-eex"
                        "heex"
                        "jade"
                        "leaf"
                        "liquid"
                        "mdx"
                        "mustache"
                        "njk"
                        "nunjucks"
                        "php"
                        "razor"
                        "slim"
                        "twig"
                        "css"
                        "less"
                        "postcss"
                        "sass"
                        "scss"
                        "stylus"
                        "sugarss"
                        "javascript"
                        "javascriptreact"
                        "reason"
                        "rescript"
                        "typescript"
                        "typescriptreact"
                        "vue"
                        "svelte"
                        "templ"
                    ];
                };
                ts_ls.enable = true;
                rust_analyzer = {
                    enable = true;
                    installCargo = true;
                    installRustc = true;
                };
                clangd.enable = true;

            };
        };
        lspsaga = {
            enable = true;
            outline = {
                closeAfterJump = true;
                layout = "float";
                keys = {
                    jump = "gd";
                    toggleOrJump = "<CR>";
                };
            };
            diagnostic = {
                diagnosticOnlyCurrent = true;
            };
        };
    };
    filetype = {
        pattern = {
            ".*inventory" = "yaml.ansible";
            ".*playbook.yml" = "yaml.ansible";
            ".*config.yml" = "yaml.ansible";
        };
    };
    extraConfigLua = ''
        vim.g.type_checking = true;
        '';
}
