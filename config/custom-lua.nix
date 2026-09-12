{
  extraConfigLua = ''

    -- Detect if we're running in WSL
    local is_wsl = vim.loop.os_uname().release:match("microsoft")

    if is_wsl then
        vim.g.clipboard = {
          name = 'OSC 52',
          copy = {
            ['+'] = require('vim.ui.clipboard.osc52').copy('+'),
            ['*'] = require('vim.ui.clipboard.osc52').copy('*'),
          },
          paste = {
            ['+'] = require('vim.ui.clipboard.osc52').paste('+'),
            ['*'] = require('vim.ui.clipboard.osc52').paste('*'),
          },
        }
        -- Override `vim.ui.open` to simulate Windows behavior
        vim.ui.open = function(uri)
            -- Use `wslview` (or a similar tool) to open links in the Windows browser
            vim.fn.system({ "wslview", uri })
        end

        -- Open a toggleterm float terminal with PowerShell
        vim.keymap.set("n", "<leader>to", function()
            local Terminal = require("toggleterm.terminal").Terminal
            local powershell = Terminal:new({
                cmd = "/mnt/c/Windows/System32/WindowsPowerShell/v1.0/powershell.exe",
                direction = "float",
                hidden = true,
            })
            powershell:toggle()
        end, { desc = "Open PowerShell float terminal" })

        -- Fix snacks image rendering in tmux+wezterm (WSL) with Oil float.
        -- Two issues:
        -- 1. Oil float (zindex=45) causes snacks' z-index filter to exclude the image
        --    window from state.wins, so render_fallback never runs and the image lands
        --    at cursor (1,1) via the default a=T transmission placement.
        -- 2. render_fallback sends cursor-move and image-place as separate DCS
        --    passthroughs; tmux may refresh between them, resetting the cursor.
        -- VimEnter is used (not User VeryLazy) because nixvim doesn't use lazy.nvim.
        vim.api.nvim_create_autocmd("VimEnter", {
            once = true,
            callback = function()
                local ok, placement = pcall(require, "snacks.image.placement")
                if ok then
                    local orig_state = placement.state
                    placement.state = function(self)
                        local state = orig_state(self)
                        if #state.wins == 0 then
                            state.wins = self:wins()
                        end
                        return state
                    end
                end

                local tok, terminal = pcall(require, "snacks.image.terminal")
                if tok then
                    local pending_cursor = nil
                    local orig_write = terminal.write
                    terminal.set_cursor = function(pos)
                        pending_cursor = "\27[" .. pos[1] .. ";" .. (pos[2] + 1) .. "H"
                    end
                    terminal.write = function(data)
                        if pending_cursor then
                            data = pending_cursor .. data
                            pending_cursor = nil
                        end
                        orig_write(data)
                    end
                end
            end,
        })
    end

    -- Relay terminal notification requests to the host terminal. tmux only
    -- forwards these when they are carried in its DCS passthrough envelope.
    vim.api.nvim_create_autocmd("TermRequest", {
        callback = function(event)
            local sequence = event.data.sequence
            if not sequence:match("^\27]9;") then
                return
            end

            if vim.env.TMUX ~= nil then
                sequence = "\27Ptmux;" .. sequence:gsub("\27", "\27\27") .. "\27\\"
            end

            vim.api.nvim_ui_send(sequence)
        end,
    })

    -- TUI jobs (OpenCode, btop, …) emit a constant stream of redraws. Neovim
    -- treats that job activity as interrupting 'timeoutlen', so mapped
    -- sequences never complete. Collect the chord in Lua instead of using
    -- Neovim's mapping timeout, then dispatch the matching mapping.
    do
      local function wait_char(timeout_ms)
        local deadline = vim.uv.now() + timeout_ms
        while vim.uv.now() < deadline do
          local c = vim.fn.getcharstr(0)
          if type(c) == "string" and c ~= "" then
            return c
          end
          vim.wait(10)
        end
        return nil
      end

      local function map_mode()
        local mode = vim.api.nvim_get_mode().mode
        if mode == "t" then
          return "t"
        end
        if mode:find("^[vV\22]") then
          return "x"
        end
        if mode:sub(1, 2) == "nt" or mode:sub(1, 1) == "n" then
          return "n"
        end
        return mode:sub(1, 1)
      end

      local function mapping_lhs_raw(m)
        if type(m.lhsraw) == "string" and m.lhsraw ~= "" then
          return m.lhsraw
        end
        return vim.api.nvim_replace_termcodes(m.lhs, true, true, true)
      end

      local function has_longer_mapping(collected, mode)
        local collected_t = vim.fn.keytrans(collected)
        local maps = vim.api.nvim_get_keymap(mode)
        local ok, buf_maps = pcall(vim.api.nvim_buf_get_keymap, 0, mode)
        if ok then
          vim.list_extend(maps, buf_maps)
        end
        for _, m in ipairs(maps) do
          local lhs = mapping_lhs_raw(m)
          if #lhs > #collected and lhs:sub(1, #collected) == collected then
            return true
          end
          local lhs_t = vim.fn.keytrans(lhs)
          if #lhs_t > #collected_t and lhs_t:sub(1, #collected_t) == collected_t then
            return true
          end
        end
        return false
      end

      local function leader_raw()
        local leader = vim.g.mapleader
        if type(leader) ~= "string" or leader == "" then
          leader = "\\"
        end
        return vim.api.nvim_replace_termcodes(leader, true, true, true)
      end

      local function lookup_map(keys, mode)
        local rest = keys:sub(#leader_raw() + 1)
        local candidates = {
          keys,
          vim.fn.keytrans(keys),
          "<leader>" .. rest,
          "<Space>" .. rest,
        }
        for _, cand in ipairs(candidates) do
          local info = vim.fn.maparg(cand, mode, false, true)
          if
            type(info) == "table"
            and (info.callback or (info.rhs and info.rhs ~= ""))
            and info.lhs ~= "<leader>"
            and info.lhs ~= "<Space>"
            and info.lhs ~= " "
          then
            return info
          end
        end
        return nil
      end

      local function execute_map(info)
        if info.callback then
          local result = info.callback()
          if info.expr == 1 and type(result) == "string" and result ~= "" then
            if info.replace_keycodes == 1 then
              result = vim.api.nvim_replace_termcodes(result, true, true, true)
            end
            vim.api.nvim_feedkeys(result, "n", false)
          end
          return
        end
        local rhs = vim.api.nvim_replace_termcodes(info.rhs, true, true, true)
        vim.api.nvim_feedkeys(rhs, info.noremap == 1 and "n" or "m", false)
      end

      local function intercept_leader()
        local mode = map_mode()
        local keys = leader_raw()
        while has_longer_mapping(keys, mode) do
          local c = wait_char(vim.o.timeoutlen)
          if not c then
            break
          end
          keys = keys .. c
        end

        if keys == leader_raw() then
          if mode == "t" then
            vim.api.nvim_feedkeys(keys, "n", false)
            return
          end
          local wk_ok, wk = pcall(require, "which-key")
          if wk_ok and wk.show then
            wk.show({ keys = vim.g.mapleader, mode = mode })
          end
          return
        end

        local info = lookup_map(keys, mode)
        if info then
          execute_map(info)
        else
          vim.api.nvim_feedkeys(keys, "n", false)
        end
      end

      vim.keymap.set({ "n", "x", "t" }, "<leader>", intercept_leader, {
        nowait = true,
        silent = true,
        desc = "Leader (collect sequence outside timeoutlen)",
      })

      local function intercept_insert_seq(first, second)
        vim.keymap.set("i", first, function()
          local c = wait_char(vim.o.timeoutlen)
          if c == second then
            return "<Esc>"
          end
          if not c then
            return first
          end
          return first .. c
        end, {
          expr = true,
          nowait = true,
          silent = true,
          replace_keycodes = true,
        })
      end

      intercept_insert_seq("j", "k")
      intercept_insert_seq("k", "j")
    end
  '';
}
