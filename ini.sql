-- Tabela Pessoa
CREATE TABLE Pessoa (
    id_pessoa INT AUTO_INCREMENT PRIMARY KEY,
    nome VARCHAR(100) NOT NULL,
    cpf CHAR(11) UNIQUE NOT NULL,
    telefone VARCHAR(15),
    email VARCHAR(100),
    endereco TEXT
);

-- Tabela Voluntario
CREATE TABLE Voluntario (
    id_voluntario INT AUTO_INCREMENT PRIMARY KEY,
    id_pessoa INT NOT NULL,
    cargo VARCHAR(50),
    data_admissao DATE,
    CONSTRAINT fk_pessoa_voluntario FOREIGN KEY (id_pessoa) REFERENCES Pessoa(id_pessoa) ON DELETE CASCADE
);

-- Tabela Beneficiario
CREATE TABLE Beneficiario (
    id_beneficiario INT AUTO_INCREMENT PRIMARY KEY,
    id_pessoa INT NOT NULL,
    renda DECIMAL(10, 2),
    CONSTRAINT fk_pessoa_beneficiario FOREIGN KEY (id_pessoa) REFERENCES Pessoa(id_pessoa) ON DELETE CASCADE
);

-- Tabela Dependente
CREATE TABLE Dependente (
    id_dependente INT AUTO_INCREMENT PRIMARY KEY,
    id_pessoa INT NOT NULL,
    CONSTRAINT fk_pessoa_dependente FOREIGN KEY (id_pessoa) REFERENCES Pessoa(id_pessoa) ON DELETE CASCADE
);

-- Tabela Beneficiario_Dependente (tabela de relacionamento)
CREATE TABLE Beneficiario_Dependente (
    id_beneficiario INT NOT NULL,
    id_dependente INT NOT NULL,
    PRIMARY KEY (id_beneficiario, id_dependente),
    CONSTRAINT fk_beneficiario_bd FOREIGN KEY (id_beneficiario) REFERENCES Beneficiario(id_beneficiario) ON DELETE CASCADE,
    CONSTRAINT fk_dependente_bd FOREIGN KEY (id_dependente) REFERENCES Dependente(id_dependente) ON DELETE CASCADE
);

-- Tabela Doacao
CREATE TABLE Doacao (
    id_doacao INT AUTO_INCREMENT PRIMARY KEY,
    id_voluntario INT,
    id_beneficiario INT NOT NULL,
    data_doacao DATE NOT NULL,
    CONSTRAINT fk_voluntario_doacao FOREIGN KEY (id_voluntario) REFERENCES Voluntario(id_voluntario) ON DELETE SET NULL,
    CONSTRAINT fk_beneficiario_doacao FOREIGN KEY (id_beneficiario) REFERENCES Beneficiario(id_beneficiario) ON DELETE CASCADE
);

-- Tabela Item
CREATE TABLE Item (
    id_item INT AUTO_INCREMENT PRIMARY KEY,
    tipo VARCHAR(50),
    descricao TEXT,
    tamanho VARCHAR(20),
    condicao VARCHAR(50)
);

-- Tabela Item_Doacao (tabela de relacionamento)
CREATE TABLE Item_Doacao (
    id_item INT NOT NULL,
    id_doacao INT NOT NULL,
    quantidade INT NOT NULL CHECK (quantidade > 0),
    PRIMARY KEY (id_item, id_doacao),
    CONSTRAINT fk_item_id FOREIGN KEY (id_item) REFERENCES Item(id_item) ON DELETE CASCADE,
    CONSTRAINT fk_doacao_id FOREIGN KEY (id_doacao) REFERENCES Doacao(id_doacao) ON DELETE CASCADE
);
