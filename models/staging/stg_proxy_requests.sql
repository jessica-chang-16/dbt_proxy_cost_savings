WITH base AS
    (SELECT *
    FROM {{source('csv_proxy_requests', 'proxy_requests_amount')}}
    ),

casting AS
    (SELECT
    FORMAT_DATE('%B', DATETIME(date)) as month,
    crawler_slug as brand,
    SPLIT(crawler_slug,'-') [OFFSET(1)] AS region_abv,
    proxy_type,
    http_requests as num_requests,
    rate_usd_per_1000_requests,
    cost_usd
    FROM base)

SELECT 
    *
FROM casting