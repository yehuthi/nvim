require("config.editor").setup {}

local lazy_spec = {}
lazy_spec = require("config.visual").setup(lazy_spec, {})

require("config.lazy").setup(lazy_spec)
