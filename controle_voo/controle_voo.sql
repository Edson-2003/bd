/*
===================================================================================
                           ANTES DE EXECUTAR:
===================================================================================
1) Descompacte o arquivo controle_voo.zip em uma pasta (diretório)
2) Crie um BD no servidor Postgresql com nome Controle_Voo;
3) Altere neste script todas as ocorrências de "/dados/controle_voo/" 
   para o caminho da pasta criada no item 1)

===================================================================================
                               EXECUÇÃO
===================================================================================
4) Conectado no BD criado no item 2) execute apenas uma única vez todo este script;
5) Ao final da execução deverá aparecer o total de registros cadastrados no BD:
   - pessoas: 30000;
   - funcionários: 1000;
   - pilotos: 342;
   - aeromoças: 570;
   - cidades: 364;
   - aeroportos: 68.
   - tipo de aeronaves: 6
   - País: 68
===================================================================================
*/



/*
CONSTRAINT - restrição
PRIMARY KEY (PK) = chave primária
    - restrição de unicidade, ou seja,
    não aceita duplicatas;
    - utilizada para busca
FOREING KEY (FK)= chave estrangeira
    restrição referencial
REFERENCES - serve para criar uma chave estrangeira
PRIMARY FOREING KEY - Chave primária estrangeira

CREATE TABLE = comando para criação de uma 
    tabela no nosso BD
NULL - campo (coluna) pode ser opcional
NOT NULL - Obrigatório = tem que ser informado
UNIQUE - Restrição de unicidade    
CHECK - restringimos os valores possíveis
*/

\set QUIET ON

DROP VIEW IF EXISTS vaeroporto;
DROP TABLE IF EXISTS aeroportosbrasileiros;
DROP VIEW IF EXISTS vaeronave;
DROP VIEW IF EXISTS VVoo;
DROP VIEW IF EXISTS VPiloto;
DROP VIEW IF EXISTS VFuncionario;
DROP VIEW IF EXISTS VPessoa;
DROP TABLE IF EXISTS Bagagem;
DROP TABLE IF EXISTS Passagem;
DROP TABLE IF EXISTS Aeromoca_Voo;
DROP TABLE IF EXISTS Voo;
DROP TABLE IF EXISTS Aeronave;
DROP TABLE IF EXISTS Tipo_Aeronave;
DROP TABLE IF EXISTS Aeroporto;
DROP TABLE IF EXISTS Idioma_Funcionario;
DROP TABLE IF EXISTS Gerente;
DROP TABLE IF EXISTS Piloto;
DROP TABLE IF EXISTS Aeromoca;
DROP TABLE IF EXISTS Passageiro;
DROP TABLE IF EXISTS Funcionario;
DROP TABLE IF EXISTS Pessoa;
DROP TABLE IF EXISTS Cidade;
DROP TABLE IF EXISTS Pais;
DROP TABLE IF EXISTS Idioma;
DROP TABLE IF EXISTS fakenames;

DROP SEQUENCE IF EXISTS fakenames_seq;
CREATE SEQUENCE fakenames_seq INCREMENT 1 START 1;

  
CREATE TABLE fakenames (
  number int NOT NULL PRIMARY KEY DEFAULT nextval('fakenames_seq'),
  gender varchar(6) NOT NULL,
  nameset varchar(25) NOT NULL,
  title varchar(6) NOT NULL,
  givenname varchar(20) NOT NULL,
  middleinitial varchar(1) NOT NULL,
  surname varchar(23) NOT NULL,
  streetaddress varchar(100) NOT NULL,
  city varchar(100) NOT NULL,
  state varchar(22) NOT NULL,
  statefull varchar(100) NOT NULL,
  zipcode varchar(15) NOT NULL,
  country varchar(2) NOT NULL,
  countryfull varchar(100) NOT NULL,
  emailaddress varchar(100) NOT NULL,
  username varchar(25) NOT NULL,
  password varchar(25) NOT NULL,
  browseruseragent varchar(255) NOT NULL,
  telephonenumber varchar(25) NOT NULL,
  telephonecountrycode int NOT NULL,
  maidenname varchar(20) NOT NULL,
  birthday varchar(10) NOT NULL,
  age int NOT NULL,
  tropicalzodiac varchar(11) NOT NULL,
  cctype varchar(10) NOT NULL,
  ccnumber varchar(16) NOT NULL,
  CVV2 varchar(3) NOT NULL,
  ccexpires varchar(10) NOT NULL,
  nationalid varchar(20) NOT NULL,
  upstracking varchar(24) NOT NULL,
  westernunionmtcn char(10) NOT NULL,
  moneygrammtcn char(8) NOT NULL,
  color varchar(6) NOT NULL,
  occupation varchar(70) NOT NULL,
  company varchar(70) NOT NULL,
  vehicle varchar(255) NOT NULL,
  domain varchar(70) NOT NULL,
  bloodtype varchar(3) NOT NULL,
  pounds varchar(5) NOT NULL,
  kilograms varchar(5) NOT NULL,
  feetinches varchar(6) NOT NULL,
  centimeters varchar(3) NOT NULL,
  guid varchar(36) NOT NULL,
  latitude numeric(10,6) NOT NULL,
  longitude numeric(10,6) NOT NULL
);


