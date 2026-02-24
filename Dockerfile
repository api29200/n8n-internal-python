# ETAP 1: Pobieramy apk
FROM alpine:latest AS builder
RUN apk add --no-cache apk-tools-static

# ETAP 2: Docelowy obraz n8n
FROM n8nio/n8n:2.8.3

USER root

# Krok 1: Przywracamy apk
COPY --from=builder /sbin/apk.static /sbin/apk
RUN /sbin/apk -X http://dl-cdn.alpinelinux.org/alpine/latest-stable/main -U --allow-untrusted --initdb add apk-tools

# Krok 2: Instalujemy Pythona, venv oraz GIT-a
RUN apk update && apk add --no-cache python3 py3-pip py3-virtualenv git

# Krok 3: Odtworzenie brakującego kodu runnera Pythona (Błąd obrazu n8n)
RUN mkdir -p /usr/local/lib/node_modules/@n8n && \
    git clone --depth 1 https://github.com/n8n-io/n8n.git /tmp/n8n-repo && \
    cp -r /tmp/n8n-repo/packages/@n8n/task-runner-python /usr/local/lib/node_modules/@n8n/ && \
    rm -rf /tmp/n8n-repo

# Krok 4: Budowa .venv i instalacja krytycznych bibliotek, które odkryliśmy w debugu
RUN cd /usr/local/lib/node_modules/@n8n/task-runner-python && \
    python3 -m venv .venv && \
    # Instalujemy websockets (wymagane przez n8n) i requests (Twoje zapotrzebowanie)
    .venv/bin/pip install --no-cache-dir requests websockets && \
    chmod -R 777 /usr/local/lib/node_modules/@n8n/task-runner-python && \
    chown -R node:node /usr/local/lib/node_modules/@n8n/task-runner-python

# Krok 5: Utworzenie bezpiecznego folderu tymczasowego (rozwiązanie "insufficient permissions")
RUN mkdir -p /tmp/n8n_runner && \
    chown -R node:node /tmp/n8n_runner && \
    chmod -R 777 /tmp/n8n_runner

# Krok 6: Nadanie domyślnych uprawnień dla procesu n8n
RUN chown -R node:node /usr/local/lib/node_modules/n8n && \
    mkdir -p /home/node/.n8n && chown -R node:node /home/node/.n8n

USER node
WORKDIR /home/node
