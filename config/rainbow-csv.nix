{ pkgs, ... }:
{
    extraPlugins = [
        (pkgs.vimUtils.buildVimPlugin {
            name = "rainbow_csv";
            src = pkgs.fetchFromGitHub {
                owner = "cameron-wags";
                repo = "rainbow_csv.nvim";
                rev = "main";
                hash = "sha256-gj1SmcTBIW2fkgOzYkCeltZcsyHKniS8iEiPKhYJgmY=";
            };
        })
    ];
    extraConfigLua = ''
    require('rainbow_csv').setup({})
    '';
}
