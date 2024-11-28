local export = {}

---comment
---@generic T
---@param a T[]
---@param b T[]
---@return T[]
function export.append(a, b)
	for _, value in ipairs(b) do
		a[#a+1] = value
	end
	return a
end

export.autocmd = vim.api.nvim_create_autocmd
export.augroup = vim.api.nvim_create_augroup

return export
