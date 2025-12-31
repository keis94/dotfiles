FROM ubuntu:24.04

ARG USER=testuser
ARG UID=1001
ARG GID=1001

ENV DEBIAN_FRONTEND=noninteractive
ENV USER=$USER

# Install minimal packages
RUN --mount=type=cache,target=/var/cache/apt,sharing=locked \
    --mount=type=cache,target=/var/lib/apt,sharing=locked \
    apt-get update && apt-get install -y \
    git \
    curl \
    sudo

# Create non-root user with sudo access
RUN groupadd -g ${GID} ${USER} \
    && useradd -m -u ${UID} -g ${GID} -s /bin/bash ${USER} \
    && echo "${USER} ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers \
    && echo ${USER}:${USER} | sudo chpasswd

# Copy dotfiles
COPY --chown=${USER}:${USER} . /home/${USER}/repo/dotfiles/

USER ${USER}
WORKDIR /home/${USER}/repo/dotfiles

RUN git init

CMD ["bash", "-l"]
