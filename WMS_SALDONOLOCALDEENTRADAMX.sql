USE [Westcon]
GO

/****** Object:  View [Starsoft].[WMS_SALDONOLOCALDEENTRADAMX]    Script Date: 21/09/2015 16:47:09 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO










ALTER VIEW [Starsoft].[WMS_SALDONOLOCALDEENTRADAMX]
AS

SELECT	CIA.CIA_001_C FILIAL,
		RTRIM(D07_FILHO.D07_001_C) + '-' + RTRIM(D07_FILHO.D07_002_C) LOCAL,
		D04.D04_001_C PARTNUMBER,
		D04.D04_008_C DESCRICAO,
		D26.D26_001_B SALDO_FISICO,
		D07_FILHO.UKEY D07_UKEY,
		D04.UKEY D04_UKEY
FROM STARWESTCONMX.DBO.D07 D07_PAI (NOLOCK)
JOIN STARWESTCONMX.DBO.CIA CIA (NOLOCK) ON D07_PAI.CIA_UKEY_WMS = CIA.UKEY
JOIN STARWESTCONMX.DBO.D07 D07_FILHO (NOLOCK) ON D07_FILHO.D07_UKEY = D07_PAI.UKEY
JOIN STARWESTCONMX.DBO.D26 D26 (NOLOCK) ON D26.D07_UKEY = D07_FILHO.UKEY
JOIN STARWESTCONMX.DBO.D04 D04 (NOLOCK) ON D26.D04_UKEY = D04.UKEY
WHERE D07_FILHO.D07_500_N = 1 AND D26.ARRAY_209 = 13 AND D26.D26_001_B > 0








GO

