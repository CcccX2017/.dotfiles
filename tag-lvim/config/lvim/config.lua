--[[
 THESE ARE EXAMPLE CONFIGS FEEL FREE TO CHANGE TO WHATEVER YOU WANT
 `lvim` is the global options object
]]

-- vim options
vim.opt.shiftwidth = 2
vim.opt.tabstop = 2
vim.opt.relativenumber = true

-- general
lvim.log.level = "error"
lvim.format_on_save.enabled = true
-- lvim.format_on_save = {
--   enabled = true,
--   pattern = "*.lua",
--   timeout = 1000,
-- }
-- to disable icons and use a minimalist setup, uncomment the following
-- lvim.use_icons = false

-- keymappings <https://www.lunarvim.org/docs/configuration/keybindings>
lvim.leader = "space"
-- add your own keymapping
lvim.keys.normal_mode["<C-s>"] = ":w<cr>"

-- 相对行号
vim.opt.relativenumber = true

-- 快捷键
lvim.keys.normal_mode["<C-s>"] = ":w<cr>"
lvim.keys.normal_mode["<S-l>"] = ":BufferLineCycleNext<CR>"
lvim.keys.normal_mode["<S-h>"] = ":BufferLineCyclePrev<CR>"
lvim.keys.normal_mode["<leader>1"] = ":BufferLineGoToBuffer 1<CR>"
lvim.keys.normal_mode["<leader>2"] = ":BufferLineGoToBuffer 2<CR>"
lvim.keys.normal_mode["<leader>3"] = ":BufferLineGoToBuffer 3<CR>"
lvim.keys.normal_mode["<leader>4"] = ":BufferLineGoToBuffer 4<CR>"
lvim.keys.normal_mode["<leader>5"] = ":BufferLineGoToBuffer 5<CR>"
lvim.keys.normal_mode["<leader>6"] = ":BufferLineGoToBuffer 6<CR>"
lvim.keys.normal_mode["<leader>7"] = ":BufferLineGoToBuffer 7<CR>"
lvim.keys.normal_mode["<leader>8"] = ":BufferLineGoToBuffer 8<CR>"
lvim.keys.normal_mode["<leader>9"] = ":BufferLineGoToBuffer 9<CR>"
-- 输入模式下jk映射为esc
lvim.keys.insert_mode["jk"] = "<ESC>"
-- lvim.keys.normal_mode["<C-s>"] = "0"
-- lvim.keys.normal_mode["<C-e>"] = "$"
lvim.keys.normal_mode["-"] = "Nzz"
lvim.keys.normal_mode["="] = "nzz"
lvim.keys.normal_mode["tt"] = ":ToggleTerm<CR>"
lvim.keys.normal_mode["sw"] = ":Switch<CR>"
lvim.builtin.which_key.mappings["P"] = { "<cmd>Telescope projects<CR>", "Projects" }
lvim.builtin.which_key.mappings["t"] = {
	name = "Diagnostics",
	t = { "<cmd>TroubleToggle<cr>", "trouble" },
	w = { "<cmd>TroubleToggle workspace_diagnostics<cr>", "workspace" },
	d = { "<cmd>TroubleToggle document_diagnostics<cr>", "document" },
	q = { "<cmd>TroubleToggle quickfix<cr>", "quickfix" },
	l = { "<cmd>TroubleToggle loclist<cr>", "loclist" },
	r = { "<cmd>TroubleToggle lsp_references<cr>", "references" },
}

-- lvim.keys.normal_mode["<S-l>"] = ":BufferLineCycleNext<CR>"
-- lvim.keys.normal_mode["<S-h>"] = ":BufferLineCyclePrev<CR>"

-- -- Use which-key to add extra bindings with the leader-key prefix
-- lvim.builtin.which_key.mappings["W"] = { "<cmd>noautocmd w<cr>", "Save without formatting" }
-- lvim.builtin.which_key.mappings["P"] = { "<cmd>Telescope projects<CR>", "Projects" }

-- -- Change theme settings
-- lvim.colorscheme = "catppuccin"
lvim.colorscheme = "tokyonight"
lvim.transparent_window = false

