# Bazujemy na oficjalnym obrazie n8n (Alpine)
FROM n8nio/n8n:2.9.0

# Przełączamy na root, żeby zainstalować Python
USER root

# Instalacja Pythona i pip w Alpine
RUN apk add --no-cache python3 py3-pip py3-virtualenv py3-setuptools \
    && ln -sf python3 /usr/bin/python \
    && python3 -m ensurepip \
    && pip3 install --upgrade pip

# Wracamy do użytkownika n8n
USER node
WORKDIR /home/node

# Port i entrypoint
EXPOSE 5678
ENTRYPOINT ["n8n"]
CMD ["start"]
