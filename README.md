# Manual Customer Retention

## Project Overview

This project aims to analyse customer retention by looking at key metrics like active customers, sign ups, and churn per month as well as doing a cohort analysis to see how well customers are being retained based on when they signed up.

## Data Sources

The data sources come from 3 csv tables which were uploaded into bigquery:

- **activity Table**: Contains customer activity including `customer_id`, `from_date` (when the customer became active), and `to_date` (when the customer became inactive).
- **customers Table**: Contains customer information including `customer_id` and `customer_country`.
- **acq_orders Table**: Contains acquisition information including `customer_id`, and `taxonomy_business_category_group` (the group the customer signed up to)

## Data Models

This project includes two key dbt models:

1. **retention_over_time**: A table by month, country, and acquisition taxonomy for key metrics including active customers, sign ups, and churn.
2. **retention_cohort**: Cohort analysis by month, country, and acquisition taxonomy showing the number of months that number of customers was active for.

## Packages

Packages used in this project are:

- **dbt_utils**: This is used for the unique combination of columns test.

## Notes

- For table and column level descriptions and definitions, see the yaml files.