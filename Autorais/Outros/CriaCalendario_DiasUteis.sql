CREATE PROCEDURE dbo.stpGera_Feriados
AS BEGIN
    

    -------------------------------
    -- Cria a tabela se n�o existir
    -------------------------------

    IF (OBJECT_ID('dbo.Feriado') IS NULL)
    BEGIN
        
        -- DROP TABLE dbo.Feriado
        CREATE TABLE dbo.Feriado (
            Nr_Ano SMALLINT NOT NULL,
            Nr_Mes SMALLINT NOT NULL,
            Nr_Dia SMALLINT NOT NULL,
            Tp_Feriado CHAR(1) NULL,
            Ds_Feriado VARCHAR(100) NOT NULL,
            Sg_UF CHAR(2) NOT NULL
        )
        
        ALTER TABLE dbo.Feriado ADD CONSTRAINT [Pk_Feriado] PRIMARY KEY CLUSTERED  ([Nr_Ano], [Nr_Mes], [Nr_Dia], [Sg_UF]) WITH (FILLFACTOR=90, PAD_INDEX=ON) ON [PRIMARY]


    END


    -- Apaga os dados se j� tiverem sido populados
    TRUNCATE TABLE dbo.Feriado


    -------------------------------
    -- Feriados nacionais
    -------------------------------

    INSERT INTO dbo.Feriado
    SELECT 0, 1, 1, 1, 'Confraterniza��o Universal', ''
    UNION
    SELECT 0, 4, 21, 1, 'Tiradentes', ''
    UNION
    SELECT 0, 5, 1, 1, 'Dia do Trabalhador', ''
    UNION
    SELECT 0, 9, 7, 1, 'Independ�ncia', ''
    UNION
    SELECT 0, 10, 12, 1, 'Nossa Senhora Aparecida', ''
    UNION
    SELECT 0, 11, 2, 1, 'Finados', ''
    UNION
    SELECT 0, 11, 15, 1, 'Proclama��o da Rep�blica', ''
    UNION
    SELECT 0, 12, 25, 1, 'Natal', ''



    -------------------------------
    -- Feriados estaduais
    -------------------------------

    -- Acre
    INSERT INTO dbo.Feriado
    SELECT 0, 1, 23, 2, 'Dia do evang�lico', 'AC'
    UNION
    SELECT 0, 3, 8, 2, 'Alusivo ao Dia Internacional da Mulher', 'AC'
    UNION
    SELECT 0, 6, 15, 2, 'Anivers�rio do estado', 'AC'
    UNION
    SELECT 0, 9, 5, 2, 'Dia da Amaz�nia', 'AC'
    UNION
    SELECT 0, 11, 17, 2, 'Assinatura do Tratado de Petr�polis', 'AC'

    -- Alagoas
    INSERT INTO dbo.Feriado
    SELECT 0, 6, 24, 2, 'S�o Jo�o', 'AL'
    UNION
    SELECT 0, 6, 29, 2, 'S�o Pedro', 'AL'
    UNION
    SELECT 0, 9, 16, 2, 'Emancipa��o pol�tica', 'AL'
    UNION
    SELECT 0, 11, 20, 2, 'Morte de Zumbi dos Palmares', 'AL'

    -- Amap�
    INSERT INTO dbo.Feriado
    SELECT 0, 3, 19, 2, 'Dia de S�o Jos�, santo padroeiro do Estado do Amap�', 'AP'
    UNION
    SELECT 0, 9, 13, 2, 'Cria��o do Territ�rio Federal (Data Magna do estado)', 'AP'

    -- Amazonas
    INSERT INTO dbo.Feriado
    SELECT 0, 9, 5, 2, 'Eleva��o do Amazonas � categoria de prov�ncia', 'AM'
    UNION
    SELECT 0, 11, 20, 2, 'Dia da Consci�ncia Negra', 'AM'

    -- Bahia
    INSERT INTO dbo.Feriado
    SELECT 0, 7, 2, 2, 'Independ�ncia da Bahia�(Data magna do estado)', 'BA'

    -- Cear�
    INSERT INTO dbo.Feriado
    SELECT 0, 3, 25, 2, 'Data magna do estado (data da aboli��o da escravid�o no Cear�)', 'CE'

    -- Distrito Federal
    INSERT INTO dbo.Feriado
    SELECT 0, 4, 21, 2, 'Funda��o de�Bras�lia', 'DF'
    UNION
    SELECT 0, 11, 30, 2, 'Dia do�evang�lico', 'DF'

    -- Maranh�o
    INSERT INTO dbo.Feriado
    SELECT 0, 7, 28, 2, 'Ades�o do Maranh�o �independ�ncia do Brasil', 'MA'

    -- Mato Grosso
    INSERT INTO dbo.Feriado
    SELECT 0, 11, 20, 2, 'Dia da Consci�ncia Negra', 'MT'

    -- Mato Grosso do Sul
    INSERT INTO dbo.Feriado
    SELECT 0, 10, 11, 2, 'Cria��o do estado', 'MS'

    -- Minas Gerais
    INSERT INTO dbo.Feriado
    SELECT 0, 4, 21, 2, 'Data magna do estado', 'MG'

    -- Par�
    INSERT INTO dbo.Feriado
    SELECT 0, 8, 15, 2, 'Ades�o do�Gr�o-Par��independ�ncia do Brasil�(data magna)', 'PA'

    -- Para�ba
    INSERT INTO dbo.Feriado
    SELECT 0, 7, 26, 2, 'Homenagem � mem�ria do ex-presidente Jo�o Pessoa', 'PB'
    UNION
    SELECT 0, 8, 5, 2, 'Funda��o do Estado em 1585', 'PB'

    -- Paran�
    INSERT INTO dbo.Feriado
    SELECT 0, 12, 19, 2, 'Emancipa��o pol�tica (emancipa��o do�Paran�)', 'PR'

    -- Piau�
    INSERT INTO dbo.Feriado
    SELECT 0, 10, 19, 2, 'Dia do�Piau�', 'PI'

    -- Rio de Janeiro
    INSERT INTO dbo.Feriado
    SELECT 0, 4, 23, 2, 'Dia de�S�o Jorge', 'RJ'
    UNION
    SELECT 0, 11, 20, 2, 'Dia da Consci�ncia Negra', 'RJ'

    -- Rio Grande do Norte
    INSERT INTO dbo.Feriado
    SELECT 0, 10, 3, 2, 'M�rtires de Cunha� e Urua�u', 'RN'

    -- Rio Grande do Sul
    INSERT INTO dbo.Feriado
    SELECT 0, 9, 20, 2, 'Proclama��o da Rep�blica Rio-Grandense', 'RS'

    -- Rond�nia
    INSERT INTO dbo.Feriado
    SELECT 0, 1, 4, 2, 'Cria��o do estado (data magna)', 'RO'
    UNION
    SELECT 0, 6, 18, 2, 'Dia do evang�lico', 'RO'

    -- Roraima
    INSERT INTO dbo.Feriado
    SELECT 0, 10, 5, 2, 'Cria��o do estado', 'RR'

    -- Santa Catarina
    INSERT INTO dbo.Feriado
    SELECT 0, 10, 5, 2, 'Dia de Santa Catarina', 'SC'

    -- S�o Paulo
    INSERT INTO dbo.Feriado
    SELECT 0, 7, 9, 2, 'Revolu��o Constitucionalista de 1932�(Data magna do estado)', 'SP'

    -- Sergipe
    INSERT INTO dbo.Feriado
    SELECT 0, 3, 17, 2, 'Anivers�rio de Aracaju', 'SE'
    UNION
    SELECT 0, 6, 24, 2, 'S�o Jo�o', 'SE'
    UNION
    SELECT 0, 7, 8, 2, 'Autonomia pol�tica de Sergipe', 'SE'
    UNION
    SELECT 0, 12, 8, 2, 'Nossa Senhora da Concei��o', 'SE'

    -- Tocantins
    INSERT INTO dbo.Feriado
    SELECT 0, 10, 5, 2, 'Cria��o do estado', 'TO'
    UNION
    SELECT 0, 3, 18, 2, 'Autonomia do Estado (cria��o da Comarca do Norte)', 'TO'
    UNION
    SELECT 0, 9, 8, 2, 'Padroeira do Estado (Nossa Senhora da Natividade)', 'TO'

    
    -------------------------------
    -- Feriados m�veis
    -------------------------------

    DECLARE
        @ano INT,
        @seculo INT,
        @G INT,
        @K INT,
        @I INT,
        @H INT,
        @J INT,
        @L INT,
        @MesDePascoa INT,
        @DiaDePascoa INT,
        @pascoa DATETIME 


    DECLARE 
        @Dt_Inicial datetime = '1990-01-01',
        @Dt_Final datetime = '2099-01-01'


    WHILE(@Dt_Inicial <= @Dt_Final)
    BEGIN
        
        SET @ano = YEAR(@Dt_Inicial)

        SET @seculo = @ano / 100 
        SET @G = @ano % 19
        SET @K = ( @seculo - 17 ) / 25
        SET @I = ( @seculo - CAST(@seculo / 4 AS int) - CAST(( @seculo - @K ) / 3 AS int) + 19 * @G + 15 ) % 30
        SET @H = @I - CAST(@I / 28 AS int) * ( 1 * -CAST(@I / 28 AS int) * CAST(29 / ( @I + 1 ) AS int) ) * CAST(( ( 21 - @G ) / 11 ) AS int)
        SET @J = ( @ano + CAST(@ano / 4 AS int) + @H + 2 - @seculo + CAST(@seculo / 4 AS int) ) % 7
        SET @L = @H - @J
        SET @MesDePascoa = 3 + CAST(( @L + 40 ) / 44 AS int)
        SET @DiaDePascoa = @L + 28 - 31 * CAST(( @MesDePascoa / 4 ) AS int)
        SET @pascoa = CAST(@MesDePascoa AS varchar(2)) + '-' + CAST(@DiaDePascoa AS varchar(2)) + '-' + CAST(@ano AS varchar(4))

        
        INSERT INTO dbo.Feriado
        SELECT YEAR(DATEADD(DAY , -2, @pascoa)), MONTH(DATEADD(DAY , -2, @pascoa)), DAY(DATEADD(DAY , -2, @pascoa)), 1, 'Paix�o de Cristo', ''
        
        INSERT INTO dbo.Feriado
        SELECT YEAR(DATEADD(DAY , -48, @pascoa)), MONTH(DATEADD(DAY , -48, @pascoa)), DAY(DATEADD(DAY , -48, @pascoa)), 1, 'Carnaval', ''
        
        INSERT INTO dbo.Feriado
        SELECT YEAR(DATEADD(DAY , -47, @pascoa)), MONTH(DATEADD(DAY , -47, @pascoa)), DAY(DATEADD(DAY , -47, @pascoa)), 1, 'Carnaval', ''
        
        INSERT INTO dbo.Feriado
        SELECT YEAR(DATEADD(DAY , 60, @pascoa)), MONTH(DATEADD(DAY , 60, @pascoa)), DAY(DATEADD(DAY , 60, @pascoa)), 1, 'Corpus Christi', ''
        

        SET @Dt_Inicial = DATEADD(YEAR, 1, @Dt_Inicial)
        

    END

    
