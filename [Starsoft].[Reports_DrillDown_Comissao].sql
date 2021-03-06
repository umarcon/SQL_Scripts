USE [Westcon]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- exec [Starsoft].[Reports_DrillDown_Comissao] '20160101','20160831'

alter PROCEDURE [Starsoft].[Reports_DrillDown_Comissao]
	@PLD_INITIAL DATE, -- Data de inicio da pesquisa
	@PLD_FINAL DATE -- Data final da pesquisa

AS
BEGIN


    declare @initial_date as date
	declare @final_date as date

	set @initial_date = @PLD_INITIAL
	set @final_date = @PLD_FINAL

	SET NOCOUNT ON;

	
	SELECT * 
	INTO #TMP_RAZAO
	FROM (
		-- Armazeno os lançamentos Contábeis na Conta de Clientes 2104040006
		SELECT * 
		FROM [Westcon].[Starsoft].[fnFinancialPostingsPerAccountPerPeriodBR](@initial_date,@final_date,'2104040006')
		-- Armazeno os lançamentos Contábeis na Conta de Clientes 2104040007
		UNION ALL
		SELECT * 
		FROM [Westcon].[Starsoft].[fnFinancialPostingsPerAccountPerPeriodBR](@initial_date,@final_date,'2104040007')
		-- Armazeno os lançamentos Contábeis na Conta de Clientes 2104040008
		UNION ALL
		SELECT * 
		FROM [Westcon].[Starsoft].[fnFinancialPostingsPerAccountPerPeriodBR](@initial_date,@final_date,'2104040008')
		)TMP
	ORDER BY OPERACAO, NUMERO_OPERACAO, VALORLANCAMENTO

	-- BUSCO TODAS AS NOTAS DE VENDA NO PERIODO INFORMADO QUE POSSUEM VALOR PARA INTEGRACAO COM O FINANCEIRO
	SELECT 
		J10.UKEY AS UKEY,
		J10.J10_001_C AS NF,
		CASE WHEN J10.J10_032_N = 1 THEN 0 ELSE ISNULL(SUM(round(F14.F14_010_B,2)),0) END AS VALOR,
		J10.J10_003_D AS EMISSAO,
		J10.J10_032_N AS CANCELADA,
		LTRIM(RTRIM(A03.A03_003_C)) AS CLIENTE,
		CAST('VENDA' AS CHAR(254)) AS OBS,
		CAST(CIA.CIA_001_C AS CHAR(254)) AS EMPRESA
	INTO #TMP_NF -- ARMAZENO AS NOTAS NO CURSOR TEMPORÁRIO DE NOTAS
	FROM
		StarWestcon.dbo.J10 J10 (NOLOCK)
		INNER JOIN StarWestcon.dbo.A03 A03 (NOLOCK) ON J10.A03_UKEY = A03.UKEY
		INNER JOIN StarWestcon.dbo.CIA CIA (NOLOCK) ON J10.CIA_UKEY = CIA.UKEY
		LEFT JOIN StarWestcon.dbo.J06 J06 (NOLOCK) ON J06.J06_UKEYP = J10.UKEY
		JOIN StarWestcon.dbo.F11 F11 (NOLOCK) ON F11.F11_IUKEYP = J10.UKEY AND F11.F11_016_C = '002' -- SOMENTE NOTAS QUE GERARAM COMISSÃO A PAGAR
		JOIN StarWestcon.dbo.F14 F14 (NOLOCK) ON F14.F11_UKEY = F11.UKEY
	WHERE
		J10.J10_002_N = 1 
		AND J10.J10_003_D BETWEEN @initial_date AND @final_date
		AND (J06.ARRAY_241 = 2 AND J06.J06_001_B > 0) -- NOTAS QUE POSSUEM VALOR PARA INTEGRACAO COM O FINANCEIRO
	GROUP BY
		J10.UKEY, J10.J10_001_C, J10.J10_003_D, A03.A03_003_C, J10.UKEY, J10.J10_032_N, CIA.CIA_001_C



	-- *******************************   QUERY DE NOTAS DE DEVOLUCAO DE VENDAS - INICIO ****************************************
	
	-- ARMAZENO AS NOTAS NO CURSOR TEMPORÁRIO DE NOTAS
	INSERT INTO #TMP_NF
	-- BUSCO TODAS AS NOTAS DE DEVOLUCAO DE VENDA DO PERIODO INFORMADO E OS VALORES GERADOS NO FINANCEIRO
	SELECT
		UKEY,
		NF,
		ROUND(VALOR_FINANCEIRO,2) AS VALOR,
		EMISSAO,
		CANCELADA,
		CLIENTE,
		CAST('DEVOLUCAO' AS CHAR(254)) AS OBS,
		CAST(EMPRESA AS CHAR(254)) AS EMPRESA
	FROM
		(
			-- NOTAS DE DEVOLUCAO QUE GERARAM ESTORNO DE CONTAS A RECEBER
			SELECT
				TMP_J10DEV.UKEY as UKEY,
				TMP_J10DEV.J10_001_C as NF,
				CASE WHEN TMP_J10DEV.J10_032_N = 1 THEN 0 ELSE ISNULL(MAX(J06.J06_001_B),0) END AS VALOR,
				TMP_J10DEV.J10_003_D AS EMISSAO,
				TMP_J10DEV.J10_032_N AS CANCELADA,
				RTRIM(A03.A03_003_C) AS CLIENTE,
				ISNULL(SUM(F16.F16_002_B),0) AS VALOR_FINANCEIRO,
				CIA.CIA_001_C AS EMPRESA
			FROM
				StarWestcon.dbo.J10 J10 (NOLOCK)
				INNER JOIN StarWestcon.dbo.CIA CIA (NOLOCK) ON J10.CIA_UKEY = CIA.UKEY
				INNER JOIN StarWestcon.dbo.F11 F11 (NOLOCK) ON F11.F11_IUKEYP = J10.UKEY
				INNER JOIN StarWestcon.dbo.F14 F14 (NOLOCK) ON F14.F11_UKEY = F11.UKEY
				INNER JOIN (	
								SELECT 
									J11.J10_UKEY AS UKEY_NFORIGEM,
									J10_DEV.UKEY AS UKEY,
									J10_DEV.J10_001_C AS J10_001_C,
									J10_DEV.J10_032_N AS J10_032_N,
									J10_DEV.J10_003_D AS J10_003_D,
									J10_DEV.J10_014_D AS J10_014_D,
									J10_DEV.A03_UKEY AS A03_UKEY
								FROM
									StarWestcon.dbo.J10 J10_DEV (NOLOCK) 
									INNER JOIN StarWestcon.dbo.J11 J11_DEV (NOLOCK) ON J11_DEV.J10_UKEY = J10_DEV.UKEY
									INNER JOIN StarWestcon.dbo.J11 J11 (NOLOCK) ON J11_DEV.J11_UKEYP = J11.UKEY
								GROUP BY
									J11.J10_UKEY, J10_DEV.UKEY, J10_DEV.A03_UKEY, J10_DEV.J10_001_C, J10_DEV.J10_032_N, J10_DEV.J10_003_D, J10_DEV.J10_014_D
							)TMP_J10DEV ON TMP_J10DEV.UKEY_NFORIGEM = J10.UKEY
				INNER JOIN StarWestcon.dbo.A03 A03 (NOLOCK) ON TMP_J10DEV.A03_UKEY = A03.UKEY
				LEFT JOIN StarWestcon.dbo.J06 J06 (NOLOCK) ON J06.J06_UKEYP = TMP_J10DEV.UKEY
				INNER JOIN StarWestcon.dbo.F18 F18 (NOLOCK) ON F18.F18_IUKEYP = J10.UKEY AND F18.F18_DUKEYP = TMP_J10DEV.UKEY
				INNER JOIN StarWestcon.dbo.F16 F16 (NOLOCK) ON F16.F18_UKEY = F18.UKEY AND F16.F14_UKEY = F14.UKEY--AND F16.F11_UKEY = F11.UKEY 
			WHERE
				J10.J10_002_N = 1 -- NOTAS DE VENDA
				AND F18.F18_002_C = '032' -- ESTORNO DE COMISSÃO A PAGAR
				AND TMP_J10DEV.J10_014_D BETWEEN @initial_date AND @final_date -- DATA DE ENTRADA DA NOTA
				AND (J06.ARRAY_241 = 2 AND J06.J06_001_B > 0) -- NOTAS QUE POSSUEM VALOR PARA INTEGRACAO COM O FINANCEIRO
			GROUP BY
				TMP_J10DEV.UKEY, TMP_J10DEV.J10_001_C, TMP_J10DEV.J10_003_D, A03.A03_003_C, TMP_J10DEV.UKEY, TMP_J10DEV.J10_032_N, CIA.CIA_001_C
		)TMP
	GROUP BY
		UKEY, NF, EMISSAO, CANCELADA, CLIENTE, EMPRESA, VALOR_FINANCEIRO
