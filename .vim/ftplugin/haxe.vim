" Turn on autowrite for haxe completion
set autowrite 
" Map F5 to build and run a debug version
nnoremap <F5> :make<CR>
" Set default lime target to be flash
let g:vaxe_lime_target = 'flash'
" Start a caching compilation server with Vaxe
silent VaxeStartCompletionServer
