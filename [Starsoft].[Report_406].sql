USE [Westcon]

GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
--Exec [Starsoft].[Report_XXX] ''
CREATE PROCEDURE [Starsoft].[Report_406]
		@Vendor as varchar(50),
		@DueDateInicio date = null,
		@DueDateFim date = null,
		@EmissionInicio date = null,
		@EmissionFim date = null

--SERVI?OS, HARDWARES E SOFTWARES DO PROCESSO NOVO
AS
	BEGIN
		SELECT INVOICE, DATA, FABRICANTE, REPLACE(REPLACE(REPLACE(EXPORTADOR, '<B U30_004_C=',''),'/>','/'),'"','') AS EXPORTADOR, TOTAL_DOC_US$, TITULO, PARCELA, TOTAL_FIN, MOEDA, 
		REPLACE(REPLACE(REPLACE(DI, '<B U30_001_C=',''), '"',''), '/>','/') DI, TAXA, VL_DOLAR, VL_REAL, ABERTO_REAL, ABERTO_DOLAR, PO, SERVI?O, HARDWARE, SOFTWARE FROM (
			SELECT DISTINCT U10_001_C as INVOICE, 
			CONVERT(VARCHAR(10),U10_004_D, 105) AS DATA,
			A08_003_C FABRICANTE, 
			(SELECT DISTINCT LTRIM(RTRIM(U30_004_C)) U30_004_C FROM STARWESTCON.DBO.U30 (NOLOCK) 
				INNER JOIN STARWESTCON.DBO.E10 (NOLOCK) ON U30.E10_UKEY = E10.UKEY 
				INNER JOIN STARWESTCON.DBO.E11 (NOLOCK) ON E11.E10_UKEY = E10.UKEY 
				INNER JOIN STARWESTCON.DBO.U11 (NOLOCK) ON E11.E11_UKEYP = U11.UKEY
				WHERE U11.U10_UKEY = U10.UKEY FOR XML RAW('B')) EXPORTADOR,
			CAST(U08_001_B AS MONEY) AS TOTAL_DOC_US$,
			F11_001_C TITULO, 
			F14_001_C PARCELA, 
			ISNULL(F14_501_D, F14_003_D) AS DUEDATE,
			CAST(F14_010_B AS MONEY) AS TOTAL_FIN,
			'DOLAR' AS MOEDA,
			(SELECT DISTINCT LTRIM(RTRIM(U30_001_C)) U30_001_C FROM STARWESTCON.DBO.U30 (NOLOCK) 
				INNER JOIN STARWESTCON.DBO.E10 (NOLOCK) ON U30.E10_UKEY = E10.UKEY 
				INNER JOIN STARWESTCON.DBO.E11 (NOLOCK) ON E11.E10_UKEY = E10.UKEY 
				INNER JOIN STARWESTCON.DBO.U11 (NOLOCK) ON E11.E11_UKEYP = U11.UKEY
				WHERE U11.U10_UKEY = U10.UKEY FOR XML RAW('B')) DI,
			CAST(A37TAX.A37_002_B AS MONEY) AS TAXA,
			CAST(F14_010_B AS MONEY) as VL_DOLAR, 
			CAST((F14_010_B * A37TAX.A37_002_B) AS MONEY) as VL_REAL, 
			CAST(((F14.F14_010_B - F14.F14_029_B - F14.F14_025_B - F14.F14_021_B) * A37TAX.A37_002_B) AS MONEY) AS ABERTO_REAL, 
			CAST(((F14.F14_010_B - F14.F14_029_B - F14.F14_025_B - F14.F14_021_B)) AS MONEY) AS ABERTO_DOLAR,
			ISNULL(U05_001_C,'') AS PO, 
			ISNULL((select sum(CAST(u11_012_b AS MONEY)) from STARWESTCON.DBO.u11 (NOLOCK) inner join STARWESTCON.DBO.d04 (NOLOCK) on u11.d04_ukey = d04.ukey and D04.t05_ukey in ('20140514OF79AG17A5EP','STAR_W525U_12C0NBHNT') where u11.u10_ukey = u10.ukey),0) as SERVI?O,
			ISNULL((select sum(CAST(u11_012_b AS MONEY)) from STARWESTCON.DBO.u11 (NOLOCK) inner join STARWESTCON.DBO.d04 (NOLOCK) on u11.d04_ukey = d04.ukey and D04.t05_ukey = 'STAR_W525U_12C0NA4NE' where u11.u10_ukey = u10.ukey),0) AS HARDWARE, 
			ISNULL((select sum(CAST(u11_012_b AS MONEY)) from STARWESTCON.DBO.u11 (NOLOCK) inner join STARWESTCON.DBO.d04 (NOLOCK) on u11.d04_ukey = d04.ukey and D04.t05_ukey = 'STAR_W525U_12C0NC7DV' where u11.u10_ukey = u10.ukey),0) AS SOFTWARE
			FROM STARWESTCON.DBO.U10 (Nolock)
			INNER JOIN STARWESTCON.DBO.A08 (NOLOCK) ON U10.A08_UKEYA = A08.UKEY 
			INNER JOIN STARWESTCON.DBO.A22 (NOLOCK) ON A08.A22_UKEY = A22.UKEY 
			INNER JOIN STARWESTCON.DBO.CIA (NOLOCK)ON U10.CIA_UKEY = CIA.UKEY 
			INNER JOIN STARWESTCON.DBO.U11 (NOLOCK)ON U11.U10_UKEY = U10.UKEY
			LEFT JOIN STARWESTCON.DBO.E11 (NOLOCK) ON E11_UKEYP = U11.UKEY 
			LEFT JOIN STARWESTCON.DBO.E10 (NOLOCK)ON E11.E10_UKEY = E10.UKEY 
			LEFT JOIN STARWESTCON.DBO.F11 (NOLOCK)ON F11_IUKEYP = U10.UKEY 
			LEFT JOIN STARWESTCON.DBO.F14 (NOLOCK)ON F14.F11_UKEY = F11.UKEY 
			INNER JOIN STARWESTCON.DBO.U08 (NOLOCK)ON U08_UKEYP = U10.UKEY AND ARRAY_241 = 1
			LEFT JOIN STARWESTCON.DBO.U30 (NOLOCK)ON U30.E10_UKEY = E10.UKEY 
			LEFT JOIN STARWESTCON.DBO.U06 (NOLOCK)ON U11.U06_ukey = u06.ukey
			LEFT JOIN STARWESTCON.DBO.U05 (NOLOCK)ON U06.u05_ukey = u05.ukey
			INNER JOIN 	(
						SELECT 
						/* PARA TAXA MENSAM (A54.A54_013_N = 1) ? TRATADO PARA DEIXAR O CAMPO A37.A37_001_D COM O DIA 01 */
						CASE A54.A54_013_N WHEN 1 THEN SUBSTRING(CONVERT(CHAR, A37.A37_001_D, 112),1 , 6) + '01' ELSE A37.A37_001_D END AS A37_001_D,
						A37.A37_002_B,
						A37.A36_UKEYA,
						A37.A36_UKEY,
						A54.A54_013_N
						FROM StarWestcon.dbo.A36 (NOLOCK) 
						INNER JOIN StarWestcon.dbo.A54 (nolock) on A54.A36_UKEY = A36.UKEY
						INNER JOIN StarWestcon.dbo.A37 (nolock) on A37.A36_UKEY = A36.UKEY
						) A37TAX ON CASE A37TAX.A54_013_N WHEN 0 THEN U10.U10_004_D ELSE SUBSTRING(CONVERT(CHAR, U10.U10_004_D, 112),1 , 6) + '01' END = A37TAX.A37_001_D
			WHERE a37TAX.a36_ukey = SUBSTRING(u10.A36_CODEA,1,5) AND A37TAX.A36_UKEYA = SUBSTRING(u10.A36_CODEB,1,5) AND
			(@Vendor = '' OR A08_003_C LIKE @Vendor+'%') AND 
			((@DueDateInicio IS NULL OR @DueDateFim IS NULL) OR (ISNULL(F14_501_D, F14_003_D) BETWEEN @DueDateInicio AND @DueDateFim )) AND
			((@EmissionInicio IS NULL OR @EmissionFim IS NULL) OR (U10.U10_004_D BETWEEN @EmissionInicio AND @EmissionFim )) AND
			(F14.F14_010_B - F14.F14_029_B - F14.F14_025_B - F14.F14_021_B) > 0 AND
			F14.F14_015_N != 1
			and (F14.F14_010_B - F14.F14_029_B - F14.F14_025_B - F14.F14_021_B) >0
			AND F14.F14_028_N != 1 
			and F11.F11_016_C = '001'
			AND F11.F11_002_D < DATEADD (DD, 1, '2017-01-31')
			)TMP

		UNION ALL

		--SOFTWARES DO PROCESSO ANTIGO
		SELECT INVOICE, DATA, FABRICANTE, REPLACE(REPLACE(REPLACE(EXPORTADOR, '<B U30_004_C=',''),'/>','/'),'"','') AS EXPORTADOR, TOTAL_DOC_US$, TITULO, PARCELA, TOTAL_FIN, MOEDA, 
		REPLACE(REPLACE(REPLACE(DI, '<B U30_001_C=',''), '"',''), '/>','/') DI, TAXA, VL_DOLAR, VL_REAL, ABERTO_REAL, ABERTO_DOLAR, PO, SERVI?O, HARDWARE, SOFTWARE FROM (
			SELECT DISTINCT E10_001_C as INVOICE, 
			CONVERT(VARCHAR(10),E10_003_D, 105) AS DATA,
			A08_003_C FABRICANTE, 
			(SELECT DISTINCT LTRIM(RTRIM(U30_004_C)) U30_004_C FROM STARWESTCON.DBO.U30 (NOLOCK) WHERE U30.E10_UKEY = E10.UKEY FOR XML RAW('B')) EXPORTADOR,
			ISNULL(CAST((E04_001_B/A37TAX.A37_002_B) AS MONEY),0) AS TOTAL_DOC_US$,
			F11_001_C TITULO, 
			F14_001_C PARCELA, 
			ISNULL(F14_501_D, F14_003_D) AS DUEDATE,
			CAST(F14_010_B AS MONEY) AS TOTAL_FIN,
			'REAL' AS MOEDA,
			(SELECT DISTINCT LTRIM(RTRIM(U30_001_C)) U30_001_C FROM STARWESTCON.DBO.U30 (NOLOCK) WHERE U30.E10_UKEY = E10.UKEY FOR XML RAW('B')) DI,
			ISNULL(CAST(A37TAX.A37_002_B AS MONEY),0) AS TAXA,
			ISNULL(CAST((F14_010_B/A37TAX.A37_002_B) AS MONEY),0) as VL_DOLAR, 
			CAST(F14_010_B AS MONEY) as VL_REAL, 
			CAST(((F14.F14_010_B - F14.F14_029_B - F14.F14_025_B - F14.F14_021_B)) AS MONEY) AS ABERTO_REAL, 
			ISNULL(CAST(((F14.F14_010_B - F14.F14_029_B - F14.F14_025_B - F14.F14_021_B)/A37TAX.A37_002_B) AS MONEY),0) AS ABERTO_DOLAR,
			'' AS PO, 
			ISNULL((select sum(CAST(E11_008_b AS MONEY)) from STARWESTCON.DBO.E11 (NOLOCK) inner join STARWESTCON.DBO.d04 (NOLOCK) on E11.d04_ukey = d04.ukey and D04.t05_ukey in ('20140514OF79AG17A5EP','STAR_W525U_12C0NBHNT') where E11.E10_ukey = E10.ukey),0) as SERVI?O,
			ISNULL((select sum(CAST(E11_008_b AS MONEY)) from STARWESTCON.DBO.E11 (NOLOCK) inner join STARWESTCON.DBO.d04 (NOLOCK) on E11.d04_ukey = d04.ukey and D04.t05_ukey = 'STAR_W525U_12C0NA4NE' where E11.E10_ukey = E10.ukey),0) AS HARDWARE, 
			ISNULL((select sum(CAST(E11_008_b AS MONEY)) from STARWESTCON.DBO.E11 (NOLOCK) inner join STARWESTCON.DBO.d04 (NOLOCK) on E11.d04_ukey = d04.ukey and D04.t05_ukey = 'STAR_W525U_12C0NC7DV' where E11.E10_ukey = E10.ukey),0) AS SOFTWARE
			FROM STARWESTCON.DBO.E10 (NOLOCK)
			INNER JOIN STARWESTCON.DBO.E11 ON E11.E10_UKEY = E10.UKEY
			INNER JOIN STARWESTCON.DBO.A08 (NOLOCK) ON E10.A08_UKEY = A08.UKEY 
			INNER JOIN STARWESTCON.DBO.A22 (NOLOCK) ON A08.A22_UKEY = A22.UKEY 
			INNER JOIN STARWESTCON.DBO.CIA (NOLOCK)ON E10.CIA_UKEY = CIA.UKEY 
			LEFT JOIN STARWESTCON.DBO.F11 (NOLOCK)ON F11_IUKEYP = E10.UKEY 
			LEFT JOIN STARWESTCON.DBO.F14 (NOLOCK)ON F14.F11_UKEY = F11.UKEY 
			INNER JOIN STARWESTCON.DBO.E04 (NOLOCK)ON E04_UKEYP = E10.UKEY AND ARRAY_241 = 1
			LEFT JOIN STARWESTCON.DBO.U30 (NOLOCK)ON U30.E10_UKEY = E10.UKEY 
			INNER JOIN STARWESTCON.DBO.T04 ON E11.T04_UKEY = T04.UKEY 
			INNER JOIN 	(
						SELECT 
						/* PARA TAXA MENSAM (A54.A54_013_N = 1) ? TRATADO PARA DEIXAR O CAMPO A37.A37_001_D COM O DIA 01 */
						CASE A54.A54_013_N WHEN 1 THEN SUBSTRING(CONVERT(CHAR, A37.A37_001_D, 112),1 , 6) + '01' ELSE A37.A37_001_D END AS A37_001_D,
						A37.A37_002_B,
						A37.A36_UKEYA,
						A37.A36_UKEY,
						A54.A54_013_N
						FROM StarWestcon.dbo.A36 (NOLOCK) 
						INNER JOIN StarWestcon.dbo.A54 (nolock) on A54.A36_UKEY = A36.UKEY
						INNER JOIN StarWestcon.dbo.A37 (nolock) on A37.A36_UKEY = A36.UKEY
						) A37TAX ON CASE A37TAX.A54_013_N WHEN 0 THEN E10.E10_003_D ELSE SUBSTRING(CONVERT(CHAR, E10.E10_003_D, 112),1 , 6) + '01' END = A37TAX.A37_001_D
			WHERE a37TAX.a36_ukey = SUBSTRING(E10.A36_CODE,1,5) AND A37TAX.A36_UKEYA = 'US$  ' AND
			(@Vendor = '' OR A08_003_C LIKE @Vendor+'%') AND 
			((@DueDateInicio IS NULL OR @DueDateFim IS NULL) OR (ISNULL(F14_501_D, F14_003_D) BETWEEN @DueDateInicio AND @DueDateFim )) AND
			((@EmissionInicio IS NULL OR @EmissionFim IS NULL) OR (E10.E10_003_D BETWEEN @EmissionInicio AND @EmissionFim )) AND
			F14.F14_015_N != 1
			and (F14.F14_010_B - F14.F14_029_B - F14.F14_025_B - F14.F14_021_B) >0
			AND F14.F14_028_N != 1 
			and F11.F11_016_C = '001'
			AND F11.F11_002_D < '2017-01-09'
			AND A22_001_C <> 'BRASIL' 
			)TMP

		UNION ALL

		--HARDWARES DO PROCESSO ANTIGO
		SELECT INVOICE, DATA, FABRICANTE, REPLACE(REPLACE(REPLACE(EXPORTADOR, '<B U30_004_C=',''),'/>','/'),'"','') AS EXPORTADOR, TOTAL_DOC_US$, TITULO, PARCELA, TOTAL_FIN, MOEDA, 
		REPLACE(REPLACE(REPLACE(DI, '<B U30_001_C=',''), '"',''), '/>','/') DI, TAXA, VL_DOLAR, VL_REAL, ABERTO_REAL, ABERTO_DOLAR, PO, SERVI?O, HARDWARE, SOFTWARE FROM (
			SELECT DISTINCT E10_001_C as INVOICE, 
			CONVERT(VARCHAR(10),E10_003_D, 105) AS DATA,
			A08_003_C FABRICANTE, 
			(SELECT DISTINCT LTRIM(RTRIM(U30_004_C)) U30_004_C FROM STARWESTCON.DBO.U30 (NOLOCK) WHERE U30.E10_UKEY = E10.UKEY FOR XML RAW('B')) EXPORTADOR,
			ISNULL(CAST((E04_001_B/A37TAX.A37_002_B) AS MONEY),0) AS TOTAL_DOC_US$,
			F11_001_C TITULO, 
			F14_001_C PARCELA, 
			ISNULL(F14_501_D, F14_003_D) AS DUEDATE,
			CAST(F14_010_B AS MONEY) AS TOTAL_FIN,
			'REAL' AS MOEDA,
			(SELECT DISTINCT LTRIM(RTRIM(U30_001_C)) U30_001_C FROM STARWESTCON.DBO.U30 (NOLOCK) WHERE U30.E10_UKEY = E10.UKEY FOR XML RAW('B')) DI,
			ISNULL(CAST(A37TAX.A37_002_B AS MONEY),0) AS TAXA,
			ISNULL(CAST((F14_010_B/A37TAX.A37_002_B) AS MONEY),0) as VL_DOLAR, 
			CAST(F14_010_B AS MONEY) as VL_REAL, 
			CAST((F14.F14_010_B - F14.F14_029_B - F14.F14_025_B - F14.F14_021_B) AS MONEY) AS ABERTO_REAL, 
			ISNULL(CAST(((F14.F14_010_B - F14.F14_029_B - F14.F14_025_B - F14.F14_021_B)/A37TAX.A37_002_B) AS MONEY),0) AS ABERTO_DOLAR,
			'' AS PO, 
			ISNULL((select sum(CAST(E11_008_b AS MONEY)) from STARWESTCON.DBO.E11 (NOLOCK) inner join STARWESTCON.DBO.d04 (NOLOCK) on E11.d04_ukey = d04.ukey and D04.t05_ukey in ('20140514OF79AG17A5EP','STAR_W525U_12C0NBHNT') where E11.E10_ukey = E10.ukey),0) as SERVI?O,
			ISNULL((select sum(CAST(E11_008_b AS MONEY)) from STARWESTCON.DBO.E11 (NOLOCK) inner join STARWESTCON.DBO.d04 (NOLOCK) on E11.d04_ukey = d04.ukey and D04.t05_ukey = 'STAR_W525U_12C0NA4NE' where E11.E10_ukey = E10.ukey),0) AS HARDWARE, 
			ISNULL((select sum(CAST(E11_008_b AS MONEY)) from STARWESTCON.DBO.E11 (NOLOCK) inner join STARWESTCON.DBO.d04 (NOLOCK) on E11.d04_ukey = d04.ukey and D04.t05_ukey = 'STAR_W525U_12C0NC7DV' where E11.E10_ukey = E10.ukey),0) AS SOFTWARE
			FROM STARWESTCON.DBO.E10 (NOLOCK)
			INNER JOIN STARWESTCON.DBO.E11 ON E11.E10_UKEY = E10.UKEY
			INNER JOIN STARWESTCON.DBO.A08 (NOLOCK) ON E10.A08_UKEY = A08.UKEY 
			INNER JOIN STARWESTCON.DBO.A22 (NOLOCK) ON A08.A22_UKEY = A22.UKEY 
			INNER JOIN STARWESTCON.DBO.CIA (NOLOCK)ON E10.CIA_UKEY = CIA.UKEY 
			LEFT JOIN STARWESTCON.DBO.F11 (NOLOCK)ON F11_IUKEYP = E10.UKEY 
			LEFT JOIN STARWESTCON.DBO.F14 (NOLOCK)ON F14.F11_UKEY = F11.UKEY 
			INNER JOIN STARWESTCON.DBO.E04 (NOLOCK)ON E04_UKEYP = E10.UKEY AND ARRAY_241 = 1
			LEFT JOIN STARWESTCON.DBO.U30 (NOLOCK)ON U30.E10_UKEY = E10.UKEY 
			INNER JOIN STARWESTCON.DBO.T04 ON E11.T04_UKEY = T04.UKEY 
			INNER JOIN 	(
						SELECT 
						/* PARA TAXA MENSAM (A54.A54_013_N = 1) ? TRATADO PARA DEIXAR O CAMPO A37.A37_001_D COM O DIA 01 */
						CASE A54.A54_013_N WHEN 1 THEN SUBSTRING(CONVERT(CHAR, A37.A37_001_D, 112),1 , 6) + '01' ELSE A37.A37_001_D END AS A37_001_D,
						A37.A37_002_B,
						A37.A36_UKEYA,
						A37.A36_UKEY,
						A54.A54_013_N
						FROM StarWestcon.dbo.A36 (NOLOCK) 
						INNER JOIN StarWestcon.dbo.A54 (nolock) on A54.A36_UKEY = A36.UKEY
						INNER JOIN StarWestcon.dbo.A37 (nolock) on A37.A36_UKEY = A36.UKEY
						) A37TAX ON CASE A37TAX.A54_013_N WHEN 0 THEN E10.E10_003_D ELSE SUBSTRING(CONVERT(CHAR, E10.E10_003_D, 112),1 , 6) + '01' END = A37TAX.A37_001_D
			WHERE a37TAX.a36_ukey = SUBSTRING(E10.A36_CODE,1,5) AND A37TAX.A36_UKEYA = 'US$  ' AND
			(@Vendor = '' OR A08_003_C LIKE @Vendor+'%') AND 
			((@DueDateInicio IS NULL OR @DueDateFim IS NULL) OR (ISNULL(F14_501_D, F14_003_D) BETWEEN @DueDateInicio AND @DueDateFim )) AND
			((@EmissionInicio IS NULL OR @EmissionFim IS NULL) OR (E10.E10_003_D BETWEEN @EmissionInicio AND @EmissionFim )) AND
			(E10.E10_003_D BETWEEN @EmissionInicio AND @EmissionFim ) AND
			F14.F14_015_N != 1
			and (F14.F14_010_B - F14.F14_029_B - F14.F14_025_B - F14.F14_021_B) >0
			AND F14.F14_028_N != 1 
			and F11.F11_016_C = '001'
			AND T04_001_C = 'E01.22ES'
			AND F14_001_C='00003'
			)TMP

		ORDER BY FABRICANTE, DATA
	END