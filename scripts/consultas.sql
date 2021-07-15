-- Arquivo com 7 consultas complexas que podem ser feitas no banco




-- //TODO: A SEREM APROVADAS vv


-- Seleciona o rating médio dos contratantes que fizeram mais de um serviço com um dado fotógrafo em um dado local
SELECT O.local, AVG(C.rating), COUNT(*) FROM Contratante C 
	INNER JOIN Servico S ON C.doc_cont == S.doc_cont
	INNER JOIN Oferta O ON S.doc_cont == O.doc_cont and S.titulo_oferta == O.titulo and S.formas_pag == O.formas_pag
	WHERE O.local == "local_escolhido"
	GROUP BY S.doc_fot
	HAVING COUNT(*) > 2

-- Seleciona o local mais mencionado nas ofertas de cada contratante, bem como a quantidade de vezes que ele aparece
SELECT C.cont, O.local, count(*) FROM Contratante C
	INNER JOIN Oferta O ON C.doc_cont == O.doc_cont
	GROUP BY C.doc_cont, O.local
	HAVING max(count(*)) == (
		SELECT max(count(O2.local)) FROM Oferta O2 WHERE O2.doc_cont == C.doc_cont
	)

-- Média de tempo de reserva hospedagem agrupada por local de oferta de serviço
-- TODO: subtração de datas no postgree
-- TODO: dar nome para coluna AVG (como faz?)
SELECT O.local, AVG(P.data_saida - P.data_chegada) FROM Parada P
INNER JOIN ReservaHospedagem R ON P.id_parada == R.id_parada
INNER JOIN OferecimentoHospedagem OH ON R.cep_hosp == OH.cep and R.nome_hosp == OH.nome
INNER JOIN Oferta O ON O.doc_cont == OH.doc_cont and O.titulo == OH.titulo and O.formas_pag == OH.formas_pag
GROUP BY O.local
