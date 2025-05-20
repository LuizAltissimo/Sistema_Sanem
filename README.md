# 🧥 Sistema de Gerenciamento de Doações – SANEM

Este sistema foi desenvolvido para gerenciar de forma eficiente as doações recebidas e distribuídas pelo brechó beneficente da **SANEM**, uma iniciativa voltada ao atendimento de pessoas em situação de vulnerabilidade social.

---

## 🧑‍💻 Apresentação dos Alunos

Este projeto foi desenvolvido como parte de uma atividade acadêmica, da disciplina de Oficina de Desenvolvimento de Software do curso de Ciência da Computação da UTFPR - Medianeira.

### 👥 Equipe Técnica

| Nome                 | Função           |
|----------------------|------------------|
| **Ricardo Sobjak**       | Product Owner                |
| **Marcos Paulo Soares**  | Scrum Master                 |
| **Giovane Aguirre**      | Desenvolvedor                |
| **Henrique Triches**     | Desenvolvedor Back-End       |
| **Ellyson Vissotto**     | Desenvolvedor                |
| **Luiz Altissimo**       | Desenvolvedor Banco de dados |
| **Rafael Silva Vieira**  | Desenvolvedor Front-End      |

Cada integrante contribuirá nas fases de planejamento, desenvolvimento, testes e documentação da aplicação, utilizando a metodologia Scrum

---

## 🎯 Objetivo

O sistema visa:

- Controlar o **estoque** de itens doados;
- Cadastrar **beneficiários** que receberão os itens;
- Emitir **cartões físicos ou virtuais** com limites mensais de retirada;
- **Registrar e catalogar** todas as doações recebidas;
- **Gerar relatórios detalhados** sobre a entrada e saída de itens.

---

## 🛍️ Sobre o Brechó SANEM

A SANEM realiza atividades sociais com foco em inclusão e suporte comunitário. Entre elas, destaca-se o **brechó beneficente**, que distribui roupas, calçados e utensílios domésticos a famílias em situação de risco, com base em doações feitas por voluntários. Estas doações são organizadas, classificadas e disponibilizadas mediante critérios de elegibilidade.

---

## 🔧 Funcionalidades

- 📦 **Cadastro e controle de estoque**
- 🙋 **Gestão de beneficiários**
- 💳 **Emissão de cartão de retirada**
- 📊 **Relatórios de doações e distribuição**
- ✅ **Sistema de aprovação de beneficiários**
- 🔐 **Acesso restrito por perfil de usuário (admin, voluntário, etc.)**

---

## 🖥️ Tecnologias Utilizadas

- Node.js / Express
- PostgreSQL
- TypeScript
- React (Frontend)

---

## 🚀 Como Executar o Projeto

### Pré-requisitos

- Docker Desktop
- Node.js (versão 14 ou superior)
- npm ou yarn

### 📋 Passo a Passo

1. **Clone o repositório**
```bash
git clone https://github.com/LuizAltissimo/Sistema_Sanem.git
cd Sistema_Sanem
```

2. **Execute o script de inicialização**

No Windows:
```bash
npm run start:docker:win
```

No Linux/Mac:
```bash
npm run start:docker
```

Este script vai:
- Verificar se o Docker está rodando
- Iniciar o banco de dados PostgreSQL
- Instalar as dependências (se necessário)
- Compilar o projeto
- Executar os testes

### 🔧 Configuração Manual (se necessário)

1. **Configure as variáveis de ambiente**
   - Crie um arquivo `.env` na raiz do projeto:
   ```env
   DB_HOST=localhost
   DB_PORT=5432
   DB_NAME=sistema_sanem
   DB_USER=postgres
   DB_PASSWORD=postgres
   ```

2. **Inicie o banco de dados**
   ```bash
   docker-compose up -d
   ```

3. **Instale as dependências**
   ```bash
   npm install
   ```

4. **Compile o projeto**
   ```bash
   npm run build
   ```

5. **Execute os testes**
   ```bash
   npm test
   ```

### 📁 Estrutura do Projeto

```
src/
├── models/          # Classes de domínio
├── repositories/    # Classes de acesso ao banco
├── test.ts         # Script de demonstração
└── index.ts        # Ponto de entrada da aplicação

dist/               # Código compilado (gerado automaticamente)
database/
└── schema.sql     # Script de criação do banco
```

### 🔍 Explicação do Código

O projeto utiliza Programação Orientada a Objetos (POO) com as seguintes classes principais:

- `Pessoa`: Classe base para Voluntário e Beneficiário
- `Voluntario`: Representa um voluntário do sistema
- `Beneficiario`: Representa um beneficiário das doações
- `Item`: Representa um item que pode ser doado
- `Doacao`: Representa uma doação com seus itens

Cada classe possui seu respectivo repositório para operações no banco de dados.