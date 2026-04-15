{ pkgs, ... }:
{
  plugins = {
    telescope = {
      enable = true;
      keymaps = {
        "<leader>ff" = "find_files";
        "<leader>fg" = "live_grep";
        "<leader>fh" = "help_tags";
        "<leader>fs" = "lsp_document_symbols";
        "<leader>fb" = "buffers";
        "<leader>fk" = "keymaps";
        "<leader>fn" = "notify";
        "<leader>fq" = "quickfix";
        "<leader>fx" = "manix";
        "<leader>fc" = "command_history";
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
      name = "tmux-switch";
      src = pkgs.fetchFromGitHub {
        owner = "jkeresman01";
        repo = "tmux-switch.nvim";
        rev = "main";
        hash = "sha256-GIKsuHnt26vM+/BRsX0d2aHVEOg1PIVNmj/U+UxZqi8=";
      };
      doCheck = false;
    })
  ];
}
