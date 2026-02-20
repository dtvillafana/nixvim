{
  plugins = {
    grug-far = {
      enable = true;
    };
  };

  keymaps = [
    {
      mode = "n";
      key = "<leader>gr";
      action = "<CMD>lua require('grug-far').open({ prefills = { search = vim.fn.expand('<cword>') } })<CR>";
      options = {
        noremap = true;
        silent = true;
        desc = "grug-far: Search current word";
      };
    }
    {
      mode = "n";
      key = "<leader>g";
      action.__raw = ''
        function()
          local width = math.floor(vim.o.columns * 0.8)
          local height = math.floor(vim.o.lines * 0.8)
          require('grug-far').toggle_instance({
            instanceName = 'far',
            staticTitle = 'Find and Replace',
            windowCreationCommand = 'lua vim.api.nvim_open_win(0, true, { relative = "editor", width = ' .. width .. ', height = ' .. height .. ', row = math.floor((vim.o.lines - ' .. height .. ') / 2), col = math.floor((vim.o.columns - ' .. width .. ') / 2), style = "minimal", border = "rounded" })',
          })
        end
      '';
      options = {
        noremap = true;
        silent = true;
        desc = "grug-far: Toggle instance";
      };
    }
    {
      mode = "x";
      key = "<leader>r";
      action.__raw = ''
        function()
          require('grug-far').open({
            prefills = {
              paths = vim.fn.expand('%'),
            },
          })
        end
      '';
      options = {
        noremap = true;
        silent = true;
        desc = "grug-far: Search visual selection in current file";
      };
    }
    {
      mode = [
        "n"
        "x"
      ];
      key = "<leader>gi";
      action = "<CMD>lua require('grug-far').open({ visualSelectionUsage = 'operate-within-range' })<CR>";
      options = {
        noremap = true;
        silent = true;
        desc = "grug-far: Search within range";
      };
    }
  ];

  autoCmd = [
    {
      event = "FileType";
      pattern = [ "grug-far" ];
      callback = {
        __raw = ''
          function()
            vim.keymap.set('n', '<localleader>w', function()
              local state = unpack(require('grug-far').get_instance(0):toggle_flags({ '--fixed-strings' }))
              vim.notify('grug-far: toggled --fixed-strings ' .. (state and 'ON' or 'OFF'))
            end, { buffer = true, desc = 'grug-far: Toggle --fixed-strings' })

            vim.keymap.set('n', '<C-enter>', function()
              require('grug-far').get_instance(0):open_location()
              require('grug-far').get_instance(0):close()
            end, { buffer = true, desc = 'grug-far: Open location and close' })

            vim.keymap.set('n', '<left>', function()
              require('grug-far').get_instance(0):goto_first_input()
            end, { buffer = true, desc = 'grug-far: Jump to first input' })
          end
        '';
      };
    }
  ];
}
