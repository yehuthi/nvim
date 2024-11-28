local util = require("util")
local export = {}

local servers = {
	lua_ls = {},
	cmake = {},
	ts_ls = {},
	svelte = {},
	sqlls = {},
	zls = {},
	clangd = {},
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
				local capabilities = vim.lsp.protocol.make_client_capabilities()
				local cmp = util.require_try('cmp_nvim_lsp')
				if cmp ~= nil then
					capabilities = vim.tbl_deep_extend('force',
						capabilities,
						cmp.default_capabilities()
					)
				end
				require('mason-lspconfig').setup {
					handlers = {
						function(server_name)
							local server = servers[server_name] or {}
							server.capabilities = vim.tbl_deep_extend('force',
								{}, capabilities, server.capabilities or {})
						end
					}
				}
			end
		},
		{
			'hrsh7th/nvim-cmp',
			dependencies = {
				'L3MON4D3/LuaSnip',
				'saadparwaiz1/cmp_luasnip',
				'hrsh7th/cmp-nvim-lsp',
				'hrsh7th/cmp-path',
			},
			build = (function()
				-- Build Step is needed for regex support in snippets.
				-- This step is not supported in many windows environments.
				-- Remove the below condition to re-enable on windows.
				if vim.fn.has 'win32' == 1 or vim.fn.executable 'make' == 0 then
					return
				end
				return 'make install_jsregexp'
			end)(),
			config = function()
				local cmp = require 'cmp'
				local luasnip = require 'luasnip'
				luasnip.config.setup {}


				local t = luasnip.text_node
				local choice = luasnip.choice_node
				luasnip.add_snippets('cmake', {
					luasnip.snippet('cmake_minimum_version', {
						t("cmake_minimum_required(VERSION 3.15...3.30)")
					})
				})
				luasnip.add_snippets('sql', {
					luasnip.snippet('primarypg', {
						t('id '),
						choice(1, { t('INTEGER'), t('SMALLINT'), t('BIGINT') }),
						t(' PRIMARY KEY GENERATED '),
						choice(2, {t('ALWAYS'), t('BY DEFAULT')}),
						t(' AS IDENTITY'),
					}),
				})
				cmp.setup {
					mapping = cmp.mapping.preset.insert {
						['<C-n>'] = cmp.mapping.select_next_item(),
						['<C-p>'] = cmp.mapping.select_prev_item(),
						['<C-b>'] = cmp.mapping.scroll_docs(-4),
						['<C-f>'] = cmp.mapping.scroll_docs(4),
						['<C-y>'] = cmp.mapping.confirm { select = true },
						['<Enter>'] = cmp.mapping.confirm { select = true },
						['<C-Space>'] = cmp.mapping.complete {},
						['<C-l>'] = cmp.mapping(function()
							if luasnip.expand_or_locally_jumpable() then
								luasnip.expand_or_jump()
							end
						end, { 'i', 's' }),
						['<C-h>'] = cmp.mapping(function()
							if luasnip.locally_jumpable(-1) then
								luasnip.jump(-1)
							end
						end, { 'i', 's' }),
					},
					snippet = {
						expand = function(args)
							luasnip.lsp_expand(args.body)
						end
					},
					completion = {
						completeopt = 'menu,menuone,noinsert'
					},
					sources = {
						{ name = "lazydev", group_index = 0 },
						{ name = "nvim_lsp" },
						{ name = "luasnip" },
						{ name = "path" },
					},
				}
			end
		}
	})
end

return export
