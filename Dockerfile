# ETAP 1: Ściągamy bezpieczny, statyczny instalator 'apk'
FROM alpine:latest AS builder
RUN apk add --no-cache apk-tools-static

# ETAP 2: Docelowy obraz n8n
FROM n8nio/n8n:2.8.3

USER root

# Krok 1: Kopiujemy pojedynczy, statyczny plik apk
COPY --from=builder /sbin/apk.static /sbin/apk

# Krok 2: Przywracamy system pakietów w zablokowanym n8n
RUN /sbin/apk -X http://dl-cdn.alpinelinux.org/alpine/latest-stable/main -U --allow-untrusted --initdb add apk-tools

# Krok 3: Instalujemy Pythona
RUN apk update && apk add --no-cache python3 py3-pip py3-virtualenv

# Krok 4: Znajdujemy ukryty folder task-runner-python, tworzymy .venv i instalujemy paczki
RUN RUNNER_DIR=$(find /usr/local/lib/node_modules/n8n -name "task-runner-python" -type d | head -n 1) && \
    python3 -m venv $RUNNER_DIR/.venv && \
    $RUNNER_DIR/.venv/bin/pip install requests && \
    chown -R node:node $RUNNER_DIR/.venv

USER node
