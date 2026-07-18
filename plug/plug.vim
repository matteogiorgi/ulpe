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




" Ctrlp {{{
if &rtp =~ 'ctrlp'
    let g:ctrlp_map = ''
    let g:ctrlp_clear_cache_on_exit = 0
    let g:ctrlp_show_hidden = 0
    let g:ctrlp_custom_ignore = {
          \     'dir': '\v[\/]\.(git|hg|svn|mypy_cache)$',
          \     'file': '\v\.(exe|so|dll)$'
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




" Copilot {{{
if &rtp =~ 'copilot'
    imap <silent><C-s> <Plug>(copilot-suggest)
    imap <silent><C-f> <Plug>(copilot-accept-word)
    imap <silent><C-j> <Plug>(copilot-next)
    imap <silent><C-k> <Plug>(copilot-previous)
    imap <silent><C-l> <Plug>(copilot-accept-line)
endif
"}}}




" Sonokai {{{
if &rtp =~ 'sonokai'
    colorscheme sonokai
endif
"}}}




" Lightline {{{
if &rtp =~ 'lightline'
    set noshowmode
    let g:lightline = {
          \     'colorscheme': 'sonokai',
          \     'active': {
          \         'left': [ [ 'mode', 'paste' ],
          \                   [ 'gitbranch', 'readonly', 'filename', 'modified' ] ],
          \         'right': [ [ 'lineinfo' ],
          \                    [ 'percent' ],
          \                    [ 'filetype', 'charvaluehex' ] ]
          \     },
          \     'component': {
          \         'charvaluehex': '0x%B'
          \     },
          \     'component_function': {
          \         'gitbranch': 'LightlineGitBranch'
          \     },
          \ }
    " ---
    function! LightlineGitBranch() abort
        let l:dir = expand('%:p:h')
        if l:dir !=# get(b:, 'gitbranch_dir', '')
            let b:gitbranch_dir = l:dir
            let l:branch = substitute(system('git -C ' . shellescape(l:dir) . ' rev-parse --abbrev-ref HEAD 2>/dev/null'), '\n', '', '')
            if v:shell_error != 0 || empty(l:branch)
                let b:gitbranch_cache = ''
            else
                let l:dirty = !empty(system('git -C ' . shellescape(l:dir) . ' status --porcelain --untracked-files=no 2>/dev/null')) ? '*' : ''
                let b:gitbranch_cache = ' ' . l:branch . l:dirty
            endif
        endif
        return get(b:, 'gitbranch_cache', '')
    endfunction
    " ---
    augroup lightline_gitbranch
        autocmd!
        autocmd FocusGained,BufEnter * unlet! b:gitbranch_dir
    augroup end
endif
"}}}

" vim: fdm=marker:sw=4:sts=4:et
