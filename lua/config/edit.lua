local util = require('util')
local export = {}
function export.setup(spec)
	return util.append(spec, {
		{
			"justinmk/vim-sneak",
			keys = { "s", "S" },
			init = function()
				vim.g['sneak#label']  = 1
				vim.g['sneak#prompt'] = "🔎 " -- <- requries an emoji font
				require('sneak')
			end,
		}
	})
end
return export
