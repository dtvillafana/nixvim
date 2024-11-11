{
    description = "David's Nixvim config";

    inputs = {
        nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
        nixvim.url = "github:nix-community/nixvim";
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
                                alejandra
                                lazygit
                                diff-so-fancy
                                btop
                                nodejs-18_x
                                ripgrep
                                pandoc
                                nix-direnv
                                xclip
                            ];
                        };
                        # You can use `extraSpecialArgs` to pass additional arguments to your module files
                        extraSpecialArgs = {
                            system = system;
                            pkgs = pkgs;
                            orgPath = null;
                            omenPath = null;
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
