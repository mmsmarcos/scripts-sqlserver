SELECT * FROM information_schema.constraint_column_usage
 WHERE TABLE_NAME='TMOV' 
   AND CONSTRAINT_NAME LIKE 'FK%'
   AND COLUMN_NAME IN ('CODCOLIGADA', 'CODTB1FLX')
   AND CONSTRAINT_NAME LIKE '%FTB1'

select o.name as mastertable, 
       c.name as mastercolumn, 
	   table_name childtable,
	   column_name childcolumn,
	   type_name(c.system_type_id) as tipo
from sys.objects o inner join sys.columns c on o.object_id = c.object_id
                   inner join sys.schemas s on o.schema_id = s.schema_id
				   left join sys.index_columns ic on ic.column_id = c.column_id and ic.object_id = c.object_id
			       left join sys.indexes i on i.index_id = ic.index_id and ic.object_id = i.object_id
				   inner join information_schema.constraint_column_usage on information_schema.constraint_column_usage.column_name=c.name
where o.type_desc = 'user_table' 
  and o.name = 'TPRODUTO'
  and table_name='TITMMOV'
  AND CONSTRAINT_NAME LIKE 'FK%'
  AND CONSTRAINT_NAME LIKE '%TITMMOV'
  and s.name = 'dbo'
  and i.is_primary_key = 1;