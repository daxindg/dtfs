--------------------------------------
--------- General Settings -----------
--------------------------------------

vim.o.laststatus = 0 -- hide status line
vim.o.scrolloff = math.floor(vim.fn.winheight('%') / 2.4)

vim.o.tabstop = 4
vim.o.shiftwidth = 4

-- Clipbaord
vim.o.clipboard = 'unnamedplus'

--Incremental live completion
vim.o.inccommand = "nosplit"

--Set highlight on search
vim.o.hlsearch = false
vim.o.incsearch = true

--Make line numbers default
vim.wo.rnu = true
vim.wo.nu = true

--Do not save when switching buffers
vim.o.hidden = true

--Enable mouse mode
vim.o.mouse = "a"

--Enable break indent
vim.o.breakindent = true

--Save undo history
vim.cmd [[set undofile]]

--Case insensitive searching UNLESS /C or capital in search
vim.o.ignorecase = true
vim.o.smartcase = true

--Decrease update time
vim.o.updatetime = 250
vim.wo.signcolumn = "yes"

--Set colorscheme (order is important here)
vim.o.termguicolors = true
vim.g.onedark_terminal_italics = 2

--------------------------------------
--------- General KeyMappings --------
--------------------------------------

--Remap space as leader key
vim.api.nvim_set_keymap('', '<Space>', '<Nop>', { noremap = true, silent = true })
vim.g.mapleader = " "
vim.g.maplocalleader = " "

--Remap for dealing with word wrap
vim.api.nvim_set_keymap('n', 'k', "v:count == 0 ? 'gk' : 'k'", { noremap = true, expr = true, silent = true })
vim.api.nvim_set_keymap('n', 'j', "v:count == 0 ? 'gj' : 'j'", { noremap = true, expr = true, silent = true })

-- Copy & Paste

