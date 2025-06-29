return {
  'tpope/vim-vinegar',
  'tpope/vim-surround',
  'tpope/vim-fugitive',
  'tpope/vim-rhubarb',
  'tpope/vim-repeat',
  'tpope/vim-sleuth',
  'tpope/vim-commentary',

  {
    'nvim-telescope/telescope.nvim',
    tag = '0.1.4',
    dependencies = {
      'nvim-lua/plenary.nvim',
      'nvim-telescope/telescope-media-files.nvim',
    },
    config = function ()
      require('config.telescope')
    end
  },

  {
    'nvim-treesitter/nvim-treesitter',
    build = ':TSUpdate',
    config = function()
      local ts = require("nvim-treesitter.configs");
      ts.setup({
        highlight = { enable = true },
        indent = { enable = false }
      });
    end
  },

  {
    'lewis6991/gitsigns.nvim',
    config = function()
      require('config.gitsigns');
    end
  },

  -- TODO: switch to nvim-tree
  {
    'preservim/nerdtree',
    config = function()
      require('config.nerdtree');
    end
  },
  {
    'navarasu/onedark.nvim',
    config = function()
      require('onedark').load();
    end
  },
  {
    'lukas-reineke/indent-blankline.nvim',
    main = "ibl",
    opts = {},
    config = function ()
      require('ibl').setup({
        indent = {char = "┊"},
        scope = { enabled = false },
      })
    end
  },

  -- LSP
  {
    'mason-org/mason-lspconfig.nvim',
    opts={},
    dependencies = {
      {'mason-org/mason.nvim', opts={}},
      { 
        'neovim/nvim-lspconfig', 
        config = function()
          require('config.lsp')
        end
      }
    }
  },

  -- cmp
  {
    'hrsh7th/nvim-cmp',
    dependencies = {
      'hrsh7th/cmp-nvim-lsp',
      'hrsh7th/cmp-buffer',
      'hrsh7th/cmp-path',
      'hrsh7th/cmp-nvim-lua',
      'hrsh7th/cmp-cmdline',
      'hrsh7th/cmp-nvim-lsp-signature-help',

      -- 'daxindg/cmp-rainbow-fart',
      'uga-rosa/cmp-dictionary',

      'onsails/lspkind-nvim',
    },
    config = function()
      require('config.cmp')
    end
  },

  'L3MON4D3/LuaSnip',

  {
    "iamcco/markdown-preview.nvim",
    cmd = { "MarkdownPreviewToggle", "MarkdownPreview", "MarkdownPreviewStop" },
    ft = { "markdown" },
    build = function() vim.fn["mkdp#util#install"]() end,
  },

  {
    'martineausimon/nvim-lilypond-suite',
    config = function()
      require('config.lilypond')
    end
  },

  -- dap
  {
    "mfussenegger/nvim-dap",
    dependencies = {
      "rcarriga/nvim-dap-ui",
      "nvim-neotest/nvim-nio",
    },
    config = function()
      require('config.dap')
    end
  },
}
