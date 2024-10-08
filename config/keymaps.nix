{
    globals = {
        mapleader = " ";
        maplocalleader = " ";
    };
    keymaps = [
        # set leader key
        { action = "<Space>"; key = "<Nop>"; options = { noremap = true; silent = true; }; }

        # easier window navigation
        { mode = "n"; action = "<C-w>h"; key = "<C-h>"; options = { noremap = true; silent = true; }; }
        { mode = "n"; action = "<C-w>j"; key = "<C-j>"; options = { noremap = true; silent = true; }; }
        { mode = "n"; action = "<C-w>k"; key = "<C-k>"; options = { noremap = true; silent = true; }; }
        { mode = "n"; action = "<C-w>l"; key = "<C-l>"; options = { noremap = true; silent = true; }; }

        # exiting controls
        { mode = "n"; key = "<leader>q"; action = "<CMD>q<CR>"; options = { noremap = true; silent = true; }; }
        { mode = "n"; key = "<A-q>"; action = "<CMD>tabclose<CR>"; options = { noremap = true; silent = true; }; }
        { mode = "n"; key = "<leader>w"; action = "<CMD>w!<CR>"; options = { noremap = true; silent = true; }; }
        { mode = "n"; key = "<leader>x"; action = "<CMD>x<CR>"; options = { noremap = true; silent = true; }; }

        # resizing with arrow actions
        { mode = "n"; key = "<C-Up>"; action = "<CMD>resize -2<CR>"; options = { noremap = true; silent = true; }; }
        { mode = "n"; key = "<C-Down>"; action = "<CMD>resize +2<CR>"; options = { noremap = true; silent = true; }; }
        { mode = "n"; key = "<C-Left>"; action = "<CMD>vertical resize -2<CR>"; options = { noremap = true; silent = true; }; }
        { mode = "n"; key = "<C-Right>"; action = "<CMD>vertical resize +2<CR>"; options = { noremap = true; silent = true; }; }
        { mode = "n"; key = "<S-l>"; action = "<CMD>bnext<CR>"; options = { noremap = true; silent = true; }; }
        { mode = "n"; key = "<S-h>"; action = "<CMD>bprevious<CR>"; options = { noremap = true; silent = true; }; }

        # Navigate/Control tabs
        { mode = "n"; key = "<A-h>"; action = "<CMD>tabnext<CR>"; options = { noremap = true; silent = true; }; }
        { mode = "n"; key = "<A-l>"; action = "<CMD>tabprevious<CR>"; options = { noremap = true; silent = true; }; }
        { mode = "n"; key = "<leader><C-t>"; action = "<CMD>tabnew<CR>"; options = { noremap = true; silent = true; }; }

        # remove highlighting
        { mode = "n"; key = "<leader>hr"; action = "<CMD>nohl<CR>"; options = { noremap = true; silent = true; }; }

        # file tree
        { mode = "n"; key = "<leader>v"; action = "<CMD>NvimTreeToggle<CR>"; options = { noremap = true; silent = true; }; }

        # quick escape from insert mode
        { mode = "i"; key = "jk"; action = "<ESC>"; options = { noremap = true; silent = true; }; }
        { mode = "i"; key = "kj"; action = "<ESC>"; options = { noremap = true; silent = true; }; }

        # yank to system clipboard
        { mode = "v"; key = "<leader>y"; action = "\"+y"; options = { noremap = true; silent = true; }; }

        # global replace visual selection
        { mode = "v"; key = "<leader>r"; action = "\"hy:%s/<C-r>h//g<left><left>"; options = { noremap = true; silent = true; }; }

        # Stay in indent mode when indenting
        { mode = "v"; key = "<"; action = "<gv"; options = { noremap = true; silent = true; }; }
        { mode = "v"; key = ">"; action = ">gv"; options = { noremap = true; silent = true; }; }

        # cd to current dir
        { mode = "n"; key = "<leader>rc"; action = "<CMD>lua local current_buf = vim.api.nvim_get_current_buf(); local filepath = vim.api.nvim_buf_get_name(current_buf); local directory = vim.fn.fnamemodify(filepath, ':h'); local command = 'cd ' .. directory; vim.api.nvim_exec2(command, { output = false });<CR>"; options = { noremap = true; silent = true; }; }

        # dismiss notifications
        { mode = "n"; key = "<leader>pd"; action = "<CMD>NoiceDismiss<CR>"; options = { noremap = true; silent = true; }; }
    ];
}
