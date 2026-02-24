# WAŻNE: Używamy wersji 'latest-debian'. 
# Zwykłe 'latest' to Alpine, który nie obsługuje apt-get i ma problemy z Pythonem.
FROM n8nio/n8n:latest-debian

USER root

# Instalacja Pythona, PIP i Venv (na Debianie używamy apt-get)
RUN apt-get update && \
    apt-get install -y --no-install-recommends python3 python3-pip python3-venv && \
    rm -rf /var/lib/apt/lists/*

# Instalacja bibliotek. Flaga --break-system-packages jest konieczna w Debianie 12+
RUN pip3 install requests --break-system-packages

USER node
