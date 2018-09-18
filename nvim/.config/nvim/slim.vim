" vim:foldmethod=marker:foldlevel=0

" Standard vim settings {{{
set mouse=a                    " Some gibberish to make the mouse work in tmux on mac
set relativenumber             " show relative line numbers
set number                     " show line number on the current line
set autoread                   " automatically reload buffers when changed outside of vim
set showmatch                  " jump to matches when entering regexp
set ignorecase                 " ignore case when searching
set smartcase                  " no ignorecase if Uppercase char present
set nowrap                     " turn off text wrapping
set noswapfile                 " turn off creation of .swp files everywhere
set splitbelow                 " create splits below instead of above
set splitright                 " create splits to the right instead of to the left
set wildmode=longest:full,list:full " setup command line completion mode
set colorcolumn=80,100         " display a vertical line at 80 chars
set modeline
set modelines=5                " allow the use of file-specific modeline configs
set foldlevel=0                " close all folds by default on file open
set foldmethod=syntax          " set foldmethod
set tabstop=4                  " make tabs have a width of 4
set softtabstop=4              " not really sure what this changes to be honest
set shiftwidth=4               " make indents have a width of 4
set expandtab                  " expand tabs into spaces when used for indentation
set fillchars=vert:\           " make vertical splits look less stupid
set noshowmode                 " dont show the mode (insert/normal) as airline will
set list lcs=tab:\|\           " use vertical bars to show indent levels
set inccommand=split           " make use of NeoVim's new live search/replace
set encoding=utf-8             " force utf-8 encoding

" setup ignore wildcards for everything
set wildignore+=node_modules/**,obj/**,bin/**,coverage/**,public/**,**.jpg,**.svg
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
" Remap H and L to go to the start and end of line {{{
noremap H ^
noremap L $
" }}}
" Use backspace to quick switch buffers {{{
noremap <BS> <C-6>
" }}}
" Remap Q to save and Ctrl+q to quit {{{
noremap Q :w<CR>
noremap <C-q> :q<CR>
" }}}
" Map Enter to removing search highlighting {{{
noremap <CR> :nohlsearch<CR>
" }}}
" Remap Ctrl + hjkl to switch focues between panes {{{
noremap <C-J> <C-W><C-J>
noremap <C-K> <C-W><C-K>
noremap <C-L> <C-W><C-L>
noremap <C-H> <C-W><C-H>
noremap <BS> <C-W><C-H>
" }}}
" Remap K to split the line (opposite of J) {{{
nnoremap K i<CR><ESC>
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
" Custom bundle definitions {{{
call plug#begin()
" let vim-plug manage itself
Plug 'junegunn/vim-plug'
" various other plugins
Plug 'tomasr/molokai'
Plug 'scrooloose/nerdcommenter'
Plug 'airblade/vim-gitgutter'
Plug 'Raimondi/delimitMate'
Plug 'tpope/vim-repeat'
Plug 'tpope/vim-surround'
Plug 'tpope/vim-fugitive'
Plug 'bling/vim-airline'
Plug 'wellle/targets.vim'
Plug 'Yggdroot/indentLine'
Plug 'elzr/vim-json', { 'for': 'json' }
Plug 'mxw/vim-jsx', { 'for': [ 'javascript', 'javascript.jsx' ] }
Plug 'othree/es.next.syntax.vim', { 'for': [ 'javascript', 'javascript.jsx' ] }
Plug 'othree/javascript-libraries-syntax.vim', { 'for': [ 'javascript', 'javascript.jsx' ] }
Plug 'Shougo/vimproc.vim', { 'do': 'make' }
Plug 'Quramy/tsuquyomi', { 'for': 'typescript' }
Plug 'othree/html5.vim', { 'for': 'html' }
Plug 'rust-lang/rust.vim', { 'for': 'rust' }
Plug 'octol/vim-cpp-enhanced-highlight', { 'for': 'cpp' }
Plug 'jparise/vim-graphql'
Plug 'christoomey/vim-tmux-navigator'
Plug 'tmux-plugins/vim-tmux-focus-events'
Plug 'ryanoasis/vim-devicons' " must stay at bottom to load after other plugins
" }}}
" Post bundle commands {{{
" End vim-plug
call plug#end()
" Set the colorscheme to molokai dark (vim version of TextMate's monokai)
colorscheme molokai
set background=dark
" use ripgrep as the vimgrep backend
set grepprg=rg\ --vimgrep
" give me some background transparency
highlight Normal ctermbg=none
highlight NonText ctermbg=none
" Get delimitMate expand newlines and spaces
let delimitMate_expand_cr = 1
let delimitMate_expand_space = 1
" Setup vim-airline
let g:airline_powerline_fonts = 1
let g:airline#extensions#tabline#enabled = 1
let g:airline#extensions#whitespace#enabled = 0
" set indent character
let g:indentLine_char = '¦'
" fix indentLine plugin breaking conceal settings for json
let g:indentLine_concealcursor=''
" Set up the list of JS libraries to provide syntax for
let g:used_javascript_libs = 'underscore,react,flux,requirejs,backbone,angularjs,angularui,chai'
" }}}
