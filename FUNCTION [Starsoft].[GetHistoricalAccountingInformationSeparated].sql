USE [Westcon]
GO
/****** Object:  UserDefinedFunction [Starsoft].[GetHistoricalAccountingInformationSeparated]    Script Date: 05/01/2017 14:39:05 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



ALTER FUNCTION [Starsoft].[GetHistoricalAccountingInformationSeparated]
(
	-- Histório do lançamento contábil
	@PLC_Historical as varchar(254),
	-- O que deseja retornar, 1- Sigla da Operação, 2- numero da Operação, 3- Nome do Fornecedor da Operação/Descritivo da Operação
	@PLN_WhatIWant as int
)
RETURNS varchar(254)
AS
BEGIN

	declare @VLN_InitialPosicion as int = 0
	declare @VLN_LenExpression as int = 0
	declare @VLC_Return as varchar(254)

	SET @VLC_Return = ''
	
	-- Retiro os espaços em branco do inicio e do final do historico caso existam
	-- Troco o indicador númerico pois temos dois tipos e isso faz acontecer um erro
	-- Obs: se quiser ver a diferença entre os campos faça um select com os char(186) e char(176)
	SET @PLC_Historical = REPLACE(RTRIM(LTRIM(@PLC_Historical)),CHAR(186),CHAR(176))

	IF (PATINDEX('%[N° - ]%',@PLC_Historical) > 0)
	BEGIN

		-- Verifico o que desejo retornar
		IF (@PLN_WhatIWant = 1) -- Sigla da Operação
		BEGIN
			-- Posicao inicial
			SET @VLN_InitialPosicion = 1
			
			-- Tamanho da Expressão (Retiro uma posição pois preciso dos caracteres até a posição anterior a essa usada na busca
			SET @VLN_LenExpression = CHARINDEX('N°',@PLC_Historical) - 1
			
		END
		
		IF (@PLN_WhatIWant = 2) -- Número da Operação
		BEGIN
			-- Posicao inicial (Add duas posições pois preciso dos caracteres após a posição usada na busca
			SET @VLN_InitialPosicion = CHARINDEX('ref. ',@PLC_Historical) + 4
			
			-- Tamanho da Expressão (Posicao final - posicao inicial)
			SET @VLN_LenExpression = CHARINDEX('do',@PLC_Historical) - @VLN_InitialPosicion
		END

		IF (@PLN_WhatIWant = 3) -- Nome do Fornecedor da Operação/Descritivo da Operação
		BEGIN
			-- Posicao inicial (Add três posições pois preciso dos caracteres após a posição usada na busca
			--SET @VLN_InitialPosicion = CHARINDEX('do',@PLC_Historical) + 3 Comentado por Ulisses Marcon a fim de corrigir o problema do nome do cliente no histórico contábil - SCRUM-15478
			SET @VLN_InitialPosicion = CHARINDEX('do',@PLC_Historical) + 3
			
			-- Tamanho da Expressão (Tamanho total da expressao - posicao inicial)
			-- Se tiver ponto no final da expressão, desconsidero ele
			SET @VLN_LenExpression = LEN(@PLC_Historical) - @VLN_InitialPosicion + CASE WHEN RIGHT(@PLC_Historical,1) = '.' THEN 0 ELSE 1 END
		END

	END

	-- Verifico se encontrei as separações
	IF (@VLN_InitialPosicion > 0) and (@VLN_LenExpression > 0)
		SET @VLC_Return = LTRIM(RTRIM(SUBSTRING(@PLC_Historical,@VLN_InitialPosicion,@VLN_LenExpression)))
		
	RETURN @VLC_Return
	
END