lvim.builtin.project.active = true
lvim.builtin.alpha.active = true
lvim.builtin.alpha.mode = "dashboard"
lvim.builtin.terminal.active = true
lvim.builtin.nvimtree.setup.view.side = "left"
lvim.builtin.nvimtree.setup.renderer.icons.show.git = true
lvim.builtin.nvimtree.setup.actions.open_file.quit_on_open = true
lvim.builtin.indentlines.options.show_current_context = false
lvim.builtin.indentlines.options.show_current_context_start = false
lvim.builtin.cmp.cmdline.enable = true
lvim.builtin.cmp.cmdline.options = {
	{
		type = ":",
		sources = {
			{ name = "cmdline" },
			{ name = "path" },
		},
	},
	{
		type = { "/", "?" },
		sources = {
			{ name = "buffer" },
		},
	},
}

-- Automatically install missing parsers when entering buffer
lvim.builtin.treesitter.ensure_installed = {
	"bash",
	"c",
	"javascript",
	"json",
	"lua",
	"python",
	"typescript",
	"tsx",
	"css",
	"rust",
	"java",
	"yaml",
	"vue",
	"go",
	"html",
}
lvim.builtin.treesitter.auto_install = true
lvim.builtin.treesitter.ignore_install = { "haskell" }
lvim.builtin.treesitter.highlight.enable = true
lvim.builtin.treesitter.rainbow.enable = true

