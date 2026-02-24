# ETAP 1: Ściągamy bezpieczny, statyczny instalator 'apk'
FROM alpine:latest AS builder
RUN apk add --no-cache apk-tools-static

# ETAP 2: Docelowy obraz n8n
FROM n8nio/n8n:2.8.3

USER root

# Krok 1: Przywracamy system pakietów
COPY --from=builder /sbin/apk.static /sbin/apk
RUN /sbin/apk -X http://dl-cdn.alpinelinux.org/alpine/latest-stable/main -U --allow-untrusted --initdb add apk-tools

# Krok 2: Instalujemy Pythona i narzędzia
RUN apk update && apk add --no-cache python3 py3-pip py3-virtualenv

# Krok 3: Lokalizujemy runnera używając find -L (podąża za symlinkami pnpm)
RUN export RUNNER_DIR=$(find -L /usr/local/lib/node_modules -type d -name "task-runner-python" | head -n 1) && \
    if [ -z "$RUNNER_DIR" ]; then \
        echo "Błąd: Nie znaleziono folderu runnera nawet przez symlinki!"; \
        exit 1; \
    fi && \
    echo "Sukces! Znaleziono runnera w: $RUNNER_DIR" && \
    python3 -m venv "$RUNNER_DIR/.venv" && \
    "$RUNNER_DIR/.venv/bin/pip" install --upgrade pip && \
    "$RUNNER_DIR/.venv/bin/pip" install requests && \
    chown -R node:node "$RUNNER_DIR"

# Krok 4: Uprawnienia do folderu n8n
RUN mkdir -p /home/node/.n8n && chown -R node:node /home/node/.n8n

USER node
