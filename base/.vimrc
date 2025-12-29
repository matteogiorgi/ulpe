" ~/.vimrc
" --------
" Vim script for general settings, no external dependencies.
" Still in legacy version but not compatible with Vim8.




" Vim9 {{{
if v:version < 900
    finish
elseif !isdirectory(expand('~/.vim'))
    silent! execute '!mkdir -p ~/.vim >/dev/null 2>&1'
endif
" }}}




" Undodir & Sessiondir {{{
if has('persistent_undo')
    if !isdirectory(expand('~/.vim/undodir'))
        silent! execute '!mkdir -p ~/.vim/undodir >/dev/null 2>&1'
    endif
    set undodir=${HOME}/.vim/undodir
    set undofile
endif
" ---
if !isdirectory(expand('~/.vim/sessiondir'))
    silent! execute '!mkdir -p ~/.vim/sessiondir >/dev/null 2>&1'
endif
" }}}




" Leaders, Caret & Linebreak {{{
let g:mapleader = "\<Space>"
let g:maplocalleader = "\\"
let &t_SI = "\e[6 q"
let &t_EI = "\e[2 q"
" ---
if has('linebreak')
    let &showbreak='  ~'
endif
" }}}




" Syntax & Filetype {{{
syntax on
filetype plugin indent on
set background=dark
silent! colorscheme wildcharm
" }}}




