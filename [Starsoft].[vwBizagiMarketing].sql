USE [Westcon]
GO

/****** Object:  View [Starsoft].[vwBizagiMarketing]    Script Date: 01/06/2016 11:27:39 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

ALTER  VIEW [Starsoft].[vwBizagiMarketing]
AS

	SELECT F11.F11_001_C AS 'NUMERO DA DESPESA',
	F11.F11_002_D AS 'DATA DA EMISSAO',
	F14.F14_003_D AS 'DATA DE VENCIMENTO',
	F14.F14_010_B AS 'VALOR',
	F11.F11_033_C AS 'CODIGO DE PAGAMENTO',
	LTRIM(RTRIM(A08.A08_010_C))+' - '+LTRIM(RTRIM(A08.A08_003_C)) AS 'FORNECEDOR'
	FROM STARWESTCON.DBO.F11 (NOLOCK)
	INNER JOIN STARWESTCON.DBO.F14 (NOLOCK) ON F14.F11_UKEY = F11.UKEY
	INNER JOIN STARWESTCON.DBO.A08 (NOLOCK) ON F11.A08_UKEY = A08.UKEY
	INNER JOIN STARWESTCON.DBO.A21 (NOLOCK) ON F11.A21_UKEY = A21.UKEY
	WHERE F11.F11_033_C <> '' AND A21.A21_001_C IN ('15.99','02.16')




GO


