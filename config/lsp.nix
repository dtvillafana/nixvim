{ system, pkgs, ... }:
{
    plugins = {
        direnv = {
            enable = true;
            direnvPackage = pkgs.nix-direnv;
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
                    { mode = "n"; key = "<leader>lg"; action = "<CMD>Lspsaga goto_definition<CR>"; }
                    { mode = "n"; key = "<leader>lp"; action = "<CMD>Lspsaga peek_definition<CR>"; }
                    { mode = "n"; key = "<leader>lh"; action = "<CMD>Lspsaga hover_doc<CR>"; }
                    { mode = "n"; key = "<leader>lt"; action = "<CMD>Lspsaga goto_type_definition<CR>"; }
                    { mode = "n"; key = "<leader>lo"; action = "<CMD>Lspsaga outline<CR>"; }
                    { mode = "n"; key = "<leader>lc"; action = "<CMD>Lspsaga code_action<CR>"; }
                    { mode = "n"; key = "<leader>ldj"; action = "<CMD>Lspsaga diagnostic_jump_next<CR>"; }
                    { mode = "n"; key = "<leader>ldk"; action = "<CMD>Lspsaga diagnostic_jump_prev<CR>"; }
                    { mode = "n"; key = "<leader>lx"; action = "<CMD>lua require('lspconfig').basedpyright.setup({settings = { basedpyright = { analysis = { typeCheckingMode = 'off' } } } })<CR>"; }
                ];
            };
            servers = {
                jdtls.enable = true;
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
                ansiblels = {
                    enable = true;
                    filetypes = [
                        "yaml.ansible"
                    ];
                    settings.ansible = {
                        executionEnvironment.enabled = false;
                    };
                };

            };
        };
        lspsaga = {
            enable = true;
        };
    };
    filetype = {
        pattern = {
            ".*inventory" = "yaml.ansible";
            ".*playbook.yml" = "yaml.ansible";
            ".*config.yml" = "yaml.ansible";
        };
    };
}
