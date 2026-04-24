-- DBUI keymaps — all under <leader>d
-- Note: <leader>dl and <leader>dq are reserved for LSP diagnostics

local map = vim.keymap.set
local opts = { noremap = true, silent = true }

-- Panel
map('n', '<leader>db', '<cmd>DBUIToggle<CR>',        vim.tbl_extend('force', opts, { desc = "Toggle DBUI panel" }))
map('n', '<leader>da', '<cmd>DBUIAddConnection<CR>',  vim.tbl_extend('force', opts, { desc = "Add DB connection" }))
map('n', '<leader>df', '<cmd>DBUIFindBuffer<CR>',     vim.tbl_extend('force', opts, { desc = "Find buffer in DB tree" }))
map('n', '<leader>do', '<cmd>DBUI<CR>',               vim.tbl_extend('force', opts, { desc = "Open DBUI" }))

-- Quick-reference: buffer-local mappings set by DBUI in query/result buffers
-- (these are active automatically when inside a DBUI buffer)
--
--   <leader>S  — execute current statement
--   <leader>W  — save query (prompts for name)
--   <leader>E  — edit saved query name
--   <leader>R  — rename result buffer
--   <leader>gj — jump to foreign key result
--   [t / ]t    — navigate between result sets
