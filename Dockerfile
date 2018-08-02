FROM ubuntu:xenial

# Install zsh, neovim, and dependencies
RUN apt update;\
    apt upgrade -y;\
    apt install -y software-properties-common git zsh curl xsel locales gawk;\
    apt-add-repository -y ppa:neovim-ppa/stable;\
    apt update;\
    apt install -y neovim

# Locale setting
ENV LANGUAGE=en_US.UTF-8 \
    LANG=en_US.UTF-8
RUN locale-gen en_US.UTF-8;\
    dpkg-reconfigure -f noninteractive locales

# 
RUN useradd -mU -d /home/test -s /bin/zsh test
COPY . /home/test/.dotfiles
RUN chown test:test /home/test/.dotfiles/*

WORKDIR /home/test/.dotfiles
USER test
CMD /bin/zsh
