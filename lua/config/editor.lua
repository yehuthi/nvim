local export = {}

---@class config
---@field leader? string
---@field column_marker? integer
---@field clipboard? boolean

---@type config
local config_default = {
	leader = '\\',
	column_marker = 75,
	clipboard = false,
}

---@param config config
function export.setup(config)
	config = config or {}

	vim.g.mapleader      = config.leader or config_default.leader
	vim.g.maplocalleader = vim.g.mapleader

	vim.opt.number         = true
	vim.opt.relativenumber = true

	vim.opt.undofile   = true
	vim.opt.updatetime = 250

	vim.opt.ignorecase = true
	vim.opt.smartcase  = true

	vim.opt.signcolumn = 'yes'
	vim.opt.inccommand = 'split'
	vim.opt.cursorline = true
	vim.opt.scrolloff  = 2

	vim.opt.breakindent = true
	vim.opt.mouse       = 'a'

	vim.opt.colorcolumn = tostring(
		(config.column_marker or config_default.column_marker) + 1
	)

	if config.clipboard ~= nil and config.clipboard
		or config_default.clipboard
	then
		vim.schedule(function() vim.opt.clipboard = 'unnamedplus' end)
	end

	vim.opt.list = true
	vim.opt.listchars = {
		tab   = '  ',
		trail = '·' ,
		nbsp  = '␣' ,
	}

	vim.cmd [[
		set foldmethod=marker
	]]

	vim.keymap.set('n', '<Esc>', '<cmd>nohlsearch<CR>')

	-- windows navigation
	for key, desc in pairs
		{ h = 'left', l = 'right', j = 'lower', k = 'upper' }
	do
		vim.keymap.set('n',
			string.format('<C-%s>', key),
			string.format('<C-w><C-%s>', key),
			{ desc = string.format('Move focus to the %s window', desc) })
	end
	-- Configure how new splits should be opened
	vim.opt.splitright = true
	vim.opt.splitbelow = true

end

return export
