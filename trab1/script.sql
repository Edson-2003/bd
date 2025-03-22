DROP VIEW IF EXISTS mais_ouvidas CASCADE;
DROP VIEW IF EXISTS generos_mais_ouvidos CASCADE;
DROP TABLE IF EXISTS entrace CASCADE;
DROP TABLE IF EXISTS songs CASCADE;
DROP TABLE IF EXISTS label CASCADE;
DROP TABLE IF EXISTS lenguage CASCADE;
DROP TABLE IF EXISTS albun CASCADE;
DROP TABLE IF EXISTS collaborators CASCADE;
DROP TABLE IF EXISTS genre CASCADE;
DROP TABLE IF EXISTS composer CASCADE;
DROP TABLE IF EXISTS producer CASCADE;

 


/*
  BASE DE DADOS 50K SONGS
  ALUNO: EDSON AUGUSTO PEREIRA FERREIRA
  UC: BANCO DE DADOS
  PROFESSOR: EDSON DA SILVA CASTRO
  
  comando para consta das tabelas resultantes

  consultas possiveis
  select * from mais_ouvidas;
  select * from generos_mais_ouvidos;
*/



/* criação da tabela inicial e importação de dados */
CREATE TABLE entrace
(
  song_id character varying(16) NOT NULL,
  song_title character varying(64) NOT NULL,
  artist character varying(32) NOT NULL,
  albun character varying(32) NOT NULL,
  genre character varying(32) NOT NULL,
  release_date date NOT NULL,
  duration character varying (8) NULL,
  popularity numeric(3) NOT NULL,
  streams numeric(10) NOT NULL,
  lenguage character varying(16) NOT NULL,
  explicit_content character varying(4) NOT NULL,
  label character varying(32) NOT NULL,
  composer character varying(32) NOT NULL,
  producer character varying(32) NOT NULL,
  collaboration character varying(32) NULL
);
COPY entrace FROM '/tmp/spotify_songs_dataset.csv' header delimiter ',';

select * into songs from entrace;


/* criação das tabelas auxiliares*/

CREATE TABLE label (id SERIAL PRIMARY KEY, name varchar(32) NOT NULL);
INSERT INTO label (name) SELECT DISTINCT label FROM songs ORDER BY label;
ALTER TABLE songs ADD COLUMN label_id INT;
ALTER TABLE songs ADD CONSTRAINT FK_Label_Name FOREIGN KEY (label_id) REFERENCES label(id);
UPDATE songs SET label_id = label.id FROM label where label = label.name;


UPDATE songs SET lenguage = 'undeclared' where lenguage = '';
CREATE TABLE lenguage (id SERIAL PRIMARY KEY, lenguage varchar(16) NOT NULL);
INSERT INTO lenguage(lenguage) SELECT DISTINCT lenguage FROM songs ORDER BY lenguage;
ALTER TABLE songs ADD COLUMN lenguage_id INT;
ALTER TABLE songs ADD CONSTRAINT FK_lenguage FOREIGN KEY (lenguage_id) REFERENCES lenguage(id);
UPDATE songs SET lenguage_id = lenguage.id FROM lenguage where songs.lenguage = lenguage.lenguage;

CREATE TABLE albun (id SERIAL PRIMARY KEY, name VARCHAR(32));
INSERT INTO albun (name) SELECT DISTINCT albun FROM songs ORDER BY albun;
ALTER TABLE songs ADD COLUMN albun_id INT;
ALTER TABLE songs ADD CONSTRAINT FK_Albun_id FOREIGN KEY (albun_id) REFERENCES albun(id);
UPDATE songs SET albun_id = albun.id FROM albun where songs.albun = albun.name;

UPDATE songs SET collaboration = 'no collaboration' where collaboration = '';
CREATE TABLE collaborators (id SERIAL PRIMARY KEY, name VARCHAR(32));
INSERT INTO collaborators (name) SELECT DISTINCT collaboration FROM songs ORDER BY collaboration;
ALTER TABLE songs ADD COLUMN collaborator_id INT;
UPDATE songs SET collaborator_id = collaborators.id FROM collaborators where songs.collaboration = collaborators.name;


CREATE TABLE genre (id SERIAL PRIMARY KEY, genre VARCHAR(16));
insert into genre (genre) select distinct genre from songs order by 1;
ALTER TABLE songs ADD COLUMN genre_id INT;
alter table songs add constraint Fk_Genre_id FOREIGN KEY (genre_id) references genre(id);
UPDATE songs SET genre_id = genre.id from genre where songs.genre = genre.genre;

CREATE TABLE composer (id SERIAL PRIMARY KEY, name VARCHAR(32));
insert into composer (name) select distinct composer from songs order by 1;
ALTER TABLE songs ADD COLUMN composer_id INT;
alter table songs add constraint Fk_composer_id FOREIGN KEY (composer_id) references composer(id);
UPDATE songs SET composer_id = composer.id from composer where songs.composer = composer.name;



CREATE TABLE producer (id SERIAL PRIMARY KEY, name VARCHAR(32));
insert into producer (name) select distinct producer from songs order by 1;
ALTER TABLE songs ADD COLUMN producer_id INT;
alter table songs add constraint Fk_producer_id FOREIGN KEY (producer_id) references producer(id);
UPDATE songs SET producer_id = producer.id from producer where songs.producer = producer.name;


 /*Exclusao de campos nao nescessarios */
ALTER TABLE songs DROP COLUMN label;
ALTER TABLE songs DROP COLUMN lenguage;
ALTER TABLE songs DROP COLUMN albun;
ALTER TABLE songs DROP COLUMN collaboration;
ALTER TABLE songs DROP COLUMN genre;
ALTER TABLE songs DROP COLUMN composer;
ALTER TABLE songs DROP COLUMN producer;


/*views para consulta*/

CREATE VIEW generos_mais_ouvidos AS 
  SELECT genre.genre AS "generos", SUM(songs.streams) AS "Reproducoes" 
  FROM songs JOIN genre on songs.genre_id = genre.id GROUP BY genre.genre ORDER BY 2;

CREATE VIEW mais_ouvidas AS
  SELECT 
    songs.song_title AS "Musica",
    songs.artist AS "Musico",
    composer.name AS "Compositor",
    collaborators.name AS "Participacao",
    albun.name AS "Album",
    producer.name AS "Produtora",
    genre.genre AS "Genero Musical",
    label.name AS "Gravadora",
    songs.streams AS "Reproducoes"
  FROM songs
  JOIN composer on composer.id = songs.composer_id
  JOIN collaborators on collaborators.id = songs.collaborator_id
  JOIN albun on albun.id = songs.albun_id
  JOIN producer on producer.id = songs.producer_id
  JOIN label on label.id = songs.label_id
  join genre on genre.id = songs.genre_id
  ORDER BY 8
  LIMIT 10;



/*resumo da quantidade de registros*/

select count(*) AS "REGISTROS NA TABELA SONGS" FROM songs;
select count(*) AS "REGISTROS NA TABELA LABEL" FROM label;
select count(*) AS "REGISTROS NA TABELA LENGUAGE" FROM lenguage;
select count(*) AS "REGISTROS NA TABELA ALBUN" FROM albun;
select count(*) AS "REGISTROS NA TABELA COLLABORATORS" FROM collaborators;
select count(*) AS "REGISTROS NA TABELA GENRE" FROM genre;
select count(*) AS "REGISTROS NA TABELA COMPOSER" FROM composer;
select count(*) AS "REGISTROS NA TABELA PRODUCER" FROM producer;

select * from generos_mais_ouvidos;
select * from mais_ouvidas;
