USE [Westcon]
GO

/****** Object:  StoredProcedure [Starsoft].[Reports_PO_invoice_importacao]    Script Date: 29/03/2016 10:02:08 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


/*=============================================
Alterado por: Peterson Ricardo em : 15-04-2015
Inserido campo U11.ukey as U11_UKEY REF. chamado service now: INC0216932

Alterado por: Marcelo Ayabe em : 08-12-2015
Incluído os parâmetros @ERP, @Divisao (Alteração na verificação dos IFs)
Atividade ERP Latam Rollout - ROLLOUT-1
=============================================*/

ALTER PROCEDURE [Starsoft].[Reports_PO_invoice_importacao]

--EXEC [Starsoft].[Reports_PO_invoice_importacao] 1,24, '20160301','20160328','0','0','0','0'

-- Add the parameters for the stored procedure here
(
	@ERP						int,				-- CodERP vindo da Intranet de: Select * from Westcon.dbo.TblERP
	@Divisao					int,				-- Codigo da divisão do grupo westcon CodDivisao de: select * from Westcon.dbo.tbldivisao
	@PLD_EMISSAOINICIAL			DATE = null ,
	@PLD_EMISSAOFINAL			DATE = null,
	@PLC_CODFORNECEDOR			VARCHAR(20),
	@PLC_CODFABRICANTE			VARCHAR(20),
	@PLC_NUMINVOICE				VARCHAR(20),
	@PLC_NUMPO					VARCHAR(20),
	@PLD_ENTRADAINICIAL			DATE = null,
	@PLD_ENTRADAFINAL			DATE = null
)

AS

-- SET NOCOUNT ON added to prevent extra result sets from
-- interfering with SELECT statements.
SET NOCOUNT ON;

-- PRION - 24/11/2015
Declare @CIA_UKEY as varchar(20) 
-- Setando a CIA_UKEY ----------------------------------------------------------------------
SELECT @CIA_UKEY = CIA_UKEY FROM [intranet].[CiaUkey] (@ERP,@Divisao)
-----------------------------------------------------------------------------------------------

