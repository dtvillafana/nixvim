{ pkgs, lib, orgPath, ... }:
if orgPath == null then {} else 
    {
    extraPackages = with pkgs; [
        texliveSmall
    ];
    plugins = {
        orgmode = {
            enable = true;
            settings = {
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
                    notifier = ''
                        function(tasks)
                            local result = {}
                            for _, task in ipairs(tasks) do
                                require('orgmode.utils').concat(result, {
                                    string.format('# %s (%s)', task.category, task.humanized_duration),
                                    string.format('%s %s %s', string.rep('*', task.level), task.todo, task.title),
                                    string.format('%s: <%s>', task.type, task.time:to_string()),
                                })
                            end

                            local msg = ""
                            for _, val in ipairs(result) do
                                msg = msg .. val .. '\n'
                            end

                            if msg ~= "" then
                                require('noice').notify(tostring(msg), 'info', {
                                    title = 'OrgNotify',
                                    on_open = function(win)
                                        local buf_id = vim.api.nvim_win_get_buf(win)
                                        vim.api.nvim_set_option_value('filetype', 'org', { buf = buf_id })
                                    end,
                                })
                            end
                        end,
                    '';
                    cron_notifier = null;
                };
            };
        };
    };

    extraPlugins = [
        (pkgs.vimUtils.buildVimPlugin {
            name = "org-roam";
            src = pkgs.fetchFromGitHub {
                owner = "chipsenkbeil";
                repo = "org-roam.nvim";
                rev = "master";
                hash = "sha256-TOhVdfiwXuRqCqlz3ZMVQuHGIoJYBtHQwp7GnwlmOzA=";
            };
            doCheck = false;
        })
        (pkgs.vimUtils.buildVimPlugin {
            name = "telescope-orgmode";
            src = pkgs.fetchFromGitHub {
                owner = "nvim-orgmode";
                repo = "telescope-orgmode.nvim";
                rev = "master";
                hash = "sha256-u3ZntL8qcS/SP1ZQqgx5q6zfGb/8L8xiguvsmU1M5XE=";
            };
            doCheck = false;
        })
    ];
    extraConfigLua = ''
        require('org-roam').setup({
            directory = '${orgPath}roam',
        })


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
            '';
}
