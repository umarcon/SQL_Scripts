--Criado por Ulisses Marcon para atender a atividade 1109
CREATE PROCEDURE [Starsoft].[Reports_252_CA]
	@PLD_INITIAL DATE, -- Data de inicio da pesquisa
	@PLD_FINAL DATE -- Data final da pesquisa

AS
BEGIN

    declare @initial_date as date
	declare @final_date as date

    set @initial_date = @PLD_INITIAL
	set @final_date = @PLD_FINAL

-- Armazeno os lan�amentos Cont�beis na Conta de Clientes 1102010001
	SELECT * 
	INTO #TMP_RAZAO
	FROM [Starsoft].[fnReports_252_CA](@initial_date,@final_date)
	ORDER BY OPERACAO, NUMERO_OPERACAO, VALORLANCAMENTO

	-- BUSCO TODAS AS NOTAS DE VENDA NO PERIODO INFORMADO QUE POSSUEM VALOR PARA INTEGRACAO COM O FINANCEIRO
	SELECT 
		J10.UKEY AS UKEY,
		J10.J10_001_C AS NF,
		CASE WHEN J10.J10_032_N = 1 THEN 0 ELSE ISNULL(SUM(F13.F13_010_B),0) END AS VALOR,
		J10.J10_003_D AS EMISSAO,
		J10.J10_032_N AS CANCELADA,
		LTRIM(RTRIM(A03.A03_003_C)) AS CLIENTE,
		CAST('FACTURA DE VENTA' AS CHAR(254)) AS OBS,
		CAST(CIA.CIA_001_C AS CHAR(254)) AS EMPRESA
	INTO #TMP_NF -- ARMAZENO AS NOTAS NO CURSOR TEMPOR�RIO DE NOTAS
	FROM
		StarWestconCala2.dbo.J10 J10 (NOLOCK)
		INNER JOIN StarWestconCala2.dbo.A03 A03 (NOLOCK) ON J10.A03_UKEY = A03.UKEY
		INNER JOIN StarWestconCala2.dbo.CIA CIA (NOLOCK) ON J10.CIA_UKEY = CIA.UKEY
		LEFT JOIN StarWestconCala2.dbo.J06 J06 (NOLOCK) ON J06.J06_UKEYP = J10.UKEY
		LEFT JOIN StarWestconCala2.dbo.F12 F12 (NOLOCK) ON F12.F12_IUKEYP = J10.UKEY AND F12.F12_016_C = '001' -- SOMENTE NOTAS QUE GERARAM CONTAS A RECEBER
		LEFT JOIN StarWestconCala2.dbo.F13 F13 (NOLOCK) ON F13.F12_UKEY = F12.UKEY
	WHERE
		J10.CIA_UKEY = 'STAR_'
		AND J10.J10_002_N = 1 
		AND J10.J10_003_D BETWEEN @initial_date AND @final_date
		AND (J06.ARRAY_241 = 2 AND J06.J06_001_B > 0) -- NOTAS QUE POSSUEM VALOR PARA INTEGRACAO COM O FINANCEIRO
	GROUP BY
		J10.UKEY, J10.J10_001_C, J10.J10_003_D, A03.A03_003_C, J10.UKEY, J10.J10_032_N, CIA.CIA_001_C



	-- *******************************   QUERY DE NOTAS DE DEVOLUCAO DE VENDAS - INICIO ****************************************
	
	-- ARMAZENO AS NOTAS NO CURSOR TEMPOR�RIO DE NOTAS
	INSERT INTO #TMP_NF
	-- BUSCO TODAS AS NOTAS DE DEVOLUCAO DE VENDA DO PERIODO INFORMADO E OS VALORES GERADOS NO FINANCEIRO
	SELECT
		UKEY,
		NF,
		ROUND(SUM(VALOR_FINANCEIRO),2) AS VALOR,
		EMISSAO,
		CANCELADA,
		CLIENTE,
		CAST('DEVOLUCI�N DE FACTURA DE VENTA' AS CHAR(254)) AS OBS,
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
				ISNULL(SUM(F15.F15_002_B),0) AS VALOR_FINANCEIRO,
				CIA.CIA_001_C AS EMPRESA
			FROM
				StarWestconCala2.dbo.J10 J10 (NOLOCK)
				INNER JOIN StarWestconCala2.dbo.CIA CIA (NOLOCK) ON J10.CIA_UKEY = CIA.UKEY
				INNER JOIN StarWestconCala2.dbo.F12 F12 (NOLOCK) ON F12.F12_IUKEYP = J10.UKEY
				INNER JOIN StarWestconCala2.dbo.F13 F13 (NOLOCK) ON F13.F12_UKEY = F12.UKEY
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
									StarWestconCala2.dbo.J10 J10_DEV (NOLOCK) 
									INNER JOIN StarWestconCala2.dbo.J11 J11_DEV (NOLOCK) ON J11_DEV.J10_UKEY = J10_DEV.UKEY AND J10_DEV.CIA_UKEY = 'STAR_'
									INNER JOIN StarWestconCala2.dbo.J11 J11 (NOLOCK) ON J11_DEV.J11_UKEYP = J11.UKEY
								GROUP BY
									J11.J10_UKEY, J10_DEV.UKEY, J10_DEV.A03_UKEY, J10_DEV.J10_001_C, J10_DEV.J10_032_N, J10_DEV.J10_003_D, J10_DEV.J10_014_D
							)TMP_J10DEV ON TMP_J10DEV.UKEY_NFORIGEM = J10.UKEY
				INNER JOIN StarWestconCala2.dbo.A03 A03 (NOLOCK) ON TMP_J10DEV.A03_UKEY = A03.UKEY
				LEFT JOIN StarWestconCala2.dbo.J06 J06 (NOLOCK) ON J06.J06_UKEYP = TMP_J10DEV.UKEY
				INNER JOIN StarWestconCala2.dbo.F18 F18 (NOLOCK) ON F18.F18_IUKEYP = J10.UKEY AND F18.F18_DUKEYP = TMP_J10DEV.UKEY
				INNER JOIN StarWestconCala2.dbo.F15 F15 (NOLOCK) ON F15.F18_UKEY = F18.UKEY AND F15.F12_UKEY = F12.UKEY AND F15.F13_UKEY = F13.UKEY
			WHERE
				J10.CIA_UKEY = 'STAR_'
				AND J10.J10_002_N = 1 -- NOTAS DE VENDA
				AND F18.F18_002_C = '031' -- ESTORNO DE CONTAS A RECEBER
				AND TMP_J10DEV.J10_014_D BETWEEN @initial_date AND @final_date -- DATA DE ENTRADA DA NOTA
				AND (J06.ARRAY_241 = 2 AND J06.J06_001_B > 0) -- NOTAS QUE POSSUEM VALOR PARA INTEGRACAO COM O FINANCEIRO
			GROUP BY
				TMP_J10DEV.UKEY, TMP_J10DEV.J10_001_C, TMP_J10DEV.J10_003_D, A03.A03_003_C, TMP_J10DEV.UKEY, TMP_J10DEV.J10_032_N, CIA.CIA_001_C
		)TMP
	GROUP BY
		UKEY, NF, EMISSAO, CANCELADA, CLIENTE, EMPRESA
