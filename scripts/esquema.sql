-- Arquivo com informações de criação das tabelas no banco de dados

-- Tipo de serviço: evento cultural, registro histórico, natureza, registro esportivo, divulgação
-- Tipo de hospedagem: hotel, motel, sítio, casa, apartamento, hostel, camping, pousada
-- Formas de pagamento: moradia, desconto em passagem, dinheiro, outros

DROP DATABASE IF EXISTS db-turismo;
CREATE DATABASE db-turismo;

DROP TABLE IF EXISTS ReservaTransporte CASCADE;
DROP TABLE IF EXISTS ReservaHospedagem CASCADE;
DROP TABLE IF EXISTS Servico CASCADE;
DROP TABLE IF EXISTS Parada CASCADE;
DROP TABLE IF EXISTS PlanoViagem CASCADE;
DROP TABLE IF EXISTS IdiomaFotografo CASCADE;
DROP TABLE IF EXISTS PortfolioFotografo CASCADE;
DROP TABLE IF EXISTS OferecimentoHospedagem CASCADE;
DROP TABLE IF EXISTS Beneficio CASCADE;
DROP TABLE IF EXISTS Hospedagem CASCADE;
DROP TABLE IF EXISTS Oferta CASCADE;
DROP TABLE IF EXISTS Contratante CASCADE;
DROP TABLE IF EXISTS Fotografo CASCADE;


CREATE TABLE Contratante (
	doc_cont VARCHAR(20) NOT NULL,
	nome VARCHAR(80) NOT NULL, 
	email VARCHAR(50) NOT NULL, 
	telefone VARCHAR(25) NOT NULL, 
	rating SMALLINT,
	qtd_aval INT DEFAULT 0 CHECK (qtd_aval >= 0),
	logradouro VARCHAR(50), 
	numero SMALLINT NOT NULL, 
	complemento VARCHAR(15), 
	cep VARCHAR(12) NOT NULL, 
	cidade VARCHAR(30), 
	estado VARCHAR(30), 
	pais VARCHAR(30), 
	nb_servicos INT DEFAULT 0,
	CONSTRAINT pk_contratante PRIMARY KEY (doc_cont),
	CONSTRAINT unique_telefone_cont UNIQUE (telefone),
	CONSTRAINT unique_email_cont UNIQUE (email),
  	CHECK (nb_servicos >= 0),
	CHECK (rating >= 0 and rating <= 5),
  	CHECK (qtd_aval >= 0)
);

CREATE TABLE Oferta (
	doc_cont VARCHAR(20) NOT NULL, 
	titulo VARCHAR(60) NOT NULL, 
	formas_pag VARCHAR(30) NOT NULL, 
	local VARCHAR(50) NOT NULL, 
	descricao TEXT NOT NULL, 
	tipo_servico  VARCHAR(50) NOT NULL,
	CONSTRAINT pk_oferta PRIMARY KEY (doc_cont, titulo, formas_pag),
	CONSTRAINT fk_contratante FOREIGN KEY (doc_cont) REFERENCES Contratante(doc_cont) ON DELETE CASCADE,

	CHECK (tipo_servico IN ('evento cultural', 'registro histórico', 'natureza', 'registro esportivo', 'divulgação'))
);

CREATE TABLE Beneficio (
	doc_cont VARCHAR(20) NOT NULL,
	titulo_oferta VARCHAR(60) NOT NULL, 
	formas_pag VARCHAR(30) NOT NULL,
	descricao VARCHAR(200) NOT NULL,
	CONSTRAINT pk_beneficio PRIMARY KEY (doc_cont, titulo_oferta, formas_pag, descricao),
	CONSTRAINT fk_oferta FOREIGN KEY (doc_cont, titulo_oferta, formas_pag) REFERENCES Oferta(doc_cont, titulo, formas_pag) ON DELETE CASCADE
);

