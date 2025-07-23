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

# Expõe as portas necessárias (ajuste se necessário)
EXPOSE 5000 5001 5002 5003

# Define o comando de execução padrão
CMD ["python", "starter.py"]
