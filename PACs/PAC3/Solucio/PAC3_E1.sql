------------------------------------------------------------------------------------------------
--
-- E1 a)
--
------------------------------------------------------------------------------------------------
alter table olympic.tb_register
  rename column register_date to register_ts;
alter table olympic.tb_register
  alter column register_ts type timestamp using register_ts::timestamp;
alter table olympic.tb_register
  alter column register_ts set default current_timestamp;

------------------------------------------------------------------------------------------------
--
-- E1 b)
--
------------------------------------------------------------------------------------------------
alter table olympic.tb_register add register_updated timestamp null;

create or replace function olympic.fn_register_inserted() returns trigger as $$
begin
  new.register_updated = new.register_ts;
  return new;
end; $$
language plpgsql;

create trigger tg_register_inserted
  after insert on olympic.tb_register
  for each row 
  execute procedure olympic.fn_register_inserted();

------------------------------------------------------------------------------------------------
--
-- E1 c)
--
------------------------------------------------------------------------------------------------

create or replace function olympic.fn_register_updated() returns trigger as $$
begin
  if pg_trigger_depth() < 1 THEN
    update olympic.tb_register
      set register_updated = current_timestamp
      where athlete_id = old.athlete_id
        and round_number = old.round_number
        and discipline_id = old.discipline_id;
  end if;
  return new;
end; $$
language plpgsql;

create trigger tg_register_updated
  after update on olympic.tb_register
  for each row
  execute procedure olympic.fn_register_updated();
