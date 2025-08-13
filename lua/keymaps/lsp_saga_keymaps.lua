local opts = { noremap = true, silent = true }

-- DIAGNOSTIC KEYMAPS (your existing ones - these look correct)
-- Show diagnostics on the current line
vim.keymap.set('n', '<leader>cdd', '<cmd>Lspsaga show_line_diagnostics<CR>',
    vim.tbl_extend('force', opts, { desc = 'Show Line Diagnostics' }))
-- Jump to the previous diagnostic
vim.keymap.set('n', '<leader>cde', '<cmd>Lspsaga diagnostic_jump_prev<CR>',
    vim.tbl_extend('force', opts, { desc = 'Previous Diagnostic' }))
-- Jump to the next diagnostic
vim.keymap.set('n', '<leader>cdq', '<cmd>Lspsaga diagnostic_jump_next<CR>',
    vim.tbl_extend('force', opts, { desc = 'Next Diagnostic' }))
-- Show all diagnostics in buffer
vim.keymap.set('n', '<leader>cda', '<cmd>Lspsaga show_buf_diagnostics<CR>',
    vim.tbl_extend('force', opts, { desc = 'Show All Diagnostics' }))
-- Show diagnostics where the cursor is
vim.keymap.set('n', '<leader>cdc', '<cmd>Lspsaga show_cursor_diagnostics<CR>',
    vim.tbl_extend('force', opts, { desc = 'Show Cursor Diagnostics' }))

-- HOVER AND DOCUMENTATION
-- Hover documentation
vim.keymap.set('n', 'K', '<cmd>Lspsaga hover_doc<CR>', vim.tbl_extend('force', opts, { desc = 'Hover Documentation' }))

-- CALL HIERARCHY (your existing ones - these are correct)
-- View incoming calls to the symbol under cursor
vim.keymap.set('n', '<leader>ce', '<cmd>Lspsaga incoming_calls<CR>',
    vim.tbl_extend('force', opts, { desc = 'Incoming Calls' }))
-- View outgoing calls from the symbol under cursor
vim.keymap.set('n', '<leader>cq', '<cmd>Lspsaga outgoing_calls<CR>',
    vim.tbl_extend('force', opts, { desc = 'Outgoing Calls' }))

-- DEFINITION AND TYPE (your existing ones - these are correct)
-- Peek type definition without moving
vim.keymap.set('n', '<leader>ct', '<cmd>Lspsaga peek_type_definition<CR>',
    vim.tbl_extend('force', opts, { desc = 'Peek Type Definition' }))

-- FINDER AND OUTLINE (your existing ones - these are correct)
-- Finder to search and preview LSP entities
vim.keymap.set('n', '<leader>cf', '<cmd>Lspsaga finder<CR>', vim.tbl_extend('force', opts, { desc = 'LSP Finder' }))
-- Show outline of the current file
vim.keymap.set('n', '<leader>co', '<cmd>Lspsaga outline<CR>', vim.tbl_extend('force', opts, { desc = 'LSP Outline' }))

-- RENAME (your existing one - this is correct)
-- Rename the symbol under cursor
vim.keymap.set('n', '<leader>cr', '<cmd>Lspsaga rename<CR>', vim.tbl_extend('force', opts, { desc = 'Rename Symbol' }))

-- ADDITIONAL VERIFIED KEYMAPS

-- Code Actions
vim.keymap.set({ 'n', 'v' }, '<leader>ca', '<cmd>Lspsaga code_action<CR>',
    vim.tbl_extend('force', opts, { desc = 'Code Actions' }))

-- More Definition/Type Navigation
vim.keymap.set('n', '<leader>cgd', '<cmd>Lspsaga peek_definition<CR>',
    vim.tbl_extend('force', opts, { desc = 'Peek Definition' }))
vim.keymap.set('n', '<leader>cgg', '<cmd>Lspsaga goto_definition<CR>',
    vim.tbl_extend('force', opts, { desc = 'Go to Definition' }))
vim.keymap.set('n', '<leader>cgt', '<cmd>Lspsaga goto_type_definition<CR>',
    vim.tbl_extend('force', opts, { desc = 'Go to Type Definition' }))

-- Workspace Diagnostics
vim.keymap.set('n', '<leader>cdw', '<cmd>Lspsaga show_workspace_diagnostics<CR>',
    vim.tbl_extend('force', opts, { desc = 'Show Workspace Diagnostics' }))

-- Project-wide Rename
vim.keymap.set('n', '<leader>cR', '<cmd>Lspsaga rename ++project<CR>',
    vim.tbl_extend('force', opts, { desc = 'Rename in Project' }))

-- Peek Implementation (if supported by your LSP server)
vim.keymap.set('n', '<leader>ci', '<cmd>Lspsaga finder imp<CR>',
    vim.tbl_extend('force', opts, { desc = 'Find Implementations' }))

-- Terminal Toggle
vim.keymap.set({ 'n', 't' }, '<leader>ctt', '<cmd>Lspsaga term_toggle<CR>',
    vim.tbl_extend('force', opts, { desc = 'Toggle Terminal' }))

-- ERROR/WARNING SPECIFIC NAVIGATION (using lua functions for filtering)
-- Next/Previous Error only
vim.keymap.set('n', '<leader>cee', function()
    require("lspsaga.diagnostic"):goto_next({ severity = vim.diagnostic.severity.ERROR })
end, vim.tbl_extend('force', opts, { desc = 'Next Error' }))

vim.keymap.set('n', '<leader>ceE', function()
    require("lspsaga.diagnostic"):goto_prev({ severity = vim.diagnostic.severity.ERROR })
end, vim.tbl_extend('force', opts, { desc = 'Previous Error' }))

-- Next/Previous Warning only
vim.keymap.set('n', '<leader>cww', function()
    require("lspsaga.diagnostic"):goto_next({ severity = vim.diagnostic.severity.WARN })
end, vim.tbl_extend('force', opts, { desc = 'Next Warning' }))

vim.keymap.set('n', '<leader>cwW', function()
    require("lspsaga.diagnostic"):goto_prev({ severity = vim.diagnostic.severity.WARN })
end, vim.tbl_extend('force', opts, { desc = 'Previous Warning' }))

-- ALTERNATIVE FALLBACK KEYMAPS (if lspsaga commands don't work)
-- These use native vim.diagnostic and vim.lsp functions as fallbacks

-- Fallback: Show diagnostics in float
vim.keymap.set('n', '<leader>cdf', function()
    vim.diagnostic.open_float(nil, {
        focusable = false,
        close_events = { "BufLeave", "CursorMoved", "InsertEnter", "FocusLost" },
        border = 'rounded',
        source = 'always',
        prefix = ' ',
        scope = 'cursor',
    })
end, vim.tbl_extend('force', opts, { desc = 'Float Diagnostic' }))

-- Fallback: Native LSP hover
vim.keymap.set('n', '<leader>ch', vim.lsp.buf.hover, vim.tbl_extend('force', opts, { desc = 'LSP Hover (fallback)' }))
