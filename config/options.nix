{
    opts = {
        backup = false; # creates a backup file
        clipboard = "unnamedplus"; # allows neovim to access the system clipboard
        cmdheight = 2; # more space in the neovim command line for displaying messages
        completeopt = [
            "menuone"
            "noselect"
        ]; # mostly just for cmp
        concealcursor = "nc";
        conceallevel = 2; # was originally set to 0 so that `` is visible in markdown files, is now set to 2 so emphasis markers in org are hidden
        cursorline = true; # highlight the current line
        expandtab = true; # convert tabs to spaces
        fileencoding = "utf-8"; # the encoding written to a file
        foldcolumn = "0"; # "0" is not bad
        foldenable = true;
        foldlevel = 99; # Using ufo provider need a large value, feel free to decrease the value
        foldlevelstart = 99;
        hlsearch = true; # highlight all matches on previous search pattern
        ignorecase = true; # ignore case in search patterns
        laststatus = 3;
        linebreak = true; # break wrapped lines at sensible characters
        mouse = ""; # enable or disable mouse
        number = true; # set numbered lines
        numberwidth = 4; # set number column width to 2 {default 4}
        pumheight = 10; # pop up menu height
        relativenumber = true; # set relative numbered lines
        scrolloff = 4; # set how many lines the cursor can be from the edge of the screen before scrolling
        sessionoptions = "buffers,curdir,folds,winpos,winsize,tabpages,globals";
        shiftwidth = 4; # the number of spaces inserted for each indentation
        showmode = false; # we don"t need to see things like -- INSERT -- anymore
        showtabline = 2; # always show tabs
        sidescrolloff = 4;
        signcolumn = "yes"; # always show the sign column, otherwise it would shift the text each time
        smartcase = true; # smart case
        smartindent = true; # make indenting smarter again
        splitbelow = true; # force all horizontal splits to go below current window
        splitright = true; # force all vertical splits to go to the right of current window
        swapfile = false; # creates a swapfile
        tabstop = 4; # number of spaces that make up a tab
        termguicolors = true; # set term gui colors (most terminals support this)
        timeoutlen = 200; # time to wait for a mapped sequence to complete (in milliseconds)
        undofile = true; # enable persistent undo
        updatetime = 300; # faster completion (4000ms default)
        wrap = true; # wrap lines that are too long to display on the screen
        writebackup = false; # if a file is being edited by another program (or was written to file while editing with another program), it is not allowed to be edited
        guifont = "SauceCodePro Nerd Font Mono:h11"; # the font used in graphical neovim applications
        maxmempattern = 2000000;
        list = true;
        listchars = "tab:>-,space:·";
    };
}
