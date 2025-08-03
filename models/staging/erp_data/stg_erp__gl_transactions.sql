{{ config(materialized='view') }}

-- This model joins general ledger lines with their corresponding headers
-- to create a unified view of transactions at the staging layer.

with gl_lines as (

    select * from {{ ref('base_erp__gl_lines') }}

),

gl_headers as (

    select * from {{ ref('base_erp__gl_headers') }}

),

final as (
    select
        -- From Headers
        gl_headers.entry_date,
        gl_headers.journal_id,
        gl_headers.journal_name,
        
        -- From Lines
        gl_lines.line_id,
        gl_lines.line_description,
        gl_lines.account_id,
        
        gl_lines.debit_amount,
        gl_lines.credit_amount,
        
        -- Calculated field
        (gl_lines.debit_amount - gl_lines.credit_amount) as net_amount

    from gl_lines
    inner join gl_headers on gl_lines.journal_id = gl_headers.journal_id
)

select * from final