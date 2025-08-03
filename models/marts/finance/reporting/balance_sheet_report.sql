{{
    config(
        materialized='table'
    )
}}

-- Aggregates balances for Balance Sheet accounts to show a closing balance for each month.

with monthly_movements as (
    select
        date_trunc(entry_date, month) as balance_month, -- column that could be used to filter
        account_id,
        account_code,
        account_name,
        account_type,
        top_level_parent_account_name,
        company_code,
        department_code,
        sum(net_amount) as monthly_net_movement
    from {{ ref('fct_gl_transactions') }}
    where financial_statement = 'Balance Sheet'
    group by 1, 2, 3, 4, 5, 6, 7, 8
),

monthly_balances as (
    select
        *,
        sum(monthly_net_movement) over (
            partition by account_id, company_code, department_code
            order by balance_month
            rows between unbounded preceding and current row
        ) as closing_balance
    from monthly_movements
)

select
    balance_month,
    account_id,
    account_code,
    account_name,
    account_type,
    top_level_parent_account_name,
    company_code,
    department_code,
    closing_balance
from monthly_balances