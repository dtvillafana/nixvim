{ pkgs, omenPath, ... }:
if omenPath == null then {} else {
    extraPlugins = [
        (pkgs.vimUtils.buildVimPlugin {
            name = "omen";
            src = pkgs.fetchFromGitHub {
                owner = "dtvillafana";
                repo = "omen.nvim";
                rev = "master";
                hash = "sha256-yQ+RiF1v7+XmF+Z7/9UGZeZej3rIML012gV+9r3nvOs=";
            };
        })
    ];
    extraConfigLua = ''
    require('omen').setup({
        picker = 'telescope', -- Picker type
        title = 'Omen', -- Title to be displayed on the picker
        store = '${omenPath}',
        passphrase_prompt = 'Passphrase: ', -- Prompt when asking the passphrase
        register = '+', -- Which register to fill after decoding a password
        retention = 45, -- Delay before password is cleared from the register
        ignored = { -- Ignored directories or files that are not to be listed in picker
            '.git',
            '.gitattributes',
            '.gpg-id',
            '.stversions',
            'Recycle Bin',
        },
        use_default_keymaps = true, -- Whether display info messages or not
    })
    '';
}
