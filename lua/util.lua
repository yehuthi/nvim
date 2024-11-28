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

return export
