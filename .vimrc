" ------------------------------------------------------------------------------------------------------ dein
" dein.vim settings {{{
" install dir {{{
let s:dein_dir = expand('~/.cache/dein')
let s:dein_repo_dir = s:dein_dir . '/repos/github.com/Shougo/dein.vim'
" }}}

" dein installation check {{{
if &runtimepath !~# '/dein.vim'
  if !isdirectory(s:dein_repo_dir)
    execute '!git clone https://github.com/Shougo/dein.vim' s:dein_repo_dir
  endif
  execute 'set runtimepath^=' . s:dein_repo_dir
endif
" }}}

" begin settings {{{
if dein#load_state(s:dein_dir)
  call dein#begin(s:dein_dir)

  " .toml file
  let s:rc_dir = expand('~/.vim')
  if !isdirectory(s:rc_dir)
    call mkdir(s:rc_dir, 'p')
  endif
  let s:toml = s:rc_dir . '/dein.toml'

  " read toml and cache
  call dein#load_toml(s:toml, {'lazy': 0})

  " end settings
  call dein#end()
  call dein#save_state()
endif
" }}}

" plugin installation check {{{
if dein#check_install()
  call dein#install()
endif
" }}}

" plugin remove check {{{
let s:removed_plugins = dein#check_clean()
if len(s:removed_plugins) > 0
  call map(s:removed_plugins, "delete(v:val, 'rf')")
  call dein#recache_runtimepath()
endif
" }}}

" ------------------------------------------------------------------------------------------------------ general
" 行番号＋相対行番号表示
set nu rnu
" terminalのタイトルセット
set title
" ステータスラインの有効化
set laststatus=2
" ファイル名補間
set wildmenu
"----------------------------------------- tab/indent/space
" tab幅4スペース
set tabstop=4
" tabを半角スペース
set expandtab
" vimが自動で生成するtab幅をスペース4つ文にする
set shiftwidth=4
" 改行時などに自動インデント
set smartindent
" 空白文字の可視化
set list
" 可視化した空白文字の表示形式についてセット
set listchars=tab:»~,trail:~,eol:\ ,extends:»,precedes:«,nbsp:%
"----------------------------------------- cursor
" 矩形選択時に文末以降にも移動できるようにする
set virtualedit=block
" カーソルの回り込みができるようになる（行末で→を押すと、次の行へ）
set whichwrap=b,s,[,],<,>
" バックスペースを、空白、行末、行頭でも使えるようにする
set backspace=indent,eol,start
" 全角文字の幅を2に固定
set ambiwidth=double
"----------------------------------------- search
" インクリメンタル検索
set incsearch
" ハイライト検索
set hlsearch
" 大文字小文字区別せず検索
set ignorecase
" 検索文字列に大文字が含まれていれば区別して検索
set smartcase
" 検索文字列が最後まで行ったら最初に戻る
set wrapscan
"----------------------------------------- etc
" 0で始まる数値を、8進数として扱わないようにする
set nrformats-=octal
" ファイルの保存をしていなくても、べつのファイルを開けるようにする
set hidden
" コマンドラインモードで保存する履歴件数
set history=500
"----------------------------------------- colorscheme
" コメントを濃い緑にする
autocmd ColorScheme * highlight Comment ctermfg=59
" 背景色
autocmd ColorScheme * highlight Normal            ctermbg=none
autocmd ColorScheme * highlight LineNr ctermfg=27 ctermbg=none
" 構文ハイライト有効
syntax on
" カラースキーム設定
colorscheme tender
" 現在の行を強調表示
set cursorline
highlight CursorLine cterm=none ctermfg=none ctermbg=17

" ------------------------------------------------------------------------------------------------------ remap
" 入力モード中のjj->ESC
ino jj <Esc>
" 連続改行
no O o<Esc>
" 数字のインクリメント/デクリメント
nn + <C-a>
nn - <C-x>
" Shift + 矢印でウィンドウサイズを変更
nn <S-Left>  <C-w><
nn <S-Right> <C-w>>
nn <S-Up>    <C-w>-
nn <S-Down>  <C-w>+
" 行をまたがないカーソルの上下移動
nn k gk
nn gk k
nn j gj
nn gj j
" 検索後にジャンプした際に検索単語を画面中央にもってくる
nn n nzz
nn N Nzz
nn * *zz
nn # #zz
nn g* g*zz
nn g# g#zz
" ESCを二回押すことでハイライトを消す
nmap <silent> <Esc><Esc> :nohlsearch<CR>

" ------------------------------------------------------------------------------------------------------ etc
" 前回までのカーソル位置記憶
if has("autocmd")
au BufReadPost * if line("'\"") > 1 && line("'\"") <= line("$") | exe "normal! g`\"" | endif
endif

" 行の折り込み記憶
augroup AutoSaveFolds
  autocmd!
  " view files are about 500 bytes
  " bufleave but not bufwinleave captures closing 2nd tab
  " nested is needed by bufwrite* (if triggered via other autocmd)
  autocmd BufWinLeave,BufLeave,BufWritePost ?* nested silent! mkview!
  autocmd BufWinEnter ?* silent loadview
augroup end
set viewoptions=folds,cursor
set sessionoptions=folds

" ------------------------------------------------------------------------------------------------------ alias
" 行番号＋相対行番号非表示
command Nn set nonu nornu
