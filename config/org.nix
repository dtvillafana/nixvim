{
  pkgs,
  lib,
  orgPath,
  ...
}:
if orgPath == null then
  { }
else
  {
    extraPackages = with pkgs; [
      (texlive.withPackages (
        p: with p; [
          hyphenat
          latex
          latex-bin
          latexmk
          scheme-medium
        ]
      ))
    ];
    plugins = {
      orgmode = {
        enable = true;
        settings = {
          # Limit scope to specific directories or files for better performance
          # Consider changing this to only include frequently used directories
          org_agenda_files = "${orgPath}**/*";
          org_default_notes_file = "${orgPath}refile.org";
          org_hide_emphasis_markers = true;
          org_priority_default = "B";
          org_priority_lowest = "G";
          org_priority_highest = "A";
          org_todo_keywords = [
            "TODO(t)"
            "MEET(m)"
            "CALL(c)"
            "EVENT(e)"
            "WAITING(w)"
            "|"
            "DONE(d)"
            "CANCELED(a)"
          ];
          org_agenda_skip_deadline_if_done = true;
          org_agenda_skip_scheduled_if_done = true;
          org_custom_exports = {
            f = {
              label = "Export to standalone PDF";
              action = lib.generators.mkLuaInline ''
                function(exporter)
                    local current_file = vim.api.nvim_buf_get_name(0)
                    local target = vim.fn.fnamemodify(current_file, ':p:r') .. '.pdf'
                    local command = 'cd ' ..  ' $(realpath $(dirname ' .. tostring(current_file) .. ')) ' ..  ' &&' ..  ' pandoc ' ..  current_file ..  ' -o ' ..  target ..  ' --standalone'
                    local on_success = function(output)
                        print('Success! exported to ' .. target)
                        vim.api.nvim_echo({ { table.concat(output, '\n') } }, true, {})
                    end
                    local on_error = function(err)
                        print('Error!')
                        vim.api.nvim_echo({ { table.concat(err, '\n'), 'ErrorMsg' } }, true, {})
                    end
                    return exporter(command, target, on_success, on_error)
                end
              '';
            };
          };
          org_capture_templates = {
            t = {
              description = "Task";
              template = "* TODO %?\n  %u";
            };
            c = {
              description = "Quick Calendar Reminder";
              template = "* TODO %?\n  SCHEDULED: %T";
            };
          };
          mappings = {
            org = {
              org_timestamp_up_day = "<C-=>";
              org_timestamp_down_day = "<C#>";
              org_refile = false;
            };
            agenda = {
              org_agenda_later = "f";
              org_agenda_earlier = "b";
              org_agenda_goto_today = ".";
            };
          };
          notifications = {
            enabled = true;
            cron_enabled = false;
            repeater_reminder_time = [
              1
              5
              15
            ];
            deadline_warning_reminder_time = [
              1
              5
              15
              30
              60
            ];
            reminder_time = [
              1
              5
              15
              30
            ];
            deadline_reminder = true;
            scheduled_reminder = true;
            # Improved async notifier that won't block UI
            notifier = ''
              function(tasks)
                  -- Process small batches of tasks to avoid UI freezes
                  local function process_tasks_batch(all_tasks, start_idx, batch_size)
                      local result = {}
                      local end_idx = math.min(start_idx + batch_size - 1, #all_tasks)

                      for i = start_idx, end_idx do
                          local task = all_tasks[i]
                          require('orgmode.utils').concat(result, {
                              string.format('# %s (%s)', task.category, task.humanized_duration),
                              string.format('%s %s %s', string.rep('*', task.level), task.todo, task.title),
                              string.format('%s: <%s>', task.type, task.time:to_string()),
                          })
                      end

                      local msg = table.concat(result, '\n')
                      if msg ~= "" then
                          require('noice').notify(msg, 'info', {
                              title = 'OrgNotify ' .. start_idx .. '-' .. end_idx,
                              on_open = function(win)
                                  local buf_id = vim.api.nvim_win_get_buf(win)
                                  vim.api.nvim_set_option_value('filetype', 'org', { buf = buf_id })
                              end,
                          })
                      end

                      -- Schedule next batch if there are more tasks
                      if end_idx < #all_tasks then
                          vim.defer_fn(function()
                              process_tasks_batch(all_tasks, end_idx + 1, batch_size)
                          end, 10) -- 10ms delay between batches
                      end
                  end

                  -- Start processing in batches
                  if #tasks > 0 then
                      vim.defer_fn(function()
                          process_tasks_batch(tasks, 1, 5) -- Process 5 tasks at a time
                      end, 0)
                  end
              end,
            '';
            cron_notifier = null;
          };
        };
      };
    };

    extraPlugins = [
      # (pkgs.vimUtils.buildVimPlugin {
      #   name = "org-roam";
      #   src = pkgs.fetchFromGitHub {
      #     owner = "chipsenkbeil";
      #     repo = "org-roam.nvim";
      #     rev = "master";
      #     hash = "sha256-k/odVuPx6YdX8Cc+DZmVgo3M+NTpKQbFgSMtDe+UwUE=";
      #   };
      #   doCheck = false;
      # })
      (pkgs.vimUtils.buildVimPlugin {
        name = "telescope-orgmode";
        src = pkgs.fetchFromGitHub {
          owner = "nvim-orgmode";
          repo = "telescope-orgmode.nvim";
          rev = "master";
          hash = "sha256-2XsKl6iJYmrWDJEtj1tXBVuAHMO4RGr6C2gIguJTCKk=";
        };
        doCheck = false;
      })
    ];
    extraConfigLua = ''
      -- Add a more efficient setup for org-roam
      --    vim.defer_fn(function()
      --    require('org-roam').setup({
      --    directory = '${orgPath}roam',
      --    })
      -- end, 100) -- Delay loading slightly

      -- Lazy-load telescope extension
      vim.defer_fn(function()
          local status_ok, telescope = pcall(require, 'telescope')
          if not status_ok then
              return
          end
          telescope.load_extension('orgmode')
          vim.keymap.set('n', '<leader>oh', telescope.extensions.orgmode.search_headings)
          vim.keymap.set('n', '<leader>ol', telescope.extensions.orgmode.insert_link)
          vim.api.nvim_create_autocmd('FileType', {
              pattern = 'org',
              group = vim.api.nvim_create_augroup('orgmode_telescope_nvim', { clear = true }),
              callback = function()
                  vim.keymap.set('n', '<leader>or', require('telescope').extensions.orgmode.refile_heading)
              end,
          })
      end, 200) -- Load after org-roam

      -- Add a global command to disable/enable org notifications temporarily
      vim.api.nvim_create_user_command('OrgNotifyToggle', function()
          if vim.g.org_notify_disabled then
              vim.g.org_notify_disabled = nil
              vim.notify('Org notifications enabled')
              -- Re-enable the notifications
              require('orgmode').setup({
                  notifications = {
                      enabled = true,
                      cron_enabled = false
                  }
              })
          else
              vim.g.org_notify_disabled = true
              vim.notify('Org notifications disabled')
              require('orgmode').setup({
                  notifications = {
                      enabled = false,
                      cron_enabled = false
                  }
              })
              -- You could add code here to stop any existing notification timers
          end
      end, {})

      -- Add a function to limit org agenda scope temporarily
      vim.api.nvim_create_user_command('OrgLimitAgendaScope', function(opts)
          local path = opts.args
          if path and path ~= "" then
              -- Store the original path
              if not vim.g.original_agenda_files then
                  vim.g.original_agenda_files = require('orgmode.config').org_agenda_files
              end
              require('orgmode.config').org_agenda_files = path
              vim.notify('Org agenda scope limited to: ' .. path)
          else
              -- Restore original path if exists
              if vim.g.original_agenda_files then
                  require('orgmode.config').org_agenda_files = vim.g.original_agenda_files
                  vim.notify('Org agenda scope restored to original')
              end
          end
      end, {nargs = '?'})
    '';
  }
