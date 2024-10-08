{
    plugins = {
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
                    { mode = "n"; key = "<leader>l"; action = "<CMD>Lspsaga code_action<CR>"; }
                ];
            };

            servers = {
                nil-ls.enable = true;
                lua-ls = {
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
                pylsp.enable = true;
                bashls.enable = true;
                cmake.enable = true;
                htmx.enable = true;
                html.enable = true;
                jsonls.enable = true;
                lemminx.enable = true;
                tailwindcss.enable = true;
                ts-ls.enable = true;
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
