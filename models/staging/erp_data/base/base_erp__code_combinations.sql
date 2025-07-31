{{ config(materialized='view') }}

-- This model extends the account dimension with business segments.
with source as (

    select * from {{ ref('code_combinations') }}

),

renamed as (

    select
        -- primary key
        cast(code_combination_id as integer) as code_combination_id,

        -- dimensions
        cast(company_code as string) as company_code,
        cast(department_code as string) as department_code,
        
        -- foreign key to the accounts table
        cast(account_id as integer) as account_id

    from source

)

select * from renamed
