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
              vim.bo.formatexpr = ""
              vim.bo.formatprg = "${pkgs.nixfmt-rfc-style}/bin/nixfmt"
              vim.bo.equalprg = "nixfmt"
          end
        '';
      };
    }
  ];
}
