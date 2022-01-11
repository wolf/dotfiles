set encoding=utf-8
set fileencoding=utf-8

set nocompatible    " this is Vim, not vi, so act like it

" Set <Leader> before anything references it
let mapleader = "\<Space>"
let maplocalleader = "\\"

" Plugins {{{
filetype off        " required by Vundle

" set the runtime path to include Vundle and intitialize
set rtp+=~/.vim/bundle/Vundle.vim
call vundle#begin()
" alternatively, pass a path where Vundle should install plugins
"call vundle#begin('~/some/path/here')

" let Vundle manage Vundle, required
Plugin 'VundleVim/Vundle.vim'

" Basics {{{
Plugin 'tpope/vim-sensible'
Plugin 'tpope/vim-fugitive'
Plugin 'airblade/vim-gitgutter'
Plugin 'jiangmiao/auto-pairs'
Plugin 'tpope/vim-surround'
Plugin 'tommcdo/vim-exchange'
Plugin 'tpope/vim-commentary'
Plugin 'tpope/vim-capslock'
Plugin 'tpope/vim-repeat'
Plugin 'tpope/vim-eunuch'
Plugin 'tpope/vim-abolish'
Plugin 'tpope/vim-unimpaired'
" }}}

" Navigation {{{
" Within a file...
Plugin 'justinmk/vim-sneak'
Plugin 'haya14busa/incsearch.vim'
Plugin 'easymotion/vim-easymotion'
Plugin 'haya14busa/incsearch-easymotion.vim'

" Between files...
Plugin 'junegunn/fzf'
Plugin 'junegunn/fzf.vim'
Plugin 'preservim/nerdtree'

if !has('win32') && !has('win32unix')
    " Between notes...
    Plugin 'alok/notational-fzf-vim'
    let g:nv_search_paths = ['~/Vaults/Notes', './notes']
    let g:nv_create_note_window = 'split'
endif
" }}}

" Autocomplete and friends {{{
if !has('win32') && !has('win32unix')
    " Yeah.  Even with Python3, this stuff has trouble on Windows.
    Plugin 'ervandew/supertab'
    Plugin 'Valloric/YouCompleteMe'
    Plugin 'SirVer/ultisnips'
    Plugin 'honza/vim-snippets'
    let g:SuperTabDefaultCompletionType = '<C-N>'
    let g:SuperTabCrMapping = 0
    " let g:ycm_extra_conf_globlist = ['~/work/*']
    " let g:ycm_key_list_select_completion = ['<C-J>', '<C-N>', '<Down>']
    " let g:ycm_key_list_previous_completion = ['<C-K>', '<C-P>', '<Up>']
    let g:UltiSnipsExpandTrigger = '<Tab>'
    let g:UltiSnipsJumpForwardTrigger = '<Tab>'
    let g:UltiSnipsJumpBackwardTrigger = '<S-Tab>'
endif

Plugin 'mattn/emmet-vim'
" }}}

" Experimental {{{
" ...that is, plugins I don't know that I will keep

Plugin 'inkarkat/vim-visualrepeat'
Plugin 'inkarkat/vim-ingo-library'
Plugin 'inkarkat/vim-ReplaceWithRegister'
Plugin 'inkarkat/vim-ReplaceWithSameIndentRegister'

Plugin 'michaeljsmith/vim-indent-object'

Plugin 'prettier/vim-prettier'
Plugin 'scrooloose/syntastic'

" let g:ale_disable_lsp = 1
Plugin 'dense-analysis/ale'
let g:ale_linters = {
\    'python': ['flake8', 'mypy', 'pyright']
\}
let g:ale_linters_explicit = 1

if has('python3')
    Plugin 'python-mode/python-mode'
    let g:pymode_options_max_line_length = 120
    let g:pymode_lint_options_pep8 = {'max_line_length': g:pymode_options_max_line_length}
    let g:pymode_options_colorcolumn = 1
endif

Plugin 'pangloss/vim-javascript'
Plugin 'HerringtonDarkholme/yats.vim'
Plugin 'Xuyuanp/nerdtree-git-plugin'
let g:NERDTreeGitStatusIndicatorMapCustom = {
    \ 'Modified'    :'*',
    \ 'Staged'      :'+',
    \ 'Untracked'   :'%',
    \ 'Renamed'     :'➜',
    \ 'Unmerged'    :'=',
    \ 'Deleted'     :'-',
    \ 'Dirty'       :'.',
    \ 'Ignored'     :'!',
    \ 'Clean'       :'✔︎',
    \ 'Unknown'     :'?',
    \ }

Plugin 'editorconfig/editorconfig-vim'
let g:EditorConfig_exclude_patterns = ['fugitive://.*']

Plugin 'nelstrom/vim-visual-star-search'
Plugin 'mg979/vim-visual-multi'
" }}}

" Temporary {{{
" ...not experimental because I know I will be ditching these when I'm done
Plugin 'chikamichi/mediawiki.vim'
" }}}

