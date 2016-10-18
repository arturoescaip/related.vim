if exists("g:loaded_related") || &cp || v:version < 700
  finish
endif
let g:loaded_related = 1

let s:alternatives = [
      \ [ '\.c$', ['.h'] ],
      \ [ '\.cpp$', ['.h'] ],
      \ [ '\.h$', ['.c', '.cpp'] ],
      \ [ '\.go$', [ '_test.go' ] ],
      \ [ '_test\.go$', [ '.go' ] ],
      \]

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

function s:getMatches(assoc)
  let result = []
  let fname = expand('%')
  for part in a:assoc
    if match(fname, part[0]) != -1
      let result += part
    endif
  endfor
  return result
endfunction

function! s:handleAlternative(base, alt, editCmd)
  let fname = substitute(expand('%'), '\v' . a:base, a:alt, '')

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
  let fname = expand('%')
  let editCmd = s:getEditCmd(a:inSplit)
  
  if exists('g:related_alternatives')
    let alternatives = g:related_alternatives + s:alternatives
  else
    let alternatives = s:alternatives
  endif

  for altList in alternatives
    if match(fname, '\v' . altList[0]) != -1
      for alt in altList[1]
        if s:handleAlternative(altList[0], alt, editCmd)
          return
        endif
      endfor
    endif
  endfor

  let msg = 'No alternate file found for ' . expand('%:t')
  echohl ErrorMsg | echo msg | echohl None
endfunction
