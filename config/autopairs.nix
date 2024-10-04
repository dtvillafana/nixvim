{
    plugins = {
        nvim-autopairs = {
            enable = true;
            settings = {

                check_ts = true;
                ts_config = {
                    lua = [
                        "string"
                        "source"
                    ];
                    javascript = [
                        "string"
                        "template_string"
                    ];
                    java = false;
                };
                disable_filetype = [
                    "TelescopePrompt"
                    "spectre_panel"
                ];
                fast_wrap = {
                    map = "<M-e>"; # hit alt (Meta) + e to put the closing pair where you want
                    chars = [
                        "{"
                        "["
                        "("
                        "\""
                        "'"
                        "`"
                    ]; # add opening char here for autopairs
                    offset = 0; # Offset from pattern match
                    end_key = "$";
                    keys = "qwertyuiopzxcvbnmasdfghjkl";
                    check_comma = true;
                    highlight = "PmenuSel";
                    highlight_grey = "LineNr";
                };
            };
        };
    };
}
