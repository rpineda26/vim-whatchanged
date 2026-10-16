" whatchanged.vim - see plugin/whatchanged.vim

" Decide what to do when a buffer's file changed on disk.  Unmodified buffers reload
" (undoable with u); buffers with unsaved changes ask, so your work is never dropped.
function! whatchanged#on_file_changed(buf) abort
  " only content changes; leave deletes and permission changes to Vim's default warning
  if index(['changed', 'conflict', 'time'], v:fcs_reason) < 0
    let v:fcs_choice = ''
    return
  endif
  if v:fcs_reason ==# 'conflict' || getbufvar(a:buf, '&modified')
    let v:fcs_choice = 'ask'
    return
  endif
  " keep the oldest snapshot: several outside edits in a row diff as one
  if empty(getbufvar(a:buf, 'whatchanged_before', []))
    call setbufvar(a:buf, 'whatchanged_before', getbufline(a:buf, 1, '$'))
  endif
  let v:fcs_choice = 'reload'
endfunction

function! whatchanged#after_reload(buf, name) abort
  call setbufvar(a:buf, 'whatchanged_tick', getbufvar(a:buf, 'changedtick'))
  if exists('*gitgutter#process_buffer')
    silent! call gitgutter#process_buffer(a:buf, 0)
  endif
  if g:whatchanged_notify
    execute 'echohl' g:whatchanged_hl
    echo '↻ ' . a:name . ' changed on disk · :WhatChanged shows what changed'
    echohl None
  endif
endfunction

" your own edit (not a reload) starts a new baseline
function! whatchanged#on_text_changed() abort
  if exists('b:whatchanged_before') && b:changedtick != get(b:, 'whatchanged_tick', -1)
    unlet b:whatchanged_before
  endif
endfunction

function! whatchanged#reset() abort
  unlet! b:whatchanged_before
endfunction

" Open the snapshot in a left split, diffed against the current buffer.  q closes it.
function! whatchanged#show() abort
  if empty(get(b:, 'whatchanged_before', []))
    echo 'No outside changes since your last edit'
    return
  endif
  let [l:lines, l:ft, l:name] = [b:whatchanged_before, &filetype, expand('%:t')]
  diffthis
  vertical leftabove new
  call setline(1, l:lines)
  setlocal buftype=nofile bufhidden=wipe noswapfile nomodifiable
  let &l:filetype = l:ft
  execute 'silent file' fnameescape('before: ' . l:name)
  diffthis
  nnoremap <buffer> <silent> q :diffoff!<Bar>quit<CR>
  autocmd BufWipeout <buffer> diffoff!
  wincmd p
endfunction

" Called by a timer so changes show up even while Vim isn't focused.  Only in Normal
" mode, so it never interrupts a command line, insert, or prompt.
function! whatchanged#poll(...) abort
  if mode() ==# 'n' && empty(getcmdwintype())
    silent! checktime
  endif
endfunction
