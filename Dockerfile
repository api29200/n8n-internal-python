# ETAP 1: Ściągamy bezpieczny, statyczny instalator 'apk'
FROM alpine:latest AS builder
RUN apk add --no-cache apk-tools-static

# ETAP 2: Docelowy obraz n8n
FROM n8nio/n8n:2.8.3

USER root

# Krok 1: Przywracamy system pakietów apk
COPY --from=builder /sbin/apk.static /sbin/apk
RUN /sbin/apk -X http://dl-cdn.alpinelinux.org/alpine/latest-stable/main -U --allow-untrusted --initdb add apk-tools

# Krok 2: Instalujemy Pythona
RUN apk update && apk add --no-cache python3 py3-pip py3-virtualenv

# Krok 3: Tworzymy venv w stabilnej lokalizacji na dysku użytkownika
RUN python3 -m venv /home/node/python_venv && \
    /home/node/python_venv/bin/pip install --no-cache-dir requests && \
    chown -R node:node /home/node/python_venv && \
    chmod -R 777 /home/node/python_venv

# Krok 4: Rozwiązanie błędu "Insufficient Permissions"
# Tworzymy dedykowany folder tymczasowy dla runnera i nadajemy mu pełne uprawnienia
RUN mkdir -p /home/node/.n8n/runner_temp && \
    chown -R node:node /home/node/.n8n && \
    chmod -R 777 /home/node/.n8n/runner_temp

# Krok 5: Oszukanie mechanizmu detekcji n8n
# n8n 2.x sprawdza fizyczną obecność folderu .venv wewnątrz modułu task-runner-python
RUN RUNNER_DIR=$(find -L /usr/local/lib/node_modules -name "task-runner-python" -type d | head -n 1) && \
    if [ ! -z "$RUNNER_DIR" ]; then \
        ln -s /home/node/python_venv "$RUNNER_DIR/.venv" && \
        chown -h node:node "$RUNNER_DIR/.venv"; \
    fi

USER node
WORKDIR /home/node
