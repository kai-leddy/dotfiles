" vim:foldmethod=marker:foldlevel=0

" Standard vim settings {{{
" Disable GUI Items {{{
set go-=m
set go-=M
set go-=T
set go-=r
set go-=L
" }}}
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
set modelines=1                " allow the use of file-specific modeline configs
set foldlevel=1                " close all folds by default on file open
set tabstop=4                  " make tabs have a width of 4
set shiftwidth=4               " make indents have a width of 4
set fillchars=vert:\           " make vertical splits look less stupid
set noshowmode				   " dont show the mode (insert/normal) as airline will
set list lcs=tab:\|\           " use vertical bars to show indent levels

" setup ignore wildcards for everything
set wildignore+=node_modules/**,obj/**,bin/**,coverage/**,public/**,**.jpg,**.svg
" }}}
" Commands and auto commands {{{
" trim trailing whitespace for everything except markdown and vim
let blacklist = '^vim$\|^mkd$\|^markdown$'
autocmd BufWritePre * if &ft !~# blacklist | :%s/\s\+$//e
" make all grep commands open the quick fix window
autocmd QuickFixCmdPost *grep* cwindow
" auto lint files with Neomake on enter and save
autocmd! BufWritePost,BufEnter * Neomake
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
noremap <BS> <C-W><C-H>
" }}}
" Remove mappings for Ctrl + es so that ultisnips can use them {{{
map <C-E> <NOP>
map <C-S> <NOP>
" }}}
" Use Ctrl + p / P for FZF fuzzy find {{{
nnoremap <M-p> :FZF<CR>
nnoremap <M-P> :Ag<CR>
" }}}
" Deoplete tab-complete {{{
inoremap <expr><tab> pumvisible() ? "\<c-n>" : "\<tab>"
" }}}
" Ultisnips expand if exists with <CR> {{{
function! TryExpand()
	call UltiSnips#ExpandSnippet()
	return g:ulti_expand_res
endfunction
inoremap <CR> <C-R>=TryExpand() == 1 ? "" : "\<lt>CR>"<CR>
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
" Custom bundle definitions {{{
call plug#begin()
" let vim-plug manage itself
Plug 'junegunn/vim-plug'
" various other plugins
Plug 'tomasr/molokai'
Plug 'godlygeek/tabular'
Plug 'scrooloose/nerdtree'
Plug 'scrooloose/nerdcommenter'
Plug 'airblade/vim-gitgutter'
Plug 'jistr/vim-nerdtree-tabs'
Plug 'SirVer/ultisnips' | Plug 'honza/vim-snippets'
Plug 'Shougo/deoplete.nvim', { 'do': ':UpdateRemotePlugins' }
Plug 'neomake/neomake'
Plug 'Raimondi/delimitMate'
Plug 'majutsushi/tagbar'
Plug 'pseewald/vim-anyfold'
Plug 'tpope/vim-repeat'
Plug 'tpope/vim-surround'
Plug 'tpope/vim-fugitive'
Plug 'bling/vim-airline'
Plug 'wellle/targets.vim'
Plug 'Yggdroot/indentLine'
Plug 'ternjs/tern_for_vim', { 'do': 'npm install' }
Plug 'elzr/vim-json', { 'for': 'json' }
Plug 'rschmukler/pangloss-vim-indent', { 'for': [ 'javascript', 'javascript.jsx' ] }
Plug 'othree/yajs.vim' | Plug 'mxw/vim-jsx', { 'for': [ 'javascript', 'javascript.jsx' ] }
Plug 'othree/es.next.syntax.vim', { 'for': [ 'javascript', 'javascript.jsx' ] }
Plug 'othree/javascript-libraries-syntax.vim', { 'for': [ 'javascript', 'javascript.jsx' ] }
Plug 'othree/html5.vim', { 'for': 'html' }
Plug 'rust-lang/rust.vim', { 'for': 'rust' }
Plug 'junegunn/fzf', { 'dir': '~/.fzf', 'do': './install --all' }
Plug 'junegunn/fzf.vim'
Plug 'christoomey/vim-tmux-navigator'
Plug 'tmux-plugins/vim-tmux-focus-events'
" }}}
" Post bundle commands {{{
" End vim-plug
call plug#end()
" Set the colorscheme to molokai dark (vim version of TextMate's monokai)
colorscheme molokai
set background=dark
" Change Ultisnips keybindings to prevent conflicts with YouCompleteMe
let g:UltiSnipsExpandTrigger="<C-E>"
let g:UltiSnipsListSnippets="<C-S>"
let g:UltiSnipsJumpForwardTrigger="<CR>"
let g:UltiSnipsJumpBackwardTrigger="<S-CR>"
" Get delimitMate expand newlines and spaces
let delimitMate_expand_cr = 1
let delimitMate_expand_space = 1
" Set NERDTree to ignore java .class and .ctxt files
let NERDTreeIgnore = ['\.class$', '\.ctxt$', '\.pyc$']
" Setup vim-airline
let g:airline_powerline_fonts = 1
let g:airline#extensions#tabline#enabled = 1
let g:airline#extensions#whitespace#enabled = 0
" Use Deoplete for auto-completion
let g:deoplete#enable_at_startup = 1
" Use smartcase
let g:deoplete#enable_smart_case = 1
" use ESLint for JavaScript linting
let g:neomake_javascript_enabled_makers = ['eslint']
let g:neomake_jsx_enabled_makers = ['eslint']
" set nicer error and warning symbols in the gutter
let g:neomake_warning_sign = { 'text': 'W', 'texthl': 'WarningMsg' }
let g:neomake_error_sign = { 'text': 'E', 'texthl': 'ErrorMsg' }
" set indent character
let g:indentLine_char = '|'
" fix indentLine plugin breaking conceal settings for json
let g:indentLine_concealcursor=''
" Set up the list of JS libraries to provide syntax for
let g:used_javascript_libs = 'underscore,react,flux,requirejs,backbone,angularjs,angularui,chai'
" Setup vim-anyfold
let anyfold_activate=1
let anyfold_fold_comments=1
" Filter fzf files through ag to follow gitignore etc
let $FZF_DEFAULT_COMMAND='ag -l -g ""'
" }}}
