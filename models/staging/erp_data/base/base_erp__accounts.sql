{{ config(materialized='view') }}

-- This model acts as a core dimension for the Chart of Accounts.
with source as (

    select * from {{ ref('accounts') }}

),

renamed as (

    select
        -- primary key
        cast(account_id as integer) as account_id,

        -- dimensions
        cast(account_code as string) as account_code,
        cast(account_name as string) as account_name,
        cast(account_type as string) as account_type,
        cast(financial_statement as string) as financial_statement

    from source

)

select * from renamed