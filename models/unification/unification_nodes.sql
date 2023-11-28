{{ config(materialized='table') }}

{% set models_list = get_unification_criteria() %}

WITH NODES AS (
    {% for model in fromjson(models_list) %}
    SELECT 
        '{{ model.name }}' AS source,
        [
            {% for identifier in model.identifiers %}

            STRUCT(
                CAST({{identifier.field_name}} AS STRING) AS node_value,
                '{{identifier.name}}' AS node_type
            )
            {% if not loop.last %},{% endif %}

            {% endfor %}
        ] AS nodes
    
    FROM
    {{ ref(model.name) }}

    {%- if not loop.last %}
    UNION ALL
    {%- endif %}

    {% endfor %}
),

GROUPED_NODES AS (
    SELECT
        NODES.nodes,
        source,
        DENSE_RANK() OVER (ORDER BY TO_JSON_STRING(nodes) ASC) AS group_id
    FROM NODES
),

UNIQUE_NODE_GROUPS_PER_SOURCE AS (
    SELECT
        *
    FROM GROUPED_NODES
    QUALIFY ROW_NUMBER() OVER(PARTITION BY group_id, source ORDER BY 1) = 1
),

NODES_UNFILTERED AS (
    SELECT 
        group_id,
        source,
        CAST(n.node_type AS STRING) AS node_type,
        CAST(n.node_value AS STRING) AS node_value
    FROM UNIQUE_NODE_GROUPS_PER_SOURCE, UNNEST(UNIQUE_NODE_GROUPS_PER_SOURCE.nodes) n
    WHERE 
        node_value IS NOT NULL
),

NODES_FILTERED AS (
    SELECT
        group_id,
        source,
        node_type,
        CASE 
            WHEN is_excluded THEN CONCAT(node_value, '-REDACTED-', GENERATE_UUID())
            ELSE node_value
        END AS node_value
    FROM NODES_UNFILTERED

    LEFT JOIN (SELECT * FROM {{ ref('unification_exclusions') }} WHERE node_value IS NOT NULL)
    USING(source, node_value, node_type)
)

SELECT 
    group_id,
    source,
    node_type,
    node_value,
    DENSE_RANK() OVER (ORDER BY node_type, node_value) AS node_id
FROM NODES_FILTERED