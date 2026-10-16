" whatchanged.vim - live-reload files changed by other programs (AI agents, formatters,
" git) and diff them against how they were before the first outside edit since your
" own last change.
" Maintainer: Ralph Pineda
" License:    MIT

if exists('g:loaded_whatchanged') || &compatible || v:version < 802
  finish
endif
let g:loaded_whatchanged = 1

let g:whatchanged_poll_ms = get(g:, 'whatchanged_poll_ms', 1000)
let g:whatchanged_notify  = get(g:, 'whatchanged_notify', 1)
let g:whatchanged_hl      = get(g:, 'whatchanged_hl', 'Comment')

" 'autoread' reloads unmodified buffers without firing FileChangedShell, so the
" "before" snapshot could never be taken.  This plugin does the reloading instead.
set noautoread

augroup whatchanged
  autocmd!
  autocmd FileChangedShell     * call whatchanged#on_file_changed(str2nr(expand('<abuf>')))
  autocmd FileChangedShellPost * call whatchanged#after_reload(str2nr(expand('<abuf>')), expand('<afile>:t'))
  autocmd TextChanged,TextChangedI * call whatchanged#on_text_changed()
  autocmd FocusGained,BufEnter * silent! checktime
augroup END

command! -bar WhatChanged      call whatchanged#show()
command! -bar WhatChangedReset call whatchanged#reset()
nnoremap <silent> <Plug>(WhatChanged) :<C-u>call whatchanged#show()<CR>

if g:whatchanged_poll_ms > 0 && has('timers')
  call timer_start(g:whatchanged_poll_ms, function('whatchanged#poll'), {'repeat': -1})
endif
