
------------------------------------------------------------------------------------------------

-- 
SET search_path TO olimpic;

------------------------------------------------------------------------------------------------
--
-- Consulta a) 
--
------------------------------------------------------------------------------------------------
SELECT * 
FROM olimpic.tb_athlete 
WHERE country ='ESP' AND name LIKE 'PE%' 
ORDER BY athlete_id DESC;

------------------------------------------------------------------------------------------------
--
-- Consulta b) 
--
------------------------------------------------------------------------------------------------
SELECT d.name, a.name, a.athlete_id 
FROM olimpic.tb_athlete a
INNER JOIN olimpic.tb_play p ON p.athlete_id=a.athlete_id
INNER JOIN olimpic.tb_discipline d ON d.discipline_id=p.discipline_id
WHERE a.country ='FRA' AND d.type='JUMP'
ORDER BY d.name, a.name DESC;

------------------------------------------------------------------------------------------------
--
-- Consulta c) 
--
------------------------------------------------------------------------------------------------

SELECT d.discipline_id, d.name, count(*) FROM olimpic.tb_play p
NATURAL JOIN olimpic.tb_discipline d
GROUP BY d.discipline_id, d.name
HAVING count(*)=(SELECT max(c.c) FROM (SELECT count(cp.*) c  FROM olimpic.tb_play cp GROUP BY cp.discipline_id) c)

Usando LIMIT:

SELECT d.discipline_id, d.name, count(*) FROM olimpic.tb_play p
NATURAL JOIN olimpic.tb_discipline d
GROUP BY d.discipline_id, d.name
ORDER BY count(*) DESC
LIMIT 1;


------------------------------------------------------------------------------------------------
--
-- Consulta d) 
--
------------------------------------------------------------------------------------------------
SELECT a.athlete_id, a.name, a.country, count(*) 
FROM olimpic.tb_play p
NATURAL JOIN olimpic.tb_athlete a 
GROUP BY a.athlete_id, a.name, a.country
HAVING count(*)>1;


------------------------------------------------------------------------------------------------
--
-- Consulta e) 
--
------------------------------------------------------------------------------------------------
SELECT a.athlete_id, a.name, d.discipline_id, d.name, count(*)
FROM olimpic.tb_athlete a
INNER JOIN olimpic.tb_register r ON r.athlete_id=a.athlete_id
INNER JOIN olimpic.tb_discipline d ON d.discipline_id=r.discipline_id
GROUP BY a.athlete_id, a.name, d.discipline_id, d.name
HAVING count(*)=(
	SELECT MAX(s.rounds) FROM (
		SELECT COUNT(*) rounds
		FROM olimpic.tb_register
		GROUP BY athlete_id, discipline_id
	) s
);

