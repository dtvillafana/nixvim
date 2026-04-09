{
  colorschemes.catppuccin = {
    enable = true;
    settings = {
      flavour = "frappe";
      transparent_background = false; # disables setting the background color.
      term_colors = true; # sets terminal colors (e.g. `g:terminal_color_0`)
      styles = {
        # Handles the styles of general hi groups (see `:h highlight-args`):
        comments = [ "italic" ]; # Change the style of comments
        conditionals = [ "italic" ];
      };
      integrations = {
        bufferline = true;
        cmp = true;
        gitsigns = true;
        nvimtree = true;
        treesitter = true;
        notify = true;
        alpha = true;
        flash = true;
        which_key = true;
      };
    };
  };
}
