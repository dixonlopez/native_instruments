-- This model is materialized as 'ephemeral' for performance and cost optimization.
-- By not creating a physical table, we allow BigQuery's query planner to see the full execution plan
-- and optimize the entire workflow at once, which is highly efficient for this type of join-heavy intermediate model.
{{
    config(
        materialized='ephemeral'
    )
}}

-- This model enriches the unified transactions with dimensional data.
-- It joins the pre-joined transactions with accounts, hierarchies, and code combinations.

with gl_transactions as (

    select * from {{ ref('stg_erp__gl_transactions') }}

),

accounts as (

    select * from {{ ref('base_erp__accounts') }}

),

account_hierarchy as (
    -- We only need the top-level parent for this simplified denormalization
    select
        base_account_id,
        max_by(parent_account_name, level) as top_level_parent_account_name
    from {{ ref('int_account_hierarchy_unpacked') }}
    group by 1

),

code_combinations as (

    select * from {{ ref('base_erp__code_combinations') }}

),

-- Join all transaction and dimension data together
final as (
    select
        -- Transaction details from pre-joined staging model
        general_ledger_transactions.line_id,
        general_ledger_transactions.entry_date,
        general_ledger_transactions.journal_id,
        general_ledger_transactions.journal_name,
        general_ledger_transactions.line_description,

        -- Account details
        general_ledger_transactions.account_id,
        accounts.account_code,
        accounts.account_name,
        accounts.account_type,
        accounts.financial_statement,

        -- Hierarchy details
        hierarchy.top_level_parent_account_name,
        
        -- Business segment details
        code_combinations.company_code,
        code_combinations.department_code,
        
        -- Measures from pre-joined staging model
        general_ledger_transactions.debit_amount,
        general_ledger_transactions.credit_amount,
        general_ledger_transactions.net_amount

    from gl_transactions as general_ledger_transactions
    left join accounts as accounts
        on general_ledger_transactions.account_id = accounts.account_id
    left join account_hierarchy as hierarchy 
        on general_ledger_transactions.account_id = hierarchy.base_account_id
    left join code_combinations as code_combinations
        on general_ledger_transactions.account_id = code_combinations.account_id
)

select * from final