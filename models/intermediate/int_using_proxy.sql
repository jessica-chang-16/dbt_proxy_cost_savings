WITH proxy as (
    SELECT
        *
    FROM {{ref('stg_proxy_data')}}
),

whitelisting as (
    SELECT
        *
    FROM {{ref('stg_whitelisting_data')}}
),

using_proxy as (
    SELECT
        {{dbt_utils.generate_surrogate_key(['retailer','whitelisting.brand','region'])}} as retailer_brand_region_key,
        whitelisting.retailer AS retailer,
        whitelisting.brand AS brand,
        whitelisting.region_abv AS region,
        whitelisting.whitelisted AS whitelisted,
        proxy.proxy AS proxy
    FROM
        proxy LEFT JOIN whitelisting ON proxy.brand = whitelisting.brand_region
    WHERE whitelisting.whitelisted = false
),

final as (
    SELECT
        retailer_brand_region_key,
        retailer,
        brand,
        region,
        whitelisted,
        proxy
    FROM using_proxy
)
SELECT
    *
FROM final