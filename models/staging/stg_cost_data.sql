{{config(materialized ='table')}}

WITH raw_client_data as
(
SELECT *
FROM {{source('raw_data','raw_client_data')}}
),
renamed as (
    SELECT 
    `company name` as retailer,
    slug as brand
    FROM raw_client_data
)
SELECT *
FROM renamed