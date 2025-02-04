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
                "<leader>ldf" = "diagnostics";
                "<leader>fn" = "notify";
                "<leader>fq" = "quickfix";
                "<leader>fx" = "manix";
                "<leader>fc" = "command_history";
                "<leader>/" = "current_buffer_fuzzy_find";
            };
            extensions.manix.enable = true;
            luaConfig.post = ''
                function GET_TELESCOPE_LAYOUT()
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

                vim.api.nvim_create_autocmd("VimResized", {
                  callback = function()
                    local status_ok, telescope = pcall(require, 'telescope')
                    if status_ok then
                        telescope.setup({
                            defaults = {
                                layout_strategy = GET_TELESCOPE_LAYOUT()
                            }
                        })
                    end
                  end
                })

                local status_ok, telescope = pcall(require, 'telescope')
                if status_ok then
                    telescope.setup({
                        defaults = {
                            layout_strategy = GET_TELESCOPE_LAYOUT()
                        }
                    })
                end
            '';
        };
    };
}
