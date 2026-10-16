-- Build hook: must be defined BEFORE vim.pack.add so it fires on first install
vim.api.nvim_create_autocmd("PackChanged", {
  callback = function(ev)
    local name, kind = ev.data.spec.name, ev.data.kind
    if name == "sqmeow.nvim" and (kind == "install" or kind == "update") then
      if not ev.data.active then vim.cmd.packadd("sqmeow.nvim") end
      require("sqmeow").install() -- or install("curl"), install("cargo"), etc.
    end
  end,
})

vim.pack.add({
  "https://github.com/MunifTanjim/nui.nvim", -- dependency, listed first
  { src = "https://github.com/2giosangmitom/sqmeow.nvim", version = vim.version.range("*") },
})

require("sqmeow").setup({})

vim.keymap.set("n", "<leader>Dd", "<cmd>Sqmeow toggle<cr>", { desc = "Toggle" })
vim.keymap.set("n", "<leader>Dc", "<cmd>Sqmeow cancel<cr>", { desc = "Cancel" })
vim.keymap.set("n", "<leader>Da", "<cmd>Sqmeow add<cr>", { desc = "Add Connection" })
vim.keymap.set("n", "<leader>Ds", "<cmd>Sqmeow scratch<cr>", { desc = "New Scratchpad" })
