{ pkgs, ... }:
{
  plugins = {
    fzf-lua = {
      enable = true;
      keymaps."<leader>fd" = {
        action = "zoxide";
        settings.actions.enter.__raw = ''
          function(selected)
            require('oil').open(selected[1]:match('[^\t]+$'))
          end
        '';
        options.desc = "Find frecent directories";
      };
    };
    telescope = {
      enable = true;
      keymaps = {
        "<leader>fg" = "live_grep";
        "<leader>fh" = "help_tags";
        "<leader>fs" = "lsp_document_symbols";
        "<leader>fb" = "buffers";
        "<leader>fk" = "keymaps";
        "<leader>fn" = "notify";
        "<leader>fq" = "quickfix";
        "<leader>fx" = "manix";
        "<leader>fc" = "command_history";
        "<leader>fp" = "neoclip";
        "<leader>/" = "current_buffer_fuzzy_find";
      };
      settings = {
        defaults = {
          vimgrep_arguments = [
            "rg"
            "--color=never"
            "--no-heading"
            "--with-filename"
            "--line-number"
            "--column"
            "--smart-case"
          ];
        };
        pickers.find_files.follow = true;
      };
      extensions = {
        manix.enable = true;
        zf-native.enable = true;
      };
      luaConfig.post = ''
        function GET_TELESCOPE_LAYOUT()
            local status_ok, telescope = pcall(require, 'telescope')
            if not status_ok then
                return 'horizontal'
            end
            local layout = ""
            if vim.o.lines > 100 then
                return 'vertical'
            else
                return 'horizontal'
            end
        end

        vim.api.nvim_create_autocmd("VimResized", {
          callback = function()
            local status_ok, telescope = pcall(require, 'telescope')
            if status_ok then
                telescope.setup({
                    defaults = {
                        layout_strategy = GET_TELESCOPE_LAYOUT()
                    }
                })
            end
          end
        })

        local status_ok, telescope = pcall(require, 'telescope')
        if status_ok then
            local _picker_hidden = {}

            local function toggle_rg_hidden(prompt_bufnr)
                local action_state = require('telescope.actions.state')
                local actions = require('telescope.actions')
                local builtin = require('telescope.builtin')
                local picker = action_state.get_current_picker(prompt_bufnr)
                local title = picker.prompt_title
                local prompt = picker:_get_prompt()
                local cwd = picker.cwd

                _picker_hidden[title] = not (_picker_hidden[title] or false)
                local hidden = _picker_hidden[title]

                actions.close(prompt_bufnr)

                vim.schedule(function()
                    if title == "Find Files" then
                        builtin.find_files({
                            hidden = hidden,
                            default_text = prompt,
                            cwd = cwd,
                        })
                    elseif title:match("[Gg]rep") then
                        builtin.live_grep({
                            additional_args = hidden and { "--hidden" } or {},
                            default_text = prompt,
                            cwd = cwd,
                        })
                    else
                        vim.notify("telescope: don't know how to toggle hidden for picker: " .. title)
                    end
                end)
            end

             telescope.setup({
                 defaults = {
                     layout_strategy = GET_TELESCOPE_LAYOUT(),
                    mappings = {
                        i = { ["<A-h>"] = toggle_rg_hidden },
                        n = { ["<A-h>"] = toggle_rg_hidden },
                     },
                 }
             })

         end
      '';
      enabledExtensions = [
      ];
    };
  };
  extraPlugins = [
    (pkgs.vimUtils.buildVimPlugin {
      name = "fzf-oil.nvim";
      src = pkgs.fetchFromGitHub {
        owner = "ingur";
        repo = "fzf-oil.nvim";
        rev = "f49a44658c3ae6243b88b20db5767657d29dd5cc";
        hash = "sha256-kOMh4gmfnK0drx8OxzMZDrjRyTUrDQiqMK+Vp2d1ZAs=";
      };
    })
    (pkgs.vimUtils.buildVimPlugin {
      name = "nvim-neoclip";
      src = pkgs.fetchFromGitHub {
        owner = "AckslD";
        repo = "nvim-neoclip.lua";
        rev = "master";
        hash = "sha256-IjkpqLHGO48QRiYkELyadZK2uFXQVyklGfBJSgAbzIY=";
      };
      doCheck = false;
    })
  ];
  extraConfigLua = ''
    local fzf_oil_hidden = false
    local fzf_oil
    local fzf_oil_keys = {
      parent = '-',
      child = '<C-l>',
      down = '<C-j>',
      up = '<C-k>',
      toggle_find = '<C-f>',
      edit = '<C-e>',
      home = '<C-g>',
      back = '<C-o>',
      quit = 'q',
    }
    fzf_oil = require('fzf-oil').setup({
      cmd = 'fd --max-depth 3 --exclude .git --type f --type d --type l',
      find_cmd = 'fd --exclude .git --type f --type l',
      keys = fzf_oil_keys,
      fzf_exec_opts = {
        actions = {
          ['alt-h'] = {
            fn = function()
              fzf_oil_hidden = not fzf_oil_hidden
              local hidden = fzf_oil_hidden and ' --hidden' or ""
              fzf_oil.cmd = 'fd --max-depth 1' .. hidden .. ' --exclude .git --type f --type d --type l'
              fzf_oil.find_cmd = 'fd' .. hidden .. ' --exclude .git --type f --type l'
            end,
            reload = true,
            postfix = 'clear-query',
          },
        },
      },
    })
    vim.keymap.set('n', '<leader>ff', function()
      fzf_oil.browse(nil, true)
    end, { desc = 'Browse files recursively' })

    require('neoclip').setup({
      history = 1000,
      enable_persistent_history = false,
      length_limit = 1048576,
      continuous_sync = false,
      db_path = vim.fn.stdpath("data") .. "/databases/neoclip.sqlite3",
      filter = nil,
      preview = true,
      prompt = nil,
      default_register = '"',
      default_register_macros = 'q',
      enable_macro_history = true,
      content_spec_column = false,
      disable_keycodes_parsing = false,
      dedent_picker_display = false,
      initial_mode = 'insert',
      on_select = {
    	move_to_front = false,
    	close_telescope = true,
      },
      on_paste = {
    	set_reg = false,
    	move_to_front = false,
    	close_telescope = true,
      },
      on_replay = {
    	set_reg = false,
    	move_to_front = false,
    	close_telescope = true,
      },
      on_custom_action = {
    	close_telescope = true,
      },
      keys = {
    	telescope = {
    	  i = {
    		select = '<cr>',
    		paste = '<c-p>',
    		paste_behind = '<c-k>',
    		replay = '<c-q>',  -- replay a macro
    		delete = '<c-d>',  -- delete an entry
    		edit = '<c-e>',  -- edit an entry
    		custom = {},
    	  },
    	  n = {
    		select = '<cr>',
    		paste = 'p',
    		--- It is possible to map to more than one key.
    		-- paste = { 'p', '<c-p>' },
    		paste_behind = 'P',
    		replay = 'q',
    		delete = 'd',
    		edit = 'e',
    		custom = {},
    	  },
    	},
    	fzf = {
    	  select = 'default',
    	  paste = 'ctrl-p',
    	  paste_behind = 'ctrl-k',
    	  custom = {},
    	},
      },
    })

  '';
}
