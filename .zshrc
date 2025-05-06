# Source Prezto.
 if [[ -s "${ZDOTDIR:-$HOME}/.zprezto/init.zsh" ]]; then
   source "${ZDOTDIR:-$HOME}/.zprezto/init.zsh"
 fi

#----------------------------------------- export env
# xterm指定
export TERM=xterm-256color
#tz
export TZ=Asia/Tokyo
# WSL上でのscreenのソケット用ディレクトリ指定
export SCREENDIR=$HOME/.screen
# grepの色変更
export GREP_COLOR='01;35'
export GREP_COLORS=mt='01;35'
# python
export PYTHONUTF8=1
export PYTHONDONTWRITEBYTECODE=1
export PYTHONUNBUFFERED=1
export PIP_DISABLE_PIP_VERSION_CHECK=on
export PIP_NO_CACHE_DIR=off

#----------------------------------------- etc
# エイリアス有効化
. ~/.alias
# screen(work)起動
if [ $SHLVL = 1 ];then screen -x work; fi
## Preztoテーマ適用
autoload -Uz promptinit
promptinit
prompt bigfade 17 27 245 111
# time関数の出力フォーマットを変更する
TIMEFMT=$'\n\n========================\nProgram : %J\nCPU     : %P\nuser    : %*Us\nsystem  : %*Ss\ntotal   : %*Es\n========================\n'
# リダイレクトによる上書き禁止を解除
setopt clobber
# CTRL-zでbackgroundに戻る
fancy-ctrl-z () {
  if [[ $#BUFFER -eq 0 ]]; then
    BUFFER="fg"
    zle accept-line
  else
    zle push-input
    zle clear-screen
  fi
}
zle -N fancy-ctrl-z
bindkey '^Z' fancy-ctrl-z

# bindkey
bindkey '^q' backward-word
bindkey '^y' forward-word

# lsカラースキーム
eval $(dircolors -b ~/.dircolors)

#----------------------------------------- git
# git ブランチ名を色付きで表示させるメソッド
function rprompt-git-current-branch {
  local branch_name st branch_status
#  if [ ! -e  ".git" ]; then
#    # git 管理されていないディレクトリは何も返さない
#    return
#  fi
  branch_name=`git rev-parse --abbrev-ref HEAD 2> /dev/null`
  st=`git status 2> /dev/null`
  if [[ -n `echo "$st" | grep "^nothing to"` ]]; then
    # 全て commit されてクリーンな状態
    branch_status="%F{green}"
  elif [[ -n `echo "$st" | grep "^Untracked files"` ]]; then
    # git 管理されていないファイルがある状態
    branch_status="%F{red}?"
  elif [[ -n `echo "$st" | grep "^Changes not staged for commit"` ]]; then
    # git add されていないファイルがある状態
    branch_status="%F{red}+"
  elif [[ -n `echo "$st" | grep "^Changes to be committed"` ]]; then
    # git commit されていないファイルがある状態
    branch_status="%F{yellow}!"
  elif [[ -n `echo "$st" | grep "^rebase in progress"` ]]; then
    # コンフリクトが起こった状態
    echo "%F{red}!(no branch)"
    return
  else
    # 上記以外の状態の場合
    branch_status="%F{blue}"
  fi
  # ブランチ名を色付きで表示する
  echo "${branch_status}[$branch_name]"
}
# プロンプトが表示されるたびにプロンプト文字列を評価、置換する
setopt prompt_subst
# プロンプトの右側にメソッドの結果を表示させる
RPROMPT='`rprompt-git-current-branch`'


#----------------------------------------- fzf
[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh
export FZF_DEFAULT_OPTS='--color=fg+:11 --height 90% --reverse --select-1 --exit-0 --multi'


#----------------------------------------- zle
replace_multiple_dots() {
  local dots=$LBUFFER[-2,-1]
  if [[ $dots == ".." ]]; then
    LBUFFER=$LBUFFER[1,-3]'../.'
  fi
  zle self-insert
}

zle -N replace_multiple_dots
bindkey "." replace_multiple_dots

select-history() {
  BUFFER=$(history -n -r 1 | fzf --no-sort --exact +m --query "$LBUFFER" --prompt="History > ")
  CURSOR=$#BUFFER
}
zle -N select-history
bindkey '^r' select-history



#----------------------------------------- etc
# docker start
if [ $(service docker status | awk '{print $4}') = "not" ]; then
  sudo service docker start > /dev/null
fi

sudo hwclock --hctosys
export PATH=$PATH:/mnt/c/AndroidSDK/platform-tools

. ${HOME}/.venv/bin/activate

# GPU環境
export PATH=/usr/local/cuda-12.9/bin:$PATH
export LD_LIBRARY_PATH=/usr/local/cuda-12.9/lib64:$LD_LIBRARY_PATH

. "$HOME/.local/bin/env"
