local util = require("util")
require("config.editor").setup {}

local lazy_spec = util.fold({
	"visual", "git", "files", "telescope", "lsp", "ux", "edit",
}, function (spec, submodule)
	return require("config." .. submodule).setup(spec)
end, {})

require("config.lazy").setup {
	install = { colorscheme = { "habamax" } },
	checker = { enabled = true },
	spec = lazy_spec,
}

util.autocmd('VimEnter', {
	group = util.augroup('lazy-autoupdate'),
	callback = function()
		require("lazy").update({ show = false })
	end
})

