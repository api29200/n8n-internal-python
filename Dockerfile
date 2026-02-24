# ETAP 1: Ściągamy bezpieczny, statyczny instalator 'apk'
FROM alpine:latest AS builder
RUN apk add --no-cache apk-tools-static

# ETAP 2: Docelowy obraz n8n
FROM n8nio/n8n:2.8.3

USER root

# Krok 1: Przywracamy apk (obraz n8n ma go usuniętego)
COPY --from=builder /sbin/apk.static /sbin/apk
RUN /sbin/apk -X http://dl-cdn.alpinelinux.org/alpine/latest-stable/main -U --allow-untrusted --initdb add apk-tools

# Krok 2: Instalujemy Pythona i narzędzia venv
RUN apk update && apk add --no-cache python3 py3-pip py3-virtualenv

# Krok 3: Agresywne szukanie folderu runnera i tworzenie venv
# W n8n 2.x foldery są ukryte w strukturze pnpm. Szukamy precyzyjnie ścieżki pakietu.
RUN RUNNER_DIR=$(find /usr/local/lib/node_modules -path "*/@n8n/task-runner-python" -type d | head -n 1) && \
    if [ -z "$RUNNER_DIR" ]; then \
        # Fallback jeśli pnpm nie wyeksponował nazwy z małpą
        RUNNER_DIR=$(find /usr/local/lib/node_modules -name "task-runner-python" -type d | head -n 1); \
    fi && \
    echo "Lokalizacja runnera: $RUNNER_DIR" && \
    python3 -m venv "$RUNNER_DIR/.venv" && \
    "$RUNNER_DIR/.venv/bin/pip" install --no-cache-dir requests && \
    # Nadanie uprawnień 777 dla venv i plików runnera
    chown -R node:node "$RUNNER_DIR" && \
    chmod -R 777 "$RUNNER_DIR/.venv"

# Krok 4: Rozwiązanie błędu "Insufficient Permissions"
# Tworzymy folder tymczasowy w systemowym /tmp (nie na dysku persistent)
# To tutaj n8n wymienia dane (skrypty .py i wyniki .json) z procesem Pythona.
RUN mkdir -p /tmp/n8n_runner && \
    chown -R node:node /tmp/n8n_runner && \
    chmod -R 777 /tmp/n8n_runner

# Krok 5: Przygotowanie folderu domowego i uprawnienia dla n8n
RUN mkdir -p /home/node/.n8n && chown -R node:node /home/node/.n8n

USER node
WORKDIR /home/node
