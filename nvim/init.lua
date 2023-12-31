local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
    vim.fn.system({
        "git", "clone",
        "--filter=blob:none",
        "https://github.com/folke/lazy.nvim.git",
        "--branch=stable", -- latest stable release
        lazypath,
    })
end
vim.opt.rtp:prepend(lazypath)


vim.opt.nu = true
vim.opt.relativenumber = true
vim.opt.tabstop = 8
vim.opt.softtabstop = 4
vim.opt.shiftwidth = 4
vim.opt.expandtab = true
vim.opt.smartindent = true
vim.opt.swapfile = false
vim.opt.backup = false
vim.opt.undodir = os.getenv("HOME") .. "/.vim/undodir"
vim.opt.undofile = true
vim.opt.termguicolors = true
vim.opt.cursorline = true

-- craziest remap ever
-- when pasting over a selection, keep the clipboard content
vim.keymap.set("v", "p", "pgvy")

-- Make sure to set `mapleader` before lazy so your mappings are correct
vim.g.mapleader = " "

-- add Control-C as a shortcut to get to the normal mode (alternative to caps-lock)
-- vim.keymap.set("i", "<C-c>", "<Esc>")

require("lazy").setup({
    "folke/which-key.nvim",
    { "folke/neoconf.nvim", cmd = "Neoconf" },
    {
        "nvim-treesitter/nvim-treesitter",
        build = ":TSUpdate",
        config = function () 
            local configs = require("nvim-treesitter.configs")

            configs.setup({
                ensure_installed = { "rust", "javascript", "html", "perl", "c", "lua", "javascript" },
                sync_install = false,
                highlight = { enable = true },
                indent = { enable = false },  
            })
        end
    },
    { "catppuccin/nvim", name = "catppuccin", priority = 1000 },
    {
        'VonHeikemen/lsp-zero.nvim',
        branch = 'v2.x',
        dependencies = {
            -- LSP Support
            {'neovim/nvim-lspconfig'},             -- Required
            {'williamboman/mason.nvim'},           -- Optional
            {'williamboman/mason-lspconfig.nvim'}, -- Optional

            -- Autocompletion
            {'hrsh7th/nvim-cmp'},     -- Required
            {'hrsh7th/cmp-nvim-lsp'}, -- Required

            {'hrsh7th/cmp-buffer'},
            {'hrsh7th/cmp-path'},
            {'saadparwaiz1/cmp_luasnip'},
            {'hrsh7th/cmp-nvim-lua'},

            -- Snippets
            {'L3MON4D3/LuaSnip'},
            {'rafamadriz/friendly-snippets'},
        }
    },
    {
        'nvim-telescope/telescope.nvim', branch = '0.1.x',
        dependencies = { 
            'nvim-lua/plenary.nvim', 
            'nvim-telescope/telescope-file-browser.nvim',
            {
                'nvim-telescope/telescope-fzf-native.nvim',
                -- NOTE: If you are having trouble with this installation,
                --       refer to the README for telescope-fzf-native for more instructions.
                build = 'make',
                cond = function()
                    return vim.fn.executable 'make' == 1
                end,
            },
        }
    },
    'nvim-telescope/telescope-project.nvim',
    'ThePrimeagen/git-worktree.nvim',
    { 'ThePrimeagen/harpoon', branch = 'harpoon2', dependencies = { 'nvim-lua/plenary.nvim' } },
    'nvim-treesitter/nvim-treesitter-context',
    'tpope/vim-fugitive',
    'lewis6991/gitsigns.nvim',
    'RRethy/vim-illuminate',
    'mbbill/undotree',
    'nvim-tree/nvim-web-devicons',
    'folke/trouble.nvim',
    {
        "folke/todo-comments.nvim",
        dependencies = { "nvim-lua/plenary.nvim" },
        opts = {
            -- your confiuration comes here
            -- or leave it empty to use the default settings
            -- refer to the configuration section below
            signs = true,
        }
    },
    'nvim-pack/nvim-spectre',
    {
        "j-hui/fidget.nvim",
        tag = "legacy",
        event = "LspAttach",
        opts = {
            -- options
        },
    },
    'rmagatti/auto-session',
    {
        "folke/flash.nvim",
        event = "VeryLazy",
        ---@type Flash.Config
        opts = {},
        -- stylua: ignore
        keys = {
            { "s", mode = { "n", "o" }, 
            function() require("flash").jump() end, desc = "Flash" },
            { "S", mode = { "n", "", "o" }, 
            function() require("flash").treesitter() end, desc = "Flash Treesitter" },
            { "R", mode = { "o", "x" }, 
            function() require("flash").treesitter_search() end, desc = "Treesitter Search" },
        },
    },
    'nvim-lualine/lualine.nvim',
    'tpope/vim-sleuth',
})

