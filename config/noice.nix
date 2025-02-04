{
    keymaps = [
        # dismiss notifications keymap
        { mode = "n"; key = "<leader>pd"; action = "<CMD>NoiceDismiss<CR>"; options = { noremap = true; silent = true; }; }
    ];

    plugins = {
        notify = {
            enable = true;
            settings.fps = 60;
        };
        noice = {
            enable = true;
            settings.presets = {
                command_palette = true;
            };
        };
    };
}
