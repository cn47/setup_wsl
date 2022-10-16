#!/bin/bash
cd `dirname $0`
CURRENT=`pwd`

### ビルドのために最低限必要なツールを導入
sudo apt install -y git gettext libtinfo-dev libacl1-dev libgpm-dev build-essential

### Python2, Python3連携に必要なツールとライブラリを導入 ...python3はだいたい入ってるだろうから多分Skipしておｋ
# sudo apt install -y python3 python3-dev

### GitHubから最新版のVimをクローン
git clone https://github.com/vim/vim.git
cd $CURRENT/vim/src
sudo make uninstall; sudo make clean; sudo make distclean  # 初期化

### buildオプションを設定
./configure --prefix=/usr/local/ \  # /usr/local/bin/vimというパスに入る
            --with-features=huge \
            --with-x \
            --enable-multibyte \
            --enable-cscope \
            --enable-gtk2-check \
            --enable-terminal \
            --enable-netbeans \
            --enable-python3interp=dynamic \
            --with-python3-command=/usr/bin/python3 \
            --with-local-dir=/opt/local \
            --enable-fail-if-missing

### ビルド&インストール
sudo make && sudo make install

### 新しい Vim が呼び出せるように、コマンドへのパスのキャッシュを再構築
hash -r

### plugをインストール
curl -fLo ~/.vim/autoload/plug.vim --create-dirs \
      https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim

### /bin/vimにリンクを張ってソースコード削除する
sudo ln -snf /usr/local/bin/vim /bin/vim
cd $CURRENT && rm -rf vim
