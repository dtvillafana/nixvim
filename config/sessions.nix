{ pkgs, ... }:
{
    extraPlugins = [
        (pkgs.vimUtils.buildVimPlugin {
            name = "resession";
            src = pkgs.fetchFromGitHub {
                owner = "stevearc";
                repo = "resession.nvim";
                rev = "master";
                hash = "sha256-S5mN/1yzUjV76YTYB41aaTL1xuGEfTN2LpEsc28RhDM=";
            };
        })
    ];
    extraConfigLua = ''
    local resession = require("resession")
    resession.setup({
        autosave = {
            enabled = true,
            interval = 60,
            notify = false,
        },
        tab_buf_filter = function(tabpage, bufnr)
            local dir = vim.fn.getcwd(-1, vim.api.nvim_tabpage_get_number(tabpage))
            -- ensure dir has trailing /
            dir = dir:sub(-1) ~= "/" and dir .. "/" or dir
            return vim.startswith(vim.api.nvim_buf_get_name(bufnr), dir)
        end,
        extensions = { scope = {} }, -- add scope.nvim extension
    })
    vim.api.nvim_create_autocmd("VimLeavePre", {
        callback = function()
            -- Always save a special session named "last"
            resession.save("last")
        end,
    })
    -- keymaps
    vim.keymap.set("n", "<leader>ss", resession.save_tab)
    vim.keymap.set("n", "<leader>sl", resession.load)
    vim.keymap.set("n", "<leader>sd", resession.delete)
    '';
}
