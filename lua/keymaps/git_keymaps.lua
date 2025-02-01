vim.api.nvim_set_keymap('n', '<leader>gg', ':GitMessenger<CR>',
    { noremap = true, silent = true, desc = "Show git commit message" })

vim.keymap.set("n", "<leader>gl", "2do", { desc = "Keep LOCAL version (Your changes)" })  -- Local
vim.keymap.set("n", "<leader>gr", "4do", { desc = "Keep REMOTE version (Their changes)" })  -- Remote

vim.keymap.set("n", "<leader>gn", "]c", { desc = "Next Git conflict" })  -- Move to next conflict
vim.keymap.set("n", "<leader>gp", "[c", { desc = "Previous Git conflict" })  -- Move to previous conflict
