{ fyler, pkgs, ... }:
{
  plugins.mini-icons.enable = true;
  plugins.web-devicons.enable = true;

  extraPlugins = [
    (pkgs.vimUtils.buildVimPlugin {
      name = "fyler.nvim";
      src = fyler;
      doCheck = false;
    })
  ];

  extraConfigLua = ''
    require('fyler.extensions').register({
      name = 'fit_split_width',
      setup = function(opts, config)
        config.extensions.fit_split_width = vim.tbl_deep_extend('force', { enabled = true }, opts)
      end,
      hooks = {
        finder_refresh_post = function(instance, _, _, lines)
          if not require('fyler.config').DATA.extensions.fit_split_width.enabled then return end
          if instance.opts.kind ~= 'split_left_most' or not vim.api.nvim_win_is_valid(instance.win_id) then return end

          local text_width = 0
          for _, line in ipairs(lines) do
            -- Fyler conceals its internal entry IDs, so exclude them from the displayed width.
            text_width = math.max(text_width, vim.fn.strdisplaywidth((line:gsub('/%d+ ', ""))))
          end

          local wininfo = vim.fn.getwininfo(instance.win_id)[1]
          local textoff = wininfo and wininfo.textoff or 0
          pcall(vim.api.nvim_win_set_width, instance.win_id, text_width + textoff)
        end,
      },
    })

    require('fyler').setup({
      integrations = {
        icon = 'mini_icons',
        window_picker = function()
          return require('window-picker').pick_window({
            hint = 'floating-big-letter',
            filter_rules = {
              autoselect_one = false,
              include_current_win = true,
            },
          })
        end,
      },
      extensions = {
        git = { enabled = true },
        trash = { enabled = true },
        watcher = { enabled = true },
        fit_split_width = { enabled = true },
      },
      mappings = {
        n = {
          ['<CR>'] = {
            action = 'select',
            args = { pick = true },
          },
          ['-'] = {
            action = 'visit',
            args = { parent = true },
          },
          ['<C-l>'] = {
            action = 'visit',
            args = { cursor = true },
          },
        },
      },
    })
  '';

  keymaps = [
    {
      mode = "n";
      key = "<leader>v";
      action = "<CMD>lua require('fyler').open({ kind = 'split_left_most' })<CR>";
      options = {
        noremap = true;
        silent = true;
        desc = "Open Fyler split";
      };
    }
  ];
}
