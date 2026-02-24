# ETAP 1: Ściągamy bezpieczny, statyczny instalator 'apk'
FROM alpine:latest AS builder
RUN apk add --no-cache apk-tools-static

# ETAP 2: Docelowy obraz n8n
FROM n8nio/n8n:2.8.3

USER root

# Krok 1: Przywracamy system pakietów
COPY --from=builder /sbin/apk.static /sbin/apk
RUN /sbin/apk -X http://dl-cdn.alpinelinux.org/alpine/latest-stable/main -U --allow-untrusted --initdb add apk-tools

# Krok 2: Instalujemy Pythona
RUN apk update && apk add --no-cache python3 py3-pip py3-virtualenv

# Krok 3: Tworzymy venv w /opt/venv (stała lokalizacja, poza strukturą n8n)
RUN python3 -m venv /opt/venv && \
    /opt/venv/bin/pip install --no-cache-dir --upgrade pip && \
    /opt/venv/bin/pip install --no-cache-dir requests && \
    chown -R node:node /opt/venv

# Krok 4: Przygotowanie folderu tymczasowego i roboczego na dysku Render
# Błąd "insufficient permissions" często dotyczy zapisu wyników w /tmp
RUN mkdir -p /home/node/.n8n/tmp && \
    chown -R node:node /home/node/.n8n

# Krok 5: "Oszukujemy" n8n, tworząc symlinki w najbardziej prawdopodobnych miejscach
# To rozwiązuje błąd "Virtual environment is missing" jeśli zmienna path nie zadziała
RUN for dir in $(find /usr/local/lib/node_modules -type d -name "task-runner-python"); do \
      ln -s /opt/venv "$dir/.venv" || true; \
    done

USER node
WORKDIR /home/node