CREATE TABLE Hospedagem (
	cep VARCHAR(12) NOT NULL,
	nome VARCHAR(80) NOT NULL,
	logradouro VARCHAR(50), 
	numero SMALLINT NOT NULL,
	complemento VARCHAR(15),
	cidade VARCHAR(30),
	estado VARCHAR(30),
  	pais VARCHAR(30),
  	tipo VARCHAR(10),

  	CONSTRAINT pk_hospedagem PRIMARY KEY (cep,nome),

	CHECK (tipo IN ('hotel', 'motel', 'sítio', 'casa', 'apartamento', 'hostel', 'camping', 'pousada'))
);

CREATE TABLE OferecimentoHospedagem (
	doc_cont VARCHAR(20) NOT NULL,
	titulo VARCHAR(60) NOT NULL,
	formas_pag VARCHAR(30) NOT NULL,
	cep VARCHAR(12) NOT NULL,
	nome_hosp VARCHAR(80) NOT NULL,

	CONSTRAINT pk_oferecimento_hospedagem PRIMARY KEY (doc_cont, titulo, formas_pag, cep, nome_hosp),
	CONSTRAINT fk_oferta FOREIGN KEY (doc_cont, titulo, formas_pag) REFERENCES Oferta(doc_cont, titulo, formas_pag) ON DELETE CASCADE,
	CONSTRAINT fk_hospedagem FOREIGN KEY (cep, nome_hosp) REFERENCES Hospedagem(cep, nome) ON DELETE CASCADE
);

CREATE TABLE Fotografo (
	doc_fot VARCHAR(20) NOT NULL,
	nome VARCHAR(80) NOT NULL,
	email VARCHAR(50) NOT NULL,
	telefone VARCHAR(25) NOT NULL,
	rating SMALLINT,
	qtd_aval INT DEFAULT 0,
	nacionalidade VARCHAR(30) NOT NULL, --Todos os países podem ser representados por um código de tres caracteres (ISO 3166-1 alfa-3)
	data_nasc DATE NOT NULL, -- Somente a data (sem horário)
	visualizacoes INT DEFAULT 0,
	nb_servicos INT DEFAULT 0,
	CONSTRAINT pk_fotografo PRIMARY KEY(doc_fot),
	CONSTRAINT unique_telefone_fot UNIQUE (telefone),
	CONSTRAINT unique_email_fot UNIQUE (email),

	CHECK (qtd_aval >= 0),
	CHECK (rating >= 0 and rating <= 5),
	CHECK (visualizacoes >= 0),
	CHECK (nb_servicos >= 0),
	CHECK (LENGTH(nacionalidade) = 3)

);

CREATE TABLE IdiomaFotografo (
	doc_fot VARCHAR(20) NOT NULL,
	idioma CHAR(3) NOT NULL, -- Segundo ISO_639-2, 3 dígitos
	CONSTRAINT pk_idioma PRIMARY KEY (doc_fot, idioma),
	CONSTRAINT fk_fotografo FOREIGN KEY (doc_fot) REFERENCES Fotografo(doc_fot) ON DELETE CASCADE,
	
	CHECK (LENGTH(idioma) = 3)
);

CREATE TABLE PortfolioFotografo (
	doc_fot VARCHAR(20) NOT NULL,
	checksum VARCHAR(60) NOT NULL,
	imagem_url VARCHAR(80) NOT NULL, -- Iriamos usar OID (Object ID), que é a referência que o PostgreSQL faz ao arquivo inserido, mas nessa etapa foi observado que era melhor usar uma URL por simplicidade e economia de espaço (essa é a única diferença que há com relação ao projeto lógico!)
	CONSTRAINT pk_portifolio PRIMARY KEY (doc_fot, checksum),
	CONSTRAINT fk_fotografo FOREIGN KEY (doc_fot) REFERENCES Fotografo(doc_fot) ON DELETE CASCADE
);


