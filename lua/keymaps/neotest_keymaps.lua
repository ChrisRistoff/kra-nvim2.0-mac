-- Neotest keymaps — under <leader>n (n for "neotest"), to avoid clashing with
-- existing <leader>t* (typescript-tools) and <leader>tf (conform toggle).

local ok, neotest = pcall(require, "neotest")
if not ok then return end

local map = vim.keymap.set

map("n", "<leader>nt", function() neotest.run.run() end,                              { desc = "Neotest: run nearest" })
map("n", "<leader>nf", function() neotest.run.run(vim.fn.expand("%")) end,            { desc = "Neotest: run file" })
map("n", "<leader>nl", function() neotest.run.run_last() end,                         { desc = "Neotest: run last" })
map("n", "<leader>ns", function() neotest.summary.toggle() end,                       { desc = "Neotest: toggle summary" })
map("n", "<leader>no", function() neotest.output.open({ enter = true, auto_close = true }) end, { desc = "Neotest: open output" })
map("n", "<leader>np", function() neotest.output_panel.toggle() end,                  { desc = "Neotest: toggle output panel" })
map("n", "<leader>nx", function() neotest.run.stop() end,                             { desc = "Neotest: stop" })
