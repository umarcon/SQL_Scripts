USE [StarWestconCALA2]
GO
/****** Object:  UserDefinedFunction [dbo].[NotaDebitoChile_Referencia]    Script Date: 20/03/2018 14:59:07 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER FUNCTION [dbo].[NotaDebitoChile_Referencia] 
(   
    @J10_UKEY AS VARCHAR(20)
)
RETURNS NVARCHAR(MAX)
AS
BEGIN
	DECLARE @MY_STRING AS VARCHAR(2000)
	-- COMEÇO DA LINHA DE CABEÇALHO
	SET @MY_STRING=+CHAR(13)+CHAR(10)+'->Referencia<-'+CHAR(13)+CHAR(10)

	-- (NroLineaRef) Primeira linha
	SET @MY_STRING=@MY_STRING+'1;'

	-- (TipoDTERef, FolioRef, FechaRef) - Modelo da Nota Original, Número de NF, Data de Emissão da NF, 
	SET @MY_STRING=@MY_STRING+ ISNULL( 
	(SELECT TOP 1
		LTRIM(RTRIM(T89_001_C))+';'+
		LTRIM(RTRIM(J10_507_C))+';'+
		CONVERT(char(10), J10_508_D,126)+';'+
		-- (CodigoRef)
		--0 Si Código de Referencia
		--1 Anula Documento de Referencia
		--2 Corrige Texto Documento de Referencia
		--3 Corrige Montos
		case when j10.ARRAY_979WE = 1 then '0;Sin Código de Referencia;'
			when j10.ARRAY_979WE = 2 then '1;Anula Documento de Referencia;'
			when j10.ARRAY_979WE = 3 then '2;Corrige Texto Documento de Referencia;'
			else '3;Corrige Montos' end
		FROM J10 (nolock) 
		JOIN T89 (NOLOCK) ON J10.T89WE_UKEY=T89.UKEY
		WHERE J10.UKEY=@J10_UKEY
		), '')+';'

	-- (CodigoRef)
	--0 Si Código de Referencia
	--1 Anula Documento de Referencia
	--2 Corrige Texto Documento de Referencia
	--3 Corrige Montos
	--SET @MY_STRING=@MY_STRING+'3;'

	-- (RazonRef) - Motivo da devolução
	--SET @MY_STRING=@MY_STRING+'Cobro de intereses;'

	RETURN @MY_STRING
END
