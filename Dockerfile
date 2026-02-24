# Dockerfile do Render z Pythonem w Code Node
FROM node:20-bullseye-slim

# Instalacja zależności dla n8n
RUN apt-get update && apt-get install -y \
    python3 python3-pip python3-venv python3-distutils curl gnupg lsb-release && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

# Instalacja n8n globalnie
RUN npm install -g n8n@2.9.0

# Użytkownik n8n
RUN useradd -m n8n
USER n8n
WORKDIR /home/n8n

# Port i entrypoint
EXPOSE 5678
ENTRYPOINT ["n8n"]
CMD ["start"]
