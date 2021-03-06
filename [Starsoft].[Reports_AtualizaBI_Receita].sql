USE [Westcon]
GO
/****** Object:  StoredProcedure [Starsoft].[Reports_AtualizaBI_Receita]    Script Date: 17/10/2016 15:37:57 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


ALTER PROCEDURE [Starsoft].[Reports_AtualizaBI_Receita]

/****************************************************************************************************                                                                               
* Objetivo : - Trazer informações referente as Notas Fiscais com impostos e informacoes da intranet *
*       Obs: - No parametro @VENDOR, ao adicionar '0' tráz todos os fabricantes.                    *
*              Essas informações são inseridas em uma tabela definitiva, sendo ela a                *
*              Reprots.BIReceita. Caso essa tabela já possua informações, estas são deletadas e		*
*              inseridas as informações da nova execução.											*
*																									*
*****************************************************************************************************
*****************************************************************************************************
*****************************************************************************************************
*	OS CAMPOS DO SELECT DO ERP 1 SÃO OS MESMOS DOS DEMAIS ERPS										*
*	OU SEJA, SE FIZER UMA ALTERAÇÃO EM ALGUMA FÓRMULA, PODE COPIAR O								*
*	SELECT (APENAS O SELECT, TOMANDO MUITO CUIDADO COM O FROM, POR FAVOR!!!) DESTE ERP E ALTERAR	*
*	PARA TODOS OS DEMAIS																			*
*****************************************************************************************************
*****************************************************************************************************
*****************************************************************************************************

* Alteracoes :


*- Alteração - Thviotto dia 10/10/2016 - SCRUM-15463 mudei a chamada da [StarSoft].[fnReceitaProdutosBR] para [StarSoft].[fnReceitaProdutosBR] e adicionei o parameto a mais

- Alterado em 28/06/2016 por Peterson Ricardo
Alterado os campos ResselerMK e VendorMkt para calcular pelo fator, quando for devolução o valor devera aparecer negativo 
-- ref. chamado service now: INC0404904


- Alterado em 28/06/2016 por ELCruz
Alterado os campos Familia e Fabricante para considerar as informações do Appl quando a NF do Appl não possuir uma OV da Intranet Associada

 - Alterado em 09/05/2016 17:35:41 por Thviotto
SCRUM-15091, 


- Alterado em 18/11/2015 por Thiago Motta
SCRUM-14727: Eu gostaria de classificar propostas com tags
Incluído o campo GDS na tabela BiReceita


- Alterado em 27/08/2015 por ELCruz
Incluído o campo IDIntranet na tabela BIReceita pois esse campo é a chave única de ligação entre o item da OV na Intranet e no SSA.
Isso foi necessário porque quando o mesmo partnumber era informado mais de uma vez na mesma OV as informações estavam duplicando

- Alterado em 27/08/2015 por ELCruz
INC0273508 -  Alterado a fórmula do campo receita líquida conforme especificações abaixo: 
TotalItemNF-ICMS-PIS-COFINS-ISS-ProvisaoComissaoRevenda -- negativo se for devolução


- Alterado em 23/12/2014 por ELCruz
Desenvolvido um  novo script para popular a tabela BIReceita pelo Andres devido à demora na execução do modelo antigo. Essa é uma solução temporária (Apaga Incêndio) , 
pois quando Baiano voltar de férias iremos discutir isso

- Alterado em 09/05/14 por ELCruz (SCRUM-8097)
Correção das colunas ReceitaLiquida e LucroVenda conforme especificações abaixo: 
ReceitaLiquida = TotalItemNF-ICMS-PIS-COFINS-IRRF-CSLL-ISS-ProvisaoComissaoRevenda -- negativo se for devolução
LucroVenda = ReceitaLiquida-CustoMedioTotal+(ExtendedClaimAmount*USDRate)

- Alterado em 02/05/14 por ELCruz (SCRUM-7909)
Correção das colunas TotalItemNFComICMSSTeIPI e TotalItemNFComIVA para que ambas sejam apresentadas com valores negativos quando se tratar de nf de devolução de venda

- Alterado em 06/12/13 por ELCruz
Foi adicionada a coluna J11_UKEY para permitir criar uma chave única na tabela BIReceita contendo os campos CODERP, CIA_UKEY, J10_UKEY, J11_UKEY
Foi adicionada a coluna "Intercompany" referente ao cadastro do cliente para facilitar na visualização dos retlatórios
A Coluna "InvoiceLineNumber" foi alterada para retornar a informação exata contida na tabela do applications, pois no applications essa informação é iniciada e inclementada por 5,
porém anteriormente estavámos dividindo essa numeração por 5 para demonstra-la como número sequencial


|---------------------------------------------------------------------------------------------------|
| DATA      | RESPONSAVEL    | VERSAO        | ALTERACAO                                            |
|-----------+----------------+---------------+----------------------------------------------------------------------------------------|
|27/11/2013 |ELCruz      	 | 1.6.4		 | Foi add a coluna "Complement" onde deverá indicar se a NF é uma nota complementar. Nesse momento essa funcionalidade esta sendo usada apenas para o BR
|-----------+----------------+---------------|----------------------------------------------------------------------------------------|

|---------------------------------------------------------------------------------------------------|
| DATA      | RESPONSAVEL    | VERSAO        | ALTERACAO                                            |
|-----------+----------------+---------------+----------------------------------------------------------------------------------------|
|02/10/2013 |ELCruz      	 | 1.6.3		 | Foi add a coluna "SOPurchaseDiscountPercent" de acordo com a regra: 'case when SBADiscount<>0 AND SBAType='Front End' THEN SBADiscount ELSE StandardPurchaseDiscountPercentage END as PurchaseDiscountPercent
|-----------+----------------+---------------|----------------------------------------------------------------------------------------|

|---------------------------------------------------------------------------------------------------|
| DATA      | RESPONSAVEL    | VERSAO        | ALTERACAO                                            |
|-----------+----------------+---------------+----------------------------------------------------------------------------------------|
|13/09/2013 |Thiago Motta	 | 1.6.2		 | Alteração do campo CBN para cada erp. Este campo é retornado pela view RECEITA_INTRANET
|-----------+----------------+---------------|----------------------------------------------------------------------------------------|


|---------------------------------------------------------------------------------------------------|
| DATA      | RESPONSAVEL    | VERSAO        | ALTERACAO                                            |
|-----------+----------------+---------------+----------------------------------------------------------------------------------------|
|26/07/2013 |Maurício 	     | 1.6.1		 | Inclusão do campo CodERP no left join de RECEITA_INTRANET para cada erp correspondente
|-----------+----------------+---------------|----------------------------------------------------------------------------------------|


|---------------------------------------------------------------------------------------------------|
| DATA      | RESPONSAVEL    | VERSAO        | ALTERACAO                                            |
|-----------+----------------+---------------+----------------------------------------------------------------------------------------|
|23/07/2013 |Leo			 | 1.6           |Inclusão do campo NomeParte disponibilizado pela view da Intranet
|-----------+----------------+---------------|----------------------------------------------------------------------------------------|


|---------------------------------------------------------------------------------------------------|
| DATA      | RESPONSAVEL    | VERSAO        | ALTERACAO                                            |
|-----------+----------------+---------------+----------------------------------------------------------------------------------------|
|10/06/2012 |Thiago Motta	 | 1.5           | Alteração na forma de gravação do campo StandardPurchaseDiscountPercentage.
|			|				 |				 | A partir de agora, se o campo for NULL, será obtido o desconto padrão na intranet
|			|				 |				 | SCRUM-2887
|			|				 |				 | 
|			|				 |				 | Inclusão do campo CodRegiao. SCRUM-2894
|-----------+----------------+---------------|----------------------------------------------------------------------------------------|


|---------------------------------------------------------------------------------------------------|
| DATA      | RESPONSAVEL    | VERSAO        | ALTERACAO                                            |
|-----------+----------------+---------------+----------------------------------------------------------------------------------------|
|07/06/2012 |Thiago Motta	 | 1.4           | Alteração no calculo do campo SBAsAdditionalExtendedPurchaseDiscount que multiplicavam pelo RECEITA_STARSOFT.Fator
|			|				 |				 | Este problema existia apenas quando o fator era NEGATIVO
|			|				 |				 | SCRUM-2886
|-----------+----------------+---------------|----------------------------------------------------------------------------------------|


|---------------------------------------------------------------------------------------------------|
| DATA      | RESPONSAVEL    | VERSAO        | ALTERACAO                                            |
|-----------+----------------+---------------+----------------------------------------------------------------------------------------|
|22/05/2012 |Thiago Motta e  | 1.3           | Alteração no calculo dos campos que multiplicavam pelo RECEITA_STARSOFT.Fator
|			|ELCruz			 |				 | Este problema existia apenas quando o fator era NEGATIVO
|			|				 |				 | SCRUM-
|-----------+----------------+---------------|----------------------------------------------------------------------------------------|


|---------------------------------------------------------------------------------------------------|
| DATA      | RESPONSAVEL    | VERSAO        | ALTERACAO                                            |
|-----------+----------------+---------------+----------------------------------------------------------------------------------------|
|21/05/2012 |Thiago Motta    | 1.2           | Alteração no calculo dos campos: 
|			|				 |				 | StandardPurchaseDiscountPercentage, ExtendedStandardPurchaseDiscountAmount e 
|			|				 |				 | SBAsAdditionalExtendedPurchaseDiscount para que fique de acordo com o excel
|-----------+----------------+---------------|----------------------------------------------------------------------------------------|


|---------------------------------------------------------------------------------------------------|
| DATA      | RESPONSAVEL    | VERSAO        | ALTERACAO                                            |
|-----------+----------------+---------------+----------------------------------------------------------------------------------------|
|19/02/2012 |ELCruz			 | 1.1           | Alteração da origem do campo revenuetype, antes era intranet agora é SSA.|
|-----------+----------------+---------------|----------------------------------------------------------------------------------------|

                                                                             
|---------------------------------------------------------------------------------------------------|
| DATA      | RESPONSAVEL    | VERSAO        | ALTERACAO                                            |
|-----------+----------------+---------------+------------------------------------------------------|
|21/11/2012 |Peterson Ricardo| 1.0           | Criação de StoresProcedure                           |
|-----------+----------------+---------------|------------------------------------------------------|
*/

--DECLARE

        @ERP INT, --CodERP vindo da Intranet de(1 = Brasil, 2 = Cala, 3 = Mexico, 4 = Colombia)
        @PLD_DATAINI VARCHAR(08), -- Data Inicial da Emissão da NF
        @PLD_DATAFIM VARCHAR(08), -- Data Final da Emissão da NF
        @VENDOR VARCHAR(255) -- Descrição do Fabricante ou adicionar '0' para trazer todos os Fabricantes


--EXEC [Starsoft].[Reports_AtualizaBI_Receita] 3, '20160101', '20160131', '0'


WITH RECOMPILE

AS

DECLARE @DATAINI AS DATE, -- Data Inicial da Emissão da NF
        @DATAFIM AS DATE -- Data Final da Emissão da NF

-- Tratamento para otimizar a query, pois sem isso para todas consultar o SQL precisa converter a data e com isso fica muito lento
SET @DATAINI = @PLD_DATAINI
SET @DATAFIM = @PLD_DATAFIM

/**************************************Exclui Registros Ref. Periodo e ERP *****************************************/
--DELETE FROM Reports.BIReceita WHERE (@ERP = 0 OR CodERP = CONVERT(varchar,@ERP)) AND (EmissaoNF between CONVERT(DATETIME, @DATAINI, 102) and CONVERT(DATETIME, @DATAFIM, 102))
DELETE FROM Reports.BIReceita WHERE (@ERP = 0 OR CodERP = CONVERT(varchar,@ERP)) AND (EmissaoNF between @DATAINI and @DATAFIM)
/*******************************************************************************************************************/


