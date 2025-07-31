{{ config(materialized='view') }}

with source as (

    select * from {{ ref('gl_headers') }}

),

renamed as (

    select
        -- primary key
        cast(journal_id as integer) as journal_id,
        
        -- dimensions
        cast(journal_name as string) as journal_name,
        cast(entry_date as date) as entry_date

    from source

)

select * from renamed