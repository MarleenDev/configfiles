" useful commands:
"  HEX edit:                    %!xxd
"  source buffer as vim script: so %

set nocompatible
set nomodeline
set undolevels=1000
set timeoutlen=500  " time in ms for a key sequence to complete
let mapleader="\\"
let maplocalleader="\\"
set langmenu=en_US
let $LANG='en_US'
set encoding=utf8
set guifont=Hack\ Nerd\ Font\ 18
set nobomb  " don't clutter files with unicode BOMs
set hidden
set wildmenu
" set ruler
set title
set lazyredraw  " do not redraw when executing macros
set report=0  " always report changes
set cursorline
set cursorcolumn
set autoread  " auto read files changed only from outside of vim
if has("persistent_undo") && (&undofile)
    set autowriteall    " auto write changes if persistent undo is enabled
endif
set fsync  " sync after write
set confirm  " ask whether to save changed files
set showmode

set spelllang=en
set nospell
if has("autocmd")
    augroup spell
        autocmd!
        "autocmd filetype vim setlocal spell enabled when editing vimrc
    augroup END
endif

set nolist                            " hide unprintable characters
if has("multi_byte")                  " if multi_byte is available,
    set listchars=eol:¬,tab:▸\ ,trail:⌴ " use pretty Unicode unprintable symbols
else                                  " otherwise,
    set listchars=eol:$,tab:>\ ,trail:. " use ASCII characters
endif

" search and replace
set wrapscan    " wrap around when searching
" set incsearch   " show match results while typing search pattern
if (&t_Co > 2 || has("gui_running"))
    set hlsearch  " highlight search terms
endif
" temporarily disable highlighting when entering insert mode
if has("autocmd")
    augroup hlsearch
        autocmd!
        autocmd InsertEnter * let g:restorehlsearch=&hlsearch | :set
        nohlsearch
        autocmd InsertLeave * let &hlsearch=g:restorehlsearch
    augroup END
endif
set ignorecase  " case insensitive search
set smartcase   " case insensitive only if search pattern is all lowercase
                "   (smartcase requires ignorecase)
" set gdefault    " search/replace globally (on a line) by default

" temporarily disable search highlighting
nnoremap <silent> <leader><Space> :nohlsearch<CR>:match none<CR>:2match none<CR>:3match none<CR>

" highlight all instances of the current word where the cursor is positioned
nnoremap <silent> <leader>hs :setl hls<CR>:let @/="\\<<C-r><C-w>\\>"<CR>

" use <leader>h1, <leader>h2, <leader>h3 to highlight words in different colors
nnoremap <silent> <leader>h1 :highlight Highlight1 ctermfg=0 ctermbg=226 guifg=Black guibg=Yellow<CR> :execute 'match Highlight1 /\<<C-r><C-w>\>/'<cr>
nnoremap <silent> <leader>h2 :highlight Highlight2 ctermfg=0 ctermbg=51 guifg=Black guibg=Cyan<CR> :execute '2match Highlight2 /\<<C-r><C-w>\>/'<cr>
nnoremap <silent> <leader>h3 :highlight Highlight3 ctermfg=0 ctermbg=46 guifg=Black guibg=Green<CR> :execute '3match Highlight3 /\<<C-r><C-w>\>/'<cr>

" replace word under cursor
nnoremap <leader>; :%s/\<<C-r><C-w>\>//<Left>

function! BlinkMatch(t)
    let [l:bufnum, l:lnum, l:col, l:off] = getpos('.')
    let l:current = '\c\%#'.@/
    let l:highlight = matchadd('IncSearch', l:current, 1000)
    redraw
    exec 'sleep ' . float2nr(a:t * 1000) . 'm'
    call matchdelete(l:highlight)
    redraw
endfunction

" center screen on next/previous match, blink current match
" noremap <silent> n nzzzv:call BlinkMatch(0.2)<CR>
" noremap <silent> N Nzzzv:call BlinkMatch(0.2)<CR>


