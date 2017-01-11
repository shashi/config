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
Plugin 'jpalardy/vim-slime'
Plugin 'monkoose/boa.vim'
Plugin 'vimwiki/vimwiki'
Plugin 'morhetz/gruvbox'
Plugin 'xero/blaquemagick.vim'
Plugin 'itchyny/lightline.vim'
Plugin 'christoomey/vim-tmux-navigator'

" All of your Plugins must be added before the following line
call vundle#end()            " required

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

nnoremap <C-J> <C-W><C-J>
nnoremap <C-K> <C-W><C-K>
nnoremap <C-L> <C-W><C-L>
nnoremap <C-H> <C-W><C-H>

set number

" colorscheme
set background=dark
let g:gruvbox_contrast_dark='soft'
colorscheme gruvbox

"folding settings
let g:vimwiki_folding='list'