lvim.plugins = {
	{ "catppuccin/nvim", name = "catppuccin", priority = 1000 },
	{ "EdenEast/nightfox.nvim" },
	{
		"mrjones2014/nvim-ts-rainbow",
	},
	{
		"hrsh7th/cmp-cmdline",
	},
	{
		"tzachar/cmp-tabnine",
		build = "./install.sh",
		dependencies = "hrsh7th/nvim-cmp",
		event = "InsertEnter",
	},
	{
		"norcalli/nvim-colorizer.lua",
		config = function()
			require("colorizer").setup({ "css", "scss", "html", "javascript" }, {
				RGB = true, -- #RGB hex codes
				RRGGBB = true, -- #RRGGBB hex codes
				RRGGBBAA = true, -- #RRGGBBAA hex codes
				rgb_fn = true, -- CSS rgb() and rgba() functions
				hsl_fn = true, -- CSS hsl() and hsla() functions
				css = true, -- Enable all CSS features: rgb_fn, hsl_fn, names, RGB, RRGGBB
				css_fn = true, -- Enable all CSS *functions*: rgb_fn, hsl_fn
			})
		end,
	},
	{
		"rmagatti/goto-preview",
		config = function()
			require("goto-preview").setup({
				width = 120, -- Width of the floating window
				height = 25, -- Height of the floating window
				default_mappings = false, -- Bind default mappings
				debug = false, -- Print debug information
				opacity = nil, -- 0-100 opacity level of the floating window where 100 is fully transparent.
				post_open_hook = nil, -- A function taking two arguments, a buffer and a window to be ran as a hook.
				-- You can use "default_mappings = true" setup option
				-- Or explicitly set keybindings
				-- vim.cmd("nnoremap gpd <cmd>lua require('goto-preview').goto_preview_definition()<CR>")
				-- vim.cmd("nnoremap gpi <cmd>lua require('goto-preview').goto_preview_implementation()<CR>")
				-- vim.cmd("nnoremap gP <cmd>lua require('goto-preview').close_all_win()<CR>")
			})
		end,
	},
	{
		"ray-x/lsp_signature.nvim",
		event = "BufRead",
		config = function()
			require("lsp_signature").on_attach()
		end,
	},
	{
		"folke/flash.nvim",
		event = "VeryLazy",
		--@type Flash.Config
		opts = {},
    -- stylua: ignore
    keys = {
      { "s",     mode = { "n", "x", "o" }, function() require("flash").jump() end,              desc = "Flash" },
      { "S",     mode = { "n", "x", "o" }, function() require("flash").treesitter() end,        desc = "Flash Treesitter" },
      { "r",     mode = "o",               function() require("flash").remote() end,            desc = "Remote Flash" },
      { "R",     mode = { "o", "x" },      function() require("flash").treesitter_search() end, desc = "Treesitter Search" },
      { "<c-s>", mode = { "c" },           function() require("flash").toggle() end,            desc = "Toggle Flash Search" },
    },
	},
	{
		"kevinhwang91/nvim-bqf",
		event = { "BufRead", "BufNew" },
		config = function()
			require("bqf").setup({
				auto_enable = true,
				preview = {
					win_height = 12,
					win_vheight = 12,
					delay_syntax = 80,
					border_chars = { "┃", "┃", "━", "━", "┏", "┓", "┗", "┛", "█" },
				},
				func_map = {
					vsplit = "",
					ptogglemode = "z,",
					stoggleup = "",
				},
				filter = {
					fzf = {
						action_for = { ["ctrl-s"] = "split" },
						extra_opts = { "--bind", "ctrl-o:toggle-all", "--prompt", "> " },
					},
				},
			})
		end,
	},
	{
		"nacro90/numb.nvim",
		event = "BufRead",
		config = function()
			require("numb").setup({
				show_numbers = true, -- Enable 'number' for the window while peeking
				show_cursorline = true, -- Enable 'cursorline' for the window while peeking
			})
		end,
	},
	{
		"windwp/nvim-spectre",
		event = "BufRead",
		config = function()
			require("spectre").setup()
		end,
	},
	{
		"kevinhwang91/rnvimr",
		cmd = "RnvimrToggle",
		config = function()
			vim.g.rnvimr_draw_border = 1
			vim.g.rnvimr_pick_enable = 1
			vim.g.rnvimr_bw_enable = 1
		end,
	},
	{
		"andymass/vim-matchup",
		event = "CursorMoved",
		config = function()
			vim.g.matchup_matchparen_offscreen = { method = "popup" }
		end,
	},
	{
		"f-person/git-blame.nvim",
		event = "BufRead",
		config = function()
			vim.cmd("highlight default link gitblame SpecialComment")
			vim.g.gitblame_enabled = 0
		end,
	},
	{
		"sindrets/diffview.nvim",
		event = "BufRead",
	},
	{
		"windwp/nvim-ts-autotag",
		config = function()
			require("nvim-ts-autotag").setup()
		end,
	},
	{
		"simrat39/symbols-outline.nvim",
		config = function()
			require("symbols-outline").setup()
		end,
	},
	{
		-- 在有code action的地方显示灯泡
		"kosayoda/nvim-lightbulb",
		config = function()
			require("nvim-lightbulb").setup({
				autocmd = { enabled = true },
				-- LSP client names to ignore
				-- Example: {"sumneko_lua", "null-ls"}
				ignore = {},
				sign = {
					enabled = true,
					-- Priority of the gutter sign
					priority = 10,
				},
				float = {
					enabled = false,
					-- Text to show in the popup float
					text = "💡", --
					-- Available keys for window options:
					-- - height     of floating window
					-- - width      of floating window
					-- - wrap_at    character to wrap at for computing height
					-- - max_width  maximal width of floating window
					-- - max_height maximal height of floating window
					-- - pad_left   number of columns to pad contents at left
					-- - pad_right  number of columns to pad contents at right
					-- - pad_top    number of lines to pad contents at top
					-- - pad_bottom number of lines to pad contents at bottom
					-- - offset_x   x-axis offset of the floating window
					-- - offset_y   y-axis offset of the floating window
					-- - anchor     corner of float to place at the cursor (NW, NE, SW, SE)
					-- - winblend   transparency of the window (0-100)
					win_opts = {},
				},
				virtual_text = {
					enabled = true,
					-- Text to show at virtual text
					text = "💡", --
					-- highlight mode to use for virtual text (replace, combine, blend), see :help nvim_buf_set_extmark() for reference
					hl_mode = "replace",
				},
				status_text = {
					enabled = false,
					-- Text to provide when code actions are available
					text = "💡",
					-- Text to provide when no actions are available
					text_unavailable = "",
				},
			})
		end,
	},
	{
		"folke/trouble.nvim",
		cmd = "TroubleToggle",
	},
	{
		"ethanholz/nvim-lastplace",
		event = "BufRead",
		config = function()
			require("nvim-lastplace").setup({
				lastplace_ignore_buftype = { "quickfix", "nofile", "help" },
				lastplace_ignore_filetype = {
					"gitcommit",
					"gitrebase",
					"svn",
					"hgcommit",
				},
				lastplace_open_folds = true,
			})
		end,
	},
	{
		"folke/todo-comments.nvim",
		event = "BufRead",
		config = function()
			require("todo-comments").setup()
		end,
	},
	{
		"turbio/bracey.vim",
		cmd = { "Bracey", "BracyStop", "BraceyReload", "BraceyEval" },
		build = "npm install --prefix server",
	},
	{
		"folke/noice.nvim",
		event = "VeryLazy",
		config = function()
			require("noice").setup({
				-- add any options here
				lsp = {
					signature = {
						enabled = false,
					},
					override = {
						["vim.lsp.util.convert_input_to_markdown_lines"] = true,
						["vim.lsp.util.stylize_markdown"] = true,
						["cmp.entry.get_documentation"] = true,
					},
					hover = {
						enabled = false,
					},
				},
				routes = {
					{
						filter = {
							event = "msg_show",
							any = {
								{ find = "%d+L, %d+B" },
								{ find = "; after #%d+" },
								{ find = "; before #%d+" },
							},
						},
						view = "mini",
					},
				},
				presets = {
					bottom_search = true,
					command_palette = true,
					long_message_to_split = true,
				},
			})
			require("notify").setup({
				background_colour = "#000000",
			})
		end,
		dependencies = {
			-- if you lazy-load any plugin below, make sure to add proper `module="..."` entries
			"MunifTanjim/nui.nvim",
			-- OPTIONAL:
			--   `nvim-notify` is only needed, if you want to use the notification view.
			--   If not available, we use `mini` as the fallback
			"rcarriga/nvim-notify",
		},
	},
	{
		-- commit = "a0b9d25154be573bc0f99877afb3f57cf881cce7",
		"Shatur/neovim-session-manager",
		config = function()
			local Path = require("plenary.path")
			require("session_manager").setup({
				sessions_dir = Path:new(vim.fn.stdpath("data"), "sessions"),
				path_replacer = "__",
				colon_replacer = "++",
				autoload_mode = require("session_manager.config").AutoloadMode.CurrentDir,
				-- autoload_mode = require('session_manager.config').AutoloadMode.LastSession,
				autosave_last_session = true,
				autosave_ignore_not_normal = true,
				autosave_ignore_dirs = { "~" },
				autosave_ignore_filetypes = {
					"gitcommit",
					"gitrebase",
				},
				autosave_ignore_buftypes = {},
				autosave_only_in_session = false,
				max_path_length = 80,
			})

			-- local config_group = vim.api.nvim_create_augroup('MyConfigGroup', {})

			-- vim.api.nvim_create_autocmd({ 'User' }, {
			--   pattern = "SessionLoadPost",
			--   group = config_group,
			--   callback = function()
			--     -- vim.cmd("NvimTreeToggle")
			--     require('nvim-tree.api').tree.toggle(false, true)
			--   end,
			-- })
		end,
		dependencies = "nvim-lua/plenary.nvim",
	},
	{
		"AndrewRadev/switch.vim",
	},
	{
		"tpope/vim-surround",
	},
	{
		-- 多光标支持
		"mg979/vim-visual-multi",
	},
	{
		-- 增强code action浮空显示
		"weilbith/nvim-code-action-menu",
		config = function()
			vim.g.code_action_menu_show_details = false
			vim.g.code_action_menu_show_diff = true
			vim.g.code_action_menu_show_action_kind = true
		end,
	},
	{
		-- 支持当前buffer最大化
		"szw/vim-maximizer",
	},
	{
		-- 可以再浏览器中预览markdown文件
		"iamcco/markdown-preview.nvim",
		config = function()
			vim.fn["mkdp#util#install"]()
			vim.g.mkdp_auto_close = 0 -- not close when changing buffer
		end,
	},
	{
		-- 增强代码块 {} 指示显示
		"shellRaining/hlchunk.nvim",
		-- commit = "350e4e8f1b6f4c6dbd9a98946547ed557bab5335",
		config = function()
			-- vim.api.nvim_create_autocmd({ "CursorMoved", "CursorMovedI" }, { pattern = "*", command = "EnableHL" })
			require("hlchunk").setup({
				chunk = {
					enable = true,
					use_treesitter = false,
					notify = true, -- notify if some situation(like disable chunk mod double time)
					exclude_filetypes = {
						aerial = true,
						dashboard = true,
					},
					support_filetypes = {
						"*.lua",
						"*.js",
					},
					chars = {
						horizontal_line = "─",
						vertical_line = "│",
						left_top = "╭",
						left_bottom = "╰",
						right_arrow = ">",
					},
					style = {
						{ fg = "#CB8764" },
					},
				},
				indent = {
					enable = true, --
					-- chars = { "│", "¦", "┆", "┊" },
					chars = { "▏" },
					-- chars = { " ", " ", " ", " " },
					use_treesitter = false,
					style = {
						-- { fg = vim.fn.synIDattr(vim.fn.synIDtrans(vim.fn.hlID("Whitespace")), "fg", "gui") }
						{ fg = "#51576e" },
					},
				},
				line_num = {
					enable = false,
					use_treesitter = true,
					style = "#806d9c",
				},
				blank = {
					enable = false,
					chars = {
						"․",
					},
					style = {
						vim.fn.synIDattr(vim.fn.synIDtrans(vim.fn.hlID("Whitespace")), "fg", "gui"),
					},
				},
			})
		end,
	},
	{
		-- 增强折叠显示
		-- lazy = true,
		"kevinhwang91/nvim-ufo",
		dependencies = "kevinhwang91/promise-async",
		config = function()
			vim.o.foldcolumn = "0" -- '0' is not bad
			vim.o.foldlevel = 9999 -- Using ufo provider need a large value, feel free to decrease the value
			vim.o.foldlevelstart = 99
			vim.o.foldenable = true
			-- vim.o.foldmethod = "syntax"

			-- Using ufo provider need remap `zR` and `zM`. If Neovim is 0.6.1, remap yourself
			vim.keymap.set("n", "zR", require("ufo").openAllFolds)
			vim.keymap.set("n", "zM", require("ufo").closeAllFolds)

			-- Option 2: nvim lsp as LSP client
			-- Tell the server the capability of foldingRange,
			-- Neovim hasn't added foldingRange to default capabilities, users must add it manually
			local capabilities = vim.lsp.protocol.make_client_capabilities()
			capabilities.textDocument.foldingRange = {
				dynamicRegistration = false,
				lineFoldingOnly = true,
			}
			local language_servers = require("lspconfig").util.available_servers() -- or list servers manually like {'gopls', 'clangd'}
			for _, ls in ipairs(language_servers) do
				-- NOTE: gxt_kt: Must change lspconfig to lvim.lsp.manager
				-- Otherwise will make lsp server start failure
				require("lvim.lsp.manager").setup(ls, {
					capabilities = capabilities,
					-- you can add other fields for setting up lsp server in this table
				})
				-- require('lspconfig')[ls].setup({
				--   capabilities = capabilities
				--   -- you can add other fields for setting up lsp server in this table
				-- })
			end
			-- require('ufo').setup()
			--
			--
			--
			local handler = function(virtText, lnum, endLnum, width, truncate)
				local newVirtText = {}
				local suffix = (" 󰁂 %d "):format(endLnum - lnum)
				local sufWidth = vim.fn.strdisplaywidth(suffix)
				local targetWidth = width - sufWidth
				local curWidth = 0
				for _, chunk in ipairs(virtText) do
					local chunkText = chunk[1]
					local chunkWidth = vim.fn.strdisplaywidth(chunkText)
					if targetWidth > curWidth + chunkWidth then
						table.insert(newVirtText, chunk)
					else
						chunkText = truncate(chunkText, targetWidth - curWidth)
						local hlGroup = chunk[2]
						table.insert(newVirtText, { chunkText, hlGroup })
						chunkWidth = vim.fn.strdisplaywidth(chunkText)
						-- str width returned from truncate() may less than 2nd argument, need padding
						if curWidth + chunkWidth < targetWidth then
							suffix = suffix .. (" "):rep(targetWidth - curWidth - chunkWidth)
						end
						break
					end
					curWidth = curWidth + chunkWidth
				end
				table.insert(newVirtText, { suffix, "MoreMsg" })
				return newVirtText
			end

			-- global handler
			-- `handler` is the 2nd parameter of `setFoldVirtTextHandler`,
			-- check out `./lua/ufo.lua` and search `setFoldVirtTextHandler` for detail.
			require("ufo").setup({
				fold_virt_text_handler = handler,
			})
		end,
	},
	-- {
	--   -- 定义自己的状态栏，比如让git标识显示在行号右侧
	--   "luukvbaal/statuscol.nvim",
	--   config = function()
	--     local builtin = require("statuscol.builtin")
	--     require("statuscol").setup({
	--       setopt = true, -- Whether to set the 'statuscolumn' option, may be set to false for those who
	--       -- want to use the click handlers in their own 'statuscolumn': _G.Sc[SFL]a().
	--       -- Although I recommend just using the segments field below to build your
	--       -- statuscolumn to benefit from the performance optimizations in this plugin.
	--       -- builtin.lnumfunc number string options
	--       thousands = false,  -- or line number thousands separator string ("." / ",")
	--       relculright = true, -- whether to right-align the cursor line number with 'relativenumber' set
	--       -- Builtin 'statuscolumn' options
	--       ft_ignore = nil,    -- lua table with filetypes for which 'statuscolumn' will be unset
	--       bt_ignore = nil,    -- lua table with 'buftype' values for which 'statuscolumn' will be unset
	--       -- Default segments (fold -> sign -> line number + separator), explained below
	--       segments = {
	--         -- { text = { builtin.foldfunc }, click = "v:lua.ScSa" },
	--         {
	--           sign = {
	--             name = { ".*" },
	--             namespace = { ".*" },
	--             max_width = 2,
	--             colwidth = 2,
	--             auto = false,
	--           },
	--           condition = { true, builtin.not_empty },
	--           click = "v:lua.ScLa",
	--         },
	--         -- {
	--         --   sign = {
	--         --     name = { "Diagnostic" },
	--         --     max_width = 1,
	--         --     colwidth = 1,
	--         --     auto = false,
	--         --   },
	--         --   click = "v:lua.ScLa",
	--         -- },
	--         {
	--           text = { builtin.lnumfunc, " " },
	--           -- condition = { true, builtin.not_empty },
	--           click = "v:lua.ScLa",
	--         },
	--         {
	--           -- Ref: https://github.com/luukvbaal/statuscol.nvim/issues/71
	--           sign = {
	--             name = { "GitSign" },
	--             namespace = { "gitsign" },
	--             max_width = 1,
	--             colwidth = 1,
	--             auto = false,
	--           },
	--           -- condition = { true, builtin.not_empty },
	--           click = "v:lua.ScLa",
	--         },
	--       },
	--       clickmod = "c",   -- modifier used for certain actions in the builtin clickhandlers:
	--       -- "a" for Alt, "c" for Ctrl and "m" for Meta.
	--       clickhandlers = { -- builtin click handlers
	--         Lnum                    = builtin.lnum_click,
	--         FoldClose               = builtin.foldclose_click,
	--         FoldOpen                = builtin.foldopen_click,
	--         FoldOther               = builtin.foldother_click,
	--         DapBreakpointRejected   = builtin.toggle_breakpoint,
	--         DapBreakpoint           = builtin.toggle_breakpoint,
	--         DapBreakpointCondition  = builtin.toggle_breakpoint,
	--         DiagnosticSignError     = builtin.diagnostic_click,
	--         DiagnosticSignHint      = builtin.diagnostic_click,
	--         DiagnosticSignInfo      = builtin.diagnostic_click,
	--         DiagnosticSignWarn      = builtin.diagnostic_click,
	--         GitSignsTopdelete       = builtin.gitsigns_click,
	--         GitSignsUntracked       = builtin.gitsigns_click,
	--         GitSignsAdd             = builtin.gitsigns_click,
	--         GitSignsChange          = builtin.gitsigns_click,
	--         GitSignsChangedelete    = builtin.gitsigns_click,
	--         GitSignsDelete          = builtin.gitsigns_click,
	--         gitsigns_extmark_signs_ = builtin.gitsigns_click,
	--       },
	--     })
	--   end,
	-- },
	{
		-- 增强笔记文件显示，markdown, orgmode, neorg
		-- show latex on markdown file can use plugin "jbyuki/nabla.nvim"
		"lukas-reineke/headlines.nvim",
		dependencies = "nvim-treesitter/nvim-treesitter",
		config = function()
			require("headlines").setup()
		end,
	},
	{
		-- visual自动选择，按enter增加，backspace减少
		"sustech-data/wildfire.nvim",
		event = "VeryLazy",
		dependencies = { "nvim-treesitter/nvim-treesitter" },
		config = function()
			require("wildfire").setup()
		end,
	},
	-- {
	--   -- 支持修改后自动保存文件
	--   "pocco81/auto-save.nvim",
	--   config = function()
	--     require("auto-save").setup({
	--       execution_message = {
	--         cleaning_interval = 100,
	--       }
	--     })
	--   end,
	-- },
}

