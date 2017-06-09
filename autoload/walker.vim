if !exists('g:walker_path')
  let g:walker_path = "~/workspace/codewalks"
endif

if !exists('g:walker_current_walk')
  let g:walker_current_walk = ''
endif

" used for debugging
function! s:log(...)
  if (get(g:, 'walker_debug', 0))
    " only support first arg right now :\
    echom a:0
  end
endfunction

" used for actually 'talking' to user
function! s:message(...)
    " only support first arg right now :\
  echom(a:0)
endfunction

" todo: use git / SCM to look up route and append a hash if necessary?
" we need to ideally:
"   store things in a human readable but also machine parseable way (YAML OMG)
function! walker#mark()
  let lineNo = line(".")
  let filePath = expand("%:p")
  if empty(g:walker_current_walk)
    :call s:log("No walk file defined, choose one:\n")
    :call walker#setFile()
  end

  " I do not know how to discard output except by assigning ¯\_(ツ)_/¯
  let _ = execute('! echo "' . filePath . ':' . lineNo . ';" >>' . g:walker_current_walk)
endfunction

" this is the quickest and dirtiest way of doing this and easily editing the
" files, there may be better options
function! walker#files()
  " https://vi.stackexchange.com/a/4006
  execute "Explore " . fnameescape(g:walker_path)
endfunction

function! walker#setFile()
  let files = split(globpath(g:walker_path, "*"), "\n")
  let names = []
  let idx = 0

  for file in files
    :call add(names, idx . "-:" . fnamemodify(file, ":t"))
    let idx = idx + 1
  endfor

  call s:message(join(names, " "))
  call inputsave()
  let choice = input('Choose an existing walk or enter the name of a new one (e.g. "my_walk")')
  call inputrestore()

  " look for non digit characters and use them as the name of a walk
  " within the walk folder
  if choice =~? '^\D'
    let g:walker_current_walk = g:walker_path . '/' . choice
    return
  end

  let chosenFile = get(files,  str2nr(choice), v:null)
  if chosenFile is v:null
    call s:message("Invalid index specified"))
    return
  else
    let g:walker_current_walk = chosenFile
  endif
endfunction

function! s:buildQFList(_, path)
  let [filename, lnum] = split(a:path, ';')
  return {
        \  'filename': filename,
        \  'lnum': lnum,
        \  'text': ''
        \ }
endfunction

function! walker#walk(walk_name)
  let contents = readfile(glob(g:walker_path . '/' . a:walk_name))
  let qfList = map(contents, function('s:buildQFList'))
  :call setqflist(qfList, 'r')
  :execute
endfunction
