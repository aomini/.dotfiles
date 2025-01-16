lvim.format_on_save = true

-- local capabilities = require("lvim.lsp").common_capabilities()
-- capabilities.offsetEncoding = { "utf-16" }

local formatters = require "lvim.lsp.null-ls.formatters"
formatters.setup {
  { exe = "clang-format", filetypes = { "cpp", "c" } },
  { exe = "prettier" }
}

local linters = require "lvim.lsp.null-ls.linters";
linters.setup {
  { name = 'eslint_d' }
}

local codeActions = require "lvim.lsp.null-ls.code_actions"
codeActions.setup {
  { name = 'eslint_d' }
}

vim.opt.wrap = true

-- Compile c++
--autocmd vimEnter *.cpp map <F8> :w <CR> :!clear ; g++ --std=c++17 %; if [ -f a.out ]; then time ./a.out; rm a.out; fi <CR>

lvim.builtin.which_key.mappings["r"] = {
  name = "Run & build",
  c    = { "<cmd>:w <CR> <cmd>term clear; g++ --std=c++17 %; if [ -f a.out ]; then time ./a.out; rm a.out; fi <CR> <cmd>startinsert<CR>", "Build C++ code" },
  d    = { "<cmd>:w <CR> <cmd>term clear; g++ --std=c++17 --debug %;<CR>", "Compile C++ with debug flags" },
}

-- Fold
vim.opt.foldmethod = "expr"
vim.opt.foldexpr = "nvim_treesitter#foldexpr()"
vim.opt.foldenable = false
lvim.plugins = {
  {
    "ThePrimeagen/harpoon",
    branch = "harpoon2",
    dependencies = { "nvim-lua/plenary.nvim" },
    event = "VeryLazy",
    config = function()
      local harpoon = require('harpoon')
      harpoon:setup({
        settings = {
          save_on_toggle = true
        }
      })

      -- basic telescope configuration
      local conf = require("telescope.config").values
      local function toggle_telescope(harpoon_files)
        local file_paths = {}
        for _, item in ipairs(harpoon_files.items) do
          table.insert(file_paths, item.value)
        end

        require("telescope.pickers").new({
        }, {
          -- Default: Harpoon
          prompt_title = "Pudge Hook",
          finder = require("telescope.finders").new_table({
            results = file_paths,
          }),
          --previewer = conf.file_previewer({}),
          sorter = conf.generic_sorter({}),
          initial_mode = "normal", -- Start in normal mode
        }):find()
      end

      vim.keymap.set("n", "<leader>hf", function() toggle_telescope(harpoon:list()) end,
        { desc = "Open harpoon window" })
    end,
    keys = {
      { "<leader>ha", function() require('harpoon'):list():add() end },
      { "<leader>hn", function() require('harpoon'):list():next() end },
      { "<leader>hp", function() require('harpoon'):list():prev() end },
      { "<leader>h1", function() require('harpoon'):list():select(1) end, desc = "Harpoon to file 1" },
      { "<leader>h2", function() require('harpoon'):list():select(2) end, desc = "Harpoon to file 2" },
      { "<leader>h3", function() require('harpoon'):list():select(3) end, desc = "Harpoon to file 3" },
      { "<leader>h4", function() require('harpoon'):list():select(4) end, desc = "Harpoon to file 4" },
    }
  },
  {
    'windwp/nvim-ts-autotag',
    config = function()
      require('nvim-ts-autotag').setup({
        opts = { enable_close = true, enable_rename = true, enable_close_on_slash = false }
      })
    end,
  },
  {
    'smoka7/hop.nvim',
    event = "BufRead",
    config = function()
      require('hop').setup()
      vim.api.nvim_set_keymap("n", "s", ":HopChar2<cr>", { silent = true })
      vim.api.nvim_set_keymap("n", "S", ":HopWord<cr>", { silent = true })
      vim.api.nvim_set_keymap("n", "<leader>k", ":HopLineStartBC<cr>", { silent = true })
      vim.api.nvim_set_keymap("n", "<leader>j", ":HopLineStartAC<cr>", { silent = true })
      vim.api.nvim_set_keymap("n", "<leader>W", ":HopWordCurrentLineAC<cr>", { silent = true })
      vim.api.nvim_set_keymap("n", "<leader>B", ":HopWordCurrentLineBC<cr>", { silent = true })
    end,
  },
}

vim.diagnostic.config({ virtual_text = true })
lvim.builtin.treesitter.highlight.enable = true
-- auto install treesitter parsers
lvim.builtin.treesitter.ensure_installed = { "cpp", "c" }

-- Additional Plugins
table.insert(lvim.plugins, {
  "p00f/clangd_extensions.nvim",
})

vim.list_extend(lvim.lsp.automatic_configuration.skipped_servers, { "clangd" })

