{ pkgs, ... }:
{
    extraPlugins = [
        (pkgs.vimUtils.buildVimPlugin {
            name = "rainbow_csv";
            src = pkgs.fetchFromGitHub {
                owner = "cameron-wags";
                repo = "rainbow_csv.nvim";
                rev = "main";
                hash = "sha256-/XHQd/+sqhVeeMAkcKNvFDKFuFecChrgp56op3KQAhs=";
            };
        })
    ];
    extraConfigLua = ''
    require('rainbow_csv').setup({})
    '';
}
