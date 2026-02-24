# ETAP 1: Ściągamy bezpieczny, statyczny instalator 'apk'
FROM alpine:latest AS builder
RUN apk add --no-cache apk-tools-static

# ETAP 2: Docelowy obraz n8n
FROM n8nio/n8n:2.8.3

USER root

# Krok 1: Przywracamy system pakietów w zablokowanym n8n
COPY --from=builder /sbin/apk.static /sbin/apk
RUN /sbin/apk -X http://dl-cdn.alpinelinux.org/alpine/latest-stable/main -U --allow-untrusted --initdb add apk-tools

# Krok 2: Instalujemy Pythona i pakiety deweloperskie
RUN apk update && apk add --no-cache python3 python3-dev py3-pip py3-virtualenv build-base git

# Krok 3: Instalujemy 'uv'
RUN pip3 install uv --break-system-packages

# Krok 4: PRAWIDŁOWE BUDOWANIE ŚRODOWISKA (instalacja silnika n8n wewnątrz .venv)
RUN RUNNER_DIR=$(find /usr/local/lib/node_modules/n8n -name "task-runner-python" -type d | head -n 1) && \
    cd $RUNNER_DIR && \
    uv venv .venv && \
    uv pip install . && \
    uv pip install requests && \
    chown -R node:node /usr/local/lib/node_modules/n8n

USER node
