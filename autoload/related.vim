if exists("g:loaded_related") || &cp || v:version < 700
  finish
endif
let g:loaded_related = 1

let s:alternatives = {
   \ 'c': ['h'],
   \ 'cpp': ['h'],
   \ 'h': ['c', 'cpp'] }

function! s:getEditCmd(inSplit)
  if a:inSplit
    if ( winwidth(0) * 1.0 / winheight(0) ) < 2.3
      return 'sp '
    else
      return 'vs '
    endif
  else
    return 'edit '
  endif
endfunction

function! s:getAlternatives(originalExt)
  " Returns a list of alternative extensions for the given argument.
  let result = []
  if exists('g:related_alternatives') &&
        \ has_key(g:related_alternatives, originalExt)
    let result = result + g:related_alternatives[originalExt]
  endif

  if has_key(s:alternatives, a:originalExt)
    let result = result + s:alternatives[a:originalExt]
  endif
  return result
endfunction

function! s:handleExtension(ext, editCmd)
  let fname = printf('%s.%s', expand('%:r'), a:ext)

  " If the file is already displayed in a window, just go to it.
  let window = bufwinnr(fname)
  if window != -1
    execute window . 'wincmd w'
    return 1
  endif

  if filereadable(fname)
    execute a:editCmd . fname
    return 1
  endif

  return 0
endfunction

function! related#switch(inSplit)
  let editCmd = s:getEditCmd(a:inSplit)
  
  for ext in s:getAlternatives(expand('%:e'))
    if s:handleExtension(ext, editCmd)
      return
    endif
  endfor

  let msg = 'No alternate file found for ' . expand('%:t')
  echohl ErrorMsg | echo msg | echohl None
endfunction