" line numbering
set number
set relativenumber  " show relative line numbers
set numberwidth=4   " narrow number column
" cycles between relative / absolute / no numbering
    function! RelativeNumberToggle()
        if (&number == 1 && &relativenumber == 1)
            set nonumber
            set relativenumber relativenumber?
        elseif (&number == 0 && &relativenumber == 1)
            set norelativenumber
            set number number?
        elseif (&number == 1 && &relativenumber == 0)
            set norelativenumber
            set nonumber number?
        else
            set number
            set relativenumber relativenumber?
        endif
    endfunc
" nnoremap <silent> <leader>n :call RelativeNumberToggle()<CR>

" No annoying sound on errors
set noerrorbells
set novisualbell
set t_vb=
set tm=500

" <leader>ev edits .vimrc
nnoremap <leader>ev :vsplit $MYVIMRC<CR>

" <leader>sv sources .vimrc
nnoremap <leader>sv :source $MYVIMRC<CR>:redraw<CR>:echo $MYVIMRC 'reloaded'<CR>

" cd to the directory of the current buffer
nnoremap <silent> <leader>cd :cd %:p:h<CR>

" Properly disable sound on errors on MacVim
if has("gui_macvim")
    autocmd GUIEnter * set vb t_vb=
endif

" Add a bit extra margin to the left
set foldcolumn=1

" Enable 256 colors palette in Gnome Terminal
if $COLORTERM == 'gnome-terminal'
    set t_Co=256
endif

" Configure backspace so it acts as it should act
set backspace=eol,start,indent
set whichwrap+=<,>,h,l

" Ignore compiled files
set wildignore=*.o,*~,*.pyc
set wildmode=longest:full,full
if has("win16") || has("win32")
    set wildignore+=.git\*,.hg\*,.svn\*
else
    set wildignore+=*/.git/*,*/.hg/*,*/.svn/*,*/.DS_Store
endif

" For regular expressions turn magic on
set magic

" Show matching brackets when text indicator is over them
set showmatch
" How many tenths of a second to blink when matching brackets
set mat=2

" save file using sudo when permissions are not sufficient
" command! W execute 'w !sudo tee % > /dev/null' <bar> edit!
cabbrev w!! w !sudo tee % >/dev/null

" OS dependent things
" set an environment var VIMOS in each OS
if has('win32') || has('win64')
    let g:os='windows'
    set rtp+=C:/Users/mvos/vimfiles/bundle
    set rtp+=C:/Users/mvos/vimfiles/bundle/Vundle.vim
elseif has('win32unix')
    let g:os='cygwin'
    set rtp+=~/.vim/
    set rtp+=~/.vim/bundle/Vundle.vim/
elseif has('macunix')
    set pythonthreedll=/opt/homebrew/Cellar/python@3.9/3.9.12/Frameworks/Python.framework/Versions/3.9/lib/python3.9/config-3.9-darwin/libpython3.9.dylib
    let g:os='macosx'
    set rtp+=~/.vim/
    set rtp+=~/.vim/bundle/Vundle.vim/
elseif has('unix')
    let g:os='linux'
    set rtp+=~/.vim/
    set rtp+=~/.vim/bundle/Vundle.vim/
    " copy paste using CTRL-c/x/v
    vmap <C-c> "+yi
    vmap <C-x> "+c
    vmap <C-v> c<ESC>"+p
    imap <C-v> <C-r><C-o>+
endif

