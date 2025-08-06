-- This model is materialized as 'incremental' to efficiently handle the large volume of historical data (15+ years).
-- On a daily run, this strategy processes only new records instead of rebuilding the entire fact table,
-- significantly reducing query costs and execution time.
{{
    config(
        materialized='incremental',
        unique_key='line_id',
        partition_by={
            "field": "entry_month",
            "data_type": "date",
            "granularity": "month"
        },
        cluster_by=['account_name', 'account_type', 'financial_statement']
    )
}}

-- This model serves as the final presentation layer for the transaction fact data.

with transactions_source as (

    select * from {{ ref('int_transactions_enriched') }}

    {% if is_incremental() %}

    -- this filter restricts the set of rows that will be processed on an incremental run
    where entry_date > (select max(entry_date) from {{ this }})

    {% endif %}

),

final as (

    select 
        line_id,
        entry_date,
        DATE_TRUNC(entry_date, MONTH) AS entry_month,
        journal_id,
        journal_name,
        line_description,
        account_id,
        account_code,
        account_name,
        account_type,
        financial_statement,
        top_level_parent_account_name,
        company_code,
        department_code,
        debit_amount,
        credit_amount,
        net_amount

    from transactions_source

)

select * from final