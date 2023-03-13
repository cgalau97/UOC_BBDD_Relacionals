------------------------------------------------------------------------------------------------
--
-- E3 b)
--
------------------------------------------------------------------------------------------------
create or replace function olympic.fn_send_sponsor_info (
    select_date date,
    sponsor varchar
)
returns jsonb
language plpgsql
set search_path TO 'olympic'
as $$
declare 
	send_sponsor_info jsonb; 
begin
	send_sponsor_info:= (
      select 
        jsonb_agg(
            json_build_object(
                'sponsor_email', ts.email,
                'sponsor_name', ts.name,
                'athlete_name', tail.athlete_name,
                'discipline_name', tail.discipline_name,
                'round_number', tail.round_number,
                'mark', tail.mark,
                'rating', tail.rating,
                'date', date(tr.register_updated)
        )
        ) send_list
        from olympic.tb_athletes_info_log tail 
        right join olympic.tb_finance tf on tf.athlete_id = tail.athlete_id 
        right join olympic.tb_sponsor ts on ts."name" = tf.sponsor_name
        right join olympic.tb_register tr on tr.athlete_id = tail.athlete_id
            and tr.round_number = tail.round_number 
            and tr.discipline_id = tail.discipline_id
        where date(tr.register_updated) = select_date
            and ts."name" = sponsor
    );

	return send_sponsor_info;
end; $$
