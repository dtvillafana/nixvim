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
    require('fyler').setup({
      integrations = {
        icon = 'mini_icons',
      },
      extensions = {
        git = { enabled = true },
        trash = { enabled = true },
        watcher = { enabled = true },
      },
      mappings = {
        n = {
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
      action = "<CMD>Fyler<CR>";
      options = {
        noremap = true;
        silent = true;
        desc = "Open Fyler";
      };
    }
  ];
}
