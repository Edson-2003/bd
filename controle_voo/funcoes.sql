-- CREATE OR REPLACE FUNCTION NOME_DA_FUNCAO ([lista de parâmetros]) 
-- RETURNS TIPO_RETORNO 
-- AS $$
-- -- DECLARE xx tipox; yy tipoy;	
-- BEGIN
  
-- END;
-- $$ LANGUAGE plpgsql;


--receba o ID de uma pessoa e retorne seu CPF
CREATE OR REPLACE FUNCTION Fn_CPF(p_ID int)
RETURNS varchar(14)
AS $$
BEGIN
    return CPF
	  FROM pessoa
	  WHERE ID = p_ID;	  
END;
$$ LANGUAGE plpgsql;


select fn_cpf(5);

select ID, nome, fn_cpf(ID)
from pessoa
limit 5;

--drop function if exists fn_pessoa_id (varchar(14));

--receba o CPF de uma pessoa e retorne seu ID
CREATE OR REPLACE FUNCTION Fn_Pessoa_ID(p_cpf varchar(14))
RETURNS varchar(14)
AS $$
BEGIN
    return ID
	  FROM pessoa
	  WHERE CPF = p_cpf;	  
END;
$$ LANGUAGE plpgsql;

-- select id, cpf, fn_pessoa_id(cpf)
-- from pessoa 
-- limit 5;


--receba o ID de uma pessoa (fakenames) e retorne seu IMC
CREATE OR REPLACE FUNCTION Fn_IMC(p_number int)
RETURNS numeric(5,2)
AS $$
	DECLARE nome varchar(40); massa_kg numeric(5,2); altura_m numeric(5,2);		
	   imc numeric(5,2);
BEGIN
	SELECT givenname || ' ' || surname nome,
	   kilograms::numeric(5,2),
	   (centimeters::float/100) INTO nome, massa_kg, altura_m
	FROM fakenames
	WHERE number = p_number;
	
	RAISE INFO E'\n  ID: %\n  nome: % \n  massa(kg): % \n altura(metros): %', 
	   p_number, nome, massa_kg, altura_m ;
	
	SELECT massa_kg/(altura_m*altura_m) INTO IMC;
	
	RAISE INFO 'IMC: %', imc;
	
	RETURN IMC;
    
END;
$$ LANGUAGE plpgsql;

/*
select Fn_IMC(5);


select number, Fn_IMC(number)
FROM fakenames
ORDER BY 2
limit 5;

select number, Fn_IMC(number)
FROM fakenames
-- ORDER BY 2
limit 5;
*/


--receba o ID de uma pessoa (fakenames) e retorne seu IMC
CREATE OR REPLACE FUNCTION Fn_IMC2(p_number int, print_info BOOLEAN)
RETURNS numeric(5,2)
AS $$
	DECLARE nome varchar(40); massa_kg numeric(5,2); altura_m numeric(5,2);		
	   imc numeric(5,2);
BEGIN
	SELECT givenname || ' ' || surname nome,
	   kilograms::numeric(5,2),
	   (centimeters::float/100) INTO nome, massa_kg, altura_m
	FROM fakenames
	WHERE number = p_number;
	
	SELECT massa_kg/(altura_m*altura_m) INTO IMC;
	
	IF (print_info = TRUE) THEN	
	  RAISE INFO E'\n  ID: %\n  nome: % \n  massa(kg): % \n altura(metros): % \n  IMC: %', 
	     p_number, nome, massa_kg, altura_m, imc ;	   
	END IF;
		
	RETURN IMC;
    
END;
$$ LANGUAGE plpgsql;

-- select number, Fn_IMC2(number, true)
-- FROM fakenames
-- order by 2 DESC
-- limit 5;

-- select number, Fn_IMC2(number, true)
-- FROM fakenames
-- order by surname, number
-- limit 20;



-- receba a sigla de um aeroporto 
-- e retorne a concatenação da sigla com o nome do aeroporto e o nome da cidade de localização
	-- com junção
	-- sem junção (variável aux)


CREATE OR REPLACE FUNCTION Fn_Cidade_Aeroporto(p_sigla char(3))
RETURNS text
AS $$
    -- DECLARE xx tipox; yy tipoy;	
BEGIN
    return A.sigla || ' - ' || A.nome || ' - ' || Cid.nome_Cidade
	    FROM Aeroporto A JOIN Cidade Cid ON A.Cidade_ID = Cid.Codigo
		WHERE A.sigla = p_sigla;
    
END;
$$ LANGUAGE plpgsql;


-- SELECT Fn_Cidade_Aeroporto('GRU');

