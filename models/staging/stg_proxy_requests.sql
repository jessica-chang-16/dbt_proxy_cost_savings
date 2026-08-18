WITH base AS (
    SELECT 
    *
    FROM {{source('csv_proxy_requests', 'proxy_requests_amount')}}
),

casting AS (
    SELECT
    DATE_TRUNC(DATE(date), MONTH) as month,
    SPLIT(crawler_slug,'-') [SAFE_OFFSET(0)] AS brand,
    SPLIT(crawler_slug,'-') [SAFE_OFFSET(1)] AS region_abv,
    proxy_type,
    http_requests as num_requests,
    rate_usd_per_1000_requests,
    cost_usd
    FROM base
),

final AS (
    SELECT
    month,
    brand,
    region_abv,
    proxy_type,
    num_requests,
    rate_usd_per_1000_requests,
    cost_usd
    FROM casting
)

SELECT 
    *
FROM final