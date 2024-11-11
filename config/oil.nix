{
    plugins = {
        oil = {
            enable = true;
            settings.view_options.show_hidden = true;
        };
    };
    keymaps = [
        { action = "<CMD>Oil --float<CR>"; key = "<Space>e"; options = { noremap = true; silent = true; }; }
    ];
}