END
GO


CREATE FUNCTION [dbo].[fncDia_Util_Anterior] ( @Data_Dia DATETIME )
RETURNS DATETIME
AS
BEGIN
 
    WHILE (1 = 1)
    BEGIN

        SET @Data_Dia = @Data_Dia - (CASE DATEPART(WEEKDAY, @Data_Dia) WHEN 1 THEN 2 WHEN 7 THEN 1 ELSE 0 END)

        IF EXISTS ( SELECT TOP 1 Nr_Dia FROM dbo.Feriado WITH ( NOLOCK ) WHERE Nr_Dia = DAY(@Data_Dia) AND Nr_Mes = MONTH(@Data_Dia) AND Tp_Feriado = '1'  AND ( Nr_Ano = 0 OR Nr_Ano = YEAR(@Data_Dia) ) )
            SET @Data_Dia = @Data_Dia - 1
        ELSE
            BREAK  

    END

    RETURN CAST(FLOOR(CAST(@Data_Dia AS FLOAT)) AS DATETIME)

END


CREATE FUNCTION [dbo].[fncProximo_Dia_Util] ( @Data_Dia DATETIME )
RETURNS DATETIME
AS
BEGIN 

    WHILE (1 = 1)
    BEGIN

        SET @Data_Dia = @Data_Dia + (CASE DATEPART(WEEKDAY, @Data_Dia) WHEN 1 THEN 1 WHEN 7 THEN 2 ELSE 0 END)

        IF EXISTS ( SELECT TOP 1 Nr_Dia FROM dbo.Feriado WITH ( NOLOCK ) WHERE Nr_Dia = DAY(@Data_Dia) AND Nr_Mes = MONTH(@Data_Dia) AND Tp_Feriado = '1' AND ( Nr_Ano = 0 OR Nr_Ano = YEAR(@Data_Dia) ) )
            SET @Data_Dia = @Data_Dia + 1
        ELSE
            BREAK  
    END

    RETURN CAST(FLOOR(CAST(@Data_Dia AS FLOAT)) AS DATETIME)