" Visual effects {{{
Plugin 'machakann/vim-highlightedyank'
let g:highlightedyank_highlight_duration = 450

set background=light
set t_Co=256
Plugin 'NLKNguyen/papercolor-theme'

" Airline {{{
Plugin 'vim-airline/vim-airline'
let g:airline#extensions#fzf#enabled = 0

Plugin 'vim-airline/vim-airline-themes'

if !exists('g:airline_symbols')
    let g:airline_symbols = {}
endif

" powerline symbols
let g:airline_left_sep = ''
let g:airline_left_alt_sep = ''
let g:airline_right_sep = ''
let g:airline_right_alt_sep = ''
let g:airline_symbols.branch = ''
let g:airline_symbols.readonly = ''
let g:airline_symbols.linenr = '☰'
let g:airline_symbols.maxlinenr = ''

let g:airline_theme='papercolor'
let g:airline#extensions#tabline#enabled = 1
let g:airline#extensions#tabline#left_sep = ''
let g:airline#extensions#tabline#left_alt_sep = ''
" }}}
" }}}

" Language support {{{
Plugin 'tpope/vim-endwise'
Plugin 'tweekmonster/braceless.vim'
let g:braceless_line_continuation = 0
" }}}

call vundle#end()   " required
filetype plugin indent on
" }}}

" Terminal and colorscheme properties {{{
" See https://stackoverflow.com/a/44102038/908269
function! GetColorSchemes()
    return uniq(sort(map(
    \   globpath(&runtimepath, "colors/*.vim", 0, 1),
    \   'fnamemodify(v:val, ":t:r")'
    \)))
endfunction

let s:schemes = GetColorSchemes()
if index(s:schemes, 'PaperColor') >= 0
    colorscheme PaperColor
else
    colorscheme peachpuff
endif

if !has('nvim') && &term !~ 'builtin_gui'
    set ttymouse=xterm2
endif

" Set the cursor shape appropriately, see https://vim.fandom.com/wiki/Change_cursor_shape_in_different_modes
if has('mac')
    if &term !~? 'screen'
        " for iTerm
        let &t_SI = "\<Esc>]50;CursorShape=1\x7"
        let &t_SR = "\<Esc>]50;CursorShape=2\x7"
        let &t_EI = "\<Esc>]50;CursorShape=0\x7"
    else
        " for tmux running in iTerm
        let &t_SI = "\<Esc>Ptmux;\<Esc>\<Esc>]50;CursorShape=1\x7\<Esc>\\"
        let &t_SR = "\<Esc>Ptmux;\<Esc>\<Esc>]50;CursorShape=2\x7\<Esc>\\"
        let &t_EI = "\<Esc>Ptmux;\<Esc>\<Esc>]50;CursorShape=0\x7\<Esc>\\"
    endif
endif
" }}}

" Settings {{{
if has('nvim')
    let g:python3_host_prog = '~/.pyenv/versions/nvim/bin/python'
endif

set pyxversion=3

set hidden
set showcmd
set showmode
set hlsearch
set showmatch
set autoread

set ignorecase      " searches are case-insensitive
set smartcase       " ...unless you actually include capital letters in the search string

set scrolloff=3
set cmdheight=2     " enlarge the command area to two lines
set number          " display line numbers

