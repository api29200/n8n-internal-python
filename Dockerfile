FROM n8nio/n8n:2.8.3

USER root

# 1. Instalacja Pythona
RUN apk add --update --no-cache python3 py3-pip py3-virtualenv

# 2. Szukamy ukrytego folderu runnera, tworzymy w nim wymagane ".venv" 
# i od razu instalujemy tam Twoje zewnętrzne paczki (np. requests)
RUN RUNNER_DIR=$(find /usr/local/lib/node_modules/n8n -name "task-runner-python" -type d | head -n 1) && \
    python3 -m venv $RUNNER_DIR/.venv && \
    $RUNNER_DIR/.venv/bin/pip install requests && \
    chown -R node:node $RUNNER_DIR/.venv

USER node
