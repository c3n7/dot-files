" vim:foldmethod=marker
" header {{{
set nocompatible              " be iMproved, required
filetype off                  " required
" }}}

" plugins {{{
" Specify a directory for plugins
" - For Neovim: stdpath('data') . '/plugged'
" - Avoid using standard Vim directory names like 'plugin'
call plug#begin('~/.vim/plugged')
" Plug 'itchyny/lightline.vim'
Plug 'vim-airline/vim-airline'
Plug 'vim-airline/vim-airline-themes'
Plug 'dense-analysis/ale'
Plug 'mattn/emmet-vim'
Plug 'godlygeek/tabular'
Plug 'plasticboy/vim-markdown'
Plug 'scrooloose/nerdcommenter'
Plug 'scrooloose/nerdtree'
Plug 'ryanoasis/vim-devicons'
Plug 'Xuyuanp/nerdtree-git-plugin'
Plug 'tiagofumo/vim-nerdtree-syntax-highlight'
Plug 'neoclide/coc.nvim', {'branch': 'release'}
Plug 'iamcco/markdown-preview.nvim', { 'do': { -> mkdp#util#install() } }
Plug 'dart-lang/dart-vim-plugin'
Plug 'junegunn/fzf', { 'do': { -> fzf#install() } }
Plug 'junegunn/fzf.vim'
Plug 'SirVer/ultisnips'
Plug 'tpope/vim-fugitive'
Plug 'tpope/vim-surround'
Plug 'jiangmiao/auto-pairs'
Plug 'maxmellon/vim-jsx-pretty'
Plug 'OmniSharp/omnisharp-vim'
Plug 'francoiscabrol/ranger.vim'
Plug 'kevinhwang91/rnvimr'
Plug 'rbgrouleff/bclose.vim'
Plug 'elkowar/yuck.vim'
Plug 'jwalton512/vim-blade'
Plug 'nvim-treesitter/nvim-treesitter', {'do': ':TSUpdate'}  " We recommend updating the parsers on update

Plug 'nvim-lua/plenary.nvim'
Plug 'folke/todo-comments.nvim'

" For showing errors and stuff
Plug 'kyazdani42/nvim-web-devicons'
Plug 'folke/trouble.nvim'

Plug 'williamboman/nvim-lsp-installer'
Plug 'neovim/nvim-lspconfig'
Plug 'hrsh7th/nvim-cmp' " -- Autocompletion plugin
" Plug 'hrsh7th/cmp-nvim-lsp' " -- LSP source for nvim-cmp
" Plug 'saadparwaiz1/cmp_luasnip' "  -- Snippets source for nvim-cmp
Plug 'L3MON4D3/LuaSnip' " -- Snippets plugin

" Plug 'Chiel92/vim-autoformat'

" theme plugins
Plug 'ellisonleao/gruvbox.nvim'
" Plug 'arcticicestudio/nord-vim'
" Plug 'joshdick/onedark.vim'
" Plug 'sainnhe/sonokai'
" Plug 'sainnhe/edge'

" Initialize plugin system
call plug#end()
" }}}

" plug info {{{
filetype plugin indent on    " required
" To ignore plugin indent changes, instead use:
"filetype plugin on
"
" Brief help
" :PluginList       - lists configured plugins
" :PluginInstall    - installs plugins; append `!` to update or just :PluginUpdate
" :PluginSearch foo - searches for foo; append `!` to refresh local cache
" :PluginClean      - confirms removal of unused plugins; append `!` to auto-approve removal
" }}}

" Nim LSP Completion {{{
lua << EOF
--[[
-- Add additional capabilities supported by nvim-cmp
local capabilities = vim.lsp.protocol.make_client_capabilities()
capabilities = require('cmp_nvim_lsp').update_capabilities(capabilities)

local lspconfig = require('lspconfig')

-- Enable some language servers with the additional completion capabilities offered by nvim-cmp
require("nvim-lsp-installer").setup {}
-- local servers = require'lspinstall'.installed_servers()
local servers = { 'tailwindcss', 'volar', 'lemminx' }
for _, server in pairs(servers) do
  require'lspconfig'[server].setup{}
end

require'lspconfig'['intelephense'].setup{
    settings = {
        intelephense = {
          files = {
            maxSize = 1000000;
          };
          diagnostics = {
            undefinedMethods = false;
          };
        };
        -- https://github.com/bmewburn/intelephense-docs/blob/master/installation.md#configuration-options
  };
}


-- luasnip setup
local luasnip = require 'luasnip'

-- nvim-cmp setup
 local cmp = require 'cmp'
 cmp.setup {
   snippet = {
     expand = function(args)
       luasnip.lsp_expand(args.body)
     end,
   },
   mapping = cmp.mapping.preset.insert({
     ['<C-d>'] = cmp.mapping.scroll_docs(-4),
     ['<C-f>'] = cmp.mapping.scroll_docs(4),
     ['<C-Space>'] = cmp.mapping.complete(),
     ['<CR>'] = cmp.mapping.confirm {
       behavior = cmp.ConfirmBehavior.Replace,
       select = true,
     },
     ['<Tab>'] = cmp.mapping(function(fallback)
       if cmp.visible() then
         cmp.select_next_item()
       elseif luasnip.expand_or_jumpable() then
         luasnip.expand_or_jump()
       else
         fallback()
       end
     end, { 'i', 's' }),
     ['<S-Tab>'] = cmp.mapping(function(fallback)
       if cmp.visible() then
         cmp.select_prev_item()
       elseif luasnip.jumpable(-1) then
         luasnip.jump(-1)
       else
         fallback()
       end
     end, { 'i', 's' }),
   }),
   sources = {
     { name = 'nvim_lsp' },
     { name = 'luasnip' },
   },
 }
 --]]
EOF
" }}}

" Use 24-bit (true-color) mode in Vim/Neovim when outside tmux. {{{
"If you're using tmux version 2.2 or later, you can remove the outermost $TMUX check and use tmux's 24-bit color support
"(see < http://sunaku.github.io/tmux-24bit-color.html#usage > for more information.)
if (empty($TMUX))
  if (has("nvim"))
    "For Neovim 0.1.3 and 0.1.4 < https://github.com/neovim/neovim/pull/2198 >
    let $NVIM_TUI_ENABLE_TRUE_COLOR=1
  endif
  "For Neovim > 0.1.5 and Vim > patch 7.4.1799 < https://github.com/vim/vim/commit/61be73bb0f965a895bfb064ea3e55476ac175162 >
  "Based on Vim patch 7.4.1770 (`guicolors` option) < https://github.com/vim/vim/commit/8a633e3427b47286869aa4b96f2bfc1fe65b25cd >
  " < https://github.com/neovim/neovim/wiki/Following-HEAD#20160511 >
  if (has("termguicolors"))
    set termguicolors
  endif
endif
" }}}

" colorscheme onedark {{{
" let g:airline_theme = 'onedark'
" }}}

" colorscheme nord {{{
" let g:airline_theme = 'nord'
" }}}

" sonokai {{{
" let g:sonokai_style = 'andromeda'
" colorscheme sonokai
" let g:airline_theme = 'sonokai'
" }}}

"  edge theme {{{
" let g:edge_style = 'neon'
" colorscheme edge
" let g:airline_theme = 'edge'
" }}}

" Use gruvbox theme {{{
autocmd vimenter * ++nested colorscheme gruvbox
set background=dark
" for neovide
colorscheme gruvbox
let g:airline_theme = 'base16_gruvbox_dark_medium'
" }}}

" To show the weird icons in airline {{{
let g:airline_powerline_fonts = 1
let g:airline#extensions#tabline#enabled = 1
" }}}

" general editor settings {{{
set expandtab
set tabstop=4
set shiftwidth=4
set softtabstop=4
set number
set relativenumber
" Make the status line visible
set laststatus=2
set guifont=Hasklug\ Nerd\ Font:h10

" packadd termdebug
" }}}

" files to format on save {{{
" au BufWrite *.py :Autoformat
" au BufWrite *.c :Autoformat
" au BufWrite *.cpp :Autoformat
" }}}

" custom styling {{{
highlight Pmenu ctermbg=black ctermfg=white
highlight PmenuSel ctermbg=darkgreen ctermfg=white
highlight Visual cterm=NONE ctermbg=blue ctermfg=NONE guibg=brown
highlight CursorColumn ctermbg=green ctermfg=NONE
"CursorColumn CocHighlightText CocHighlightRead CocHighlightWrite

" For vertsplit
highlight VertSplit cterm=NONE ctermbg=black ctermfg=blue
" }}}

" nerdtree and ranger {{{
" Since I am not using consolas, change the arrows to these
"let g:NERDTreeDirArrowExpandable="\u00BB"
"let g:NERDTreeDirArrowCollapsible="\u00AB"
" Change colors for the files in NERDTree
let g:NERDTreeFileExtensionHighlightFullName = 1
let g:NERDTreeExactMatchHighlightFullName = 1
let g:NERDTreePatternMatchHighlightFullName = 1
let g:NERDTreeHighlightFolders = 1 " enables folder icon highlighting using exact match
let g:NERDTreeHighlightFoldersFullName = 1 " highlights the folder name
" Close NERDtree on file open
let NERDTreeQuitOnOpen = 1
" Keyboard mapping for NERDTree
nmap <leader>ne :NERDTreeToggle<cr>:NERDTreeRefreshRoot<cr>
nmap <leader>mp <Plug>MarkdownPreviewToggle

nmap <leader>nr :RnvimrToggle<cr>
nmap <leader>nR :Ranger<cr>

" Add spaces after comment delimiters by default
let g:NERDSpaceDelims = 1

" Enable trimming of trailing whitespace when uncommenting
let g:NERDTrimTrailingWhitespace = 1

" au VimEnter * NERDTree

let g:NERDTreeGitStatusIndicatorMapCustom = {
    \ "Modified"  : "",
    \ "Staged"    : "",
    \ "Untracked" : "",
    \ "Renamed"   : "",
    \ "Unmerged"  : "═",
    \ "Deleted"   : "",
    \ "Dirty"     : "✗",
    \ "Clean"     : "✔︎",
    \ 'Ignored'   : '',
    \ "Unknown"   : "?"
    \ }
" }}}

" buffer, tab, trouble and fzf shortcuts {{{
nmap <leader>nh :nohls<cr>
" buffer navigation
nmap <leader>bn :bn<cr>
nmap <leader>bp :bp<cr>
" buffer funga
nmap <leader>bf :bdelete<cr>
nmap <leader>bD :bdelete!<cr>
command! BufOnly execute '%bdelete!|edit #|normal `"'
nmap <leader>bc :BufOnly<cr>

" tabs
nmap <leader>tc :tabnew<cr>
nmap <leader>td :tabclose<cr>
nmap <leader>tn :tabnext<cr>
nmap <leader>tp :tabprevious<cr>

" terminal
nmap <leader>tr :terminal<cr>
nmap <leader>ta :tabnew<cr>:terminal<cr>

" Trouble Shortcuts
nnoremap <leader>xx <cmd>TroubleToggle<cr>
nnoremap <leader>xw <cmd>TroubleToggle workspace_diagnostics<cr>
nnoremap <leader>xd <cmd>TroubleToggle document_diagnostics<cr>
nnoremap <leader>xq <cmd>TroubleToggle quickfix<cr>
nnoremap <leader>xl <cmd>TroubleToggle loclist<cr>
nnoremap gR <cmd>TroubleToggle lsp_references<cr>

nmap <leader>ff :Files<cr>
nmap <leader>fg :GFiles<cr>
nmap <leader>fF :Files!<cr>
nmap <leader>fb :BLines<cr>
nmap <leader>fc :BCommits!<cr>
inoremap <Leader>fs <ESC>:Snippets<CR>
" }}}

" uncat {{{
" let g:lightline = {
    " \ 'colorscheme': 'wombat',
    " \ }

let g:UltiSnipsExpandTrigger = "<leader>fu"

" Search but do not jump
nnoremap * :keepjumps normal! mi*`i<CR>

let g:dart_format_on_save = 1

" Disable folding in vim-markdown
let g:vim_markdown_folding_disabled = 1

command! -nargs=0 Prettier :CocCommand prettier.formatFile
nmap <leader>fm :Format<cr>
nmap <leader>fP :Prettier<cr>
nmap <leader>fp :Prettier<cr>
" }}}

" ale {{{

let g:ale_echo_msg_format = '[%linter%]: %s  [%severity%]'

" Do not lint or fix c++ files.
" \ '\.cpp$': {'ale_linters': [], 'ale_fixers': []},
let g:ale_pattern_options = {
\ '\.cc$': {'ale_linters': [], 'ale_fixers': []},
\ '\.h$': {'ale_linters': [], 'ale_fixers': []},
\ '\.java$': {'ale_linters': [], 'ale_fixers': []},
\ '\.php$': {'ale_linters': [], 'ale_fixers': []},
\}

" \   'python': ['black', 'isort', 'autopep8'],
let g:ale_fixers = {
\   '*': ['remove_trailing_lines', 'trim_whitespace'],
\   'python': ['autopep8', 'isort'],
\   'cpp': ['clang-format', 'clangtidy'],
\   'cs': ['uncrustify', 'dotnet-format'],
\}

let g:ale_linters = {
\   'c': [], 'cpp': [], 'rust': [], 'go': [], 'python': ['flake8'], 'sh': [],
\   'html': [], 'css': [], 'javascript': [], 'typescript': [], 'reason': [],
\   'json': [], 'vue': [],
\   'tex': [], 'latex': [], 'bib': [], 'bibtex': [],
\   'cs':['OmniSharp']
\ }

" Set this variable to 1 to fix files when you save them.
let g:ale_fix_on_save = 1

" }}}

"  todo commenter {{{
lua << EOF
  require("todo-comments").setup {
    -- your configuration comes here
    -- or leave it empty to use the default settings
    -- refer to the configuration section below
  }
EOF

nmap <leader>tl :TodoQuickFix<cr>
" }}}

"  tree sitter {{{
lua << EOF
require'nvim-treesitter.configs'.setup {
  -- A list of parser names, or "all" (the first five listed parsers should always be installed)
  ensure_installed = {
      "c",
      "lua", "vim", "vimdoc", "query", "yaml",
      "php",  "css", "javascript",  "typescript", "html"
  },


  -- Install parsers synchronously (only applied to `ensure_installed`)
  sync_install = false,

  -- Automatically install missing parsers when entering buffer
  -- Recommendation: set to false if you don't have `tree-sitter` CLI installed locally
  auto_install = true,


  -- List of parsers to ignore installing (or "all")
  ignore_install = { "rust" },

  ---- If you need to change the installation directory of the parsers (see -> Advanced Setup)
  -- parser_install_dir = "/some/path/to/store/parsers", -- Remember to run vim.opt.runtimepath:append("/some/path/to/store/parsers")!

  highlight = {
    enable = true,

    -- NOTE: these are the names of the parsers and not the filetype. (for example if you want to
    -- disable highlighting for the `tex` filetype, you need to include `latex` in this list as this is
    -- the name of the parser)
    -- list of language that will be disabled
    disable = { "c", "rust" },
    -- Or use a function for more flexibility, e.g. to disable slow treesitter highlight for large files

    disable = function(lang, buf)
        local max_filesize = 100 * 1024 -- 100 KB
        local ok, stats = pcall(vim.loop.fs_stat, vim.api.nvim_buf_get_name(buf))
        if ok and stats and stats.size > max_filesize then
            return true
        end
    end,

    -- Setting this to true will run `:h syntax` and tree-sitter at the same time.
    -- Set this to `true` if you depend on 'syntax' being enabled (like for indentation).
    -- Using this option may slow down your editor, and you may see some duplicate highlights.
    -- Instead of true it can also be a list of languages
    additional_vim_regex_highlighting = false,

  },

}
EOF
" }}}

" coc.nvim {{{
" ==================================================================================
"                               coc.nvim Config
" ==================================================================================
" Some servers have issues with backup files, see #649.
set nobackup
set nowritebackup

" Having longer updatetime (default is 4000 ms = 4 s) leads to noticeable
" delays and poor user experience.
set updatetime=300

" Always show the signcolumn, otherwise it would shift the text each time
" diagnostics appear/become resolved.
set signcolumn=yes

" Use tab for trigger completion with characters ahead and navigate.
" NOTE: There's always complete item selected by default, you may want to enable
" no select by `"suggest.noselect": true` in your configuration file.
" NOTE: Use command ':verbose imap <tab>' to make sure tab is not mapped by
" other plugin before putting this into your config.
inoremap <silent><expr> <TAB>
      \ coc#pum#visible() ? coc#pum#next(1) :
      \ CheckBackspace() ? "\<Tab>" :
      \ coc#refresh()
inoremap <expr><S-TAB> coc#pum#visible() ? coc#pum#prev(1) : "\<C-h>"

" Make <CR> to accept selected completion item or notify coc.nvim to format
" <C-g>u breaks current undo, please make your own choice.
inoremap <silent><expr> <CR> coc#pum#visible() ? coc#pum#confirm()
                              \: "\<C-g>u\<CR>\<c-r>=coc#on_enter()\<CR>"

function! CheckBackspace() abort
  let col = col('.') - 1
  return !col || getline('.')[col - 1]  =~# '\s'
endfunction

" Use <c-space> to trigger completion.
if has('nvim')
  inoremap <silent><expr> <c-space> coc#refresh()
else
  inoremap <silent><expr> <c-@> coc#refresh()
endif

" Use `[g` and `]g` to navigate diagnostics
" Use `:CocDiagnostics` to get all diagnostics of current buffer in location list.
nmap <silent> [g <Plug>(coc-diagnostic-prev)
nmap <silent> ]g <Plug>(coc-diagnostic-next)

" GoTo code navigation.
nmap <silent> gd <Plug>(coc-definition)
nmap <silent> gy <Plug>(coc-type-definition)
nmap <silent> gi <Plug>(coc-implementation)
nmap <silent> gr <Plug>(coc-references)

" Use K to show documentation in preview window.
nnoremap <silent> K :call ShowDocumentation()<CR>

function! ShowDocumentation()
  if CocAction('hasProvider', 'hover')
    call CocActionAsync('doHover')
  else
    call feedkeys('K', 'in')
  endif
endfunction

" Highlight the symbol and its references when holding the cursor.
autocmd CursorHold * silent call CocActionAsync('highlight')

" Symbol renaming.
nmap <leader>rn <Plug>(coc-rename)

" Formatting selected code.
xmap <leader>f  <Plug>(coc-format-selected)
nmap <leader>f  <Plug>(coc-format-selected)

augroup mygroup
  autocmd!
  " Setup formatexpr specified filetype(s).
  autocmd FileType typescript,json setl formatexpr=CocAction('formatSelected')
  " Update signature help on jump placeholder.
  autocmd User CocJumpPlaceholder call CocActionAsync('showSignatureHelp')
augroup end

" Applying codeAction to the selected region.
" Example: `<leader>aap` for current paragraph
xmap <leader>a  <Plug>(coc-codeaction-selected)
nmap <leader>a  <Plug>(coc-codeaction-selected)

" Remap keys for applying codeAction to the current buffer.
nmap <leader>ac  <Plug>(coc-codeaction)
" Apply AutoFix to problem on the current line.
nmap <leader>qf  <Plug>(coc-fix-current)

" Run the Code Lens action on the current line.
nmap <leader>cl  <Plug>(coc-codelens-action)

" Map function and class text objects
" NOTE: Requires 'textDocument.documentSymbol' support from the language server.
xmap if <Plug>(coc-funcobj-i)
omap if <Plug>(coc-funcobj-i)
xmap af <Plug>(coc-funcobj-a)
omap af <Plug>(coc-funcobj-a)
xmap ic <Plug>(coc-classobj-i)
omap ic <Plug>(coc-classobj-i)
xmap ac <Plug>(coc-classobj-a)
omap ac <Plug>(coc-classobj-a)

" Remap <C-f> and <C-b> for scroll float windows/popups.
if has('nvim-0.4.0') || has('patch-8.2.0750')
  nnoremap <silent><nowait><expr> <C-f> coc#float#has_scroll() ? coc#float#scroll(1) : "\<C-f>"
  nnoremap <silent><nowait><expr> <C-b> coc#float#has_scroll() ? coc#float#scroll(0) : "\<C-b>"
  inoremap <silent><nowait><expr> <C-f> coc#float#has_scroll() ? "\<c-r>=coc#float#scroll(1)\<cr>" : "\<Right>"
  inoremap <silent><nowait><expr> <C-b> coc#float#has_scroll() ? "\<c-r>=coc#float#scroll(0)\<cr>" : "\<Left>"
  vnoremap <silent><nowait><expr> <C-f> coc#float#has_scroll() ? coc#float#scroll(1) : "\<C-f>"
  vnoremap <silent><nowait><expr> <C-b> coc#float#has_scroll() ? coc#float#scroll(0) : "\<C-b>"
endif

" Use CTRL-S for selections ranges.
" Requires 'textDocument/selectionRange' support of language server.
nmap <silent> <C-s> <Plug>(coc-range-select)
xmap <silent> <C-s> <Plug>(coc-range-select)

" Add `:Format` command to format current buffer.
command! -nargs=0 Format :call CocActionAsync('format')

" Add `:Fold` command to fold current buffer.
command! -nargs=? Fold :call     CocAction('fold', <f-args>)

" Add `:OR` command for organize imports of the current buffer.
command! -nargs=0 OR   :call     CocActionAsync('runCommand', 'editor.action.organizeImport')

" Add (Neo)Vim's native statusline support.
" NOTE: Please see `:h coc-status` for integrations with external plugins that
" provide custom statusline: lightline.vim, vim-airline.
set statusline^=%{coc#status()}%{get(b:,'coc_current_function','')}

" Mappings for CoCList
" Show all diagnostics.
nnoremap <silent><nowait> <space>a  :<C-u>CocList diagnostics<cr>
" Manage extensions.
nnoremap <silent><nowait> <space>e  :<C-u>CocList extensions<cr>
" Show commands.
nnoremap <silent><nowait> <space>c  :<C-u>CocList commands<cr>
" Find symbol of current document.
nnoremap <silent><nowait> <space>o  :<C-u>CocList outline<cr>
" Search workspace symbols.
nnoremap <silent><nowait> <space>s  :<C-u>CocList -I symbols<cr>
" Do default action for next item.
nnoremap <silent><nowait> <space>j  :<C-u>CocNext<CR>
" Do default action for previous item.
nnoremap <silent><nowait> <space>k  :<C-u>CocPrev<CR>
" Resume latest coc list.
nnoremap <silent><nowait> <space>p  :<C-u>CocListResume<CR>" Setup Prettier
command! -nargs=0 Prettier :CocCommand prettier.formatFile
" ==================================================================================
"                               end coc.nvim Config
" ==================================================================================
" }}}
