Walker.vim
---

Make code walks as simple as a roundhouse kick to the face. If you are slicing your way through a codepath that weaves between microservices and want a trail, walker is your friend.

## Installation

```viml
" or any github compatible runtime loader
Plug 'nicktomlin/walker.vim'
```

Add the following bindings to your `.vimrc`:

```viml
" Add a stop to your code walk
nmap <silent> <leader>wm :call walker#mark()<CR>

" Open all stops in your codewalk in the quickfix list
nmap <silent> <leader>ww :call walker#walk()<CR>
```

## Usage

See the [docs](doc/walker.txt)

