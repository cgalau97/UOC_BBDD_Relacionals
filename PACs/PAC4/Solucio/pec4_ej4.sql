--Ejecicio 4.a
EXPLAIN			   
SELECT ta.name atleta,
		   td.name disciplina,
	       ta.country pais,
	       tr.discipline_id,
	       count(1)
	FROM 
     olympic.tb_register tr,
	 olympic.tb_athlete ta,
	 olympic.tb_discipline td
  WHERE 
	1=1
	and ta.athlete_id = tr.athlete_id
	and td.discipline_id = tr.discipline_id
  GROUP by 	ta.name ,
		   td.name ,
	       ta.country ,
	       tr.discipline_id		   
  ORDER BY ta.country, tr.discipline_id,ta.name	;
			   
--Ejecicio 4.b			   
CREATE MATERIALIZED VIEW v_participaciones TABLESPACE ts_uocpress AS
SELECT ta.name atleta,
		   td.name disciplina,
	       ta.country pais,
	       tr.discipline_id,
	       count(1)
	FROM 
     olympic.tb_register tr,
	 olympic.tb_athlete ta,
	 olympic.tb_discipline td
  WHERE 
	1=1
	and ta.athlete_id = tr.athlete_id
	and td.discipline_id = tr.discipline_id
  GROUP by 	ta.name ,
		   td.name ,
	       ta.country ,
	       tr.discipline_id		   
  ORDER BY ta.country, tr.discipline_id,ta.name
WITH DATA;	