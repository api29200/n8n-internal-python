FROM n8nio/n8n:2.8.3

USER root

# Instalujemy Pythona i KLUCZOWY pakiet py3-virtualenv, którego n8n twardo wymaga
RUN apk add --update --no-cache python3 py3-pip py3-virtualenv

# Instalujemy zewnętrzne biblioteki globalnie
RUN pip3 install requests --break-system-packages

USER node
