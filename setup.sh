#!/bin/bash
cd `dirname $0`

### Set Parameter ##############################################################
pw=''

### Define Process #############################################################
main(){
  # set_password
  # add_sudoers
  # link_dotfiles
  # update_linux_package
  # install_linux_package
  # install_fzf
  # login_zsh
  # setup_prezto
  install_uv_and_python
  # docker_wsl_setup
  # # # sh build_and_install_vim.sh
  # setup_vim_colorscheme
  # install_japanase_font

  # cp -rf ./.config ${HOME}/ # for ptpython
  # cp -rf ./pyproject.toml ${HOME}/ # for pysen

}

### Define Function ############################################################
set_password(){ : 'パスワード設定'
  echo -e "${pw}\n${pw}\n" | sudo -S passwd `whoami`
}
add_sudoers(){ : 'ログインユーザををsudoers追加'
  cat<<EOT > /tmp/iam
Defaults  secure_path = /sbin:/bin:/usr/sbin:/usr/bin:/usr/local/bin
User_Alias IAM = `whoami`
# User privilege specification
IAM ALL=(ALL) ALL
IAM ALL=(ALL) NOPASSWD:ALL
EOT
  sudo chown root:root /tmp/iam
  sudo mv /tmp/iam /etc/sudoers.d/
  echo "*** sudoers done."

}
### dotfiles
link_dotfiles(){ : 'dotfilesを$HOME以下にリンク付'
  sh ./dotfilesLink.sh
}
### Shell Package
update_linux_package(){ : ' linuxパッケージ情報update&パッケージupgrade'
  sudo apt-get update -y && sudo apt-get upgrade -y
}
install_linux_package(){ : 'linuxパッケージインストール'
  sudo apt install -y \
    jq \
    mailutils \
    tree \
    zip \
    zsh \
    ripgrep \
    python3-pip
}
install_fzf(){
  git clone --depth 1 https://github.com/junegunn/fzf.git ${HOME}/.fzf
  ${HOME}/.fzf/install
}
### ZSH
login_zsh(){ : 'zshをデフォルトSHELLに設定しzshでログイン'
  # create empty zshrc
  touch ${HOME}/.zshrc
  # set zsh as default shell
  sudo chsh $USER -s $(which zsh)
  # relogin zsh
  exec -l `which zsh`
}
setup_prezto(){ : 'preztoインストール'
  git clone --recursive https://github.com/sorin-ionescu/prezto.git "${ZDOTDIR:-$HOME}/.zprezto"
  # creat config
  echo '
    #!/bin/bash
    setopt EXTENDED_GLOB
    for rcfile in "${ZDOTDIR:-$HOME}"/.zprezto/runcoms/^README.md(.N); do
      ln -fs "$rcfile" "${ZDOTDIR:-$HOME}/.${rcfile:t}"
    done
  '>./create_zprezto_config.sh && zsh create_zprezto_config.sh && rm create_zprezto_config.sh
  # edit colorscheme(blue -> cyan)
  sed -i -e 's/{4}/{6}/g' ~/.zprezto/modules/prompt/functions/prompt_sorin_setup

  ''' WSL環境の場合、Preztoコマンド補間高速化するために以下実施

    ### /etc/wsl.confを作成し、以下を追記
    [interop]
    appendWindowsPath = false
    enabled = false
  '''
}
### Python
install_uv_and_python(){
  curl -LsSf https://astral.sh/uv/install.sh | sh
  exec $SHELL -l
  uv python install 3.13.3
  uv venv ${HOME}/.venv
  uv pip install -r pyproject.toml --all-extras

}
### Docker
docker_wsl_setup(){ 'WSL環境にて動くようdocker / docker-composeインストール'
  ### install docker
  ## Ref: https://docs.docker.com/engine/install/ubuntu/

  # uninstall old versions
  sudo apt-get remove -y docker docker-engine docker.io containerd runc

  # update the apt package index. install packages to allow apt to use a repository over HTTPS:
  sudo apt-get update -y
  sudo apt-get install -y \
    ca-certificates \
    curl \
    gnupg \
    lsb-release
  # Add Docker’s official GPG key:
  curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
  # set up the stable repository.
  echo \
    "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu \
    $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

  # install Docker Engine
  sudo apt-get update
  sudo apt-get install docker-ce docker-ce-cli containerd.io

  # install docker-compose
  yes | pip3 install docker-compose

  ### docker group
  # add login user to dockert group
  sudo gpasswd -a `whoami` docker
  # grant docker group write access to docker.sock
  sudo chgrp docker /var/run/docker.sock

  ### if not work sudo service docker start. execute below
  # sudo update-alternatives --set iptables /usr/sbin/iptables-legacy
  # sudo update-alternatives --set ip6tables /usr/sbin/ip6tables-legacy
}
### VIM
setup_vim_colorscheme(){ : 'vimのcolorscheme追加'
  to_dir=${HOME}/.vim
  # make dir for save colorscheme
  mkdir -p ${to_dir}/colors
  # fetch & install colorscheme(tender)
  git clone https://github.com/jacoborus/tender.vim.git ${to_dir}/tender.vim
  mv ${to_dir}/tender.vim/colors/tender.vim ${to_dir}/colors/
  # fetch & install colorscheme(yuyuko)
  git clone https://github.com/Enonya/yuyuko.vim.git ${to_dir}/yuyuko.vim
  mv ${to_dir}/yuyuko.vim/colors/yuyuko.vim ${to_dir}/colors/
}
### Font
install_japanase_font(){
  cd ${HOME}
  #azuki
  wget http://azukifont.com/font/azukifont121.zip && unzip azukifont121.zip
  mv azukifont121/azuki.ttf
  rm -rf azukifont121 azukifont121.zip
  # Ricty
  wget https://github.com/edihbrandon/RictyDiminished/raw/master/RictyDiminished-Regular.ttf
  # install
  sudo mkdir /usr/share/fonts/
  sudo mv azuki.ttf RictyDiminished-Regular.ttf /usr/share/fonts/
  sudo apt install -y fontconfig
  sudo fc-cache -fv
  sudo rm -rf ${HOME}/.cache/matplotlib/fontlist-v330.json
}


### Execute Process ############################################################
main
