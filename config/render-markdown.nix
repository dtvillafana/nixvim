{ ... }:
{
  plugins = {
    render-markdown = {
      enable = true;
      settings = {
        injections = {
          poweron = {
            enable = true;
            query = ''
              ((comment) @injection.content
                  (#set! injection.language "markdown"))
            '';
          };
        };
      };
    };
  };
}