" vundle
let path='$HOME/.vim/bundle'
filetype off                   " required
call vundle#begin()            " required
Plugin 'VundleVim/Vundle.vim'  " required
Plugin 'vim-scripts/a.vim'
Plugin 'preservim/nerdtree'
Plugin 'Xuyuanp/nerdtree-git-plugin'
Plugin 'tiagofumo/vim-nerdtree-syntax-highlight'
Plugin 'jlanzarotta/bufexplorer'
Plugin 'octol/vim-cpp-enhanced-highlight'
Plugin 'bfrg/vim-cpp-modern'
Plugin 'altercation/vim-colors-solarized'
Plugin 'kien/ctrlp.vim'
Plugin 'majutsushi/tagbar'
Plugin 'Valloric/YouCompleteMe'
" Plugin 'MarcWeber/vim-addon-mw-utils'  " needed by vim-snipmate
" Plugin 'tomtom/tlib_vim'               " needed by vim-snipmate
" Plugin 'garbas/vim-snipmate'
" Plugin 'hrsh7th/vim-vsnip'
" Plugin 'hrsh7th/vim-vsnip-integ'
" Plugin 'rafamadriz/friendly-snippets'
" Plugin 'pangloss/vim-javascript'
Plugin 'vim-airline/vim-airline'
Plugin 'vim-airline/vim-airline-themes'
" Plugin 'peterhoeg/vim-qml'
Plugin 'severin-lemaignan/vim-minimap'
Plugin 'scrooloose/nerdcommenter'
Plugin 'vim-scripts/DoxygenToolkit.vim'
Plugin 'vim-scripts/SearchComplete'
Plugin 'tpope/vim-surround'
Plugin 'dense-analysis/ale'
Plugin 'preservim/vim-pencil'
Plugin 'bfrg/vim-jq'
Plugin 'tpope/vim-fugitive'
Plugin 'airblade/vim-gitgutter'
Plugin 'mg979/vim-visual-multi'
" Plugin 'prabirshrestha/vim-lsp'
" Plugin 'mattn/vim-lsp-settings'
" Plugin 'prabirshrestha/asyncomplete.vim'
" Plugin 'prabirshrestha/asyncomplete-lsp.vim'
" Plugin 'keith/swift.vim'
" Plugin 'realm/SwiftLint'
" Plugin 'justmao945/vim-clang'
Plugin 'BurntSushi/ripgrep'
Plugin 'junegunn/fzf'
Plugin 'vim-scripts/MultipleSearch'
Plugin 'ryanoasis/vim-devicons'
" themes:
Plugin 'morhetz/gruvbox'
Plugin 'sainnhe/everforest'
call vundle#end()              " required
filetype plugin indent on      " required
" " Brief help
" " :PluginList       - lists configured plugins
" " :PluginInstall    - installs plugins; append `!` to update or just
" :PluginUpdate
" " :PluginSearch foo - searches for foo; append `!` to refresh local cache
" " :PluginClean      - confirms removal of unused plugins; append `!` to
" auto-approve removal
" "
" " see :h vundle for more details or wiki for FAQ

autocmd StdinReadPre * let s:std_in=1
autocmd VimEnter * if argc()==0 && !exists('s:std_in') | NERDTree | endif
autocmd vimenter * ++nested colorscheme gruvbox

" a.ivm
let g:alternateNoDefaultAlternate = 1

" vim-lsp
if executable('sourcekit-lsp')
    au User lsp_setup call lsp#register_server({
        \ 'name': 'sourcekit-lsp',
        \ 'cmd': {server_info->['sourcekit-lsp']},
        \ 'whitelist': ['swift'],
        \ })
endif
autocmd FileType swift setlocal omnifunc=lsp#complete
" enable/disable nvimlsp integration >
  let g:airline#extensions#nvimlsp#enabled = 0
" nvimlsp error_symbol >
  let g:airline#extensions#nvimlsp#error_symbol = 'E:'
" nvimlsp warning - needs v:lua.vim.diagnostic.get
  let g:airline#extensions#nvimlsp#warning_symbol = 'W:'
" nvimlsp show_line_numbers - needs v:lua.vim.diagnostic.get
  let g:airline#extensions#nvimlsp#show_line_numbers = 1
" nvimlsp open_lnum_symbol - needs v:lua.vim.diagnostic.get
  let g:airline#extensions#nvimlsp#open_lnum_symbol = '(L'
" nvimlsp close_lnum_symbol - needs v:lua.vim.diagnostic.get
  let g:airline#extensions#nvimlsp#close_lnum_symbol = ')'

" bufexplorer
"<Leader>be normal open
"<Leader>bt toggle open / close
"<Leader>bs force horizontal split open
"<Leader>bv force vertical split open
let g:bufExplorerDefaultHelp=0
let g:bufExplorerShowRelativePath=1
let g:bufExplorerFindActive=1
let g:bufExplorerSortBy='name'
map <leader>o :BufExplorer<cr>