-- *******************************   QUERY DE NOTAS DE DEVOLUCAO DE VENDAS - FIM ****************************************	


	-- DIFERENCAS COM BASE NAS NF E DEVOLUCOES DE NF GERADAS
	SELECT 
		CAST('NF' AS VARCHAR(254)) AS OPERACAO,
		CAST(TMP_NF.NF AS VARCHAR(254)) AS DOCUMENTO,
		TMP_NF.VALOR AS VALOR_DOCUMENTO,
		CAST(0 AS NUMERIC(16,8)) AS VALOR_QUITADO_PERIODO,
		CAST(0 AS NUMERIC(16,8)) AS VALOR_TOTAL_QUITADO,
		TMP_NF.EMISSAO AS EMISSAO,
		CAST(TMP_NF.CLIENTE AS VARCHAR(254)) AS CLIENTE,
		CAST(ISNULL(TMP_RAZAO.LANCAMENTO,'') AS VARCHAR(254)) AS LANCAMENTO,
		ISNULL(TMP_RAZAO.VALORLANCAMENTO,0) AS VALOR_RAZAO,
		CAST(ISNULL(TMP_RAZAO.HISTORICO,'') AS VARCHAR(254)) AS HISTORICO,
		CAST(	CASE	WHEN TMP_NF.CANCELADA = 1 AND TMP_NF.VALOR = 0 THEN 'CANCELADO, PERO TIENE LANZAMIENTO EN LA CONTABILIDAD' 
						WHEN TMP_NF.CANCELADA = 1 AND TMP_NF.VALOR > 0 THEN 'CANCELADO, PERO TIENE DOCUMENTO FINANCEIRO' 
						WHEN TMP_NF.VALOR = 0 THEN 'NO TIENE DOCUMENTO FINANCEIRO, PERO TIENE LANZAMIENTO CONTABLE' 
						WHEN TMP_NF.VALOR <> TMP_RAZAO.VALORLANCAMENTO THEN 'DIFERENCIA ENTRE FINANCEIRO Y CONTABILIDAD'
				ELSE  
						'SIN ERROR'
				END 
			AS CHAR(254)) AS MOTIVO,
		CAST(TMP_NF.OBS AS VARCHAR(254)) AS OBSERVACAO,
		TMP_NF.EMPRESA AS EMPRESA,
		TMP_NF.UKEY AS DOCUMENTO_UKEY,
		space(20) as DOCUMENTO_UKEY2
	INTO #TMP_RESULTADO -- ARMAZENO AS NOTAS QUE APRESENTARAM DIFEREN�A EM UM CURSOR TEMPOR�RIO
	FROM 
		#TMP_NF AS TMP_NF
		JOIN #TMP_RAZAO AS TMP_RAZAO ON TMP_RAZAO.B06_UKEYP = TMP_NF.UKEY OR ( TMP_RAZAO.OPERACAO = 'NF' AND TMP_RAZAO.NUMERO_OPERACAO = TMP_NF.NF AND TMP_RAZAO.CLIENTE_OPERACAO = TMP_NF.CLIENTE AND TMP_RAZAO.DATALANCAMENTO = TMP_NF.EMISSAO)

	-- DELETO TODAS AS NF QUE J� FORAM TRATADAS
	DELETE #TMP_NF WHERE UKEY IN (SELECT DOCUMENTO_UKEY FROM #TMP_RESULTADO)
	-- DELETO TODOS OS LANCAMENTOS QUE J� FORAM TRATADOS
	DELETE #TMP_RAZAO WHERE LANCAMENTO IN (SELECT LANCAMENTO FROM #TMP_RESULTADO)

	-- ARMAZENO AS NOTAS QUE APRESENTARAM DIFEREN�A EM UM CURSOR TEMPOR�RIO
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
			CAST( CASE WHEN TMP_NF.CANCELADA = 1 AND TMP_NF.VALOR > 0 THEN 'CANCELADO, PERO TIENE DOCUMENTO FINANCEIRO' WHEN TMP_NF.CANCELADA = 0 AND TMP_NF.VALOR > 0 THEN 'NO TIENE LANZAMIENTO CONTABLE'  ELSE 'SIN ERROR' END AS CHAR(254)) AS MOTIVO,
			RTRIM(TMP_NF.OBS) + ' - ' + CASE WHEN TMP_NF.CANCELADA = 1 THEN 'CANCELADA' ELSE '' END  AS OBSERVACAO,
			TMP_NF.EMPRESA AS EMPRESA,
			TMP_NF.UKEY AS DOCUMENTO_UKEY,
			space(20) as DOCUMENTO_UKEY2
	FROM #TMP_NF AS TMP_NF

	-- Busco todas as quita��es no Per�odo
	SELECT 
		RTRIM(F12_001_C) AS TITULO,
		RTRIM(F13_001_C) AS PARCELA,
		RTRIM(F12_001_C) + '-' + RTRIM(F13_001_C) AS TITULO_PARCELA,
		ROUND(F13.F13_010_B,2) AS VALOR_PARCELA,
		SUM(ROUND(F15.F15_003_B,2)) AS VALOR_QUITADO_PERIODO,
		SUM(ROUND(F15.F15_008_B,2)) AS ABATIMENTO,		
		SUM(ROUND(F15.F15_018_B + F15.F15_006_B + F15.F15_009_B + F15.F15_010_B,2)) AS JUROS,
		ISNULL((SELECT ROUND(SUM(F15T.F15_018_B + F15T.F15_006_B + F15T.F15_009_B + F15T.F15_010_B),2) FROM StarWestconCala2.DBO.F15 F15T (NOLOCK) JOIN StarWestconCala2.DBO.F18 F18T (NOLOCK) ON F15T.F18_UKEY = F18T.UKEY WHERE F15T.F13_UKEY = F13.UKEY AND F15T.F15_005_C = '002' AND F18T.F18_004_N = 1),0) AS VALOR_TOTA_JUROS,
		ISNULL((SELECT ROUND(SUM(F15T.F15_008_B),2) FROM StarWestconCala2.DBO.F15 F15T (NOLOCK) JOIN StarWestconCala2.DBO.F18 F18T (NOLOCK) ON F15T.F18_UKEY = F18T.UKEY WHERE F15T.F13_UKEY = F13.UKEY AND F15T.F15_005_C = '002' AND F18T.F18_004_N = 1),0) AS VALOR_TOTA_ABATIMENTO,
		ISNULL((SELECT ROUND(SUM(F15T.F15_003_B),2) FROM StarWestconCala2.DBO.F15 F15T (NOLOCK) JOIN StarWestconCala2.DBO.F18 F18T (NOLOCK) ON F15T.F18_UKEY = F18T.UKEY WHERE F15T.F13_UKEY = F13.UKEY AND F15T.F15_005_C = '002' AND F18T.F18_004_N = 1),0) AS VALOR_TOTAL_QUITADO,
		LTRIM(RTRIM(A03_003_C)) AS CLIENTE,
		CAST(CIA.CIA_001_C AS CHAR(254)) AS EMPRESA,
		F18.F18_003_D AS EMISSAO_QUITACAO,
		F12.UKEY AS F12_UKEY,
		F13.UKEY AS F13_UKEY,
		F15.UKEY AS F15_UKEY -- Scrum 14527
	INTO #TMP_QUITACAO
	FROM 
		StarWestconCala2.dbo.F18 F18 (NOLOCK)
		JOIN StarWestconCala2.dbo.F15 F15 (NOLOCK) ON F15.F18_UKEY = F18.UKEY AND F15.F15_005_C = '002' -- SOMENTE QUITACAO
		JOIN StarWestconCala2.dbo.F12 F12 (NOLOCK) ON F15.F12_UKEY = F12.UKEY
		JOIN StarWestconCala2.dbo.CIA CIA (NOLOCK) ON F12.CIA_UKEY = CIA.UKEY
		JOIN StarWestconCala2.dbo.F13 F13 (NOLOCK) ON F15.F13_UKEY = F13.UKEY
		JOIN StarWestconCala2.dbo.A03 A03 (NOLOCK) ON F12.A03_UKEY = A03.UKEY
	WHERE 
		F18.CIA_UKEY = 'STAR_' AND
		F18.F18_002_C = '002' AND -- Operacao de Quitacao
		F18.F18_004_N = 1 AND -- Indica que a Quita��o foi Efetuada
		F18.F18_003_D BETWEEN @initial_date AND @final_date -- Emiss�o Quitacao
	GROUP BY
		F12.F12_001_C, 
		F13.F13_001_C, 
		F13.F13_010_B,
		A03_003_C,
		CIA.CIA_001_C,
		F18.F18_003_D,
		F12.UKEY,
		F13.UKEY,
		F15.UKEY -- Scrum 14527			

	-- ARMAZENO AS NOTAS QUE APRESENTARAM DIFEREN�A EM UM CURSOR TEMPOR�RIO
	INSERT INTO #TMP_RESULTADO 
	-- DIFERENCAS ENTRE OS TITULOS E PARCELAS MOVIMENTADOS NO PERIODO
	SELECT 
		'QR' AS OPERACAO,
		TMP_QUITACAO.TITULO_PARCELA AS DOCUMENTO,
		TMP_QUITACAO.VALOR_PARCELA AS VALOR_DOCUMENTO,
		SUM(TMP_QUITACAO.VALOR_QUITADO_PERIODO) AS VALOR_QUITADO_PERIODO,
		TMP_QUITACAO.VALOR_TOTAL_QUITADO AS VALOR_TOTAL_QUITADO,
		CASE WHEN COUNT(1) = 1 
			THEN CAST((SELECT TOP 1 TMP_RAZAO.DATALANCAMENTO FROM #TMP_RAZAO AS TMP_RAZAO WHERE TMP_RAZAO.OPERACAO = 'QR' AND TMP_QUITACAO.TITULO_PARCELA = TMP_RAZAO.NUMERO_OPERACAO) AS VARCHAR(254))
		ELSE
			NULL
		END AS EMISSAO,		
		TMP_RAZAO.CLIENTE_OPERACAO AS CLIENTE,
		CASE WHEN COUNT(1) = 1 
			THEN CAST((SELECT TOP 1 TMP_RAZAO.LANCAMENTO FROM #TMP_RAZAO AS TMP_RAZAO WHERE TMP_RAZAO.OPERACAO = 'QR' AND TMP_QUITACAO.TITULO_PARCELA = TMP_RAZAO.NUMERO_OPERACAO) AS VARCHAR(254))
		ELSE
			CAST('TIENE M�S DE UN LANZAMIENTO CONTABLE' AS VARCHAR(254))
		END AS LANCAMENTO,
		SUM(TMP_RAZAO.VALORLANCAMENTO) AS VALOR_RAZAO,
		CASE WHEN COUNT(1) = 1 
			THEN CAST((SELECT TOP 1 TMP_RAZAO.HISTORICO FROM #TMP_RAZAO AS TMP_RAZAO WHERE TMP_RAZAO.OPERACAO = 'QR' AND TMP_QUITACAO.TITULO_PARCELA = TMP_RAZAO.NUMERO_OPERACAO) AS VARCHAR(254))
		ELSE
			CAST('TIENE M�S DE UN LANZAMIENTO CONTABLE EN EL PER�ODO' AS VARCHAR(254))
		END AS HISTORICO,		
		--CASE	
		--	WHEN SUM(TMP_QUITACAO.VALOR_QUITADO_PERIODO + TMP_QUITACAO.ABATIMENTO - TMP_QUITACAO.JUROS) <> SUM(TMP_RAZAO.VALORLANCAMENTO) THEN 'DIFERENCA ENTRE FINANCEIRO E CONTABILIDADE'
		--	WHEN TMP_QUITACAO.VALOR_TOTAL_QUITADO > TMP_QUITACAO.VALOR_PARCELA - TMP_QUITACAO.ABATIMENTO + TMP_QUITACAO.JUROS THEN 'VALOR QUITADO MAIOR QUE O VALOR DA PARCELA'
		--ELSE  
		--	'SEM ERRO'
		--END AS MOTIVO,
		CASE	
			WHEN SUM(TMP_QUITACAO.VALOR_QUITADO_PERIODO + TMP_QUITACAO.ABATIMENTO - TMP_QUITACAO.JUROS) <> SUM(TMP_RAZAO.VALORLANCAMENTO) THEN 'DIFERENCIA ENTRE FINANCEIRO Y CONTABILIDAD 2'
			WHEN TMP_QUITACAO.VALOR_TOTAL_QUITADO > TMP_QUITACAO.VALOR_PARCELA - SUM(TMP_QUITACAO.VALOR_TOTA_ABATIMENTO) + SUM(TMP_QUITACAO.VALOR_TOTA_JUROS) THEN 'VALOR QUITADO MAYOR QUE EL VALOR DE LA PARCELA'
		ELSE  
			'SIN ERROR'
		END AS MOTIVO,		
		NULL AS OBSERVACAO,
		TMP_QUITACAO.EMPRESA AS EMPRESA,
		TMP_QUITACAO.F13_UKEY AS DOCUMENTO_UKEY,
		TMP_QUITACAO.F15_UKEY AS DOCUMENTO_UKEY2
	FROM 
		#TMP_QUITACAO AS TMP_QUITACAO
		JOIN (SELECT OPERACAO,NUMERO_OPERACAO,DATALANCAMENTO,CLIENTE_OPERACAO,SUM(VALORLANCAMENTO) AS VALORLANCAMENTO, B07_UKEYP,B07_PAR FROM #TMP_RAZAO GROUP BY OPERACAO,NUMERO_OPERACAO,DATALANCAMENTO,CLIENTE_OPERACAO,B07_UKEYP,B07_PAR) AS TMP_RAZAO ON (TMP_RAZAO.B07_UKEYP <> '' AND TMP_RAZAO.B07_UKEYP = TMP_QUITACAO.F15_UKEY AND TMP_RAZAO.B07_PAR ='F15') OR ( TMP_RAZAO.OPERACAO = 'QR' AND TMP_QUITACAO.TITULO_PARCELA = TMP_RAZAO.NUMERO_OPERACAO AND TMP_QUITACAO.EMISSAO_QUITACAO = TMP_RAZAO.DATALANCAMENTO AND TMP_QUITACAO.CLIENTE = TMP_RAZAO.CLIENTE_OPERACAO) 
		--JOIN (SELECT OPERACAO,NUMERO_OPERACAO,DATALANCAMENTO,CLIENTE_OPERACAO,SUM(VALORLANCAMENTO) AS VALORLANCAMENTO  FROM #TMP_RAZAO GROUP BY OPERACAO,NUMERO_OPERACAO,DATALANCAMENTO,CLIENTE_OPERACAO) AS TMP_RAZAO ON ( TMP_RAZAO.OPERACAO = 'QR' AND TMP_QUITACAO.TITULO_PARCELA = TMP_RAZAO.NUMERO_OPERACAO AND TMP_QUITACAO.EMISSAO_QUITACAO = TMP_RAZAO.DATALANCAMENTO AND TMP_QUITACAO.CLIENTE = TMP_RAZAO.CLIENTE_OPERACAO)
	
		-- TRATAMENTO PARA OS CASOS DE QUITA��O PARCIAL PARA A MESMA PARCELA EFETUADAS NO MESMO DIA
		--JOIN #TMP_RAZAO AS TMP_RAZAO ON ( TMP_RAZAO.OPERACAO = 'QR' AND TMP_QUITACAO.TITULO_PARCELA = TMP_RAZAO.NUMERO_OPERACAO AND TMP_QUITACAO.EMISSAO_QUITACAO = TMP_RAZAO.DATALANCAMENTO )
	GROUP BY
		TMP_QUITACAO.TITULO_PARCELA,
		TMP_QUITACAO.VALOR_PARCELA,
		--TMP_QUITACAO.ABATIMENTO,
		--TMP_QUITACAO.JUROS,
		TMP_QUITACAO.VALOR_TOTAL_QUITADO,
		TMP_RAZAO.CLIENTE_OPERACAO,
		TMP_QUITACAO.EMPRESA,
		TMP_QUITACAO.F13_UKEY,
		TMP_QUITACAO.F15_UKEY
		
	-- DELETO TODAS AS PARCELAS QUE J� FORAM TRATADAS
	DELETE #TMP_QUITACAO WHERE F13_UKEY IN (SELECT DOCUMENTO_UKEY FROM #TMP_RESULTADO)
	-- DELETO TODOS OS LANCAMENTOS QUE J� FORAM TRATADOS
	DELETE #TMP_RAZAO 
	FROM #TMP_RAZAO AS TMP_RAZAO
	--JOIN #TMP_RESULTADO AS TMP_RESULTADO ON TMP_RESULTADO.DOCUMENTO = TMP_RAZAO.NUMERO_OPERACAO AND TMP_RESULTADO.CLIENTE = TMP_RAZAO.CLIENTE_OPERACAO
	INNER JOIN #TMP_RESULTADO AS TMP_RESULTADO ON TMP_RESULTADO.DOCUMENTO_UKEY2 = TMP_RAZAO.B07_UKEYP 
	WHERE TMP_RAZAO.OPERACAO = 'QR'

	-- ARMAZENO AS NOTAS QUE APRESENTARAM DIFEREN�A EM UM CURSOR TEMPOR�RIO
	INSERT INTO #TMP_RESULTADO 
	-- PARCELAS SEM TRATAMENTO
	SELECT 
		'QR' AS OPERACAO,
		TMP_QUITACAO.TITULO_PARCELA AS DOCUMENTO,
		TMP_QUITACAO.VALOR_PARCELA AS VALOR_DOCUMENTO,
		TMP_QUITACAO.VALOR_QUITADO_PERIODO AS VALOR_QUITADO_PERIODO,
		TMP_QUITACAO.VALOR_TOTAL_QUITADO AS VALOR_TOTAL_QUITADO,
		TMP_QUITACAO.EMISSAO_QUITACAO AS EMISSAO,
		TMP_QUITACAO.CLIENTE AS CLIENTE,
		NULL AS LANCAMENTO,
		0 AS VALOR_RAZAO,
		NULL AS HISTORICO,
		'NO TIENE LANZAMIENTO CONTABLE' AS MOTIVO,
		NULL AS OBSERVACAO,
		TMP_QUITACAO.EMPRESA AS EMPRESA,
		TMP_QUITACAO.F13_UKEY AS DOCUMENTO_UKEY,
		TMP_QUITACAO.F15_UKEY AS DOCUMENTO_UKEY2
	FROM 
		#TMP_QUITACAO AS TMP_QUITACAO
		
	--BUSCO AS SAIDAS EM CONTAS BANCARIAS
	SELECT
		'CBR' AS OPERACAO,
		F18.F18_001_C AS DOCUMENTO,
		F17.F17_001_B AS VALOR_DOCUMENTO,
		0 AS VALOR_QUITADO_PERIODO,
		0 AS VALOR_TOTAL_QUITADO,
		F18.F18_003_D AS EMISSAO,
		'' AS CLIENTE,	  	
		'' AS LANCAMENTO,
		0  AS VALOR_RAZAO,
		'' AS HISTORICO,
		'' AS MOTIVO,
		'SALIDA EN CUENTA BANCARIA' AS OBSERVACAO,
		CIA_001_C AS EMPRESA,
		F18.UKEY AS DOCUMENTO_UKEY,
		F17.UKEY AS F17_UKEY
		INTO #TMP_SAIDA_BANCARIA
	FROM
		StarWestconCala2.dbo.F17 (NOLOCK)
		INNER JOIN StarWestconCala2.dbo.A01 (NOLOCK) ON F17.A01_UKEY = A01.UKEY
		INNER JOIN StarWestconCala2.dbo.A38 (NOLOCK) ON F17.A38_UKEY = A38.UKEY
		INNER JOIN StarWestconCala2.dbo.A39 (NOLOCK) ON F17.A39_UKEY = A39.UKEY
		INNER JOIN StarWestconCala2.dbo.F18 (NOLOCK) ON F17.F18_UKEY = F18.UKEY
		INNER JOIN StarWestconCala2.dbo.A21 (NOLOCK) ON F17.A21_UKEY = A21.UKEY
		INNER JOIN StarWestconCala2.dbo.CIA (NOLOCK) ON F18.CIA_UKEY = CIA.UKEY
	WHERE
	   F18.CIA_UKEY = 'STAR_' AND
	   F18.F18_002_C = '007' AND
	   A21_001_C='19.02' AND 
	   F18_003_D BETWEEN @initial_date AND @final_date
	ORDER BY
		F18.F18_001_C,
		F17_002_D,
		A01_001_C
	
	
	-- ARMAZENO AS SAIDAS EM CONTA BANCARIAS QUE APRESENTARAM DIFEREN�A 
	INSERT INTO	#TMP_RESULTADO
	-- DIFERENCAS ENTRE AS SAIDAS EM CONTA BANCARIAS E MOVIMENTADOS NO PERIODO
	SELECT
		TMP_SAIDA_BANCARIA.OPERACAO, 
		TMP_SAIDA_BANCARIA.DOCUMENTO,
		TMP_SAIDA_BANCARIA.VALOR_DOCUMENTO, 
		TMP_SAIDA_BANCARIA.VALOR_QUITADO_PERIODO,
		TMP_SAIDA_BANCARIA.VALOR_TOTAL_QUITADO,
		TMP_SAIDA_BANCARIA.EMISSAO,
		TMP_SAIDA_BANCARIA.CLIENTE,	  
		TMP_RAZAO.LANCAMENTO AS LANCAMENTO,
		TMP_RAZAO.VALORLANCAMENTO AS VALOR_RAZAO,
		TMP_RAZAO.HISTORICO,	
		'SIN ERROR' AS MOTIVO,
		TMP_SAIDA_BANCARIA.OBSERVACAO,
		TMP_SAIDA_BANCARIA.EMPRESA,
		TMP_SAIDA_BANCARIA.DOCUMENTO_UKEY,
		space(20) as DOCUMENTO_UKEY2
	FROM 
		#TMP_SAIDA_BANCARIA AS TMP_SAIDA_BANCARIA
		JOIN #TMP_RAZAO AS TMP_RAZAO ON TMP_RAZAO.B07_UKEYP = TMP_SAIDA_BANCARIA.F17_UKEY AND TMP_RAZAO.B07_PAR ='F17'
	
	-- DELETO TODAS AS SAIDAS EM CONTAS BANCARIAS QUE J� FORAM TRATADAS
	DELETE #TMP_SAIDA_BANCARIA WHERE DOCUMENTO_UKEY IN (SELECT DOCUMENTO_UKEY FROM #TMP_RESULTADO)
	
	---- DELETO TODOS OS LANCAMENTOS QUE J� FORAM TRATADOS
	DELETE #TMP_RAZAO WHERE B06_PAR='F18' AND B06_UKEYP IN (SELECT DOCUMENTO_UKEY FROM #TMP_RESULTADO)	
	
	----DELETO AS SAIDAS EM CONTAS BANCARIAS QUR TEM LAN�AMENTOS EM OUTRA CONTA CONTABIL
	--DELETE #TMP_SAIDA_BANCARIA FROM  #TMP_SAIDA_BANCARIA AS TMP_SAIDA_BANCARIA
	--JOIN StarWestconCala2.DBO.B06 AS B06 ON B06.B06_UKEYP = DOCUMENTO_UKEY AND B06_PAR='F18'
	
	
	-- ARMAZENO AS SAIDAS EM CONTA BANCARIAS QUE APRESENTARAM DIFEREN�A EM UM CURSOR TEMPOR�RIO
	INSERT INTO #TMP_RESULTADO 
	-- SAIDAS EM CONTA BANCARIAS SEM TRATAMENTO
	SELECT
		TMP_SAIDA_BANCARIA.OPERACAO, 
		TMP_SAIDA_BANCARIA.DOCUMENTO,
		TMP_SAIDA_BANCARIA.VALOR_DOCUMENTO, 
		TMP_SAIDA_BANCARIA.VALOR_QUITADO_PERIODO,
		TMP_SAIDA_BANCARIA.VALOR_TOTAL_QUITADO,
		TMP_SAIDA_BANCARIA.EMISSAO,
		TMP_SAIDA_BANCARIA.CLIENTE,	  
		TMP_SAIDA_BANCARIA.LANCAMENTO,
		TMP_SAIDA_BANCARIA.VALOR_RAZAO,
		TMP_SAIDA_BANCARIA.HISTORICO,	
		'NO TIENE LANZAMIENTO CONTABLE'  AS MOTIVO,
		TMP_SAIDA_BANCARIA.OBSERVACAO,
		TMP_SAIDA_BANCARIA.EMPRESA,
		TMP_SAIDA_BANCARIA.DOCUMENTO_UKEY,
		space(20) as DOCUMENTO_UKEY2
	FROM 
		#TMP_SAIDA_BANCARIA AS TMP_SAIDA_BANCARIA
	
	
	-- ARMAZENO AS NOTAS QUE APRESENTARAM DIFEREN�A EM UM CURSOR TEMPOR�RIO
	INSERT INTO #TMP_RESULTADO 
	-- LANCAMENTOS SEM OPERACAO
	SELECT 
			TMP_RAZAO.OPERACAO AS OPERACAO,
			ISNULL(TMP_RAZAO.NUMERO_OPERACAO,'') AS DOCUMENTO,
			0 AS VALOR_DOCUMENTO,
			0 AS VALOR_QUITADO_PERIODO,
			0 AS VALOR_TOTAL_QUITADO,
			TMP_RAZAO.DATALANCAMENTO AS EMISSAO,
			ISNULL(TMP_RAZAO.CLIENTE_OPERACAO,'') AS CLIENTE,
			TMP_RAZAO.lancamento AS LANCAMENTO,
			TMP_RAZAO.valorlancamento AS VALOR_RAZAO,
			ISNULL(TMP_RAZAO.HISTORICO,'') AS HISTORICO,
			CAST( 'LANZAMIENTO SIN HISTORIALES O DE OPERACI�N NO TRATADA POR EL INFORME' AS CHAR(254)) AS MOTIVO,
			CAST('' AS CHAR(254)) AS OBSERVACAO,
			CAST('' AS CHAR(254)) AS EMPRESA,
			'' AS DOCUMENTO_UKEY,
			space(20) as DOCUMENTO_UKEY2
	FROM #TMP_RAZAO AS TMP_RAZAO


	-- ARMAZENO OS TITULOS QUE APRESENTARAM DIFEREN�A EM UM CURSOR TEMPOR�RIO
	INSERT INTO #TMP_RESULTADO 
	-- VERIFICO SE EXISTE ALGUM TITULO NO FINANCEIRO QUE N�O POSSU� NF DE ORIGEM
	SELECT 
		'CR' AS OPERACAO,
		RTRIM(F12_001_C) AS DOCUMENTO,
		MAX(F12.F12_013_B) AS VALOR_DOCUMENTO,
		ISNULL((SELECT ROUND(SUM(F15T.F15_002_B),2) FROM StarWestconCala2.DBO.F15 F15T (NOLOCK) JOIN StarWestconCala2.DBO.F18 F18T (NOLOCK) ON F15T.F18_UKEY = F18T.UKEY WHERE F15T.F12_UKEY = F12.UKEY AND F15T.F15_005_C = '002' AND F18T.F18_004_N = 1 AND F18T.F18_003_D BETWEEN @initial_date AND @final_date),0) AS VALOR_QUITADO_PERIODO,
		ISNULL((SELECT ROUND(SUM(F15T.F15_002_B),2) FROM StarWestconCala2.DBO.F15 F15T (NOLOCK) JOIN StarWestconCala2.DBO.F18 F18T (NOLOCK) ON F15T.F18_UKEY = F18T.UKEY WHERE F15T.F12_UKEY = F12.UKEY AND F15T.F15_005_C = '002' AND F18T.F18_004_N = 1),0) AS VALOR_TOTAL_QUITADO,		
		F12.F12_002_D AS EMISSAO,
		RTRIM(A03.A03_003_C) AS CLIENTE,
		'' AS LANCAMENTO,
		0  AS VALOR_RAZAO,
		'' AS HISTORICO,
		CAST( IIF(F12.F12_IPAR='J10','CC SIN FACTURA DE ORIGEM','NO TIENE LANZAMIENTO CONTABLE') AS CHAR(254)) AS MOTIVO,
		CAST('' AS CHAR(254)) AS OBSERVACAO,
		CAST(CIA.CIA_001_C AS CHAR(254)) AS EMPRESA,
		F12.UKEY AS DOCUMENTO_UKEY,
		space(20) as DOCUMENTO_UKEY2
	FROM
		StarWestconCala2.dbo.F12 F12 (NOLOCK)
		JOIN StarWestconCala2.dbo.F13 F13 (NOLOCK) ON F13.F12_UKEY = F12.UKEY
		JOIN StarWestconCala2.dbo.A03 A03 (NOLOCK) ON F12.F12_UKEYP = A03.UKEY
		JOIN StarWestconCala2.dbo.CIA CIA (NOLOCK) ON F12.CIA_UKEY = CIA.UKEY
	WHERE
		F12.CIA_UKEY = 'STAR_' AND
		F12.F12_016_C = '001' -- CONTAS A RECEBER
		AND F12.F12_002_D BETWEEN @initial_date AND @final_date
		AND ( ISNULL(F12.F12_IUKEYP,'') = '' or ( ISNULL(F12.F12_IUKEYP,'') <> '' AND NOT exists( SELECT J10.UKEY FROM StarWestconCala2.dbo.J10 J10 (NOLOCK) WHERE J10.UKEY = F12.F12_IUKEYP ) ) )
		AND NOT EXISTS (SELECT UKEY FROM StarWestconCala2.dbo.B06 B06 (NOLOCK) WHERE B06.B06_UKEYP = F12.UKEY)
	GROUP BY
		F12.F12_001_C,
		F12.F12_002_D,
		A03.A03_003_C,
		F12.F12_IPAR,
		CIA.CIA_001_C,
		F12.UKEY 

	-- MOSTRO AS NOTAS QUE APRESENTARAM DIFEREN�AS
	SELECT 
			*
	 FROM 
		#TMP_RESULTADO AS TMP_RESULTADO
	 ORDER 
		BY MOTIVO, OPERACAO, DOCUMENTO, CLIENTE

	-- APAGO OS CURSORES TEMPOR�RIOS
	DROP TABLE #TMP_RAZAO
	DROP TABLE #TMP_NF
	DROP TABLE #TMP_QUITACAO
	DROP TABLE #TMP_SAIDA_BANCARIA
	DROP TABLE #TMP_RESULTADO

end