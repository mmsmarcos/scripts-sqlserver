DECLARE @CODCOLIGADA INT, @REDUZIDO VARCHAR(20)

-- Cursor para percorrer os nomes dos objetos 
DECLARE DELETA_LINHAS_DUPLICADAS CURSOR FOR
    
SELECT DISTINCT codcoligada, reduzido
  FROM dre.contadre 
 WHERE Reduzido='60602'


-- Abrindo Cursor para leitura
OPEN DELETA_LINHAS_DUPLICADAS

-- Lendo a próxima linha
FETCH NEXT FROM DELETA_LINHAS_DUPLICADAS INTO @CODCOLIGADA, @REDUZIDO

-- Percorrendo linhas do cursor (enquanto houverem)
WHILE @@FETCH_STATUS = 0
BEGIN

    IF (SELECT count(codcoligada) as #row 
	      FROM dre.contadre WHERE codcoligada=@CODCOLIGADA AND reduzido=@REDUZIDO
			group by codcoligada, reduzido, descricao
			having count(codcoligada) > 1) > 1
	
	SET ROWCOUNT 1
	DELETE FROM dre.contadre WHERE codcoligada=@CODCOLIGADA AND reduzido=@REDUZIDO

-- Lendo a próxima linha
    FETCH NEXT FROM DELETA_LINHAS_DUPLICADAS INTO @CODCOLIGADA, @REDUZIDO
END

-- Fechando Cursor para leitura
CLOSE DELETA_LINHAS_DUPLICADAS

-- Desalocando o cursor
DEALLOCATE DELETA_LINHAS_DUPLICADAS