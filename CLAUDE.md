# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project overview

A dbt Core project (BigQuery adapter) that automates a "proxy cost savings" gap analysis for a retail intelligence SaaS company. The company scrapes retailer websites and pays for expensive third-party proxies to bypass anti-scraping blockers. If a blocked retailer is already a client, the company can request direct IT whitelisting instead of paying for a proxy. This pipeline joins proxy-usage data against client/whitelisting data to produce a prioritized outreach list for the customer success team, feeding a Looker Studio dashboard.

Read `README.md` for the full business context and architecture rationale before making model changes — it explains *why* the layers are structured this way, not just what they do.

## Project structure

- Staging models: models/staging/stg\_\*.sql
- Marts models: models/marts/fct*\*, dim*\*
- Each model should have a corresponding .yml file with tests and descriptions

Three-tier dbt structure, all sourced from BigQuery external tables (Google Sheets) or API-ingested tables — no static CSV uploads except the two seeds.

- **Ingestion** (`ingestion/currency_exchange.py`): a standalone script (not run by dbt/CI) that pulls exchange rates from the US Treasury `fiscal_service` API and loads them into `cost-savings-tl.analytics.exchange_rates` via the `google-cloud-bigquery` client. Run manually/out-of-band when exchange rate data needs refreshing.
- **Staging (`stg_`)**: 1:1 with a source table. Renames columns, casts types, filters obvious junk (e.g. `stg_proxy_data` drops `proxy = '#N/A'` rows). No joins.
  - `stg_exchange_rates` ← `api_exchange_rates.exchange_rates` (from the ingestion script)
  - `stg_proxy_data` ← `google_sheets_raw_proxy.proxy_raw_data`
  - `stg_proxy_requests` ← `csv_proxy_requests.proxy_requests_amount`
  - `stg_whitelisting_data` ← `google_sheets_raw_clients.raw_client_data`
- **Intermediate (`int_`)**: business logic and multi-source joins.
  - `int_using_proxy`: joins `stg_proxy_data` to `stg_whitelisting_data` on `proxy.brand = whitelisting.brand_region`, keeping only rows where `whitelisted = false`. This is the core "proxy exception" logic.
  - `int_average_exchange_rate`: joins `stg_exchange_rates` and `stg_proxy_requests` through the `dim_regions` seed (matching on region abbreviation) to convert USD proxy costs into local currency per country/month.
- **Marts (`fct_`, `dim_`)**: star schema, final BI-facing layer, materialized as tables.
  - `fct_outreach_target_list`: fact table — chains `int_using_proxy` → `dim_clients` seed (adds account manager / CSM) → `dim_regions` seed (adds region name). This is the table the outreach dashboard reads.
  - `dim_retailers`: retailer dimension, sourced directly from `stg_whitelisting_data`.

Key join key convention: brand/region identity is usually carried as a single slugged `brand_region` string (e.g. `slug` split on `-` into `brand` + `region_abv`), so staging models frequently do `SPLIT(slug, '-')[OFFSET(n)]` to decompose it — the joins across layers depend on `brand` and `region_abv` being derived consistently this way.

Known upstream quirk: the raw exchange-rate source field is literally misspelled `exchange_rage` (both in the ingestion script's uploaded column name and in `stg_exchange_rates.sql`'s reference to it) — this is intentional/consistent, not a bug to silently "fix" in one file without the other.

## SQL style

- Use CTEs with clear names: source, renamed, final
- Always alias tables and qualify columns
- Prefer explicit column lists (avoid SELECT \* in marts)
- Use {{ source() }} for raw tables, {{ ref() }} for model references

## dbt CLI

- Use `dbt build --select <model>` to build and test a specific model
- Use `dbt build --select state:modified+` to build only changed models
- Use `dbt test --select <model>` to run tests only
- Use `dbt compile --select <model>` to see compiled SQL

## Data quality

- `not_null` tests are applied at the staging layer on join-key and business-critical columns (e.g. `brand`, `proxy`, `brand_region`, `whitelisted`) to prevent silent record loss in downstream joins — per the README, this is a deliberate design choice, not incidental coverage.
- Two files (`stg_proxy_requests.yml`, `int_average_exchange_rate.yml`) still have `#add columns, descriptions and tests` placeholder comments — descriptions/tests there are incomplete and known to be in-progress.

## Security note
- Never hardcode credentials, instead use env_var() in profiles.yml
- Never modify profiles.yml or dbt_cloud.yml directly
`bigquery-key.json` exists in the repo root locally but is correctly gitignored (`*.json` in `.gitignore`) — never remove that gitignore rule or add BigQuery/service-account keys to git.

