{
  description = "David's Nixvim config";

  inputs = {
    nixpkgs.url = "https://flakehub.com/f/NixOS/nixpkgs/0.1.*";
    claude-code = {
      url = "github:sadjow/claude-code-nix";
    };
    opencode-tui.url = "github:aodhanhayter/opencode-flake";
    nixvim = {
      url = "github:dtvillafana/nixvim-for-pr";
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
        { system, ... }:
        let
          pkgs = import inputs.nixpkgs {
            inherit system;
            overlays = [
              (final: prev: {
                claude-code = inputs.claude-code.packages.${system}.claude-code;
                opencode = inputs.opencode-tui.packages.${system}.opencode;
              })
            ];
          };
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
                emacs
                fd
                ghostscript_headless
                gnupg
                imagemagick
                lazygit
                nix-direnv
                nixfmt-tree
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
            # Lets you run `nix run .#print-init-lua` to print the path to the built init.lua
            print-init-lua = pkgs.writeShellScriptBin "print-init-lua" ''
              grep -oP '/nix/store/\S*-init\.lua' ${nvim}/bin/nvim
              grep -oP '/nix/store/\S*-vim-pack-dir' ${nvim}/bin/nvim | head -1
            '';
          };
        };
    };
}
