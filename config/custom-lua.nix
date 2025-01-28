{
    extraConfigLua = ''
        -- Detect if we're running in WSL
        local is_wsl = vim.loop.os_uname().release:match("microsoft")
        
        if is_wsl then
            -- Override `vim.ui.open` to simulate Windows behavior
            vim.ui.open = function(uri)
                -- Use `wslview` (or a similar tool) to open links in the Windows browser
                vim.fn.system({ "wslview", uri })
            end
        end
    '';
}
