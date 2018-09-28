" vim:foldmethod=marker

" Standard vim settings {{{
" Disable GUI Items {{{
set go-=m
set go-=M
set go-=T
set go-=r
set go-=L
" }}}
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
set tabstop=2                  " make tabs have a width of 2
set softtabstop=2              " not really sure what this changes to be honest
set shiftwidth=2               " make indents have a width of 2
set expandtab                  " expand tabs into spaces when used for indentation
set fillchars=vert:\           " make vertical splits look less stupid
set noshowmode                 " dont show the mode (insert/normal) as airline will
set list lcs=tab:\|\           " use vertical bars to show indent levels
set inccommand=split           " make use of NeoVim's new live search/replace
set encoding=utf-8             " force utf-8 encoding

" setup ignore wildcards for everything
set wildignore+=node_modules/**,obj/**,bin/**,coverage/**,public/**,**.jpg,**.svg
" }}}
" Commands and auto commands {{{
" make all grep commands open the quick fix window
autocmd QuickFixCmdPost *grep* cwindow
" Make all javascript files interpret as jsx
autocmd  BufNew,BufEnter *.js set filetype=javascript.jsx
autocmd FileType javascript,javascript.jsx,typescript,less,scss,css,graphql set formatprg=prettier-eslint\ --parser\ babylon\ --stdin\ --tab-width\ 2\ --jsx-bracket-same-line\ --single-quote
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
nnoremap H ^
nnoremap L $
" }}}
" Use backspace to quick switch buffers {{{
nnoremap <BS> <C-^>
" }}}
" Remap Q to save and Ctrl+q to quit {{{
nnoremap Q :w<CR>
nnoremap <C-q> :q<CR>
" }}}
" Map \a to align the given pattern with Tabular {{{
noremap <Leader>a :Tabular<Space>/
" }}}
" Map \f to pretty print (reformat) the file with ALE {{{
noremap <Leader>f :ALEFix<CR>
" }}}
" Map Enter to removing search highlighting {{{
nnoremap <CR> :nohlsearch<CR>
" }}}
" Remap Ctrl + hjkl to switch focues between panes {{{
noremap <C-J> <C-W><C-J>
noremap <C-K> <C-W><C-K>
noremap <C-L> <C-W><C-L>
noremap <C-H> <C-W><C-H>
" }}}
" Remove mappings for Ctrl + es so that ultisnips can use them {{{
map <C-E> <NOP>
map <C-S> <NOP>
" }}}
" Use Ctrl + p / Alt + p for FZF fuzzy find {{{
nnoremap <C-p> :Files<CR>
nnoremap <A-p> :Find<CR>
" }}}
" Map gd, gD, gr, gR to javascript utilities {{{
nnoremap gd :TernDef<CR>
nnoremap gD :TernDoc<CR>
nnoremap gr :TernRename<CR>
nnoremap gR :TernRefs<CR>
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
Plug 'editorconfig/editorconfig-vim'
Plug 'scrooloose/nerdcommenter'
Plug 'airblade/vim-gitgutter'
Plug 'SirVer/ultisnips'
Plug 'honza/vim-snippets'
Plug 'w0rp/ale'
Plug 'Shougo/deoplete.nvim', { 'do': ':UpdateRemotePlugins' }
Plug 'Raimondi/delimitMate'
Plug 'majutsushi/tagbar'
Plug 'tpope/vim-repeat'
Plug 'tpope/vim-surround'
Plug 'tpope/vim-fugitive'
Plug 'bling/vim-airline'
Plug 'wellle/targets.vim'
Plug 'mattn/emmet-vim'
Plug 'Yggdroot/indentLine'
Plug 'ternjs/tern_for_vim', { 'for': [ 'javascript', 'javascript.jsx' ], 'do': 'npm install' }
Plug 'elzr/vim-json', { 'for': 'json' }
" Plug 'othree/yajs.vim', { 'for': [ 'javascript', 'javascript.jsx' ] }
Plug 'jelera/vim-javascript-syntax', { 'for': [ 'javascript', 'javascript.jsx' ] }
Plug 'HerringtonDarkholme/yats.vim', { 'for': 'typescript' }
Plug 'mxw/vim-jsx', { 'for': [ 'javascript', 'javascript.jsx' ] }
Plug 'othree/es.next.syntax.vim', { 'for': [ 'javascript', 'javascript.jsx' ] }
Plug 'othree/javascript-libraries-syntax.vim', { 'for': [ 'javascript', 'javascript.jsx' ] }
Plug 'Shougo/vimproc.vim', { 'do': 'make' }
Plug 'Quramy/tsuquyomi', { 'for': 'typescript' }
Plug 'othree/html5.vim', { 'for': 'html' }
Plug 'rust-lang/rust.vim', { 'for': 'rust' }
Plug 'octol/vim-cpp-enhanced-highlight', { 'for': 'cpp' }
Plug 'jparise/vim-graphql'
Plug 'junegunn/fzf', { 'dir': '~/.fzf', 'do': './install --all' }
Plug 'junegunn/fzf.vim'
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
" setup editorconfig plugin
let g:EditorConfig_exclude_patterns = ['fugitive://.*']
" let g:EditorConfig_exec_path = 'Path to your EditorConfig Core executable'
" Change Ultisnips keybindings to prevent conflicts with YouCompleteMe
let g:UltiSnipsExpandTrigger="<C-E>"
let g:UltiSnipsListSnippets="<C-S>"
let g:UltiSnipsJumpForwardTrigger="<CR>"
let g:UltiSnipsJumpBackwardTrigger="<S-CR>"
" Get delimitMate expand newlines and spaces
let delimitMate_expand_cr = 1
let delimitMate_expand_space = 1
" Setup vim-airline
let g:airline_powerline_fonts = 1
let g:airline#extensions#tabline#enabled = 1
let g:airline#extensions#whitespace#enabled = 0
" Use Deoplete for auto-completion
let g:deoplete#enable_at_startup = 1
" Use smartcase
let g:deoplete#enable_smart_case = 1
" set indent character
let g:indentLine_char = '¦'
" fix indentLine plugin breaking conceal settings for json
let g:indentLine_concealcursor=''
" Set up the list of JS libraries to provide syntax for
let g:used_javascript_libs = 'underscore,react,flux,requirejs,angularjs,angularui,chai'
" Set up formatters for use with ALEFix
let g:ale_fix_on_save = 1
let g:ale_fixers = {
\  '*': ['remove_trailing_lines', 'trim_whitespace'],
\  'javascript': ['prettier-eslint', 'prettier', 'eslint'],
\  'json': ['prettier', 'jq'],
\}
" }}}
" Custom FZF fuzzy find grep madness {{{
" Filter fzf files through ag to follow gitignore etc
let $FZF_DEFAULT_COMMAND='rg --files --follow --glob "!.git/*" --glob "!**/node_modules/*" --color never'
" --column: Show column number
" --line-number: Show line number
" --no-heading: Do not show file headings in results
" --fixed-strings: Search term as a literal string
" --ignore-case: Case insensitive search
" --no-ignore: Do not respect .gitignore, etc...
" --hidden: Search hidden files and folders
" --follow: Follow symlinks
" --glob: Additional conditions for search (in this case ignore everything in the .git/ folder)
" --color: Search color options
command! -bang -nargs=* Find call fzf#vim#grep('rg --column --line-number --no-heading --fixed-strings --ignore-case --follow --glob "!.git/*" --glob "!**/node_modules/*" --color "always" '.shellescape(<q-args>), 1, <bang>0)
" }}}
