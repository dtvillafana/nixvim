{ lib, pkgs, ... }:
let
  opencode = lib.getExe pkgs.opencode;
  opencodeCmd = ''
    local function opencode_http_request(method, path, body, callback)
      local tcp = vim.uv.new_tcp()
      if not tcp then
        callback("Failed to create TCP handle")
        return
      end

      local done = false
      local chunks = {}

      local function finish(err, response)
        if done then
          return
        end
        done = true
        pcall(tcp.read_stop, tcp)
        if not tcp:is_closing() then
          tcp:close()
        end
        callback(err, response)
      end

      tcp:connect("127.0.0.1", 4096, function(err)
        if err then
          finish(err)
          return
        end

        local payload = body and vim.json.encode(body) or ""
        local request = table.concat({
          method .. " " .. path .. " HTTP/1.1",
          "Host: localhost:4096",
          "Content-Type: application/json",
          "Accept: application/json",
          "Content-Length: " .. #payload,
          "Connection: close",
          "",
          payload,
        }, "\r\n")

        tcp:read_start(function(read_err, data)
          if read_err then
            finish(read_err)
          elseif data then
            table.insert(chunks, data)
          else
            local raw = table.concat(chunks)
            local header, response = raw:match("^(.-)\r\n\r\n(.*)$")
            local status = header and tonumber(header:match("^HTTP/%d%.%d%s+(%d+)"))
            if not status or status < 200 or status >= 300 then
              finish("opencode request failed with status " .. tostring(status), response)
            else
              finish(nil, response)
            end
          end
        end)

        tcp:write(request, function(write_err)
          if write_err then
            finish(write_err)
          end
        end)
      end)
    end

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
      return "${opencode} --port " .. shellescape(root)
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
      opencode_http_request("GET", "/session", nil, function(err, response)
        local cmd = start_cmd(root)
        if not err then
          local ok, sessions = pcall(vim.json.decode, response)
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

  extraConfigLua = ''
    local function opencode_http_request(method, path, body, callback)
      local tcp = vim.uv.new_tcp()
      if not tcp then
        callback("Failed to create TCP handle")
        return
      end

      local done = false
      local chunks = {}

      local function finish(err, response)
        if done then
          return
        end
        done = true
        pcall(tcp.read_stop, tcp)
        if not tcp:is_closing() then
          tcp:close()
        end
        callback(err, response)
      end

      tcp:connect("127.0.0.1", 4096, function(err)
        if err then
          finish(err)
          return
        end

        local payload = body and vim.json.encode(body) or ""
        local request = table.concat({
          method .. " " .. path .. " HTTP/1.1",
          "Host: localhost:4096",
          "Content-Type: application/json",
          "Accept: application/json",
          "Content-Length: " .. #payload,
          "Connection: close",
          "",
          payload,
        }, "\r\n")

        tcp:read_start(function(read_err, data)
          if read_err then
            finish(read_err)
          elseif data then
            table.insert(chunks, data)
          else
            local raw = table.concat(chunks)
            local header, response = raw:match("^(.-)\r\n\r\n(.*)$")
            local status = header and tonumber(header:match("^HTTP/%d%.%d%s+(%d+)"))
            if not status or status < 200 or status >= 300 then
              finish("opencode request failed with status " .. tostring(status), response)
            else
              finish(nil, response)
            end
          end
        end)

        tcp:write(request, function(write_err)
          if write_err then
            finish(write_err)
          end
        end)
      end)
    end

    local function send_opencode_tui_command(command)
      opencode_http_request(
        "POST",
        "/tui/publish",
        {
          type = "tui.command.execute",
          properties = { command = command },
        },
        function(err)
          if not err then
            return
          end
          vim.schedule(function()
            vim.notify("Failed to send opencode command: " .. err, vim.log.levels.ERROR)
          end)
        end
      )
    end

    vim.api.nvim_create_autocmd("TermOpen", {
      callback = function(event)
        local name = vim.api.nvim_buf_get_name(event.buf)
        if not name:match("opencode") then
          return
        end

        local opts = { buffer = event.buf }
        vim.keymap.set("n", "<C-u>", function()
          send_opencode_tui_command("session.half.page.up")
        end, vim.tbl_extend("force", opts, { desc = "Scroll opencode up" }))
        vim.keymap.set("n", "<C-d>", function()
          send_opencode_tui_command("session.half.page.down")
        end, vim.tbl_extend("force", opts, { desc = "Scroll opencode down" }))
        vim.keymap.set("t", "<C-u>", function()
          send_opencode_tui_command("session.half.page.up")
        end, vim.tbl_extend("force", opts, { desc = "Scroll opencode up" }))
        vim.keymap.set("t", "<C-d>", function()
          send_opencode_tui_command("session.half.page.down")
        end, vim.tbl_extend("force", opts, { desc = "Scroll opencode down" }))

        -- Some terminals can distinguish shifted Ctrl keys; most collapse them to <C-u>/<C-d>.
        vim.keymap.set("n", "<S-C-u>", function()
          send_opencode_tui_command("session.half.page.up")
        end, vim.tbl_extend("force", opts, { desc = "Scroll opencode up" }))
        vim.keymap.set("n", "<S-C-d>", function()
          send_opencode_tui_command("session.half.page.down")
        end, vim.tbl_extend("force", opts, { desc = "Scroll opencode down" }))
        vim.keymap.set("t", "<S-C-u>", function()
          send_opencode_tui_command("session.half.page.up")
        end, vim.tbl_extend("force", opts, { desc = "Scroll opencode up" }))
        vim.keymap.set("t", "<S-C-d>", function()
          send_opencode_tui_command("session.half.page.down")
        end, vim.tbl_extend("force", opts, { desc = "Scroll opencode down" }))
      end,
    })
  '';

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
