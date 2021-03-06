USE [Westcon]
GO
/****** Object:  StoredProcedure [Starsoft].[Reports_Good_In_Transit]    Script Date: 19/12/2016 16:25:06 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

--exec [Starsoft].[Reports_Good_In_Transit] 2,'20161001','20161030',7,0

-- ==============================================================================================================
-- PROCEDURE CRIADA A PEDIDO DO PAULO E DO WAGNER PARA EXTRAIR BALANCETE COM DADOS DO HYPERION E CRD POR COLUNAS
-- CRIADO POR CARLOS RODRIGO - 18.05.2015C

-- Alteração por Thviotto Dia 08/08/2016- devido a Atividade SCRUM-15323 - (Ivoices em Transito seriaam Invoices que não possuem COnehcimento e NF no perido Informado.)
--Alteração: 04/01/2016 por Marcelo Ayabe
--Atividade: ROLLOUT-63
--Descrição: Ajustar objetos do SQL que utilizão a cia ukey em sua estrutura.
--Link:	     https://jira.westcon.com.br/browse/ROLLOUT-63
-- ==============================================================================================================
ALTER  PROCEDURE [Starsoft].[Reports_Good_In_Transit]
	@ERP		int,		--CodERP vindo da Intranet de: Select * from Westcon.dbo.TblERP
	@IPeriod    datetime,
	@FPeriod    datetime,
	@CodDivisao	int = 0	,	--Codigo da divisão do grupo westcon CodDivisao de: select * from Westcon.dbo.tbldivisao
	@HistoricofInvoices	int = 0		--SCRUM-15323
AS
BEGIN
--1- Brasil
--2-CALA
--3- México
--4 -Colômbia
--5-Peru
--6-Equadore

	--ROLLOUT-63
	Declare @CIA_UKEY varchar(20)
	SELECT @CIA_UKEY = CIA_UKEY FROM [intranet].[CiaUkey] (@ERP,@CodDivisao)

	-- Se Colombia
	IF @ERP=4
	BEGIN

		if @HistoricofInvoices=1
			begin
				SELECT  
				U10_001_C [Invoice Numbe],
				U10_004_D [Issue Date], U11_003_D [Delivery Date],
				U11_900_B Quantity, 
				T02_002_C [Unit],
				U11_012_B [Net Total],
				SUBSTRING(U10.A36_CODEA,1,5) Currency,
				D04_001_C [Part Number], ISNULL(T05_001_C,'') [Item Type ID], ISNULL(T05_002_C,'') [Type Name], D04_008_C [Item Description], A08_003_C [Supplier], A08_010_C [Supplier ID]
				--SCRUM-15324
				, (SELECT [Starsoft].[ConvertValueColombia](1,SUBSTRING(U10.A36_CODEA,1,5),'$',CAST(U10.U10_004_D AS DATE))) as [TRM] 
				, U11.U11_012_B*(SELECT [Starsoft].[ConvertValueColombia](1,SUBSTRING(U10.A36_CODEA,1,5),'$',CAST(U10.U10_004_D AS DATE))) AS [Invoice value COP]
				--SCRUM-15324
				FROM STARWESTCONCALA2.DBO.U11 (NOLOCK)
				JOIN STARWESTCONCALA2.DBO.T02 (NOLOCK) ON U11.T02_UKEY0=T02.UKEY
				JOIN STARWESTCONCALA2.DBO.D04 (NOLOCK) ON U11.D04_UKEY=D04.UKEY
				LEFT JOIN STARWESTCONCALA2.DBO.T05 (NOLOCK) ON D04.T05_UKEY = T05.UKEY
				JOIN STARWESTCONCALA2.DBO.U10 (NOLOCK) ON U11.U10_UKEY=U10.UKEY
				JOIN STARWESTCONCALA2.DBO.A08 (NOLOCK) ON U10.A08_UKEYA=A08.UKEY
				where 
			--	u11_921_c not in ('1','3')  and 
				U11.CIA_UKEY = @CIA_UKEY 
				--Alterado por Thiago Rodrigues data:06/12/2016,verifica se a invoice deu entrada no periodo solicitado
				--Inicio
				AND U11.UKEY NOT IN (SELECT U14_UKEYP FROM STARWESTCONCALA2.DBO.U14 (NOLOCK) 
								INNER JOIN STARWESTCONCALA2.DBO.U13 (NOLOCK) ON U13.UKEY = U14.U13_UKEY 
								INNER JOIN STARWESTCONCALA2.DBO.E11 (NOLOCK) ON E11.E11_UKEYP = U14.UKEY
								INNER JOIN STARWESTCONCALA2.DBO.E10 (NOLOCK) ON E10.UKEY = E11.E10_UKEY 
							WHERE E10.E10_014_D  BETWEEN @IPERIOD AND @FPERIOD)
				AND U11.UKEY NOT IN (SELECT E11_UKEYP FROM STARWESTCONCALA2.DBO.E11 (NOLOCK)  
						INNER JOIN STARWESTCONCALA2.DBO.E10 (NOLOCK) ON E10.UKEY = E11.E10_UKEY  
						WHERE E10.E10_014_D BETWEEN @IPeriod AND @FPeriod)
				--Fim
				AND U10_004_D BETWEEN @IPeriod AND @FPeriod
				ORDER BY U10_001_C
			end
			else
				if @HistoricofInvoices=0
					begin
						SELECT  
						U10_001_C [Invoice Numbe],
						U10_004_D [Issue Date], U11_003_D [Delivery Date],
						U11_900_B Quantity, 
						T02_002_C [Unit],
						U11_012_B [Net Total],
						SUBSTRING(U10.A36_CODEA,1,5) Currency,
						D04_001_C [Part Number], ISNULL(T05_001_C,'') [Item Type ID], ISNULL(T05_002_C,'') [Type Name], D04_008_C [Item Description], A08_003_C [Supplier], A08_010_C [Supplier ID]
						--SCRUM-15324
						, (SELECT [Starsoft].[ConvertValueColombia](1,SUBSTRING(U10.A36_CODEA,1,5),'$',CAST(U10.U10_004_D AS DATE))) as [TRM] 
						, U11.U11_012_B*(SELECT [Starsoft].[ConvertValueColombia](1,SUBSTRING(U10.A36_CODEA,1,5),'$',CAST(U10.U10_004_D AS DATE))) AS [Invoice value COP]
						--SCRUM-15324
						FROM STARWESTCONCALA2.DBO.U11 (NOLOCK)
						JOIN STARWESTCONCALA2.DBO.T02 (NOLOCK) ON U11.T02_UKEY0=T02.UKEY
						JOIN STARWESTCONCALA2.DBO.D04 (NOLOCK) ON U11.D04_UKEY=D04.UKEY
						LEFT JOIN STARWESTCONCALA2.DBO.T05 (NOLOCK) ON D04.T05_UKEY = T05.UKEY
						JOIN STARWESTCONCALA2.DBO.U10 (NOLOCK) ON U11.U10_UKEY=U10.UKEY
						JOIN STARWESTCONCALA2.DBO.A08 (NOLOCK) ON U10.A08_UKEYA=A08.UKEY
						where 
						u11_921_c not in ('1','3')  and 
						U11.CIA_UKEY = @CIA_UKEY 
	--					and u11.ukey NOT IN (SELECT E11_UKEYP FROM STARWESTCONCALA2.DBO.E11 (NOLOCK) ) 
	--					and u11.ukey NOT IN (SELECT U14_UKEYP FROM STARWESTCONCALA2.DBO.U14 (NOLOCK) )
						AND U10_004_D BETWEEN @IPeriod AND @FPeriod
						ORDER BY U10_001_C
					end

	END
	-- Se Peru
	ELSE IF  @ERP=5	
	BEGIN

		if @HistoricofInvoices=1
			begin
				SELECT  
				U10_001_C [Invoice Numbe],
				U10_004_D [Issue Date], U11_003_D [Delivery Date],
				U11_900_B Quantity, 
				T02_002_C [Unit],
				U11_012_B [Net Total],
				SUBSTRING(U10.A36_CODEA,1,5) Currency,
				D04_001_C [Part Number], ISNULL(T05_001_C,'') [Item Type ID], ISNULL(T05_002_C,'') [Type Name], D04_008_C [Item Description], A08_003_C [Supplier], A08_010_C [Supplier ID]
				--SCRUM-15324
				, (SELECT [Starsoft].[ConvertValuePeru](1,SUBSTRING(U10.A36_CODEA,1,5),'PEN',CAST(U10.U10_004_D AS DATE))) as [TRM] 
				, U11.U11_012_B*(SELECT [Starsoft].[ConvertValuePeru](1,SUBSTRING(U10.A36_CODEA,1,5),'PEN',CAST(U10.U10_004_D AS DATE))) AS [Invoice value COP]
				--SCRUM-15324
				FROM STARWESTCONCALA2.DBO.U11 (NOLOCK)
				JOIN STARWESTCONCALA2.DBO.T02 (NOLOCK) ON U11.T02_UKEY0=T02.UKEY
				JOIN STARWESTCONCALA2.DBO.D04 (NOLOCK) ON U11.D04_UKEY=D04.UKEY
				LEFT JOIN STARWESTCONCALA2.DBO.T05 (NOLOCK) ON D04.T05_UKEY = T05.UKEY
				JOIN STARWESTCONCALA2.DBO.U10 (NOLOCK) ON U11.U10_UKEY=U10.UKEY
				JOIN STARWESTCONCALA2.DBO.A08 (NOLOCK) ON U10.A08_UKEYA=A08.UKEY
				where 
				u11_921_c not in ('1','3')  and 
				U11.CIA_UKEY = @CIA_UKEY 
				-- SCRUM-15323 - inicio
			--	AND U11.UKEY NOT IN (SELECT E11_UKEYP FROM STARWESTCONCALA2.DBO.E11 (NOLOCK)  
			--			INNER JOIN STARWESTCONCALA2.DBO.E10 (NOLOCK) ON E10.UKEY = E11.E10_UKEY  
			--			WHERE E10.E10_014_D BETWEEN @IPeriod AND @FPeriod)
			--	AND U11.UKEY NOT IN (SELECT U14_UKEYP FROM STARWESTCONCALA2.DBO.U14 (NOLOCK) 
			--						INNER JOIN STARWESTCONCALA2.DBO.U13 (NOLOCK) ON U13.UKEY = U14.U13_UKEY  
			--						where U13.U13_015_D BETWEEN @IPeriod AND @FPeriod)
				-- SCRUM-15323 - Fim
				AND U10_004_D BETWEEN @IPeriod AND @FPeriod
				ORDER BY U10_001_C
			end
			else
				if @HistoricofInvoices=0
					begin
						SELECT  
						U10_001_C [Invoice Numbe],
						U10_004_D [Issue Date], U11_003_D [Delivery Date],
						U11_900_B Quantity, 
						T02_002_C [Unit],
						U11_012_B [Net Total],
						SUBSTRING(U10.A36_CODEA,1,5) Currency,
						D04_001_C [Part Number], ISNULL(T05_001_C,'') [Item Type ID], ISNULL(T05_002_C,'') [Type Name], D04_008_C [Item Description], A08_003_C [Supplier], A08_010_C [Supplier ID]
						--SCRUM-15324
						, (SELECT [Starsoft].[ConvertValuePeru](1,SUBSTRING(U10.A36_CODEA,1,5),'PEN',CAST(U10.U10_004_D AS DATE))) as [TRM] 
						, U11.U11_012_B*(SELECT [Starsoft].[ConvertValuePeru](1,SUBSTRING(U10.A36_CODEA,1,5),'PEN',CAST(U10.U10_004_D AS DATE))) AS [Invoice value COP]
						--SCRUM-15324
						FROM STARWESTCONCALA2.DBO.U11 (NOLOCK)
						JOIN STARWESTCONCALA2.DBO.T02 (NOLOCK) ON U11.T02_UKEY0=T02.UKEY
						JOIN STARWESTCONCALA2.DBO.D04 (NOLOCK) ON U11.D04_UKEY=D04.UKEY
						LEFT JOIN STARWESTCONCALA2.DBO.T05 (NOLOCK) ON D04.T05_UKEY = T05.UKEY
						JOIN STARWESTCONCALA2.DBO.U10 (NOLOCK) ON U11.U10_UKEY=U10.UKEY
						JOIN STARWESTCONCALA2.DBO.A08 (NOLOCK) ON U10.A08_UKEYA=A08.UKEY
						where 
						u11_921_c not in ('1','3')  and 
						U11.CIA_UKEY = @CIA_UKEY 
	--					and u11.ukey NOT IN (SELECT E11_UKEYP FROM STARWESTCONCALA2.DBO.E11 (NOLOCK) ) 
	--					and u11.ukey NOT IN (SELECT U14_UKEYP FROM STARWESTCONCALA2.DBO.U14 (NOLOCK) )
						AND U10_004_D BETWEEN @IPeriod AND @FPeriod
						ORDER BY U10_001_C
					end

	END
	-- Se México
	ELSE IF @ERP=3
	BEGIN

		if @HistoricofInvoices=1
			begin
				SELECT  
				U10_001_C [Invoice Numbe],
				U10_004_D [Issue Date], U11_003_D [Delivery Date],
				U11_900_B Quantity, 
				T02_002_C [Unit],
				U11_012_B [Net Total],
				SUBSTRING(U10.A36_CODEA,1,5) Currency,
				D04_001_C [Part Number], ISNULL(T05_001_C,'') [Item Type ID], ISNULL(T05_002_C,'') [Type Name], D04_008_C [Item Description], A08_003_C [Supplier], A08_010_C [Supplier ID]
				--SCRUM-15324
				, (SELECT [Starsoft].[ConvertValueMX](1,SUBSTRING(U10.A36_CODEA,1,5),'MN',CAST(U10.U10_004_D AS DATE))) as [TRM] 
				, U11.U11_012_B*(SELECT [Starsoft].[ConvertValueMX](1,SUBSTRING(U10.A36_CODEA,1,5),'MN',CAST(U10.U10_004_D AS DATE))) AS [Invoice value COP]
				--SCRUM-15324
				FROM STARWESTCONMX.DBO.U11 (NOLOCK)
				JOIN STARWESTCONMX.DBO.T02 (NOLOCK) ON U11.T02_UKEY0=T02.UKEY
				JOIN STARWESTCONMX.DBO.D04 (NOLOCK) ON U11.D04_UKEY=D04.UKEY
				LEFT JOIN STARWESTCONMX.DBO.T05 (NOLOCK) ON D04.T05_UKEY = T05.UKEY
				JOIN STARWESTCONMX.DBO.U10 (NOLOCK) ON U11.U10_UKEY=U10.UKEY
				JOIN STARWESTCONMX.DBO.A08 (NOLOCK) ON U10.A08_UKEYA=A08.UKEY
				where 
				u11_921_c<>'3' and 
				U10_004_D BETWEEN @IPeriod AND @FPeriod and 
				-- SCRUM-15323 - inicio
				 U11.UKEY NOT IN (SELECT E11_UKEYP FROM STARWESTCONMX.DBO.E11 (NOLOCK)  
									INNER JOIN STARWESTCONMX.DBO.E10 (NOLOCK) ON E10.UKEY = E11.E10_UKEY  WHERE E10.E10_014_D BETWEEN @IPeriod AND @FPeriod)
				AND U11.UKEY NOT IN (SELECT U14_UKEYP FROM STARWESTCONMX.DBO.U14 (NOLOCK) 
									INNER JOIN STARWESTCONMX.DBO.U13 (NOLOCK) ON U13.UKEY = U14.U13_UKEY  where U13.U13_015_D BETWEEN @IPeriod AND @FPeriod)
				-- SCRUM-15323 - Fim
				ORDER BY U10_001_C
			end
			else
				if @HistoricofInvoices=0
					begin
						SELECT  
						U10_001_C [Invoice Numbe],
						U10_004_D [Issue Date], U11_003_D [Delivery Date],
						U11_900_B Quantity, 
						T02_002_C [Unit],
						U11_012_B [Net Total],
						SUBSTRING(U10.A36_CODEA,1,5) Currency,
						D04_001_C [Part Number], ISNULL(T05_001_C,'') [Item Type ID], ISNULL(T05_002_C,'') [Type Name], D04_008_C [Item Description], A08_003_C [Supplier], A08_010_C [Supplier ID]
						--SCRUM-15324
						, (SELECT [Starsoft].[ConvertValueMX](1,SUBSTRING(U10.A36_CODEA,1,5),'MN',CAST(U10.U10_004_D AS DATE))) as [TRM] 
						, U11.U11_012_B*(SELECT [Starsoft].[ConvertValueMX](1,SUBSTRING(U10.A36_CODEA,1,5),'MN',CAST(U10.U10_004_D AS DATE))) AS [Invoice value COP]
						--SCRUM-15324
						FROM STARWESTCONMX.DBO.U11 (NOLOCK)
						JOIN STARWESTCONMX.DBO.T02 (NOLOCK) ON U11.T02_UKEY0=T02.UKEY
						JOIN STARWESTCONMX.DBO.D04 (NOLOCK) ON U11.D04_UKEY=D04.UKEY
						LEFT JOIN STARWESTCONMX.DBO.T05 (NOLOCK) ON D04.T05_UKEY = T05.UKEY
						JOIN STARWESTCONMX.DBO.U10 (NOLOCK) ON U11.U10_UKEY=U10.UKEY
						JOIN STARWESTCONMX.DBO.A08 (NOLOCK) ON U10.A08_UKEYA=A08.UKEY
						where 
						u11_921_c<>'3' and 
						U10_004_D BETWEEN @IPeriod AND @FPeriod and 
						u11.ukey NOT IN (SELECT E11_UKEYP FROM STARWESTCONMX.DBO.E11 (NOLOCK)  )
						and u11.ukey NOT IN (SELECT U14_UKEYP FROM STARWESTCONMX.DBO.U14 (NOLOCK) )
						ORDER BY U10_001_C
					end

	END
	-- Se CALA
	ELSE IF @ERP=2
	BEGIN
		SELECT  
		E08_001_C [Invoice Numbe],
		E08_003_D [Issue Date], E09_001_D [Delivery Date],
		E09_900_B-E09_901_B Quantity, 
		T02_002_C [Unit],
		ABS((E09_008_B/ CASE WHEN E09_003_B >0 THEN E09_003_B ELSE 1 END) * E09_900_B-E09_901_B )
		
		* CASE WHEN RIGHT(RTRIM(LTRIM(E08_001_C)), 2)='-F' THEN -1 ELSE 1 END
		
		
		 [Net Total],
		SUBSTRING(E08.A36_CODE,1,5) Currency,
		D04_001_C [Part Number], ISNULL(T05_001_C,'') [Item Type ID], ISNULL(T05_002_C,'') [Type Name], D04_008_C [Item Description], 
		A08_003_C [Supplier], A08_010_C [Supplier ID]
		--SCRUM-15324
		, (SELECT [Starsoft].[ConvertValueColombia](1,SUBSTRING(E08.A36_CODE,1,5),'US$',CAST(E08.E08_003_D AS DATE))) as [TRM] 
		, E09.E09_008_B*(SELECT [Starsoft].[ConvertValueColombia](1,SUBSTRING(E08.A36_CODE,1,5),'US$',CAST(E08.E08_003_D AS DATE))) AS [Invoice value COP]
		--SCRUM-15324
		FROM STARWESTCONCALA2.DBO.E09 (NOLOCK)
		JOIN STARWESTCONCALA2.DBO.T02 (NOLOCK) ON E09.T02_UKEY0=T02.UKEY
		JOIN STARWESTCONCALA2.DBO.D04 (NOLOCK) ON E09.D04_UKEY=D04.UKEY
		LEFT JOIN STARWESTCONCALA2.DBO.T05 (NOLOCK) ON D04.T05_UKEY = T05.UKEY
		JOIN STARWESTCONCALA2.DBO.E08 (NOLOCK) ON E09.E08_UKEY=E08.UKEY
		JOIN STARWESTCONCALA2.DBO.A08 (NOLOCK) ON E08.A08_UKEY=A08.UKEY
		where 
		e09_921_c<>'3' and 

		E09.CIA_UKEY='STAR_'
		and E09.ukey NOT IN (SELECT E11_UKEYP FROM STARWESTCONCALA2.DBO.E11 (NOLOCK) )
		AND E08_003_D BETWEEN @IPeriod AND @FPeriod
		ORDER BY E08_001_C

	END
END









