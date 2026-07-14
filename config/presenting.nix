{ pkgs, ... }:
{
  extraPlugins = [
    (pkgs.vimUtils.buildVimPlugin {
      name = "presenting";
      src = pkgs.fetchFromGitHub {
        owner = "sotte";
        repo = "presenting.nvim";
        rev = "master";
        hash = "sha256-nAOKUW01KyC5kCP86s0KUsNPfb9wWngDNH3KWvKBwo8=";
      };
    })
  ];
  extraConfigLua = ''
    require('presenting').setup({
        options = {
            width = 100,
        },
        configure_slide_buffer = function(buf) vim.api.nvim_buf_set_option(buf, 'filetype', 'org'); vim.api.nvim_buf_set_option(buf, 'foldlevel', 99) end,
    })
  '';

  keymaps = [
    {
      mode = "n";
      key = "<leader>pr";
      action = "<CMD>lua require('presenting').toggle()<CR>";
      options = {
        noremap = true;
        silent = true;
      };
    }
  ];
}
