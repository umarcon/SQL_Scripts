USE [Westcon]
GO

/****** Object:  View [Starsoft].[vwFilialBrasil]    Script Date: 29/09/2015 15:28:59 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO



CREATE  VIEW [Starsoft].[vwFilialBrasil]
AS

	SELECT
		RTRIM(LTRIM(CIA.CIA_001_C)) AS FILIAL
	FROM
		StarWestcon.dbo.CIA (NOLOCK)
		

GO

