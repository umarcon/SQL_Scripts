USE [Westcon]
GO

/****** Object:  View [Starsoft].[vwCadCrdColombia]    Script Date: 30/09/2015 11:52:10 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO





CREATE  VIEW [Starsoft].[vwCadCrdColombia]
AS

	SELECT
		A11.A11_001_C AS CODIGO, A11.A11_003_C AS DESCRICAO
	FROM
		StarWestconcala2.dbo.A11 (NOLOCK)
	



GO

