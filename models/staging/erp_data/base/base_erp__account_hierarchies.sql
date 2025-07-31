{{ config(materialized='view') }}

with source as (

    select * from {{ ref('account_hierarchies') }}

),

renamed as (

    select
        -- primary key
        cast(hierarchy_id as integer) as hierarchy_id,
        
        -- foreign keys
        cast(account_id as integer) as account_id,
        cast(parent_account_id as integer) as parent_account_id

    from source

)

select * from renamed