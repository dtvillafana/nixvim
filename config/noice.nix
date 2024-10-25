{
    keymaps = [
        # dismiss notifications keymap
        { mode = "n"; key = "<leader>pd"; action = "<CMD>NoiceDismiss<CR>"; options = { noremap = true; silent = true; }; }
    ];

    plugins = {
        notify = {
            enable = true;
            fps = 60;
        };
        noice = {
            enable = true;
            presets = {
                command_palette = true;
            };
        };
    };
}
