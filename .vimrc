call plug#begin('~/.local/share/nvim/plugged')

" LSP Support
Plug 'neovim/nvim-lspconfig'            " Better LSP config support for Neovim native LSP client
Plug 'williamboman/mason.nvim'          " Optional: Manage external LSP servers
Plug 'williamboman/mason-lspconfig.nvim'  " Mason integration with lspconfig

" Completion (lightweight)
Plug 'hrsh7th/nvim-cmp'                 " Completion engine
Plug 'hrsh7th/cmp-nvim-lsp'            " LSP source for nvim-cmp
Plug 'hrsh7th/cmp-buffer'              " Buffer source for nvim-cmp

" FZF fuzzy finder
Plug 'junegunn/fzf', { 'do': { -> fzf#install() } }
Plug 'junegunn/fzf.vim'

"Cal
Plug 'itchyny/calendar.vim'

" Syntax highlighting collection
Plug 'sheerun/vim-polyglot'

" Colorscheme
Plug 'morhetz/gruvbox'
Plug 'dense-analysis/ale'

Plug 'nvim-lua/plenary.nvim'

" AI assistance
Plug 'samir-roy/code-bridge.nvim'

" Git
Plug 'f-person/git-blame.nvim'

call plug#end()

" Set leader key to space (must be before any leader mappings)
let mapleader = " "

" linting and language support
let g:ale_fixers = {
\   '*': ['remove_trailing_lines', 'trim_whitespace'],
\   'elixir': ['mix_format'],
\   'python': ['black', 'ruff'],
\   'javascript': ['prettier'],
\   'typescript': ['prettier'],
\   'typescriptreact': ['prettier'],
\   'javascriptreact': ['prettier']
\}

let g:ale_fix_on_save = 1
let g:ale_enabled = 0  " Start with ALE disabled for performance

" Preserve undo history when formatting with ALE
augroup ALEProgress
    autocmd!
    autocmd User ALEFixPre  try | silent undojoin | catch | endtry
augroup END

" LSP mappings (we'll configure these in lua)
nmap <silent> gd :lua vim.lsp.buf.definition()<CR>
nmap <silent> gr :lua vim.lsp.buf.references()<CR>
nmap <silent> K :lua vim.lsp.buf.hover()<CR>
nmap <silent> <leader>rn :lua vim.lsp.buf.rename()<CR>
nmap <silent> <leader>ca :lua vim.lsp.buf.code_action()<CR>

" Toggle diagnostics
nmap <silent> <leader>td :lua ToggleDiagnostics()<CR>
nmap <silent> <leader>ti :lua ToggleInlayHints()<CR>

" Show diagnostic details
nmap <silent> <leader>e :lua vim.diagnostic.open_float()<CR>
nmap <silent> [d :lua vim.diagnostic.goto_prev()<CR>
nmap <silent> ]d :lua vim.diagnostic.goto_next()<CR>


" Numbers & UI
set number
set mouse=a
set clipboard^=unnamedplus
set cursorline
set termguicolors
set background=dark
syntax enable
filetype plugin indent on
colorscheme gruvbox

" Make cursor more visible
set guicursor=n-v-c:block-Cursor,i:ver25-CursorInsert,r-cr-o:hor20
autocmd ColorScheme * highlight CursorInsert guibg=#fabd2f guifg=#282828
autocmd ColorScheme * highlight Cursor guibg=#ebdbb2 guifg=#282828
doautocmd ColorScheme

" Line wrapping
set wrap
set linebreak
set showbreak=↪\

" Persistent undo
set undofile
set undodir=~/.config/nvim/undodir
set undolevels=10000
set undoreload=10000

" Scroll settings
set scrolloff=4
set sidescrolloff=4

set lazyredraw       " Don't redraw during macros/commands

" Tabs
set tabstop=4 shiftwidth=4 expandtab

" File type specific settings
autocmd FileType typescript,typescriptreact,javascript,javascriptreact setlocal tabstop=2 shiftwidth=2

" FZF mappings
nnoremap <C-p> :Files<CR>

" Window navigation
nnoremap <C-j> <C-W>j
nnoremap <C-k> <C-W>k
nnoremap <C-h> <C-W>h
nnoremap <C-l> <C-W>l

" Quit mapping
nnoremap <C-q> :q!<CR>

" --- LSP and completion config ---
lua <<EOF
-- Setup Mason first
require("mason").setup()

-- Simple LSP setup without mason-lspconfig auto-enable
local lspconfig = require("lspconfig")
local capabilities = require('cmp_nvim_lsp').default_capabilities()

-- Configure diagnostics display
vim.diagnostic.config({
    virtual_text = {
        prefix = '●',
        source = 'if_many',
        -- Limit the virtual text width
        format = function(diagnostic)
            local max_width = 50
            local message = diagnostic.message
            if string.len(message) > max_width then
                return string.sub(message, 1, max_width) .. '...'
            end
            return message
        end,
    },
    float = {
        source = 'always',
        border = 'rounded',
    },
})

-- LSP on_attach function
local on_attach = function(client, bufnr)
    -- Apply current global state to new buffers
    vim.diagnostic.enable(_G.diagnostics_enabled, { bufnr = bufnr })

    -- Apply inlay hints state if supported
    if client.server_capabilities.inlayHintProvider then
        vim.lsp.inlay_hint.enable(_G.inlay_hints_enabled, { bufnr = bufnr })
    end
end

-- Setup Python LSP manually
if vim.fn.executable("basedpyright-langserver") == 1 then
    lspconfig.basedpyright.setup({
        on_attach = on_attach,
        capabilities = capabilities,
        settings = {
            basedpyright = {
                analysis = {
                    typeCheckingMode = "strict",
                    autoImportCompletions = true,
                    inlayHints = {
                        variableTypes = true,
                        functionReturnTypes = true,
                        callArgumentNames = true,
                        pytestParameters = true,
                    },
                },
            },
        },
    })
end

-- Setup Elixir LSP manually
local elixirls_path = vim.fn.expand("~/.local/share/nvim/mason/bin/elixir-ls")
if vim.fn.executable(elixirls_path) == 1 then
    lspconfig.elixirls.setup({
        on_attach = on_attach,
        capabilities = capabilities,
        cmd = { elixirls_path },
        root_dir = lspconfig.util.root_pattern("mix.exs", ".git") or vim.fn.getcwd,
        settings = {
            elixirLS = {
                dialyzerEnabled = false,  -- Start with Dialyzer disabled for performance
                fetchDeps = false,        -- Don't fetch deps automatically
                incrementalDialyzer = false
            }
        }
    })
end

-- Setup TypeScript LSP
local tsserver_path = vim.fn.expand("~/.local/share/nvim/mason/bin/typescript-language-server")
if vim.fn.executable(tsserver_path) == 1 or vim.fn.executable("typescript-language-server") == 1 then
    lspconfig.ts_ls.setup({
        on_attach = on_attach,
        capabilities = capabilities,
        settings = {
            typescript = {
                inlayHints = {
                    includeInlayParameterNameHints = 'all',
                    includeInlayParameterNameHintsWhenArgumentMatchesName = false,
                    includeInlayFunctionParameterTypeHints = true,
                    includeInlayVariableTypeHints = true,
                    includeInlayVariableTypeHintsWhenTypeMatchesName = false,
                    includeInlayPropertyDeclarationTypeHints = true,
                    includeInlayFunctionLikeReturnTypeHints = true,
                    includeInlayEnumMemberValueHints = true,
                }
            },
            javascript = {
                inlayHints = {
                    includeInlayParameterNameHints = 'all',
                    includeInlayParameterNameHintsWhenArgumentMatchesName = false,
                    includeInlayFunctionParameterTypeHints = true,
                    includeInlayVariableTypeHints = true,
                    includeInlayVariableTypeHintsWhenTypeMatchesName = false,
                    includeInlayPropertyDeclarationTypeHints = true,
                    includeInlayFunctionLikeReturnTypeHints = true,
                    includeInlayEnumMemberValueHints = true,
                }
            }
        },
    })
end

-- Setup nvim-cmp for completion
local cmp = require('cmp')
cmp.setup({
    enabled = false,  -- Start with completion disabled
    mapping = {
        ['<Tab>'] = cmp.mapping(cmp.mapping.select_next_item(), {'i', 's'}),
        ['<S-Tab>'] = cmp.mapping(cmp.mapping.select_prev_item(), {'i', 's'}),
        ['<CR>'] = cmp.mapping.confirm({ select = true }),
        ['<C-Space>'] = cmp.mapping.complete(),
    },
    sources = cmp.config.sources({
        { name = 'nvim_lsp' },
        { name = 'buffer' },
    })
})

-- Global state for toggles
_G.completion_enabled = false
_G.dialyzer_enabled = false
_G.diagnostics_enabled = true  -- Start with diagnostics ON
_G.inlay_hints_enabled = false

-- Function to toggle Dialyzer
function ToggleDialyzer()
    _G.dialyzer_enabled = not _G.dialyzer_enabled
    for _, client in pairs(vim.lsp.get_active_clients()) do
        if client.name == "elixirls" then
            -- Update the settings
            if not client.config.settings then
                client.config.settings = {}
            end
            if not client.config.settings.elixirLS then
                client.config.settings.elixirLS = {}
            end
            client.config.settings.elixirLS.dialyzerEnabled = _G.dialyzer_enabled

            -- Send the notification
            client.notify("workspace/didChangeConfiguration", {
                settings = client.config.settings
            })

        end
    end
    if _G.dialyzer_enabled then
        print("Dialyzer enabled (may take time on first run)")
    else
        print("Dialyzer disabled")
    end
end

function ToggleInlayHints()
    _G.inlay_hints_enabled = not _G.inlay_hints_enabled
    vim.lsp.inlay_hint.enable(_G.inlay_hints_enabled)
    if _G.inlay_hints_enabled then
        print("Inlay hints enabled")
    else
        print("Inlay hints disabled")
    end
end

-- Function to toggle completion
function ToggleCompletion()
    _G.completion_enabled = not _G.completion_enabled
    require('cmp').setup({ enabled = _G.completion_enabled })
    if _G.completion_enabled then
        print("Completion enabled")
    else
        print("Completion disabled")
    end
end

-- Function to toggle diagnostics
function ToggleDiagnostics()
    _G.diagnostics_enabled = not _G.diagnostics_enabled
    vim.diagnostic.enable(_G.diagnostics_enabled)
    if _G.diagnostics_enabled then
        print("Diagnostics enabled")
    else
        print("Diagnostics disabled")
    end
end

-- Setup code-bridge for Claude integration
require('code-bridge').setup({
    use_tmux = true,
    tmux_target = "claude",  -- Target tmux window name
})

EOF

" Claude Code integration - send to Claude
nmap <leader>cc :CodeBridgeTmux<CR>
vmap <leader>cc :'<,'>CodeBridgeTmux<CR>

" Additional toggle commands
nmap <silent> <leader>tc :lua ToggleCompletion()<CR>
nmap <silent> <leader>ta :ALEToggle<CR>
nmap <silent> <leader>tz :lua ToggleDialyzer()<CR>

" Git commands
nmap <silent> <leader>gb :GitBlameToggle<CR>
nmap <silent> <leader>go :GitBlameOpenCommitURL<CR>

" Disable git blame on startup
autocmd VimEnter * GitBlameDisable
