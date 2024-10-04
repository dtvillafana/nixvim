{
    plugins = {
        # lsp-format.enable = true;

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
                nil-ls.enable = true;
                lua-ls.enable = true;
                pylsp.enable = true;
                ansiblels.enable = true;
                bashls.enable = true;
                cmake.enable = true;
                htmx.enable = true;
                html.enable = true;
                jsonls.enable = true;
                lemminx.enable = true;
                tailwindcss.enable = true;
                ts-ls.enable = true;

            };
        };
        lspsaga = {
            enable = true;
        };
    };
}
