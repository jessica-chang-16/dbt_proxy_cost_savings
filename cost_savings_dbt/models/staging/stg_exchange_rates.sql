WITH rate AS
    (SELECT *
    FROM {{source('api_exchange_rates','exchange_rates')}}
    ),

rename AS
    (SELECT
    country,
    exchange_rage AS exchange_rate,
    currency
    FROM rate),

final AS
    (SELECT
    country,
    exchange_rate,
    currency
    FROM rename
    )

SELECT *
FROM final