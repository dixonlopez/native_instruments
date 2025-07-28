{{ config(materialized="view") }}

with
    source_data as (select * from {{ source("erp_data", "general_ledger_lines") }}),

    renamed_and_casted as (

        select
            -- Primary & Foreign Keys
            line_id,
            header_id,
            combination_id,

            -- Financial Amounts, cast to a numeric type for calculations.
            cast(entered_dr as numeric) as debit_amount,
            cast(entered_cr as numeric) as credit_amount,

            -- Details
            description as line_description,
            currency_code

        from source_data

    )

select *
from renamed_and_casted
