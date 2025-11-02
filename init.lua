vim.g.mapleader = " "
vim.g.maplocalleader = " "

vim.g.have_nerd_font = true

vim.opt.mouse = "a"

-- Enable break indent
-- vim.opt.breakindent = true

-- Case-insensitive searching UNLESS \C or one or more capital letters in the search term
vim.opt.ignorecase = true
vim.opt.smartcase = true

-- Decrease mapped sequence wait time
vim.opt.timeoutlen = 300

-- Configure how new splits should be opened
vim.opt.splitright = true
vim.opt.splitbelow = true

-- Preview substitutions live, as you type!
vim.opt.inccommand = "split"

-- Show which line your cursor is on
vim.opt.cursorline = true

-- if performing an operation that would fail due to unsaved changes in the buffer (like `:q`),
-- instead raise a dialog asking if you wish to save the current file(s)
vim.opt.confirm = true

vim.opt.nu = true
vim.opt.relativenumber = true

vim.opt.tabstop = 4
vim.opt.softtabstop = 4
vim.opt.shiftwidth = 4
vim.opt.expandtab = true

vim.opt.smartindent = true

vim.opt.wrap = false

vim.opt.swapfile = false
vim.opt.backup = false
--vim.opt.undodir = os getenv("HOME") .. "/.vim/undodir"
vim.opt.undofile = true

vim.opt.hlsearch = true
vim.opt.incsearch = true

vim.opt.termguicolors = true

vim.opt.scrolloff = 8
vim.opt.signcolumn = "yes"
vim.opt.isfname:append("@-@")

vim.opt.updatetime = 50

vim.opt.showmode = false

vim.opt.fillchars = { eob = " " }

vim.opt.foldmethod = "indent"
vim.opt.foldlevelstart = 99

vim.keymap.set("n", "<Esc>", "<cmd>nohlsearch<CR>")
vim.keymap.set("v", "/", "\"vy/<C-R>v<CR>")

-- Diagnostic keymaps
vim.keymap.set("n", "<leader>q", vim.diagnostic.setloclist, { desc = "Open diagnostic [Q]uickfix list" })

-- Keybinds to make split navigation easier.
-- vim.keymap.set("n", "<A-h>", "<C-w><C-h>", { desc = "Move focus to the left window" })
-- vim.keymap.set("n", "<A-l>", "<C-w><C-l>", { desc = "Move focus to the right window" })
-- vim.keymap.set("n", "<A-j>", "<C-w><C-j>", { desc = "Move focus to the lower window" })
-- vim.keymap.set("n", "<A-k>", "<C-w><C-k>", { desc = "Move focus to the upper window" })

-- vim.keymap.set("n", "n", "nzzzv") -- leave cursor in the middle of the screen when jumping between found texts
-- vim.keymap.set("n", "N", "Nzzzv")

vim.keymap.set("n", "<leader>e", "<CMD>lua MiniFiles.open()<CR>", { desc = "Open parent directory" })

-- vim.keymap.set("n", "<leader>d", "<cmd>lua ToggleVirtualText()<CR>") -- show/hide diagnostics -- currently not working for some reason...

vim.keymap.set("n", "<leader>y", '"+y') -- yank to clipboard
vim.keymap.set("v", "<leader>y", '"+y')
vim.keymap.set("n", "<leader>y", '"+Y')
vim.keymap.set("n", "<leader>p", '"+p')
vim.keymap.set("v", "<leader>p", '"+p')

vim.keymap.set("v", ">", ">gv") -- give me my selection back after tabbing
vim.keymap.set("v", "<", "<gv")

vim.keymap.set("n", ">", ">>") -- indent in normal mode if a say so
vim.keymap.set("n", "<", "<<")

vim.keymap.set("n", "J", "J_") -- leave me on the beginning when joinin

vim.keymap.set("n", "<leader>t", "<CMD>lua require('FTerm').open()<CR>")
vim.keymap.set("t", "<Esc>", "<C-\\><C-n><CMD>lua require('FTerm').toggle()<CR>")

-- Highlight when yanking (copying) text
vim.api.nvim_create_autocmd("TextYankPost", {
    desc = "Highlight when yanking (copying) text",
    group = vim.api.nvim_create_augroup("kickstart-highlight-yank", { clear = true }),
    callback = function()
        vim.highlight.on_yank()
    end,
})

