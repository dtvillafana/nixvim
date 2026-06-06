{ lib, pkgs, ... }:
let
  curl = lib.getExe pkgs.curl;
  opencode = lib.getExe pkgs.opencode;
  opencodeCmd = ''
    local function project_root()
      local cwd = vim.uv.cwd()
      local markers = {
        "flake.nix",
        "README.md",
        "readme.md",
        "package.json",
        "Cargo.toml",
        "go.mod",
        "pyproject.toml",
        "Makefile",
      }

      local dir = cwd
      local dirs = {}
      for _ = 0, 2 do
        table.insert(dirs, dir)

        local parent = vim.fs.dirname(dir)
        if not parent or parent == dir then
          break
        end
        dir = parent
      end

      for _, root in ipairs(dirs) do
        if vim.uv.fs_stat(root .. "/.git") then
          return vim.uv.fs_realpath(root) or root
        end
      end

      for _, root in ipairs(dirs) do
        for _, marker in ipairs(markers) do
          if vim.uv.fs_stat(root .. "/" .. marker) then
            return vim.uv.fs_realpath(root) or root
          end
        end
      end

      return vim.uv.fs_realpath(cwd) or cwd
    end

    local function shellescape(value)
      return '"' .. tostring(value)
        :gsub("\\", "\\\\")
        :gsub('"', '\\"')
        :gsub("%$", "\\$")
        :gsub("`", "\\`")
        .. '"'
    end

    local function start_cmd(root)
      return "${opencode} " .. shellescape(root)
    end

    local function attach_cmd(session, root)
      return "${opencode} attach http://localhost:4096 --session "
        .. shellescape(session.id)
        .. " --dir "
        .. shellescape(root)
    end

    local function latest_matching_session(sessions, root)
      local match
      for _, session in ipairs(sessions) do
        local directory = session.directory and (vim.uv.fs_realpath(session.directory) or session.directory)
        if directory == root and session.id then
          if not match or (session.time and session.time.updated or 0) > (match.time and match.time.updated or 0) then
            match = session
          end
        end
      end
      return match
    end

    local function session_cmd(root, callback)
      vim.system({ "${curl}", "-fsS", "http://localhost:4096/session" }, { text = true }, function(result)
        local cmd = start_cmd(root)
        if result.code == 0 then
          local ok, sessions = pcall(vim.json.decode, result.stdout)
          if ok and type(sessions) == "table" then
            local session = latest_matching_session(sessions, root)
            if session then
              cmd = attach_cmd(session, root)
            end
          end
        end

        vim.schedule(function()
          callback(cmd)
        end)
      end)
    end

    local function opencode_cmd(callback)
      local root = project_root()
      local tcp = vim.uv.new_tcp()
      tcp:connect("127.0.0.1", 4096, function(err)
        tcp:close()
        if err == nil then
          session_cmd(root, callback)
        else
          vim.schedule(function()
            callback(start_cmd(root))
          end)
        end
      end)
    end
  '';
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
      settings = {
        server = {
          start = lib.nixvim.mkRaw ''
            function()
              ${opencodeCmd}

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
              ${opencodeCmd}

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
