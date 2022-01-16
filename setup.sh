#!/bin/bash
cd `dirname $0`

### Set Parameter ##############################################################
pw=''

### Define Process #############################################################
main(){
#  set_password
#  add_sudoers
#  update_linux_package
#  install_linux_package
#  login_zsh
#  setup_prezto
#  link_dotfiles
#  setup_vim_colorscheme
#  install_pyenv
#  install_python_package
#  docker_wsl_setup
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
update_linux_package(){ : ' linuxパッケージ情報update&パッケージupgrade'
  sudo apt-get update -y && sudo apt-get upgrade -y
}
install_linux_package(){ : 'linuxパッケージインストール'
  sudo apt install -y \
    jq \
    # mailutils \
    tree \
    zip \
    zsh \
    fzf \
    ripgrep \
    python3-pip
}
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
  '>./create_presto_config.sh && zsh create_presto_config.sh && rm create_presto_config.sh
  # edit colorscheme(blue -> cyan)
  sed -i -e 's/{4}/{6}/g' ~/.zprezto/modules/prompt/functions/prompt_sorin_setup

  ''' WSL環境の場合、Preztoコマンド補間高速化するために以下実施

    ### /etc/wsl.confを作成し、以下を追記
    [interop]
    appendWindowsPath = false
    enabled = false
  '''
}
link_dotfiles(){ : 'dotfilesを$HOME以下にリンク付'
  sh ./dotfilesLink.sh
}
setup_vim_colorscheme(){ : 'vimのcolorscheme追加'
  to_dir=${HOME}/.vim
  # make dir for save colorscheme
  mkdir -p ${to_dir}/colors
  # fetch & install colorscheme(tender)
  git clone https://github.com/jacoborus/tender.vim.git ${to_dir}/tender.vim
  mv ${to_dir}/tender.vim/colors/tender.vim ${to_dir}/colors/
}
install_pyenv(){ : 'pyenvインストール'
  pyver=3.10.2

  git clone https://github.com/pyenv/pyenv.git ${HOME}/.pyenv
  echo 'export PYENV_ROOT="$HOME/.pyenv"' >> ${HOME}/.zprofile
  echo 'export PATH="$PYENV_ROOT/bin:$PATH"' >> ${HOME}/.zprofile
  echo 'eval "$(pyenv init --path)"' >> ~/.zprofile
  echo 'eval "$(pyenv init -)"' >> ${HOME}/.zprofile
  . ${HOME}/.zprofile

  # install required packages for building python by pyenv
  sudo apt-get install -y make build-essential libssl-dev zlib1g-dev \
    libbz2-dev libreadline-dev libsqlite3-dev wget curl llvm \
    libncursesw5-dev xz-utils tk-dev libxml2-dev libxmlsec1-dev libffi-dev liblzma-dev

  # python install
  pyenv install $pyver
  pyenv global $pyver
  echo "python global is `python -V`"

  # pip upgrade
  yes | pip3 install --upgrade pip
}

install_python_package(){ : 'HOME以下に.venvを作ってpip install. pyenv管理のpythonk環境に対して行う'
  # specify the python env
  pyver=3.10.2
  venv_dpath=${HOME}/.venv
  pyenv global $pyver

  # venv
  python3 -m venv ${venv_dpath}
  . ${venv_dpath}/bin/activate
  yes | pip3 install --upgrade pip

  # pip install # sudoつけるとpyenvで管理してるpythonでなくsystemの方にinstallしにいくのでsudoなし
  yes | pip3 install \
    ipython \
    pandas \
    numpy \
    glances

  # 起動時にvenv環境に入れるようにする
  echo ". ${venv_dpath}/bin/activate" >> ${HOME}/.zshrc
}

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
}


### Execute Process ############################################################
main