-- lvim.builtin.treesitter.ignore_install = { "haskell" }

-- -- always installed on startup, useful for parsers without a strict filetype
-- lvim.builtin.treesitter.ensure_installed = { "comment", "markdown_inline", "regex" }

-- -- generic LSP settings <https://www.lunarvim.org/docs/languages#lsp-support>

-- --- disable automatic installation of servers
-- lvim.lsp.installer.setup.automatic_installation = false

-- ---configure a server manually. IMPORTANT: Requires `:LvimCacheReset` to take effect
-- ---see the full default list `:lua =lvim.lsp.automatic_configuration.skipped_servers`
-- vim.list_extend(lvim.lsp.automatic_configuration.skipped_servers, { "pyright" })
-- local opts = {} -- check the lspconfig documentation for a list of all possible options
-- require("lvim.lsp.manager").setup("pyright", opts)

-- ---remove a server from the skipped list, e.g. eslint, or emmet_ls. IMPORTANT: Requires `:LvimCacheReset` to take effect
-- ---`:LvimInfo` lists which server(s) are skipped for the current filetype
-- lvim.lsp.automatic_configuration.skipped_servers = vim.tbl_filter(function(server)
--   return server ~= "emmet_ls"
-- end, lvim.lsp.automatic_configuration.skipped_servers)

