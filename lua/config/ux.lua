local util = require("util")
local export = {}

export.lazy_spec = {
	{
		'folke/which-key.nvim',
		event = "VeryLazy",
		keys = {
			{
				"<leader>?",
				function()
					require("which-key").show({ global = false })
				end,
				desc = "Buffer Local Keymaps (which-key)",
			},
		},
	},
}

function export.setup(spec)
	return util.append(spec, export.lazy_spec)
end

return export
