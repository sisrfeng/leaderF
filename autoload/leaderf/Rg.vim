" ============================================================================
" File:        Rg.vim
" Description:
" Author:      Yggdroot <archofortune@gmail.com>
" Website:     https://github.com/Yggdroot
" Note:
" License:     Apache License, Version 2.0
" ============================================================================

if leaderf#versionCheck() == 0  " this check is necessary
    finish
en

exec g:Lf_py "from leaderf.rgExpl import *"

fun! leaderf#Rg#Maps(heading)
    nmapclear <buffer>
    nno  <buffer> <silent> <CR>          :exec g:Lf_py "rgExplManager.accept()"<CR>
    nno  <buffer> <silent> o             :exec g:Lf_py "rgExplManager.accept()"<CR>
    nno  <buffer> <silent> <2-LeftMouse> :exec g:Lf_py "rgExplManager.accept()"<CR>
    nno  <buffer> <silent> x             :exec g:Lf_py "rgExplManager.accept('h')"<CR>
    nno  <buffer> <silent> v             :exec g:Lf_py "rgExplManager.accept('v')"<CR>
    nno  <buffer> <silent> t             :exec g:Lf_py "rgExplManager.accept('t')"<CR>
    nno  <buffer> <silent> p             :exec g:Lf_py "rgExplManager._previewResult(True)"<CR>
    nno  <buffer> <silent> j             j:exec g:Lf_py "rgExplManager._previewResult(False)"<CR>
    nno  <buffer> <silent> k             k:exec g:Lf_py "rgExplManager._previewResult(False)"<CR>
    nno  <buffer> <silent> <Up>          <Up>:exec g:Lf_py "rgExplManager._previewResult(False)"<CR>
    nno  <buffer> <silent> <Down>        <Down>:exec g:Lf_py "rgExplManager._previewResult(False)"<CR>
    nno  <buffer> <silent> <PageUp>      <PageUp>:exec g:Lf_py "rgExplManager._previewResult(False)"<CR>
    nno  <buffer> <silent> <PageDown>    <PageDown>:exec g:Lf_py "rgExplManager._previewResult(False)"<CR>
    nno  <buffer> <silent> q             :exec g:Lf_py "rgExplManager.quit()"<CR>
    " nnoremap <buffer> <silent> <Esc>         :exec g:Lf_py "rgExplManager.quit()"<CR>
    if a:heading == 0
        nno  <buffer> <silent> i             :exec g:Lf_py "rgExplManager.input()"<CR>
        nno  <buffer> <silent> <Tab>         :exec g:Lf_py "rgExplManager.input()"<CR>
    en
    nno  <buffer> <silent> <F1>          :exec g:Lf_py "rgExplManager.toggleHelp()"<CR>
    nno  <buffer> <silent> d             :exec g:Lf_py "rgExplManager.deleteCurrentLine()"<CR>
    nno  <buffer> <silent> Q             :exec g:Lf_py "rgExplManager.outputToQflist()"<CR>
    nno  <buffer> <silent> L             :exec g:Lf_py "rgExplManager.outputToLoclist()"<CR>
    nno  <buffer> <silent> r             :exec g:Lf_py "rgExplManager.replace()"<CR>
    nno  <buffer> <silent> w             :call leaderf#Rg#ApplyChangesAndSave(0)<CR>
    nno  <buffer> <silent> W             :call leaderf#Rg#ApplyChangesAndSave(1)<CR>
    nno  <buffer> <silent> U             :call leaderf#Rg#UndoLastChange()<CR>
    if has("nvim")
        nno  <buffer> <silent> <C-Up>    :exec g:Lf_py "rgExplManager._toUpInPopup()"<CR>
        nno  <buffer> <silent> <C-Down>  :exec g:Lf_py "rgExplManager._toDownInPopup()"<CR>
        nno  <buffer> <silent> <Esc>     :exec g:Lf_py "rgExplManager._closePreviewPopup()"<CR>
    en
    if has_key(g:Lf_NormalMap, "Rg")
        for i in g:Lf_NormalMap["Rg"]
            exec 'nnoremap <buffer> <silent> '.i[0].' '.i[1]
        endfor
    en
endf

" return the visually selected text and quote it with double quote
fun! leaderf#Rg#visual()
    try
        let x_save = getreg("x", 1)
        let type = getregtype("x")
        norm! gv"xy
        return '"' . escape(@x, '"') . '"'
    finally
        call setreg("x", x_save, type)
    endtry
endf

" type: 0, word under cursor
"       1, WORD under cursor
"       2, text visually selected
fun! leaderf#Rg#getPattern(type)
    if a:type == 0
        return expand('<cword>')
    elseif a:type == 1
        return '"' . escape(expand('<cWORD>'), '"') . '"'
    elseif a:type == 2
        return leaderf#Rg#visual()
    el
        return ''
    en
