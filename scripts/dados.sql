-- Arquivo com informações de preenchimento das tabelas do aplicação com pelo menos 2 tuplas cada

-- Tipo de serviço: evento cultural, registro histórico, natureza, registro esportivo, divulgação
-- Tipo de hospedagem: hotel, motel, sítio, casa, apartamento, hostel, camping
-- Formas de pagamento: Moradia, Desconto em passagem, Dinheiro, Outros

SET timezone = 'America/Sao_Paulo';
SHOW timezone;

CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- ---------------- INSERINDO EM CONTRATANTE ---------------- --
INSERT INTO Contratante (doc_cont, nome, email, telefone, rating, qtd_aval, logradouro, numero, complemento, cep, cidade, estado, pais, nb_servicos)
VALUES 
(
	'11111111111', -- documento do contratante
	'Contratante 1', -- nome
	'cont1@gmail.com', -- email
	'+55 1197890623', -- telefone
	NULL,-- rating
	DEFAULT, -- qtd. de avaliacoes
	'Rua XYZ', -- logradouro
	11, -- numero
	'apto 3', -- complemento
	'12345000', -- cep
	'Santos', -- cidade
	'São Paulo', -- estado
	'Brasil', -- pais
	DEFAULT -- numero de servicos
),
(
	'22222222222', -- documento do contratante
	'Contratante 2', -- nome
	'cont2@uol.com', -- email
	'+55 2733096754', -- telefone
	NULL,-- rating
	DEFAULT, -- qtd. de avaliacoes
	'Rua ABCD', -- logradouro
	22, -- numero
	'casa 1', -- complemento
	'11223123', -- cep
	'São Carlos', -- cidade
	'São Paulo', -- estado
	'Brasil', -- pais
	DEFAULT -- numero de servicos
);

-- ---------------- INSERINDO EM OFERTA ---------------- --
INSERT INTO Oferta (doc_cont,titulo,formas_pag,local,descricao,tipo_servico)
VALUES 
(
	'11111111111', -- documento do contratante (chave estrangeira)
	'Fotógrafo para divulgação de hotel fazenda', -- titulo
	'Desconto em passagem, Moradia', -- formas de pagamento
	'Hotel-fazenda Bela Vista', -- local
	'Precisa-se de fotógrafo para tirar fotos do hotel-fazenda a fim de inserí-las nas redes sociais e no site do hotel. O prósito do trabalho é atualizar fotos de divulgação pós reforma do hotel.', -- descricao
	'Divulgação' -- tipo de servico
),
(
	'22222222222', -- documento do contratante
	'Fotógrafo de evento zen', -- titulo
	'Moradia, Outros', -- formas de pagamento
	'Mosteiro Sakya Tsarpa', -- local
	'Precisa-se de fotógrafo para fotografar evento de fim de ano que ocorrerá no mosteiro. O evento terá duração de 2 dias (fim de semana).', -- descricao
	'Evento cultural' -- tipo de servico
);

-- ---------------- INSERINDO EM BENEFICIO ---------------- --
INSERT INTO Beneficio (doc_cont,titulo_oferta,formas_pag,descricao)
VALUES 
(
	'11111111111', -- documento do contratante
	'Fotógrafo para divulgação de hotel fazenda', -- titulo
	'Desconto em passagem, Moradia', -- formas de pagamento
	'Desconto na passagem, estadia no hotel-fazenda, café da manhã e almoço no hotel, passeio de cavalo' -- descricao
),
(
	'22222222222', -- documento do contratante
	'Fotógrafo de evento zen', -- titulo
	'Moradia, Outros', -- formas de pagamento
	'Estadia no mosteiro durante uma semana, cursos de yoga e budismo com os monges do mosteiro, café da manhã, almoço e janta, sessões de meditação' -- descricao
);

-- ---------------- INSERINDO EM HOSPEDAGEM ---------------- --
INSERT INTO Hospedagem (cep,nome,logradouro,numero,complemento,cidade,estado,pais,tipo)
VALUES
(
	'94735293', -- cep
	'Mosteiro Sakya Tsarpa', -- nome
	'Rodovia Ver. José de Moraes', -- logradouro
	30, -- numero
	NULL, -- complemento
	'Cabreúva', -- cidade
	'São Paulo', -- estado
  	'Brasil', -- brasil
  	'Sítio' -- tipo de hospedagem
),
(
	'12345000', -- cep
	'Hotel-fazenda Bela Vista', -- nome
	'Rua ABC', -- logradouro
	100, -- numero
	NULL, -- complemento
	'Guarujá', -- cidade
	'São Paulo', -- estado
  	'Brasil', -- brasil
  	'Hotel' -- tipo de hospedagem
);

-- ---------------- INSERINDO EM OFERECIMENTO HOSPEDAGEM ---------------- --
INSERT INTO OferecimentoHospadagem (doc_cont,titulo,formas_pag,cep,nome_hosp)
VALUES 
(
	'22222222222', -- documento do contratante
	'Fotógrafo de evento zen', -- titulo
	'Moradia, Outros', -- formas de pagamento
	'94735293', -- cep
	'Mosteiro Sakya Tsarpa' -- nome da hospedagem
),
(
	'11111111111', -- documento do contratante
	'Fotógrafo para divulgação de hotel fazenda', -- titulo
	'Desconto em passagem, Moradia', -- formas de pagamento
	'12345000', -- cep
	'Hotel-fazenda Bela Vista' -- nome
);

