SELECT P.id, P.nome, f.MATRICULA
FROM Gerente G JOIN Funcionario F ON G.pessoa_id = F.pessoa_id
   JOIN Pessoa P ON F.pessoa_id =  P.id
ORDER BY P.ID;

SELECT P.id, P.nome
FROM Gerente G JOIN Pessoa P ON g.pessoa_id =  P.id
ORDER BY P.ID;

SELECT id, nome FROM Pessoa WHERE  ID IN
  (SELECT Pessoa_ID FROM Gerente);


CREATE OR REPLACE FUNCTION Fn_Funcionarios (tipo char) 
RETURNS TABLE
   (
       ID int,       
       nome varchar(60),
       imc numeric(5,2),
       idade_anos int
   )   
AS $$
BEGIN
    tipo := UPPER(tipo);
    RAISE INFO '%', tipo;

    IF (tipo = 'G') THEN
        RETURN QUERY
           SELECT P.id, P.nome, fN_imc2(P.ID, false), date_part('year', age(data_nasc))::int 
           FROM Pessoa P WHERE  P.ID IN
                (SELECT Pessoa_ID FROM Gerente);
    END IF;

    IF (tipo = 'P') THEN
        RETURN QUERY
           SELECT P.id, P.nome, fN_imc2(P.ID, false), date_part('year', age(data_nasc))::int 
           FROM Pessoa P WHERE  P.ID IN
                (SELECT Pessoa_ID FROM Piloto);
    END IF;

    IF (tipo = 'A') THEN
        RETURN QUERY
           SELECT P.id, P.nome, fN_imc2(P.ID, false), date_part('year', age(data_nasc))::int 
           FROM Pessoa P WHERE  P.ID IN
                (SELECT Pessoa_ID FROM Aeromoca);
    END IF;


END;
$$ LANGUAGE plpgsql;


CREATE OR REPLACE FUNCTION Fn_Funcionarios2 (tipo char) 
RETURNS TABLE
   (
       ID int,       
       nome varchar(60),
       imc numeric(5,2),
       idade_anos int
   )   
AS $$
    DECLARE nome_tabela varchar(10);
      _query varchar(200);
BEGIN
    tipo := UPPER(tipo);
    RAISE INFO '%', tipo;

    -- SELECT 
    --    CASE WHEN tipo = 'A' THEN 'Aeromoca'
    --         WHEN tipo = 'G' THEN 'Gerente'
    --         WHEN tipo = 'P' THEN 'Piloto'
    --    END INTO nome_tabela;
    
    -- outra forma de escrever
    SELECT 
       CASE tipo
            WHEN 'A' THEN 'Aeromoca'
            WHEN 'G' THEN 'Gerente'
            WHEN 'P' THEN 'Piloto'
            ELSE NULL
       END INTO nome_tabela;

    IF (nome_tabela IS NULL) THEN
        RAISE EXCEPTION 'Tipo de funcionário inválido';
    END IF;

    _query := 'SELECT P.id, P.nome, fN_imc2(P.ID, false), ' || 
              '   date_part(''year'', age(data_nasc))::int ' ||
              '   FROM Pessoa P WHERE  P.ID IN ' ||
              '      (SELECT Pessoa_ID FROM '  || nome_tabela || ')';

    --RAISE INFO '%', _query; 

    RETURN QUERY EXECUTE _query;

END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION Fn_Funcionarios3 
   (tipo char, ordem varchar(10), quant int) 
RETURNS TABLE
   (
       ID int,       
       nome varchar(60),
       imc numeric(5,2),
       idade_anos int
   )   
AS $$
    DECLARE nome_tabela varchar(10);       
      _query varchar(200);
