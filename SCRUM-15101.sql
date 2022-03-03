USE [Westcon]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
--exec [Starsoft].[Reports_InvoicePgto]  '22605666','CI159087CI', 2

alter PROCEDURE [Starsoft].[Reports_InvoicePgto] 
@Invoice as varchar(20),
@PO as varchar(20),
@TAXA as decimal(10,4)

as

	SELECT DISTINCT U10_001_C, 
	CAST(U10_004_D AS DATE) AS U10_004_D, 
	U05_001_C, 
	CAST(F14_003_D AS DATE) AS VENCIMENTO, 
	SUBSTRING(MOEDAP,1,5) AS MOEDA, 
	CAST(CASE WHEN SUBSTRING(MOEDAT,1,3) <> 'US$' THEN ISNULL((F14_009_B / TAXA),0) ELSE F14_009_B END AS DECIMAL(10,2)) AS BRUTODOLAR, 
	CAST(CASE WHEN SUBSTRING(MOEDAT,1,3) <> 'US$' THEN ISNULL(((F14_010_B - (F14_021_B + F14_029_B + F14_025_B)) / TAXA),0) 
		ELSE ISNULL((F14_010_B - (F14_021_B + F14_029_B + F14_025_B)),0) END AS DECIMAL(10,2)) AS ABERTODOLAR, 
	CAST(taxa AS DECIMAL(10,4)) AS TAXA,
	CAST(CASE WHEN SUBSTRING(MOEDAT,1,2) <> 'R$' THEN ISNULL((F14_009_B * TAXA),0) ELSE F14_009_B END AS DECIMAL(10,2)) AS BRUTOREAL, 
	CAST(CASE WHEN SUBSTRING(MOEDAT,1,2) <> 'R$' THEN ISNULL(((F14_010_B - (F14_021_B + F14_029_B + F14_025_B)) * TAXA),0) 
		ELSE ISNULL((F14_010_B - (F14_021_B + F14_029_B + F14_025_B)),0) END AS DECIMAL(10,2)) AS ABERTOREAL, 
	CAST(CASE WHEN SUBSTRING(MOEDAT,1,3) <> 'R$' THEN ISNULL(((F14_010_B - (F14_021_B + F14_029_B + F14_025_B)) * TAXA),0) 
		ELSE ISNULL((F14_010_B - (F14_021_B + F14_029_B + F14_025_B)),0) END AS DECIMAL(10,2)) -
	CAST((F14_010_B - (F14_021_B + F14_029_B + F14_025_B)) * @TAXA AS DECIMAL(10,2)) AS VARIACAO, 
	CAST(TOTAL_HARDWARE AS DECIMAL(10,2)) AS TOTAL_HARDWARE, 
	CAST(TOTAL_SOFTWARE AS DECIMAL(10,2)) AS TOTAL_SOFTWARE, 
	CAST(TOTAL_SERVICO AS DECIMAL(10,2)) AS TOTAL_SERVICO, 
	CAST(IRRF AS DECIMAL(10,2)) AS IRRF
	FROM (
	select u10_001_c, U10_004_D, U05_001_C, ISNULL(F14_002_D,F14_003_D) AS F14_003_D, F14.A36_CODE0 AS MOEDAP, F11.A36_CODE0 AS MOEDAT, F14_009_B, F14_010_B, F14_021_B, F14_029_B, F14_025_B, 
		(SELECT A37.A37_002_B
				FROM StarWestcon.dbo.A36 (NOLOCK) 
				INNER JOIN StarWestcon.dbo.A54 (nolock) on A54.A36_UKEY = A36.UKEY
				INNER JOIN StarWestcon.dbo.A37 (nolock) on A37.A36_UKEY = A36.UKEY
				where CASE A54.A54_013_N WHEN 0 THEN F11.F11_002_D ELSE SUBSTRING(CONVERT(CHAR, F11.F11_002_D, 112),1 , 6) + '01' END = A37.A37_001_D and a37.a36_ukey = SUBSTRING(U10.A36_CODEA,1,5) AND A37.A36_UKEYA = SUBSTRING(U10.A36_CODEB,1,5)) AS TAXA,
		CASE WHEN F11_IPAR = 'U10' THEN ISNULL((SELECT SUM(U11_013_B) FROM STARWESTCON.DBO.U11 (NOLOCK) INNER JOIN STARWESTCON.DBO.D04 (NOLOCK) ON U11.D04_UKEY = D04.UKEY INNER JOIN STARWESTCON.DBO.T05 (NOLOCK) ON D04.T05_UKEY = T05.UKEY WHERE T05.ARRAY_051A = 1 AND U11.U10_UKEY = F11.F11_IUKEYP),0)
			ELSE ISNULL((SELECT SUM(E11_021_B) FROM STARWESTCON.DBO.E11 (NOLOCK) INNER JOIN STARWESTCON.DBO.D04 (NOLOCK) ON E11.D04_UKEY = D04.UKEY INNER JOIN STARWESTCON.DBO.T05 (NOLOCK) ON D04.T05_UKEY = T05.UKEY WHERE T05.ARRAY_051A = 1 AND E11.E10_UKEY = F11.F11_IUKEYP),0) END AS 'TOTAL_HARDWARE',
		CASE WHEN F11_IPAR = 'U10' THEN ISNULL((SELECT SUM(U11_013_B) FROM STARWESTCON.DBO.U11 (NOLOCK) INNER JOIN STARWESTCON.DBO.D04 (NOLOCK) ON U11.D04_UKEY = D04.UKEY INNER JOIN STARWESTCON.DBO.T05 (NOLOCK) ON D04.T05_UKEY = T05.UKEY WHERE T05.ARRAY_051A = 5 AND U11.U10_UKEY = F11.F11_IUKEYP),0)
			ELSE ISNULL((SELECT SUM(E11_021_B) FROM STARWESTCON.DBO.E11 (NOLOCK) INNER JOIN STARWESTCON.DBO.D04 (NOLOCK) ON E11.D04_UKEY = D04.UKEY INNER JOIN STARWESTCON.DBO.T05 (NOLOCK) ON D04.T05_UKEY = T05.UKEY WHERE T05.ARRAY_051A = 5 AND E11.E10_UKEY = F11.F11_IUKEYP),0) END AS 'TOTAL_SERVICO',
		CASE WHEN F11_IPAR = 'U10' THEN ISNULL((SELECT SUM(U11_013_B) FROM STARWESTCON.DBO.U11 (NOLOCK) INNER JOIN STARWESTCON.DBO.D04 (NOLOCK) ON U11.D04_UKEY = D04.UKEY INNER JOIN STARWESTCON.DBO.T05 (NOLOCK) ON D04.T05_UKEY = T05.UKEY WHERE T05.ARRAY_051A = 13 AND U11.U10_UKEY = F11.F11_IUKEYP),0)
			ELSE ISNULL((SELECT SUM(E11_021_B) FROM STARWESTCON.DBO.E11 (NOLOCK) INNER JOIN STARWESTCON.DBO.D04 (NOLOCK) ON E11.D04_UKEY = D04.UKEY INNER JOIN STARWESTCON.DBO.T05 (NOLOCK) ON D04.T05_UKEY = T05.UKEY WHERE T05.ARRAY_051A = 13 AND E11.E10_UKEY = F11.F11_IUKEYP),0) END AS 'TOTAL_SOFTWARE',
		IR.VALOR AS 'IRRF'
	FROM STARWESTCON.DBO.U10 (NOLOCK)
	INNER JOIN STARWESTCON.DBO.U11 (NOLOCK) ON U11.U10_UKEY = U10.UKEY
	LEFT JOIN STARWESTCON.DBO.F11 (NOLOCK) ON F11.F11_IUKEYP = U10.UKEY
	LEFT JOIN STARWESTCON.DBO.F14 (NOLOCK) ON F11_UKEY = F11.UKEY
	LEFT JOIN STARWESTCON.DBO.U05 (NOLOCK) ON U10.U05_UKEY = U05.UKEY
	LEFT JOIN STARWESTCON.DBO.E10 (NOLOCK) ON F11.F11_IUKEYP = E10.UKEY
	LEFT JOIN STARWESTCON.DBO.E11 (NOLOCK) ON E11.E10_UKEY = E10.UKEY
	LEFT JOIN (SELECT U08.U08_001_B AS VALOR, 
						U08.U08_UKEYP
				FROM STARWESTCON.DBO.U08 (NOLOCK)
				JOIN STARWESTCON.DBO.T08 (NOLOCK) ON U08.T08_UKEY = T08.UKEY
				WHERE T08_001_C = '_IRIMP'
			)IR ON IR.U08_UKEYP = U10.UKEY
	WHERE (U10_001_C = @Invoice OR U05_001_C = @PO)
	)TMP



 