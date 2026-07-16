WITH rates AS
    (SELECT *
    FROM {{ref('stg_exchange_rates')}}
    ),

average_rate AS
    (SELECT
    country,
    AVG(exchange_rate) AS avg_exchange_rate,
    currency
    FROM rates
    GROUP BY country, currency
    ),

final AS
    (SELECT
    country,
    avg_exchange_rate,
    currency
    FROM average_rate
    WHERE country = 'United Kingdom'
    )

SELECT *
FROM final