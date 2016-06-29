" Auto-select next issue
let s:autoselect = 1

" Check file extension to ensure .py
let s:check_extension = 1


" Line selected in pep8 window
let s:pep_line = 0

" Name of pep8 window split
let s:pep_name = "pep8this_pep8"

" If the cursor is in the original calling window, then it will move to the
" pep8 window and remove the stored line number.
" If the cusor is in the pep8 window, then it will move to the original
" calling window to the specified line.
function! pep8this#LineSelected()
    " Check which file pressed mapping, need to know if
    " we're in the pep8 split or the python split

    " New pep8 split doesn't have a path, python split does
    let f = expand('%:r')
    let full_f = expand('%:p')

    if f == s:pep_name
        :call pep8this#jumpDown()
    elseif full_f == s:python_file
        :call pep8this#jumpUp()
    else
        echo "I seem to be lost..."
    endif

endfunction

" Jump from the python window up to the pep8 window
function! pep8this#jumpUp()
    :execute "w"
    :wincmd k

    if expand('%:r') == s:pep_name
        :execute "q!"
        :call pep8this#Pep8This()
        let f = expand('%:r')
        if expand('%:r') == s:pep_name
            let s:pep_line = s:pep_line - 1
            :execute ":" . s:pep_line
            if s:autoselect
                " The split doesn't always scroll to show the line of the
                " cursor, this ensures that it does
                normal! lh
                :call pep8this#jumpDown()
            endif
        endif
    else
        echo "Can't find pep8 window"
    endif
endfunction

" Jump from the pep8 window to the proper place in the python window
function! pep8this#jumpDown()
    let l = getline('.')
    let x = split(l, ':')
    if len(x) != 3
        echo "Invalid line!"
        return
    endif

    " Save line number so we can come back to this line later
    let s:pep_line = line('.')

    :wincmd j

    :call cursor(x[0], x[1])
endfunction

" Calls pep8 on the calling file
" Creates a new window and displays pep8 results
function! pep8this#Pep8This()
    if expand('%:e') != 'py' && s:check_extension
        echo "This doesn't look like a Python file!"
        return 1
    endif

    let s:python_file = expand('%:p')

    let pep8 = split(system(s:which . " pep8"), '\n')[0]

    let pep8_list = split(system(pep8 . " " . s:python_file), '\n')

    if len(pep8_list) > 0
        :execute "5new " . s:pep_name
        :execute "set cursorline"
        :execute "set ff=unix"
        for line in pep8_list
            let l = split(line, ':')
            let @x = l[-3] . ':' . l[-2] . ':' . l[-1]

            let x = @x

            " Write pep8 line to new window
            normal! V"xp
            normal! o
            let @x = x
        endfor
        normal! dd
    else
        echo "No changes to make!"
    endif
endfunction

" Removes pep8 window
function! pep8this#Finish()
    :wincmd k

    let f = expand('%:r')

    if f == s:pep_name
        :execute "q!"
    else
        echo "Can't find pep8 window"
    endif
endfunction

" Set which to be 'which' or 'where'
function! pep8this#SetWhichCmd()
    let os = substitute(system('uname'), '\n', '', 'g')
    if os == 'Darwin' || os == 'Mac' || os == 'Linux'
        let s:which = 'which'
    else
        let s:which = 'where'
    endif
endfunction

:call pep8this#SetWhichCmd()