END

CREATE FUNCTION [dbo].[fncDia_Util] ( @Data_Dia DATETIME )
RETURNS BIT
AS
BEGIN 

    DECLARE @retorno BIT

    IF ( DATEPART(WEEKDAY, @Data_Dia) IN ( 1, 7 ) )
        SET @retorno = 0	
    ELSE
    BEGIN

        IF EXISTS ( SELECT TOP 1 Nr_Dia FROM dbo.Feriado WITH ( NOLOCK ) WHERE Nr_Dia = DAY(@Data_Dia) AND Nr_Mes = MONTH(@Data_Dia) AND Tp_Feriado = '1' AND ( Nr_Ano = 0 OR Nr_Ano = YEAR(@Data_Dia) ) )
            SET @retorno = 0
        ELSE
            SET @retorno = 1
        
    END
    
    RETURN @retorno

END


SET LANGUAGE 'Brazilian'

IF (OBJECT_ID('dbo.Dia_Util') IS NOT NULL) DROP TABLE dbo.Dia_Util
CREATE TABLE dbo.Dia_Util (
    Dt_Referencia DATETIME,
    Nr_Dia TINYINT,
    Nr_Mes TINYINT,
    Nr_Ano INT,
    Dt_Dia_Util_Anterior DATETIME,
    Dt_Proximo_Dia_Util DATETIME,
    Fl_Dia_Util BIT,
    Fl_Dia_Util_Incluindo_Sabado BIT,
    Fl_Feriado BIT,
    Nr_Dia_Semana TINYINT,
    Ds_Dia_Semana VARCHAR(13),
    Nr_Semana INT,
    Nr_Semana_Mes INT,
    Nr_Dia_Ano INT,
    Qt_Dias_Uteis_Mes INT NULL,
    Qt_Dias_Uteis_Ano INT NULL
)