COPY fakenames FROM
  '/tmp/fakenames.csv' csv header delimiter ';' quote '"';


CREATE TABLE AeroportosBrasileiros
(
   sigla char(3) NOT NULL PRIMARY KEY,
   aeroporto varchar(50) NOT NULL,
   cidade varchar(50) NULL
);


COPY AeroportosBrasileiros FROM
  '/tmp/AeroportosBrasileiros.csv' csv header delimiter ';' quote '"';

UPDATE  AeroportosBrasileiros
SET  cidade = substring(aeroporto from 14 for 50)
WHERE cidade = '' or cidade is null;

CREATE TABLE Idioma
(
    sigla varchar(5) NOT NULL PRIMARY KEY,
    nome varchar(40) NOT NULL UNIQUE
);

CREATE TABLE Pais 
(
    ID int NOT NULL PRIMARY KEY,
    nome_pais varchar(50) NOT NULL UNIQUE,
	idioma_principal varchar(5) DEFAULT 'pt-BR' NOT NULL references idioma(sigla)    
);

CREATE TABLE Cidade
(
    codigo serial NOT NULL PRIMARY KEY,
    nome_cidade varchar(50) NOT NULL,
    turistica boolean NULL,
    pais_id int NOT NULL 
	REFERENCES Pais(ID)
);
CREATE TABLE Pessoa
(
    ID serial NOT NULL PRIMARY KEY,
    nome varchar(60) NOT NULL,
    CPF varchar(14) NULL UNIQUE,
    telefone varchar(20) NULL,
    email varchar(100) NULL, 
    data_nasc date NOT NULL,
    sexo char(1) NOT NULL,
    Cidade_codigo int not null
        REFERENCES Cidade(codigo),
    CHECK (sexo IN ( 'F' , 'M' )),
    Passaporte varchar(8)
);

CREATE TABLE Funcionario
(
   Pessoa_ID int NOT NULL PRIMARY KEY
      REFERENCES Pessoa(ID),
   Matricula int NOT NULL UNIQUE, 
   salario numeric(7,2) NOT NULL
);
CREATE TABLE Passageiro
(
   Pessoa_ID int NOT NULL PRIMARY KEY
      REFERENCES Pessoa(ID),
   necessidade_especial boolean
   
);
CREATE TABLE Piloto
(
    Pessoa_ID int NOT NULL PRIMARY KEY
       REFERENCES Funcionario(Pessoa_ID),
    codigo_ANAC numeric(9) NOT NULL UNIQUE
);
CREATE TABLE Aeromoca
(
    Pessoa_ID int NOT NULL PRIMARY KEY
        REFERENCES Funcionario (Pessoa_ID),
    data_curso_ANAC date NOT NULL
);
CREATE TABLE Gerente
(
    pessoa_ID int NOT NULL PRIMARY KEY
        REFERENCES Funcionario(Pessoa_ID),
    adicional_produtividade numeric(6,2) NOT NULL
);

CREATE TABLE Idioma_Funcionario
(
    id int NOT NULL PRIMARY KEY, 
    pessoa_id int NOT NULL 
        REFERENCES Funcionario (Pessoa_ID),
    idioma varchar(3) NOT NULL
        REFERENCES Idioma (sigla),
    UNIQUE (pessoa_id, idioma)
);
CREATE TABLE Aeroporto
(
   sigla char(3) NOT NULL PRIMARY KEY,
   nome varchar(50) NOT NULL UNIQUE,
   cidade_id int NOT NULL 
      REFERENCES Cidade(Codigo)
);

