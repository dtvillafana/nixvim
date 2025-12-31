{
  pkgs,
  lib,
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
              vim.bo.equalprg =  "${lib.getExe pkgs.nixfmt-rfc-style}"
              vim.opt_local.formatoptions:remove({ "r", "o" })
          end
        '';
      };
    }
  ];
}