DECLARE @Dt_Inicial DATETIME = '19900101', @Dt_Final DATETIME = '20991231'

WHILE (@Dt_Inicial <= @Dt_Final)
BEGIN
    
    INSERT INTO dbo.Dia_Util
    SELECT 
        @Dt_Inicial AS Dt_Referencia, 
        DATEPART(DAY, @Dt_Inicial) AS Nr_Dia,
        DATEPART(MONTH, @Dt_Inicial) AS Nr_Mes,
        DATEPART(YEAR, @Dt_Inicial) AS Nr_Ano,
        dbo.fncDia_Util_Anterior(DATEADD(DAY, -1, @Dt_Inicial)) AS Dt_Dia_Util_Anterior,
        dbo.fncProximo_Dia_Util(DATEADD(DAY, 1, @Dt_Inicial)) AS Dt_Proximo_Dia_Util,
        dbo.fncDia_Util(@Dt_Inicial) AS Fl_Dia_Util,
        (CASE WHEN DATEPART(WEEKDAY, @Dt_Inicial) = 1 OR EXISTS(SELECT TOP 1 Nr_Dia FROM dbo.Feriado WITH(NOLOCK) WHERE Nr_Dia = DAY(@Dt_Inicial) AND Nr_Mes = MONTH(@Dt_Inicial) AND Tp_Feriado = '1' AND (Nr_Ano = 0 OR Nr_Ano = YEAR(@Dt_Inicial))) THEN 0 ELSE 1 END) AS Fl_Dia_Util_Incluindo_Sabado,
        (CASE WHEN EXISTS(SELECT TOP 1 Nr_Dia FROM dbo.Feriado WITH(NOLOCK) WHERE Nr_Dia = DAY(@Dt_Inicial) AND Nr_Mes = MONTH(@Dt_Inicial) AND Tp_Feriado = '1' AND (Nr_Ano = 0 OR Nr_Ano = YEAR(@Dt_Inicial))) THEN 1 ELSE 0 END) AS Fl_Feriado,
        DATEPART(WEEKDAY, @Dt_Inicial) AS Nr_Dia_Semana,
        DATENAME(WEEKDAY, @Dt_Inicial) AS Ds_Dia_Semana,
        DATEPART(WEEK, @Dt_Inicial) AS Nr_Semana,
        DATEPART(WEEK, @Dt_Inicial) - DATEPART(WEEK, @Dt_Inicial - DATEPART(DAY, @Dt_Inicial) + 1) + 1 AS Nr_Semana_Mes,
        DATEPART(DAYOFYEAR, @Dt_Inicial) AS Nr_Dia_Ano,
        NULL AS Qt_Dias_Uteis_Mes,
        NULL AS Qt_Dias_Uteis_Ano
        

    SET @Dt_Inicial = DATEADD(DAY, 1, @Dt_Inicial)
    