CREATE TABLE Tipo_Aeronave
(
    sigla varchar(10) NOT NULL PRIMARY KEY,
    nome varchar(40) NOT NULL UNIQUE,
    quant_assentos smallint NOT NULL
);
CREATE TABLE Aeronave
(
    codigo varchar(6) NOT NULL PRIMARY KEY,
    tipo_sigla varchar(10) NOT NULL 
       REFERENCES Tipo_Aeronave(sigla)
);
CREATE TABLE Voo
(
    id serial NOT NULL PRIMARY KEY,
    Numero_voo int NOT NULL,
    data_hora_decolagem timestamp NOT NULL,
    data_hora_pouso timestamp NOT NULL,
    aeronave varchar(6) NOT NULL
        REFERENCES Aeronave(codigo),
    aeroporto_decolagem char(3) NOT NULL 
        REFERENCES Aeroporto(sigla),
    aeroporto_pouso char(3) NOT NULL 
        REFERENCES Aeroporto(sigla),
    piloto_ID int NOT NULL
        REFERENCES Piloto(pessoa_ID),
    copiloto_ID int NOT NULL
        REFERENCES Piloto(pessoa_ID)
);
CREATE TABLE Aeromoca_Voo
(
    voo_ID int NOT NULL
        REFERENCES voo(ID),
    aeromoca_id int NOT NULL
        REFERENCES Aeromoca(pessoa_id),
    PRIMARY KEY (voo_ID, aeromoca_id)
                
);
CREATE TABLE Passagem
(
    id int NOT NULL PRIMARY KEY,
    voo_id int NOT NULL REFERENCES voo(id),
    passageiro_id int NOT NULL REFERENCES Passageiro(Pessoa_ID),
    data_hora_compra timestamp NOT NULL,
    numero_assento smallint NOT NULL
);

CREATE TABLE Bagagem
(
    id int NOT NULL PRIMARY KEY,
    passagem_id int NOT NULL REFERENCES passagem(id),
    massa_gramas int NOT NULL
);


CREATE OR REPLACE VIEW VPessoa AS
SELECT id, nome, CPF, data_nasc, 
   age(now(), data_nasc) Idade, cidade_codigo, nome_cidade, 
   CASE when sexo = 'F' then 'feminino'
      else 'masculino'
   END sexo   
FROM Pessoa JOIN Cidade ON (cidade_codigo = codigo);

CREATE VIEW VFuncionario AS
SELECT id, nome, cpf, 
  data_nasc, idade, nome_cidade cidade_moradia, sexo,
  matricula, salario
from VPessoa JOIN Funcionario
   ON (id = pessoa_id);

CREATE OR REPLACE VIEW VPiloto AS
SELECT id, nome, cpf, 
  data_nasc, idade, cidade_moradia, sexo,
  matricula, salario, codigo_anac
FROM VFuncionario JOIN Piloto ON (id = Pessoa_ID);


INSERT INTO Idioma (sigla, nome) values ('pt-BR','Português brasileiro');
INSERT INTO Idioma (sigla, nome) values ('pt-PT','Português europeu');
INSERT INTO Idioma (sigla, nome) values ('en-US','Inglês');
INSERT INTO Idioma (sigla, nome) values ('es','Espanho');
INSERT INTO Idioma (sigla, nome) values ('fr','Francês');
INSERT INTO Idioma (sigla, nome) values ('ru','Russo');
INSERT INTO Idioma (sigla, nome) values ('it','Italiano');
INSERT INTO Idioma (sigla, nome) values ('de','Alemão');
INSERT INTO Idioma (sigla, nome) values ('ja','Japão');
INSERT INTO Idioma (sigla, nome) values ('zh-CN','Chinês Simplificao');

INSERT INTO PAIS (id, nome_pais, idioma_principal) values(1, 'Brasil', 'pt-BR');

INSERT INTO cidade (nome_cidade, pais_id)
    SELECT DISTINCT TRIM(city || ' (' ||  state || ')') ,1 from fakenames   
UNION
   SELECT DISTINCT TRIM(Cidade), 1
   from AeroportosBrasileiros
   ORDER BY 1;


INSERT INTO Aeroporto (sigla, nome, cidade_id)
select sigla, Aeroporto, cidade.codigo
from aeroportosBrasileiros JOIN Cidade ON 
   (aeroportosBrasileiros.cidade = nome_cidade)
