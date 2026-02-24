# Bazujemy na oficjalnym obrazie n8n
FROM n8nio/n8n:2.9.0

# Przełączamy na root, żeby zainstalować pakiety systemowe
USER root

# Instalacja Python3 i pip w Alpine Linux
# UWAGA: W Alpine nie aktualizujemy pip komendą 'pip install --upgrade pip', 
# bo to psuje systemowe zarządzanie pakietami.
RUN apk add --update --no-cache python3 py3-pip

# (Opcjonalnie) Jeśli potrzebujesz bibliotek np. pandas/requests odkomentuj linię niżej:
# RUN pip3 install requests pandas --break-system-packages

# Wracamy do użytkownika node (bezpieczeństwo i uprawnienia n8n)
USER node
