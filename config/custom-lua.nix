{
  extraConfigLua = ''

    -- Detect if we're running in WSL
    local is_wsl = vim.loop.os_uname().release:match("microsoft")

    if is_wsl then
        vim.g.clipboard = {
          name = 'OSC 52',
          copy = {
            ['+'] = require('vim.ui.clipboard.osc52').copy('+'),
            ['*'] = require('vim.ui.clipboard.osc52').copy('*'),
          },
          paste = {
            ['+'] = require('vim.ui.clipboard.osc52').paste('+'),
            ['*'] = require('vim.ui.clipboard.osc52').paste('*'),
          },
        }
        -- Override `vim.ui.open` to simulate Windows behavior
        vim.ui.open = function(uri)
            -- Use `wslview` (or a similar tool) to open links in the Windows browser
            vim.fn.system({ "wslview", uri })
        end

        -- Open a toggleterm float terminal with PowerShell
        vim.keymap.set("n", "<leader>to", function()
            local Terminal = require("toggleterm.terminal").Terminal
            local powershell = Terminal:new({
                cmd = "/mnt/c/Windows/System32/WindowsPowerShell/v1.0/powershell.exe",
                direction = "float",
                hidden = true,
            })
            powershell:toggle()
        end, { desc = "Open PowerShell float terminal" })

        -- Fix snacks image rendering in tmux+wezterm (WSL) with Oil float.
        -- Two issues:
        -- 1. Oil float (zindex=45) causes snacks' z-index filter to exclude the image
        --    window from state.wins, so render_fallback never runs and the image lands
        --    at cursor (1,1) via the default a=T transmission placement.
        -- 2. render_fallback sends cursor-move and image-place as separate DCS
        --    passthroughs; tmux may refresh between them, resetting the cursor.
        -- VimEnter is used (not User VeryLazy) because nixvim doesn't use lazy.nvim.
        vim.api.nvim_create_autocmd("VimEnter", {
            once = true,
            callback = function()
                local ok, placement = pcall(require, "snacks.image.placement")
                if ok then
                    local orig_state = placement.state
                    placement.state = function(self)
                        local state = orig_state(self)
                        if #state.wins == 0 then
                            state.wins = self:wins()
                        end
                        return state
                    end
                end

                local tok, terminal = pcall(require, "snacks.image.terminal")
                if tok then
                    local pending_cursor = nil
                    local orig_write = terminal.write
                    terminal.set_cursor = function(pos)
                        pending_cursor = "\27[" .. pos[1] .. ";" .. (pos[2] + 1) .. "H"
                    end
                    terminal.write = function(data)
                        if pending_cursor then
                            data = pending_cursor .. data
                            pending_cursor = nil
                        end
                        orig_write(data)
                    end
                end
            end,
        })
    end
  '';
}
