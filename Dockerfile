FROM ubuntu:24.04

ENV DEBIAN_FRONTEND=noninteractive
ENV TZ=Asia/Jakarta

# 1. Update & Install sistem utilities + Registrasi PPA Fastfetch resmi
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

# 2. Node.js 22 LTS & pembersihan cache apt
RUN curl -fsSL https://deb.nodesource.com/setup_22.x | bash - && \
    apt-get install -y nodejs && \
    npm install -g npm@latest && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# 3. Download ttyd versi terbaru untuk arsitektur x86_64
RUN wget -O /usr/local/bin/ttyd \
    https://github.com/tsl0922/ttyd/releases/latest/download/ttyd.x86_64 && \
    chmod +x /usr/local/bin/ttyd

# 4. Kustomisasi Bash (Dipindahkan ke sini agar aman dan dinamis saat dijalankan)
RUN echo "fastfetch" >> /root/.bashrc && \
    echo "alias ll='ls -lah'" >> /root/.bashrc && \
    echo "alias cls='clear'" >> /root/.bashrc && \
    echo "cd /root" >> /root/.bashrc && \
    echo "export PS1='\[\e[1;32m\]\${USERNAME:-admin}@\h\[\e[0m\]:\[\e[1;34m\]\w\[\e[0m\]\$ '" >> /root/.bashrc

# Set working directory utama
WORKDIR /root

# Beritahu Railway untuk membuka jalur port dinamis
EXPOSE $PORT

# CMD Baru: Bersih, super aman dari crash, dan mengikat ke IP 0.0.0.0
CMD ["/bin/bash", "-c", "exec ttyd -W -i 0.0.0.0 -t fontSize=16 -t theme=dark -p ${PORT:-8080} -c ${USERNAME:-admin}:${PASSWORD:-admin123} /bin/bash"]
