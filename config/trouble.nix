{
  plugins = {
    trouble = {
      enable = true;
    };
  };
  keymaps = [
    # {
    #   mode = "n";
    #   key = "<leader>ldf";
    #   action = "<cmd>Trouble diagnostics toggle filter.buf=0 win.position=bottom focus=true<cr>";
    #   options.desc = "Buffer Diagnostics";
    # }
    {
      mode = "n";
      key = "<leader>lo";
      action = "<cmd>Trouble symbols toggle focus=false win.position=right<cr>";
      options.desc = "Buffer Diagnostics";
    }
    {
        key = "<leader>lde";
        action = "<CMD> lua vim.diagnostic.open_float()<Enter>";
        mode = "n";
    }
  ];
}
