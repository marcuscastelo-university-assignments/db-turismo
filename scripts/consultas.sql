-- Arquivo com 7 consultas complexas que podem ser feitas no banco

/*
Inner join ==============================================>  [ usado em 2 ]
Left/Right join
Cross join
Except
Where ===================================================>  [ usado em 2 ]
Group by [having] =======================================>	[ usado em 1 ]
Order by  ===============================================>	[ usado em 1 ]
Distinct 
Agregação (max, avg, count, etc...) =====================>	[ usado em 1 ]
EXISTS ==================================================>	[ usado em 1 ]
IN
when ... case ... else ...
Nested select ===========================================>  [ usado em 1 ]

Assignment

Álgebra Relacinal:
Minus (A - B (conjuntos))
Intersection
Union  ==================================================>  [ usado em 1 ]
Exclusive Union

OBRIGATORIO TER UMA COM DIVISION: https://www.geeksforgeeks.org/sql-division/


OBS: 
Inner join com Left/Right join (a ordem importa)
*/

-- Seleciona o rating médio dos contratantes que fizeram mais de um serviço em um dado local
SELECT O.local, AVG(C.rating), COUNT(*)
FROM Contratante C 
INNER JOIN Oferta O ON C.doc_cont = O.doc_cont
WHERE O.local = 'Hotel-fazenda Bela Vista'
GROUP BY C.doc_cont, O.local
HAVING COUNT(*) > 2;

-- Listas contratantes e fotógrafos do maior rating para menor rating
SELECT C.nome AS nome_usuario, 'contratante' AS tipo, COALESCE(C.rating, 0) AS rating
FROM Contratante C
UNION
SELECT F.nome AS nome_usuario, 'fotógrafo' AS tipo, COALESCE(F.rating, 0) AS rating
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





------------------------ EM DESENVOLVIMENTO: ------------------------

-- Seleciona o local mais mencionado nas ofertas de cada contratante, bem como a quantidade de vezes que ele aparece
SELECT doc, local, qty FROM (
	SELECT O.doc_cont as doc, O.local as local, COUNT(*) AS qty FROM Oferta O
	GROUP BY O.doc_cont, O.local
) 
	
ON a.adoc = b.bdoc and a.alocal = b.blocal and a.aqty < b.bqty
WHERE b.bdoc IS NULL;

SELECT C.doc_cont as contratante, MAX(ML.qty) as ofertas_no_local FROM Contratante C INNER JOIN (
	SELECT O.doc_cont, O.local, COUNT(*) AS qty FROM Oferta O
	GROUP BY O.doc_cont, O.local
) ML ON C.doc_cont = ML.doc_cont
GROUP BY C.doc_cont;

-- Média de tempo de reserva hospedagem agrupada por local de oferta de serviço
-- TODO: subtração de datas no postgree
-- TODO: dar nome para coluna AVG (como faz?)
SELECT O.local, AVG(P.data_saida - P.data_chegada) FROM Parada P
INNER JOIN ReservaHospadagem R ON P.id_parada = R.id_parada
INNER JOIN OferecimentoHospedagem OH ON R.cep_hosp = OH.cep and R.nome_hosp = OH.nome
INNER JOIN Oferta O ON O.doc_cont = OH.doc_cont and O.titulo = OH.titulo and O.formas_pag = OH.formas_pag
GROUP BY O.local;

--
SELECT * FROM R as sx
WHERE NOT EXISTS (
	(SELECT p.y FROM S as p )
	EXCEPT
	(SELECT sp.y FROM  R as sp WHERE sp.x = sx.x ) 
	);

