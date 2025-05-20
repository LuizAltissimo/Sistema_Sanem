#!/bin/bash

# Verifica se o Docker está rodando
if ! docker info > /dev/null 2>&1; then
    echo "Docker não está rodando. Por favor, inicie o Docker Desktop."
    exit 1
fi

# Para qualquer container existente
docker-compose down

# Inicia o banco de dados
docker-compose up -d

# Aguarda o banco estar pronto
echo "Aguardando o banco de dados iniciar..."
sleep 5

# Instala dependências se necessário
if [ ! -d "node_modules" ]; then
    echo "Instalando dependências..."
    npm install
fi

# Compila o TypeScript
echo "Compilando o projeto..."
npm run build

# Executa o teste
echo "Executando os testes..."
npm test 