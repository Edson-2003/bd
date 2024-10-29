CREATE TABLE Produto 
(
    ID int NOT NULL PRIMARY KEY,
    nome varchar(20) NOT NULL,
    quant_minima numeric(3,1) NOT NULL,
    unidade_medida varchar(6) NOT NULL
);

CREATE TABLE Mercado 
(
    ID int NOT NULL PRIMARY KEY,
    nome varchar(25) NOT NULL
);


CREATE TABLE Pesquisa
(
    ID serial NOT NULL PRIMARY KEY,
    mercado_id int NOT NULL
        REFERENCES Mercado(ID),
    produto_id int NOT NULL
        REFERENCES Produto(ID),
    preco numeric(6,2) NOT NULL
);

CREATE TABLE Cesta -- CESTA PEQUENA
(
    codigo char(1) NOT NULL PRIMARY KEY,
    nome varchar(20) NOT NULL
);


CREATE TABLE Produto_Cesta
(
    ID serial NOT NULL PRIMARY KEY,
    cesta_codigo char(1) 
        REFERENCES Cesta(codigo),
    produto_id int NOT NULL
        REFERENCES Produto(ID),
    quantidade numeric(3,1) NOT NULL    
);



INSERT INTO Produto VALUES (786, 'Carne',  6,	'Kg');
INSERT INTO Produto VALUES (174, 'Pão',	   6,	'Kg');
INSERT INTO Produto VALUES (647, 'Feijão', 4.5,	'Kg');
INSERT INTO Produto VALUES (508, 'Tomate', 9,	'Kg');
INSERT INTO Produto VALUES (355, 'Arroz',  3,	'Kg');
INSERT INTO Produto VALUES (203, 'Leite',  15,	'litros');
INSERT INTO Produto VALUES (487, 'Banana', 10,	'Kg');


INSERT INTO Mercado (id, nome) VALUES (20, 'Supermercado Preço Bom');
INSERT INTO Mercado (id, nome) VALUES (11, 'Mercadinho da Esquina');
INSERT INTO Mercado (id, nome) VALUES (30, 'Quitanda do Zé');

INSERT INTO Cesta (codigo, nome) VALUES ('X', 'Cesta Almoço');
INSERT INTO Cesta (codigo, nome) VALUES ('Y', 'Cesta Café Manhã');

INSERT INTO Produto_Cesta (cesta_codigo, produto_id, quantidade) values('Y', 487, 2);
INSERT INTO Produto_Cesta (cesta_codigo, produto_id, quantidade) values('X', 355, 2);
INSERT INTO Produto_Cesta (cesta_codigo, produto_id, quantidade) values('Y', 203, 5);
INSERT INTO Produto_Cesta (cesta_codigo, produto_id, quantidade) values('X', 647, 2);
INSERT INTO Produto_Cesta (cesta_codigo, produto_id, quantidade) values('Y', 174, 5);
INSERT INTO Produto_Cesta (cesta_codigo, produto_id, quantidade) values('X', 508, 1);
INSERT INTO Produto_Cesta (cesta_codigo, produto_id, quantidade) values('X', 786, 3);

INSERT INTO Pesquisa (mercado_id, produto_id, preco) values(11, 355, 7.00);
INSERT INTO Pesquisa (mercado_id, produto_id, preco) values(30, 487, 8.00);
INSERT INTO Pesquisa (mercado_id, produto_id, preco) values(30, 508, 13.00);
INSERT INTO Pesquisa (mercado_id, produto_id, preco) values(30, 647, 10.00);
INSERT INTO Pesquisa (mercado_id, produto_id, preco) values(11, 647, 8.00);
INSERT INTO Pesquisa (mercado_id, produto_id, preco) values(30, 174, 4.00);
INSERT INTO Pesquisa (mercado_id, produto_id, preco) values(30, 203, 20.00);
INSERT INTO Pesquisa (mercado_id, produto_id, preco) values(11, 786, 35.00);
INSERT INTO Pesquisa (mercado_id, produto_id, preco) values(20, 647, 8.00);
INSERT INTO Pesquisa (mercado_id, produto_id, preco) values(30, 355, 2.00);
INSERT INTO Pesquisa (mercado_id, produto_id, preco) values(20, 487, 5.00);
INSERT INTO Pesquisa (mercado_id, produto_id, preco) values(11, 487, 5.00);
INSERT INTO Pesquisa (mercado_id, produto_id, preco) values(11, 508, 10.00);
INSERT INTO Pesquisa (mercado_id, produto_id, preco) values(20, 786, 30.00);
INSERT INTO Pesquisa (mercado_id, produto_id, preco) values(20, 355, 5.00);
INSERT INTO Pesquisa (mercado_id, produto_id, preco) values(20, 174, 3.00);
INSERT INTO Pesquisa (mercado_id, produto_id, preco) values(11, 203, 12.00);
INSERT INTO Pesquisa (mercado_id, produto_id, preco) values(20, 508, 6.00);
INSERT INTO Pesquisa (mercado_id, produto_id, preco) values(30, 786, 30.00);
INSERT INTO Pesquisa (mercado_id, produto_id, preco) values(20, 203, 10.00);
INSERT INTO Pesquisa (mercado_id, produto_id, preco) values(11, 174, 6.00);
