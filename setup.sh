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
  install_pyenv
#  docker_wsl_setup
}

### Define Function ############################################################
set_password(){
  echo -e "${pw}\n${pw}\n" | sudo -S passwd `whoami`
}
add_sudoers(){
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
update_linux_package(){
  # パッケージ情報update / パッケージのアップグレード
  sudo apt-get update -y && sudo apt-get upgrade -y
}
install_linux_package(){
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
login_zsh(){
  # create empty zshrc
  touch ${HOME}/.zshrc
  # set zsh as default shell
  sudo chsh $USER -s $(which zsh)
  # relogin zsh
  exec -l `which zsh`
}
setup_prezto(){
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

  echo 'WSL環境なら追加でPreztoコマンド補間高速化するための操作を実施しましょう'
}
link_dotfiles(){
  sh ./dotfilesLink.sh
}
setup_vim_colorscheme(){
  to_dir=${HOME}/.vim
  # make dir for save colorscheme
  mkdir -p ${to_dir}/colors
  # fetch & install colorscheme(tender)
  git clone https://github.com/jacoborus/tender.vim.git ${to_dir}/tender.vim
  mv ${to_dir}/tender.vim/colors/tender.vim ${to_dir}/colors/
}
install_pyenv(){ ############ 工事中
  git clone https://github.com/pyenv/pyenv.git ${HOME}/.pyenv
  echo 'eval "$(pyenv init --path)"' >> ${HOME}/.zprofile
  echo 'eval "$(pyenv init -)"' >> ${HOME}/.zshrc
  . ${HOME}/.zshrc
}

docker_wsl_setup(){
  ### install docker
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

  ### docker group
  # add login user to dockert group
  sudo gpasswd -a `whoami` docker
  # grant docker group write access to docker.sock
  sudo chgrp docker /var/run/docker.sock
}


### Execute Process ############################################################
main
