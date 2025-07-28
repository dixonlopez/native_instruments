{{ config(materialized="table") }}

with
    general_ledger_lines as (select * from {{ ref("stg_erp_data__gl_lines") }}),

    general_ledger_headers as (select * from {{ ref("stg_erp_data__gl_headers") }}),

    code_combinations as (select * from {{ ref("stg_erp_data__code_combinations") }}),

    -- This CTE joins the core transaction components to create a single, unified record
    -- for each general ledger line item.
    unioned_ledger_transactions as (

        select
            -- Keys
            general_ledger_lines.line_id,
            general_ledger_lines.header_id,
            general_ledger_lines.combination_id,

            -- Dates
            general_ledger_headers.transaction_date,
            general_ledger_headers.posting_date,

            -- Accounting Codes from the combination table
            code_combinations.account_code,
            code_combinations.company_code,
            code_combinations.cost_center_code,
            code_combinations.intercompany_code,

            -- Financials - Coalesce nulls to 0 to ensure accurate calculations.
            coalesce(general_ledger_lines.debit_amount, 0) as debit,
            coalesce(general_ledger_lines.credit_amount, 0) as credit,
            debit - credit as net_amount,

            -- Descriptions
            general_ledger_headers.header_description,
            general_ledger_lines.line_description

        from general_ledger_lines
        inner join
            general_ledger_headers
            on general_ledger_lines.header_id = general_ledger_headers.header_id
        inner join
            code_combinations
            on general_ledger_lines.combination_id = code_combinations.combination_id

    )

select *
from unioned_ledger_transactions