BEGIN
    tipo := UPPER(tipo);
    RAISE INFO '%', tipo;

    -- SELECT 
    --    CASE WHEN tipo = 'A' THEN 'Aeromoca'
    --         WHEN tipo = 'G' THEN 'Gerente'
    --         WHEN tipo = 'P' THEN 'Piloto'
    --    END INTO nome_tabela;
    
    -- outra forma de escrever

    SELECT 
       CASE tipo
            WHEN 'A' THEN 'Aeromoca'
            WHEN 'G' THEN 'Gerente'
            WHEN 'P' THEN 'Piloto'
            ELSE NULL
       END INTO nome_tabela;

    IF (nome_tabela IS NULL) THEN
        RAISE EXCEPTION 'Tipo de funcionário inválido!';
    END IF;

    ordem := UPPER(ordem);

    IF (ordem != 'ID' AND ordem != 'NOME' AND ordem != 'IMC') THEN
        RAISE EXCEPTION 'Ordenação inválida!';
    END IF;


    _query := 'SELECT P.id, P.nome, fN_imc2(P.ID, false) AS IMC, ' || 
              '   date_part(''year'', age(data_nasc))::int ' ||
              '   FROM Pessoa P WHERE  P.ID IN ' ||
              '      (SELECT Pessoa_ID FROM '  || nome_tabela || ')';

    _query := _query || ' ORDER BY ' || ordem;

    IF (quant >0) THEN
        _query := _query || ' LIMIT ' || quant;
    END IF;



    --RAISE INFO '%', _query; 

    RETURN QUERY EXECUTE _query;

END;
$$ LANGUAGE plpgsql;


-- SELECT * FROM Fn_Funcionarios3('a', 'id', NULL);
-- SELECT * FROM Fn_Funcionarios3('a', 'NOME', NULL);

-- SELECT * FROM Fn_Funcionarios3('g', 'NoMe', 7);
-- SELECT * FROM Fn_Funcionarios3('g', 'ID', 7);
-- SELECT * FROM Fn_Funcionarios3('g', 'ID', NULL);
-- SELECT * FROM Fn_Funcionarios3('g', 'IMC', NULL);

-- SELECT * FROM Fn_Funcionarios3('g', 'abobrinha', NULL );


CREATE OR REPLACE FUNCTION Fn_Funcionarios4
   (tipo char, ordem varchar(10), quant int) 
RETURNS TABLE
   (
       ID int,       
       nome varchar(60),
       imc numeric(5,2),
       idade_anos int,
       classif_imc varchar(20)
   )   
AS $$
    DECLARE nome_tabela varchar(10);       
      _query varchar(300);
BEGIN
    tipo := UPPER(tipo);
    RAISE INFO '%', tipo;

    SELECT 
       CASE tipo
            WHEN 'A' THEN 'Aeromoca'
            WHEN 'G' THEN 'Gerente'
            WHEN 'P' THEN 'Piloto'
            ELSE NULL
       END INTO nome_tabela;

    IF (nome_tabela IS NULL) THEN
        RAISE EXCEPTION 'Tipo de funcionário inválido!';
    END IF;

    ordem := UPPER(ordem);

    IF (ordem != 'ID' AND ordem != 'NOME' AND ordem != 'IMC') THEN
        RAISE EXCEPTION 'Ordenação inválida!';
    END IF;

    CREATE TEMPORARY TABLE Temporaria
    (
       ID int,       
       nome varchar(60),
       imc numeric(5,2),
       idade_anos int
   );

    _query := 'INSERT INTO Temporaria ' ||
              '   SELECT P.id, P.nome, fN_imc2(P.ID, false) AS IMC, ' || 
              '     date_part(''year'', age(data_nasc))::int ' ||
              '   FROM Pessoa P WHERE  P.ID IN ' ||
              '      (SELECT Pessoa_ID FROM '  || nome_tabela || ')';

    _query := _query || ' ORDER BY ' || ordem;

    IF (quant >0) THEN
        _query := _query || ' LIMIT ' || quant;
    END IF;

    EXECUTE _query;

    --RAISE INFO '%', _query; 

    RETURN QUERY SELECT *, ''::varchar(20) FROM temporaria;
    --RETURN QUERY SELECT *, fn_classifimc(temporaria.ID) FROM temporaria;
    RETURN QUERY SELECT *, null::varchar(20) FROM temporaria;

    drop table Temporaria;

END;
$$ LANGUAGE plpgsql;

SELECT * FROM Fn_Funcionarios4('a', 'NoMe', 3);