-- Autoformat Prettier-supported files on save
vim.api.nvim_create_autocmd("BufWritePre", {
    pattern = {
        "*.js", "*.ts", "*.jsx", "*.tsx",
        "*.css", "*.scss", "*.html",
        "*.json", "*.yaml", "*.yml",
        "*.md", "*.markdown"
    },
    callback = function()
        vim.lsp.buf.format({ async = false })
    end,
})

-- [[ Install `lazy.nvim` plugin manager ]]
--    See `:help lazy.nvim.txt` or https://github.com/folke/lazy.nvim for more info
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
    local lazyrepo = "https://github.com/folke/lazy.nvim.git"
    local out = vim.fn.system({ "git", "clone", "--filter=blob:none", "--branch=stable", lazyrepo, lazypath })
    if vim.v.shell_error ~= 0 then
        error("Error cloning lazy.nvim:\n" .. out)
    end
end ---@diagnostic disable-next-line: undefined-field
vim.opt.rtp:prepend(lazypath)

require("lazy").setup({
    { -- Fuzzy Finder (files, lsp, etc)
        "nvim-telescope/telescope.nvim",
        event = "VimEnter",
        branch = "0.1.x",
        dependencies = {
            "nvim-lua/plenary.nvim",
            { -- If encountering errors, see telescope-fzf-native README for installation instructions
                "nvim-telescope/telescope-fzf-native.nvim",

                build = "make",

                cond = function()
                    return vim.fn.executable("make") == 1
                end,
            },
            { "nvim-telescope/telescope-ui-select.nvim" },
            { "nvim-tree/nvim-web-devicons", enabled = vim.g.have_nerd_font },
        },
        config = function()
            require("telescope").setup({
                defaults = {
                    extensions = {
                        ["ui-select"] = {
                            require("telescope.themes").get_dropdown(),
                        },
                    },
                    file_ignore_patterns = { "node_modules" },
                }
            })

            -- Enable Telescope extensions if they are installed
            pcall(require("telescope").load_extension, "fzf")
            pcall(require("telescope").load_extension, "ui-select")

            local builtin = require("telescope.builtin")

            vim.keymap.set("n", "<leader>f", builtin.find_files, { desc = "Telescope find files" })
            vim.keymap.set("n", "<leader>s", function()
                builtin.grep_string({ search = vim.fn.input("Grep > ") })
            end)
            vim.keymap.set("n", "<leader>b", builtin.buffers, { desc = "Telescope find buffers" })
            vim.keymap.set('n', '<leader>w', builtin.grep_string, { desc = '[S]earch current [W]ord' })
            -- vim.keymap.set('n', '<leader>sh', builtin.help_tags, { desc = '[S]earch [H]elp' })
            -- vim.keymap.set('n', '<leader>sk', builtin.keymaps, { desc = '[S]earch [K]eymaps' })
            -- vim.keymap.set('n', '<leader>sf', builtin.find_files, { desc = '[S]earch [F]iles' })
            -- vim.keymap.set('n', '<leader>ss', builtin.builtin, { desc = '[S]earch [S]elect Telescope' })
            -- vim.keymap.set('n', '<leader>sw', builtin.grep_string, { desc = '[S]earch current [W]ord' })
            -- vim.keymap.set('n', '<leader>sg', builtin.live_grep, { desc = '[S]earch by [G]rep' })
            -- vim.keymap.set('n', '<leader>sd', builtin.diagnostics, { desc = '[S]earch [D]iagnostics' })
            -- vim.keymap.set('n', '<leader>sr', builtin.resume, { desc = '[S]earch [R]esume' })
            -- vim.keymap.set('n', '<leader>s.', builtin.oldfiles, { desc = '[S]earch Recent Files ("." for repeat)' })
            -- vim.keymap.set('n', '<leader><leader>', builtin.buffers, { desc = '[ ] Find existing buffers' })
        end,
    },

    -- LSP Plugins
    {
        -- `lazydev` configures Lua LSP for your Neovim config, runtime and plugins
        -- used for completion, annotations and signatures of Neovim apis
        "folke/lazydev.nvim",
        ft = "lua",
        opts = {
            library = {
                -- Load luvit types when the `vim.uv` word is found
                { path = "${3rd}/luv/library", words = { "vim%.uv" } },
            },
        },
    },
    {
        -- Main LSP Configuration
        "neovim/nvim-lspconfig",
        dependencies = {
            -- Automatically install LSPs and related tools to stdpath for Neovim
            -- Mason must be loaded before its dependents so we need to set it up here.
            { "williamboman/mason.nvim", opts = {} },
            {"williamboman/mason-lspconfig.nvim", opts = {ensure_installed = { "html", "cssls", "tsserver" }}},
            "WhoIsSethDaniel/mason-tool-installer.nvim",

            -- Useful status updates for LSP.
            { "j-hui/fidget.nvim", opts = {} },

            -- Allows extra capabilities provided by nvim-cmp
            "hrsh7th/cmp-nvim-lsp",
        },
        config = function()
            vim.api.nvim_create_autocmd("LspAttach", {
                group = vim.api.nvim_create_augroup("kickstart-lsp-attach", { clear = true }),
                callback = function(event)
                    local map = function(keys, func, desc, mode)
                        mode = mode or "n"
                        vim.keymap.set(mode, keys, func, { buffer = event.buf, desc = "LSP: " .. desc })
                    end

                    -- Jump to the definition of the word under your cursor.
                    --  To jump back, press <C-t>.
                    map("gd", require("telescope.builtin").lsp_definitions, "[G]oto [D]efinition")

                    -- Find references for the word under your cursor.
                    map("gr", require("telescope.builtin").lsp_references, "[G]oto [R]eferences")

                    -- Jump to the implementation of the word under your cursor.
                    map("gI", require("telescope.builtin").lsp_implementations, "[G]oto [I]mplementation")

                    -- Jump to the type of the word under your cursor.
                    map("<leader>D", require("telescope.builtin").lsp_type_definitions, "Type [D]efinition")

                    -- Fuzzy find all the symbols in your current document.
                    map("<leader>ds", require("telescope.builtin").lsp_document_symbols, "[D]ocument [S]ymbols")

                    -- Fuzzy find all the symbols in your current workspace.
                    map("<leader>ws", require("telescope.builtin").lsp_dynamic_workspace_symbols, "[W]orkspace [S]ymbols")

                    -- Rename the variable under your cursor.
                    map("<leader>rn", vim.lsp.buf.rename, "[R]e[n]ame")

                    -- Execute a code action, usually your cursor needs to be on top of an error
                    -- or a suggestion from your LSP for this to activate.
                    map("<leader>ca", vim.lsp.buf.code_action, "[C]ode [A]ction", { "n", "x" })

                    map("gD", vim.lsp.buf.declaration, "[G]oto [D]eclaration")

                    -- This function resolves a difference between neovim nightly (version 0.11) and stable (version 0.10)
                    ---@param client vim.lsp.Client
                    ---@param method vim.lsp.protocol.Method
                    ---@param bufnr? integer some lsp support methods only in specific files
                    ---@return boolean
                    local function client_supports_method(client, method, bufnr)
                        if vim.fn.has("nvim-0.11") == 1 then
                            return client:supports_method(method, bufnr)
                        else
                            return client.supports_method(method, { bufnr = bufnr })
                        end
                    end

                    -- The following two autocommands are used to highlight references of the
                    -- word under your cursor when your cursor rests there for a little while.
                    -- When you move your cursor, the highlights will be cleared (the second autocommand).
                    local client = vim.lsp.get_client_by_id(event.data.client_id)
                    if client and client_supports_method(client, vim.lsp.protocol.Methods.textDocument_documentHighlight, event.buf)
                    then
                        local highlight_augroup =
                        vim.api.nvim_create_augroup("kickstart-lsp-highlight", { clear = false })
                        vim.api.nvim_create_autocmd({ "CursorHold", "CursorHoldI" }, {
                            buffer = event.buf,
                            group = highlight_augroup,
                            callback = vim.lsp.buf.document_highlight,
                        })

                        vim.api.nvim_create_autocmd({ "CursorMoved", "CursorMovedI" }, {
                            buffer = event.buf,
                            group = highlight_augroup,
                            callback = vim.lsp.buf.clear_references,
                        })

                        vim.api.nvim_create_autocmd("LspDetach", {
                            group = vim.api.nvim_create_augroup("kickstart-lsp-detach", { clear = true }),
                            callback = function(event2)
                                vim.lsp.buf.clear_references()
                                vim.api.nvim_clear_autocmds({ group = "kickstart-lsp-highlight", buffer = event2.buf })
                            end,
                        })
                    end

                    -- The following code creates a keymap to toggle inlay hints in your
                    -- code, if the language server you are using supports them
                    -- This may be unwanted, since they displace some of your code
                    if client and client_supports_method(client, vim.lsp.protocol.Methods.textDocument_inlayHint, event.buf)
                    then
                        map("<leader>th", function()
                            vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled({ bufnr = event.buf }))
                        end, "[T]oggle Inlay [H]ints")
                    end
                end,
            })

            vim.diagnostic.config({
                severity_sort = true,
                float = { border = "rounded", source = "if_many" },
                underline = { severity = vim.diagnostic.severity.ERROR },
                signs = vim.g.have_nerd_font and {
                    text = {
                        [vim.diagnostic.severity.ERROR] = "󰅚 ",
                        [vim.diagnostic.severity.WARN] = "󰀪 ",
                        [vim.diagnostic.severity.INFO] = "󰋽 ",
                        [vim.diagnostic.severity.HINT] = "󰌶 ",
                    },
                } or {},
                virtual_text = {
                    source = "if_many",
                    spacing = 2,
                    format = function(diagnostic)
                        local diagnostic_message = {
                            [vim.diagnostic.severity.ERROR] = diagnostic.message,
                            [vim.diagnostic.severity.WARN] = diagnostic.message,
                            [vim.diagnostic.severity.INFO] = diagnostic.message,
                            [vim.diagnostic.severity.HINT] = diagnostic.message,
                        }
                        return diagnostic_message[diagnostic.severity]
                    end,
                },
            })

            local capabilities = vim.lsp.protocol.make_client_capabilities()
            capabilities = vim.tbl_deep_extend("force", capabilities, require("cmp_nvim_lsp").default_capabilities())

            local servers = {
                lua_ls = {
                    settings = {
                        Lua = {
                            completion = {
                                callSnippet = "Replace",
                            },
                        },
                    },
                },
            }

            local ensure_installed = vim.tbl_keys(servers or {})
            vim.list_extend(ensure_installed, {
                "stylua", -- Used to format Lua code
            })
            require("mason-tool-installer").setup({ ensure_installed = ensure_installed })

            -- This function augments the default LSP `on_attach` to ensure 4-space indentation
            local lsp_on_attach = function(client, bufnr)
                -- Set local buffer options
                vim.bo[bufnr].tabstop = 4
                vim.bo[bufnr].shiftwidth = 4
                vim.bo[bufnr].softtabstop = 4
                vim.bo[bufnr].expandtab = true

                -- Notify LSP server about the formatting preferences
                if client.server_capabilities.textDocument and client.server_capabilities.textDocument.formatting then
                    client.config.settings = client.config.settings or {}
                    client.config.settings.editor = client.config.settings.editor or {}
                    client.config.settings.editor.tabSize = 4
                    client.config.settings.editor.insertSpaces = true
                end
            end

            require("mason-lspconfig").setup({
                ensure_installed = {}, -- explicitly set to an empty table (Kickstart populates installs via mason-tool-installer)
                automatic_installation = false,
                handlers = {
                    function(server_name)
                        -- local server = servers[server_name] or {}
                        -- server.capabilities = vim.tbl_deep_extend("force", {}, capabilities, server.capabilities or {})
                        -- require("lspconfig")[server_name].setup(server)
                        require('lspconfig')[server_name].setup {
                            on_attach = lsp_on_attach,
                            settings = {
                                -- This helps with servers like tsserver, jsonls, etc.
                                editor = {
                                    tabSize = 4,
                                    insertSpaces = true,
                                },
                            },
                        }
                    end,
                },
            })

            -- Apply to all servers (this assumes you're using `mason-lspconfig`)
            -- require('mason-lspconfig').setup_handlers {
            --   function(server_name)
            --     require('lspconfig')[server_name].setup {
            --       on_attach = lsp_on_attach,
            --       settings = {
            --         -- This helps with servers like tsserver, jsonls, etc.
            --         editor = {
            --           tabSize = 4,
            --           insertSpaces = true,
            --         },
            --       },
            --     }
            --   end,
            -- }
        end,
    },

    { -- Autocompletion
        "hrsh7th/nvim-cmp",
        event = "InsertEnter",
        dependencies = {
            {
                "L3MON4D3/LuaSnip",
                build = (function()
                    if vim.fn.has("win32") == 1 or vim.fn.executable("make") == 0 then
                        return
                    end
                    return "make install_jsregexp"
                end)(),
                dependencies = { },
            },
            "saadparwaiz1/cmp_luasnip",

            "hrsh7th/cmp-nvim-lsp",
            "hrsh7th/cmp-path",
            "hrsh7th/cmp-nvim-lsp-signature-help",
        },
        config = function()
            local cmp = require("cmp")
            local luasnip = require("luasnip")
            luasnip.config.setup({})

            cmp.setup({
                snippet = {
                    expand = function(args)
                        luasnip.lsp_expand(args.body)
                    end,
                },
                completion = { completeopt = "menu,menuone,noinsert" },

                mapping = cmp.mapping.preset.insert({
                    ["<Tab>"] = cmp.mapping.select_next_item(),
                    ["<S-Tab>"] = cmp.mapping.select_prev_item(),
                    ["<C-b>"] = cmp.mapping.scroll_docs(-4),
                    ["<C-f>"] = cmp.mapping.scroll_docs(4),
                    ["<Enter>"] = cmp.mapping.confirm({ select = true }),
                }),
                sources = {
                    {
                        name = "lazydev",
                        -- set group index to 0 to skip loading LuaLS completions as lazydev recommends it
                        group_index = 0,
                    },
                    { name = "nvim_lsp" },
                    { name = "luasnip" },
                    { name = "path" },
                    { name = "nvim_lsp_signature_help" },
                },
            })
        end,
    },

    {
        "catppuccin/nvim", name = "catppuccin", priority = 1000,
        config = function()
            require("catppuccin").setup({
                custom_highlights = function(colors) -- for ghostty
                    return {
                        Normal = { bg = "#282C34" },     -- your desired background color
                        NormalNC = { bg = "#282C34" },   -- background when not focused
                        -- Optional: change Float, Pmenu, etc. if needed
                        -- FloatBorder = { bg = "#1e1e2e", fg = colors.mauve },
                        -- Pmenu = { bg = "#1e1e2e" },
                    }
                end,
                flavour = "frappe",
                -- transparent_background = true,
                styles = {
                    comments = {"italic"},
                    integrations = {
                        cmp = true,
                        gitsigns = true,
                        treesitter = true,
                        notify = false,
                        mini = {
                            enabled = true,
                            indentscope_color = "",
                        },
                    },
                }
            })
            vim.cmd.colorscheme("catppuccin")

        end,
    },

    -- { -- You can easily change to a different colorscheme.
    -- 	"folke/tokyonight.nvim",
    -- 	priority = 1000, -- Make sure to load this before all the other start plugins.
    -- 	config = function()
    -- 		---@diagnostic disable-next-line: missing-fields
    -- 		require("tokyonight").setup({
    -- 			styles = {
    -- 				comments = { italic = true }, -- Disable italics in comments
    -- 			},
    -- 		})
    --
    -- 		vim.cmd.colorscheme("tokyonight-storm")
    --
    --      vim.api.nvim_set_hl(0, "Normal", { bg = "none" })
    --      vim.api.nvim_set_hl(0, "NormalNC", { bg = "none" }) -- inactive windowsp
    --      vim.api.nvim_set_hl(0, "NormalFloat", { bg = "none"})
    --    end,
    -- },

    { -- Collection of various small independent plugins/modules
        "echasnovski/mini.nvim",
        config = function()
            require("mini.ai").setup({ n_lines = 10 })
            require("mini.surround").setup()
            require("mini.pairs").setup()
            require("mini.icons").setup()
            require("mini.files").setup({
                mappings = {
                    close = "<ESC>",
                    go_in_plus = "<ENTER>",
                },
                windows = {
                    preview = true,
                    width_focus = 50,
                    width_nofocus = 15,
                    with_preview = 50,
                },
            })

            require("mini.git").setup()

            local diff = require("mini.diff")
            diff.setup()

            local statusline = require("mini.statusline")
            statusline.setup({
                use_icons = vim.g.have_nerd_font,

                content = {
                    active = function ()
                        local mode, mode_hl = MiniStatusline.section_mode({ trunc_width = 120 })

                        -- local filename = vim.fn.expand('%:t')
                        local filename = vim.fn.expand('%:.')
                        if filename == '' then filename = '[No Name]' end

                        local git = MiniStatusline.section_git({ trunc_width = 75 })
                        local diff = MiniStatusline.section_diff({ trunc_width = 75 })
                        local diagnostics = MiniStatusline.section_diagnostics({ trunc_width = 75 })
                        local fileinfo = MiniStatusline.section_fileinfo({ trunc_width = 120 })
                        local location = MiniStatusline.section_location({ trunc_width = 75 })

                        return MiniStatusline.combine_groups({
                            { hl = mode_hl, strings = { mode }},
                            { hl = 'MiniStatuslineFilename', strings = {filename}},
                            { hl = 'MiniStatuslineDevinfo', strings = {git, diff, diagnostics}},
                            '%=',
                            { hl = 'MiniStatuslineFileinfo', strings = {fileinfo}},
                            { hl = 'MiniStatuslineLocation', strings = {location}},
                        })
                    end,
                }
            })

            ---@diagnostic disable-next-line: duplicate-set-field
            statusline.section_location = function()
                return "%2l:%-2v"
            end
        end,
    },
    { -- Highlight, edit, and navigate code
        "nvim-treesitter/nvim-treesitter",
        build = ":TSUpdate",
        main = "nvim-treesitter.configs", -- Sets main module to use for opts
        opts = {
            ensure_installed = {
                "bash",
                "c",
                "diff",
                "html",
                "lua",
                "luadoc",
                "markdown",
                "markdown_inline",
                "query",
                "vim",
                "vimdoc",
                "javascript",
                "typescript",
            },
            auto_install = true,
            highlight = {
                enable = true,
                additional_vim_regex_highlighting = { "ruby" },
            },
            indent = { enable = true, disable = false },
        },
    },
    {
        "numToStr/FTerm.nvim",
        opts = {
            border = "rounded",
            dimensions = {
                height = 0.9,
                width = 0.9,
            },
        },
    },
    { "m4xshen/autoclose.nvim", opts = {} },
    { "mbbill/undotree", config = function()
        vim.keymap.set("n", "<leader>u", vim.cmd.UndotreeToggle)
    end
    },

    { -- multicursor
        "jake-stewart/multicursor.nvim",
        branch = "1.0",
        config = function()
            local mc = require("multicursor-nvim")
            mc.setup()

            local set = vim.keymap.set

            -- Add or skip cursor above/below the main cursor.
            set({"n", "x"}, "<up>", function() mc.lineAddCursor(-1) end)
            set({"n", "x"}, "<down>", function() mc.lineAddCursor(1) end)
            set({"n", "x"}, "<leader><up>", function() mc.lineSkipCursor(-1) end)
            set({"n", "x"}, "<leader><down>", function() mc.lineSkipCursor(1) end)

            -- Add or skip adding a new cursor by matching word/selection
            set({"n", "x"}, "<leader>n", function() mc.matchAddCursor(1) end)
            set({"n", "x"}, "<leader>s", function() mc.matchSkipCursor(1) end)
            set({"n", "x"}, "<leader>N", function() mc.matchAddCursor(-1) end)
            set({"n", "x"}, "<leader>S", function() mc.matchSkipCursor(-1) end)

            -- Add and remove cursors with control + left click.
            set("n", "<c-leftmouse>", mc.handleMouse)
            set("n", "<c-leftdrag>", mc.handleMouseDrag)
            set("n", "<c-leftrelease>", mc.handleMouseRelease)

            -- Disable and enable cursors.
            set({"n", "x"}, "<c-q>", mc.toggleCursor)

            -- Mappings defined in a keymap layer only apply when there are
            -- multiple cursors. This lets you have overlapping mappings.
            mc.addKeymapLayer(function(layerSet)

                -- Select a different cursor as the main one.
                layerSet({"n", "x"}, "<left>", mc.prevCursor)
                layerSet({"n", "x"}, "<right>", mc.nextCursor)

                -- Delete the main cursor.
                layerSet({"n", "x"}, "<leader>x", mc.deleteCursor)

                -- Enable and clear cursors using escape.
                layerSet("n", "<esc>", function()
                    if not mc.cursorsEnabled() then
                        mc.enableCursors()
                    else
                        mc.clearCursors()
                    end
                end)
            end)

            -- Customize how cursors look.
            local hl = vim.api.nvim_set_hl
            hl(0, "MultiCursorCursor", { reverse = true })
            hl(0, "MultiCursorVisual", { link = "Visual" })
            hl(0, "MultiCursorSign", { link = "SignColumn"})
            hl(0, "MultiCursorMatchPreview", { link = "Search" })
            hl(0, "MultiCursorDisabledCursor", { reverse = true })
            hl(0, "MultiCursorDisabledVisual", { link = "Visual" })
            hl(0, "MultiCursorDisabledSign", { link = "SignColumn"})
        end
    },

    {
        "nvimtools/none-ls.nvim",  -- plugin repository
        dependencies = { "nvim-lua/plenary.nvim" },  -- required dependency
        config = function()
            local null_ls = require("null-ls")

            null_ls.setup({
                sources = {
                    null_ls.builtins.formatting.prettier.with({
                        extra_args = { 
                            "--tab-width", "4",
                            "--use-tabs", "false",
                            "--print-width", "9999",
                            "--semi", "null",
                            "--single-quote", "null",
                            "--quote-props", "preserve",
                            "--trailing-comma", "none",
                            "--bracket-spacing", "null",
                            "--arrow-parens", "avoid",
                            "--jsx-single-quote", "null",
                            "--prose-wrap", "never",
                            "--end-of-line", "auto",
                            "--embedded-language-formatting", "off",
                        },
                    }),
                },
            })
        end,
    },

    {
        "mattn/emmet-vim",
        ft = { "html", "css", "javascriptreact", "typescriptreact" },
    }

    -- The following comments only work if you have downloaded the kickstart repo, not just copy pasted the
    -- init.lua. If you want these files, they are in the repository, so you can just download them and
    -- place them in the correct locations.

    -- NOTE: Next step on your Neovim journey: Add/Configure additional plugins for Kickstart
    --
    --  Here are some example plugins that I've included in the Kickstart repository.
    --  Uncomment any of the lines below to enable them (you will need to restart nvim).
    --
    -- require 'kickstart.plugins.debug',
    -- require 'kickstart.plugins.indent_line',
    -- require 'kickstart.plugins.lint',
    -- require 'kickstart.plugins.autopairs',
    -- require 'kickstart.plugins.neo-tree',
    -- require 'kickstart.plugins.gitsigns', -- adds gitsigns recommend keymaps

    -- NOTE: The import below can automatically add your own plugins, configuration, etc from `lua/custom/plugins/*.lua`
    --    This is the easiest way to modularize your config.
    --
    --  Uncomment the following line and add your plugins to `lua/custom/plugins/*.lua` to get going.
    -- { import = 'custom.plugins' },
    --
    -- For additional information with loading, sourcing and examples see `:help lazy.nvim-🔌-plugin-spec`
    -- Or use telescope!
    -- In normal mode type `<space>sh` then write `lazy.nvim-plugin`
    -- you can continue same window with `<space>sr` which resumes last telescope search
}, {
        ui = {
            -- If you are using a Nerd Font: set icons to an empty table which will use the
            -- default lazy.nvim defined Nerd Font icons, otherwise define a unicode icons table
            icons = vim.g.have_nerd_font and {} or {
                cmd = "⌘",
                config = "🛠",
                event = "📅",
                ft = "📂",
                init = "⚙",
                keys = "🗝",
                plugin = "🔌",
                runtime = "💻",
                require = "🌙",
                source = "📄",
                start = "🚀",
                task = "📌",
                lazy = "💤 ",
            },
        },
    })

-- The line beneath this is called `modeline`. See `:help modeline`
-- vim: ts=2 sts=2 sw=2 et
