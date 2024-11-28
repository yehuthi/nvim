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

export.augroup = function(name)
	return vim.api.nvim_create_augroup(name, { clear = true })
end

---@param path string
---@return table?
function export.require_try(path)
	local ok, module = pcall(require, path)
	return ok and module or nil
end

return export
