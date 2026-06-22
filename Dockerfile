RUN apt-get update && \
    apt-get upgrade -y && \
    apt-get install -y \
    curl \
    wget \
    git \
    nano \
    vim \
    htop \
    tmux \
    screen \
    unzip \
    zip \
    jq \
    ca-certificates \
    software-properties-common \
    python3 \
    python3-pip \
    python3-venv \
    build-essential \
    openssh-client \
    sudo && \
    add-apt-repository -y ppa:zhangsongcui3371/fastfetch && \
    apt-get update && \
    apt-get install -y fastfetch && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

RUN curl -fsSL https://deb.nodesource.com/setup_22.x | bash - && \
    apt-get install -y nodejs && \
    npm install -g npm@latest && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

RUN wget -O /usr/local/bin/ttyd \
    https://github.com/tsl0922/ttyd/releases/latest/download/ttyd.x86_64 && \
    chmod +x /usr/local/bin/ttyd

RUN echo "fastfetch" >> /root/.bashrc && \
    echo "alias ll='ls -lah'" >> /root/.bashrc && \
    echo "alias cls='clear'" >> /root/.bashrc && \
    echo "cd /root" >> /root/.bashrc && \
    echo "export PS1='\[\e[1;32m\]\${USERNAME:-cmnty}@\h\[\e[0m\]:\[\e[1;34m\]\w\[\e[0m\]\$ '" >> /root/.bashrc

WORKDIR /root

EXPOSE $PORT

CMD ["/bin/bash", "-c", "exec ttyd -W -i 0.0.0.0 -t fontSize=20 -t theme=dark -p ${PORT:-8080} -c ${USERNAME:-cmnty}:${PASSWORD:-cmnty123} /bin/bash"]
