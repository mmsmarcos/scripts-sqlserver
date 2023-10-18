-- Nome: ASS_PROJETOS_TOTVS_CLIENTE_SQLSERVER_HTML.sql
-- Modulo/Descrição : Assessment Servidor SQLSERVER / Informações Gerais
-- Atenção: Este script deverá ser executado para cada instância a ser migrada para a Totvs
-- Este script é de propriedade da Totvs

--------------------------------------------------
-- Inicialização
--------------------------------------------------
set nocount on
set xact_abort on
set arithabort off
set ansi_warnings off
set transaction isolation level read uncommitted
go

--------------------------------------------------
-- Procedures
--------------------------------------------------
use tempdb
go
if object_id('dbo.usp_resultset_html') is not null drop procedure dbo.usp_resultset_html
go
create procedure dbo.usp_resultset_html (@consulta nvarchar(max), @titulo_tabela nvarchar(300) = '', @css nvarchar(max) = 'default', @html varchar(max) = '' output, @output_result bit = 0)
as begin 
	begin transaction
	set nocount on
	set xact_abort on
	declare @colunas varchar(max)
	declare @html_final nvarchar(max)
	declare @html_parcial nvarchar(max)
	declare @sql nvarchar(max)
	
	-- Define nome da tabela temporária com newid para permitir execução simultanea por diversos terminais
	declare @table_name varchar(50)
	set @table_name = 'tb' + convert(varchar, abs(checksum(newid())))

	-- Altera query original para salvar o resultado da query na tabela temporária
	-- Ex: DE: "select * from produtos" PARA: "select * into tb123456 from produtos"
	if charindex('from', lower(@consulta)) = 0
		begin
			-- selects sem "from tabela", exemplo: select 1, 2
			set @consulta = @consulta + ' into ' + @table_name
		end
	else
		begin
			-- Selects normais, com tabelas
			set @consulta = replace(lower(@consulta), 'from', ' into ' + @table_name + ' from ')
		end
	execute (@consulta)

	-- Obtem colunas do select original e converte para TDs
	set @colunas = stuff((select ', [' + COLUMN_NAME + '] as td' from tempdb.[INFORMATION_SCHEMA].[COLUMNS] where TABLE_NAME = @table_name for xml path('')), 1, 1, '')

	-- Cria html a partir da tabela temporária salva
	set @html_final = '<table class="sql_tabela">'
	if @titulo_tabela <> '' set @html_final = @html_final + '<caption>' + @titulo_tabela + '</caption>'
	set @html_final = @html_final + '<thead><tr>'
	set @sql = 'set @html_parcial= (select column_name as th from [INFORMATION_SCHEMA].[COLUMNS] where table_name = ''' + @table_name + ''' ORDER BY ORDINAL_POSITION for xml path(''''))'
	execute sp_executesql @sql, N'@html_parcial varchar(max) out', @html_parcial out
	set @html_final = @html_final + @html_parcial
	set @html_final = @html_final + '</tr></thead>'
	set @html_final = @html_final + '<tbody>'
	set @sql = 'set @html_parcial= (select ' + @colunas + ' from ' + @table_name + ' for xml raw(''tr''), elements xsinil)'
	execute sp_executesql @sql, N'@html_parcial nvarchar(max) out', @html_parcial out
	if @html_parcial is not null set @html_final = @html_final + @html_parcial -- Caso o resultset retorne não-vazio
	set @html_final = @html_final + '</tbody></table>'

	-- Adiciona CSS:
	if @css is null set @css = ''
	if @css = 'default'
		begin
			set @css = '
				<style>
					.sql_tabela {
						border-spacing: 0px;
						border-collapse: collapse;
					}
					.sql_tabela caption {
						padding: 5px;
						border: 1px solid #CCC;
						text-align: center;
					}
					.sql_tabela thead {
						background: #fafafb;
					}
					.sql_tabela th {
						padding: 1px 10px 1px 5px;
						border: 1px solid #CCC;
						font-weight: normal;    
						text-align: left;
						word-wrap: break-word;
						max-width: 200px;
					}
					.sql_tabela body {
					}
					.sql_tabela td {
						padding: 1px 10px 1px 5px;
						border: 1px solid #CCC;
						word-wrap: break-word;
						max-width: 200px;
					}
				</style>'
				-- Substituir campos nulos por texto NULL
				set @html_final = replace(@html_final, '<td xsi:nil="true"/>', '<td style="background-color: #FFFFE1;">NULL</td>')
				set @html_final = replace(@html_final, '<td xsi:nil="true" />', '<td style="background-color: #FFFFE1;">NULL</td>')
			end
	if @css = 'default_inline'
		begin
			set @css = ''
			set @html_final = replace(@html_final, '<table class="sql_tabela">', '<table style="border-spacing: 0px;border-collapse: collapse;">')
			set @html_final = replace(@html_final, '<caption>', '<caption style="padding: 5px; border: 1px solid #CCC; text-align: center;">')
			set @html_final = replace(@html_final, '<thead>', '<thead style="background: #fafafb;">')
			set @html_final = replace(@html_final, '<th>', '<th style="padding: 1px 10px 1px 5px; border: 1px solid #CCC; font-weight: normal; text-align: left; word-wrap: break-word; max-width: 200px;">')
			set @html_final = replace(@html_final, '<td>', '<td style="padding: 1px 10px 1px 5px; border: 1px solid #CCC; word-wrap: break-word; max-width: 200px;">')
			-- Substituir campos nulos por texto NULL
			set @html_final = replace(@html_final, '<td xsi:nil="true"/>', '<td style="padding: 1px 10px 1px 5px; border: 1px solid #CCC; word-wrap: break-word; max-width: 200px; background-color: #FFFFE1;">NULL</td>')
		end
	set @html_final = @css + @html_final
	
	-- Mostra HTML
	set @html = @html_final
	if @output_result = 1 select @html as html

	-- Exclui tabela temporária
	execute ('drop table ' + @table_name)
	rollback transaction
end
go

