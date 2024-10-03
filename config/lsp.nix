{
    plugins = {
        lsp-format.enable = true;

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
                    { mode = "n"; key = "<leader>ldv"; action = "<CMD>Lspsaga show_buf_diagnostics<CR>"; }
                ];
            };

            servers = {
                rnix-lsp.enable = true;
                pylsp.enable = true;
            };
        };
        lspsaga = {
            enable = true;

        };
    };
}
