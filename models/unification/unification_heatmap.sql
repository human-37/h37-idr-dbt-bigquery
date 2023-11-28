{{ config(materialized='table') }}

WITH OCCURENCES AS (
    SELECT 
        distinct 
        group_id, 
        node_type 
    FROM {{ ref('unification_identities_distincts') }}
),

CROSSED AS (
    SELECT
        group_id,
        OCCURENCES_LEFT.node_type AS node_type_1,
        OCCURENCES_RIGHT.node_type AS node_type_2,
        CAST(NULL AS INT64) AS default_value
    FROM OCCURENCES AS OCCURENCES_LEFT

    LEFT JOIN (SELECT node_type, group_id FROM OCCURENCES) AS OCCURENCES_RIGHT
    USING(group_id)
)

SELECT
  node_type_1,
  {{ dbt_utils.pivot(
      'node_type_2',
      dbt_utils.get_column_values(ref('unification_identities_distincts'), 'node_type'),
      agg='count',
      then_value='group_id',
      else_value='default_value',
      distinct=true
  ) }}
FROM CROSSED
GROUP BY node_type_1