{
    plugins = {
        treesitter = {
            enable = true;
            settings = {
                highlight = {
                    additional_vim_regex_highlighting = [ "csv" ];
                    enable = true;
                    disable = ''function(lang, buf)
                local max_filesize = 1000 * 1024
                local ok, stats = pcall(vim.loop.fs_stat, vim.api.nvim_buf_get_name(buf))
                if ok and stats and stats.size > max_filesize then
                    return true
                end
            end'';
                };
                incremental_selection = {
                    enable = true;
                    keymaps = {
                        init_selection = " si";
                        node_incremental = " sn";
                        node_decremental = " sN";
                        scope_incremental = " ss";
                    };
                };
                indent = {
                    enable = true;
                };
            };
        };
    };
}
