-- Tabela Pessoa
CREATE TABLE Pessoa (
    id_pessoa SERIAL PRIMARY KEY,
    nome VARCHAR(100) NOT NULL,
    cpf CHAR(11) UNIQUE NOT NULL,
    telefone VARCHAR(15),
    email VARCHAR(100),
    endereco TEXT
);

-- Tabela Voluntario
CREATE TABLE Voluntario (
    id_voluntario SERIAL PRIMARY KEY,
    id_pessoa INT NOT NULL,
    cargo VARCHAR(50),
    data_admissao DATE,
    CONSTRAINT fk_pessoa_voluntario FOREIGN KEY (id_pessoa) REFERENCES Pessoa(id_pessoa) ON DELETE CASCADE
);

-- Tabela Beneficiario
CREATE TABLE Beneficiario (
    id_beneficiario SERIAL PRIMARY KEY,
    id_pessoa INT NOT NULL,
    renda NUMERIC(10, 2),
    CONSTRAINT fk_pessoa_beneficiario FOREIGN KEY (id_pessoa) REFERENCES Pessoa(id_pessoa) ON DELETE CASCADE
);

-- Tabela Dependente
CREATE TABLE Dependente (
    id_dependente SERIAL PRIMARY KEY,
    id_pessoa INT NOT NULL,
    parentesco VARCHAR(50),
    CONSTRAINT fk_pessoa_dependente FOREIGN KEY (id_pessoa) REFERENCES Pessoa(id_pessoa) ON DELETE CASCADE
);

-- Tabela Beneficiario_Dependente
CREATE TABLE Beneficiario_Dependente (
    id_beneficiario INT NOT NULL,
    id_dependente INT NOT NULL,
    PRIMARY KEY (id_beneficiario, id_dependente),
    CONSTRAINT fk_beneficiario_bd FOREIGN KEY (id_beneficiario) REFERENCES Beneficiario(id_beneficiario) ON DELETE CASCADE,
    CONSTRAINT fk_dependente_bd FOREIGN KEY (id_dependente) REFERENCES Dependente(id_dependente) ON DELETE CASCADE
);

-- Tabela Item
CREATE TABLE Item (
    id_item SERIAL PRIMARY KEY,
    tipo VARCHAR(50),
    descricao TEXT,
    tamanho VARCHAR(20),
    condicao VARCHAR(50),
    categoria VARCHAR(50),
    status VARCHAR(20) DEFAULT 'DISPONIVEL'
);

-- Tabela Estoque
CREATE TABLE Estoque (
    id_item INT PRIMARY KEY,
    quantidade_disponivel INT NOT NULL DEFAULT 0,
    quantidade_minima INT NOT NULL DEFAULT 0,
    ultima_atualizacao TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_item_estoque FOREIGN KEY (id_item) REFERENCES Item(id_item) ON DELETE CASCADE
);

-- Tabela Limite_Mensal
CREATE TABLE Limite_Mensal (
    id_beneficiario INT PRIMARY KEY,
    limite_itens INT NOT NULL DEFAULT 5,
    mes_referencia DATE NOT NULL,
    itens_retirados INT NOT NULL DEFAULT 0,
    CONSTRAINT fk_beneficiario_limite FOREIGN KEY (id_beneficiario) REFERENCES Beneficiario(id_beneficiario) ON DELETE CASCADE
);

-- Tabela Cartao
CREATE TABLE Cartao (
    id_cartao SERIAL PRIMARY KEY,
    id_beneficiario INT NOT NULL,
    numero_cartao VARCHAR(20) UNIQUE NOT NULL,
    data_emissao DATE NOT NULL,
    data_validade DATE NOT NULL,
    status VARCHAR(20) NOT NULL DEFAULT 'ATIVO',
    CONSTRAINT fk_beneficiario_cartao FOREIGN KEY (id_beneficiario) REFERENCES Beneficiario(id_beneficiario) ON DELETE CASCADE
);

-- Tabela Doacao
CREATE TABLE Doacao (
    id_doacao SERIAL PRIMARY KEY,
    id_voluntario INT NOT NULL,
    id_beneficiario INT NOT NULL,
    data_doacao DATE NOT NULL,
    tipo_doacao VARCHAR(20) NOT NULL,
    status VARCHAR(20) NOT NULL DEFAULT 'PENDENTE',
    observacoes TEXT,
    CONSTRAINT fk_voluntario_doacao FOREIGN KEY (id_voluntario) REFERENCES Voluntario(id_voluntario) ON DELETE SET NULL,
    CONSTRAINT fk_beneficiario_doacao FOREIGN KEY (id_beneficiario) REFERENCES Beneficiario(id_beneficiario) ON DELETE CASCADE
);

-- Tabela Item_Doacao
CREATE TABLE Item_Doacao (
    id_item INT NOT NULL,
    id_doacao INT NOT NULL,
    quantidade INT NOT NULL CHECK (quantidade > 0),
    PRIMARY KEY (id_item, id_doacao),
    CONSTRAINT fk_item_id FOREIGN KEY (id_item) REFERENCES Item(id_item) ON DELETE CASCADE,
    CONSTRAINT fk_doacao_id FOREIGN KEY (id_doacao) REFERENCES Doacao(id_doacao) ON DELETE CASCADE
);

-- Tabela Requisito_Aprovacao
CREATE TABLE Requisito_Aprovacao (
    id_requisito SERIAL PRIMARY KEY,
    descricao TEXT NOT NULL,
    obrigatorio BOOLEAN NOT NULL DEFAULT true
);

-- Tabela Aprovacao_Beneficiario
CREATE TABLE Aprovacao_Beneficiario (
    id_beneficiario INT PRIMARY KEY,
    data_solicitacao TIMESTAMP NOT NULL,
    data_aprovacao TIMESTAMP,
    status VARCHAR(20) NOT NULL DEFAULT 'PENDENTE',
    observacoes TEXT,
    CONSTRAINT fk_beneficiario_aprovacao FOREIGN KEY (id_beneficiario) REFERENCES Beneficiario(id_beneficiario) ON DELETE CASCADE
);

-- Tabela Relatorio
CREATE TABLE Relatorio (
    id_relatorio SERIAL PRIMARY KEY,
    tipo_relatorio VARCHAR(50) NOT NULL,
    data_geracao TIMESTAMP NOT NULL,
    periodo_inicio DATE NOT NULL,
    periodo_fim DATE NOT NULL,
    dados_relatorio JSONB NOT NULL,
    usuario_gerador INT NOT NULL
);

-- Tabela Log_Operacao
CREATE TABLE Log_Operacao (
    id_log SERIAL PRIMARY KEY,
    tipo_operacao VARCHAR(50) NOT NULL,
    data_operacao TIMESTAMP NOT NULL,
    usuario_id INT NOT NULL,
    detalhes JSONB NOT NULL
);

-- Tabela Usuario
CREATE TABLE Usuario (
    id_usuario SERIAL PRIMARY KEY,
    id_pessoa INT NOT NULL,
    login VARCHAR(50) UNIQUE NOT NULL,
    senha_hash VARCHAR(255) NOT NULL,
    nivel_acesso VARCHAR(20) NOT NULL,
    status VARCHAR(20) NOT NULL DEFAULT 'ATIVO',
    CONSTRAINT fk_pessoa_usuario FOREIGN KEY (id_pessoa) REFERENCES Pessoa(id_pessoa) ON DELETE CASCADE
); 