ORDER BY sigla;   


INSERT INTO pessoa 
   (nome, telefone, email, data_nasc, sexo, cidade_codigo, CPF)
select givenname || ' ' || middleinitial || ' ' || surname, 
   telephonenumber, 
   emailaddress, 
   now() data_nasc, -- Data importada de outro .csv
   --to_date (birthday, 'MM/DD/YYYY'),
   case when gender = 'female' then 'F' else 'M' end, 
  (
      SELECT codigo
      FROM Cidade
      WHERE nome_cidade = city || ' (' ||  state || ')' 
  ),
  nationalID
from fakenames;

-- -- UPDATE Pessoa
-- -- SET data_nasc = data_nasc + 
-- --   CAST(floor(random()* (18-(-18) + 1)) + (-18) AS INT) * interval '1 year';

CREATE TABLE DataNasc
(
   id int,
   data_nasc date
);


COPY  DataNasc FROM
  '/tmp/DataNasc.csv' csv header delimiter ';' quote '"';


UPDATE Pessoa
SET Data_Nasc = D.Data_Nasc
FROM DataNasc D
WHERE Pessoa.id = D.id;

DROP TABLE IF EXISTS DataNasc;



COPY Funcionario FROM
  '/tmp/Funcionario.csv' csv header delimiter ';' quote '"';


COPY Aeromoca FROM
  '/tmp/Aeromoca.csv' csv header delimiter ';' quote '"';


COPY Piloto FROM
  '/tmp/Piloto.csv' csv header delimiter ';' quote '"';

insert into pais values (2, 'Estados Unidos', 'en-US');
insert into pais values (3, 'China', 'zh-CN');
insert into pais values (4, 'Japão', 'ja');
insert into pais values (5, 'Inglaterra', 'en-US');
insert into pais values (6, 'França', 'fr');
insert into pais values (7, 'México', 'es');
insert into pais values (8, 'Argentina', 'es');
insert into pais values (9, 'Espanha', 'es');
insert into pais values (14, 'Itália', 'it');
insert into pais values (20, 'Alemanha', 'de');
insert into pais values (21, 'Portugal', 'pt-PT');

insert into cidade (nome_cidade, pais_id) values ('Atlanta', 2);
insert into cidade (nome_cidade, pais_id) values ('Pequim', 3);
insert into cidade (nome_cidade, pais_id) values ('Los Angeles', 2);
insert into cidade (nome_cidade, pais_id) values ('Tóquio', 4);
insert into cidade (nome_cidade, pais_id) values ('Chicago', 2);
insert into cidade (nome_cidade, pais_id) values ('Londres', 5);
insert into cidade (nome_cidade, pais_id) values ('Xangai', 3);
insert into cidade (nome_cidade, pais_id) values ('Paris', 6);
insert into cidade (nome_cidade, pais_id) values ('Buenos Aires', 8);
insert into cidade (nome_cidade, pais_id) values ('Tenerife', 9);
insert into cidade (nome_cidade, pais_id) values ('Florença', 14);
insert into cidade (nome_cidade, pais_id) values ('Frankfurt', 20);
insert into cidade (nome_cidade, pais_id) values ('Porto', 21);
insert into cidade (nome_cidade, pais_id) values ('Lisboa', 21);
insert into cidade (nome_cidade, pais_id) values ('Cidade do México', 7);


INSERT INTO Aeroporto (sigla, nome, cidade_id) 
	values ('ATL', 'Aeroporto Internacional de Atlanta', 350);
INSERT INTO Aeroporto (sigla, nome, cidade_id) 
	values ('PEK', 'Aeroporto Internacional de Pequim', 351);
INSERT INTO Aeroporto (sigla, nome, cidade_id) 
	values ('LAX', 'Aeroporto Internacional de Los Anageles', 352);
INSERT INTO Aeroporto (sigla, nome, cidade_id) 
	values ('HND', 'Aeroporto Internacional Haneda', 353);
INSERT INTO Aeroporto (sigla, nome, cidade_id) 
	values ('ORD', 'Aeroporto Internacional O’Hare', 354);
INSERT INTO Aeroporto (sigla, nome, cidade_id) 
	values ('LHR', 'Aeroporto Internacional Heathrow', 355);
INSERT INTO Aeroporto (sigla, nome, cidade_id) 
	values ('PVG', 'Aeroporto Internacional Pudong', 356);
