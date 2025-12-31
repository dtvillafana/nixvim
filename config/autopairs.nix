{
  autoCmd = [
    {
      event = "FileType";
      pattern = [ "nix" ];
      callback = {
        __raw = "
          function()
            -- Override autopairs CR mapping for nix files to prevent equalprg from being called
            vim.keymap.set('i', '<CR>', function()
              local line = vim.api.nvim_get_current_line()
              local col = vim.api.nvim_win_get_cursor(0)[2]
              local prev_char = col > 0 and line:sub(col, col) or ''
              local next_char = col < #line and line:sub(col + 1, col + 1) or ''

              -- Check if we're between matching pairs
              if (prev_char == '{' and next_char == '}') or
                 (prev_char == '[' and next_char == ']') or
                 (prev_char == '(' and next_char == ')') then
                -- Insert newline, add closing brace on new line, and position cursor
                return '<CR><Esc>O'
              else
                -- Normal CR behavior
                return '<CR>'
              end
            end, { buffer = true, expr = true, noremap = true })
          end";
      };
    }
  ];

  plugins = {
    nvim-autopairs = {
      enable = true;
      settings = {

        check_ts = true;
        ts_config = {
          lua = [
            "string"
            "source"
          ];
          javascript = [
            "string"
            "template_string"
          ];
          java = false;
        };
        disable_filetype = [
          "TelescopePrompt"
          "spectre_panel"
        ];
        fast_wrap = {
          map = "<M-e>"; # hit alt (Meta) + e to put the closing pair where you want
          chars = [
            "{"
            "["
            "("
            "\""
            "'"
            "`"
          ]; # add opening char here for autopairs
          offset = 0; # Offset from pattern match
          end_key = "$";
          keys = "qwertyuiopzxcvbnmasdfghjkl";
          check_comma = true;
          highlight = "PmenuSel";
          highlight_grey = "LineNr";
        };
      };
    };
  };
}
