{ pkgs, ... }:
{
  extraPlugins = [
    (pkgs.vimUtils.buildVimPlugin {
      name = "tmux-switch";
      src = pkgs.fetchFromGitHub {
        owner = "jkeresman01";
        repo = "tmux-switch.nvim";
        rev = "main";
        hash = "sha256-GIKsuHnt26vM+/BRsX0d2aHVEOg1PIVNmj/U+UxZqi8=";
      };
      doCheck = false;
    })
  ];
  extraConfigLua = ''
    require('tmux-switch').setup({})
  '';
  keymaps = [
    {
      mode = "n";
      key = "<leader>sts";
      action = "<CMD>TmuxSwitch<CR>";
      options = {
        noremap = true;
        silent = true;
      };
    }
    {
      mode = "n";
      key = "<leader>stn";
      action = "<CMD>TmuxCreateSession<CR>";
      options = {
        noremap = true;
        silent = true;
      };
    }
    {
      mode = "n";
      key = "<leader>str";
      action = "<CMD>TmuxRenameSession<CR>";
      options = {
        noremap = true;
        silent = true;
      };
    }
  ];
}
