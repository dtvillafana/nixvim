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
    end
  '';
}
