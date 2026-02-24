# ETAP 1: Ściągamy bezpieczny, statyczny instalator 'apk'
FROM alpine:latest AS builder
RUN apk add --no-cache apk-tools-static

# ETAP 2: Docelowy obraz n8n
FROM n8nio/n8n:2.8.3

USER root

# Krok 1: Przywracamy apk
COPY --from=builder /sbin/apk.static /sbin/apk
RUN /sbin/apk -X http://dl-cdn.alpinelinux.org/alpine/latest-stable/main -U --allow-untrusted --initdb add apk-tools

# Krok 2: Instalujemy Pythona
RUN apk update && apk add --no-cache python3 py3-pip py3-virtualenv

# Krok 3: Instalujemy venv bezpośrednio tam, gdzie n8n go oczekuje
# Używamy ścieżki absolutnej dla n8n 2.x
RUN export RUNNER_DIR="/usr/local/lib/node_modules/n8n/node_modules/@n8n/task-runner-python" && \
    mkdir -p "$RUNNER_DIR" && \
    python3 -m venv "$RUNNER_DIR/.venv" && \
    "$RUNNER_DIR/.venv/bin/pip" install --no-cache-dir requests && \
    # Pełne uprawnienia dla użytkownika node i procesów potomnych
    chown -R node:node "$RUNNER_DIR" && \
    chmod -R 777 "$RUNNER_DIR/.venv"

# Krok 4: Rozwiązanie błędu "Insufficient Permissions"
# Tworzymy folder tymczasowy w systemowym /tmp (pamięć kontenera, nie dysk persistent)
RUN mkdir -p /tmp/n8n_runner && \
    chown -R node:node /tmp/n8n_runner && \
    chmod -R 777 /tmp/n8n_runner

# Krok 5: Uprawnienia do folderu n8n
RUN chown -R node:node /usr/local/lib/node_modules/n8n

USER node
WORKDIR /home/node
