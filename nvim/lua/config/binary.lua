if vim.fn.executable("xxd") ~= 1 then
  vim.notify("xxd not found. Binary mode disabled.", vim.log.levels.WARN)
  return
end

local applied_buffers = {}

local function apply_xxd(bufnr)
  bufnr = bufnr or vim.api.nvim_get_current_buf()
  if applied_buffers[bufnr] then
    return
  end

  local ok, err = pcall(function()
    vim.cmd("silent %!xxd -g 1")
  end)

  if ok then
    applied_buffers[bufnr] = true
    vim.bo[bufnr].filetype = "xxd"
  else
    vim.notify("xxd failed: " .. tostring(err), vim.log.levels.ERROR)
  end
end

local group = vim.api.nvim_create_augroup("BinaryXXD", { clear = true })

vim.api.nvim_create_user_command("Binary", function()
  local bufnr = vim.api.nvim_get_current_buf()
  apply_xxd(bufnr)
end, { desc = "Enable binary editing mode with xxd" })

vim.api.nvim_create_user_command("BinaryOff", function()
  local bufnr = vim.api.nvim_get_current_buf()
  if not applied_buffers[bufnr] then
    vim.notify("Binary mode is not active for this buffer", vim.log.levels.WARN)
    return
  end
  if vim.bo[bufnr].modified then
    vim.notify("Buffer has unsaved changes. Save first or use :e!", vim.log.levels.ERROR)
    return
  end
  applied_buffers[bufnr] = nil
  vim.cmd("silent edit!")
end, { desc = "Disable binary editing mode" })

vim.api.nvim_create_autocmd("BufWritePre", {
  group = group,
  pattern = "*",
  callback = function(ev)
    if applied_buffers[ev.buf] then
      local ok, err = pcall(function()
        vim.cmd("silent %!xxd -r")
      end)
      if not ok then
        vim.notify("xxd -r failed: " .. tostring(err), vim.log.levels.ERROR)
        error("xxd -r failed, aborting write")
      end
    end
  end,
})

vim.api.nvim_create_autocmd("BufWritePost", {
  group = group,
  pattern = "*",
  callback = function(ev)
    if applied_buffers[ev.buf] then
      applied_buffers[ev.buf] = nil
      apply_xxd(ev.buf)
    end
  end,
})

vim.api.nvim_create_autocmd({ "BufWipeout", "BufDelete" }, {
  group = group,
  pattern = "*",
  callback = function(ev)
    applied_buffers[ev.buf] = nil
  end,
})
