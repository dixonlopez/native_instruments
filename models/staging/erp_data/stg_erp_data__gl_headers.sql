{{ config(materialized="view") }}

with
    source_data as (select * from {{ source("erp_data", "general_ledger_headers") }}),

    renamed_and_casted as (

        select
            -- Primary Key
            header_id,

            -- Timestamps and Dates
            cast(transaction_date as date) as transaction_date,
            cast(posting_date as date) as posting_date,

            -- Descriptive Fields
            journal_source,  -- e.g. sales, purchase..
            journal_category,
            description as header_description

        from source_data

    )

select *
from renamed_and_casted
