{{
    config(
        materialized='table'
    )
}}

-- Aggregates movements for P&L accounts.

select
    -- Use EXTRACT to allow filtering by year/month in the spreadsheet
    extract(YEAR from entry_date) as financial_year,
    extract(MONTH from entry_date) as financial_month,
    account_id,
    account_code,
    account_name,
    account_type,
    top_level_parent_account_name,
    company_code,
    department_code,
    sum(net_amount) as period_net_movement

from {{ ref('fct_gl_transactions') }}
where financial_statement = 'P&L'
group by 1, 2, 3, 4, 5, 6, 7, 8, 9