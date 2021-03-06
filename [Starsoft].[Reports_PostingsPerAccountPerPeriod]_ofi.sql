USE [Westcon]
GO
/****** Object:  StoredProcedure [Starsoft].[Reports_PostingsPerAccountPerPeriod]    Script Date: 26/07/2016 11:37:24 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

--exec [Starsoft].[Reports_PostingsPerAccountPerPeriod] 4,'20160601','20160730','4101100001'

ALTER PROCEDURE [Starsoft].[Reports_PostingsPerAccountPerPeriod]
      @ERP  int,--CodERP vindo da Intranet de: Select * from Westcon.dbo.TblERP
      @Data_Inicial date, -- Data inicial
      @Data_Final date, -- Data Final
      @DeContaContabil varchar(20), -- Código da conta contábil
      @AteContaContabil varchar(20) -- Código da conta contábil
AS

/*
	2015-10-02 Incluído os campos de Fornecedor/Invoice/OC	

	2013-04-29 JM Alterei o FROM de MX e CALA para
	de convert(varchar,B07.B07_002_M) as Historico PARA convert(varchar (8000),B07.B07_002_M) as Historico, 
	para trazer o campo Histórico com mais caracteres.

	2012-02-27 A procedure foi criada por Edson Leonardo da Starsoft.

	2012-03-01 JM - Para acomodar lançamentos até 23h59m59s de uma data, troquei
	AND B07.B07_003_D BETWEEN @Data_Inicial AND @Data_Final
	por
	AND B07.B07_003_D >= @Data_Inicial AND B07.B07_003_D  < DATEADD(dd, 1, @Data_Final)
	
	2012-04-05 - Edson Leonardo (StarSoft)
	Criei a função 'Westcon.Starsoft.DisjoinHistoricalAccounting' que recebe como parâmetro o historico do lançamento 
	contábil e separa o numero da nota e/ou nome do cliente caso tenha essa inf. no histórico e adicionei os campo
	NF e Cliente que são preenchidos por essa nova função
	
	2012-04-05 - Vívian Domingues (Starsoft)
	Conforme alteração solicitada por "Jorge Luis Pereira Valle" e direcionada a mim por "Maurício Weckerle (Gaúcho)", 
	adicionei o limite de caractéres para "8000" na conversão de Tipo Memo para Tipo Varchar do Campo "B07.B07_002_M" 
	para que traga toda a descrição do histórico. A alteração foi realizada somente para o "ERP = 1", onde o script de
	conversão ficou desta maneira: "convert(varchar (8000),B07.B07_002_M) as Historico" 
	
	Obs: Link da atividade no JIRA "https://jira.westcon.com.br/browse/SSA-3403"  
	
	*/

