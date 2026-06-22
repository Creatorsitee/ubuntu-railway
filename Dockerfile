FROM ubuntu:24.04

ENV DEBIAN_FRONTEND=noninteractive
ENV TZ=Asia/Jakarta

# 1. Update & Install sistem utilities (Layer dioptimalkan)
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
    sudo \
    fastfetch && \
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

# 4. Kustomisasi Bash Statis
RUN echo "fastfetch" >> /root/.bashrc && \
    echo "alias ll='ls -lah'" >> /root/.bashrc && \
    echo "alias cls='clear'" >> /root/.bashrc && \
    echo "cd /root" >> /root/.bashrc

# Set working directory utama
WORKDIR /root

# Healthcheck dinamis menyesuaikan PORT dari Railway (default ke 7681)
HEALTHCHECK --interval=30s --timeout=10s --start-period=20s \
  CMD curl -f http://localhost:${PORT:-7681} || exit 1

EXPOSE 7681

# CMD Aman: Menghapus baris PS1 lama sebelum menulis yang baru agar tidak duplikat saat restart
CMD ["/bin/bash", "-c", "\
export USERNAME=${USERNAME:-admin}; \
export PASSWORD=${PASSWORD:-admin123}; \
sed -i '/export PS1=/d' /root/.bashrc; \
echo \"export PS1='\\[\\e[1;32m\\]\$USERNAME@\\h\\[\\e[0m\\]:\\[\\e[1;34m\\]\\w\\[\\e[0m\\]\\$ '\" >> /root/.bashrc; \
exec ttyd \
-W \
-t fontSize=16 \
-t theme=dark \
-p ${PORT:-7681} \
-c ${USERNAME}:${PASSWORD} \
/bin/bash"]
