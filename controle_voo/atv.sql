CREATE OR REPALCE VIE public.vvoo AS
select 
  voo.id as id,
  voo.data_hora_decolagem,
  voo.data_hora_pouso,
  voo.aeronave,
  aeronave.tipo_sigla as aeronave_sigla,
  tipo.nome as aeronave_tipo,
  tipo.quant_assentos,
  voo.aeroporto_decolagem,
  decolagem.nome as nome_aeroporto_decolagem,
  cidade_d.nome_cidade as cidade_decolagem,
  pais_d.nome_pais as pais_decolagem,
  voo.aeroporto_pouso,
  pouso.nome as nome_aeroporto_pouso,
  cidade_p.nome_cidade as cidade_pouso,
  pais_p.nome_pais as pais_pouso,
  voo.piloto_id,
  pessoa_p.nome,
  pessoa_p.cpf,
  pessoa_p.sexo,
  piloto_p.codigo_anac,
  voo.copiloto_id,
  pessoa_c.nome,
  pessoa_c.cpf,
  pessoa_c.sexo,
  piloto_c.codigo_anac,
  case when voo.aeroporto_decolagem = voo.aeroporto_pouso then 1 else 0 end as internacional
  



from voo
  join aeronave on voo.aeronave = aeronave.codigo 
  join tipo_aeronave as tipo on aeronave.tipo_sigla = tipo.sigla
  join aeroporto as decolagem on voo.aeroporto_decolagem = decolagem.sigla
  join cidade as cidade_d on decolagem.cidade_id = cidade_d.codigo
  join pais as pais_d  on cidade_d.pais_id = pais_d.id
  join aeroporto as pouso on voo.aeroporto_pouso = pouso.sigla
  join cidade as cidade_p on pouso.cidade_id = cidade_p.codigo
  join pais as pais_p on cidade_p.pais_id = pais_p.id
  join piloto as piloto_p on voo.piloto_id = piloto_p.pessoa_id
  join pessoa as pessoa_p on voo.piloto_id = pessoa_p.id
  join piloto as piloto_c on voo.copiloto_id = piloto_c.pessoa_id
  join pessoa as pessoa_c on voo.copiloto_id = pessoa_c.id
limit 5;

