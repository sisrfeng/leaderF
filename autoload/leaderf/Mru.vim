" File:        Mru.vim
" Website:     https://github.com/Yggdroot
" License:     Apache License, Version 2.0


if leaderf#versionCheck() == 0  " this check is necessary
    finish
en

exec g:Lf_py "from leaderf.mruExpl import *"

fun! leaderf#Mru#Maps()
    nmapclear <buffer>
    nno      <buffer> <silent> <CR>          :exec g:Lf_py "mruExplManager.accept('t')"<CR>
    nno      <buffer> <silent> o             :exec g:Lf_py "mruExplManager.accept()"<CR>
    nno      <buffer> <silent> <2-LeftMouse> :exec g:Lf_py "mruExplManager.accept()"<CR>
    nno      <buffer> <silent> x             :exec g:Lf_py "mruExplManager.accept('h')"<CR>
    nno      <buffer> <silent> v             :exec g:Lf_py "mruExplManager.accept('v')"<CR>
    nno      <buffer> <silent> t             :exec g:Lf_py "mruExplManager.accept('t')"<CR>
    nno      <buffer> <silent> t             :exec g:Lf_py "mruExplManager.accept('t')"<CR>
    nno      <buffer> <silent> q             :exec g:Lf_py "mruExplManager.quit()"<CR>
    " nnoremap <buffer> <silent> <Esc>         :exec g:Lf_py "mruExplManager.quit()"<CR>
    nno      <buffer> <silent> i             :exec g:Lf_py "mruExplManager.input()"<CR>
    nno      <buffer> <silent> <Tab>         :exec g:Lf_py "mruExplManager.input()"<CR>
    nno      <buffer> <silent> <F1>          :exec g:Lf_py "mruExplManager.toggleHelp()"<CR>
    nno      <buffer> <silent> d             :exec g:Lf_py "mruExplManager.deleteMru()"<CR>
    nno      <buffer> <silent> s             :exec g:Lf_py "mruExplManager.addSelections()"<CR>
    nno      <buffer> <silent> a             :exec g:Lf_py "mruExplManager.selectAll()"<CR>
    nno      <buffer> <silent> c             :exec g:Lf_py "mruExplManager.clearSelections()"<CR>
    nno      <buffer> <silent> p             :exec g:Lf_py "mruExplManager._previewResult(True)"<CR>
    nno      <buffer> <silent> j             j:exec g:Lf_py "mruExplManager._previewResult(False)"<CR>
    nno      <buffer> <silent> k             k:exec g:Lf_py "mruExplManager._previewResult(False)"<CR>
    nno      <buffer> <silent> <Up>          <Up>:exec g:Lf_py "mruExplManager._previewResult(False)"<CR>
    nno      <buffer> <silent> <Down>        <Down>:exec g:Lf_py "mruExplManager._previewResult(False)"<CR>
    nno      <buffer> <silent> <PageUp>      <PageUp>:exec g:Lf_py "mruExplManager._previewResult(False)"<CR>
    nno      <buffer> <silent> <PageDown>    <PageDown>:exec g:Lf_py "mruExplManager._previewResult(False)"<CR>
    if has("nvim")
        nno      <buffer> <silent> <C-Up>    :exec g:Lf_py "mruExplManager._toUpInPopup()"<CR>
        nno      <buffer> <silent> <C-Down>  :exec g:Lf_py "mruExplManager._toDownInPopup()"<CR>
        nno      <buffer> <silent> <Esc>     :exec g:Lf_py "mruExplManager._closePreviewPopup()"<CR>
    en
    if has_key(g:Lf_NormalMap, "Mru")
        for i in g:Lf_NormalMap["Mru"]
            exec 'nnoremap <buffer> <silent> '.i[0].' '.i[1]
        endfor
    en
endf

