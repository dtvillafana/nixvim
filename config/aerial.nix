{ ... }:
{
  plugins.aerial = {
    enable = true;
    settings = {
      backends = [
        "lsp"
        "treesitter"
        "markdown"
        "man"
      ];
      layout = {
        max_width = [
          40
          0.2
        ];
        min_width = 10;
        default_direction = "prefer_right";
      };
      filter_kind = [
        "Class"
        "Constructor"
        "Enum"
        "Function"
        "Interface"
        "Module"
        "Method"
        "Struct"
      ];
      show_guides = true;
      # Automatically fold symbols in the aerial panel
      fold = {
        autofold_depth = null;
        auto_unfold_min_lines = 20;
      };
    };
  };

  keymaps = [
    { mode = "n"; key = "<leader>a"; action = "<cmd>AerialToggle!<cr>"; options = { desc = "Aerial toggle"; noremap = true; silent = true; }; }
    { mode = "n"; key = "{"; action = "<cmd>AerialPrev<cr>"; options = { noremap = true; silent = true; }; }
    { mode = "n"; key = "}"; action = "<cmd>AerialNext<cr>"; options = { noremap = true; silent = true; }; }
    { mode = "n"; key = "[["; action = "<cmd>AerialPrevUp<cr>"; options = { noremap = true; silent = true; }; }
    { mode = "n"; key = "]]"; action = "<cmd>AerialNextUp<cr>"; options = { noremap = true; silent = true; }; }
    # Telescope integration — opens an aerial symbol picker
    {
      mode = "n";
      key = "<leader>fa";
      action.__raw = "function() require('telescope').extensions.aerial.aerial() end";
      options = {
        desc = "Aerial symbols (telescope)";
        noremap = true;
        silent = true;
      };
    }
  ];
}
