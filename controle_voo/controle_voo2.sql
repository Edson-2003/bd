/*
AGENDA
====================================================
Criação de objetos temporários
Criação de sequences
Criação e atualização de funções de BD
Criação e manipulação de cursores de BD
====================================================


Salve prezados estudantes de BD
Vamos para mais uma aula prática.
Ressalto que é muito importante praticar, 
e não apenas assistir às nossas aulas.
E dessa forma vocês vão ganhando maturidade
e desenvolverão os exercícios 
de maneira correta e com agilidade.

*/

/*

CREATE FUNCTION NOME_DA_FUNCAO ([lista de parâmetros]) 
RETURNS TIPO_RETORNO 
AS $$

$$ LANGUAGE nome_linguagem_utilizada;

*/

CREATE OR REPLACE FUNCTION Fn_Caracter_Aleatorio()
RETURNS char(1)
AS $$
BEGIN
    return chr(cast(65 + random()*25 as int));
END;
$$ LANGUAGE plpgsql;

--SELECT Fn_Caracter_Aleatorio();

CREATE OR REPLACE FUNCTION Fn_3Caracter_Aleatorio()
RETURNS char(3)
AS $$
BEGIN
    return Fn_Caracter_Aleatorio() 
         || Fn_Caracter_Aleatorio() 
         || Fn_Caracter_Aleatorio();
END;
$$ LANGUAGE plpgsql;

-- SELECT Fn_3Caracter_Aleatorio()
-- FROM generate_series(1,10)
-- order by 1;

CREATE OR REPLACE FUNCTION Fn_PrefixoAero_Aleatorio()
RETURNS char(2)
AS $$
BEGIN
    return prefixo 
      FROM VPrefixo_Aeronautico
      ORDER BY RANDOM()
	  LIMIT 1;
END;
$$ LANGUAGE plpgsql;

SELECT Fn_PrefixoAero_Aleatorio() || '-' || Fn_3Caracter_Aleatorio() 
from generate_series (1,10);


CREATE OR REPLACE FUNCTION Fn_MyRandom(limite int)
RETURNS int
AS $$
   DECLARE r float; i int ;
BEGIN
    select random() INTO r;
	
	RAISE NOTICE 'o numero sorteado foi: %', r;

    SELECT (r*limite)::int INTO i;
   
    RAISE NOTICE 'aleatorio: %', i;
	
    return i;
END;
$$ LANGUAGE plpgsql;

SELECT Fn_MyRandom(100)
from generate_series (1,10);

CREATE OR REPLACE FUNCTION Fn_Cria_Aeronaves
   (quantidade int , sigla_tipo_aeronave varchar(10))
RETURNS void
AS $$
BEGIN
    RAISE NOTICE 'Criando % aeronaves com pref. aleatório e tipo  %',
       quantidade, sigla_tipo_aeronave;
    
    INSERT INTO Aeronave(codigo, tipo_sigla) 
    SELECT Fn_PrefixoAero_Aleatorio() 
         || '-' || Fn_3Caracter_Aleatorio(),
         sigla_tipo_aeronave
    FROM generate_series(1,quantidade);
END;
$$ LANGUAGE plpgsql;

--select * from tipo_aeronave;

select Fn_Cria_Aeronaves(2, 'A330');
select Fn_Cria_Aeronaves(5,  'ATR-72');
select Fn_Cria_Aeronaves(8,  'A321');
select Fn_Cria_Aeronaves(6,  'E-190');
select Fn_Cria_Aeronaves(12,  'E-195');
select Fn_Cria_Aeronaves(1, 'A330');
select Fn_Cria_Aeronaves(11,  'E-190');
select Fn_Cria_Aeronaves(3,  '737 MAX');



-- select count(*) from aeronave;

-- select * from tipo_aeronave;

-- select Codigo, sigla, nome, quant_assentos
-- FROM Aeronave A JOIN Tipo_Aeronave TA 
  -- ON (tipo_sigla = sigla)
-- ORDER BY codigo;


-- select SUM(quant_assentos)
-- FROM Aeronave A JOIN Tipo_Aeronave TA 
  -- ON (tipo_sigla = sigla);


--https://www.postgresqltutorial.com/plpgsql-loop-statements/
CREATE OR REPLACE FUNCTION Fn_Cria_Aeronaves_loop
   (quantidade int , sigla_tipo_aeronave varchar(10))
RETURNS void
AS $$
   declare n integer;
