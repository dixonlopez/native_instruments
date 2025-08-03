{{ config(materialized='view') }}

with source as (
    select * from {{ ref('customers') }}
),

renamed as (
    select
        -- primary key
        cast(customer_id as string) as customer_id,

        -- dimensions
        cast(customer_name as string) as customer_name
    from source
)

select * from renamed
