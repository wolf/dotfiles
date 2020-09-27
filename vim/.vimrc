set encoding=utf-8
set fileencoding=utf-8

set nocompatible    " this is Vim, not vi, so act like it

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
" }}}

" Special effects {{{
Plugin 'machakann/vim-highlightedyank'
let g:highlightedyank_highlight_duration = 450
" }}}

" Language support {{{
Plugin 'tweekmonster/braceless.vim'
" }}}

" Experimental {{{
if !has('win32')
    " These are too hard to keep running on Windows
    Plugin 'ervandew/supertab'
    Plugin 'Valloric/YouCompleteMe'
    Plugin 'SirVer/ultisnips'
    Plugin 'honza/vim-snippets'
    let g:SuperTabDefaultCompletionType = '<C-n>'
    let g:SuperTabCrMapping = 0
    let g:ycm_extra_conf_globlist = ['~/work/*']
    let g:ycm_key_list_select_completion = ['<C-j>', '<C-n>', '<Down>']
    let g:ycm_key_list_previous_completion = ['<C-k>', '<C-p>', '<Up>']
    let g:UltiSnipsExpandTrigger = '<Tab>'
    let g:UltiSnipsJumpForwardTrigger = '<Tab>'
    let g:UltiSnipsJumpBackwardTrigger = '<S-Tab>'
endif

Plugin 'tpope/vim-repeat'
Plugin 'easymotion/vim-easymotion'
" }}}

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

set background=light
set t_Co=256
Plugin 'NLKNguyen/papercolor-theme'

call vundle#end()   " required
filetype plugin indent on
" }}}

" Settings {{{
let g:python_host_prog = '/Users/wolf/.pyenv/versions/nvim2/bin/python'
let g:python3_host_prog = '/Users/wolf/.pyenv/versions/nvim3/bin/python'

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
if has('nvim')
    set clipboard=unnamedplus
else
    set clipboard=autoselect
endif
set guioptions+=a
set cursorline

set shiftwidth=4
set softtabstop=4
set expandtab
set nomodeline
" }}}

" All files {{{
augroup open_and_close
    autocmd!
    " Show the cursorline in the active window when _not_ in insert mode
    autocmd InsertLeave,WinEnter * set cursorline
    autocmd InsertEnter,WinLeave * set nocursorline

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

" Markdown files {{{
augroup filetype_markdown
    autocmd!
    autocmd BufNewFile,BufReadPost *.md set filetype=markdown
augroup END
" }}}

" Python files {{{
augroup filetype_python
    autocmd!
    autocmd! BufRead,BufNewFile *.ipy set filetype=python
    autocmd FileType python BracelessEnable +indent +highlight-cc2 +fold
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

let mapleader = "\<space>"
let maplocalleader = "\\"

nnoremap <silent> <C-L> :nohlsearch<cr>

" Edit my ~/.vimrc in a new tab, source it
nnoremap <silent> <leader>ev :tabnew $HOME/.vimrc<cr>
nnoremap <silent> <leader>sv :source $HOME/.vimrc<cr>
if has('gui')
    nnoremap <silent> <leader>eg :tabnew $MYGVIMRC<cr>
    nnoremap <silent> <leader>sg :source $MYGVIMRC<cr>
endif

" Insert Time/Date-stamp
inoremap <F2> <C-r>=strftime('%c')<cr>

" Highlight whitespace errors, clear highlighting
nnoremap <leader>w :2match Error /\v\s+$/<cr>
nnoremap <leader>W :2match none<cr>

" Toggle relative line numbers for easier motion math
nnoremap <leader>r :set relativenumber!<cr>
" Toggle list view
nnoremap <leader>l :set list!<cr>
set listchars=tab:>\ ,trail:-,extends:>,precedes:<,nbsp:+,eol:$

" Force saving files that require root permission
cnoremap w!! w !sudo tee > /dev/null %

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

" terminal and colorscheme properties {{{
if &term =~? 'cygwin'
    colorscheme peachpuff
elseif has('mac') || &term !~? '^screen'
    colorscheme PaperColor
    " must come after setting the colorscheme
    highlight HighlightedyankRegion guifg=Black guibg=Yellow
else
    colorscheme peachpuff
endif

if !has('nvim') && &term !~ 'builtin_gui'
    set ttymouse=xterm2
endif
" }}}

if has('persistent_undo')
    set undodir=~/.vim/undo/
    set undofile
endif
