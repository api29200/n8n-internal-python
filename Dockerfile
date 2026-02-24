# ETAP 1: Ściągamy bezpieczny, statyczny instalator 'apk'
FROM alpine:latest AS builder
RUN apk add --no-cache apk-tools-static

# ETAP 2: Docelowy obraz n8n
FROM n8nio/n8n:2.8.3

USER root

# Krok 1: Przywracamy system pakietów w zablokowanym obrazie n8n
COPY --from=builder /sbin/apk.static /sbin/apk
RUN /sbin/apk -X http://dl-cdn.alpinelinux.org/alpine/latest-stable/main -U --allow-untrusted --initdb add apk-tools

# Krok 2: Instalujemy Pythona i niezbędne narzędzia systemowe
RUN apk update && apk add --no-cache python3 py3-pip py3-virtualenv

# Krok 3: Lokalizujemy folder task-runner-python i tworzymy w nim .venv
# Używamy ścieżki bezwzględnej dla pewności i unikamy komend 'uv install .'
RUN RUNNER_DIR=$(find /usr/local/lib/node_modules/n8n -name "task-runner-python" -type d | head -n 1) && \
    echo "Found runner dir at: $RUNNER_DIR" && \
    python3 -m venv "$RUNNER_DIR/.venv" && \
    "$RUNNER_DIR/.venv/bin/pip" install --upgrade pip && \
    "$RUNNER_DIR/.venv/bin/pip" install requests && \
    chown -R node:node "$RUNNER_DIR"

# Krok 4: Upewniamy się, że uprawnienia do folderu n8n są poprawne dla użytkownika node
RUN chown -R node:node /home/node/.n8n

USER node
