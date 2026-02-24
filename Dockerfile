# Startujemy z oficjalnego obrazu n8n
FROM n8nio/n8n:2.9.0

# Przełączamy na root
USER root

# Instalacja Pythona i pip w Alpine
RUN apk add --no-cache python3 py3-pip py3-virtualenv py3-setuptools \
    && ln -sf python3 /usr/bin/python

# Powrót do użytkownika node
USER node

# Opcjonalnie: potwierdzenie wersji Pythona
RUN python --version && pip --version
