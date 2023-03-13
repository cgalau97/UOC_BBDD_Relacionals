------------------------------------------------------------------------------------------------
--
-- E2 a)
--
------------------------------------------------------------------------------------------------
create domain olympic.email_type as text
  check (value ~* '^[a-za-z0-9._%-]+@[a-za-z0-9.-]+[.][a-za-z]+$');

alter table olympic.tb_collaborator
  add column email olympic.email_type;

alter table olympic.tb_sponsor
  add column email olympic.email_type;

------------------------------------------------------------------------------------------------
--
-- E2 b)
--
------------------------------------------------------------------------------------------------
create table olympic.tb_athletes_info_log    (
  athlete_id    character(7) not null,
  discipline_id  integer not null,
  round_number  integer not null,
  athlete_name  character varying(50) not null,
  discipline_name  character varying(50) not null,
  mark  character varying(12) not null,
  rating  integer not null,
  info_log_dt date,
  constraint pk_athlete_info_log
    primary key (athlete_id, round_number, discipline_id),
  constraint fk_register_athlete_info_log
    foreign key (athlete_id, round_number, discipline_id)
    references olympic.tb_register (athlete_id, round_number, discipline_id)
);

------------------------------------------------------------------------------------------------
--
-- E2 c)
--
------------------------------------------------------------------------------------------------
--
-- Primer, s'ha d'eliminar la restricció de la taula tb_athletes_info_log
-- que fa referència a la PK de la taula tb_register
ALTER TABLE olympic.tb_athletes_info_log DROP CONSTRAINT tb_athletes_info_log_fk;

-- Proposta de solució 1:
-- Aplicant el cascade, no fa falta que el trigger escolti l'acció DELETE
-- sobre la taula tb_register
ALTER TABLE olympic.tb_athletes_info_log ADD CONSTRAINT tb_athletes_info_log_fk
    FOREIGN KEY (athlete_id,round_number,discipline_id)
        REFERENCES olympic.tb_register(athlete_id,round_number,discipline_id) 
        ON DELETE CASCADE;

create or replace function olympic.fn_athletes_info() returns trigger
  LANGUAGE plpgsql SECURITY DEFINER
  SET search_path TO 'pg_catalog', 'olympic'
  as $$
declare 
  v_athlete_id char(7);
  v_discipline_id integer;
  v_round_number integer;
  v_athlete_name varchar(50);
  v_discipline_name varchar(50);
  v_mark varchar(12);
  v_rating integer;
  v_info_log_dt date;
begin
  v_athlete_id := new.athlete_id;
  v_discipline_id := new.discipline_id;
  v_round_number := new.round_number;
  
  v_athlete_name := (select name from olympic.tb_athlete where athlete_id = v_athlete_id);
  v_discipline_name := (select name from olympic.tb_discipline where discipline_id = v_discipline_id);
  
  v_rating := new.register_position;
  
  v_info_log_dt := date(new.register_ts);
  
  if (new.register_time is not null) then
      v_mark := to_char(new.register_time, 'HH:MI:SS');
  else
      v_mark := to_char(new.register_measure, '99D999');
  end if;
      
  insert into olympic.tb_athletes_info_log (athlete_id, discipline_id, round_number, athlete_name, discipline_name, mark, rating, info_log_dt)
      values (v_athlete_id, v_discipline_id, v_round_number, v_athlete_name, v_discipline_name, v_mark, v_rating, v_info_log_dt)
  on conflict (athlete_id, discipline_id, round_number)
  do update set athlete_id = v_athlete_id,
      discipline_id = v_discipline_id,
      round_number = v_round_number,
      athlete_name = v_athlete_name,
      discipline_name = v_discipline_name,
      rating = v_rating,
      mark = v_mark,
      info_log_dt = v_info_log_dt;
  
  return new;
end; $$

create trigger tg_athletes_info
  after insert or update ON olympic.tb_register
  for each row 
  execute procedure olympic.fn_athletes_info();

  
-- Proposta de solució 2:
-- Aplicant l'operación DELETE al Trigger i a la funció
create or replace function olympic.fn_athletes_info() returns trigger
  LANGUAGE plpgsql SECURITY DEFINER
  SET search_path TO 'pg_catalog', 'olympic'
  as $$
declare 
  v_athlete_id char(7);
  v_discipline_id integer;
  v_round_number integer;
  v_athlete_name varchar(50);
  v_discipline_name varchar(50);
  v_mark varchar(12);
  v_rating integer;
  v_info_log_dt date;
begin
  if (TG_OP = 'DELETE') then
    v_athlete_id := old.athlete_id;
    v_discipline_id := old.discipline_id;
    v_round_number := old.round_number;
  
    delete from olympic.tb_athletes_info_log
      where athlete_id = v_athlete_id
        and discipline_id = v_discipline_id
        and round_number = v_round_number;

    return old;
  else
    v_athlete_id := new.athlete_id;
    v_discipline_id := new.discipline_id;
    v_round_number := new.round_number;
  
    v_athlete_name := (select name from olympic.tb_athlete where athlete_id = v_athlete_id);
    v_discipline_name := (select name from olympic.tb_discipline where discipline_id = v_discipline_id);
  
    v_rating := new.register_position;
    
    v_info_log_dt := date(new.register_ts);
    
    if (new.register_time is not null) then
      v_mark := to_char(new.register_time, 'HH:MI:SS');
    else
      v_mark := to_char(new.register_measure, '99D999');
    end if;
        
    insert into olympic.tb_athletes_info_log (athlete_id, discipline_id, round_number, athlete_name, discipline_name, mark, rating, info_log_dt)
      values (v_athlete_id, v_discipline_id, v_round_number, v_athlete_name, v_discipline_name, v_mark, v_rating, v_info_log_dt)
    on conflict (athlete_id, discipline_id, round_number)
    do update set athlete_id = v_athlete_id,
        discipline_id = v_discipline_id,
        round_number = v_round_number,
        athlete_name = v_athlete_name,
        discipline_name = v_discipline_name,
        rating = v_rating,
        mark = v_mark,
        info_log_dt = v_info_log_dt;

    return new;
  end if;
end; $$

create trigger tg_athletes_info
  after insert or delete or update ON olympic.tb_register
  for each row 
  execute procedure olympic.fn_athletes_info();


------------------------------------------------------------------------------------------------
--
-- E2 d)
--
------------------------------------------------------------------------------------------------
create or replace function olympic.fn_get_info_by_sponsor (
    select_date date,
    sponsor varchar
)
returns table (
    email olympic.email_type,
    "name" varchar(100),
    athlete_name varchar(50),
    discipline_name varchar(50),
    round_number integer,
    mark varchar(12),
    rating integer,
    register date
)
language plpgsql
set search_path TO 'olympic'
as $$
begin
    return query
    select 
        ts.email,
        ts.name,
        tail.athlete_name,
        tail.discipline_name,
        tail.round_number,
        tail.mark,
        tail.rating,
        date(tr.register_updated)
    from olympic.tb_athletes_info_log tail 
    right join olympic.tb_finance tf on tf.athlete_id = tail.athlete_id 
    right join olympic.tb_sponsor ts on ts."name" = tf.sponsor_name
    right join olympic.tb_register tr on tr.athlete_id = tail.athlete_id
        and tr.round_number = tail.round_number 
        and tr.discipline_id = tail.discipline_id
    where date(tr.register_updated) = select_date
        and ts."name" = sponsor;
end; $$

-- select some date and some sponsor to check if function works
select olympic.fn_get_info_by_sponsor(current_date, 'Nike'::varchar);
