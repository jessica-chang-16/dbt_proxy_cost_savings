{{
    config(
        materialized = 'table',
    )
}}

select date_day
from unnest(generate_date_array('2000-01-01', '2030-01-01', interval 1 day)) as date_day
