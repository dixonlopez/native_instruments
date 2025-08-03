{{ config(materialized='view') }}

with source as (
    select * from {{ ref('products') }}
),

renamed as (
    select
        -- primary key
        cast(product_id as string) as product_id,

        -- dimensions
        cast(product_name as string) as product_name
    from source
)

select * from renamed