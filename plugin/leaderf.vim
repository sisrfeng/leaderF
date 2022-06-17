" ============================================================================
" File:        leaderf.vim
" Description:
" Author:      Yggdroot <archofortune@gmail.com>
" Website:     https://github.com/Yggdroot
" Note:
" License:     Apache License, Version 2.0
" ============================================================================

if exists('g:leaderf_loaded') || &compatible
    finish
elseif v:version < 704 || v:version == 704 && has("patch330") == 0
    echohl Error
    echomsg "LeaderF requires Vim 7.4.330+."
    echohl None
    finish
elseif !has('pythonx') && !has('python3') && !has('python')
    echohl Error
    echomsg "LeaderF requires Vim compiled with python and/or a compatible python version."
    echohl None
    finish
el
    let g:leaderf_loaded = 1
en

fun! s:InitVar(var, value)
    if !exists(a:var)
        exec 'let '.a:var.'='.string(a:value)
    en
endf

call s:InitVar('g:Lf_ShortcutF', '<Leader>f')
call s:InitVar('g:Lf_ShortcutB', '<Leader>b')
call s:InitVar('g:Lf_WindowPosition', 'bottom')
call s:InitVar('g:Lf_CacheDirectory', $HOME)
call s:InitVar('g:Lf_MruBufnrs', [])
call s:InitVar('g:Lf_PythonExtensions', {})
call s:InitVar('g:Lf_PreviewWindowID', {})

fun! g:LfNoErrMsgMatch(expr, pat)
    try
        return match(a:expr, a:pat)
    catch /^Vim\%((\a\+)\)\=:E/
    endtry
    return -2
endf

fun! g:LfNoErrMsgCmd(cmd)
    try
        exec a:cmd
        return 1
    catch /^Vim\%((\a\+)\)\=:/
        return 0
    endtry
endf

call s:InitVar('g:Lf_SelfContent', {})

fun! g:LfRegisterSelf(cmd, description)
    let g:Lf_SelfContent[a:cmd] = a:description
endf

fun! g:LfRegisterPythonExtension(name, dict)
    let g:Lf_PythonExtensions[a:name] = a:dict
endf

let s:leaderf_path = expand("<sfile>:p:h:h")
fun! s:InstallCExtension(install) abort
    let win_exists = 0
    let bot_split = "botright new | let w:leaderf_installC = 1 |"
    let use_cur_win = has("nvim") ? "" : " ++curwin"
    for n in range(winnr('$'))
        if getwinvar(n+1, 'leaderf_installC', 0) == 1
            let win_exists = 1
            let bot_split = ""
            exec string(n+1) . "wincmd w"
            break
        en
    endfor
    let terminal = exists(':terminal') == 2 ? bot_split ." terminal". use_cur_win : "!"
    if has('win32') || has('win64')
        let shell =  "cmd /c"
        let cd_cmd = "cd /d"
        let script = "install.bat"
    el
        let shell =  "sh -c"
        let cd_cmd = "cd"
        let script = "./install.sh"
    en
    let reverse = a:install ? "" : " --reverse"
    let cmd = printf('%s %s "%s %s && %s%s"', terminal, shell, cd_cmd, s:leaderf_path, script, reverse)
    exec cmd
    if has("nvim")
        norm! G
    en
endf

