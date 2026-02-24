# ETAP 1: Ściągamy bezpieczny, statyczny instalator 'apk'
FROM alpine:latest AS builder
RUN apk add --no-cache apk-tools-static

# ETAP 2: Docelowy obraz n8n
FROM n8nio/n8n:2.8.3

USER root

# Krok 1: Przywracamy system pakietów
COPY --from=builder /sbin/apk.static /sbin/apk
RUN /sbin/apk -X http://dl-cdn.alpinelinux.org/alpine/latest-stable/main -U --allow-untrusted --initdb add apk-tools

# Krok 2: Instalujemy Pythona i venv
RUN apk update && apk add --no-cache python3 py3-pip py3-virtualenv

# Krok 3: Tworzymy venv w stałej lokalizacji
RUN python3 -m venv /home/node/python_venv && \
    /home/node/python_venv/bin/pip install --no-cache-dir --upgrade pip && \
    /home/node/python_venv/bin/pip install --no-cache-dir requests

# Krok 4: Dynamicznie znajdujemy folder runnera i tworzymy symlink .venv
# Używamy Node, aby zapytać system, gdzie dokładnie leży paczka runnera
RUN RUNNER_DIR=$(node -e "console.log(require('path').dirname(require.resolve('@n8n/task-runner-python/package.json')))") && \
    echo "Runner znaleziony w: $RUNNER_DIR" && \
    ln -s /home/node/python_venv "$RUNNER_DIR/.venv" && \
    chown -R node:node /home/node/python_venv && \
    chown -h node:node "$RUNNER_DIR/.venv"

# Krok 5: Uprawnienia do folderu roboczego
RUN mkdir -p /home/node/.n8n && chown -R node:node /home/node/.n8n

USER node