-- ---------------- INSERINDO EM FOTOGRAFO ---------------- --
INSERT INTO Fotografo (doc_fot, nome, email, telefone, rating, qtd_aval, nacionalidade, data_nasc, visualizacoes, nb_servicos) 
VALUES 
(
	'12312312300', -- documento do fotógrafo
	'Pedro Rogério Silva', -- nome
	'pedro_rog@gmail.com', -- email
	'21997564011', -- telefone
	NULL, -- rating
	DEFAULT, -- qtd. de avaliações
	'brasileiro', -- nacionalidade
	'1985-03-10', -- data de nascimento no formato YYYY-MM-DD
	DEFAULT, -- qtd. visualizações no perfil
	DEFAULT -- qtd. de serviços feitos 
),
(
	'49320549212', -- documento do fotógrafo
	'Lucca Romeu Matias Fausto', -- nome
	'luc_romeu11@outlook.com', -- email
	'16998091322', -- telefone
	NULL, -- rating
	DEFAULT, -- qtd. de avaliações
	'brasileiro', -- nacionalidade
	'1991-07-23', -- data de nascimento no formato YYYY-MM-DD
	DEFAULT, -- qtd. visualizações no perfil
	DEFAULT -- qtd. de serviços feitos 
);

-- ---------------- INSERINDO EM IDIOMA FOTOGRAFO ---------------- --
INSERT INTO IdiomaFotografo (doc_fot, idioma) 
VALUES 
	('12312312300', 'por'),
	('12312312300', 'jpn'),
	('12312312300', 'eng'),
	---
	('49320549212', 'por'),
	('49320549212', 'spa');

-- ---------------- INSERINDO EM PORTFOLIO FOTOGRAFO ---------------- --
INSERT INTO PortfolioFotografo (doc_fot, checksum, imagem_url)
VALUES
(	'12312312300',
	'3a474fbb5cf4d23afedfccfd0e604169',
	'https://images.app.goo.gl/uSuJkTu4L4quxay4A'
),
(
	'49320549212',
	'064a3859ecda245f83dac1f5b3210998',
	'https://images.app.goo.gl/ucF1z84qrKW4t7jb8'	
);

-- ---------------- INSERINDO EM PLANO VIAGEM ---------------- --
-- Generate UUID outside the database here (VERSION 4): https://www.uuidgenerator.net/version4
INSERT INTO PlanoViagem (id_plano, doc_fot, data_inicio, data_fim, nb_paradas, nb_servicos)
VALUES
(
	'92caa2c2-ac56-4971-bad0-7a43043ffdc6', --uuid_generate_v4()
	'12312312300',
	'2021-11-01 08:00:00', -- inicio do plano
	'2021-11-15 22:30:00', -- fim do plano
	1, -- nº de paradas
	1 -- nº de serviços
),
(
	'aff5598c-3d65-486a-89f1-d64b7145be19', --uuid_generate_v4()
	'49320549212',
	'2021-07-10 12:00:00', -- inicio do plano
	'2021-07-21 12:00:00', -- fim do plano
	1, -- nº de paradas
	1 -- nº de serviços
);

INSERT INTO Parada (id_parada, id_plano, data_chegada, data_saida, local)
VALUES
(
	'e4bace5c-e58f-11eb-ba80-0242ac130004', -- id da parada: uuid_generate_v4()
	'92caa2c2-ac56-4971-bad0-7a43043ffdc6', -- id do plano de viagem
	'2021-11-01 08:00:00', -- horário de inicio na parada
	'2021-11-15 22:30:00', -- horário de saída na parada
	'Hotel-fazenda Bela Vista' -- local
),
(
	'c779ad08-e590-11eb-ba80-0242ac130004', -- id da parada: uuid_generate_v4()
	'aff5598c-3d65-486a-89f1-d64b7145be19', -- id do plano
	'2021-07-10 12:00:00', -- horário de inicio na parada
	'2021-07-21 12:00:00', -- horário de fim na parada
	'Mosteiro Sakya Tsarpa' -- local
);

-- ---------------- INSERINDO EM RESERVA TRANSPORTE ---------------- --
INSERT INTO ReservaTransporte (nb_reserva,marca,modelo,tipo,horario,doc_fot)
VALUES
(
	'ABC123456', -- nº de reserva
	'Mitsubishi', -- marca
	'Pajero Sport', -- modelo
	'carro', -- tipo
	'2021-11-01 10:00:00', -- horário da reserva
	'12312312300' -- documento do fotógrafo
),
(
	'GEF420129', -- nº de reserva
	'Mitsubishi', -- marca
	'Pajero Sport', -- modelo
	'carro', -- tipo
	'2021-11-15 20:00:00', -- horário da reserva
	'12312312300' -- documento do fotógrafo
);

INSERT INTO Servico (doc_fot,doc_cont,titulo_oferta,formas_pag,data_inicio,data_fim,concluido,aval_fot,aval_cont,id_plano)
VALUES
(
	'12312312300',
	'11111111111',
	'Fotógrafo para divulgação de hotel fazenda',
	'Desconto em passagem, Moradia',
	'2021-11-01',
	'2021-11-30',
	FALSE,
	NULL,
	NULL,
	'92caa2c2-ac56-4971-bad0-7a43043ffdc6'

),
(
	'12312312300',
	'22222222222',
	'Fotógrafo de evento zen',
	'Moradia, Outros',
	'2021-12-10',
	'2021-12-17',
	FALSE,
	NULL,
	NULL,
	'92caa2c2-ac56-4971-bad0-7a43043ffdc6'
),
(
	'49320549212',
	'22222222222',
	'Fotógrafo de evento zen',
	'Moradia, Outros',
	'2021-07-05',
	'2021-07-22', 
	FALSE,
	NULL,
	NULL,
	'aff5598c-3d65-486a-89f1-d64b7145be19'
);