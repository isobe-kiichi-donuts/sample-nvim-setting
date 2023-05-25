-- 左に行数が表示される
vim.opt.number = true
-- 現在の行が強調表示される
vim.opt.cursorline = true
-- タブや末尾スペースが可視化される
vim.opt.list = true
-- タブを押した時にスペースが2個入力される
vim.opt.expandtab = true
vim.opt.tabstop = 2
-- インデントがスペース2個分で表示される
vim.opt.shiftwidth = 2
-- クリップボードと連携させる
vim.opt.clipboard:append('unnamedplus')


local keymap_opts = { noremap = true, silent = true }
-- ESC2回で検索結果のハイライトを消す
vim.keymap.set('n', '<ESC><ESC>', ':nohlsearch<CR>', keymap_opts)
-- s+hjklで分割画面を移動する
vim.keymap.set('n', 's', '<Nop>', keymap_opts)
vim.keymap.set('n', 'sh', '<C-w>h', keymap_opts)
vim.keymap.set('n', 'sj', '<C-w>j', keymap_opts)
vim.keymap.set('n', 'sk', '<C-w>k', keymap_opts)
vim.keymap.set('n', 'sl', '<C-w>l', keymap_opts)


-- プラグインマネージャーが入っていなければインストールする
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable", -- latest stable release
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

-- 各種プラグインの設定
require('lazy').setup({
  -- カラースキーマの設定
  {
    'catppuccin/nvim',
    name = 'catppuccin',
    config = function()
      require('catppuccin').setup({
        flavour = 'frappe',
        integrations = {
          neotree = true,
        },
      })
      vim.opt.termguicolors = true
      vim.cmd([[colorscheme catppuccin]])
    end,
  },
  -- シンタックスハイライトの設定
  {
    'nvim-treesitter/nvim-treesitter',
    config = function()
      require('nvim-treesitter.configs').setup({
        ensure_installed = {'lua', 'go'},
        highlight = {
          enable = true,
        },
      })
    end,
  },
  -- ステータスラインの設定
  {
    'nvim-lualine/lualine.nvim',
    dependencies = {
      'nvim-tree/nvim-web-devicons',
    },
    config = function()
      require('lualine').setup({
        opts = {
          options = {
            theme = 'catppuccin',
          },
        },
      })
      vim.opt.showmode = false
    end,
  },
  -- ファイラーの設定
  {
    'nvim-neo-tree/neo-tree.nvim',
    branch = 'v2.x',
    dependencies = {
      'nvim-lua/plenary.nvim',
      'nvim-tree/nvim-web-devicons',
      'MunifTanjim/nui.nvim',
    },
    config = function ()
      vim.keymap.set('n', '<C-n>', function ()
        require('neo-tree.command').execute({ position = 'float', toggle = true, reveal = true })
      end, { noremap = true, silent = true })
    end,
  },
  -- ファインダーの設定
  {
    'nvim-telescope/telescope.nvim',
    branch = '0.1.x',
    dependencies = {
      'nvim-lua/plenary.nvim',
    },
    config = function()
      local function builtin(name, opts)
        return function()
          require('telescope.builtin')[name](opts)
        end
      end
      local keymap_opts = { noremap = true, silent = true }

      vim.keymap.set('n', ',f', builtin('find_files'), keymap_opts)
      vim.keymap.set('n', ',r', builtin('live_grep'), keymap_opts)
    end,
  },
  -- バッファラインの設定
  {
    'akinsho/bufferline.nvim',
    version = '3.*',
    dependencies = {
      'catppuccin',
      'nvim-tree/nvim-web-devicons',
    },
    opts = function ()
      return {
        highlights = require('catppuccin.groups.integrations.bufferline').get(),
      }
    end,
    config = function()
      require("bufferline").setup({
        highlights = require('catppuccin.groups.integrations.bufferline').get(),
      })

      local keymap_opts = { noremap = true, silent = true }
      vim.keymap.set('n', 'qn', ':BufferLineCycleNext<CR>', keymap_opts)
      vim.keymap.set('n', 'qp', ':BufferLineCyclePrev<CR>', keymap_opts)
      vim.keymap.set('n', 'qd', ':bdelete<CR>', keymap_opts)
    end
  },
  -- 言語サーバーの設定
  {
    'neovim/nvim-lspconfig',
    dependencies = {
      -- 'hrsh7th/cmp-nvim-lsp',
      'williamboman/mason-lspconfig.nvim',
    },
    config = function()
      local on_attach = function(client, bufnr)
        local bufopts = { noremap = true, silent = true, buffer = bufnr }
        vim.keymap.set('n', 'gn', vim.diagnostic.goto_next, keymap_opts)
        vim.keymap.set('n', 'gp', vim.diagnostic.goto_prev, keymap_opts)
        vim.keymap.set('n', 'gd', vim.lsp.buf.definition, bufopts)
        vim.keymap.set('n', 'gh', vim.lsp.buf.hover, bufopts)
      end

      local lsp_flags = {
        debounce_text_changes = 150,
      }

      local on_attach_gopls = function(client, bufnr)
        on_attach(client, bufnr)
        vim.api.nvim_create_autocmd('BufWritePre', {
          buffer = bufnr,
          callback = function()
            -- 保存時にパッケージをインポートする
            local params = vim.lsp.util.make_range_params(nil, vim.lsp.util._get_offset_encoding())
            params.context = { only = { 'source.organizeImports' }}
            local result = vim.lsp.buf_request_sync(0, 'textDocument/codeAction', params)
            for _, res in pairs(result or {}) do
              for _, r in pairs(res.result or {}) do
                if r.edit then
                  vim.lsp.util.apply_workspace_edit(r.edit, vim.lsp.util._get_offset_encoding())
                else
                  vim.lsp.buf.execute_command(r.command)
                end
              end
            end
            -- 保存時にフォーマットする
            vim.lsp.buf.format({ async = false })
          end
        })
      end

      -- local capabilities = require('cmp_nvim_lsp').default_capabilities()
      require('lspconfig')['gopls'].setup({
        on_attach = on_attach_gopls,
        flags = lsp_flags,
      })
    end,
  },
  {
    'williamboman/mason.nvim',
    config = true,
  },
  {
    'williamboman/mason-lspconfig.nvim',
    dependencies = { 'williamboman/mason.nvim' },
    config = true,
  },
})