" Options {{{
set exrc
set title
set shell=bash
set runtimepath+=~/.vim_runtime
set number relativenumber mouse=a ttymouse=sgr
set tabstop=4 softtabstop=0 expandtab shiftwidth=4 smarttab
set foldenable foldcolumn=0 foldmethod=indent foldlevelstart=99 foldnestmax=10 foldminlines=1
set textwidth=120 wrapmargin=0
set formatoptions=tcroqaj
set ruler scrolloff=8 sidescrolloff=16
set autoindent autoread
set formatoptions+=l
set hlsearch incsearch
set nowrap nospell conceallevel=0
set ignorecase smartcase smartindent
set noswapfile nobackup
set showmode showcmd
set noerrorbells novisualbell
set cursorline cursorlineopt=number,line
set splitbelow splitright
set equalalways
set matchpairs+=<:>
set autochdir
set hidden
set updatetime=100
set timeoutlen=2000
set ttimeoutlen=0
set termencoding=utf-8 encoding=utf-8 | scriptencoding utf-8
set sessionoptions=blank,buffers,curdir,folds,tabpages,help,winsize,options,localoptions
set viminfo-=/
set cmdheight=1
set nrformats-=alpha
set fillchars=vert:┃,eob:╺
set laststatus=2 showtabline=1
set termguicolors
set nocompatible
set esckeys
set tags+=./tags;
" ---
set path+=**
set completeopt=menuone,popup,noinsert,noselect
set complete=.,w,b,u,t,i,kspell
set complete+=k/usr/share/dict/american-english
set dictionary+=/usr/share/dict/american-english
set wildmenu wildoptions=fuzzy,pum,tagfile
set wildchar=<Tab> wildmode=full
set wildignore=*/.git/*,*/.hg/*,*/.svn/*,*/tmp/*,*.so,*.swp,*.zip
set shortmess+=c
set belloff+=ctrlg
" ---
if has('unnamedplus')
    set clipboard^=unnamedplus
endif
" }}}




" Functions {{{
function! s:RootDir() abort
    let l:root = getcwd()
    if executable('git')
        let l:root = system('git rev-parse --show-toplevel 2>/dev/null')
        let l:root = v:shell_error == 0 ? substitute(l:root, '\n\+$', '', '') : getcwd()
    endif
    return l:root
endfunction
" ---
function! s:CTags() abort
    if !executable('ctags')
        echo 'ctags not found'
        return
    endif
    let l:root = <SID>RootDir()
    let l:cmd = printf(
              \ 'ctags -R -f %s/tags'
              \ . ' --exclude=.git'
              \ . ' --exclude=.hg'
              \ . ' --exclude=.svn'
              \ . ' --exclude=.mypy_cache'
              \ . ' --exclude=__pycache__'
              \ . ' --exclude=.venv'
              \ . ' --exclude=node_modules'
              \ . ' %s',
              \ shellescape(l:root),
              \ shellescape(l:root)
          \ )
    silent! execute '!' . l:cmd . ' 2>/dev/null'
    redraw!|redrawstatus!|redrawtabline
    echo 'ctags executed @ "' . l:root . '"'
endfunction
" ---
function! s:CopyClip() abort
    let l:ans = input('copy from register: ')|redraw!
    let l:rin = empty(l:ans) ? '"' : (l:ans =~# '^"' ? l:ans[1:] : l:ans)
    let [l:reg, l:src] = empty(l:rin) ? ['"', ''] : [l:rin[0], l:rin[0]]
    let l:text = getreg(l:src)
    if (($XDG_SESSION_TYPE ==# 'x11') && exists('$DISPLAY')) && executable('xclip')
        call system('xclip -selection clipboard -in >/dev/null 2>&1', l:text)
        echom printf('xcopied from register "%s"', l:reg ==# '"' ? 'unnamed' : l:reg)
        return
    elseif (($XDG_SESSION_TYPE ==# 'wayland') && exists('$WAYLAND_DISPLAY')) && executable('wl-copy')
        call system('wl-copy', l:text)
        echom printf('wcopied from register "%s"', l:reg ==# '"' ? 'unnamed' : l:reg)
        return
    endif
    echo 'xclip|wl-copy not found'
endfunction
" ---
function! s:PastaClip() abort
    if (($XDG_SESSION_TYPE ==# 'x11') && exists('$DISPLAY')) && executable('xclip')
        let l:text = systemlist('xclip -selection clipboard -out')
        let l:who = 'x'
    elseif (($XDG_SESSION_TYPE ==# 'wayland') && exists('$WAYLAND_DISPLAY')) && executable('wl-paste')
        let l:text = systemlist('wl-paste')
        let l:who = 'w'
    else
        echo 'xclip|wl-paste not found'
        return
    endif
    let l:ans = input('paste into register: ')|redraw!
    let l:rout = empty(l:ans) ? '"' : (l:ans =~# '^"' ? l:ans[1:] : l:ans)
    let [l:reg, l:src] = empty(l:rout) ? ['"', ''] : [l:rout[0], l:rout[0]]
    call setreg(l:reg, l:text)
    echom printf(l:who . 'pasted into register "%s"', l:reg ==# '"' ? 'unnamed' : l:reg)
endfunction
" ---
function! s:ToggleFC() abort
    let &foldcolumn = (&foldcolumn + 1) % 2
endfunction
" ---
function! s:ToggleWM() abort
    if get(b:, 'wrapmotion', 0)
        unlet b:wrapmotion
        setlocal nowrap
        for m in ['n', 'x', 'o']
            execute m . 'unmap <buffer> j'
            execute m . 'unmap <buffer> k'
            execute m . 'unmap <buffer> 0'
            execute m . 'unmap <buffer> $'
        endfor
        echo 'wrapmotion off'
        return
    endif
    let b:wrapmotion = 1
    setlocal wrap
    for m in ['n', 'x', 'o']
        execute m . 'noremap <buffer> <expr> j (v:count == 0 ? "gj" : "j")'
        execute m . 'noremap <buffer> <expr> k (v:count == 0 ? "gk" : "k")'
    endfor
    for m in ['n', 'x', 'o']
        execute m . 'noremap <buffer> 0 g0'
        execute m . 'noremap <buffer> $ g$'
    endfor
    echo 'wrapmotion on'
endfunction
" ---
function! s:ToggleQF() abort
    silent! lclose
    if empty(filter(range(1, winnr('$')), 'getwinvar(v:val, "&filetype") ==# "qf"'))
        silent! copen
        return
    endif
    silent! cclose
endfunction
" ---
function! s:AddLineQF() abort
    let l:qf_list = getqflist()
    let l:qf_entry = {
              \ 'bufnr': bufnr('%'),
              \ 'lnum': line('.'),
              \ 'col': col('.'),
              \ 'text': getline('.'),
              \ 'filename': expand('%:p'),
          \ }
    call add(l:qf_list, l:qf_entry)
    call setqflist(l:qf_list)
    echo 'quickfix newline added'
endfunction
" ---
function! s:ResetQF() abort
    call setqflist([])
    echo 'quickfix resetted'
endfunction
" ---
function! s:ResetSR() abort
    let @/=''
    while histdel('search', -1) > 0
    endwhile
    echo 'search resetted'
endfunction
" ---
function! s:SSession() abort
    if executable('git')
        let l:root = system('git rev-parse --show-toplevel 2>/dev/null')
        let l:root = v:shell_error == 0 ? substitute(l:root, '\n\+$', '', '') : getcwd()
    else
        let l:root = getcwd()
    endif
    let l:ans = input('save session as: ')|redraw!
    let l:name = empty(l:ans) ? fnamemodify(l:root, ':t') : l:ans
    let l:dir = expand('~/.vim/sessiondir')
    if !isdirectory(l:dir)
        echo 'sessiondir not present'
        return
    endif
    silent! execute 'mksession! ' . fnameescape(l:dir . '/' . l:name)
    echo 'session "' . l:name . '" saved'
endfunction
" ---
function! s:OSession() abort
    let l:dir = expand('~/.vim/sessiondir')
    let l:sessions = split(glob(l:dir . '/*'), '\n')
    if !isdirectory(l:dir) || empty(l:sessions)
        echo 'no session saved'
        return
    endif
    let l:names = map(copy(l:sessions), 'fnamemodify(v:val, ":t")')
    let l:choice = inputlist(['select session:'] + map(copy(l:names), 'v:key+1 . ") " . v:val'))
    if l:choice > 0 && l:choice <= len(l:names)
        let l:path = l:sessions[l:choice - 1]
        execute 'source' fnameescape(l:path)
    endif
endfunction
" ---
function! s:ScratchBuffer() abort
    if &filetype ==# 'scratch'
        b#|return
    endif
    let target_buffer = bufnr('/tmp/scratchbuffer')
    let target_window = bufwinnr(target_buffer)
    if target_buffer != -1 && target_window != -1
        silent! execute target_window . 'wincmd w'
    else
        edit /tmp/scratchbuffer
        if &l:filetype !=# 'scratch'
            setlocal filetype=scratch
        endif
        setlocal bufhidden=hide
        setlocal nobuflisted
        setlocal noswapfile
        setlocal nospell
    endif
endfunction
" ---
function! s:CleanBuffer() abort
    let l:pos = getpos('.')
    silent! %s/\s\+$//e
    silent! %s/\n\+\%$//e
    call setpos('.', l:pos)
    silent! update
    echo 'buffer cleaned'
endfunction
" ---
function! s:ExecScript(cmd, target) abort
    if exists(':CleanBuffer')
        CleanBuffer
    else
        silent! update
    endif
    let l:target = expand(a:target)
    if empty(l:target)
        echo 'empty target'
        return
    endif
    execute 'terminal ++curwin ' . a:cmd . ' ' . fnameescape(l:target)
endfunction
" ---
function! s:GitDiff() abort
    if system('git rev-parse --is-inside-work-tree 2>/dev/null') !=# "true\n"
        echo "'" . getcwd() . "' is not in a git repo"
        return
    endif
    if exists(':CleanBuffer')
        CleanBuffer
    else
        silent! update
    endif
    execute '!git diff %'
endfunction
" }}}




" Augroups {{{
augroup netrw_prettyfier
    autocmd!
    autocmd FileType netrw
          \ cd %:p:h|
          \ setlocal nonu nornu|
          \ setlocal bufhidden=delete|
          \ setlocal nobuflisted|
          \ setlocal cursorline
    autocmd VimEnter *
          \ if !argc() && exists(':Explore')|
          \     Explore|
          \ endif
    let g:netrw_keepdir = 0
    let g:netrw_banner = 0
    let g:netrw_liststyle = 4
    let g:netrw_sort_options = 'i'
    let g:netrw_sort_sequence = '[\/]$,*'
    let g:netrw_browsex_viewer = 'xdg-open'
    let g:netrw_list_hide = '^\./$'
    let g:netrw_hide = 1
    let g:netrw_preview = 0
    let g:netrw_alto = 1
    let g:netrw_altv = 0
augroup end
" ---
augroup linenumber_prettyfier
    autocmd!
    autocmd BufWinEnter *
          \ if !get(b:, 'wrapmotion', 0) && &l:wrap|
          \     silent! call <SID>ToggleWM()|
          \ endif
    autocmd InsertEnter *
          \ if !get(b:, 'wrapmotion', 0)|
          \     let &l:colorcolumn = '121,'.join(range(121,999),',')|
          \ endif|
          \ setlocal nocursorline|
          \ setlocal number norelativenumber
    autocmd InsertLeave,BufWinEnter *
          \ setlocal colorcolumn=|
          \ setlocal cursorline|
          \ setlocal number relativenumber
augroup end
" ---
augroup terminal_prettyfier
    autocmd!
    autocmd TerminalOpen *
          \ setlocal nobuflisted bufhidden=wipe|
          \ setlocal nonumber norelativenumber
augroup end
" ---
augroup syntax_prettyfier
    autocmd!
    autocmd VimEnter,ColorScheme *
          \ hi! Normal ctermbg=NONE guibg=NONE|
          \ hi! LineNr ctermbg=NONE guibg=NONE|
          \ hi! Folded ctermbg=NONE guibg=NONE|
          \ hi! FoldColumn ctermbg=NONE guibg=NONE|
          \ hi! SignColumn ctermbg=NONE guibg=NONE|
          \ hi! CursorLine cterm=NONE gui=NONE|
          \ hi! CursorLineNr cterm=bold ctermbg=NONE gui=bold guibg=NONE|
          \ hi! MatchParen cterm=underline ctermbg=NONE gui=underline guibg=NONE|
          \ hi! VertSplit cterm=NONE ctermbg=NONE gui=NONE guibg=NONE
augroup end
" ---
augroup syntax_complete
    autocmd!
    autocmd FileType * set omnifunc=syntaxcomplete#Complete
augroup end
" ---
augroup fold_autoload
    autocmd!
    autocmd BufWinEnter *
          \ if expand('%:t') != ''|
          \     silent! loadview|
          \ endif
    autocmd BufWinLeave *
          \ if expand('%:t') != ''|
          \     silent! mkview|
          \ endif
augroup end
" ---
augroup writer_filetype
    autocmd!
    autocmd FileType plaintex setfiletype=tex
    autocmd FileType tex,markdown,html,text,scratch
          \ setlocal formatoptions=|
          \ setlocal spell conceallevel=0|
          \ setlocal spelllang=en_us|
          \ setlocal foldmethod=manual|
          \ if !get(b:, 'wrapmotion', 0)|
          \     silent! call <SID>ToggleWM()|
          \ endif
augroup end
" ---
augroup scratchbuffer_autosave
    autocmd!
    autocmd TextChanged,TextChangedI,BufLeave /tmp/scratchbuffer
          \ if &modified && &modifiable|
          \     silent write|
          \ endif
augroup end
" ---
augroup ctags_onsave
    autocmd!
    autocmd BufWritePost *
          \ if filereadable(<SID>RootDir() . '/tags')|
          \     silent! call <SID>CTags()|
          \ endif
augroup end
" ---
augroup viminfo_sync
    autocmd!
    autocmd TextYankPost * silent! wviminfo
augroup end
" ---
augroup exec_cmd
    autocmd!
    for [ft, cmd] in [
          \     ['sh', 'sh'],
          \     ['awk', 'awk -f'],
          \ ]
        execute 'autocmd FileType ' . ft . ' nnoremap <buffer> <leader>x :ExecScript ' . escape(cmd, ' ') . ' %<CR>'
    endfor
augroup end
" }}}




" Commands {{{
command! -nargs=0 CTags call <SID>CTags()
command! -nargs=0 CopyClip call <SID>CopyClip()
command! -nargs=0 PastaClip call <SID>PastaClip()
command! -nargs=0 CleanBuffer call <SID>CleanBuffer()
command! -nargs=+ -complete=shellcmd ExecScript call <SID>ExecScript(<f-args>)
command! -nargs=0 ToggleQF call <SID>ToggleQF()
command! -nargs=0 ToggleFC call <SID>ToggleFC()
command! -nargs=0 ToggleWM call <SID>ToggleWM()
command! -nargs=0 AddLineQF call <SID>AddLineQF()
command! -nargs=0 ResetQF call <SID>ResetQF()
command! -nargs=0 ResetSR call <SID>ResetSR()
command! -nargs=0 ScratchBuffer call <SID>ScratchBuffer()
command! -nargs=0 SSession call <SID>SSession()
command! -nargs=0 OSession call <SID>OSession()
command! -nargs=0 GitDiff call <SID>GitDiff()
" }}}




" Keymaps {{{
nnoremap <silent><C-n> :bnext<CR>
nnoremap <silent><C-p> :bprev<CR>
nnoremap <silent><Tab> :buffer#<CR>
" ---
noremap <silent><C-h> (
noremap <silent><C-l> )
noremap <silent><C-j> }
noremap <silent><C-k> {
" ---
inoremap <silent> <C-c> <Esc>
xnoremap <silent> <C-c> <Esc>
snoremap <silent> <C-c> <Esc>
onoremap <silent> <C-c> <Esc>
" ---
vnoremap <silent>H <gv
vnoremap <silent>L >gv
xnoremap <silent>J :move '>+1<CR>gv=gv
xnoremap <silent>K :move '<-2<CR>gv=gv
" ---
nnoremap <silent>Y y$
nnoremap <silent>ZU :update<BAR>rviminfo<CR>
nnoremap <silent>ZO :tabnew%<CR>
" ---
nnoremap <leader>q :ToggleQF<CR>
nnoremap <leader>w :ToggleWM<CR>
nnoremap <leader>e :ResetSR<CR>
nnoremap <leader>r :ResetQF<CR>
nnoremap <leader>t :CTags<CR>
nnoremap <leader>o :OSession<CR>
nnoremap <leader>p :SSession<CR>
nnoremap <leader>a :AddLineQF<CR>
nnoremap <leader>s :ScratchBuffer<CR>
nnoremap <leader>d :CleanBuffer<CR>
nnoremap <leader>g :GitDiff<CR>
nnoremap <leader>z :ToggleFC<CR>
nnoremap <leader>c :CopyClip<CR>
nnoremap <leader>v :PastaClip<CR>
" }}}

" vim: fdm=marker:sw=2:sts=2:et
