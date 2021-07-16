	-- Arquivo com 7 consultas complexas que podem ser feitas no banco

	/*
	Inner join ==============================================>  [ usado em 4 ]
	Left/Right join =========================================>  [ usado em 1 ]
	Cross join
	Except ==================================================>	[ usado em 1 ]
	Where ===================================================>  [ usado em 6 ]
	Group by [having] =======================================>	[ usado em 2 ]
	Order by  ===============================================>	[ usado em 1 ]
	Distinct  ===============================================>	[ usado em 1 ]
	Agregação (max, avg, count, etc...) =====================>	[ usado em 2 ]
	EXISTS ==================================================>	[ usado em 2 ]
	IN
	when ... case ... else ...
	NESTED SELECTS ===========================================>  [ usado em 3 ]
	LIKE ====================================================>	[ usado em 1 ]
	UNION  ==================================================>  [ usado em 2 ]

	Assignment

	Álgebra Relacinal:
	Intersection
	Exclusive Union

	OBRIGATORIO TER UMA COM DIVISION: https://www.geeksforgeeks.org/sql-division/


	OBS: 
	Inner join com Left/Right join (a ordem importa)
	*/


	-- Seleciona todos os idiomas falados pelos fotógrafos que tem 
	-- o telefone começando com +55 (código do Brasil)
	SELECT DISTINCT I.idioma AS pais FROM Fotografo F, IdiomaFotografo I 
		WHERE F.telefone LIKE '+55%' AND F.doc_fot = I.doc_fot;

	-- Média de tempo que fotógrafos passam em cada local de hospedagem
	-- (de acordo com a hora de entrada e saída na hospedagem)
	-- agrupada por local de oferta de serviço
	SELECT O.local, AVG(R.data_fim - R.data_inicio) AS media_tempo 
	FROM ReservaHospedagem R
	INNER JOIN OferecimentoHospedagem OH ON
		R.cep_hosp = OH.cep AND 
		R.nome_hosp = OH.nome_hosp
	INNER JOIN Oferta O ON
		O.doc_cont = OH.doc_cont AND
		O.titulo = OH.titulo AND 
		O.formas_pag = OH.formas_pag
	GROUP BY O.local;

	-- Seleciona o rating médio dos contratantes que fizeram mais de um serviço em um dado local
	SELECT O.local, COALESCE(AVG(C.rating), -1), COUNT(*)
	FROM Contratante C 
	INNER JOIN Oferta O ON C.doc_cont = O.doc_cont
	WHERE O.local = 'Hotel-fazenda Bela Vista'
	GROUP BY C.doc_cont, O.local
	HAVING COUNT(*) > 1;

	-- Listas contratantes e fotógrafos do maior rating para menor rating
	SELECT C.nome AS nome_usuario, 'contratante' AS tipo, COALESCE(C.rating, -1) AS rating
	FROM Contratante C
	UNION
	SELECT F.nome AS nome_usuario, 'fotógrafo' AS tipo, COALESCE(F.rating, -1) AS rating
	FROM Fotografo F
	ORDER BY rating;
	-- COALESCE é usado para trocar os ratings nulos por 0

	-- Selecionar todas as hospedagem oferecidas por cada contratante as quais não tem qualquer reserva feita até o momento no ano atual
	SELECT OH.doc_cont AS contratante, H.Nome AS nome_hospedagem, H.tipo AS tipo_hospedagem
	FROM OferecimentoHospedagem OH, Hospedagem H
	WHERE 
		OH.cep = H.cep AND
		OH.nome_hosp = H.nome AND
		NOT EXISTS (
			SELECT RH.nome_hosp
			FROM ReservaHospedagem RH
			WHERE 
				EXTRACT(YEAR FROM NOW()) = EXTRACT(YEAR FROM RH.data_inicio) AND
				RH.nome_hosp = H.Nome
		);


	-- Seleciona o local mais mencionado nas ofertas de cada contratante, bem como a quantidade de vezes que ele aparece
	SELECT L.doc, MIN(L.local), R.max_qty AS max_qty FROM 
	(
		SELECT O.doc_cont as doc, O.local as local, COUNT(*) AS qty FROM Oferta O
		GROUP BY O.doc_cont, O.local
	) AS L
	LEFT JOIN
	(
		SELECT C.doc as doc, MAX(C.qty) as max_qty FROM (
			SELECT O.doc_cont as doc, O.local as local, COUNT(*) AS qty FROM Oferta O
			GROUP BY O.doc_cont, O.local
		) as C
		GROUP BY C.doc
	) AS R
	ON L.doc = R.doc and L.qty = R.max_qty
	WHERE R.max_qty IS NOT NULL
	GROUP BY L.doc, R.max_qty;

	-- Liste todos os contratantes que tem serviços com todos os fotógrafos (divisão)
	-- Obs.: SQL não implemeta diretamente "division" então ela foi implementada através de EXISTS e EXCEPT
	SELECT C.doc_cont, C.nome, COALESCE(C.rating, -1)
	FROM Contratante C
	WHERE NOT EXISTS (
		(
			SELECT F.doc_fot 
			FROM Fotografo F
		)
		EXCEPT 
		(
			SELECT S.doc_fot 
			FROM Servico S
			WHERE 
			C.doc_cont = S.doc_cont
		)
	);