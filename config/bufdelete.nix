{
  plugins = {
    bufdelete.enable = true;
  };
  keymaps = [
    {
      mode = "n";
      key = "<leader>bd";
      action = "<CMD>Bdelete<CR>";
      options = {
        noremap = true;
        silent = true;
      };
    }
  ];
}
