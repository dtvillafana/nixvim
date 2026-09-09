{ lib, pkgs, ... }:
let
  opencode2 = lib.getExe pkgs.opencode2;
in
{
  plugins = {
    claude-code = {
      enable = true;
      settings = {
        command = lib.getExe pkgs.claude-code;
        refresh = {
          show_notifications = false;
        };
        keymaps = {
          toggle = {
            normal = "<leader>a,";
            terminal = "<leader>a,";
            variants = {
              continue = "<leader>ac";
            };
          };
          window_navigation = true;
          scrolling = true;
        };
      };
    };
    opencode = {
      enable = true;
      package = pkgs.vimUtils.buildVimPlugin {
        name = "opencode.nvim";
        src = pkgs.fetchFromGitHub {
          owner = "dtvillafana";
          repo = "opencode.nvim";
          rev = "main";
          hash = "sha256-Kdn/Qk0y3Grtz2xq/o5EQkYgoSIh5Kv+pIuqp/tiOtY=";
        };
      };
      settings.server.start = lib.nixvim.mkRaw "function() _G.__opencode_ai.terminal():open() end";
    };
  };

  extraConfigLua = ''
    _G.__opencode_ai = {
      terminal = function()
        return require("toggleterm.terminal").Terminal:new({
          cmd = "${opencode2}",
          hidden = true,
          direction = "horizontal",
          display_name = "opencode",
          id = 99,
        })
      end,
    }
  '';

  keymaps = [
    {
      mode = [
        "n"
        "x"
      ];
      key = "<leader>aa";
      action.__raw = ''function() require("opencode").ask("@this: ") end'';
      options.desc = "Ask opencode…";
    }
    {
      mode = [
        "n"
        "x"
      ];
      key = "<leader>ax";
      action.__raw = ''function() require("opencode").select() end'';
      options.desc = "Execute opencode action…";
    }
    {
      mode = [
        "n"
        "t"
      ];
      key = "<leader>a.";
      action.__raw = ''function() _G.__opencode_ai.terminal():toggle() end'';
      options.desc = "Toggle opencode";
    }
    {
      mode = [
        "n"
        "x"
      ];
      key = "go";
      action.__raw = ''function() return require("opencode").operator("@this ") end'';
      options = {
        desc = "Add range to opencode";
        expr = true;
      };
    }
    {
      mode = "n";
      key = "goo";
      action.__raw = ''function() return require("opencode").operator("@this ") .. "_" end'';
      options = {
        desc = "Add line to opencode";
        expr = true;
      };
    }
  ];
}
