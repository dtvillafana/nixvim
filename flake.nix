{
  description = "David's Nixvim config";

  inputs = {
    nixpkgs.url = "https://flakehub.com/f/NixOS/nixpkgs/0.1";
    nixvim = {
      url = "github:nix-community/nixvim";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    flake-parts.url = "github:hercules-ci/flake-parts";
  };

  outputs =
    { nixvim, flake-parts, ... }@inputs:
    flake-parts.lib.mkFlake { inherit inputs; } {
      systems = [
        "x86_64-linux"
        "aarch64-linux"
        "x86_64-darwin"
        "aarch64-darwin"
      ];

      perSystem =
        { pkgs, system, ... }:
        let
          nixvimLib = nixvim.lib.${system};
          nixvim' = nixvim.legacyPackages.${system};
          nixvimModule = {
            module = {
              imports = [ ./config ]; # import the modules directly
              extraPackages = with pkgs; [
                ansible
                ansible-lint
                btop
                diff-so-fancy
                direnv
                emacs
                fd
                ghostscript_headless
                gnupg
                imagemagick
                lazygit
                nix-direnv
                nixfmt-rfc-style
                ripgrep
                xclip
              ];
            };
            # You can use `extraSpecialArgs` to pass additional arguments to your module files
            extraSpecialArgs = {
              system = system;
              pkgs = pkgs;
              orgPath = "/home/vir/git-repos/orgfiles/";
              omenPath = "/home/vir/.local/share/gopass/stores/root/";
              # inherit (inputs) foo;
            };
          };
          nvim = nixvim'.makeNixvimWithModule nixvimModule;
        in
        {
          checks = {
            # Run `nix flake check .` to verify that your config is not broken
            default = nixvimLib.check.mkTestDerivationFromNixvimModule nixvimModule;
          };

          packages = {
            # Lets you run `nix run .` to start nixvim
            default = nvim;
          };
        };
    };
}
