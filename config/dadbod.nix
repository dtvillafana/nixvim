{ ... }:
{
  plugins = {
    vim-dadbod = {
      enable = true;
    };
    vim-dadbod-ui = {
      enable = true;
    };
    vim-dadbod-completion = {
      enable = true;
    };
  };
  extraConfigLua = ''
    vim.g.db_ui_use_nerd_fonts = 1
    vim.g.db_ui_show_database_icon = 1
    local dbs = {}
    function urlencode(str)
        if str then
            -- Convert all characters except alphanumeric, '-', '_', '.', '~' to percent encoding
            -- These are the "unreserved characters" in RFC 3986
            str = string.gsub(str, "([^%w%-_%.~])", function(c)
                -- Convert to hex and format as %XX
                return string.format("%%%02X", string.byte(c))
            end)
        end
        return str
    end
    local env_vars = {
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
    {
      action = "<CMD>DBUIToggle<CR>";
      key = "<Space>sq";
      options = {
        noremap = true;
        silent = true;
      };
    }
  ];
}
