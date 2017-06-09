if !exists('g:walker_map_keys')
    let g:walker_map_keys = 1
endif

if g:walker_map_keys
  nmap <silent> <leader>wm :call walker#mark()<CR>
  nmap <silent> <leader>ww :call walker#walk()<CR>
endif