" tmux integration
" make arrow keys, home/end/pgup/pgdown, and function keys work when inside tmux
if exists('$TMUX') && (system("tmux show-options -wg xterm-keys | cut -d' '-f2") =~ '^on')
    " tmux will send xterm-style keys when its xterm-keys option is on
    " add 'setw -g xterm-keys on' to your ~/.tmux.conf
    execute "set <xUp>=\e[1;*A"
    execute "set <xDown>=\e[1;*B"
    execute "set <xRight>=\e[1;*C"
    execute "set <xLeft>=\e[1;*D"
    execute "set <xHome>=\e[1;*H"
    execute "set <xEnd>=\e[1;*F"
    execute "set <Insert>=\e[2;*~"
    execute "set <Delete>=\e[3;*~"
    execute "set <PageUp>=\e[5;*~"
    execute "set <PageDown>=\e[6;*~"
    execute "set <xF1>=\e[1;*P"
    execute "set <xF2>=\e[1;*Q"
    execute "set <xF3>=\e[1;*R"
    execute "set <xF4>=\e[1;*S"
    execute "set <F5>=\e[15;*~"
    execute "set <F6>=\e[17;*~"
    execute "set <F7>=\e[18;*~"
    execute "set <F8>=\e[19;*~"
    execute "set <F9>=\e[20;*~"
    execute "set <F10>=\e[21;*~"
    execute "set <F11>=\e[23;*~"
    execute "set <F12>=\e[24;*~"
endif

" vim-airline
let g:airline#extensions#ale#enabled=1
let g:airline#extensions#nerdtree_statusline=1
let g:airline#extensions#tabline#formatter = 'default'
let g:airline_experimental=1
let g:airline_solarized_bg='dark'
" let g:airline_left_sep='>'
" let g:airline_right_sep='<'
" let g:airline_detect_modified=1
" let g:airline_detect_paste=1
" let g:airline_inactive_collapse=1
" let g:airline_inactive_alt_sep=1
let g:airline_theme='cobalt2'
let g:airline_powerline_fonts=1
function! WindowNumber(...)
    let builder = a:1
    let context = a:2
    call builder.add_section('airline_b', '%{tabpagewinnr(tabpagenr())}')
    return 0
endfunction
call airline#add_statusline_func('WindowNumber')
call airline#add_inactive_statusline_func('WindowNumber')

" NERDTree
let NERDTreeShowHidden=1   " use I to toggle
let g:WebDevIconsDisableDefaultFolderSymbolColorFromNERDTreeDir = 1
let g:WebDevIconsDisableDefaultFileSymbolColorFromNERDTreeFile = 1
" in case of no devicons:
let g:NERDTreeFileExtensionHighlightFullName = 1
let g:NERDTreeExactMatchHighlightFullName = 1
let g:NERDTreePatternMatchHighlightFullName = 1
" folders
let g:NERDTreeHighlightFolders = 1 " enables folder icon highlighting using exact match
let g:NERDTreeHighlightFoldersFullName = 1 " highlights the folder name
" you can add these colors to your .vimrc to help customizing
let s:brown = "905532"
let s:aqua =  "3AFFDB"
let s:blue = "689FB6"
let s:darkBlue = "44788E"
let s:purple = "834F79"
let s:lightPurple = "834F79"
let s:red = "AE403F"
let s:beige = "F5C06F"
let s:yellow = "F09F17"
let s:orange = "D4843E"
let s:darkOrange = "F16529"
let s:pink = "CB6F6F"
let s:salmon = "EE6E73"
let s:green = "8FAA54"
let s:lightGreen = "31B53E"
let s:white = "FFFFFF"
let s:rspec_red = 'FE405F'
let s:git_orange = 'F54D27'
let g:NERDTreeExtensionHighlightColor = {} " this line is needed to avoid error
let g:NERDTreeExtensionHighlightColor['css'] = s:blue " sets the color of css files to blue
let g:NERDTreeExactMatchHighlightColor = {} " this line is needed to avoid error
let g:NERDTreeExactMatchHighlightColor['.gitignore'] = s:git_orange " sets the color for .gitignore files
let g:NERDTreePatternMatchHighlightColor = {} " this line is needed to avoid error
let g:NERDTreePatternMatchHighlightColor['.*_spec\.rb$'] = s:rspec_red " sets the color for files ending with _spec.rb
let g:WebDevIconsDefaultFolderSymbolColor = s:beige " sets the color for folders that did not match any rule
let g:WebDevIconsDefaultFileSymbolColor = s:blue " sets the color for files that did not match any rule
"nnoremap <leader>n :NERDTreeFocus<CR>
"nnoremap <C-n> :NERDTree<CR>
nnoremap <F2> :NERDTreeToggle<CR>
"nnoremap <C-f> :NERDTreeFind<CR>

