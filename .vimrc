" Standard vim settings {{{
" Disable GUI Items {{{
set go-=m
set go-=M
set go-=T
set go-=r
set go-=L
" }}}
set nocompatible               " use vim defaults
set autoindent                 " set auto-indenting on for programming
set relativenumber             " show relative line numbers
set number                     " show line number on the current line
set incsearch                  " do incremental searching
set hlsearch                   " highlight searches
set showmatch                  " jump to matches when entering regexp
set ignorecase                 " ignore case when searching
set smartcase                  " no ignorecase if Uppercase char present
set nowrap                     " turn off text wrapping
set noswapfile                 " turn off creation of .swp files everywhere
set splitbelow                 " create splits below instead of above
set splitright                 " create splits to the right instead of to the left
set wildmenu                   " turn on command line completion menu
set wildmode=longest:full,list:full " setup command line completion mode
set backspace=indent,eol,start " make that backspace key work the way it should
set colorcolumn=80,100         " display a vertical line at 80 chars
set foldmethod=marker          " set the foldmethod to custom comment markers
set tabstop=4                  " make tabs have a width of 4
set shiftwidth=4               " make indents have a width of 4
set fillchars=vert:\           " make vertical splits look less stupid
set noshowmode				   " dont show the mode (insert/normal) as airline will
set laststatus=2			   " make airline always be displayed
set encoding=utf-8			   " use the utf-8 character set
set list lcs=tab:\|\           " use vertical bars to show indent levels
syntax on                      " turn syntax highlighting on by default
" }}}
" Commands and auto commands {{{
" trim trailing whitespace for everything except markdown and vim
let blacklist = '^vim$\|^mkd$\|^markdown$'
autocmd BufWritePre * if &ft !~# blacklist | :%s/\s\+$//e
" make all grep commands open the quick fix window
autocmd QuickFixCmdPost *grep* cwindow
" open a mirror of Tagbar for all new tabs
autocmd BufWinEnter * TagbarOpen
" set :Todo to display all TODO and FIXME comments
command Todo vimgrep /TODO\|FIXME/j ** | cw
" set :Vimrc to open the .vimrc in a new tab
command Vimrc tabnew $MYVIMRC
" }}}
" Custom key mappings {{{
" Make Y work properly {{{
map Y y$
" }}}
" Remove Up Down Left Right mapping {{{
" Normal modes {{{
map <Up> <NOP>
map <Down> <NOP>
map <left> <NOP>
map <Right> <NOP>
map <C-Up> <NOP>
map <C-Down> <NOP>
map <C-left> <NOP>
map <C-Right> <NOP>
map <S-Up> <NOP>
map <S-Down> <NOP>
map <S-left> <NOP>
map <S-Right> <NOP>
map <A-Up> <NOP>
map <A-Down> <NOP>
map <A-left> <NOP>
map <A-Right> <NOP>
" }}}
" Insert mode {{{
imap <Up> <NOP>
imap <Down> <NOP>
imap <left> <NOP>
imap <Right> <NOP>
imap <C-Up> <NOP>
imap <C-Down> <NOP>
imap <C-left> <NOP>
imap <C-Right> <NOP>
imap <S-Up> <NOP>
imap <S-Down> <NOP>
imap <S-left> <NOP>
imap <S-Right> <NOP>
imap <A-Up> <NOP>
imap <A-Down> <NOP>
imap <A-left> <NOP>
imap <A-Right> <NOP>
" }}}
" }}}
" Remap Q to save and Ctrl+q to quit {{{
noremap Q :w<CR>
noremap <C-q> :q<CR>
" }}}
" Map \a to align the given pattern with Tabular {{{
noremap <Leader>a :Tabular<Space>/
" }}}
" Map Enter to removing search highlighting {{{
noremap <CR> :nohlsearch<CR>
" }}}
" Remap Ctrl + hjkl to switch focues between panes {{{
noremap <C-J> <C-W><C-J>
noremap <C-K> <C-W><C-K>
noremap <C-L> <C-W><C-L>
noremap <C-H> <C-W><C-H>
" }}}
" Remove mappings for Ctrl + npes so that ultisnips can use them {{{
map <C-N> <NOP>
map <C-P> <NOP>
map <C-E> <NOP>
map <C-S> <NOP>
" }}}
" Remap K to split the line (opposite of J) {{{
nnoremap K i<CR><ESC>
" }}}
" Map F5 to run :make {{{
" Map F5 to build and run python files
nnoremap <F5> :make!<CR>
" }}}
" Mappings for tab navigation {{{
" Map Alt + qo to close and open tabs {{{
nnoremap <A-q> :tabclose<CR>
nnoremap <A-o> :tabnew<CR>
" }}}
" Map Alt + hl to switch between tabs {{{
nnoremap <A-h> :tabprevious<CR>
nnoremap <A-l> :tabnext<CR>
" }}}
" }}}
" }}}
" Setup Vundle {{{
filetype off
set rtp+=~/.vim/bundle/Vundle.vim
call vundle#begin()

