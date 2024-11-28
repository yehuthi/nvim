local util = require("util")

local export = {}

export.lazy = {
	{
		"NeogitOrg/neogit",
		dependencies = {
			"nvim-lua/plenary.nvim",
			{
				"nvim-telescope/telescope.nvim",
				optional = true,
			},
			"sindrets/diffview.nvim",
		},
		config = true,
	},
}

function export.setup(spec)
	return util.append(spec, export.lazy)
end

return export