" snipmate
let g:snipMate = { 'snippet_version' : 1 }

" NERDCommenter
" Add spaces after comment delimiters by default
let g:NERDSpaceDelims = 1
" Use compact syntax for prettified multi-line comments
let g:NERDCompactSexyComs = 1
" Align line-wise comment delimiters flush left instead of following code indentation
let g:NERDDefaultAlign = 'left'
" Set a language to use its alternate delimiters by default
let g:NERDAltDelims_java = 1
" Add your own custom formats or override the defaults
let g:NERDCustomDelimiters = { 'c': { 'left': '/**','right': '*/' } }
" Allow commenting and inverting empty lines (useful when commenting a region)
let g:NERDCommentEmptyLines = 1
" Enable trimming of trailing whitespace when uncommenting
let g:NERDTrimTrailingWhitespace = 1

" cpp enhanced highlight
let g:cpp_class_scope_highlight = 1
let g:cpp_member_variable_highlight = 1
let g:cpp_class_decl_highlight = 1
" let g:cpp_experimental_simple_template_highlight = 1
let g:cpp_experimental_template_highlight = 1
" let g:cpp_concepts_highlight = 1
let g:cpp_no_function_highlight = 1

" scrollbar
let g:scrollbar_thumb='#'
let g:scrollbar_clear='|'
highlight Scrollbar_Clear ctermfg=green ctermbg=black guifg=green guibg=black cterm=none
highlight Scrollbar_Thumb ctermfg=darkgreen ctermbg=darkgreen guifg=darkgreen guibg=darkgreen cterm=reverse

" tagbar
nmap <F4> :TagbarToggle<CR>
"if has('gui_running')
  if g:os=='windows'
    let g:tagbar_ctags_bin='d:\dev\utils\ctags.exe'
  elseif g:os=='cygwin'
  elseif g:os=='macosx'
  elseif g:os=='linux'
    let g:tagbar_ctags_bin='/usr/local/bin/ctags'
  endif
"endif

" tags
if g:os=='windows'
    set tags=d:/dev/tags_delirium_win
    set tags+=d:/dev/tags_cpp_win
    set tags+=d:/dev/tags_qt59_win
elseif g:os=='cygwin'
    set tags=/d/dev/tags_delirium
    set tags+=/d/dev/tags_cpp
    set tags+=/d/dev/tags_qt59
elseif g:os=='macosx'
elseif g:os=='linux'
    set tags=./tags
  "set tags+=/home/marleenvos/dev/projects/ldd3_yocto/sources/ldd3/TAGS
  "set tags+=/home/marleenvos/dev/repos/linux/TAGS
  "set tags+=/home/marleenvos/dev/repos/bluez/tags
  "set tags+=/usr/include/glib-2.0/tags
endif

" clang
if g:os=='windows'
    let g:clang_exec='C:\Program Files\LLVM\bin\clang.exe'
    let g:clang_library_path='C:\Program Files\LLVM\bin\libclang.dll'
elseif g:os=='cygwin'
    let g:clang_library_path='/cygdrive/c/Program Files/LLVM/bin/libclang.dll'
    let g:clang_exec='/usr/bin/clang'
endif

