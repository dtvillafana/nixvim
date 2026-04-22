{ pkgs, ... }:
{
  extraPlugins = [
    (pkgs.vimUtils.buildVimPlugin {
      name = "rainbow_csv";
      src = pkgs.fetchFromGitHub {
        owner = "dtvillafana";
        repo = "rainbow_csv.nvim";
        rev = "master";
        hash = "sha256-F+ar0cNzUkJM+HRUB5GRz/GPc0THMH8wRzV+F39F/4s=";
      };
    })
  ];
  extraConfigLua = ''
    vim.g.disable_rainbow_statusline = 0
    require('rainbow_csv').setup()
  '';
  autoCmd = [
    {
      event = "FileType";
      pattern = [
        "csv"
        "csv_pipe"
        "csv_tab"
        "csv_whitespace"
        "csv_semicolon"
      ];
      callback.__raw = ''
        function(ev)
          vim.treesitter.stop(ev.buf)
        end
      '';
    }
  ];
}