BEGIN
	/**************************************BRASIL*****************************************/
	IF @ERP = 1 
	BEGIN
	
		SELECT	
				  U10.U10_004_D AS INVOICEDATE
				, RTRIM(U10.U10_001_C) AS INVOICENUMBER
				, RTRIM(D04.D04_001_C) AS INVOICEPARTNUMBER
				, RTRIM(D03.D03_001_C) + ' - ' + RTRIM(D03.D03_002_C) AS INVOICEVENDOR
				, RTRIM(A08.A08_001_C) + ' - ' + RTRIM(A08.A08_002_C) AS INVOICESUPLIER
				, U11.U11_005_B AS INVOICEQTY	
				, U11.U11_006_B AS INVOICEUNITPRICE
				, U11.U11_012_B AS INVOICETOTAL
				, RTRIM(U05.U05_001_C) AS PONUMBER
				, RTRIM(D04T.D04_001_C) AS POPARTNUMBER
				, U11.U11_005_B AS POQTY	
				, TMP.PO_UNITATIO AS POUNITPRICE
				, U06.U06_012_B AS POTOTAL
				, case  
					when D04T.D04_001_C IS NULL			then 'Partnumber não encontrado na PO'  		
					when U06.U06_005_B > (select isnull(sum(U11T.U11_005_B),0) from STARWESTCON.DBO.U11	U11T (nolock) where U11T.U11_UKEYP = U06.UKEY) then 'Quantidade de itens da invoice é menor que a PO'  
					--when U06.U06_005_B < U11.U11_005_B	then 'Quantidade de itens da invoice é maior que a PO'  
					--when U11.U11_006_B < U06.U06_006_B	AND U11.U11_012_B <> U06.U06_012_B then 'Preço unitario da invoice é menor que o da PO' 
					when U11.U11_006_B > TMP.PO_UNITATIO	AND U11.U11_012_B <> U06.U06_012_B then 'Preço unitario da invoice é maior que o da PO' 			
					when U11.U11_006_B <> TMP.PO_UNITATIO AND U11.U11_012_B = U06.U06_012_B then 'O Valor unitario da invoice é menor que o da PO, mas o total final está correto.' 			
					ELSE
					''
				end	as status
				, T05.T05_002_C AS PRODUTO,
				U10.U10_009_M  AS OBSERVACAO,
				U10.U10_008_D AS ENTRADA,
				(SELECT USR_001_C FROM STARWESTCON.DBO.USR (NOLOCK) WHERE UKEY=SUBSTRING(U10.UKEY,9,5)) AS USUARIO,
				A22_001_C AS PAIS ,
				isnull(E10_001_C,'') AS Numero_da_nota,
				E10_003_D AS Data_da_entrada,
				isnull(A08_E10.A08_003_C,'') AS Nome_Fornecedor, 
				isnull(E11_003_B,0) AS Quantidade,
				isnull(E11_008_B,0) AS Valor_Liquido, 
				isnull(E11_006_B,0) AS Valor_total,
				CASE 
					WHEN WE16_001_N IS NULL THEN ''
					WHEN WE16_001_N = 1 THEN 'Em Analise' 
					WHEN WE16_001_N = 2 THEN 'Resolvido'
				END AS STATUS_CREDT, 
				WE16_006_D AS DATA_CRED_MEMO,
				ISNULL(WE16_005_C,'') AS NUMERO_CREDT_MEMO,
				ISNULL(WE16_004_N,0)  AS VALOR_CREDT_MEMO,
				ISNULL(WE16_003_M,'') AS COMENTARIO_CREDT_MEMO,
				ISNULL((SELECT USR_001_C FROM STARWESTCON.DBO.USR (NOLOCK) WHERE UKEY=SUBSTRING(WE16.USR_UKEY,9,5)),'') AS USUARIO_CREDT_MEMO,
				WE16_001_N,
				U11.UKEY as U11_UKEY,
				ISNULL(GRP.GRUPO,'') AS TIPO_PN,
				ISNULL(WE97.WE97_001_C,'') AS COD_NBS,
				CASE WHEN ISNULL(E10.E10_001_C,'') = '' THEN D07A.D07_001_C ELSE D07.D07_001_C END AS LOCAL
				FROM STARWESTCON.DBO.U10 (NOLOCK)
				INNER JOIN STARWESTCON.DBO.U11		 (NOLOCK) ON U11.U10_UKEY =U10.UKEY
				LEFT  JOIN STARWESTCON.DBO.WE16		 (NOLOCK) ON WE16.U10_UKEY =U10.UKEY  
				LEFT  JOIN STARWESTCON.DBO.A22		 (NOLOCK) ON U10.A22_UKEY =A22.UKEY  
				LEFT  JOIN STARWESTCON.DBO.U06		 (NOLOCK) ON U11_UKEYP=U06.UKEY AND U11_PAR='U06'
				LEFT  JOIN STARWESTCON.DBO.U05		 (NOLOCK) ON U06.U05_UKEY=U05.UKEY	
				INNER JOIN STARWESTCON.DBO.A08		 (NOLOCK) ON U10.U10_UKEYP = A08.UKEY AND U10.U10_PAR='A08'
				LEFT  JOIN STARWESTCON.DBO.D04 D04T	 (NOLOCK) ON U06.D04_UKEY = D04T.UKEY		
				INNER JOIN STARWESTCON.DBO.D04       (NOLOCK) ON U11.D04_UKEY = D04.UKEY	
				LEFT JOIN WESTCON.DBO.tblParte1 GRP	 (NOLOCK) ON D04.D04_001_C = GRP.CODPARTE
				LEFT JOIN STARWESTCON.DBO.WE97		 (NOLOCK) ON D04.WE97_UKEY = WE97.UKEY
				LEFT  JOIN STARWESTCON.DBO.D03		 (NOLOCK) ON D04.D03_UKEY = D03.UKEY 
				INNER JOIN STARWESTCON.DBO.T05       (NOLOCK) ON D04.T05_UKEY = T05.UKEY
				LEFT  JOIN STARWESTCON.DBO.E11       (NOLOCK) ON E11.E11_UKEYP = U11.UKEY AND E11_PAR='U11'
				LEFT JOIN STARWESTCON.DBO.E10        (NOLOCK) ON E11.E10_UKEY = E10.UKEY 
				LEFT JOIN STARWESTCON.DBO.D14		 (NOLOCK) ON D14.D14_IUKEYP = E11.UKEY
				LEFT JOIN STARWESTCON.DBO.D07		 (NOLOCK) ON D14.D07_UKEY = D07.UKEY
				LEFT JOIN STARWESTCON.DBO.D07 D07A   (NOLOCK) ON U11.D07_UKEY = D07A.UKEY
				LEFT JOIN STARWESTCON.DBO.A08 A08_E10 (NOLOCK) ON E10.E10_UKEYP = A08_E10.UKEY AND E10.E10_PAR='A08'
				INNER JOIN (SELECT
								 CASE WHEN U06_016_B > 0 
								 THEN 
									(U06T.U06_016_B/U06T.U06_005_B)+ U06T.U06_006_B   
								 ELSE 
									U06T.U06_006_B
								 END AS PO_UNITATIO, 
								 UKEY 
							FROM STARWESTCON.DBO.U06 U06T
							 )TMP ON TMP.UKEY=U06.UKEY  
			WHERE U06.D04_UKEY = U11.D04_UKEY 
			and (@PLC_CODFORNECEDOR='0' or A08.A08_002_C = @PLC_CODFORNECEDOR)
			and (@PLC_CODFABRICANTE='0' or D03.D03_002_C = @PLC_CODFABRICANTE)   
			and (@PLC_NUMINVOICE='0' OR ltrim(rtrim(U10.U10_001_C)) = ltrim(rtrim(@PLC_NUMINVOICE)))
			and (@PLC_NUMPO='0' OR ltrim(rtrim(U05.U05_001_C)) = ltrim(rtrim(@PLC_NUMPO)))
			and (
					 (@PLD_ENTRADAINICIAL is NOT NULL AND @PLD_ENTRADAFINAL IS NOT NULL AND @PLD_EMISSAOINICIAL IS NOT NULL AND @PLD_EMISSAOFINAL IS NOT NULL
					 AND (U10.U10_004_D BETWEEN @PLD_EMISSAOINICIAL AND @PLD_EMISSAOFINAL) AND (U10.U10_062_D BETWEEN @PLD_ENTRADAINICIAL AND @PLD_ENTRADAFINAL))
					 OR
					 (@PLD_ENTRADAINICIAL is NOT NULL AND @PLD_ENTRADAFINAL is NOT NULL AND @PLD_EMISSAOINICIAL IS NOT NULL AND @PLD_EMISSAOFINAL IS NULL
					 AND (U10.U10_004_D >= @PLD_EMISSAOINICIAL) AND (U10.U10_062_D BETWEEN @PLD_ENTRADAINICIAL AND @PLD_ENTRADAFINAL))
					 OR
					 (@PLD_ENTRADAINICIAL is NOT NULL AND @PLD_ENTRADAFINAL is NOT NULL AND @PLD_EMISSAOINICIAL IS NULL AND @PLD_EMISSAOFINAL IS NOT NULL
					 AND (U10.U10_004_D <= @PLD_EMISSAOFINAL) AND (U10.U10_062_D BETWEEN @PLD_ENTRADAINICIAL AND @PLD_ENTRADAFINAL))
					 OR 
					 (@PLD_ENTRADAINICIAL is NOT NULL AND @PLD_ENTRADAFINAL is not NULL AND @PLD_EMISSAOINICIAL IS NULL AND @PLD_EMISSAOFINAL IS NULL
					 AND (U10.U10_062_D BETWEEN @PLD_ENTRADAINICIAL AND @PLD_ENTRADAFINAL))
					 OR
					 (@PLD_ENTRADAINICIAL is NOT NULL AND @PLD_ENTRADAFINAL is NULL AND @PLD_EMISSAOINICIAL IS NOT NULL AND @PLD_EMISSAOFINAL IS NOT NULL
					 AND (U10.U10_004_D BETWEEN @PLD_EMISSAOINICIAL AND @PLD_EMISSAOFINAL) AND (U10.U10_062_D >= @PLD_ENTRADAINICIAL))
					 OR
					 (@PLD_ENTRADAINICIAL is NOT NULL AND @PLD_ENTRADAFINAL is NULL AND @PLD_EMISSAOINICIAL IS NOT NULL AND @PLD_EMISSAOFINAL IS NULL
					 AND (U10.U10_004_D >= @PLD_EMISSAOINICIAL) AND (U10.U10_062_D >= @PLD_ENTRADAINICIAL))
					 OR
					 (@PLD_ENTRADAINICIAL is NOT NULL AND @PLD_ENTRADAFINAL is NULL AND @PLD_EMISSAOINICIAL IS NULL AND @PLD_EMISSAOFINAL IS NOT NULL
					 AND (U10.U10_004_D <= @PLD_EMISSAOFINAL) AND (U10.U10_062_D >= @PLD_ENTRADAINICIAL))
					 OR
					 (@PLD_ENTRADAINICIAL is NOT NULL AND @PLD_ENTRADAFINAL is NULL AND @PLD_EMISSAOINICIAL IS NULL AND @PLD_EMISSAOFINAL IS NULL
					 AND (U10.U10_062_D >= @PLD_ENTRADAINICIAL))
					 OR
					 (@PLD_ENTRADAINICIAL is NULL AND @PLD_ENTRADAFINAL is NOT NULL AND @PLD_EMISSAOINICIAL IS NOT NULL AND @PLD_EMISSAOFINAL IS NOT NULL
					 AND (U10.U10_004_D BETWEEN @PLD_EMISSAOINICIAL AND @PLD_EMISSAOFINAL) AND (U10.U10_062_D <= @PLD_ENTRADAFINAL))
					 OR
					 (@PLD_ENTRADAINICIAL is NULL AND @PLD_ENTRADAFINAL is NOT NULL AND @PLD_EMISSAOINICIAL IS NOT NULL AND @PLD_EMISSAOFINAL IS NULL
					 AND (U10.U10_004_D >= @PLD_EMISSAOINICIAL) AND (U10.U10_062_D <= @PLD_ENTRADAFINAL))
					 OR
					 (@PLD_ENTRADAINICIAL is NULL AND @PLD_ENTRADAFINAL is NOT NULL AND @PLD_EMISSAOINICIAL IS NULL AND @PLD_EMISSAOFINAL IS NOT NULL
					 AND (U10.U10_004_D <= @PLD_EMISSAOFINAL) AND (U10.U10_062_D <= @PLD_ENTRADAFINAL))
					 OR
					 (@PLD_ENTRADAINICIAL is NULL AND @PLD_ENTRADAFINAL is NOT NULL AND @PLD_EMISSAOINICIAL IS NULL AND @PLD_EMISSAOFINAL IS NULL
					 AND (U10.U10_062_D <= @PLD_ENTRADAFINAL))
					 OR
					 (@PLD_ENTRADAINICIAL is NULL AND @PLD_ENTRADAFINAL is NULL AND @PLD_EMISSAOINICIAL IS NOT NULL AND @PLD_EMISSAOFINAL IS NOT NULL
					 AND (U10.U10_004_D BETWEEN @PLD_EMISSAOINICIAL AND @PLD_EMISSAOFINAL))
					 OR
					 (@PLD_ENTRADAINICIAL is NULL AND @PLD_ENTRADAFINAL is NULL AND @PLD_EMISSAOINICIAL IS NOT NULL AND @PLD_EMISSAOFINAL IS NULL
					 AND (U10.U10_004_D >= @PLD_EMISSAOINICIAL))
					 OR
					 (@PLD_ENTRADAINICIAL is NULL AND @PLD_ENTRADAFINAL is NULL AND @PLD_EMISSAOINICIAL IS NULL AND @PLD_EMISSAOFINAL IS NOT NULL
					 AND (U10.U10_004_D <= @PLD_EMISSAOFINAL))
					 OR
					 (@PLD_ENTRADAINICIAL is NULL AND @PLD_ENTRADAFINAL is NULL AND @PLD_EMISSAOINICIAL IS NULL AND @PLD_EMISSAOFINAL IS NULL)
				)
	END

	/**************************************CALA*****************************************/
	ELSE IF @ERP = 2
	BEGIN
		SELECT	
				  U10.U10_004_D AS INVOICEDATE
				, RTRIM(U10.U10_001_C) AS INVOICENUMBER
				, RTRIM(D04.D04_001_C) AS INVOICEPARTNUMBER
				, RTRIM(D03.D03_001_C) + ' - ' + RTRIM(D03.D03_002_C) AS INVOICEVENDOR
				, RTRIM(A08.A08_001_C) + ' - ' + RTRIM(A08.A08_002_C) AS INVOICESUPLIER
				, U11.U11_005_B AS INVOICEQTY	
				, U11.U11_006_B AS INVOICEUNITPRICE
				, U11.U11_012_B AS INVOICETOTAL
				, RTRIM(U05.U05_001_C) AS PONUMBER
				, RTRIM(D04T.D04_001_C) AS POPARTNUMBER
				, U11.U11_005_B AS POQTY	
				, TMP.PO_UNITATIO AS POUNITPRICE
				, U06.U06_012_B AS POTOTAL
				, case  
					when D04T.D04_001_C IS NULL			then 'Partnumber não encontrado na PO'  		
					when U06.U06_005_B > (select isnull(sum(U11T.U11_005_B),0) from StarWestconCALA2.dbo.U11	U11T (nolock) where U11T.U11_UKEYP = U06.UKEY) then 'Quantidade de itens da invoice é menor que a PO'  
					--when U06.U06_005_B < U11.U11_005_B	then 'Quantidade de itens da invoice é maior que a PO'  
					--when U11.U11_006_B < U06.U06_006_B	AND U11.U11_012_B <> U06.U06_012_B then 'Preço unitario da invoice é menor que o da PO' 
					when U11.U11_006_B > TMP.PO_UNITATIO	AND U11.U11_012_B <> U06.U06_012_B then 'Preço unitario da invoice é maior que o da PO' 			
					when U11.U11_006_B <> TMP.PO_UNITATIO AND U11.U11_012_B = U06.U06_012_B then 'O Valor unitario da invoice é menor que o da PO, mas o total final está correto.' 			
					ELSE
					''
				end	as status
				, T05.T05_002_C AS PRODUTO,
				U10.U10_009_M  AS OBSERVACAO,
				U10.U10_008_D AS ENTRADA,
				(SELECT USR_001_C FROM StarWestconCALA2.dbo.USR (NOLOCK) WHERE UKEY=SUBSTRING(U10.UKEY,9,5)) AS USUARIO,
				A22_001_C AS PAIS ,
				isnull(E10_001_C,'') AS Numero_da_nota,
				E10_003_D AS Data_da_entrada,
				isnull(A08_E10.A08_003_C,'') AS Nome_Fornecedor, 
				isnull(E11_003_B,0) AS Quantidade,
				isnull(E11_008_B,0) AS Valor_Liquido, 
				isnull(E11_006_B,0) AS Valor_total,
				'' AS STATUS_CREDT, 
				NULL AS DATA_CRED_MEMO,
				'' AS NUMERO_CREDT_MEMO,
				0  AS VALOR_CREDT_MEMO,
				'' AS COMENTARIO_CREDT_MEMO,
				'' AS USUARIO_CREDT_MEMO,
				0  AS WE16_001_N,
				U11.UKEY as U11_UKEY
				FROM StarWestconCALA2.dbo.U10 (NOLOCK)
				INNER JOIN StarWestconCALA2.dbo.U11		 (NOLOCK) ON U11.U10_UKEY =U10.UKEY AND U11.CIA_UKEY = @CIA_UKEY
				--LEFT  JOIN StarWestconCALA2.dbo.WE16	 (NOLOCK) ON WE16.U10_UKEY =U10.UKEY  
				LEFT  JOIN StarWestconCALA2.dbo.A22		 (NOLOCK) ON U10.A22_UKEY =A22.UKEY  
				LEFT  JOIN StarWestconCALA2.dbo.U06		 (NOLOCK) ON U11_UKEYP=U06.UKEY AND U11_PAR='U06' AND U06.CIA_UKEY = @CIA_UKEY
				LEFT  JOIN StarWestconCALA2.dbo.U05		 (NOLOCK) ON U06.U05_UKEY=U05.UKEY AND U05.CIA_UKEY = @CIA_UKEY	
				INNER JOIN StarWestconCALA2.dbo.A08		 (NOLOCK) ON U10.U10_UKEYP = A08.UKEY AND U10.U10_PAR='A08'  AND A08.CIA_UKEY = @CIA_UKEY		
				LEFT  JOIN StarWestconCALA2.dbo.D04 D04T (NOLOCK) ON U06.D04_UKEY = D04T.UKEY AND D04T.CIA_UKEY = @CIA_UKEY		
				INNER JOIN StarWestconCALA2.dbo.D04      (NOLOCK) ON U11.D04_UKEY = D04.UKEY AND D04.CIA_UKEY = @CIA_UKEY				
				LEFT  JOIN StarWestconCALA2.dbo.D03		 (NOLOCK) ON D04.D03_UKEY = D03.UKEY 
				INNER JOIN StarWestconCALA2.dbo.T05      (NOLOCK) ON D04.T05_UKEY = T05.UKEY
				LEFT  JOIN StarWestconCALA2.dbo.E11      (NOLOCK) ON E11.E11_UKEYP = U11.UKEY AND E11_PAR='U11' AND E11.CIA_UKEY = @CIA_UKEY		
				LEFT JOIN StarWestconCALA2.dbo.E10       (NOLOCK) ON E11.E10_UKEY = E10.UKEY  AND E10.CIA_UKEY = @CIA_UKEY		
				LEFT JOIN StarWestconCALA2.dbo.A08 A08_E10 (NOLOCK) ON E10.E10_UKEYP = A08_E10.UKEY AND E10.E10_PAR='A08'
				INNER JOIN (SELECT
								 CASE WHEN U06_016_B > 0 
								 THEN 
									(U06T.U06_016_B/U06T.U06_005_B)+ U06T.U06_006_B   
								 ELSE 
									U06T.U06_006_B
								 END AS PO_UNITATIO, 
								 UKEY 
							FROM StarWestconCALA2.dbo.U06 U06T
							 )TMP ON TMP.UKEY=U06.UKEY  
			WHERE U06.D04_UKEY = U11.D04_UKEY AND U10.CIA_UKEY = @CIA_UKEY
			and (@PLC_CODFORNECEDOR='0' or A08.A08_002_C = @PLC_CODFORNECEDOR)
			and (@PLC_CODFABRICANTE='0' or D03.D03_002_C = @PLC_CODFABRICANTE)   
			and (@PLC_NUMINVOICE='0' OR ltrim(rtrim(U10.U10_001_C)) = ltrim(rtrim(@PLC_NUMINVOICE)))
			and (@PLC_NUMPO='0' OR ltrim(rtrim(U05.U05_001_C)) = ltrim(rtrim(@PLC_NUMPO)))
			and (
					 (@PLD_ENTRADAINICIAL is NOT NULL AND @PLD_ENTRADAFINAL IS NOT NULL AND @PLD_EMISSAOINICIAL IS NOT NULL AND @PLD_EMISSAOFINAL IS NOT NULL
					 AND (U10.U10_004_D BETWEEN @PLD_EMISSAOINICIAL AND @PLD_EMISSAOFINAL) AND (U10.U10_062_D BETWEEN @PLD_ENTRADAINICIAL AND @PLD_ENTRADAFINAL))
					 OR
					 (@PLD_ENTRADAINICIAL is NOT NULL AND @PLD_ENTRADAFINAL is NOT NULL AND @PLD_EMISSAOINICIAL IS NOT NULL AND @PLD_EMISSAOFINAL IS NULL
					 AND (U10.U10_004_D >= @PLD_EMISSAOINICIAL) AND (U10.U10_062_D BETWEEN @PLD_ENTRADAINICIAL AND @PLD_ENTRADAFINAL))
					 OR
					 (@PLD_ENTRADAINICIAL is NOT NULL AND @PLD_ENTRADAFINAL is NOT NULL AND @PLD_EMISSAOINICIAL IS NULL AND @PLD_EMISSAOFINAL IS NOT NULL
					 AND (U10.U10_004_D <= @PLD_EMISSAOFINAL) AND (U10.U10_062_D BETWEEN @PLD_ENTRADAINICIAL AND @PLD_ENTRADAFINAL))
					 OR 
					 (@PLD_ENTRADAINICIAL is NOT NULL AND @PLD_ENTRADAFINAL is not NULL AND @PLD_EMISSAOINICIAL IS NULL AND @PLD_EMISSAOFINAL IS NULL
					 AND (U10.U10_062_D BETWEEN @PLD_ENTRADAINICIAL AND @PLD_ENTRADAFINAL))
					 OR
					 (@PLD_ENTRADAINICIAL is NOT NULL AND @PLD_ENTRADAFINAL is NULL AND @PLD_EMISSAOINICIAL IS NOT NULL AND @PLD_EMISSAOFINAL IS NOT NULL
					 AND (U10.U10_004_D BETWEEN @PLD_EMISSAOINICIAL AND @PLD_EMISSAOFINAL) AND (U10.U10_062_D >= @PLD_ENTRADAINICIAL))
					 OR
					 (@PLD_ENTRADAINICIAL is NOT NULL AND @PLD_ENTRADAFINAL is NULL AND @PLD_EMISSAOINICIAL IS NOT NULL AND @PLD_EMISSAOFINAL IS NULL
					 AND (U10.U10_004_D >= @PLD_EMISSAOINICIAL) AND (U10.U10_062_D >= @PLD_ENTRADAINICIAL))
					 OR
					 (@PLD_ENTRADAINICIAL is NOT NULL AND @PLD_ENTRADAFINAL is NULL AND @PLD_EMISSAOINICIAL IS NULL AND @PLD_EMISSAOFINAL IS NOT NULL
					 AND (U10.U10_004_D <= @PLD_EMISSAOFINAL) AND (U10.U10_062_D >= @PLD_ENTRADAINICIAL))
					 OR
					 (@PLD_ENTRADAINICIAL is NOT NULL AND @PLD_ENTRADAFINAL is NULL AND @PLD_EMISSAOINICIAL IS NULL AND @PLD_EMISSAOFINAL IS NULL
					 AND (U10.U10_062_D >= @PLD_ENTRADAINICIAL))
					 OR
					 (@PLD_ENTRADAINICIAL is NULL AND @PLD_ENTRADAFINAL is NOT NULL AND @PLD_EMISSAOINICIAL IS NOT NULL AND @PLD_EMISSAOFINAL IS NOT NULL
					 AND (U10.U10_004_D BETWEEN @PLD_EMISSAOINICIAL AND @PLD_EMISSAOFINAL) AND (U10.U10_062_D <= @PLD_ENTRADAFINAL))
					 OR
					 (@PLD_ENTRADAINICIAL is NULL AND @PLD_ENTRADAFINAL is NOT NULL AND @PLD_EMISSAOINICIAL IS NOT NULL AND @PLD_EMISSAOFINAL IS NULL
					 AND (U10.U10_004_D >= @PLD_EMISSAOINICIAL) AND (U10.U10_062_D <= @PLD_ENTRADAFINAL))
					 OR
					 (@PLD_ENTRADAINICIAL is NULL AND @PLD_ENTRADAFINAL is NOT NULL AND @PLD_EMISSAOINICIAL IS NULL AND @PLD_EMISSAOFINAL IS NOT NULL
					 AND (U10.U10_004_D <= @PLD_EMISSAOFINAL) AND (U10.U10_062_D <= @PLD_ENTRADAFINAL))
					 OR
					 (@PLD_ENTRADAINICIAL is NULL AND @PLD_ENTRADAFINAL is NOT NULL AND @PLD_EMISSAOINICIAL IS NULL AND @PLD_EMISSAOFINAL IS NULL
					 AND (U10.U10_062_D <= @PLD_ENTRADAFINAL))
					 OR
					 (@PLD_ENTRADAINICIAL is NULL AND @PLD_ENTRADAFINAL is NULL AND @PLD_EMISSAOINICIAL IS NOT NULL AND @PLD_EMISSAOFINAL IS NOT NULL
					 AND (U10.U10_004_D BETWEEN @PLD_EMISSAOINICIAL AND @PLD_EMISSAOFINAL))
					 OR
					 (@PLD_ENTRADAINICIAL is NULL AND @PLD_ENTRADAFINAL is NULL AND @PLD_EMISSAOINICIAL IS NOT NULL AND @PLD_EMISSAOFINAL IS NULL
					 AND (U10.U10_004_D >= @PLD_EMISSAOINICIAL))
					 OR
					 (@PLD_ENTRADAINICIAL is NULL AND @PLD_ENTRADAFINAL is NULL AND @PLD_EMISSAOINICIAL IS NULL AND @PLD_EMISSAOFINAL IS NOT NULL
					 AND (U10.U10_004_D <= @PLD_EMISSAOFINAL))
					 OR
					 (@PLD_ENTRADAINICIAL is NULL AND @PLD_ENTRADAFINAL is NULL AND @PLD_EMISSAOINICIAL IS NULL AND @PLD_EMISSAOFINAL IS NULL)
				)
	END

	/**************************************MEXICO*****************************************/	
	ELSE IF @ERP = 3
	BEGIN
		SELECT	
				  U10.U10_004_D AS INVOICEDATE
				, RTRIM(U10.U10_001_C) AS INVOICENUMBER
				, RTRIM(D04.D04_001_C) AS INVOICEPARTNUMBER
				, RTRIM(D03.D03_001_C) + ' - ' + RTRIM(D03.D03_002_C) AS INVOICEVENDOR
				, RTRIM(A08.A08_001_C) + ' - ' + RTRIM(A08.A08_002_C) AS INVOICESUPLIER
				, U11.U11_005_B AS INVOICEQTY	
				, U11.U11_006_B AS INVOICEUNITPRICE
				, U11.U11_012_B AS INVOICETOTAL
				, RTRIM(U05.U05_001_C) AS PONUMBER
				, RTRIM(D04T.D04_001_C) AS POPARTNUMBER
				, U11.U11_005_B AS POQTY	
				, TMP.PO_UNITATIO AS POUNITPRICE
				, U06.U06_012_B AS POTOTAL
				, case  
					when D04T.D04_001_C IS NULL			then 'Partnumber não encontrado na PO'  		
					when U06.U06_005_B > (select isnull(sum(U11T.U11_005_B),0) from StarWestconMX.dbo.U11	U11T (nolock) where U11T.U11_UKEYP = U06.UKEY) then 'Quantidade de itens da invoice é menor que a PO'  
					--when U06.U06_005_B < U11.U11_005_B	then 'Quantidade de itens da invoice é maior que a PO'  
					--when U11.U11_006_B < U06.U06_006_B	AND U11.U11_012_B <> U06.U06_012_B then 'Preço unitario da invoice é menor que o da PO' 
					when U11.U11_006_B > TMP.PO_UNITATIO	AND U11.U11_012_B <> U06.U06_012_B then 'Preço unitario da invoice é maior que o da PO' 			
					when U11.U11_006_B <> TMP.PO_UNITATIO AND U11.U11_012_B = U06.U06_012_B then 'O Valor unitario da invoice é menor que o da PO, mas o total final está correto.' 			
					ELSE
					''
				end	as status
				, T05.T05_002_C AS PRODUTO,
				U10.U10_009_M  AS OBSERVACAO,
				U10.U10_008_D AS ENTRADA,
				(SELECT USR_001_C FROM StarWestconMX.dbo.USR (NOLOCK) WHERE UKEY=SUBSTRING(U10.UKEY,9,5)) AS USUARIO,
				A22_001_C AS PAIS ,
				isnull(E10_001_C,'') AS Numero_da_nota,
				E10_003_D AS Data_da_entrada,
				isnull(A08_E10.A08_003_C,'') AS Nome_Fornecedor, 
				isnull(E11_003_B,0) AS Quantidade,
				isnull(E11_008_B,0) AS Valor_Liquido, 
				isnull(E11_006_B,0) AS Valor_total,
				'' AS STATUS_CREDT, 
				NULL AS DATA_CRED_MEMO,
				'' AS NUMERO_CREDT_MEMO,
				0  AS VALOR_CREDT_MEMO,
				'' AS COMENTARIO_CREDT_MEMO,
				'' AS USUARIO_CREDT_MEMO,
				0  AS WE16_001_N,
				U11.UKEY as U11_UKEY
				FROM StarWestconMX.dbo.U10 (NOLOCK)
				INNER JOIN StarWestconMX.dbo.U11		 (NOLOCK) ON U11.U10_UKEY = U10.UKEY
				--LEFT  JOIN StarWestconMX.dbo.WE16		 (NOLOCK) ON WE16.U10_UKEY = U10.UKEY  
				LEFT  JOIN StarWestconMX.dbo.A22		 (NOLOCK) ON U10.A22_UKEY =A22.UKEY  
				LEFT  JOIN StarWestconMX.dbo.U06		 (NOLOCK) ON U11_UKEYP=U06.UKEY AND U11_PAR='U06'
				LEFT  JOIN StarWestconMX.dbo.U05		 (NOLOCK) ON U06.U05_UKEY=U05.UKEY	
				INNER JOIN StarWestconMX.dbo.A08		 (NOLOCK) ON U10.U10_UKEYP = A08.UKEY AND U10.U10_PAR='A08'
				LEFT  JOIN StarWestconMX.dbo.D04 D04T	 (NOLOCK) ON U06.D04_UKEY = D04T.UKEY		
				INNER JOIN StarWestconMX.dbo.D04       (NOLOCK) ON U11.D04_UKEY = D04.UKEY		
				LEFT  JOIN StarWestconMX.dbo.D03		 (NOLOCK) ON D04.D03_UKEY = D03.UKEY 
				INNER JOIN StarWestconMX.dbo.T05       (NOLOCK) ON D04.T05_UKEY = T05.UKEY
				LEFT  JOIN StarWestconMX.dbo.E11       (NOLOCK) ON E11.E11_UKEYP = U11.UKEY AND E11_PAR='U11'
				LEFT JOIN StarWestconMX.dbo.E10        (NOLOCK) ON E11.E10_UKEY = E10.UKEY 
				LEFT JOIN StarWestconMX.dbo.A08 A08_E10 (NOLOCK) ON E10.E10_UKEYP = A08_E10.UKEY AND E10.E10_PAR='A08'
				INNER JOIN (SELECT
								 CASE WHEN U06_016_B > 0 
								 THEN 
									(U06T.U06_016_B/U06T.U06_005_B)+ U06T.U06_006_B   
								 ELSE 
									U06T.U06_006_B
								 END AS PO_UNITATIO, 
								 UKEY 
							FROM StarWestconMX.dbo.U06 U06T
							 )TMP ON TMP.UKEY=U06.UKEY  
			WHERE U06.D04_UKEY = U11.D04_UKEY 
			and (@PLC_CODFORNECEDOR='0' or A08.A08_002_C = @PLC_CODFORNECEDOR)
			and (@PLC_CODFABRICANTE='0' or D03.D03_002_C = @PLC_CODFABRICANTE)   
			and (@PLC_NUMINVOICE='0' OR ltrim(rtrim(U10.U10_001_C)) = ltrim(rtrim(@PLC_NUMINVOICE)))
			and (@PLC_NUMPO='0' OR ltrim(rtrim(U05.U05_001_C)) = ltrim(rtrim(@PLC_NUMPO)))
			and (
					 (@PLD_ENTRADAINICIAL is NOT NULL AND @PLD_ENTRADAFINAL IS NOT NULL AND @PLD_EMISSAOINICIAL IS NOT NULL AND @PLD_EMISSAOFINAL IS NOT NULL
					 AND (U10.U10_004_D BETWEEN @PLD_EMISSAOINICIAL AND @PLD_EMISSAOFINAL) AND (U10.U10_062_D BETWEEN @PLD_ENTRADAINICIAL AND @PLD_ENTRADAFINAL))
					 OR
					 (@PLD_ENTRADAINICIAL is NOT NULL AND @PLD_ENTRADAFINAL is NOT NULL AND @PLD_EMISSAOINICIAL IS NOT NULL AND @PLD_EMISSAOFINAL IS NULL
					 AND (U10.U10_004_D >= @PLD_EMISSAOINICIAL) AND (U10.U10_062_D BETWEEN @PLD_ENTRADAINICIAL AND @PLD_ENTRADAFINAL))
					 OR
					 (@PLD_ENTRADAINICIAL is NOT NULL AND @PLD_ENTRADAFINAL is NOT NULL AND @PLD_EMISSAOINICIAL IS NULL AND @PLD_EMISSAOFINAL IS NOT NULL
					 AND (U10.U10_004_D <= @PLD_EMISSAOFINAL) AND (U10.U10_062_D BETWEEN @PLD_ENTRADAINICIAL AND @PLD_ENTRADAFINAL))
					 OR 
					 (@PLD_ENTRADAINICIAL is NOT NULL AND @PLD_ENTRADAFINAL is not NULL AND @PLD_EMISSAOINICIAL IS NULL AND @PLD_EMISSAOFINAL IS NULL
					 AND (U10.U10_062_D BETWEEN @PLD_ENTRADAINICIAL AND @PLD_ENTRADAFINAL))
					 OR
					 (@PLD_ENTRADAINICIAL is NOT NULL AND @PLD_ENTRADAFINAL is NULL AND @PLD_EMISSAOINICIAL IS NOT NULL AND @PLD_EMISSAOFINAL IS NOT NULL
					 AND (U10.U10_004_D BETWEEN @PLD_EMISSAOINICIAL AND @PLD_EMISSAOFINAL) AND (U10.U10_062_D >= @PLD_ENTRADAINICIAL))
					 OR
					 (@PLD_ENTRADAINICIAL is NOT NULL AND @PLD_ENTRADAFINAL is NULL AND @PLD_EMISSAOINICIAL IS NOT NULL AND @PLD_EMISSAOFINAL IS NULL
					 AND (U10.U10_004_D >= @PLD_EMISSAOINICIAL) AND (U10.U10_062_D >= @PLD_ENTRADAINICIAL))
					 OR
					 (@PLD_ENTRADAINICIAL is NOT NULL AND @PLD_ENTRADAFINAL is NULL AND @PLD_EMISSAOINICIAL IS NULL AND @PLD_EMISSAOFINAL IS NOT NULL
					 AND (U10.U10_004_D <= @PLD_EMISSAOFINAL) AND (U10.U10_062_D >= @PLD_ENTRADAINICIAL))
					 OR
					 (@PLD_ENTRADAINICIAL is NOT NULL AND @PLD_ENTRADAFINAL is NULL AND @PLD_EMISSAOINICIAL IS NULL AND @PLD_EMISSAOFINAL IS NULL
					 AND (U10.U10_062_D >= @PLD_ENTRADAINICIAL))
					 OR
					 (@PLD_ENTRADAINICIAL is NULL AND @PLD_ENTRADAFINAL is NOT NULL AND @PLD_EMISSAOINICIAL IS NOT NULL AND @PLD_EMISSAOFINAL IS NOT NULL
					 AND (U10.U10_004_D BETWEEN @PLD_EMISSAOINICIAL AND @PLD_EMISSAOFINAL) AND (U10.U10_062_D <= @PLD_ENTRADAFINAL))
					 OR
					 (@PLD_ENTRADAINICIAL is NULL AND @PLD_ENTRADAFINAL is NOT NULL AND @PLD_EMISSAOINICIAL IS NOT NULL AND @PLD_EMISSAOFINAL IS NULL
					 AND (U10.U10_004_D >= @PLD_EMISSAOINICIAL) AND (U10.U10_062_D <= @PLD_ENTRADAFINAL))
					 OR
					 (@PLD_ENTRADAINICIAL is NULL AND @PLD_ENTRADAFINAL is NOT NULL AND @PLD_EMISSAOINICIAL IS NULL AND @PLD_EMISSAOFINAL IS NOT NULL
					 AND (U10.U10_004_D <= @PLD_EMISSAOFINAL) AND (U10.U10_062_D <= @PLD_ENTRADAFINAL))
					 OR
					 (@PLD_ENTRADAINICIAL is NULL AND @PLD_ENTRADAFINAL is NOT NULL AND @PLD_EMISSAOINICIAL IS NULL AND @PLD_EMISSAOFINAL IS NULL
					 AND (U10.U10_062_D <= @PLD_ENTRADAFINAL))
					 OR
					 (@PLD_ENTRADAINICIAL is NULL AND @PLD_ENTRADAFINAL is NULL AND @PLD_EMISSAOINICIAL IS NOT NULL AND @PLD_EMISSAOFINAL IS NOT NULL
					 AND (U10.U10_004_D BETWEEN @PLD_EMISSAOINICIAL AND @PLD_EMISSAOFINAL))
					 OR
					 (@PLD_ENTRADAINICIAL is NULL AND @PLD_ENTRADAFINAL is NULL AND @PLD_EMISSAOINICIAL IS NOT NULL AND @PLD_EMISSAOFINAL IS NULL
					 AND (U10.U10_004_D >= @PLD_EMISSAOINICIAL))
					 OR
					 (@PLD_ENTRADAINICIAL is NULL AND @PLD_ENTRADAFINAL is NULL AND @PLD_EMISSAOINICIAL IS NULL AND @PLD_EMISSAOFINAL IS NOT NULL
					 AND (U10.U10_004_D <= @PLD_EMISSAOFINAL))
					 OR
					 (@PLD_ENTRADAINICIAL is NULL AND @PLD_ENTRADAFINAL is NULL AND @PLD_EMISSAOINICIAL IS NULL AND @PLD_EMISSAOFINAL IS NULL)
				)
	END

	/**************************************COLOMBIA*****************************************/	
	ELSE IF @ERP = 4
	BEGIN
		SELECT	
				  U10.U10_004_D AS INVOICEDATE
				, RTRIM(U10.U10_001_C) AS INVOICENUMBER
				, RTRIM(D04.D04_001_C) AS INVOICEPARTNUMBER
				, RTRIM(D03.D03_001_C) + ' - ' + RTRIM(D03.D03_002_C) AS INVOICEVENDOR
				, RTRIM(A08.A08_001_C) + ' - ' + RTRIM(A08.A08_002_C) AS INVOICESUPLIER
				, U11.U11_005_B AS INVOICEQTY	
				, U11.U11_006_B AS INVOICEUNITPRICE
				, U11.U11_012_B AS INVOICETOTAL
				, RTRIM(U05.U05_001_C) AS PONUMBER
				, RTRIM(D04T.D04_001_C) AS POPARTNUMBER
				, U11.U11_005_B AS POQTY	
				, TMP.PO_UNITATIO AS POUNITPRICE
				, U06.U06_012_B AS POTOTAL
				, case  
					when D04T.D04_001_C IS NULL			then 'Partnumber não encontrado na PO'  		
					when U06.U06_005_B > (select isnull(sum(U11T.U11_005_B),0) from StarWestconCALA2.dbo.U11	U11T (nolock) where U11T.U11_UKEYP = U06.UKEY) then 'Quantidade de itens da invoice é menor que a PO'  
					--when U06.U06_005_B < U11.U11_005_B	then 'Quantidade de itens da invoice é maior que a PO'  
					--when U11.U11_006_B < U06.U06_006_B	AND U11.U11_012_B <> U06.U06_012_B then 'Preço unitario da invoice é menor que o da PO' 
					when U11.U11_006_B > TMP.PO_UNITATIO	AND U11.U11_012_B <> U06.U06_012_B then 'Preço unitario da invoice é maior que o da PO' 			
					when U11.U11_006_B <> TMP.PO_UNITATIO AND U11.U11_012_B = U06.U06_012_B then 'O Valor unitario da invoice é menor que o da PO, mas o total final está correto.' 			
					ELSE
					''
				end	as status
				, T05.T05_002_C AS PRODUTO,
				U10.U10_009_M  AS OBSERVACAO,
				U10.U10_008_D AS ENTRADA,
				(SELECT USR_001_C FROM StarWestconCALA2.dbo.USR (NOLOCK) WHERE UKEY=SUBSTRING(U10.UKEY,9,5)) AS USUARIO,
				A22_001_C AS PAIS ,
				isnull(E10_001_C,'') AS Numero_da_nota,
				E10_003_D AS Data_da_entrada,
				isnull(A08_E10.A08_003_C,'') AS Nome_Fornecedor, 
				isnull(E11_003_B,0) AS Quantidade,
				isnull(E11_008_B,0) AS Valor_Liquido, 
				isnull(E11_006_B,0) AS Valor_total,
				'' AS STATUS_CREDT, 
				NULL AS DATA_CRED_MEMO,
				'' AS NUMERO_CREDT_MEMO,
				0  AS VALOR_CREDT_MEMO,
				'' AS COMENTARIO_CREDT_MEMO,
				'' AS USUARIO_CREDT_MEMO,
				0  AS WE16_001_N,
				U11.UKEY as U11_UKEY
				FROM StarWestconCALA2.dbo.U10 (NOLOCK)
				INNER JOIN StarWestconCALA2.dbo.U11			(NOLOCK) ON U11.U10_UKEY = U10.UKEY AND U11.CIA_UKEY = @CIA_UKEY
				--LEFT  JOIN StarWestconCALA2.dbo.WE16		(NOLOCK) ON WE16.U10_UKEY = U10.UKEY   
				LEFT  JOIN StarWestconCALA2.dbo.A22			(NOLOCK) ON U10.A22_UKEY = A22.UKEY  
				LEFT  JOIN StarWestconCALA2.dbo.U06			(NOLOCK) ON U11_UKEYP = U06.UKEY AND U11_PAR='U06' AND U06.CIA_UKEY = @CIA_UKEY
				LEFT  JOIN StarWestconCALA2.dbo.U05			(NOLOCK) ON U06.U05_UKEY=U05.UKEY AND U05.CIA_UKEY = @CIA_UKEY	
				INNER JOIN StarWestconCALA2.dbo.A08			(NOLOCK) ON U10.U10_UKEYP = A08.UKEY AND U10.U10_PAR = 'A08' AND A08.CIA_UKEY IN ('M8530','M8531')
				LEFT  JOIN StarWestconCALA2.dbo.D04 D04T	(NOLOCK) ON U06.D04_UKEY = D04T.UKEY AND D04T.CIA_UKEY IN ('M8530','M8531')		
				INNER JOIN StarWestconCALA2.dbo.D04			(NOLOCK) ON U11.D04_UKEY = D04.UKEY	AND D04.CIA_UKEY IN ('M8530','M8531')	
				LEFT  JOIN StarWestconCALA2.dbo.D03			(NOLOCK) ON D04.D03_UKEY = D03.UKEY AND D03.CIA_UKEY IN ('M8530','M8531')	
				INNER JOIN StarWestconCALA2.dbo.T05			(NOLOCK) ON D04.T05_UKEY = T05.UKEY AND T05.CIA_UKEY IN ('M8530','M8531')	
				LEFT  JOIN StarWestconCALA2.dbo.E11			(NOLOCK) ON E11.E11_UKEYP = U11.UKEY AND E11_PAR='U11' AND E11.CIA_UKEY = @CIA_UKEY
				LEFT JOIN StarWestconCALA2.dbo.E10			(NOLOCK) ON E11.E10_UKEY = E10.UKEY AND E10.CIA_UKEY = @CIA_UKEY
				LEFT JOIN StarWestconCALA2.dbo.A08 A08_E10	(NOLOCK) ON E10.E10_UKEYP = A08_E10.UKEY AND E10.E10_PAR='A08'
				INNER JOIN (SELECT
								 CASE WHEN U06_016_B > 0 
								 THEN 
									(U06T.U06_016_B/U06T.U06_005_B)+ U06T.U06_006_B   
								 ELSE 
									U06T.U06_006_B
								 END AS PO_UNITATIO, 
								 UKEY 
							FROM StarWestconCALA2.dbo.U06 U06T
							 )TMP ON TMP.UKEY=U06.UKEY  
			WHERE U06.D04_UKEY = U11.D04_UKEY AND U10.CIA_UKEY = @CIA_UKEY
			and (@PLC_CODFORNECEDOR='0' or A08.A08_002_C = @PLC_CODFORNECEDOR)
			and (@PLC_CODFABRICANTE='0' or D03.D03_002_C = @PLC_CODFABRICANTE)   
			and (@PLC_NUMINVOICE='0' OR ltrim(rtrim(U10.U10_001_C)) = ltrim(rtrim(@PLC_NUMINVOICE)))
			and (@PLC_NUMPO='0' OR ltrim(rtrim(U05.U05_001_C)) = ltrim(rtrim(@PLC_NUMPO)))
			and (
					 (@PLD_ENTRADAINICIAL is NOT NULL AND @PLD_ENTRADAFINAL IS NOT NULL AND @PLD_EMISSAOINICIAL IS NOT NULL AND @PLD_EMISSAOFINAL IS NOT NULL
					 AND (U10.U10_004_D BETWEEN @PLD_EMISSAOINICIAL AND @PLD_EMISSAOFINAL) AND (U10.U10_062_D BETWEEN @PLD_ENTRADAINICIAL AND @PLD_ENTRADAFINAL))
					 OR
					 (@PLD_ENTRADAINICIAL is NOT NULL AND @PLD_ENTRADAFINAL is NOT NULL AND @PLD_EMISSAOINICIAL IS NOT NULL AND @PLD_EMISSAOFINAL IS NULL
					 AND (U10.U10_004_D >= @PLD_EMISSAOINICIAL) AND (U10.U10_062_D BETWEEN @PLD_ENTRADAINICIAL AND @PLD_ENTRADAFINAL))
					 OR
					 (@PLD_ENTRADAINICIAL is NOT NULL AND @PLD_ENTRADAFINAL is NOT NULL AND @PLD_EMISSAOINICIAL IS NULL AND @PLD_EMISSAOFINAL IS NOT NULL
					 AND (U10.U10_004_D <= @PLD_EMISSAOFINAL) AND (U10.U10_062_D BETWEEN @PLD_ENTRADAINICIAL AND @PLD_ENTRADAFINAL))
					 OR 
					 (@PLD_ENTRADAINICIAL is NOT NULL AND @PLD_ENTRADAFINAL is not NULL AND @PLD_EMISSAOINICIAL IS NULL AND @PLD_EMISSAOFINAL IS NULL
					 AND (U10.U10_062_D BETWEEN @PLD_ENTRADAINICIAL AND @PLD_ENTRADAFINAL))
					 OR
					 (@PLD_ENTRADAINICIAL is NOT NULL AND @PLD_ENTRADAFINAL is NULL AND @PLD_EMISSAOINICIAL IS NOT NULL AND @PLD_EMISSAOFINAL IS NOT NULL
					 AND (U10.U10_004_D BETWEEN @PLD_EMISSAOINICIAL AND @PLD_EMISSAOFINAL) AND (U10.U10_062_D >= @PLD_ENTRADAINICIAL))
					 OR
					 (@PLD_ENTRADAINICIAL is NOT NULL AND @PLD_ENTRADAFINAL is NULL AND @PLD_EMISSAOINICIAL IS NOT NULL AND @PLD_EMISSAOFINAL IS NULL
					 AND (U10.U10_004_D >= @PLD_EMISSAOINICIAL) AND (U10.U10_062_D >= @PLD_ENTRADAINICIAL))
					 OR
					 (@PLD_ENTRADAINICIAL is NOT NULL AND @PLD_ENTRADAFINAL is NULL AND @PLD_EMISSAOINICIAL IS NULL AND @PLD_EMISSAOFINAL IS NOT NULL
					 AND (U10.U10_004_D <= @PLD_EMISSAOFINAL) AND (U10.U10_062_D >= @PLD_ENTRADAINICIAL))
					 OR
					 (@PLD_ENTRADAINICIAL is NOT NULL AND @PLD_ENTRADAFINAL is NULL AND @PLD_EMISSAOINICIAL IS NULL AND @PLD_EMISSAOFINAL IS NULL
					 AND (U10.U10_062_D >= @PLD_ENTRADAINICIAL))
					 OR
					 (@PLD_ENTRADAINICIAL is NULL AND @PLD_ENTRADAFINAL is NOT NULL AND @PLD_EMISSAOINICIAL IS NOT NULL AND @PLD_EMISSAOFINAL IS NOT NULL
					 AND (U10.U10_004_D BETWEEN @PLD_EMISSAOINICIAL AND @PLD_EMISSAOFINAL) AND (U10.U10_062_D <= @PLD_ENTRADAFINAL))
					 OR
					 (@PLD_ENTRADAINICIAL is NULL AND @PLD_ENTRADAFINAL is NOT NULL AND @PLD_EMISSAOINICIAL IS NOT NULL AND @PLD_EMISSAOFINAL IS NULL
					 AND (U10.U10_004_D >= @PLD_EMISSAOINICIAL) AND (U10.U10_062_D <= @PLD_ENTRADAFINAL))
					 OR
					 (@PLD_ENTRADAINICIAL is NULL AND @PLD_ENTRADAFINAL is NOT NULL AND @PLD_EMISSAOINICIAL IS NULL AND @PLD_EMISSAOFINAL IS NOT NULL
					 AND (U10.U10_004_D <= @PLD_EMISSAOFINAL) AND (U10.U10_062_D <= @PLD_ENTRADAFINAL))
					 OR
					 (@PLD_ENTRADAINICIAL is NULL AND @PLD_ENTRADAFINAL is NOT NULL AND @PLD_EMISSAOINICIAL IS NULL AND @PLD_EMISSAOFINAL IS NULL
					 AND (U10.U10_062_D <= @PLD_ENTRADAFINAL))
					 OR
					 (@PLD_ENTRADAINICIAL is NULL AND @PLD_ENTRADAFINAL is NULL AND @PLD_EMISSAOINICIAL IS NOT NULL AND @PLD_EMISSAOFINAL IS NOT NULL
					 AND (U10.U10_004_D BETWEEN @PLD_EMISSAOINICIAL AND @PLD_EMISSAOFINAL))
					 OR
					 (@PLD_ENTRADAINICIAL is NULL AND @PLD_ENTRADAFINAL is NULL AND @PLD_EMISSAOINICIAL IS NOT NULL AND @PLD_EMISSAOFINAL IS NULL
					 AND (U10.U10_004_D >= @PLD_EMISSAOINICIAL))
					 OR
					 (@PLD_ENTRADAINICIAL is NULL AND @PLD_ENTRADAFINAL is NULL AND @PLD_EMISSAOINICIAL IS NULL AND @PLD_EMISSAOFINAL IS NOT NULL
					 AND (U10.U10_004_D <= @PLD_EMISSAOFINAL))
					 OR
					 (@PLD_ENTRADAINICIAL is NULL AND @PLD_ENTRADAFINAL is NULL AND @PLD_EMISSAOINICIAL IS NULL AND @PLD_EMISSAOFINAL IS NULL)
				)
	END
END

GO

