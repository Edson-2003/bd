--\i /dados/fakes.sql

SELECT * INTO Pessoa from fake;

ALTER TABLE Pessoa RENAME COLUMN numero TO ID;

ALTER TABLE Pessoa ADD CONSTRAINT PK_Pessoa PRIMARY KEY (ID);



select distinct pais, pais_completo from pessoa;
-- pais | pais_completo 
--------+---------------
-- BR   | Brazil
--(1 row)

CREATE TABLE Pais 
(
   codigo char(2) PRIMARY KEY,
   Nome varchar(50) NOT NULL UNIQUE
);
INSERT INTO Pais (codigo, nome) VALUES ('BR', 'Brazil');

create table estado 
(
  sigla char(2) primary key, 
  nome varchar(60) not null
);

insert into estado (sigla, nome)
   SELECT DISTINCT estado, estado_completo
   FROM Pessoa
   ORDER BY estado;

ALTER TABLE Estado ADD COLUMN pais_codigo char(2) NOT NULL DEFAULT 'BR' REFERENCES Pais(Codigo);

CREATE TABLE cidade
(
    id SERIAL primary key,
    estado char(2) NOT NULL,
    nome varchar(60) NOT NULL
);

INSERT INTO Cidade (estado, nome) 
    SELECT DISTINCT estado, cidade
    from Pessoa
    order by estado, cidade;

alter table cidade add constraint fk_cidade_estado 
   FOREIGN KEY (estado) REFERENCES Estado(sigla);

ALTER TABLE Pessoa ADD COLUMN Cidade_ID int;

ALTER TABLE PESSOA ADD CONSTRAINT FK_Cidade_Pessoa 
   FOREIGN KEY (Cidade_ID) REFERENCES Cidade(ID);

UPDATE Pessoa SET Cidade_ID = Cidade.ID
   FROM Cidade
   WHERE Cidade.estado = Pessoa.estado
      AND Cidade.nome = Pessoa.cidade;

CREATE TABLE Logradouro
(
   codigo_postal varchar(9) NOT NULL PRIMARY KEY,
   rua varchar(100) NOT NULL,
   cidade_id int NOT NULL REFERENCES Cidade(ID)
);

INSERT INTO Logradouro 
   SELECT DISTINCT codigo_postal, 
       regexp_replace(endereco, '\s\d+$', ''), 
       cidade_id 
   from pessoa 
   order by 1, 2, 3;

ALTER TABLE Pessoa ADD CONSTRAINT FK_Logradouro_Pessoa
   FOREIGN KEY (codigo_postal)
   REFERENCES Logradouro (codigo_postal);

ALTER TABLE Pessoa ADD COLUMN rua_numero INT NULL;
UPDATE Pessoa SET rua_numero = regexp_replace(endereco, '.*\s(\d+)$', '\1')::int;

ALTER TABLE Pessoa ALTER COLUMN codigo_postal SET NOT NULL;


CREATE TABLE Profissao 
(
   ID serial not null primary key,
   nome varchar(80) not null
); 

insert into profissao (nome)
    SELECT DISTINCT Profissao 
    from Pessoa 
    ORDER BY Profissao;

ALTER TABLE Pessoa ADD COLUMN profissao_ID int;

UPDATE Pessoa SET Profissao_ID = Profissao.ID
   FROM Profissao
   WHERE Pessoa.profissao = Profissao.nome;

ALTER TABLE Pessoa ADD CONSTRAINT FK_Profissao_Pessoa
    FOREIGN KEY (Profissao_ID)
    REFERENCES Profissao (ID);

ALTER TABLE PESSOA ALTER COLUMN Profissao_id SET NOT NULL;

CREATE TABLE Empresa 
(
   ID serial not null primary key,
   nome varchar(60) NOT NULL
);

INSERT INTO Empresa (nome)
   SELECT DISTINCT Empresa
   FROM Pessoa
   WHERE empresa != ''
   ORDER BY 1;

ALTER TABLE Pessoa ADD COLUMN Empresa_id int NULL; -- Pessoa sem empresa

UPDATE Pessoa SET Empresa_ID = Empresa.id
    FROM Empresa
    WHERE Empresa.nome = Pessoa.empresa;

