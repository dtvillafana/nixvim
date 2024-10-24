{ system, ... }:
{
    plugins = {
        direnv.enable = true;
        lsp = {
            enable = true;

            keymaps = {
                silent = true;
                diagnostic = {
                    # Navigate in diagnostics
                    "<leader>k" = "goto_prev";
                    "<leader>j" = "goto_next";
                };

                extra = [
                    { mode = "n"; key = "<leader>lr"; action = "<CMD>Lspsaga rename<CR>"; }
                    { mode = "n"; key = "<leader>lg"; action = "<CMD>Lspsaga goto_definition<CR>"; }
                    { mode = "n"; key = "<leader>lp"; action = "<CMD>Lspsaga peek_definition<CR>"; }
                    { mode = "n"; key = "<leader>lh"; action = "<CMD>Lspsaga hover_doc<CR>"; }
                    { mode = "n"; key = "<leader>lt"; action = "<CMD>Lspsaga goto_type_definition<CR>"; }
                    { mode = "n"; key = "<leader>lo"; action = "<CMD>Lspsaga outline<CR>"; }
                    { mode = "n"; key = "<leader>lc"; action = "<CMD>Lspsaga code_action<CR>"; }
                    { mode = "n"; key = "<leader>lx"; action = "<CMD>lua require('lspconfig').basedpyright.setup({settings = { basedpyright = { analysis = { typeCheckingMode = 'off' } } } })<CR>"; }
                ];
            };
            servers = {
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
                bashls.enable = true;
                cmake.enable = true;
                htmx.enable = true;
                html.enable = true;
                jsonls.enable = true;
                lemminx.enable = true;
                tailwindcss.enable = true;
                ts_ls.enable = true;
                ansiblels = {
                    enable = true;
                    filetypes = [
                        "yaml.ansible"
                    ];
                    settings.ansible = {
                        validation.enabled = false;
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
