{
  plugins = {
    trouble = {
      enable = true;
    };
  };
  keymaps = [
    {
      mode = "n";
      key = "<leader>ldf";
      action = "<cmd>Trouble diagnostics toggle filter.buf=0 win.position=bottom focus=true<cr>";
      options.desc = "Buffer Diagnostics";
    }
    {
      mode = "n";
      key = "<leader>lo";
      action = "<cmd>Trouble symbols toggle focus=false win.position=right<cr>";
      options.desc = "Buffer Diagnostics";
    }
    {
      mode = "n";
      key = "<leader>lde";
      action.__raw = "function() require('trouble').toggle({ mode = 'diagnostics', focus = true, filter = { buf = 0, lnum = vim.fn.line('.') - 1 }, win = { type = 'float', relative = 'cursor', border = 'rounded', size = { width = 80, height = 6 }, position = { -1, 2 }, zindex = 200 } }) end";
      options.desc = "Diagnostic float preview";
    }
  ];
}