ALTER TABLE Pessoa ADD CONSTRAINT FK_Empresa_pessoa
    FOREIGN KEY (Empresa_id)
    REFERENCES Empresa(ID);


create TEMPORARY TABLE Temp_Veiculo
(
   pessoa_ID int,
   veiculo varchar(50),
   ano int,
   aux varchar(50),
   fabricante varchar(50),
   modelo varchar(50),
   modelo_ID int NULL
);

insert into temp_veiculo (pessoa_ID, veiculo)
select ID, veiculo  
FROM Pessoa
ORDER BY ID;

update temp_veiculo SET ano = left(veiculo, 4)::int;

update temp_veiculo set aux = substring(veiculo from 6 for 60);

update temp_veiculo set fabricante = substring(aux from 1 for (position(' ' in aux))) ;

update temp_veiculo set modelo = substring(aux from (position(' ' in aux)) for 60);

--Fiat
--FIAT

CREATE TABLE Fabricante_Veic 
(
   ID serial not null PRIMARY KEY,
   nome varchar(30) NOT NULL 
);

INSERT INTO Fabricante_Veic(nome)
    SELECT DISTINCT Fabricante from temp_veiculo order by 1;

CREATE TABLE Modelo_Veic
(
   ID serial not null primary key,
   fabricante_id int NOT NULL REFERENCES Fabricante_Veic (ID),
   nome varchar(30) NOT NULL
   
);

INSERT INTO Modelo_Veic (fabricante_ID, nome)
   SELECT DISTINCT F.ID, Temp.Modelo
   FROM temp_veiculo Temp JOIN Fabricante_Veic F ON Temp.fabricante = F.nome
   ORDER BY 1, 2;

UPDATE temp_veiculo SET modelo_ID = M.ID
    FROM Modelo_Veic M JOIN Fabricante_Veic F ON M.Fabricante_ID = F.ID
    WHERE M.nome = temp_veiculo.modelo AND F.nome = Temp_veiculo.fabricante;

ALTER TABLE Pessoa ADD COLUMN Modelo_Veic_ID int REFERENCES Modelo_Veic(ID);
ALTER TABLE Pessoa ADD COLUMN Ano_Veic int;

UPDATE Pessoa SET Modelo_Veic_ID = Temp.Modelo_ID, Ano_Veic = Temp.ano
    FROM temp_veiculo Temp
    WHERE Pessoa.ID = Temp.pessoa_ID;


CREATE TABLE Cor
(
   sigla char(3) NOT NULL PRIMARY KEY,
   nome varchar(20) NOT NULL UNIQUE
);

INSERT INTO COR (Sigla, nome) 
    select DISTINCT left(cor,3), COR 
    from pessoa order by 1;


CREATE TABLE Cartao_Credito
(
   pessoa_id int NOT NULL PRIMARY KEY REFERENCES Pessoa(ID),
   tipo_cartao char(1) NOT NULL,
   cor varchar(3) NOT NULL REFERENCES Cor(sigla),
   numero_cartao varchar(16) NOT NULL, 
   cvv2 varchar(3) NOT NULL, 
   validade_cartao varchar(10) NOT NULL,
   CHECK (tipo_cartao IN ('V', 'M')) -- Visa, MasterCard
);

insert into Cartao_Credito
   select ID, left(tipo_cartao, 1), left(cor, 3), 
         numero_cartao, cvv2, validade_cartao 
   from pessoa order by ID;


CREATE TABLE Usuario
(
   Pessoa_ID int not null primary key REFERENCES Pessoa(ID),
   nome_de_usuario varchar(25) NOT NULL,
   endereco_de_email varchar(100) NOT NULL,
   senha varchar(25) NOT NULL,
   agente_usuario_navegador varchar(255)
);

INSERT INTO Usuario
   select ID, nome_de_usuario, endereco_de_email, senha, agente_usuario_navegador
   from pessoa
   order by ID;


