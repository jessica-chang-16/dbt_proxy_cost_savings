-- cast date into month
-- select all columns
-- aggregation will happen in intermediate mart with joining exchange rate

WITH requests AS
    (SELECT *
    FROM {{source('csv_proxy_requests', 'proxy_requests_amount')}}
    ),

