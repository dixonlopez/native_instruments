{{ config(materialized='view') }}

with source as (

    select * from {{ ref('gl_lines') }}

),

renamed as (

    select
        -- primary key
        cast(line_id as integer) as line_id,

        -- foreign keys
        cast(journal_id as integer) as journal_id,
        cast(account_id as integer) as account_id,

        -- dimensions
        cast(description as string) as line_description,

        -- measures
        cast(debit as numeric) as debit_amount,
        cast(credit as numeric) as credit_amount

    from source

)

select * from renamed