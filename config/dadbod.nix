{ pkgs, ... }:
{
    extraPlugins = with pkgs.vimPlugins; [
        vim-dadbod
        vim-dadbod-ui
        vim-dadbod-completion
    ];
    extraConfigLua = ''
        vim.g.db_ui_use_nerd_fonts = 1
        vim.g.db_ui_show_database_icon = 1
        local dbs = {}
        local env_vars = {
            {
                env_var = os.getenv('sql3_pw'),
                key = 'fics-test',
                value_func = function(var)
                    -- to make sql server work you might have to URL encode special characters and/or add some parameters to the end of your connection string:
                    return 'sqlserver://fics:'
                        .. var
                        .. '@172.20.102.60:1433/fics_test?Encrypt=1;trustServerCertificate=1'
                end,
            },
            {
                env_var = os.getenv('HOME'),
                key = 'politics',
                value_func = function(var)
                    return 'sqlite://' .. var .. '/Sync/datasets/politics.db'
                end,
            },
        }

        for _, item in ipairs(env_vars) do
            if item.env_var ~= nil then
                dbs = vim.tbl_deep_extend('force', dbs, {
                    [item.key] = item.value_func(item.env_var),
                })
            end
        end
        vim.g.dbs = dbs
        vim.g.db_ui_use_nvim_notify = 0

        -- enable completion using cmp, I tried to make the autocmd fire on FileType but that just doesn't work
        vim.api.nvim_create_autocmd('BufEnter', {
            pattern = { '*.sql', '*.tsql', '*.plsql', '*-query-*' },
            callback = function()
                require('cmp').setup.buffer({ sources = { { name = 'vim-dadbod-completion' } } })
            end,
        })
    '';
    keymaps = [
        { action = "<CMD>DBUIToggle<CR>"; key = "<Space>sq"; options = { noremap = true; silent = true; }; }
    ];
}