-- *******************************   QUERY DE NOTAS DE DEVOLUCAO DE VENDAS - FIM ****************************************	


	-- DIFERENCAS COM BASE NAS NF E DEVOLUCOES DE NF GERADAS
	--SELECT 
	--	CAST('NF' AS VARCHAR(254)) AS OPERACAO,
	--	CAST(TMP_NF.NF AS VARCHAR(254)) AS DOCUMENTO,
	--	TMP_NF.VALOR AS VALOR_DOCUMENTO,
	--	CAST(0 AS NUMERIC(16,8)) AS VALOR_QUITADO_PERIODO,
	--	CAST(0 AS NUMERIC(16,8)) AS VALOR_TOTAL_QUITADO,
	--	TMP_NF.EMISSAO AS EMISSAO,
	--	CAST(TMP_NF.CLIENTE AS VARCHAR(254)) AS CLIENTE,
	--	CAST(ISNULL(TMP_RAZAO.LANCAMENTO,'') AS VARCHAR(254)) AS LANCAMENTO,
	--	(SELECT SUM(ISNULL(#TMP_RAZAO.VALORLANCAMENTO,0)) FROM #TMP_RAZAO WHERE B06_UKEYP = TMP_NF.UKEY) AS VALOR_RAZAO,
	--	CAST(ISNULL(TMP_RAZAO.HISTORICO,'') AS VARCHAR(254)) AS HISTORICO,
	--	CAST(	CASE	WHEN TMP_NF.CANCELADA = 1 AND TMP_NF.VALOR = 0 THEN 'CANCELADO MAS TEM LANCAMENTO NA CONTABILIDADE' 
	--					WHEN TMP_NF.CANCELADA = 1 AND TMP_NF.VALOR > 0 THEN 'CANCELADO MAS TEM DOCUMENTO NO FINANCEIRO' 
	--					WHEN TMP_NF.VALOR = 0 THEN 'NAO TEM DOCUMENTO NO FINANCEIRO MAS TEM LANCAMENTO NA CONTABILIDADE' 
	--					WHEN TMP_NF.VALOR <> TMP_RAZAO.VALORLANCAMENTO THEN 'DIFERENCA ENTRE FINANCEIRO E CONTABILIDADE'
	--			ELSE  
	--					'SEM ERRO'
	--			END 
	--		AS CHAR(254)) AS MOTIVO,
	--	CAST(TMP_NF.OBS AS VARCHAR(254)) AS OBSERVACAO,
	--	TMP_NF.EMPRESA AS EMPRESA,
	--	TMP_NF.UKEY AS DOCUMENTO_UKEY
	SELECT 
	OPERACAO,
	DOCUMENTO,
	VALOR_DOCUMENTO,
	VALOR_QUITADO_PERIODO,
	VALOR_TOTAL_QUITADO,
	EMISSAO,
	CLIENTE,
	LANCAMENTO,
	VALOR_RAZAO,
	HISTORICO,
	CAST(CASE WHEN CANCELADA = 1 AND VALOR_DOCUMENTO = 0 THEN 'CANCELADO MAS TEM LANCAMENTO NA CONTABILIDADE' 
								WHEN CANCELADA = 1 AND VALOR_DOCUMENTO > 0 THEN 'CANCELADO MAS TEM DOCUMENTO NO FINANCEIRO' 
								WHEN VALOR_DOCUMENTO = 0 THEN 'NAO TEM DOCUMENTO NO FINANCEIRO MAS TEM LANCAMENTO NA CONTABILIDADE' 
								WHEN VALOR_DOCUMENTO = VALOR_RAZAO THEN 'SEM ERRO'
						ELSE  
								'DIFERENCA ENTRE FINANCEIRO E CONTABILIDADE'
						END 
					AS CHAR(254)) AS MOTIVO,
	OBSERVACAO,
	EMPRESA,
	DOCUMENTO_UKEY
	INTO #TMP_RESULTADO -- ARMAZENO AS NOTAS QUE APRESENTARAM DIFERENÇA EM UM CURSOR TEMPORÁRIO
	FROM (
		SELECT 
				CAST('NF' AS VARCHAR(254)) AS OPERACAO,
				CAST(TMP_NF.NF AS VARCHAR(254)) AS DOCUMENTO,
				CAST(TMP_NF.VALOR AS MONEY) AS VALOR_DOCUMENTO,
				CAST(0 AS NUMERIC(16,8)) AS VALOR_QUITADO_PERIODO,
				CAST(0 AS NUMERIC(16,8)) AS VALOR_TOTAL_QUITADO,
				TMP_NF.EMISSAO AS EMISSAO,
				CAST(TMP_NF.CLIENTE AS VARCHAR(254)) AS CLIENTE,
				CAST(ISNULL(TMP_RAZAO.LANCAMENTO,'') AS VARCHAR(254)) AS LANCAMENTO,
				(SELECT SUM(ISNULL(#TMP_RAZAO.VALORLANCAMENTO,0)) FROM #TMP_RAZAO WHERE B06_UKEYP = TMP_NF.UKEY) AS VALOR_RAZAO,
				--TMP_RAZAO.VALORLANCAMENTO AS VALOR_RAZAO,
				CAST(ISNULL(TMP_RAZAO.HISTORICO,'') AS VARCHAR(254)) AS HISTORICO,
				TMP_NF.CANCELADA AS CANCELADA,
				CAST(TMP_NF.OBS AS VARCHAR(254)) AS OBSERVACAO,
				TMP_NF.EMPRESA AS EMPRESA,
				TMP_NF.UKEY AS DOCUMENTO_UKEY
		FROM #TMP_NF AS TMP_NF
		JOIN #TMP_RAZAO AS TMP_RAZAO ON TMP_RAZAO.B06_UKEYP = TMP_NF.UKEY OR ( TMP_RAZAO.OPERACAO = 'NF' AND TMP_RAZAO.NUMERO_OPERACAO = TMP_NF.NF AND TMP_RAZAO.CLIENTE_OPERACAO = TMP_NF.CLIENTE )
		)TMP
	--GROUP BY TMP_NF.UKEY, TMP_NF.NF, TMP_NF.VALOR, TMP_NF.EMISSAO, TMP_NF.CLIENTE, TMP_RAZAO.LANCAMENTO, TMP_RAZAO.HISTORICO, TMP_NF.EMPRESA, TMP_NF.CANCELADA, TMP_RAZAO.VALORLANCAMENTO, TMP_NF.OBS

	-- DELETO TODAS AS NF QUE JÁ FORAM TRATADAS
	DELETE #TMP_NF WHERE UKEY IN (SELECT DOCUMENTO_UKEY FROM #TMP_RESULTADO)
	-- DELETO TODOS OS LANCAMENTOS QUE JÁ FORAM TRATADOS
	DELETE #TMP_RAZAO WHERE LANCAMENTO IN (SELECT LANCAMENTO FROM #TMP_RESULTADO)

	-- ARMAZENO AS NOTAS QUE APRESENTARAM DIFERENÇA EM UM CURSOR TEMPORÁRIO
	INSERT INTO #TMP_RESULTADO 
	-- NF SEM TRATAMENTO
	SELECT 
			'NF' AS OPERACAO,
			TMP_NF.NF AS DOCUMENTO,
			TMP_NF.VALOR AS VALOR_DOCUMENTO,
			0 AS VALOR_QUITADO_PERIODO,
			0 AS VALOR_TOTAL_QUITADO,
			TMP_NF.EMISSAO AS EMISSAO,
			TMP_NF.CLIENTE AS CLIENTE,
			NULL AS LANCAMENTO,
			0 AS VALOR_RAZAO,
			NULL AS HISTORICO,
			CAST( CASE WHEN TMP_NF.CANCELADA = 1 AND TMP_NF.VALOR > 0 THEN 'CANCELADO MAS TEM DOCUMENTO NO FINANCEIRO' WHEN TMP_NF.CANCELADA = 0 AND TMP_NF.VALOR > 0 THEN 'NAO TEM LANCAMENTO NA CONTABILIDADE'  ELSE 'SEM ERRO' END AS CHAR(254)) AS MOTIVO,
			RTRIM(TMP_NF.OBS) + ' - ' + CASE WHEN TMP_NF.CANCELADA = 1 THEN 'CANCELADA' ELSE '' END  AS OBSERVACAO,
			TMP_NF.EMPRESA AS EMPRESA,
			TMP_NF.UKEY AS DOCUMENTO_UKEY
	FROM #TMP_NF AS TMP_NF

	-- Busco todas as quitações no Período
	SELECT 
		RTRIM(F11_001_C) AS TITULO,
		RTRIM(F14_001_C) AS PARCELA,
		RTRIM(F11_001_C) + '-' + RTRIM(F14_001_C) AS TITULO_PARCELA,
		ROUND(F14.F14_010_B,2) AS VALOR_PARCELA,
		SUM(ROUND(F16.F16_013_B,2)) AS VALOR_QUITADO_PERIODO,
		SUM(ROUND(F16.F16_008_B,2)) AS ABATIMENTO,		
		SUM(ROUND(F16.F16_018_B + F16.F16_006_B + F16.F16_009_B + F16.F16_010_B,2)) AS JUROS,
		ISNULL((SELECT ROUND(SUM(F16T.F16_018_B + F16T.F16_006_B + F16T.F16_009_B + F16T.F16_010_B),2) FROM STARWESTCON.DBO.F16 F16T (NOLOCK) JOIN STARWESTCON.DBO.F18 F18T (NOLOCK) ON F16T.F18_UKEY = F18T.UKEY WHERE F16T.F14_UKEY = F14.UKEY AND F16T.F16_005_C = '002' AND F18T.F18_004_N = 1),0) AS VALOR_TOTA_JUROS,
		ISNULL((SELECT ROUND(SUM(F16T.F16_008_B),2) FROM STARWESTCON.DBO.F16 F16T (NOLOCK) JOIN STARWESTCON.DBO.F18 F18T (NOLOCK) ON F16T.F18_UKEY = F18T.UKEY WHERE F16T.F14_UKEY = F14.UKEY AND F16T.F16_005_C = '032' AND F18T.F18_004_N = 1),0) AS VALOR_TOTA_ABATIMENTO,
		ISNULL((SELECT ROUND(SUM(F16T.F16_003_B),2) FROM STARWESTCON.DBO.F16 F16T (NOLOCK) JOIN STARWESTCON.DBO.F18 F18T (NOLOCK) ON F16T.F18_UKEY = F18T.UKEY WHERE F16T.F14_UKEY = F14.UKEY AND F16T.F16_005_C = '032' AND F18T.F18_004_N = 1),0) AS VALOR_TOTAL_QUITADO,
		(SELECT B06_001_C FROM STARWESTCON.DBO.B06 (NOLOCK) WHERE B06_UKEYP = F18.UKEY) AS LANCAMENTO,
		(SELECT top 1 convert(varchar (8000),B07.B07_002_M) FROM STARWESTCON.DBO.B07 (NOLOCK) WHERE B07_UKEYP = F16.UKEY) AS HISTORICO,
		LTRIM(RTRIM(A03_003_C)) AS CLIENTE,
		CAST(CIA.CIA_001_C AS CHAR(254)) AS EMPRESA,
		F18.F18_003_D AS EMISSAO_QUITACAO,
		F11.UKEY AS F11_UKEY,
		F14.UKEY AS F14_UKEY,
		F16.UKEY AS F16_UKEY 
	INTO #TMP_QUITACAO
	FROM 
		StarWestcon.dbo.F18 F18 (NOLOCK)
		JOIN StarWestcon.dbo.F16 F16 (NOLOCK) ON F16.F18_UKEY = F18.UKEY AND F16.F16_005_C = '032' -- SOMENTE QUITACAO
		JOIN StarWestcon.dbo.F11 F11 (NOLOCK) ON F16.F11_UKEY = F11.UKEY
		JOIN StarWestcon.dbo.CIA CIA (NOLOCK) ON F11.CIA_UKEY = CIA.UKEY
		JOIN StarWestcon.dbo.F14 F14 (NOLOCK) ON F16.F14_UKEY = F14.UKEY
		JOIN StarWestcon.dbo.A03 A03 (NOLOCK) ON F11.A03_UKEY = A03.UKEY
	WHERE 
		F18.F18_002_C = '032' AND 
		F18.F18_004_N = 1 AND -- Indica que a Quitação foi Efetuada
		F18.F18_003_D BETWEEN @initial_date AND @final_date -- Emissão Quitacao
	GROUP BY
		F11.F11_001_C, 
		F14.F14_001_C, 
		F14.F14_010_B,
		A03_003_C,
		CIA.CIA_001_C,
		F18.F18_003_D,
		F11.UKEY,
		F14.UKEY,
		F16.UKEY,
		F18.UKEY

	-- ARMAZENO AS NOTAS QUE APRESENTARAM DIFERENÇA EM UM CURSOR TEMPORÁRIO
	INSERT INTO #TMP_RESULTADO 
	-- DIFERENCAS ENTRE OS TITULOS E PARCELAS MOVIMENTADOS NO PERIODO
	SELECT	OPERACAO,  
			DOCUMENTO,
			VALOR_DOCUMENTO,
			VALOR_QUITADO_PERIODO,
			VALOR_TOTAL_QUITADO,
			EMISSAO,
			CLIENTE,
			LANCAMENTO,
			VALOR_RAZAO,
			HISTORICO,
			CASE	
				WHEN (VALOR_QUITADO_PERIODO + ABATIMENTO - JUROS) <> VALOR_RAZAO THEN 'DIFERENCA ENTRE FINANCEIRO E CONTABILIDADE2'
				WHEN VALOR_TOTAL_QUITADO > VALOR_PARCELA - VALOR_TOTA_ABATIMENTO + VALOR_TOTA_JUROS THEN 'VALOR QUITADO MAIOR QUE O VALOR DA PARCELA'
			ELSE  
				'SEM ERRO'
			END AS MOTIVO,	
			OBSERVACAO,
			EMPRESA,
			DOCUMENTO_UKEY
	FROM (
		SELECT 
			'CP' AS OPERACAO,
			TMP_QUITACAO.TITULO +'-'+ TMP_QUITACAO.PARCELA AS DOCUMENTO,
			TMP_QUITACAO.VALOR_PARCELA AS VALOR_DOCUMENTO,
			TMP_QUITACAO.VALOR_QUITADO_PERIODO AS VALOR_QUITADO_PERIODO,
			TMP_QUITACAO.VALOR_TOTAL_QUITADO AS VALOR_TOTAL_QUITADO,
			--CASE WHEN COUNT(1) = 1 
			--	THEN CAST((SELECT TOP 1 TMP_RAZAO.DATALANCAMENTO FROM #TMP_RAZAO AS TMP_RAZAO WHERE TMP_RAZAO.OPERACAO = 'CP' AND TMP_QUITACAO.TITULO_PARCELA = TMP_RAZAO.NUMERO_OPERACAO) AS VARCHAR(254))
			--ELSE
			--	NULL
			--END AS EMISSAO,		
			TMP_QUITACAO.EMISSAO_QUITACAO AS EMISSAO,
			TMP_RAZAO.CLIENTE_OPERACAO AS CLIENTE,
			--CASE WHEN COUNT(1) = 1 
			--	THEN CAST((SELECT TOP 1 TMP_RAZAO.LANCAMENTO FROM #TMP_RAZAO AS TMP_RAZAO WHERE TMP_RAZAO.OPERACAO = 'CP' AND TMP_QUITACAO.TITULO_PARCELA = TMP_RAZAO.NUMERO_OPERACAO) AS VARCHAR(254))
			--ELSE
			--	CAST('TEM MAIS DE UM LANCAMENTO NO PERIODO' AS VARCHAR(254))
			--END AS LANCAMENTO,
			TMP_QUITACAO.LANCAMENTO,
			(SELECT SUM(#TMP_RAZAO.VALORLANCAMENTO) FROM #TMP_RAZAO WHERE B07_UKEYP = TMP_QUITACAO.F16_UKEY) AS VALOR_RAZAO,
			--CASE WHEN COUNT(1) = 1 
			--	THEN CAST((SELECT TOP 1 TMP_RAZAO.HISTORICO FROM #TMP_RAZAO AS TMP_RAZAO WHERE TMP_RAZAO.OPERACAO = 'CP' AND TMP_QUITACAO.TITULO_PARCELA = TMP_RAZAO.NUMERO_OPERACAO) AS VARCHAR(254))
			--ELSE
			--	CAST('TEM MAIS DE UM LANCAMENTO NO PERIODO' AS VARCHAR(254))
			--END AS HISTORICO,		
			TMP_QUITACAO.HISTORICO,
			--round(SUM(TMP_QUITACAO.VALOR_QUITADO_PERIODO),2) AS VALOR_QUITADO_PERIODO,
			round(sum(TMP_QUITACAO.ABATIMENTO),2) AS ABATIMENTO,
			round(sum(TMP_QUITACAO.JUROS),2) AS JUROS,
			'ESTORNO CP' AS OBSERVACAO,
			TMP_QUITACAO.EMPRESA AS EMPRESA,
			TMP_QUITACAO.VALOR_PARCELA AS VALOR_PARCELA,
			TMP_QUITACAO.VALOR_TOTA_ABATIMENTO AS VALOR_TOTA_ABATIMENTO,
			TMP_QUITACAO.VALOR_TOTA_JUROS AS VALOR_TOTA_JUROS,
			TMP_QUITACAO.F16_UKEY AS DOCUMENTO_UKEY	
		FROM 
			#TMP_QUITACAO AS TMP_QUITACAO
			JOIN (SELECT OPERACAO,NUMERO_OPERACAO,DATALANCAMENTO,CLIENTE_OPERACAO,SUM(VALORLANCAMENTO) AS VALORLANCAMENTO, B07_UKEYP,B07_PAR FROM #TMP_RAZAO GROUP BY OPERACAO,NUMERO_OPERACAO,DATALANCAMENTO,CLIENTE_OPERACAO,B07_UKEYP,B07_PAR) AS TMP_RAZAO ON (TMP_RAZAO.B07_UKEYP = TMP_QUITACAO.F16_UKEY AND TMP_RAZAO.B07_PAR ='F16') OR ( TMP_RAZAO.OPERACAO = '' AND TMP_QUITACAO.TITULO_PARCELA = TMP_RAZAO.NUMERO_OPERACAO AND TMP_QUITACAO.EMISSAO_QUITACAO = TMP_RAZAO.DATALANCAMENTO AND TMP_QUITACAO.CLIENTE = TMP_RAZAO.CLIENTE_OPERACAO) 
		GROUP BY
			TMP_QUITACAO.TITULO_PARCELA,
			TMP_QUITACAO.VALOR_PARCELA,
			TMP_QUITACAO.VALOR_TOTAL_QUITADO,
			TMP_RAZAO.CLIENTE_OPERACAO,
			TMP_QUITACAO.EMPRESA,
			TMP_QUITACAO.F14_UKEY,
			TMP_QUITACAO.LANCAMENTO,
			TMP_QUITACAO.HISTORICO,
			TMP_QUITACAO.TITULO,
			TMP_QUITACAO.PARCELA,
			TMP_QUITACAO.EMISSAO_QUITACAO,
			TMP_QUITACAO.VALOR_QUITADO_PERIODO,
			TMP_QUITACAO.F16_UKEY,
			TMP_QUITACAO.ABATIMENTO,
			TMP_QUITACAO.JUROS,
			TMP_QUITACAO.VALOR_TOTA_ABATIMENTO,
			TMP_QUITACAO.VALOR_TOTA_JUROS
		)TMP

	-- DELETO TODAS AS PARCELAS QUE JÁ FORAM TRATADAS
	DELETE #TMP_QUITACAO WHERE F16_UKEY IN (SELECT DOCUMENTO_UKEY FROM #TMP_RESULTADO)
	-- DELETO TODOS OS LANCAMENTOS QUE JÁ FORAM TRATADOS
	DELETE #TMP_RAZAO 
	FROM #TMP_RAZAO AS TMP_RAZAO
	JOIN #TMP_RESULTADO AS TMP_RESULTADO ON TMP_RESULTADO.DOCUMENTO_UKEY = TMP_RAZAO.B07_UKEYP -- ltrim(rtrim(TMP_RESULTADO.DOCUMENTO)) = ltrim(rtrim(TMP_RAZAO.NUMERO_OPERACAO)) AND ltrim(rtrim(TMP_RESULTADO.CLIENTE)) = ltrim(rtrim(TMP_RAZAO.CLIENTE_OPERACAO))
	WHERE TMP_RAZAO.OPERACAO = ''

	-- ARMAZENO AS NOTAS QUE APRESENTARAM DIFERENÇA EM UM CURSOR TEMPORÁRIO
	INSERT INTO #TMP_RESULTADO 
	-- PARCELAS SEM TRATAMENTO
	SELECT 
		'CP' AS OPERACAO,
		TMP_QUITACAO.TITULO + '-'+ TMP_QUITACAO.PARCELA AS DOCUMENTO,
		TMP_QUITACAO.VALOR_PARCELA AS VALOR_DOCUMENTO,
		TMP_QUITACAO.VALOR_QUITADO_PERIODO AS VALOR_QUITADO_PERIODO,
		TMP_QUITACAO.VALOR_TOTAL_QUITADO AS VALOR_TOTAL_QUITADO,
		TMP_QUITACAO.EMISSAO_QUITACAO AS EMISSAO,
		TMP_QUITACAO.CLIENTE AS CLIENTE,
		NULL AS LANCAMENTO,
		0 AS VALOR_RAZAO,
		NULL AS HISTORICO,
		'NAO TEM LANCAMENTO NA CONTABILIDADE' AS MOTIVO,
		'ESTORNO CP' AS OBSERVACAO,
		TMP_QUITACAO.EMPRESA AS EMPRESA,
		TMP_QUITACAO.F14_UKEY AS DOCUMENTO_UKEY
	FROM 
		#TMP_QUITACAO AS TMP_QUITACAO
		
	
	-- ARMAZENO AS NOTAS QUE APRESENTARAM DIFERENÇA EM UM CURSOR TEMPORÁRIO
	INSERT INTO #TMP_RESULTADO 
	-- LANCAMENTOS SEM OPERACAO
	SELECT 
			'LC' AS OPERACAO,
			ISNULL(TMP_RAZAO.NUMERO_OPERACAO,'') AS DOCUMENTO,
			0 AS VALOR_DOCUMENTO,
			0 AS VALOR_QUITADO_PERIODO,
			0 AS VALOR_TOTAL_QUITADO,
			TMP_RAZAO.DATALANCAMENTO AS EMISSAO,
			ISNULL(TMP_RAZAO.CLIENTE_OPERACAO,'') AS CLIENTE,
			TMP_RAZAO.lancamento AS LANCAMENTO,
			TMP_RAZAO.valorlancamento AS VALOR_RAZAO,
			ISNULL(TMP_RAZAO.HISTORICO,'') AS HISTORICO,
			CAST( 'LANCAMENTO SEM HISTORICO OU DE OPERACAO NAO TRATADA PELO RELATORIO' AS CHAR(254)) AS MOTIVO,
			CAST('LANÇAMENTO' AS CHAR(254)) AS OBSERVACAO,
			CIA_001_C AS EMPRESA,
			TMP_RAZAO.B06_UKEY AS DOCUMENTO_UKEY
	FROM #TMP_RAZAO AS TMP_RAZAO
		JOIN STARWESTCON.DBO.CIA (NOLOCK) ON TMP_RAZAO.CIA_UKEY = CIA.UKEY


	-- ARMAZENO OS TITULOS QUE APRESENTARAM DIFERENÇA EM UM CURSOR TEMPORÁRIO
	INSERT INTO #TMP_RESULTADO 
	-- VERIFICO SE EXISTE ALGUM TITULO NO FINANCEIRO QUE NÃO POSSUÍ NF DE ORIGEM
	SELECT 
		'CP' AS OPERACAO,
		RTRIM(F11_001_C) + '-' + RTRIM(F14_001_C) AS DOCUMENTO,
		F11.F11_013_B AS VALOR_DOCUMENTO,
		ISNULL((SELECT ROUND(SUM(F16T.F16_002_B),2) FROM STARWESTCON.DBO.F16 F16T (NOLOCK) JOIN STARWESTCON.DBO.F18 F18T (NOLOCK) ON F16T.F18_UKEY = F18T.UKEY WHERE F16T.F14_UKEY = F14.UKEY AND F16T.F16_005_C = '032' AND F18T.F18_004_N = 1 AND F18T.F18_003_D BETWEEN @initial_date AND @final_date),0) AS VALOR_QUITADO_PERIODO,
		ISNULL((SELECT ROUND(SUM(F16T.F16_002_B),2) FROM STARWESTCON.DBO.F16 F16T (NOLOCK) JOIN STARWESTCON.DBO.F18 F18T (NOLOCK) ON F16T.F18_UKEY = F18T.UKEY WHERE F16T.F14_UKEY = F14.UKEY AND F16T.F16_005_C = '032' AND F18T.F18_004_N = 1),0) AS VALOR_TOTAL_QUITADO,		
		F11.F11_002_D AS EMISSAO,
		RTRIM(A03.A03_003_C) AS CLIENTE,
		'' AS LANCAMENTO,
		0  AS VALOR_RAZAO,
		'' AS HISTORICO,
		CAST( 'CP SEM NOTA FISCAL DE ORIGEM' AS CHAR(254)) AS MOTIVO,
		CAST('COMISSÃO' AS CHAR(254)) AS OBSERVACAO,
		CAST(CIA.CIA_001_C AS CHAR(254)) AS EMPRESA,
		F14.UKEY AS DOCUMENTO_UKEY
	FROM
		StarWestcon.dbo.F11 F11 (NOLOCK)
		JOIN StarWestcon.dbo.F14 F14 (NOLOCK) ON F14.F11_UKEY = F14.UKEY
		JOIN StarWestcon.dbo.A03 A03 (NOLOCK) ON F11.F11_UKEYP = A03.UKEY
		JOIN StarWestcon.dbo.CIA CIA (NOLOCK) ON F11.CIA_UKEY = CIA.UKEY
	WHERE
		F11.F11_016_C = '002' -- COMISSÃO A PAGAR
		AND F11.F11_002_D BETWEEN @initial_date AND @final_date
		AND ISNULL(F11.F11_IUKEYP,'') <> ''
		AND F11.F11_IUKEYP NOT IN ( SELECT J10.UKEY FROM StarWestcon.dbo.J10 J10 (NOLOCK) )	

	-- MOSTRO AS NOTAS QUE APRESENTARAM DIFERENÇAS
	SELECT 
			LTRIM(RTRIM(OPERACAO)) AS OPERACAO,
			LTRIM(RTRIM(DOCUMENTO)) AS DOCUMENTO,
			CAST(VALOR_DOCUMENTO AS money) AS VALOR_DOCUMENTO,
			CAST(VALOR_QUITADO_PERIODO AS DECIMAL(10,2)) AS VALOR_QUITADO_PERIODO,
			CAST(VALOR_TOTAL_QUITADO AS DECIMAL(10,2)) AS VALOR_TOTAL_QUITADO,
			CONVERT(VARCHAR(10),EMISSAO, 105) AS EMISSAO,
			LTRIM(RTRIM(CLIENTE)) AS CLIENTE,
			LTRIM(RTRIM(LANCAMENTO)) AS LANCAMENTO,
			CAST(VALOR_RAZAO AS money) AS VALOR_RAZAO,
			LTRIM(RTRIM(HISTORICO)) AS HISTORICO,
			LTRIM(RTRIM(MOTIVO)) AS MOTIVO,
			LTRIM(RTRIM(OBSERVACAO)) AS OBSERVACAO,
			LTRIM(RTRIM(EMPRESA)) AS EMPRESA,
			LTRIM(RTRIM(DOCUMENTO_UKEY)) AS DOCUMENTO_UKEY
	 FROM 
		#TMP_RESULTADO AS TMP_RESULTADO
	 ORDER 
		BY OPERACAO, DOCUMENTO, CLIENTE

	-- APAGO OS CURSORES TEMPORÁRIOS
	DROP TABLE #TMP_RAZAO
	DROP TABLE #TMP_NF
	DROP TABLE #TMP_QUITACAO
	DROP TABLE #TMP_RESULTADO

END