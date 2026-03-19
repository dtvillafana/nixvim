# use these to control PDF export formatting
# #+PDF_FONT_SCALE: 90%
# #+PDF_PAGE_MARGIN: 0.2in
{
  pkgs,
  lib,
  orgPath,
  ...
}:
if orgPath == null then
  { }
else
  let
    font_dir = pkgs.runCommand "pandoc-fonts" { } ''
      mkdir -p $out/fonts
      ln -s ${pkgs.nerd-fonts.dejavu-sans-mono}/share/fonts/truetype/NerdFonts/DejaVuSansM/*.ttf $out/fonts/
    '';
    pico_css = pkgs.fetchurl {
      url = "https://cdn.jsdelivr.net/npm/@picocss/pico@2/css/pico.min.css";
      sha256 = "1nx3kc8s20vhn93d3jprwixgga8zw439iz6p5z8p57zwr4zsdjgv";
    };
    org_treesitter =
      pkgs.luajitPackages."tree-sitter-orgmode" or pkgs.lua51Packages."tree-sitter-orgmode";
  in
  {
    extraPackages = with pkgs; [
      chromium
      emacs
      tectonic
      (texlive.withPackages (
        p: with p; [
          beamer
          hyphenat
          latex
          latex-bin
          latexmk
          pandoc
          preview
          scheme-medium
          standalone
          varwidth
          wrapfig
        ]
      ))
    ];
    plugins = {
      orgmode = {
        enable = true;
        package = pkgs.vimUtils.buildVimPlugin {
          name = "orgmode";
          src = pkgs.fetchFromGitHub {
            owner = "dtvillafana";
            repo = "orgmode-notifications";
            rev = "master";
            hash = "sha256-/Yk6Je/9M64yKQh1naC7+ohmQ/XOaPkbX/XheEpNNzA=";
          };
          doCheck = false;
          postPatch = ''
            substituteInPlace lua/orgmode/config/init.lua \
              --replace-fail \
              "return require('orgmode.utils.treesitter.install').install()" \
              "return pcall(function() vim.treesitter.language.add('org', { path = '${org_treesitter}/lib/lua/5.1/parser/org.so'}) end)" \
              --replace-fail \
              "return require('orgmode.utils.treesitter.install').reinstall()" \
              "return pcall(function() vim.treesitter.language.add('org', { path = '${org_treesitter}/lib/lua/5.1/parser/org.so'}) end)"
          '';
        };
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
            "DELEGATED(l)"
          ];
          org_agenda_skip_deadline_if_done = true;
          org_agenda_skip_scheduled_if_done = true;
          org_custom_exports = {
            t = {
              label = "Export to standalone PDF (tectonic)";
              action = lib.generators.mkLuaInline ''
                function(exporter)
                    local current_file = vim.api.nvim_buf_get_name(0)
                    local target = vim.fn.fnamemodify(current_file, ':p:r') .. '.pdf'
                    local command = 'cd ' ..  ' $(realpath $(dirname ' .. tostring(current_file) .. ')) ' ..  ' &&' .. ' OSFONTDIR=${pkgs.nerd-fonts.dejavu-sans-mono}/share/fonts/truetype/NerdFonts/DejaVuSansM ${pkgs.pandoc}/bin/pandoc ' ..  current_file ..  ' -o ' ..  target ..  ' --standalone --pdf-engine=tectonic'
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
            w = {
              label = "Export to HTML PDF (Chromium)";
              action = lib.generators.mkLuaInline ''
                function(exporter)
                    local current_file = vim.api.nvim_buf_get_name(0)
                    local base = vim.fn.fnamemodify(current_file, ':p:r')
                    local target = base .. '.pdf'
                    local html_target = base .. '.html'
                    local file_escaped = vim.fn.shellescape(current_file)
                    local pdf_escaped = vim.fn.shellescape(target)
                    local file_url_escaped = vim.fn.shellescape('file://' .. html_target)
                    local emacs_eval = vim.fn.shellescape(
                      string.format(
                        "(progn (require 'org) (require 'ox-html) (find-file %q) (let* ((org-export-with-toc nil) (org-html-postamble nil) (font-scale (or (car (cdr (assoc \"PDF_FONT_SCALE\" (org-collect-keywords '(\"PDF_FONT_SCALE\"))))) \"75%%\")) (page-margin (or (car (cdr (assoc \"PDF_PAGE_MARGIN\" (org-collect-keywords '(\"PDF_PAGE_MARGIN\"))))) \"0.35in\")) (org-html-head (concat \"<link rel=\\\"stylesheet\\\" href=\\\"file://${pico_css}\\\"><style>:root{--org-pdf-font-scale:\" font-scale \"}@page{margin:\" page-margin \"}html{font-size:var(--org-pdf-font-scale)}body{margin:0}main.container{padding:0;max-width:none;width:100%%}#content{margin:0}.title{margin-bottom:2rem}.subtitle{color:var(--muted-color)}.org-src-container,pre.src,pre.example{padding:1rem;border-radius:var(--pico-border-radius);background:var(--pico-code-background,#f5f7f8);overflow-x:auto}table{width:100%%}#table-of-contents{display:none}</style>\")) (org-html-head-include-default-style nil)) (org-html-export-to-html nil nil nil nil nil)))",
                        current_file
                      )
                    )
                    local command =
                      'cd $(realpath $(dirname ' .. file_escaped .. ')) && ' ..
                      '${pkgs.emacs}/bin/emacs --batch ' .. file_escaped .. ' --eval ' .. emacs_eval .. ' && ' ..
                      "perl -0pi -e 's#<body([^>]*)>#<body$1><main class=\"container\">#; s#</body>#</main></body>#' " .. vim.fn.shellescape(html_target) .. ' && ' ..
                      '${pkgs.chromium}/bin/chromium --headless --disable-gpu --allow-file-access-from-files --no-pdf-header-footer ' ..
                      '--print-to-pdf=' .. pdf_escaped .. ' ' .. file_url_escaped .. ' 2>/dev/null'
                    local on_success = function(output)
                        print('Success! exported to ' .. target .. ' via ' .. html_target)
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
            b = {
              label = "Export to beamer";
              action = lib.generators.mkLuaInline ''
                function(exporter)
                    local current_file = vim.api.nvim_buf_get_name(0)
                    local target = vim.fn.fnamemodify(current_file, ':p:r') .. '.pdf'
                    local command = 'cd $(realpath $(dirname ' .. tostring(current_file) .. ')) && ' .. 'OSFONTDIR=${font_dir}/fonts ' .. '${pkgs.pandoc}/bin/pandoc ' .. current_file .. ' -o ' .. target .. ' --standalone --pdf-engine=tectonic'
                    local on_success = function(output)
                        print('Success! exported to ' .. target)
                        vim.api.nvim_echo({ { table.concat(output, '\n') } }, true, {})
                    end
                    local on_error = function(err)
                        print('Error!')
                        vim.api.nvim_echo({ { table.concat(err, ""), 'ErrorMsg' } }, true, {})
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
          };
        };
      };
    };

    extraPlugins = [
      (pkgs.vimUtils.buildVimPlugin {
        name = "org-bullets";
        src = pkgs.fetchFromGitHub {
          owner = "nvim-orgmode";
          repo = "org-bullets.nvim";
          rev = "main";
          hash = "sha256-/l8IfvVSPK7pt3Or39+uenryTM5aBvyJZX5trKNh0X0=";
        };
        doCheck = false;
      })
      (pkgs.vimUtils.buildVimPlugin {
        name = "org-modern.nvim";
        src = pkgs.fetchFromGitHub {
          owner = "danilshvalov";
          repo = "org-modern.nvim";
          rev = "main";
          hash = "sha256-TYs3g5CZDVXCFXuYaj3IriJ4qlIOxQgArVOzT7pqkqs=";
        };
        doCheck = false;
      })
      (pkgs.vimUtils.buildVimPlugin {
        name = "org-super-agenda.nvim";
        src = pkgs.fetchFromGitHub {
          owner = "hamidi-dev";
          repo = "org-super-agenda.nvim";
          rev = "main";
          hash = "sha256-4O7wyPoYFtGLi/TYy9U6kildyr+RCpUsqb0vr4Aovw4=";
        };
        doCheck = false;
      })
      (pkgs.vimUtils.buildVimPlugin {
        name = "telescope-orgmode";
        src = pkgs.fetchFromGitHub {
          owner = "nvim-orgmode";
          repo = "telescope-orgmode.nvim";
          rev = "master";
          hash = "sha256-UaK+ct04Y4lNEZ93NzCkgzQYbpAeTnpbGEZ8wZiAxtM=";
        };
        doCheck = false;
      })
    ];
    extraConfigLua = ''
      require('org-bullets').setup()
      local org_modern_menu_ok, OrgModernMenu = pcall(require, 'org-modern.menu')
      if org_modern_menu_ok then
          require('orgmode').setup({
              ui = {
                  menu = {
                      handler = function(data)
                          OrgModernMenu:new({
                              window = {
                                  margin = { 1, 0, 1, 0 },
                                  padding = { 0, 1, 0, 1 },
                                  title_pos = 'center',
                                  border = 'single',
                                  zindex = 1000,
                              },
                              icons = {
                                  separator = '➜',
                              },
                          }):open(data)
                      end,
                  },
              },
          })
      end

      local org_super_agenda_ok, org_super_agenda = pcall(require, 'org-super-agenda')
      if org_super_agenda_ok then
          org_super_agenda.setup({
              org_directories = { '${orgPath}' },
              todo_states = {
                  { name = 'TODO', shortcut = 't', keymap = 'ot', color = '#ff6b6b', strike_through = false, fields = { 'filename', 'todo', 'headline', 'priority', 'date', 'tags' } },
                  { name = 'MEET', shortcut = 'm', keymap = 'om', color = '#4dabf7', strike_through = false, fields = { 'filename', 'todo', 'headline', 'priority', 'date', 'tags' } },
                  { name = 'CALL', shortcut = 'c', keymap = 'oc', color = '#74c0fc', strike_through = false, fields = { 'filename', 'todo', 'headline', 'priority', 'date', 'tags' } },
                  { name = 'EVENT', shortcut = 'e', keymap = 'oe', color = '#ffd43b', strike_through = false, fields = { 'filename', 'todo', 'headline', 'priority', 'date', 'tags' } },
                  { name = 'WAITING', shortcut = 'w', keymap = 'ow', color = '#b197fc', strike_through = false, fields = { 'filename', 'todo', 'headline', 'priority', 'date', 'tags' } },
                  { name = 'DONE', shortcut = 'd', keymap = 'od', color = '#69db7c', strike_through = true, fields = { 'filename', 'todo', 'headline', 'priority', 'date', 'tags' } },
                  { name = 'CANCELED', shortcut = 'a', keymap = 'ox', color = '#868e96', strike_through = true, fields = { 'filename', 'todo', 'headline', 'priority', 'date', 'tags' } },
              },
              groups = {
                  {
                      name = 'Today',
                      matcher = function(item)
                          return item.scheduled and item.scheduled:is_today()
                      end,
                      sort = { by = 'scheduled_time', order = 'asc' },
                  },
                  {
                      name = 'Overdue',
                      matcher = function(item)
                          return item.todo_state ~= 'DONE'
                              and item.todo_state ~= 'CANCELED'
                              and (
                                  (item.deadline and item.deadline:is_past())
                                  or (item.scheduled and item.scheduled:is_past())
                              )
                      end,
                      sort = { by = 'date_nearest', order = 'asc' },
                  },
                  {
                      name = 'Upcoming',
                      matcher = function(item)
                          local days = require('org-super-agenda.config').get().upcoming_days or 7
                          local deadline_days = item.deadline and item.deadline:days_from_today()
                          local scheduled_days = item.scheduled and item.scheduled:days_from_today()
                          return (deadline_days and deadline_days >= 0 and deadline_days <= days)
                              or (scheduled_days and scheduled_days >= 0 and scheduled_days <= days)
                      end,
                      sort = { by = 'date_nearest', order = 'asc' },
                  },
                  {
                      name = 'Waiting',
                      matcher = function(item)
                          return item.todo_state == 'WAITING'
                      end,
                  },
                  {
                      name = 'Meetings',
                      matcher = function(item)
                          return item.todo_state == 'MEET'
                      end,
                  },
                  {
                      name = 'Calls',
                      matcher = function(item)
                          return item.todo_state == 'CALL'
                      end,
                  },
                  {
                      name = 'Events',
                      matcher = function(item)
                          return item.todo_state == 'EVENT'
                      end,
                  },
              },
              upcoming_days = 7,
              hide_empty_groups = true,
          })

          vim.keymap.set('n', '<leader>oa', '<CMD>OrgSuperAgenda<CR>', {
              silent = true,
              desc = 'Org Super Agenda',
          })
      end

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
