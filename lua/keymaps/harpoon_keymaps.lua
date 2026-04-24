-- Harpoon v2 keymaps
-- https://github.com/ThePrimeagen/harpoon/tree/harpoon2

local ok, harpoon = pcall(require, "harpoon")
if not ok then return end

local map = vim.keymap.set

map("n", "<leader>ha", function() harpoon:list():add() end,            { desc = "Harpoon: add file" })
map("n", "<leader>hh", function() harpoon.ui:toggle_quick_menu(harpoon:list()) end, { desc = "Harpoon: toggle menu" })

map("n", "<leader>1", function() harpoon:list():select(1) end, { desc = "Harpoon: file 1" })
map("n", "<leader>2", function() harpoon:list():select(2) end, { desc = "Harpoon: file 2" })
map("n", "<leader>3", function() harpoon:list():select(3) end, { desc = "Harpoon: file 3" })
map("n", "<leader>4", function() harpoon:list():select(4) end, { desc = "Harpoon: file 4" })
map("n", "<leader>5", function() harpoon:list():select(5) end, { desc = "Harpoon: file 5" })

map("n", "<leader>hn", function() harpoon:list():next() end, { desc = "Harpoon: next pin" })
map("n", "<leader>hp", function() harpoon:list():prev() end, { desc = "Harpoon: prev pin" })
