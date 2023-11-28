{{ config(materialized='table') }}

-- Change below number if the last iteration did not converge
{% set iterations = 7 %}

WITH 

{% for i in range(iterations) %}
ITERATION_{{ i + 1 }} AS (
        SELECT
        MIN(group_id) OVER(PARTITION BY node_id_left ) AS group_id,
        node_type,
        node_value,
        node_id_left,
        node_id_right,
        source_right,
        source_left,
        node_type_right,
        node_value_right,
        {{ i + 1 }} AS iteration
    FROM
    (SELECT
        MIN(group_id) OVER(PARTITION BY node_id_right ) AS group_id,
        node_type,
        node_value,
        node_id_left,
        node_id_right,
        source_right,
        source_left,
        node_type_right,
        node_value_right
    FROM {% if loop.first %} {{ ref('unification_edges') }} {% else %} ITERATION_{{ i }} {% endif %})
)
{%- if not loop.last %}
 ,
{%- endif %}
{% endfor %}


{% for i in range(iterations) %}
SELECT * FROM ITERATION_{{ i + 1 }}
{%- if not loop.last %}
UNION ALL
{%- endif %}

{% endfor %}