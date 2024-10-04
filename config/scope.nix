{
    plugins = {
        scope = {
            enable = true;
            luaConfig.post = ''
                require('telescope').load_extension('scope')
            '';
        };
    };
    keymaps = [
        { mode = "n"; key = "<leader>fb"; action = "<CMD>Telescope scope buffers<CR>"; options = { noremap = true; silent = true; }; }
    ];
}
