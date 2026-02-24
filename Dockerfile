# Zmieniamy wersję na 'latest' (stabilną), bo 2.9.0 jest błędna/nieobsługiwana
FROM n8nio/n8n:latest

USER root

# Instalacja Pythona 3 i pip
# Używamy flagi --no-cache aby nie zapychać obrazu śmieciami
RUN apk add --update --no-cache python3 py3-pip

# Opcjonalnie: Instalacja bibliotek (np. requests)
# W nowych wersjach Pythona na Alpine flaga --break-system-packages jest wymagana
RUN pip3 install requests --break-system-packages

USER node
