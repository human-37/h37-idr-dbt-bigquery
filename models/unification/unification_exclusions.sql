{{ config(materialized='table') }}

{%- set models_list = get_unification_criteria() -%}

WITH EXCLUSIONS AS (
{%- for model in fromjson(models_list) -%}
    {%- for identifier in model.identifiers if identifier.exclude_threshold %}
    SELECT
        '{{ model.name }}' AS source,
        CAST({{identifier.field_name}} AS STRING) AS node_value,
        '{{identifier.name}}' AS node_type,
        COUNT(*) AS count_occurences,
        TRUE AS is_excluded
    FROM
        {{ ref(model.name) }}
    GROUP BY source, node_type, node_value
    HAVING count_occurences > {{identifier.exclude_threshold}}
    {% if not loop.last %}
    UNION ALL
    {% endif %}
    
    {%- endfor -%}
{% endfor %}
)

SELECT 
    * 
FROM
    EXCLUSIONS