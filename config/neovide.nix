{
  keymaps = [
    # set leader key
    {
      action = "<CMD>lua ModifyFontSize(vim.v.count, 1)<CR>";
      key = "<C-+>";
      options = {
        noremap = true;
        silent = true;
      };
    }
    {
      action = "<CMD>lua ModifyFontSize(vim.v.count, -1)<CR>";
      key = "<C-->";
      options = {
        noremap = true;
        silent = true;
      };
    }
  ];
  extraConfigLua = ''
    function ModifyFontSize(num, multiplier)
        require('notify').dismiss() -- TODO: change this from dismissing notifications to updating the notification with the same title
        local currentFontString = vim.opt.guifont['_value']
        local fontParsed = vim.split(currentFontString, ':h')
        local fontName = fontParsed[1]
        local fontSize = fontParsed[2]
        if num == 0 then
            num = 1
        end
        vim.opt.guifont = fontName .. ':h' .. (fontSize + (num * multiplier))
        require('notify').notify(vim.opt.guifont['_value'], vim.log.levels.INFO, { title = 'resized '.. num })
    end
  '';
}
