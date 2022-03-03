/*
	Alterado por Thiago Rodrigues
	Data: 13/06/2017
	Atividade PRB0040598 do service now
*/


alter FUNCTION [Starsoft].[GetHistoricalAccountingInformationSeparated]
(
	-- Hist�rio do lan�amento cont�bil
	@PLC_Historical as varchar(254),
	-- O que deseja retornar, 1- Sigla da Opera��o, 2- numero da Opera��o, 3- Nome do Fornecedor da Opera��o/Descritivo da Opera��o
	@PLN_WhatIWant as int
)
RETURNS varchar(254)
AS
BEGIN

	declare @VLN_InitialPosicion as int = 0
	declare @VLN_LenExpression as int = 0
	declare @VLC_Return as varchar(254)

	SET @VLC_Return = ''
	
	-- Retiro os espa�os em branco do inicio e do final do historico caso existam
	-- Troco o indicador n�merico pois temos dois tipos e isso faz acontecer um erro
	-- Obs: se quiser ver a diferen�a entre os campos fa�a um select com os char(186) e char(176)
	SET @PLC_Historical = REPLACE(RTRIM(LTRIM(@PLC_Historical)),CHAR(186),CHAR(176))

	IF (PATINDEX('%[N� - ]%',@PLC_Historical) > 0)
		BEGIN

			-- Verifico o que desejo retornar
			IF (@PLN_WhatIWant = 1) -- Sigla da Opera��o
			BEGIN
				-- Posicao inicial
				SET @VLN_InitialPosicion = 1
			
				-- Tamanho da Express�o (Retiro uma posi��o pois preciso dos caracteres at� a posi��o anterior a essa usada na busca
				SET @VLN_LenExpression = CHARINDEX('N�',@PLC_Historical) - 1

				IF @VLN_LenExpression <0
				BEGIN
					-- Tamanho da Express�o (Retiro uma posi��o pois preciso dos caracteres at� a posi��o anterior a essa usada na busca
					SET @VLN_InitialPosicion = CHARINDEX('CD',@PLC_Historical) 
					SET @VLN_LenExpression = 2
				END
			
			END
		
			IF (@PLN_WhatIWant = 2) -- N�mero da Opera��o
			BEGIN
				-- Posicao inicial (Add duas posi��es pois preciso dos caracteres ap�s a posi��o usada na busca
				-- SET @VLN_InitialPosicion = CHARINDEX('ref. ',@PLC_Historical) + 4
				   SET @VLN_InitialPosicion = CHARINDEX('N�',@PLC_Historical) + 3 -- Atividade PRB0040598 do service now
			
				-- Tamanho da Express�o (Posicao final - posicao inicial)
				-- SET @VLN_LenExpression = CHARINDEX('do',@PLC_Historical) - @VLN_InitialPosicion
				   SET @VLN_LenExpression = CHARINDEX('-',@PLC_Historical) - @VLN_InitialPosicion -- Atividade PRB0040598 do service now

					IF @VLN_InitialPosicion = 3
					BEGIN
						SET @VLN_InitialPosicion = CHARINDEX('CD-',@PLC_Historical)+3
						SET @VLN_LenExpression = CHARINDEX(',',@PLC_Historical) - @VLN_InitialPosicion -- Atividade PRB0040598 do service now
					END

			END

			IF (@PLN_WhatIWant = 3) -- Nome do Fornecedor da Opera��o/Descritivo da Opera��o
			BEGIN
				-- Posicao inicial (Add tr�s posi��es pois preciso dos caracteres ap�s a posi��o usada na busca
				--SET @VLN_InitialPosicion = CHARINDEX('do',@PLC_Historical) + 3 Comentado por Ulisses Marcon a fim de corrigir o problema do nome do cliente no hist�rico cont�bil - SCRUM-15478
				SET @VLN_InitialPosicion = CHARINDEX('do',@PLC_Historical) + 3
			
				-- Tamanho da Express�o (Tamanho total da expressao - posicao inicial)
				-- Se tiver ponto no final da express�o, desconsidero ele
				SET @VLN_LenExpression = LEN(@PLC_Historical) - @VLN_InitialPosicion + CASE WHEN RIGHT(@PLC_Historical,1) = '.' THEN 0 ELSE 1 END

				IF @VLN_InitialPosicion = 3
				BEGIN
					SET @VLN_InitialPosicion = CHARINDEX(', ',@PLC_Historical) + 2
					SET @VLN_LenExpression = LEN(@PLC_Historical) - @VLN_InitialPosicion + CASE WHEN RIGHT(@PLC_Historical,1) = '.' THEN 0 ELSE 1 END
				END
			END

		END

	-- Verifico se encontrei as separa��es
	IF (@VLN_InitialPosicion > 0) and (@VLN_LenExpression > 0)
		SET @VLC_Return = LTRIM(RTRIM(SUBSTRING(@PLC_Historical,@VLN_InitialPosicion,@VLN_LenExpression)))
		
	RETURN @VLC_Return
	
END