-- some settings can only passed as commandline flags, see `clangd --help`
local clangd_flags = {
  -- capabilities,
  "--background-index",
  "--fallback-style=Google",
  "--all-scopes-completion",
  "--clang-tidy",
  "--log=error",
  "--suggest-missing-includes",
  "--cross-file-rename",
  "--completion-style=detailed",
  "--pch-storage=memory",     -- could also be disk
  "--folding-ranges",
  "--enable-config",          -- clangd 11+ supports reading from .clangd configuration file
  "--offset-encoding=utf-16", --temporary fix for null-ls
  -- "--limit-references=1000",
  -- "--limit-resutls=1000",
  -- "--malloc-trim",
  -- "--clang-tidy-checks=-*,llvm-*,clang-analyzer-*,modernize-*,-modernize-use-trailing-return-type",
  -- "--header-insertion=never",
  -- "--query-driver=<list-of-white-listed-complers>"
}

local provider = "clangd"

local custom_on_attach = function(client, bufnr)
  require("lvim.lsp").common_on_attach(client, bufnr)

  local opts = { noremap = true, silent = true, buffer = bufnr }
  vim.keymap.set("n", "<leader>lh", "<cmd>ClangdSwitchSourceHeader<cr>", opts)
  vim.keymap.set("x", "<leader>lA", "<cmd>ClangdAST<cr>", opts)
  vim.keymap.set("n", "<leader>lH", "<cmd>ClangdTypeHierarchy<cr>", opts)
  vim.keymap.set("n", "<leader>lt", "<cmd>ClangdSymbolInfo<cr>", opts)
  vim.keymap.set("n", "<leader>lm", "<cmd>ClangdMemoryUsage<cr>", opts)

  require("clangd_extensions.inlay_hints").setup_autocmd()
  require("clangd_extensions.inlay_hints").set_inlay_hints()
end

local status_ok, project_config = pcall(require, "rhel.clangd_wrl")
if status_ok then
  clangd_flags = vim.tbl_deep_extend("keep", project_config, clangd_flags)
end

local custom_on_init = function(client, bufnr)
  require("lvim.lsp").common_on_init(client, bufnr)
  require("clangd_extensions.config").setup {}
  --require("clangd_extensions.ast").init()
  vim.cmd [[
  command ClangdToggleInlayHints lua require('clangd_extensions.inlay_hints').toggle_inlay_hints()
  command -range ClangdAST lua require('clangd_extensions.ast').display_ast(<line1>, <line2>)
  command ClangdTypeHierarchy lua require('clangd_extensions.type_hierarchy').show_hierarchy()
  command ClangdSymbolInfo lua require('clangd_extensions.symbol_info').show_symbol_info()
  command -nargs=? -complete=customlist,s:memuse_compl ClangdMemoryUsage lua require('clangd_extensions.memory_usage').show_memory_usage('<args>' == 'expand_preamble')
  ]]
end

local opts = {
  cmd = { provider, unpack(clangd_flags) },
  on_attach = custom_on_attach,
  on_init = custom_on_init,
}

require("lvim.lsp.manager").setup("clangd", opts)

-- install codelldb with :MasonInstall codelldb
-- configure nvim-dap (codelldb)
lvim.builtin.dap.on_config_done = function(dap)
  dap.adapters.codelldb = {
    type = "server",
    port = "${port}",
    executable = {
      -- provide the absolute path for `codelldb` command if not using the one installed using `mason.nvim`
      command = "codelldb",
      args = { "--port", "${port}" },

      -- On windows you may have to uncomment this:
      -- detached = false,
    },
  }

  dap.configurations.cpp = {
    {
      name = "Launch file",
      type = "codelldb",
      request = "launch",
      program = function()
        local path
        vim.ui.input({ prompt = "Path to executable: ", default = vim.loop.cwd() .. "/build/" }, function(input)
          path = input
        end)
        vim.cmd [[redraw]]
        return path
      end,
      cwd = "${workspaceFolder}",
      stopOnEntry = false,
    },
  }

  dap.configurations.c = dap.configurations.cpp
end

-- Auto command terminal
local autocmd = vim.api.nvim_create_autocmd

autocmd('TermOpen', {
  group = vim.api.nvim_create_augroup('custom-term-open', { clear = true }),
  callback = function()
    vim.opt.number = false
    vim.opt.relativenumber = false
    vim.opt.cursorline = false
    vim.opt.cursorcolumn = false
  end,
})

autocmd('TermOpen', {
  pattern = '',
  command = 'startinsert'
})

autocmd('TermClose', {
  pattern = 'term://*',
  callback = function()
    local buffnr = vim.api.nvim_get_current_buf();
    -- local jobId = vim.api.nvim_buf_get_var(buffnr, "term_job_id");
    print(buffnr)
    -- vim.api.nvim_input("<CR>")
  end,
})