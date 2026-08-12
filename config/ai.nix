{ lib, pkgs, ... }:
let
  opencode = lib.getExe pkgs.opencode;
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
      settings.server = {
        url = lib.nixvim.mkRaw "function(callback) _G.__opencode_ai.url(callback) end";
        start = lib.nixvim.mkRaw "function() _G.__opencode_ai.start() end";
        toggle = lib.nixvim.mkRaw "function() _G.__opencode_ai.toggle() end";
      };
    };
  };

  extraConfigLua = ''
    local opencode_port

    local function port()
      if opencode_port then
        return opencode_port
      end

      local tcp = assert(vim.uv.new_tcp())
      assert(tcp:bind("127.0.0.1", 0))
      opencode_port = assert(tcp:getsockname()).port
      tcp:close()
      return opencode_port
    end

    local function command()
      return "${opencode} --port " .. port()
    end

    local terminal_opts = {
      split = "below",
      height = math.floor(vim.o.lines * 0.3),
    }

    _G.__opencode_ai = {
      url = function(callback)
        callback("http://127.0.0.1:" .. port())
      end,
      start = function()
        require("opencode.terminal").open(command(), terminal_opts)
      end,
      toggle = function()
        require("opencode.terminal").toggle(command(), terminal_opts)
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
      action.__raw = ''function() require("opencode").toggle() end'';
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
    {
      mode = "n";
      key = "<S-C-u>";
      action.__raw = ''function() require("opencode").command("session.half.page.up") end'';
      options.desc = "Scroll opencode up";
    }
    {
      mode = "n";
      key = "<S-C-d>";
      action.__raw = ''function() require("opencode").command("session.half.page.down") end'';
      options.desc = "Scroll opencode down";
    }
  ];
}
