WITH proxy_data as (
    SELECT
    *
FROM {{source('google_sheets_raw_proxy','proxy_raw_data')}}
),

renamed as (
    SELECT
    `Slug` as brand,
    Proxy_request_all as proxy,
    COALESCE(Region,'unassigned') as region,
    whitelisted
FROM proxy_data 
),

final as (
    SELECT
    brand,
    proxy,
    region,
    whitelisted
FROM renamed
WHERE proxy != '#N/A'
)

SELECT *
FROM final