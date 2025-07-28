{{
    config(
        materialized="incremental",
        unique_key="line_id",
        incremental_strategy="merge",
        partition_by={
            "field": "posting_date",
            "data_type": "date",
            "granularity": "month",
        },
        cluster_by=["account_code", "company_code"],
    )
}}

with
    general_ledger_unioned as (

        select * from {{ ref("int_finance__general_ledger_unioned") }}

    ),

    account_hierarchies as (

        select * from {{ ref("stg_erp_data__account_hierarchies") }}

    ),

    final_transactions_with_details as (

        select
            -- Transaction Keys
            general_ledger_unioned.line_id,
            general_ledger_unioned.header_id,

            -- Dates
            general_ledger_unioned.posting_date,
            general_ledger_unioned.transaction_date,

            -- Enriched Account & Hierarchy Details
            general_ledger_unioned.account_code,
            account_hierarchies.account_description,
            account_hierarchies.account_type,
            account_hierarchies.financial_statement_level_1,
            account_hierarchies.financial_statement_level_2,
            account_hierarchies.financial_statement_level_3,
            account_hierarchies.financial_statement_level_4,

            -- Other Dimensions
            general_ledger_unioned.company_code,
            general_ledger_unioned.cost_center_code,
            general_ledger_unioned.intercompany_code,

            -- Financials
            general_ledger_unioned.debit,
            general_ledger_unioned.credit,
            general_ledger_unioned.net_amount,

            -- Descriptions
            general_ledger_unioned.header_description,
            general_ledger_unioned.line_description

        from general_ledger_unioned
        left join
            account_hierarchies
            on general_ledger_unioned.account_code = account_hierarchies.account_code

        {% if is_incremental() %}

            -- This filter is crucial for performance. It tells dbt to only scan for
            -- records
            -- on or after the latest posting date already in the target table.
            where
                general_ledger_unioned.posting_date
                >= (select max(posting_date) from {{ this }})

        {% endif %}

    )

select *
from final_transactions_with_details
