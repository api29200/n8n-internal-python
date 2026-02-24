# ETAP 1: Ściągamy bezpieczny, statyczny instalator 'apk'
FROM alpine:latest AS builder
RUN apk add --no-cache apk-tools-static

# ETAP 2: Docelowy obraz n8n
FROM n8nio/n8n:2.8.3

USER root

# Krok 1: Przywracamy apk (wymagane w zablokowanym n8n 2.x)
COPY --from=builder /sbin/apk.static /sbin/apk
RUN /sbin/apk -X http://dl-cdn.alpinelinux.org/alpine/latest-stable/main -U --allow-untrusted --initdb add apk-tools

# Krok 2: Instalujemy Pythona
RUN apk update && apk add --no-cache python3 py3-pip py3-virtualenv

# Krok 3: Tworzymy venv w systemowej lokalizacji /usr/local/
# To omija problemy z uprawnieniami dysku /home/node/.n8n
RUN python3 -m venv /usr/local/python_venv && \
    /usr/local/python_venv/bin/pip install --no-cache-dir requests && \
    chown -R node:node /usr/local/python_venv && \
    chmod -R 755 /usr/local/python_venv

# Krok 4: Konfiguracja folderu tymczasowego w /tmp
# To rozwiązuje błąd "insufficient permissions" (Render blokuje exec na dyskach persistent)
RUN mkdir -p /tmp/n8n_runner && \
    chown -R node:node /tmp/n8n_runner && \
    chmod -R 777 /tmp/n8n_runner

# Krok 5: Linkowanie .venv do paczki n8n
# Szukamy DOKŁADNEJ lokalizacji paczki runnera i podpinamy nasz venv
RUN RUNNER_DIR=$(find /usr/local/lib/node_modules -name "task-runner-python" -type d | head -n 1) && \
    if [ ! -z "$RUNNER_DIR" ]; then \
        rm -rf "$RUNNER_DIR/.venv" && \
        ln -s /usr/local/python_venv "$RUNNER_DIR/.venv" && \
        chown -h node:node "$RUNNER_DIR/.venv"; \
    fi

# Krok 6: Zapewnienie uprawnień dla node do plików n8n
RUN chown -R node:node /usr/local/lib/node_modules/n8n

USER node
WORKDIR /home/node
