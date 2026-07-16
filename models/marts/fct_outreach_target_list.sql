WITH proxy_exception as (
    SELECT
        retailer,
        brand,
        region,
        whitelisted,
        proxy
    FROM {{ref('int_using_proxy')}}
),

client_info as (
    SELECT
        pe.retailer as retailer,
        pe.brand as brand,
        pe.region as region,
        pe.whitelisted as whitelisted,
        pe.proxy as proxy,
        c.account_manager as account_manager,
        c.customer_success_manager as csm
    FROM proxy_exception as pe
    LEFT JOIN {{ref('dim_clients')}} as c
    ON pe.retailer = c.client_name

),

region_info as (
    SELECT
        ci.retailer as retailer,
        ci.brand as brand,
        ci.region as region,
        ci.whitelisted as whitelisted,
        ci.proxy as proxy,
        ci.account_manager as account_manager,
        ci.csm as csm,
        r.region_name as region_name
    FROM client_info as ci
    LEFT JOIN {{ref('dim_regions')}} as r
    ON ci.region = r.region_abv
),

final as (
    SELECT
        retailer,
        brand,
        region as region_abv,
        region_name,
        whitelisted,
        proxy,
        account_manager,
        csm,
    FROM region_info
)

SELECT
    *
FROM final