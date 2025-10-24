{
  lib,
  ...
}:
{
  extraConfigLuaPost = ''
    local severity = vim.diagnostic.severity
    vim.diagnostic.config({
        signs = {
            text = {
                [severity.ERROR] = " ",
                [severity.WARN] = " ",
                [severity.INFO] = " ",
                [severity.HINT] = " ",
            },
        },
    })
  '';
  lsp = {
    inlayHints.enable = true;
    keymaps = [
      # General LSP Actions
      {
        key = "grh";
        lspBufAction = "hover";
        mode = "n";
      }
      # Diagnostics
      {
        key = "<leader>lde";
        action = "<CMD>lua vim.diagnostic.open_float()<Enter>";
        mode = "n";
      }
      # Python server specific
      {
        mode = "n";
        key = "<leader>lx";
        action = "<CMD>lua vim.g.type_checking = not vim.g.type_checking; local clients = vim.lsp.get_clients({name = 'basedpyright'}); for _, client in ipairs(clients) do vim.lsp.stop_client(client.id) end; vim.defer_fn(function() vim.lsp.start({name = 'basedpyright', cmd = {'basedpyright-langserver', '--stdio'}, settings = { basedpyright = { analysis = { typeCheckingMode = vim.g.type_checking and 'on' or 'off', }, }, }, root_markers = {'.git', 'pyproject.toml', 'setup.py'}}) end, 100)<CR>";
      }
    ];
    servers = {
      html = {
        enable = true;
      };
      nixd = {
        enable = true;
        settings = {
          cmd = [ "nixd" ];
          filetypes = [ "nix" ];
        };
      };
      basedpyright = {
        enable = true;
        settings = {
          cmd = [
            "basedpyright-langserver"
            "--stdio"
          ];
          filetypes = [
            "python"
          ];
        };
      };
      jsonls = {
        enable = true;
        settings = {
          cmd = [
            "vscode-json-language-server"
            "--stdio"
          ];
          filetypes = [
            "json"
          ];
        };
      };
      lemminx = {
        enable = true;
        settings = {
          cmd = [ "lemminx" ];
          filetypes = [ "xml" ];
        };
      };
      ts_ls = {
        enable = true;
        settings = {
          cmd = [
            "typescript-language-server"
            "--stdio"
          ];
          root_dir = lib.nixvim.mkRaw ''
            function(bufnr, on_dir)
                -- The project root is where the LSP can be started from
                -- As stated in the documentation above, this LSP supports monorepos and simple projects.
                -- We select then from the project root, which is identified by the presence of a package
                -- manager lock file.
                local root_markers = { 'package-lock.json', 'yarn.lock', 'pnpm-lock.yaml', 'bun.lockb', 'bun.lock', '.git' }
                local project_root = vim.fs.root(bufnr, root_markers)
                if not project_root then
                  return
                end

                on_dir(project_root)
            end
          '';
        };
      };
      lua_ls = {
        enable = true;
      };
    };
    luaConfig = {
      post = ''
        -- the following is for when native completion is as good as cmp
        -- vim.api.nvim_create_autocmd('LspAttach', {
        --   callback = function(ev)
        --     local client = vim.lsp.get_client_by_id(ev.data.client_id)
        --     if client:supports_method('textDocument/completion') then
        --       vim.lsp.completion.enable(true, client.id, ev.buf, { autotrigger = true })
        --     end
        --   end,
        -- })

        vim.g.type_checking = true;
        function RESET_LSP()
            local cur_buf = vim.api.nvim_get_current_buf()
            local clients = vim.lsp.get_clients({bufnr = cur_buf})

            -- Collect client names before stopping them
            local client_names = {}
            for _, client in ipairs(clients) do
                table.insert(client_names, client.name)
                vim.lsp.stop_client(client.id)
            end

            local filepath = vim.api.nvim_buf_get_name(cur_buf)
            local directory = vim.fn.fnamemodify(filepath, ':h')
            local command = 'cd ' .. directory
            vim.api.nvim_exec2(command, { output = false })
            vim.api.nvim_exec2('DirenvExport', { output = false })

            -- Wait 500ms then reattach LSP
            vim.defer_fn(function()
                -- Force LSP to reattach by editing the buffer
                vim.cmd('edit!')

                -- Notify user which LSP servers were restarted
                if #client_names > 0 then
                    local message = "Restarted LSP servers: " .. table.concat(client_names, ", ")
                    vim.notify(message, vim.log.levels.INFO)
                else
                    vim.notify("No LSP servers were running", vim.log.levels.WARN)
                end
            end, 1000)
        end
      '';
    };
  };
  plugins.lsp = {
    servers = {
      ansiblels = {
        enable = true;
        filetypes = [
          "yaml.ansible"
        ];
        settings.ansible = {
          ansible = {
            path = "ansible";
            useFullyQualifiedCollectionNames = true;
          };
          executionEnvironment.enabled = false;
          python = {
            interpreterPath = "python"; # Will use the first python in PATH, which should be the one from direnv
            envKind = "auto";
          };
        };
      };
      lua_ls = {
        enable = true;
        settings = {
          telemetry.enable = false;
          diagnostics = {
            globals = [
              "vim"
            ];
          };
        };
      };
      bashls = {
        enable = true;
        filetypes = [
          "zsh"
          "sh"
          "bash"
          "ksh"
        ];
      };
      tailwindcss = {
        enable = true;
        filetypes = [
          "aspnetcorerazor"
          "astro"
          "astro-markdown"
          "blade"
          "clojure"
          "django-html"
          "htmldjango"
          "edge"
          "eelixir"
          "elixir"
          "ejs"
          "erb"
          "eruby"
          "gohtml"
          "gohtmltmpl"
          "haml"
          "handlebars"
          "hbs"
          "htmlangular"
          "html-eex"
          "heex"
          "jade"
          "leaf"
          "liquid"
          "mdx"
          "mustache"
          "njk"
          "nunjucks"
          "php"
          "razor"
          "slim"
          "twig"
          "css"
          "less"
          "postcss"
          "sass"
          "scss"
          "stylus"
          "sugarss"
          "javascript"
          "javascriptreact"
          "reason"
          "rescript"
          "typescript"
          "typescriptreact"
          "vue"
          "svelte"
          "templ"
        ];
      };
      rust_analyzer = {
        enable = true;
        installCargo = true;
        installRustc = true;
      };
    };
  };

  plugins = {
    lspconfig.enable = true;
    telescope.keymaps = {
      "<leader>lf" = "lsp_references";
      "<leader>lg" = "lsp_definitions";
      "<leader>lci" = "lsp_incoming_calls";
      "<leader>lco" = "lsp_outgoing_calls";
    };
    direnv = {
      enable = true;
      settings = {
        direnv_silent_reload = 0;
      };
    };
  };
  filetype = {
    pattern = {
      ".*inventory" = "yaml.ansible";
      ".*playbook.yml" = "yaml.ansible";
      ".*config.yml" = "yaml.ansible";
    };
  };
}
