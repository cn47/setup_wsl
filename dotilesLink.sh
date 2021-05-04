#!/bin/bash

create_links() {
  ln -sf ~/dotfiles/${1} ~/${1}
}

create_links .alias
create_links .dircolors
create_links .screenrc
create_links .vimrc
create_links .zshrc


ln -sf ~/dotfiles/.vim/dein.toml ~/.vim/dein.toml
