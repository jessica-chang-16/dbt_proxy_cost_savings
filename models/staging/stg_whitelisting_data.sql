{{config(materialized ='table')}}

WITH whitelisting as(
    SELECT
        *
    FROM {{source('google_sheets_raw_clients', 'raw_client_data')}}
),
renamed as (
    SELECT 
        Company_name as retailer,
        SPLIT(Slug,'-') [OFFSET(0)] AS brand,
        SPLIT(Slug,'-') [OFFSET(1)] AS region_abv,
        Slug as brand_region,
        Whitelisted
    FROM whitelisting
),

final as (
    SELECT *
    from renamed
)
SELECT *
FROM final