---Ejercicio 1.a
		   
ALTER TABLE olympic.tb_athlete ADD id INTEGER;
			   
CREATE SEQUENCE olympic.seq_athlete_id INCREMENT BY 1 START WITH 1001  NO CYCLE;
			   
ALTER TABLE olympic.tb_athlete
ALTER COLUMN id SET DEFAULT nextval('olympic.seq_athlete_id')	;

---Validacion secuencia			   
INSERT INTO olympic.tb_athlete(athlete_id, name, country, substitute_id) VALUES('999999','MARTINEZ Marcos','ESP',NULL);
			   
SELECT *
FROM olympic.tb_athlete
WHERE athlete_id = '999999';
			   
WITH seleccion AS (
  SELECT athlete_id, id from olympic.tb_athlete order by athlete_id desc
)			   
UPDATE 	olympic.tb_athlete upd
SET id = nextval('olympic.seq_athlete_id')
FROM seleccion o			   
where upd.athlete_id = o.athlete_id;
---Ejercicio 1.b
WITH RECURSIVE posicion AS (
  SELECT 
	name,
	--tr.athlete_id,
	discipline_id,
	round_number,
	register_position,
	CAST(register_position || ': ' || name AS TEXT) AS a_position
  FROM 
     olympic.tb_register tr,
	 olympic.tb_athlete ta
  WHERE 
	register_position=0
	and ta.athlete_id = tr.athlete_id
  UNION
  SELECT 
	ta.name,
	p.discipline_id,
	tr.round_number,
	tr.register_position,
    CAST(p.a_position || ' -> ' || tr.register_position || ': ' || ta.name AS TEXT) AS a_position
  FROM olympic.tb_register tr,
	 olympic.tb_athlete ta,
	 posicion p
  WHERE 
	tr.register_position<>0
	and ta.athlete_id = tr.athlete_id
	and p.discipline_id = tr.discipline_id
	and p.round_number  = tr.round_number
	and p.register_position +1 = tr.register_position 
)
SELECT td.name,
	P.round_number,
	p.register_position,
	a_position
	FROM posicion p, olympic.tb_discipline td
where td.discipline_id = p.discipline_id
and td.name = 'Triathlon'
and round_number  =3
ORDER BY p.register_position;

---Ejercicio 1.c

select distinct ta.name atleta,
		   td.name disciplina,
	       ta.country pais,
	       MIN(register_time) OVER (PARTITION BY tr.discipline_id) AS posicion,
	       AVG(register_time) OVER (PARTITION BY ta.country, tr.discipline_id) AS tiempo_medio_pais_disciplina, 
		   sum(1) OVER (PARTITION BY ta.country,tr.discipline_id, ta.athlete_id) AS num_participaciones,
		   sum(1) OVER (PARTITION BY ta.country,tr.discipline_id) AS num_participaciones_por_disciplina_pais
	FROM 
     olympic.tb_register tr,
	 olympic.tb_athlete ta,
	 olympic.tb_discipline td
  WHERE 
	1=1
	and ta.athlete_id = tr.athlete_id
	and td.discipline_id = tr.discipline_id
  ORDER BY  td.name, ta.country