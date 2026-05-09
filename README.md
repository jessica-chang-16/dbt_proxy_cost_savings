### Proxy Cost Savings Analysis | dbt core, BigQuery, SQL

#### Summary:
This project transforms a manual, error-prone gap analysis project into a modular ELT pipeline. Using mock data, I migrated fragmented CSV data into BigQuery to help identify high-cost crawlers that are using third-party proxies.

The focus of the project is to create a target list of clients where we are currently not being allowed whitelisting so having to use costly third-party proxies to help collect data. With the results of the target list, we can utilize these established relationships to implement whitelisting headers; The end result being reduced third-party proxies used.

#### Business Impact:
  - Cost Reduction: Automates the identification of clients who own high cost crawlers.
  - Operational Efficiency: Replaces manual spreadsheet joins with automated dbt models.
  - Actionable Insights: Generates a prioritized outreach list for account management team.
    

#### Data Architecture & Modeling:
![Data lineage graph](cost_savings_data_lineage.png)

This project follows a modular, three-tier architecture designed for scalability and maintainability. 

  - Staging Layer (`stg_`): Cleans and standardizes raw CSV data from Google Sheets. Handles renaming, type casting, and initital filtering to ensure a clean starting point.
  - Intermediate Layer (`int_`): Performs core business logic and joins (`int_proxy_exception`) with client metadata to isolate high-cost proxy dependant crawlers.
  - Marts Layer (`fct_`, `dim_`):
    - fct_outreach_target_list: This is the centralized fact table used for reporting and outreach prioritization.
    - dim_retailers: This is a dimension table that provides the single source of truth for retailer attributes. 

#### Key Features:
  - Modular Logic: Decoupled transformations for maintainability and reusibility.
  - Data Quality: Implemented automated dbt tests (unique, not_null) to ensure data integrity.
  - Star Schema: Designed the final marts to isolate facts from descriptive dimensions, allowing for performance and streamlined architecture within BigQuery. 

This is currently still being worked on. Next steps after having tested is to document and orchestrate within dbt cloud.
