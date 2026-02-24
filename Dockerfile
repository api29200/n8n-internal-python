# Wybrana przez Ciebie wersja
FROM n8nio/n8n:2.8.3

USER root

# Instalacja Pythona w systemie Alpine (standard dla n8n)
# Jeśli build wyrzuci błąd "apk: not found", oznacza to, że ta wersja to Debian (patrz niżej)
RUN apk add --update --no-cache python3 py3-pip

# Instalacja bibliotek (wymagana flaga --break-system-packages w nowych wersjach)
RUN pip3 install requests --break-system-packages

USER node
