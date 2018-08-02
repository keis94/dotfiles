FROM ubuntu:xenial

RUN apt update; apt upgrade -y;\
    apt install -y software-properties-common git zsh curl sudo xsel;\
    apt-add-repository -y ppa:neovim-ppa/stable;\
    apt update;\
    apt install -y neovim

RUN useradd -mU -G sudo -d /home/test -s /bin/zsh test
USER test
WORKDIR /home/test
RUN git clone https://github.com/keis94/dotfiles.git ~/.dotfiles
CMD /bin/zsh
