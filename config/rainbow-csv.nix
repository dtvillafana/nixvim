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
    vim.g.disable_rainbow_statusline = 0
    vim.g.disable_rainbow_hover = 0
    vim.g.rainbow_hover_debounce_ms = 300
    require('rainbow_csv').setup({})
    '';
}