-- -- you can set a custom on_attach function that will be used for all the language servers
-- -- See <https://github.com/neovim/nvim-lspconfig#keybindings-and-completion>
-- lvim.lsp.on_attach_callback = function(client, bufnr)
--   local function buf_set_option(...)
--     vim.api.nvim_buf_set_option(bufnr, ...)
--   end
--   --Enable completion triggered by <c-x><c-o>
--   buf_set_option("omnifunc", "v:lua.vim.lsp.omnifunc")
-- end

-- -- linters and formatters <https://www.lunarvim.org/docs/languages#lintingformatting>
-- local formatters = require "lvim.lsp.null-ls.formatters"
-- formatters.setup {
--   { command = "stylua" },
--   {
--     command = "prettier",
--     extra_args = { "--print-width", "100" },
--     filetypes = { "typescript", "typescriptreact" },
--   },
-- }
-- local linters = require "lvim.lsp.null-ls.linters"
-- linters.setup {
--   { command = "flake8", filetypes = { "python" } },
--   {
--     command = "shellcheck",
--     args = { "--severity", "warning" },
--   },
-- }

-- -- Additional Plugins <https://www.lunarvim.org/docs/plugins#user-plugins>
-- lvim.plugins = {
--     {
--       "folke/trouble.nvim",
--       cmd = "TroubleToggle",
--     },
-- }

-- -- Autocommands (`:help autocmd`) <https://neovim.io/doc/user/autocmd.html>
-- vim.api.nvim_create_autocmd("FileType", {
--   pattern = "zsh",
--   callback = function()
--     -- let treesitter use bash highlight for zsh files as well
--     require("nvim-treesitter.highlight").attach(0, "bash")
--   end,
-- })