BEGIN
    RAISE NOTICE 'Criando % aeronaves com pref. aleatório e tipo  %',
       quantidade, sigla_tipo_aeronave;

    n = 0;

    LOOP
	    EXIT WHEN n = quantidade;

	    RAISE NOTICE 'n: %', n+1;
	    
        INSERT INTO Aeronave(codigo, tipo_sigla)
          SELECT Fn_PrefixoAero_Aleatorio()  || '-' || Fn_3Caracter_Aleatorio(),
	        sigla_tipo_aeronave;

        n = n+1;

    END LOOP;
END;
$$ LANGUAGE plpgsql;


select Fn_Cria_Aeronaves_loop(33,  'A330');
select Fn_Cria_Aeronaves_loop(20,  'ATR-72');


CREATE OR REPLACE View VAeronave AS
select Codigo, sigla, nome, quant_assentos
FROM Aeronave A JOIN Tipo_Aeronave TA 
  ON (tipo_sigla = sigla)
ORDER BY sigla, codigo;

SELECT * FROM VAeronave;


CREATE OR REPLACE FUNCTION Fn_Piloto_Aleatorio()
RETURNS integer
AS $$
BEGIN
    return pessoa_id
      FROM Piloto
      ORDER BY random()
      LIMIT 1;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION Fn_Cria_Voos
   ( p_numero_voo int,
     p_data_hora_inicio timestamp with time zone, 
     p_data_fim date, 
     p_tempo_voo int, -- minutos
     p_tipo_aeronave varchar(10), 
     p_aeroporto_decolagem char(3),
     p_aeroporto_pouso char(3), 
     diario_semanal_mensal char(1) -- D, S, M
   )
RETURNS void
AS $$
DECLARE 
    piloto integer;
    copiloto integer;
    aeronave varchar(6);
    intervalo_dias integer;
BEGIN
   IF( p_data_hora_inicio > p_data_fim ) THEN
      RAISE 'Data de início deve ser anterior à final';
      RETURN;
   END IF;

    piloto = Fn_Piloto_Aleatorio();
    copiloto = Fn_Piloto_Aleatorio();
    loop 
      EXIT WHEN piloto <> copiloto;
      
      copiloto = Fn_Piloto_Aleatorio();
    end loop;
	


    IF (p_tipo_aeronave IS NULL ) THEN
       SELECT codigo INTO aeronave
       FROM Aeronave
       ORDER BY random()
       LIMIT 1;
    ELSE
       SELECT codigo INTO aeronave
       FROM Aeronave
       WHERE tipo_sigla = p_tipo_aeronave
       ORDER BY random()
       LIMIT 1;
    END IF;

    raise NOTICE 'piloto: % - copiloto: %; aeronave: % ', piloto, copiloto, aeronave;

    diario_semanal_mensal := UPPER(diario_semanal_mensal);

    SELECT CASE diario_semanal_mensal
             WHEN 'D' THEN 1
             WHEN 'S' THEN 7
             ELSE 30             
           END INTO intervalo_dias;

  INSERT INTO Voo (numero_voo, data_hora_decolagem, data_hora_pouso, 
     aeronave, aeroporto_decolagem, aeroporto_pouso, 
     piloto_id, copiloto_id)
  SELECT p_numero_voo, SERIE, SERIE + p_tempo_voo * interval '1 minute',
     aeronave, p_aeroporto_decolagem, p_aeroporto_pouso,
     piloto, copiloto
  
  FROM generate_series(p_data_hora_inicio, 
    p_data_fim + interval '1 day', intervalo_dias * interval '1 day') SERIE;

END;
$$ LANGUAGE plpgsql;

--CREATE SEQUENCE voo_id_seq START 1;

-- ALTER TABLE Voo ALTER COLUMN id SET DEFAULT nextval('voo_id_seq');

-- SELECT 4784, SERIE, SERIE + 120 * interval '1 minute',
--      'I-ECF', 'CGR', 'GRU',
--      855, 18526
--   FROM generate_series(now(), 
--     cast('2022/12/25' as date) + interval '1 day', 7 * interval '1 day') SERIE;







SELECT Fn_Cria_Voos(4800, '2021/06/18 17:00', '2022/12/25', 120, 'ATR-72', 'CGR', 'GRU', 'd');
SELECT Fn_Cria_Voos(4785, '2021/06/20 21:00', '2022/12/25', 120, 'ATR-72', 'GRU', 'CGR', 'd');
SELECT Fn_Cria_Voos(5000, '2021/06/20 21:00', '2022/12/25', 120, 'ATR-72', 'GRU', 'CGB', 'd');

--select now() + 5 * interval '1 minute';

--select generate_series(now(), current_date + 365 * interval '1 day', interval '15 day') SERIE;

