WITH base_rates AS
    (SELECT *
    FROM {{ref('stg_exchange_rates')}}
    ),

proxy_requests AS
    (SELECT *
    FROM {{ref('stg_proxy_requests')}}
    ),

average_rate_per_country AS
    (SELECT
    r.country AS country,
    AVG(r.exchange_rate) AS avg_exchange_rate,
    r.currency AS currency,
    dr.region_abv AS region_abv
    FROM base_rates r
    LEFT JOIN {{ref('dim_regions')}} AS dr
    ON r.country = dr.region_name
    GROUP BY r.country, r.currency, dr.region_abv
    ),

country_exchange_rates AS
    (SELECT
    pr.month AS month,
    pr.brand AS brand,
    pr.num_requests AS num_http_requests,
    ROUND(pr.cost_usd,2) AS cost_usd,
    arpc.country AS country,
    arpc.avg_exchange_rate AS avg_exchange_rate,
    arpc.currency AS currency
    FROM proxy_requests AS pr
    LEFT JOIN average_rate_per_country AS arpc
    ON pr.region_abv = arpc.region_abv
    ),

proxy_cost_per_country AS
    (SELECT
    month,
    brand,
    country,
    ROUND(cost_usd * avg_exchange_rate,2) AS cost_country,
    currency,
    cost_usd
    FROM country_exchange_rates
    ),

final AS
    (SELECT
    month,
    brand,
    country,
    cost_country,
    currency,
    cost_usd
    FROM proxy_cost_per_country
    )

SELECT *
FROM final