END


-- POPULA A QUANTIDADE DE DIAS �TEIS AT� A DATA
DECLARE @Qt_Dias_Uteis_Mes INT, @Qt_Dias_Uteis_Ano INT

SET @Dt_Inicial = '19900101'

WHILE (@Dt_Inicial <= @Dt_Final)
BEGIN
    
    
    SET @Qt_Dias_Uteis_Mes = (SELECT COUNT(*) FROM dbo.Dia_Util WITH(NOLOCK) WHERE Fl_Dia_Util = 1 AND Nr_Ano = YEAR(@Dt_Inicial) AND Dt_Referencia <= @Dt_Inicial AND Nr_Mes = MONTH(@Dt_Inicial))
    SET @Qt_Dias_Uteis_Ano = (SELECT COUNT(*) FROM dbo.Dia_Util WITH(NOLOCK) WHERE Fl_Dia_Util = 1 AND Nr_Ano = YEAR(@Dt_Inicial) AND Dt_Referencia <= @Dt_Inicial)
    
    
    UPDATE 
       A
    SET 
       Qt_Dias_Uteis_Mes = @Qt_Dias_Uteis_Mes,
       Qt_Dias_Uteis_Ano = @Qt_Dias_Uteis_Ano
    FROM
       dbo.Dia_Util A
    WHERE 
       Dt_Referencia = @Dt_Inicial
       
    
    SET @Dt_Inicial = DATEADD(DAY, 1, @Dt_Inicial)
    
END


-- ADICIONA MAIS INFORMA��ES NA TABELA (ATUALIZADO EM 09/10/2019)
ALTER TABLE dbo.Dia_Util ADD Fl_Ultimo_Dia_Mes BIT, Fl_Ultimo_Dia_Util_Mes BIT

UPDATE dbo.Dia_Util SET Fl_Ultimo_Dia_Mes = 0, Fl_Ultimo_Dia_Util_Mes = 0

UPDATE A 
SET A.Fl_Ultimo_Dia_Mes = 1
FROM dbo.Dia_Util A
JOIN (
    SELECT Nr_Ano, Nr_Mes, MAX(Dt_Referencia) AS Dt_Referencia
    FROM dbo.Dia_Util
    GROUP BY Nr_Ano, Nr_Mes
) B ON B.Dt_Referencia = A.Dt_Referencia


UPDATE A 
SET A.Fl_Ultimo_Dia_Util_Mes = 1
FROM dbo.Dia_Util A
JOIN (
    SELECT Nr_Ano, Nr_Mes, MAX(Dt_Referencia) AS Dt_Referencia
    FROM dbo.Dia_Util
    WHERE Fl_Dia_Util = 1
    GROUP BY Nr_Ano, Nr_Mes
) B ON B.Dt_Referencia = A.Dt_Referencia



ALTER TABLE dbo.Dia_Util ADD Nr_Bimestre TINYINT, Nr_Trimestre TINYINT, Nr_Semestre TINYINT

UPDATE dbo.Dia_Util
SET Nr_Bimestre = CEILING((Nr_Mes * 1.0) / 2),
Nr_Trimestre = CEILING((Nr_Mes * 1.0) / 3),
Nr_Semestre = CEILING((Nr_Mes * 1.0) / 6)


ALTER TABLE dbo.Dia_Util ADD Nm_Mes VARCHAR(20), Nm_Mes_Ano VARCHAR(30), Nm_Mes_Ano_Abreviado VARCHAR(20), Nr_Mes_Ano INT


UPDATE dbo.Dia_Util
SET
    Nm_Mes = DATENAME(MONTH, Dt_Referencia),
    Nm_Mes_Ano = DATENAME(MONTH, Dt_Referencia) + ' ' + CAST(Nr_Ano AS VARCHAR(4)),
    Nm_Mes_Ano_Abreviado = LEFT(DATENAME(MONTH, Dt_Referencia), 3) + '/' + RIGHT(Nr_Ano, 2),
    Nr_Mes_Ano = CAST(CAST(Nr_Ano AS VARCHAR(4)) + RIGHT('0' + CAST(Nr_Mes AS VARCHAR(2)), 2) AS INT)


ALTER TABLE dbo.Dia_Util ADD Nr_Quinzena INT, Ds_Semana VARCHAR(20), Ds_Quinzena VARCHAR(20), Ds_Bimestre VARCHAR(20), Ds_Trimestre VARCHAR(20), Ds_Semestre VARCHAR(20)


