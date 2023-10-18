select tbl.name as 'tabela', 
       trg.name 'gatilho',
	   case when trg.is_disabled = 1 then 'Desabilitado' else 'Habilitado' end as [status]
  from corpore.sys.triggers trg inner join corpore.sys.tables tbl on (trg.parent_id=tbl.object_id)
 WHERE trg.name not like 'log%'
order by tbl.name