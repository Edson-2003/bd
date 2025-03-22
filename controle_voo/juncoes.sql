ALTER TABLE Pessoa 
ALTER COLUMN Cidade_codigo 
drop not NULL;

UPDATE Pessoa SET cidade_codigo = NULL 
WHERE id%10 = 0;

SELECT Pessoa.id, pessoa.nome, cidade.nome_cidade
FROM Pessoa INNER JOIN Cidade ON
  cidade_codigo = Cidade.codigo
ORDER BY 1
LIMIT 30;

SELECT Pessoa.id, pessoa.nome, cidade.nome_cidade
FROM Pessoa LEFT OUTER JOIN Cidade ON
  cidade_codigo = Cidade.codigo
ORDER BY 1
LIMIT 30;

SELECT Pessoa.id, pessoa.nome, cidade.nome_cidade
FROM Pessoa LEFT JOIN Cidade ON
  cidade_codigo = Cidade.codigo
ORDER BY 1
LIMIT 30;

SELECT Pessoa.id, pessoa.nome, cidade.nome_cidade
FROM Cidade RIGHT JOIN Pessoa ON
  cidade_codigo = Cidade.codigo
ORDER BY 1
LIMIT 30;

