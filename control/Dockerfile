# Dockerfile per Pannello di Controllo
FROM node:18-alpine

# Installa dipendenze di sistema
RUN apk add --no-cache \
    python3 \
    py3-pip \
    android-tools-adb \
    curl \
    jq

# Crea directory di lavoro
WORKDIR /app

# Copia package.json e installa dipendenze
COPY package*.json ./
RUN npm install

# Copia codice sorgente
COPY . .

# Esponi porta
EXPOSE 3000

# Comando di avvio
CMD ["npm", "start"]
