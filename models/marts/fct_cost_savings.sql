WITH cost_savings AS
    (SELECT
    month_brand_key,
    month,
    brand,
    region_abv,
    SUM(num_http_requests) as total_http_requests,
    country,
    ROUND(SUM(cost_country),2) as total_og_currency_cost_savings,
    ROUND(SUM(cost_usd),2) as total_usd_cost_savings
    FROM {{ref('int_average_exchange_rate')}}
    GROUP BY month_brand_key, month, brand, region_abv, country
    ),

final as
    (SELECT
    month_brand_key,
    month,
    brand,
    region_abv,
    country,
    total_http_requests,
    total_og_currency_cost_savings,
    total_usd_cost_savings
    FROM cost_savings
    )

SELECT * from final