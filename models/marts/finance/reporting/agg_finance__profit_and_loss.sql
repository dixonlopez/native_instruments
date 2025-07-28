{{ config(materialized="table", cluster_by=["financial_year", "account_code"]) }}

with
    transactions_mart as (select * from {{ ref("fact_finance__transactions") }}),

    profit_and_loss_aggregation as (

        select
            -- Date Dimensions
            extract(year from posting_date) as financial_year,
            extract(month from posting_date) as financial_month,
            last_day(posting_date, month) as month_end_date,

            -- Accounting Dimensions
            company_code,
            cost_center_code,
            account_code,
            account_description,
            account_type,
            financial_statement_level_2,
            financial_statement_level_3,
            financial_statement_level_4,

            -- Aggregated Financials
            sum(net_amount) as total_net_amount

        from transactions_mart
        -- Filter for P&L accounts only based on the account hierarchy.
        where account_type in ('Revenue', 'Expense')
        group by 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11

    )

select *
from profit_and_loss_aggregation
