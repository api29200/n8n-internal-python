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

# Krok 3: Tworzymy venv w STAŁEJ lokalizacji (nie szukamy folderów n8n!)
RUN python3 -m venv /usr/local/python_venv && \
    /usr/local/python_venv/bin/pip install --no-cache-dir requests && \
    # Nadajemy pełne uprawnienia, aby użytkownik 'node' mógł go uruchamiać
    chown -R node:node /usr/local/python_venv && \
    chmod -R 755 /usr/local/python_venv

# Krok 4: Tworzymy symlink tam, gdzie n8n 2.8.3 zazwyczaj zagląda (na wszelki wypadek)
# Nawet jeśli find nic nie znajdzie, build się nie wywali (dzięki || true)
RUN RUNNER_DIR=$(find /usr/local/lib/node_modules -name "task-runner-python" -type d | head -n 1) && \
    if [ ! -z "$RUNNER_DIR" ]; then ln -s /usr/local/python_venv "$RUNNER_DIR/.venv" || true; fi

# Krok 5: Uprawnienia do folderu roboczego
RUN mkdir -p /home/node/.n8n && chown -R node:node /home/node/.n8n

USER node
