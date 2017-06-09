if !exists('g:walker_path')
  let g:walker_path = "~/workspace/codewalks"
endif

if !exists('g:walker_current_walk')
  let g:walker_current_walk = ''
endif

""" HELPERS {{{

" used for debugging
function! Log(...)
  if (get(g:, 'walker_debug', 0))
    " only support first arg right now :\
    echom a:0
  end
endfunction

function! BuildQFList(_, path)
  let [filename, lnum] = split(a:path, ';')
  return {
        \  'filename': filename,
        \  'lnum': lnum,
        \  'text': '_'
        \ }
endfunction

function! GetWalkFiles()
  let files = split(globpath(g:walker_path, "*"), "\n")
  let names = []
  let idx = 0
  for file in files
    :call add(names, idx . "-:" . fnamemodify(file, ":t"))
    let idx = idx + 1
  endfor
  return [files, names]
endfunction

function! Prompt(message)
  call inputsave()
  let choice = input(a:message)
  call inputrestore()
  return choice
endfunction
""" }}}

" responsible for writing a line to the walk file
function! walker#mark()
  let lineNo = line(".")
  let filePath = expand("%:p")
  if empty(g:walker_current_walk)
    call Log("No walk file defined, choose one:\n")
    call walker#setFile()
  end

  " I do not know how to discard output except by assigning ¯\_(ツ)_/¯
  let _ = execute('! echo "' . filePath . ';' . lineNo . ';" >>' . g:walker_current_walk)
endfunction

" List files
" this is the quickest and dirtiest way of doing this and easily editing the
" files, there may be better options
function! walker#files()
  " https://vi.stackexchange.com/a/4006
  execute "Explore " . fnameescape(g:walker_path)
endfunction

function! walker#setFile()
  let [files, names] = GetWalkFiles()
  echo join(names, " ")
  let choice = Prompt('Choose an existing walk or enter the name of a new one (e.g. "my_walk")')

  " look for non digit characters and use them as the name of a walk
  " within the walk folder
  if choice =~? '^\D'
    let g:walker_current_walk = g:walker_path . '/' . choice
    return
  end

  let chosenFile = get(files,  str2nr(choice), v:null)
  if chosenFile is v:null
    call Message("Invalid index specified"))
    return
  endif

  let g:walker_current_walk = chosenFile
endfunction

function! walker#walk()
  let [files, names] = GetWalkFiles()
  echo join(names, " ")
  let walkName = Prompt('Choose a walk:')
  let chosenFile = get(files,  str2nr(walkName), v:null)
  if chosenFile is v:null
    call echo "Invalid index specified"
    return
  endif

  let g:walker_current_walk = chosenFile
  let contents = readfile(chosenFile)
  let qfList = map(contents, function('BuildQFList'))
  call setqflist(qfList, 'r')
  :copen
endfunction
