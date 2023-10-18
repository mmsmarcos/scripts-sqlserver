-- Nome: APURACAO_DOCUMENTOS_ELETRONICOS_HTML.sql
-- Modulo/Descrição : Apuração de documentos eletrônicos saída html
-- Atenção: Este script deverá ser executado na instância do Protheus que será migrada para Totvs
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
if object_id('dbo.usp_resultset_html') is not null drop procedure dbo.usp_resultset_html
go
create procedure dbo.usp_resultset_html  (@consulta nvarchar(max) , @titulo_tabela nvarchar(300) = '', @css nvarchar(max) = 'default', @html varchar(max) = '' output, @output_result bit = 0)
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
	set @colunas = stuff((select ', [' + COLUMN_NAME + '] as td' from [INFORMATION_SCHEMA].[COLUMNS] where TABLE_NAME = @table_name for xml path('')), 1, 1, '')

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


go
if object_id('dbo.usp_assessment_projetos_clientes') is not null drop procedure dbo.usp_assessment_projetos_clientes
go
create procedure dbo.usp_assessment_projetos_clientes 
as begin 
	declare @version varchar(4)
	set @version = substring(@@version, 22, 4)
	
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
			set @html_final = @html_final + '<h1>Apuração de Emissão de Documentos Eletrônicos</h1>'
					   						
			-- SPED050/NFe:
			set @html_final = @html_final + '<h2>SPED050 / NFe</h2>'
			
			declare @ano1 varchar(4)
			declare @ano2 varchar(4)
			set @ano1 = YEAR(GETDATE())
			set @ano2 = YEAR(GETDATE()) -3

			if object_id('tempdb.dbo.##tempsped050') is not null drop table ##tempsped050
			SELECT  substring(DATE_NFE, 1, 4) AS "Ano", COUNT(*) AS "Quantidade Total NFe"
			into ##tempsped050
			FROM SPED050 WHERE substring(DATE_NFE, 1, 4) BETWEEN  @ano2 AND @ano1 
			GROUP BY substring(DATE_NFE, 1, 4)
			ORDER BY substring(DATE_NFE, 1, 4) DESC						

			execute dbo.usp_resultset_html  @consulta = 'select * from ##tempsped050', 
			@css = '', @html = @html_temp out
			set @html_final = @html_final + @html_temp

			--SOMATÓRIO NFe
			if object_id('tempdb.dbo.##somasped050') is not null drop table ##somasped050
			SELECT  COUNT(*) AS "##### Somatorio NFe #####"
			INTO ##somasped050
			FROM SPED050 WHERE substring(DATE_NFE, 1, 4) BETWEEN  @ano2 AND @ano1
			execute dbo.usp_resultset_html  @consulta = 'SELECT * FROM ##somasped050',
			
			@css = '', @html = @html_temp out
			set @html_final = @html_final + @html_temp
			

			-- SPED051/NFSe:
			set @html_final = @html_final + '<h2>SPED051 / NFSe</h2>'
			
			if object_id('tempdb.dbo.##tempsped051') is not null drop table ##tempsped051
			SELECT  substring(DATE_NFSE, 1, 4) AS "Ano", COUNT(*) AS "Quantidade Total NFSe"
			INTO ##tempsped051
			FROM SPED051 WHERE substring(DATE_NFSE, 1, 4) BETWEEN  @ano2 AND @ano1
			GROUP BY substring(DATE_NFSE, 1, 4)
			ORDER BY substring(DATE_NFSE, 1, 4) DESC

			execute dbo.usp_resultset_html  @consulta = 'select * from ##tempsped051', 

			@css = '', @html = @html_temp out
			set @html_final = @html_final + @html_temp

			if object_id('tempdb.dbo.##somasped051') is not null drop table ##somasped051
			SELECT COUNT(*) AS "##### Somatorio NFSe #####"
			INTO ##somasped051
			FROM SPED051 WHERE substring(DATE_NFSE, 1, 4) BETWEEN  @ano2 AND @ano1

			execute dbo.usp_resultset_html  @consulta = 'select * from ##somasped051', 

			@css = '', @html = @html_temp out									
			set @html_final = @html_final + @html_temp + '<p></p>' -- '<p></p>' = espaço entre os dois resultsets

			-- SPED150/NFCe:
			set @html_final = @html_final + '<h2>SPED150 / NFCe</h2>'	

			if object_id('tempdb.dbo.##tempsped150') is not null drop table ##tempsped150
			SELECT  substring(DATE_EVEN, 1, 4) AS "Ano", COUNT(*) AS "Quantidade Total NFCe"
			INTO ##tempsped150
			FROM SPED150 WHERE substring(DATE_EVEN, 1, 4) BETWEEN  @ano2 AND @ano1
			GROUP BY substring(DATE_EVEN, 1, 4)
			ORDER BY substring(DATE_EVEN, 1, 4) DESC

			execute dbo.usp_resultset_html  @consulta = 'select * from ##tempsped150', 

			@css = '', @html = @html_temp out
			set @html_final = @html_final + @html_temp

			if object_id('tempdb.dbo.##somasped150') is not null drop table ##somasped150
			SELECT COUNT(*) AS "##### Somatorio NFCe #####"
			INTO ##somasped150
			FROM SPED150 WHERE substring(DATE_EVEN, 1, 4) BETWEEN  @ano2 AND @ano1

			execute dbo.usp_resultset_html  @consulta = 'select * from ##somasped150', 
			
			@css = '', @html = @html_temp out									
			set @html_final = @html_final + @html_temp + '<p></p>' -- '<p></p>' = espaço entre os dois resultsets

			-- SPED400/eSocial:
			set @html_final = @html_final + '<h2>SPED400 / eSocial</h2>'
			
			if object_id('tempdb.dbo.##tempsped400') is not null drop table ##tempsped400
			SELECT  substring(DTENTRADA, 1, 4) AS "Ano", COUNT(*) AS "Quantidade Total eSocial"
			INTO ##tempsped400
			FROM SPED400 WHERE substring(DTENTRADA, 1, 4) BETWEEN  @ano2 AND @ano1
			GROUP BY substring(DTENTRADA, 1, 4)
			ORDER BY substring(DTENTRADA, 1, 4) DESC

			execute dbo.usp_resultset_html  @consulta = 'select * from ##tempsped400', 

			@css = '', @html = @html_temp out
			set @html_final = @html_final + @html_temp

			if object_id('tempdb.dbo.##somasped400') is not null drop table ##somasped400
			SELECT COUNT(*) AS "##### Somatorio eSocial #####"
			INTO ##somasped400
			FROM SPED400 WHERE substring(DTENTRADA, 1, 4) BETWEEN  @ano2 AND @ano1

			execute dbo.usp_resultset_html  @consulta = 'select * from ##somasped400', 

			@css = '', @html = @html_temp out									
			set @html_final = @html_final + @html_temp + '<p></p>' -- '<p></p>' = espaço entre os dois resultsets

			-- SPED500/REINF:
			set @html_final = @html_final + '<h2>SPED500 / REINF</h2>'	
			
			if object_id('tempdb.dbo.##tempsped500') is not null drop table ##tempsped500
			SELECT  substring(DTENTRADA, 1, 4) AS "Ano", COUNT(*) AS "Quantidade Total REINF"
			INTO ##tempsped500
			FROM SPED500 WHERE substring(DTENTRADA, 1, 4) BETWEEN  @ano2 AND @ano1
			GROUP BY substring(DTENTRADA, 1, 4)
			ORDER BY substring(DTENTRADA, 1, 4) DESC

			execute dbo.usp_resultset_html  @consulta = 'select * from ##tempsped500', 

			@css = '', @html = @html_temp out
			set @html_final = @html_final + @html_temp

			if object_id('tempdb.dbo.##somasped500') is not null drop table ##somasped500
			SELECT COUNT(*) AS "##### Somatorio REINF #####"
			INTO ##somasped500
			FROM SPED500 WHERE substring(DTENTRADA, 1, 4) BETWEEN  @ano2 AND @ano1

			execute dbo.usp_resultset_html  @consulta = 'select * from ##somasped500', 

			@css = '', @html = @html_temp out							
			set @html_final = @html_final + @html_temp + '<p></p>' -- '<p></p>' = espaço entre os dois resultsets

			-- SPED201/GNRE:
			set @html_final = @html_final + '<h2>SPED201 / GNRE</h2>'	
			
			if object_id('tempdb.dbo.##tempsped201') is not null drop table ##tempsped201
			SELECT  substring(DTENVTSS, 1, 4) AS "Ano", COUNT(*) AS "Quantidade Total GNRE"
			INTO ##tempsped201
			FROM SPED201 WHERE substring(DTENVTSS, 1, 4) BETWEEN  @ano2 AND @ano1
			GROUP BY substring(DTENVTSS, 1, 4)
			ORDER BY substring(DTENVTSS, 1, 4) DESC

			execute dbo.usp_resultset_html  @consulta = 'select * from ##tempsped201', 

			@css = '', @html = @html_temp out
			set @html_final = @html_final + @html_temp

			if object_id('tempdb.dbo.##somasped201') is not null drop table ##somasped201
			SELECT COUNT(*) AS "##### Somatorio GNRE ####"
			INTO ##somasped201
			FROM SPED201 WHERE substring(DTENVTSS, 1, 4) BETWEEN  @ano2 AND @ano1

			execute dbo.usp_resultset_html  @consulta = 'select * from ##somasped201',
			
			@css = '', @html = @html_temp out									
			set @html_final = @html_final + @html_temp + '<p></p>' -- '<p></p>' = espaço entre os dois resultsets

			-- SOMATÓRIO GERAL:
			set @html_final = @html_final + '<h2>Somatório Geral</h2>'	
			
			--declare @ano1 varchar(4)					
			--declare @ano2 varchar(4)
			declare @somatorio int
			declare @somatorio2 int
			declare @somatorio3 int
			declare @somatorio4 int
			declare @somatorio5 int
			declare @somatorio6 int
			set @ano1 = YEAR(GETDATE())
			set @ano2 = YEAR(GETDATE()) -3
			SELECT @somatorio =  COUNT(*)
			FROM SPED050 WHERE substring(DATE_NFE, 1, 4) BETWEEN  @ano2 AND @ano1
			SELECT @somatorio2 = COUNT(*) 
			FROM SPED051 WHERE substring(DATE_NFSE, 1, 4) BETWEEN  @ano2 AND @ano1
			SELECT @somatorio3 = COUNT(*)
			FROM SPED150 WHERE substring(DATE_EVEN, 1, 4) BETWEEN  @ano2 AND @ano1
			SELECT @somatorio4 = COUNT(*)
			FROM SPED400 WHERE substring(DTENTRADA, 1, 4) BETWEEN  @ano2 AND @ano1
			SELECT @somatorio5 = COUNT(*)
			FROM SPED500 WHERE substring(DTENTRADA, 1, 4) BETWEEN  @ano2 AND @ano1
			SELECT @somatorio6 = COUNT(*)
			FROM SPED201 WHERE substring(DTENVTSS, 1, 4) BETWEEN  @ano2 AND @ano1
			if object_id('tempdb.dbo.##somatoriogeral') is not null drop table ##somatoriogeral
													 
			SELECT @somatorio + @somatorio2 + @somatorio3 + @somatorio4 + @somatorio5 + @somatorio6 AS "Somatorio Geral" INTO ##somatoriogeral
														
			execute dbo.usp_resultset_html  @consulta = 'SELECT * FROM ##somatoriogeral
														', 
			@css = '', @html = @html_temp out
			set @html_final = @html_final + @html_temp

			-- ENTIDADES ATIVAS:
			set @html_final = @html_final + '<h2>Entidades Ativas</h2>'

			if object_id('tempdb.dbo.##entidadesativas') is not null drop table ##entidadesativas
			SELECT A.ID_ENT, A.CNPJ, A.UF, B.NOME, B.FANTASIA, A.PASSCERT, A.IDEMPRESA  
			INTO ##entidadesativas
			FROM SPED001 A INNER JOIN SPED001A B
			ON A.ID_ENT = B.ID_ENT
			AND (ENTATIV = '' OR ENTATIV = 'S')

			execute dbo.usp_resultset_html  @consulta = 'select * from ##entidadesativas',
			
			@css = '', @html = @html_temp out									
			set @html_final = @html_final + @html_temp + '<p></p>' -- '<p></p>' = espaço entre os dois resultsets

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
execute dbo.usp_assessment_projetos_clientes

drop procedure dbo.usp_resultset_html
drop procedure dbo.usp_assessment_projetos_clientes