INSERT INTO Aeroporto (sigla, nome, cidade_id) 
	values ('CDG', 'Aeroporto Internacional Charles de Gaulle', 357);
INSERT INTO Aeroporto (sigla, nome, cidade_id) 
	values ('MEX', 'Aeroporto Internacional Juarez', 364);
INSERT INTO Aeroporto (sigla, nome, cidade_id) 
	values ('AEP', 'Aeroporto Internacional Jorge Newberry', 358);
INSERT INTO Aeroporto (sigla, nome, cidade_id) 
	values ('TFN', 'Aeroporto Tenerife, Canarias', 359);
INSERT INTO Aeroporto (sigla, nome, cidade_id) 
	values ('FLR', 'Aeroporto Internacional de Florença', 360);
INSERT INTO Aeroporto (sigla, nome, cidade_id) 
	values ('FRA', 'Aeroporto Internacional de Frankfurt', 361);
INSERT INTO Aeroporto (sigla, nome, cidade_id) 
	values ('OPO', 'Aeroporto Internacional do Porto', 362);
INSERT INTO Aeroporto (sigla, nome, cidade_id) 
	values ('LIS', 'Aeroporto Internacional da Portela', 363);	


CREATE OR REPLACE VIEW VAeroporto AS
select A.Sigla as sigla_aeroporto, A.nome as aeroporto, 
   cidade_id, nome_cidade, 
   pais_id, nome_pais,
   case when pais_id = 1 then false
      else true
   end internacional,
   idioma_principal, I.nome as nome_idioma_principal
from aeroporto A JOIN Cidade C ON (A.cidade_id = C.codigo)
  JOIN Pais P ON (C.pais_id = P.id)
  JOIN Idioma I ON (P.idioma_Principal = I.sigla)
ORDER BY Sigla_Aeroporto;


/*
A330	Airbus A330		30+222
A321	Airbus A321neo	12+182
ATR-72	ATR-72-600		68
E-190	Embraer E-190	90
E-195	Embraer E-195   124
737 MAX Boeing 737 MAX  204
*/


insert into tipo_aeronave (sigla, nome, quant_assentos)
  values('A330', 'Airbus A330', 30+222);
insert into tipo_aeronave (sigla, nome, quant_assentos)
  values('A321', 'Airbus A321neo', 12+182);
insert into tipo_aeronave (sigla, nome, quant_assentos)
  values('ATR-72', 'ATR-72-600', 68);
insert into tipo_aeronave (sigla, nome, quant_assentos)
  values('E-190', 'Embraer E-190', 90);
insert into tipo_aeronave (sigla, nome, quant_assentos)
  values('E-195', 'Embraer E-195', 124);
insert into tipo_aeronave (sigla, nome, quant_assentos)
  values('737 MAX', 'Boeing 737 MAX', 204);

/*
Prefixos Aeronáuticos
N	Estados Unidos
I	Itália
JA  Japão
PT  Brasil
D	Alemanha
CR 	Portugal
G   Reino Unido
*/

CREATE OR REPLACE VIEW VPrefixo_Aeronautico AS
select  1 ordem, 'N' prefixo, 'Estados Unidos' Pais
  UNION SELECT 2, 'I', 'Itália' 
  UNION SELECT 3, 'JA', 'Japão' 
  UNION SELECT 4, 'PT', 'Brasil'
  UNION SELECT 5, 'D',  'Alemanha'
  UNION SELECT 6, 'CR', 'Portugal'
  UNION SELECT 7, 'G',  'Reino Unido'
ORDER BY ordem;

UPDATE Cidade
SET Turistica = TRUE
WHERE codigo IN (14, 116, 117, 189, 204, 246, 263, 269, 299,
	350, 352, 353, 354, 355, 357, 363);

SELECT (SELECT count(*) from pessoa) AS Pessoas,
       (SELECT count(*) from funcionario) AS Funcionarios,
       (SELECT count(*) from Piloto) AS Pilotos,
       (SELECT count(*) from Aeromoca) AS Aeromocas,
       (SELECT count(*) from Cidade) AS Cidades,
       (SELECT count(*) from Aeroporto) AS Aeroportos,
	   (SELECT count(*) from tipo_aeronave) AS tipo_aeronave,
	   (SELECT count(*) from Aeroporto) AS Pais;
	   
\set QUIET OFF