local lsp = require('lsp-zero').preset({})

lsp.preset("recommended")

lsp.ensure_installed({
    'rust_analyzer',
})

-- Fix Undefined global 'vim'
lsp.nvim_workspace()

require('trouble').setup {
    icons = true,
}

-- to make PLS work
require'lspconfig'.perlpls.setup{}

local cmp = require('cmp')
local cmp_select = {behavior = cmp.SelectBehavior.Select}
local cmp_mappings = lsp.defaults.cmp_mappings({
    ['<C-k>'] = cmp.mapping.select_prev_item(cmp_select),
    ['<C-j>'] = cmp.mapping.select_next_item(cmp_select),
    ['<CR>'] = cmp.mapping.confirm({ select = true }),
    ["<C-Space>"] = cmp.mapping.complete(),
})

cmp_mappings['<Tab>'] = nil
cmp_mappings['<S-Tab>'] = nil


lsp.setup_nvim_cmp({
    mapping = cmp_mappings,
})

lsp.set_preferences({
    suggest_lsp_servers = false,
})

lsp.on_attach(function(client, bufnr)
    local opts = {buffer = bufnr, remap = false}

    vim.keymap.set("n", "gd", function() vim.lsp.buf.definition() end, opts)
    vim.keymap.set("n", "gh", function() vim.lsp.buf.hover() end, opts)
    -- show all errors in popup
    vim.keymap.set("n", "ge", function() vim.diagnostic.open_float() end, opts)
    -- show code actions
    vim.keymap.set("n", "gc", function() vim.lsp.buf.code_action() end, opts)
    vim.keymap.set("n", "gr", function() vim.lsp.buf.references() end, opts)
    vim.keymap.set("n", "<leader>vrn", function() vim.lsp.buf.rename() end, opts)
    vim.keymap.set("i", "<C-h>", function() vim.lsp.buf.signature_help() end, opts)
end)

lsp.format_on_save({
    format_opts = {
        async = false,
        timeout_ms = 10000,
    },
    servers = {
        ['rust_analyzer'] = {'rust'},
    }
})


lsp.setup()

vim.diagnostic.config({
    virtual_text = true
})

require('telescope').load_extension('project')
require('telescope').load_extension('git_worktree')
require('telescope').load_extension('file_browser')

local wk = require("which-key")

wk.register({
    ["<leader>f"] = {
        name = "+file", -- optional group name
        f = { "<cmd>:Telescope find_files<cr>", "Find File"},
        g = { "<cmd>:Telescope live_grep<cr>", "Live Grep"},
        s = { "<cmd>:Telescope lsp_document_symbols<cr>", "Document symbols"},
        h = { "<cmd>:Telescope help_tags<cr>", "Help Tags"},
        l = { "<cmd>:Telescope buffers<cr>", "Last files"},
        b = { "<cmd>:Telescope file_browser<cr>", "Browse"},
        p = { "<cmd>:Telescope project<cr>", "Project"},
        w = { "<cmd>:Telescope git_worktree<cr>", "Git Worktree"},
    },
    ["<leader>x"] = {
        name = "+Trouble", -- optional group name
    },
})

require("auto-session").setup {
    log_level = "error",
    auto_session_suppress_dirs = { "~/Downloads"},
}

require("lualine").setup {
    sections = {
        lualine_c = {
            {
                "filename",
                path = 1,
                file_status = true,
                newfile_status = true,
            },
        },
        lualine_x = {},
    }
}


require("catppuccin").setup({
    flavour = "mocha",
    term_colors = true, -- sets terminal colors (e.g. `g:terminal_color_0`)
})

vim.cmd[[colorscheme catppuccin]]

-- Undotree
vim.keymap.set("n", "<leader>u", vim.cmd.UndotreeToggle)


