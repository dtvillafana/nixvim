{
  plugins = {
    oil = {
      enable = true;
      settings = {
        view_options.show_hidden = true;
        delete_to_trash = true;
        keymaps = {
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