" let Vundle manage Vundle
Bundle 'gmarik/vundle'
" }}}
" Custom bundle definitions {{{
" Github repos {{{
Bundle 'tomasr/molokai'
Bundle 'godlygeek/tabular'
Bundle 'scrooloose/nerdtree'
Bundle 'scrooloose/nerdcommenter'
Bundle 'scrooloose/syntastic'
Bundle 'jistr/vim-nerdtree-tabs'
Bundle 'Valloric/YouCompleteMe'
Bundle 'SirVer/ultisnips'
Bundle 'honza/vim-snippets'
Bundle 'Raimondi/delimitMate'
Bundle 'majutsushi/tagbar'
Bundle 'bkad/CamelCaseMotion'
Bundle 'tpope/vim-repeat'
Bundle 'tpope/vim-surround'
Bundle 'tpope/vim-fugitive'
Bundle 'bling/vim-airline'
Bundle 'airblade/vim-gitgutter'
Bundle 'othree/html5.vim'
Bundle 'wellle/targets.vim'
Bundle 'nathanaelkane/vim-indent-guides'
Bundle 'jdonaldson/vaxe'
Bundle 'rust-lang/rust.vim'
Bundle 'rdnetto/YCM-Generator'
Bundle 'osyo-manga/vim-over'
Bundle 'PotatoesMaster/i3-vim-syntax'
Bundle 'sirtaj/vim-openscad'
" }}}
" Vim-scripts repos {{{
Bundle 'HTML-AutoCloseTag'
" }}}
" }}}
" Post bundle commands {{{
" End Vundle
call vundle#end()
" Turn filetype based syntax and indenting on
filetype plugin indent on
filetype on
" Set the colorscheme to molokai dark (vim version of TextMate's monokai)
colorscheme molokai
set background=dark
" Change Ultisnips keybindings to prevent conflicts with YouCompleteMe
let g:UltiSnipsExpandTrigger="<C-E>"
let g:UltiSnipsListSnippets="<C-S>"
let g:UltiSnipsJumpForwardTrigger="<C-Tab>"
let g:UltiSnipsJumpBackwardTrigger="<C-S-Tab>"
" Get delimitMate to auto indent the newline after an open squiggly bracket
let delimitMate_expand_cr = 1
" Set NERDTree to ignore java .class and .ctxt files
let NERDTreeIgnore = ['\.class$', '\.ctxt$', '\.pyc$']
" Allow YouCompleteMe to complete inside comments
let g:ycm_complete_in_comments = 1
" Disable YouCompleteMe asking to load C++ configs
let g:ycm_confirm_extra_conf = 0
" Setup vim-airline
let g:airline_powerline_fonts = 1
let g:airline#extensions#tabline#enabled = 1
let g:airline#extensions#whitespace#enabled = 0
" }}}