endf

" type: 0, word under cursor
"       1, WORD under cursor
"       2, text visually selected
fun! leaderf#Rg#startCmdline(type, is_bang, is_regex, is_whole_word)
    return printf(
            \ "Leaderf%s rg %s%s-e %s "        ,
            \ a:is_bang       ? '!'    : ''    ,
            \ a:is_regex      ? ''     : '-F ' ,
            \ a:is_whole_word ? '-w '  : ''    ,
            \ leaderf#Rg#getPattern(a:type)    ,
        \ )
endf

fun! leaderf#Rg#Interactive()
    try
        echohl Question
        let pattern = input("Search pattern: ")
        let pattern = escape(pattern,'"')
        let glob = input("Search in files(e.g., *.c, *.cpp): ", "*")
        if glob =~ '^\s*$'  | return  | endif
        let globList = map(
            \ split(glob, '[ ,]\+'),
            \ 'v:val =~ ''^".*"$''
                    \ ? v:val
                    \ : ''"'' . v:val . ''"''',
           \ )
        exe printf(
            \ "Leaderf rg %s\"%s\" -g %s" ,
            \ pattern =~ '^\s*$'
                \ ? ''
                \ : '-e '                 ,
            \ pattern                     ,
            \ join(globList, ' -g ')      ,
           \ )
    finally
        echohl None
    endtry
endf

fun! leaderf#Rg#TimerCallback(id)
    call leaderf#LfPy("rgExplManager._workInIdle(bang=True)")
endf

fun! leaderf#Rg#ApplyChanges()
    call leaderf#LfPy("rgExplManager.applyChanges()")
endf

fun! leaderf#Rg#UndoLastChange()
    call leaderf#LfPy("rgExplManager.undo()")
endf

fun! leaderf#Rg#Quit()
    call leaderf#LfPy("rgExplManager.quit()")
endf

fun! leaderf#Rg#ApplyChangesAndSave(save)
    if ! &modified
        return
    en
    try
        if a:save
            let g:Lf_rg_apply_changes_and_save = 1
        en
        write
    finally
        silent! unlet g:Lf_rg_apply_changes_and_save
    endtry
endf

fun! leaderf#Rg#Undo(buf_number_dict)
    if has_key(a:buf_number_dict, bufnr('%'))
        undo
    en
endf

let s:type_list = []
fun! s:rg_type_list() abort
    if len(s:type_list) > 0
        return s:type_list
    en

    let l:ret = {}
    let l:output = systemlist('rg --type-list')

    for l:line in l:output
        " e,g,. 'c: *.[chH], *.[chH].in, *.cats'
        let [l:type, l:pattern_str] = split(l:line, ': ')
        let l:pattern_list = split(l:pattern_str, ', ')

        let l:ret[l:type] = map(l:pattern_list, 'glob2regpat(v:val)')
    endfor

    let s:type_list = l:ret
    return s:type_list
endf

fun! s:getType(fname) abort
    for [l:type, l:pattern_list] in items(s:rg_type_list())
        for l:pattern in l:pattern_list
            if a:fname =~# l:pattern
                return l:type
            en
        endfor
    endfor
    return ''
endf

" Returns the type of rg matching the filename.
" e,g,: nnoremap <Leader>fg :<C-u><C-r>=printf('Leaderf rg %s ', leaderf#Rg#getTypeByFileName(expand('%')))<CR>
fun! leaderf#Rg#getTypeByFileName(fname) abort
    let l:type = s:getType(a:fname)
    return empty(l:type) ? '' : printf('-t "%s"', l:type)
endf


fun! leaderf#Rg#NormalModeFilter(winid, key) abort
    let key = get(g:Lf_KeyDict, get(g:Lf_KeyMap, a:key, a:key), a:key)

    if key !=# "g"
        call win_execute(a:winid, "let g:Lf_Rg_is_g_pressed = 0")
    en

    if key ==# "j" || key ==? "<Down>"
        call win_execute(a:winid, "norm! j")
        exec g:Lf_py "rgExplManager._cli._buildPopupPrompt()"
        "redraw
        exec g:Lf_py "rgExplManager._getInstance().refreshPopupStatusline()"
        exec g:Lf_py "rgExplManager._previewResult(False)"
    elseif key ==# "k" || key ==? "<Up>"
        call win_execute(a:winid, "norm! k")
        exec g:Lf_py "rgExplManager._cli._buildPopupPrompt()"
        "redraw
        exec g:Lf_py "rgExplManager._getInstance().refreshPopupStatusline()"
        exec g:Lf_py "rgExplManager._previewResult(False)"
    elseif key ==? "<PageUp>" || key ==? "<C-B>"
        call win_execute(a:winid, "norm! \<PageUp>")
        exec g:Lf_py "rgExplManager._cli._buildPopupPrompt()"
        exec g:Lf_py "rgExplManager._getInstance().refreshPopupStatusline()"
        exec g:Lf_py "rgExplManager._previewResult(False)"
    elseif key ==? "<PageDown>" || key ==? "<C-F>"
        call win_execute(a:winid, "norm! \<PageDown>")
        exec g:Lf_py "rgExplManager._cli._buildPopupPrompt()"
        exec g:Lf_py "rgExplManager._getInstance().refreshPopupStatusline()"
        exec g:Lf_py "rgExplManager._previewResult(False)"
    elseif key ==# "g"
        if get(g:, "Lf_Rg_is_g_pressed", 0) == 0
            let g:Lf_Rg_is_g_pressed = 1
        el
            let g:Lf_Rg_is_g_pressed = 0
            call win_execute(a:winid, "norm! gg")
            exec g:Lf_py "rgExplManager._cli._buildPopupPrompt()"
            redraw
        en
    elseif key ==# "G"
        call win_execute(a:winid, "norm! G")
        exec g:Lf_py "rgExplManager._cli._buildPopupPrompt()"
        redraw
    elseif key ==? "<C-U>"
        call win_execute(a:winid, "norm! \<C-U>")
        exec g:Lf_py "rgExplManager._cli._buildPopupPrompt()"
        redraw
    elseif key ==? "<C-D>"
        call win_execute(a:winid, "norm! \<C-D>")
        exec g:Lf_py "rgExplManager._cli._buildPopupPrompt()"
        redraw
    elseif key ==? "<LeftMouse>"
        if exists("*getmousepos")
            let pos = getmousepos()
            call win_execute(pos.winid, "call cursor([pos.line, pos.column])")
            exec g:Lf_py "rgExplManager._cli._buildPopupPrompt()"
            redraw
            exec g:Lf_py "rgExplManager._previewResult(False)"
        elseif has('patch-8.1.2266')
            call win_execute(a:winid, "exec v:mouse_lnum")
            call win_execute(a:winid, "exec 'norm!'.v:mouse_col.'|'")
            exec g:Lf_py "rgExplManager._cli._buildPopupPrompt()"
            redraw
            exec g:Lf_py "rgExplManager._previewResult(False)"
        en
    elseif key ==? "<ScrollWheelUp>"
        call win_execute(a:winid, "norm! 3k")
        exec g:Lf_py "rgExplManager._cli._buildPopupPrompt()"
        redraw
        exec g:Lf_py "rgExplManager._getInstance().refreshPopupStatusline()"
    elseif key ==? "<ScrollWheelDown>"
        call win_execute(a:winid, "norm! 3j")
        exec g:Lf_py "rgExplManager._cli._buildPopupPrompt()"
        redraw
        exec g:Lf_py "rgExplManager._getInstance().refreshPopupStatusline()"
    elseif key ==# "q" || key ==? "<ESC>"
        exec g:Lf_py "rgExplManager.quit()"
    elseif key ==# "i" || key ==? "<Tab>"
        if g:Lf_py == "py "
            let has_heading = pyeval("'--heading' in rgExplManager._arguments")
        el
            let has_heading = py3eval("'--heading' in rgExplManager._arguments")
        en
        if !has_heading
            call leaderf#ResetPopupOptions(a:winid, 'filter', 'leaderf#PopupFilter')
            exec g:Lf_py "rgExplManager.input()"
        en
    elseif key ==# "o" || key ==? "<CR>" || key ==? "<2-LeftMouse>"
        exec g:Lf_py "rgExplManager.accept()"
    elseif key ==# "x"
        exec g:Lf_py "rgExplManager.accept('h')"
    elseif key ==# "v"
        exec g:Lf_py "rgExplManager.accept('v')"
    elseif key ==# "t"
        exec g:Lf_py "rgExplManager.accept('t')"
    elseif key ==# "p"
        exec g:Lf_py "rgExplManager._previewResult(True)"
    elseif key ==? "<F1>"
        exec g:Lf_py "rgExplManager.toggleHelp()"
    elseif key ==# "d"
        exec g:Lf_py "rgExplManager.deleteCurrentLine()"
    elseif key ==# "Q"
        exec g:Lf_py "rgExplManager.outputToQflist()"
    elseif key ==# "L"
        exec g:Lf_py "rgExplManager.outputToLoclist()"
    elseif key ==? "<C-Up>"
        exec g:Lf_py "rgExplManager._toUpInPopup()"
    elseif key ==? "<C-Down>"
        exec g:Lf_py "rgExplManager._toDownInPopup()"
    en

    return 1
endf