fun! leaderf#Mru#NormalModeFilter(winid, key) abort
    let key = get(g:Lf_KeyDict, get(g:Lf_KeyMap, a:key, a:key), a:key)

    if key !=# "g"
        call win_execute(a:winid, "let g:Lf_Mru_is_g_pressed = 0")
    en

    if key ==# "j" || key ==? "<Down>"
        call win_execute(a:winid, "norm! j")
        exec g:Lf_py "mruExplManager._cli._buildPopupPrompt()"
        "redraw
        exec g:Lf_py "mruExplManager._getInstance().refreshPopupStatusline()"
        exec g:Lf_py "mruExplManager._previewResult(False)"
    elseif key ==# "k" || key ==? "<Up>"
        call win_execute(a:winid, "norm! k")
        exec g:Lf_py "mruExplManager._cli._buildPopupPrompt()"
        "redraw
        exec g:Lf_py "mruExplManager._getInstance().refreshPopupStatusline()"
        exec g:Lf_py "mruExplManager._previewResult(False)"
    elseif key ==? "<PageUp>" || key ==? "<C-B>"
        call win_execute(a:winid, "norm! \<PageUp>")
        exec g:Lf_py "mruExplManager._cli._buildPopupPrompt()"
        exec g:Lf_py "mruExplManager._getInstance().refreshPopupStatusline()"
        exec g:Lf_py "mruExplManager._previewResult(False)"
    elseif key ==? "<PageDown>" || key ==? "<C-F>"
        call win_execute(a:winid, "norm! \<PageDown>")
        exec g:Lf_py "mruExplManager._cli._buildPopupPrompt()"
        exec g:Lf_py "mruExplManager._getInstance().refreshPopupStatusline()"
        exec g:Lf_py "mruExplManager._previewResult(False)"
    elseif key ==# "g"
        if get(g:, "Lf_Mru_is_g_pressed", 0) == 0
            let g:Lf_Mru_is_g_pressed = 1
        el
            let g:Lf_Mru_is_g_pressed = 0
            call win_execute(a:winid, "norm! gg")
            exec g:Lf_py "mruExplManager._cli._buildPopupPrompt()"
            redraw
        en
    elseif key ==# "G"
        call win_execute(a:winid, "norm! G")
        exec g:Lf_py "mruExplManager._cli._buildPopupPrompt()"
        redraw
    elseif key ==? "<C-U>"
        call win_execute(a:winid, "norm! \<C-U>")
        exec g:Lf_py "mruExplManager._cli._buildPopupPrompt()"
        redraw
    elseif key ==? "<C-D>"
        call win_execute(a:winid, "norm! \<C-D>")
        exec g:Lf_py "mruExplManager._cli._buildPopupPrompt()"
        redraw
    elseif key ==? "<LeftMouse>"
        if exists("*getmousepos")
            let pos = getmousepos()
            call win_execute(pos.winid, "call cursor([pos.line, pos.column])")
            exec g:Lf_py "mruExplManager._cli._buildPopupPrompt()"
            redraw
            exec g:Lf_py "mruExplManager._previewResult(False)"
        elseif has('patch-8.1.2266')
            call win_execute(a:winid, "exec v:mouse_lnum")
            call win_execute(a:winid, "exec 'norm!'.v:mouse_col.'|'")
            exec g:Lf_py "mruExplManager._cli._buildPopupPrompt()"
            redraw
            exec g:Lf_py "mruExplManager._previewResult(False)"
        en
    elseif key ==? "<ScrollWheelUp>"
        call win_execute(a:winid, "norm! 3k")
        exec g:Lf_py "mruExplManager._cli._buildPopupPrompt()"
        redraw
        exec g:Lf_py "mruExplManager._getInstance().refreshPopupStatusline()"
    elseif key ==? "<ScrollWheelDown>"
        call win_execute(a:winid, "norm! 3j")
        exec g:Lf_py "mruExplManager._cli._buildPopupPrompt()"
        redraw
        exec g:Lf_py "mruExplManager._getInstance().refreshPopupStatusline()"
    elseif key ==# "q" || key ==? "<ESC>"
        exec g:Lf_py "mruExplManager.quit()"
    elseif key ==# "i" || key ==? "<Tab>"
        call leaderf#ResetPopupOptions(a:winid, 'filter', 'leaderf#PopupFilter')
        exec g:Lf_py "mruExplManager.input()"
    elseif key ==# "o" || key ==? "<CR>" || key ==? "<2-LeftMouse>"
        exec g:Lf_py "mruExplManager.accept()"
    elseif key ==# "x"
        exec g:Lf_py "mruExplManager.accept('h')"
    elseif key ==# "v"
        exec g:Lf_py "mruExplManager.accept('v')"
    elseif key ==# "t"
        exec g:Lf_py "mruExplManager.accept('t')"
    elseif key ==# "d"
        exec g:Lf_py "mruExplManager.deleteMru()"
    elseif key ==# "s"
        exec g:Lf_py "mruExplManager.addSelections()"
    elseif key ==# "a"
        exec g:Lf_py "mruExplManager.selectAll()"
    elseif key ==# "c"
        exec g:Lf_py "mruExplManager.clearSelections()"
    elseif key ==# "p"
        exec g:Lf_py "mruExplManager._previewResult(True)"
    elseif key ==? "<F1>"
        exec g:Lf_py "mruExplManager.toggleHelp()"
    elseif key ==? "<C-Up>"
        exec g:Lf_py "mruExplManager._toUpInPopup()"
    elseif key ==? "<C-Down>"
        exec g:Lf_py "mruExplManager._toDownInPopup()"
    en

    return 1
endf
