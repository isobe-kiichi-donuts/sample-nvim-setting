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
