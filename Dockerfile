FROM n8nio/n8n:2.8.3

USER root

# Krok 1: Instalacja Pythona (apk jest dostępne w tym obrazie domyślnie dla roota)
RUN apk update && apk add --no-cache python3 py3-pip py3-virtualenv

# Krok 2: Instalacja venv bezpośrednio wewnątrz struktury n8n
# Używamy ścieżki, którą n8n 2.8.3 preferuje domyślnie.
RUN RUNNER_DIR=$(find /usr/local/lib/node_modules -name "task-runner-python" -type d | head -n 1) && \
    echo "Instalacja w: $RUNNER_DIR" && \
    python3 -m venv "$RUNNER_DIR/.venv" && \
    "$RUNNER_DIR/.venv/bin/pip" install --no-cache-dir requests && \
    # Nadanie uprawnień do całego folderu runnera dla użytkownika node
    chown -R node:node "$RUNNER_DIR" && \
    # Kluczowe: nadanie uprawnień do wykonywania plików w venv
    chmod -R 755 "$RUNNER_DIR/.venv"

# Krok 3: Czyszczenie uprawnień folderu roboczego
RUN mkdir -p /home/node/.n8n && chown -R node:node /home/node/.n8n

USER node
