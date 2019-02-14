set nocompatible              " be iMproved, required
filetype off                  " enabled below after vundle setup

" set the runtime path to include Vundle and initialize
set rtp+=~/.vim/bundle/Vundle.vim

call vundle#begin()
" alternatively, pass a path where Vundle should install plugins
"call vundle#begin('~/some/path/here')

" let Vundle manage Vundle, required
Plugin 'gmarik/Vundle.vim'
Plugin 'JuliaLang/julia-vim'
Plugin 'tpope/vim-commentary'
Plugin 'tpope/vim-surround'
" Plugin 'kana/vim-textobj-indent'
" Plugin 'kana/vim-textobj-line'
Plugin 'vimwiki/vimwiki'
Plugin 'morhetz/gruvbox'
Plugin 'xero/blaquemagick.vim'
Plugin 'itchyny/lightline.vim'
Plugin 'christoomey/vim-tmux-navigator'
Plugin 'dracula/vim'
Plugin 'junegunn/limelight.vim'
Plugin 'leafgarland/typescript-vim'

" All of your Plugins must be added before the following line
call vundle#end()            " required

let g:limelight_conceal_ctermfg = 'gray'
let g:limelight_conceal_ctermfg = 240

" Default: 0.5
let g:limelight_default_coefficient = 0.7

" Number of preceding/following paragraphs to include (default: 0)
let g:limelight_paragraph_span = 1

" Beginning/end of paragraph
"   When there's no empty line between the paragraphs
"   and each paragraph starts with indentation
let g:limelight_bop = '^\s'
let g:limelight_eop = '\ze\n^\s'

" Highlighting priority (default: 10)
"   Set it to -1 not to overrule hlsearch
let g:limelight_priority = -1
set expandtab
set shiftwidth=4
set tabstop=4
filetype plugin indent on

" store .swp files in a different directory - don't pollute git trees
set backupdir=~/.vim/backups//
set directory=~/.vim/backups//

"better clipboard - combined for OS + editor
set clipboard=unnamedplus

" persistent undo
if has('persistent_undo')
    set undofile
    set undolevels=1000         " Maximum number of changes that can be undone
    set undoreload=10000        " Maximum number lines to save for undo on a buffer reload
endif

set number
set relativenumber

" colorscheme
set background=dark
let g:gruvbox_contrast_dark='soft'
colorscheme dracula

"folding settings
let g:vimwiki_folding='list'
