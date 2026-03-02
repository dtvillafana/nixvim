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
      action = "<cmd>Trouble diagnostics toggle filter.buf=0 win.position=right focus=true<cr>";
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
      action = "<cmd>Trouble diagnostics toggle focus=true filter.buf=0 win.type=float win.relative=cursor win.border=rounded win.size.width=80 win.size.height=6 win.position={-1,2} win.zindex=200<cr>";
      options.desc = "Diagnostic float preview";
    }
  ];
}