CREATE TABLE Identificacao_E_Rastreamento
(
   Pessoa_ID int not null primary key REFERENCES Pessoa(ID),
   codigo_rastreamento_upstracking character varying(24),
   numero_mtc_western_union character(10),
   numero_mtc_moneygram character(8), 
   identificador_global character varying(36),
   latitude numeric(10,6),
   longitude numeric(10,6)
);

insert into Identificacao_E_Rastreamento 
   SELECT ID, codigo_rastreamento_upstracking,
        numero_mtc_western_union, numero_mtc_moneygram, 
        identificador_global, latitude, longitude
   FROM Pessoa
   ORDER BY ID;


CREATE TABLE Agente_Navegador
(
   ID serial NOT NULL PRIMARY KEY,
   texto varchar(100) NOT NULL
);

CREATE TABLE Agente_Navegador_Usuario
(
   Pessoa_ID int NOT NULL REFERENCES Pessoa(ID),
   Agente_ID int NOT NULL REFERENCES Agente_Navegador(ID),
   PRIMARY KEY (Pessoa_ID, Agente_ID)
);

CREATE TEMPORARY TABLE temp_navegador
(
   pessoa_id int,
   texto varchar(100),
   navegador_ID int NULL
);

INSERT INTO temp_navegador (pessoa_ID, texto)
    select pessoa_id, regexp_split_to_table(agente_usuario_navegador, 
        E'(?<=\\))|(?=\\()|\\s+(?=(?:[^()]*\\([^)]*\\))*[^()]*$)') 
    from usuario
    ORDER BY 1, 2;

INSERT INTO Agente_Navegador (Texto)
    SELECT DISTINCT texto
    FROM temp_navegador
    ORDER BY Texto;

UPDATE temp_navegador SET navegador_ID = Agente_Navegador.id
    FROM Agente_Navegador
    WHERE temp_navegador.texto = Agente_Navegador.texto;

INSERT INTO Agente_Navegador_Usuario (Pessoa_ID, Agente_ID)
   SELECT pessoa_id, navegador_ID
   FROM Temp_Navegador
   ORDER BY Pessoa_ID, navegador_ID;




CREATE TABLE Dominio
(
   ID serial NOT NULL PRIMARY KEY,
   nome varchar(70) NOT NULL UNIQUE
);

INSERT INTO Dominio(nome)
    SELECT DISTINCT dominio
    FROM Pessoa
    ORDER BY dominio;

ALTER TABLE Pessoa ADD COLUMN dominio_ID int;

UPDATE Pessoa SET dominio_ID = Dominio.ID
    FROM Dominio
    WHERE Dominio.nome = Pessoa.dominio;

ALTER TABLE Pessoa ADD CONSTRAINT FK_Dominio_Pessoa
    FOREIGN KEY (dominio_ID)
    REFERENCES Dominio(ID);

ALTER TABLE Pessoa ALTER COLUMN dominio_ID SET NOT NULL;

ALTER TABLE Pessoa  ADD COLUMN nascimento date;
UPDATE PESSOA SET nascimento = to_date(data_nascimento, 'MM/DD/YYY');
ALTER TABLE PESSOA DROP COLUMN data_nascimento;
ALTER TABLE PESSOA RENAME COLUMN nascimento TO data_nascimento; 


--ALTER TABLE table_name ALTER COLUMN column_name SET DATA TYPE new_data_type;
ALTER TABLE Pessoa ALTER COLUMN peso_quilos SET DATA TYPE numeric(5,1) USING peso_quilos::numeric(5,1);

ALTER TABLE Pessoa ALTER COLUMN altura_centimetros SET DATA TYPE numeric(3,0) USING altura_centimetros::numeric(3,0);
    