fun! s:Normalize(filename)
    if has("nvim") && (has('win32') || has('win64'))
        if &shellslash
            return tr(a:filename, '\', '/')
        el
            return tr(a:filename, '/', '\')
        en
    el
        return a:filename
    en
endf

augroup LeaderF_Mru
    au      BufAdd,BufEnter,BufWritePost * call lfMru#record(s:Normalize(expand('<afile>:p'))) |
                \ call lfMru#recordBuffer(expand('<abuf>'))
augroup END

augroup LeaderF_Gtags
    autocmd!
    if get(g:, 'Lf_GtagsAutoGenerate', 0) == 1
        au      BufRead * call leaderf#Gtags#updateGtags(expand('<afile>:p'), 0)
    en
    if get(g:, 'Lf_GtagsAutoUpdate', 1) == 1
        au      BufWritePost * call leaderf#Gtags#updateGtags(expand('<afile>:p'), 1)
    en
augroup END

" map
    no      <silent> <Plug>LeaderfFileTop        :<C-U>Leaderf file --top<CR>
    no      <silent> <Plug>LeaderfFileBottom     :<C-U>Leaderf file --bottom<CR>
    no      <silent> <Plug>LeaderfFileLeft       :<C-U>Leaderf file --left<CR>
    no      <silent> <Plug>LeaderfFileRight      :<C-U>Leaderf file --right<CR>
    no      <silent> <Plug>LeaderfFileFullScreen :<C-U>Leaderf file --fullScreen<CR>

    no      <silent> <Plug>LeaderfBufferTop        :<C-U>Leaderf buffer --top<CR>
    no      <silent> <Plug>LeaderfBufferBottom     :<C-U>Leaderf buffer --bottom<CR>
    no      <silent> <Plug>LeaderfBufferLeft       :<C-U>Leaderf buffer --left<CR>
    no      <silent> <Plug>LeaderfBufferRight      :<C-U>Leaderf buffer --right<CR>
    no      <silent> <Plug>LeaderfBufferFullScreen :<C-U>Leaderf buffer --fullScreen<CR>

    no      <silent> <Plug>LeaderfMruCwdTop        :<C-U>Leaderf mru --top<CR>
    no      <silent> <Plug>LeaderfMruCwdBottom     :<C-U>Leaderf mru --bottom<CR>
    no      <silent> <Plug>LeaderfMruCwdLeft       :<C-U>Leaderf mru --left<CR>
    no      <silent> <Plug>LeaderfMruCwdRight      :<C-U>Leaderf mru --right<CR>
    no      <silent> <Plug>LeaderfMruCwdFullScreen :<C-U>Leaderf mru --fullScreen<CR>

    no      <Plug>LeaderfRgPrompt :<C-U>Leaderf rg -e<Space>
    no      <Plug>LeaderfRgCwordLiteralNoBoundary :<C-U><C-R>=leaderf#Rg#startCmdline(0, 0, 0, 0)<CR>
    no      <Plug>LeaderfRgCwordLiteralBoundary   :<C-U><C-R>=leaderf#Rg#startCmdline(0, 0, 0, 1)<CR>
    no      <Plug>LeaderfRgCwordRegexNoBoundary   :<C-U><C-R>=leaderf#Rg#startCmdline(0, 0, 1, 0)<CR>
    no      <Plug>LeaderfRgCwordRegexBoundary     :<C-U><C-R>=leaderf#Rg#startCmdline(0, 0, 1, 1)<CR>

    no      <Plug>LeaderfRgBangCwordLiteralNoBoundary :<C-U><C-R>=leaderf#Rg#startCmdline(0, 1, 0, 0)<CR>
    no      <Plug>LeaderfRgBangCwordLiteralBoundary   :<C-U><C-R>=leaderf#Rg#startCmdline(0, 1, 0, 1)<CR>
    no      <Plug>LeaderfRgBangCwordRegexNoBoundary   :<C-U><C-R>=leaderf#Rg#startCmdline(0, 1, 1, 0)<CR>
    no      <Plug>LeaderfRgBangCwordRegexBoundary     :<C-U><C-R>=leaderf#Rg#startCmdline(0, 1, 1, 1)<CR>

    no      <Plug>LeaderfRgWORDLiteralNoBoundary :<C-U><C-R>=leaderf#Rg#startCmdline(1, 0, 0, 0)<CR>
    no      <Plug>LeaderfRgWORDLiteralBoundary   :<C-U><C-R>=leaderf#Rg#startCmdline(1, 0, 0, 0)<CR>
    no      <Plug>LeaderfRgWORDRegexNoBoundary   :<C-U><C-R>=leaderf#Rg#startCmdline(1, 0, 1, 0)<CR>
    no      <Plug>LeaderfRgWORDRegexBoundary     :<C-U><C-R>=leaderf#Rg#startCmdline(1, 0, 1, 1)<CR>

    vno      <silent> <Plug>LeaderfRgVisualLiteralNoBoundary :<C-U><C-R>=leaderf#Rg#startCmdline(2, 0, 0, 0)<CR>
    vno      <silent> <Plug>LeaderfRgVisualLiteralBoundary   :<C-U><C-R>=leaderf#Rg#startCmdline(2, 0, 0, 1)<CR>
    vno      <silent> <Plug>LeaderfRgVisualRegexNoBoundary   :<C-U><C-R>=leaderf#Rg#startCmdline(2, 0, 1, 0)<CR>
    vno      <silent> <Plug>LeaderfRgVisualRegexBoundary     :<C-U><C-R>=leaderf#Rg#startCmdline(2, 0, 1, 1)<CR>

    vno      <silent> <Plug>LeaderfRgBangVisualLiteralNoBoundary :<C-U><C-R>=leaderf#Rg#startCmdline(2, 1, 0, 0)<CR>
    vno      <silent> <Plug>LeaderfRgBangVisualLiteralBoundary   :<C-U><C-R>=leaderf#Rg#startCmdline(2, 1, 0, 1)<CR>
    vno      <silent> <Plug>LeaderfRgBangVisualRegexNoBoundary   :<C-U><C-R>=leaderf#Rg#startCmdline(2, 1, 1, 0)<CR>
    vno      <silent> <Plug>LeaderfRgBangVisualRegexBoundary     :<C-U><C-R>=leaderf#Rg#startCmdline(2, 1, 1, 1)<CR>

    no      <Plug>LeaderfGtagsDefinition :<C-U><C-R>=leaderf#Gtags#startCmdline(0, 1, 'd')<CR><CR>
    no      <Plug>LeaderfGtagsReference :<C-U><C-R>=leaderf#Gtags#startCmdline(0, 1, 'r')<CR><CR>
    no      <Plug>LeaderfGtagsSymbol :<C-U><C-R>=leaderf#Gtags#startCmdline(0, 1, 's')<CR><CR>
    no      <Plug>LeaderfGtagsGrep :<C-U><C-R>=leaderf#Gtags#startCmdline(0, 1, 'g')<CR><CR>

    vno      <silent> <Plug>LeaderfGtagsDefinition :<C-U><C-R>=leaderf#Gtags#startCmdline(2, 1, 'd')<CR><CR>
    vno      <silent> <Plug>LeaderfGtagsReference :<C-U><C-R>=leaderf#Gtags#startCmdline(2, 1, 'r')<CR><CR>
    vno      <silent> <Plug>LeaderfGtagsSymbol :<C-U><C-R>=leaderf#Gtags#startCmdline(2, 1, 's')<CR><CR>
    vno      <silent> <Plug>LeaderfGtagsGrep :<C-U><C-R>=leaderf#Gtags#startCmdline(2, 1, 'g')<CR><CR>

" command
    com!     -bar -nargs=* -complete=dir LeaderfFile Leaderf file <args>
    com!     -bar -nargs=* -complete=dir LeaderfFileFullScreen Leaderf file --fullScreen <args>
    com!     -bar -nargs=1 LeaderfFilePattern Leaderf file --input <args>
    com!     -bar -nargs=0 LeaderfFileCword Leaderf file --cword

    com!     -bar -nargs=0 LeaderfBuffer Leaderf buffer
    com!     -bar -nargs=0 LeaderfBufferAll Leaderf buffer --all
    com!     -bar -nargs=0 LeaderfTabBuffer Leaderf buffer --tabpage
    com!     -bar -nargs=0 LeaderfTabBufferAll Leaderf buffer --tabpage --all
    com!     -bar -nargs=1 LeaderfBufferPattern Leaderf buffer --input <args>
    com!     -bar -nargs=0 LeaderfBufferCword Leaderf buffer --cword

    com!     -bar -nargs=0 LeaderfMru Leaderf mru
    com!     -bar -nargs=0 LeaderfMruCwd Leaderf mru --cwd
    com!     -bar -nargs=1 LeaderfMruPattern Leaderf mru --input <args>
    com!     -bar -nargs=0 LeaderfMruCword Leaderf mru --cword
    com!     -bar -nargs=1 LeaderfMruCwdPattern Leaderf mru --cwd --input <args>
    com!     -bar -nargs=0 LeaderfMruCwdCword Leaderf mru --cwd --cword

    com!     -bar -nargs=0 LeaderfTag Leaderf tag
    com!     -bar -nargs=1 LeaderfTagPattern Leaderf tag --input <args>
    com!     -bar -nargs=0 LeaderfTagCword Leaderf tag --cword

    com!     -bar -nargs=0 -bang LeaderfBufTag Leaderf<bang> bufTag
    com!     -bar -nargs=0 -bang LeaderfBufTagAll Leaderf<bang> bufTag --all
    com!     -bar -nargs=1 -bang LeaderfBufTagPattern Leaderf<bang> bufTag --input <args>
    com!     -bar -nargs=0 -bang LeaderfBufTagCword Leaderf<bang> bufTag --cword
    com!     -bar -nargs=1 -bang LeaderfBufTagAllPattern Leaderf<bang> bufTag --all --input <args>
    com!     -bar -nargs=0 -bang LeaderfBufTagAllCword Leaderf<bang> bufTag --all --cword

    com!     -bar -nargs=0 -bang LeaderfFunction Leaderf<bang> function
    com!     -bar -nargs=0 -bang LeaderfFunctionAll Leaderf<bang> function --all
    com!     -bar -nargs=1 -bang LeaderfFunctionPattern Leaderf<bang> function --input <args>
    com!     -bar -nargs=0 -bang LeaderfFunctionCword Leaderf<bang> function --cword
    com!     -bar -nargs=1 -bang LeaderfFunctionAllPattern Leaderf<bang> function --all --input <args>
    com!     -bar -nargs=0 -bang LeaderfFunctionAllCword Leaderf<bang> function --all --cword

    com!     -bar -nargs=0 LeaderfLine Leaderf line
    com!     -bar -nargs=0 LeaderfLineAll Leaderf line --all
    com!     -bar -nargs=1 LeaderfLinePattern Leaderf line --input <args>
    com!     -bar -nargs=0 LeaderfLineCword Leaderf line --cword
    com!     -bar -nargs=1 LeaderfLineAllPattern Leaderf line --all --input <args>
    com!     -bar -nargs=0 LeaderfLineAllCword Leaderf line --all --cword

    com!     -bar -nargs=0 LeaderfHistoryCmd Leaderf cmdHistory
    com!     -bar -nargs=0 LeaderfHistorySearch exec "Leaderf searchHistory" | silent! norm! n

    com!     -bar -nargs=0 LeaderfSelf Leaderf self

    com!     -bar -nargs=0 LeaderfHelp Leaderf help
    com!     -bar -nargs=1 LeaderfHelpPattern Leaderf help --input <args>
    com!     -bar -nargs=0 LeaderfHelpCword Leaderf help --cword

    com!     -bar -nargs=0 LeaderfColorscheme Leaderf colorscheme

    com!     -bar -nargs=0 LeaderfRgInteractive call leaderf#Rg#Interactive()
    com!     -bar -nargs=0 LeaderfRgRecall exec "Leaderf! rg --recall"

    com!     -bar -nargs=0 LeaderfFiletype Leaderf filetype

    com!     -bar -nargs=0 LeaderfCommand Leaderf command

    com!     -bar -nargs=0 LeaderfWindow Leaderf window

    com!     -bar -nargs=0 LeaderfQuickFix Leaderf quickfix
    com!     -bar -nargs=0 LeaderfLocList  Leaderf loclist

try
    if g:Lf_ShortcutF != ""
        exec 'nnoremap <silent><unique> ' g:Lf_ShortcutF ':<C-U>LeaderfFile<CR>'
    en
catch /^Vim\%((\a\+)\)\=:E227/
endtry

try
    if g:Lf_ShortcutB != ""
        exec 'nnoremap <silent><unique> ' g:Lf_ShortcutB ':<C-U>LeaderfBuffer<CR>'
    en
catch /^Vim\%((\a\+)\)\=:E227/
endtry

com!     -nargs=* -bang -complete=customlist,leaderf#Any#parseArguments
    \ Leaderf
    \ call leaderf#Any#start(<bang>0, <q-args>)

com!     -nargs=0 LeaderfInstallCExtension call s:InstallCExtension(1)
com!     -nargs=0 LeaderfUninstallCExtension call s:InstallCExtension(0)
