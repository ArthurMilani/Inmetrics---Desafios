# Usa a imagem base Python 3 mais recente
FROM python:3.12-slim

# Define o diretório de trabalho dentro do container
WORKDIR /app

# Copia o arquivo de dependências
COPY /requirements.txt .

# Instala as dependências
RUN pip install --no-cache-dir -r requirements.txt

# Copia todo o código da aplicação para o container
COPY . .

# Instala o NGINX
RUN apt-get update && apt-get install -y nginx && \
    rm -f /etc/nginx/sites-enabled/default && \
    rm -rf /var/lib/apt/lists/*

COPY nginx.conf /etc/nginx/sites-enabled/default

# Script para iniciar NGINX e as APIs
COPY start.sh .
RUN chmod +x start.sh

# Expõe as portas necessárias
EXPOSE 80

# Define o comando de execução padrão
CMD ["./start.sh"]
