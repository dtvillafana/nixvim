{
    plugins = {
        luasnip.enable = true;

        cmp-async-path.enable = true;
        cmp = {
            enable = true;
            autoEnableSources = true;
            settings = {
                snippet.expand = "function(args) require('luasnip').lsp_expand(args.body) end";
                experimental.ghost_text = true;
                menu = {
                    nvim_lsp = "[LSP]";
                    nvim_lua = "[lua]";
                    path = "[path]";
                    luasnip = "[snip]";
                    buffer = "[buffer]";
                };

                mapping = {
                    "<C-d>" = "cmp.mapping.scroll_docs(-4)";
                    "<C-f>" = "cmp.mapping.scroll_docs(4)";
                    "<C-Space>" = "cmp.mapping.complete()";
                    "<C-e>" = "cmp.mapping.close()";
                    "<Tab>" = "cmp.mapping(cmp.mapping.select_next_item(), {'i', 's'})";
                    "<S-Tab>" = "cmp.mapping(cmp.mapping.select_prev_item(), {'i', 's'})";
                    "<CR>" = "cmp.mapping.confirm({ select = true })";
                };

                sources = [
                    { name = "async_path"; }
                    { name = "nvim_lsp"; }
                    { name = "luasnip"; }
                    {
                        name = "buffer";
                        # Words from other open buffers can also be suggested.
                        option.get_bufnrs.__raw = "vim.api.nvim_list_bufs";
                    }
                ];
            };
        };
    };
}

