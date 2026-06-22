# Ensure you are using an Ubuntu base image if you want to use PPAs
FROM ubuntu:22.04

# Avoid prompts from apt during installation
ENV DEBIAN_FRONTEND=noninteractive

# 1. Install system dependencies and fastfetch
RUN apt-get update && apt-get install -y --no-install-recommends \
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
    gnupg \
    python3 \
    python3-pip \
    python3-venv \
    build-essential \
    openssh-client \
    sudo && \
    add-apt-repository -y ppa:zhangsongcui3371/fastfetch && \
    apt-get update && \
    apt-get install -y --no-install-recommends fastfetch && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# 2. Install Node.js 22 (NodeSource)
RUN curl -fsSL https://deb.nodesource.com/setup_22.x | bash - && \
    apt-get install -y --no-install-recommends nodejs && \
    npm install -g npm@latest && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# 3. Install ttyd
RUN wget -O /usr/local/bin/ttyd \
    https://github.com/tsl0922/ttyd/releases/latest/download/ttyd.x86_64 && \
    chmod +x /usr/local/bin/ttyd

# 4. Configure Bash environment
RUN echo "fastfetch" >> /root/.bashrc && \
    echo "alias ll='ls -lah'" >> /root/.bashrc && \
    echo "alias cls='clear'" >> /root/.bashrc && \
    echo "cd /root" >> /root/.bashrc && \
    echo "export PS1='\[\e[1;32m\]\${USERNAME:-cmnty}@\h\[\e[0m\]:\[\e[1;34m\]\w\[\e[0m\]\$ '" >> /root/.bashrc

WORKDIR /root

# EXPOSE does not support dynamic runtime env variables. 
# It's informational, so it's best to expose the default port (e.g., 8080).
EXPOSE 8080

CMD ["/bin/bash", "-c", "exec ttyd -W -i 0.0.0.0 -t fontSize=20 -t theme=dark -p ${PORT:-8080} -c ${USERNAME:-cmnty}:${PASSWORD:-cmnty123} /bin/bash"]
