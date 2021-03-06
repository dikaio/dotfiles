set nocompatible
filetype off

set rtp+=~/.vim/bundle/Vundle.vim
call vundle#begin()

" Let Vundle manage itself
Plugin 'VundleVim/Vundle.vim'
Plugin 'bling/vim-airline'
Plugin 'ctrlpvim/ctrlp.vim'
Plugin 'ntpeters/vim-better-whitespace'
Plugin 'tpope/vim-fugitive'
Plugin 'slashmili/alchemist.vim'
Plugin 'avakhov/vim-yaml'
Plugin 'vim-ruby/vim-ruby'
Plugin 'joonty/vdebug'
Plugin 'tpope/vim-surround'
Plugin 'tpope/vim-endwise'
Plugin 'lucidstack/hex.vim'
Plugin 'scrooloose/nerdtree'
Plugin 'lambdatoast/elm.vim'
if has('nvim')
    Plugin 'Shougo/deoplete.nvim'
end
Plugin 'isRuslan/vim-es6'
Plugin 'vim-scripts/SyntaxRange'
Plugin 'easymotion/vim-easymotion'
Plugin 'elmcast/elm-vim'
Plugin 'elzr/vim-json'
Plugin 'elixir-lang/vim-elixir'
Plugin 'terryma/vim-multiple-cursors'
Plugin 'morhetz/gruvbox'
Plugin 'wkentaro/conque.vim'
Plugin 'plasticboy/vim-markdown'

call vundle#end()
filetype plugin indent on
syntax on

set laststatus=2

set nocompatible
se nostartofline
set autoindent
set incsearch
set nohlsearch
set fdm=marker
set hlsearch
set wildmenu
set ignorecase
set hidden
set tabstop=4 softtabstop=4 shiftwidth=4 expandtab
set number
set scrolloff=5
set backspace=indent,eol,start

"Restore cursor to file position in previous editing session
""http://vim.wikia.com/wiki/Restore_cursor_to_file_position_in_previous_editing_session
"set viminfo='10,\"100,:20,%,n~/.viminfo
" :help last-position-jump
autocmd BufReadPost * if line("'\"") > 1 && line("'\"") <= line("$") | exe "normal! g`\"" | endif


map <Leader>b :CtrlPBuffer<CR>
let g:ctrlp_working_path_mode = 0
let g:ctrlp_custom_ignore = {
    \ 'dir':  '\v\c(elm-stuff|node_modules|_build|deps|vendor|\.git|\.svn)$',
    \ 'file': '\v\c\.(swf|bak|png|gif|mov|ico|jpg|pdf|jrxml|o)$',
    \}


set background=dark
colorscheme gruvbox
set cursorline
highlight   CursorLine    term=NONE    cterm=bold
set cursorcolumn


" :help last-position-jump
autocmd BufReadPost * if line("'\"") > 1 && line("'\"") <= line("$") | exe "normal! g`\"" | endif

" set 2 space tab for ruby file
autocmd Filetype ruby setlocal ts=2 sw=2 expandtab

" to open quickfix window after running Ggrep
autocmd QuickFixCmdPost *grep* cwindow

"Clear search highlight
nnoremap <C-l> :nohlsearch<CR>

"map jj to go to normal mode
inoremap jj <Esc>

"Kill the opened buffer
nnoremap <C-k> :bd<CR>

"Toggle spell checker
"nnoremap <leader>s :set spell!<CR>

"Clean whitespace at the end of the lines
nnoremap <silent> <Leader><space> :StripWhitespace<CR>

"Break the line from cursor
nnoremap <C-j> i<CR><Esc>

"Jump to home in Vim's command line
cnoremap <C-a>  <Home>

"vimrc config helpers
nnoremap <Leader>e :e ~/.vimrc<CR>
nnoremap <Leader>r :source ~/.vimrc<CR>

"Grep for current word in git
noremap <c-g> :Ggrep <cword><CR>

"\g open Gstate window
nnoremap <Leader>g :Gstatus<CR>

"<UP> goes through the history where starts with text
cnoremap <C-p>  <UP>

"Switch between last buffers
nnoremap <C-\> :e #<CR>

"Switch between last buffers
inoremap <C-\> <Esc>:e #<CR>
