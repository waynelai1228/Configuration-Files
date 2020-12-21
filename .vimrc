
filetype plugin on
filetype plugin indent on

syntax enable

set nocompatible
set ruler
set number
set wildmenu
set autoread
set ignorecase
set nowrap
set smartcase
set hlsearch
set incsearch
set magic
set showmatch
set mat=2
set noerrorbells
set novisualbell
set hidden
set nobackup
set noswapfile
set expandtab
set tabpagemax=100
"set smarttab
"set autoindent

set t_Co=256
colorscheme inkpot

set cursorline!

" hack to make verilog indent smaller, w/o this it is 8 spaces.
autocmd FileType verilog_systemverilog setlocal shiftwidth=4 tabstop=4 softtabstop=4
autocmd FileType verilog setlocal shiftwidth=4 tabstop=4 softtabstop=4

" hack to turn off spell check for verilog file types
autocmd BufNewFile,BufRead *.sv setlocal nospell

filetype on
autocmd BufNewFile,BufRead *.sv set filetype=verilog_systemverilog

" upper case keys for writting and quiting

command WQ wq
command Wq wq
command W w
command Wa w
command Q q
command Qa qa

function RubySettings()
  set tabstop=2
  set shiftwidth=2
  set softtabstop=2
endfunction

function CSettings()
  set tabstop=2
  set shiftwidth=2
  set softtabstop=2
endfunction

"autocmd FileType xml call XmlSettings()
autocmd FileType c,cpp,python call CSettings()
autocmd FileType ruby call RubySettings()
autocmd BufNewFile,BufRead *.proto set filetype=proto

if has("cscope")
  "set csprg=/usr/local/bin/cscope
  set csto=0
  set cst
  set nocsverb

  if filereadable("cscope.out")
      cs add cscope.out
  endif

  set csverb
endif

map <C-\> :cs find 0 <C-R>=expand("<cword>")<CR><CR>
map <A-]> :vsp <CR>:exec("tag ".expand("<cword>"))<CR>
map f<C-]> :cs find f <C-R>=expand("<cword>")<CR><CR>
map g<C-]> :silent! !build_cscope_db&<CR>
nnoremap <silent> gc :redir @a<CR>:g//<CR>:redir END<CR>:new<CR>:put! a<CR>
nnoremap <CR> :noh<CR><CR>

map <leader>gb :Gblame<CR>
map <leader>gl :Glog<CR>
map <leader>gs :Gstatus<CR>

map <leader>rt :TagbarToggle<CR>

map <silent> <leader>ev :e ~/.vimrc<CR>

command! -nargs=* Etag call EtagFunc(<f-args>)
function! EtagFunc(...)
    if a:0 == 0
        let a:regexToFind = expand("<cword>")
    else
        let a:regexToFind = a:1
    endif
    execute "cscope find e " . a:regexToFind
endfunction

set grepprg=grep\ --exclude=tags\ -rsIn\ $*\ /dev/null
let g:ackprg="ack -H --ignore-dir=validation --nocolor --nogroup --column --type=cc --type-add cc=.fml,.mf,.proto $*"
map gV :silent! !dot -Txlib % & <CR>
cabbr %% <C-R>=expand('%:p:h')<CR>

" Strip the newline from the end of a string
function! Chomp(str)
  return substitute(a:str, '\n$', '', '')
endfunction

" Find a file and pass it to cmd
function! DmenuOpen(cmd)
  let fname = Chomp(system("git ls-files | dmenu -i -l 20 -p " . a:cmd))
  if empty(fname)
    return
  endif
  execute a:cmd . " " . fname
endfunction

map t<c-p> :call DmenuOpen("tabe")<cr>
map <c-p> :call DmenuOpen("e")<cr>

" Zoom / Restore window.
function! s:ZoomToggle() abort
    if exists('t:zoomed') && t:zoomed
        execute t:zoom_winrestcmd
        let t:zoomed = 0
    else
        let t:zoom_winrestcmd = winrestcmd()
        resize
        vertical resize
        let t:zoomed = 1
    endif
endfunction
command! ZoomToggle call s:ZoomToggle()
nnoremap <silent> <C-W>o :ZoomToggle<CR>

"let g:ctrlp_user_command = ['.git', 'cd %s && git ls-files --exclude-standard']
"let g:ctrlp_max_files = 0

if exists("+showtabline")
function MyTabLine()
    let s = ''
    let t = tabpagenr()
    let i = 1
    let m = 0 "modified counter
    while i <= tabpagenr('$')
      let buflist = tabpagebuflist(i)
      let winnr = tabpagewinnr(i)
      for b in buflist
              if getbufvar(b, "&modified")
                      let m += 1
              endif
      endfor
      let s .= '%' . i . 'T'
      let s .= (i == t ? '%1*' : '%2*')

      if m > 0
            let s .= '[' . m . '+]'
            let m = 0
      endif

      let s .= ' '
      let s .= i . ':'
      let s .= winnr . '/' . tabpagewinnr(i,'$')
      let s .= ' %*'
      let s .= (i == t ? '%#TabLineSel#' : '%#TabLine#')


      let bufnr = buflist[winnr - 1]
      let file = bufname(bufnr)
      let buftype = getbufvar(bufnr, 'buftype')
      
      if buftype == 'nofile'
        if file =~ '\/.'
          let file = substitute(file, '.*\/\ze.', '', '')
        endif
      else
        let file = fnamemodify(file, ':p:t')
      endif
      if file == ''
        let file = '[No Name]'
      endif
      let s .= file . ' '
      let i = i + 1
    endwhile
    if i > 1
        set stal=2
    else
        set stal=1
    endif
    let s .= '%T%#TabLineFill#%='
    let s .= (tabpagenr('$') > 1 ? '%999XX' : 'X')
    return s
  endfunction
 set tabline=%!MyTabLine()
endif

