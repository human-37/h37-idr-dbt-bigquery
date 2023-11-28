{{ config(materialized='table') }}

WITH NODES AS (
    SELECT
        node_type,
        node_value,
        node_id,
        group_id,
        source
    FROM {{ ref('unification_nodes') }}
)

-- recreates all directions by joining directional edges

SELECT
    group_id,
    NODES_LEFT.node_type AS node_type,
    NODES_LEFT.node_value AS node_value,
    NODES_LEFT.node_id AS node_id_left,
    NODES_LEFT.source AS source_left,
    NODES_RIGHT.node_id AS node_id_right,
    NODES_RIGHT.source AS source_right,
    NODES_RIGHT.node_type AS node_type_right,
    NODES_RIGHT.node_value AS node_value_right

FROM NODES AS NODES_LEFT

LEFT JOIN (SELECT node_id, group_id, source, node_type, node_value FROM NODES) AS NODES_RIGHT
USING(group_id)