vim.api.nvim_set_keymap('v', '<leader>Y', '"+y', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', '<leader>Y', '"+y', { noremap = true, silent = true })
vim.api.nvim_set_keymap('v', '<leader>P', '"+p', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', '<leader>P', '"+p', { noremap = true, silent = true })


--Add move line shortcuts
vim.api.nvim_set_keymap('n', '<A-j>', ':m .+1<CR>==', { noremap = true })
vim.api.nvim_set_keymap('n', '<A-k>', ':m .-2<CR>==', { noremap = true })
vim.api.nvim_set_keymap('i', '<A-j>', '<Esc>:m .+1<CR>==gi', { noremap = true })
vim.api.nvim_set_keymap('i', '<A-k>', '<Esc>:m .-2<CR>==gi', { noremap = true })
vim.api.nvim_set_keymap('v', '<A-j>', ':m \'>+1<CR>gv=gv', { noremap = true })
vim.api.nvim_set_keymap('v', '<A-k>', ':m \'<-2<CR>gv=gv', { noremap = true })
vim.api.nvim_set_keymap('i', '<C-j>', '<Esc>', { noremap = true })
vim.api.nvim_set_keymap('v', '<C-j>', '<Esc>', { noremap = true })

--Remap escape to leave terminal mode
vim.api.nvim_exec([[
  augroup Terminal
    autocmd!
    au TermOpen * tnoremap <buffer> <Esc> <c-\><c-n>
    au TermOpen * set nonu
  augroup end
]], false)

--Map blankline
vim.g.indent_blankline_char = "┊"
vim.g.indent_blankline_filetype_exclude = { 'help' }
vim.g.indent_blankline_buftype_exclude = { 'terminal', 'nofile', 'packer' }
vim.g.indent_blankline_char_highlight = 'LineNr'

-- Toggle to disable mouse mode and indentlines for easier paste
ToggleMouse = function()
  if vim.o.mouse == 'a' then
    vim.cmd [[IndentBlanklineDisable]]
    vim.wo.signcolumn = 'no'
    vim.o.mouse = 'v'
    vim.wo.number = false
    print("Mouse disabled")
  else
    vim.cmd [[IndentBlanklineEnable]]
    vim.wo.signcolumn = 'yes'
    vim.o.mouse = 'a'
    vim.wo.number = true
    print("Mouse enabled")
  end
end

vim.api.nvim_set_keymap('n', '<F10>', '<cmd>lua ToggleMouse()<cr>', { noremap = true })

-- Highlight on yank
vim.api.nvim_exec([[
  augroup YankHighlight
    autocmd!
    autocmd TextYankPost * silent! lua vim.highlight.on_yank()
  augroup end
]], false)

-- Y yank until the end of line
vim.api.nvim_set_keymap('n', 'Y', 'y$', { noremap = true })



--------------------------------------
---------- Plugin Manager ------------
--------------------------------------

-- Install packer
local execute = vim.api.nvim_command
local install_path = vim.fn.stdpath('data') .. '/site/pack/packer/opt/packer.nvim'

if vim.fn.empty(vim.fn.glob(install_path)) > 0 then
  execute('!git clone https://github.com/wbthomason/packer.nvim ' .. install_path)
end

vim.cmd [[packadd packer.nvim]]
vim.api.nvim_exec([[
  augroup Packer
    autocmd!
    autocmd BufWritePost plugins.lua PackerCompile
  augroup end
]], false)

local use = require('packer').use
require('packer').startup(function()
  use { 'wbthomason/packer.nvim', opt = true }
  use 'tpope/vim-vinegar'
  use 'tpope/vim-surround'
  use 'tpope/vim-fugitive'
  use 'tpope/vim-rhubarb'
  use 'tpope/vim-repeat'
  use 'tpope/vim-sleuth'
  use 'tpope/vim-commentary'

  use { 'nvim-telescope/telescope.nvim', requires = { { 'nvim-lua/popup.nvim' }, { 'nvim-lua/plenary.nvim' } } }
  use { 'nvim-telescope/telescope-media-files.nvim' }
  use { 'nvim-treesitter/nvim-treesitter', run = ":TSUpdate" }
  use 'navarasu/onedark.nvim'
  use { 'lukas-reineke/indent-blankline.nvim' }
  use 'sheerun/vim-polyglot'
  use 'mikewest/vimroom'
  use 'preservim/nerdtree'
  use { 'lewis6991/gitsigns.nvim', requires = { 'nvim-lua/plenary.nvim' } }

  use {
    'neovim/nvim-lspconfig',
    'onsails/lspkind-nvim',
    'williamboman/mason.nvim',
    'williamboman/mason-lspconfig.nvim',
  }

  -- use 'hrsh7th/nvim-compe'
  use 'hrsh7th/nvim-cmp'
  use 'hrsh7th/cmp-nvim-lsp'
  use 'hrsh7th/cmp-buffer'
  use 'hrsh7th/cmp-path'
  use 'hrsh7th/cmp-nvim-lua'
  use 'hrsh7th/cmp-cmdline'
  use 'hrsh7th/cmp-nvim-lsp-signature-help'
  use 'L3MON4D3/LuaSnip'
  use 'daxindg/cmp-rainbow-fart'
  use 'uga-rosa/cmp-dictionary'

  use({
    "iamcco/markdown-preview.nvim",
    run = function() vim.fn["mkdp#util#install"]() end,
  })

  use {
    'martineausimon/nvim-lilypond-suite',
    requires = { 'MunifTanjim/nui.nvim' }
  }

  -- debugger
  use 'mfussenegger/nvim-dap'
  use { "rcarriga/nvim-dap-ui", requires = { "mfussenegger/nvim-dap" } }
end)

require("gitsigns-config")
require("cmp-config")
require("lsp-config")
require("scope-config")
require("nerd-config")
require("dap-config")
require("lily-config")
-- Treesitter
local ts = require("nvim-treesitter.configs")
ts.setup({
  highlight = { enable = true },
  indent = { enable = false }
})

require('onedark').load()
