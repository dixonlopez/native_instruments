{{
    config(
        materialized="table", cluster_by=["balance_month_end_date", "account_code"]
    )
}}

with
    transactions_mart as (select * from {{ ref("fact_finance__transactions") }}),

    -- First, get the monthly net change for each balance sheet account
    monthly_activity as (
        select
            last_day(posting_date, month) as month_end_date,
            company_code,
            account_code,
            account_description,
            account_type,
            financial_statement_level_2,
            financial_statement_level_3,
            financial_statement_level_4,
            sum(net_amount) as monthly_net_change
        from transactions_mart
        where account_type in ('Asset', 'Liability', 'Equity')
        group by 1, 2, 3, 4, 5, 6, 7, 8
    ),

    -- Now, calculate the running total (cumulative balance) over time
    balance_sheet_calculation as (
        select
            month_end_date as balance_month_end_date,
            company_code,
            account_code,
            account_description,
            account_type,
            financial_statement_level_2,
            financial_statement_level_3,
            financial_statement_level_4,
            sum(monthly_net_change) over (
                partition by company_code, account_code
                order by month_end_date
                rows between unbounded preceding and current row
            ) as month_end_balance
        from monthly_activity
    )

select *
from balance_sheet_calculation
