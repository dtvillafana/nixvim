{ lib, pkgs, ... }:
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
      settings = {
        server = {
          start = lib.nixvim.mkRaw ''
            function()
              local function opencode_cmd(callback)
                local tcp = vim.uv.new_tcp()
                tcp:connect("127.0.0.1", 4096, function(err)
                  tcp:close()
                  vim.schedule(function()
                    callback(err == nil
                      and "${lib.getExe pkgs.opencode} attach http://localhost:4096"
                      or "${lib.getExe pkgs.opencode} --port 4096 --hostname 0.0.0.0")
                  end)
                end)
              end

              opencode_cmd(function(cmd)
                require("opencode.terminal").open(cmd, {
                  split = "below",
                  height = math.floor(vim.o.lines * 0.3),
                })
              end)
            end
          '';
          toggle = lib.nixvim.mkRaw ''
            function()
              local function opencode_cmd(callback)
                local tcp = vim.uv.new_tcp()
                tcp:connect("127.0.0.1", 4096, function(err)
                  tcp:close()
                  vim.schedule(function()
                    callback(err == nil
                      and "${lib.getExe pkgs.opencode} attach http://localhost:4096"
                      or "${lib.getExe pkgs.opencode} --port 4096 --hostname 0.0.0.0")
                  end)
                end)
              end

              opencode_cmd(function(cmd)
                require("opencode.terminal").toggle(cmd, {
                  split = "below",
                  height = math.floor(vim.o.lines * 0.3),
                })
              end)
            end
          '';
        };
      };
    };
  };

  keymaps = [
    {
      mode = [
        "n"
        "x"
      ];
      key = "<leader>aa";
      action.__raw = ''function() require("opencode").ask("@this: ", { submit = true }) end'';
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