use tempdb
go
if object_id('dbo.usp_assessment_projetos_clientes') is not null drop procedure dbo.usp_assessment_projetos_clientes
go
create procedure dbo.usp_assessment_projetos_clientes 
as begin 
	declare @version varchar(4)
	set @version = substring(@@version, 22, 4)
	declare @version2 varchar(4)
	set @version2 = substring(@@version, 22, 4)
	if convert(int, @version) >= 2005
		begin
			declare @html_final varchar(max)
			declare @html_temp varchar(max)
			set @html_final = '
				<style>
					.sql_tabela {
						border-spacing: 0px;
						border-collapse: collapse;
						font-size: small;
					}
					.sql_tabela caption {
						padding: 5px;
						border: 1px solid #CCC;
						text-align: center;
					}
					.sql_tabela thead {
						background: #fafafb;
					}
					.sql_tabela th {
						padding: 1px 10px 1px 5px;
						border: 1px solid #CCC;
						font-weight: normal;    
						text-align: left;
						word-wrap: break-word;
						max-width: 200px;
						background-color: beige;
					}
					.sql_tabela body {
					}
					.sql_tabela td {
						padding: 1px 10px 1px 5px;
						border: 1px solid #CCC;
						word-wrap: break-word;
						max-width: 200px;
					}
				</style>'
			set @html_temp = ''

			-- Título do relatório:
			set @html_final = @html_final + '<h1>Relatório de Informações da Instância - Assesment</h1>'

			-- Informações Time Pré-Vendas:
			set @html_final = @html_final + '<h1>Informações Time Pré-Vendas</h1>'

			-- Propriedades:
			set @html_final = @html_final + '<h2>Propriedades</h2>'
			IF CONVERT(INT, @version) >= 2017
				execute tempdb.dbo.usp_resultset_html 
					@consulta = '
						SELECT 
	  SERVERPROPERTY(''ComputerNamePhysicalNetBIOS'') AS [Current Node Name],
      CASE SERVERPROPERTY(''IsClustered'') 
      WHEN 0 THEN ''False''
      WHEN 1 THEN ''True''
    END AS [Is Clustered?], 
    [cpu_count] AS [CPUs],
	[socket_count], --SQL Server 2016 (13.x) SP2 e posterior.
	[cores_per_socket], --SQL Server 2016 (13.x) SP2 e posterior
    [physical_memory_kb]/1024 AS [RAM (MB)], --SQL Server 2012 (11.x) e posteriores
	[virtual_machine_type_desc] -- SQL Server 2008 R2 e posteriores
	  FROM  
    [sys].[dm_os_sys_info]', 
					@css = '', @html = @html_temp out
			ELSE
			IF CONVERT(INT, @version) >= 2016
				execute tempdb.dbo.usp_resultset_html 
					@consulta = '
						SELECT 
	  SERVERPROPERTY(''ComputerNamePhysicalNetBIOS'') AS [Current Node Name],
      CASE SERVERPROPERTY(''IsClustered'') 
      WHEN 0 THEN ''False''
      WHEN 1 THEN ''True''
    END AS [Is Clustered?], 
    [cpu_count] AS [CPUs],
	--[socket_count], --SQL Server 2016 (13.x) SP2 e posterior.
	--[cores_per_socket], --SQL Server 2016 (13.x) SP2 e posterior
    [physical_memory_kb]/1024 AS [RAM (MB)], --SQL Server 2012 (11.x) e posteriores
	[virtual_machine_type_desc] -- SQL Server 2008 R2 e posteriores
	  FROM  
    [sys].[dm_os_sys_info]', 
					@css = '', @html = @html_temp out
			ELSE 
				IF CONVERT(SMALLINT, @version) >= 2012
					execute tempdb.dbo.usp_resultset_html 
						@consulta = '
							SELECT 
	  SERVERPROPERTY(''ComputerNamePhysicalNetBIOS'') AS [Current Node Name],
      CASE SERVERPROPERTY(''IsClustered'') 
      WHEN 0 THEN ''False''
      WHEN 1 THEN ''True''
    END AS [Is Clustered?], 
    [cpu_count] AS [CPUs],
    [physical_memory_kb]/1024 AS [RAM_GB], --SQL Server 2012 (11.x) e posteriores
	[virtual_machine_type_desc] -- SQL Server 2008 R2 e posteriores
	FROM  
    [sys].[dm_os_sys_info]',
						@css = '', @html = @html_temp out
				ELSE
			IF CONVERT(SMALLINT, @version) >= 2008
					execute tempdb.dbo.usp_resultset_html 
						@consulta = '
							SELECT 
	  SERVERPROPERTY(''ComputerNamePhysicalNetBIOS'') AS [Current Node Name],
      CASE SERVERPROPERTY(''IsClustered'') 
      WHEN 0 THEN ''False''
      WHEN 1 THEN ''True''
    END AS [Is Clustered?], 
    [cpu_count] AS [CPUs]--,
    --[virtual_machine_type_desc] -- SQL Server 2008 R2 SP3 e posteriores
	FROM  
    [sys].[dm_os_sys_info]',
						@css = '', @html = @html_temp out
				ELSE
		IF CONVERT(SMALLINT, @version) >= 2005
					execute tempdb.dbo.usp_resultset_html 
						@consulta = '
							SELECT 
	  SERVERPROPERTY(''ComputerNamePhysicalNetBIOS'') AS [Current Node Name],
      CASE SERVERPROPERTY(''IsClustered'') 
      WHEN 0 THEN ''False''
      WHEN 1 THEN ''True''
    END AS [Is Clustered?], 
    [cpu_count] AS [CPUs]
    --[physical_memory_kb]/1024 AS [RAM_GB],
	--[virtual_machine_type_desc]
	FROM  
    [sys].[dm_os_sys_info]',
						@css = '', @html = @html_temp out
				ELSE
					execute tempdb.dbo.usp_resultset_html 
						@consulta = 'SELECT ''This SQL Server instance is running SQL Server 2005 or lower! You will need alternative methods in getting the SQL instance level information.'' as erro_os_sys_info',
						@css = '', @html = @html_temp out

			set @html_final = @html_final + @html_temp + '<p></p>' -- '<p></p>' = espaço entre os dois resultsets

			execute tempdb.dbo.usp_resultset_html 
						@consulta = '
							SELECT 
							SERVERPROPERTY(''servername'') AS [Instance Name],
							c.VALUE AS [Memória Instancia],
							CASE SERVERPROPERTY(''IsIntegratedSecurityOnly'') WHEN 0 THEN ''SQL Server and Windows Authentication mode'' WHEN 1 THEN ''Windows Authentication mode'' END AS [Server Authentication],
							SERVERPROPERTY(''Collation'') AS [ SQL Collation]
							FROM  
							[sys].[dm_os_sys_info] i, sys.configurations c 
							WHERE c.[configuration_id] = 1544',
						@css = '', @html = @html_temp out
			set @html_final = @html_final + @html_temp

			--set @html_final = @html_final + @html_temp + '<p></p>' -- '<p></p>' = espaço entre os dois resultsets

			-- Informações AlwaysOn:
			set @html_final = @html_final + '<h2>AlwaysOn</h2>'

			IF CONVERT(INT, @version) >= 2012
			execute tempdb.dbo.usp_resultset_html @consulta = 'declare @IsHadrEnabled as sql_variant  
																set @IsHadrEnabled = (select SERVERPROPERTY(''IsHadrEnabled''))  
																select @IsHadrEnabled as IsHadrEnabled,  
																case @IsHadrEnabled  
																when 0 then ''The Always On availability groups is disabled''  
																when 1 then ''The Always On availability groups is enabled''  
																else ''Invalid Input''  
																end as ''Hadr''', @css = '', @html = @html_temp out
			ELSE
					execute tempdb.dbo.usp_resultset_html 
						@consulta = 'SELECT ''This SQL Server instance is running SQL Server 2008 or lower! AG is available starting with SQL Server 2012.'' as erro_os_sys_info',
						@css = '', @html = @html_temp out

			set @html_final = @html_final + @html_temp  + '<p></p>'

			IF CONVERT(INT, @version) >= 2016

			execute tempdb.dbo.usp_resultset_html @consulta = 'SELECT
    ag.name AS "GroupName" 
   ,cs.replica_server_name AS "Replica"
   ,rs.role_desc AS "Role"
   ,REPLACE(ar.availability_mode_desc,''_'','' '') AS "AvailabilityMode"
   ,ar.failover_mode_desc AS "FailoverMode"
   ,ar.primary_role_allow_connections_desc AS "ConnPrimaryRole"
   ,ar.secondary_role_allow_connections_desc AS "ConnSecondaryRole"
   --,ar.seeding_mode_desc AS "SeedingMode"
   ,ar.endpoint_url AS "EndpointURL"
   ,al.dns_name AS "Listener"
FROM sys.availability_groups ag
JOIN sys.dm_hadr_availability_group_states ags ON ag.group_id = ags.group_id
JOIN sys.dm_hadr_availability_replica_cluster_states cs ON ags.group_id = cs.group_id 
JOIN sys.availability_replicas ar ON ar.replica_id = cs.replica_id 
JOIN sys.dm_hadr_availability_replica_states rs  ON rs.replica_id = cs.replica_id 
LEFT JOIN sys.availability_group_listeners al ON ar.group_id = al.group_id', @css = '', @html = @html_temp out
			--set @html_final = @html_final + @html_temp

			ELSE 
			IF CONVERT(INT, @version) >= 2012

				execute tempdb.dbo.usp_resultset_html @consulta = 'SELECT
    ag.name AS "GroupName" 
   ,cs.replica_server_name AS "Replica"
   ,rs.role_desc AS "Role"
   ,REPLACE(ar.availability_mode_desc,''_'','' '') AS "AvailabilityMode"
   ,ar.failover_mode_desc AS "FailoverMode"
   ,ar.primary_role_allow_connections_desc AS "ConnPrimaryRole"
   ,ar.secondary_role_allow_connections_desc AS "ConnSecondaryRole"
   --,ar.seeding_mode_desc AS "SeedingMode"
   ,ar.endpoint_url AS "EndpointURL"
   ,al.dns_name AS "Listener"
FROM sys.availability_groups ag
JOIN sys.dm_hadr_availability_group_states ags ON ag.group_id = ags.group_id
JOIN sys.dm_hadr_availability_replica_cluster_states cs ON ags.group_id = cs.group_id 
JOIN sys.availability_replicas ar ON ar.replica_id = cs.replica_id 
JOIN sys.dm_hadr_availability_replica_states rs  ON rs.replica_id = cs.replica_id 
LEFT JOIN sys.availability_group_listeners al ON ar.group_id = al.group_id', @css = '', @html = @html_temp out
			--set @html_final = @html_final + @html_temp

			ELSE 

			execute tempdb.dbo.usp_resultset_html 
						@consulta = 'SELECT ''This SQL Server instance is running SQL Server 2008 or lower! AG is available starting with SQL Server 2012.'' as erro_os_sys_info',
						@css = '', @html = @html_temp out

			set @html_final = @html_final + @html_temp + '<p></p>' -- '<p></p>' = espaço entre os dois resultsets
			
						
			/*Alterado aqui*/

			set @html_final = @html_final + '<h2>Informações Discos SO</h2>'

				IF CONVERT(INT, @version2) > 2014
				execute tempdb.dbo.usp_resultset_html 
					@consulta = '
						SELECT DISTINCT
    VS.volume_mount_point [Montagem] ,
    VS.logical_volume_name AS [Volume] ,
    CAST(CAST(VS.total_bytes AS DECIMAL(19, 2)) / 1024 / 1024 / 1024 AS DECIMAL(10, 2)) AS [Total_GB] ,
    CAST(CAST(VS.available_bytes AS DECIMAL(19, 2)) / 1024 / 1024 / 1024 AS DECIMAL(10, 2)) AS [Espaço_Disponível_GB] ,
    CAST(( CAST(VS.available_bytes AS DECIMAL(19, 2)) / CAST(VS.total_bytes AS DECIMAL(19, 2)) * 100 ) AS DECIMAL(10, 2)) AS [%Espaço_Disponível] ,
    CAST(( 100 - CAST(VS.available_bytes AS DECIMAL(19, 2)) / CAST(VS.total_bytes AS DECIMAL(19, 2)) * 100 ) AS DECIMAL(10, 2)) AS [%Espaço_em_uso]
FROM
    sys.master_files AS MF
    CROSS APPLY [sys].[dm_os_volume_stats](MF.database_id, MF.file_id) AS VS
WHERE
    CAST(VS.available_bytes AS DECIMAL(19, 2)) / CAST(VS.total_bytes AS DECIMAL(19, 2)) * 100 < 100', 
					@css = '', @html = @html_temp out
			ELSE 
				IF CONVERT(SMALLINT, @version2) >= 2012
					execute tempdb.dbo.usp_resultset_html 
						@consulta = '
							SELECT DISTINCT
    VS.volume_mount_point [Montagem] ,
    VS.logical_volume_name AS [Volume] ,
    CAST(CAST(VS.total_bytes AS DECIMAL(19, 2)) / 1024 / 1024 / 1024 AS DECIMAL(10, 2)) AS [Total_GB] ,
    CAST(CAST(VS.available_bytes AS DECIMAL(19, 2)) / 1024 / 1024 / 1024 AS DECIMAL(10, 2)) AS [Espaço_Disponível_GB] ,
    CAST(( CAST(VS.available_bytes AS DECIMAL(19, 2)) / CAST(VS.total_bytes AS DECIMAL(19, 2)) * 100 ) AS DECIMAL(10, 2)) AS [%Espaço_Disponível] ,
    CAST(( 100 - CAST(VS.available_bytes AS DECIMAL(19, 2)) / CAST(VS.total_bytes AS DECIMAL(19, 2)) * 100 ) AS DECIMAL(10, 2)) AS [%Espaço_em_uso]
FROM
    sys.master_files AS MF
    CROSS APPLY [sys].[dm_os_volume_stats](MF.database_id, MF.file_id) AS VS
WHERE
    CAST(VS.available_bytes AS DECIMAL(19, 2)) / CAST(VS.total_bytes AS DECIMAL(19, 2)) * 100 < 100',
						@css = '', @html = @html_temp out
				ELSE
					execute tempdb.dbo.usp_resultset_html 
						@consulta = 'SELECT ''This SQL Server instance is running SQL Server 2008 or lower! You will need alternative methods in getting the SQL disks information.'' as erro_os_sys_info',
						@css = '', @html = @html_temp out

						/*Fim alterado aqui*/					

			set @html_final = @html_final + @html_temp + '<p></p>' -- '<p></p>' = espaço entre os dois resultsets

			

			
			-- Versão DB/SO:
			set @html_final = @html_final + '<h2>Versão do DB/SO</h2>'
			execute tempdb.dbo.usp_resultset_html @consulta = 'SELECT @@version AS "Versão DB/SO"', @css = '', @html = @html_temp out
			set @html_final = @html_final + @html_temp
					   			

			--Informações collation colunas
			set @html_final = @html_final + '<h2>Informações Collation Colunas</h2>'
			DECLARE @command_collation varchar(max) 
			SELECT @command_collation = 'USE [?]; IF DB_ID(''?'') > 4
				BEGIN
				SELECT DB_NAME() AS banco_de_dados,count(collation_name ) AS quantidade_colunas, collation_name 
				FROM sys.columns c 
				inner join sys.tables t on c.object_id = t.object_id
				where collation_name IS NOT NULL
				group by collation_name 
				END' 
			if object_id('tempdb.dbo.##tabela_collation') is not null drop table ##tabela_collation
			CREATE TABLE ##tabela_collation (banco_de_dados sysname, quantidade_colunas bigint, collation_name sysname)
			INSERT INTO ##tabela_collation EXEC sp_MSforeachdb @command_collation
			
			execute tempdb.dbo.usp_resultset_html 
				@consulta = 'SELECT * FROM ##tabela_collation', 
				@css = '', @html = @html_temp out
			set @html_final = @html_final + @html_temp + '<p></p>'

								
			-- Informações database
			set @html_final = @html_final + '<h2>Informações Database</h2>'
			execute tempdb.dbo.usp_resultset_html 
				@consulta = '
					SELECT 
						db.name as "Database Name", db.recovery_model_desc , db.is_read_only, SUM((size * 8)/1024) AS "Tamanho MB", 
						db.collation_name, db.[compatibility_level], db.is_auto_update_stats_on, db.is_read_committed_snapshot_on, db.is_auto_create_stats_on, db.is_parameterization_forced
					FROM sys.databases db
					INNER JOIN sys.master_files
					ON db.database_id = sys.master_files.database_id
					GROUP BY db.name, db.collation_name, db.[compatibility_level], db.recovery_model_desc , db.is_read_only, db.is_auto_update_stats_on, db.is_read_committed_snapshot_on, db.is_auto_create_stats_on, db.is_parameterization_forced', 
				@css = '', @html = @html_temp out
			set @html_final = @html_final + @html_temp + '<p></p>'

			-- Tamanho Total Bancos de Dados
			set @html_final = @html_final + '<h2>Tamanho Todos Bancos de Dados - GB</h2>'
			execute tempdb.dbo.usp_resultset_html @consulta = 'SELECT CONVERT(DECIMAL(10,2),(SUM(size * 8.00) / 1024.00 / 1024.00)) As "Tamanho Todos Bancos de Dados - GB" FROM master.sys.master_files WHERE database_id > 4', 
			@css = '', @html = @html_temp out
			set @html_final = @html_final + @html_temp

			-- Informações datafile
			set @html_final = @html_final + '<h2>Informações Datafiles</h2>'
			execute tempdb.dbo.usp_resultset_html 
				@consulta = '
					SELECT 
						db.[name], mf.physical_name, mf.state_desc, mf.type_desc, (mf.size *8)/1024 "Size MB", 
						CONVERT(DECIMAL(10,2), ROUND((CAST(FILEPROPERTY(mf.name, ''SpaceUsed'') AS INT)/128),0,0)) "Used Size",
						CONVERT(DECIMAL(10,2), ROUND((mf.size/128 - CAST(FILEPROPERTY(mf.name, ''SpaceUsed'') AS INT)/128),0,0)) AS FreeSpaceMB,
						(mf.growth *8)/1024 "Crescimento MB", 
						mf.is_percent_growth, 
						case when mf.is_percent_growth = 1 then mf.growth else ''0'' END AS ''% Crescimento'', 
						mf.max_size 
					FROM sys.databases AS db
					INNER JOIN sys.master_files as mf on db.database_id = mf.database_id
					order by db.name, mf.physical_name', 
				@css = '', @html = @html_temp out
			set @html_final = @html_final + @html_temp

			-- INFORMAÇÕES DE FEATURES
			-- ChangeCapture - Habilitada para BD - Armazena inf. UP, DEL, INSERT
			-- ColumnStoreIndex - Tabela tem índice ColumnStore
			-- Compression - Tabela esta comprimida
			-- Partition - Nivel Tabela
			-- TransparentDataEncryption - Nivel de Banco de dados
			-- feature_id = id da feauture - não garantido compatibilidade dos ids entre versões
			IF OBJECT_ID('tempdb.dbo.##enterprise_features') IS NOT NULL DROP TABLE ##enterprise_features
			if object_id('tempdb.dbo.##compression') is not null drop table ##compression
			CREATE TABLE ##enterprise_features (dbname SYSNAME, feature_name VARCHAR(100), feature_id INT)		
			create table ##compression (dbname sysname, SchemaName sysname, TableName sysname, row_count bigint, TableSize_MB varchar(100), Used_Space_MB varchar(100), data_compression_desc sysname, CompressionObject sysname)
			EXEC msdb..sp_MSforeachdb
				N' USE [?] 
				IF (SELECT COUNT(*) FROM sys.dm_db_persisted_sku_features) > 0 
					BEGIN 
						INSERT INTO ##enterprise_features 
						SELECT dbname=DB_NAME(),feature_name,feature_id FROM sys.dm_db_persisted_sku_features
					END
				IF (SELECT COUNT(*) FROM sys.dm_db_persisted_sku_features) =0
				BEGIN
					insert into ##compression
  						select distinct DB_NAME() DBName, sc.name SchemaName, st.name TableName, pst.row_count,
						sum(sau.total_pages)/128 TableSize_MB, sum(sau.used_pages)/128 Used_Space_MB,
						sp.data_compression_desc, 
						case when sp.index_id in (0, 1) then ''Table'' else ''Index'' end CompressionObject
						from sys.partitions sp
						inner join sys.allocation_units sau on sau.container_id = sp.partition_id
						inner join sys.tables st on st.object_id = sp.object_id
						inner join sys.schemas sc on sc.schema_id = st.schema_id
						inner join sys.dm_db_partition_stats pst on pst.object_id =  sp.object_id
						where sp.data_compression_desc <> ''NONE'' COLLATE Latin1_General_CI_AI
						group by sc.name, st.name, sp.data_compression_desc, sp.index_id,pst.row_count
				 END'

			set @html_final = @html_final + '<h2>Informações de Features</h2>'
			execute tempdb.dbo.usp_resultset_html @consulta = 'select * from ##enterprise_features', @css = '', @html = @html_temp out
			if object_id('tempdb.dbo.##enterprise_features') is not null drop table ##enterprise_features
			set @html_final = @html_final + @html_temp + '<p></p>' -- espaço entre os dois resultsets
			set @html_final = @html_final + '<h2>Informações Tabelas Compactadas</h2>'
			execute tempdb.dbo.usp_resultset_html @consulta = 'select * from ##compression', @css = '', @html = @html_temp out
			if object_id('tempdb.dbo.##compression') is not null drop table ##compression
			set @html_final = @html_final + @html_temp

			-- CONSULTA LINKED SERVER
			if object_id('tempdb.dbo.##sp_linkedservers') is not null drop table ##sp_linkedservers
			create table ##sp_linkedservers (SRV_NAME sysname, SRV_PROVIDERNAME sysname, SRV_PRODUCT SYSNAME, SRV_DATASOURCE SYSNAME, SRV_PROVIDERSTRING VARCHAR(1000), SRV_LOCATION VARCHAR(1000), SRV_CAT VARCHAR(1000))
			insert into ##sp_linkedservers execute sys.sp_linkedservers
			set @html_final = @html_final + '<h2>Consulta Linked Server</h2>'
			execute tempdb.dbo.usp_resultset_html @consulta = 'select * from ##sp_linkedservers', @css = '', @html = @html_temp out
			if object_id('tempdb.dbo.##sp_linkedservers') is not null drop table ##sp_linkedservers
			set @html_final = @html_final + @html_temp


			-- CONSULTA LINKED SERVER ATIVO
			if object_id('tempdb.dbo.##sp_testlinkedserver') is not null drop table ##sp_testlinkedserver
			create table ##sp_testlinkedserver (IsOff int, servername varchar(100), TheError varchar(8000))
			DECLARE @name NVARCHAR(100)
			DECLARE getid CURSOR FOR SELECT name FROM sys.servers where is_linked = 1
			OPEN getid
			FETCH NEXT FROM getid INTO @name
			WHILE @@FETCH_STATUS = 0
				BEGIN
					begin try
						exec sys.sp_testlinkedserver @name
						insert into ##sp_testlinkedserver values (1, @name, 'Server is Connected')
					end try
					begin catch
						insert into ##sp_testlinkedserver values (0, @name, ERROR_MESSAGE())
					end catch
					FETCH NEXT FROM getid INTO @name
				END
			CLOSE getid
			DEALLOCATE getid
			set @html_final = @html_final + '<h2>Consulta Linked Server Ativo</h2>'
			execute tempdb.dbo.usp_resultset_html @consulta = 'select * from ##sp_testlinkedserver order by servername', @css = '', @html = @html_temp out
			if object_id('tempdb.dbo.##sp_testlinkedserver') is not null drop table ##sp_testlinkedserver
			set @html_final = @html_final + @html_temp

			-- Informações Time SQUAD Cloud DBA:
			set @html_final = @html_final + '<h1>Informações Time SQUAD Cloud DBA</h1>'

			-- Backup FULL/DIFERENCIAL
			set @html_final = @html_final + '<h2>Backup Full/Diferencial</h2>'
			execute tempdb.dbo.usp_resultset_html 
				@consulta = '
					SELECT sdb.name AS DBNAME,
						CASE 
							WHEN bs.type = ''D''
								THEN ''FULL''
							WHEN bs.type = ''I''
								THEN ''DIFF''
							END AS TIPO,
						bs.backup_start_date AS DATA_INICIO, bs.backup_finish_date AS DATA_FIM, 
						CONVERT(VARCHAR(8), Convert(TIME, Convert(DATETIME, Datediff(ms, backup_start_date, bs.backup_finish_date) / 86400000.0))) [DURACAO],
						cast((bs.backup_size/1024/1024) as int) [TAMANHO BKP MB],
						cast((bs.compressed_backup_size/1024/1024) as int) [TAM BKP MB COMPRIMIDO]
					FROM master.sys.databases sdb
					LEFT OUTER JOIN msdb.dbo.backupset bs ON bs.database_name = sdb.name
					WHERE
					dateadd(DD,0,(CAST(bs.backup_start_date as date))) >= dateadd(DD,-6,(CAST(getdate() as date)))
					AND (bs.type = ''D'' COLLATE Latin1_General_CI_AI OR bs.type = ''I'' COLLATE Latin1_General_CI_AI) 
					--AND replica_id IS NULL
					ORDER BY sdb.name, bs.backup_start_date desc ', 
				@css = '', @html = @html_temp out
			set @html_final = @html_final + @html_temp


			-- Backup LOG
			set @html_final = @html_final + '<h2>Backup Log</h2>'
			execute tempdb.dbo.usp_resultset_html 
				@consulta = '
					SELECT sdb.name AS DBNAME,
						CASE 
							WHEN bs.type = ''L''
								THEN ''LOG''
							END AS TIPO,
						bs.backup_start_date AS DATA_INICIO, bs.backup_finish_date AS DATA_FIM, 
						CONVERT(VARCHAR(8), Convert(TIME, Convert(DATETIME, Datediff(ms, backup_start_date, bs.backup_finish_date) / 86400000.0))) [DURACAO],
						cast((bs.backup_size/1024/1024) as int) [TAMANHO BKP MB],
						cast((bs.compressed_backup_size/1024/1024) as int) [TAM BKP MB COMPRIMIDO]
					FROM master.sys.databases sdb
					LEFT OUTER JOIN msdb.dbo.backupset bs ON bs.database_name = sdb.name
					WHERE
					dateadd(DD,0,(CAST(bs.backup_start_date as date))) >= dateadd(DD,-1,(CAST(getdate() as date)))
					AND bs.type = ''L'' COLLATE Latin1_General_CI_AI
					--AND replica_id IS NULL
					ORDER BY sdb.name, bs.backup_start_date desc ', 
				@css = '', @html = @html_temp out
			set @html_final = @html_final + @html_temp


			-- HISTORICO MENSAL BACKUP ULTIMOS 360 DIAS
			set @html_final = @html_final + '<h2>Histórico Mensal Backup Últimos 360 Dias</h2>'
			execute tempdb.dbo.usp_resultset_html 
				@consulta = '
					SELECT 
						database_name "Database Name", 
						convert(varchar(4), (datepart(YYYY, max(backup_start_date)))) + right(''0'' + convert(varchar(2), datepart(MM, max(backup_start_date))), 2) as "Ano Mes",
						--max(backup_size / 1024000000) AS Size,
						max(cast((backup_size/1024/1024) as int)) AS "Size MB"
					FROM msdb..backupset
					WHERE type = ''D'' COLLATE Latin1_General_CI_AI
					AND backup_start_date>= GETDATE()-360
					group by database_name
					ORDER BY 1, 2 desc', 
				@css = '', @html = @html_temp out
			set @html_final = @html_final + @html_temp


			-- INFORMAÇÕES DE LOGINS
			set @html_final = @html_final + '<h2>Informações de Logins</h2>'
			execute tempdb.dbo.usp_resultset_html 
				@consulta = '
					SELECT
						CASE WHEN SSPs2.name IS NULL THEN ''Public'' ELSE SSPs2.name END AS ''Role Name'',
						SSPs.name AS ''Login Name'',
						Case SSPs.is_disabled When 0 Then ''0 – Habilitado'' When 1 Then ''1 – Desabilitado'' End AS ''Login Status'',
						SSPs.type_desc AS ''Login Type''
					FROM sys.server_principals SSPs 
					LEFT JOIN sys.server_role_members SSRM ON SSPs.principal_id  = SSRM.member_principal_id
					LEFT JOIN sys.server_principals SSPs2 ON SSRM.role_principal_id = SSPs2.principal_id
					WHERE 
						SSPs2.name IS NOT NULL 
						OR SSPs.type_desc <> ''CERTIFICATE_MAPPED_LOGIN'' COLLATE Latin1_General_CI_AI
						AND SSPs.type_desc <> ''SERVER_ROLE'' COLLATE Latin1_General_CI_AI
						AND SSPs2.name IS NULL
					ORDER BY SSPs2.name DESC, SSPs.name', 
				@css = '', @html = @html_temp out
			set @html_final = @html_final + @html_temp
					   

			-- INFORMAÇÕES ESTATISTICAS DAS TABELAS
			IF OBJECT_ID('tempdb..#Temp') IS NOT NULL DROP TABLE #Temp
			if object_id('tempdb.dbo.##informacoes_estatisticas_tabelas') is not null drop table ##informacoes_estatisticas_tabelas
			CREATE TABLE #Temp (TableName NVARCHAR(255), UserSeeks DEC, UserScans DEC, UserUpdates DEC)
			INSERT INTO #Temp
				EXEC sys.sp_MSforeachdb 'USE [?]; IF DB_ID(''?'') > 4
				BEGIN
				SELECT DB_NAME() + ''.'' + object_name(b.object_id), a.user_seeks, a.user_scans, a.user_updates 
				FROM sys.dm_db_index_usage_stats a
				RIGHT OUTER JOIN [?].sys.indexes b on a.object_id = b.object_id and a.database_id = DB_ID()
				WHERE b.object_id > 100 
				END'
				SELECT TOP 20 TableName as 'Table_Name', sum(UserSeeks + UserScans + UserUpdates) as 'Total_Accesses',
				sum(UserUpdates) as 'Total_Writes', 
				CONVERT(DEC(25,2),(sum(UserUpdates)/sum(UserSeeks + UserScans + UserUpdates)*100)) as '%Accesses_Writes',
				sum(UserSeeks + UserScans) as 'Total_Reads', 
				CONVERT(DEC(25,2),(sum(UserSeeks + UserScans)/sum(UserSeeks + UserScans + UserUpdates)*100)) as '%Accesses_Reads',
				SUM(UserSeeks) as 'Read Seeks', CONVERT(DEC(25,2),(SUM(UserSeeks)/sum(UserSeeks + UserScans)*100)) as '%Reads_Index_Seeks', 
				SUM(UserScans) as 'Read Scans', CONVERT(DEC(25,2),(SUM(UserScans)/sum(UserSeeks + UserScans)*100)) as '%Reads_Index_Scans'
				into ##informacoes_estatisticas_tabelas
				FROM #Temp
				GROUP by TableName
				ORDER by sum(UserSeeks + UserScans + UserUpdates) DESC, TableName
				
			IF OBJECT_ID('tempdb..#Temp') IS NOT NULL DROP TABLE #Temp

			set @html_final = @html_final + '<h2>Informações Estatísticas das Tabelas</h2>'
			execute tempdb.dbo.usp_resultset_html @consulta = 'select * from ##informacoes_estatisticas_tabelas', @css = '', @html = @html_temp out
			if object_id('tempdb.dbo.##informacoes_estatisticas_tabelas') is not null drop table ##informacoes_estatisticas_tabelas
			set @html_final = @html_final + @html_temp

		
			--INFORMAÇÕES DE TAMANHO TABELAS TOP 20
			if object_id('tempdb.dbo.##tabelas_20k_rows') is not null drop table ##tabelas_20k_rows
			create table ##tabelas_20k_rows (db_name sysname, SchemaName sysname, TableName sysname, rows bigint, TotalSpaceMB decimal(20,2), UnusedSpaceMB decimal(20,2))
			declare @command varchar(1000)
			SELECT @command = 'IF ''?'' NOT IN(''master'', ''model'', ''msdb'', ''tempdb'') BEGIN USE [?]; SELECT TOP 20 "?" [db_name],
			s.name AS SchemaName, t.name AS TableName,  p.rows As Rows,
			CAST(ROUND(((SUM(a.total_pages) * 8) / 1024.00), 2) AS NUMERIC(36, 2)) AS TotalSpaceMB,
			CAST(ROUND(((SUM(a.total_pages) - SUM(a.used_pages)) * 8) / 1024.00, 2) AS NUMERIC(36, 2)) AS UnusedSpaceMB
			FROM 
			sys.tables t
			INNER JOIN 
			sys.partitions p ON t.object_id = p.object_id 
			INNER JOIN 
			sys.allocation_units a ON p.partition_id = a.container_id
			LEFT OUTER JOIN 
			sys.schemas s ON t.schema_id = s.schema_id
			GROUP BY t.name, s.name, p.rows
			ORDER BY 5 DESC, t.name END'
			insert into ##tabelas_20k_rows EXECUTE sp_MSforeachdb @command

			set @html_final = @html_final + '<h2>Informações de Tamanho Tabelas Top 20</h2>'
			execute tempdb.dbo.usp_resultset_html @consulta = 'select TOP 20 * from ##tabelas_20k_rows', @css = '', @html = @html_temp out
			if object_id('tempdb.dbo.##tabelas_20k_rows') is not null drop table ##tabelas_20k_rows
			set @html_final = @html_final + @html_temp
		
		
			-- INFORMAÇÕES CONEXÕES SIMULTANEAS
			set @html_final = @html_final + '<h2>Informações Conexões Simultâneas</h2>'
			execute tempdb.dbo.usp_resultset_html 
				@consulta = '
					SELECT
						DB_NAME(dbid) as BancoDeDados, 
						COUNT(dbid) as QtdeConexoes,
						loginame as Login
					FROM
						sys.sysprocesses
					WHERE
						dbid > 0
					GROUP BY
						dbid, loginame
					', 
				@css = '', @html = @html_temp out
			set @html_final = @html_final + @html_temp

			-- Configurações da instância
			set @html_final = @html_final + '<h2>Configurações da Instância</h2>'
			execute tempdb.dbo.usp_resultset_html @consulta = 'select * from sys.configurations order by name', @css = '', @html = @html_temp out
			set @html_final = @html_final + @html_temp

			-- Buffer Cache Hit Ratio
			set @html_final = @html_final + '<h2>Buffer Cache Hit Ration</h2>'
			execute tempdb.dbo.usp_resultset_html 
				@consulta = '
					SELECT
						  CASE WHEN t2.cntr_value = 0 
						  THEN 0
						  ELSE CONVERT(DECIMAL(38,2), CAST(t1.cntr_value AS FLOAT) / CAST(t2.cntr_value AS FLOAT) * 100.0)
						  END ''Buffer Cache Hit Ratio (%)''
					  FROM sys.dm_os_performance_counters t1,
						   sys.dm_os_performance_counters t2
					  WHERE
						  t1.object_name LIKE ''%Buffer Manager%'' COLLATE Latin1_General_CI_AI
					  AND t1.object_name = t2.object_name
					  AND t1.counter_name=''Buffer cache hit ratio'' COLLATE Latin1_General_CI_AI
					  AND t2.counter_name=''Buffer cache hit ratio base'' COLLATE Latin1_General_CI_AI
					', 
				@css = '', @html = @html_temp out
			set @html_final = @html_final + @html_temp


			-- Page Life Expectancy
			set @html_final = @html_final + '<h2>Page Life Expectancy</h2>'
			execute tempdb.dbo.usp_resultset_html 
				@consulta = '
					SELECT [object_name],
					[counter_name],
					[cntr_value]
					FROM sys.dm_os_performance_counters
					WHERE [object_name] LIKE ''%Manager%'' COLLATE Latin1_General_CI_AI
					AND [counter_name] = ''Page life expectancy'' COLLATE Latin1_General_CI_AI
					', 
				@css = '', @html = @html_temp out
			set @html_final = @html_final + @html_temp


			-- Batch resquest por segundo
			if object_id('tempdb.dbo.##batch_request_sec') is not null drop table ##batch_request_sec
			DECLARE @v1 BIGINT, @delay SMALLINT = 2, @time DATETIME;
			SELECT @time = DATEADD(SECOND, @delay, '00:01:00');
			SELECT @v1 = cntr_value FROM master.sys.dm_os_performance_counters WHERE counter_name = 'Batch Requests/sec' COLLATE Latin1_General_CI_AI;
			WAITFOR DELAY @time;
			SELECT (cntr_value - @v1)/@delay 'Batch Requests/sec' into ##batch_request_sec FROM master.sys.dm_os_performance_counters WHERE counter_name='Batch Requests/sec' COLLATE Latin1_General_CI_AI;

			set @html_final = @html_final + '<h2>Batch Resquest por Segundo</h2>'
			execute tempdb.dbo.usp_resultset_html 
				@consulta = 'select * from ##batch_request_sec', 
				@css = '', @html = @html_temp out
			set @html_final = @html_final + @html_temp

			-- Trace Flag
			set @html_final = @html_final + '<h2>Trace Flag</h2>'
			execute tempdb.dbo.usp_resultset_html @consulta = 'if object_id(''tempdb..#tracetemp'') is not null
			drop table #tracetemp
			create table #tracetemp (TraceFlag INT, Status INT, Global INT, Session INT)
			insert into #tracetemp exec (''DBCC TRACESTATUS (8048, 1222)'')
			SELECT * from #tracetemp', 
			@css = '', @html = @html_temp out
			set @html_final = @html_final + @html_temp

			-- Serviços
			set @html_final = @html_final + '<h2>Serviços</h2>'
			execute tempdb.dbo.usp_resultset_html 
				@consulta = '
					SELECT 
						servicename [Servico], 
						startup_type_desc [Tipo Exec], 
						status_desc [Status], 
						last_startup_time, 
						service_account, 
						[filename], 
						is_clustered 
						--, instant_file_initialization_enabled 
					FROM [sys].[dm_server_services]
					Order by [servicename] desc
					', 
				@css = '', @html = @html_temp out
			set @html_final = @html_final + @html_temp


			-- Operadores
			set @html_final = @html_final + '<h2>Operadores</h2>'
			execute tempdb.dbo.usp_resultset_html 
				@consulta = '
					SELECT [name], [enabled], [email_address] FROM [msdb].[dbo].[sysoperators]
					', 
				@css = '', @html = @html_temp out
			set @html_final = @html_final + @html_temp


			-- Email Profile
			set @html_final = @html_final + '<h2>Email Profile</h2>'
			execute tempdb.dbo.usp_resultset_html 
				@consulta = '
					SELECT p.profile_id,profile_name=p.name,a.account_id,account_name=a.name,c.sequence_number  
					FROM msdb.dbo.sysmail_profile p, msdb.dbo.sysmail_account a, msdb.dbo.sysmail_profileaccount c  
					WHERE p.profile_id=c.profile_id AND a.account_id=c.account_id  
					', 
				@css = '', @html = @html_temp out
			set @html_final = @html_final + @html_temp


			-- Auditoria
			set @html_final = @html_final + '<h2>Auditoria</h2>'
			execute tempdb.dbo.usp_resultset_html 
				@consulta = '
					SELECT	audit_id, 
							a.name as audit_name, 
							s.name as server_specification_name,
							d.audit_action_name,
							s.is_state_enabled,
							d.is_group,
							d.audit_action_id,	
							s.create_date,
							s.modify_date
					FROM sys.server_audits AS a JOIN sys.server_audit_specifications AS s
						ON a.audit_guid = s.audit_guid JOIN sys.server_audit_specification_details AS d
						ON s.server_specification_id = d.server_specification_id
					WHERE s.is_state_enabled = 1 
					', 
				@css = '', @html = @html_temp out
			set @html_final = @html_final + @html_temp


			-- DATABASE specifications
			set @html_final = @html_final + '<h2>Database Specifications</h2>'
			execute tempdb.dbo.usp_resultset_html 
				@consulta = '
					SELECT	a.audit_id,
							a.name as audit_name,
							s.name as database_specification_name,
							d.audit_action_name,
							s.is_state_enabled,
							d.is_group,
							s.create_date,
							s.modify_date,
							d.audited_result
					FROM sys.server_audits AS a JOIN sys.database_audit_specifications AS s
						ON a.audit_guid = s.audit_guid JOIN sys.database_audit_specification_details AS d
						ON s.database_specification_id = d.database_specification_id
					WHERE s.is_state_enabled = 1
					', 
				@css = '', @html = @html_temp out
			set @html_final = @html_final + @html_temp


			-- INFORMAÇÕES DOS JOBS
			set @html_final = @html_final + '<h2>Informações dos Jobs</h2>'
			execute tempdb.dbo.usp_resultset_html 
				@consulta = '
					SELECT
						[sJOB].[name] AS [JobName] ,
						CASE [sJOB].[enabled]
						  WHEN 1 THEN ''Yes''
						  WHEN 0 THEN ''No''
						END AS [IsEnabled] ,
						CASE
							WHEN [sSCH].[schedule_uid] IS NULL THEN ''No''
							ELSE ''Yes''
						  END AS [IsScheduled],
								CASE [sSCH].[freq_type]
							WHEN 1 THEN ''One Time''
							WHEN 4 THEN ''Daily''
							WHEN 8 THEN ''Weekly''
							WHEN 16 THEN ''Monthly''
							WHEN 32 THEN ''Monthly - Relative to Frequency Interval''
							WHEN 64 THEN ''Start automatically when SQL Server Agent starts''
							WHEN 128 THEN ''Start whenever the CPUs become idle''
					  END [Occurrence], 
					  CASE [sSCH].[freq_type]
							WHEN 4 THEN ''Occurs every '' + CAST([freq_interval] AS VARCHAR(3)) + '' day(s)''
							WHEN 8 THEN ''Occurs every '' + CAST([freq_recurrence_factor] AS VARCHAR(3)) + '' week(s) on ''
									+ CASE WHEN [sSCH].[freq_interval] & 1 = 1 THEN ''Sunday'' ELSE '''' END
									+ CASE WHEN [sSCH].[freq_interval] & 2 = 2 THEN '', Monday'' ELSE '''' END
									+ CASE WHEN [sSCH].[freq_interval] & 4 = 4 THEN '', Tuesday'' ELSE '''' END
									+ CASE WHEN [sSCH].[freq_interval] & 8 = 8 THEN '', Wednesday'' ELSE '''' END
									+ CASE WHEN [sSCH].[freq_interval] & 16 = 16 THEN '', Thursday'' ELSE '''' END
									+ CASE WHEN [sSCH].[freq_interval] & 32 = 32 THEN '', Friday'' ELSE '''' END
									+ CASE WHEN [sSCH].[freq_interval] & 64 = 64 THEN '', Saturday'' ELSE '''' END
							WHEN 16 THEN ''Occurs on Day '' + CAST([freq_interval] AS VARCHAR(3)) + '' of every '' + CAST([sSCH].[freq_recurrence_factor] AS VARCHAR(3)) + '' month(s)''
							WHEN 32 THEN ''Occurs on ''
									 + CASE [sSCH].[freq_relative_interval]
										WHEN 1 THEN ''First''
										WHEN 2 THEN ''Second''
										WHEN 4 THEN ''Third''
										WHEN 8 THEN ''Fourth''
										WHEN 16 THEN ''Last''
									   END
									 + '' '' 
									 + CASE [sSCH].[freq_interval]
										WHEN 1 THEN ''Sunday''
										WHEN 2 THEN ''Monday''
										WHEN 3 THEN ''Tuesday''
										WHEN 4 THEN ''Wednesday''
										WHEN 5 THEN ''Thursday''
										WHEN 6 THEN ''Friday''
										WHEN 7 THEN ''Saturday''
										WHEN 8 THEN ''Day''
										WHEN 9 THEN ''Weekday''
										WHEN 10 THEN ''Weekend day''
									   END
									 + '' of every '' + CAST([sSCH].[freq_recurrence_factor] AS VARCHAR(3)) + '' month(s)''
						END AS [Recurrence], 
					[sSCH].[name] AS [JobScheduleName],
						CASE [sSCH].[freq_subday_type]
							WHEN 1 THEN ''Occurs once at '' + STUFF(STUFF(RIGHT(''000000'' + CAST([sSCH].[active_start_time] AS VARCHAR(6)), 6), 3, 0, '':''), 6, 0, '':'')
							WHEN 2 THEN ''Occurs every '' + CAST([sSCH].[freq_subday_interval] AS VARCHAR(3)) + '' Second(s) between '' + STUFF(STUFF(RIGHT(''000000'' + CAST([sSCH].[active_start_time] AS VARCHAR(6)), 6), 3, 0, '':''), 6, 0, '':'')+ '' & '' + STUFF(STUFF(RIGHT(''000000'' + CAST([sSCH].[active_end_time] AS VARCHAR(6)), 6), 3, 0, '':''), 6, 0, '':'')
							WHEN 4 THEN ''Occurs every '' + CAST([sSCH].[freq_subday_interval] AS VARCHAR(3)) + '' Minute(s) between '' + STUFF(STUFF(RIGHT(''000000'' + CAST([sSCH].[active_start_time] AS VARCHAR(6)), 6), 3, 0, '':''), 6, 0, '':'')+ '' & '' + STUFF(STUFF(RIGHT(''000000'' + CAST([sSCH].[active_end_time] AS VARCHAR(6)), 6), 3, 0, '':''), 6, 0, '':'')
							WHEN 8 THEN ''Occurs every '' + CAST([sSCH].[freq_subday_interval] AS VARCHAR(3)) + '' Hour(s) between '' + STUFF(STUFF(RIGHT(''000000'' + CAST([sSCH].[active_start_time] AS VARCHAR(6)), 6), 3, 0, '':''), 6, 0, '':'')+ '' & '' + STUFF(STUFF(RIGHT(''000000'' + CAST([sSCH].[active_end_time] AS VARCHAR(6)), 6), 3, 0, '':''), 6, 0, '':'')
						END [Frequency], 
						CASE 
							WHEN [sSCH].[freq_type] = 64 THEN ''Start automatically when SQL Server Agent starts''
							WHEN [sSCH].[freq_type] = 128 THEN ''Start whenever the CPUs become idle''
							WHEN [sSCH].[freq_type] IN (4,8,16,32) THEN ''Recurring''
							WHEN [sSCH].[freq_type] = 1 THEN ''One Time''
						END [ScheduleType], 
						[sJSTP].[step_id] AS [StepNo] ,
						[sJSTP].[step_name] AS [StepName] ,
						[sDBP].[name] AS [JobOwner] ,
						CASE [sJSTP].[subsystem]
						  WHEN ''ActiveScripting'' THEN ''ActiveX Script''
						  WHEN ''CmdExec'' THEN ''Operating system (CmdExec)''
						  WHEN ''PowerShell'' THEN ''PowerShell''
						  WHEN ''Distribution'' THEN ''Replication Distributor''
						  WHEN ''Merge'' THEN ''Replication Merge''
						  WHEN ''QueueReader'' THEN ''Replication Queue Reader''
						  WHEN ''Snapshot'' THEN ''Replication Snapshot''
						  WHEN ''LogReader'' THEN ''Replication Transaction-Log Reader''
						  WHEN ''ANALYSISCOMMAND'' THEN ''SQL Server Analysis Services Command''
						  WHEN ''ANALYSISQUERY'' THEN ''SQL Server Analysis Services Query''
						  WHEN ''SSIS'' THEN ''SQL Server Integration Services Package''
						  WHEN ''TSQL'' THEN ''Transact-SQL script (T-SQL)''
						  ELSE sJSTP.subsystem
						END AS [StepType] ,
						[sPROX].[name] AS [RunAs] ,
						[sJSTP].[database_name] AS [Database] ,
						REPLACE(REPLACE(REPLACE([sJSTP].[command], CHAR(10) + CHAR(13), '' ''), CHAR(13), '' ''), CHAR(10), '' '') AS [ExecutableCommand] ,
						CASE [sJOB].[delete_level]
							WHEN 0 THEN ''Never''
							WHEN 1 THEN ''On Success''
							WHEN 2 THEN ''On Failure''
							WHEN 3 THEN ''On Completion''
						END AS [JobDeletionCriterion]
					FROM
						[msdb].[dbo].[sysjobsteps] AS [sJSTP]
						INNER JOIN [msdb].[dbo].[sysjobs] AS [sJOB] ON [sJSTP].[job_id] = [sJOB].[job_id]
						LEFT JOIN [msdb].[dbo].[sysjobsteps] AS [sOSSTP] ON [sJSTP].[job_id] = [sOSSTP].[job_id] AND [sJSTP].[on_success_step_id] = [sOSSTP].[step_id]
						LEFT JOIN [msdb].[dbo].[sysjobsteps] AS [sOFSTP] ON [sJSTP].[job_id] = [sOFSTP].[job_id] AND [sJSTP].[on_fail_step_id] = [sOFSTP].[step_id]
						LEFT JOIN [msdb].[dbo].[sysproxies] AS [sPROX] ON [sJSTP].[proxy_id] = [sPROX].[proxy_id]
						LEFT JOIN [msdb].[dbo].[syscategories] AS [sCAT] ON [sJOB].[category_id] = [sCAT].[category_id]
						LEFT JOIN [msdb].[sys].[database_principals] AS [sDBP] ON [sJOB].[owner_sid] = [sDBP].[sid]
						LEFT JOIN [msdb].[dbo].[sysjobschedules] AS [sJOBSCH] ON [sJOB].[job_id] = [sJOBSCH].[job_id]
						LEFT JOIN [msdb].[dbo].[sysschedules] AS [sSCH] ON [sJOBSCH].[schedule_id] = [sSCH].[schedule_id]
					ORDER BY
					 [IsScheduled], [IsEnabled] ,
					 [sJOB].[enabled],
					 [JobName] ,
						[StepNo]
					', 
				@css = '', @html = @html_temp out
			set @html_final = @html_final + @html_temp


			-- INFORMAÇÕES DE JOBS COM ERROS DE EXECUÇÃO NOS ULTIMOS 30 DIAS
			set @html_final = @html_final + '<h2>Informações de Jobs com Erros de Execução nos Últimos 30 Dias</h2>'
			execute tempdb.dbo.usp_resultset_html 
				@consulta = '
					SELECT msdb.dbo.agent_datetime(jh.run_date,jh.run_time) as date_time, j.name as job_name,js.step_id as job_step,jh.message as error_message
					FROM msdb.dbo.sysjobs AS j
					INNER JOIN msdb.dbo.sysjobsteps AS js ON js.job_id = j.job_id
					INNER JOIN msdb.dbo.sysjobhistory AS jh ON jh.job_id = j.job_id AND jh.step_id = js.step_id
					WHERE jh.run_status = 0 AND msdb.dbo.agent_datetime(jh.run_date,jh.run_time) >= GETDATE()-30
					ORDER BY msdb.dbo.agent_datetime(jh.run_date,jh.run_time) DESC
					', 
				@css = '', @html = @html_temp out
			set @html_final = @html_final + @html_temp

			-- HTML finalizado (mostro em XML para que o html não seja truncado quando superar 65k chars)
			set @html_final = '<html>' + @html_final + '</html>'
			select cast(@html_final as xml) as html

		end
	else
		raiserror ('SQL Inferior a 2008R2 não suportado.', 16, 1);  

end
go


--------------------------------------------------
-- MAIN
--------------------------------------------------
execute tempdb.dbo.usp_assessment_projetos_clientes

/*
== OBS: Para que o XML não seja truncado pelo SSMS, configure: 
	Tools > Options 
	Query Results > SQL Server > Results to Grid
	Maximum character retrieved: XML = Unlimited

== Troubleshooting:
execute tempdb.dbo.usp_resultset_html @consulta='select 1 as teste', @output_result=1
execute tempdb.dbo.usp_resultset_html @consulta='select * from information_schema.tables', @output_result=1

*/