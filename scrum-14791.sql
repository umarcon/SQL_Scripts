USE [Westcon]
GO
/****** Object:  StoredProcedure [Starsoft].[Reports_ContasReceber]    Script Date: 16/12/2015 11:21:48 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
	2015-12-01 - PRION
		- Alterada a forma de pegar a CIA_UKEY através de uma query que verifica por meio do ERP e Divisão.
		- Com isso, foram alterados os lugares que a CIA_UKEY estava fixa.

2015-01-14: Adicionado a coluna "CODREGIAO" e "REGIAO" " (SCRUM-13104)

2013-07-14: Adicionado o parametro EndInvoiceDate

Dia 2012-05-14: Alterado por JM e Paulo. Campo f13.a36_code0 adicionado no select para que seja trazida a moeda da parcela

16/dez/2013 por Gaúcho
	. Adicionado o parâmetro CodERP as funções:
		. GetIdGrupoEconomicoEmpresa
		. GetNomeGrupoEconomicoEmpresa
		
2015-05-11 Por Thiago Rodrigues
Inluido as colunas:
- Inclusao do status
- Origem de faturamento
Atividade 14493 do Scrum

2015-11-16 Por Marcelo Ayabe
- Incluído o parâmetro @RazaoSocial
Atividade ERP Latam Rollout - ROLLOUT-4

2015-12-04 Por Marcelo Ayabe
- Incluído os parâmetros @DataInicialVencimento, @DataFinalVencimento
Atividade ERP Latam Rollout - ROLLOUT-4
*/

-- exec [Starsoft].[testantoReports_ContasReceber] 1,0,'0','0',null,'', '',null,null

alter PROCEDURE [Starsoft].[Reports_ContasReceber]
	@ERP						int,				--CodERP vindo da Intranet de: Select * from Westcon.dbo.TblERP
	@Divisao					int,				-- Codigo da divisão do grupo westcon CodDivisao de: select * from Westcon.dbo.tbldivisao
	@Operador					varchar(20),		--Usuario que envio a parcela
	@Vendedor					varchar(50),		-- Vendedor da NF
	@EndInvoiceDate				datetime, 
	@usuarioLogado				varchar(50) = '',	--Login do usuario no Reports
	@RazaoSocial				varchar(100),		--Nome do Cliente / Fornecedor
	@DataInicialVencimento		datetime,			--Data Inicial de Vencimento
	@DataFinalVencimento		datetime			--Data Final de Vencimento
	
	with recompile
AS

--EXEC [Starsoft].[Reports_ContasReceber] 4,4,'0','0', '2015-11-03'

-- PRION - 24/11/2015
Declare @CIA_UKEY as varchar(20) 
-- Setando a CIA_UKEY ----------------------------------------------------------------------
SELECT @CIA_UKEY = CIA_UKEY FROM [intranet].[CiaUkey] (@ERP,@Divisao)
-----------------------------------------------------------------------------------------------

