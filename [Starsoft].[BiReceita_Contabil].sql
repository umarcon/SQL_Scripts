USE [Westcon]
GO
/****** Object:  StoredProcedure [Starsoft].[BiReceita_Contabil]    Script Date: 14/03/2018 18:10:59 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

ALTER PROCEDURE [Starsoft].[BiReceita_Contabil]
        @CodERP INT, --CodERP vindo da Intranet de(1 = Brasil, 2 = Cala, 3 = Mexico, 4 = Colombia)
        @IDATE DATE, -- Data Inicial da Emissão da NF
        @FDATE DATE -- Data Final da Emissão da NF
AS

--Alterado por Ulisses Marcon - 14/03/2018 - PRIME-1849
-- FOI ALTERADO OS CAMPOS : ValorUnitarioNF, TotalItemNF

-- FOI ALTERADO O CONTEÚDO DO CAMPO FINAL OBSERVATIONS PARA TRAZER O CONTEÚO DO HISTÓRICO DO LANÇAMENTO CONTÁBIL
-- CRODRIGO
-- 22.02.2018

-- ESSA IMPLEMENTAÇÃO SÓ PODERÁ SER VÁLIDA A PARTIR DE 01.09.2017.
-- CRODRIGO - 05.10.2017
IF @IDATE<'20170901'
BEGIN
	SET @IDATE='20170901'
END



BEGIN
	INSERT INTO Reports.BIReceita(
	Fabricante, Familia, TipoHwSw, TipoGrupoSw, DescrNota, PedidoVenda, PedidoVendaTrimmed, NF, TipoES, EmissaoNF, 
	PartNumber, CNPJEmpresaNF, EmpresaNF, Qtd, ValorUnitarioNF, TotalItemNF, CustoMedioUn, CustoMedioTotal, ProvisaoComissaoRevenda, 
	OrigemPipeline, TotalRevendaAntesComissao, ICMS, PIS, COFINS, IRRF, CSLL, IPI, ISS, UF, CIDADE, VENDEDOR, VENDEDORIntranet,
	NFDevolvida, DataEstEntrega, CodPedido, J10_UKEY, CIA_UKEY, J09_UKEY, CodERP, IVA, ICMSST, A03_UKEY, A36_CODE, Currency, 
	USDRate, DataPedido, CodPedidoRevenda, NomeRevenda, EnderecoRevenda,BairroRevenda, CidadeRevenda, UFRevenda, CEPRevenda,  
	PaisRevenda, ContatoRevenda, EmailRevenda, TelRevenda, EnderecoFatura, BairroFatura, CEPFatura, PaisFatura, EmpresaEntrega, 
	EnderecoEntrega, BairroEntrega, CidadeEntrega,UFEntrega, PaisEntrega, EndUser, EnderecoEndUser, BairroEndUser, CidadeEndUser, 
	UFEndUser, CEPEnduser, PaisEndUser, UnitListPrice, ExtendedListPrice, StandardPurchaseDiscountPercentage, 
	ExtendedStandardPurchaseDiscountAmount,SBAType, SBANumber, RebateNumber, SBADiscount, SBAsAdditionalExtendedPurchaseDiscount, 

	ExtendedPurchaseDiscount, UnitPurchasePrice, ExtendedPurchasePrice, PurchasingCurrency, NetPurchaseUnitCost, 
	NetPurchaseExtendedCost, UnitClaimAmount, ExtendedClaimAmount, SFAOpportunityTrackingNumber, ObservacoesFinais, 
	NomeERP, NomeRegiao, DistributorToVendorPO, NomeDivisao, CodDivisao, CodProposta,
	CodCarrinho, CustomerIdGrupoEconomicoRevenda, NomeGrupoEconomicoRevenda, CustomerIdGrupoEconomicoFatura, 
	NomeGrupoEconomicoFatura, ReceitaBrutaDescontadaComissao, ReceitaLiquida, LucroVenda,NetAccounting, NetAccountingRevenue, 
	RevenueType, NetMargin, MaintenanceOrOther, TotalItemNFComICMSSTEIPI, TotalItemNFComIVA, LoginAccountManager, SalesTax, 
	ServiceProvider, ServiceProviderCountry,CEPEntrega, POEfetiva, InvoiceLineNumber, CodRegiao, NomeParte, CBN, 
	SOPurchaseDiscountPercent, Complement, J11_UKEY, Intercompany, CustoMedioUnMN, CustoMedioTotalMN, VendorMKT, ResselerMKT,
	IdIntranet, GDS, [TotalItemNF(Local Currency)], [ReceitaLiquida(Local Currency)], CustoMedioUnUSD, CustoMedioTotalUSD, Uplift_CSP)

	SELECT 
	FABRICANTE, 
	FAMILIA, 
	0 TipoHwSw, 
	'' TipoGrupoSw,  
	DescNota,
	CodPedido PedidoVenda, 
	RTRIM(LTRIM(CodPedido)) PedidoVendaTrimmed, 
	NF, '' TIPOES, 
	EmissaoNF, 
	PartNumber, 
	CIA_006_C CnpjEmpresaNF,
	CIA_001_C EmpresaNF, 1 QTD, 
	--CASE WHEN CustoMedioTotal<>0 THEN CustoMedioTotal ELSE ReceitaLiquida END  VALORUNITARIONF,
	--CASE WHEN CustoMedioTotal<>0 THEN CustoMedioTotal ELSE ReceitaLiquida END  TotalItemNF,
	--ALTERADO - USMARCON - 14.03.2018
	-- QUANDO É CONTA DE CUSTO ESSE CAMPO DEVE VIR COMO 0
	CASE WHEN CustoMedioTotal<>0 THEN 0 ELSE ReceitaLiquida END  VALORUNITARIONF,
	--ALTERADO - USMARCON - 14.03.2018
	-- QUANDO É CONTA DE CUSTO ESSE CAMPO DEVE VIR COMO 0
	CASE WHEN CustoMedioTotal<>0 THEN 0 ELSE ReceitaLiquida END  TotalItemNF,
	CustoMedioTotal CustoMedioUn, 
	CustoMedioTotal CustoMedioTotal,
	0 ProvisaoComissaoRevenda,
	'Accounting' OrigemPipeline,
	ReceitaLiquida TotalRevendaAntesComissao,
	0 ICMS,
	0 PIS,
	0 COFINS, 
	0 IRRF,
	0 CSLL,
	0 IPI,
	0 ISS,
	'' Estado,
	'' Cidade,
	'' Vendedor, 
	'Accounting' VendedorIntranet,
	'' NFDevolvida,
	EMISSAONF  DataEstEntrega, 
	null CodPedido,
	J11_UKEY  J10_UKEY,  
	CIA_UKEY, 
	'' J09_UKEY, 
	CODERP, 
	0 IVA,
	0 ICMSST,
	'' A03_UKEY, 
	Currency A36_CODE,
	CURRENCY,
	USDRATE, 
	EMISSAONF DataPedido,
	null CodPedidoRevenda, 
	'' NomeRevenda,
	'' EnderecoRevenda,
	'' BairroRevenda, 
	'' CidadeRevenda,
	'' UfRevenda,
	'' CEPRevenda,
	'' PaisRevenda,
	'' ContatoRevenda,
	'' EmailRevenda, 
	'' TelRevenda, 
	'' EnderecoFatura,
	'' BairroFatura,
	'' CEPFatura,
	NomeERP PaisFatura,
	'' EmpresaEntrega,
	'' EnderecoEntrega, 
	'' BairroEntrega, 
	'' CidadeEntrega, 
	'' UFEntrega,
	NomeERP PaisEntrega,
	'' EndUser,
	'' EnderecoEndUser,
	'' BairroEndUser,
	'' CidadeEndUser,
	'' UFEndUser,
	'' CEPEndUser,
	'' PaisEndUser,
	ReceitaLiquida UnitListPrice,
	ReceitaLiquida ExtendedListPrice,
	0 StandardPurchaseDiscountPercentage,
	0 ExtendedStandardPurchaseDiscountAmount, 
	null SBAType,
	null SBANumber,
	null RebateNumber,
	0 SBADiscount,
	0 SBAsAdditionalExtendedPurchaseDiscount, 
	0 ExtendedPurchaseDiscount,
	0 UnitPurchasePrice, 
	0 ExtendedPurchasePrice,
	'' PurchasingCurrency,
	CustoMedioTotal NetPurchaseUnitCost,
	CustoMedioTotal NetPurchaseExtendedCost,
	ExtendedClaimAmount UnitClaimAmount, 
	ExtendedClaimAmount,
	null SFAOportunityTrackingNumber, 
	historial ObservacoesFinais, 
	NomeERP,
	NomeRegiao,
	null DistributorToVendorPO,
	
	isnull((SELECT  top 1 tblDivisao.NomeDivisao  FROM WESTCON.DBO.tblEscritorioDivisao (nolock)
	join WESTCON.DBO.tblEscritorio (nolock) on tblEscritorio.CodEscritorio=tblEscritorioDivisao.CodEscritorio 
	join westcon.dbo.tblDivisao    (nolock) on tblDivisao.CodDivisao=tblEscritorioDivisao.CodDivisao 
	where tblEscritorio.cia_ukey=SELECT2.CIA_UKEY AND tblEscritorio.CodErpEscritorio =@CodERP), 'Westcon')  NomeDivisao,
	
	isnull((SELECT  top 1 tblDivisao.CodDivisao  FROM WESTCON.DBO.tblEscritorioDivisao (nolock)
	join WESTCON.DBO.tblEscritorio (nolock) on tblEscritorio.CodEscritorio=tblEscritorioDivisao.CodEscritorio 
	join westcon.dbo.tblDivisao    (nolock) on tblDivisao.CodDivisao=tblEscritorioDivisao.CodDivisao 
	where tblEscritorio.cia_ukey=SELECT2.CIA_UKEY AND tblEscritorio.CodErpEscritorio =@CodERP), 0) 
	
	 CodDivisao,
	null CodProposta,
	null CodCarrinho,
	'' CustomerIdGrupoEconomicoRevenda,
	'Accounting' NomeGrupoEconomicoRevenda,
	'' CustomerIdGrupoEconomicoFatura,
	'' NomeGrupoEconomicoFatura, 
	ReceitaLiquida ReceitaBrutaDescontadaComissao,
	ReceitaLiquida,
	LucroVenda  LucroVenda,
	'No' NetAccounting,
	ReceitaLiquida NetAccountingRevenue,
	'' RevenueType, 
	0 NetMarging,
	'Other' MaintenanceOrOther,
	ReceitaLiquida TotalItemNFComICMSEIPI,
	ReceitaLiquida TotalItemNFComIVA,
	'Accounting' LoginAccountManager,
	0 SalesTax,
	null ServiceProvider, 
	null ServiceProviderCountry, 
	'' CepEntrega,
	null PoEfetiva,
	'00005' InvoiceLineNumber,
	CodErp CodRegiao,
	PartNumber NomeParte,
	null CBN,
	0 SOPurchaseDiscountPercent,
	0 Complement, 
	J11_UKEY, 
	CASE WHEN CODERP=2 AND PartNumber in ('3302050008', '3302050009') then 'Yes' else 'No' end 	InterCompany,
 	CustoMedioTotal CustoMedioUNMN,
	CustoMedioTotal CustoMedioTotalMN,
	0 VendorMKT,
	0 ResselerMKT,
	null IDIntranet,
	null GDS,
	ReceitaLiquida 'TotalItemNF(Local Currency)',
	ReceitaLiquida 'ReceitaLiquida(Local Currency)'
	,CustoMedioTotal / CASE WHEN USDRATE>0 THEN USDRATE ELSE 1 END CustoMedioUnUSD
	,CustoMedioTotal / CASE WHEN USDRATE>0 THEN USDRATE ELSE 1 END CustoMedioTotalUSD, 

	0 Uplift_CSP 

	FROM 

	(


	SELECT 
	historial,
	CIA_006_C, CIA_001_C, CIA_UKEY, 


	FABRICANTE, FAMILIA, NF, EMISSAONF, sum(CustoMedioTotal) CustoMedioTotal, CodPedido, CodErp, Currency, 
	RebateNumber, 
	sum(ExtendedClaimAmount) ExtendedClaimAmount, 
	NomeERP, NomeRegiao, NomeDivisao, 
	sum(ReceitaLiquida) ReceitaLiquida, 
	sum((ReceitaLiquida-CustoMedioTotal)+(ExtendedClaimAmount*USDRATE))     LucroVenda, 
	CodRegiao, J11_UKEY, PartNumber, ValorUnitarioNF, 
	NFDevolvida, Complement, InterCompany, NomeVendor, USDRATE, DescNota

	FROM (

	SELECT DISTINCT 
	
	cast(b07_002_m as varchar(255)) historial,

	CIA_006_C, CIA_001_C, CIA.UKEY CIA_UKEY , 
	CASE WHEN SUBSTRING(A11_001_C,1,3)='143' OR SUBSTRING(A11_001_C,1,2)='50' THEN  NomeVendor  ELSE 'Shared Costs' END FABRICANTE,
	CASE WHEN SUBSTRING(A11_001_C,1,3)='143' OR SUBSTRING(A11_001_C,1,2)='50' THEN  NomeVendor  ELSE 'Shared Costs' END FAMILIA,
	'Hyperion Exp ' + CONVERT(VARCHAR(8), B07_003_D, 112) NF,
	CONVERT(date, B07_003_D) EMISSAONF,
	CASE WHEN B11_001_C IN ('3301010099', '3301020099')  THEN 0
	ELSE
	CASE WHEN SUBSTRING(B19_001_C,1,1)='5' OR  B11_001_C='4101100001'  THEN CASE WHEN B07_011_N=1 THEN 1 ELSE -1 END * B04_001_B ELSE 0  END END CustoMedioTotal,
	LTRIM(RTRIM(B06_001_C)) CodPedido,
	1 CodERP,
	'R$'  Currency,
	'' RebateNumber,
	
	CASE WHEN B11_001_C IN ('3301010099', '3301020099')  
	THEN 
	
	CASE 
	WHEN B07_011_N=1 THEN -1 ELSE 1 END* B04_001_B ELSE 0  END 
	
	/ CASE WHEN 
	ISNULL((SELECT  TOP 1 A37_002_B FROM STARWESTCON.DBO.A37 (NOLOCK) WHERE A37.A36_UKEY='R$' AND A37.A36_UKEYA='US$' AND A37_001_D<=B07.B07_003_D ORDER BY A37_001_D DESC),0)>0
	THEN
	ISNULL((SELECT  TOP 1 A37_002_B FROM STARWESTCON.DBO.A37 (NOLOCK) WHERE A37.A36_UKEY='R$' AND A37.A36_UKEYA='US$' AND A37_001_D<=B07.B07_003_D ORDER BY A37_001_D DESC),0)
	ELSE
	1 END
	
	
	
	ExtendedClaimAmount,
	-- PROPER
	UPPER(SUBSTRING(ISNULL(A22.A22_001_C,''),1,1)) + LOWER(SUBSTRING(ISNULL(A22.A22_001_C,''),2,30)) NomeERP,
	'BR' NomeRegiao,
	'Westcon' NomeDivisao,

	CASE WHEN B11_001_C IN ('3301010099', '3301020099')  THEN 0
	ELSE
	CASE WHEN SUBSTRING(B19_001_C,1,1)='4' THEN CASE WHEN B07_012_N=1 THEN 1 ELSE -1 END*B04_001_B ELSE 0  END  END ReceitaLiquida,
	0 LucroVenda,
	1 CodRegiao,
	B04.UKEY J11_UKEY,
	B11.B11_001_C PartNumber,
	B11.B11_003_C DescNota,
	0 ValorUnitarioNF,
	'' NFDevolvida,
	0 Complement,
	'No' Intercompany,
	CASE WHEN SUBSTRING(A11_001_C,1,3)='143' OR SUBSTRING(A11_001_C,1,2)='50' THEN  TBLVENDOR.NomeVendor   ELSE 'Shared Costs' END NomeVendor

	,ISNULL((SELECT  TOP 1 A37_002_B FROM STARWESTCON.DBO.A37 (NOLOCK) WHERE A37.A36_UKEY='R$' AND A37.A36_UKEYA='US$' AND A37_001_D<=B07.B07_003_D ORDER BY A37_001_D DESC),0) USDRATE

	FROM STARWESTCON.DBO.A11      (NOLOCK) 
	JOIN STARWESTCON.DBO.B04      (NOLOCK) ON B04.A11_UKEY=A11.UKEY
	JOIN STARWESTCON.DBO.CIA      (NOLOCK) ON B04.CIA_UKEY=CIA.UKEY
	LEFT JOIN STARWESTCON.DBO.A22 (NOLOCK) ON CIA.A22_UKEY=A22.UKEY
	JOIN STARWESTCON.DBO.B07      (NOLOCK) ON B07.UKEY=B04_UKEYP AND B04_004_C='B07_007_B'
	JOIN STARWESTCON.DBO.B11      (NOLOCK) ON B07.B11_UKEY=B11.UKEY
	JOIN STARWESTCON.DBO.WE30     (NOLOCK) ON WE30.B11_UKEY=B11.UKEY
	JOIN STARWESTCONCALA2.DBO.B19 (NOLOCK) ON WE30.B19_UKEY=B19.UKEY
	JOIN STARWESTCON.DBO.B06      (NOLOCK) ON B07.B06_UKEY=B06.UKEY
	LEFT JOIN STARWESTCON.DBO.F18 (NOLOCK) ON B06_UKEYP=F18.UKEY
	LEFT JOIN WESTCON.DBO.TBLVENDOR (NOLOCK) ON  TBLVENDOR.CODVENDOR=A11.A11_CODVENDOR
	WHERE 
	@CODERP=1 AND 
	CIA.UKEY NOT IN ('AFIES', 'OSL0R') 	
	AND B07_003_D BETWEEN @IDATE AND @FDATE
	AND B06_011_N=0 
	AND CIA_001_C NOT LIKE '%AFINA%'
	AND (SUBSTRING(B19_001_C,1,1) IN ('5','4') OR B11_001_C IN ('3301010099', '3301020099', '4101100001'))
	AND B11_001_C NOT IN ('3302050002')
	AND B06_PAR<>'J10'
	AND B04.UKEY NOT IN (SELECT J11_UKEY FROM WESTCON.Reports.BIReceita (NOLOCK))


	) SELECT1

	GROUP BY 
	HISTORIAL,
	CIA_006_C, CIA_001_C, CIA_UKEY,
	FABRICANTE, FAMILIA, NF, EMISSAONF, CodPedido, CodErp, Currency, 
	RebateNumber, NomeERP, NomeRegiao, NomeDivisao, CodRegiao, J11_UKEY, PartNumber, ValorUnitarioNF, 
	NFDevolvida, Complement, InterCompany, NomeVendor, USDRATE, DescNota


	UNION ALL 


	SELECT 
	historial,
	CIA_006_C, CIA_001_C,  CIA_UKEY , 
	FABRICANTE, FAMILIA, NF, EMISSAONF, sum(CustoMedioTotal) CustoMedioTotal, CodPedido, CodErp, Currency, 
	RebateNumber, sum(ExtendedClaimAmount) ExtendedClaimAmount, 
	NomeERP, NomeRegiao, NomeDivisao, sum(ReceitaLiquida) ReceitaLiquida, 
	sum((ReceitaLiquida-CustoMedioTotal)+(ExtendedClaimAmount*USDRATE))     LucroVenda, 
	CodRegiao, J11_UKEY, PartNumber, ValorUnitarioNF, 
	NFDevolvida, Complement, InterCompany, NomeVendor, USDRATE, DescNota

	FROM (
	SELECT DISTINCT 
	cast(b07_002_m as varchar(255)) historial,
	CIA_006_C, CIA_001_C, CIA.UKEY CIA_UKEY , 
	CASE WHEN SUBSTRING(A11_001_C,1,2)='50' THEN  A11_003_C  ELSE 'Shared Costs' END FABRICANTE,
	CASE WHEN SUBSTRING(A11_001_C,1,2)='50' THEN  A11_003_C  ELSE 'Shared Costs' END FAMILIA,
	'Hyperion Exp ' + CONVERT(VARCHAR(8), B07_003_D, 112) NF,
	CONVERT(date, B07_003_D) EMISSAONF,

	CASE WHEN B11_001_C IN ('3301010005')  THEN 0
	ELSE
	CASE WHEN SUBSTRING(B19_001_C,1,1)='5' OR (RTRIM(LTRIM(B19_001_C))='41601' AND RTRIM(LTRIM(B11_001_C))='3301010040') THEN CASE WHEN B07_011_N=1 THEN 1 ELSE -1 END * B04_001_B ELSE 0  END 
	END CustoMedioTotal,
	LTRIM(RTRIM(B06_001_C)) CodPedido,
	TBLERP.CODERP CodERP,
	'MN'  Currency,
	'' RebateNumber,
	CASE WHEN B11_001_C IN ('3301010005')  THEN CASE 
	WHEN B07_011_N=1 THEN -1 ELSE 1 END* B04_001_B ELSE 0  END
	/ 

	CASE WHEN B07_007_B>0.10 AND B07_008_B>0.10 THEN ROUND(B07_007_B/B07_008_B,4)
		ELSE	
		
			CASE WHEN 
				ISNULL((SELECT  TOP 1 A37_002_B FROM STARWESTCONMX.DBO.A37 (NOLOCK) WHERE A37.A36_UKEY='MN' AND A37.A36_UKEYA='US$' AND A37_001_D<=B07.B07_003_D ORDER BY A37_001_D DESC),0)>0
			THEN
				ISNULL((SELECT  TOP 1 A37_002_B FROM STARWESTCONMX.DBO.A37 (NOLOCK) WHERE A37.A36_UKEY='MN' AND A37.A36_UKEYA='US$' AND A37_001_D<=B07.B07_003_D ORDER BY A37_001_D DESC),0)
			ELSE
				1 
			END
	END

		
	ExtendedClaimAmount,
	-- PROPER
	UPPER(SUBSTRING(ISNULL(A22.A22_001_C,''),1,1)) + LOWER(SUBSTRING(ISNULL(A22.A22_001_C,''),2,30)) NomeERP,
	'MX' NomeRegiao,
	'Westcon' NomeDivisao,

	CASE WHEN B11_001_C IN ('3301010005')  THEN 0
	ELSE

	

	CASE WHEN SUBSTRING(B19_001_C,1,1)='4'  
		THEN CASE WHEN B07_012_N=1 THEN 1 ELSE -1 END
		*  (B04_001_B*	CASE WHEN (RTRIM(LTRIM(B19_001_C))='41601' AND RTRIM(LTRIM(B11_001_C))='3301010040') THEN 0 ELSE 1 END)
	ELSE 0  END  END 
	ReceitaLiquida,

	0 LucroVenda,
	TBLERP.CODERP CodRegiao,
	B04.UKEY J11_UKEY,
	B11.B11_001_C PartNumber,
	B11.B11_003_C DescNota,
	0 ValorUnitarioNF,
	'' NFDevolvida,
	0 Complement,
	'No' Intercompany,
	CASE WHEN SUBSTRING(A11_001_C,1,2)='50' THEN  TBLVENDOR.NomeVendor   ELSE 'Shared Costs' END NomeVendor

	,
	-- CASO TENHA TIPO DE CAMBIO NA CONTABILIDADE, COSNSIDERA ESSE
	CASE WHEN B07_007_B>0.10 AND B07_008_B>0.10 THEN ROUND(B07_007_B/B07_008_B,4)
	ELSE	
		ISNULL((SELECT  TOP 1 A37_002_B FROM STARWESTCONMX.DBO.A37 (NOLOCK) WHERE A37.A36_UKEY='MN' AND A37.A36_UKEYA='US$' AND A37_001_D<=B07.B07_003_D ORDER BY A37_001_D DESC),0) 
	END
	
	USDRATE



	FROM StarWestconMX.DBO.A11      (NOLOCK) 
	JOIN StarWestconMX.DBO.B04      (NOLOCK) ON B04.A11_UKEY=A11.UKEY
	JOIN StarWestconMX.DBO.CIA      (NOLOCK) ON B04.CIA_UKEY=CIA.UKEY
	JOIN WESTCON.DBO.TBLERP (NOLOCK) ON TBLERP.CIA_UKEYPADRAO=CIA.UKEY 
	LEFT JOIN StarWestconMX.DBO.A22 (NOLOCK) ON CIA.A22_UKEY=A22.UKEY
	JOIN StarWestconMX.DBO.B07      (NOLOCK) ON B07.UKEY=B04_UKEYP AND B04_004_C='B07_007_B'
	JOIN StarWestconMX.DBO.B11      (NOLOCK) ON B07.B11_UKEY=B11.UKEY
	JOIN StarWestconMX.DBO.WE30     (NOLOCK) ON WE30.B11_UKEY=B11.UKEY
	JOIN STARWESTCONCALA2.DBO.B19 (NOLOCK) ON WE30.B19_UKEY=B19.UKEY
	JOIN StarWestconMX.DBO.B06      (NOLOCK) ON B07.B06_UKEY=B06.UKEY
	LEFT JOIN StarWestconMX.DBO.F18 (NOLOCK) ON B06_UKEYP=F18.UKEY
	LEFT JOIN WESTCON.DBO.TBLVENDOR (NOLOCK) ON  TBLVENDOR.CODVENDOR=A11.A11_CODVENDOR  /*SUBSTRING(RTRIM(LTRIM(TBLVENDOR.NomeVendor)),1,10)=SUBSTRING(RTRIM(LTRIM(A11_003_C)) ,1,10) - INC0487786*/
	WHERE 
	TBLERP.CODERP=@CODERP AND
	B07_003_D BETWEEN @IDATE AND @FDATE 
	AND B06_011_N=0 
	AND (SUBSTRING(B19_001_C,1,1) IN ('5','4') OR B11_001_C IN ('3301010005'))
	AND B11_001_C NOT IN ('4101020002')
	AND B06_PAR<>'J10'
	AND B04.UKEY NOT IN (SELECT J11_UKEY FROM WESTCON.Reports.BIReceita (NOLOCK))

	) SELECT1

	GROUP BY 
	HISTORIAL, CIA_006_C, CIA_001_C, CIA_UKEY, 
	FABRICANTE, FAMILIA, NF, EMISSAONF, CodPedido, CodErp, Currency, 
	RebateNumber, NomeERP, NomeRegiao, NomeDivisao, CodRegiao, J11_UKEY, PartNumber, ValorUnitarioNF, 
	NFDevolvida, Complement, InterCompany, NomeVendor, USDRATE, DescNota


	UNION ALL 

	SELECT
	historial,
	CIA_006_C, CIA_001_C, CIA_UKEY , 
	FABRICANTE, FAMILIA, NF, EMISSAONF, sum(CustoMedioTotal) CustoMedioTotal, CodPedido, CodErp, Currency, 
	RebateNumber, sum(ExtendedClaimAmount) ExtendedClaimAmount, 
	NomeERP, NomeRegiao, NomeDivisao, sum(ReceitaLiquida) ReceitaLiquida, 
	sum((ReceitaLiquida-CustoMedioTotal)+(ExtendedClaimAmount*USDRATE))     LucroVenda, 
	CodRegiao, J11_UKEY, PartNumber, ValorUnitarioNF, 
	NFDevolvida, Complement, InterCompany, NomeVendor, USDRATE, DescNota
	FROM (

	SELECT DISTINCT 
	cast(b07_002_m as varchar(255)) historial,
	CIA_006_C, CIA_001_C, CIA.UKEY CIA_UKEY , 
	CASE WHEN SUBSTRING(A11_001_C,1,2) IN ('20','50') THEN  NomeVendor  ELSE 'Shared Costs' END FABRICANTE,
	CASE WHEN SUBSTRING(A11_001_C,1,2)  IN('20','50') THEN  NomeVendor  ELSE 'Shared Costs' END FAMILIA,
	'Hyperion Exp ' + CONVERT(VARCHAR(8), B07_003_D, 112) NF,
	CONVERT(date, B07_003_D) EMISSAONF,


	ISNULL(CASE WHEN 
		-- ARGENTINA
		(B11_001_C='411303' and B11.CIA_UKEY='5DTR4') OR 
		-- CHILE
		(B11_001_C IN ('30202009', '30202010') AND B11.CIA_UKEY='5J6PB')  OR 
		-- CALA
		(B11_001_C IN ('3302050003', '3302050004', '3302050005', '3302050006', '3302050007', '3302050008', '3302050009', '3302050010') AND B11.CIA_UKEY='STAR_') OR 
		-- PERU
		(B11_001_C IN ('6329208','6329209') AND B11.CIA_UKEY='P6SIH') OR 
		-- ECUADOR
		(B11_001_C IN ('117102') AND B11.CIA_UKEY='5HV8Z') 
		THEN 
		0
		ELSE
		CASE WHEN SUBSTRING(B19_001_C,1,1)='5' 
		THEN 
			CASE WHEN B07_011_N=1 
				THEN 1 ELSE -1 
			END * ISNULL(B04.B04_001_B ,0)
		ELSE 0  
			END END,0) CustoMedioTotal,

	LTRIM(RTRIM(B06_001_C)) CodPedido,
	@CodErp CodERP,
	CIA.A36_UKEY  Currency,
	'' RebateNumber,

	ISNULL(CASE WHEN 
	-- ARGENTINA
	(b11_001_c='411303' and B11.CIA_UKEY='5DTR4') OR 
	-- CHILE
	(B11_001_C IN ('30202009', '30202010') AND B11.CIA_UKEY='5J6PB')  OR 
	-- CALA
	(B11_001_C IN ('3302050003', '3302050004', '3302050005', '3302050006', '3302050007', '3302050008', '3302050009', '3302050010') AND B11.CIA_UKEY='STAR_') OR 
	-- PERU
	(B11_001_C IN ('6329208','6329209') AND B11.CIA_UKEY='P6SIH') OR
	-- ECUADOR
	(B11_001_C IN ('117102') AND B11.CIA_UKEY='5HV8Z') 
	THEN 
		CASE 
			WHEN B07_011_N=1 THEN -1 ELSE 1 END* B04.B04_001_B 
		ELSE 
		0  
	END,0) 
	
	/ 
	
	CASE WHEN 
		CASE @CODERP
	-- CALA
		WHEN 2 THEN 1
	-- ECUADOR
		WHEN 6 THEN 1 
	-- COLOMBIA
		WHEN 4 THEN ISNULL((SELECT  TOP 1 A37_002_B FROM STARWESTCONCALA2.WCAL.A37 (NOLOCK) WHERE A37.A36_UKEY='$' AND A37.A36_UKEYA='US$' AND A37_001_D<=B07.B07_003_D ORDER BY A37_001_D DESC),0) 
	-- CHILE
		WHEN 8 THEN ISNULL((SELECT  TOP 1 A37_002_B FROM STARWESTCONCALA2.WCHI.A37 (NOLOCK) WHERE A37.A36_UKEY='CLP' AND A37.A36_UKEYA='US$' AND A37_001_D<=B07.B07_003_D ORDER BY A37_001_D DESC),0) 
	-- ARGENTINA
		WHEN 7 THEN ISNULL((SELECT  TOP 1 A37_002_B FROM STARWESTCONCALA2.WARG.A37 (NOLOCK) WHERE A37.A36_UKEY='ARS' AND A37.A36_UKEYA='US$' AND A37_001_D<=B07.B07_003_D ORDER BY A37_001_D DESC),0) 
	-- CHILE
		WHEN 5 THEN ISNULL((SELECT  TOP 1 A37_002_B FROM STARWESTCONCALA2.WPERU.A37 (NOLOCK) WHERE A37.A36_UKEY='PEN' AND A37.A36_UKEYA='US$' AND A37_001_D<=B07.B07_003_D ORDER BY A37_001_D DESC),0) 
		ELSE 1
		END>0
	THEN

		CASE  @CODERP
		-- CALA
			WHEN 2 THEN 1
		-- ECUADOR
			WHEN 6 THEN 1 
		-- COLOMBIA
			WHEN 4 THEN ISNULL((SELECT  TOP 1 A37_002_B FROM STARWESTCONCALA2.WCAL.A37 (NOLOCK) WHERE A37.A36_UKEY='$' AND A37.A36_UKEYA='US$' AND A37_001_D<=B07.B07_003_D ORDER BY A37_001_D DESC),0) 
		-- CHILE
			WHEN 8 THEN ISNULL((SELECT  TOP 1 A37_002_B FROM STARWESTCONCALA2.WCHI.A37 (NOLOCK) WHERE A37.A36_UKEY='CLP' AND A37.A36_UKEYA='US$' AND A37_001_D<=B07.B07_003_D ORDER BY A37_001_D DESC),0) 
		-- ARGENTINA
			WHEN 7 THEN ISNULL((SELECT  TOP 1 A37_002_B FROM STARWESTCONCALA2.WARG.A37 (NOLOCK) WHERE A37.A36_UKEY='ARS' AND A37.A36_UKEYA='US$' AND A37_001_D<=B07.B07_003_D ORDER BY A37_001_D DESC),0) 
		-- CHILE
			WHEN 5 THEN ISNULL((SELECT  TOP 1 A37_002_B FROM STARWESTCONCALA2.WPERU.A37 (NOLOCK) WHERE A37.A36_UKEY='PEN' AND A37.A36_UKEYA='US$' AND A37_001_D<=B07.B07_003_D ORDER BY A37_001_D DESC),0) 
			ELSE 1
		END

	ELSE
		1 
	END

	
	
	
	ExtendedClaimAmount,


	-- PROPER
	(SELECT TBLERP.NomeERP FROM WESTCON.DBO.TBLERP (NOLOCK) WHERE TBLERP.CODERP=@CODERP) NomeERP, 
	SUBSTRING(UPPER((SELECT TBLERP.NomeERP FROM WESTCON.DBO.TBLERP (NOLOCK) WHERE TBLERP.CODERP=@CODERP)),1,2) NomeRegiao,
	'Westcon' NomeDivisao,

	ISNULL(CASE WHEN 
	-- ARGENTINA
	(b11_001_c='411303' and B11.CIA_UKEY='5DTR4') OR 
	-- CHILE
	(B11_001_C IN ('30202009', '30202010') AND B11.CIA_UKEY='5J6PB')  OR 
	-- CALA
	(B11_001_C IN ('3302050003', '3302050004', '3302050005', '3302050006', '3302050007', '3302050008', '3302050009', '3302050010') AND B11.CIA_UKEY='STAR_') OR 
	-- PERU
	(B11_001_C IN ('6329208','6329209') AND B11.CIA_UKEY='P6SIH') OR
	-- ECUADOR
	(B11_001_C IN ('117102') AND B11.CIA_UKEY='5HV8Z') 
	THEN 0
	ELSE
	CASE WHEN SUBSTRING(B19_001_C,1,1)='4' THEN CASE WHEN B07_012_N=1 THEN 1 ELSE -1 END*B04.B04_001_B ELSE 0  END  END,0) ReceitaLiquida,
	0 LucroVenda,
	1 CodRegiao,
	B04.UKEY J11_UKEY,
	B11.B11_001_C PartNumber,
	B11.B11_003_C DescNota,
	0 ValorUnitarioNF,
	'' NFDevolvida,
	0 Complement,
	'No' Intercompany,


	CASE WHEN SUBSTRING(A11_001_C,1,2) IN ('20', '50') THEN  TBLVENDOR.NomeVendor   ELSE 'Shared Costs' END NomeVendor

	,CASE @CODERP 
	-- CALA
		WHEN 2 THEN 1
	-- ECUADOR
		WHEN 6 THEN 1 
	-- COLOMBIA
		WHEN 4 THEN ISNULL((SELECT  TOP 1 A37_002_B FROM STARWESTCONCALA2.WCAL.A37 (NOLOCK) WHERE A37.A36_UKEY='$' AND A37.A36_UKEYA='US$' AND A37_001_D<=B07.B07_003_D ORDER BY A37_001_D DESC),0) 
	-- CHILE
		WHEN 8 THEN ISNULL((SELECT  TOP 1 A37_002_B FROM STARWESTCONCALA2.WCHI.A37 (NOLOCK) WHERE A37.A36_UKEY='CLP' AND A37.A36_UKEYA='US$' AND A37_001_D<=B07.B07_003_D ORDER BY A37_001_D DESC),0) 
	-- ARGENTINA
		WHEN 7 THEN ISNULL((SELECT  TOP 1 A37_002_B FROM STARWESTCONCALA2.WARG.A37 (NOLOCK) WHERE A37.A36_UKEY='ARS' AND A37.A36_UKEYA='US$' AND A37_001_D<=B07.B07_003_D ORDER BY A37_001_D DESC),0) 
	-- CHILE
		WHEN 5 THEN ISNULL((SELECT  TOP 1 A37_002_B FROM STARWESTCONCALA2.WPERU.A37 (NOLOCK) WHERE A37.A36_UKEY='PEN' AND A37.A36_UKEYA='US$' AND A37_001_D<=B07.B07_003_D ORDER BY A37_001_D DESC),0) 
		ELSE 1
	END as USDRATE

	FROM STARWESTCONCALA2.DBO.A11      (NOLOCK) 
	JOIN STARWESTCONCALA2.DBO.B04      (NOLOCK) ON B04.A11_UKEY=A11.UKEY
	JOIN STARWESTCONCALA2.DBO.CIA      (NOLOCK) ON B04.CIA_UKEY=   CIA.UKEY
	LEFT JOIN STARWESTCONCALA2.DBO.A22 (NOLOCK) ON CIA.A22_UKEY=A22.UKEY
	JOIN STARWESTCONCALA2.DBO.B07      (NOLOCK) ON B07.UKEY=B04_UKEYP AND B04_004_C='B07_007_B'
	JOIN STARWESTCONCALA2.DBO.B11      (NOLOCK) ON B07.B11_UKEY=B11.UKEY
	JOIN STARWESTCONCALA2.DBO.WE30     (NOLOCK) ON WE30.B11_UKEY=B11.UKEY
	JOIN STARWESTCONCALA2.DBO.B19 (NOLOCK) ON WE30.B19_UKEY=B19.UKEY
	JOIN STARWESTCONCALA2.DBO.B06      (NOLOCK) ON B07.B06_UKEY=B06.UKEY
	LEFT JOIN STARWESTCONCALA2.DBO.F18 (NOLOCK) ON B06_UKEYP=F18.UKEY
	LEFT JOIN WESTCON.DBO.TBLVENDOR (NOLOCK) ON  TBLVENDOR.CODVENDOR=A11.A11_CODVENDOR
	WHERE 
	((@CODERP=4 AND CIA.UKEY IN ('M8530', 'M8531') )
	OR 
	(@CODERP<>4 AND EXISTS (SELECT TOP 1 TBLERP.CIA_UKEYPADRAO FROM WESTCON.DBO.TBLERP (NOLOCK) WHERE TBLERP.CODERP=@CODERP AND TBLERP.CIA_UKEYPADRAO=CIA.UKEY AND TBLERP.CODERP<>1)))
	AND 
	B07_003_D BETWEEN @IDATE AND @FDATE
	AND B06_011_N=0 
	AND (SUBSTRING(B19_001_C,1,1) IN ('5','4') OR B11_001_C IN ('3301010099', '3301020099'))
	AND B11_003_C NOT IN ('COMMISSIONS', 'COMISIONES')  
	AND B06_PAR<>'J10'
	AND B04.UKEY NOT IN (SELECT J11_UKEY FROM WESTCON.Reports.BIReceita (NOLOCK))

	) SELECT1

	GROUP BY 
	historial,
	CIA_006_C, CIA_001_C, CIA_UKEY, 
	FABRICANTE, FAMILIA, NF, EMISSAONF, CodPedido, CodErp, Currency, 
	RebateNumber, NomeERP, NomeRegiao, NomeDivisao, CodRegiao, J11_UKEY, PartNumber, ValorUnitarioNF, 
	NFDevolvida, Complement, InterCompany, NomeVendor, USDRATE, DescNota


	) SELECT2
	ORDER BY CODERP, EMISSAONF



END