UPDATE dbo.Dia_Util
SET
    Nr_Quinzena = (CASE WHEN Nr_Dia <= 15 THEN 1 ELSE 2 END),
    Ds_Semana = CAST(Nr_Ano AS VARCHAR(4)) + ' - ' + CAST(Nr_Semana AS VARCHAR(2)) + 'a Semana',
    Ds_Quinzena = CAST(Nr_Ano AS VARCHAR(4)) + ' - ' + (CASE WHEN Nr_Dia <= 15 THEN '1a Quinzena' ELSE '2a Quinzena' END),
    Ds_Bimestre = CAST(Nr_Ano AS VARCHAR(4)) + ' - ' + CAST(Nr_Bimestre AS VARCHAR(2)) + 'o Bimestre',
    Ds_Trimestre = CAST(Nr_Ano AS VARCHAR(4)) + ' - ' + CAST(Nr_Trimestre AS VARCHAR(2)) + 'o Trimestre',
    Ds_Semestre = CAST(Nr_Ano AS VARCHAR(4)) + ' - ' + CAST(Nr_Semestre AS VARCHAR(2)) + 'o Semestre'


CREATE CLUSTERED INDEX Idx01 ON dbo.Dia_Util(Dt_Referencia)




CREATE FUNCTION dbo.fncQtde_Dias_Uteis_Mes (
    @Dt_Referencia DATETIME
)
RETURNS INT
AS BEGIN

    DECLARE @Retorno INT = 0

    SELECT
        @Retorno = COUNT(*)
    FROM
        dbo.Dia_Util	 WITH(NOLOCK)
    WHERE
        Dt_Referencia < = CONVERT(DATE, @Dt_Referencia)
        AND YEAR(Dt_Referencia) = YEAR(@Dt_Referencia) 
        AND MONTH(Dt_Referencia) = MONTH(@Dt_Referencia) 
        AND Fl_Dia_Util = 1

    RETURN @Retorno

END




CREATE FUNCTION dbo.fncAdiciona_Dias_Uteis(
    @Dt_Referencia [datetime], 
    @Qt_Dias_Uteis [int]
)
RETURNS datetime
AS 
BEGIN


    -- DECLARE @Dt_Referencia DATETIME = '2015-05-02 09:56:57.203'
    
    DECLARE 
        @Data_Retorno DATE,
        @Retorno DATETIME,
        @Hora TIME = @Dt_Referencia,
        @Ranking INT


    DECLARE @Ranking_Dias_Uteis TABLE (
        Ranking INT,
        Dt_Referencia DATETIME
    )

    
    INSERT INTO @Ranking_Dias_Uteis	
    SELECT
        ROW_NUMBER() OVER(ORDER BY Dt_Referencia) AS Ranking,
        Dt_Referencia
    FROM 
        dbo.Dia_Util		WITH(NOLOCK)
    WHERE 
        Fl_Dia_Util = 1


    SELECT @Ranking = (SELECT Ranking FROM @Ranking_Dias_Uteis WHERE Dt_Referencia = CONVERT(DATE, @Dt_Referencia))


    IF (@Ranking IS NULL)
        SET @Ranking = (SELECT MIN(Ranking) FROM @Ranking_Dias_Uteis WHERE Dt_Referencia >= CONVERT(DATE, @Dt_Referencia))

    
    SELECT @Data_Retorno = Dt_Referencia
    FROM @Ranking_Dias_Uteis
    WHERE Ranking = @Ranking + @Qt_Dias_Uteis
    

    SET @Retorno = CONVERT(DATETIME, CONVERT(VARCHAR(10), @Data_Retorno, 112) + ' ' + CONVERT(VARCHAR(12), @Hora))
    RETURN @Retorno

END



CREATE FUNCTION dbo.fncUltimo_Dia_Util(
    @Dt_Referencia DATETIME
)
RETURNS DATETIME
AS 
BEGIN

    DECLARE
        @Ano INT = YEAR(@Dt_Referencia),
        @Mes INT = MONTH(@Dt_Referencia),
        @Retorno DATETIME


    SELECT @Retorno = MAX(Dt_Referencia)
    FROM dbo.Dia_Util    WITH(NOLOCK)
    WHERE Nr_Ano = @Ano
    AND Nr_Mes = @Mes
    AND Fl_Dia_Util = 1

    RETURN @Retorno
    
END