BEGIN		
	/**************************************BRASIL*****************************************/
	IF @ERP = 1 
		BEGIN
			select
			substring (f13.A36_CODE0,1,3) AS 'Moeda', -- campo com moeda da parcela
			[Westcon].[Intranet].[GetIdGrupoEconomicoEmpresa] (ISNULL(A08.A08_001_C,A03.A03_001_C), 1) as CustomerID,
			Westcon.Intranet.GetNomeGrupoEconomicoEmpresa(ISNULL(A08.A08_001_C,A03.A03_001_C), 1) as 'Grupo Economico',
			ISNULL(A08.A08_003_C,A03.A03_003_C) AS 'RAZAO SOCIAL',
			ISNULL(A08.A08_001_C,A03.A03_001_C) AS 'CNPJ',
			F12.F12_002_D 'DATA EMISSAO NOTA',
			F13.F13_003_D 'DATA VENCIMENTO NOMINAL', -- DEVE SER A QUE VAI VALER
			F12.F12_001_C 'NUMERO NOTA',
			F13.F13_001_C 'Parcela',
			F13.F13_010_B 'Valor Total',
			-- COLOCAR VALOR EM ABERTO
			F13.F13_021_B 'Valor Quitado',
			F13.F13_029_B 'Valor do Estorno na Moeda da Parcela',
			F13.F13_999_D AS 'PREVISAO DE PAGAMENTO',
			F13.F13_997_D AS 'DATA_PRORROGACAO',
			F13.F13WS_013_M AS 'OBS',
			VwIntranet.CodPedido AS 'numero OV Westcon',-- --intranet 
			A33.A33_003_C AS 'VENDEDOR WG',
			J07_002_C AS 'PEDIDO_CLIENTE',
			--A33.A33_003_C AS 'REVENDA COMISSIONADA',
			(SELECT DISTINCT top 1 A03_003_C FROM Starwestcon.dbo.A03 (NOLOCK)
				INNER JOIN Starwestcon.dbo.J15 (NOLOCK) ON J15.A03_UKEY = A03.UKEY
				INNER JOIN Starwestcon.dbo.J05 (NOLOCK) ON J05.J05_UKEYP = J15.UKEY
				INNER JOIN Starwestcon.dbo.A21 (NOLOCK) ON J05.A21_UKEY = A21.UKEY
				WHERE J15.J15_UKEYP = J10.UKEY AND A21.A21_001_C NOT IN ('15.96','15.97')) AS 'REVENDA COMISSIONADA',
			USR.USR_001_C AS 'OPERADOR',
			CASE WHEN F13.F13WS_002_N = 1 THEN 'SIM' ELSE 'NAO' END AS 'BOL_ENV_EMAIL',
			F13.F13WS_001_D AS 'DATA_ENV_EMAIL',
			ISNULL((SELECT USR.USR_001_C FROM Starwestcon.dbo.USR (NOLOCK) WHERE F13.USR_UKEY = USR.UKEY), '') AS 'BOL_ENV_POR',
			CASE WHEN F13.F13WS_003_N =1 THEN 'SIM' ELSE 'NAO' END AS 'EMAIL_ENV_APOS_VENC',
			F13.F13WS_008_D AS 'DATA_EMAIL_ENV_APOS_VENC',
			ISNULL((SELECT USR.USR_001_C FROM Starwestcon.dbo.USR (NOLOCK) WHERE F13.USR_UKEY0 = USR.UKEY),'') AS 'ENV_APOS_VENC_POR',
			CASE WHEN F13.F13WS_004_N =1 THEN 'SIM' ELSE 'NAO' END AS 'FILTRO_COBRANCA',
			F13.F13WS_007_D AS 'VALIDADE_FILTRO',
			CASE WHEN F13.F13WS_005_N = 1 THEN 'SIM' ELSE 'NAO' END AS 'NEGATIVADO_SERASA',
			F13.F13WS_006_D AS 'DATA_NEGATIVACAO',
			CASE WHEN F13.F13WS_009_N = 1 THEN 'SIM' ELSE 'NAO' END AS 'RETIRAR_NEG_SERASA',
			F13.F13WS_010_D AS 'RETIRADO_NEG_EM',
			F47.F47_001_C as 'codigo classificacao bancaria',
			F47.F47_002_C AS 'descricao classificacao bancaria',
			ISNULL(F40.F40_002_C,'Not categorized') AS 'STATUS DE COBRANCA',
			ISNULL(VwIntranet.divisao,'Divisao nao identificada') AS DIVISAO,
			ISNULL(VwIntranet.CodRegiao, 0) AS CODREGIAO, --SCRUM-13104
			ISNULL(VwIntranet.NomeRegiao, 0) AS REGIAO, --SCRUM-13104
			(SELECT TOP 1 WE17.TIMESTAMP FROM Starwestcon.dbo.WE17 (NOLOCK) WHERE  WE17_001_C ='F40_UKEY' AND  WE17.F13_UKEY=F13.UKEY ORDER BY WE17.TIMESTAMP DESC) As 'Inclusao do status',--SCRUM 14493
			isnull(CIA_001_C,'') As 'Origem de faturamento', --SCRUM 14493
			F13.F13_011_C as 'NUMERO BANCARIO' -- Incluso por rpaulista a pedido do Sr. Paulo (scrum 14493)
			from Starwestcon.dbo.F13 
			INNER JOIN Starwestcon.dbo.F12 (NOLOCK) ON F13.F12_UKEY = F12.UKEY
			INNER JOIN Starwestcon.dbo.CIA (NOLOCK) ON F12.CIA_UKEY = CIA.UKEY
			left JOIN Starwestcon.dbo.A08            (NOLOCK) ON F12.F12_UKEYP = A08.UKEY --FORNECEDOR
			left JOIN Starwestcon.dbo.A03            (NOLOCK) ON F12.F12_UKEYP = A03.UKEY --CLIENTE
			left JOIN Starwestcon.dbo.J10           (NOLOCK) ON F12_IUKEYP=J10.UKEY
			left JOIN Starwestcon.dbo.A33 A33 (NOLOCK) ON J10.A33_UKEY=A33.UKEY
			LEFT OUTER JOIN Starwestcon.dbo.F47      (NOLOCK) ON F13.F47_UKEY = F47.UKEY --CLASSIFICACAO FINANCEIRA
			LEFT OUTER JOIN Starwestcon.dbo.F40      (NOLOCK) ON F13.F40_UKEY = F40.UKEY --STATUS
			LEFT OUTER JOIN Starwestcon.dbo.USR USR (NOLOCK) ON F13.USRWS_UKEY = USR.UKEY --USUARIO
			left JOIN Starwestcon.dbo.J07 (NOLOCK) ON J10.J07_UKEY=J07.UKEY
			LEFT JOIN Westcon.Intranet.vwSalesOrder_Division as VwIntranet ON VwIntranet.codPedido = [Westcon].[StarSoft].[FN_GetOVGlobalCode](J07.J07_001_C,1)
			LEFT JOIN (
							SELECT	
								SUM(F15.F15_002_B) VALOR_QUITADO,
								F15.F13_UKEY
							FROM STARWESTCON.DBO.F15 F15 (NOLOCK) 
							JOIN STARWESTCON.DBO.F18 F18 (NOLOCK) ON F15.F18_UKEY = F18.UKEY
							WHERE F15.F15_005_C = '002' -- EVENTO DE QUITACAO
								AND F18.F18_004_N = 1 -- EFETIVACAO DA QUITACAO
								AND (F15.F15_004_D <= @EndInvoiceDate or (@EndInvoiceDate is null)) 					
							GROUP BY F15.F13_UKEY
						)QP ON QP.F13_UKEY = F13.UKEY
			LEFT JOIN (
							SELECT	
								SUM(F15.F15_002_B) VALOR_ESTORNO,
								F15.F13_UKEY
							FROM STARWESTCON.DBO.F15 F15 (NOLOCK) 
							JOIN STARWESTCON.DBO.F18 F18 (NOLOCK) ON F15.F18_UKEY = F18.UKEY
							WHERE F15.F15_005_C = '031' -- EVENTO DE ESTORNO
								AND F18.F18_004_N = 1 -- EFETIVACAO DO ESTORNO
								AND (F15.F15_004_D <= @EndInvoiceDate or (@EndInvoiceDate is null)) 					
							GROUP BY F15.F13_UKEY
						)ESTORNO ON ESTORNO.F13_UKEY = F13.UKEY		
			LEFT JOIN (
							SELECT	
								SUM(F15.F15_002_B) VALOR_REPARCELAMENTO,
								F15.F13_UKEY
							FROM STARWESTCON.DBO.F15 F15 (NOLOCK) 
							JOIN STARWESTCON.DBO.F18 F18 (NOLOCK) ON F15.F18_UKEY = F18.UKEY
							WHERE F15.F15_005_C = '028' -- EVENTO DO REPARCELAMENTO
								AND F18.F18_004_N = 1 -- EFETIVACAO DO REPARCELAMENTO
								AND (F15.F15_004_D <= @EndInvoiceDate or (@EndInvoiceDate is null)) 					
							GROUP BY F15.F13_UKEY
						)REPARC ON REPARC.F13_UKEY = F13.UKEY	
			LEFT JOIN (
							SELECT	
								SUM(F15.F15_002_B) VALOR_ADIANTAMENTO,
								F15.F13_UKEY
							FROM STARWESTCON.DBO.F15 F15 (NOLOCK) 
							WHERE F15.F15_005_C = '022' -- EVENTO DE ADIANTAMENTO
								AND (F15.F15_004_D <= @EndInvoiceDate or (@EndInvoiceDate is null)) 					
							GROUP BY F15.F13_UKEY
						)ADT ON ADT.F13_UKEY = F13.UKEY
			where 
			(ISNULL(@EndInvoiceDate,'') = '' OR F12.F12_002_D < dateadd(dd,1,@EndInvoiceDate)) AND -- Verifica data máxima de emissao 
			(ISNULL(@DataInicialVencimento,'') = '' OR CONVERT(CHAR, F13.F13_002_D, 112) >= CONVERT(CHAR, @DataInicialVencimento, 112)) AND -- Verifica data de vencimento inicial
			(ISNULL(@DataFinalVencimento,'') = '' OR CONVERT(CHAR, F13.F13_002_D, 112) <= CONVERT(CHAR, @DataFinalVencimento, 112)) AND -- Verifica data de vencimento final
			(@Divisao = 0 OR VwIntranet.CodDivisao = @Divisao) AND -- Verifica divisão
			(@Operador = '0' OR USR.UKEY = @Operador) AND -- Verifica Operador
			(@Vendedor = '0' OR A33.UKEY= @Vendedor) AND -- Verifica Vendedor
			(ISNULL(A08.A08_003_C,'') LIKE '%'+RTRIM(LTRIM(@RazaoSocial))+'%' OR ISNULL(A03.A03_003_C,'') LIKE '%'+RTRIM(LTRIM(@RazaoSocial))+'%' ) AND -- Verifica nome do Cliente / Fornecedor
			(F12.F12_PAR = 'A08' or F12.F12_PAR = 'A03')/*id client/fornecedor na A03 ou A08*/ AND
			F12.F12_016_C = '001' /*Tipo igual a título*/ AND
			( F13.F13_010_B - F13.F13_029_B - F13.F13_025_B - F13.F13_021_B - F13.F13_022_B ) > 0 AND
			(ISNULL(@usuarioLogado, '') = '' OR (ISNULL(VwIntranet.CodRegiao, 0) = 0 OR VwIntranet.CodRegiao IN (select R.CodRegiao from tblUsuarioRegiao R INNER JOIN tblUsuario U ON U.CodUsuario  = R.CodUsuario INNER JOIN wcnUsuarioWestcon wU ON wU.IDUsuario = U.CodUsuario WHERE wU.LoginDominio = @usuarioLogado)))

			-- F13.F13_028_N <> 1 /*Status para estorno 0 - Não Estornado ou 2 - Estornado Parcialmente */AND
			-- F13.F13_026_N = 0 /*Status igual a 0 em Aberto */ AND
			--(((F13.F13_015_N = 0 OR F13.F13_015_N = 2) AND F13.F13_024_N = 0))/*(Status 0 em Aberto OU 2 Quitado Parcialmente) E Flag de parcela quitada igual a 0*/	
		END
	

	/**************************************CALA*****************************************/

	ELSE IF @ERP = 2
		BEGIN
			select
			substring (f13.A36_CODE0,1,3) AS 'Moeda', -- campo com moeda da parcela
			[Westcon].[Intranet].[GetIdGrupoEconomicoEmpresa] (ISNULL(A08.A08_001_C,A03.A03_001_C), 2) as CustomerID,
			Westcon.Intranet.GetNomeGrupoEconomicoEmpresa(ISNULL(A08.A08_001_C,A03.A03_001_C), 2) as 'Grupo Economico',
			ISNULL(A08.A08_003_C,A03.A03_003_C) AS 'RAZAO SOCIAL',
			ISNULL(A08.A08_001_C,A03.A03_001_C) AS 'CNPJ',
			F12.F12_002_D 'DATA EMISSAO NOTA',
			F13.F13_003_D 'DATA VENCIMENTO NOMINAL', -- DEVE SER A QUE VAI VALER
			F12.F12_001_C 'NUMERO NOTA',
			F13.F13_001_C 'Parcela',
			F13.F13_010_B 'Valor Total',
			-- COLOCAR VALOR EM ABERTO
			F13.F13_021_B 'Valor Quitado',
			F13.F13_029_B 'Valor do Estorno na Moeda da Parcela',
			F13.F13_999_D AS 'PREVISAO DE PAGAMENTO',
			F13.F13_997_D AS 'DATA_PRORROGACAO',
			F13.F13_998_C AS 'OBS',
			VwIntranet.CodPedido AS 'numero OV Westcon',-- --intranet 
			A33.A33_003_C AS 'VENDEDOR WG',
			J07_002_C AS 'PEDIDO_CLIENTE',
			A33.A33_003_C AS 'REVENDA COMISSIONADA',
			USR.USR_001_C AS 'OPERADOR',
			CASE WHEN F13.F13WS_002_N = 1 THEN 'SIM' ELSE 'NAO' END AS 'BOL_ENV_EMAIL',
			F13.F13WS_001_D AS 'DATA_ENV_EMAIL',
			ISNULL((SELECT USR.USR_001_C FROM StarWestconCALA2.dbo.USR (NOLOCK) WHERE F13.USR_UKEY = USR.UKEY), '') AS 'BOL_ENV_POR',
			CASE WHEN F13.F13WS_003_N =1 THEN 'SIM' ELSE 'NAO' END AS 'EMAIL_ENV_APOS_VENC',
			F13.F13WS_008_D AS 'DATA_EMAIL_ENV_APOS_VENC',
			ISNULL((SELECT USR.USR_001_C FROM StarWestconCALA2.dbo.USR (NOLOCK) WHERE F13.USR_UKEY0 = USR.UKEY),'') AS 'ENV_APOS_VENC_POR',
			CASE WHEN F13.F13WS_004_N =1 THEN 'SIM' ELSE 'NAO' END AS 'FILTRO_COBRANCA',
			F13.F13WS_007_D AS 'VALIDADE_FILTRO',
			CASE WHEN F13.F13WS_005_N = 1 THEN 'SIM' ELSE 'NAO' END AS 'NEGATIVADO_SERASA',
			F13.F13WS_006_D AS 'DATA_NEGATIVACAO',
			CASE WHEN F13.F13WS_009_N = 1 THEN 'SIM' ELSE 'NAO' END AS 'RETIRAR_NEG_SERASA',
			F13.F13WS_010_D AS 'RETIRADO_NEG_EM',
			F47.F47_001_C as 'codigo classificacao bancaria',
			F47.F47_002_C AS 'descricao classificacao bancaria',
			ISNULL(VwIntranet.divisao,'Divisao nao identificada') AS DIVISAO,
			ISNULL(VwIntranet.CodRegiao, 0) AS CODREGIAO, --SCRUM-13104
			ISNULL(VwIntranet.NomeRegiao, 0) AS REGIAO, --SCRUM-13104
			'' As 'Inclusao do status',--SCRUM 14493
			'' As  'Origem de faturamento', --SCRUM 14493
			F13.F13_011_C as 'NUMERO BANCARIO' -- Incluso por rpaulista a pedido do Sr. Paulo (scrum 14493)
			from StarWestconCALA2.dbo.F13
			INNER JOIN StarWestconCALA2.dbo.F12 (NOLOCK) ON F13.F12_UKEY = F12.UKEY AND F12.CIA_UKEY = @CIA_UKEY
			left JOIN StarWestconCALA2.dbo.A08            (NOLOCK) ON F12.F12_UKEYP = A08.UKEY AND A08.CIA_UKEY = @CIA_UKEY --FORNECEDOR 
			left JOIN StarWestconCALA2.dbo.A03            (NOLOCK) ON F12.F12_UKEYP = A03.UKEY AND A03.CIA_UKEY = @CIA_UKEY --CLIENTE
			left JOIN StarWestconCALA2.dbo.J10           (NOLOCK) ON F12_IUKEYP=J10.UKEY AND J10.CIA_UKEY = @CIA_UKEY
			left JOIN StarWestconCALA2.dbo.A33 A33 (NOLOCK) ON J10.A33_UKEY=A33.UKEY AND A33.CIA_UKEY = @CIA_UKEY 
			LEFT OUTER JOIN StarWestconCALA2.dbo.F47      (NOLOCK) ON F13.F47_UKEY = F47.UKEY --CLASSIFICACAO FINANCEIRA
			LEFT OUTER JOIN StarWestconCALA2.dbo.USR USR (NOLOCK) ON F13.USRWS_UKEY = USR.UKEY --USUARIO
			left JOIN StarWestconCALA2.dbo.J07 (NOLOCK) ON J10.J07_UKEY=J07.UKEY AND J07.CIA_UKEY = @CIA_UKEY
			LEFT JOIN Westcon.Intranet.vwSalesOrder_Division as VwIntranet ON VwIntranet.codPedido = [Westcon].[StarSoft].[FN_GetOVGlobalCode](J07.J07_001_C,1)
			where 
			(ISNULL(@EndInvoiceDate,'') = '' OR F12.F12_002_D < dateadd(dd,1,@EndInvoiceDate)) AND -- Verifica data máxima de emissao 
			(ISNULL(@DataInicialVencimento,'') = '' OR CONVERT(CHAR, F13.F13_002_D, 112) >= CONVERT(CHAR, @DataInicialVencimento, 112)) AND -- Verifica data de vencimento inicial
			(ISNULL(@DataFinalVencimento,'') = '' OR CONVERT(CHAR, F13.F13_002_D, 112) <= CONVERT(CHAR, @DataFinalVencimento, 112)) AND -- Verifica data de vencimento final
			(@Divisao = 0 OR VwIntranet.CodDivisao = @Divisao) AND -- Verifica divisão
			(@Operador = '0' OR USR.UKEY = @Operador) AND -- Verifica Operador
			(@Vendedor = '0' OR A33.UKEY= @Vendedor) AND -- Verifica Vendedor
			(ISNULL(A08.A08_003_C,'') LIKE '%'+RTRIM(LTRIM(@RazaoSocial))+'%' OR ISNULL(A03.A03_003_C,'') LIKE '%'+RTRIM(LTRIM(@RazaoSocial))+'%' ) AND -- Verifica nome do Cliente / Fornecedor
			(F12.F12_PAR = 'A08' or F12.F12_PAR = 'A03')/*id client/fornecedor na A03 ou A08*/ AND
			F12.F12_016_C = '001' /*Tipo igual a título*/ AND
			( F13.F13_010_B - F13.F13_029_B - F13.F13_025_B - F13.F13_021_B - F13.F13_022_B ) > 0 AND
			(ISNULL(@usuarioLogado, '') = '' OR (ISNULL(VwIntranet.CodRegiao, 0) = 0 OR VwIntranet.CodRegiao IN (select R.CodRegiao from tblUsuarioRegiao R INNER JOIN tblUsuario U ON U.CodUsuario  = R.CodUsuario INNER JOIN wcnUsuarioWestcon wU ON wU.IDUsuario = U.CodUsuario WHERE wU.LoginDominio = @usuarioLogado)))
			-- F13.F13_028_N <> 1 /*Status para estorno 0 - Não Estornado ou 2 - Estornado Parcialmente */AND
			-- F13.F13_026_N = 0 /*Status igual a 0 em Aberto */ AND
			--(((F13.F13_015_N = 0 OR F13.F13_015_N = 2) AND F13.F13_024_N = 0))/*(Status 0 em Aberto OU 2 Quitado Parcialmente) E Flag de parcela quitada igual a 0*/	
			
		END
		
	

	/**************************************MEXICO*****************************************/	
	ELSE IF @ERP = 3
		BEGIN
			select distinct
			substring (f13.A36_CODE0,1,3) AS 'Moeda', -- campo com moeda da parcela
			[Westcon].[Intranet].[GetIdGrupoEconomicoEmpresa] (ISNULL(A08.A08_001_C,A03.A03_001_C), 3) as CustomerID,
			Westcon.Intranet.GetNomeGrupoEconomicoEmpresa(ISNULL(A08.A08_001_C,A03.A03_001_C), 3) as 'Grupo Economico',
			ISNULL(A08.A08_003_C,A03.A03_003_C) AS 'RAZAO SOCIAL',
			ISNULL(A08.A08_001_C,A03.A03_001_C) AS 'CNPJ',
			F12.F12_002_D 'DATA EMISSAO NOTA',
			F13.F13_003_D 'DATA VENCIMENTO NOMINAL', -- DEVE SER A QUE VAI VALER
			F12.F12_001_C 'NUMERO NOTA',
			F13.F13_001_C 'Parcela',
			F13.F13_010_B 'Valor Total',
			-- COLOCAR VALOR EM ABERTO
			F13.F13_021_B 'Valor Quitado',
			F13.F13_029_B 'Valor do Estorno na Moeda da Parcela',
			F13.F13_999_D AS 'PREVISAO DE PAGAMENTO',
			F13.F13_997_D AS 'DATA_PRORROGACAO',
			F13.F13_998_C AS 'OBS',
			VwIntranet.CodPedido AS 'numero OV Westcon',-- --intranet 
			A33.A33_003_C AS 'VENDEDOR WG',
			J07_002_C AS 'PEDIDO_CLIENTE',
			A33.A33_003_C AS 'REVENDA COMISSIONADA',
			USR.USR_001_C AS 'OPERADOR',
			CASE WHEN F13.F13WS_002_N = 1 THEN 'SIM' ELSE 'NAO' END AS 'BOL_ENV_EMAIL',
			F13.F13WS_001_D AS 'DATA_ENV_EMAIL',
			ISNULL((SELECT USR.USR_001_C FROM StarWestconMX.dbo.USR (NOLOCK) WHERE F13.USR_UKEY = USR.UKEY), '') AS 'BOL_ENV_POR',
			CASE WHEN F13.F13WS_003_N =1 THEN 'SIM' ELSE 'NAO' END AS 'EMAIL_ENV_APOS_VENC',
			F13.F13WS_008_D AS 'DATA_EMAIL_ENV_APOS_VENC',
			ISNULL((SELECT USR.USR_001_C FROM StarWestconMX.dbo.USR (NOLOCK) WHERE F13.USR_UKEY0 = USR.UKEY),'') AS 'ENV_APOS_VENC_POR',
			CASE WHEN F13.F13WS_004_N =1 THEN 'SIM' ELSE 'NAO' END AS 'FILTRO_COBRANCA',
			F13.F13WS_007_D AS 'VALIDADE_FILTRO',
			CASE WHEN F13.F13WS_005_N = 1 THEN 'SIM' ELSE 'NAO' END AS 'NEGATIVADO_SERASA',
			F13.F13WS_006_D AS 'DATA_NEGATIVACAO',
			CASE WHEN F13.F13WS_009_N = 1 THEN 'SIM' ELSE 'NAO' END AS 'RETIRAR_NEG_SERASA',
			F13.F13WS_010_D AS 'RETIRADO_NEG_EM',
			F47.F47_001_C as 'codigo classificacao bancaria',
			F47.F47_002_C AS 'descricao classificacao bancaria',
			ISNULL(VwIntranet.divisao,'Divisao nao identificada') AS DIVISAO,
			ISNULL(VwIntranet.CodRegiao, 0) AS CODREGIAO, --SCRUM-13104
			ISNULL(VwIntranet.NomeRegiao, 0) AS REGIAO, --SCRUM-13104
			'' As 'Inclusao do status',--SCRUM 14493
			'' As  'Origem de faturamento', --SCRUM 14493
			F13.F13_011_C as 'NUMERO BANCARIO' -- Incluso por rpaulista a pedido do Sr. Paulo (scrum 14493)
			from StarWestconMX.dbo.F13
			INNER JOIN StarWestconMX.dbo.F12 (NOLOCK) ON F13.F12_UKEY = F12.UKEY
			left JOIN StarWestconMX.dbo.A08            (NOLOCK) ON F12.F12_UKEYP = A08.UKEY --FORNECEDOR
			left JOIN StarWestconMX.dbo.A03            (NOLOCK) ON F12.F12_UKEYP = A03.UKEY --CLIENTE
			left JOIN StarWestconMX.dbo.J10           (NOLOCK) ON F12_IUKEYP=J10.UKEY
			left JOIN StarWestconMX.dbo.A33 A33 (NOLOCK) ON J10.A33_UKEY=A33.UKEY
			LEFT OUTER JOIN StarWestconMX.dbo.F47      (NOLOCK) ON F13.F47_UKEY = F47.UKEY --CLASSIFICACAO FINANCEIRA
			LEFT OUTER JOIN StarWestconMX.dbo.USR USR (NOLOCK) ON F13.USRWS_UKEY = USR.UKEY --USUARIO
			--left JOIN StarWestconMX.dbo.J07 (NOLOCK) ON J10.J07_UKEY=J07.UKEY -- ALTERADO DEVIDO NAO ESTAR NA CAPA DAS NOTAS FISCAIS (J10.J07_UKEY) A UKEY DA J07 (PEDIDO) E ESTAR SOMENTE NOS ITENS DA NF (J11)
			left join StarWestconMX.dbo.J11 (NOLOCK) ON J11.J10_ukey = J10.UKEY
			LEFT JOIN StarWestconMX.dbo.J08 (NOLOCK) ON J11.J11_UKEYP = J08.UKEY
			LEFT JOIN StarWestconMX.dbo.J07 (NOLOCK) ON J08.J07_UKEY = J07.UKEY 
			LEFT JOIN Westcon.Intranet.vwSalesOrder_Division as VwIntranet ON VwIntranet.codPedido = [Westcon].[StarSoft].[FN_GetOVGlobalCode](J07.J07_001_C,1)
			where 
			(ISNULL(@EndInvoiceDate,'') = '' OR F12.F12_002_D < dateadd(dd,1,@EndInvoiceDate)) AND -- Verifica data máxima de emissao 
			(ISNULL(@DataInicialVencimento,'') = '' OR CONVERT(CHAR, F13.F13_002_D, 112) >= CONVERT(CHAR, @DataInicialVencimento, 112)) AND -- Verifica data de vencimento inicial
			(ISNULL(@DataFinalVencimento,'') = '' OR CONVERT(CHAR, F13.F13_002_D, 112) <= CONVERT(CHAR, @DataFinalVencimento, 112)) AND -- Verifica data de vencimento final
			(@Divisao = 0 OR VwIntranet.CodDivisao = @Divisao) AND -- Verifica divisão
			(@Operador = '0' OR USR.UKEY = @Operador) AND -- Verifica Operador
			(@Vendedor = '0' OR A33.UKEY= @Vendedor) AND -- Verifica Vendedor
			(ISNULL(A08.A08_003_C,'') LIKE '%'+RTRIM(LTRIM(@RazaoSocial))+'%' OR ISNULL(A03.A03_003_C,'') LIKE '%'+RTRIM(LTRIM(@RazaoSocial))+'%' ) AND -- Verifica nome do Cliente / Fornecedor
			(F12.F12_PAR = 'A08' or F12.F12_PAR = 'A03')/*id client/fornecedor na A03 ou A08*/ AND
			F12.F12_016_C = '001' /*Tipo igual a título*/ AND
			( F13.F13_010_B - F13.F13_029_B - F13.F13_025_B - F13.F13_021_B - F13.F13_022_B ) > 0 AND
			(ISNULL(@usuarioLogado, '') = '' OR (ISNULL(VwIntranet.CodRegiao, 0) = 0 OR VwIntranet.CodRegiao IN (select R.CodRegiao from tblUsuarioRegiao R INNER JOIN tblUsuario U ON U.CodUsuario  = R.CodUsuario INNER JOIN wcnUsuarioWestcon wU ON wU.IDUsuario = U.CodUsuario WHERE wU.LoginDominio = @usuarioLogado)))
			-- F13.F13_028_N <> 1 /*Status para estorno 0 - Não Estornado ou 2 - Estornado Parcialmente */AND
			-- F13.F13_026_N = 0 /*Status igual a 0 em Aberto */ AND
			--(((F13.F13_015_N = 0 OR F13.F13_015_N = 2) AND F13.F13_024_N = 0))/*(Status 0 em Aberto OU 2 Quitado Parcialmente) E Flag de parcela quitada igual a 0*/			
		END
	

	/**************************************COLOMBIA*****************************************/	
	
	ELSE IF @ERP = 4
		BEGIN
			select
			distinct
			substring (f13.A36_CODE0,1,3) AS 'Moeda', -- campo com moeda da parcela
			[Westcon].[Intranet].[GetIdGrupoEconomicoEmpresa] (ISNULL(A08.A08_001_C,A03.A03_001_C), 4) as CustomerID,
			Westcon.Intranet.GetNomeGrupoEconomicoEmpresa(ISNULL(A08.A08_001_C,A03.A03_001_C), 4) as 'Grupo Economico',
			ISNULL(A08.A08_003_C,A03.A03_003_C) AS 'RAZAO SOCIAL',
			ISNULL(A08.A08_001_C,A03.A03_001_C) AS 'CNPJ',
			F12.F12_002_D 'DATA EMISSAO NOTA',
			F13.F13_003_D 'DATA VENCIMENTO NOMINAL', -- DEVE SER A QUE VAI VALER
			F12.F12_001_C 'NUMERO NOTA',
			F13.F13_001_C 'Parcela',
			F13.F13_010_B 'Valor Total',
			-- COLOCAR VALOR EM ABERTO
			F13.F13_021_B 'Valor Quitado',
			F13.F13_029_B 'Valor do Estorno na Moeda da Parcela',
			F13.F13_999_D AS 'PREVISAO DE PAGAMENTO',
			F13.F13_997_D AS 'DATA_PRORROGACAO',
			F13.F13_998_C AS 'OBS',
			VwIntranet.CodPedido AS 'numero OV Westcon',-- --intranet 
			A33.A33_003_C AS 'VENDEDOR WG',
			J07_002_C AS 'PEDIDO_CLIENTE',
			A33.A33_003_C AS 'REVENDA COMISSIONADA',
			USR.USR_001_C AS 'OPERADOR',
			CASE WHEN F13.F13WS_002_N = 1 THEN 'SIM' ELSE 'NAO' END AS 'BOL_ENV_EMAIL',
			F13.F13WS_001_D AS 'DATA_ENV_EMAIL',
			ISNULL((SELECT USR.USR_001_C FROM StarWestconCALA2.dbo.USR (NOLOCK) WHERE F13.USR_UKEY = USR.UKEY), '') AS 'BOL_ENV_POR',
			CASE WHEN F13.F13WS_003_N =1 THEN 'SIM' ELSE 'NAO' END AS 'EMAIL_ENV_APOS_VENC',
			F13.F13WS_008_D AS 'DATA_EMAIL_ENV_APOS_VENC',
			ISNULL((SELECT USR.USR_001_C FROM StarWestconCALA2.dbo.USR (NOLOCK) WHERE F13.USR_UKEY0 = USR.UKEY),'') AS 'ENV_APOS_VENC_POR',
			CASE WHEN F13.F13WS_004_N =1 THEN 'SIM' ELSE 'NAO' END AS 'FILTRO_COBRANCA',
			F13.F13WS_007_D AS 'VALIDADE_FILTRO',
			CASE WHEN F13.F13WS_005_N = 1 THEN 'SIM' ELSE 'NAO' END AS 'NEGATIVADO_SERASA',
			F13.F13WS_006_D AS 'DATA_NEGATIVACAO',
			CASE WHEN F13.F13WS_009_N = 1 THEN 'SIM' ELSE 'NAO' END AS 'RETIRAR_NEG_SERASA',
			F13.F13WS_010_D AS 'RETIRADO_NEG_EM',
			F47.F47_001_C as 'codigo classificacao bancaria',
			F47.F47_002_C AS 'descricao classificacao bancaria',
			ISNULL(VwIntranet.divisao,'Divisao nao identificada') AS DIVISAO,
			ISNULL(VwIntranet.CodRegiao, 0) AS CODREGIAO, --SCRUM-13104
			ISNULL(VwIntranet.NomeRegiao, 0) AS REGIAO, --SCRUM-13104
			'' As 'Inclusao do status',--SCRUM 14493
			'' As  'Origem de faturamento', --SCRUM 14493
			F13.F13_011_C as 'NUMERO BANCARIO' -- Incluso por rpaulista a pedido do Sr. Paulo (scrum 14493)
			from StarWestconCALA2.dbo.F13
			INNER JOIN StarWestconCALA2.dbo.F12 (NOLOCK) ON F13.F12_UKEY = F12.UKEY AND F12.CIA_UKEY = @CIA_UKEY
			left JOIN StarWestconCALA2.dbo.A08            (NOLOCK) ON F12.F12_UKEYP = A08.UKEY AND A08.CIA_UKEY IN ('M8530','M8531') --FORNECEDOR 
			left JOIN StarWestconCALA2.dbo.A03            (NOLOCK) ON F12.F12_UKEYP = A03.UKEY AND A03.CIA_UKEY IN ('M8530','M8531') --CLIENTE
			left JOIN StarWestconCALA2.dbo.J10           (NOLOCK) ON F12_IUKEYP=J10.UKEY AND J10.CIA_UKEY = @CIA_UKEY
			left JOIN StarWestconCALA2.dbo.A33 A33 (NOLOCK) ON J10.A33_UKEY=A33.UKEY AND A33.CIA_UKEY = @CIA_UKEY 
			LEFT OUTER JOIN StarWestconCALA2.dbo.F47      (NOLOCK) ON F13.F47_UKEY = F47.UKEY --CLASSIFICACAO FINANCEIRA
			LEFT OUTER JOIN StarWestconCALA2.dbo.USR USR (NOLOCK) ON F13.USRWS_UKEY = USR.UKEY --USUARIO
			left JOIN StarWestconCALA2.dbo.J11           (NOLOCK) ON J11.J10_UKEY=J10.UKEY AND J11.CIA_UKEY = @CIA_UKEY
			left JOIN StarWestconCALA2.dbo.J08 (NOLOCK) ON J11_UKEYP=J08.UKEY AND J08.CIA_UKEY = @CIA_UKEY
			left JOIN StarWestconCALA2.dbo.J07 (NOLOCK) ON J08.J07_UKEY=J07.UKEY AND J07.CIA_UKEY = @CIA_UKEY
			LEFT JOIN Westcon.Intranet.vwSalesOrder_Division as VwIntranet ON VwIntranet.codPedido = [Westcon].[StarSoft].[FN_GetOVGlobalCode](J07.J07_001_C,1)
			where 
			(ISNULL(@EndInvoiceDate,'') = '' OR F12.F12_002_D < dateadd(dd,1,@EndInvoiceDate)) AND -- Verifica data máxima de emissao 
			(ISNULL(@DataInicialVencimento,'') = '' OR CONVERT(CHAR, F13.F13_002_D, 112) >= CONVERT(CHAR, @DataInicialVencimento, 112)) AND -- Verifica data de vencimento inicial
			(ISNULL(@DataFinalVencimento,'') = '' OR CONVERT(CHAR, F13.F13_002_D, 112) <= CONVERT(CHAR, @DataFinalVencimento, 112)) AND -- Verifica data de vencimento final
			(@Divisao = 0 OR VwIntranet.CodDivisao = @Divisao) AND -- Verifica divisão
			(@Operador = '0' OR USR.UKEY = @Operador) AND -- Verifica Operador
			(@Vendedor = '0' OR A33.UKEY= @Vendedor) AND -- Verifica Vendedor
			(ISNULL(A08.A08_003_C,'') LIKE '%'+RTRIM(LTRIM(@RazaoSocial))+'%' OR ISNULL(A03.A03_003_C,'') LIKE '%'+RTRIM(LTRIM(@RazaoSocial))+'%' ) AND -- Verifica nome do Cliente / Fornecedor
			(F12.F12_PAR = 'A08' or F12.F12_PAR = 'A03')/*id client/fornecedor na A03 ou A08*/ AND
			F12.F12_016_C = '001' /*Tipo igual a título*/ AND
			( F13.F13_010_B - F13.F13_029_B - F13.F13_025_B - F13.F13_021_B - F13.F13_022_B ) > 0 AND
			(ISNULL(@usuarioLogado, '') = '' OR (ISNULL(VwIntranet.CodRegiao, 0) = 0 OR VwIntranet.CodRegiao IN (select R.CodRegiao from tblUsuarioRegiao R INNER JOIN tblUsuario U ON U.CodUsuario  = R.CodUsuario INNER JOIN wcnUsuarioWestcon wU ON wU.IDUsuario = U.CodUsuario WHERE wU.LoginDominio = @usuarioLogado)))
			-- F13.F13_028_N <> 1 /*Status para estorno 0 - Não Estornado ou 2 - Estornado Parcialmente */AND
			-- F13.F13_026_N = 0 /*Status igual a 0 em Aberto */ AND
			--(((F13.F13_015_N = 0 OR F13.F13_015_N = 2) AND F13.F13_024_N = 0))/*(Status 0 em Aberto OU 2 Quitado Parcialmente) E Flag de parcela quitada igual a 0*/	
		END
	
	
END