CREATE TABLE PlanoViagem (
	id_plano UUID NOT NULL,
	doc_fot VARCHAR(20) NOT NULL,
	data_inicio TIMESTAMP NOT NULL,
	data_fim TIMESTAMP NOT NULL,
	nb_paradas SMALLINT DEFAULT 0,
	nb_servicos SMALLINT DEFAULT 0,
	CONSTRAINT pk_plano PRIMARY KEY (id_plano),
	CONSTRAINT fk_fotografo FOREIGN KEY (doc_fot) REFERENCES Fotografo(doc_fot) ON DELETE CASCADE,

	CONSTRAINT unique_plano_viagem UNIQUE (doc_fot, data_inicio, data_fim),

	CHECK (data_inicio < data_fim),
	CHECK (nb_paradas >= 0),
	CHECK (nb_servicos >= 0)
);


CREATE TABLE Parada (
	id_parada UUID NOT NULL,
	id_plano UUID NOT NULL,
	data_chegada TIMESTAMP NOT NULL,
	data_saida TIMESTAMP NOT NULL,
	local VARCHAR(70) NOT NULL,
	CONSTRAINT pk_parada PRIMARY KEY (id_parada),
	CONSTRAINT sec_key UNIQUE (id_plano, data_chegada, data_saida),
	CONSTRAINT fk_plano FOREIGN KEY (id_plano) REFERENCES PlanoViagem(id_plano) ON DELETE CASCADE,

	CHECK (data_chegada < data_saida)
);

CREATE TABLE ReservaHospedagem (
	nb_reserva VARCHAR(25) NOT NULL,
	data_inicio TIMESTAMP NOT NULL,
	data_fim TIMESTAMP NOT NULL,
	cep_hosp VARCHAR(12) NOT NULL,
	nome_hosp VARCHAR(80) NOT NULL,
	id_parada UUID,
	doc_fot VARCHAR(20) NOT NULL,
	CONSTRAINT pk_reserva_hospedagem PRIMARY KEY (nb_reserva),
	CONSTRAINT fk_parada FOREIGN KEY (id_parada) REFERENCES Parada(id_parada) ON DELETE SET NULL,
	CONSTRAINT fk_fotogafo FOREIGN KEY (doc_fot) REFERENCES Fotografo(doc_fot),
	CONSTRAINT fk_hospedagem FOREIGN KEY (cep_hosp, nome_hosp) REFERENCES Hospedagem(cep, nome),

	CHECK (data_inicio < data_fim)
);

CREATE TABLE ReservaTransporte (
	nb_reserva VARCHAR(25) NOT NULL,
	marca VARCHAR(15),
	modelo VARCHAR(20),
	tipo VARCHAR(15) NOT NULL,
	horario TIMESTAMP NOT NULL,
	doc_fot VARCHAR(20) NOT NULL,
	CONSTRAINT pk_reserva_transporte PRIMARY KEY (nb_reserva),
	CONSTRAINT fk_fotografo FOREIGN KEY (doc_fot) REFERENCES Fotografo(doc_fot),

	CHECK (tipo IN ('carro', 'avião', 'trem', 'navio', 'barco', 'moto', 'cavalo', 'metrô') )
);

CREATE TABLE Servico (
	doc_fot VARCHAR(20) NOT NULL,
	doc_cont VARCHAR(20) NOT NULL,
	titulo_oferta VARCHAR(60) NOT NULL,
	formas_pag VARCHAR(30) NOT NULL,
	data_inicio DATE NOT NULL,
	data_fim DATE NOT NULL,
	concluido BOOL,
	aval_fot SMALLINT,
	aval_cont SMALLINT,
	id_plano UUID, -- Validação de plano

	CONSTRAINT pk_servico PRIMARY KEY (doc_fot, doc_cont, titulo_oferta, formas_pag, data_inicio, data_fim),

	CONSTRAINT fk_serv_fotografo FOREIGN KEY (doc_fot) REFERENCES Fotografo(doc_fot),
	CONSTRAINT fk_serv_contratante FOREIGN KEY (doc_cont) REFERENCES Contratante(doc_cont),
	CONSTRAINT fk_oferta FOREIGN KEY (doc_cont, titulo_oferta, formas_pag) REFERENCES Oferta(doc_cont, titulo, formas_pag),
    CONSTRAINT fk_plano FOREIGN KEY (id_plano) REFERENCES PlanoViagem(id_plano) ON DELETE SET NULL,

	CHECK (data_inicio < data_fim)
);
