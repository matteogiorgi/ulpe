" plug.vim
" --------
" Vim script containing extra settings,
" keymaps and few plugins configuration.




" Init {{{
if exists('g:plugme')
    finish
endif
let g:plugme = 1
"}}}




" Formatters {{{
function! s:Formatter(bin, cmd) abort
    if executable(a:bin)
        silent! update
        execute 'silent! !' . a:cmd . ' % >/dev/null 2>&1'
        redraw! | redrawstatus! | redrawtabline
    elseif exists(':CleanBuffer')
        CleanBuffer
    else
        silent! update
    endif
    echo 'buffer cleaned'
endfunction
" ---
augroup python_cmd
    autocmd!
    autocmd FileType python command! -buffer -bar -nargs=0 Black call <SID>Formatter('black', 'black')
    autocmd FileType python nnoremap <buffer> <leader>d :Black<CR>
    autocmd FileType python nnoremap <buffer> <leader>x :ExecScript python3 %<CR>
augroup end
" ---
augroup javascript_cmd
    autocmd!
    autocmd FileType javascript command! -buffer -bar -nargs=0 Prettier call <SID>Formatter('prettier', 'prettier --write --tab-width 4 --print-width 120')
    autocmd FileType javascript nnoremap <buffer> <leader>d :Prettier<CR>
    autocmd FileType javascript nnoremap <buffer> <leader>x :ExecScript node %<CR>
augroup end
" ---
augroup go_cmd
    autocmd!
    autocmd FileType go command! -buffer -bar -nargs=0 GoFmt call <SID>Formatter('gofmt', 'gofmt -w')
    autocmd FileType go nnoremap <buffer> <leader>d :GoFmt<CR>
    autocmd FileType go nnoremap <buffer> <leader>x :ExecScript go\ run %:p:h<CR>
augroup end
" }}}




" Ctrlp {{{
if &rtp =~ 'ctrlp'
    let g:ctrlp_map = ''
    let g:ctrlp_clear_cache_on_exit = 0
    let g:ctrlp_show_hidden = 0
    let g:ctrlp_custom_ignore = {
          \      'dir': '\v[\/]\.(git|hg|svn|mypy_cache)$',
          \      'file': '\v\.(exe|so|dll)$'
          \ }
    " ---
    augroup netrw_prettyfier
        autocmd FileType netrw
              \ if g:loaded_ctrlp == 1|
              \     nmap <buffer> <leader>f :CtrlP<space>%:p:h<CR>|
              \ endif
    augroup end
    " ---
    nnoremap <leader>u :CtrlPQuickfix<CR>
    nnoremap <leader>i :CtrlPChangeAll<CR>
    nnoremap <leader>f :CtrlP<space>%:p:h<CR>
    nnoremap <leader>h :CtrlPMRUFiles<CR>
    nnoremap <leader>j :CtrlPBuffer<CR>
    nnoremap <leader>k :CtrlPTag<CR>
    nnoremap <leader>l :CtrlPLine<CR>
endif
" }}}




" Sandwich {{{
if &rtp =~ 'sandwich'
    runtime macros/sandwich/keymap/surround.vim
endif
"}}}

" vim: fdm=marker:sw=2:sts=2:et
