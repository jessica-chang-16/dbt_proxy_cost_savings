WITH retailer_info as (
    SELECT
        retailer,
        brand_region,
        whitelisted
    FROM {{ref('stg_whitelisting_data')}}
)

SELECT *
FROM retailer_info