{ pkgs, ... }:
{
    plugins = {
        telescope = {
            enable = true;
            keymaps = {
                "<leader>ff" = "find_files";
                "<leader>fg" = "live_grep";
                "<leader>fh" = "help_tags";
                "<leader>fs" = "lsp_document_symbols";
                "<leader>fb" = "buffers";
                "<leader>fk" = "keymaps";
                "<leader>fm" = "toggleterm_manager";
                "<leader>ldf" = "diagnostics";
                "<leader>fn" = "notify";
                "<leader>fq" = "quickfix";
                "<leader>fx" = "manix";
                "<leader>fc" = "command_history";
            };
            extensions.manix.enable = true;
            luaConfig.post = ''
                function set_telescope_layout()
                    local status_ok, telescope = pcall(require, 'telescope')
                    if not status_ok then
                        return 'horizontal'
                    end
                    local layout = ""
                    if vim.o.lines > 100 then
                        return 'vertical'
                    else
                        return 'horizontal'
                    end
                end
                local status_ok, telescope = pcall(require, 'telescope')
                if not status_ok then
                    return
                end
                telescope.setup({
                    defaults = {
                        layout_strategy = set_telescope_layout()
                    }
                })
            '';
        };
    };
}
