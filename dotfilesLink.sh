#!/bin/bash
cd `dirname $0`
DIR=`pwd`

create_links() {
  ln -sfn ${DIR}/${1} ${HOME}/${1}
}

create_links .alias
# create_links .dircolors
create_links .screenrc
create_links .vimrc
create_links .zpreztorc
create_links .zprofile
create_links .zshrc
create_links .vim/dein.toml

