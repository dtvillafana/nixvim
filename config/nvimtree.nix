{
    keymaps = [
        # file tree
        { mode = "n"; key = "<leader>v"; action = "<CMD>NvimTreeToggle<CR>"; options = { noremap = true; silent = true; }; }
    ];

    plugins = {
        web-devicons.enable = true;
        nvim-tree.enable = true;
    };
}
