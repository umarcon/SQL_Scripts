USE [Westcon]
GO
/****** Object:  StoredProcedure [Starsoft].[Report_RAS]    Script Date: 10/08/2017 10:58:27 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
*- 10/08/2017 - USMARCON
Criada para atender a atividade PRIME-1054
*/


-- EXEC [Starsoft].[Report_276] '','','',''
          
CREATE PROCEDURE [Starsoft].[Report_RAS]
	@PLC_RAS as varchar(20),
	@PLC_INVOICE as varchar(20)
	
AS
BEGIN
	SET NOCOUNT ON;

	SELECT DISTINCT
		WE98_005_C AS RAS,
		WE98_004_D AS DATA_RAS,
		A08_001_C AS COD_FORN,
		A08_003_C AS FORNECEDOR,
		U10_001_C AS INVOICE,
		U10_004_D AS EMISSAO,
		WE97_001_C AS NBS,
		SUM(U11_995_B) AS TOTAL_NBS
	FROM STARWESTCON.DBO.U10 (NOLOCK)
	INNER JOIN STARWESTCON.DBO.U11 (NOLOCK) ON U11.U10_UKEY = U10.UKEY
	INNER JOIN STARWESTCON.DBO.D04 (NOLOCK) ON U11.D04_UKEY = D04.UKEY
	INNER JOIN STARWESTCON.DBO.WE97 (NOLOCK) ON D04.WE97_UKEY = WE97.UKEY
	INNER JOIN STARWESTCON.DBO.A08 (NOLOCK) ON U10.U10_UKEYP = A08.UKEY
	INNER JOIN STARWESTCON.DBO.WE98 (NOLOCK) ON WE98.WE98_UKEYP = U11.UKEY AND WE98.WE98_002_N = 7
	WHERE (@PLC_RAS = '' OR WE98_005_C = @PLC_RAS) AND (@PLC_INVOICE = '' OR U10_001_C = @PLC_INVOICE)
	GROUP BY WE97_001_C, WE98_005_C, U10_001_C, WE98_004_D, A08_001_C, A08_003_C, U10_004_D
	 
END