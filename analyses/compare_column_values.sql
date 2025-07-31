-- This analysis performs a detailed, column-by-column comparison for rows that exist in both the legacy and new tables.
-- It identifies specific columns where the values do not match for a given primary key.
-- This is crucial for pinpointing exact discrepancies in the transformation logic.

{% set old_table = ref('legacy_qs_gl_transactions') %}
{% set new_table = ref('fct_gl_transactions') %}

with comparison as (

    {{ audit_helper.compare_all_columns(
        a_relation=old_table,
        b_relation=new_table,
        primary_key="line_id"
    ) }}

)

select * from comparison