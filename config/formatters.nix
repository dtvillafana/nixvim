{
  pkgs,
  ...
}:
{
  autoCmd = [
    {
      event = "FileType";
      pattern = [ "nix" ];
      callback = {
        __raw = ''
          function()
              vim.bo.formatexpr = "v:lua.vim.lsp.formatexpr()"
              vim.bo.equalprg =  "${pkgs.nixfmt-rfc-style}/bin/nixfmt"
          end
        '';
      };
    }
  ];
}
