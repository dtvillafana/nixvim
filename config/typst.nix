{ pkgs, ... }:
{
  extraPackages = with pkgs; [
    poppler-utils
    typst
  ];

  extraPlugins = [
    (pkgs.vimUtils.buildVimPlugin {
      name = "typst-preview.nvim";
      doCheck = false;
      src = pkgs.fetchFromGitHub {
        owner = "al-kot";
        repo = "typst-preview.nvim";
        rev = "59028097432682e8f619ed61b24333c6e5f79a97";
        hash = "sha256-/zrxxTsw1R2phmTgW8fD8UWaMEMxNsYA3TYbmWQRGDw=";
      };
      postPatch = ''
        substituteInPlace \
          lua/typst-preview/init.lua \
          lua/typst-preview/preview.lua \
          lua/typst-preview/statusline.lua \
          lua/typst-preview/utils.lua \
          lua/typst-preview/renderer/renderer.lua \
          --replace-fail "typst-preview." "typst-preview-split."
        substituteInPlace \
          lua/typst-preview/init.lua \
          lua/typst-preview/statusline.lua \
          lua/typst-preview/utils.lua \
          --replace-fail "TypstPreview" "TypstSplitPreview"
        mv lua/typst-preview lua/typst-preview-split
        rm plugin/init.lua
      '';
    })
  ];

  extraConfigLua = ''
    local typst_preview = require("typst-preview-split")
    local typst_preview_open = false

    typst_preview.setup()
    vim.api.nvim_create_user_command("TypstSplitPreviewToggle", function()
        if typst_preview_open then
            typst_preview.stop()
        else
            typst_preview.start()
        end
        typst_preview_open = not typst_preview_open
    end, {})

    vim.api.nvim_create_autocmd("FileType", {
        pattern = "typst",
        callback = function(event)
            local function map(key, action, description)
                vim.keymap.set("n", key, action, {
                    buffer = event.buf,
                    desc = description,
                    silent = true,
                })
            end

            map("<Space>pn", typst_preview.next_page, "Typst preview next page")
            map("<Space>pp", typst_preview.prev_page, "Typst preview previous page")
            map("<Space>pf", typst_preview.first_page, "Typst preview first page")
            map("<Space>pl", typst_preview.last_page, "Typst preview last page")
            map("<Space>pg", function()
                vim.ui.input({ prompt = "Typst preview page: " }, function(input)
                    local page = tonumber(input)
                    if page then
                        typst_preview.goto_page(page)
                    end
                end)
            end, "Typst preview go to page")
            map("<Space>pc", function()
                vim.cmd.update()

                local source = vim.api.nvim_buf_get_name(event.buf)
                local output = vim.fn.fnamemodify(source, ":r") .. ".pdf"
                local source_dir = vim.fs.dirname(source)
                local candidate = source_dir
                local project_root

                for _ = 0, 2 do
                    if vim.uv.fs_stat(candidate .. "/flake.nix") then
                        project_root = candidate
                        break
                    end
                    candidate = vim.fs.dirname(candidate)
                end
                local command

                if project_root and vim.fn.executable("nix") == 1 then
                    command = {
                        "nix",
                        "develop",
                        project_root,
                        "--command",
                        "typst",
                        "compile",
                        "--root",
                        project_root,
                        source,
                        output,
                    }
                elseif project_root then
                    command = {
                        vim.fn.exepath("typst"),
                        "compile",
                        "--root",
                        project_root,
                        source,
                        output,
                    }
                else
                    command = { vim.fn.exepath("typst"), "compile", source, output }
                end

                vim.notify("Compiling " .. vim.fn.fnamemodify(source, ":t"), vim.log.levels.INFO)
                vim.system(command, { text = true }, function(result)
                    vim.schedule(function()
                        if result.code == 0 then
                            vim.notify("Compiled " .. output, vim.log.levels.INFO)
                            return
                        end

                        local message = result.stderr ~= "" and result.stderr or result.stdout
                        vim.notify(vim.trim(message), vim.log.levels.ERROR)
                    end)
                end)
            end, "Compile Typst document")
        end,
    })
  '';

  lsp.servers.tinymist = {
    enable = true;
    config.settings = {
      exportPdf = "onSave";
      formatterMode = "typstyle";
    };
  };

  plugins.typst-preview.enable = true;

  keymaps = [
    {
      mode = "n";
      key = "<Space>pt";
      action = "<CMD>TypstSplitPreviewToggle<CR>";
      options = {
        desc = "Toggle Typst preview split";
        noremap = true;
        silent = true;
      };
    }
    {
      mode = "n";
      key = "<Space>pb";
      action = "<CMD>TypstPreviewToggle<CR>";
      options = {
        desc = "Toggle Typst browser preview";
        noremap = true;
        silent = true;
      };
    }
  ];
}
