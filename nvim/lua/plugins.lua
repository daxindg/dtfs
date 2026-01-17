return {
  'tpope/vim-vinegar',
  'tpope/vim-surround',
  'tpope/vim-fugitive',
  'tpope/vim-rhubarb',
  'tpope/vim-repeat',
  'tpope/vim-sleuth',
  'tpope/vim-commentary',
  {
    "ibhagwan/fzf-lua",
    -- optional for icon support
    dependencies = { "nvim-tree/nvim-web-devicons" },
    -- or if using mini.icons/mini.nvim
    -- dependencies = { "nvim-mini/mini.icons" },
    ---@module "fzf-lua"
    ---@type fzf-lua.Config|{}
    ---@diagnostic disable: missing-fields
    opts = {},
	config = function()
      require("fzf-lua").setup {}
	  vim.api.nvim_set_keymap('n', '<leader>f', [[<cmd>lua FzfLua.global()<cr>]], { noremap = true, silent = true})
	  vim.api.nvim_set_keymap('n', '<leader>rg', [[<cmd>lua FzfLua.live_grep()<cr>]], { noremap = true, silent = true})
	end
    ---@diagnostic enable: missing-fields
  },
  {
    'nvim-treesitter/nvim-treesitter',
    build = ':TSUpdate'
  },

  {
    'lewis6991/gitsigns.nvim',
    config = function()
      require('config.gitsigns');
    end
  },
  {
    "nvim-tree/nvim-tree.lua",
    version = "*",
    lazy = false,
    dependencies = {
      "nvim-tree/nvim-web-devicons",
    },
    config = function()
      require("nvim-tree").setup {}

      vim.api.nvim_set_keymap('n', '<leader>n', ':NvimTreeToggle<CR>', {noremap= true, silent = true})
      vim.api.nvim_set_keymap('n', '<C-f>', ':NvimTreeFindFile<CR>', {noremap= true, silent = true})
    end,
  },
  {
    'navarasu/onedark.nvim',
    config = function()
      local onedark = require('onedark')
      onedark.setup {
        transparent = true,
      };
      onedark.load()
    end
  },
  {
    'lukas-reineke/indent-blankline.nvim',
    main = "ibl",
    opts = {},
    config = function()
      require('ibl').setup({
        indent = { char = "┊" },
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

  { 'terrastruct/d2-vim', ft = { "d2" } },

  -- cmp
  {
    'hrsh7th/nvim-cmp',
    dependencies = {
      'hrsh7th/cmp-nvim-lsp',
      'hrsh7th/cmp-buffer',
      'hrsh7th/cmp-path',
      --'hrsh8th/cmp-nvim-lua',
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

  -- {
  --   'daxindg/cmp-codeverse',
  --   dir = '/Users/bytedance/repos/cmp-codeverse/',
  --   config = function ()
  --     require('cmp_codeverse')
  --   end
  -- },

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
