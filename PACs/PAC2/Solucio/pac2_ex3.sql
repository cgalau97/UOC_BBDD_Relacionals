------------------------------------------------------------------------------------------------
--
-- Format de data: dia-mes-any
--
------------------------------------------------------------------------------------------------

SET datestyle = DMY;

------------------------------------------------------------------------------------------------
--
-- Exercici 3.1)
--
------------------------------------------------------------------------------------------------

INSERT INTO olimpic.tb_athlete
  (athlete_id, name, country, substitute_id) 
VALUES
  ('0000001','REMBRAND Luc','FRA',NULL),
  ('0000002','SMITH Mike','ENG',NULL),
  ('0000003','LEWIS Carl','USA',NULL)
;

------------------------------------------------------------------------------------------------
--
-- Exercici 3.2)
--
------------------------------------------------------------------------------------------------

ALTER TABLE  olimpic.tb_athlete
ADD CONSTRAINT ck_athlete_esp 
CHECK (country<>'ESP' OR (country='ESP' AND substitute_id IS NOT NULL));

-- Verificació:
-- UPDATE olimpic.tb_athlete SET substitute_id=NULL WHERE athlete_id='1354668';

------------------------------------------------------------------------------------------------
--
-- Exercici 3.3)
--
------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW olimpic.exercise33 AS
SELECT * 
FROM olimpic.tb_athlete 
WHERE country ='ESP' AND name LIKE 'PE%' 
ORDER BY athlete_id DESC
WITH CHECK OPTION;

-- Verificació:
-- INSERT INTO olimpic.exercise33 (athlete_id, name, country, substitute_id) VALUES ('0000006','PEÑA Alberto','ESP','0000001');
-- INSERT INTO olimpic.exercise33 (athlete_id, name, country, substitute_id) VALUES ('0000007','LAMBORT Rene','FRA','0000001');

------------------------------------------------------------------------------------------------
--
-- Exercici 3.4)
--
------------------------------------------------------------------------------------------------

ALTER TABLE olimpic.tb_athlete
  ADD COLUMN date_add DATE NOT NULL DEFAULT CURRENT_DATE
;


------------------------------------------------------------------------------------------------
--
-- Exercici 3.5)
--
------------------------------------------------------------------------------------------------

-- La creació d'usuaris en PostgreSQL es basa en rols. CREATE USER és un àlies de CREATE ROLE.

CREATE USER registerer WITH LOGIN PASSWORD '1234';
GRANT USAGE ON SCHEMA olimpic TO registerer;        -- Donem privilegi d'ús de l'esquema olimpic a l'usuari creat   
GRANT ALL ON olimpic.tb_register TO registerer;     -- Donem tots els privilegis a l'usuari només en aquesta taula. Sense WITH GRANT OPTION
GRANT SELECT ON olimpic.tb_athlete TO registerer;   -- Donem privilegi de SELECT a l'usuari en aquesta taula. Sense WITH GRANT OPTION