" CtrlP plugin
" :help ctrlp-commands and :help ctrlp-extensions
let g:ctrlp_map = '<c-p>'
let g:ctrlp_cmd = 'CtrlP'
let g:ctrlp_working_path_mode = 'ra'
set wildignore+=*/tmp/*,*.so,*.swp,*.zip     " MacOSX/Linux
set wildignore+=*\\tmp\\*,*.swp,*.zip,*.exe  " Windows
let g:ctrlp_custom_ignore = '\v[\/]\.(git|hg|svn)$'
let g:ctrlp_custom_ignore = {
  \ 'dir':  '\v[\/]\.(git|hg|svn)$',
  \ 'file': '\v\.(exe|so|dll)$',
  \ 'link': 'some_bad_symbolic_links',
  \ }
" let g:ctrlp_working_path_mode = 0
" " Quickly find and open a file in the current working directory
" let g:ctrlp_map = '<C-f>'
" map <leader>j :CtrlP<cr>
" " Quickly find and open a buffer
" map <leader>b :CtrlPBuffer<cr>
" let g:ctrlp_max_height = 20
" let g:ctrlp_custom_ignore = 'node_modules\|^\.DS_Store\|^\.git\|^\.coffee'

" multiple cursors:
let g:multi_cursor_use_default_mapping=0
" Default mapping
let g:multi_cursor_start_word_key      = '<C-s>'
let g:multi_cursor_select_all_word_key = '<A-s>'
let g:multi_cursor_start_key           = 'g<C-s>'
let g:multi_cursor_select_all_key      = 'g<A-s>'
let g:multi_cursor_next_key            = '<C-s>'
let g:multi_cursor_prev_key            = '<C-p>'
let g:multi_cursor_skip_key            = '<C-x>'
let g:multi_cursor_quit_key            = '<Esc>'

" general stuff
syntax enable
set expandtab
set tabstop=4
set softtabstop=4
set shiftwidth=4
set autoindent
set copyindent
set shiftround   " use multiple of shiftwidth when indenting with '<' and '>'
set smarttab
set hlsearch
set nowrap
set linebreak
set nojoinspaces  " compact space when joining lines
set colorcolumn=110
highlight ColorColumn ctermbg=darkgray

" make Y consistent with C and D by yanking up to end of line
noremap Y y$

if has("autocmd")
    augroup makefile
        autocmd!
        " don't expand tab to space in Makefiles
        autocmd filetype make setlocal noexpandtab
    augroup END
endif

function! Preserve(command)
  let l:search=@/
  let l:line = line(".")
  let l:col = col(".")
  execute a:command
  let @/=l:search
  call cursor(l:line, l:col)
endfunction

" <leader>rt retabs the file, preserve cursor position
nnoremap <silent> <leader>rt :call Preserve(":retab")<CR>

" <leader>s removes trailing spaces
noremap <silent> <leader>s :call Preserve("%s/\\s\\+$//e")<CR>

" <leader>$ fixes mixed EOLs (^M)
noremap <silent> <leader>$ :call Preserve("%s/<C-V><CR>//e")<CR>

" use <leader>d to delete a line without adding it to the yanked stack
nnoremap <silent> <leader>d "_d
vnoremap <silent> <leader>d "_d

" use <leader>c to replace text without yanking replaced text
nnoremap <silent> <leader>c "_c
vnoremap <silent> <leader>c "_c

" yank/paste to/from the OS clipboard
noremap <silent> <leader>y "+y
noremap <silent> <leader>Y "+Y
noremap <silent> <leader>p "+p
noremap <silent> <leader>P "+P

" paste without yanking replaced text in visual mode
vnoremap <silent> p "_dP
vnoremap <silent> P "_dp

set showmatch     " briefly jumps the cursor to the matching brace on insert
set matchtime=4   " blink matching braces for 0.4s
set matchpairs+=<:>         " make < and > match
runtime macros/matchit.vim  " enable extended % matching

" make dot work in visual mode
vnoremap . :normal .<CR>

" backup and swap files
set backup
set writebackup
set swapfile
let s:vimdir=$HOME . "/.vim"
let &backupdir=s:vimdir . "/backup"  " backups location
let &directory=s:vimdir . "/tmp"     " swap location
if exists("*mkdir")
    if !isdirectory(s:vimdir)
        call mkdir(s:vimdir, "p")
    endif
    if !isdirectory(&backupdir)
        call mkdir(&backupdir, "p")
    endif
    if !isdirectory(&directory)
        call mkdir(&directory, "p")
    endif
endif
set backupskip+=*.tmp " skip backup for *.tmp
if has("persistent_undo")
      let &undodir=&backupdir
        set undofile  " enable persistent undo
endif
let &viminfo=&viminfo . ",n" . s:vimdir . "/.viminfo" " viminfo location

" solarized
set background=dark
let g:solarized_termcolors=256
let g:solarized_termtrans=1
"colorscheme solarized
"colorscheme gruvbox
colorscheme everforest
if has('gui_running')
    if (has("termguicolors"))
        set termguicolors
    endif
    set lines=60 columns=120
    " set guioptions-=T
    " set guioptions-=e
    " set t_Co=256
    " set guitablabel=%M\ %t
endif

" Use Unix as the standard file type
set ffs=unix,dos,mac

" persistent undo
try
    set undodir=~/.vim_runtime/undodir
    set undofile
catch
endtry

" Visual mode pressing * or # searches for the current selection
vnoremap <silent> * :<C-u>call VisualSelection('', '')<CR>/<C-R>=@/<CR><CR>
vnoremap <silent> # :<C-u>call VisualSelection('', '')<CR>?<C-R>=@/<CR><CR>

" Smart way to move between windows
map <C-j> <C-W>j
map <C-k> <C-W>k
map <C-h> <C-W>h
map <C-l> <C-W>l

" Disable highlight when <leader><cr> is pressed
map <silent> <leader><cr> :noh<cr>

" Close the current buffer
map <leader>bd :Bclose<cr>:tabclose<cr>gT

" Close all the buffers
map <leader>ba :bufdo bd<cr>

map <leader>l :bnext<cr>
map <leader>h :bprevious<cr>

" Useful mappings for managing tabs
map <leader>tn :tabnew<cr>
map <leader>to :tabonly<cr>
map <leader>tc :tabclose<cr>
map <leader>tm :tabmove
map <leader>t<leader> :tabnext<cr>

" Let 'tl' toggle between this and the last accessed tab
let g:lasttab = 1
nmap <leader>tl :exe "tabn ".g:lasttab<CR>
au TabLeave * let g:lasttab = tabpagenr()

" Pressing <leader>ss will toggle spell checking
map <leader>ss :setlocal spell!<cr>

" Remove the Windows ^M - when the encodings gets messed up
noremap <Leader>m mmHmt:%s/<C-V><cr>//ge<cr>'tzt'm

" Quickly open a buffer for scribble
map <leader>q :e ~/buffer<cr>

" Quickly open a markdown buffer for scribble
map <leader>x :e ~/buffer.md<cr>

" Toggle paste mode on and off
map <leader>pp :setlocal paste!<cr>

" Opens a new tab with the current buffer's path
" Super useful when editing files in the same directory
map <leader>te :tabedit <C-r>=escape(expand("%:p:h"), " ")<cr>/

" Switch CWD to the directory of the open buffer
map <leader>cd :cd %:p:h<cr>:pwd<cr>

" Specify the behavior when switching between buffers
try
  set switchbuf=useopen,usetab,newtab
  set stal=2
catch
endtry

" Return to last edit position when opening files (You want this!)
au BufReadPost * if line("'\"") > 1 && line("'\"") <= line("$") | exe "normal! g'\"" | endif

" " Set font according to system
" if has("mac") || has("macunix")
    " set gfn=IBM\ Plex\ Mono:h14,Hack:h14,Source\ Code\ Pro:h15,Menlo:h15
" elseif has("win16") || has("win32")
    " set gfn=IBM\ Plex\ Mono:h14,Source\ Code\ Pro:h12,Bitstream\ Vera\ Sans\ Mono:h11
" elseif has("gui_gtk2")
    " set gfn=IBM\ Plex\ Mono\ 14,:Hack\ 14,Source\ Code\ Pro\ 12,Bitstream\ Vera\ Sans\ Mono\ 11
" elseif has("linux")
    " set gfn=IBM\ Plex\ Mono\ 14,:Hack\ 14,Source\ Code\ Pro\ 12,Bitstream\ Vera\ Sans\ Mono\ 11
" elseif has("unix")
    " set gfn=Monospace\ 11
" endif

" minimap
let g:minimap_show='<leader>ms'
let g:minimap_update='<leader>mu'
let g:minimap_close='<leader>gc'
let g:minimap_toggle='<leader>gt'
let g:minimap_highlight='Visual'

" JSON beautifier
nmap <leader>jq :%!jq<CR>

" ALE linter
" let g:ale_linters = {
" \   'javascript': ['eslint'],
" \   'python': ['flake8'],
" \   'go': ['go', 'golint', 'errcheck']
" \}
" nmap <silent> <leader>a <Plug>(ale_next_wrap)
" " Disabling highlighting
" let g:ale_set_highlights = 0
" " Only run linting when saving the file
" let g:ale_lint_on_text_changed = 'never'
" let g:ale_lint_on_enter = 0
" let g:ale_virtualtext_cursor = 'disabled'

" git gutter
let g:gitgutter_enabled=0
nnoremap <silent> <leader>d :GitGutterToggle<cr>

" fugitive
" Copy the link to the line of a Git repository to the clipboard
nnoremap <leader>v :.GBrowse!<CR>
xnoremap <leader>v :GBrowse!<CR>

" => Parenthesis/bracket
vnoremap $1 <esc>`>a)<esc>`<i(<esc>
vnoremap $2 <esc>`>a]<esc>`<i[<esc>
vnoremap $3 <esc>`>a}<esc>`<i{<esc>
vnoremap $$ <esc>`>a"<esc>`<i"<esc>
vnoremap $q <esc>`>a'<esc>`<i'<esc>
vnoremap $e <esc>`>a`<esc>`<i`<esc>
" Map auto complete of (, ", ', [
inoremap $1 ()<esc>i
inoremap $2 []<esc>i
inoremap $3 {}<esc>i
inoremap $4 {<esc>o}<esc>O
inoremap $q ''<esc>i
inoremap $e ""<esc>i

" compiling
map <F5> :call CompileRun()<CR>
imap <F5> <Esc>:call CompileRun()<CR>
vmap <F5> <Esc>:call CompileRun()<CR>
func! CompileRun()
exec "w"
if &filetype == 'c'
    exec "!gcc % -o %<"
    exec "!time ./%<"
elseif &filetype == 'cpp'
    exec "!g++ % -o %<"
    exec "!time ./%<"
elseif &filetype == 'java'
    exec "!javac %"
    exec "!time java %"
elseif &filetype == 'sh'
    exec "!time bash %"
elseif &filetype == 'python'
    exec "!time python3 %"
elseif &filetype == 'html'
    exec "!google-chrome % &"
elseif &filetype == 'go'
    exec "!go build %<"
    exec "!time go run %"
elseif &filetype == 'matlab'
    exec "!time octave %"
endif
endfunc

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" => Helper functions
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Returns true if paste mode is enabled
function! HasPaste()
    if &paste
        return 'PASTE MODE  '
    endif
    return ''
endfunction

" Don't close window, when deleting a buffer
command! Bclose call <SID>BufcloseCloseIt()
function! <SID>BufcloseCloseIt()
    let l:currentBufNum = bufnr("%")
    let l:alternateBufNum = bufnr("#")

    if buflisted(l:alternateBufNum)
        buffer #
    else
        bnext
    endif

    if bufnr("%") == l:currentBufNum
        new
    endif

    if buflisted(l:currentBufNum)
        execute("bdelete! ".l:currentBufNum)
    endif
endfunction

function! CmdLine(str)
    call feedkeys(":" . a:str)
endfunction

function! VisualSelection(direction, extra_filter) range
    let l:saved_reg = @"
    execute "normal! vgvy"

    let l:pattern = escape(@", "\\/.*'$^~[]")
    let l:pattern = substitute(l:pattern, "\n$", "", "")

    if a:direction == 'gv'
        call CmdLine("Ack '" . l:pattern . "' " )
    elseif a:direction == 'replace'
        call CmdLine("%s" . '/'. l:pattern . '/')
    endif

    let @/ = l:pattern
    let @" = l:saved_reg
endfunction
