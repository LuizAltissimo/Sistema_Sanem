# 🏥 SANEM - Sistema de Gerenciamento de Doações

> **Sistema completo para gestão de doações e apoio a pessoas em vulnerabilidade social**

[![React](https://img.shields.io/badge/React-18.0-blue.svg)](https://reactjs.org/)
[![TypeScript](https://img.shields.io/badge/TypeScript-5.0-blue.svg)](https://typescriptlang.org/)
[![Supabase](https://img.shields.io/badge/Supabase-Database-green.svg)](https://supabase.com/)
[![Tailwind CSS](https://img.shields.io/badge/Tailwind_CSS-3.0-38B2AC.svg)](https://tailwindcss.com/)

## 🚀 Tecnologias

- **Frontend**: React 18 + TypeScript + Vite
- **Styling**: Tailwind CSS + shadcn/ui
- **Backend**: Supabase (PostgreSQL)
- **Autenticação**: Sistema customizado com Supabase
- **Estado**: Context API + React Query
- **Validação**: Zod + React Hook Form
- **Linting**: ESLint + TypeScript ESLint
- **Icons**: Lucide React
- **Motion**: Framer Motion

## 📁 Estrutura do Projeto

```
src/
├── components/          # Componentes reutilizáveis
│   ├── common/         # Componentes comuns (LoadingSpinner, ErrorBoundary)
│   ├── ui/             # Componentes de UI (shadcn/ui)
│   ├── AppSidebar.tsx  # Sidebar principal com navegação
│   ├── ProtectedRoute.tsx # Proteção de rotas por permissão
│   └── ThemeToggle.tsx # Alternador de tema claro/escuro
├── contexts/           # React Contexts
│   └── AuthContext.tsx # Contexto de autenticação e permissões
├── hooks/              # Custom hooks
│   ├── useLocalStorage.ts
│   ├── useTheme.tsx
│   └── use-toast.ts
├── pages/              # Páginas da aplicação
│   ├── Index.tsx       # Página de login
│   ├── Dashboard.tsx   # Dashboard principal
│   ├── Beneficiarios.tsx # Gestão de beneficiários
│   ├── Cadastro.tsx    # Cadastro de pessoas
│   ├── Doacoes.tsx     # Controle de doações
│   ├── Estoque.tsx     # Gestão de estoque
│   ├── Distribuicao.tsx # Distribuição de itens
│   ├── Relatorios.tsx  # Relatórios e análises
│   ├── Perfil.tsx      # Perfil do usuário
│   ├── GestaoUsuarios.tsx # Gestão de usuários (Admin)
│   └── NotFound.tsx    # Página 404
├── types/              # Definições de tipos TypeScript
├── constants/          # Constantes e permissões
├── utils/              # Funções utilitárias
├── integrations/       # Integrações externas
│   └── supabase/      # Cliente e tipos do Supabase
└── lib/               # Configurações e utilitários
```

## 🗄️ Estrutura do Banco de Dados

O sistema utiliza **16 tabelas** organizadas logicamente:

### 👥 **Gestão de Pessoas**
- `users` - Usuários do sistema (superadmin, admin, voluntario)
- `beneficiarios` - Pessoas que recebem as doações
- `dependentes` - Familiares dos beneficiários  
- `doadores` - Pessoas/empresas que fazem doações

### 📦 **Controle de Estoque**
- `categorias_produtos` - Categorias (roupas, calçados, etc.)
- `produtos` - Itens individuais do estoque
- `movimentacoes_estoque` - Histórico de entrada/saída

### 🎁 **Gestão de Doações**
- `doacoes` - Registro das doações recebidas
- `itens_doacao` - Produtos específicos de cada doação

### 📋 **Controle de Distribuição**
- `distribuicoes` - Entregas para beneficiários
- `itens_distribuicao` - Produtos específicos distribuídos

### ⚙️ **Sistema e Controle**
- `audit_logs` - Logs de auditoria
- `configuracoes_sistema` - Configurações do sistema
- `notificacoes` - Sistema de notificações
- `atividades_sistema` - Atividades para o dashboard
- `periodos_mensais` - Controle de períodos e limites

## 🔧 Configuração do Ambiente

> **💡 O projeto utiliza um banco de dados compartilhado no Supabase. Todas as máquinas de desenvolvimento podem usar o mesmo banco para ter acesso aos mesmos dados.**

### **🚀 Como Configurar em uma Nova Máquina**

### 1. **Clone o repositório**
```bash
git clone https://github.com/rafavieira1/sanem.git
cd sanem
```

### 2. **Instale as dependências**
```bash
npm install
```

### 3. **Configure o banco existente**

Crie o arquivo `.env.local` na raiz do projeto com as credenciais do banco já configurado:

```env
# Banco de dados SANEM já configurado (use estas credenciais)
VITE_SUPABASE_URL=https://jqpfqwbzdpdvguoulmff.supabase.co
VITE_SUPABASE_ANON_KEY=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImpxcGZxd2J6ZHBkdmd1b3VsbWZmIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTAwOTU0NjgsImV4cCI6MjA2NTY3MTQ2OH0.ryOYXPDk72A-Qukjf9lq8-BjdiiCMQGsoBQLxPbK764
```

### 4. **Execute o projeto**
```bash
npm run dev
```

### 5. **Acesse o sistema**
- **URL:** `http://localhost:5173`
- **Email:** `superadmin@sanem.org`
- **Senha:** `123`
- **Papel:** Super Administrador

### ✅ **Vantagens desta Configuração:**
- ✅ Banco já contém **todas as 16 tabelas** criadas
- ✅ **Usuário superadmin** já configurado
- ✅ **Dados de exemplo** disponíveis
- ✅ **Configurações padrão** já inseridas
- ✅ **Funciona imediatamente** sem configuração adicional
- ✅ **Dados sincronizados** entre todas as máquinas da equipe

---

## 🔍 **Verificação da Instalação**

### **Como saber se deu certo:**
1. Execute `npm run dev`
2. Acesse `http://localhost:5173`
3. Faça login com `superadmin@sanem.org` / `123`
4. Se aparecer o **Dashboard** = ✅ **Sucesso!**

### **Problemas comuns:**

| Problema | Solução |
|----------|---------|
| ❌ **Erro de conexão** | Verifique se copiou corretamente as credenciais no `.env.local` |
| ❌ **Login falha** | Confirme que está usando `superadmin@sanem.org` / `123` |
| ❌ **Página em branco** | Execute `npm install` e depois `npm run dev` novamente |
| ❌ **Erro de CORS** | Certifique-se que está acessando `http://localhost:5173` |
| ❌ **Módulos não encontrados** | Execute `rm -rf node_modules && npm install` |

### **📋 Checklist de verificação:**
- [ ] Arquivo `.env.local` criado na raiz do projeto
- [ ] Credenciais copiadas exatamente como mostrado
- [ ] `npm install` executado sem erros
- [ ] `npm run dev` rodando na porta 5173
- [ ] Navegador acessando `http://localhost:5173`

---

## 👥 **Desenvolvimento em Equipe**

**O sistema foi configurado para ser usado por múltiplos desenvolvedores:**
- 🌐 **Banco único compartilhado** - Todos acessam o mesmo banco de dados
- 📁 **Mesmo `.env.local`** - Todas as máquinas usam as mesmas credenciais
- 🔄 **Dados sincronizados** - Mudanças são visíveis para toda equipe em tempo real
- 👥 **Colaboração facilitada** - Teste com dados reais e consistentes
- 🚀 **Setup rápido** - Nova máquina funciona em menos de 5 minutos

### **⚙️ Para Novos Membros da Equipe:**
1. Clone o repositório
2. Copie o arquivo `.env.local` (peça para qualquer membro da equipe)
3. Execute `npm install && npm run dev`
4. Pronto! Está usando o mesmo banco que todos os outros

## 🎯 Funcionalidades Implementadas

### ✅ **Sistema de Autenticação**
- Login com níveis de acesso (superadmin, admin, voluntario)
- Controle de permissões por rota
- Persistência de sessão
- Logout seguro

### ✅ **Dashboard Inteligente**
- Estatísticas em tempo real
- Gráficos de atividades recentes
- Alertas e ações urgentes
- Ações rápidas

### ✅ **Gestão Completa de Beneficiários**
- Cadastro completo com dependentes
- Controle de limites mensais
- Status (ativo, inativo, limite atingido)
- Histórico de distribuições

### ✅ **Sistema de Doações**
- Cadastro de doadores (pessoa física/jurídica)
- Registro de doações (dinheiro, produtos, mista)
- Controle de status (pendente, processada, cancelada)
- Relacionamento com produtos doados

### ✅ **Controle de Estoque Avançado**
- Categorização de produtos
- Controle de quantidade mínima
- Alertas de estoque baixo
- Histórico de movimentações
- Estados de conservação

### ✅ **Sistema de Distribuição**
- Registro de entregas para beneficiários
- Controle de limites mensais
- Alertas para beneficiários próximos ao limite
- Histórico completo

### ✅ **Relatórios Gerenciais**
- 9 tipos diferentes de relatórios
- Filtros por período
- Permissões específicas por tipo
- Interface de exportação

### ✅ **Gestão de Usuários (Admin)**
- CRUD completo de usuários
- Controle de papéis e permissões
- Histórico de acessos
- Políticas de segurança

### ✅ **Sistema de Configurações**
- Configurações globais do sistema
- Limites padrão personalizáveis
- Preferências de interface
- Controle de notificações

### ✅ **Interface Moderna**
- Design responsivo (mobile-first)
- Tema claro/escuro
- Efeitos visuais (Framer Motion)
- Componentes acessíveis

## 👥 Níveis de Acesso e Permissões

### 🔴 **Super Administrador**
- **Acesso:** Completo ao sistema
- **Permissões:**
  - Gerenciamento de usuários
  - Configurações do sistema
  - Todos os relatórios
  - Logs de auditoria
  - Gestão completa de todas as funcionalidades

### 🟡 **Administrador**
- **Acesso:** Operacional completo
- **Permissões:**
  - Gestão de beneficiários, doações, estoque
  - Controle de distribuições
  - Relatórios operacionais
  - **Sem acesso:** Gestão de usuários e configurações

### 🟢 **Voluntário**
- **Acesso:** Operações básicas
- **Permissões:**
  - Dashboard básico
  - Gestão de beneficiários
  - Registro de doações
  - **Sem acesso:** Estoque, distribuições, relatórios


## 🔒 Segurança Implementada

### **Autenticação e Autorização**
- Sistema de login seguro
- JWT para sessões
- Controle de permissões granular
- Políticas RLS no Supabase

### **Validação de Dados**
- Validação client-side com Zod
- Sanitização de entradas
- Validação de formulários
- Constraints no banco de dados

### **Auditoria**
- Log de todas as ações importantes
- Rastreamento de alterações
- Histórico de acessos
- Monitoramento de atividades

## 🌐 Deploy e Produção

### **Plataformas Suportadas**
- ✅ Vercel (recomendado)
- ✅ Netlify
- ✅ GitHub Pages
- ✅ Qualquer hosting estático

### **Configuração para Deploy**
1. Configure as variáveis de ambiente na plataforma
2. Execute `npm run build`
3. Deploy da pasta `dist/`

### **Variáveis de Ambiente em Produção**
```env
VITE_SUPABASE_URL=your_production_supabase_url
VITE_SUPABASE_ANON_KEY=your_production_supabase_anon_key
```

## 📊 Métricas do Projeto

- **Páginas:** 10 páginas principais
- **Componentes:** 25+ componentes reutilizáveis
- **Tabelas BD:** 16 tabelas relacionais
- **Tipos TS:** 20+ interfaces e tipos
- **Permissões:** 8 níveis de permissão
- **Relatórios:** 9 tipos diferentes

## 🚧 Roadmap de Melhorias

### **Versão 2.0 (Planejado)**
- [ ] Sistema de backup automático
- [ ] Notificações push
- [ ] API REST para integrações
- [ ] Dashboard de métricas avançado
- [ ] Sistema de aprovação de distribuições
- [ ] Integração com sistemas de pagamento
- [ ] App mobile (React Native)

### **Funcionalidades Extras**
- [ ] Impressão de recibos
- [ ] Código de barras para produtos
- [ ] Sistema de reservas
- [ ] Chat interno entre usuários
- [ ] Integração com redes sociais

## 🤝 Contribuição

### **Como Contribuir**
1. Fork o projeto
2. Crie uma branch: `git checkout -b feature/nova-funcionalidade`
3. Commit: `git commit -m 'Add: nova funcionalidade'`
4. Push: `git push origin feature/nova-funcionalidade`
5. Abra um Pull Request

### **Padrões de Commit**
- `feat:` nova funcionalidade
- `fix:` correção de bug
- `docs:` documentação
- `style:` formatação
- `refactor:` refatoração
- `test:` testes

## 📄 Licença

Este projeto está sob a licença MIT. Veja o arquivo [LICENSE](LICENSE) para mais detalhes.

## 🆘 Suporte e Contato

---

<div align="center">

**Desenvolvido por Rafael Vieira para apoiar comunidades em vulnerabilidade social**

[![Made with React](https://img.shields.io/badge/Made_with-React-blue.svg)](https://reactjs.org/)
[![Powered by Supabase](https://img.shields.io/badge/Powered_by-Supabase-green.svg)](https://supabase.com/)
[![Built with TypeScript](https://img.shields.io/badge/Built_with-TypeScript-blue.svg)](https://typescriptlang.org/)

</div>
