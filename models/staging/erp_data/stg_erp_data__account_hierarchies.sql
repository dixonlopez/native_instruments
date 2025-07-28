{{ config(materialized="view") }}

with
    source_data as (select * from {{ source("erp_data", "account_hierarchies") }}),

    renamed_and_casted as (

        select
            -- Primary Key
            account_code,

            -- Account Details
            account_description,
            account_type,  -- e.g., 'Asset', 'Liability', 'Equity', 'Revenue', 'Expense'

            -- Hierarchy Levels for Financial Statements
            parent_account_code,
            financial_statement_level_1,  -- e.g., 'Balance Sheet', 'P&L'
            financial_statement_level_2,  -- e.g., 'Current Assets', 'Operating Expenses'
            financial_statement_level_3,
            financial_statement_level_4,

            -- Flags
            is_summary_account as is_summary_account_flag

        from source_data

    )

select *
from renamed_and_casted
