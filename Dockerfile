FROM ubuntu:24.04

ENV DEBIAN_FRONTEND=interactive
ENV TZ=Asia/Jakarta

# 1. Update & Install sistem utilities, NGINX, PROOT, dan DEBOOTSTRAP
RUN apt-get update && \
    apt-get upgrade -y && \
    apt-get install -y \
    curl wget git nano vim htop tmux screen unzip zip jq \
    ca-certificates software-properties-common python3 python3-pip python3-venv \
    build-essential openssh-client sudo \
    nginx proot debootstrap tar && \
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

# 4. Kustomisasi Bash Ubuntu Utama
RUN echo "fastfetch" >> /root/.bashrc && \
    echo "alias ll='ls -lah'" >> /root/.bashrc && \
    echo "alias cls='clear'" >> /root/.bashrc && \
    echo "cd /root" >> /root/.bashrc && \
    echo "export PS1='\[\e[1;32m\]\${USERNAME:-admin}@ubuntu\[\e[0m\]:\[\e[1;34m\]\w\[\e[0m\]\$ '" >> /root/.bashrc

# 5. --- PEMBUATAN GUEST OS (DEBIAN & ALPINE) ---
RUN mkdir -p /os/debian && \
    debootstrap --variant=minbase stable /os/debian http://deb.debian.org/debian/

RUN mkdir -p /os/alpine && \
    curl -s https://dl-cdn.alpinelinux.org/alpine/v3.20/releases/x86_64/alpine-minirootfs-3.20.0-x86_64.tar.gz | tar -xz -C /os/alpine

# 6. --- HALAMAN UI TOMBOL (INDEX.HTML) ---
# Membuat halaman landing page yang responsif dan modern
RUN mkdir -p /var/www/html && \
    cat << 'EOF' > /var/www/html/index.html
<!DOCTYPE html>
<html lang="id">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Terminal Hub</title>
    <style>
        body { background: #1a1b26; color: #c0caf5; font-family: system-ui, sans-serif; display: flex; flex-direction: column; align-items: center; justify-content: center; height: 100vh; margin: 0; }
        h1 { margin-bottom: 2rem; font-size: 2rem; }
        .container { display: flex; flex-direction: column; gap: 15px; width: 100%; max-width: 300px; }
        a.btn { background: #7aa2f7; color: #1a1b26; text-decoration: none; padding: 15px 30px; border-radius: 8px; font-weight: bold; font-size: 1.2rem; text-align: center; transition: 0.2s; box-shadow: 0 4px 6px rgba(0,0,0,0.3); }
        a.btn:hover { background: #89b4fa; transform: translateY(-2px); }
        a.btn.debian { background: #f7768e; }
        a.btn.debian:hover { background: #ff8c9f; }
        a.btn.alpine { background: #9ece6a; }
        a.btn.alpine:hover { background: #b3e37c; }
    </style>
</head>
<body>
    <h1>Pilih OS Server</h1>
    <div class="container">
        <a href="/ubuntu/" class="btn">Ubuntu 24.04</a>
        <a href="/debian/" class="btn debian">Debian Stable</a>
        <a href="/alpine/" class="btn alpine">Alpine Linux</a>
    </div>
</body>
</html>
EOF

# 7. --- KONFIGURASI NGINX (REVERSE PROXY) ---
RUN echo 'server { \
    listen 8080; \
    root /var/www/html; \
    index index.html; \
    location /ubuntu/ { proxy_pass http://127.0.0.1:8001/; proxy_http_version 1.1; proxy_set_header Upgrade $http_upgrade; proxy_set_header Connection "upgrade"; } \
    location /debian/ { proxy_pass http://127.0.0.1:8002/; proxy_http_version 1.1; proxy_set_header Upgrade $http_upgrade; proxy_set_header Connection "upgrade"; } \
    location /alpine/ { proxy_pass http://127.0.0.1:8003/; proxy_http_version 1.1; proxy_set_header Upgrade $http_upgrade; proxy_set_header Connection "upgrade"; } \
    location / { try_files $uri $uri/ =404; } \
}' > /etc/nginx/sites-available/default

# 8. --- SCRIPT STARTUP ---
RUN echo '#!/bin/bash\n\
sed -i "s/listen 8080;/listen ${PORT:-8080};/g" /etc/nginx/sites-available/default\n\
service nginx start\n\
\n\
ttyd -b /ubuntu -W -i 127.0.0.1 -t fontSize=20 -t theme=dark -p 8001 -c ${USERNAME:-admin}:${PASSWORD:-admin123} /bin/bash &\n\
ttyd -b /debian -W -i 127.0.0.1 -t fontSize=20 -t theme=dark -p 8002 -c ${USERNAME:-admin}:${PASSWORD:-admin123} proot -r /os/debian -w /root /bin/bash &\n\
ttyd -b /alpine -W -i 127.0.0.1 -t fontSize=20 -t theme=dark -p 8003 -c ${USERNAME:-admin}:${PASSWORD:-admin123} proot -r /os/alpine -w /root /bin/sh &\n\
\n\
wait -n\n\
' > /root/start.sh && chmod +x /root/start.sh

WORKDIR /root
EXPOSE $PORT
CMD ["/root/start.sh"]
