/*
	Autor: Marcos Miguel
	Data: 15/08/2018
	Objetivo: Analisando Índices
*/

--Exibe os índices da tabela
Use CorporeRM_Teste
GO
EXEC sp_helpindex 'FLAN'

-- Analisando o histograma dos índices
-- DBCC SHOW_STATISTICS(Nome_da_Tabela, Nome_do_Indice)
DBCC SHOW_STATISTICS(Logins, SK01)

--Exibe as páginas do indice 01 da tabela FLAN
DBCC IND('CorporeRM_Teste', 'FLAN',1)

--Verificar a utilização dos índices
SELECT
    ObjectName = OBJECT_SCHEMA_NAME(idx.object_id) + '.' + OBJECT_NAME(idx.object_id),
    IndexName = idx.name,
    IndexType = CASE WHEN is_unique = 1 THEN 'UNIQUE ' ELSE '' END + idx.type_desc,
    User_Seeks = us.user_seeks,
    User_Scans = us.user_scans,
    User_Lookups = us.user_lookups,
    User_Updates = us.user_updates
FROM
    sys.indexes idx
    LEFT JOIN sys.dm_db_index_usage_stats us ON idx.object_id = us.object_id AND idx.index_id = us.index_id AND us.database_id = DB_ID()
WHERE
    OBJECT_SCHEMA_NAME(idx.object_id) != 'sys'
ORDER BY
    us.user_seeks + us.user_scans + us.user_lookups DESC


--Identificando índices ausentes (missing index)
SELECT
    mid.statement,
    migs.avg_total_user_cost * ( migs.avg_user_impact / 100.0 ) * ( migs.user_seeks + migs.user_scans ) AS improvement_measure,
    OBJECT_NAME(mid.object_id),
    'CREATE INDEX [missing_index_' + CONVERT (VARCHAR, mig.index_group_handle) + '_' + CONVERT (VARCHAR, mid.index_handle) + '_' + LEFT(PARSENAME(mid.statement, 1), 32) + ']' + ' ON ' + mid.statement + ' (' + ISNULL(mid.equality_columns, '') + CASE WHEN mid.equality_columns IS NOT NULL AND mid.inequality_columns IS NOT NULL THEN ',' ELSE '' END + ISNULL(mid.inequality_columns, '') + ')' + ISNULL(' INCLUDE (' + mid.included_columns + ')', '') AS create_index_statement,
    migs.*,
    mid.database_id,
    mid.[object_id]
FROM
    sys.dm_db_missing_index_groups mig
    INNER JOIN sys.dm_db_missing_index_group_stats migs ON migs.group_handle = mig.index_group_handle
    INNER JOIN sys.dm_db_missing_index_details mid ON mig.index_handle = mid.index_handle
WHERE
    migs.avg_total_user_cost * ( migs.avg_user_impact / 100.0 ) * ( migs.user_seeks + migs.user_scans ) > 10
ORDER BY
    migs.avg_total_user_cost * migs.avg_user_impact * ( migs.user_seeks + migs.user_scans ) DESC