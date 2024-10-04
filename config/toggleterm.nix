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
    keymaps = [
        {
            mode = "n";
            key = "<leader>tf";
            action = ''<CMD>lua require('toggleterm.terminal').Terminal:new({ hidden = true, direction = 'float', id = vim.v.count, display_name = 'Terminal ' .. vim.v.count, }):toggle()<CR>'';
            options = { noremap = true; silent = true; };
        }
        {
            mode = "n";
            key = "<leader>tv";
            action = ''<CMD>lua require('toggleterm.terminal').Terminal:new({ hidden = true, direction = 'vertical', id = vim.v.count + 10, display_name = 'Terminal ' .. vim.v.count, }):toggle()<CR>'';
            options = { noremap = true; silent = true; };
        }
        {
            mode = "n";
            key = "<leader>th";
            action = ''<CMD>lua require('toggleterm.terminal').Terminal:new({ hidden = true, direction = 'horizontal', id = vim.v.count + 20, display_name = 'Terminal ' .. vim.v.count, }):toggle()<CR>'';
            options = { noremap = true; silent = true; };
        }
        {
            mode = "n";
            key = "<leader>tt";
            action = ''<CMD>lua require('toggleterm.terminal').Terminal:new({ hidden = true, direction = 'tab', id = vim.v.count + 30, display_name = 'Terminal ' .. vim.v.count, }):toggle()<CR>'';
            options = { noremap = true; silent = true; };
        }
        {
            mode = "n";
            key = "<leader>tl";
            action = ''<CMD>lua local current_buf = vim.api.nvim_get_current_buf(); local filepath = vim.api.nvim_buf_get_name(current_buf); local directory = vim.fn.fnamemodify(filepath, ':h'); require('toggleterm.terminal').Terminal:new({ cmd = 'lazygit', hidden = true, close_on_exit = true, direction = 'float', dir = directory, display_name = 'lazygit', }):toggle()<CR>'';
            options = { noremap = true; silent = true; };
        }
        {
            mode = "n";
            key = "<leader>tb";
            action = ''<CMD>lua require('toggleterm.terminal').Terminal:new({ cmd = 'bpytop', hidden = true, close_on_exit = true, direction = 'float', display_name = 'bpytop' }):toggle()<CR>'';
            options = { noremap = true; silent = true; };
        }
        {
            mode = "n";
            key = "<leader>tj";
            action = ''<CMD>lua require('toggleterm.terminal').Terminal:new({ cmd = 'nodejs', hidden = true, close_on_exit = true, direction = 'float', display_name = 'nodejs' }):toggle()<CR>'';
            options = { noremap = true; silent = true; };
        }
    ];
    autoCmd = [
        {
            command = ''lua 
            local opts = { noremap = true }
            vim.api.nvim_buf_set_keymap(0, 't', '<leader><esc>', [[<C-\><C-n>]], opts)
            vim.api.nvim_buf_set_keymap(0, 't', '<leader>q', [[<C-\><C-n>:q<CR>]], opts)
            vim.api.nvim_buf_set_keymap(0, 't', '<C-h>', [[<C-\><C-n><C-W>h]], opts)
            vim.api.nvim_buf_set_keymap(0, 't', '<C-j>', [[<C-\><C-n><C-W>j]], opts)
            vim.api.nvim_buf_set_keymap(0, 't', '<C-k>', [[<C-\><C-n><C-W>k]], opts)
            vim.api.nvim_buf_set_keymap(0, 't', '<C-l>', [[<C-\><C-n><C-W>l]], opts)
            '';
            event = [ "TermOpen" ];
            pattern = [ "term://*" ];
        }
    ];
}
