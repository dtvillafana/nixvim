{ pkgs, ... }:
{
    extraPlugins = [
        (pkgs.vimUtils.buildVimPlugin {
            name = "presenting";
            src = pkgs.fetchFromGitHub {
                owner = "sotte";
                repo = "presenting.nvim";
                rev = "master";
                hash = "sha256-eat4lkhQ/+hAOYUeXIgRb5AaHqJE71v3y1rSOZY0waw=";
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
}
