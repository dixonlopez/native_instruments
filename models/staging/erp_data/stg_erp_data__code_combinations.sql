{{ config(materialized="view") }}

with
    source_data as (select * from {{ source("erp_data", "code_combinations") }}),

    renamed_and_casted as (

        select
            -- Primary Key
            combination_id,

            -- Accounting Segment Codes
            segment1 as company_code,
            segment2 as cost_center_code,
            segment3 as account_code,  -- This is the natural account
            segment4 as intercompany_code,
            segment5 as future_use_segment_code

        from source_data

    )

select *
from renamed_and_casted