local harpoon = require("harpoon")

harpoon:setup()

vim.keymap.set("n", "<leader>a", function() harpoon:list():append() end)
vim.keymap.set("n", "<leader><leader>", function() harpoon.ui:toggle_quick_menu(harpoon:list()) end)

vim.keymap.set("n", "<C-h>", function() harpoon:list():select(1) end)
vim.keymap.set("n", "<C-t>", function() harpoon:list():select(2) end)
vim.keymap.set("n", "<C-n>", function() harpoon:list():select(3) end)
vim.keymap.set("n", "<C-s>", function() harpoon:list():select(4) end)


vim.o.updatetime = 900
vim.wo.signcolumn = 'yes'

require('gitsigns').setup {
    signcolumn = true,  -- Toggle with `:Gitsigns toggle_signs`
    numhl      = false, -- Toggle with `:Gitsigns toggle_numhl`
    linehl     = false, -- Toggle with `:Gitsigns toggle_linehl`
    word_diff  = false, -- Toggle with `:Gitsigns toggle_word_diff`
    watch_gitdir = {
        follow_files = true
    },
    attach_to_untracked = true,
    current_line_blame = true, -- Toggle with `:Gitsigns toggle_current_line_blame`
    current_line_blame_formatter = '<author>, <author_time:%Y-%m-%d> - <summary>',
    on_attach = function(bufnr)
        local gs = package.loaded.gitsigns

        local function map(mode, l, r, opts)
            opts = opts or {}
            opts.buffer = bufnr
            vim.keymap.set(mode, l, r, opts)
        end

        -- Navigation
        map('n', ']c', function()
            if vim.wo.diff then return ']c' end
            vim.schedule(function() gs.next_hunk() end)
            return '<Ignore>'
        end, {expr=true})

        map('n', '[c', function()
            if vim.wo.diff then return '[c' end
            vim.schedule(function() gs.prev_hunk() end)
            return '<Ignore>'
        end, {expr=true})

        -- Actions
        -- set the git base back to HEAD
        map('n', '<leader>hd', function() 
            gs.change_base('HEAD') 
            gs.toggle_linehl(false) 
        end)
        -- quickly review the latest applied patches
        map('n', '<leader>hr', function() 
            gs.change_base('origin/master') 
            gs.toggle_linehl(true) 
        end)
    end

}


vim.keymap.set("n", "<leader>xw", "<cmd>TroubleToggle workspace_diagnostics<cr>", {silent = true, noremap = true})
vim.keymap.set("n", "<leader>xd", "<cmd>TroubleToggle document_diagnostics<cr>", {silent = true, noremap = true})
vim.keymap.set("n", "<leader>xt", "<cmd>TodoTrouble<cr>", {silent = true, noremap = true})

vim.keymap.set('n', '<leader>s', '<cmd>lua require("spectre").toggle()<CR>', {
    desc = "Toggle Spectre"
})


-- other random remaps
vim.g.mapleader = " "
vim.keymap.set("n", "<leader>pv", vim.cmd.Ex)

-- vim.keymap.set("n", "<C-d>", "<C-d>zz")
-- vim.keymap.set("n", "<C-u>", "<C-u>zz")

-- centers and selects the word when searching and going to next reference
vim.keymap.set("n", "n", "nzzzv")
vim.keymap.set("n", "N", "Nzzzv")


-- copy to clipboard
vim.keymap.set({"n", "v"}, "<leader>y", [["+y]])
vim.keymap.set("n", "<leader>Y", [["+Y]])

vim.keymap.set("i", "<C-c>", "<Esc>")

vim.keymap.set({"n", "v"}, "<leader>d", [["_d]])

vim.keymap.set("n", "Q", "<nop>")
vim.keymap.set("n", "<C-f>", "<cmd>silent !tmux neww tmux-sessionizer<CR>")

vim.keymap.set("n", "<C-j>", "<cmd>cnext<CR>zz")
vim.keymap.set("n", "<C-k>", "<cmd>cprev<CR>zz")
vim.keymap.set("n", "<leader>k", "<cmd>lnext<CR>zz")
vim.keymap.set("n", "<leader>j", "<cmd>lprev<CR>zz")

vim.keymap.set("n", "<leader>gb", ":G blame<CR>");
