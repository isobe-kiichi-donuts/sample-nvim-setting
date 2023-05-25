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
})