DROP TABLE IF EXISTS Temp_Cria_Voo;
CREATE TEMPORARY TABLE Temp_Cria_Voo
(
     p_numero_voo int NULL,
     p_data_hora_inicio timestamp with time zone NULL, 
     p_data_fim date NULL,
     p_tempo_voo int NOT NULL, -- minutos
     p_tipo_aeronave varchar(10) NOT NULL, 
     p_aeroporto_decolagem char(3) NOT NULL,
     p_aeroporto_pouso char(3) NOT NULL, 
     diario_semanal_mensal char(1) NOT NULL-- D, S, M	
);

INSERT INTO Temp_Cria_Voo VALUES (NULL, NULL, NULL, 130, 'A330', 'GRU', 'AEP', 'D');
INSERT INTO Temp_Cria_Voo VALUES (NULL, NULL, NULL, 240, 'A330', 'GRU', 'ATL', 'D');
INSERT INTO Temp_Cria_Voo VALUES (NULL, NULL, NULL, 240, 'A330', 'GRU', 'FLR', 'S');
INSERT INTO Temp_Cria_Voo VALUES (NULL, NULL, NULL, 600, 'A321', 'GRU', 'HND', 'D');
INSERT INTO Temp_Cria_Voo VALUES (NULL, NULL, NULL, 360, 'A321', 'GRU', 'LHR', 'M');
INSERT INTO Temp_Cria_Voo VALUES (NULL, NULL, NULL, 300, 'A330', 'GRU', 'MEX', 'S');
INSERT INTO Temp_Cria_Voo VALUES (NULL, NULL, NULL, 400, 'A330', 'GRU', 'ORD', 'M');
INSERT INTO Temp_Cria_Voo VALUES (NULL, NULL, NULL, 720, 'E-195','GRU', 'PVG', 'S');
INSERT INTO Temp_Cria_Voo VALUES (NULL, NULL, NULL, 130, 'A330', 'AEP', 'GRU', 'D');
INSERT INTO Temp_Cria_Voo VALUES (NULL, NULL, NULL, 240, 'A330', 'ATL', 'GRU', 'D');
INSERT INTO Temp_Cria_Voo VALUES (NULL, NULL, NULL, 300, 'A321', 'CDG', 'GRU', 'D');
INSERT INTO Temp_Cria_Voo VALUES (NULL, NULL, NULL, 500, 'E-195','CDG', 'GRU', 'D');
INSERT INTO Temp_Cria_Voo VALUES (NULL, NULL, NULL, 240, 'A330', 'FLR', 'GRU', 'D');
INSERT INTO Temp_Cria_Voo VALUES (NULL, NULL, NULL, 420, 'A321', 'FRA', 'GRU', 'S');
INSERT INTO Temp_Cria_Voo VALUES (NULL, NULL, NULL, 800, 'E-195','HND', 'GRU', 'S');
INSERT INTO Temp_Cria_Voo VALUES (NULL, NULL, NULL, 300, 'A330', 'MEX', 'GRU', 'S');
INSERT INTO Temp_Cria_Voo VALUES (NULL, NULL, NULL, 400, 'A321', 'ORD', 'GRU', 'D');
INSERT INTO Temp_Cria_Voo VALUES (NULL, NULL, NULL, 600, 'A321', 'PEK', 'GRU', 'S');
INSERT INTO Temp_Cria_Voo VALUES (NULL, NULL, NULL, 800, 'E-195','PVG', 'GRU', 'S');

--SELECT * FROM Temp_Cria_Voo;

CREATE OR REPLACE FUNCTION Fn_Inteiro_Aleatorio(limite int)
RETURNS integer
AS $$
BEGIN
    return cast(floor(random()*limite) as int);
END;
$$ LANGUAGE plpgsql;

SELECT Fn_Inteiro_Aleatorio(5000),
   current_date + 1.1 *Fn_Inteiro_Aleatorio(365)* interval '1 day',
   cast(current_date + (365 + Fn_Inteiro_Aleatorio(365))* interval '1 day' as date)
FROM Temp_Cria_Voo;


UPDATE Temp_Cria_Voo
SET p_numero_voo = Fn_Inteiro_Aleatorio(10000),
    p_data_hora_inicio = current_date + 1.1 *Fn_Inteiro_Aleatorio(365)* interval '1 day',
    p_data_fim = cast(current_date + (365 + Fn_Inteiro_Aleatorio(5*365))* interval '1 day' as date);

SELECT * FROM Temp_Cria_Voo;

-- CUIDADO ANTES DE EXECUTAR ISTO!
SELECT Fn_Cria_Voos
  (
    p_numero_voo, 
    p_data_hora_inicio, 
    p_data_fim, 
    p_tempo_voo, p_tipo_aeronave, 
    p_aeroporto_decolagem,
    p_aeroporto_pouso, 
    diario_semanal_mensal
   )
FROM Temp_Cria_Voo;

