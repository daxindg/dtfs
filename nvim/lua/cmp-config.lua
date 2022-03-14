-- Set completeopt to have a better completion experience
vim.o.completeopt="menuone,noinsert,noselect"

local cmp = require('cmp')
local lspkind = require('lspkind')

local source_mapping = {
  buffer = "[Buffer]",
  nvim_lsp = "[LSP]",
  nvim_lua = "[Lua]",
  cmp_tabnine = "[TN]",
  path = "[Path]",
  copilot = "[CP]",
  nvim_lsp_signature_help = "[Sig]"
}

-- local tabnine = require('cmp_tabnine.config')
-- tabnine:setup({
--   max_lines = 1000;
--   max_num_results = 20;
--   sort = true;
--   run_on_every_keystroke = true;
--   snippet_placeholder = '..';
--   ignored_file_types = { -- default is not to ignore
--     -- lua = true
--   };
-- })

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
    { name = 'nvim_lsp' },
    { name = 'nvim_lua' },
    { name = 'copilot'},
--    { name = 'cmp_tabnine'},
    { name = 'nvim_lsp_signature_help'},
  }, {
    { name = 'buffer' },
  }),
  preselect = cmp.PreselectMode.None,
  formatting = {
    format = function(entry, vim_item)
      vim_item.kind = lspkind.presets.default[vim_item.kind] .. ' ' .. vim_item.kind
      if entry.source.name == 'cmp_tabnine' then
        vim_item.kind = ''
        if entry.completion_item.data ~= nil and entry.completion_item.data.detail ~= nil then
          vim_item.kind = vim_item.kind .. ' ' ..  entry.completion_item.data.detail
        end
      end
      vim_item.menu = source_mapping[entry.source.name]
      return vim_item
    end
  },
  experimental = {
    native_menu = false,
    ghost_text = true,
  }
})