" statusline {{{
set statusline=%<                           " where to break
set statusline+=%f%M%R                      " leafname, modified, read-only
set statusline+=\ %{fugitive#statusline()}  " if in git repo, git info
set statusline+=%=                          " switch to the right side

set statusline+=%y                          " file type, e.g., [markdown]
set statusline+=\ %-14.(%l,%c%)             " like ruler, line, column
set statusline+=\ %P                        " percentage of file shown
" }}}

set splitright      " make splitting act more like one would expect: open new splits to the right
set splitbelow      " ...and/or below the current window

set nostartofline
set confirm
set visualbell
set mouse=a
set notimeout ttimeout ttimeoutlen=200
"set pastetoggle=<F11>
set sessionoptions+=resize,unix,slash
set shortmess-=S

if has('nvim')
    set clipboard=unnamedplus
else
    set clipboard=unnamed
endif

set cpoptions+=>
set cursorline

set shiftwidth=4
set softtabstop=4
set expandtab
" }}}

" FZF behavior {{{
nnoremap <silent> <Leader>o :NERDTreeClose \| FZF<CR>
nnoremap <silent> <Leader>b :Buffers<CR>
nnoremap <silent> <Leader>w :Windows<CR>
nnoremap <silent> <Leader>rg :Rg<CR>

nnoremap <silent> <Leader>nv :NV<CR>
" }}}

" NERDTree behavior {{{
augroup NERDTree_behavior
    autocmd!
"     autocmd StdinReadPre * let s:std_in=1
"     autocmd VimEnter * if argc() == 0 && !exists('s:std_in') | NERDTree | endif

    " Exit Vim if NERDTree is the only window left.
    autocmd BufEnter * if tabpagenr('$') == 1 && winnr('$') == 1 && exists('b:NERDTree') && b:NERDTree.isTabTree() |
        \ quit | endif
augroup END

let g:NERDTreeHijackNetrw=1
let g:NERDTreeIgnore=['\.git$[[dir]]', 'node_modules[[dir]]', '__pycache__[[dir]]', '.*venv$[[dir]]']

nnoremap <silent> <Leader>t :NERDTreeToggle<CR>
nnoremap <silent> <Leader>f :NERDTreeFocus<CR>
" }}}

" All files {{{
augroup open_and_close
    autocmd!
    " Show the cursorline in the active window when _not_ in insert mode
    autocmd InsertLeave,WinEnter * set cursorline
    autocmd InsertEnter,WinLeave * set nocursorline

    " Use the current background color
    autocmd VimEnter * set t_ut=

    " When opening a buffer, restore the exact cursor position if it still
    " exists
    autocmd BufReadPost *
        \ if line("'\"") > 1 && line("'\"") <= line("$") |
        \   exe "normal! g`\"" |
        \ endif
augroup END
" }}}

" Vim files {{{
augroup filetype_vim
    autocmd!
    autocmd FileType vim setlocal foldmethod=marker foldlevelstart=0
augroup END

augroup filetype_help
    autocmd!
    autocmd FileType help setlocal scrolloff=0 nonumber
augroup END
" }}}

" Python files {{{
augroup filetype_python
    autocmd!
    autocmd! BufRead,BufNewFile *.ipy set filetype=python
    autocmd FileType python BracelessEnable +indent +highlight-cc2 +fold
augroup END
" }}}

" Bash files {{{
augroup filetype_sh
    autocmd!
    autocmd FileType sh let b:surround_{char2nr("v")} = "\"${\r}\""
    autocmd FileType sh let b:surround_{char2nr("s")} = "\"$(\r)\""
    autocmd FileType sh let b:surround_{char2nr("S")} = "\"$( \r )\""
augroup END
" }}}

" The commit message in Git {{{
augroup filetype_edit_commitmessage
    autocmd!
    autocmd BufEnter COMMIT_EDITMSG call setpos('.', [0, 1, 1, 0])
augroup END
" }}}

" Mappings and abbreviations {{{
iabbrev ehome Wolf@zv.cx
iabbrev ework Wolf@learninga-z.com

nnoremap <silent> <C-L> :nohlsearch<CR>

" Edit my ~/.vimrc in a new tab, source it
nnoremap <silent> <Leader>ev :tabnew $HOME/.vimrc<CR>
nnoremap <silent> <Leader>sv :source $HOME/.vimrc<CR>
if has('gui')
    nnoremap <silent> <Leader>eg :tabnew $MYGVIMRC<CR>
    nnoremap <silent> <Leader>sg :source $MYGVIMRC<CR>
endif

" Whitespace errors {{{
let g:show_whitespace_errors = 0
function! ToggleShowWhitespaceErrors()
    let g:show_whitespace_errors = !g:show_whitespace_errors
    if g:show_whitespace_errors
        :2match Error /\v\s+$/
    else
        :2match none
    endif
endfunction

nnoremap <silent> <Leader>sw :call ToggleShowWhitespaceErrors()<CR>
" }}}

" Toggle relative line numbers for easier motion math
nnoremap <silent> <Leader>rn :set relativenumber!<CR>
" Toggle list view
nnoremap <silent> <Leader>l :set list!<CR>
set listchars=tab:>\ ,trail:-,extends:>,precedes:<,nbsp:+,eol:$

" Act naturally when lines wrap
nnoremap j gj
nnoremap k gk
nnoremap ^ g^
nnoremap 0 g0
nnoremap $ g$
nnoremap gj j
nnoremap gk k
nnoremap g^ ^
nnoremap g$ $
nnoremap g0 0

" Keep the visual selection after in|out-denting
vnoremap > >gv
vnoremap < <gv

" }}}

" Modelines {{{
set modeline

" Append modeline after last line in buffer.
" Use substitute() instead of printf() to handle '%%s' modeline in LaTeX
" files.  See: https://vim.fandom.com/wiki/Modeline_magic
function! AppendModeline()
    let l:modeline = printf(" vim: set ts=%d sw=%d tw=%d %set %sai :",
        \ &tabstop, &shiftwidth, &textwidth, &expandtab ? '' : 'no', &autoindent ? '' : 'no')
    let l:modeline = substitute(&commentstring, "%s", l:modeline, "")
    call append(line("$"), "")
    call append(line("$"), l:modeline)
endfunction

nnoremap <silent> <Leader>ml :call AppendModeline()<CR>

" }}}

" Undo {{{
if has('persistent_undo')
    set undodir=~/.vim/undo/
    set undofile
endif

" }}}


" vim: set ts=4 sw=4 tw=78 et ai :
