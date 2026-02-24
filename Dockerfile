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

# Krok 3: Tworzymy venv w folderze domowym node (najbezpieczniejsze miejsce na Render)
RUN python3 -m venv /home/node/python_venv && \
    /home/node/python_venv/bin/pip install --no-cache-dir requests && \
    chown -R node:node /home/node/python_venv && \
    chmod -R 777 /home/node/python_venv

# Krok 4: Tworzymy folder tymczasowy na dysku persistent z pełnymi uprawnieniami
# To rozwiązuje błąd "insufficient permissions" przy odczycie wyników.
RUN mkdir -p /home/node/.n8n/runner_temp && \
    chown -R node:node /home/node/.n8n && \
    chmod -R 777 /home/node/.n8n/runner_temp

# Krok 5: Agresywne linkowanie .venv do wszystkich potencjalnych folderów runnera
# n8n 2.x sprawdza fizyczny folder .venv wewnątrz pakietu. Szukamy go wszędzie.
RUN for dir in $(find /usr/local/lib/node_modules -type d -name "task-runner-python" 2>/dev/null); do \
      echo "Linkowanie .venv w: $dir"; \
      rm -rf "$dir/.venv" && ln -s /home/node/python_venv "$dir/.venv"; \
      chown -h node:node "$dir/.venv"; \
    done

USER node
WORKDIR /home/node
