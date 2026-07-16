import requests
from google.cloud import bigquery

URL = ("https://api.fiscaldata.treasury.gov/services/api/fiscal_service/v1/accounting/od/rates_of_exchange")
params = {
        "fields": "country,currency,exchange_rate,record_date",
        "filter": "record_date:gte:2026-01-01",
        "page[size]": 1000,
}
def main():
    req = requests.get(URL, params=params)
    print(f"Fetching data from {URL}")
    data = req.json()
    
    rows = [{
        "country": record["country"],
        "currency": record["currency"],
        "exchange_rage": float(record["exchange_rate"]),
        }
        for record in data["data"]
        ]

    client = bigquery.Client()
    table_id = "cost-savings-tl.analytics.exchange_rates"
    job = client.load_table_from_json (rows, table_id)
    job.result()
    print("Success!")

if __name__ == "__main__":
    main()