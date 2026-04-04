{
  lib,
  pkgs,
  ...
}:
let

  py =
    (pkgs.python313.override {
      packageOverrides = self: super: {
        jaraco-test = super.jaraco-test.overridePythonAttrs { doCheck = false; };
        importlib-resources = super.importlib-resources.overridePythonAttrs { doCheck = false; };
        lsprotocol = self.buildPythonPackage rec {
          pname = "lsprotocol";
          version = "2023.0.1";
          format = "pyproject";
          src = self.fetchPypi {
            inherit pname version;
            hash = "sha256-zFwVEw0kA8GLc0MEM55RJC0wGKBcT30PGYrW4M0hhh0=";
          };
          nativeBuildInputs = [
            self.flit-core
            self.poetry-core
          ];
          propagatedBuildInputs = [
            self.cattrs
            self.attrs
          ];
          doCheck = false;
        };
        pygls = self.buildPythonPackage rec {
          pname = "pygls";
          version = "1.3.1";
          format = "pyproject";
          src = self.fetchPypi {
            inherit pname version;
            hash = "sha256-FA7c7voNoOmzxTNUfIkqQqfS/ZIXroSMMwxT0malUBg=";
          };
          nativeBuildInputs = [
            self.poetry-core
            self.setuptools
            self.setuptools-scm
          ];
          propagatedBuildInputs = [
            self.cattrs
            self.lsprotocol
          ];
          doCheck = false;
        };
        jedi = super.jedi.overridePythonAttrs { doCheck = false; };
        poetry-core = super.poetry-core.overridePythonAttrs { doCheck = false; };
        cattrs = super.cattrs.overridePythonAttrs { doCheck = false; };
      };
    }).pkgs;

in
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
    inlayHints.enable = false;
    keymaps = [
      # General LSP Actions
      {
        key = "grh";
        lspBufAction = "hover";
        mode = "n";
      }
      # Python server specific
      {
        mode = "n";
        key = "<leader>lx";
        action = "<CMD>lua vim.g.type_checking = not vim.g.type_checking; local clients = vim.lsp.get_clients({name = 'ty'}); for _, client in ipairs(clients) do vim.lsp.stop_client(client.id) end; vim.defer_fn(function() vim.lsp.start({name = 'ty', cmd = {'ty', 'server'}, settings = { ty = { analysis = { typeCheckingMode = vim.g.type_checking and 'on' or 'off', }, }, }, root_markers = {'.git', 'pyproject.toml', 'setup.py'}}) end, 100)<CR>";
      }
    ];
    servers = {
      ansiblels = {
        enable = true;
        config = {
          filetypes = [
            "yaml.ansible"
          ];
          root_markers = [
            ".git"
            "inventory"
            "ansible.cfg"
          ];
          settings = {
            ansible = {
              path = "ansible";
              useFullyQualifiedCollectionNames = true;
            };
            executionEnvironment = {
              enabled = false;
            };
            python = {
              interpreterPath = "python";
              envKind = "auto";
            };
          };
        };
      };
      html = {
        enable = true;
      };
      bashls = {
        enable = true;
        config = {
          cmd = [
            "bash-language-server"
            "start"
          ];
          filetypes = [
            "zsh"
            "sh"
            "bash"
            "ksh"
          ];
        };
      };
      nixd = {
        enable = true;
        config = {
          cmd = [ "nixd" ];
          filetypes = [ "nix" ];
          settings = {
            nixd = {
              options = {
                nixvim = {
                  expr = "(builtins.getFlake \"github:nix-community/nixvim\").legacyPackages.\${builtins.currentSystem}.nixvimConfiguration.options";
                };
                # WARN: these options expressions for completions only work as long as my upstream flake is structured as it currently is
                nixos = {
                  expr = ''(builtins.getFlake "github:dtvillafana/dotfiles-nix").outputs.nixosConfigurations.thinkpad.options'';
                };
                home_manager = {
                  expr = ''((builtins.getFlake "github:dtvillafana/dotfiles-nix").outputs.nixosConfigurations.thinkpad.options.home-manager.users.type.getSubOptions [])'';
                };
              };
            };
          };
        };
      };
      djlsp = {
        enable = true;
        package = py.buildPythonPackage rec {
          pname = "django_template_lsp";
          version = "1.2.2";
          format = "pyproject";

          src = py.fetchPypi {
            inherit pname version;
            hash = "sha256-FdzLsz3H70y4ThZzvwWD1UUrspuMskZWO4xbpOFBXIM=";
          };

          nativeBuildInputs = with py; [
            setuptools
          ];

          propagatedBuildInputs = with py; [
            pygls
            lsprotocol
            jedi
          ];

          doCheck = false;

          meta = with lib; {
            description = "Language server for Django templates";
            homepage = "https://github.com/fourdigits/djlsp";
            license = licenses.mit;
          };
        };
        config = {
          cmd = [
            "djlsp"
          ];
          filetypes = [ "htmldjango" ];
        };
      };
      htmx = {
        enable = true;
        config = {
          cmd = [ "htmx-lsp" ];
          filetypes = [
            "aspnetcorerazor"
            "astro"
            "astro-markdown"
            "blade"
            "clojure"
            "django-html"
            "edge"
            "eelixir"
            "ejs"
            "elixir"
            "erb"
            "eruby"
            "gohtml"
            "gohtmltmpl"
            "haml"
            "handlebars"
            "hbs"
            "heex"
            "html"
            "html-eex"
            "htmlangular"
            "htmldjango"
            "jade"
            "javascript"
            "javascriptreact"
            "leaf"
            "liquid"
            "markdown"
            "mdx"
            "mustache"
            "njk"
            "nunjucks"
            "php"
            "razor"
            "reason"
            "rescript"
            "slim"
            "svelte"
            "templ"
            "twig"
            "typescript"
            "typescriptreact"
            "vue"
          ];
        };
      };
      ty = {
        enable = true;
        config = {
          cmd = [
            "ty"
            "server"
          ];
          filetypes = [
            "python"
          ];
        };
      };
      jsonls = {
        enable = true;
        config = {
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
        config = {
          cmd = [ "lemminx" ];
          filetypes = [ "xml" ];
        };
      };
      ts_ls = {
        enable = true;
        config = {
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
      tailwindcss = {
        enable = true;
        config = {
          cmd = [ "tailwindcss-language-server" ];
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
      };
      lua_ls = {
        enable = true;
        config = {
          telemetry.enable = false;
          diagnostics = {
            globals = [
              "vim"
            ];
          };
        };
      };
    };
    luaConfig = {
      post = ''
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
      "<leader>lt" = "lsp_type_definitions";
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
