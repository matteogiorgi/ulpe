" plug.vim
" --------
" Vim script containing extra settings,
" keymaps and few plugins configuration.




" Init {{{
if exists('g:uplug') || !exists('g:ubase') || v:version < 900
    finish
endif
let g:uplug = 1
"}}}




" Formatters {{{
function! s:Formatter(bin, cmd) abort
    if executable(a:bin)
        silent! update
        execute 'silent! !' . a:cmd . ' % >/dev/null 2>&1'
        redraw!|redrawstatus!|redrawtabline
        echo 'buffer formatted'
        return
    endif
    CleanBuffer
endfunction
" ---
augroup language_cmd
    autocmd FileType python nnoremap <buffer> <silent><leader>d :call <SID>Formatter('black', 'black')<CR>
    autocmd FileType python nnoremap <buffer> <silent><leader>x :ExecScript terminal\ ++curwin\ python3 %<CR>
augroup end
" ---
augroup language_doc
    autocmd FileType python nnoremap <buffer> <silent>K :KeywordLookup<CR>
    autocmd FileType python setlocal keywordprg=pydoc
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
              \     nmap <buffer> <silent><leader>f :CtrlP<space>%:p:h<CR>|
              \ endif
    augroup end
    " ---
    nnoremap <silent><leader>u :CtrlPQuickfix<CR>
    nnoremap <silent><leader>i :CtrlPChangeAll<CR>
    nnoremap <silent><leader>f :CtrlP<space>%:p:h<CR>
    nnoremap <silent><leader>h :CtrlPMRUFiles<CR>
    nnoremap <silent><leader>j :CtrlPBuffer<CR>
    nnoremap <silent><leader>k :CtrlPTag<CR>
    nnoremap <silent><leader>l :CtrlPLine<CR>
endif
" }}}




" Sandwich {{{
if &rtp =~ 'sandwich'
    runtime macros/sandwich/keymap/surround.vim
endif
"}}}




" Sonokai {{{
if &rtp =~ 'sonokai'
    colorscheme sonokai
endif
"}}}

" vim: fdm=marker:sw=4:sts=4:et
