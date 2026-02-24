# ETAP 1: Pobieramy apk
FROM alpine:latest AS builder
RUN apk add --no-cache apk-tools-static

# ETAP 2: Docelowy obraz n8n
FROM n8nio/n8n:2.8.3

USER root

# Krok 1: Przywracamy apk w obrazie n8n
COPY --from=builder /sbin/apk.static /sbin/apk
RUN /sbin/apk -X http://dl-cdn.alpinelinux.org/alpine/latest-stable/main -U --allow-untrusted --initdb add apk-tools

# Krok 2: Instalujemy Pythona, narzędzia wirtualne i GIT-a
RUN apk update && apk add --no-cache python3 py3-pip py3-virtualenv git

# Krok 3: Ręczne odtworzenie brakującego kodu runnera z repozytorium GitHub!
# Tworzymy ścieżkę, do której n8n odwołuje się w kodzie źródłowym
RUN mkdir -p /usr/local/lib/node_modules/@n8n && \
    git clone --depth 1 https://github.com/n8n-io/n8n.git /tmp/n8n-repo && \
    cp -r /tmp/n8n-repo/packages/@n8n/task-runner-python /usr/local/lib/node_modules/@n8n/ && \
    rm -rf /tmp/n8n-repo

# Krok 4: Budowa .venv i nadanie uprawnień dokładnie w folderze runnera
RUN cd /usr/local/lib/node_modules/@n8n/task-runner-python && \
    python3 -m venv .venv && \
    .venv/bin/pip install --no-cache-dir requests && \
    # 777 rozwiązuje problemy z Sandboxem n8n
    chmod -R 777 /usr/local/lib/node_modules/@n8n/task-runner-python && \
    chown -R node:node /usr/local/lib/node_modules/@n8n/task-runner-python

# Krok 5: Ominięcie blokady zapisu na dysku Render (noexec bug)
RUN mkdir -p /tmp/n8n_runner && \
    chown -R node:node /tmp/n8n_runner && \
    chmod -R 777 /tmp/n8n_runner

# Krok 6: Standardowe uprawnienia n8n
RUN chown -R node:node /usr/local/lib/node_modules/n8n && \
    mkdir -p /home/node/.n8n && chown -R node:node /home/node/.n8n

USER node
WORKDIR /home/node
