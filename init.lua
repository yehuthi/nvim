local util = require("util")
require("config.editor").setup {}

local lazy_spec = {}
lazy_spec = require("config.visual").setup(lazy_spec, {})
lazy_spec = require("config.git").setup(lazy_spec)
lazy_spec = require("config.files").setup(lazy_spec)
lazy_spec = require("config.telescope").setup(lazy_spec)
lazy_spec = require("config.lsp").setup(lazy_spec)

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

