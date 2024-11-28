local util = require("util")
local export = {}

local servers = {
	lua_ls = {},
}

function export.setup(spec)
	return util.append(spec, {
		{
			'neovim/nvim-lspconfig',
			dependencies = {
				{ 'williamboman/mason.nvim', optional = true },
				{ 'j-hui/fidget.nvim', optional = true },
				{ 'hrsh7th/cmp-nvim-lsp', optional = true },
				{ 'nvim-telescope/telescope.nvim', optional = true },
			},
			config = function()
				util.autocmd('LspAttach', {
					group = util.augroup('init-lsp-attach'),
					callback = function(event)
						local bind = function(keys, func, desc, mode)
							mode = mode or 'n'
							vim.keymap.set(
								mode,
								keys,
								func,
								{
									buffer = event.buf,
									desc = 'LSP: ' .. desc,
								}
							)
						end
						local ts = util.require_try('telescope.builtin')
						if ts ~= nil then
							bind(
								'gd', ts.lsp_definitions,
								'[G]oto [D]efinition'
							)
							bind(
								'gr', ts.lsp_references,
								'[G]oto [R]eference'
							)
							bind(
								'gI', ts.lsp_implementations,
								'[G]oto [I]mplementation'
							)
							bind(
								'<leader>D', ts.lsp_type_definitions,
								'Type [D]efinition'
							)
							bind(
								'<leader>ds', ts.lsp_definitions,
								'[D]ocument [S]ymbols'
							)
							bind(
								'<leader>ws',
								ts.lsp_dynamic_workspace_symbols,
								'[W]orkspace [S]ymbols'
							)
						end
						bind(
							'<leader>rn', vim.lsp.buf.rename,
							'[R]e[n]ame'
						)
						bind(
							'<leader>ca', vim.lsp.buf.code_action,
							'[C]ode [A]ction'
						)
						bind(
							'gD', vim.lsp.buf.declaration,
							'[G]oto [D]eclaration'
						)

						local client =
							vim.lsp.get_client_by_id(event.data.client_id)
							if client and client.supports_method(vim.lsp.protocol.Methods.textDocument_inlayHint) then
								bind('<leader>th', function()
									vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled { bufnr = event.buf })
								end, '[T]oggle Inlay [H]ints')
							end

						if client and client.supports_method(vim.lsp.protocol.Methods.textDocument_documentHighlight) then
							local highlight_augroup = util.augroup('init-lsp-highlight')
							util.autocmd({ 'CursorHold', 'CursorHoldI' }, {
								buffer = event.buf,
								group = highlight_augroup,
								callback = vim.lsp.buf.document_highlight,
							})

							util.autocmd({ 'CursorMoved', 'CursorMovedI' }, {
								buffer = event.buf,
								group = highlight_augroup,
								callback = vim.lsp.buf.clear_references,
							})

							util.autocmd('LspDetach', {
								group = util.augroup('init-lsp-detach'),
								callback = function(detach_event)
									vim.lsp.buf.clear_references()
									vim.api.nvim_clear_autocmds { group = 'init-lsp-highlight', buffer = detach_event.buf }
								end,
							})
						end
					end
				})

				local lspconfig = require('lspconfig')
				for server, config in pairs(servers) do
					lspconfig[server].setup(config)
				end
			end
		},
		{
			'williamboman/mason.nvim',
			dependencies = {
				'williamboman/mason-lspconfig.nvim',
				'WhoIsSethDaniel/mason-tool-installer.nvim',
			},
			config = function()
				require('mason').setup {}
				local ensure_installed = vim.tbl_keys(servers)
				require('mason-tool-installer').setup {
					ensure_installed = ensure_installed
				}
			end
		},
	})
end

return export
