" Indentation settings
set tabstop=4
set softtabstop=4
set shiftwidth=4
set noexpandtab
" Map F5 to build and run python files
nnoremap <F5> :!python2 %<CR>
" Tell syntastic to use python2
let g:syntastic_python_python_exec = 'python2'
