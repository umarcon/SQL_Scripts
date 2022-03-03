USE [Westcon]
GO

/****** Object:  View [Starsoft].[vwPlanoContasColombia]    Script Date: 30/09/2015 11:52:21 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO





CREATE  VIEW [Starsoft].[vwPlanoContasColombia]
AS

	SELECT
		B11.B11_001_C AS CODIGO, B11.B11_003_C AS DESCRICAO
	FROM
		StarWestconcala2.dbo.b11 (NOLOCK)
	



GO

