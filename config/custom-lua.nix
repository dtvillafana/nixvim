{
  extraConfigLua = ''
    -- Refresh treesitter folds after buffer load (parser attaches asynchronously)
    vim.api.nvim_create_autocmd("BufReadPost", {
      callback = function(args)
        vim.schedule(function()
          local ok = pcall(vim.treesitter.get_parser, args.buf)
          if ok then
            vim.cmd("normal! zx")
          end
        end)
      end,
    })

    -- Detect if we're running in WSL
    local is_wsl = vim.loop.os_uname().release:match("microsoft")

    if is_wsl then
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
