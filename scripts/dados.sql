-- Arquivo com informações de preenchimento das tabelas do aplicação com pelo menos 2 tuplas cada

-- CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
-- uuid_generate_v4()

-- Tipo de serviço: evento cultural, registro histórico, natureza, registro esportivo, divulgação
-- Tipo de hospedagem: hotel, motel, sítio, casa, apartamento, hostel, camping
-- Formas de pagamento: Moradia, Desconto em passagem, Dinheiro, Outros

-- ---------------- INSERINDO EM CONTRATANTE ---------------- --
INSERT INTO Contratante VALUES (
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
);

INSERT INTO Contratante VALUES (
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
INSERT INTO Oferta VALUES (
	'11111111111', -- documento do contratante (chave estrangeira)
	'Fotógrafo para divulgação de hotel fazenda', -- titulo
	'Desconto em passagem, Moradia', -- formas de pagamento
	'Hotel-fazenda Bela Vista', -- local
	'Precisa-se de fotógrafo para tirar fotos do hotel-fazenda a fim de inserí-las nas redes sociais e no site do hotel. O prósito do trabalho é atualizar fotos de divulgação pós reforma do hotel.', -- descricao
	'Divulgação' -- tipo de servico
);

INSERT INTO Oferta VALUES (
	'22222222222', -- documento do contratante
	'Fotógrafo de evento zen', -- titulo
	'Moradia, Outros', -- formas de pagamento
	'Mosteiro Sakya Tsarpa', -- local
	'Precisa-se de fotógrafo para fotografar evento de fim de ano que ocorrerá no mosteiro. O evento terá duração de 2 dias (fim de semana).', -- descricao
	'Evento cultural' -- tipo de servico
);

-- ---------------- INSERINDO EM BENEFICIO ---------------- --
INSERT INTO Beneficio VALUES (
	'11111111111', -- documento do contratante
	'Fotógrafo para divulgação de hotel fazenda', -- titulo
	'Desconto em passagem, Moradia', -- formas de pagamento
	'Desconto na passagem, estadia no hotel-fazenda, café da manhã e almoço no hotel, passeio de cavalo' -- descricao
);

INSERT INTO Beneficio VALUES (
	'22222222222', -- documento do contratante
	'Fotógrafo de evento zen', -- titulo
	'Moradia, Outros', -- formas de pagamento
	'Estadia no mosteiro durante uma semana, cursos de yoga e budismo com os monges do mosteiro, café da manhã, almoço e janta, sessões de meditação' -- descricao
);

-- ---------------- INSERINDO EM HOSPEDAGEM ---------------- --
INSERT INTO Hospedagem VALUES (
	'94735293', -- cep
	'Mosteiro Sakya Tsarpa', -- nome
	'Rodovia Ver. José de Moraes', -- logradouro
	30, -- numero
	NULL, -- complemento
	'Cabreúva', -- cidade
	'São Paulo', -- estado
  	'Brasil', -- brasil
  	'Sítio' -- tipo de hospedagem
);

INSERT INTO Hospedagem VALUES (
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
