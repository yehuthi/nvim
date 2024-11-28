local util = require("util")
local export = {}

local lazy_spec = {
	{
		'folke/tokyonight.nvim',
		priority = 1000,
		init = function ()
			vim.cmd.colorscheme 'tokyonight-night'
		end
	},
	{
		'folke/todo-comments.nvim',
		event = 'VimEnter',
		dependencies = { 'nvim-lua/plenary.nvim' },
		opts = { signs = true }
	},
	{
		'lewis6991/gitsigns.nvim',
		opts = {
			signs = {
				add			 = { text = '+' },
				change		 = { text = '~' },
				delete		 = { text = '_' },
				topdelete	 = { text = '‾' },
				changedelete = { text = '~' },
			},
		},
	},

}

---@class config
---@field yank_highlight? integer

---@type config
local config_default = {
	yank_highlight = 150
}

---@param spec table
---@param config config
---@return table
function export.setup(spec, config)
	config = config or {}
	local yank_timeout = config.yank_highlight
	or config_default.yank_highlight
	if yank_timeout then
		vim.api.nvim_create_autocmd('TextYankPost', {
			desc = 'Highlight when yanking (copying) text',
			group = vim.api.nvim_create_augroup(
			'highlight-yank', { clear = true }
			),
			callback = function()
				vim.highlight.on_yank({ timeout = yank_timeout })
			end,
		})
	end
	return util.append(spec, lazy_spec)
end

export.lazy = lazy_spec

return export