-- SELECT Fn_Cidade_Aeroporto(sigla)
-- FROM Aeroporto
-- ORDER BY sigla;


CREATE OR REPLACE FUNCTION Fn_Cidade_Aeroporto2(p_sigla char(3))
RETURNS text
AS $$
    DECLARE aero text; cid_codigo int; cid_nome varchar(50);
BEGIN
    SELECT A.sigla || ' - ' || A.nome, A.cidade_id INTO aero, cid_codigo
	FROM Aeroporto A
	WHERE A.sigla = p_sigla;	
	
	SELECT Cid.nome_cidade INTO cid_nome 
	FROM Cidade Cid
	WHERE Cid.codigo = cid_codigo;

    return aero || ' - ' || cid_nome;
    
END;
$$ LANGUAGE plpgsql;

-- SELECT Fn_Cidade_Aeroporto2(sigla)
-- FROM Aeroporto
-- ORDER BY sigla;


-- receba a sigla de um aeroporto 
-- e retorne um booleano se brasileiro ou não
CREATE OR REPLACE FUNCTION Fn_Aeroporto_Brasileiro (p_sigla char(3))
RETURNS boolean
AS $$   
BEGIN
    return (Cid.Pais_ID = 1)
	  FROM Aeroporto A JOIN Cidade Cid ON A.Cidade_ID = Cid.Codigo
	  WHERE A.sigla = p_sigla;
    
END;
$$ LANGUAGE plpgsql;

-- select Fn_Cidade_Aeroporto(sigla), Fn_Aeroporto_Brasileiro(sigla)
-- from Aeroporto
-- order by 2, 1;

-- receba uma data de nascimento
	-- SE existir apenas uma pessoa nascida naquela data retornar o ID e nome (concatenados)
	-- Caso contrário imprimir mensagem e não retornar nada

CREATE OR REPLACE FUNCTION Fn_Pessoa_nascimento (p_data date)
RETURNS varchar(66)
AS $$   
    DECLARE quant int;
BEGIN
   
    SELECT COUNT(*) into quant 
	FROM Pessoa 
	WHERE data_nasc = p_data;
	
	if (quant = 1) THEN
	    RAISE INFO 'Pessoa nascida em % ', to_char(p_data, 'DD/MM/YYYY');
		return ID::varchar(6) || ' - ' || nome
		  FROM Pessoa
		  WHERE data_nasc = p_data;	
	ELSEIF (quant = 0) THEN
		RAISE INFO 'Nenhuma pessoa nascida em % ', to_char(p_data, 'DD/MM/YYYY');
		
		return NULL;	
	ELSE
		RAISE INFO '% pessoas nascidas em %', quant, to_char(p_data, 'DD/MM/YYYY');
		return NULL;
	END IF;
	
    
END;
$$ LANGUAGE plpgsql;

SELECT Fn_Pessoa_nascimento('1957-02-01'::date);
SELECT Fn_Pessoa_nascimento('2000-10-01'::date);
SELECT Fn_Pessoa_nascimento('1977-02-28'::date);


-- receba uma data de nascimento e 
-- retorne uma tabela 
-- com ID, CPF e nome das pessoas nascidas naquela data

CREATE OR REPLACE FUNCTION Fn_Pessoas_Nascidas_Em (p_data date) 
RETURNS TABLE
   (
       ID int, 
       CPF varchar(14),
       nome varchar(60)	   
   )   
AS $$
-- DECLARE xx tipox; yy tipoy;	
BEGIN
  RETURN QUERY
    SELECT P.ID, P.CPF, P.nome
	FROM Pessoa P
	WHERE P.data_nasc = p_data;
END;
$$ LANGUAGE plpgsql;


SELECT CPF, ID, nome from Fn_Pessoas_Nascidas_Em ('1977/02/28'::date);


CREATE OR REPLACE FUNCTION Fn_Pessoas_Nascidas_Em (dia int, mes int) 
RETURNS TABLE
   (
       ID int, 
       CPF varchar(14),
       nome varchar(60),
       Data_nasc date	   
   )   
AS $$
BEGIN
  RETURN QUERY
    SELECT P.ID, P.CPF, P.nome, P.data_nasc
	FROM Pessoa P
	WHERE date_part('day', P.data_nasc) = dia
	  AND date_part('month', P.data_nasc) = mes
	ORDER BY P.data_nasc;
END;
$$ LANGUAGE plpgsql;

SELECT * FROM Fn_Pessoas_Nascidas_Em (29, 02);

SELECT * FROM Fn_Pessoas_Nascidas_Em (30, 06);

/*

receba o ID de uma pessoa e retorne a classificação do seu IMC

*/