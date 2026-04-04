{ pkgs, lib, ... }:
let
  lazygitConfig = pkgs.writeText "lazygit-config.yml" ''
    git:
      pagers:
        - pager:  ${lib.getExe pkgs.diff-so-fancy}
          colorArg: always
          useConfig: false
  '';
in
{
  plugins = {
    lazygit = {
      enable = true;
      settings = {
        use_custom_config_file_path = 1;
        config_file_path = toString lazygitConfig;
      };
    };
  };
  keymaps = [
    {
      mode = "n";
      key = "<leader>tl";
      action = "<CMD>LazyGit<CR>";
      options = {
        noremap = true;
        silent = true;
      };
    }
  ];
}
