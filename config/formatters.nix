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
              vim.bo.equalprg =  "${lib.getExe pkgs.nixfmt}"
              vim.opt_local.formatoptions:remove({ "r", "o" })
          end
        '';
      };
    }
  ];
}
