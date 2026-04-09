{ pkgs, lib, ... }:
let
  diffSoFancyWrapper = pkgs.writeShellScript "diff-so-fancy-wrapper" ''
    export GIT_CONFIG_COUNT=4
    export GIT_CONFIG_KEY_0="color.diff-highlight.newnormal"
    export GIT_CONFIG_VALUE_0="green"
    export GIT_CONFIG_KEY_1="color.diff-highlight.newhighlight"
    export GIT_CONFIG_VALUE_1="bold green"
    export GIT_CONFIG_KEY_2="color.diff-highlight.oldnormal"
    export GIT_CONFIG_VALUE_2="red"
    export GIT_CONFIG_KEY_3="color.diff-highlight.oldhighlight"
    export GIT_CONFIG_VALUE_3="bold red"
    exec ${lib.getExe pkgs.diff-so-fancy} "$@"
  '';
  lazygitConfig = pkgs.writeText "lazygit-config.yml" ''
    git:
      pagers:
        - pager:  ${diffSoFancyWrapper}
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
