--create database eng5_b1;

\c eng5_b1;

--select pg_sleep(2);
--SELECT 'primeira aula prática BD';
--sElecT pg_sleep(2);
--SELECT 50*2;

DROP TABLE IF EXISTS Estudante;--             select pg_sleep(2);
DROP TABLE IF EXISTS Cidade;--             select pg_sleep(2);

CREATE TABLE Cidade
(
    id INT PRIMARY KEY,
    nome VARCHAR(50) NOT NULL
);


INSERT INTO Cidade (nome, id) VALUES  ('TRES LAGOAS', 3);
INSERT INTO Cidade (id, nome) VALUES  
   
      (10, 'SALVADOR'),
      (30, 'ANDRADINA'),
      (7, 'CASTILHO'),
      (9, 'BELEM');


CREATE TABLE Estudante
(
    RA int PRIMARY KEY,
    nome varchar(60) NOT NULL,
    data_nasc date NOT NULL,
    nome_social varchar(30) NULL,
    cidade_id int NULL REFERENCES Cidade (ID)
);                               --              select pg_sleep(2);

INSERT INTO Estudante 
   VALUES (1010, 'JOSÉ DA SILVA', '2002/03/17', 'ZEFA', 7);


SELECT RA, nome FROM Estudante;                   --select pg_sleep(2);
SELECT nome_social, nome FROM Estudante;            -- select pg_sleep(2);

INSERT INTO Estudante VALUES 
    (1020, 'MARIA DA SILVA', '2000/10/10', NULL),   
    (1031, 'ARNALDO SENIOR', '2005/01/01', NULL),
    (1051, 'EDSON AUGUSTO', '2003/01/17', 'FURACAO MILTON'),
    (1000, 'EDSON ARANTES', '1950/01/17', 'VULGO PELÉ')
   ;

SELECT RA, nome FROM Estudante;                   --select pg_sleep(2);
SELECT nome_social, nome FROM Estudante;            -- select pg_sleep(2);

SELECT nome, data_nasc FROM Estudante;             --select pg_sleep(2);

SELECT nome, data_nasc, age(data_nasc) 
FROM Estudante;

SELECT nome, data_nasc AS data_nascc, 
   age(data_nasc) AS "Idade do estudante", RA
FROM Estudante;

SELECT nome, data_nasc AS data_nascc, 
   age(data_nasc) AS "Idade do estudante", RA
FROM Estudante
ORDER BY RA DESC;


SELECT nome, data_nasc AS data_nascc, 
   age(data_nasc) AS "Idade do estudante", RA
FROM Estudante
ORDER BY nome ASC;

SELECT nome, data_nasc AS data_nascc, 
   age(data_nasc) AS "Idade do estudante", RA
FROM Estudante
ORDER BY data_nasc ASC;

SELECT nome, data_nasc AS data_nascc, 
   age(data_nasc) AS "Idade do estudante", 
   date_part('year',  age(data_nasc)) AS idade_anos,
   RA
FROM Estudante
ORDER BY data_nasc ASC;