/*
Preto (Black): Frequentemente associado a cartões de alto padrão, como cartões de crédito premium (por exemplo, o Black Card), que oferecem benefícios exclusivos.

Azul (Blue): Uma cor comum em cartões de crédito padrão, muitas vezes usada por bancos para cartões de entrada, mas também pode ser usada em cartões de benefícios ou para clientes com bom histórico de crédito.

Marrom (Brown): Menos comum, mas pode ser usado por algumas instituições financeiras, especialmente para versões mais simples ou com um design mais discreto.

Verde (Green): Tradicionalmente usado em cartões de crédito básicos ou para cartões de entrada (como o cartão Verde do American Express).

Laranja (Orange): Pode ser uma cor vibrante usada em cartões promocionais ou de algumas empresas, embora não seja tão comum.

Roxo (Purple): Usado em alguns cartões de alto nível, ou cartões com benefícios exclusivos, ou em edições limitadas de algumas marcas.

Vermelho (Red): Também usado em cartões de crédito, especialmente aqueles que estão associados a programas de recompensas, cashback, ou até cartões de marcas específicas.

Prata (Silver): Normalmente associado a cartões de crédito de nível médio, muitas vezes oferecendo benefícios como pontos ou acesso a serviços adicionais.

Branco (White): Pode ser usado em cartões de design simples ou minimalista. Alguns bancos ou instituições financeiras usam essa cor para dar uma aparência mais limpa e sofisticada.

Amarelo (Yellow): Embora não seja muito comum, o amarelo pode ser usado em cartões promocionais ou em edições limitadas, dependendo da marca ou banco.
*/

--ALTER TABLE Pessoa DROP COLUMN 
ALTER TABLE Pessoa DROP COLUMN estado;
ALTER TABLE Pessoa DROP COLUMN estado_completo;
ALTER TABLE Pessoa DROP COLUMN nameset; -- redundante
ALTER TABLE Pessoa DROP COLUMN pais;
ALTER TABLE Pessoa DROP COLUMN pais_completo;
ALTER TABLE Pessoa DROP COLUMN cidade;
ALTER TABLE Pessoa DROP COLUMN cidade_ID; -- link com logradouro
ALTER TABLE Pessoa DROP COLUMN Profissao;
ALTER TABLE Pessoa DROP COLUMN Veiculo;
ALTER TABLE Pessoa DROP COLUMN Endereco;
ALTER TABLE Pessoa DROP COLUMN tipo_cartao;
ALTER TABLE Pessoa DROP COLUMN numero_cartao;
ALTER TABLE Pessoa DROP COLUMN cvv2;
ALTER TABLE Pessoa DROP COLUMN validade_cartao;
ALTER TABLE Pessoa DROP COLUMN cor;
ALTER TABLE Pessoa DROP COLUMN nome_de_usuario;
ALTER TABLE Pessoa DROP COLUMN senha; 
ALTER TABLE Pessoa DROP COLUMN agente_usuario_navegador;
ALTER TABLE Pessoa DROP COLUMN codigo_rastreamento_upstracking;
ALTER TABLE Pessoa DROP COLUMN numero_mtc_western_union;
ALTER TABLE Pessoa DROP COLUMN numero_mtc_moneygram;
ALTER TABLE Pessoa DROP COLUMN identificador_global;
ALTER TABLE Pessoa DROP COLUMN latitude;
ALTER TABLE Pessoa DROP COLUMN longitude;
ALTER TABLE Pessoa DROP COLUMN dominio;

-- CAMPOS CALCULADOS
ALTER TABLE Pessoa DROP COLUMN idade;
ALTER TABLE Pessoa DROP COLUMN signo_tropical;
ALTER TABLE Pessoa DROP COLUMN peso_libras;
ALTER TABLE Pessoa DROP COLUMN altura_polegadas;


/*
A data de cada signo
Áries: de 21 de março a 20 de abril;
Touro: de 21 de abril a 20 de maio;
Gêmeos: de 21 de maio a 20 de junho;
Câncer: de 21 de junho a 22 de julho;
Leão: de 23 de julho a 22 de agosto;
Virgem: de 23 de agosto a 22 de setembro;
Libra: de 23 de setembro a 22 de outubro;
Escorpião: de 23 de outubro a 21 de novembro;
Sagitário: de 22 de novembro a 21 de dezembro;
Capricórnio: de 22 de dezembro a 20 de janeiro;
Aquário: de 21 de janeiro a 18 de fevereiro;
Peixes: de 19 de fevereiro a 20 de março;
*/


/*
veiculo                         | character varying(255) |           |          | 
 dominio                         | character varying(70)  |           |          | 
 tipo_sanguineo                  | character varying(3) 
*/