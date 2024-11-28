local util = require("util")

local export = {}

function export.setup(spec)
	return util.append(spec, {
		{
			'stevearc/oil.nvim',
			dependencies = { { "echasnovski/mini.icons", opts = {} } },
			opts = {
				view_options = {
					show_hidden = true,
				},
			},
		}
	})
end

return export
