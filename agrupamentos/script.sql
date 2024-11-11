-- CONSULTA 1
SELECT * FROM objetos ORDER BY id ASC;

-- CONSULTA 2
SELECT * FROM objeto WHERE (cor = 'amarelo') ORDER BY id ASC;

-- CONSULTA 3
SELECT * 
FROM objeto 
WHERE (forma = 'círculo') AND (cor = 'amarelo') 
ORDER BY id ASC;

-- CONSULTA 4
SELECT tamanho 
FROM objeto 
GROUP BY tamanho 
ORDER BY tamanho ASC;

-- CONSULTA 5
SELECT forma 
FROM objeto 
GROUP BY forma 
ORDER BY forma ASC;

-- CONSULTA 6
SELECT forma, 
       tamanho 
FROM objeto 
GROUP BY forma, tamanho 
ORDER BY forma, tamanho ASC;

-- CONSULTA 7
SELECT forma, 
       tamanho, 
       COUNT(forma) 
FROM objeto 
GROUP BY forma, tamanho 
ORDER BY forma, tamanho ASC;

-- CONSULTA 8
SELECT forma, 
       COUNT(forma) 
FROM objeto 
GROUP BY forma 
ORDER BY forma DESC;

-- CONSULTA 9
SELECT tamanho, 
       COUNT(tamanho) 
FROM objeto 
GROUP BY tamanho;

-- CONSULTA 10
SELECT forma, 
       MAX(tamanho) 
FROM objeto 
GROUP BY forma;

-- CONSULTA 11
SELECT forma, 
       COUNT(forma), 
       MAX(id) AS id_maximo, 
       MIN(tamanho) AS tamanho_min, 
       MAX(tamanho) AS tamanho_max 
FROM objeto 
GROUP BY forma;

-- CONSULTA 12
SELECT id, forma 
FROM objeto 
WHERE (forma = 'triângulo');

-- CONSULTA 13
SELECT cor,
       AVG(tamanho), 
       CAST(AVG(tamanho) AS DECIMAL(8,2)) 
FROM objeto 
GROUP BY cor;

-- CONSULTA 14
SELECT AVG(tamanho), 
       forma 
FROM objeto 
GROUP BY forma;

-- CONSULTA 15
SELECT cor, 
       MAX(forma) 
FROM objeto 
GROUP BY cor;

-- CONSULTA 16
SELECT forma 
FROM objeto 
GROUP BY forma 
ORDER BY forma ASC;

-- constulta 17
SELECT cor 
FROM objeto 
ORDER BY cor asc;

-- CONSULTA 18
SELECT cor, 
       CHAR_LENGTH(cor) AS numero_caracteres 
FROM objeto 
GROUP BY cor 
ORDER BY cor ASC;

-- CONSULTA 19
SELECT MIN(cor), 
       MAX(cor), 
       MIN(tamanho), 
       MAX(tamanho), 
       MIN(forma), 
       MAX(forma), 
       MIN(CHAR_LENGTH(cor)), 
       MAX(CHAR_LENGTH(cor)) 
FROM objeto;

