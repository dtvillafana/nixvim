{ pkgs, ... }:
{
    extraPlugins = [
        (pkgs.vimUtils.buildVimPlugin {
            name = "window-picker";
            src = pkgs.fetchFromGitHub {
                owner = "s1n7ax";
                repo = "nvim-window-picker";
                rev = "main";
                hash = "sha256-ZavIPpQXLSRpJXJVJZp3N6QWHoTKRvVrFAw7jekNmX4=";
            };
        })
    ];
    extraConfigLua = ''
        require('window-picker').setup()
        function open_path_in_win()
            local path = vim.fn.expand('<cfile>')
            
            if vim.fn.filereadable(path) == 1 then
                -- Check if a buffer for this file already exists
                local existing_buf = vim.fn.bufnr(path)
                local buf
                
                if existing_buf ~= -1 then
                    -- Buffer already exists, use it
                    buf = existing_buf
                else
                    -- Create a new buffer for this file
                    buf = vim.api.nvim_create_buf(true, false)
                    vim.api.nvim_buf_set_name(buf, path)
                    
                    -- Switch to the buffer temporarily to load the file content
                    local current_buf = vim.api.nvim_get_current_buf()
                    vim.api.nvim_set_current_buf(buf)
                    vim.cmd('edit')
                    vim.api.nvim_set_current_buf(current_buf)
                end
                
                -- Let the user pick a window and set the buffer there
                local picked_win = require('window-picker').pick_window({
                    hint = 'floating-big-letter',
                    filter_rules = {
                        -- when there is only one window available to pick from, use that window
                        -- without prompting the user to select
                        autoselect_one = false,

                        -- whether you want to include the window you are currently on to window
                        -- selection or not
                        include_current_win = true
                    }
                })
                if picked_win then
                    vim.api.nvim_win_set_buf(picked_win, buf)
                else
                    print("No window selected")
                end
            else
                print(path .. " is not a valid path")
            end
        end
    '';
    keymaps = [
        { action = "<CMD>lua open_path_in_win()<CR>"; key = "gf"; options = { noremap = true; silent = true; }; }
    ];
}