/**************************************BRASIL*****************************************/
Begin
	IF @ERP = 1

	BEGIN        
    
    
		DELETE FROM [dbo].[BIDadosPedidosIntranet]
	
		;WITH ctePedido AS
		(
			SELECT 
				tblPropostaPedido.CodPedido,
				tblPropostaPedido.DataPedido,
				tblPropostaPedido.CBN,

				tblProposta.CodDivisao,
				tblProposta.CodRegiao,
				tblProposta.NomeProposta,
				tblProposta.CGCRevenda,
				tblProposta.CustomerIDRevenda,
				tblProposta.IdRevenda,
				tblProposta.CodUsuarioComercial,
				tblProposta.NomeRevenda, 
				tblProposta.EnderecoRevenda,
				tblProposta.BairroRevenda,
				tblProposta.CidadeRevenda,
				tblProposta.UFRevenda,
				tblProposta.PaisRevenda,
				tblProposta.CEPRevenda,
				tblProposta.IDContato,
				tblProposta.ContatoRevenda, 
				tblProposta.EmailRevenda,
				tblProposta.TelRevenda,

				tblPropostaCarrinho.CodCarrinho,

				-- campos que existem em tblProposta e tblPropostaCarrinho
				tblProposta.CodPedoc,
				tblProposta.NomeEntrega,
				tblProposta.EnderecoEntrega,
				tblProposta.BairroEntrega,
				tblProposta.CidadeEntrega,
				tblProposta.UFEntrega,
				tblProposta.CEPEntrega,
				tblProposta.EndUser,
				tblProposta.EnderecoEndUser,
				tblProposta.CidadeEndUser,	
				tblProposta.UFEndUser,
				tblProposta.CEPEndUser,
				tblProposta.Observacao,
				tblProposta.CodProposta,
				tblProposta.PaisEndUser,
				tblProposta.PaisEntrega,
				tblProposta.CustomerIdFatura
			FROM 
				tblPropostaPedido WITH (NoLock)
				INNER JOIN tblProposta WITH (NoLock) on tblPropostaPedido.CodProposta=tblProposta.CodProposta
				INNER JOIN tblPropostaCarrinho WITH (NoLock) ON tblProposta.CodProposta=tblPropostaCarrinho.CodProposta
			WHERE 
				tblPropostaPedido.CodCarrinho IS NULL

			UNION ALL

			SELECT 
				tblPropostaPedido.CodPedido,
				tblPropostaPedido.DataPedido,
				tblPropostaPedido.CBN,

				tblProposta.CodDivisao,
				tblProposta.CodRegiao,
				tblProposta.NomeProposta,
				tblProposta.CGCRevenda,
				tblProposta.CustomerIDRevenda,
				tblProposta.IdRevenda,
				tblProposta.CodUsuarioComercial,
				tblProposta.NomeRevenda, 
				tblProposta.EnderecoRevenda,
				tblProposta.BairroRevenda,
				tblProposta.CidadeRevenda,
				tblProposta.UFRevenda,
				tblProposta.PaisRevenda,
				tblProposta.CEPRevenda,
				tblProposta.IDContato,
				tblProposta.ContatoRevenda, 
				tblProposta.EmailRevenda,
				tblProposta.TelRevenda,

				tblPropostaCarrinho.CodCarrinho,

				-- campos que existem em tblProposta e tblPropostaCarrinho
				tblPropostaCarrinho.CodPedoc,
				tblPropostaCarrinho.NomeEntrega,
				tblPropostaCarrinho.EnderecoEntrega,
				tblPropostaCarrinho.BairroEntrega,
				tblPropostaCarrinho.CidadeEntrega,
				tblPropostaCarrinho.UFEntrega,
				tblPropostaCarrinho.CEPEntrega,
				tblPropostaCarrinho.EndUser,
				tblPropostaCarrinho.EnderecoEndUser,
				tblPropostaCarrinho.CidadeEndUser,	
				tblPropostaCarrinho.UFEndUser,
				tblPropostaCarrinho.CEPEndUser,
				tblPropostaCarrinho.Observacao,
				tblPropostaCarrinho.CodProposta,
				tblPropostaCarrinho.PaisEndUser,
				tblPropostaCarrinho.PaisEntrega,
				tblPropostaCarrinho.CustomerIdFatura

			FROM 
				tblPropostaPedido WITH (NoLock)
				INNER JOIN tblProposta WITH (NoLock) on tblPropostaPedido.CodProposta=tblProposta.CodProposta
				INNER JOIN tblPropostaCarrinho WITH (NoLock) ON tblPropostaPedido.CodCarrinho=tblPropostaCarrinho.CodCarrinho
		)
		INSERT INTO [dbo].[BIDadosPedidosIntranet]
		SELECT * FROM ctePedido    
    
    
		INSERT INTO Reports.BIReceita
		select
		RTRIM(ISNULL(RECEITA_INTRANET.Fabricante, RECEITA_STARSOFT.FABRICANTE)) as Fabricante,
		RTRIM(ISNULL(RECEITA_INTRANET.Familia, RECEITA_STARSOFT.FAMILIA)) as Familia,
		ISNULL(RECEITA_INTRANET.TipoHwSw, [Westcon].[Intranet].[Reports_PartNumberTipoHwSw](RECEITA_STARSOFT.PartNumber)) as TipoHwSw,
		ISNULL(RECEITA_INTRANET.TipoGrupoSw, [Westcon].[Intranet].[Reports_PartNumberTipoGrupoSw](RECEITA_STARSOFT.PartNumber)) as TipoGrupoSw,
		ISNULL(RECEITA_INTRANET.DescrNota, [Westcon].[Intranet].[Reports_PartNumberDescription](RECEITA_STARSOFT.PartNumber)) AS DescrNota, 	
		RECEITA_STARSOFT.PedidoVenda,
		RECEITA_STARSOFT.PedidoVendaTrimmed,
		RTRIM(RECEITA_STARSOFT.NF),
		RECEITA_STARSOFT.TipoES,
		RECEITA_STARSOFT.EmissaoNF,
		RTRIM(RECEITA_STARSOFT.PartNumber),
		RTRIM(RECEITA_STARSOFT.CNPJEmpresaNF),
		RECEITA_STARSOFT.EmpresaNF,
		RECEITA_STARSOFT.Qtd,
		RECEITA_STARSOFT.ValorUnitarioNF * RECEITA_STARSOFT.Fator as ValorUnitarioNF,
		--RECEITA_STARSOFT.TotalItemNF + isnull(RECEITA_STARSOFT.IPI,0) as TotalItemNF,
		RECEITA_STARSOFT.TotalItemNF * RECEITA_STARSOFT.Fator as TotalItemNF,
		RECEITA_STARSOFT.CustoMedioUn * RECEITA_STARSOFT.Fator as CustoMedioUn,
		RECEITA_STARSOFT.CustoMedioTotal * RECEITA_STARSOFT.Fator as CustoMedioTotal,
		RECEITA_STARSOFT.ProvisaoComissaoRevenda * RECEITA_STARSOFT.Fator as ProvisaoComissaoRevenda,
		RECEITA_INTRANET.OrigemPipeline,       		
		RECEITA_STARSOFT.TotalRevendaAntesComissao * RECEITA_STARSOFT.Fator as TotalRevendaAntesComissao,
		RECEITA_STARSOFT.ICMS * RECEITA_STARSOFT.Fator AS ICMS,
		RECEITA_STARSOFT.PIS * RECEITA_STARSOFT.Fator AS PIS,
		RECEITA_STARSOFT.COFINS * RECEITA_STARSOFT.Fator AS COFINS,
		RECEITA_STARSOFT.IRRF * RECEITA_STARSOFT.Fator AS IRRF,
		RECEITA_STARSOFT.CSLL * RECEITA_STARSOFT.Fator AS CSLL,
		RECEITA_STARSOFT.IPI * RECEITA_STARSOFT.Fator AS IPI,
		RECEITA_STARSOFT.ISS * RECEITA_STARSOFT.Fator AS ISS,
		RECEITA_STARSOFT.Estado,
		RTRIM(RECEITA_STARSOFT.Cidade),
		RECEITA_STARSOFT.VENDEDOR,
		RECEITA_INTRANET.NomeVendedor as VendedorIntranet, 	
		RECEITA_STARSOFT.NFDevolvida,
		CASE WHEN ISNULL(RECEITA_INTRANET.TipoHwSw,0) IN (0,3,5) THEN RECEITA_STARSOFT.EmissaoNF ELSE DATEADD(day,2,RECEITA_STARSOFT.EmissaoNF) END AS DataEstEntrega,
		RECEITA_STARSOFT.CodPedido,		
		RECEITA_STARSOFT.J10_UKEY,
		RECEITA_STARSOFT.CIA_UKEY,	
		RECEITA_STARSOFT.J09_UKEY,
		RECEITA_STARSOFT.CodERP,
		RECEITA_STARSOFT.IVA * RECEITA_STARSOFT.Fator AS IVA,	
		RECEITA_STARSOFT.ICMSST * RECEITA_STARSOFT.Fator AS ICMSST,		
		RECEITA_STARSOFT.A03_UKEY,
		RECEITA_STARSOFT.A36_CODE,
		RECEITA_STARSOFT.Currency,
		RECEITA_STARSOFT.USDRate,
		RECEITA_INTRANET.DataPedido,
		RECEITA_INTRANET.CodPedidoRevenda,
		RECEITA_INTRANET.NomeRevenda,
		RECEITA_INTRANET.EnderecoRevenda,
		RECEITA_INTRANET.BairroRevenda,
		RECEITA_INTRANET.CidadeRevenda,
		RECEITA_INTRANET.UFRevenda,
		RECEITA_INTRANET.CEPRevenda,
		RTRIM(RECEITA_INTRANET.PaisRevenda),
		RECEITA_INTRANET.ContatoRevenda,
		RECEITA_INTRANET.EmailRevenda,
		RECEITA_INTRANET.TelRevenda,
		RECEITA_STARSOFT.EnderecoFatura,
		RTRIM(RECEITA_STARSOFT.BairroFatura),
		RECEITA_STARSOFT.CEPFatura,
		RTRIM(RECEITA_STARSOFT.PaisFatura),    
		RECEITA_INTRANET.EmpresaEntrega,
		RECEITA_INTRANET.EnderecoEntrega,
		RECEITA_INTRANET.BairroEntrega,
		RECEITA_INTRANET.CidadeEntrega,
		RECEITA_INTRANET.UFEntrega,
		RECEITA_INTRANET.PaisEntrega,
		RECEITA_INTRANET.EndUser,
		RECEITA_INTRANET.EnderecoEndUser,
		RECEITA_INTRANET.BairroEndUser,
		RECEITA_INTRANET.CidadeEndUser,
		RECEITA_INTRANET.UFEndUser,
		RECEITA_INTRANET.CEPEnduser,
		RECEITA_INTRANET.PaisEndUser,
		RECEITA_INTRANET.PCR * RECEITA_STARSOFT.Fator as UnitListPrice,    	        
		( RECEITA_INTRANET.PCR * RECEITA_STARSOFT.Qtd ) * RECEITA_STARSOFT.Fator AS ExtendedListPrice,
	
		CASE WHEN ((IsNUll(RECEITA_INTRANET.CodPedido, 0)) = 0)
			THEN IsNull( (SELECT intranet.GetDiscountPriceByCodERP (RECEITA_STARSOFT.PartNumber, RECEITA_STARSOFT.CodERP)), 0)
			ELSE (RECEITA_INTRANET.DescontoP * 100)
		END as StandardPurchaseDiscountPercentage,
	
		( RECEITA_INTRANET.PCR * RECEITA_STARSOFT.Qtd * RECEITA_INTRANET.DescontoP ) * RECEITA_STARSOFT.Fator as ExtendedStandardPurchaseDiscountAmount,
		RECEITA_INTRANET.SBAType,
		RECEITA_INTRANET.SBANumber,
		RECEITA_INTRANET.RebateNumber,
		RECEITA_INTRANET.SBADiscount * 100 as SBADiscount,
		--( RECEITA_INTRANET.PCR * RECEITA_STARSOFT.Qtd * RECEITA_INTRANET.SBADiscount ) * RECEITA_STARSOFT.Fator as SBAsAdditionalExtendedPurchaseDiscount, 
		-- se houver SBA, preço_lista*qtde * (SBA%-standard_purchase_discount%), senão 0 (zero) -- (negativo se devolução)
		CASE WHEN (IsNull(RECEITA_INTRANET.SBADiscount, 0) <> 0)
			THEN ((RECEITA_INTRANET.PCR * RECEITA_STARSOFT.Qtd * (RECEITA_INTRANET.SBADiscount - RECEITA_INTRANET.DescontoP))) * RECEITA_STARSOFT.Fator
			ELSE 0
		END as SBAsAdditionalExtendedPurchaseDiscount,

	   CASE WHEN IsNull(RECEITA_INTRANET.SBADiscount, 0) <> 0 AND LOWER(RECEITA_INTRANET.SBAType) = 'frontend'
			THEN ( RECEITA_INTRANET.PCR * RECEITA_STARSOFT.Qtd * RECEITA_INTRANET.SBADiscount ) * RECEITA_STARSOFT.Fator
			ELSE ( RECEITA_INTRANET.PCR * RECEITA_STARSOFT.Qtd * RECEITA_INTRANET.DESCONTO ) * RECEITA_STARSOFT.Fator
		END as ExtendedPurchaseDiscount, 
   
		RECEITA_INTRANET.UnitPurchasePrice * RECEITA_STARSOFT.Fator as UnitPurchasePrice, 
   
		( RECEITA_INTRANET.UnitPurchasePrice * RECEITA_STARSOFT.Qtd ) * RECEITA_STARSOFT.Fator as ExtendedPurchasePrice,      
	
		RECEITA_INTRANET.PurchasingCurrency as PurchasingCurrency, 
	
		RECEITA_INTRANET.NetPurchaseUnitCost * RECEITA_STARSOFT.Fator as NetPurchaseUnitCost, 
	
		( RECEITA_INTRANET.NetPurchaseUnitCost * RECEITA_STARSOFT.Qtd ) * RECEITA_STARSOFT.Fator as NetPurchaseExtendedCost,
   
		ISNULL(RECEITA_INTRANET.UnitClaimAmount,0) * RECEITA_STARSOFT.Fator as UnitClaimAmount,
	
		( ISNULL(RECEITA_INTRANET.UnitClaimAmount,0) * RECEITA_STARSOFT.Qtd ) * RECEITA_STARSOFT.Fator as ExtendedClaimAmount,
		
		'' as SFAOpportunityTrackingNumber,
		RECEITA_INTRANET.ObservacoesFinais,
		NomeERP = (select nomeerp from westcon.dbo.tblERP where CodERP = @ERP),
		/*RECEITA_INTRANET.NomeERP as NomeERP,*/
 		RECEITA_INTRANET.NomeRegiao as NomeRegiao,
		RECEITA_INTRANET.DistributorToVendorPO,
		RECEITA_INTRANET.NomeDivisao,
		RECEITA_INTRANET.CodDivisao,
		RECEITA_INTRANET.CodProposta,
		RECEITA_INTRANET.CodCarrinho,
		RECEITA_INTRANET.CustomerIdGrupoEconomicoRevenda,
		RECEITA_INTRANET.NomeGrupoEconomicoRevenda,
		RECEITA_INTRANET.CustomerIdGrupoEconomicoFatura,
		RECEITA_INTRANET.NomeGrupoEconomicoFatura,

		CASE WHEN (RECEITA_STARSOFT.TotalRevendaAntesComissao = 0)
			THEN 0
			ELSE RECEITA_STARSOFT.TotalRevendaAntesComissao * (1 + RECEITA_STARSOFT.IPI / (RECEITA_STARSOFT.TotalItemNF + isnull(RECEITA_STARSOFT.IPI,0))) * (1 + RECEITA_STARSOFT.IVA / (RECEITA_STARSOFT.TotalItemNF + isnull(RECEITA_STARSOFT.IPI,0))) * RECEITA_STARSOFT.Fator
		END as ReceitaBrutaDescontadaComissao,	 
		-- QUALQUER ALTERAÇÃO NESSE CAMPO DEVERÁ SER FEITA A MESMA ALTERAÇÃO NA SP [Starsoft].[AtualizaBIBookingVendas] NO CAMPO ValorLiquidoVenda!!!!!! NÃO PODEMOS ATUALIZAR ESSE CAMPO COM O CONTEUDO DESSE CAMPO DA BIRECEITA PQ ESSA FUNÇÃO É EXECUTADA EM TEMPO REAL DURANTE OS PROCESSOS DE FATURAMENTO, CANCELAMENTO E DEVOLUÇÃO DE NF NO APPLICATIONS
		( 
			RECEITA_STARSOFT.TotalItemNF - RECEITA_STARSOFT.ICMS - RECEITA_STARSOFT.PIS - RECEITA_STARSOFT.COFINS - IsNull(RECEITA_STARSOFT.ISS,0) - IsNull(RECEITA_STARSOFT.ProvisaoComissaoRevenda,0) - isnull(RECEITA_STARSOFT.VendorMKT,0) - isnull(RECEITA_STARSOFT.ResselerMKT,0) -- ReceitaLiquidaStarSoft 
		) * RECEITA_STARSOFT.Fator
		as ReceitaLiquida,	

		(
			( 
				( RECEITA_STARSOFT.TotalItemNF - RECEITA_STARSOFT.ICMS - RECEITA_STARSOFT.PIS - RECEITA_STARSOFT.COFINS - IsNull(RECEITA_STARSOFT.ISS,0) - IsNull(RECEITA_STARSOFT.ProvisaoComissaoRevenda,0) - isnull(RECEITA_STARSOFT.VendorMKT,0) - isnull(RECEITA_STARSOFT.ResselerMKT,0) ) -- ReceitaLiquidaStarSoft 
				+ 
				( ISNULL(RECEITA_INTRANET.UnitClaimAmount,0) * RECEITA_STARSOFT.Qtd * RECEITA_STARSOFT.USDRate) -- ExtendedClaimAmount Convertido
			) -- Receita Liquida
			- RECEITA_STARSOFT.CustoMedioTotal 
		) * RECEITA_STARSOFT.Fator as LucroVenda,

		RECEITA_INTRANET.NetAccounting as NetAccounting,		

		case when RECEITA_INTRANET.NetAccounting = 'Yes'
		then
			(
				( 
					( RECEITA_STARSOFT.TotalItemNF - RECEITA_STARSOFT.ICMS - RECEITA_STARSOFT.PIS - RECEITA_STARSOFT.COFINS - IsNull(RECEITA_STARSOFT.ISS,0) - IsNull(RECEITA_STARSOFT.ProvisaoComissaoRevenda,0) - isnull(RECEITA_STARSOFT.VendorMKT,0) - isnull(RECEITA_STARSOFT.ResselerMKT,0) ) -- ReceitaLiquidaStarSoft 
					- 
					( ISNULL(RECEITA_INTRANET.UnitClaimAmount,0) * RECEITA_STARSOFT.Qtd * RECEITA_STARSOFT.USDRate) -- ExtendedClaimAmount Convertido
				) -- Receita Liquida
				- RECEITA_STARSOFT.CustoMedioTotal  -- LucroVendaNovo,
			) * RECEITA_STARSOFT.Fator
		else
			( 
				( RECEITA_STARSOFT.TotalItemNF - RECEITA_STARSOFT.ICMS - RECEITA_STARSOFT.PIS - RECEITA_STARSOFT.COFINS - IsNull(RECEITA_STARSOFT.ISS,0) - IsNull(RECEITA_STARSOFT.ProvisaoComissaoRevenda,0) - isnull(RECEITA_STARSOFT.VendorMKT,0) - isnull(RECEITA_STARSOFT.ResselerMKT,0) ) -- ReceitaLiquidaStarSoft 
				- 
				( ISNULL(RECEITA_INTRANET.UnitClaimAmount,0) * RECEITA_STARSOFT.Qtd * RECEITA_STARSOFT.USDRate) -- ExtendedClaimAmount Convertido
			) * RECEITA_STARSOFT.Fator -- ReceitaLiquidaNovo	
		end as NetAccountingRevenue,
		RECEITA_STARSOFT.RevenueType as RevenueType,
		case when 
				(
					case when RECEITA_INTRANET.NetAccounting = 'Yes'
					then
						(
							( 
								( RECEITA_STARSOFT.TotalItemNF - RECEITA_STARSOFT.ICMS - RECEITA_STARSOFT.PIS - RECEITA_STARSOFT.COFINS - IsNull(RECEITA_STARSOFT.ISS,0) - IsNull(RECEITA_STARSOFT.ProvisaoComissaoRevenda,0) - isnull(RECEITA_STARSOFT.VendorMKT,0) - isnull(RECEITA_STARSOFT.ResselerMKT,0) ) -- ReceitaLiquidaStarSoft 
								- 
								( ISNULL(RECEITA_INTRANET.UnitClaimAmount,0) * RECEITA_STARSOFT.Qtd * RECEITA_STARSOFT.USDRate) -- ExtendedClaimAmount Convertido
							) -- Receita Liquida
							- RECEITA_STARSOFT.CustoMedioTotal  -- LucroVendaNovo,
						) * RECEITA_STARSOFT.Fator
					else
						( 
							( RECEITA_STARSOFT.TotalItemNF - RECEITA_STARSOFT.ICMS - RECEITA_STARSOFT.PIS - RECEITA_STARSOFT.COFINS - IsNull(RECEITA_STARSOFT.ISS,0) - IsNull(RECEITA_STARSOFT.ProvisaoComissaoRevenda,0) - isnull(RECEITA_STARSOFT.VendorMKT,0) - isnull(RECEITA_STARSOFT.ResselerMKT,0) ) -- ReceitaLiquidaStarSoft 
							- 
							( ISNULL(RECEITA_INTRANET.UnitClaimAmount,0) * RECEITA_STARSOFT.Qtd * RECEITA_STARSOFT.USDRate) -- ExtendedClaimAmount Convertido
						) * RECEITA_STARSOFT.Fator -- ReceitaLiquidaNovo	
					end		
				) -- NetAccountingRevenue
				= 0
		then
			0
		else
			-- LucroVendaNovo / NetAccountingRevenue
			(
				(
					( 
						( RECEITA_STARSOFT.TotalItemNF - RECEITA_STARSOFT.ICMS - RECEITA_STARSOFT.PIS - RECEITA_STARSOFT.COFINS - IsNull(RECEITA_STARSOFT.ISS,0) - IsNull(RECEITA_STARSOFT.ProvisaoComissaoRevenda,0) - isnull(RECEITA_STARSOFT.VendorMKT,0) - isnull(RECEITA_STARSOFT.ResselerMKT,0) ) -- ReceitaLiquidaStarSoft 
						- 
						( ISNULL(RECEITA_INTRANET.UnitClaimAmount,0) * RECEITA_STARSOFT.Qtd * RECEITA_STARSOFT.USDRate) -- ExtendedClaimAmount Convertido
					) -- Receita Liquida
					- RECEITA_STARSOFT.CustoMedioTotal
				) * RECEITA_STARSOFT.Fator
			)-- LucroVendaNovo				
			/ -- dividido
			(
				case when RECEITA_INTRANET.NetAccounting = 'Yes'
				then
					(
						( 
							( RECEITA_STARSOFT.TotalItemNF - RECEITA_STARSOFT.ICMS - RECEITA_STARSOFT.PIS - RECEITA_STARSOFT.COFINS - IsNull(RECEITA_STARSOFT.ISS,0) - IsNull(RECEITA_STARSOFT.ProvisaoComissaoRevenda,0) - isnull(RECEITA_STARSOFT.VendorMKT,0) - isnull(RECEITA_STARSOFT.ResselerMKT,0) ) -- ReceitaLiquidaStarSoft 
							- 
							( ISNULL(RECEITA_INTRANET.UnitClaimAmount,0) * RECEITA_STARSOFT.Qtd * RECEITA_STARSOFT.USDRate) -- ExtendedClaimAmount Convertido
						) -- Receita Liquida
						- RECEITA_STARSOFT.CustoMedioTotal -- LucroVendaNovo,
					) * RECEITA_STARSOFT.Fator
				else
					( 
						( RECEITA_STARSOFT.TotalItemNF - RECEITA_STARSOFT.ICMS - RECEITA_STARSOFT.PIS - RECEITA_STARSOFT.COFINS - IsNull(RECEITA_STARSOFT.ISS,0) - IsNull(RECEITA_STARSOFT.ProvisaoComissaoRevenda,0) - isnull(RECEITA_STARSOFT.VendorMKT,0) - isnull(RECEITA_STARSOFT.ResselerMKT,0) ) -- ReceitaLiquidaStarSoft 
						- 
						( ISNULL(RECEITA_INTRANET.UnitClaimAmount,0) * RECEITA_STARSOFT.Qtd * RECEITA_STARSOFT.USDRate) -- ExtendedClaimAmount Convertido
					) * RECEITA_STARSOFT.Fator -- ReceitaLiquidaNovo	
				end 
			)
		end as NetMargin,
		RECEITA_INTRANET.MaintenanceOrOther as MaintenanceOrOther,
		(RECEITA_STARSOFT.TotalItemNF + RECEITA_STARSOFT.ICMSST + RECEITA_STARSOFT.IPI) * RECEITA_STARSOFT.Fator AS TotalItemNFComICMSEIPI,
		(RECEITA_STARSOFT.TotalItemNF + RECEITA_STARSOFT.IVA) * RECEITA_STARSOFT.Fator AS TotalItemNFComIVA,
		RECEITA_INTRANET.LoginAccountManager as LoginAccountManager,
		RECEITA_STARSOFT.SalesTax,
		RECEITA_INTRANET.ServiceProvider,
		RTRIM(RECEITA_INTRANET.ServiceProviderCountry),
		RECEITA_INTRANET.CEPEntrega,
		RECEITA_STARSOFT.POEfetiva,
		RECEITA_STARSOFT.InvoiceLineNumber,
		IsNull(RECEITA_INTRANET.CodRegiao,0) as CodRegiao,
		RTRIM(RECEITA_INTRANET.NomeParte),
		RECEITA_INTRANET.CBN,
		CASE WHEN IsNull(RECEITA_INTRANET.SBADiscount, 0) <> 0 AND LOWER(RECEITA_INTRANET.SBAType) = 'frontend'
			THEN RECEITA_INTRANET.SBADiscount * 100 -- SBADiscount
			ELSE 
				CASE WHEN ((IsNUll(RECEITA_INTRANET.CodPedido, 0)) = 0)
				THEN IsNull( (SELECT intranet.GetDiscountPriceByCodERP (RECEITA_STARSOFT.PartNumber, RECEITA_STARSOFT.CodERP)), 0)
				ELSE (RECEITA_INTRANET.DescontoP * 100) 
				END -- StandardPurchaseDiscountPercentage
		END as SOPurchaseDiscountPercent,
		RECEITA_STARSOFT.Complement,
		RECEITA_STARSOFT.J11_Ukey,
		RECEITA_STARSOFT.Intercompany,
		0 as CustoMedioUnMN,
		0 as CustoMedioTotalMN,		
		isnull(RECEITA_STARSOFT.VendorMKT * RECEITA_STARSOFT.Fator,0), 
		isnull(RECEITA_STARSOFT.ResselerMKT * RECEITA_STARSOFT.Fator,0),
		RECEITA_INTRANET.ID AS IDINTRANET,
		RECEITA_INTRANET.GDS as GDS,	

		--SCRUM-15091 - inicio
		CASE WHEN
				 RTRIM(CURRENCY) = 'US$' AND (RTRIM(CURRENCY_CIA) = '$' or RTRIM(CURRENCY_CIA) = 'R$' )
					THEN 
						(RECEITA_STARSOFT.ValorUnitarioNF * RECEITA_STARSOFT.Fator)*
						(CASE WHEN TAX1 <> 1 THEN TAX1
							WHEN  USDRATE <> 1 THEN USDRATE
							ELSE TAX2 
						END)
			WHEN
				(RTRIM(CURRENCY_CIA) = '$' or RTRIM(CURRENCY_CIA) = 'R$') AND RTRIM(CURRENCY_CIA) = 'US$' 
					THEN
						(RECEITA_STARSOFT.ValorUnitarioNF * RECEITA_STARSOFT.Fator)/
						(CASE	WHEN TAX1 <> 1 THEN TAX1
							WHEN  USDRATE <> 1 THEN USDRATE
							ELSE TAX2 END)
		
		ELSE
			(RECEITA_STARSOFT.ValorUnitarioNF * RECEITA_STARSOFT.Fator)
	
		END AS [totalitemnf(local currency)]
		,
	
		CASE WHEN
				 RTRIM(CURRENCY) = 'US$' AND (RTRIM(CURRENCY_CIA) = '$' or RTRIM(CURRENCY_CIA) = 'R$' )
					THEN 
						(RECEITA_STARSOFT.TotalItemNF * RECEITA_STARSOFT.Fator)*
						(CASE WHEN TAX1 <> 1 THEN TAX1
							WHEN  USDRATE <> 1 THEN USDRATE
							ELSE TAX2 
						END)
			WHEN
				(RTRIM(CURRENCY_CIA) = '$' or RTRIM(CURRENCY_CIA) = 'R$') AND RTRIM(CURRENCY_CIA) = 'US$' 
					THEN
						(RECEITA_STARSOFT.TotalItemNF * RECEITA_STARSOFT.Fator)/
						(CASE	WHEN TAX1 <> 1 THEN TAX1
							WHEN  USDRATE <> 1 THEN USDRATE
							ELSE TAX2 END)
		
		ELSE
			(RECEITA_STARSOFT.TotalItemNF * RECEITA_STARSOFT.Fator)
	
		END AS [receitaliquida(local currency)] 
		--SCRUM-15091 - fim
		FROM			[StarSoft].[fnReceitaProdutosBR](@DATAINI, @DATAFIM,0)		RECEITA_STARSOFT 
		LEFT JOIN	(
			SELECT DISTINCT
	
				wcnUsuarioWestcon.CodVendedor, -- não existe nas querys da BIReceita
				wcnUsuarioWestcon.LoginDominio as LoginAccountManager, -- login do vendedor 
				tblUsuario.NomeUsuario as NomeVendedor,
				ISNULL(dbo.tblParte1.Pcr, 0) AS Pcr, -- não existe nas querys da BIReceita
				(ISNULL(ISNULL(ISNULL(tblPropostaCarrinhoParte.SBA, tblPropostaCarrinhoParte.Promocao), tblParteDescontoRegiao.Desconto), 0) / 100) AS Desconto, -- não existe nas querys da BIReceita
				ISNULL(tblParte1.Pcr, 0) AS PcrP, -- não existe nas querys da BIReceita
				(ISNULL(tblParteDescontoRegiao.Desconto, 0)/100) AS DescontoP, -- não existe nas querys da BIReceita
				tblPropostaCarrinhoParte.CodParte as PartNumber, -- não existe nas querys da BIReceita
				tblVendor.NomeVendor AS Fabricante,
				tblParteFamilia.Descricao AS Familia,
				--tblParte1.Tipo AS TipoHwSw,
				--comentado em 23/11/2015 => Thiago/Mauricio/Raulison
				-- motivo: esta function aqui nesse SELECT esta demorando em torno de 20 segundos para executar um SELECT TOP 10
				-- esse problema foi resolvido com o CASE WHEN logo abaixo
				--(SELECT Tipo FROM dbo.GetTipoParte(tblERP.CodERP, tblParte1.CodParte, tblParte1.Tipo, tblPropostaCarrinhoParte.OrigemFaturamento)) as TipoHwSw, 
		
				CASE WHEN (@ERP = 0)
					THEN tblParte1.Tipo
					ELSE IsNUll(tblTipoItemERP.Tipo, tblParte1.Tipo)
				END as TipoHwSw,

				tblParte1.Grupo AS TipoGrupoSw,
				tblParte1.DescrNota, 
				tblForecastTipo.DescrForecastTipo AS OrigemPipeline, 
				tblERP.CodERP as CodERP, 
				ctePedido.CodPedido,
				CONVERT(smalldatetime, ctePedido.DataPedido) AS DataPedido, 
				ISNULL(ctePedido.CodPedoc, ctePedido.NomeProposta) AS CodPedidoRevenda, 
				ctePedido.NomeRevenda, 
				ctePedido.EnderecoRevenda, 
				ctePedido.BairroRevenda, 
				ctePedido.CidadeRevenda, 
				ctePedido.UFRevenda, 
				ctePedido.CEPRevenda, 
				PaisRevenda.NomePais AS PaisRevenda, 
				ISNULL(tblContato.NomeContato, ctePedido.ContatoRevenda) AS ContatoRevenda, 
				ISNULL(tblContato.Email, ctePedido.EmailRevenda) AS EmailRevenda, 
				ISNULL(tblContato.Telefone, ctePedido.TelRevenda) AS TelRevenda, 
				ISNULL(ctePedido.NomeEntrega, ctePedido.NomeRevenda) AS EmpresaEntrega, 
				ISNULL(ctePedido.EnderecoEntrega, ctePedido.EnderecoRevenda) AS EnderecoEntrega, 
				ISNULL(ctePedido.BairroEntrega, ctePedido.BairroRevenda) AS BairroEntrega, 
				ISNULL(ctePedido.CidadeEntrega, ctePedido.CidadeRevenda) AS CidadeEntrega, 
				ISNULL(ctePedido.UFEntrega, ctePedido.UFRevenda) AS UFEntrega, 
				ISNULL(ctePedido.CEPEntrega, ctePedido.CEPRevenda) AS CEPEntrega, 
				tblPaisEntrega.NomePais AS PaisEntrega, 
				ctePedido.EndUser, 
				ctePedido.EnderecoEndUser, 
				'' AS BairroEndUser, 
				ctePedido.CidadeEndUser, 
				ctePedido.UFEndUser, 
				ctePedido.CEPEndUser, 
				ISNULL(tblPaisEndUser.NomePais, '') as PaisEndUser,
				CASE WHEN (IsNUll(tblSBA.Rebate, 0) = 0) THEN 'FrontEnd' ELSE 'BackEnd' END as SBAType, 
				ISNULL(tblSBA.NomeSBA, '') AS SBANumber, 
				ISNULL(tblSBA.Dart, '') as RebateNumber, 
				(IsNull(tblPropostaCarrinhoParte.SBA,0)/100) as SBADiscount, -- campo 82
				0 as SFAOpportunityTrackingNumber, -- FALTA INFORMAÇÃO
		
				CASE WHEN (IsNull(tblPropostaCarrinhoParte.SBA,0) <> 0) AND (IsNUll(tblSBA.Rebate, 0) = 0) -- SBADiscount AND FRONTEND
				THEN ISNULL(tblParte1.Pcr, 0) * (1 - IsNull(tblPropostaCarrinhoParte.SBA,0)/100) -- SBADiscount
				ELSE ISNULL(tblParte1.Pcr, 0) * (1 - (ISNULL(tblParteDescontoRegiao.Desconto, 0) / 100)) -- (Preco) * (1 - Desconto)
				END as UnitPurchasePrice, -- campo 85

				IsNull(tblPO.A36_UKEY,'') as PurchasingCurrency, -- campo 87
		
				CASE WHEN (IsNull(tblPropostaCarrinhoParte.SBA, 0) <> 0) -- SBADiscount
				THEN ISNULL(tblParte1.Pcr,0) * (1 - IsNull(tblPropostaCarrinhoParte.SBA,0)/100) -- (Preco) * (1 - SBADiscount)
				ELSE ISNULL(tblParte1.Pcr,0) * (1 - (ISNULL(tblParteDescontoRegiao.Desconto, 0) / 100)) -- (Preco) * (1 - Desconto)
				END as NetPurchaseUnitCost, -- campo 88
		
				CASE WHEN ((IsNull(tblPropostaCarrinhoParte.SBA, 0) <> 0) AND  (IsNUll(tblSBA.Rebate, 0) <> 0) ) -- SBADiscount AND BACKEND
				THEN (ISNULL(tblParte1.Pcr,0) * (tblPropostaCarrinhoParte.SBA - ISNULL(tblParteDescontoRegiao.Desconto, 0)) / 100) -- (Preco) * (SBA - Desconto)
				ELSE 0
				END as UnitClaimAmount, -- campo 90

				/*CASE WHEN ((IsNull(tblPropostaCarrinhoParte.SBA, 0) <> 0) AND  (IsNUll(tblSBA.Rebate, 0) <> 0) ) -- SBADiscount AND BACKEND
				THEN (ISNULL(tblParte1.Pcr,0) * (tblPropostaCarrinhoParte.SBA - 
												CASE WHEN (ISNULL(tblPropostaCarrinhoPartePo.Desconto, 0) > 0) AND (IsNUll(tblPropostaCarrinhoPartePo.Desconto, 0) <= ISNULL(tblPropostaCarrinhoParte.SBA, 0))
													THEN IsNUll(tblPropostaCarrinhoPartePo.Desconto, 0)
												WHEN (ISNULL(tblParteDescontoRegiao.Desconto, 0) > 0) AND (ISNULL(tblPropostaCarrinhoPartePo.Desconto, 0) = 0) AND (IsNUll(tblParteDescontoRegiao.Desconto, 0) <= ISNULL(tblPropostaCarrinhoParte.SBA, 0))
													THEN ISNULL(tblParteDescontoRegiao.Desconto, 0) 
												ELSE
													ISNULL(tblPropostaCarrinhoParte.SBA, 0) END)/100)
				ELSE 0
				END as UnitClaimAmount, -- campo 90*/
				
				ctePedido.Observacao AS ObservacoesFinais, 
				IsNull(tblERP.NomeERP, '') as NomeERP, 
				tblRegiao.CodRegiao,
				IsNull(tblRegiao.NomeRegiao, '') as NomeRegiao, 
				ISNULL(listaPO.POList, '') AS DistributorToVendorPO, 
				--ISNULL(dbo.ConvertLinesCodPOInColumn(ctePedido.CodCarrinho, tblPropostaCarrinhoParte.CodParte), '') as EffectivePO,
				tblDivisao.NomeDivisao, 
				tblDivisao.CodDivisao, 
				ctePedido.CodProposta, 
				ctePedido.CodCarrinho, 
				tblGrupoEconomicoRevenda.CustomerID as CustomerIdGrupoEconomicoRevenda, 
				tblGrupoEconomicoRevenda.NomeGrupo as NomeGrupoEconomicoRevenda, 
				tblGrupoEconomicoFatura.CustomerID as CustomerIdGrupoEconomicoFatura, 
				tblGrupoEconomicoFatura.NomeGrupo as NomeGrupoEconomicoFatura, 
		
				CASE WHEN (
							(tblParte1.Grupo = '002') OR 
							(tblParte1.Grupo = '009') OR 
							(LOWER(tblVendor.NomeVendor) IN ('cisco', 'cisco br') OR  
							LEFT(tblPropostaCarrinhoParte.CodParte,4) = 'CON-') OR 
							(tblParte1.Grupo ='011')
						  )
					THEN 'Yes' 
					ELSE 'No' 
					END 
				AS NetAccounting, -- campo 109

				--CASE WHEN ((tblParte1.Grupo = '009') OR (LOWER(tblVendor.NomeVendor) = 'cisco' AND LEFT(tblPropostaCarrinhoParte.CodParte,4) = 'CON-')) 
				--	THEN 'Yes' 
				--	ELSE 'No' 
				--	END 
				--AS NetAccounting, -- campo 109

				'Product' as RevenueType, -- campo 110

				CASE WHEN (IsNull(tblParte1.Grupo,0) = 2 OR IsNull(tblParte1.Grupo,0) = 9)
					THEN 'Maintenance'
					ELSE 'Other'
				END as MaintenanceOrOther,
				tblServiceProvider.NomeProvider as ServiceProvider,
				PaisRevenda.NomePais AS ServiceProviderCountry,
				tblParte1.NomeParte,
				ctePedido.CBN,
				tblPropostaCarrinhoParte.Id,
				CASE WHEN (SELECT COUNT(Nome) FROM tblPropostaTag PT (NOLOCK) WHERE PT.CodPedido = ctePedido.CodPedido AND RTRIM(LTRIM(LOWER(Nome))) = 'gds') > 0 THEN 1 ELSE 0 END AS GDS
				--IsNull((SELECT Nome FROM tblPropostaTag PT (NOLOCK) WHERE PT.CodPedido = ctePedido.CodPedido AND RTRIM(LTRIM(LOWER(Nome))) = 'gds'),0) as GDS
			FROM 
				[dbo].[BIDadosPedidosIntranet] ctePedido (NOLOCK)
				INNER JOIN tblRegiao (NOLOCK) ON (ctePedido.CodRegiao = tblRegiao.CodRegiao)
				INNER JOIN tblERP ON (IsNull(tblERP.CodERP,0) = 0 OR tblRegiao.CodERP = tblERP.CodERP)
				INNER JOIN tblPropostaCarrinhoParte (NOLOCK) ON (tblPropostaCarrinhoParte.CodCarrinho = ctePedido.CodCarrinho)
				INNER JOIN tblParte1 (NOLOCK) ON (tblPropostaCarrinhoParte.CodParte = tblParte1.CodParte)
				LEFT OUTER JOIN tblSBA WITH (NOLOCK) ON (tblPropostaCarrinhoParte.CodSBA = tblSBA.CodSBA) AND (tblSBA.CodCarrinho = ctePedido.CodCarrinho)
				INNER JOIN tblParteFamilia (NOLOCK) ON (tblParte1.CodParteFamilia = tblParteFamilia.CodParteFamilia)
				INNER JOIN tblVendor (NOLOCK) ON (tblParte1.CodVendor = tblVendor.CodVendor)
				LEFT OUTER JOIN tblEmpresaRel tblRevenda WITH (NOLOCK) ON (tblRevenda.CodERP = tblERP.CodERP) AND (ctePedido.IdRevenda is not null AND ctePedido.IdRevenda = tblRevenda.Id) OR (ctePedido.IdRevenda is null AND ctePedido.CGCRevenda = tblRevenda.CGC)
				LEFT OUTER JOIN wcnUsuarioWestcon (NOLOCK) ON (ctePedido.CodUsuarioComercial = wcnUsuarioWestcon.IDUsuario)
				LEFT OUTER JOIN tblUsuario (NOLOCK) ON (wcnUsuarioWestcon.IDUsuario = tblUsuario.CodUsuario)
				LEFT OUTER JOIN tblForecast (NOLOCK) ON (ctePedido.CodProposta = tblForecast.CodProposta)
				LEFT OUTER JOIN tblForecastOportunidade (NOLOCK) ON (tblForecast.CodOportunidade = tblForecastOportunidade.CodOportunidade)
				LEFT OUTER JOIN tblForecastTipo (NOLOCK) ON (tblForecastOportunidade.CodForecastTipo = tblForecastTipo.CodForecastTipo)
				--LEFT OUTER JOIN tblGrupoEconomico tblGrupoEconomicoRevenda WITH (NOLOCK) ON (tblGrupoEconomicoRevenda.CustomerID = tblRevenda.CustomerID)
				LEFT OUTER JOIN tblPais PaisRevenda WITH (NoLock) ON (ctePedido.PaisRevenda = PaisRevenda.CodPais)
				LEFT OUTER JOIN tblPais tblPaisEndUser WITH (NoLock) ON ctePedido.PaisEndUser = tblPaisEndUser.CodPais
				LEFT OUTER JOIN tblPais tblPaisEntrega WITH (NoLock) ON ctePedido.PaisEntrega = tblPaisEntrega.CodPais
				--LEFT OUTER JOIN tblEmpresaRel tblFatura WITH (NOLOCK) ON (CASE WHEN (ctePedido.CodCarrinho IS NULL) THEN ctePedido.IDEmpresaFaturamento ELSE ctePedido.IDEmpresaFaturamento END) = tblFatura.ID
				--LEFT OUTER JOIN tblGrupoEconomico tblGrupoEconomicoFatura WITH (NOLOCK) ON tblGrupoEconomicoFatura.CustomerID = tblFatura.CustomerID
				LEFT OUTER JOIN tblGrupoEconomico tblGrupoEconomicoRevenda WITH (NOLOCK) ON (tblGrupoEconomicoRevenda.CustomerID = ctePedido.CustomerIDRevenda)
				--LEFT OUTER JOIN tblPais PaisFatura WITH (NoLock) ON (tblFatura.CodPais = PaisFatura.CodPais)
				LEFT OUTER JOIN tblGrupoEconomico tblGrupoEconomicoFatura WITH (NOLOCK) ON tblGrupoEconomicoFatura.CustomerID = ctePedido.CustomerIdFatura
				LEFT OUTER JOIN tblContato WITH (NOLOCK) ON (ctePedido.IDContato = tblContato.CodContato)
				-- LEFT OUTER JOIN tblMercadoVertical WITH (NOLOCK) ON (tblForecastOportunidade.CodMercadoVertical = tblMercadoVertical.CodMercadoVertical)
				LEFT OUTER JOIN tblServiceProvider WITH (NOLOCK) ON (tblForecastOportunidade.IDServiceProvider = tblServiceProvider.IDProvider)
				LEFT OUTER JOIN tblParteDescontoRegiao WITH (NOLOCK) ON (tblParte1.CodParteDesconto = tblParteDescontoRegiao.CodParteDesconto) AND (tblParteDescontoRegiao.CodRegiao = ctePedido.CodRegiao)
				LEFT OUTER JOIN tblDivisao WITH (NOLOCK) ON ctePedido.CodDivisao = tblDivisao.CodDivisao 
				LEFT OUTER JOIN
					(
						SELECT 
							PCPPO.CodCarrinho,
							PCPPO.CodParte,
							--[dbo].[GetPOListV3-sugestao](PCPPO.CodCarrinho, PCPPO.CodParte, 0) as POList
							[dbo].[GetPOListV2](PCPPO.CodCarrinho, PCPPO.CodParte, 0) as POList
							--'' as POList
						FROM tblPropostaCarrinhoPartePO PCPPO (NOLOCK) 
						INNER JOIN tblPO (NOLOCK) ON PCPPO.CodPO = tblPO.CodPO
						GROUP BY PCPPO.CodCarrinho, PCPPO.CodParte
					) listaPO 
					ON 	tblPropostaCarrinhoParte.CodCarrinho = ListaPO.CodCarrinho 
						and tblPropostaCarrinhoParte.CodParte = listaPO.CodParte 

				LEFT OUTER JOIN tblPropostaCarrinhoPartePo WITH (NOLOCK) ON (listaPO.CodCarrinho is not null AND tblPropostaCarrinhoPartePo.CodCarrinho = ListaPO.CodCarrinho) AND (listaPO.CodParte is not null and tblPropostaCarrinhoPartePo.CodParte = listaPO.CodParte)
				LEFT OUTER JOIN tblPO WITH (NOLOCK) ON (tblPropostaCarrinhoPartePO.CodPO = tblPO.CodPO)
				LEFT OUTER JOIN tblTipoItemERP WITH (NOLOCK) ON tblTipoItemERP.PartNumber = tblParte1.CodParte AND tblTipoItemERP.CodErp = tblERP.CodERP

			--WHERE ctePedido.CodPedido>=150000 and tblRegiao.CodERP = @CodERP AND tblPropostaCarrinhoParte.CodParte='WS-C2960X-48LPS-L'
			--WHERE tblRegiao.CodERP= @CodERP AND ctePedido.CodPedido >= 202257 AND ctePedido.CodPedido <= 321659
			WHERE tblRegiao.CodERP= @ERP  AND ctePedido.CodPedido IN ((select codpedido from [StarSoft].[fnReceitaProdutosBR](@DATAINI, @DATAFIM,0) where codpedido is not null
																				group by codpedido))
		) RECEITA_INTRANET 
		ON				(CONVERT(VARCHAR,RECEITA_INTRANET.CodPedido) = RECEITA_STARSOFT.CodPedido) AND (RECEITA_INTRANET.PartNumber = RECEITA_STARSOFT.PartNumber) AND (RECEITA_STARSOFT.ID_INTRANET IS NULL OR RECEITA_STARSOFT.ID_INTRANET = RECEITA_INTRANET.ID)
		--LEFT OUTER JOIN starwestcon.dbo.A33 (NoLock) VENDEDOR_STARSOFT 
		--ON				VENDEDOR_STARSOFT.A33_001_C = IsNull(RECEITA_INTRANET.CodVendedor,'NAOENCONTRAR')    
		Where			(@VENDOR = '0' OR ISNULL(RECEITA_INTRANET.Fabricante, RECEITA_STARSOFT.FABRICANTE) = @VENDOR)   
	
  		
	END

	/***************************************CALA******************************************/

	IF @ERP = 2

	BEGIN        
    
		INSERT INTO Reports.BIReceita 
		select
		RTRIM(ISNULL(RECEITA_INTRANET.Fabricante, RECEITA_STARSOFT.FABRICANTE)) as Fabricante,
		RTRIM(ISNULL(RECEITA_INTRANET.Familia, RECEITA_STARSOFT.FAMILIA)) as Familia,
		ISNULL(RECEITA_INTRANET.TipoHwSw, [Westcon].[Intranet].[Reports_PartNumberTipoHwSw](RECEITA_STARSOFT.PartNumber)) as TipoHwSw,
		ISNULL(RECEITA_INTRANET.TipoGrupoSw, [Westcon].[Intranet].[Reports_PartNumberTipoGrupoSw](RECEITA_STARSOFT.PartNumber)) as TipoGrupoSw,
		ISNULL(RECEITA_INTRANET.DescrNota, [Westcon].[Intranet].[Reports_PartNumberDescription](RECEITA_STARSOFT.PartNumber)) AS DescrNota, 	
		RECEITA_STARSOFT.PedidoVenda,
		RECEITA_STARSOFT.PedidoVendaTrimmed,
		RTRIM(RECEITA_STARSOFT.NF),
		RECEITA_STARSOFT.TipoES,
		RECEITA_STARSOFT.EmissaoNF,
		RTRIM(RECEITA_STARSOFT.PartNumber),
		RTRIM(RECEITA_STARSOFT.CNPJEmpresaNF),
		RECEITA_STARSOFT.EmpresaNF,
		RECEITA_STARSOFT.Qtd,
		RECEITA_STARSOFT.ValorUnitarioNF * RECEITA_STARSOFT.Fator as ValorUnitarioNF,
		--RECEITA_STARSOFT.TotalItemNF + isnull(RECEITA_STARSOFT.IPI,0) as TotalItemNF,
		RECEITA_STARSOFT.TotalItemNF * RECEITA_STARSOFT.Fator as TotalItemNF,
		RECEITA_STARSOFT.CustoMedioUn * RECEITA_STARSOFT.Fator as CustoMedioUn,
		RECEITA_STARSOFT.CustoMedioTotal * RECEITA_STARSOFT.Fator as CustoMedioTotal,
		RECEITA_STARSOFT.ProvisaoComissaoRevenda * RECEITA_STARSOFT.Fator as ProvisaoComissaoRevenda,
		RECEITA_INTRANET.OrigemPipeline,       		
		RECEITA_STARSOFT.TotalRevendaAntesComissao * RECEITA_STARSOFT.Fator as TotalRevendaAntesComissao,
		RECEITA_STARSOFT.ICMS * RECEITA_STARSOFT.Fator AS ICMS,
		RECEITA_STARSOFT.PIS * RECEITA_STARSOFT.Fator AS PIS,
		RECEITA_STARSOFT.COFINS * RECEITA_STARSOFT.Fator AS COFINS,
		RECEITA_STARSOFT.IRRF * RECEITA_STARSOFT.Fator AS IRRF,
		RECEITA_STARSOFT.CSLL * RECEITA_STARSOFT.Fator AS CSLL,
		RECEITA_STARSOFT.IPI * RECEITA_STARSOFT.Fator AS IPI,
		RECEITA_STARSOFT.ISS * RECEITA_STARSOFT.Fator AS ISS,
		RECEITA_STARSOFT.Estado,
		RTRIM(RECEITA_STARSOFT.Cidade),
		RECEITA_STARSOFT.VENDEDOR,
		RECEITA_INTRANET.NomeVendedor as VendedorIntranet, 	
		RECEITA_STARSOFT.NFDevolvida,
		CASE WHEN ISNULL(RECEITA_INTRANET.TipoHwSw,0) IN (0,3,5) THEN RECEITA_STARSOFT.EmissaoNF ELSE DATEADD(day,2,RECEITA_STARSOFT.EmissaoNF) END AS DataEstEntrega,
		RECEITA_STARSOFT.CodPedido,		
		RECEITA_STARSOFT.J10_UKEY,
		RECEITA_STARSOFT.CIA_UKEY,	
		RECEITA_STARSOFT.J09_UKEY,
		RECEITA_STARSOFT.CodERP,
		RECEITA_STARSOFT.IVA * RECEITA_STARSOFT.Fator AS IVA,	
		RECEITA_STARSOFT.ICMSST * RECEITA_STARSOFT.Fator AS ICMSST,		
		RECEITA_STARSOFT.A03_UKEY,
		RECEITA_STARSOFT.A36_CODE,
		RECEITA_STARSOFT.Currency,
		RECEITA_STARSOFT.USDRate,
		RECEITA_INTRANET.DataPedido,
		RECEITA_INTRANET.CodPedidoRevenda,
		RECEITA_INTRANET.NomeRevenda,
		RECEITA_INTRANET.EnderecoRevenda,
		RECEITA_INTRANET.BairroRevenda,
		RECEITA_INTRANET.CidadeRevenda,
		RECEITA_INTRANET.UFRevenda,
		RECEITA_INTRANET.CEPRevenda,
		RTRIM(RECEITA_INTRANET.PaisRevenda),
		RECEITA_INTRANET.ContatoRevenda,
		RECEITA_INTRANET.EmailRevenda,
		RECEITA_INTRANET.TelRevenda,
		RECEITA_STARSOFT.EnderecoFatura,
		RTRIM(RECEITA_STARSOFT.BairroFatura),
		RECEITA_STARSOFT.CEPFatura,
		RTRIM(RECEITA_STARSOFT.PaisFatura),    
		RECEITA_INTRANET.EmpresaEntrega,
		RECEITA_INTRANET.EnderecoEntrega,
		RECEITA_INTRANET.BairroEntrega,
		RECEITA_INTRANET.CidadeEntrega,
		RECEITA_INTRANET.UFEntrega,
		RECEITA_INTRANET.PaisEntrega,
		RECEITA_INTRANET.EndUser,
		RECEITA_INTRANET.EnderecoEndUser,
		RECEITA_INTRANET.BairroEndUser,
		RECEITA_INTRANET.CidadeEndUser,
		RECEITA_INTRANET.UFEndUser,
		RECEITA_INTRANET.CEPEnduser,
		RECEITA_INTRANET.PaisEndUser,
		RECEITA_INTRANET.PCR * RECEITA_STARSOFT.Fator as UnitListPrice,    	        
		( RECEITA_INTRANET.PCR * RECEITA_STARSOFT.Qtd ) * RECEITA_STARSOFT.Fator AS ExtendedListPrice,
	
		CASE WHEN ((IsNUll(RECEITA_INTRANET.CodPedido, 0)) = 0)
			THEN IsNull( (SELECT intranet.GetDiscountPriceByCodERP (RECEITA_STARSOFT.PartNumber, RECEITA_STARSOFT.CodERP)), 0)
			ELSE (RECEITA_INTRANET.DescontoP * 100)
		END as StandardPurchaseDiscountPercentage,
	
		( RECEITA_INTRANET.PCR * RECEITA_STARSOFT.Qtd * RECEITA_INTRANET.DescontoP ) * RECEITA_STARSOFT.Fator as ExtendedStandardPurchaseDiscountAmount,
		RECEITA_INTRANET.SBAType,
		RECEITA_INTRANET.SBANumber,
		RECEITA_INTRANET.RebateNumber,
		RECEITA_INTRANET.SBADiscount * 100 as SBADiscount,
		--( RECEITA_INTRANET.PCR * RECEITA_STARSOFT.Qtd * RECEITA_INTRANET.SBADiscount ) * RECEITA_STARSOFT.Fator as SBAsAdditionalExtendedPurchaseDiscount, 
		-- se houver SBA, preço_lista*qtde * (SBA%-standard_purchase_discount%), senão 0 (zero) -- (negativo se devolução)
		CASE WHEN (IsNull(RECEITA_INTRANET.SBADiscount, 0) <> 0)
			THEN ((RECEITA_INTRANET.PCR * RECEITA_STARSOFT.Qtd * (RECEITA_INTRANET.SBADiscount - RECEITA_INTRANET.DescontoP))) * RECEITA_STARSOFT.Fator
			ELSE 0
		END as SBAsAdditionalExtendedPurchaseDiscount,

	   CASE WHEN IsNull(RECEITA_INTRANET.SBADiscount, 0) <> 0 AND LOWER(RECEITA_INTRANET.SBAType) = 'frontend'
			THEN ( RECEITA_INTRANET.PCR * RECEITA_STARSOFT.Qtd * RECEITA_INTRANET.SBADiscount ) * RECEITA_STARSOFT.Fator
			ELSE ( RECEITA_INTRANET.PCR * RECEITA_STARSOFT.Qtd * RECEITA_INTRANET.DESCONTO ) * RECEITA_STARSOFT.Fator
		END as ExtendedPurchaseDiscount, 
   
		RECEITA_INTRANET.UnitPurchasePrice * RECEITA_STARSOFT.Fator as UnitPurchasePrice, 
   
		( RECEITA_INTRANET.UnitPurchasePrice * RECEITA_STARSOFT.Qtd ) * RECEITA_STARSOFT.Fator as ExtendedPurchasePrice,      
	
		RECEITA_INTRANET.PurchasingCurrency as PurchasingCurrency, 
	
		RECEITA_INTRANET.NetPurchaseUnitCost * RECEITA_STARSOFT.Fator as NetPurchaseUnitCost, 
	
		( RECEITA_INTRANET.NetPurchaseUnitCost * RECEITA_STARSOFT.Qtd ) * RECEITA_STARSOFT.Fator as NetPurchaseExtendedCost,
   
		ISNULL(RECEITA_INTRANET.UnitClaimAmount,0) * RECEITA_STARSOFT.Fator as UnitClaimAmount,
	
		( ISNULL(RECEITA_INTRANET.UnitClaimAmount,0) * RECEITA_STARSOFT.Qtd ) * RECEITA_STARSOFT.Fator as ExtendedClaimAmount,
		
		'' as SFAOpportunityTrackingNumber,
		RECEITA_INTRANET.ObservacoesFinais,
		NomeERP = (select nomeerp from westcon.dbo.tblERP where CodERP = @ERP),
		/*RECEITA_INTRANET.NomeERP as NomeERP,*/
 		RECEITA_INTRANET.NomeRegiao as NomeRegiao,
		RECEITA_INTRANET.DistributorToVendorPO,
		RECEITA_INTRANET.NomeDivisao,
		RECEITA_INTRANET.CodDivisao,
		RECEITA_INTRANET.CodProposta,
		RECEITA_INTRANET.CodCarrinho,
		RECEITA_INTRANET.CustomerIdGrupoEconomicoRevenda,
		RECEITA_INTRANET.NomeGrupoEconomicoRevenda,
		RECEITA_INTRANET.CustomerIdGrupoEconomicoFatura,
		RECEITA_INTRANET.NomeGrupoEconomicoFatura,

		CASE WHEN (RECEITA_STARSOFT.TotalRevendaAntesComissao = 0)
			THEN 0
			ELSE RECEITA_STARSOFT.TotalRevendaAntesComissao * (1 + RECEITA_STARSOFT.IPI / (RECEITA_STARSOFT.TotalItemNF + isnull(RECEITA_STARSOFT.IPI,0))) * (1 + RECEITA_STARSOFT.IVA / (RECEITA_STARSOFT.TotalItemNF + isnull(RECEITA_STARSOFT.IPI,0))) * RECEITA_STARSOFT.Fator
		END as ReceitaBrutaDescontadaComissao,	 
		( 
			RECEITA_STARSOFT.TotalItemNF - RECEITA_STARSOFT.ICMS - RECEITA_STARSOFT.PIS - RECEITA_STARSOFT.COFINS - IsNull(RECEITA_STARSOFT.IRRF,0) - IsNull(RECEITA_STARSOFT.CSLL,0) - 0 - IsNull(RECEITA_STARSOFT.ProvisaoComissaoRevenda,0) -- ReceitaLiquidaStarSoft 
		) * RECEITA_STARSOFT.Fator
		as ReceitaLiquida,	

		(
			( 
				( RECEITA_STARSOFT.TotalItemNF - RECEITA_STARSOFT.ICMS - RECEITA_STARSOFT.PIS - RECEITA_STARSOFT.COFINS - IsNull(RECEITA_STARSOFT.IRRF,0) - IsNull(RECEITA_STARSOFT.CSLL,0) - 0 - IsNull(RECEITA_STARSOFT.ProvisaoComissaoRevenda,0) ) -- ReceitaLiquidaStarSoft 
				+ 
				( ISNULL(RECEITA_INTRANET.UnitClaimAmount,0) * RECEITA_STARSOFT.Qtd * RECEITA_STARSOFT.USDRate) -- ExtendedClaimAmount Convertido
			) -- Receita Liquida
			- RECEITA_STARSOFT.CustoMedioTotal 
		) * RECEITA_STARSOFT.Fator as LucroVenda,

		RECEITA_INTRANET.NetAccounting as NetAccounting,		

		case when RECEITA_INTRANET.NetAccounting = 'Yes'
		then
			(
				( 
					( RECEITA_STARSOFT.TotalItemNF - RECEITA_STARSOFT.ICMS - RECEITA_STARSOFT.PIS - RECEITA_STARSOFT.COFINS - IsNull(RECEITA_STARSOFT.IRRF,0) - IsNull(RECEITA_STARSOFT.CSLL,0) - 0 - IsNull(RECEITA_STARSOFT.ProvisaoComissaoRevenda,0) ) -- ReceitaLiquidaStarSoft 
					- 
					( ISNULL(RECEITA_INTRANET.UnitClaimAmount,0) * RECEITA_STARSOFT.Qtd * RECEITA_STARSOFT.USDRate) -- ExtendedClaimAmount Convertido
				) -- Receita Liquida
				- RECEITA_STARSOFT.CustoMedioTotal  -- LucroVendaNovo,
			) * RECEITA_STARSOFT.Fator
		else
			( 
				( RECEITA_STARSOFT.TotalItemNF - RECEITA_STARSOFT.ICMS - RECEITA_STARSOFT.PIS - RECEITA_STARSOFT.COFINS - IsNull(RECEITA_STARSOFT.IRRF,0) - IsNull(RECEITA_STARSOFT.CSLL,0) - 0 - IsNull(RECEITA_STARSOFT.ProvisaoComissaoRevenda,0) ) -- ReceitaLiquidaStarSoft 
				- 
				( ISNULL(RECEITA_INTRANET.UnitClaimAmount,0) * RECEITA_STARSOFT.Qtd * RECEITA_STARSOFT.USDRate) -- ExtendedClaimAmount Convertido
			) * RECEITA_STARSOFT.Fator -- ReceitaLiquidaNovo	
		end as NetAccountingRevenue,
		RECEITA_STARSOFT.RevenueType as RevenueType,
		case when 
				(
					case when RECEITA_INTRANET.NetAccounting = 'Yes'
					then
						(
							( 
								( RECEITA_STARSOFT.TotalItemNF - RECEITA_STARSOFT.ICMS - RECEITA_STARSOFT.PIS - RECEITA_STARSOFT.COFINS - IsNull(RECEITA_STARSOFT.IRRF,0) - IsNull(RECEITA_STARSOFT.CSLL,0) - 0 - IsNull(RECEITA_STARSOFT.ProvisaoComissaoRevenda,0) ) -- ReceitaLiquidaStarSoft 
								- 
								( ISNULL(RECEITA_INTRANET.UnitClaimAmount,0) * RECEITA_STARSOFT.Qtd * RECEITA_STARSOFT.USDRate) -- ExtendedClaimAmount Convertido
							) -- Receita Liquida
							- RECEITA_STARSOFT.CustoMedioTotal  -- LucroVendaNovo,
						) * RECEITA_STARSOFT.Fator
					else
						( 
							( RECEITA_STARSOFT.TotalItemNF - RECEITA_STARSOFT.ICMS - RECEITA_STARSOFT.PIS - RECEITA_STARSOFT.COFINS - IsNull(RECEITA_STARSOFT.IRRF,0) - IsNull(RECEITA_STARSOFT.CSLL,0) - 0 - IsNull(RECEITA_STARSOFT.ProvisaoComissaoRevenda,0) ) -- ReceitaLiquidaStarSoft 
							- 
							( ISNULL(RECEITA_INTRANET.UnitClaimAmount,0) * RECEITA_STARSOFT.Qtd * RECEITA_STARSOFT.USDRate) -- ExtendedClaimAmount Convertido
						) * RECEITA_STARSOFT.Fator -- ReceitaLiquidaNovo	
					end		
				) -- NetAccountingRevenue
				= 0
		then
			0
		else
			-- LucroVendaNovo / NetAccountingRevenue
			(
				(
					( 
						( RECEITA_STARSOFT.TotalItemNF - RECEITA_STARSOFT.ICMS - RECEITA_STARSOFT.PIS - RECEITA_STARSOFT.COFINS - IsNull(RECEITA_STARSOFT.IRRF,0) - IsNull(RECEITA_STARSOFT.CSLL,0) - 0 - IsNull(RECEITA_STARSOFT.ProvisaoComissaoRevenda,0) ) -- ReceitaLiquidaStarSoft 
						- 
						( ISNULL(RECEITA_INTRANET.UnitClaimAmount,0) * RECEITA_STARSOFT.Qtd * RECEITA_STARSOFT.USDRate) -- ExtendedClaimAmount Convertido
					) -- Receita Liquida
					- RECEITA_STARSOFT.CustoMedioTotal
				) * RECEITA_STARSOFT.Fator
			)-- LucroVendaNovo				
			/ -- dividido
			(
				case when RECEITA_INTRANET.NetAccounting = 'Yes'
				then
					(
						( 
							( RECEITA_STARSOFT.TotalItemNF - RECEITA_STARSOFT.ICMS - RECEITA_STARSOFT.PIS - RECEITA_STARSOFT.COFINS - IsNull(RECEITA_STARSOFT.IRRF,0) - IsNull(RECEITA_STARSOFT.CSLL,0) - 0 - IsNull(RECEITA_STARSOFT.ProvisaoComissaoRevenda,0) ) -- ReceitaLiquidaStarSoft 
							- 
							( ISNULL(RECEITA_INTRANET.UnitClaimAmount,0) * RECEITA_STARSOFT.Qtd * RECEITA_STARSOFT.USDRate) -- ExtendedClaimAmount Convertido
						) -- Receita Liquida
						- RECEITA_STARSOFT.CustoMedioTotal -- LucroVendaNovo,
					) * RECEITA_STARSOFT.Fator
				else
					( 
						( RECEITA_STARSOFT.TotalItemNF - RECEITA_STARSOFT.ICMS - RECEITA_STARSOFT.PIS - RECEITA_STARSOFT.COFINS - IsNull(RECEITA_STARSOFT.IRRF,0) - IsNull(RECEITA_STARSOFT.CSLL,0) - 0 - IsNull(RECEITA_STARSOFT.ProvisaoComissaoRevenda,0) ) -- ReceitaLiquidaStarSoft 
						- 
						( ISNULL(RECEITA_INTRANET.UnitClaimAmount,0) * RECEITA_STARSOFT.Qtd * RECEITA_STARSOFT.USDRate) -- ExtendedClaimAmount Convertido
					) * RECEITA_STARSOFT.Fator -- ReceitaLiquidaNovo	
				end 
			)
		end as NetMargin,
		RECEITA_INTRANET.MaintenanceOrOther as MaintenanceOrOther,
		(RECEITA_STARSOFT.TotalItemNF + RECEITA_STARSOFT.ICMSST + RECEITA_STARSOFT.IPI) * RECEITA_STARSOFT.Fator AS TotalItemNFComICMSEIPI,
		(RECEITA_STARSOFT.TotalItemNF + RECEITA_STARSOFT.IVA) * RECEITA_STARSOFT.Fator AS TotalItemNFComIVA,
		RECEITA_INTRANET.LoginAccountManager as LoginAccountManager,
		RECEITA_STARSOFT.SalesTax,
		RECEITA_INTRANET.ServiceProvider,
		RTRIM(RECEITA_INTRANET.ServiceProviderCountry),
		RECEITA_INTRANET.CEPEntrega,
		RECEITA_STARSOFT.POEfetiva,
		RECEITA_STARSOFT.InvoiceLineNumber,
		IsNull(RECEITA_INTRANET.CodRegiao,0) as CodRegiao,
		RTRIM(RECEITA_INTRANET.NomeParte),
		RECEITA_INTRANET.CBN,
		CASE WHEN IsNull(RECEITA_INTRANET.SBADiscount, 0) <> 0 AND LOWER(RECEITA_INTRANET.SBAType) = 'frontend'
			THEN RECEITA_INTRANET.SBADiscount * 100 -- SBADiscount
			ELSE 
				CASE WHEN ((IsNUll(RECEITA_INTRANET.CodPedido, 0)) = 0)
				THEN IsNull( (SELECT intranet.GetDiscountPriceByCodERP (RECEITA_STARSOFT.PartNumber, RECEITA_STARSOFT.CodERP)), 0)
				ELSE (RECEITA_INTRANET.DescontoP * 100) 
				END -- StandardPurchaseDiscountPercentage
		END as SOPurchaseDiscountPercent,
		RECEITA_STARSOFT.Complement,
		RECEITA_STARSOFT.J11_Ukey,
		RECEITA_STARSOFT.Intercompany,
		0 as CustoMedioUnMN,
		0 as CustoMedioTotalMN,
		isnull(RECEITA_STARSOFT.VendedorMTK,0) as VendedorMTK,  
		isnull(RECEITA_STARSOFT.ResselerMTK,0) as ResselerMTK,
		RECEITA_INTRANET.ID AS IDINTRANET,
		RECEITA_INTRANET.GDS as GDS,	

		--SCRUM-15091 - inicio
		CASE WHEN
				 RTRIM(CURRENCY) = 'US$' AND (RTRIM(CURRENCY_CIA) = '$' or RTRIM(CURRENCY_CIA) = 'R$' )
					THEN 
						(RECEITA_STARSOFT.ValorUnitarioNF * RECEITA_STARSOFT.Fator)*
						(CASE WHEN TAX1 <> 1 THEN TAX1
							WHEN  USDRATE <> 1 THEN USDRATE
							ELSE TAX2 
						END)
			WHEN
				(RTRIM(CURRENCY_CIA) = '$' or RTRIM(CURRENCY_CIA) = 'R$') AND RTRIM(CURRENCY_CIA) = 'US$' 
					THEN
						(RECEITA_STARSOFT.ValorUnitarioNF * RECEITA_STARSOFT.Fator)/
						(CASE	WHEN TAX1 <> 1 THEN TAX1
							WHEN  USDRATE <> 1 THEN USDRATE
							ELSE TAX2 END)
		
		ELSE
			(RECEITA_STARSOFT.ValorUnitarioNF * RECEITA_STARSOFT.Fator)
	
		END AS [totalitemnf(local currency)]
		,
	
		CASE WHEN
				 RTRIM(CURRENCY) = 'US$' AND (RTRIM(CURRENCY_CIA) = '$' or RTRIM(CURRENCY_CIA) = 'R$' )
					THEN 
						(RECEITA_STARSOFT.TotalItemNF * RECEITA_STARSOFT.Fator)*
						(CASE WHEN TAX1 <> 1 THEN TAX1
							WHEN  USDRATE <> 1 THEN USDRATE
							ELSE TAX2 
						END)
			WHEN
				(RTRIM(CURRENCY_CIA) = '$' or RTRIM(CURRENCY_CIA) = 'R$') AND RTRIM(CURRENCY_CIA) = 'US$' 
					THEN
						(RECEITA_STARSOFT.TotalItemNF  * RECEITA_STARSOFT.Fator)/
						(CASE	WHEN TAX1 <> 1 THEN TAX1
							WHEN  USDRATE <> 1 THEN USDRATE
							ELSE TAX2 END)
		
		ELSE
			(RECEITA_STARSOFT.TotalItemNF  * RECEITA_STARSOFT.Fator)
	
		END AS [receitaliquida(local currency)] 
		--SCRUM-15091 - fim
		FROM			StarSoft.fnReceitaProdutosCALA(@DATAINI, @DATAFIM,2)	RECEITA_STARSOFT 
		LEFT JOIN(
			SELECT DISTINCT
	
				wcnUsuarioWestcon.CodVendedor, -- não existe nas querys da BIReceita
				wcnUsuarioWestcon.LoginDominio as LoginAccountManager, -- login do vendedor 
				tblUsuario.NomeUsuario as NomeVendedor,
				ISNULL(dbo.tblParte1.Pcr, 0) AS Pcr, -- não existe nas querys da BIReceita
				(ISNULL(ISNULL(ISNULL(tblPropostaCarrinhoParte.SBA, tblPropostaCarrinhoParte.Promocao), tblParteDescontoRegiao.Desconto), 0) / 100) AS Desconto, -- não existe nas querys da BIReceita
				ISNULL(tblParte1.Pcr, 0) AS PcrP, -- não existe nas querys da BIReceita
				(ISNULL(tblParteDescontoRegiao.Desconto, 0)/100) AS DescontoP, -- não existe nas querys da BIReceita
				tblPropostaCarrinhoParte.CodParte as PartNumber, -- não existe nas querys da BIReceita
				tblVendor.NomeVendor AS Fabricante,
				tblParteFamilia.Descricao AS Familia,
				--tblParte1.Tipo AS TipoHwSw,
				--comentado em 23/11/2015 => Thiago/Mauricio/Raulison
				-- motivo: esta function aqui nesse SELECT esta demorando em torno de 20 segundos para executar um SELECT TOP 10
				-- esse problema foi resolvido com o CASE WHEN logo abaixo
				--(SELECT Tipo FROM dbo.GetTipoParte(tblERP.CodERP, tblParte1.CodParte, tblParte1.Tipo, tblPropostaCarrinhoParte.OrigemFaturamento)) as TipoHwSw, 
		
				CASE WHEN (@ERP = 0)
					THEN tblParte1.Tipo
					ELSE IsNUll(tblTipoItemERP.Tipo, tblParte1.Tipo)
				END as TipoHwSw,

				tblParte1.Grupo AS TipoGrupoSw,
				tblParte1.DescrNota, 
				tblForecastTipo.DescrForecastTipo AS OrigemPipeline, 
				tblERP.CodERP as CodERP, 
				ctePedido.CodPedido,
				CONVERT(smalldatetime, ctePedido.DataPedido) AS DataPedido, 
				ISNULL(ctePedido.CodPedoc, ctePedido.NomeProposta) AS CodPedidoRevenda, 
				ctePedido.NomeRevenda, 
				ctePedido.EnderecoRevenda, 
				ctePedido.BairroRevenda, 
				ctePedido.CidadeRevenda, 
				ctePedido.UFRevenda, 
				ctePedido.CEPRevenda, 
				PaisRevenda.NomePais AS PaisRevenda, 
				ISNULL(tblContato.NomeContato, ctePedido.ContatoRevenda) AS ContatoRevenda, 
				ISNULL(tblContato.Email, ctePedido.EmailRevenda) AS EmailRevenda, 
				ISNULL(tblContato.Telefone, ctePedido.TelRevenda) AS TelRevenda, 
				ISNULL(ctePedido.NomeEntrega, ctePedido.NomeRevenda) AS EmpresaEntrega, 
				ISNULL(ctePedido.EnderecoEntrega, ctePedido.EnderecoRevenda) AS EnderecoEntrega, 
				ISNULL(ctePedido.BairroEntrega, ctePedido.BairroRevenda) AS BairroEntrega, 
				ISNULL(ctePedido.CidadeEntrega, ctePedido.CidadeRevenda) AS CidadeEntrega, 
				ISNULL(ctePedido.UFEntrega, ctePedido.UFRevenda) AS UFEntrega, 
				ISNULL(ctePedido.CEPEntrega, ctePedido.CEPRevenda) AS CEPEntrega, 
				tblPaisEntrega.NomePais AS PaisEntrega, 
				ctePedido.EndUser, 
				ctePedido.EnderecoEndUser, 
				'' AS BairroEndUser, 
				ctePedido.CidadeEndUser, 
				ctePedido.UFEndUser, 
				ctePedido.CEPEndUser, 
				ISNULL(tblPaisEndUser.NomePais, '') as PaisEndUser,
				CASE WHEN (IsNUll(tblSBA.Rebate, 0) = 0) THEN 'FrontEnd' ELSE 'BackEnd' END as SBAType, 
				ISNULL(tblSBA.NomeSBA, '') AS SBANumber, 
				ISNULL(tblSBA.Dart, '') as RebateNumber, 
				(IsNull(tblPropostaCarrinhoParte.SBA,0)/100) as SBADiscount, -- campo 82
				0 as SFAOpportunityTrackingNumber, -- FALTA INFORMAÇÃO
		
				CASE WHEN (IsNull(tblPropostaCarrinhoParte.SBA,0) <> 0) AND (IsNUll(tblSBA.Rebate, 0) = 0) -- SBADiscount AND FRONTEND
				THEN ISNULL(tblParte1.Pcr, 0) * (1 - IsNull(tblPropostaCarrinhoParte.SBA,0)/100) -- SBADiscount
				ELSE ISNULL(tblParte1.Pcr, 0) * (1 - (ISNULL(tblParteDescontoRegiao.Desconto, 0) / 100)) -- (Preco) * (1 - Desconto)
				END as UnitPurchasePrice, -- campo 85

				IsNull(tblPO.A36_UKEY,'') as PurchasingCurrency, -- campo 87
		
				CASE WHEN (IsNull(tblPropostaCarrinhoParte.SBA, 0) <> 0) -- SBADiscount
				THEN ISNULL(tblParte1.Pcr,0) * (1 - IsNull(tblPropostaCarrinhoParte.SBA,0)/100) -- (Preco) * (1 - SBADiscount)
				ELSE ISNULL(tblParte1.Pcr,0) * (1 - (ISNULL(tblParteDescontoRegiao.Desconto, 0) / 100)) -- (Preco) * (1 - Desconto)
				END as NetPurchaseUnitCost, -- campo 88
		
				CASE WHEN ((IsNull(tblPropostaCarrinhoParte.SBA, 0) <> 0) AND  (IsNUll(tblSBA.Rebate, 0) <> 0) ) -- SBADiscount AND BACKEND
				THEN (ISNULL(tblParte1.Pcr,0) * (tblPropostaCarrinhoParte.SBA - ISNULL(tblParteDescontoRegiao.Desconto, 0)) / 100) -- (Preco) * (SBA - Desconto)
				ELSE 0
				END as UnitClaimAmount, -- campo 90

				/*CASE WHEN ((IsNull(tblPropostaCarrinhoParte.SBA, 0) <> 0) AND  (IsNUll(tblSBA.Rebate, 0) <> 0) ) -- SBADiscount AND BACKEND
				THEN (ISNULL(tblParte1.Pcr,0) * (tblPropostaCarrinhoParte.SBA - 
												CASE WHEN (ISNULL(tblPropostaCarrinhoPartePo.Desconto, 0) > 0) AND (IsNUll(tblPropostaCarrinhoPartePo.Desconto, 0) <= ISNULL(tblPropostaCarrinhoParte.SBA, 0))
													THEN IsNUll(tblPropostaCarrinhoPartePo.Desconto, 0)
												WHEN (ISNULL(tblParteDescontoRegiao.Desconto, 0) > 0) AND (ISNULL(tblPropostaCarrinhoPartePo.Desconto, 0) = 0) AND (IsNUll(tblParteDescontoRegiao.Desconto, 0) <= ISNULL(tblPropostaCarrinhoParte.SBA, 0))
													THEN ISNULL(tblParteDescontoRegiao.Desconto, 0) 
												ELSE
													ISNULL(tblPropostaCarrinhoParte.SBA, 0) END)/100)
				ELSE 0
				END as UnitClaimAmount, -- campo 90*/
				
				ctePedido.Observacao AS ObservacoesFinais, 
				IsNull(tblERP.NomeERP, '') as NomeERP, 
				tblRegiao.CodRegiao,
				IsNull(tblRegiao.NomeRegiao, '') as NomeRegiao, 
				ISNULL(listaPO.POList, '') AS DistributorToVendorPO, 
				--ISNULL(dbo.ConvertLinesCodPOInColumn(ctePedido.CodCarrinho, tblPropostaCarrinhoParte.CodParte), '') as EffectivePO,
				tblDivisao.NomeDivisao, 
				tblDivisao.CodDivisao, 
				ctePedido.CodProposta, 
				ctePedido.CodCarrinho, 
				tblGrupoEconomicoRevenda.CustomerID as CustomerIdGrupoEconomicoRevenda, 
				tblGrupoEconomicoRevenda.NomeGrupo as NomeGrupoEconomicoRevenda, 
				tblGrupoEconomicoFatura.CustomerID as CustomerIdGrupoEconomicoFatura, 
				tblGrupoEconomicoFatura.NomeGrupo as NomeGrupoEconomicoFatura, 
		
				CASE WHEN (
							(tblParte1.Grupo = '002') OR 
							(tblParte1.Grupo = '009') OR 
							(LOWER(tblVendor.NomeVendor) IN ('cisco', 'cisco br') OR  
							LEFT(tblPropostaCarrinhoParte.CodParte,4) = 'CON-') OR 
							(tblParte1.Grupo ='011')
						  )
					THEN 'Yes' 
					ELSE 'No' 
					END 
				AS NetAccounting, -- campo 109

				--CASE WHEN ((tblParte1.Grupo = '009') OR (LOWER(tblVendor.NomeVendor) = 'cisco' AND LEFT(tblPropostaCarrinhoParte.CodParte,4) = 'CON-')) 
				--	THEN 'Yes' 
				--	ELSE 'No' 
				--	END 
				--AS NetAccounting, -- campo 109

				'Product' as RevenueType, -- campo 110

				CASE WHEN (IsNull(tblParte1.Grupo,0) = 2 OR IsNull(tblParte1.Grupo,0) = 9)
					THEN 'Maintenance'
					ELSE 'Other'
				END as MaintenanceOrOther,
				tblServiceProvider.NomeProvider as ServiceProvider,
				PaisRevenda.NomePais AS ServiceProviderCountry,
				tblParte1.NomeParte,
				ctePedido.CBN,
				tblPropostaCarrinhoParte.Id,
				CASE WHEN (SELECT COUNT(Nome) FROM tblPropostaTag PT (NOLOCK) WHERE PT.CodPedido = ctePedido.CodPedido AND RTRIM(LTRIM(LOWER(Nome))) = 'gds') > 0 THEN 1 ELSE 0 END AS GDS
				--IsNull((SELECT Nome FROM tblPropostaTag PT (NOLOCK) WHERE PT.CodPedido = ctePedido.CodPedido AND RTRIM(LTRIM(LOWER(Nome))) = 'gds'),0) as GDS
			FROM 
				[dbo].[BIDadosPedidosIntranet] ctePedido (NOLOCK)
				INNER JOIN tblRegiao (NOLOCK) ON (ctePedido.CodRegiao = tblRegiao.CodRegiao)
				INNER JOIN tblERP ON (IsNull(tblERP.CodERP,0) = 0 OR tblRegiao.CodERP = tblERP.CodERP)
				INNER JOIN tblPropostaCarrinhoParte (NOLOCK) ON (tblPropostaCarrinhoParte.CodCarrinho = ctePedido.CodCarrinho)
				INNER JOIN tblParte1 (NOLOCK) ON (tblPropostaCarrinhoParte.CodParte = tblParte1.CodParte)
				LEFT OUTER JOIN tblSBA WITH (NOLOCK) ON (tblPropostaCarrinhoParte.CodSBA = tblSBA.CodSBA) AND (tblSBA.CodCarrinho = ctePedido.CodCarrinho)
				INNER JOIN tblParteFamilia (NOLOCK) ON (tblParte1.CodParteFamilia = tblParteFamilia.CodParteFamilia)
				INNER JOIN tblVendor (NOLOCK) ON (tblParte1.CodVendor = tblVendor.CodVendor)
				LEFT OUTER JOIN tblEmpresaRel tblRevenda WITH (NOLOCK) ON (tblRevenda.CodERP = tblERP.CodERP) AND (ctePedido.IdRevenda is not null AND ctePedido.IdRevenda = tblRevenda.Id) OR (ctePedido.IdRevenda is null AND ctePedido.CGCRevenda = tblRevenda.CGC)
				LEFT OUTER JOIN wcnUsuarioWestcon (NOLOCK) ON (ctePedido.CodUsuarioComercial = wcnUsuarioWestcon.IDUsuario)
				LEFT OUTER JOIN tblUsuario (NOLOCK) ON (wcnUsuarioWestcon.IDUsuario = tblUsuario.CodUsuario)
				LEFT OUTER JOIN tblForecast (NOLOCK) ON (ctePedido.CodProposta = tblForecast.CodProposta)
				LEFT OUTER JOIN tblForecastOportunidade (NOLOCK) ON (tblForecast.CodOportunidade = tblForecastOportunidade.CodOportunidade)
				LEFT OUTER JOIN tblForecastTipo (NOLOCK) ON (tblForecastOportunidade.CodForecastTipo = tblForecastTipo.CodForecastTipo)
				--LEFT OUTER JOIN tblGrupoEconomico tblGrupoEconomicoRevenda WITH (NOLOCK) ON (tblGrupoEconomicoRevenda.CustomerID = tblRevenda.CustomerID)
				LEFT OUTER JOIN tblPais PaisRevenda WITH (NoLock) ON (ctePedido.PaisRevenda = PaisRevenda.CodPais)
				LEFT OUTER JOIN tblPais tblPaisEndUser WITH (NoLock) ON ctePedido.PaisEndUser = tblPaisEndUser.CodPais
				LEFT OUTER JOIN tblPais tblPaisEntrega WITH (NoLock) ON ctePedido.PaisEntrega = tblPaisEntrega.CodPais
				--LEFT OUTER JOIN tblEmpresaRel tblFatura WITH (NOLOCK) ON (CASE WHEN (ctePedido.CodCarrinho IS NULL) THEN ctePedido.IDEmpresaFaturamento ELSE ctePedido.IDEmpresaFaturamento END) = tblFatura.ID
				--LEFT OUTER JOIN tblGrupoEconomico tblGrupoEconomicoFatura WITH (NOLOCK) ON tblGrupoEconomicoFatura.CustomerID = tblFatura.CustomerID
				LEFT OUTER JOIN tblGrupoEconomico tblGrupoEconomicoRevenda WITH (NOLOCK) ON (tblGrupoEconomicoRevenda.CustomerID = ctePedido.CustomerIDRevenda)
				--LEFT OUTER JOIN tblPais PaisFatura WITH (NoLock) ON (tblFatura.CodPais = PaisFatura.CodPais)
				LEFT OUTER JOIN tblGrupoEconomico tblGrupoEconomicoFatura WITH (NOLOCK) ON tblGrupoEconomicoFatura.CustomerID = ctePedido.CustomerIdFatura
				LEFT OUTER JOIN tblContato WITH (NOLOCK) ON (ctePedido.IDContato = tblContato.CodContato)
				-- LEFT OUTER JOIN tblMercadoVertical WITH (NOLOCK) ON (tblForecastOportunidade.CodMercadoVertical = tblMercadoVertical.CodMercadoVertical)
				LEFT OUTER JOIN tblServiceProvider WITH (NOLOCK) ON (tblForecastOportunidade.IDServiceProvider = tblServiceProvider.IDProvider)
				LEFT OUTER JOIN tblParteDescontoRegiao WITH (NOLOCK) ON (tblParte1.CodParteDesconto = tblParteDescontoRegiao.CodParteDesconto) AND (tblParteDescontoRegiao.CodRegiao = ctePedido.CodRegiao)
				LEFT OUTER JOIN tblDivisao WITH (NOLOCK) ON ctePedido.CodDivisao = tblDivisao.CodDivisao 
				LEFT OUTER JOIN
					(
						SELECT 
							PCPPO.CodCarrinho,
							PCPPO.CodParte,
							--[dbo].[GetPOListV3-sugestao](PCPPO.CodCarrinho, PCPPO.CodParte, 0) as POList
							[dbo].[GetPOListV2](PCPPO.CodCarrinho, PCPPO.CodParte, 0) as POList
							--'' as POList
						FROM tblPropostaCarrinhoPartePO PCPPO (NOLOCK) 
						INNER JOIN tblPO (NOLOCK) ON PCPPO.CodPO = tblPO.CodPO
						GROUP BY PCPPO.CodCarrinho, PCPPO.CodParte
					) listaPO 
					ON 	tblPropostaCarrinhoParte.CodCarrinho = ListaPO.CodCarrinho 
						and tblPropostaCarrinhoParte.CodParte = listaPO.CodParte 

				LEFT OUTER JOIN tblPropostaCarrinhoPartePo WITH (NOLOCK) ON (listaPO.CodCarrinho is not null AND tblPropostaCarrinhoPartePo.CodCarrinho = ListaPO.CodCarrinho) AND (listaPO.CodParte is not null and tblPropostaCarrinhoPartePo.CodParte = listaPO.CodParte)
				LEFT OUTER JOIN tblPO WITH (NOLOCK) ON (tblPropostaCarrinhoPartePO.CodPO = tblPO.CodPO)
				LEFT OUTER JOIN tblTipoItemERP WITH (NOLOCK) ON tblTipoItemERP.PartNumber = tblParte1.CodParte AND tblTipoItemERP.CodErp = tblERP.CodERP

			--WHERE ctePedido.CodPedido>=150000 and tblRegiao.CodERP = @CodERP AND tblPropostaCarrinhoParte.CodParte='WS-C2960X-48LPS-L'
			--WHERE tblRegiao.CodERP= @CodERP AND ctePedido.CodPedido >= 202257 AND ctePedido.CodPedido <= 321659
			WHERE tblRegiao.CodERP= @ERP  AND ctePedido.CodPedido IN ((select codpedido from StarSoft.fnReceitaProdutosCALA(@DATAINI, @DATAFIM,2) where codpedido is not null
																				group by codpedido))
		) RECEITA_INTRANET 
		ON				(CONVERT(VARCHAR,RECEITA_INTRANET.CodPedido) = RECEITA_STARSOFT.CodPedido) AND (RECEITA_INTRANET.PartNumber = RECEITA_STARSOFT.PartNumber ) AND (RECEITA_STARSOFT.ID_INTRANET IS NULL OR RECEITA_STARSOFT.ID_INTRANET = RECEITA_INTRANET.ID)
		--LEFT OUTER JOIN starwestcon.dbo.A33 VENDEDOR_STARSOFT (NoLock)
		--ON				VENDEDOR_STARSOFT.A33_001_C = IsNull(RECEITA_INTRANET.CodVendedor,'NAOENCONTRAR')    
		Where			(@VENDOR = '0' OR ISNULL(RECEITA_INTRANET.Fabricante, RECEITA_STARSOFT.FABRICANTE) = @VENDOR)    
	
	END

	/************************************** MEXICO *****************************************/

	IF @ERP = 3

	BEGIN        
    
		INSERT INTO Reports.BIReceita 
		select
		RTRIM(ISNULL(RECEITA_INTRANET.Fabricante, RECEITA_STARSOFT.FABRICANTE)) as Fabricante,
		RTRIM(ISNULL(RECEITA_INTRANET.Familia, RECEITA_STARSOFT.FAMILIA)) as Familia,
		ISNULL(RECEITA_INTRANET.TipoHwSw, [Westcon].[Intranet].[Reports_PartNumberTipoHwSw](RECEITA_STARSOFT.PartNumber)) as TipoHwSw,
		ISNULL(RECEITA_INTRANET.TipoGrupoSw, [Westcon].[Intranet].[Reports_PartNumberTipoGrupoSw](RECEITA_STARSOFT.PartNumber)) as TipoGrupoSw,
		ISNULL(RECEITA_INTRANET.DescrNota, [Westcon].[Intranet].[Reports_PartNumberDescription](RECEITA_STARSOFT.PartNumber)) AS DescrNota, 	
		RECEITA_STARSOFT.PedidoVenda,
		RECEITA_STARSOFT.PedidoVendaTrimmed,
		RTRIM(RECEITA_STARSOFT.NF),
		RECEITA_STARSOFT.TipoES,
		RECEITA_STARSOFT.EmissaoNF,
		RTRIM(RECEITA_STARSOFT.PartNumber),
		RTRIM(RECEITA_STARSOFT.CNPJEmpresaNF),
		RECEITA_STARSOFT.EmpresaNF,
		RECEITA_STARSOFT.Qtd,
		RECEITA_STARSOFT.ValorUnitarioNF * RECEITA_STARSOFT.Fator as ValorUnitarioNF,
		--RECEITA_STARSOFT.TotalItemNF + isnull(RECEITA_STARSOFT.IPI,0) as TotalItemNF,
		RECEITA_STARSOFT.TotalItemNF * RECEITA_STARSOFT.Fator as TotalItemNF,
		RECEITA_STARSOFT.CustoMedioUn * RECEITA_STARSOFT.Fator as CustoMedioUn,
		RECEITA_STARSOFT.CustoMedioTotal * RECEITA_STARSOFT.Fator as CustoMedioTotal,
		RECEITA_STARSOFT.ProvisaoComissaoRevenda * RECEITA_STARSOFT.Fator as ProvisaoComissaoRevenda,
		RECEITA_INTRANET.OrigemPipeline,       		
		RECEITA_STARSOFT.TotalRevendaAntesComissao * RECEITA_STARSOFT.Fator as TotalRevendaAntesComissao,
		RECEITA_STARSOFT.ICMS * RECEITA_STARSOFT.Fator AS ICMS,
		RECEITA_STARSOFT.PIS * RECEITA_STARSOFT.Fator AS PIS,
		RECEITA_STARSOFT.COFINS * RECEITA_STARSOFT.Fator AS COFINS,
		RECEITA_STARSOFT.IRRF * RECEITA_STARSOFT.Fator AS IRRF,
		RECEITA_STARSOFT.CSLL * RECEITA_STARSOFT.Fator AS CSLL,
		RECEITA_STARSOFT.IPI * RECEITA_STARSOFT.Fator AS IPI,
		RECEITA_STARSOFT.ISS * RECEITA_STARSOFT.Fator AS ISS,
		RECEITA_STARSOFT.Estado,
		RTRIM(RECEITA_STARSOFT.Cidade),
		RECEITA_STARSOFT.VENDEDOR,
		RECEITA_INTRANET.NomeVendedor as VendedorIntranet, 	
		RECEITA_STARSOFT.NFDevolvida,
		CASE WHEN ISNULL(RECEITA_INTRANET.TipoHwSw,0) IN (0,3,5) THEN RECEITA_STARSOFT.EmissaoNF ELSE DATEADD(day,2,RECEITA_STARSOFT.EmissaoNF) END AS DataEstEntrega,
		RECEITA_STARSOFT.CodPedido,		
		RECEITA_STARSOFT.J10_UKEY,
		RECEITA_STARSOFT.CIA_UKEY,	
		RECEITA_STARSOFT.J09_UKEY,
		RECEITA_STARSOFT.CodERP,
		RECEITA_STARSOFT.IVA * RECEITA_STARSOFT.Fator AS IVA,	
		RECEITA_STARSOFT.ICMSST * RECEITA_STARSOFT.Fator AS ICMSST,		
		RECEITA_STARSOFT.A03_UKEY,
		RECEITA_STARSOFT.A36_CODE,
		RECEITA_STARSOFT.Currency,
		RECEITA_STARSOFT.USDRate,
		RECEITA_INTRANET.DataPedido,
		RECEITA_INTRANET.CodPedidoRevenda,
		RECEITA_INTRANET.NomeRevenda,
		RECEITA_INTRANET.EnderecoRevenda,
		RECEITA_INTRANET.BairroRevenda,
		RECEITA_INTRANET.CidadeRevenda,
		RECEITA_INTRANET.UFRevenda,
		RECEITA_INTRANET.CEPRevenda,
		RTRIM(RECEITA_INTRANET.PaisRevenda),
		RECEITA_INTRANET.ContatoRevenda,
		RECEITA_INTRANET.EmailRevenda,
		RECEITA_INTRANET.TelRevenda,
		RECEITA_STARSOFT.EnderecoFatura,
		RTRIM(RECEITA_STARSOFT.BairroFatura),
		RECEITA_STARSOFT.CEPFatura,
		RTRIM(RECEITA_STARSOFT.PaisFatura),    
		RECEITA_INTRANET.EmpresaEntrega,
		RECEITA_INTRANET.EnderecoEntrega,
		RECEITA_INTRANET.BairroEntrega,
		RECEITA_INTRANET.CidadeEntrega,
		RECEITA_INTRANET.UFEntrega,
		RECEITA_INTRANET.PaisEntrega,
		RECEITA_INTRANET.EndUser,
		RECEITA_INTRANET.EnderecoEndUser,
		RECEITA_INTRANET.BairroEndUser,
		RECEITA_INTRANET.CidadeEndUser,
		RECEITA_INTRANET.UFEndUser,
		RECEITA_INTRANET.CEPEnduser,
		RECEITA_INTRANET.PaisEndUser,
		RECEITA_INTRANET.PCR * RECEITA_STARSOFT.Fator as UnitListPrice,    	        
		( RECEITA_INTRANET.PCR * RECEITA_STARSOFT.Qtd ) * RECEITA_STARSOFT.Fator AS ExtendedListPrice,
	
		CASE WHEN ((IsNUll(RECEITA_INTRANET.CodPedido, 0)) = 0)
			THEN IsNull( (SELECT intranet.GetDiscountPriceByCodERP (RECEITA_STARSOFT.PartNumber, RECEITA_STARSOFT.CodERP)), 0)
			ELSE (RECEITA_INTRANET.DescontoP * 100)
		END as StandardPurchaseDiscountPercentage,
	
		( RECEITA_INTRANET.PCR * RECEITA_STARSOFT.Qtd * RECEITA_INTRANET.DescontoP ) * RECEITA_STARSOFT.Fator as ExtendedStandardPurchaseDiscountAmount,
		RECEITA_INTRANET.SBAType,
		RECEITA_INTRANET.SBANumber,
		RECEITA_INTRANET.RebateNumber,
		RECEITA_INTRANET.SBADiscount * 100 as SBADiscount,
		--( RECEITA_INTRANET.PCR * RECEITA_STARSOFT.Qtd * RECEITA_INTRANET.SBADiscount ) * RECEITA_STARSOFT.Fator as SBAsAdditionalExtendedPurchaseDiscount, 
		-- se houver SBA, preço_lista*qtde * (SBA%-standard_purchase_discount%), senão 0 (zero) -- (negativo se devolução)
		CASE WHEN (IsNull(RECEITA_INTRANET.SBADiscount, 0) <> 0)
			THEN ((RECEITA_INTRANET.PCR * RECEITA_STARSOFT.Qtd * (RECEITA_INTRANET.SBADiscount - RECEITA_INTRANET.DescontoP))) * RECEITA_STARSOFT.Fator
			ELSE 0
		END as SBAsAdditionalExtendedPurchaseDiscount,

	   CASE WHEN IsNull(RECEITA_INTRANET.SBADiscount, 0) <> 0 AND LOWER(RECEITA_INTRANET.SBAType) = 'frontend'
			THEN ( RECEITA_INTRANET.PCR * RECEITA_STARSOFT.Qtd * RECEITA_INTRANET.SBADiscount ) * RECEITA_STARSOFT.Fator
			ELSE ( RECEITA_INTRANET.PCR * RECEITA_STARSOFT.Qtd * RECEITA_INTRANET.DESCONTO ) * RECEITA_STARSOFT.Fator
		END as ExtendedPurchaseDiscount, 
   
		RECEITA_INTRANET.UnitPurchasePrice * RECEITA_STARSOFT.Fator as UnitPurchasePrice, 
   
		( RECEITA_INTRANET.UnitPurchasePrice * RECEITA_STARSOFT.Qtd ) * RECEITA_STARSOFT.Fator as ExtendedPurchasePrice,      
	
		RECEITA_INTRANET.PurchasingCurrency as PurchasingCurrency, 
	
		RECEITA_INTRANET.NetPurchaseUnitCost * RECEITA_STARSOFT.Fator as NetPurchaseUnitCost, 
	
		( RECEITA_INTRANET.NetPurchaseUnitCost * RECEITA_STARSOFT.Qtd ) * RECEITA_STARSOFT.Fator as NetPurchaseExtendedCost,
   
		ISNULL(RECEITA_INTRANET.UnitClaimAmount,0) * RECEITA_STARSOFT.Fator as UnitClaimAmount,
	
		( ISNULL(RECEITA_INTRANET.UnitClaimAmount,0) * RECEITA_STARSOFT.Qtd ) * RECEITA_STARSOFT.Fator as ExtendedClaimAmount,
		
		'' as SFAOpportunityTrackingNumber,
		RECEITA_INTRANET.ObservacoesFinais,
		NomeERP = (select nomeerp from westcon.dbo.tblERP where CodERP = @ERP),
		/*RECEITA_INTRANET.NomeERP as NomeERP,*/
 		RECEITA_INTRANET.NomeRegiao as NomeRegiao,
		RECEITA_INTRANET.DistributorToVendorPO,
		RECEITA_INTRANET.NomeDivisao,
		RECEITA_INTRANET.CodDivisao,
		RECEITA_INTRANET.CodProposta,
		RECEITA_INTRANET.CodCarrinho,
		RECEITA_INTRANET.CustomerIdGrupoEconomicoRevenda,
		RECEITA_INTRANET.NomeGrupoEconomicoRevenda,
		RECEITA_INTRANET.CustomerIdGrupoEconomicoFatura,
		RECEITA_INTRANET.NomeGrupoEconomicoFatura,

		CASE WHEN (RECEITA_STARSOFT.TotalRevendaAntesComissao = 0)
			THEN 0
			ELSE RECEITA_STARSOFT.TotalRevendaAntesComissao * (1 + RECEITA_STARSOFT.IPI / (RECEITA_STARSOFT.TotalItemNF + isnull(RECEITA_STARSOFT.IPI,0))) * (1 + RECEITA_STARSOFT.IVA / (RECEITA_STARSOFT.TotalItemNF + isnull(RECEITA_STARSOFT.IPI,0))) * RECEITA_STARSOFT.Fator
		END as ReceitaBrutaDescontadaComissao,	 
		( 
			 RECEITA_STARSOFT.TotalItemNF - RECEITA_STARSOFT.ICMS - RECEITA_STARSOFT.PIS - RECEITA_STARSOFT.COFINS - IsNull(RECEITA_STARSOFT.IRRF,0) - IsNull(RECEITA_STARSOFT.CSLL,0) - 0 - IsNull(RECEITA_STARSOFT.ProvisaoComissaoRevenda,0)  -- ReceitaLiquidaStarSoft 
		) * RECEITA_STARSOFT.Fator
		as ReceitaLiquida,	

		(
			( 
				( RECEITA_STARSOFT.TotalItemNF - RECEITA_STARSOFT.ICMS - RECEITA_STARSOFT.PIS - RECEITA_STARSOFT.COFINS - IsNull(RECEITA_STARSOFT.IRRF,0) - IsNull(RECEITA_STARSOFT.CSLL,0) - 0 - IsNull(RECEITA_STARSOFT.ProvisaoComissaoRevenda,0) ) -- ReceitaLiquidaStarSoft 
				+ 
				( ISNULL(RECEITA_INTRANET.UnitClaimAmount,0) * RECEITA_STARSOFT.Qtd * RECEITA_STARSOFT.USDRate) -- ExtendedClaimAmount Convertido
			) -- Receita Liquida
			- RECEITA_STARSOFT.CustoMedioTotal 
		) * RECEITA_STARSOFT.Fator as LucroVenda,

		RECEITA_INTRANET.NetAccounting as NetAccounting,		

		case when RECEITA_INTRANET.NetAccounting = 'Yes'
		then
			(
				( 
					( RECEITA_STARSOFT.TotalItemNF - RECEITA_STARSOFT.ICMS - RECEITA_STARSOFT.PIS - RECEITA_STARSOFT.COFINS - IsNull(RECEITA_STARSOFT.IRRF,0) - IsNull(RECEITA_STARSOFT.CSLL,0) - 0 - IsNull(RECEITA_STARSOFT.ProvisaoComissaoRevenda,0) ) -- ReceitaLiquidaStarSoft 
					- 
					( ISNULL(RECEITA_INTRANET.UnitClaimAmount,0) * RECEITA_STARSOFT.Qtd * RECEITA_STARSOFT.USDRate) -- ExtendedClaimAmount Convertido
				) -- Receita Liquida
				- RECEITA_STARSOFT.CustoMedioTotal  -- LucroVendaNovo,
			) * RECEITA_STARSOFT.Fator
		else
			( 
				( RECEITA_STARSOFT.TotalItemNF - RECEITA_STARSOFT.ICMS - RECEITA_STARSOFT.PIS - RECEITA_STARSOFT.COFINS - IsNull(RECEITA_STARSOFT.IRRF,0) - IsNull(RECEITA_STARSOFT.CSLL,0) - 0 - IsNull(RECEITA_STARSOFT.ProvisaoComissaoRevenda,0) ) -- ReceitaLiquidaStarSoft 
				- 
				( ISNULL(RECEITA_INTRANET.UnitClaimAmount,0) * RECEITA_STARSOFT.Qtd * RECEITA_STARSOFT.USDRate) -- ExtendedClaimAmount Convertido
			) * RECEITA_STARSOFT.Fator -- ReceitaLiquidaNovo	
		end as NetAccountingRevenue,
		RECEITA_STARSOFT.RevenueType as RevenueType,
		case when 
				(
					case when RECEITA_INTRANET.NetAccounting = 'Yes'
					then
						(
							( 
								( RECEITA_STARSOFT.TotalItemNF - RECEITA_STARSOFT.ICMS - RECEITA_STARSOFT.PIS - RECEITA_STARSOFT.COFINS - IsNull(RECEITA_STARSOFT.IRRF,0) - IsNull(RECEITA_STARSOFT.CSLL,0) - 0 - IsNull(RECEITA_STARSOFT.ProvisaoComissaoRevenda,0) ) -- ReceitaLiquidaStarSoft 
								- 
								( ISNULL(RECEITA_INTRANET.UnitClaimAmount,0) * RECEITA_STARSOFT.Qtd * RECEITA_STARSOFT.USDRate) -- ExtendedClaimAmount Convertido
							) -- Receita Liquida
							- RECEITA_STARSOFT.CustoMedioTotal  -- LucroVendaNovo,
						) * RECEITA_STARSOFT.Fator
					else
						( 
							( RECEITA_STARSOFT.TotalItemNF - RECEITA_STARSOFT.ICMS - RECEITA_STARSOFT.PIS - RECEITA_STARSOFT.COFINS - IsNull(RECEITA_STARSOFT.IRRF,0) - IsNull(RECEITA_STARSOFT.CSLL,0) - 0 - IsNull(RECEITA_STARSOFT.ProvisaoComissaoRevenda,0) ) -- ReceitaLiquidaStarSoft 
							- 
							( ISNULL(RECEITA_INTRANET.UnitClaimAmount,0) * RECEITA_STARSOFT.Qtd * RECEITA_STARSOFT.USDRate) -- ExtendedClaimAmount Convertido
						) * RECEITA_STARSOFT.Fator -- ReceitaLiquidaNovo	
					end		
				) -- NetAccountingRevenue
				= 0
		then
			0
		else
			-- LucroVendaNovo / NetAccountingRevenue
			(
				(
					( 
						( RECEITA_STARSOFT.TotalItemNF - RECEITA_STARSOFT.ICMS - RECEITA_STARSOFT.PIS - RECEITA_STARSOFT.COFINS - IsNull(RECEITA_STARSOFT.IRRF,0) - IsNull(RECEITA_STARSOFT.CSLL,0) - 0 - IsNull(RECEITA_STARSOFT.ProvisaoComissaoRevenda,0) ) -- ReceitaLiquidaStarSoft 
						- 
						( ISNULL(RECEITA_INTRANET.UnitClaimAmount,0) * RECEITA_STARSOFT.Qtd * RECEITA_STARSOFT.USDRate) -- ExtendedClaimAmount Convertido
					) -- Receita Liquida
					- RECEITA_STARSOFT.CustoMedioTotal
				) * RECEITA_STARSOFT.Fator
			)-- LucroVendaNovo				
			/ -- dividido
			(
				case when RECEITA_INTRANET.NetAccounting = 'Yes'
				then
					(
						( 
							( RECEITA_STARSOFT.TotalItemNF - RECEITA_STARSOFT.ICMS - RECEITA_STARSOFT.PIS - RECEITA_STARSOFT.COFINS - IsNull(RECEITA_STARSOFT.IRRF,0) - IsNull(RECEITA_STARSOFT.CSLL,0) - 0 - IsNull(RECEITA_STARSOFT.ProvisaoComissaoRevenda,0) ) -- ReceitaLiquidaStarSoft 
							- 
							( ISNULL(RECEITA_INTRANET.UnitClaimAmount,0) * RECEITA_STARSOFT.Qtd * RECEITA_STARSOFT.USDRate) -- ExtendedClaimAmount Convertido
						) -- Receita Liquida
						- RECEITA_STARSOFT.CustoMedioTotal -- LucroVendaNovo,
					) * RECEITA_STARSOFT.Fator
				else
					( 
						( RECEITA_STARSOFT.TotalItemNF - RECEITA_STARSOFT.ICMS - RECEITA_STARSOFT.PIS - RECEITA_STARSOFT.COFINS - IsNull(RECEITA_STARSOFT.IRRF,0) - IsNull(RECEITA_STARSOFT.CSLL,0) - 0 - IsNull(RECEITA_STARSOFT.ProvisaoComissaoRevenda,0) ) -- ReceitaLiquidaStarSoft 
						- 
						( ISNULL(RECEITA_INTRANET.UnitClaimAmount,0) * RECEITA_STARSOFT.Qtd * RECEITA_STARSOFT.USDRate) -- ExtendedClaimAmount Convertido
					) * RECEITA_STARSOFT.Fator -- ReceitaLiquidaNovo	
				end 
			)
		end as NetMargin,
		RECEITA_INTRANET.MaintenanceOrOther as MaintenanceOrOther,
		(RECEITA_STARSOFT.TotalItemNF + RECEITA_STARSOFT.ICMSST + RECEITA_STARSOFT.IPI) * RECEITA_STARSOFT.Fator AS TotalItemNFComICMSEIPI,
		(RECEITA_STARSOFT.TotalItemNF + RECEITA_STARSOFT.IVA) * RECEITA_STARSOFT.Fator AS TotalItemNFComIVA,
		RECEITA_INTRANET.LoginAccountManager as LoginAccountManager,
		RECEITA_STARSOFT.SalesTax,
		RECEITA_INTRANET.ServiceProvider,
		RTRIM(RECEITA_INTRANET.ServiceProviderCountry),
		RECEITA_INTRANET.CEPEntrega,
		RECEITA_STARSOFT.POEfetiva,
		RECEITA_STARSOFT.InvoiceLineNumber,
		IsNull(RECEITA_INTRANET.CodRegiao,0) as CodRegiao,
		RTRIM(RECEITA_INTRANET.NomeParte),
		RECEITA_INTRANET.CBN,
		CASE WHEN IsNull(RECEITA_INTRANET.SBADiscount, 0) <> 0 AND LOWER(RECEITA_INTRANET.SBAType) = 'frontend'
			THEN RECEITA_INTRANET.SBADiscount * 100 -- SBADiscount
			ELSE 
				CASE WHEN ((IsNUll(RECEITA_INTRANET.CodPedido, 0)) = 0)
				THEN IsNull( (SELECT intranet.GetDiscountPriceByCodERP (RECEITA_STARSOFT.PartNumber, RECEITA_STARSOFT.CodERP)), 0)
				ELSE (RECEITA_INTRANET.DescontoP * 100) 
				END -- StandardPurchaseDiscountPercentage
		END as SOPurchaseDiscountPercent,
		RECEITA_STARSOFT.Complement,
		RECEITA_STARSOFT.J11_Ukey,
		RECEITA_STARSOFT.Intercompany,
		RECEITA_STARSOFT.CustoMedioUnPeso as CustoMedioUnMN,
		RECEITA_STARSOFT.CustoMedioTotalPeso as CustoMedioTotalMN,
		0 as VendedorMTK,
		0 as ResselerMTK,
		RECEITA_INTRANET.ID AS IDINTRANET,
		RECEITA_INTRANET.GDS as GDS,	

		--SCRUM-15091 - inicio
		CASE WHEN
				 RTRIM(CURRENCY) = 'US$' AND (RTRIM(CURRENCY_CIA) = 'MN' or RTRIM(CURRENCY_CIA) = 'R$' )
					THEN 
						(RECEITA_STARSOFT.ValorUnitarioNF * RECEITA_STARSOFT.Fator)*
						(CASE WHEN TAX1 <> 1 THEN TAX1
							WHEN  USDRATE <> 1 THEN USDRATE
							ELSE TAX2 
						END)
			WHEN
				(RTRIM(CURRENCY_CIA) = 'MN' or RTRIM(CURRENCY_CIA) = 'R$') AND RTRIM(CURRENCY_CIA) = 'US$' 
					THEN
						(RECEITA_STARSOFT.ValorUnitarioNF * RECEITA_STARSOFT.Fator)/
						(CASE	WHEN TAX1 <> 1 THEN TAX1
							WHEN  USDRATE <> 1 THEN USDRATE
							ELSE TAX2 END)
		
		ELSE
			(RECEITA_STARSOFT.ValorUnitarioNF * RECEITA_STARSOFT.Fator)
	
		END AS [totalitemnf(local currency)]
		,
	
		CASE WHEN
				 RTRIM(CURRENCY) = 'US$' AND (RTRIM(CURRENCY_CIA) = 'MN' or RTRIM(CURRENCY_CIA) = 'R$' )
					THEN 
						(RECEITA_STARSOFT.TotalItemNF  * RECEITA_STARSOFT.Fator)*
						(CASE WHEN TAX1 <> 1 THEN TAX1
							WHEN  USDRATE <> 1 THEN USDRATE
							ELSE TAX2 
						END)
			WHEN
				(RTRIM(CURRENCY_CIA) = 'MN' or RTRIM(CURRENCY_CIA) = 'R$') AND RTRIM(CURRENCY_CIA) = 'US$' 
					THEN
						(RECEITA_STARSOFT.TotalItemNF  * RECEITA_STARSOFT.Fator)/
						(CASE	WHEN TAX1 <> 1 THEN TAX1
							WHEN  USDRATE <> 1 THEN USDRATE
							ELSE TAX2 END)
		
		ELSE
			(RECEITA_STARSOFT.TotalItemNF * RECEITA_STARSOFT.Fator)
	
		END AS [receitaliquida(local currency)] 
		--SCRUM-15091 - fim
		FROM			StarSoft.fnReceitaProdutosMX(@DATAINI, @DATAFIM)		RECEITA_STARSOFT 
		LEFT JOIN 
		(
			SELECT DISTINCT
	
				wcnUsuarioWestcon.CodVendedor, -- não existe nas querys da BIReceita
				wcnUsuarioWestcon.LoginDominio as LoginAccountManager, -- login do vendedor 
				tblUsuario.NomeUsuario as NomeVendedor,
				ISNULL(dbo.tblParte1.Pcr, 0) AS Pcr, -- não existe nas querys da BIReceita
				(ISNULL(ISNULL(ISNULL(tblPropostaCarrinhoParte.SBA, tblPropostaCarrinhoParte.Promocao), tblParteDescontoRegiao.Desconto), 0) / 100) AS Desconto, -- não existe nas querys da BIReceita
				ISNULL(tblParte1.Pcr, 0) AS PcrP, -- não existe nas querys da BIReceita
				(ISNULL(tblParteDescontoRegiao.Desconto, 0)/100) AS DescontoP, -- não existe nas querys da BIReceita
				tblPropostaCarrinhoParte.CodParte as PartNumber, -- não existe nas querys da BIReceita
				tblVendor.NomeVendor AS Fabricante,
				tblParteFamilia.Descricao AS Familia,
				--tblParte1.Tipo AS TipoHwSw,
				--comentado em 23/11/2015 => Thiago/Mauricio/Raulison
				-- motivo: esta function aqui nesse SELECT esta demorando em torno de 20 segundos para executar um SELECT TOP 10
				-- esse problema foi resolvido com o CASE WHEN logo abaixo
				--(SELECT Tipo FROM dbo.GetTipoParte(tblERP.CodERP, tblParte1.CodParte, tblParte1.Tipo, tblPropostaCarrinhoParte.OrigemFaturamento)) as TipoHwSw, 
		
				CASE WHEN (@ERP = 0)
					THEN tblParte1.Tipo
					ELSE IsNUll(tblTipoItemERP.Tipo, tblParte1.Tipo)
				END as TipoHwSw,

				tblParte1.Grupo AS TipoGrupoSw,
				tblParte1.DescrNota, 
				tblForecastTipo.DescrForecastTipo AS OrigemPipeline, 
				tblERP.CodERP as CodERP, 
				ctePedido.CodPedido,
				CONVERT(smalldatetime, ctePedido.DataPedido) AS DataPedido, 
				ISNULL(ctePedido.CodPedoc, ctePedido.NomeProposta) AS CodPedidoRevenda, 
				ctePedido.NomeRevenda, 
				ctePedido.EnderecoRevenda, 
				ctePedido.BairroRevenda, 
				ctePedido.CidadeRevenda, 
				ctePedido.UFRevenda, 
				ctePedido.CEPRevenda, 
				PaisRevenda.NomePais AS PaisRevenda, 
				ISNULL(tblContato.NomeContato, ctePedido.ContatoRevenda) AS ContatoRevenda, 
				ISNULL(tblContato.Email, ctePedido.EmailRevenda) AS EmailRevenda, 
				ISNULL(tblContato.Telefone, ctePedido.TelRevenda) AS TelRevenda, 
				ISNULL(ctePedido.NomeEntrega, ctePedido.NomeRevenda) AS EmpresaEntrega, 
				ISNULL(ctePedido.EnderecoEntrega, ctePedido.EnderecoRevenda) AS EnderecoEntrega, 
				ISNULL(ctePedido.BairroEntrega, ctePedido.BairroRevenda) AS BairroEntrega, 
				ISNULL(ctePedido.CidadeEntrega, ctePedido.CidadeRevenda) AS CidadeEntrega, 
				ISNULL(ctePedido.UFEntrega, ctePedido.UFRevenda) AS UFEntrega, 
				ISNULL(ctePedido.CEPEntrega, ctePedido.CEPRevenda) AS CEPEntrega, 
				tblPaisEntrega.NomePais AS PaisEntrega, 
				ctePedido.EndUser, 
				ctePedido.EnderecoEndUser, 
				'' AS BairroEndUser, 
				ctePedido.CidadeEndUser, 
				ctePedido.UFEndUser, 
				ctePedido.CEPEndUser, 
				ISNULL(tblPaisEndUser.NomePais, '') as PaisEndUser,
				CASE WHEN (IsNUll(tblSBA.Rebate, 0) = 0) THEN 'FrontEnd' ELSE 'BackEnd' END as SBAType, 
				ISNULL(tblSBA.NomeSBA, '') AS SBANumber, 
				ISNULL(tblSBA.Dart, '') as RebateNumber, 
				(IsNull(tblPropostaCarrinhoParte.SBA,0)/100) as SBADiscount, -- campo 82
				0 as SFAOpportunityTrackingNumber, -- FALTA INFORMAÇÃO
		
				CASE WHEN (IsNull(tblPropostaCarrinhoParte.SBA,0) <> 0) AND (IsNUll(tblSBA.Rebate, 0) = 0) -- SBADiscount AND FRONTEND
				THEN ISNULL(tblParte1.Pcr, 0) * (1 - IsNull(tblPropostaCarrinhoParte.SBA,0)/100) -- SBADiscount
				ELSE ISNULL(tblParte1.Pcr, 0) * (1 - (ISNULL(tblParteDescontoRegiao.Desconto, 0) / 100)) -- (Preco) * (1 - Desconto)
				END as UnitPurchasePrice, -- campo 85

				IsNull(tblPO.A36_UKEY,'') as PurchasingCurrency, -- campo 87
		
				CASE WHEN (IsNull(tblPropostaCarrinhoParte.SBA, 0) <> 0) -- SBADiscount
				THEN ISNULL(tblParte1.Pcr,0) * (1 - IsNull(tblPropostaCarrinhoParte.SBA,0)/100) -- (Preco) * (1 - SBADiscount)
				ELSE ISNULL(tblParte1.Pcr,0) * (1 - (ISNULL(tblParteDescontoRegiao.Desconto, 0) / 100)) -- (Preco) * (1 - Desconto)
				END as NetPurchaseUnitCost, -- campo 88
		
				CASE WHEN ((IsNull(tblPropostaCarrinhoParte.SBA, 0) <> 0) AND  (IsNUll(tblSBA.Rebate, 0) <> 0) ) -- SBADiscount AND BACKEND
				THEN (ISNULL(tblParte1.Pcr,0) * (tblPropostaCarrinhoParte.SBA - ISNULL(tblParteDescontoRegiao.Desconto, 0)) / 100) -- (Preco) * (SBA - Desconto)
				ELSE 0
				END as UnitClaimAmount, -- campo 90

				/*CASE WHEN ((IsNull(tblPropostaCarrinhoParte.SBA, 0) <> 0) AND  (IsNUll(tblSBA.Rebate, 0) <> 0) ) -- SBADiscount AND BACKEND
				THEN (ISNULL(tblParte1.Pcr,0) * (tblPropostaCarrinhoParte.SBA - 
												CASE WHEN (ISNULL(tblPropostaCarrinhoPartePo.Desconto, 0) > 0) AND (IsNUll(tblPropostaCarrinhoPartePo.Desconto, 0) <= ISNULL(tblPropostaCarrinhoParte.SBA, 0))
													THEN IsNUll(tblPropostaCarrinhoPartePo.Desconto, 0)
												WHEN (ISNULL(tblParteDescontoRegiao.Desconto, 0) > 0) AND (ISNULL(tblPropostaCarrinhoPartePo.Desconto, 0) = 0) AND (IsNUll(tblParteDescontoRegiao.Desconto, 0) <= ISNULL(tblPropostaCarrinhoParte.SBA, 0))
													THEN ISNULL(tblParteDescontoRegiao.Desconto, 0) 
												ELSE
													ISNULL(tblPropostaCarrinhoParte.SBA, 0) END)/100)
				ELSE 0
				END as UnitClaimAmount, -- campo 90*/
				
				ctePedido.Observacao AS ObservacoesFinais, 
				IsNull(tblERP.NomeERP, '') as NomeERP, 
				tblRegiao.CodRegiao,
				IsNull(tblRegiao.NomeRegiao, '') as NomeRegiao, 
				ISNULL(listaPO.POList, '') AS DistributorToVendorPO, 
				--ISNULL(dbo.ConvertLinesCodPOInColumn(ctePedido.CodCarrinho, tblPropostaCarrinhoParte.CodParte), '') as EffectivePO,
				tblDivisao.NomeDivisao, 
				tblDivisao.CodDivisao, 
				ctePedido.CodProposta, 
				ctePedido.CodCarrinho, 
				tblGrupoEconomicoRevenda.CustomerID as CustomerIdGrupoEconomicoRevenda, 
				tblGrupoEconomicoRevenda.NomeGrupo as NomeGrupoEconomicoRevenda, 
				tblGrupoEconomicoFatura.CustomerID as CustomerIdGrupoEconomicoFatura, 
				tblGrupoEconomicoFatura.NomeGrupo as NomeGrupoEconomicoFatura, 
		
				CASE WHEN (
							(tblParte1.Grupo = '002') OR 
							(tblParte1.Grupo = '009') OR 
							(LOWER(tblVendor.NomeVendor) IN ('cisco', 'cisco br') OR  
							LEFT(tblPropostaCarrinhoParte.CodParte,4) = 'CON-') OR 
							(tblParte1.Grupo ='011')
						  )
					THEN 'Yes' 
					ELSE 'No' 
					END 
				AS NetAccounting, -- campo 109

				--CASE WHEN ((tblParte1.Grupo = '009') OR (LOWER(tblVendor.NomeVendor) = 'cisco' AND LEFT(tblPropostaCarrinhoParte.CodParte,4) = 'CON-')) 
				--	THEN 'Yes' 
				--	ELSE 'No' 
				--	END 
				--AS NetAccounting, -- campo 109

				'Product' as RevenueType, -- campo 110

				CASE WHEN (IsNull(tblParte1.Grupo,0) = 2 OR IsNull(tblParte1.Grupo,0) = 9)
					THEN 'Maintenance'
					ELSE 'Other'
				END as MaintenanceOrOther,
				tblServiceProvider.NomeProvider as ServiceProvider,
				PaisRevenda.NomePais AS ServiceProviderCountry,
				tblParte1.NomeParte,
				ctePedido.CBN,
				tblPropostaCarrinhoParte.Id,
				CASE WHEN (SELECT COUNT(Nome) FROM tblPropostaTag PT (NOLOCK) WHERE PT.CodPedido = ctePedido.CodPedido AND RTRIM(LTRIM(LOWER(Nome))) = 'gds') > 0 THEN 1 ELSE 0 END AS GDS
				--IsNull((SELECT Nome FROM tblPropostaTag PT (NOLOCK) WHERE PT.CodPedido = ctePedido.CodPedido AND RTRIM(LTRIM(LOWER(Nome))) = 'gds'),0) as GDS
			FROM 
				[dbo].[BIDadosPedidosIntranet] ctePedido (NOLOCK)
				INNER JOIN tblRegiao (NOLOCK) ON (ctePedido.CodRegiao = tblRegiao.CodRegiao)
				INNER JOIN tblERP ON (IsNull(tblERP.CodERP,0) = 0 OR tblRegiao.CodERP = tblERP.CodERP)
				INNER JOIN tblPropostaCarrinhoParte (NOLOCK) ON (tblPropostaCarrinhoParte.CodCarrinho = ctePedido.CodCarrinho)
				INNER JOIN tblParte1 (NOLOCK) ON (tblPropostaCarrinhoParte.CodParte = tblParte1.CodParte)
				LEFT OUTER JOIN tblSBA WITH (NOLOCK) ON (tblPropostaCarrinhoParte.CodSBA = tblSBA.CodSBA) AND (tblSBA.CodCarrinho = ctePedido.CodCarrinho)
				INNER JOIN tblParteFamilia (NOLOCK) ON (tblParte1.CodParteFamilia = tblParteFamilia.CodParteFamilia)
				INNER JOIN tblVendor (NOLOCK) ON (tblParte1.CodVendor = tblVendor.CodVendor)
				LEFT OUTER JOIN tblEmpresaRel tblRevenda WITH (NOLOCK) ON (tblRevenda.CodERP = tblERP.CodERP) AND (ctePedido.IdRevenda is not null AND ctePedido.IdRevenda = tblRevenda.Id) OR (ctePedido.IdRevenda is null AND ctePedido.CGCRevenda = tblRevenda.CGC)
				LEFT OUTER JOIN wcnUsuarioWestcon (NOLOCK) ON (ctePedido.CodUsuarioComercial = wcnUsuarioWestcon.IDUsuario)
				LEFT OUTER JOIN tblUsuario (NOLOCK) ON (wcnUsuarioWestcon.IDUsuario = tblUsuario.CodUsuario)
				LEFT OUTER JOIN tblForecast (NOLOCK) ON (ctePedido.CodProposta = tblForecast.CodProposta)
				LEFT OUTER JOIN tblForecastOportunidade (NOLOCK) ON (tblForecast.CodOportunidade = tblForecastOportunidade.CodOportunidade)
				LEFT OUTER JOIN tblForecastTipo (NOLOCK) ON (tblForecastOportunidade.CodForecastTipo = tblForecastTipo.CodForecastTipo)
				--LEFT OUTER JOIN tblGrupoEconomico tblGrupoEconomicoRevenda WITH (NOLOCK) ON (tblGrupoEconomicoRevenda.CustomerID = tblRevenda.CustomerID)
				LEFT OUTER JOIN tblPais PaisRevenda WITH (NoLock) ON (ctePedido.PaisRevenda = PaisRevenda.CodPais)
				LEFT OUTER JOIN tblPais tblPaisEndUser WITH (NoLock) ON ctePedido.PaisEndUser = tblPaisEndUser.CodPais
				LEFT OUTER JOIN tblPais tblPaisEntrega WITH (NoLock) ON ctePedido.PaisEntrega = tblPaisEntrega.CodPais
				--LEFT OUTER JOIN tblEmpresaRel tblFatura WITH (NOLOCK) ON (CASE WHEN (ctePedido.CodCarrinho IS NULL) THEN ctePedido.IDEmpresaFaturamento ELSE ctePedido.IDEmpresaFaturamento END) = tblFatura.ID
				--LEFT OUTER JOIN tblGrupoEconomico tblGrupoEconomicoFatura WITH (NOLOCK) ON tblGrupoEconomicoFatura.CustomerID = tblFatura.CustomerID
				LEFT OUTER JOIN tblGrupoEconomico tblGrupoEconomicoRevenda WITH (NOLOCK) ON (tblGrupoEconomicoRevenda.CustomerID = ctePedido.CustomerIDRevenda)
				--LEFT OUTER JOIN tblPais PaisFatura WITH (NoLock) ON (tblFatura.CodPais = PaisFatura.CodPais)
				LEFT OUTER JOIN tblGrupoEconomico tblGrupoEconomicoFatura WITH (NOLOCK) ON tblGrupoEconomicoFatura.CustomerID = ctePedido.CustomerIdFatura
				LEFT OUTER JOIN tblContato WITH (NOLOCK) ON (ctePedido.IDContato = tblContato.CodContato)
				-- LEFT OUTER JOIN tblMercadoVertical WITH (NOLOCK) ON (tblForecastOportunidade.CodMercadoVertical = tblMercadoVertical.CodMercadoVertical)
				LEFT OUTER JOIN tblServiceProvider WITH (NOLOCK) ON (tblForecastOportunidade.IDServiceProvider = tblServiceProvider.IDProvider)
				LEFT OUTER JOIN tblParteDescontoRegiao WITH (NOLOCK) ON (tblParte1.CodParteDesconto = tblParteDescontoRegiao.CodParteDesconto) AND (tblParteDescontoRegiao.CodRegiao = ctePedido.CodRegiao)
				LEFT OUTER JOIN tblDivisao WITH (NOLOCK) ON ctePedido.CodDivisao = tblDivisao.CodDivisao 
				LEFT OUTER JOIN
					(
						SELECT 
							PCPPO.CodCarrinho,
							PCPPO.CodParte,
							--[dbo].[GetPOListV3-sugestao](PCPPO.CodCarrinho, PCPPO.CodParte, 0) as POList
							[dbo].[GetPOListV2](PCPPO.CodCarrinho, PCPPO.CodParte, 0) as POList
							--'' as POList
						FROM tblPropostaCarrinhoPartePO PCPPO (NOLOCK) 
						INNER JOIN tblPO (NOLOCK) ON PCPPO.CodPO = tblPO.CodPO
						GROUP BY PCPPO.CodCarrinho, PCPPO.CodParte
					) listaPO 
					ON 	tblPropostaCarrinhoParte.CodCarrinho = ListaPO.CodCarrinho 
						and tblPropostaCarrinhoParte.CodParte = listaPO.CodParte 

				LEFT OUTER JOIN tblPropostaCarrinhoPartePo WITH (NOLOCK) ON (listaPO.CodCarrinho is not null AND tblPropostaCarrinhoPartePo.CodCarrinho = ListaPO.CodCarrinho) AND (listaPO.CodParte is not null and tblPropostaCarrinhoPartePo.CodParte = listaPO.CodParte)
				LEFT OUTER JOIN tblPO WITH (NOLOCK) ON (tblPropostaCarrinhoPartePO.CodPO = tblPO.CodPO)
				LEFT OUTER JOIN tblTipoItemERP WITH (NOLOCK) ON tblTipoItemERP.PartNumber = tblParte1.CodParte AND tblTipoItemERP.CodErp = tblERP.CodERP

			--WHERE ctePedido.CodPedido>=150000 and tblRegiao.CodERP = @CodERP AND tblPropostaCarrinhoParte.CodParte='WS-C2960X-48LPS-L'
			--WHERE tblRegiao.CodERP= @CodERP AND ctePedido.CodPedido >= 202257 AND ctePedido.CodPedido <= 321659
			WHERE tblRegiao.CodERP= @ERP  AND ctePedido.CodPedido IN ((select codpedido from StarSoft.fnReceitaProdutosMX(@DATAINI, @DATAFIM) where codpedido is not null
																				group by codpedido))
		)				RECEITA_INTRANET 
		ON				(CONVERT(VARCHAR,RECEITA_INTRANET.CodPedido) = RECEITA_STARSOFT.CodPedido) AND (RECEITA_INTRANET.PartNumber = RECEITA_STARSOFT.PartNumber) AND (RECEITA_STARSOFT.ID_INTRANET IS NULL OR RECEITA_STARSOFT.ID_INTRANET = RECEITA_INTRANET.ID)
		--LEFT OUTER JOIN starwestcon.dbo.A33 VENDEDOR_STARSOFT (NoLock)
		--ON				VENDEDOR_STARSOFT.A33_001_C = IsNull(RECEITA_INTRANET.CodVendedor,'NAOENCONTRAR')    
		Where			(@VENDOR = '0' OR ISNULL(RECEITA_INTRANET.Fabricante, RECEITA_STARSOFT.FABRICANTE) = @VENDOR)    

	END


	/***************************************COLÔMBIA******************************************/

	IF @ERP = 4

	BEGIN        
    
		INSERT INTO Reports.BIReceita 
		select
		RTRIM(ISNULL(RECEITA_INTRANET.Fabricante, RECEITA_STARSOFT.FABRICANTE)) as Fabricante,
		RTRIM(ISNULL(RECEITA_INTRANET.Familia, RECEITA_STARSOFT.FAMILIA)) as Familia,
		ISNULL(RECEITA_INTRANET.TipoHwSw, [Westcon].[Intranet].[Reports_PartNumberTipoHwSw](RECEITA_STARSOFT.PartNumber)) as TipoHwSw,
		ISNULL(RECEITA_INTRANET.TipoGrupoSw, [Westcon].[Intranet].[Reports_PartNumberTipoGrupoSw](RECEITA_STARSOFT.PartNumber)) as TipoGrupoSw,
		ISNULL(RECEITA_INTRANET.DescrNota, [Westcon].[Intranet].[Reports_PartNumberDescription](RECEITA_STARSOFT.PartNumber)) AS DescrNota, 	
		RECEITA_STARSOFT.PedidoVenda,
		RECEITA_STARSOFT.PedidoVendaTrimmed,
		RTRIM(RECEITA_STARSOFT.NF),
		RECEITA_STARSOFT.TipoES,
		RECEITA_STARSOFT.EmissaoNF,
		RTRIM(RECEITA_STARSOFT.PartNumber),
		RTRIM(RECEITA_STARSOFT.CNPJEmpresaNF),
		RECEITA_STARSOFT.EmpresaNF,
		RECEITA_STARSOFT.Qtd,
		RECEITA_STARSOFT.ValorUnitarioNF * RECEITA_STARSOFT.Fator as ValorUnitarioNF,
		--RECEITA_STARSOFT.TotalItemNF + isnull(RECEITA_STARSOFT.IPI,0) as TotalItemNF,
		RECEITA_STARSOFT.TotalItemNF * RECEITA_STARSOFT.Fator as TotalItemNF,
		RECEITA_STARSOFT.CustoMedioUn * RECEITA_STARSOFT.Fator as CustoMedioUn,
		RECEITA_STARSOFT.CustoMedioTotal * RECEITA_STARSOFT.Fator as CustoMedioTotal,
		RECEITA_STARSOFT.ProvisaoComissaoRevenda * RECEITA_STARSOFT.Fator as ProvisaoComissaoRevenda,
		RECEITA_INTRANET.OrigemPipeline,       		
		RECEITA_STARSOFT.TotalRevendaAntesComissao * RECEITA_STARSOFT.Fator as TotalRevendaAntesComissao,
		RECEITA_STARSOFT.ICMS * RECEITA_STARSOFT.Fator AS ICMS,
		RECEITA_STARSOFT.PIS * RECEITA_STARSOFT.Fator AS PIS,
		RECEITA_STARSOFT.COFINS * RECEITA_STARSOFT.Fator AS COFINS,
		RECEITA_STARSOFT.IRRF * RECEITA_STARSOFT.Fator AS IRRF,
		RECEITA_STARSOFT.CSLL * RECEITA_STARSOFT.Fator AS CSLL,
		RECEITA_STARSOFT.IPI * RECEITA_STARSOFT.Fator AS IPI,
		RECEITA_STARSOFT.ISS * RECEITA_STARSOFT.Fator AS ISS,
		RECEITA_STARSOFT.Estado,
		RTRIM(RECEITA_STARSOFT.Cidade),
		RECEITA_STARSOFT.VENDEDOR,
		RECEITA_INTRANET.NomeVendedor as VendedorIntranet, 	
		RECEITA_STARSOFT.NFDevolvida,
		CASE WHEN ISNULL(RECEITA_INTRANET.TipoHwSw,0) IN (0,3,5) THEN RECEITA_STARSOFT.EmissaoNF ELSE DATEADD(day,2,RECEITA_STARSOFT.EmissaoNF) END AS DataEstEntrega,
		RECEITA_STARSOFT.CodPedido,		
		RECEITA_STARSOFT.J10_UKEY,
		RECEITA_STARSOFT.CIA_UKEY,	
		RECEITA_STARSOFT.J09_UKEY,
		RECEITA_STARSOFT.CodERP,
		RECEITA_STARSOFT.IVA * RECEITA_STARSOFT.Fator AS IVA,	
		RECEITA_STARSOFT.ICMSST * RECEITA_STARSOFT.Fator AS ICMSST,		
		RECEITA_STARSOFT.A03_UKEY,
		RECEITA_STARSOFT.A36_CODE,
		RECEITA_STARSOFT.Currency,
		RECEITA_STARSOFT.USDRate,
		RECEITA_INTRANET.DataPedido,
		RECEITA_INTRANET.CodPedidoRevenda,
		RECEITA_INTRANET.NomeRevenda,
		RECEITA_INTRANET.EnderecoRevenda,
		RECEITA_INTRANET.BairroRevenda,
		RECEITA_INTRANET.CidadeRevenda,
		RECEITA_INTRANET.UFRevenda,
		RECEITA_INTRANET.CEPRevenda,
		RTRIM(RECEITA_INTRANET.PaisRevenda),
		RECEITA_INTRANET.ContatoRevenda,
		RECEITA_INTRANET.EmailRevenda,
		RECEITA_INTRANET.TelRevenda,
		RECEITA_STARSOFT.EnderecoFatura,
		RTRIM(RECEITA_STARSOFT.BairroFatura),
		RECEITA_STARSOFT.CEPFatura,
		RTRIM(RECEITA_STARSOFT.PaisFatura),    
		RECEITA_INTRANET.EmpresaEntrega,
		RECEITA_INTRANET.EnderecoEntrega,
		RECEITA_INTRANET.BairroEntrega,
		RECEITA_INTRANET.CidadeEntrega,
		RECEITA_INTRANET.UFEntrega,
		RECEITA_INTRANET.PaisEntrega,
		RECEITA_INTRANET.EndUser,
		RECEITA_INTRANET.EnderecoEndUser,
		RECEITA_INTRANET.BairroEndUser,
		RECEITA_INTRANET.CidadeEndUser,
		RECEITA_INTRANET.UFEndUser,
		RECEITA_INTRANET.CEPEnduser,
		RECEITA_INTRANET.PaisEndUser,
		RECEITA_INTRANET.PCR * RECEITA_STARSOFT.Fator as UnitListPrice,    	        
		( RECEITA_INTRANET.PCR * RECEITA_STARSOFT.Qtd ) * RECEITA_STARSOFT.Fator AS ExtendedListPrice,
	
		CASE WHEN ((IsNUll(RECEITA_INTRANET.CodPedido, 0)) = 0)
			THEN IsNull( (SELECT intranet.GetDiscountPriceByCodERP (RECEITA_STARSOFT.PartNumber, RECEITA_STARSOFT.CodERP)), 0)
			ELSE (RECEITA_INTRANET.DescontoP * 100)
		END as StandardPurchaseDiscountPercentage,
	
		( RECEITA_INTRANET.PCR * RECEITA_STARSOFT.Qtd * RECEITA_INTRANET.DescontoP ) * RECEITA_STARSOFT.Fator as ExtendedStandardPurchaseDiscountAmount,
		RECEITA_INTRANET.SBAType,
		RECEITA_INTRANET.SBANumber,
		RECEITA_INTRANET.RebateNumber,
		RECEITA_INTRANET.SBADiscount * 100 as SBADiscount,
		--( RECEITA_INTRANET.PCR * RECEITA_STARSOFT.Qtd * RECEITA_INTRANET.SBADiscount ) * RECEITA_STARSOFT.Fator as SBAsAdditionalExtendedPurchaseDiscount, 
		-- se houver SBA, preço_lista*qtde * (SBA%-standard_purchase_discount%), senão 0 (zero) -- (negativo se devolução)
		CASE WHEN (IsNull(RECEITA_INTRANET.SBADiscount, 0) <> 0)
			THEN ((RECEITA_INTRANET.PCR * RECEITA_STARSOFT.Qtd * (RECEITA_INTRANET.SBADiscount - RECEITA_INTRANET.DescontoP))) * RECEITA_STARSOFT.Fator
			ELSE 0
		END as SBAsAdditionalExtendedPurchaseDiscount,

	   CASE WHEN IsNull(RECEITA_INTRANET.SBADiscount, 0) <> 0 AND LOWER(RECEITA_INTRANET.SBAType) = 'frontend'
			THEN ( RECEITA_INTRANET.PCR * RECEITA_STARSOFT.Qtd * RECEITA_INTRANET.SBADiscount ) * RECEITA_STARSOFT.Fator
			ELSE ( RECEITA_INTRANET.PCR * RECEITA_STARSOFT.Qtd * RECEITA_INTRANET.DESCONTO ) * RECEITA_STARSOFT.Fator
		END as ExtendedPurchaseDiscount, 
   
		RECEITA_INTRANET.UnitPurchasePrice * RECEITA_STARSOFT.Fator as UnitPurchasePrice, 
   
		( RECEITA_INTRANET.UnitPurchasePrice * RECEITA_STARSOFT.Qtd ) * RECEITA_STARSOFT.Fator as ExtendedPurchasePrice,      
	
		RECEITA_INTRANET.PurchasingCurrency as PurchasingCurrency, 
	
		RECEITA_INTRANET.NetPurchaseUnitCost * RECEITA_STARSOFT.Fator as NetPurchaseUnitCost, 
	
		( RECEITA_INTRANET.NetPurchaseUnitCost * RECEITA_STARSOFT.Qtd ) * RECEITA_STARSOFT.Fator as NetPurchaseExtendedCost,
   
		ISNULL(RECEITA_INTRANET.UnitClaimAmount,0) * RECEITA_STARSOFT.Fator as UnitClaimAmount,
	
		( ISNULL(RECEITA_INTRANET.UnitClaimAmount,0) * RECEITA_STARSOFT.Qtd ) * RECEITA_STARSOFT.Fator as ExtendedClaimAmount,
		
		'' as SFAOpportunityTrackingNumber,
		RECEITA_INTRANET.ObservacoesFinais,
		NomeERP = (select nomeerp from westcon.dbo.tblERP where CodERP = @ERP),
		/*RECEITA_INTRANET.NomeERP as NomeERP,*/
 		RECEITA_INTRANET.NomeRegiao as NomeRegiao,
		RECEITA_INTRANET.DistributorToVendorPO,
		RECEITA_INTRANET.NomeDivisao,
		RECEITA_INTRANET.CodDivisao,
		RECEITA_INTRANET.CodProposta,
		RECEITA_INTRANET.CodCarrinho,
		RECEITA_INTRANET.CustomerIdGrupoEconomicoRevenda,
		RECEITA_INTRANET.NomeGrupoEconomicoRevenda,
		RECEITA_INTRANET.CustomerIdGrupoEconomicoFatura,
		RECEITA_INTRANET.NomeGrupoEconomicoFatura,

		CASE WHEN (RECEITA_STARSOFT.TotalRevendaAntesComissao = 0)
			THEN 0
			ELSE RECEITA_STARSOFT.TotalRevendaAntesComissao * (1 + RECEITA_STARSOFT.IPI / (RECEITA_STARSOFT.TotalItemNF + isnull(RECEITA_STARSOFT.IPI,0))) * (1 + RECEITA_STARSOFT.IVA / (RECEITA_STARSOFT.TotalItemNF + isnull(RECEITA_STARSOFT.IPI,0))) * RECEITA_STARSOFT.Fator
		END as ReceitaBrutaDescontadaComissao,	 
		( 
			RECEITA_STARSOFT.TotalItemNF - RECEITA_STARSOFT.ICMS - RECEITA_STARSOFT.PIS - RECEITA_STARSOFT.COFINS - IsNull(RECEITA_STARSOFT.IRRF,0) - IsNull(RECEITA_STARSOFT.CSLL,0) - 0 - IsNull(RECEITA_STARSOFT.ProvisaoComissaoRevenda,0) -- ReceitaLiquidaStarSoft 
		) * RECEITA_STARSOFT.Fator
		as ReceitaLiquida,	

		(
			( 
				( RECEITA_STARSOFT.TotalItemNF - RECEITA_STARSOFT.ICMS - RECEITA_STARSOFT.PIS - RECEITA_STARSOFT.COFINS - IsNull(RECEITA_STARSOFT.IRRF,0) - IsNull(RECEITA_STARSOFT.CSLL,0) - 0 - IsNull(RECEITA_STARSOFT.ProvisaoComissaoRevenda,0) ) -- ReceitaLiquidaStarSoft 
				+ 
				( ISNULL(RECEITA_INTRANET.UnitClaimAmount,0) * RECEITA_STARSOFT.Qtd * RECEITA_STARSOFT.USDRate) -- ExtendedClaimAmount Convertido
			) -- Receita Liquida
			- RECEITA_STARSOFT.CustoMedioTotal 
		) * RECEITA_STARSOFT.Fator as LucroVenda,

		RECEITA_INTRANET.NetAccounting as NetAccounting,		

		case when RECEITA_INTRANET.NetAccounting = 'Yes'
		then
			(
				( 
					( RECEITA_STARSOFT.TotalItemNF - RECEITA_STARSOFT.ICMS - RECEITA_STARSOFT.PIS - RECEITA_STARSOFT.COFINS - IsNull(RECEITA_STARSOFT.IRRF,0) - IsNull(RECEITA_STARSOFT.CSLL,0) - 0 - IsNull(RECEITA_STARSOFT.ProvisaoComissaoRevenda,0) ) -- ReceitaLiquidaStarSoft 
					- 
					( ISNULL(RECEITA_INTRANET.UnitClaimAmount,0) * RECEITA_STARSOFT.Qtd * RECEITA_STARSOFT.USDRate) -- ExtendedClaimAmount Convertido
				) -- Receita Liquida
				- RECEITA_STARSOFT.CustoMedioTotal  -- LucroVendaNovo,
			) * RECEITA_STARSOFT.Fator
		else
			( 
				( RECEITA_STARSOFT.TotalItemNF - RECEITA_STARSOFT.ICMS - RECEITA_STARSOFT.PIS - RECEITA_STARSOFT.COFINS - IsNull(RECEITA_STARSOFT.IRRF,0) - IsNull(RECEITA_STARSOFT.CSLL,0) - 0 - IsNull(RECEITA_STARSOFT.ProvisaoComissaoRevenda,0) ) -- ReceitaLiquidaStarSoft 
				- 
				( ISNULL(RECEITA_INTRANET.UnitClaimAmount,0) * RECEITA_STARSOFT.Qtd * RECEITA_STARSOFT.USDRate) -- ExtendedClaimAmount Convertido
			) * RECEITA_STARSOFT.Fator -- ReceitaLiquidaNovo	
		end as NetAccountingRevenue,
		RECEITA_STARSOFT.RevenueType as RevenueType,
		case when 
				(
					case when RECEITA_INTRANET.NetAccounting = 'Yes'
					then
						(
							( 
								( RECEITA_STARSOFT.TotalItemNF - RECEITA_STARSOFT.ICMS - RECEITA_STARSOFT.PIS - RECEITA_STARSOFT.COFINS - IsNull(RECEITA_STARSOFT.IRRF,0) - IsNull(RECEITA_STARSOFT.CSLL,0) - 0 - IsNull(RECEITA_STARSOFT.ProvisaoComissaoRevenda,0) ) -- ReceitaLiquidaStarSoft 
								- 
								( ISNULL(RECEITA_INTRANET.UnitClaimAmount,0) * RECEITA_STARSOFT.Qtd * RECEITA_STARSOFT.USDRate) -- ExtendedClaimAmount Convertido
							) -- Receita Liquida
							- RECEITA_STARSOFT.CustoMedioTotal  -- LucroVendaNovo,
						) * RECEITA_STARSOFT.Fator
					else
						( 
							( RECEITA_STARSOFT.TotalItemNF - RECEITA_STARSOFT.ICMS - RECEITA_STARSOFT.PIS - RECEITA_STARSOFT.COFINS - IsNull(RECEITA_STARSOFT.IRRF,0) - IsNull(RECEITA_STARSOFT.CSLL,0) - 0 - IsNull(RECEITA_STARSOFT.ProvisaoComissaoRevenda,0) ) -- ReceitaLiquidaStarSoft 
							- 
							( ISNULL(RECEITA_INTRANET.UnitClaimAmount,0) * RECEITA_STARSOFT.Qtd * RECEITA_STARSOFT.USDRate) -- ExtendedClaimAmount Convertido
						) * RECEITA_STARSOFT.Fator -- ReceitaLiquidaNovo	
					end		
				) -- NetAccountingRevenue
				= 0
		then
			0
		else
			-- LucroVendaNovo / NetAccountingRevenue
			(
				(
					( 
						( RECEITA_STARSOFT.TotalItemNF - RECEITA_STARSOFT.ICMS - RECEITA_STARSOFT.PIS - RECEITA_STARSOFT.COFINS - IsNull(RECEITA_STARSOFT.IRRF,0) - IsNull(RECEITA_STARSOFT.CSLL,0) - 0 - IsNull(RECEITA_STARSOFT.ProvisaoComissaoRevenda,0) ) -- ReceitaLiquidaStarSoft 
						- 
						( ISNULL(RECEITA_INTRANET.UnitClaimAmount,0) * RECEITA_STARSOFT.Qtd * RECEITA_STARSOFT.USDRate) -- ExtendedClaimAmount Convertido
					) -- Receita Liquida
					- RECEITA_STARSOFT.CustoMedioTotal
				) * RECEITA_STARSOFT.Fator
			)-- LucroVendaNovo				
			/ -- dividido
			(
				case when RECEITA_INTRANET.NetAccounting = 'Yes'
				then
					(
						( 
							( RECEITA_STARSOFT.TotalItemNF - RECEITA_STARSOFT.ICMS - RECEITA_STARSOFT.PIS - RECEITA_STARSOFT.COFINS - IsNull(RECEITA_STARSOFT.IRRF,0) - IsNull(RECEITA_STARSOFT.CSLL,0) - 0 - IsNull(RECEITA_STARSOFT.ProvisaoComissaoRevenda,0) ) -- ReceitaLiquidaStarSoft 
							- 
							( ISNULL(RECEITA_INTRANET.UnitClaimAmount,0) * RECEITA_STARSOFT.Qtd * RECEITA_STARSOFT.USDRate) -- ExtendedClaimAmount Convertido
						) -- Receita Liquida
						- RECEITA_STARSOFT.CustoMedioTotal -- LucroVendaNovo,
					) * RECEITA_STARSOFT.Fator
				else
					( 
						( RECEITA_STARSOFT.TotalItemNF - RECEITA_STARSOFT.ICMS - RECEITA_STARSOFT.PIS - RECEITA_STARSOFT.COFINS - IsNull(RECEITA_STARSOFT.IRRF,0) - IsNull(RECEITA_STARSOFT.CSLL,0) - 0 - IsNull(RECEITA_STARSOFT.ProvisaoComissaoRevenda,0) ) -- ReceitaLiquidaStarSoft 
						- 
						( ISNULL(RECEITA_INTRANET.UnitClaimAmount,0) * RECEITA_STARSOFT.Qtd * RECEITA_STARSOFT.USDRate) -- ExtendedClaimAmount Convertido
					) * RECEITA_STARSOFT.Fator -- ReceitaLiquidaNovo	
				end 
			)
		end as NetMargin,
		RECEITA_INTRANET.MaintenanceOrOther as MaintenanceOrOther,
		(RECEITA_STARSOFT.TotalItemNF + RECEITA_STARSOFT.ICMSST + RECEITA_STARSOFT.IPI) * RECEITA_STARSOFT.Fator AS TotalItemNFComICMSEIPI,
		(RECEITA_STARSOFT.TotalItemNF + RECEITA_STARSOFT.IVA) * RECEITA_STARSOFT.Fator AS TotalItemNFComIVA,
		RECEITA_INTRANET.LoginAccountManager as LoginAccountManager,
		RECEITA_STARSOFT.SalesTax,
		RECEITA_INTRANET.ServiceProvider,
		RTRIM(RECEITA_INTRANET.ServiceProviderCountry),
		RECEITA_INTRANET.CEPEntrega,
		RECEITA_STARSOFT.POEfetiva,
		RECEITA_STARSOFT.InvoiceLineNumber,
		IsNull(RECEITA_INTRANET.CodRegiao,0) as CodRegiao,
		RTRIM(RECEITA_INTRANET.NomeParte),
		RECEITA_INTRANET.CBN,
		CASE WHEN IsNull(RECEITA_INTRANET.SBADiscount, 0) <> 0 AND LOWER(RECEITA_INTRANET.SBAType) = 'frontend'
			THEN RECEITA_INTRANET.SBADiscount * 100 -- SBADiscount
			ELSE 
				CASE WHEN ((IsNUll(RECEITA_INTRANET.CodPedido, 0)) = 0)
				THEN IsNull( (SELECT intranet.GetDiscountPriceByCodERP (RECEITA_STARSOFT.PartNumber, RECEITA_STARSOFT.CodERP)), 0)
				ELSE (RECEITA_INTRANET.DescontoP * 100) 
				END -- StandardPurchaseDiscountPercentage
		END as SOPurchaseDiscountPercent,
		RECEITA_STARSOFT.Complement,
		RECEITA_STARSOFT.J11_Ukey,
		RECEITA_STARSOFT.Intercompany,
		RECEITA_STARSOFT.CustoMedioUnPeso as CustoMedioUnMN,
		RECEITA_STARSOFT.CustoMedioTotalPeso as CustoMedioTotalMN,
		isnull(RECEITA_STARSOFT.VendedorMTK,0) as VendedorMTK, 
		isnull(RECEITA_STARSOFT.ResselerMTK,0) as ResselerMTK,
		RECEITA_INTRANET.ID AS IDINTRANET,
		RECEITA_INTRANET.GDS as GDS,	

		--SCRUM-15091 - inicio
		CASE WHEN
				 RTRIM(CURRENCY) = 'US$' AND (RTRIM(CURRENCY_CIA) = '$' or RTRIM(CURRENCY_CIA) = 'R$' )
					THEN 
						(RECEITA_STARSOFT.ValorUnitarioNF * RECEITA_STARSOFT.Fator)*
						(CASE WHEN TAX1 <> 1 THEN TAX1
							WHEN  USDRATE <> 1 THEN USDRATE
							ELSE TAX2 
						END)
			WHEN
				(RTRIM(CURRENCY_CIA) = '$' or RTRIM(CURRENCY_CIA) = 'R$') AND RTRIM(CURRENCY_CIA) = 'US$' 
					THEN
						(RECEITA_STARSOFT.ValorUnitarioNF * RECEITA_STARSOFT.Fator)/
						(CASE	WHEN TAX1 <> 1 THEN TAX1
							WHEN  USDRATE <> 1 THEN USDRATE
							ELSE TAX2 END)
		
		ELSE
			(RECEITA_STARSOFT.ValorUnitarioNF * RECEITA_STARSOFT.Fator)
	
		END AS [totalitemnf(local currency)]
		,
	
		CASE WHEN
				 RTRIM(CURRENCY) = 'US$' AND (RTRIM(CURRENCY_CIA) = '$' or RTRIM(CURRENCY_CIA) = 'R$' )
					THEN 
						(RECEITA_STARSOFT.TotalItemNF * RECEITA_STARSOFT.Fator)*
						(CASE WHEN TAX1 <> 1 THEN TAX1
							WHEN  USDRATE <> 1 THEN USDRATE
							ELSE TAX2 
						END)
			WHEN
				(RTRIM(CURRENCY_CIA) = '$' or RTRIM(CURRENCY_CIA) = 'R$') AND RTRIM(CURRENCY_CIA) = 'US$' 
					THEN
						(RECEITA_STARSOFT.TotalItemNF  * RECEITA_STARSOFT.Fator)/
						(CASE	WHEN TAX1 <> 1 THEN TAX1
							WHEN  USDRATE <> 1 THEN USDRATE
							ELSE TAX2 END)
		
		ELSE
			(RECEITA_STARSOFT.TotalItemNF * RECEITA_STARSOFT.Fator)
	
		END AS [receitaliquida(local currency)] 
		--SCRUM-15091 - fim
		FROM			StarSoft.fnReceitaProdutosCO(@DATAINI, @DATAFIM)	RECEITA_STARSOFT 
		LEFT JOIN
		(
			SELECT DISTINCT
	
				wcnUsuarioWestcon.CodVendedor, -- não existe nas querys da BIReceita
				wcnUsuarioWestcon.LoginDominio as LoginAccountManager, -- login do vendedor 
				tblUsuario.NomeUsuario as NomeVendedor,
				ISNULL(dbo.tblParte1.Pcr, 0) AS Pcr, -- não existe nas querys da BIReceita
				(ISNULL(ISNULL(ISNULL(tblPropostaCarrinhoParte.SBA, tblPropostaCarrinhoParte.Promocao), tblParteDescontoRegiao.Desconto), 0) / 100) AS Desconto, -- não existe nas querys da BIReceita
				ISNULL(tblParte1.Pcr, 0) AS PcrP, -- não existe nas querys da BIReceita
				(ISNULL(tblParteDescontoRegiao.Desconto, 0)/100) AS DescontoP, -- não existe nas querys da BIReceita
				tblPropostaCarrinhoParte.CodParte as PartNumber, -- não existe nas querys da BIReceita
				tblVendor.NomeVendor AS Fabricante,
				tblParteFamilia.Descricao AS Familia,
				--tblParte1.Tipo AS TipoHwSw,
				--comentado em 23/11/2015 => Thiago/Mauricio/Raulison
				-- motivo: esta function aqui nesse SELECT esta demorando em torno de 20 segundos para executar um SELECT TOP 10
				-- esse problema foi resolvido com o CASE WHEN logo abaixo
				--(SELECT Tipo FROM dbo.GetTipoParte(tblERP.CodERP, tblParte1.CodParte, tblParte1.Tipo, tblPropostaCarrinhoParte.OrigemFaturamento)) as TipoHwSw, 
		
				CASE WHEN (@ERP = 0)
					THEN tblParte1.Tipo
					ELSE IsNUll(tblTipoItemERP.Tipo, tblParte1.Tipo)
				END as TipoHwSw,

				tblParte1.Grupo AS TipoGrupoSw,
				tblParte1.DescrNota, 
				tblForecastTipo.DescrForecastTipo AS OrigemPipeline, 
				tblERP.CodERP as CodERP, 
				ctePedido.CodPedido,
				CONVERT(smalldatetime, ctePedido.DataPedido) AS DataPedido, 
				ISNULL(ctePedido.CodPedoc, ctePedido.NomeProposta) AS CodPedidoRevenda, 
				ctePedido.NomeRevenda, 
				ctePedido.EnderecoRevenda, 
				ctePedido.BairroRevenda, 
				ctePedido.CidadeRevenda, 
				ctePedido.UFRevenda, 
				ctePedido.CEPRevenda, 
				PaisRevenda.NomePais AS PaisRevenda, 
				ISNULL(tblContato.NomeContato, ctePedido.ContatoRevenda) AS ContatoRevenda, 
				ISNULL(tblContato.Email, ctePedido.EmailRevenda) AS EmailRevenda, 
				ISNULL(tblContato.Telefone, ctePedido.TelRevenda) AS TelRevenda, 
				ISNULL(ctePedido.NomeEntrega, ctePedido.NomeRevenda) AS EmpresaEntrega, 
				ISNULL(ctePedido.EnderecoEntrega, ctePedido.EnderecoRevenda) AS EnderecoEntrega, 
				ISNULL(ctePedido.BairroEntrega, ctePedido.BairroRevenda) AS BairroEntrega, 
				ISNULL(ctePedido.CidadeEntrega, ctePedido.CidadeRevenda) AS CidadeEntrega, 
				ISNULL(ctePedido.UFEntrega, ctePedido.UFRevenda) AS UFEntrega, 
				ISNULL(ctePedido.CEPEntrega, ctePedido.CEPRevenda) AS CEPEntrega, 
				tblPaisEntrega.NomePais AS PaisEntrega, 
				ctePedido.EndUser, 
				ctePedido.EnderecoEndUser, 
				'' AS BairroEndUser, 
				ctePedido.CidadeEndUser, 
				ctePedido.UFEndUser, 
				ctePedido.CEPEndUser, 
				ISNULL(tblPaisEndUser.NomePais, '') as PaisEndUser,
				CASE WHEN (IsNUll(tblSBA.Rebate, 0) = 0) THEN 'FrontEnd' ELSE 'BackEnd' END as SBAType, 
				ISNULL(tblSBA.NomeSBA, '') AS SBANumber, 
				ISNULL(tblSBA.Dart, '') as RebateNumber, 
				(IsNull(tblPropostaCarrinhoParte.SBA,0)/100) as SBADiscount, -- campo 82
				0 as SFAOpportunityTrackingNumber, -- FALTA INFORMAÇÃO
		
				CASE WHEN (IsNull(tblPropostaCarrinhoParte.SBA,0) <> 0) AND (IsNUll(tblSBA.Rebate, 0) = 0) -- SBADiscount AND FRONTEND
				THEN ISNULL(tblParte1.Pcr, 0) * (1 - IsNull(tblPropostaCarrinhoParte.SBA,0)/100) -- SBADiscount
				ELSE ISNULL(tblParte1.Pcr, 0) * (1 - (ISNULL(tblParteDescontoRegiao.Desconto, 0) / 100)) -- (Preco) * (1 - Desconto)
				END as UnitPurchasePrice, -- campo 85

				IsNull(tblPO.A36_UKEY,'') as PurchasingCurrency, -- campo 87
		
				CASE WHEN (IsNull(tblPropostaCarrinhoParte.SBA, 0) <> 0) -- SBADiscount
				THEN ISNULL(tblParte1.Pcr,0) * (1 - IsNull(tblPropostaCarrinhoParte.SBA,0)/100) -- (Preco) * (1 - SBADiscount)
				ELSE ISNULL(tblParte1.Pcr,0) * (1 - (ISNULL(tblParteDescontoRegiao.Desconto, 0) / 100)) -- (Preco) * (1 - Desconto)
				END as NetPurchaseUnitCost, -- campo 88
		
				CASE WHEN ((IsNull(tblPropostaCarrinhoParte.SBA, 0) <> 0) AND  (IsNUll(tblSBA.Rebate, 0) <> 0) ) -- SBADiscount AND BACKEND
				THEN (ISNULL(tblParte1.Pcr,0) * (tblPropostaCarrinhoParte.SBA - ISNULL(tblParteDescontoRegiao.Desconto, 0)) / 100) -- (Preco) * (SBA - Desconto)
				ELSE 0
				END as UnitClaimAmount, -- campo 90

				/*CASE WHEN ((IsNull(tblPropostaCarrinhoParte.SBA, 0) <> 0) AND  (IsNUll(tblSBA.Rebate, 0) <> 0) ) -- SBADiscount AND BACKEND
				THEN (ISNULL(tblParte1.Pcr,0) * (tblPropostaCarrinhoParte.SBA - 
												CASE WHEN (ISNULL(tblPropostaCarrinhoPartePo.Desconto, 0) > 0) AND (IsNUll(tblPropostaCarrinhoPartePo.Desconto, 0) <= ISNULL(tblPropostaCarrinhoParte.SBA, 0))
													THEN IsNUll(tblPropostaCarrinhoPartePo.Desconto, 0)
												WHEN (ISNULL(tblParteDescontoRegiao.Desconto, 0) > 0) AND (ISNULL(tblPropostaCarrinhoPartePo.Desconto, 0) = 0) AND (IsNUll(tblParteDescontoRegiao.Desconto, 0) <= ISNULL(tblPropostaCarrinhoParte.SBA, 0))
													THEN ISNULL(tblParteDescontoRegiao.Desconto, 0) 
												ELSE
													ISNULL(tblPropostaCarrinhoParte.SBA, 0) END)/100)
				ELSE 0
				END as UnitClaimAmount, -- campo 90*/
				
				ctePedido.Observacao AS ObservacoesFinais, 
				IsNull(tblERP.NomeERP, '') as NomeERP, 
				tblRegiao.CodRegiao,
				IsNull(tblRegiao.NomeRegiao, '') as NomeRegiao, 
				ISNULL(listaPO.POList, '') AS DistributorToVendorPO, 
				--ISNULL(dbo.ConvertLinesCodPOInColumn(ctePedido.CodCarrinho, tblPropostaCarrinhoParte.CodParte), '') as EffectivePO,
				tblDivisao.NomeDivisao, 
				tblDivisao.CodDivisao, 
				ctePedido.CodProposta, 
				ctePedido.CodCarrinho, 
				tblGrupoEconomicoRevenda.CustomerID as CustomerIdGrupoEconomicoRevenda, 
				tblGrupoEconomicoRevenda.NomeGrupo as NomeGrupoEconomicoRevenda, 
				tblGrupoEconomicoFatura.CustomerID as CustomerIdGrupoEconomicoFatura, 
				tblGrupoEconomicoFatura.NomeGrupo as NomeGrupoEconomicoFatura, 
		
				CASE WHEN (
							(tblParte1.Grupo = '002') OR 
							(tblParte1.Grupo = '009') OR 
							(LOWER(tblVendor.NomeVendor) IN ('cisco', 'cisco br') OR  
							LEFT(tblPropostaCarrinhoParte.CodParte,4) = 'CON-') OR 
							(tblParte1.Grupo ='011')
						  )
					THEN 'Yes' 
					ELSE 'No' 
					END 
				AS NetAccounting, -- campo 109

				--CASE WHEN ((tblParte1.Grupo = '009') OR (LOWER(tblVendor.NomeVendor) = 'cisco' AND LEFT(tblPropostaCarrinhoParte.CodParte,4) = 'CON-')) 
				--	THEN 'Yes' 
				--	ELSE 'No' 
				--	END 
				--AS NetAccounting, -- campo 109

				'Product' as RevenueType, -- campo 110

				CASE WHEN (IsNull(tblParte1.Grupo,0) = 2 OR IsNull(tblParte1.Grupo,0) = 9)
					THEN 'Maintenance'
					ELSE 'Other'
				END as MaintenanceOrOther,
				tblServiceProvider.NomeProvider as ServiceProvider,
				PaisRevenda.NomePais AS ServiceProviderCountry,
				tblParte1.NomeParte,
				ctePedido.CBN,
				tblPropostaCarrinhoParte.Id,
				CASE WHEN (SELECT COUNT(Nome) FROM tblPropostaTag PT (NOLOCK) WHERE PT.CodPedido = ctePedido.CodPedido AND RTRIM(LTRIM(LOWER(Nome))) = 'gds') > 0 THEN 1 ELSE 0 END AS GDS
				--IsNull((SELECT Nome FROM tblPropostaTag PT (NOLOCK) WHERE PT.CodPedido = ctePedido.CodPedido AND RTRIM(LTRIM(LOWER(Nome))) = 'gds'),0) as GDS
			FROM 
				[dbo].[BIDadosPedidosIntranet] ctePedido (NOLOCK)
				INNER JOIN tblRegiao (NOLOCK) ON (ctePedido.CodRegiao = tblRegiao.CodRegiao)
				INNER JOIN tblERP ON (IsNull(tblERP.CodERP,0) = 0 OR tblRegiao.CodERP = tblERP.CodERP)
				INNER JOIN tblPropostaCarrinhoParte (NOLOCK) ON (tblPropostaCarrinhoParte.CodCarrinho = ctePedido.CodCarrinho)
				INNER JOIN tblParte1 (NOLOCK) ON (tblPropostaCarrinhoParte.CodParte = tblParte1.CodParte)
				LEFT OUTER JOIN tblSBA WITH (NOLOCK) ON (tblPropostaCarrinhoParte.CodSBA = tblSBA.CodSBA) AND (tblSBA.CodCarrinho = ctePedido.CodCarrinho)
				INNER JOIN tblParteFamilia (NOLOCK) ON (tblParte1.CodParteFamilia = tblParteFamilia.CodParteFamilia)
				INNER JOIN tblVendor (NOLOCK) ON (tblParte1.CodVendor = tblVendor.CodVendor)
				LEFT OUTER JOIN tblEmpresaRel tblRevenda WITH (NOLOCK) ON (tblRevenda.CodERP = tblERP.CodERP) AND (ctePedido.IdRevenda is not null AND ctePedido.IdRevenda = tblRevenda.Id) OR (ctePedido.IdRevenda is null AND ctePedido.CGCRevenda = tblRevenda.CGC)
				LEFT OUTER JOIN wcnUsuarioWestcon (NOLOCK) ON (ctePedido.CodUsuarioComercial = wcnUsuarioWestcon.IDUsuario)
				LEFT OUTER JOIN tblUsuario (NOLOCK) ON (wcnUsuarioWestcon.IDUsuario = tblUsuario.CodUsuario)
				LEFT OUTER JOIN tblForecast (NOLOCK) ON (ctePedido.CodProposta = tblForecast.CodProposta)
				LEFT OUTER JOIN tblForecastOportunidade (NOLOCK) ON (tblForecast.CodOportunidade = tblForecastOportunidade.CodOportunidade)
				LEFT OUTER JOIN tblForecastTipo (NOLOCK) ON (tblForecastOportunidade.CodForecastTipo = tblForecastTipo.CodForecastTipo)
				--LEFT OUTER JOIN tblGrupoEconomico tblGrupoEconomicoRevenda WITH (NOLOCK) ON (tblGrupoEconomicoRevenda.CustomerID = tblRevenda.CustomerID)
				LEFT OUTER JOIN tblPais PaisRevenda WITH (NoLock) ON (ctePedido.PaisRevenda = PaisRevenda.CodPais)
				LEFT OUTER JOIN tblPais tblPaisEndUser WITH (NoLock) ON ctePedido.PaisEndUser = tblPaisEndUser.CodPais
				LEFT OUTER JOIN tblPais tblPaisEntrega WITH (NoLock) ON ctePedido.PaisEntrega = tblPaisEntrega.CodPais
				--LEFT OUTER JOIN tblEmpresaRel tblFatura WITH (NOLOCK) ON (CASE WHEN (ctePedido.CodCarrinho IS NULL) THEN ctePedido.IDEmpresaFaturamento ELSE ctePedido.IDEmpresaFaturamento END) = tblFatura.ID
				--LEFT OUTER JOIN tblGrupoEconomico tblGrupoEconomicoFatura WITH (NOLOCK) ON tblGrupoEconomicoFatura.CustomerID = tblFatura.CustomerID
				LEFT OUTER JOIN tblGrupoEconomico tblGrupoEconomicoRevenda WITH (NOLOCK) ON (tblGrupoEconomicoRevenda.CustomerID = ctePedido.CustomerIDRevenda)
				--LEFT OUTER JOIN tblPais PaisFatura WITH (NoLock) ON (tblFatura.CodPais = PaisFatura.CodPais)
				LEFT OUTER JOIN tblGrupoEconomico tblGrupoEconomicoFatura WITH (NOLOCK) ON tblGrupoEconomicoFatura.CustomerID = ctePedido.CustomerIdFatura
				LEFT OUTER JOIN tblContato WITH (NOLOCK) ON (ctePedido.IDContato = tblContato.CodContato)
				-- LEFT OUTER JOIN tblMercadoVertical WITH (NOLOCK) ON (tblForecastOportunidade.CodMercadoVertical = tblMercadoVertical.CodMercadoVertical)
				LEFT OUTER JOIN tblServiceProvider WITH (NOLOCK) ON (tblForecastOportunidade.IDServiceProvider = tblServiceProvider.IDProvider)
				LEFT OUTER JOIN tblParteDescontoRegiao WITH (NOLOCK) ON (tblParte1.CodParteDesconto = tblParteDescontoRegiao.CodParteDesconto) AND (tblParteDescontoRegiao.CodRegiao = ctePedido.CodRegiao)
				LEFT OUTER JOIN tblDivisao WITH (NOLOCK) ON ctePedido.CodDivisao = tblDivisao.CodDivisao 
				LEFT OUTER JOIN
					(
						SELECT 
							PCPPO.CodCarrinho,
							PCPPO.CodParte,
							--[dbo].[GetPOListV3-sugestao](PCPPO.CodCarrinho, PCPPO.CodParte, 0) as POList
							[dbo].[GetPOListV2](PCPPO.CodCarrinho, PCPPO.CodParte, 0) as POList
							--'' as POList
						FROM tblPropostaCarrinhoPartePO PCPPO (NOLOCK) 
						INNER JOIN tblPO (NOLOCK) ON PCPPO.CodPO = tblPO.CodPO
						GROUP BY PCPPO.CodCarrinho, PCPPO.CodParte
					) listaPO 
					ON 	tblPropostaCarrinhoParte.CodCarrinho = ListaPO.CodCarrinho 
						and tblPropostaCarrinhoParte.CodParte = listaPO.CodParte 

				LEFT OUTER JOIN tblPropostaCarrinhoPartePo WITH (NOLOCK) ON (listaPO.CodCarrinho is not null AND tblPropostaCarrinhoPartePo.CodCarrinho = ListaPO.CodCarrinho) AND (listaPO.CodParte is not null and tblPropostaCarrinhoPartePo.CodParte = listaPO.CodParte)
				LEFT OUTER JOIN tblPO WITH (NOLOCK) ON (tblPropostaCarrinhoPartePO.CodPO = tblPO.CodPO)
				LEFT OUTER JOIN tblTipoItemERP WITH (NOLOCK) ON tblTipoItemERP.PartNumber = tblParte1.CodParte AND tblTipoItemERP.CodErp = tblERP.CodERP

			--WHERE ctePedido.CodPedido>=150000 and tblRegiao.CodERP = @CodERP AND tblPropostaCarrinhoParte.CodParte='WS-C2960X-48LPS-L'
			--WHERE tblRegiao.CodERP= @CodERP AND ctePedido.CodPedido >= 202257 AND ctePedido.CodPedido <= 321659
			WHERE tblRegiao.CodERP= @ERP  AND ctePedido.CodPedido IN ((select codpedido from StarSoft.fnReceitaProdutosCO(@DATAINI, @DATAFIM) where codpedido is not null
																				group by codpedido))
		)				RECEITA_INTRANET 
		ON				(CONVERT(VARCHAR,RECEITA_INTRANET.CodPedido) = RECEITA_STARSOFT.CodPedido) AND (RECEITA_INTRANET.PartNumber = RECEITA_STARSOFT.PartNumber)  AND (RECEITA_STARSOFT.ID_INTRANET IS NULL OR RECEITA_STARSOFT.ID_INTRANET = RECEITA_INTRANET.ID)
		--LEFT OUTER JOIN starwestcon.dbo.A33 VENDEDOR_STARSOFT  (NoLock)
		--ON				VENDEDOR_STARSOFT.A33_001_C = IsNull(RECEITA_INTRANET.CodVendedor,'NAOENCONTRAR')    
		Where			(@VENDOR = '0' OR ISNULL(RECEITA_INTRANET.Fabricante, RECEITA_STARSOFT.FABRICANTE) = @VENDOR)    

	END
	EXEC [Starsoft].[BiReceitaContabil] @Erp, @DataIni, @DataFim -- Adicionado por Ulisses Marcon - Scrum-15141
END
