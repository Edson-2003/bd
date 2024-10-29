-- ATIVIDADE 1 BANCO DE DADOS


-- consulta 1
SELECT * FROM produto ORDER BY nome ASC;

-- consulta 2
SELECT * FROM mercado ORDER BY nome DESC;

-- consulta 3
SELECT id, id*1000, nome FROM mercado ORDER BY nome DESC;
 
-- consulta 4
SELECT * FROM pesquisa ORDER BY mercado_id, produto_id;

-- consulta 5

SELECT * FROM cesta;

-- consulta 6
SELECT * FROM produto_cesta ORDER BY id ASC;

-- consulta 7
SELECT nome, id, unidade_medida FROM produto ORDER BY nome ASC;

-- consulta 8
SELECT nome, unidade_medida, id FROM produto ORDER BY nome ASC;

-- consulta 9
SELECT produto_cesta.cesta_codigo AS codigo,
       cesta.nome,
       produto.quant_minima AS quantidade,
       produto.unidade_medida, 
       produto.nome
FROM produto_cesta
JOIN cesta ON (produto_cesta.cesta_codigo = cesta.codigo)
JOIN produto ON (produto.id = produto_cesta.produto_id)
ORDER BY cesta_codigo, produto.nome ASC;

-- consulta 10
SELECT pesquisa.produto_id,
       produto.nome,
       pesquisa.mercado_id,
       mercado.nome,
       pesquisa.preco
FROM pesquisa
JOIN produto ON (produto.id = pesquisa.produto_id)
JOIN mercado ON (mercado.id = pesquisa.mercado_id)
ORDER BY produto.nome, mercado.nome ASC;

-- consulta 11
SELECT pesquisa.produto_id,
       produto.nome,
       pesquisa.mercado_id,
       mercado.nome,
       pesquisa.preco
FROM pesquisa
JOIN produto ON (produto.id = pesquisa.produto_id)
JOIN mercado ON (mercado.id = pesquisa.mercado_id)
ORDER BY produto.nome, pesquisa.preco ASC;

-- consulta 12
SELECT pesquisa.mercado_id AS id,
       mercado.nome, 
       pesquisa.produto_id AS id, 
       produto.nome, pesquisa.preco 
FROM pesquisa 
JOIN produto ON (pesquisa.produto_id = produto.id) 
JOIN mercado ON (pesquisa.mercado_id = mercado.id) 
ORDER BY mercado.nome, produto.nome ASC;

-- consulta 13

SELECT mercado.nome,
       produto.nome, 
       pesquisa.preco 
FROM pesquisa 
JOIN mercado ON (pesquisa.mercado_id = mercado.id) 
JOIN produto ON (pesquisa.produto_id = produto.id) 
WHERE pesquisa.mercado_id = 30 
ORDER BY produto.nome ASC;

-- consulta 14

sELECT produto_cesta.cesta_codigo AS codigo,
       cesta.nome,
       pesquisa.mercado_id AS id,
       mercado.nome,
       produto_cesta.quantidade,
       produto.unidade_medida,
       produto.nome,
       pesquisa.preco,
       (pesquisa.preco * produto_cesta.quantidade) AS preco_total
FROM pesquisa
JOIN produto ON (pesquisa.produto_id = produto.id)
JOIN produto_cesta ON (produto.id = produto_cesta.produto_id)
JOIN cesta ON (cesta.codigo = produto_cesta.cesta_codigo)
JOIN mercado ON (pesquisa.mercado_id = mercado.id)
ORDER BY cesta.codigo, mercado.nome, produto.nome ASC;

-- consulta 15

SELECT cesta.nome AS nome_cesta,
       mercado.nome AS nome_mercado,
       produto_cesta.quantidade,
       produto.unidade_medida,
       produto.nome,
       pesquisa.preco,
       (pesquisa.preco * produto_cesta.quantidade) AS preco_total
FROM pesquisa
JOIN produto ON (pesquisa.produto_id = produto.id)
JOIN produto_cesta ON (produto.id = produto_cesta.produto_id)
JOIN cesta ON (cesta.codigo = produto_cesta.cesta_codigo)
JOIN mercado ON (pesquisa.mercado_id = mercado.id) 
WHERE (mercado.id = 20)
ORDER BY cesta.codigo, mercado.nome, produto.nome ASC;


-- consulta 16
SELECT produto.nome, 
       MIN(pesquisa.preco) AS menor_preco, 
       MAX(pesquisa.preco) AS maior_preco, 
       AVG(pesquisa.preco) AS media
FROM pesquisa
JOIN produto ON (produto.id = pesquisa.produto_id)
GROUP BY produto.nome
ORDER BY produto.nome;

-- consulta 17
SELECT cesta.nome AS cesta_nome,
       mercado.nome AS nome_mercado,
       SUM(pesquisa.preco * produto_cesta.quantidade) AS preco_total
FROM pesquisa
JOIN mercado ON (pesquisa.mercado_id = mercado.id)
JOIN produto ON (pesquisa.produto_id = produto.id)
JOIN produto_cesta ON (produto.id = produto_cesta.produto_id)
JOIN cesta ON (produto_cesta.cesta_codigo = cesta.codigo) 
GROUP BY mercado.nome, cesta.nome
ORDER BY cesta_nome, preco_total; 
