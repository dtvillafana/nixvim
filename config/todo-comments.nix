{
  plugins = {
    todo-comments.enable = true;
  };
  keymaps = [
    {
      mode = "n";
      key = "<leader>ft";
      action = "<CMD>TodoTelescope<CR>";
      options = {
        noremap = true;
        silent = true;
      };
    }
  ];
}
