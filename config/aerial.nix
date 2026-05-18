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
    keymaps = {
      "<leader>a" = "AerialToggle!";
      "{" = "AerialPrev";
      "}" = "AerialNext";
      "[[" = "AerialPrevUp";
      "]]" = "AerialNextUp";
    };
  };

  # Telescope integration — opens an aerial symbol picker
  keymaps = [
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