BEGIN 

      declare @V_ERP				int 
      declare @V_Data_Inicial		date
      declare @V_Data_Final			date
      declare @V_DeContaContabil	varchar(20) 
      declare @V_AteContaContabil	varchar(20)

	  SET @V_ERP				=	@ERP
      SET @V_Data_Inicial		=	@Data_Inicial
      SET @V_Data_Final			=	@Data_Final
      SET @V_DeContaContabil	=	@DeContaContabil
      SET @V_AteContaContabil	=	@AteContaContabil

	/**************************************BRASIL*****************************************/
    IF @V_ERP = 1 
	BEGIN

		SELECT	ContaContabil,
				NumeroLancamento,
				CASE WHEN 
					COUNT(1) > 1 
				THEN 
					'DIVERSOS '  + CASE WHEN DebitoOuCredito = 1 THEN 'CREDITOS' ELSE 'DEBITOS' END
				ELSE 
					max(Contrapartida)
				END AS Contrapartida, 
				CASE WHEN CHARINDEX(' - ', Historico) <> 0 
					THEN 
						(CASE WHEN CHARINDEX(' - Vendor: ', Historico) <> 0 THEN
							SUBSTRING(Historico, CHARINDEX(' - Vendor: ', Historico)+11, 300) 
							ELSE SUBSTRING(Historico, CHARINDEX(' - ', Historico)+3,300) END
						) 
					ELSE
						(CASE WHEN CHARINDEX(', ', Historico) <> 0 AND (LEN(SUBSTRING(Historico,1,8000)) - LEN(REPLACE(SUBSTRING(Historico,1,8000),', ', ''))) > 2 THEN
							SUBSTRING(Historico, CHARINDEX(', ', Historico)+2,  CHARINDEX(', ', Historico, CHARINDEX(', ', Historico)+1) - CHARINDEX(', ', Historico) - 2 )  
							ELSE '' END
						)
				END Vendor_Customer_Name, 
 				Max(ISNULL(INVOICE,'')) Invoice,
				Max(ISNULL(OC,'')) PO_Number,
				Max(ISNULL(USRNOTE,'')) Comments,
				DebitoOuCredito,
				ValorLancamento,
				Historico,
				Westcon.Starsoft.DisjoinHistoricalAccounting(Historico1 , 1) as NF,
				Westcon.Starsoft.DisjoinHistoricalAccounting(Historico2 , 2) as Cliente,
				DataLancamento,
				Ordem,
				FatorDebito,
				FatorCredito,
				HistAux,
				ValorDebito,
				ValorCredito
		FROM (
				SELECT TOP 100 PERCENT 
				B11.B11_001_C AS ContaContabil, 
				B06.B06_001_C AS NumeroLancamento,
				B11T.B11_003_C AS Contrapartida, 
				B07.ARRAY_117 AS DebitoOuCredito, 
				B07.B07_001_B AS ValorLancamento, 
				convert(varchar (8000),B07.B07_002_M) as Historico, 
				convert(varchar,B07.B07_002_M) as Historico1, 				
				convert(varchar,B07.B07_002_M) as Historico2, 								
				B07.B07_003_D AS DataLancamento, 
				B07.B07_013_C AS Ordem, 
				B07.B07_011_N AS FatorDebito, 
				B07.B07_012_N AS FatorCredito, 
				B05.B05_002_C AS HistAux, 
				CONVERT(varchar, B06.USR_NOTE) USRNOTE,
				ISNULL(ISNULL(E10_001_C, J10_001_C),'') INVOICE,
				ISNULL(ISNULL(ISNULL(E10_A03.A03_003_C,E10_A08.A08_003_C), J10_A03.A03_003_C), J10_A08.A08_003_C) VENDOR_CUSTOMER_NAME,
				ISNULL(
					ISNULL(
						ISNULL(
							ISNULL(
								  (SELECT TOP 1 E08_001_C FROM StarWestcon.dbo.E08 (NOLOCK) JOIN StarWestcon.dbo.E09 (NOLOCK) ON E09.E08_UKEY=E08.UKEY JOIN StarWestcon.dbo.E11 (NOLOCK) ON E11_UKEYP=E09.UKEY WHERE E11.E10_UKEY=E10.UKEY), 
								  (SELECT TOP 1 U05_001_C FROM StarWestcon.dbo.U05 (NOLOCK) JOIN StarWestcon.dbo.U06 (NOLOCK) ON U06.U05_UKEY=U05.UKEY JOIN StarWestcon.dbo.E11 (NOLOCK) ON E11.E11_UKEYP = U06.UKEY WHERE E11.E10_UKEY=E10.UKEY)),
							(SELECT TOP 1 U05_001_C FROM StarWestcon.dbo.U05 (NOLOCK) JOIN StarWestcon.dbo.U06 (NOLOCK) ON U06.U05_UKEY=U05.UKEY JOIN StarWestcon.dbo.U11 (NOLOCK) ON U11.U11_UKEYP = U06.UKEY JOIN StarWestcon.dbo.E11 (NOLOCK) ON E11.E11_UKEYP = U11.UKEY WHERE E11.E10_UKEY=E10.UKEY)),
						(SELECT TOP 1 U05_001_C FROM StarWestcon.dbo.U05 (NOLOCK) JOIN StarWestcon.dbo.U06 (NOLOCK) ON U06.U05_UKEY=U05.UKEY JOIN StarWestcon.dbo.U11 (NOLOCK) ON U11.U11_UKEYP = U06.UKEY JOIN StarWestcon.dbo.U14 (NOLOCK) ON U14.U14_UKEYP = U11.UKEY JOIN StarWestcon.dbo.E11 (NOLOCK) ON E11.E11_UKEYP = U14.UKEY WHERE E11.E10_UKEY=E10.UKEY)), '') OC,
				CASE WHEN B07.ARRAY_117 = 1 THEN B07.B07_001_B ELSE 0 END AS ValorDebito, 
				CASE WHEN B07.ARRAY_117 = 2 THEN B07.B07_001_B ELSE 0 END AS ValorCredito
				FROM StarWestcon.dbo.B07 B07 WITH (NoLock)
				INNER JOIN StarWestcon.dbo.B06 B06 WITH (NoLock) ON B07.B06_UKEY = B06.UKEY 
				INNER JOIN StarWestcon.dbo.B11 B11 WITH (NoLock) ON B07.B11_UKEY = B11.UKEY 
				LEFT OUTER JOIN StarWestcon.dbo.B05 B05 WITH (NoLock) ON B07.B05_UKEY = B05.UKEY
				LEFT OUTER JOIN StarWestcon.dbo.B07 B07T (NOLOCK) ON B07T.B06_UKEY = B07.B06_UKEY AND B07T.B07_010_N = B07.B07_010_N AND B07T.ARRAY_117 <> B07.ARRAY_117				
				LEFT OUTER JOIN StarWestcon.dbo.B11 B11T (NOLOCK) ON B07T.B11_UKEY = B11T.UKEY  
				LEFT JOIN StarWestcon.dbo.E10  (NOLOCK) ON B07T.B07_UKEYP = E10.UKEY
				LEFT JOIN StarWestcon.dbo.A03 E10_A03  (NOLOCK) ON E10.A03_UKEY = E10_A03.UKEY
				LEFT JOIN StarWestcon.dbo.A08 E10_A08 (NOLOCK)  ON E10.A08_UKEY = E10_A08.UKEY
				LEFT JOIN StarWestcon.dbo.J10  (NOLOCK) ON B07T.B07_UKEYP = J10.UKEY
				LEFT JOIN StarWestcon.dbo.A03 J10_A03  (NOLOCK) ON J10.A03_UKEY = J10_A03.UKEY
				LEFT JOIN StarWestcon.dbo.A08 J10_A08 (NOLOCK)  ON J10.A08_UKEY = J10_A08.UKEY
				WHERE B11.B11_001_C between @V_DeContaContabil and @V_AteContaContabil
				AND B07.B07_003_D >= @V_Data_inicial AND B07.B07_003_D  < DATEADD(dd, 1, @V_Data_Final)
		)TMP
		GROUP BY 
			ContaContabil, DebitoOuCredito, ValorLancamento, Historico, DataLancamento, Ordem, FatorDebito,
			FatorCredito, HistAux, ValorDebito, ValorCredito, Historico1, Historico2, NumeroLancamento
			
		ORDER BY 
		  DataLancamento, Ordem

		  
	END
      
	/**************************************CALA*****************************************/
	ELSE IF @V_ERP = 2
		BEGIN
		
			SELECT	ContaContabil,
					NumeroLancamento,
					CASE WHEN 
						COUNT(1) > 1 
					THEN 
						'DIVERSOS '  + CASE WHEN DebitoOuCredito = 1 THEN 'CREDITOS' ELSE 'DEBITOS' END
					ELSE 
						max(Contrapartida)
					END AS Contrapartida, 
					CASE WHEN CHARINDEX(' - ', Historico) <> 0 
						THEN 
							(CASE WHEN CHARINDEX(' - Vendor: ', Historico) <> 0 THEN
								SUBSTRING(Historico, CHARINDEX(' - Vendor: ', Historico)+11, 300) 
								ELSE SUBSTRING(Historico, CHARINDEX(' - ', Historico)+3,300) END
							) 
						ELSE
							(CASE WHEN CHARINDEX(', ', Historico) <> 0 AND (LEN(SUBSTRING(Historico,1,8000)) - LEN(REPLACE(SUBSTRING(Historico,1,8000),', ', ''))) > 2 THEN
								SUBSTRING(Historico, CHARINDEX(', ', Historico)+2,  CHARINDEX(', ', Historico, CHARINDEX(', ', Historico)+1) - CHARINDEX(', ', Historico) - 2 )  
								ELSE '' END
							)
					END Vendor_Customer_Name, 
					MAX(ISNULL(INVOICE,'')) Invoice,
					MAX(ISNULL(OC,'')) PO_Number,
					MAX(ISNULL(USRNOTE,'')) Comments,
					DebitoOuCredito,
					ValorLancamento,
					Historico,
					Westcon.Starsoft.DisjoinHistoricalAccounting(Historico1 , 1) as NF,
					Westcon.Starsoft.DisjoinHistoricalAccounting(Historico2 , 2) as Cliente,
					DataLancamento,
					Ordem,
					FatorDebito,
					FatorCredito,
					HistAux,
					ValorDebito,
					ValorCredito
			FROM (
					SELECT TOP 100 PERCENT 
					B11.B11_001_C AS ContaContabil, 
					B06.B06_001_C AS NumeroLancamento,
					B11T.B11_003_C AS Contrapartida, 
					B07.ARRAY_117 AS DebitoOuCredito, 
					B07.B07_001_B AS ValorLancamento, 
					convert(varchar (8000),B07.B07_002_M) as Historico, 
					convert(varchar,B07.B07_002_M) as Historico1, 				
					convert(varchar,B07.B07_002_M) as Historico2, 								
					B07.B07_003_D AS DataLancamento, 
					B07.B07_013_C AS Ordem, 
					B07.B07_011_N AS FatorDebito, 
					B07.B07_012_N AS FatorCredito, 
					B05.B05_002_C AS HistAux, 
					CONVERT(varchar, B06.USR_NOTE) USRNOTE,
					ISNULL(ISNULL(E10_001_C, J10_001_C),'') INVOICE,
					ISNULL(ISNULL(ISNULL(E10_A03.A03_003_C,E10_A08.A08_003_C), J10_A03.A03_003_C), J10_A08.A08_003_C) VENDOR_CUSTOMER_NAME,
					ISNULL(
						ISNULL(
							ISNULL(
								ISNULL(
									  (SELECT TOP 1 E08_001_C FROM StarWestconCALA2.dbo.E08 (NOLOCK) JOIN StarWestconCALA2.dbo.E09 (NOLOCK) ON E09.E08_UKEY=E08.UKEY JOIN StarWestconCALA2.dbo.E11 (NOLOCK) ON E11_UKEYP=E09.UKEY WHERE E11.E10_UKEY=E10.UKEY), 
									  (SELECT TOP 1 U05_001_C FROM StarWestconCALA2.dbo.U05 (NOLOCK) JOIN StarWestconCALA2.dbo.U06 (NOLOCK) ON U06.U05_UKEY=U05.UKEY JOIN StarWestconCALA2.dbo.E11 (NOLOCK) ON E11.E11_UKEYP = U06.UKEY WHERE E11.E10_UKEY=E10.UKEY)),
								(SELECT TOP 1 U05_001_C FROM StarWestconCALA2.dbo.U05 (NOLOCK) JOIN StarWestconCALA2.dbo.U06 (NOLOCK) ON U06.U05_UKEY=U05.UKEY JOIN StarWestconCALA2.dbo.U11 (NOLOCK) ON U11.U11_UKEYP = U06.UKEY JOIN StarWestconCALA2.dbo.E11 (NOLOCK) ON E11.E11_UKEYP = U11.UKEY WHERE E11.E10_UKEY=E10.UKEY)),
							(SELECT TOP 1 U05_001_C FROM StarWestconCALA2.dbo.U05 (NOLOCK) JOIN StarWestconCALA2.dbo.U06 (NOLOCK) ON U06.U05_UKEY=U05.UKEY JOIN StarWestconCALA2.dbo.U11 (NOLOCK) ON U11.U11_UKEYP = U06.UKEY JOIN StarWestconCALA2.dbo.U14 (NOLOCK) ON U14.U14_UKEYP = U11.UKEY JOIN StarWestconCALA2.dbo.E11 (NOLOCK) ON E11.E11_UKEYP = U14.UKEY WHERE E11.E10_UKEY=E10.UKEY)), '') OC,
					CASE WHEN B07.ARRAY_117 = 1 THEN B07.B07_001_B ELSE 0 END AS ValorDebito, 
					CASE WHEN B07.ARRAY_117 = 2 THEN B07.B07_001_B ELSE 0 END AS ValorCredito
					FROM StarWestconCALA2.dbo.B07 B07 WITH (NoLock)
					INNER JOIN StarWestconCALA2.dbo.B06 B06 WITH (NoLock) ON B07.B06_UKEY = B06.UKEY 
					INNER JOIN StarWestconCALA2.dbo.B11 B11 WITH (NoLock) ON B07.B11_UKEY = B11.UKEY 
					LEFT OUTER JOIN StarWestconCALA2.dbo.B05 B05 WITH (NoLock) ON B07.B05_UKEY = B05.UKEY
					LEFT OUTER JOIN StarWestconCALA2.dbo.B07 B07T (NOLOCK) ON B07T.B06_UKEY = B07.B06_UKEY AND B07T.B07_010_N = B07.B07_010_N AND B07T.ARRAY_117 <> B07.ARRAY_117				
					LEFT OUTER JOIN StarWestconCALA2.dbo.B11 B11T (NOLOCK) ON B07T.B11_UKEY = B11T.UKEY  
					LEFT JOIN StarWestconCALA2.dbo.E10  (NOLOCK) ON B07T.B07_UKEYP = E10.UKEY
					LEFT JOIN StarWestconCALA2.dbo.A03 E10_A03  (NOLOCK) ON E10.A03_UKEY = E10_A03.UKEY
					LEFT JOIN StarWestconCALA2.dbo.A08 E10_A08 (NOLOCK)  ON E10.A08_UKEY = E10_A08.UKEY
					LEFT JOIN StarWestconCALA2.dbo.J10  (NOLOCK) ON B07T.B07_UKEYP = J10.UKEY
					LEFT JOIN StarWestconCALA2.dbo.A03 J10_A03  (NOLOCK) ON J10.A03_UKEY = J10_A03.UKEY
					LEFT JOIN StarWestconCALA2.dbo.A08 J10_A08 (NOLOCK)  ON J10.A08_UKEY = J10_A08.UKEY
					WHERE B11.CIA_UKEY = 'STAR_' AND B11.B11_001_C between @V_DeContaContabil and @V_AteContaContabil 
					AND B07.B07_003_D >= @V_Data_Inicial AND B07.B07_003_D  < DATEADD(dd, 1, @V_Data_Final)
			)TMP
			GROUP BY 
				ContaContabil, DebitoOuCredito, ValorLancamento, Historico, DataLancamento, Ordem, FatorDebito,
				FatorCredito, HistAux, ValorDebito, ValorCredito, Historico1, Historico2, NumeroLancamento

			ORDER BY 
			  DataLancamento, Ordem 

		END
            
		/**************************************MEXICO*****************************************/
		ELSE IF @V_ERP = 3
			
			BEGIN
			
				SELECT	ContaContabil,
						NumeroLancamento,
						CASE WHEN 
							COUNT(1) > 1 
						THEN 
							'DIVERSOS '  + CASE WHEN DebitoOuCredito = 1 THEN 'CREDITOS' ELSE 'DEBITOS' END
						ELSE 
							max(Contrapartida)
						END AS Contrapartida, 
						CASE WHEN CHARINDEX(' - ', Historico) <> 0 
							THEN 
								(CASE WHEN CHARINDEX(' - Vendor: ', Historico) <> 0 THEN
									SUBSTRING(Historico, CHARINDEX(' - Vendor: ', Historico)+11, 300) 
									ELSE SUBSTRING(Historico, CHARINDEX(' - ', Historico)+3,300) END
								) 
							ELSE
								(CASE WHEN CHARINDEX(', ', Historico) <> 0 AND (LEN(SUBSTRING(Historico,1,8000)) - LEN(REPLACE(SUBSTRING(Historico,1,8000),', ', ''))) > 2 THEN
									SUBSTRING(Historico, CHARINDEX(', ', Historico)+2,  CHARINDEX(', ', Historico, CHARINDEX(', ', Historico)+1) - CHARINDEX(', ', Historico) - 2 )  
									ELSE '' END
								)
						END Vendor_Customer_Name, 
						MAX(ISNULL(INVOICE,'')) Invoice,
						MAX(ISNULL(OC,'')) PO_Number,
						MAX(ISNULL(USRNOTE,'')) Comments,
						DebitoOuCredito,
						ValorLancamento,
						Historico,
						Westcon.Starsoft.DisjoinHistoricalAccounting(Historico1 , 1) as NF,
						Westcon.Starsoft.DisjoinHistoricalAccounting(Historico2 , 2) as Cliente,
						DataLancamento,
						Ordem,
						FatorDebito,
						FatorCredito,
						HistAux,
						ValorDebito,
						ValorCredito
				FROM (
						SELECT TOP 100 PERCENT 
						B11.B11_001_C AS ContaContabil, 
						B06.B06_001_C AS NumeroLancamento,
						B11T.B11_003_C AS Contrapartida, 
						B07.ARRAY_117 AS DebitoOuCredito, 
						B07.B07_001_B AS ValorLancamento, 
						convert(varchar(8000),B07.B07_002_M) as Historico, 
						convert(varchar,B07.B07_002_M) as Historico1, 				
						convert(varchar,B07.B07_002_M) as Historico2, 								
						B07.B07_003_D AS DataLancamento, 
						B07.B07_013_C AS Ordem, 
						B07.B07_011_N AS FatorDebito, 
						B07.B07_012_N AS FatorCredito, 
						B05.B05_002_C AS HistAux, 
						CONVERT(varchar, B06.USR_NOTE) USRNOTE,
						ISNULL(ISNULL(E10_001_C, J10_001_C),'') INVOICE,
						ISNULL(ISNULL(ISNULL(E10_A03.A03_003_C,E10_A08.A08_003_C), J10_A03.A03_003_C), J10_A08.A08_003_C) VENDOR_CUSTOMER_NAME,
						ISNULL(
							ISNULL(
								ISNULL(
									ISNULL(
										  (SELECT TOP 1 E08_001_C FROM StarWestconMX.dbo.E08 (NOLOCK) JOIN StarWestconMX.dbo.E09 (NOLOCK) ON E09.E08_UKEY=E08.UKEY JOIN StarWestconMX.dbo.E11 (NOLOCK) ON E11_UKEYP=E09.UKEY WHERE E11.E10_UKEY=E10.UKEY), 
										  (SELECT TOP 1 U05_001_C FROM StarWestconMX.dbo.U05 (NOLOCK) JOIN StarWestconMX.dbo.U06 (NOLOCK) ON U06.U05_UKEY=U05.UKEY JOIN StarWestconMX.dbo.E11 (NOLOCK) ON E11.E11_UKEYP = U06.UKEY WHERE E11.E10_UKEY=E10.UKEY)),
									(SELECT TOP 1 U05_001_C FROM StarWestconMX.dbo.U05 (NOLOCK) JOIN StarWestconMX.dbo.U06 (NOLOCK) ON U06.U05_UKEY=U05.UKEY JOIN StarWestconMX.dbo.U11 (NOLOCK) ON U11.U11_UKEYP = U06.UKEY JOIN StarWestconMX.dbo.E11 (NOLOCK) ON E11.E11_UKEYP = U11.UKEY WHERE E11.E10_UKEY=E10.UKEY)),
								(SELECT TOP 1 U05_001_C FROM StarWestconMX.dbo.U05 (NOLOCK) JOIN StarWestconMX.dbo.U06 (NOLOCK) ON U06.U05_UKEY=U05.UKEY JOIN StarWestconMX.dbo.U11 (NOLOCK) ON U11.U11_UKEYP = U06.UKEY JOIN StarWestconMX.dbo.U14 (NOLOCK) ON U14.U14_UKEYP = U11.UKEY JOIN StarWestconMX.dbo.E11 (NOLOCK) ON E11.E11_UKEYP = U14.UKEY WHERE E11.E10_UKEY=E10.UKEY)), '') OC,
						CASE WHEN B07.ARRAY_117 = 1 THEN B07.B07_001_B ELSE 0 END AS ValorDebito, 
						CASE WHEN B07.ARRAY_117 = 2 THEN B07.B07_001_B ELSE 0 END AS ValorCredito
						FROM StarWestconMX.dbo.B07 B07 WITH (NoLock)
						INNER JOIN StarWestconMX.dbo.B06 B06 WITH (NoLock) ON B07.B06_UKEY = B06.UKEY 
						INNER JOIN StarWestconMX.dbo.B11 B11 WITH (NoLock) ON B07.B11_UKEY = B11.UKEY 
						LEFT OUTER JOIN StarWestconMX.dbo.B05 B05 WITH (NoLock) ON B07.B05_UKEY = B05.UKEY
						LEFT OUTER JOIN StarWestconMX.dbo.B07 B07T (NOLOCK) ON B07T.B06_UKEY = B07.B06_UKEY AND B07T.B07_010_N = B07.B07_010_N AND B07T.ARRAY_117 <> B07.ARRAY_117				
						LEFT OUTER JOIN StarWestconMX.dbo.B11 B11T (NOLOCK) ON B07T.B11_UKEY = B11T.UKEY  
						LEFT JOIN StarWestconMX.dbo.E10  (NOLOCK) ON B07T.B07_UKEYP = E10.UKEY
						LEFT JOIN StarWestconMX.dbo.A03 E10_A03  (NOLOCK) ON E10.A03_UKEY = E10_A03.UKEY
						LEFT JOIN StarWestconMX.dbo.A08 E10_A08 (NOLOCK)  ON E10.A08_UKEY = E10_A08.UKEY
						LEFT JOIN StarWestconMX.dbo.J10  (NOLOCK) ON B07T.B07_UKEYP = J10.UKEY
						LEFT JOIN StarWestconMX.dbo.A03 J10_A03  (NOLOCK) ON J10.A03_UKEY = J10_A03.UKEY
						LEFT JOIN StarWestconMX.dbo.A08 J10_A08 (NOLOCK)  ON J10.A08_UKEY = J10_A08.UKEY 
						WHERE B11.B11_001_C between @V_DeContaContabil and @V_AteContaContabil
						AND B07.B07_003_D >= @V_Data_Inicial AND B07.B07_003_D  < DATEADD(dd, 1, @V_Data_Final)
				)TMP
				GROUP BY 
					ContaContabil, DebitoOuCredito, ValorLancamento, Historico, DataLancamento, Ordem, FatorDebito,
					FatorCredito, HistAux, ValorDebito, ValorCredito, Historico1, Historico2, NumeroLancamento

				ORDER BY 
				  DataLancamento, Ordem 
				  
			END

		/**************************************COLOMBIA*****************************************/      

		ELSE IF @V_ERP = 4

		BEGIN
		
			SELECT	ContaContabil,
					NumeroLancamento,
					CASE WHEN 
						COUNT(1) > 1 
					THEN 
						'DIVERSOS '  + CASE WHEN DebitoOuCredito = 1 THEN 'CREDITOS' ELSE 'DEBITOS' END
					ELSE 
						max(Contrapartida)
					END AS Contrapartida, 
					CASE WHEN CHARINDEX(' - ', Historico) <> 0 
						THEN 
							(CASE WHEN CHARINDEX(' - Vendor: ', Historico) <> 0 THEN
								SUBSTRING(Historico, CHARINDEX(' - Vendor: ', Historico)+11, 300) 
								ELSE SUBSTRING(Historico, CHARINDEX(' - ', Historico)+3,300) END
							) 
						ELSE
							(CASE WHEN CHARINDEX(', ', Historico) <> 0 AND (LEN(SUBSTRING(Historico,1,8000)) - LEN(REPLACE(SUBSTRING(Historico,1,8000),', ', ''))) > 2 THEN
								SUBSTRING(Historico, CHARINDEX(', ', Historico)+2,  CHARINDEX(', ', Historico, CHARINDEX(', ', Historico)+1) - CHARINDEX(', ', Historico) - 2 )  
								ELSE '' END
							)
					END Vendor_Customer_Name, 
					MAX(ISNULL(INVOICE,'')) Invoice,
					MAX(ISNULL(OC,'')) PO_Number,
					MAX(ISNULL(USRNOTE,'')) Comments,
					DebitoOuCredito,
					ValorLancamento,
					Historico,
					Westcon.Starsoft.DisjoinHistoricalAccounting(Historico1 , 1) as NF,
					Westcon.Starsoft.DisjoinHistoricalAccounting(Historico2 , 2) as Cliente,
					DataLancamento,
					Ordem,
					FatorDebito,
					FatorCredito,
					HistAux,
					ValorDebito,
					ValorCredito
			FROM (
					SELECT TOP 100 PERCENT 
					B11.B11_001_C AS ContaContabil, 
					B06.B06_001_C AS NumeroLancamento,
					B11T.B11_003_C AS Contrapartida, 
					B07.ARRAY_117 AS DebitoOuCredito, 
					B07.B07_001_B AS ValorLancamento, 
					convert(varchar (8000),B07.B07_002_M) as Historico, 
					convert(varchar,B07.B07_002_M) as Historico1, 				
					convert(varchar,B07.B07_002_M) as Historico2, 								
					B07.B07_003_D AS DataLancamento, 
					B07.B07_013_C AS Ordem, 
					B07.B07_011_N AS FatorDebito, 
					B07.B07_012_N AS FatorCredito, 
					B05.B05_002_C AS HistAux, 
					CONVERT(varchar, B06.USR_NOTE) USRNOTE,
					ISNULL(ISNULL(E10_001_C, J10_001_C),'') INVOICE,
					ISNULL(ISNULL(ISNULL(E10_A03.A03_003_C,E10_A08.A08_003_C), J10_A03.A03_003_C), J10_A08.A08_003_C) VENDOR_CUSTOMER_NAME,
					ISNULL(
						ISNULL(
							ISNULL(
								ISNULL(
									  (SELECT TOP 1 E08_001_C FROM StarWestconCALA2.dbo.E08 (NOLOCK) JOIN StarWestconCALA2.dbo.E09 (NOLOCK) ON E09.E08_UKEY=E08.UKEY JOIN StarWestconCALA2.dbo.E11 (NOLOCK) ON E11_UKEYP=E09.UKEY WHERE E11.E10_UKEY=E10.UKEY), 
									  (SELECT TOP 1 U05_001_C FROM StarWestconCALA2.dbo.U05 (NOLOCK) JOIN StarWestconCALA2.dbo.U06 (NOLOCK) ON U06.U05_UKEY=U05.UKEY JOIN StarWestconCALA2.dbo.E11 (NOLOCK) ON E11.E11_UKEYP = U06.UKEY WHERE E11.E10_UKEY=E10.UKEY)),
								(SELECT TOP 1 U05_001_C FROM StarWestconCALA2.dbo.U05 (NOLOCK) JOIN StarWestconCALA2.dbo.U06 (NOLOCK) ON U06.U05_UKEY=U05.UKEY JOIN StarWestconCALA2.dbo.U11 (NOLOCK) ON U11.U11_UKEYP = U06.UKEY JOIN StarWestconCALA2.dbo.E11 (NOLOCK) ON E11.E11_UKEYP = U11.UKEY WHERE E11.E10_UKEY=E10.UKEY)),
							(SELECT TOP 1 U05_001_C FROM StarWestconCALA2.dbo.U05 (NOLOCK) JOIN StarWestconCALA2.dbo.U06 (NOLOCK) ON U06.U05_UKEY=U05.UKEY JOIN StarWestconCALA2.dbo.U11 (NOLOCK) ON U11.U11_UKEYP = U06.UKEY JOIN StarWestconCALA2.dbo.U14 (NOLOCK) ON U14.U14_UKEYP = U11.UKEY JOIN StarWestconCALA2.dbo.E11 (NOLOCK) ON E11.E11_UKEYP = U14.UKEY WHERE E11.E10_UKEY=E10.UKEY)), '') OC,
					CASE WHEN B07.ARRAY_117 = 1 THEN B07.B07_001_B ELSE 0 END AS ValorDebito, 
					CASE WHEN B07.ARRAY_117 = 2 THEN B07.B07_001_B ELSE 0 END AS ValorCredito
					FROM StarWestconCALA2.dbo.B07 B07 WITH (NoLock)
					INNER JOIN StarWestconCALA2.dbo.B06 B06 WITH (NoLock) ON B07.B06_UKEY = B06.UKEY 
					INNER JOIN StarWestconCALA2.dbo.B11 B11 WITH (NoLock) ON B07.B11_UKEY = B11.UKEY 
					LEFT OUTER JOIN StarWestconCALA2.dbo.B05 B05 WITH (NoLock) ON B07.B05_UKEY = B05.UKEY
					LEFT OUTER JOIN StarWestconCALA2.dbo.B07 B07T (NOLOCK) ON B07T.B06_UKEY = B07.B06_UKEY AND B07T.B07_010_N = B07.B07_010_N AND B07T.ARRAY_117 <> B07.ARRAY_117				
					LEFT OUTER JOIN StarWestconCALA2.dbo.B11 B11T (NOLOCK) ON B07T.B11_UKEY = B11T.UKEY  
					LEFT JOIN StarWestconCALA2.dbo.E10  (NOLOCK) ON B07T.B07_UKEYP = E10.UKEY
					LEFT JOIN StarWestconCALA2.dbo.A03 E10_A03  (NOLOCK) ON E10.A03_UKEY = E10_A03.UKEY
					LEFT JOIN StarWestconCALA2.dbo.A08 E10_A08 (NOLOCK)  ON E10.A08_UKEY = E10_A08.UKEY
					LEFT JOIN StarWestconCALA2.dbo.J10  (NOLOCK) ON B07T.B07_UKEYP = J10.UKEY
					LEFT JOIN StarWestconCALA2.dbo.A03 J10_A03  (NOLOCK) ON J10.A03_UKEY = J10_A03.UKEY
					LEFT JOIN StarWestconCALA2.dbo.A08 J10_A08 (NOLOCK)  ON J10.A08_UKEY = J10_A08.UKEY
					WHERE B11.CIA_UKEY = 'M8530' AND B11.B11_001_C between @V_DeContaContabil and @V_AteContaContabil 
					AND B07.B07_003_D >= @V_Data_Inicial AND B07.B07_003_D  < DATEADD(dd, 1, @V_Data_Final)
			)TMP
			GROUP BY 
				ContaContabil, DebitoOuCredito, ValorLancamento, Historico, DataLancamento, Ordem, FatorDebito,
				FatorCredito, HistAux, ValorDebito, ValorCredito, Historico1, Historico2, NumeroLancamento

			ORDER BY 
			  DataLancamento, Ordem 

		END

END





