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

Plugin 'tpope/vim-sensible'
Plugin 'tpope/vim-characterize'
Plugin 'tpope/vim-fugitive'
Plugin 'tpope/vim-surround'
Plugin 'tpope/vim-unimpaired'
Plugin 'tpope/vim-commentary'
Plugin 'tpope/vim-obsession'
Plugin 'easymotion/vim-easymotion'
Plugin 'haya14busa/incsearch.vim'
Plugin 'haya14busa/incsearch-easymotion.vim'

Plugin 'tommcdo/vim-exchange'

Plugin 'vim-airline/vim-airline'
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

let g:airline_theme='light'
let g:airline#extensions#tabline#enabled = 1
let g:airline#extensions#tabline#left_sep = ''
let g:airline#extensions#tabline#left_alt_sep = ''

Plugin 'majutsushi/tagbar'
Plugin 'mattn/emmet-vim'
Plugin 'pangloss/vim-javascript'
Plugin 'StanAngeloff/php.vim'
Plugin 'tweekmonster/braceless.vim'
Plugin 'chikamichi/mediawiki.vim'
" Plugin 'wlangstroth/vim-racket'
" Plugin 'scribble.vim'
" Plugin 'otherjoel/vim-pollen'
" Plugin 'cespare/vim-toml'
Plugin 'tmux-plugins/vim-tmux'

Plugin 'docker/docker', {'rtp': 'contrib/syntax/vim/', 'name': 'Docker-Syntax'}
" Plugin 'nginx/nginx', {'rtp': 'contrib/vim/', 'name': 'NGINX-Syntax'}
" Plugin 'apple/swift', {'rtp': 'utils/vim/', 'name': 'Swift-Syntax'}

Plugin 'jiangmiao/auto-pairs'
Plugin 'airblade/vim-gitgutter'
Plugin 'bronson/vim-visual-star-search'
Plugin 'mbbill/undotree'

Plugin 'editorconfig/editorconfig-vim'
let gEditor_Config_exclude_patterns = ['fugitive://.*', 'scp://.*']

Plugin 'SirVer/ultisnips'
let g:UltiSnipsSnippetsDir = '~/.vim/ultisnips'
Plugin 'honza/vim-snippets'

"Plugin 'Valloric/YouCompleteMe'
"let g:ycm_collect_identifiers_from_tags_files = 1
"let g:ycm_global_ycm_extra_conf = '~/.vim/bundle/YouCompleteMe/third_party/ycmd/cpp/ycm/.ycm_extra_conf.py'

set background=light
set t_Co=256
Plugin 'NLKNguyen/papercolor-theme'
Plugin 'altercation/vim-colors-solarized'
Plugin 'vim-scripts/CycleColor'

let g:markdown_fenced_languages = ['html', 'python', 'bash=sh']
Plugin 'tpope/vim-markdown'

let NERDTreeSortOrder=[]
let NERDTreeIgnore=['\.o$[[file]]', '\.pyc$[[file]]']
Plugin 'scrooloose/nerdtree'

if executable('ag')
    let g:ackprg = 'ag --vimgrep'
endif
Plugin 'mileszs/ack.vim'

call vundle#end()   " required
filetype plugin indent on
" }}}

" Settings {{{
let g:python_host_prog = '/Users/wolf/.pyenv/versions/nvim2/bin/python'
let g:python3_host_prog = '/Users/wolf/.pyenv/versions/nvim3/bin/python'

set hidden
set showcmd
set hlsearch
set showmatch

set ignorecase      " searches are case-insensitive
set smartcase       " ...unless you actually include capital letters in the search string

set scrolloff=3
set cmdheight=2     " enlarge the command area to two lines
set number          " display line numbers

" statusline {{{
set statusline=%<                           " where to break
set statusline+=%{ObsessionStatus()}        " if Session.vim saving is active
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

" Racket Languages files {{{
augroup filetype_racket_langs
    autocmd!

    "Set syntax for files with these extensions:
    autocmd! BufRead,BufNewFile *.pm set filetype=pollen
    autocmd! BufRead,BufNewFile *.pp set filetype=pollen
    autocmd! BufRead,BufNewFile *.ptree set filetype=pollen
    autocmd! BufRead,BufNewFile *.scrbl set filetype=scribble
    autocmd! BufRead,BufNewFile *.rkt set filetype=racket

    " Suggested editor settings:
    autocmd FileType pollen setlocal wrap      " Soft wrap (don't affect buffer)
    autocmd FileType pollen setlocal linebreak " Wrap on word-breaks only
augroup END
" }}}

" Python files {{{
augroup filetype_python
    autocmd!
    autocmd FileType python BracelessEnable +indent +highlight-cc2 +fold
    autocmd FileType python call tagbar#autoopen(0)
augroup END
" }}}

" C/C++ files {{{
augroup filetype_c
    autocmd!
    autocmd FileType c call tagbar#autoopen(0)
    autocmd FileType cpp call tagbar#autoopen(0)
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

nnoremap <leader>b :set background=dark<cr>
nnoremap <leader>B :set background=light<cr>

" Force saving files that require root permission
cnoremap w!! w !sudo tee > /dev/null %

nnoremap <F1> :NERDTreeToggle<cr>
nnoremap <F5> :UndotreeToggle<cr>

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
