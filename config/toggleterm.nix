{
    plugins = {
        toggleterm = {
            enable = true;
            settings = {
                size = ''function(term)
                            if term.direction == 'vertical' then
                                return vim.o.columns * 0.4
                            elseif term.direction == 'horizontal' then
                                local cur_win = vim.api.nvim_get_current_win()
                                local height = vim.api.nvim_win_get_height(cur_win)
                                return height * 0.3
                            end
                        end'';
                hide_numbers = true;
                shade_terminals = true;
                shading_factor = 2;
                start_in_insert = true;
                insert_mappings = true;
                persist_size = true;
                close_on_exit = true;
                float_opts = {
                    border = "curved";
                    winblend = 0;
                    highlights = {
                        border = "Normal";
                        background = "Normal";
                    };
                };

            };
        };
    };
}
