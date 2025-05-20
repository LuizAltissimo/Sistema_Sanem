@echo off

REM Verifica se o Docker está rodando
docker info > nul 2>&1
if errorlevel 1 (
    echo Docker não está rodando. Por favor, inicie o Docker Desktop.
    exit /b 1
)

REM Para qualquer container existente
docker-compose down

REM Inicia o banco de dados
docker-compose up -d

REM Aguarda o banco estar pronto
echo Aguardando o banco de dados iniciar...
timeout /t 5 /nobreak

REM Instala dependências se necessário
if not exist node_modules (
    echo Instalando dependências...
    npm install
)

REM Compila o TypeScript
echo Compilando o projeto...
npm run build

REM Executa o teste
echo Executando os testes...
npm test 