/*
	Transparent Data Encryption - TDE
	
	Autor: Marcos Miguel
	 Data: 21/03/2021

	 Referência: https://docs.microsoft.com/pt-br/sql/relational-databases/security/encryption/transparent-data-encryption?view=sql-server-ver15
	             https://www.dirceuresende.com/blog/sql-server-2008-como-criptografar-seus-dados-utilizando-transparent-data-encryption-tde/
*/

--Verifica se na instância já existe criado a chave mestre
SELECT DB_NAME(database_id) 'Database', 
       encryption_state 
  FROM sys.dm_database_encryption_keys;

--Ativando o TDE
USE [master]
GO
CREATE MASTER KEY ENCRYPTION BY PASSWORD = '%2021-UuUlptBOL33NviD2021@123';  
GO
CREATE CERTIFICATE MeuCertificadoDoServidor WITH SUBJECT = 'Certificado Laptop Marcos';  
GO

USE [CWEUOR_109868_RM_PRO]
GO
CREATE DATABASE ENCRYPTION KEY  
WITH ALGORITHM = AES_256  
ENCRYPTION BY SERVER CERTIFICATE MeuCertificadoDoServidor;  
GO

ALTER DATABASE [CWEUOR_109868_RM_PRO]  
SET ENCRYPTION ON;  
GO

--Verifica quais bancos estão criptografados ou acompanhar o andamento do processo de criptografia
SELECT 
    A.[name], 
    A.is_master_key_encrypted_by_server, 
    A.is_encrypted,
    B.*
FROM 
    sys.databases A
    JOIN sys.dm_database_encryption_keys B ON B.database_id = A.database_id

--Comando para realizar o backup do certificado e da chave privada:
USE [master]
GO

BACKUP CERTIFICATE MeuCertificadoDoServidor 
TO FILE =  'D:\Backups\MasterKey\marcosmiguel.cer'
WITH PRIVATE KEY ( FILE = 'D:\Backups\MasterKey\marcosmiguel_Key.pvk', 
ENCRYPTION BY PASSWORD = '%2021-UuUlptBOL33NviD2021@123' );
GO


--Restaurar o banco de dados com TDE em outra instância

-- Cria uma nova master key. Aqui você pode escolher uma nova senha
CREATE MASTER KEY ENCRYPTION BY PASSWORD = 'n6ApUO(i<8lRNT,2SF-{3LDzRUR;?MPd-Q-Fg3oec[wqMjKfp^';  
GO  
-- Cria o certificado na master
CREATE CERTIFICATE MeuCertificadoDoServidor
FROM FILE = 'D:\Backups\MasterKey\marcosmiguel.cer'   
WITH PRIVATE KEY (
    FILE = 'D:\Backups\MasterKey\marcosmiguel_Key.pvk',   
    DECRYPTION BY PASSWORD = '%2021-UuUlptBOL33NviD2021@123');
)
-- Restaura o banco
RESTORE DATABASE [CWEUOR_109868_RM_PRO]   
    FROM DISK = 'C:\Backups\CWEUOR_109868_RM_PRO.bak'
    WITH REPLACE, STATS = 5,
    MOVE 'CWEUOR_109868_RM_PRO_Data' TO 'C:\Program Files\Microsoft SQL Server\MSSQL15.SQL2019\MSSQL\DATA\dirceuresende.mdf',
    MOVE 'CWEUOR_109868_RM_PRO_log' TO 'C:\Program Files\Microsoft SQL Server\MSSQL15.SQL2019\MSSQL\DATA\dirceuresende_log.ldf'


/*
Limitações do Transparent Data Encryption (TDE)

	1. O TDE não protege os dados na memória, portanto, os dados confidenciais podem ser vistos por qualquer pessoa que tenha direitos de DBO em um banco de dados ou direitos de SA para a instância do SQL Server. Em outras palavras, o TDE não pode impedir que os DBAs visualizem os dados que desejam ver.

	2. TDE não é granular. O banco de dados inteiro é criptografado.

	3. TDE não protege as comunicações entre aplicativos clientes e o SQL Server, portanto, outros métodos de criptografia devem ser usados ​​para proteger os dados que trafegam pela rede e podem ser interceptados por usuários mal-intencionados.

	4. No TDE, todos os arquivos e os filegroups do banco de dados são criptografados. Se algum filegroup do banco de dados estiver marcado como READ ONLY, haverá falha na operação de criptografia de banco de dados.
	   Dados FILESTREAM não são criptografados.

	5. Se um banco de dados estiver sendo usado no database mirror ou log shipping, ambos os bancos de dados serão criptografados. As transações de logs serão criptografadas quando enviadas entre eles.

	6. Quando qualquer banco de dados em uma instância do SQL Server tiver a TDE ativada, o banco de dados tempdb será automaticamente criptografado, o que pode contribuir para um desempenho ruim dos bancos de dados criptografados e não criptografados em execução na mesma instância.

	7. Embora menos recursos sejam necessários para implementar a TDE do que a criptografia no nível da coluna, ainda haverá um pouco de overhead, o que pode impedir que ela seja usada em SQL Servers que estejam enfrentando problemas de bottlenecks da CPU.

	8. Os bancos de dados criptografados com o TDE não podem aproveitar a nova compactação de backup do SQL Server 2008. Se você quiser aproveitar a compactação e a criptografia de backup, precisará usar um aplicativo de terceiros, como o SQL Backup, que permite executar essas duas tarefas sem penalidade.

*/