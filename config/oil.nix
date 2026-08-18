{ pkgs, ... }:
{
  plugins = {
    oil = {
      package = pkgs.vimUtils.buildVimPlugin {
        name = "oil.nvim";
        src = pkgs.fetchFromGitHub {
          owner = "dtvillafana";
          repo = "oil.nvim";
          rev = "master";
          hash = "sha256-3W8uPPLKVnVfVFB06i1FMmhDVxd5v+hCiPu9ZOnogzg=";
        };
      };
      enable = true;
      settings = {
        view_options.show_hidden = true;
        delete_to_trash = true;
        keymaps = {
          "<CR>" = {
            callback = {
              __raw = ''
                function()
                  local oil = require('oil')
                  local entry = oil.get_cursor_entry()

                  if entry and entry.type == 'file' then
                    local dir = oil.get_current_dir()
                    if dir then
                      vim.system({ 'zoxide', 'add', dir }, { detach = true })
                    end
                  end

                  oil.select()
                end
              '';
            };
            desc = "oil: Select entry and record file directory";
          };
          gs = {
            callback = {
              __raw = ''
                function()
                  local oil = require('oil')
                  local prefills = { paths = oil.get_current_dir() }
                  local grug_far = require('grug-far')

                  if not grug_far.has_instance('explorer') then
                    grug_far.open({
                      instanceName = 'explorer',
                      prefills = prefills,
                      staticTitle = 'Find and Replace from Explorer',
                    })
                  else
                    grug_far.get_instance('explorer'):open()
                    grug_far.get_instance('explorer'):update_input_values(prefills, false)
                  end
                end
              '';
            };
            desc = "oil: Search in directory";
          };
          ";" = {
            callback = {
              __raw = ''
                function()
                  local sorts = {
                    { label = 'modified date', column = 'mtime', order = 'desc' },
                    { label = 'name', column = 'name', order = 'asc' },
                    { label = 'size', column = 'size', order = 'desc' },
                    { label = 'access date', column = 'atime', order = 'desc' },
                    { label = 'change date', column = 'ctime', order = 'desc' },
                    { label = 'birth date', column = 'birthtime', order = 'desc' },
                  }
                  local index = (vim.b.oil_sort_index or 0) % #sorts + 1
                  local sort = sorts[index]

                  vim.b.oil_sort_index = index
                  require('oil').set_sort({
                    { 'type', 'asc' },
                    { sort.column, sort.order },
                  })
                  vim.notify('Oil sorted by ' .. sort.label)
                end
              '';
            };
            desc = "oil: Cycle sort order";
          };
        };
      };
    };
  };
  keymaps = [
    {
      action = "<CMD>Oil --float<CR>";
      key = "<Space>e";
      options = {
        noremap = true;
        silent = true;
      };
    }
  ];
}
