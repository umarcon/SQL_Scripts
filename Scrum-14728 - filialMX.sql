USE [Westcon]
GO

/****** Object:  View [Starsoft].[vwFilialMexico]    Script Date: 29/09/2015 15:29:15 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO



CREATE  VIEW [Starsoft].[vwFilialMexico]
AS

	SELECT
		RTRIM(LTRIM(CIA.CIA_001_C)) AS FILIAL
	FROM
		StarWestconMX.dbo.CIA (NOLOCK)
		

GO

