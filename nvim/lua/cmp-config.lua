-- Set completeopt to have a better completion experience
vim.o.completeopt = "menuone,noinsert,noselect"

local cmp = require('cmp')
local lspkind = require('lspkind')

cmp.setup({
  snippet = {
    -- REQUIRED - you must specify a snippet engine
    expand = function(args)
      -- vim.fn["vsnip#anonymous"](args.body) -- For `vsnip` users.
      require('luasnip').lsp_expand(args.body) -- For `luasnip` users.
      -- vim.fn["UltiSnips#Anon"](args.body) -- For `ultisnips` users.
      -- require'snippy'.expand_snippet(args.body) -- For `snippy` users.
    end,
  },
  mapping = {
    ['<C-n>'] = cmp.mapping.select_next_item({ behavior = cmp.SelectBehavior.Insert }),
    ['<C-p>'] = cmp.mapping.select_prev_item({ behavior = cmp.SelectBehavior.Insert }),
    ['<C-b>'] = cmp.mapping(cmp.mapping.scroll_docs(-4), { 'i', 'c' }),
    ['<C-f>'] = cmp.mapping(cmp.mapping.scroll_docs(4), { 'i', 'c' }),
    ['<C-Space>'] = cmp.mapping(cmp.mapping.complete(), { 'i', 'c' }),
    ['<C-y>'] = cmp.config.disable, -- Specify `cmp.config.disable` if you want to remove the default `<C-y>` mapping.
    ['<C-e>'] = cmp.mapping({
      i = cmp.mapping.abort(),
      c = cmp.mapping.close(),
    }),
    -- Accept currently selected item. If none selected, `select` first item.
    -- Set `select` to `false` to only confirm explicitly selected items.
    ['<CR>'] = cmp.mapping.confirm({ select = true }),
  },
  sources = cmp.config.sources({
    { name = 'rbfart', option = { on = false } },
    { name = 'nvim_lsp' },
    { name = 'nvim_lua' },
    { name = 'nvim_lsp_signature_help' },
    { name = 'dictionary' },
    { name = 'path' },
    -- { name = 'copilot' },
  }, {
    { name = 'buffer' },
  }),
  preselect = cmp.PreselectMode.None,
  formatting = {
    format = function(entry, vim_item)
      local kind = ({
        cmp_tabnine = ' ',
        copilot     = ' ',
        path        = '󰉋 ',
        dictionary  = ' ',
        buffer      = '󰈙 ',
      })[entry.source.name]
      if (kind == nil) then
        kind = lspkind.presets.default[vim_item.kind]
      end

      vim_item.kind = kind .. ' ' .. vim_item.kind

      vim_item.menu = ({
        buffer = "[Buffer]",
        dictionary = "[DIR]",
        nvim_lsp = "[LSP]",
        nvim_lua = "[Lua]",
        cmp_tabnine = "[TN]",
        path = "[Path]",
        nvim_lsp_signature_help = "[Sig]",
        rbfart = "[rf]",
        copilot = "[CP]",
      })[entry.source.name]
      return vim_item
    end
  },
  experimental = {
    native_menu = false,
    ghost_text = true,
  }
})
