" Vim plugin for easily applying PEP8 requirements to Python files
" Last Change: 2016 June 22
" Maintainer: Andrew Seaman <andrewseaman35@gmail.com>

" Allow the user to not load the plugin, and make sure it doesn't load twice
if exists("g:loaded_pep8this")
    finish
endif

if !hasmapto(':call pep8this#Pep8This()')
    nnoremap <unique> <Leader>p :call pep8this#Pep8This()<CR>
endif
if !hasmapto(':call pep8this#LineSelected()')
    nnoremap <unique> <Leader>n :call pep8this#LineSelected()<CR>
endif
if !hasmapto(':call pep8this#Finish()')
    nnoremap <unique> <Leader><Esc> :call pep8this#Finish()<CR>
endif

let g:loaded_pep8this = 1
