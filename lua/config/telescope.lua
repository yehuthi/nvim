local util = require("util")
local export = {}

function export.setup(spec)
	return util.append(spec, {
		{
			'nvim-telescope/telescope.nvim',
			event = 'VimEnter',
			dependencies = {
				'nvim-lua/plenary.nvim',
				{
					'nvim-telescope/telescope-fzf-native.nvim',
					build = 'make',
					cond = function()
						return vim.fn.executable 'make' == 1
					end
				},
				{ 'nvim-telescope/telescope-ui-select.nvim' },
				{ 'nvim-tree/nvim-web-devicons' },
			},
			config = function()
				require('telescope').setup {
					defaults = {
						prompt_prefix = " 🔭  ",
						selection_caret = " ➦ ",
					},
				}
				local fns = require 'telescope.builtin'
				vim.keymap.set('n', '<leader>ff', fns.find_files, { desc = "[F]ind [F]ile" })
				vim.keymap.set('n', '<leader>fh', fns.help_tags, { desc = "[F]ind [H]elp" })
				vim.keymap.set('n', '<leader>fg', fns.live_grep, { desc = "[F]ind [G]rep" })
			end
		}
	})
end

return export
