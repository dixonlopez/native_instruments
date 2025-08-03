-- This analysis provides a high-level summary comparison between the legacy and new transaction tables.
-- It checks for rows that are in one table but not the other, and counts records that match on the primary key.
-- The goal is to quickly verify if the row counts are identical between the two systems.

{% set old_table %}
    select * from {{ ref('legacy_qs_gl_transactions') }}
{% endset %}

{% set new_table %}
    select * from {{ ref('fct_gl_transactions') }}
{% endset %}

with comparison as (
    {{ audit_helper.compare_queries(
        a_query=old_table,
        b_query=new_table,
        primary_key="line_id",
        summarize=true
    ) }}
)

select * from comparison