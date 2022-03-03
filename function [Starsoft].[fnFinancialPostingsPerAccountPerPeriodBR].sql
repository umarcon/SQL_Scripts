USE [Westcon]
GO
/****** Object:  UserDefinedFunction [Starsoft].[fnFinancialPostingsPerAccountPerPeriodBR]    Script Date: 05/01/2017 14:37:43 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
Alterado por: Thiago Rodrigues
Data: 12-05-2015
incluido as colunas B07_PAR e B07_UKEYP
Atividade 14527 do Scrum 
*/

ALTER function [Starsoft].[fnFinancialPostingsPerAccountPerPeriodBR]
(
      @Data_Inicial date, -- Data inicial
      @Data_Final date, -- Data Final
      @Conta_Contabil varchar(20) -- Código da conta contábil
)
returns table
AS
return
(

	SELECT	
			Lancamento,
			ContaContabil,
			CASE WHEN 
				COUNT(1) > 1 
			THEN 
				'DIVERSOS '  + CASE WHEN DebitoOuCredito = 1 THEN 'CREDITOS' ELSE 'DEBITOS' END
			ELSE 
				max(Contrapartida)
			END AS Contrapartida, 
			DebitoOuCredito,
			ValorLancamento,
			Historico,
			Westcon.Starsoft.GetHistoricalAccountingInformationSeparated(Historico , 1) as OPERACAO,
			replace(Westcon.Starsoft.GetHistoricalAccountingInformationSeparated(Historico , 2),'/','-') as NUMERO_OPERACAO,
			Westcon.Starsoft.GetHistoricalAccountingInformationSeparated(Historico , 3) as CLIENTE_OPERACAO,
			DataLancamento,
			Ordem,
			FatorDebito,
			FatorCredito,
			HistAux,
			ValorDebito,
			ValorCredito,
			B06_PAR, 
			B06_UKEYP,
			B07_PAR,
			B07_UKEYP,
			B06_UKEY,
			CIA_UKEY
	FROM (
			SELECT     TOP 100 PERCENT 
			B06.B06_001_C AS LANCAMENTO,
			B11.B11_001_C AS ContaContabil, 
			B11T.B11_003_C AS Contrapartida, 
			B07.ARRAY_117 AS DebitoOuCredito, 
			B07.B07_001_B AS ValorLancamento, 
			convert(varchar (8000),B07.B07_002_M) as Historico, 
			B07.B07_003_D AS DataLancamento, 
			B07.B07_013_C AS Ordem, 
			B07.B07_011_N AS FatorDebito, 
			B07.B07_012_N AS FatorCredito, 
			B05.B05_002_C AS HistAux, 
			CASE WHEN B07.ARRAY_117 = 1 THEN B07.B07_001_B ELSE 0 END AS ValorDebito, 
			CASE WHEN B07.ARRAY_117 = 2 THEN B07.B07_001_B ELSE 0 END AS ValorCredito,
			B06.B06_PAR AS B06_PAR,
			B06.B06_UKEYP AS B06_UKEYP,
			B07.B07_PAR AS B07_PAR,
			B07.B07_UKEYP AS B07_UKEYP,
			B06.UKEY AS B06_UKEY,
			B06.CIA_UKEY 
			FROM StarWestcon.dbo.B07 B07 WITH (NoLock)
			INNER JOIN StarWestcon.dbo.B06 B06 WITH (NoLock) ON B07.B06_UKEY = B06.UKEY 
			INNER JOIN StarWestcon.dbo.B11 B11 WITH (NoLock) ON B07.B11_UKEY = B11.UKEY 
			LEFT OUTER JOIN StarWestcon.dbo.B05 B05 WITH (NoLock) ON B07.B05_UKEY = B05.UKEY
			LEFT OUTER JOIN StarWestcon.dbo.B07 B07T (NOLOCK) ON B07T.B06_UKEY = B07.B06_UKEY AND B07T.B07_010_N = B07.B07_010_N AND B07T.ARRAY_117 <> B07.ARRAY_117				
			LEFT OUTER JOIN StarWestcon.dbo.B11 B11T (NOLOCK) ON B07T.B11_UKEY = B11T.UKEY  
			WHERE B11.B11_001_C = @Conta_Contabil 
			AND B07.B07_003_D >= @Data_Inicial AND B07.B07_003_D  < DATEADD(dd, 1, @Data_Final)
	)TMP
	GROUP BY 
		Lancamento, ContaContabil, DebitoOuCredito, ValorLancamento, Historico, DataLancamento, Ordem, FatorDebito,
		FatorCredito, HistAux, ValorDebito, ValorCredito, B06_PAR, B06_UKEYP,B07_PAR, B07_UKEYP, B06_UKEY, CIA_UKEY
      
)






