{
    plugins = {
        scope = {
            enable = true;
            luaConfig.post = ''
                require('telescope').load_extension('scope')
            '';
        };
    };
}
