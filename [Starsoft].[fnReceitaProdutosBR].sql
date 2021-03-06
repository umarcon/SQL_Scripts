USE [Westcon]
GO
/****** Object:  UserDefinedFunction [Starsoft].[fnReceitaProdutosBR]    Script Date: 13/03/2018 20:28:24 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
--**************************************************************************************
-- Funçao para retornar dados do ssa. ref. notas fiscais de RJ,ES,SP
-- Criado por Peterson Ricardo - StarSoft
--**************************************************************************************


ALTER FUNCTION [Starsoft].[fnReceitaProdutosBR]
(
	@FromYYYYMMDD as DATE,
	@ToYYYYMMDD as DATE,
	@CanceledInvoices int 
)
RETURNS TABLE
AS

/*
- Alterado em 13/03/2018 por Ulisses Marcon
Adicionado os campos CustoMedioUnPeso e CustoMedioTotalPeso
Atividade PRIME-1848

- Alterado em 09/08/2017 por USMARCON
Adicionado o campo ", D04_502_N AS CLOUD" nas sub selects para informar se o produto é de Cloud que será usado na Stored Procedure: 
Starsoft.Reports_AtualizaBI_Receita, conforme atividade: PRIME-916.

- Alterado em 22/05/2017 por CCJunior
Adicionado o campo ", D04_501_N AS MAINTENANCE" nas sub selects para informar se o produto é de Maintenance que será usado na Stored Procedure: 
Starsoft.Reports_AtualizaBI_Receita, conforme atividade: PRIME-902. */

-- Alterado em 24/05/2017 - Peterson Ricardo
-- ref. chamado service now: INC0467589
-- Alterado a criação do campo revenuetype
--  de: 
--  CASE WHEN SUBSTRING(LTRIM(ISNULL(T04.T04_001_C,'')),1,3) = 'S10' THEN 'SERVICE' ELSE 'PRODUCT' END AS RevenueType,
--para: 
--  CASE WHEN J10.J10_002_N = 1 THEN 
--     CASE WHEN SUBSTRING(LTRIM(ISNULL(T04.T04_001_C,'')),1,3) = 'S10' THEN 'SERVICE' ELSE 'PRODUCT' END 
--  ELSE 
--     CASE WHEN SUBSTRING(LTRIM(ISNULL((SELECT T04_001_C FROM StarWestcon.dbo.T04 T04_ORG WHERE T04_ORG.UKEY = (SELECT J11_ORG.T04_UKEY FROM StarWestcon.dbo.J11 J11_ORG WHERE J11_ORG.UKEY = J11_DEV.UKEY)),'')),1,3) = 'S10' THEN 'SERVICE' ELSE 'PRODUCT' END 
--  END AS RevenueType,						

/*
- Alterado em 08/03/17 por Marlon de Oliveira
-- SCRUM-15288 - Ajuste BI_Receita para demonstrar Contratos Microsoft
-- Foram Adicionadas as verificações abaixo no where para trazer apenas as notas que não sejam Microsoft CSP
	J11.I14_UKEY IS NULL and AND J11_DEV.I14_UKEY IS NULL

- Alterado em 23/01/17 por ELCruz
Adicionado as colunas CustoMedioUnUSD e CustoMedioTotalUSD para demonstrar o valor do custo médio unitário e total respectivamente conforme atividade SCRUM-15791


- Alterado em 11/01/17 por ELCruz (INC0454224)
Implementado para somar o valor da partilha do ICMS (DIFAL) junto ao o valor do ICMS


- SCRUM-15463 - 12/12/2016 - Thviotto - Criei um novo parametro @CanceledInvoices que Indica se a consulta retornará também NF Canceladas.

- Alterado em 27/09/16 por ELCruz
Adicionada o union da empresa Afina a pedido do Paulo e Gaucho

- Alterado em 28/06/16 por ELCruz
Adicionado as colunas Fabricante e Familia para efetuar o preenchimento na BIReceita quando a NF do Appl não possuir OV da Intranet associada

- Alterado por Thviotto 06/05/2016 17:59:54 - Solicitação - SCRUM-15091
--Criei o campo Tax

- Alterado em 21/05/15 por ELCruz
Alterado a condição de filtro por empresa para selecionar dados da Tabela de Cálculo do Kardex (D28), pois o cálculo do Kardex para itens de serviço é efetuado pela empresa
Consolidada, dessa forma por ter essa condição esses valores não eram visualizados. (SCRUM-14541)

- Alterado em 14/07/14 por ELCruz
Alteração no preenchimento das colunas CustoMedioUn, CustoMedioTotal, CustoMedioUnPeso e CustoMedioTotalPeso para checar se a NF de Devolução NÃO gerou Movimento
no estoque, pois nesse caso os campos referentes a CM deverão permanecer com valores zerados

- Alterado em 01/07/14 por ELCruz
Alteração na forma de obter o CM das NF de Devolução de Venda para pegar o CM do Movimento da NF que foi devolvida.
Obs: Conversa com Nelio, Andres e Wagner via skype para obter essa conclusão
Alterações nas colunas CustoMedioUn e CustoMedioTotal


alterado em 06/12/13 por ELCruz
Foi adicionada a coluna J11_UKEY para permitir criar uma chave única na tabela BIReceita contendo os campos CODERP, CIA_UKEY, J10_UKEY, J11_UKEY
Foi adicionada a coluna "Intercompany" referente ao cadastro do cliente para facilitar na visualização dos retlatórios
A Coluna "InvoiceLineNumber" foi alterada para retornar a informação exata contida na tabela do applications, pois no applications essa informação é iniciada e inclementada por 5,
porém anteriormente estavámos dividindo essa numeração por 5 para demonstra-la como número sequencial

alterado em 27/11/13 por ELCruz
Foi adicionada a nova coluna chamada COMPLEMENT, que indicará se a nf é complementar. (O CAMPO T04_503_N = 1 INDICA QUE É UM TIPO DE E/S PARA NF COMPLEMENTAR)
Foi alterada a forma de preenchimento de algumas colunas conforme a seguinte regra: 
SE FOR UMA NF DE COMPLEMENTO, DEVO DEIXAR O CAMPO QTD SEMPRE COM O VALOR 1 E OS CAMPOS ValorUnitarioNF E TotalItemNF 
COM O VALOR DA SOMA DOS IMPOSTOS ICMSST E IPI 

alterado em 09/10/13 por ELCruz
Foi adicionada uma nova regra para o campo ProvisaoComissaoRevenda para os casos de NF de devolução, onde deverá ser pego o valor da comissão do item devolvido 
na NF de origem rateado pela qtd faturada do item e esse valor deverá ser multiplicado pela qtd devolvida na NF de Devolução

alterado em 02/10/13 por JMBrasil
adicionando s50.19w8,s60.03w8 e s60.04w8 a pedido do wagner

alterado em 03/09/13 por ELCruz
*Adicionado o Tipo S60.02W8 para a empresa WHSP

Alterado em 05/ago/2013 por JM
*Adicionado o tipo S50.22ES e S01.20W6


Alterado em 02/jul/2013 por JM (SCRUM-3322)
*Adicionado o tipo S50.22ES e S01.20W6

- Alterado em 19-02-2013 para demonstrar o campo RevenueType por ELCruz
* Foi incluído o campo revenueType onde se o tipo de e/s for iniciado por S10 deverá retornar a descrição 'Service', caso contrário 'Product'

- Alterado em 19-02-2013 para contemplar a demonstração do código global da OV por ELCruz
* Foi criada a Função [Westcon].[StarSoft].[FN_GetOVGlobalCode] onde será passado como parâmetro o código da OV no SSA e deverá retornar o Código Global da OV,
usado tanto na intranet quanto no SSA. (Essa função irá preencher o campo CodPedido)

- Alterado em 19-02-2013 a pedido do JM para contemplar as NF de serviços por ELCruz
* Foi adicionado o tipo de e/s para a empresa do ES :'S10.06ES'
* Foram adicionados os tipos de e/s para a empresa de SP: 'S10.10SP','S10.09SP','S10.11SP','S10.01SP','S10.02SP','S10.03SP','S10.04SP','S10.05SP',
'S10.07SP','S10.06SP','S10.16SP','S10.17SP','S10.12SP'
* Foram adicionados os tipos de e/s para a empresa de RJ: 'S10.06ES','S10.02W6','S10.09W6','S10.16W6','S10.05W6','S10.17W6','S10.07W6',
'S10.12W6','S10.04W6','S10.01W6','S10.03W6','S10.11W6'

Alterado em 06/fev/2013 por JM (SCRUM-1063)
*Adicionado o tipo S60.01SP

Alterado em 30/outubro/2012 por JM
*Adicionados os tipos:
s01.22es
s01.23es
s01.99es
s01.99w6

alterado por peterson ricardo em 28/12/2012
inserido as ces para query do ES
S50.01ES
S50.02ES
S50.19ES
S50.21ES
S50.23ES
S52.03ES
S52.03ES
S52.07ES
S52.01ES
E52.04ES
E52.06ES
E52.01ES
E52.06ES



Alterado em 4/julho/2012 por JM
	* adicionado o tipos E02.04W6

Alterado em 2/jun/2012 por JM
	* adicionados os tipos E02.08W6, E02.08ES, E02.09ES


Alterado em 23/mai/2011 por Andrés Irazábal (mudança pequena)
	* adicionado tipo S50.01SP a pedido do Wagner

Alterado em 17/fev/2011 por Andrés Irazábal
	* adicionado o tipo E01.20ES
	
Alterado em 17/fev/2011 por Andrés Irazábal
	* Adicionado A03_UKEY

Alterado em 24/jan/2011 por Andrés Irazábal
	* voltamos atrás com a questão do ICMS-RJ, etc e agora tudo voltou a ser ICMS. ICMS_ST_XX também voltou a ser ICMS_ST.

Alterado no início de janeiro/2011 por Andrés Irazábal.
	* trocados os impostos ICMS pelos impostos ICMS-RJ, ICMS-ES, ICMS-SP de acordo com a origem do faturamento. 
	  mudança realizada pela StarSoft em função do suporte a ICMS-ST. Essa mudança é obsoleta porque depois
	  voltaram atrás.
Alterado em 02/jan/2011 por Andrés Irazábal
	* uma nota foi emitida com tipo S01.95ES com itens DAL-IPI e quantidade zero, onde o único valor maior 
	  que zero era o de IPI. Não influencia na receita e parece ser uma correção de IPI, mas causou o crash do relatório
	  (divisão por zero). Alterei para que a divisão teste se a quantidade é zero e retorne o valor zero.
Alterado em 8-out-2010 por Andrés Irazábal
	* adicionado campo ICMSST
Alterado em 1/jul/2010 por Andrés Irazábal
	* adicionada union para query de entrada manual na empresa WB01 (tipo E02.01W1). Ao fazer isso 
	  percebi que dava erro porque a query passou a ter mais de 256 tabelas. 
	  Resolvi criando a função [fnReceitaProdutosBRentradas] e chamando essa função a partir desta.
Alterado em 2/jun/2010 por Andrés Irazábal
	* Empresa WB01 adicionada
	* As empresas abaixo não foram separadas com owners próprios. Estão compartilhando com o owner dbo. Troquei para dbo até esclarecer.
			Invalid object name 'StarWestcon.WB01.D22'.
			Invalid object name 'StarWestcon.WB01.D28'.
			Invalid object name 'StarWestcon.WB01.D14'.
Alterado em 2/jun/2010 por Andrés Irazábal
	* Campo "EmissaoNF" em Notas de entrada deve ser obtido de J10_014_D e não mais de J10_006_D.
	  J10_014_D corresponde a Data de Entrada no caso de notas de entrada. J10_006_D corresponde a data de entrega.
Alterado em 5/mai/2010 por Andrés Irazábal
	* cálculo total do item alterado para evitar diferença entre valor total no ERP e em BIRelReceitaProduto
Alterado em 1/fev/2010 por Andrés Irazábal
	* adicionados novos tipos a pedido do Wagner (ES e W6)
Alterado em 2/set/2010 por JM
	* adicionados os tipos E02.12ES , S50.02SP, E02.55SP
	
Alterado em 24/sbr/2015 por Thiago Rodrigues
	Incluido as colunas VendorMKT e ResselerMKT 
	
	*/

RETURN
(
	SELECT
		   J07.J07_001_C AS PedidoVenda, 
		   [Westcon].[StarSoft].[FN_GetOVGlobalCode](J07.J07_001_C,2) AS PedidoVendaTrimmed,
		   J10.J10_001_C AS NF,
		   T04.T04_001_C AS TipoES,
		   CASE WHEN J10.J10_002_N = 1 THEN J10.J10_003_D ELSE J10.J10_014_D END AS EmissaoNF, 
			D04.D04_001_C AS PartNumber,
			A03.A03_001_C AS CNPJEmpresaNF,
			A03.A03_003_C AS EmpresaNF,			
			-- SE FOR UMA NF DE COMPLEMENTO, DEVO DEIXAR O CAMPO QTD SEMPRE COM O VALOR 1 E OS CAMPOS ValorUnitarioNF E TotalItemNF 
			-- COM O VALOR DA SOMA DOS IMPOSTOS ICMSST E IPI (O CAMPO T04_503_N = 1 INDICA QUE É UM TIPO DE E/S PARA NF COMPLEMENTAR)
			--SCRUM-15463 - INICIO
			CASE	WHEN 
						J10.J10_032_N = 1 and (rtrim(isnull(D03PAI.D03_002_C,'')) = 'CISCO' or rtrim(isnull(D03PAI.D03_002_C,'')) = 'CISCO BR') 
					THEN 
						(CASE WHEN T04.T04_503_N = 1 THEN 1 ELSE J11.J11_003_B END )*-1 
					ELSE 
						(CASE WHEN T04.T04_503_N = 1 THEN 1 ELSE J11.J11_003_B END) END AS Qtd,
			--SCRUM-15463 - FIM

			CASE WHEN T04.T04_503_N = 1 THEN ISNULL(TabIPI.IPI,0) + ISNULL(TabICMSST.ICMSST,0) ELSE J11.J11_005_B END AS ValorUnitarioNF,
			CASE WHEN T04.T04_503_N = 1 THEN ISNULL(TabIPI.IPI,0) + ISNULL(TabICMSST.ICMSST,0) ELSE J11.J11_006_B END AS TotalItemNF,			
			CASE WHEN (J10.J10_002_N = 1) 
			THEN
				ISNULL(D28.D28_006_B, 0)
			ELSE
				-- SE A NF DE DEV. NAO GEROU ESTOQUE
				CASE WHEN D14.UKEY IS NULL
				THEN
					0
				ELSE			
					ISNULL(D28_DEV.D28_006_B, 0)
				END
			END AS CustoMedioUn,
			--Atividade PRIME-1848 - Inicio
			CASE WHEN (J10.J10_002_N = 1) 
				THEN
					--CASE WHEN RTRIM(LEFT(J10.A36_CODE,3))='US$'  
					--THEN 
						ISNULL(D28.D28_009_B, 0)
					--ELSE 
					--	ISNULL(D28.D28_006_B, 0)
					--END 
				ELSE
					-- SE A NF DE DEV. NAO GEROU ESTOQUE
					CASE WHEN D14.UKEY IS NULL
					THEN
						0
					ELSE				
						--CASE WHEN RTRIM(LEFT(J10.A36_CODE,3))='US$'  
						--THEN 
							ISNULL(D28_DEV.D28_009_B, 0)
						--ELSE 
						--	ISNULL(D28_DEV.D28_006_B, 0)
						--END 	
					END
				END AS CustoMedioUnPeso,
				--Atividade PRIME-1848 - Fim
			CASE WHEN (J10.J10_002_N = 1) 
			THEN
				ISNULL(D28.D28_006_B, 0)
			ELSE
				-- SE A NF DE DEV. NAO GEROU ESTOQUE
				CASE WHEN D14.UKEY IS NULL
				THEN
					0
				ELSE			
					ISNULL(D28_DEV.D28_006_B, 0)
				END
			END * J11.J11_003_B AS CustoMedioTotal,		
			--Atividade PRIME-1848 - Inicio
			CASE WHEN (J10.J10_002_N = 1) 
				THEN
					--CASE WHEN RTRIM(LEFT(J10.A36_CODE,3))='US$'  
					--THEN 
						ISNULL(D28.D28_009_B, 0)
					--ELSE 
					--	ISNULL(D28.D28_006_B, 0)
					--END 
				ELSE
					-- SE A NF DE DEV. NAO GEROU ESTOQUE
					CASE WHEN D14.UKEY IS NULL
					THEN
						0
					ELSE				
						--CASE WHEN RTRIM(LEFT(J10.A36_CODE,3))='US$'  
						--THEN 
							ISNULL(D28_DEV.D28_009_B, 0)
						--ELSE 
						--	ISNULL(D28_DEV.D28_006_B, 0)
						--END 	
					END
				END * J11.J11_003_B AS CustoMedioTotalPeso,	
				--Atividade PRIME-1848 - Fim
			CASE WHEN (J10.J10_002_N = 1) 
			THEN
				ISNULL(D28.D28_009_B, 0)
			ELSE
				-- SE A NF DE DEV. NAO GEROU ESTOQUE
				CASE WHEN D14.UKEY IS NULL
				THEN
					0
				ELSE			
					ISNULL(D28_DEV.D28_009_B, 0)
				END
			END AS CustoMedioUnUSD,
			CASE WHEN (J10.J10_002_N = 1) 
			THEN
				ISNULL(D28.D28_009_B, 0)
			ELSE
				-- SE A NF DE DEV. NAO GEROU ESTOQUE
				CASE WHEN D14.UKEY IS NULL
				THEN
					0
				ELSE			
					ISNULL(D28_DEV.D28_009_B, 0)
				END
			END * J11.J11_003_B AS CustoMedioTotalUSD,		
			CASE WHEN (J10.J10_002_N = 1) THEN ISNULL(J15.J15_002_B,0) ELSE (ISNULL(J15.J15_002_B,0) / J11_DEV.J11_003_B) * J11.J11_003_B END AS ProvisaoComissaoRevenda,
			CASE WHEN T04.T04_001_C='S01.95' OR J11.J11_005_B=0 OR J11.J11_003_B=0 OR T04.T04_503_N = 1
			THEN 
				0 
			ELSE  
				(CASE WHEN (J10.J10_002_N = 1) THEN ISNULL(J15.J15_002_B,0) ELSE (ISNULL(J15.J15_002_B,0) / J11_DEV.J11_003_B) * J11.J11_003_B END / (1 - 0.0925 - ISNULL ((TabICMS.ICMS), 0) / (J11.J11_003_B * J11.J11_005_B)) + J11.J11_003_B * J11.J11_005_B) 
			END AS TotalRevendaAntesComissao, 
			ISNULL(TabICMS.ICMS,0) AS ICMS, 
           	CASE WHEN T04.T04_001_C='S01.20' or T04.T04_001_C='S01.12'
			THEN 
				0 
			ELSE
				ISNULL(TabPIS.PIS,0)  
			END AS PIS,
			CASE WHEN T04.T04_001_C='S01.20' or T04.T04_001_C='S01.12'
			THEN 
				0 
			ELSE
				ISNULL(TabCOFINS.COFINS,0)  
			END AS COFINS, 
			ISNULL(TabIRRF.IRRF,0) AS IRRF, 
			ISNULL(TabCSLL.CSLL,0) AS CSLL,
			ISNULL(TabIPI.IPI,0) AS IPI,
			ISNULL(TabISS.ISS,0) AS ISS,
			ISNULL(TabICMSST.ICMSST,0) AS ICMSST,					
			ISNULL(TabIVA.IVA,0) AS IVA,	
			0 AS SalesTax,					
			A23.A23_002_C AS Estado,
			A24.A24_001_C AS Cidade, 
			isnull(A33.A33_003_C,A33_DEV.A33_003_C) AS VENDEDOR,			 
			isnull(J10_DEV.J10_001_C,'') AS NFDevolvida,
			J10.UKEY as J10_UKEY,
			J10.J09_UKEY,
			J10.CIA_UKEY as CIA_UKEY,
			A03.UKEY as A03_UKEY,
			J10.A36_CODE,
			RTRIM(LEFT(J10.A36_CODE,5)) AS Currency,
		CASE WHEN RTRIM(LEFT(J10.A36_CODE,5)) = RTRIM(LEFT(J07.A36_CODE,5)) OR (J07.UKEY IS NULL AND RTRIM(LEFT(J10.A36_CODE,3)) = 'US$' )
		THEN 
			-- Se a moeda do pedido e nf forem iguais, não tem tx
			1 
		WHEN
			ISNULL(J07.A36_CODE,'') <> '' AND RTRIM(LEFT(J07.A36_CODE,5)) <> 'US$  ' 
		THEN
			-- Se o pedido tiver US$ específico, uso a data de emissão do pedido para buscar a tx
			(
				SELECT TOP 1 A37_002_B 
				FROM StarWestcon.dbo.A37 A37 (NoLock)
				WHERE A36_UKEYA='R$   '
				AND A36_UKEY=LEFT(J07.A36_CODE,5)
				AND A37_001_D= CONVERT(varchar(8),J07.J07_003_D,112)
			) 			
		ELSE
			-- Se não tiver ov para a nf, busco a tx do US$ na data do faturamento
			(
				SELECT TOP 1 A37_002_B 
				FROM StarWestcon.dbo.A37 A37 (NoLock)
				WHERE A36_UKEYA='R$   '
				AND A36_UKEY='US$  '
				AND A37_001_D=J10.J10_003_D
			) 
		END USDRate,
			[Westcon].[StarSoft].[FN_GetOVGlobalCode](J07.J07_001_C,1) AS CodPedido,
			1 AS CodERP,
			(
				RTRIM(LTRIM(A03_005_C)) + -- ENDERECO
				CASE WHEN ISNULL(A03_005_C,'') <> '' THEN ', ' + RTRIM(LTRIM(A03_014_C)) ELSE '' END -- NUMERO
			)AS EnderecoFatura,		
			A03_004_C as BairroFatura,			
			A03_006_C as CEPFatura,
			A22_001_C as PaisFatura,
CASE WHEN J10.J10_002_N = 1 THEN 
    CASE WHEN SUBSTRING(LTRIM(ISNULL(T04.T04_001_C,'')),1,3) = 'S10' THEN 'SERVICE' ELSE 'PRODUCT' END 
 ELSE 
    CASE WHEN SUBSTRING(LTRIM(ISNULL((SELECT T04_001_C FROM StarWestcon.dbo.T04 T04_ORG WHERE T04_ORG.UKEY = (SELECT J11_ORG.T04_UKEY FROM StarWestcon.dbo.J11 J11_ORG WHERE J11_ORG.UKEY = J11_DEV.UKEY)),'')),1,3) = 'S10' THEN 'SERVICE' ELSE 'PRODUCT' END
 
END AS RevenueType,						
			--CASE WHEN SUBSTRING(LTRIM(ISNULL(T04.T04_001_C,'')),1,3) = 'S10' THEN 'SERVICE' ELSE 'PRODUCT' END AS RevenueType,
			[Westcon].[StarSoft].[fnGetPOBillingAtWMS](CASE WHEN J10.J10_002_N = 1 THEN J11.UKEY ELSE J11_DEV.UKEY END) AS POEFETIVA,
			J11.J11_998_C AS InvoiceLineNumber,
		-- Se for devolução de venda o fator será negativo
		CASE WHEN J10.J10_002_N = 1 THEN 1 ELSE -1 END AS FATOR,
		T04.T04_503_N AS COMPLEMENT,
		J11.UKEY AS J11_UKEY,
		CASE A03.A03_504_N WHEN 1 THEN 'No' WHEN 2 THEN 'Intercompany' WHEN 3 THEN 'Related' END AS Intercompany,
		ISNULL(
			(	
			SELECT SUM(J15_002_B) AS J15_002_B
			FROM StarWestcon.dbo.J15 (NOLOCK) 
			WHERE CASE WHEN (J10.J10_002_N = 1) THEN J11.UKEY ELSE J11_DEV.UKEY END = J15.J15_UKEYP AND J15.J15_500_N = 2 -- INDICA QUE É A COMISSÃO DE MKT
		),0) AS VendorMKT, 
		ISNULL(
			(	
			SELECT SUM(J15_002_B) AS J15_002_B
			FROM StarWestcon.dbo.J15 (NOLOCK) 
			WHERE CASE WHEN (J10.J10_002_N = 1) THEN J11.UKEY ELSE J11_DEV.UKEY END = J15.J15_UKEYP AND J15.J15_500_N = 1 -- INDICA QUE É A COMISSÃO DE FIDELIZAÇÃO
		),0) AS ResselerMKT,
		J08.J08_INTRANETUKEY AS ID_INTRANET,
		CASE WHEN J10.J10_046_B=0 THEN 1 ELSE J10.J10_046_B END  AS TAX1,  
		ISNULL((SELECT TOP 1 A37_002_B 
				FROM StarWestcon.dbo.A37 A37 (NOLOCK)
				WHERE A36_UKEYA=(SELECT CIA.A36_UKEY FROM StarWestcon.DBO.CIA (NOLOCK) WHERE CIA.UKEY = J10.CIA_UKEY)
				AND A36_UKEY=LEFT(J10.A36_CODE,5)
				AND A37_001_D= CONVERT(VARCHAR(8),J10.J10_003_D,112)
			),1)  AS TAX2, 
		 (SELECT CIA.A36_UKEY FROM StarWestcon.DBO.CIA (NOLOCK) WHERE CIA.UKEY = J10.CIA_UKEY) AS CURRENCY_CIA,
		 D03PAI.D03_002_C AS FABRICANTE,
		 D03FILHO.D03_002_C AS FAMILIA,
		 D04_501_N AS MAINTENANCE, -- PRIME-902 
		 D04_502_N AS CLOUD --PRIME-916
			
	FROM            StarWestcon.dbo.J10 J10 (NOLOCK) 
	INNER JOIN      StarWestcon.dbo.A03 A03 (NOLOCK) ON J10.A03_UKEY = A03.UKEY 
	INNER JOIN      StarWestcon.dbo.J11 J11 (NOLOCK) ON J10.UKEY = J11.J10_UKEY AND J11.CIA_UKEY = 'STAR_'
	INNER JOIN      StarWestcon.dbo.T04 T04 (NOLOCK) ON J11.T04_UKEY = T04.UKEY 
	INNER JOIN      StarWestcon.dbo.D04 D04 (NOLOCK) ON J11.D04_UKEY = D04.UKEY 
	LEFT JOIN       StarWestcon.dbo.D03 D03FILHO (NOLOCK) ON D04.D03_UKEY = D03FILHO.UKEY 
	LEFT JOIN       StarWestcon.dbo.D03 D03PAI (NOLOCK) ON D03FILHO.D03_UKEY = D03PAI.UKEY 
	LEFT OUTER JOIN StarWestcon.dbo.D22 D22 (NOLOCK) ON J11.UKEY = D22.D22_IUKEYP  AND D22.CIA_UKEY = 'STAR_'
	LEFT OUTER JOIN StarWestcon.dbo.D28 D28 (NOLOCK) ON D22.UKEY = D28.D28_UKEYP  -- AND D28.CIA_UKEY = 'STAR_'
	LEFT OUTER JOIN StarWestcon.dbo.D14 D14 (NOLOCK) ON J11.UKEY = D14.D14_IUKEYP  AND D14.CIA_UKEY = 'STAR_'
	LEFT OUTER JOIN StarWestcon.dbo.D28 D28_1 (NOLOCK) ON D14.UKEY = D28_1.D28_UKEYP  -- AND D28_1.CIA_UKEY = 'STAR_'
	LEFT OUTER JOIN StarWestcon.dbo.J11 J11_DEV (nolock) ON J11.J11_UKEYP = J11_DEV.UKEY  AND J11_DEV.CIA_UKEY = 'STAR_'
	LEFT OUTER JOIN StarWestcon.dbo.D22 D22_DEV WITH (NOLOCK) ON J11_DEV.UKEY = D22_DEV.D22_IUKEYP
	LEFT OUTER JOIN StarWestcon.dbo.D28 D28_DEV WITH (NOLOCK) ON D22_DEV.UKEY = D28_DEV.D28_UKEYP 		
	LEFT OUTER JOIN StarWestcon.dbo.J10 J10_DEV (nolock) ON J11_DEV.J10_UKEY = J10_DEV.UKEY  AND J10_DEV.CIA_UKEY = 'STAR_'
	LEFT OUTER JOIN StarWestcon.dbo.A33 A33_DEV (NOLOCK) ON J10_DEV.A33_UKEY = A33_DEV.UKEY	
			--SCRUM-15463 - INICIO
	LEFT OUTER JOIN StarWestcon.dbo.J08 J08 (NOLOCK) ON 
													CASE 
														WHEN (J11.J08_UKEYWE <> '' AND @CanceledInvoices = 1) 
															THEN 'J08' 
														WHEN (J10.J10_002_N = 1) 
															THEN J11.J11_PAR 
															ELSE J11_DEV.J11_PAR END
														 ='J08' and 
													CASE 
														WHEN (J11.J08_UKEYWE <> '' AND @CanceledInvoices = 1) 
															THEN J11.J08_UKEYWE 
														WHEN (J10.J10_002_N = 1) 
															THEN J11.J11_UKEYP 
															ELSE J11_DEV.J11_UKEYP END
													 =J08.UKEY AND J08.CIA_UKEY = 'STAR_'
	--SCRUM-15463 - FIM

	LEFT OUTER JOIN StarWestcon.dbo.J07 J07 (NOLOCK) ON J08.J07_UKEY=J07.UKEY AND J07.CIA_UKEY = 'STAR_'
	LEFT OUTER JOIN (	
						SELECT SUM(J15_002_B) AS J15_002_B,  J15.J15_UKEYP
						FROM StarWestcon.dbo.J15 (NOLOCK) 
						WHERE J15.J15_500_N = 0 -- INDICA QUE É A COMISSÃO DA NF E NÃO É UMA COMISSO DE MKT NEM FIDELIZAÇÃO
						GROUP BY  J15.J15_UKEYP
					) J15 ON CASE WHEN (J10.J10_002_N = 1) THEN J11.UKEY ELSE J11_DEV.UKEY END = J15.J15_UKEYP 
	LEFT OUTER JOIN StarWestcon.dbo.A22 A22 (NOLOCK) ON A03.A22_UKEY = A22.UKEY 					  
	LEFT OUTER JOIN StarWestcon.dbo.A23 A23 (NOLOCK) ON A03.A23_UKEY = A23.UKEY
	LEFT OUTER JOIN StarWestcon.dbo.A24 A24 (NOLOCK) ON A03.A24_UKEY = A24.UKEY 	
	LEFT OUTER JOIN StarWestcon.dbo.A33 A33 (NOLOCK) ON J10.A33_UKEY = A33.UKEY 
	LEFT OUTER JOIN	(	
						SELECT J22.J22_UKEYP,SUM(ISNULL(J22.J22_004_B + J22.J22_049_B + J22.J22_050_B,0)) AS ICMS
						FROM StarWestcon.dbo.J22 J22 (NOLOCK)
						WHERE J22.A40_UKEY=(select UKEY FROM StarWestcon.dbo.A40 A40 (NOLOCK) WHERE A40.A40_001_C='ICMS') AND J22.CIA_UKEY = 'STAR_'
						GROUP BY J22.J22_UKEYP
					) TabICMS ON J11.UKEY=TabICMS.J22_UKEYP
	LEFT OUTER JOIN	(
						SELECT J22.J22_UKEYP,SUM(ISNULL(J22.J22_004_B,0)) AS IPI
						FROM StarWestcon.dbo.J22 J22 (NOLOCK)
						WHERE J22.A40_UKEY=(select UKEY FROM StarWestcon.dbo.A40 A40 (NOLOCK) WHERE A40.A40_001_C='IPI') AND J22.CIA_UKEY = 'STAR_'
						GROUP BY J22.J22_UKEYP
					) TabIPI ON J11.UKEY=TabIPI.J22_UKEYP
	LEFT OUTER JOIN	(
						SELECT J22.J22_UKEYP,SUM(ISNULL(J22.J22_004_B,0)) AS IRRF
						FROM StarWestcon.dbo.J22 J22 (NOLOCK)
						WHERE J22.A40_UKEY=(select UKEY FROM StarWestcon.dbo.A40 A40 (NOLOCK) WHERE A40.A40_001_C='IRRF') AND J22.CIA_UKEY = 'STAR_'
						GROUP BY J22.J22_UKEYP
					) TabIRRF ON J11.UKEY=TabIRRF.J22_UKEYP
	LEFT OUTER JOIN	(
						SELECT J22.J22_UKEYP,SUM(ISNULL(J22.J22_004_B,0)) AS CSLL
						FROM StarWestcon.dbo.J22 J22 (NOLOCK)
						WHERE J22.A40_UKEY=(select UKEY FROM StarWestcon.dbo.A40 A40 (NOLOCK) WHERE A40.A40_001_C='CSLL') AND J22.CIA_UKEY = 'STAR_'
						GROUP BY J22.J22_UKEYP
					) TabCSLL ON J11.UKEY=TabCSLL.J22_UKEYP
	LEFT OUTER JOIN	(
						SELECT J22.J22_UKEYP,SUM(ISNULL(J22.J22_004_B,0)) AS ICMSST
						FROM StarWestcon.dbo.J22 J22 (NOLOCK)
						WHERE J22.A40_UKEY=(select UKEY FROM StarWestcon.dbo.A40 A40 (NOLOCK) WHERE A40.A40_001_C='ICMS_ST') AND J22.CIA_UKEY = 'STAR_'
						GROUP BY J22.J22_UKEYP
					) TabICMSST ON J11.UKEY=TabICMSST.J22_UKEYP	
	LEFT OUTER JOIN	(
						SELECT J22.J22_UKEYP,SUM(ISNULL(J22.J22_004_B,0)) AS IVA
						FROM StarWestcon.dbo.J22 J22 (NOLOCK)
						WHERE J22.A40_UKEY=(select UKEY FROM StarWestcon.dbo.A40 A40 (NOLOCK) WHERE A40.A40_001_C='IVA') AND J22.CIA_UKEY = 'STAR_'
						GROUP BY J22.J22_UKEYP
					) TabIVA ON J11.UKEY=TabIVA.J22_UKEYP	
	LEFT OUTER JOIN	(
						SELECT J22.J22_UKEYP,SUM(ISNULL(J22.J22_004_B,0)) AS PIS
						FROM StarWestcon.dbo.J22 J22 (NOLOCK)
						WHERE J22.A40_UKEY=(select UKEY FROM StarWestcon.dbo.A40 A40 (NOLOCK) WHERE A40.A40_001_C='PIS')
						GROUP BY J22.J22_UKEYP
					) TabPIS ON J11.UKEY=TabPIS.J22_UKEYP	
	LEFT OUTER JOIN	(
						SELECT J22.J22_UKEYP,SUM(ISNULL(J22.J22_004_B,0)) AS COFINS
						FROM StarWestcon.dbo.J22 J22 (NOLOCK)
						WHERE J22.A40_UKEY=(select UKEY FROM StarWestcon.dbo.A40 A40 (NOLOCK) WHERE A40.A40_001_C='COFINS')
						GROUP BY J22.J22_UKEYP
					) TabCOFINS ON J11.UKEY=TabCOFINS.J22_UKEYP	
	LEFT OUTER JOIN	(
						SELECT J22.J22_UKEYP,SUM(ISNULL(J22.J22_004_B,0)) AS ISS
						FROM StarWestcon.dbo.J22 J22 (NOLOCK)
						WHERE J22.A40_UKEY=(select UKEY FROM StarWestcon.dbo.A40 A40 (NOLOCK) WHERE A40.A40_001_C='ISS')
						GROUP BY J22.J22_UKEYP
					) TabISS ON J11.UKEY=TabISS.J22_UKEYP																													
	WHERE 
			-- Ukey da Empresa
			J10.CIA_UKEY = 'STAR_' AND
			-- Se for NF pesquisa pela emissao, se for Dev. NF pesquisa pela data de entrada
			CASE WHEN J10.J10_002_N = 1 
			THEN 
				J10.J10_003_D 
			ELSE J10.J10_014_D END BETWEEN @FromYYYYMMDD AND @ToYYYYMMDD AND--CONVERT(DATETIME, @FromYYYYMMDD + ' 00:00:00', 102) AND CONVERT(DATETIME, @ToYYYYMMDD + ' 23:59:59', 102) AND
			-- NF não pode estar cancelada 
			--SCRUM-15463 - inicio
			((@CanceledInvoices= 0 and J10.J10_032_N = 0) or (@CanceledInvoices= 1 and J10.J10_032_N = 1 and   cast(isnull(j10.j10_111_t,j10.timestamp) as date) <> cast(isnull(j10.j10_003_d,'') as date) ) ) AND 
			--SCRUM-15463 - fim
			-- Tipos de E/S que devem ser relacionados
			T04_501_N = 1
			AND J10.Array_736 <> 1 
			AND J11.I14_UKEY IS NULL 
			AND J11_DEV.I14_UKEY IS NULL
			--T04.T04_001_C IN (
			--					'S01.01','S01.02','S01.05','S01.06','S01.09','S01.10','S01.12','S01.19','S01.20','S01.21','S01.22RJ',
			--					'S01.94RJ','S01.95','S01.98','S01.99','S02.03','S02.04','S02.06','E02.01','E02.06RJ','E02.98RJ'
			--				)
	UNION ALL
	-- PARTE 2: ESPIRITO SANTO
	SELECT     J07.J07_001_C AS PedidoVenda, 
			   [Westcon].[StarSoft].[FN_GetOVGlobalCode](J07.J07_001_C,2) AS PedidoVendaTrimmed,
			   J10.J10_001_C AS NF,
			   T04.T04_001_C AS TipoES,
			   CONVERT(smalldatetime, CASE WHEN (J10.J10_002_N <> 2 AND T04.T04_001_C <> 'E90.04') 
										   THEN J10.J10_003_D 
										   ELSE J10.J10_014_D END) AS EmissaoNF, 
		D04.D04_001_C AS PartNumber,
		A03.A03_001_C AS CNPJEmpresaNF,
		A03.A03_003_C AS EmpresaNF,
		-- SE FOR UMA NF DE COMPLEMENTO, DEVO DEIXAR O CAMPO QTD SEMPRE COM O VALOR 1 E OS CAMPOS ValorUnitarioNF E TotalItemNF 
		-- COM O VALOR DA SOMA DOS IMPOSTOS ICMSST E IPI (O CAMPO T04_503_N = 1 INDICA QUE É UM TIPO DE E/S PARA NF COMPLEMENTAR)
		--SCRUM-15463 - INICIO
		CASE WHEN J10.J10_032_N = 1  and (rtrim(isnull(D03PAI.D03_002_C,'')) = 'CISCO' or rtrim(isnull(D03PAI.D03_002_C,'')) = 'CISCO BR') THEN (CASE WHEN T04.T04_503_N = 1 THEN 1 ELSE J11.J11_003_B END )*-1 ELSE (CASE WHEN T04.T04_503_N = 1 THEN 1 ELSE J11.J11_003_B END) END AS Qtd,
		--SCRUM-15463 - FIM
		CASE WHEN T04.T04_503_N = 1 THEN ISNULL(TabIPI.IPI,0) + ISNULL(TabICMSST.ICMSST,0) ELSE J11.J11_005_B END AS ValorUnitarioNF,
		CASE WHEN T04.T04_503_N = 1 THEN ISNULL(TabIPI.IPI,0) + ISNULL(TabICMSST.ICMSST,0) ELSE J11.J11_006_B END AS TotalItemNF,				
		CASE WHEN (J10.J10_002_N = 1) 
		THEN
			ISNULL(D28.D28_006_B, 0)
		ELSE
			-- SE A NF DE DEV. NAO GEROU ESTOQUE
			CASE WHEN D14.UKEY IS NULL
			THEN
				0
			ELSE			
				ISNULL(D28_DEV.D28_006_B, 0)
			END
		END AS CustoMedioUn,
		--Atividade PRIME-1848 - Inicio
		CASE WHEN (J10.J10_002_N = 1) 
				THEN
					--CASE WHEN RTRIM(LEFT(J10.A36_CODE,3))='US$'  
					--THEN 
						ISNULL(D28.D28_009_B, 0)
					--ELSE 
					--	ISNULL(D28.D28_006_B, 0)
					--END 
				ELSE
					-- SE A NF DE DEV. NAO GEROU ESTOQUE
					CASE WHEN D14.UKEY IS NULL
					THEN
						0
					ELSE				
						--CASE WHEN RTRIM(LEFT(J10.A36_CODE,3))='US$'  
						--THEN 
							ISNULL(D28_DEV.D28_009_B, 0)
						--ELSE 
						--	ISNULL(D28_DEV.D28_006_B, 0)
						--END 	
					END
				END AS CustoMedioUnPeso,
				--Atividade PRIME-1848 - Fim
			CASE WHEN (J10.J10_002_N = 1) 
			THEN
				ISNULL(D28.D28_006_B, 0)
			ELSE
				-- SE A NF DE DEV. NAO GEROU ESTOQUE
				CASE WHEN D14.UKEY IS NULL
				THEN
					0
				ELSE			
					ISNULL(D28_DEV.D28_006_B, 0)
				END
			END * J11.J11_003_B AS CustoMedioTotal,	
			--Atividade PRIME-1848 - Inicio	
			CASE WHEN (J10.J10_002_N = 1) 
				THEN
					--CASE WHEN RTRIM(LEFT(J10.A36_CODE,3))='US$'  
					--THEN 
						ISNULL(D28.D28_009_B, 0)
					--ELSE 
					--	ISNULL(D28.D28_006_B, 0)
					--END 
				ELSE
					-- SE A NF DE DEV. NAO GEROU ESTOQUE
					CASE WHEN D14.UKEY IS NULL
					THEN
						0
					ELSE				
						--CASE WHEN RTRIM(LEFT(J10.A36_CODE,3))='US$'  
						--THEN 
							ISNULL(D28_DEV.D28_009_B, 0)
						--ELSE 
						--	ISNULL(D28_DEV.D28_006_B, 0)
						--END 	
					END
				END * J11.J11_003_B AS CustoMedioTotalPeso,	
				--Atividade PRIME-1848 - Fim			
			CASE WHEN (J10.J10_002_N = 1) 
			THEN
				ISNULL(D28.D28_009_B, 0)
			ELSE
				-- SE A NF DE DEV. NAO GEROU ESTOQUE
				CASE WHEN D14.UKEY IS NULL
				THEN
					0
				ELSE			
					ISNULL(D28_DEV.D28_009_B, 0)
				END
			END AS CustoMedioUnUSD,
			CASE WHEN (J10.J10_002_N = 1) 
			THEN
				ISNULL(D28.D28_009_B, 0)
			ELSE
				-- SE A NF DE DEV. NAO GEROU ESTOQUE
				CASE WHEN D14.UKEY IS NULL
				THEN
					0
				ELSE			
					ISNULL(D28_DEV.D28_009_B, 0)
				END
			END * J11.J11_003_B AS CustoMedioTotalUSD,		
			CASE WHEN (J10.J10_002_N = 1) THEN ISNULL(J15.J15_002_B,0) ELSE (ISNULL(J15.J15_002_B,0) / J11_DEV.J11_003_B) * J11.J11_003_B END AS ProvisaoComissaoRevenda,
			 CASE WHEN T04.T04_001_C='S01.95' OR J11.J11_005_B=0 OR J11.J11_003_B=0 OR T04.T04_503_N = 1
			 THEN 
				0 
			ELSE  
				(CASE WHEN (J10.J10_002_N = 1) THEN ISNULL(J15.J15_002_B,0) ELSE (ISNULL(J15.J15_002_B,0) / J11_DEV.J11_003_B) * J11.J11_003_B END / (1 - 0.0925 - ISNULL ((TabICMS.ICMS), 0) / (J11.J11_003_B * J11.J11_005_B)) + J11.J11_003_B * J11.J11_005_B) 
			END AS TotalRevendaAntesComissao, 
			ISNULL(TabICMS.ICMS,0) AS ICMS, 
			CASE WHEN T04.T04_001_C IN ('S01.20ES','S01.12ES','E02.12ES') -- adicionado 02-set-2011 a pedido do wagner por JM
			THEN 
				0 
			ELSE
				ISNULL(TabPIS.PIS,0)  
			END AS PIS,
			CASE WHEN T04.T04_001_C IN ('S01.20ES','S01.12ES','E02.12ES') -- adicionado 02-set-2011 a pedido do wagner por JM
			THEN 
				0 
			ELSE 
				ISNULL(TabCOFINS.COFINS,0) 
			END AS COFINS, 
			ISNULL(TabIRRF.IRRF,0) AS IRRF, 
			ISNULL(TabCSLL.CSLL,0) AS CSLL,
			ISNULL(TabIPI.IPI,0) AS IPI,
			ISNULL(TabISS.ISS,0) AS ISS,
			ISNULL(TabICMSST.ICMSST,0) AS ICMSST,
			ISNULL(TabIVA.IVA,0) AS IVA,	
			0 AS SalesTax,					
		   A23.A23_002_C AS Estado,
		   A24.A24_001_C AS Cidade, 
		   isnull(A33.A33_003_C,A33_DEV.A33_003_C) AS VENDEDOR,
		isnull(J10_DEV.J10_001_C,'') AS NFDevolvida,
		J10.UKEY as J10_UKEY,
		J10.J09_UKEY,
		J10.CIA_UKEY as CIA_UKEY,
		A03.UKEY as A03_UKEY,
		J10.A36_CODE,
		RTRIM(LEFT(J10.A36_CODE,5)) AS Currency,
		CASE WHEN RTRIM(LEFT(J10.A36_CODE,5)) = RTRIM(LEFT(J07.A36_CODE,5))
		THEN 
			-- Se a moeda do pedido e nf forem iguais, não tem tx
			1 
		WHEN
			ISNULL(J07.A36_CODE,'') <> '' AND RTRIM(LEFT(J07.A36_CODE,5)) <> 'US$  ' 
		THEN
			-- Se o pedido tiver US$ específico, uso a data de emissão do pedido para buscar a tx
			(
				SELECT TOP 1 A37_002_B 
				FROM StarWestcon.dbo.A37 A37 (NoLock)
				WHERE A36_UKEYA='R$   '
				AND A36_UKEY=LEFT(J07.A36_CODE,5)
				AND A37_001_D= CONVERT(varchar(8),J07.J07_003_D,112)
			) 			
		ELSE
			-- Se não tiver ov para a nf, busco a tx do US$ na data do faturamento
			(
				SELECT TOP 1 A37_002_B 
				FROM StarWestcon.dbo.A37 A37 (NoLock)
				WHERE A36_UKEYA='R$   '
				AND A36_UKEY='US$  '
				AND A37_001_D=J10.J10_003_D
			) 
		END USDRate,
			[Westcon].[StarSoft].[FN_GetOVGlobalCode](J07.J07_001_C,1) AS CodPedido,
			1 AS CodERP,
			(
				RTRIM(LTRIM(A03_005_C)) + -- ENDERECO
				CASE WHEN ISNULL(A03_005_C,'') <> '' THEN ', ' + RTRIM(LTRIM(A03_014_C)) ELSE '' END -- NUMERO
			)AS EnderecoFatura,	
			A03_004_C as BairroFatura,			
			A03_006_C as CEPFatura,
			A22_001_C as PaisFatura,
CASE WHEN J10.J10_002_N = 1 THEN 
    CASE WHEN SUBSTRING(LTRIM(ISNULL(T04.T04_001_C,'')),1,3) = 'S10' THEN 'SERVICE' ELSE 'PRODUCT' END 
 ELSE 
    CASE WHEN SUBSTRING(LTRIM(ISNULL((SELECT T04_001_C FROM StarWestcon.dbo.T04 T04_ORG WHERE T04_ORG.UKEY = (SELECT J11_ORG.T04_UKEY FROM StarWestcon.dbo.J11 J11_ORG WHERE J11_ORG.UKEY = J11_DEV.UKEY)),'')),1,3) = 'S10' THEN 'SERVICE' ELSE 'PRODUCT' END 

END AS RevenueType,	
			---CASE WHEN SUBSTRING(LTRIM(ISNULL(T04.T04_001_C,'')),1,3) = 'S10' THEN 'SERVICE' ELSE 'PRODUCT' END AS RevenueType,
			[Westcon].[StarSoft].[fnGetPOBillingAtWMS](CASE WHEN J10.J10_002_N = 1 THEN J11.UKEY ELSE J11_DEV.UKEY END) AS POEFETIVA,
			J11.J11_998_C AS InvoiceLineNumber,
		-- Se for devolução de venda o fator será negativo
		CASE WHEN J10.J10_002_N = 1 AND T04.T04_001_C <> 'E90.04' THEN 1 ELSE -1 END AS FATOR,
		T04.T04_503_N AS COMPLEMENT,
		J11.UKEY AS J11_UKEY,
		CASE A03.A03_504_N WHEN 1 THEN 'No' WHEN 2 THEN 'Intercompany' WHEN 3 THEN 'Related' END AS Intercompany,
		ISNULL(
			(	
			SELECT SUM(J15_002_B) AS J15_002_B
			FROM StarWestcon.dbo.J15 (NOLOCK) 
			WHERE CASE WHEN (J10.J10_002_N = 1) THEN J11.UKEY ELSE J11_DEV.UKEY END = J15.J15_UKEYP AND J15.J15_500_N = 2 -- INDICA QUE É A COMISSÃO DE MKT
		),0) AS VendorMKT, 
		ISNULL(
			(	
			SELECT SUM(J15_002_B) AS J15_002_B
			FROM StarWestcon.dbo.J15 (NOLOCK) 
			WHERE CASE WHEN (J10.J10_002_N = 1) THEN J11.UKEY ELSE J11_DEV.UKEY END = J15.J15_UKEYP AND J15.J15_500_N = 1 -- INDICA QUE É A COMISSÃO DE FIDELIZAÇÃO
		),0) AS ResselerMKT,
			J08.J08_INTRANETUKEY AS ID_INTRANET,
		CASE WHEN J10.J10_046_B=0 THEN 1 ELSE J10.J10_046_B END  AS TAX1,  
		ISNULL((SELECT TOP 1 A37_002_B 
				FROM StarWestcon.dbo.A37 A37 (NOLOCK)
				WHERE A36_UKEYA=(SELECT CIA.A36_UKEY FROM StarWestcon.DBO.CIA (NOLOCK) WHERE CIA.UKEY = J10.CIA_UKEY)
				AND A36_UKEY=LEFT(J10.A36_CODE,5)
				AND A37_001_D= CONVERT(VARCHAR(8),J10.J10_003_D,112)
			),1)  AS TAX2, 
		 (SELECT CIA.A36_UKEY FROM StarWestcon.DBO.CIA (NOLOCK) WHERE CIA.UKEY = J10.CIA_UKEY) AS CURRENCY_CIA,
		 D03PAI.D03_002_C AS FABRICANTE,
		 D03FILHO.D03_002_C AS FAMILIA,
		 D04_501_N AS MAINTENANCE, -- PRIME-902 
		 D04_502_N AS CLOUD --PRIME-916
	FROM            StarWestcon.dbo.J10 J10 (NOLOCK) 
	INNER JOIN      StarWestcon.dbo.A03 A03 (NOLOCK) ON J10.A03_UKEY = A03.UKEY 
	INNER JOIN      StarWestcon.dbo.J11 J11 (NOLOCK) ON J10.UKEY = J11.J10_UKEY AND J11.CIA_UKEY = 'MDQJW'
	INNER JOIN      StarWestcon.dbo.T04 T04 (NOLOCK) ON J11.T04_UKEY = T04.UKEY 
	INNER JOIN      StarWestcon.dbo.D04 D04 (NOLOCK) ON J11.D04_UKEY = D04.UKEY 
	LEFT JOIN       StarWestcon.dbo.D03 D03FILHO (NOLOCK) ON D04.D03_UKEY = D03FILHO.UKEY 
	LEFT JOIN       StarWestcon.dbo.D03 D03PAI (NOLOCK) ON D03FILHO.D03_UKEY = D03PAI.UKEY 
	LEFT OUTER JOIN StarWestcon.dbo.D22 D22 (NOLOCK) ON J11.UKEY = D22.D22_IUKEYP AND D22.CIA_UKEY = 'MDQJW'
	LEFT OUTER JOIN StarWestcon.dbo.D28 D28 (NOLOCK) ON D22.UKEY = D28.D28_UKEYP -- AND D28.CIA_UKEY = 'MDQJW'
	LEFT OUTER JOIN StarWestcon.dbo.D14 D14 (NOLOCK) ON J11.UKEY = D14.D14_IUKEYP AND D14.CIA_UKEY = 'MDQJW'
	LEFT OUTER JOIN StarWestcon.dbo.D28 D28_1 (NOLOCK) ON D14.UKEY = D28_1.D28_UKEYP -- AND D28_1.CIA_UKEY = 'MDQJW'
	LEFT OUTER JOIN StarWestcon.dbo.J11 J11_DEV (nolock) ON J11.J11_UKEYP = J11_DEV.UKEY AND J11_DEV.CIA_UKEY = 'MDQJW'
	LEFT OUTER JOIN StarWestcon.dbo.D22 D22_DEV WITH (NOLOCK) ON J11_DEV.UKEY = D22_DEV.D22_IUKEYP
	LEFT OUTER JOIN StarWestcon.dbo.D28 D28_DEV WITH (NOLOCK) ON D22_DEV.UKEY = D28_DEV.D28_UKEYP 		
	LEFT OUTER JOIN StarWestcon.dbo.J10 J10_DEV (nolock) ON J11_DEV.J10_UKEY = J10_DEV.UKEY AND J10_DEV.CIA_UKEY = 'MDQJW'
	LEFT OUTER JOIN StarWestcon.dbo.A33 A33_DEV (NOLOCK) ON J10_DEV.A33_UKEY = A33_DEV.UKEY
			--SCRUM-15463 - INICIO
	LEFT OUTER JOIN StarWestcon.dbo.J08 J08 (NOLOCK) ON 
													CASE 
														WHEN (J11.J08_UKEYWE <> '' AND @CanceledInvoices = 1) 
															THEN 'J08' 
														WHEN (J10.J10_002_N = 1) 
															THEN J11.J11_PAR 
															ELSE J11_DEV.J11_PAR END
														 ='J08' and 
													CASE 
														WHEN (J11.J08_UKEYWE <> '' AND @CanceledInvoices = 1) 
															THEN J11.J08_UKEYWE 
														WHEN (J10.J10_002_N = 1) 
															THEN J11.J11_UKEYP 
															ELSE J11_DEV.J11_UKEYP END
													 =J08.UKEY AND J08.CIA_UKEY = 'MDQJW'
	--SCRUM-15463 - FIM

	LEFT OUTER JOIN StarWestcon.dbo.J07 J07 (NOLOCK) ON J08.J07_UKEY=J07.UKEY AND J07.CIA_UKEY = 'MDQJW'
	LEFT OUTER JOIN (	
						SELECT SUM(J15_002_B) AS J15_002_B,  J15.J15_UKEYP
						FROM StarWestcon.dbo.J15 (NOLOCK) 
						WHERE J15.J15_500_N = 0 -- INDICA QUE É A COMISSÃO DA NF E NÃO É UMA COMISSO DE MKT NEM FIDELIZAÇÃO
						GROUP BY  J15.J15_UKEYP
					) J15 ON CASE WHEN (J10.J10_002_N = 1) THEN J11.UKEY ELSE J11_DEV.UKEY END = J15.J15_UKEYP 
	LEFT OUTER JOIN StarWestcon.dbo.A22 A22 (NOLOCK) ON A03.A22_UKEY = A22.UKEY 					   
	LEFT OUTER JOIN StarWestcon.dbo.A23 A23 (NOLOCK) ON A03.A23_UKEY = A23.UKEY
	LEFT OUTER JOIN StarWestcon.dbo.A24 A24 (NOLOCK) ON A03.A24_UKEY = A24.UKEY 
	LEFT OUTER JOIN StarWestcon.dbo.A33 A33 (NOLOCK) ON J10.A33_UKEY = A33.UKEY 
	LEFT OUTER JOIN	(SELECT J22.J22_UKEYP,SUM(ISNULL(J22.J22_004_B+ J22.J22_049_B + J22.J22_050_B,0)) AS ICMS
					FROM StarWestcon.dbo.J22 J22 (NOLOCK)
			WHERE J22.A40_UKEY=(select UKEY FROM StarWestcon.dbo.A40 A40 (NOLOCK) 
					WHERE A40.A40_001_C='ICMS') AND J22.CIA_UKEY = 'MDQJW'
			GROUP BY J22.J22_UKEYP) TabICMS 
				ON J11.UKEY=TabICMS.J22_UKEYP
	LEFT OUTER JOIN	(SELECT J22.J22_UKEYP,SUM(ISNULL(J22.J22_004_B,0)) AS IPI
					FROM StarWestcon.dbo.J22 J22 (NOLOCK)
			WHERE J22.A40_UKEY=(select UKEY FROM StarWestcon.dbo.A40 A40 (NOLOCK) 
					WHERE A40.A40_001_C='IPI') AND J22.CIA_UKEY = 'MDQJW'
			GROUP BY J22.J22_UKEYP) TabIPI 
				ON J11.UKEY=TabIPI.J22_UKEYP
	LEFT OUTER JOIN	(SELECT J22.J22_UKEYP,SUM(ISNULL(J22.J22_004_B,0)) AS IRRF
					FROM StarWestcon.dbo.J22 J22 (NOLOCK)
			WHERE J22.A40_UKEY=(select UKEY FROM StarWestcon.dbo.A40 A40 (NOLOCK) 
					WHERE A40.A40_001_C='IRRF') AND J22.CIA_UKEY = 'MDQJW'
			GROUP BY J22.J22_UKEYP) TabIRRF 
				ON J11.UKEY=TabIRRF.J22_UKEYP
	LEFT OUTER JOIN	(SELECT J22.J22_UKEYP,SUM(ISNULL(J22.J22_004_B,0)) AS CSLL
					FROM StarWestcon.dbo.J22 J22 (NOLOCK)
			WHERE J22.A40_UKEY=(select UKEY FROM StarWestcon.dbo.A40 A40 (NOLOCK) 
					WHERE A40.A40_001_C='CSLL') AND J22.CIA_UKEY = 'MDQJW'
			GROUP BY J22.J22_UKEYP) TabCSLL 
				ON J11.UKEY=TabCSLL.J22_UKEYP
	LEFT OUTER JOIN	(SELECT J22.J22_UKEYP,SUM(ISNULL(J22.J22_004_B,0)) AS ICMSST
					FROM StarWestcon.dbo.J22 J22 (NOLOCK)
			WHERE J22.A40_UKEY=(select UKEY FROM StarWestcon.dbo.A40 A40 (NOLOCK) 
					WHERE A40.A40_001_C='ICMS_ST') AND J22.CIA_UKEY = 'MDQJW'
			GROUP BY J22.J22_UKEYP) TabICMSST 
				ON J11.UKEY=TabICMSST.J22_UKEYP
	LEFT OUTER JOIN	(
						SELECT J22.J22_UKEYP, SUM(ISNULL(J22.J22_004_B,0)) AS IVA
						FROM StarWestcon.dbo.J22 J22 (NOLOCK)
						WHERE	J22.A40_UKEY=(select UKEY FROM StarWestcon.dbo.A40 A40 (NOLOCK) WHERE A40.A40_001_C='IVA') 
								AND J22.CIA_UKEY = 'MDQJW'
						GROUP BY J22.J22_UKEYP
					) TabIVA ON J11.UKEY=TabIVA.J22_UKEYP	
	LEFT OUTER JOIN	(
						SELECT J22.J22_UKEYP,SUM(ISNULL(J22.J22_004_B,0)) AS PIS
						FROM StarWestcon.dbo.J22 J22 (NOLOCK)
						WHERE J22.A40_UKEY=(select UKEY FROM StarWestcon.dbo.A40 A40 (NOLOCK) WHERE A40.A40_001_C='PIS')
						GROUP BY J22.J22_UKEYP
					) TabPIS ON J11.UKEY=TabPIS.J22_UKEYP	
	LEFT OUTER JOIN	(
						SELECT J22.J22_UKEYP,SUM(ISNULL(J22.J22_004_B,0)) AS COFINS
						FROM StarWestcon.dbo.J22 J22 (NOLOCK)
						WHERE J22.A40_UKEY=(select UKEY FROM StarWestcon.dbo.A40 A40 (NOLOCK) WHERE A40.A40_001_C='COFINS')
						GROUP BY J22.J22_UKEYP
					) TabCOFINS ON J11.UKEY=TabCOFINS.J22_UKEYP	
	LEFT OUTER JOIN	(
						SELECT J22.J22_UKEYP,SUM(ISNULL(J22.J22_004_B,0)) AS ISS
						FROM StarWestcon.dbo.J22 J22 (NOLOCK)
						WHERE J22.A40_UKEY=(select UKEY FROM StarWestcon.dbo.A40 A40 (NOLOCK) WHERE A40.A40_001_C='ISS')
						GROUP BY J22.J22_UKEYP
					) TabISS ON J11.UKEY=TabISS.J22_UKEYP									

	WHERE J10.CIA_UKEY = 'MDQJW' AND
		(
			(
				J10.J10_002_N <> 2  
				AND T04.T04_001_C <> 'E90.04'
				AND J10.J10_003_D >= @FromYYYYMMDD --CONVERT(DATETIME, @FromYYYYMMDD + ' 00:00:00', 102) 
				AND J10.J10_003_D <= @ToYYYYMMDD--CONVERT(DATETIME, @ToYYYYMMDD + ' 23:59:59', 102) 
			)
			OR (
				J10.J10_002_N = 2 
				AND J10.J10_014_D >= @FromYYYYMMDD --CONVERT(DATETIME, @FromYYYYMMDD + ' 00:00:00', 102) 
				AND J10.J10_014_D <= @ToYYYYMMDD--CONVERT(DATETIME, @ToYYYYMMDD + ' 23:59:59', 102) 
			)
		)
		AND 
		--SCRUM-15463 - inicio
		((@CanceledInvoices= 0 and J10.J10_032_N = 0) or (@CanceledInvoices= 1 and J10.J10_032_N = 1 and  cast(isnull(j10.j10_111_t,j10.timestamp) as date) <> cast(isnull(j10.j10_003_d,'') as date)  ) )
		--SCRUM-15463 - fim
 
		AND T04_501_N = 1
		AND J10.Array_736 <> 1
		AND J11.I14_UKEY IS NULL 
		AND J11_DEV.I14_UKEY IS NULL
			--T04.T04_001_C='S01.01ES'
			--or T04.T04_001_C='S01.02ES'
			--or T04.T04_001_C='S01.05ES'
			--or T04.T04_001_C='S01.06ES'
			--or T04.T04_001_C='S01.09ES'
			--or T04.T04_001_C='S01.10ES'
			--or T04.T04_001_C='S01.12ES'
			--or T04.T04_001_C='S01.19ES'
			--or T04.T04_001_C='S01.20ES'
			--or T04.T04_001_C='S01.21ES'
			--or T04.T04_001_C='S01.22ES'
			--or T04.T04_001_C='S01.94ES'
			--or T04.T04_001_C='S01.95ES'
			--or T04.T04_001_C='S01.98ES'
			--or T04.T04_001_C='S01.99ES'
			--or T04.T04_001_C='S02.03ES'
			--or T04.T04_001_C='S02.04ES'
			--or T04.T04_001_C='S02.06ES'
			--or T04.T04_001_C='E02.01ES'
			--or T04.T04_001_C='E02.04ES' -- adicionado em 1/fev/2010
			--or T04.T04_001_C='E02.06ES'
			--or T04.T04_001_C='E02.98ES'
			--or T04.T04_001_C='E90.04ES'
			--or T04.T04_001_C='E01.20ES' -- adicionado em 30-mar-2011, devolução venda trading
			--or T04.T04_001_C='E02.12ES' -- adicionado 02-set-2011 a pedido do wagner por JM
			--or T04.T04_001_C='E02.08ES' -- adicionado 02-jun-2012 a pedido do wagner por JM
			--or T04.T04_001_C='E02.09ES' -- adicionado 02-jun-2012 a pedido do wagner por JM
			--or T04.T04_001_C='S01.22ES' -- adicionado 30-out-2012 a pedido do wagner por JM
			--or T04.T04_001_C='S01.23ES' -- adicionado 30-out-2012 a pedido do wagner por JM
			--or T04.T04_001_C='S01.99ES' -- adicionado 30-out-2012 a pedido do wagner por JM
			--or T04.T04_001_C='S50.01ES'
			--or T04.T04_001_C='S50.02ES'
			--or T04.T04_001_C='S50.19ES'
			--or T04.T04_001_C='S50.21ES'
			--or T04.T04_001_C='S50.23ES'
			--or T04.T04_001_C='S52.03ES'
			--or T04.T04_001_C='S52.03ES'
			--or T04.T04_001_C='S52.07ES'
			--or T04.T04_001_C='S52.01ES'
			--or T04.T04_001_C='E52.04ES'
			--or T04.T04_001_C='E52.06ES'
			--or T04.T04_001_C='E52.01ES'
			--or T04.T04_001_C='E52.06ES'		
			--or T04.T04_001_C='S10.06ES' -- adicionado em 19-02-2013 a pedido do JM para contemplar as NF de serviços por ELCruz
			--or T04.T04_001_C='S50.22ES' -- adicionado em 02-jul-2013 a pedido do JM
			
		
	UNION ALL
	-- PARTE 3: SAO PAULO
	SELECT     J07.J07_001_C AS PedidoVenda, 
			   [Westcon].[StarSoft].[FN_GetOVGlobalCode](J07.J07_001_C,2) AS PedidoVendaTrimmed,
			   J10.J10_001_C AS NF,
			   T04.T04_001_C AS TipoES,
			   CONVERT(smalldatetime, CASE WHEN ((J10.J10_002_N <> 2) AND T04.T04_001_C <> 'E90.04') 
										   THEN J10.J10_003_D 
										   ELSE J10.J10_014_D END) AS EmissaoNF, 
	 		   D04.D04_001_C AS PartNumber,
			   A03.A03_001_C AS CNPJEmpresaNF,
			   A03.A03_003_C AS EmpresaNF,
				-- SE FOR UMA NF DE COMPLEMENTO, DEVO DEIXAR O CAMPO QTD SEMPRE COM O VALOR 1 E OS CAMPOS ValorUnitarioNF E TotalItemNF 
				-- COM O VALOR DA SOMA DOS IMPOSTOS ICMSST E IPI (O CAMPO T04_503_N = 1 INDICA QUE É UM TIPO DE E/S PARA NF COMPLEMENTAR)
				--SCRUM-15463 - INICIO
				CASE WHEN J10.J10_032_N = 1  and (rtrim(isnull(D03PAI.D03_002_C,'')) = 'CISCO' or rtrim(isnull(D03PAI.D03_002_C,'')) = 'CISCO BR') THEN (CASE WHEN T04.T04_503_N = 1 THEN 1 ELSE J11.J11_003_B END )*-1 ELSE (CASE WHEN T04.T04_503_N = 1 THEN 1 ELSE J11.J11_003_B END) END AS Qtd,
				CASE WHEN T04.T04_503_N = 1 THEN ISNULL(TabIPI.IPI,0) + ISNULL(TabICMSST.ICMSST,0) ELSE J11.J11_005_B END AS ValorUnitarioNF,
				CASE WHEN T04.T04_503_N = 1 THEN ISNULL(TabIPI.IPI,0) + ISNULL(TabICMSST.ICMSST,0) ELSE J11.J11_006_B END AS TotalItemNF,				
				CASE WHEN (J10.J10_002_N = 1) 
				THEN
					ISNULL(D28.D28_006_B, 0)
				ELSE
					-- SE A NF DE DEV. NAO GEROU ESTOQUE
					CASE WHEN D14.UKEY IS NULL
					THEN
						0
					ELSE			
						ISNULL(D28_DEV.D28_006_B, 0)
					END
				END AS CustoMedioUn,
				--Atividade PRIME-1848 - Inicio
				CASE WHEN (J10.J10_002_N = 1) 
				THEN
					--CASE WHEN RTRIM(LEFT(J10.A36_CODE,3))='US$'  
					--THEN 
						ISNULL(D28.D28_009_B, 0)
					--ELSE 
					--	ISNULL(D28.D28_006_B, 0)
					--END 
				ELSE
					-- SE A NF DE DEV. NAO GEROU ESTOQUE
					CASE WHEN D14.UKEY IS NULL
					THEN
						0
					ELSE				
						--CASE WHEN RTRIM(LEFT(J10.A36_CODE,3))='US$'  
						--THEN 
							ISNULL(D28_DEV.D28_009_B, 0)
						--ELSE 
						--	ISNULL(D28_DEV.D28_006_B, 0)
						--END 	
					END
				END AS CustoMedioUnPeso,
				--Atividade PRIME-1848 - Fim
			CASE WHEN (J10.J10_002_N = 1) 
			THEN
				ISNULL(D28.D28_006_B, 0)
			ELSE
				-- SE A NF DE DEV. NAO GEROU ESTOQUE
				CASE WHEN D14.UKEY IS NULL
				THEN
					0
				ELSE			
					ISNULL(D28_DEV.D28_006_B, 0)
				END
			END * J11.J11_003_B AS CustoMedioTotal,	
			--Atividade PRIME-1848 - Inicio	
			CASE WHEN (J10.J10_002_N = 1) 
				THEN
					--CASE WHEN RTRIM(LEFT(J10.A36_CODE,3))='US$'  
					--THEN 
						ISNULL(D28.D28_009_B, 0)
					--ELSE 
					--	ISNULL(D28.D28_006_B, 0)
					--END 
				ELSE
					-- SE A NF DE DEV. NAO GEROU ESTOQUE
					CASE WHEN D14.UKEY IS NULL
					THEN
						0
					ELSE				
						--CASE WHEN RTRIM(LEFT(J10.A36_CODE,3))='US$'  
						--THEN 
							ISNULL(D28_DEV.D28_009_B, 0)
						--ELSE 
						--	ISNULL(D28_DEV.D28_006_B, 0)
						--END 	
					END
				END * J11.J11_003_B AS CustoMedioTotalPeso,		
				--Atividade PRIME-1848 - Fim
			CASE WHEN (J10.J10_002_N = 1) 
			THEN
				ISNULL(D28.D28_009_B, 0)
			ELSE
				-- SE A NF DE DEV. NAO GEROU ESTOQUE
				CASE WHEN D14.UKEY IS NULL
				THEN
					0
				ELSE			
					ISNULL(D28_DEV.D28_009_B, 0)
				END
			END AS CustoMedioUnUSD,
			CASE WHEN (J10.J10_002_N = 1) 
			THEN
				ISNULL(D28.D28_009_B, 0)
			ELSE
				-- SE A NF DE DEV. NAO GEROU ESTOQUE
				CASE WHEN D14.UKEY IS NULL
				THEN
					0
				ELSE			
					ISNULL(D28_DEV.D28_009_B, 0)
				END
			END * J11.J11_003_B AS CustoMedioTotalUSD,							
			   CASE WHEN (J10.J10_002_N = 1) THEN ISNULL(J15.J15_002_B,0) ELSE (ISNULL(J15.J15_002_B,0) / J11_DEV.J11_003_B) * J11.J11_003_B END AS ProvisaoComissaoRevenda,
				CASE WHEN T04.T04_001_C='S01.95' OR J11.J11_005_B=0 OR T04.T04_503_N = 1
				THEN 
					0 
				ELSE  
					(CASE WHEN (J10.J10_002_N = 1) THEN ISNULL(J15.J15_002_B,0) ELSE (ISNULL(J15.J15_002_B,0) / J11_DEV.J11_003_B) * J11.J11_003_B END / (1 - 0.0925 - ISNULL ((TabICMS.ICMS), 0) / (J11.J11_003_B * J11.J11_005_B)) + J11.J11_003_B * J11.J11_005_B) 
				END AS TotalRevendaAntesComissao, 
				ISNULL(TabICMS.ICMS,0) AS ICMS, 
			CASE WHEN T04.T04_001_C='S01.20SP' or T04.T04_001_C='S01.12SP'
			THEN 
				0 
			ELSE
				ISNULL(TabPIS.PIS,0)  
			END AS PIS,
			CASE WHEN T04.T04_001_C='S01.20SP' or T04.T04_001_C='S01.12SP'
			THEN 
				0 
			ELSE
				ISNULL(TabCOFINS.COFINS,0) 
			END AS COFINS, 
			ISNULL(TabIRRF.IRRF,0) AS IRRF, 
			ISNULL(TabCSLL.CSLL,0) AS CSLL,
			ISNULL(TabIPI.IPI,0) AS IPI,
			ISNULL(TabISS.ISS,0) AS ISS,
			ISNULL(TabICMSST.ICMSST,0) AS ICMSST,
			ISNULL(TabIVA.IVA,0) AS IVA,	
			0 AS SalesTax,						
		   A23.A23_002_C AS Estado,
		   A24.A24_001_C AS Cidade, 
		   isnull(A33.A33_003_C,A33_DEV.A33_003_C) AS VENDEDOR,		
		isnull(J10_DEV.J10_001_C,'') AS NFDevolvida,
		J10.UKEY as J10_UKEY,
		J10.J09_UKEY,
		J10.CIA_UKEY as CIA_UKEY,
		A03.UKEY as A03_UKEY,
		J10.A36_CODE,
		RTRIM(LEFT(J10.A36_CODE,5)) AS Currency,
		CASE WHEN RTRIM(LEFT(J10.A36_CODE,5)) = RTRIM(LEFT(J07.A36_CODE,5))
		THEN 
			-- Se a moeda do pedido e nf forem iguais, não tem tx
			1 
		WHEN
			ISNULL(J07.A36_CODE,'') <> '' AND RTRIM(LEFT(J07.A36_CODE,5)) <> 'US$  ' 
		THEN
			-- Se o pedido tiver US$ específico, uso a data de emissão do pedido para buscar a tx
			(
				SELECT TOP 1 A37_002_B 
				FROM StarWestcon.dbo.A37 A37 (NoLock)
				WHERE A36_UKEYA='R$   '
				AND A36_UKEY=LEFT(J07.A36_CODE,5)
				AND A37_001_D= CONVERT(varchar(8),J07.J07_003_D,112)
			) 			
		ELSE
			-- Se não tiver ov para a nf, busco a tx do US$ na data do faturamento
			(
				SELECT TOP 1 A37_002_B 
				FROM StarWestcon.dbo.A37 A37 (NoLock)
				WHERE A36_UKEYA='R$   '
				AND A36_UKEY='US$  '
				AND A37_001_D=J10.J10_003_D
			) 
		END USDRate,
			[Westcon].[StarSoft].[FN_GetOVGlobalCode](J07.J07_001_C,1) AS CodPedido,
			1 AS CodERP,
			(
				RTRIM(LTRIM(A03_005_C)) + -- ENDERECO
				CASE WHEN ISNULL(A03_005_C,'') <> '' THEN ', ' + RTRIM(LTRIM(A03_014_C)) ELSE '' END -- NUMERO
			)AS EnderecoFatura,	
			A03_004_C as BairroFatura,			
			A03_006_C as CEPFatura,
			A22_001_C as PaisFatura,
CASE WHEN J10.J10_002_N = 1 THEN 
    CASE WHEN SUBSTRING(LTRIM(ISNULL(T04.T04_001_C,'')),1,3) = 'S10' THEN 'SERVICE' ELSE 'PRODUCT' END 
 ELSE 
    CASE WHEN SUBSTRING(LTRIM(ISNULL((SELECT T04_001_C FROM StarWestcon.dbo.T04 T04_ORG WHERE T04_ORG.UKEY = (SELECT J11_ORG.T04_UKEY FROM StarWestcon.dbo.J11 J11_ORG WHERE J11_ORG.UKEY = J11_DEV.UKEY)),'')),1,3) = 'S10' THEN 'SERVICE' ELSE 'PRODUCT' END 

END AS RevenueType,	
			--CASE WHEN SUBSTRING(LTRIM(ISNULL(T04.T04_001_C,'')),1,3) = 'S10' THEN 'SERVICE' ELSE 'PRODUCT' END AS RevenueType,
			[Westcon].[StarSoft].[fnGetPOBillingAtWMS](CASE WHEN J10.J10_002_N = 1 THEN J11.UKEY ELSE J11_DEV.UKEY END) AS POEFETIVA,
			J11.J11_998_C AS InvoiceLineNumber,
		-- Se for devolução de venda o fator será negativo
		CASE WHEN J10.J10_002_N = 1 AND T04.T04_001_C <> 'E90.04' THEN 1 ELSE -1 END AS FATOR,
		T04.T04_503_N AS COMPLEMENT,
		J11.UKEY AS J11_UKEY,
		CASE A03.A03_504_N WHEN 1 THEN 'No' WHEN 2 THEN 'Intercompany' WHEN 3 THEN 'Related' END AS Intercompany,
		ISNULL(
			(	
			SELECT SUM(J15_002_B) AS J15_002_B
			FROM StarWestcon.dbo.J15 (NOLOCK) 
			WHERE CASE WHEN (J10.J10_002_N = 1) THEN J11.UKEY ELSE J11_DEV.UKEY END = J15.J15_UKEYP AND J15.J15_500_N = 2 -- INDICA QUE É A COMISSÃO DE MKT
		),0) AS VendorMKT, 
		ISNULL(
			(	
			SELECT SUM(J15_002_B) AS J15_002_B
			FROM StarWestcon.dbo.J15 (NOLOCK) 
			WHERE CASE WHEN (J10.J10_002_N = 1) THEN J11.UKEY ELSE J11_DEV.UKEY END = J15.J15_UKEYP AND J15.J15_500_N = 1 -- INDICA QUE É A COMISSÃO DE FIDELIZAÇÃO
		),0) AS ResselerMKT,
			J08.J08_INTRANETUKEY AS ID_INTRANET
			,
		CASE WHEN J10.J10_046_B=0 THEN 1 ELSE J10.J10_046_B END  AS TAX1,  
		ISNULL((SELECT TOP 1 A37_002_B 
				FROM StarWestcon.dbo.A37 A37 (NOLOCK)
				WHERE A36_UKEYA=(SELECT CIA.A36_UKEY FROM StarWestcon.DBO.CIA (NOLOCK) WHERE CIA.UKEY = J10.CIA_UKEY)
				AND A36_UKEY=LEFT(J10.A36_CODE,5)
				AND A37_001_D= CONVERT(VARCHAR(8),J10.J10_003_D,112)
			),1)  AS TAX2, 
		 (SELECT CIA.A36_UKEY FROM StarWestcon.DBO.CIA (NOLOCK) WHERE CIA.UKEY = J10.CIA_UKEY) AS CURRENCY_CIA,
		 D03PAI.D03_002_C AS FABRICANTE,
		 D03FILHO.D03_002_C AS FAMILIA,
		 D04_501_N AS MAINTENANCE, -- PRIME-902 
		 D04_502_N AS CLOUD --PRIME-916

	FROM            StarWestcon.dbo.J10 J10 (NOLOCK) 
	INNER JOIN      StarWestcon.dbo.A03 A03 (NOLOCK) ON J10.A03_UKEY = A03.UKEY 
	INNER JOIN      StarWestcon.dbo.J11 J11 (NOLOCK) ON J10.UKEY = J11.J10_UKEY AND J11.CIA_UKEY = 'V5LRC'
	INNER JOIN      StarWestcon.dbo.T04 T04 (NOLOCK) ON J11.T04_UKEY = T04.UKEY 
	INNER JOIN      StarWestcon.dbo.D04 D04 (NOLOCK) ON J11.D04_UKEY = D04.UKEY 
	LEFT JOIN       StarWestcon.dbo.D03 D03FILHO (NOLOCK) ON D04.D03_UKEY = D03FILHO.UKEY 
	LEFT JOIN       StarWestcon.dbo.D03 D03PAI (NOLOCK) ON D03FILHO.D03_UKEY = D03PAI.UKEY 
	LEFT OUTER JOIN StarWestcon.dbo.D22 D22 (NOLOCK) ON J11.UKEY = D22.D22_IUKEYP AND D22.CIA_UKEY = 'V5LRC'
	LEFT OUTER JOIN StarWestcon.dbo.D28 D28 (NOLOCK) ON D22.UKEY = D28.D28_UKEYP -- AND D28.CIA_UKEY = 'V5LRC'
	LEFT OUTER JOIN StarWestcon.dbo.D14 D14 (NOLOCK) ON J11.UKEY = D14.D14_IUKEYP AND D14.CIA_UKEY = 'V5LRC'
	LEFT OUTER JOIN StarWestcon.dbo.D28 D28_1 (NOLOCK) ON D14.UKEY = D28_1.D28_UKEYP -- AND D28_1.CIA_UKEY = 'V5LRC'
	LEFT OUTER JOIN StarWestcon.dbo.J11 J11_DEV (nolock) ON J11.J11_UKEYP = J11_DEV.UKEY AND J11_DEV.CIA_UKEY = 'V5LRC'
	LEFT OUTER JOIN StarWestcon.dbo.D22 D22_DEV WITH (NOLOCK) ON J11_DEV.UKEY = D22_DEV.D22_IUKEYP
	LEFT OUTER JOIN StarWestcon.dbo.D28 D28_DEV WITH (NOLOCK) ON D22_DEV.UKEY = D28_DEV.D28_UKEYP 		
	LEFT OUTER JOIN StarWestcon.dbo.J10 J10_DEV (nolock) ON J11_DEV.J10_UKEY = J10_DEV.UKEY AND J10_DEV.CIA_UKEY = 'V5LRC'
	LEFT OUTER JOIN StarWestcon.dbo.A33 A33_DEV (NOLOCK) ON J10_DEV.A33_UKEY = A33_DEV.UKEY
			--SCRUM-15463 - INICIO
	LEFT OUTER JOIN StarWestcon.dbo.J08 J08 (NOLOCK) ON 
													CASE 
														WHEN (J11.J08_UKEYWE <> '' AND @CanceledInvoices = 1) 
															THEN 'J08' 
														WHEN (J10.J10_002_N = 1) 
															THEN J11.J11_PAR 
															ELSE J11_DEV.J11_PAR END
														 ='J08' and 
													CASE 
														WHEN (J11.J08_UKEYWE <> '' AND @CanceledInvoices = 1) 
															THEN J11.J08_UKEYWE 
														WHEN (J10.J10_002_N = 1) 
															THEN J11.J11_UKEYP 
															ELSE J11_DEV.J11_UKEYP END
													 =J08.UKEY AND J08.CIA_UKEY = 'V5LRC'
	--SCRUM-15463 - FIM

	LEFT OUTER JOIN StarWestcon.dbo.J07 J07 (NOLOCK) ON J08.J07_UKEY=J07.UKEY AND J07.CIA_UKEY = 'V5LRC'
	LEFT OUTER JOIN (	
						SELECT SUM(J15_002_B) AS J15_002_B,  J15.J15_UKEYP
						FROM StarWestcon.dbo.J15 (NOLOCK) 
						WHERE J15.J15_500_N = 0 -- INDICA QUE É A COMISSÃO DA NF E NÃO É UMA COMISSO DE MKT NEM FIDELIZAÇÃO
						GROUP BY  J15.J15_UKEYP
					) J15 ON CASE WHEN (J10.J10_002_N = 1) THEN J11.UKEY ELSE J11_DEV.UKEY END = J15.J15_UKEYP
	LEFT OUTER JOIN StarWestcon.dbo.A22 A22 (NOLOCK) ON A03.A22_UKEY = A22.UKEY 					   
	LEFT OUTER JOIN StarWestcon.dbo.A23 A23 (NOLOCK) ON A03.A23_UKEY = A23.UKEY
	LEFT OUTER JOIN StarWestcon.dbo.A24 A24 (NOLOCK) ON A03.A24_UKEY = A24.UKEY 
	LEFT OUTER JOIN StarWestcon.dbo.A33 A33 (NOLOCK) ON J10.A33_UKEY = A33.UKEY 
	LEFT OUTER JOIN	(SELECT J22.J22_UKEYP,SUM(ISNULL(J22.J22_004_B+ J22.J22_049_B + J22.J22_050_B,0)) AS ICMS
					FROM StarWestcon.dbo.J22 J22 (NOLOCK)
			WHERE J22.A40_UKEY=(select UKEY FROM StarWestcon.dbo.A40 A40 (NOLOCK) 
					WHERE A40.A40_001_C='ICMS') AND J22.CIA_UKEY = 'V5LRC'
			GROUP BY J22.J22_UKEYP) TabICMS 
				ON J11.UKEY=TabICMS.J22_UKEYP
	LEFT OUTER JOIN	(SELECT J22.J22_UKEYP,SUM(ISNULL(J22.J22_004_B,0)) AS IPI
					FROM StarWestcon.dbo.J22 J22 (NOLOCK)
			WHERE J22.A40_UKEY=(select UKEY FROM StarWestcon.dbo.A40 A40 (NOLOCK) 
					WHERE A40.A40_001_C='IPI') AND J22.CIA_UKEY = 'V5LRC'
			GROUP BY J22.J22_UKEYP) TabIPI 
				ON J11.UKEY=TabIPI.J22_UKEYP
	LEFT OUTER JOIN	(SELECT J22.J22_UKEYP,SUM(ISNULL(J22.J22_004_B,0)) AS IRRF
					FROM StarWestcon.dbo.J22 J22 (NOLOCK)
			WHERE J22.A40_UKEY=(select UKEY FROM StarWestcon.dbo.A40 A40 (NOLOCK) 
					WHERE A40.A40_001_C='IRRF') AND J22.CIA_UKEY = 'V5LRC'
			GROUP BY J22.J22_UKEYP) TabIRRF 
				ON J11.UKEY=TabIRRF.J22_UKEYP
	LEFT OUTER JOIN	(SELECT J22.J22_UKEYP,SUM(ISNULL(J22.J22_004_B,0)) AS CSLL
					FROM StarWestcon.dbo.J22 J22 (NOLOCK)
			WHERE J22.A40_UKEY=(select UKEY FROM StarWestcon.dbo.A40 A40 (NOLOCK) 
					WHERE A40.A40_001_C='CSLL') AND J22.CIA_UKEY = 'V5LRC'
			GROUP BY J22.J22_UKEYP) TabCSLL 
				ON J11.UKEY=TabCSLL.J22_UKEYP
	LEFT OUTER JOIN	(SELECT J22.J22_UKEYP,SUM(ISNULL(J22.J22_004_B,0)) AS ICMSST
					FROM StarWestcon.dbo.J22 J22 (NOLOCK)
			WHERE J22.A40_UKEY=(select UKEY FROM StarWestcon.dbo.A40 A40 (NOLOCK) 
					WHERE A40.A40_001_C='ICMS_ST') AND J22.CIA_UKEY = 'V5LRC'
			GROUP BY J22.J22_UKEYP) TabICMSST 
				ON J11.UKEY=TabICMSST.J22_UKEYP
	LEFT OUTER JOIN	(
						SELECT J22.J22_UKEYP, SUM(ISNULL(J22.J22_004_B,0)) AS IVA
						FROM StarWestcon.dbo.J22 J22 (NOLOCK)
						WHERE	J22.A40_UKEY=(select UKEY FROM StarWestcon.dbo.A40 A40 (NOLOCK) WHERE A40.A40_001_C='IVA') 
								AND J22.CIA_UKEY = 'V5LRC'
						GROUP BY J22.J22_UKEYP
					) TabIVA ON J11.UKEY=TabIVA.J22_UKEYP	
	LEFT OUTER JOIN	(
						SELECT J22.J22_UKEYP,SUM(ISNULL(J22.J22_004_B,0)) AS PIS
						FROM StarWestcon.dbo.J22 J22 (NOLOCK)
						WHERE J22.A40_UKEY=(select UKEY FROM StarWestcon.dbo.A40 A40 (NOLOCK) WHERE A40.A40_001_C='PIS')
						GROUP BY J22.J22_UKEYP
					) TabPIS ON J11.UKEY=TabPIS.J22_UKEYP	
	LEFT OUTER JOIN	(
						SELECT J22.J22_UKEYP,SUM(ISNULL(J22.J22_004_B,0)) AS COFINS
						FROM StarWestcon.dbo.J22 J22 (NOLOCK)
						WHERE J22.A40_UKEY=(select UKEY FROM StarWestcon.dbo.A40 A40 (NOLOCK) WHERE A40.A40_001_C='COFINS')
						GROUP BY J22.J22_UKEYP
					) TabCOFINS ON J11.UKEY=TabCOFINS.J22_UKEYP	
	LEFT OUTER JOIN	(
						SELECT J22.J22_UKEYP,SUM(ISNULL(J22.J22_004_B,0)) AS ISS
						FROM StarWestcon.dbo.J22 J22 (NOLOCK)
						WHERE J22.A40_UKEY=(select UKEY FROM StarWestcon.dbo.A40 A40 (NOLOCK) WHERE A40.A40_001_C='ISS')
						GROUP BY J22.J22_UKEYP
					) TabISS ON J11.UKEY=TabISS.J22_UKEYP											
				
	WHERE J10.CIA_UKEY = 'V5LRC' AND
		(
			(
				J10.J10_002_N <> 2  
				AND T04.T04_001_C <> 'E90.04'
				AND J10.J10_003_D >= @FromYYYYMMDD --CONVERT(DATETIME, @FromYYYYMMDD + ' 00:00:00', 102) 
				AND J10.J10_003_D <= @ToYYYYMMDD--CONVERT(DATETIME, @ToYYYYMMDD + ' 23:59:59', 102) 
			)
			OR (
				J10.J10_002_N = 2 
				AND J10.J10_014_D >= @FromYYYYMMDD --CONVERT(DATETIME, @FromYYYYMMDD + ' 00:00:00', 102) 
				AND J10.J10_014_D <= @ToYYYYMMDD--CONVERT(DATETIME, @ToYYYYMMDD + ' 23:59:59', 102) 
			)
		)

		AND 
		--SCRUM-15463 - inicio
		((@CanceledInvoices= 0 and J10.J10_032_N = 0) or (@CanceledInvoices= 1 and J10.J10_032_N = 1 and  cast(isnull(j10.j10_111_t,j10.timestamp) as date) <> cast(isnull(j10.j10_003_d,'') as date)  ) )
		--SCRUM-15463 - fim
		AND T04_501_N = 1
		AND J10.Array_736 <> 1
		AND J11.I14_UKEY IS NULL 
		AND J11_DEV.I14_UKEY IS NULL
			--T04.T04_001_C='S01.01SP'
			--or T04.T04_001_C='S01.02SP'
			--or T04.T04_001_C='S01.05SP'
			--or T04.T04_001_C='S01.06SP'
			--or T04.T04_001_C='S01.09SP'
			--or T04.T04_001_C='S01.10SP'
			--or T04.T04_001_C='S01.12SP'
			--or T04.T04_001_C='S01.19SP'
			--or T04.T04_001_C='S01.20SP'
			--or T04.T04_001_C='S01.21SP'
			--or T04.T04_001_C='S01.22SP'
			--or T04.T04_001_C='S01.94SP'
			--or T04.T04_001_C='S01.95SP'
			--or T04.T04_001_C='S01.98SP'
			--or T04.T04_001_C='S01.99SP'
			--or T04.T04_001_C='S02.03SP'
			--or T04.T04_001_C='S02.04SP'
			--or T04.T04_001_C='S02.06SP'
			--or T04.T04_001_C='S50.01SP' -- adicionado em 23/mai/2011 a pedido do Wagner
			--or T04.T04_001_C='E02.01SP'
			--or T04.T04_001_C='E02.06SP'
			--or T04.T04_001_C='E02.98SP'
			--or T04.T04_001_C='E90.04SP'
			--or T04.T04_001_C='E60.01SP' -- adicionado 05-ago-2013 a pedido do Wagner por JM			
			--or T04.T04_001_C='S50.02SP' -- adicionado 02-set-2011 a pedido do Wagner por JM
			--or T04.T04_001_C='E02.55SP' -- adicionado 02-set-2011 a pedido do Wagner por JM
			--or T04.T04_001_C='S60.01SP' -- adicionado 02-fev-2013 a pedido do Wagner por JM (SCRUM-1063)
			--or T04.T04_001_C='S60.02SP' -- adicionado 11-abril-2013 a pedido do JM por ELCruz (SCRUM-2011)
			--or T04.T04_001_C='S60.03SP' -- adicionado 09-abril-2013 a pedido do JM por ELCruz (SCRUM-1977)
			--or T04.T04_001_C IN (	'S10.10SP','S10.09SP','S10.11SP','S10.01SP','S10.02SP','S10.03SP','S10.04SP','S10.05SP',
			--						'S10.07SP','S10.06SP','S10.16SP','S10.17SP','S10.12SP') -- adicionado em 19-02-2013 a pedido do JM para contemplar as NF de serviços por ELCruz
		

	UNION ALL
		-- Escritório Rio
		SELECT     J07.J07_001_C AS PedidoVenda, 
				   [Westcon].[StarSoft].[FN_GetOVGlobalCode](J07.J07_001_C,2) AS PedidoVendaTrimmed,
				   J10.J10_001_C AS NF,
				   T04.T04_001_C AS TipoES,
				   CONVERT(smalldatetime, CASE WHEN (J10.J10_002_N <> 2 AND T04.T04_001_C <> 'E90.04') 
											   THEN J10.J10_003_D 
											   ELSE J10.J10_014_D END) AS EmissaoNF, 		
			       D04.D04_001_C AS PartNumber,
				   A03.A03_001_C AS CNPJEmpresaNF,
			       A03.A03_003_C AS EmpresaNF,
					-- SE FOR UMA NF DE COMPLEMENTO, DEVO DEIXAR O CAMPO QTD SEMPRE COM O VALOR 1 E OS CAMPOS ValorUnitarioNF E TotalItemNF 
					-- COM O VALOR DA SOMA DOS IMPOSTOS ICMSST E IPI (O CAMPO T04_503_N = 1 INDICA QUE É UM TIPO DE E/S PARA NF COMPLEMENTAR)
					--SCRUM-15463 - INICIO
					CASE WHEN J10.J10_032_N = 1  and (rtrim(isnull(D03PAI.D03_002_C,'')) = 'CISCO' or rtrim(isnull(D03PAI.D03_002_C,'')) = 'CISCO BR') THEN (CASE WHEN T04.T04_503_N = 1 THEN 1 ELSE J11.J11_003_B END )*-1 ELSE (CASE WHEN T04.T04_503_N = 1 THEN 1 ELSE J11
.J11_003_B END) END AS Qtd,
					--SCRUM-15463 - FIM
					CASE WHEN T04.T04_503_N = 1 THEN ISNULL(TabIPI.IPI,0) + ISNULL(TabICMSST.ICMSST,0) ELSE J11.J11_005_B END AS ValorUnitarioNF,
					CASE WHEN T04.T04_503_N = 1 THEN ISNULL(TabIPI.IPI,0) + ISNULL(TabICMSST.ICMSST,0) ELSE J11.J11_006_B END AS TotalItemNF,				
					CASE WHEN (J10.J10_002_N = 1) 
					THEN
						ISNULL(D28.D28_006_B, 0)
					ELSE
						-- SE A NF DE DEV. NAO GEROU ESTOQUE
						CASE WHEN D14.UKEY IS NULL
						THEN
							0
						ELSE			
							ISNULL(D28_DEV.D28_006_B, 0)
						END
					END AS CustoMedioUn,
					--Atividade PRIME-1848 - Inicio
					CASE WHEN (J10.J10_002_N = 1) 
				THEN
					--CASE WHEN RTRIM(LEFT(J10.A36_CODE,3))='US$'  
					--THEN 
						ISNULL(D28.D28_009_B, 0)
					--ELSE 
					--	ISNULL(D28.D28_006_B, 0)
					--END 
				ELSE
					-- SE A NF DE DEV. NAO GEROU ESTOQUE
					CASE WHEN D14.UKEY IS NULL
					THEN
						0
					ELSE				
						--CASE WHEN RTRIM(LEFT(J10.A36_CODE,3))='US$'  
						--THEN 
							ISNULL(D28_DEV.D28_009_B, 0)
						--ELSE 
						--	ISNULL(D28_DEV.D28_006_B, 0)
						--END 	
					END
				END AS CustoMedioUnPeso,
				--Atividade PRIME-1848 - Fim
			CASE WHEN (J10.J10_002_N = 1) 
			THEN
				ISNULL(D28.D28_006_B, 0)
			ELSE
				-- SE A NF DE DEV. NAO GEROU ESTOQUE
				CASE WHEN D14.UKEY IS NULL
				THEN
					0
				ELSE			
					ISNULL(D28_DEV.D28_006_B, 0)
				END
			END * J11.J11_003_B AS CustoMedioTotal,	
			--Atividade PRIME-1848 - Inicio	
			CASE WHEN (J10.J10_002_N = 1) 
				THEN
					--CASE WHEN RTRIM(LEFT(J10.A36_CODE,3))='US$'  
					--THEN 
						ISNULL(D28.D28_009_B, 0)
					--ELSE 
					--	ISNULL(D28.D28_006_B, 0)
					--END 
				ELSE
					-- SE A NF DE DEV. NAO GEROU ESTOQUE
					CASE WHEN D14.UKEY IS NULL
					THEN
						0
					ELSE				
						--CASE WHEN RTRIM(LEFT(J10.A36_CODE,3))='US$'  
						--THEN 
							ISNULL(D28_DEV.D28_009_B, 0)
						--ELSE 
						--	ISNULL(D28_DEV.D28_006_B, 0)
						--END 	
					END
				END * J11.J11_003_B AS CustoMedioTotalPeso,	
				--Atividade PRIME-1848 - Fim	
			CASE WHEN (J10.J10_002_N = 1) 
			THEN
				ISNULL(D28.D28_009_B, 0)
			ELSE
				-- SE A NF DE DEV. NAO GEROU ESTOQUE
				CASE WHEN D14.UKEY IS NULL
				THEN
					0
				ELSE			
					ISNULL(D28_DEV.D28_009_B, 0)
				END
			END AS CustoMedioUnUSD,
			CASE WHEN (J10.J10_002_N = 1) 
			THEN
				ISNULL(D28.D28_009_B, 0)
			ELSE
				-- SE A NF DE DEV. NAO GEROU ESTOQUE
				CASE WHEN D14.UKEY IS NULL
				THEN
					0
				ELSE			
					ISNULL(D28_DEV.D28_009_B, 0)
				END
			END * J11.J11_003_B AS CustoMedioTotalUSD,								
				   CASE WHEN (J10.J10_002_N = 1) THEN ISNULL(J15.J15_002_B,0) ELSE (ISNULL(J15.J15_002_B,0) / J11_DEV.J11_003_B) * J11.J11_003_B END AS ProvisaoComissaoRevenda,
					CASE WHEN T04.T04_001_C='S01.95' OR J11.J11_005_B=0 OR T04.T04_503_N = 1
					THEN 
						0 
					ELSE  
						(CASE WHEN (J10.J10_002_N = 1) THEN ISNULL(J15.J15_002_B,0) ELSE (ISNULL(J15.J15_002_B,0) / J11_DEV.J11_003_B) * J11.J11_003_B END / (1 - 0.0925 - ISNULL ((TabICMS.ICMS), 0) / (J11.J11_003_B * J11.J11_005_B)) + J11.J11_003_B * J11.J11_005_B) 
					END AS TotalRevendaAntesComissao, 
					ISNULL(TabICMS.ICMS,0) AS ICMS, 
				CASE WHEN T04.T04_001_C IN ('S01.20ES','S01.12ES','E02.12ES') -- adicionado 02-set-2011 a pedido do wagner por JM
				THEN 
					0 
				ELSE
					ISNULL(TabPIS.PIS,0)  
				END AS PIS,
				CASE WHEN T04.T04_001_C IN ('S01.20ES','S01.12ES','E02.12ES') -- adicionado 02-set-2011 a pedido do wagner por JM
				THEN 
					0 
				ELSE 
					ISNULL(TabCOFINS.COFINS,0) 
				END AS COFINS, 
				ISNULL(TabIRRF.IRRF,0) AS IRRF, 
				ISNULL(TabCSLL.CSLL,0) AS CSLL,
				ISNULL(TabIPI.IPI,0) AS IPI,
				ISNULL(TabISS.ISS,0) AS ISS,
				ISNULL(TabICMSST.ICMSST,0) AS ICMSST,
				ISNULL(TabIVA.IVA,0) AS IVA,	
				0 AS SalesTax,					
				   A23.A23_002_C AS Estado,
				   A24.A24_001_C AS Cidade, 
				   isnull(A33.A33_003_C,A33_DEV.A33_003_C) AS VENDEDOR,		
			isnull(J10_DEV.J10_001_C,'') AS NFDevolvida,
			J10.UKEY as J10_UKEY,
			J10.J09_UKEY,
			J10.CIA_UKEY as CIA_UKEY,
			A03.UKEY as A03_UKEY,
			J10.A36_CODE,
			RTRIM(LEFT(J10.A36_CODE,5)) AS Currency,
		CASE WHEN RTRIM(LEFT(J10.A36_CODE,5)) = RTRIM(LEFT(J07.A36_CODE,5))
		THEN 
			-- Se a moeda do pedido e nf forem iguais, não tem tx
			1 
		WHEN
			ISNULL(J07.A36_CODE,'') <> '' AND RTRIM(LEFT(J07.A36_CODE,5)) <> 'US$  ' 
		THEN
			-- Se o pedido tiver US$ específico, uso a data de emissão do pedido para buscar a tx
			(
				SELECT TOP 1 A37_002_B 
				FROM StarWestcon.dbo.A37 A37 (NoLock)
				WHERE A36_UKEYA='R$   '
				AND A36_UKEY=LEFT(J07.A36_CODE,5)
				AND A37_001_D= CONVERT(varchar(8),J07.J07_003_D,112)
			) 			
		ELSE
			-- Se não tiver ov para a nf, busco a tx do US$ na data do faturamento
			(
				SELECT TOP 1 A37_002_B 
				FROM StarWestcon.dbo.A37 A37 (NoLock)
				WHERE A36_UKEYA='R$   '
				AND A36_UKEY='US$  '
				AND A37_001_D=J10.J10_003_D
			) 
		END USDRate,
				[Westcon].[StarSoft].[FN_GetOVGlobalCode](J07.J07_001_C,1) AS CodPedido,
			    1 AS CodERP,
				(
					RTRIM(LTRIM(A03_005_C)) + -- ENDERECO
					CASE WHEN ISNULL(A03_005_C,'') <> '' THEN ', ' + RTRIM(LTRIM(A03_014_C)) ELSE '' END -- NUMERO
				)AS EnderecoFatura,	
			    A03_004_C as BairroFatura,
			    A03_006_C as CEPFatura,
			    A22_001_C as PaisFatura,
CASE WHEN J10.J10_002_N = 1 THEN 
    CASE WHEN SUBSTRING(LTRIM(ISNULL(T04.T04_001_C,'')),1,3) = 'S10' THEN 'SERVICE' ELSE 'PRODUCT' END 
 ELSE 
    CASE WHEN SUBSTRING(LTRIM(ISNULL((SELECT T04_001_C FROM StarWestcon.dbo.T04 T04_ORG WHERE T04_ORG.UKEY = (SELECT J11_ORG.T04_UKEY FROM StarWestcon.dbo.J11 J11_ORG WHERE J11_ORG.UKEY = J11_DEV.UKEY)),'')),1,3) = 'S10' THEN 'SERVICE' ELSE 'PRODUCT' END 

END AS RevenueType,	
			    --CASE WHEN SUBSTRING(LTRIM(ISNULL(T04.T04_001_C,'')),1,3) = 'S10' THEN 'SERVICE' ELSE 'PRODUCT' END AS RevenueType,
			[Westcon].[StarSoft].[fnGetPOBillingAtWMS](CASE WHEN J10.J10_002_N = 1 THEN J11.UKEY ELSE J11_DEV.UKEY END) AS POEFETIVA,
			J11.J11_998_C AS InvoiceLineNumber,
		-- Se for devolução de venda o fator será negativo
		CASE WHEN J10.J10_002_N = 1 AND T04.T04_001_C <> 'E90.04' THEN 1 ELSE -1 END AS FATOR,
		T04.T04_503_N AS COMPLEMENT,
		J11.UKEY AS J11_UKEY,
		CASE A03.A03_504_N WHEN 1 THEN 'No' WHEN 2 THEN 'Intercompany' WHEN 3 THEN 'Related' END AS Intercompany,
		ISNULL(
			(	
			SELECT SUM(J15_002_B) AS J15_002_B
			FROM StarWestcon.dbo.J15 (NOLOCK) 
			WHERE CASE WHEN (J10.J10_002_N = 1) THEN J11.UKEY ELSE J11_DEV.UKEY END = J15.J15_UKEYP AND J15.J15_500_N = 2 -- INDICA QUE É A COMISSÃO DE MKT
		),0) AS VendorMKT, 
		ISNULL(
			(	
			SELECT SUM(J15_002_B) AS J15_002_B
			FROM StarWestcon.dbo.J15 (NOLOCK) 
			WHERE CASE WHEN (J10.J10_002_N = 1) THEN J11.UKEY ELSE J11_DEV.UKEY END = J15.J15_UKEYP AND J15.J15_500_N = 1 -- INDICA QUE É A COMISSÃO DE FIDELIZAÇÃO
		),0) AS ResselerMKT,
			J08.J08_INTRANETUKEY AS ID_INTRANET	,
		CASE WHEN J10.J10_046_B=0 THEN 1 ELSE J10.J10_046_B END  AS TAX1,  
		ISNULL((SELECT TOP 1 A37_002_B 
				FROM StarWestcon.dbo.A37 A37 (NOLOCK)
				WHERE A36_UKEYA=(SELECT CIA.A36_UKEY FROM StarWestcon.DBO.CIA (NOLOCK) WHERE CIA.UKEY = J10.CIA_UKEY)
				AND A36_UKEY=LEFT(J10.A36_CODE,5)
				AND A37_001_D= CONVERT(VARCHAR(8),J10.J10_003_D,112)
			),1)  AS TAX2, 
		 (SELECT CIA.A36_UKEY FROM StarWestcon.DBO.CIA (NOLOCK) WHERE CIA.UKEY = J10.CIA_UKEY) AS CURRENCY_CIA,
		 D03PAI.D03_002_C AS FABRICANTE,
		 D03FILHO.D03_002_C AS FAMILIA,
		 D04_501_N AS MAINTENANCE, -- PRIME-902 
		 D04_502_N AS CLOUD --PRIME-916
			    
		FROM            StarWestcon.dbo.J10 J10 (NOLOCK) 
	INNER JOIN      StarWestcon.dbo.A03 A03 (NOLOCK) ON J10.A03_UKEY = A03.UKEY 
	INNER JOIN      StarWestcon.dbo.J11 J11 (NOLOCK) ON J10.UKEY = J11.J10_UKEY AND J11.CIA_UKEY = 'MGVJM'
	INNER JOIN      StarWestcon.dbo.T04 T04 (NOLOCK) ON J11.T04_UKEY = T04.UKEY 
	INNER JOIN      StarWestcon.dbo.D04 D04 (NOLOCK) ON J11.D04_UKEY = D04.UKEY 
	LEFT JOIN       StarWestcon.dbo.D03 D03FILHO (NOLOCK) ON D04.D03_UKEY = D03FILHO.UKEY 
	LEFT JOIN       StarWestcon.dbo.D03 D03PAI (NOLOCK) ON D03FILHO.D03_UKEY = D03PAI.UKEY 
	LEFT OUTER JOIN StarWestcon.dbo.D22 D22 (NOLOCK) ON J11.UKEY = D22.D22_IUKEYP AND D22.CIA_UKEY = 'MGVJM'
	LEFT OUTER JOIN StarWestcon.dbo.D28 D28 (NOLOCK) ON D22.UKEY = D28.D28_UKEYP -- AND D28.CIA_UKEY = 'MGVJM'
	LEFT OUTER JOIN StarWestcon.dbo.D14 D14 (NOLOCK) ON J11.UKEY = D14.D14_IUKEYP AND D14.CIA_UKEY = 'MGVJM'
	LEFT OUTER JOIN StarWestcon.dbo.D28 D28_1 (NOLOCK) ON D14.UKEY = D28_1.D28_UKEYP -- AND D28_1.CIA_UKEY = 'MGVJM'
	LEFT OUTER JOIN StarWestcon.dbo.J11 J11_DEV (nolock) ON J11.J11_UKEYP = J11_DEV.UKEY AND J11_DEV.CIA_UKEY = 'MGVJM'
	LEFT OUTER JOIN StarWestcon.dbo.D22 D22_DEV WITH (NOLOCK) ON J11_DEV.UKEY = D22_DEV.D22_IUKEYP
	LEFT OUTER JOIN StarWestcon.dbo.D28 D28_DEV WITH (NOLOCK) ON D22_DEV.UKEY = D28_DEV.D28_UKEYP 		
	LEFT OUTER JOIN StarWestcon.dbo.J10 J10_DEV (nolock) ON J11_DEV.J10_UKEY = J10_DEV.UKEY AND J10_DEV.CIA_UKEY = 'MGVJM'
	LEFT OUTER JOIN StarWestcon.dbo.A33 A33_DEV (NOLOCK) ON J10_DEV.A33_UKEY = A33_DEV.UKEY
			--SCRUM-15463 - INICIO
	LEFT OUTER JOIN StarWestcon.dbo.J08 J08 (NOLOCK) ON 
													CASE 
														WHEN (J11.J08_UKEYWE <> '' AND @CanceledInvoices = 1) 
															THEN 'J08' 
														WHEN (J10.J10_002_N = 1) 
															THEN J11.J11_PAR 
															ELSE J11_DEV.J11_PAR END
														 ='J08' and 
													CASE 
														WHEN (J11.J08_UKEYWE <> '' AND @CanceledInvoices = 1) 
															THEN J11.J08_UKEYWE 
														WHEN (J10.J10_002_N = 1) 
															THEN J11.J11_UKEYP 
															ELSE J11_DEV.J11_UKEYP END
													 =J08.UKEY AND J08.CIA_UKEY = 'MGVJM'
	--SCRUM-15463 - FIM

	LEFT OUTER JOIN StarWestcon.dbo.J07 J07 (NOLOCK) ON J08.J07_UKEY=J07.UKEY AND J07.CIA_UKEY = 'MGVJM'
	LEFT OUTER JOIN (	
						SELECT SUM(J15_002_B) AS J15_002_B,  J15.J15_UKEYP
						FROM StarWestcon.dbo.J15 (NOLOCK) 
						WHERE J15.J15_500_N = 0 -- INDICA QUE É A COMISSÃO DA NF E NÃO É UMA COMISSO DE MKT NEM FIDELIZAÇÃO
						GROUP BY  J15.J15_UKEYP
					) J15 ON CASE WHEN (J10.J10_002_N = 1) THEN J11.UKEY ELSE J11_DEV.UKEY END = J15.J15_UKEYP 
	LEFT OUTER JOIN StarWestcon.dbo.A22 A22 (NOLOCK) ON A03.A22_UKEY = A22.UKEY 					  
	LEFT OUTER JOIN StarWestcon.dbo.A23 A23 (NOLOCK) ON A03.A23_UKEY = A23.UKEY
	LEFT OUTER JOIN StarWestcon.dbo.A24 A24 (NOLOCK) ON A03.A24_UKEY = A24.UKEY 
	LEFT OUTER JOIN StarWestcon.dbo.A33 A33 (NOLOCK) ON J10.A33_UKEY = A33.UKEY 
	LEFT OUTER JOIN	(SELECT J22.J22_UKEYP,SUM(ISNULL(J22.J22_004_B+ J22.J22_049_B + J22.J22_050_B,0)) AS ICMS
					FROM StarWestcon.dbo.J22 J22 (NOLOCK)
			WHERE J22.A40_UKEY=(select UKEY FROM StarWestcon.dbo.A40 A40 (NOLOCK) 
					WHERE A40.A40_001_C='ICMS') AND J22.CIA_UKEY = 'MGVJM'
			GROUP BY J22.J22_UKEYP) TabICMS 
				ON J11.UKEY=TabICMS.J22_UKEYP
	LEFT OUTER JOIN	(SELECT J22.J22_UKEYP,SUM(ISNULL(J22.J22_004_B,0)) AS IPI
					FROM StarWestcon.dbo.J22 J22 (NOLOCK)
			WHERE J22.A40_UKEY=(select UKEY FROM StarWestcon.dbo.A40 A40 (NOLOCK) 
					WHERE A40.A40_001_C='IPI') AND J22.CIA_UKEY = 'MGVJM'
			GROUP BY J22.J22_UKEYP) TabIPI 
				ON J11.UKEY=TabIPI.J22_UKEYP
	LEFT OUTER JOIN	(SELECT J22.J22_UKEYP,SUM(ISNULL(J22.J22_004_B,0)) AS IRRF
					FROM StarWestcon.dbo.J22 J22 (NOLOCK)
			WHERE J22.A40_UKEY=(select UKEY FROM StarWestcon.dbo.A40 A40 (NOLOCK) 
					WHERE A40.A40_001_C='IRRF') AND J22.CIA_UKEY = 'MGVJM'
			GROUP BY J22.J22_UKEYP) TabIRRF 
				ON J11.UKEY=TabIRRF.J22_UKEYP
	LEFT OUTER JOIN	(SELECT J22.J22_UKEYP,SUM(ISNULL(J22.J22_004_B,0)) AS CSLL
					FROM StarWestcon.dbo.J22 J22 (NOLOCK)
			WHERE J22.A40_UKEY=(select UKEY FROM StarWestcon.dbo.A40 A40 (NOLOCK) 
					WHERE A40.A40_001_C='CSLL') AND J22.CIA_UKEY = 'MGVJM'
			GROUP BY J22.J22_UKEYP) TabCSLL 
				ON J11.UKEY=TabCSLL.J22_UKEYP
	LEFT OUTER JOIN	(SELECT J22.J22_UKEYP,SUM(ISNULL(J22.J22_004_B,0)) AS ICMSST
					FROM StarWestcon.dbo.J22 J22 (NOLOCK)
			WHERE J22.A40_UKEY=(select UKEY FROM StarWestcon.dbo.A40 A40 (NOLOCK) 
					WHERE A40.A40_001_C='ICMS_ST') AND J22.CIA_UKEY = 'MGVJM'
			GROUP BY J22.J22_UKEYP) TabICMSST 
				ON J11.UKEY=TabICMSST.J22_UKEYP
	LEFT OUTER JOIN	(SELECT J22.J22_UKEYP,SUM(ISNULL(J22.J22_004_B,0)) AS IVA
					FROM StarWestcon.dbo.J22 J22 (NOLOCK)
			WHERE J22.A40_UKEY=(select UKEY FROM StarWestcon.dbo.A40 A40 (NOLOCK) 
					WHERE A40.A40_001_C='IVA') AND J22.CIA_UKEY = 'STAR_'
			GROUP BY J22.J22_UKEYP) TabIVA
				ON J11.UKEY=TabIVA.J22_UKEYP	
	LEFT OUTER JOIN	(
						SELECT J22.J22_UKEYP,SUM(ISNULL(J22.J22_004_B,0)) AS PIS
						FROM StarWestcon.dbo.J22 J22 (NOLOCK)
						WHERE J22.A40_UKEY=(select UKEY FROM StarWestcon.dbo.A40 A40 (NOLOCK) WHERE A40.A40_001_C='PIS')
						GROUP BY J22.J22_UKEYP
					) TabPIS ON J11.UKEY=TabPIS.J22_UKEYP	
	LEFT OUTER JOIN	(
						SELECT J22.J22_UKEYP,SUM(ISNULL(J22.J22_004_B,0)) AS COFINS
						FROM StarWestcon.dbo.J22 J22 (NOLOCK)
						WHERE J22.A40_UKEY=(select UKEY FROM StarWestcon.dbo.A40 A40 (NOLOCK) WHERE A40.A40_001_C='COFINS')
						GROUP BY J22.J22_UKEYP
					) TabCOFINS ON J11.UKEY=TabCOFINS.J22_UKEYP	
	LEFT OUTER JOIN	(
						SELECT J22.J22_UKEYP,SUM(ISNULL(J22.J22_004_B,0)) AS ISS
						FROM StarWestcon.dbo.J22 J22 (NOLOCK)
						WHERE J22.A40_UKEY=(select UKEY FROM StarWestcon.dbo.A40 A40 (NOLOCK) WHERE A40.A40_001_C='ISS')
						GROUP BY J22.J22_UKEYP
					) TabISS ON J11.UKEY=TabISS.J22_UKEYP								

	WHERE J10.CIA_UKEY = 'MGVJM' AND
			(
				(
					J10.J10_002_N <> 2  
					AND T04.T04_001_C <> 'E90.04'
					AND J10.J10_003_D >= @FromYYYYMMDD--CONVERT(DATETIME, @FromYYYYMMDD + ' 00:00:00', 102) 
					AND J10.J10_003_D <= @ToYYYYMMDD--CONVERT(DATETIME, @ToYYYYMMDD + ' 23:59:59', 102) 
				)
				OR (
					J10.J10_002_N = 2 
					AND J10.J10_014_D >= @FromYYYYMMDD--CONVERT(DATETIME, @FromYYYYMMDD + ' 00:00:00', 102) 
					AND J10.J10_014_D <= @ToYYYYMMDD--CONVERT(DATETIME, @ToYYYYMMDD + ' 23:59:59', 102) 
				)
			)
		
			AND 
			--SCRUM-15463 - inicio
			((@CanceledInvoices= 0 and J10.J10_032_N = 0) or (@CanceledInvoices= 1 and J10.J10_032_N = 1 and  cast(isnull(j10.j10_111_t,j10.timestamp) as date) <> cast(isnull(j10.j10_003_d,'') as date) ) )
			--SCRUM-15463 - fim
 
			AND T04_501_N = 1
			AND J10.Array_736 <> 1
			AND J11.I14_UKEY IS NULL 
			AND J11_DEV.I14_UKEY IS NULL
				--T04.T04_001_C='S01.09W6'
				--or T04.T04_001_C='S01.01W6'
				--or T04.T04_001_C='E02.01W6'
				--or T04.T04_001_C='S02.06W6'
				--or T04.T04_001_C='S01.10W6'
				--or T04.T04_001_C='S01.19W6'
				--or T04.T04_001_C='S01.22W6' -- adicionado por PR em 13 de Dez de 2012
				--or T04.T04_001_C='E02.08W6' -- adicionado por JM em 2 de jun de 2012				 
				--or T04.T04_001_C='E02.04W6' -- adicionado por JM em 4 de julho de 2012				 
				--or T04.T04_001_C='S01.99W6' -- adicionado 30-out-2012 a pedido do wagner por JM	
				--or T04.T04_001_C IN (	'S10.06ES','S10.02W6','S10.09W6','S10.16W6','S10.05W6','S10.17W6','S10.07W6',
				--						'S10.12W6','S10.04W6','S10.01W6','S10.03W6','S10.11W6'	) -- adicionado em 19-02-2013 a pedido do JM para contemplar as NF de serviços por ELCruz		
				--or T04.T04_001_C='S01.20W6' -- adicionado 02-jul-2013 por JM
			

	UNION ALL
	-- PARTE : ESPIRITO SANTO W1
	SELECT     J07.J07_001_C AS PedidoVenda, 
			   [Westcon].[StarSoft].[FN_GetOVGlobalCode](J07.J07_001_C,2) AS PedidoVendaTrimmed,
			   J10.J10_001_C AS NF,
			   T04.T04_001_C AS TipoES,
			   CONVERT(smalldatetime, CASE WHEN (J10.J10_002_N <> 2 AND T04.T04_001_C <> 'E90.04') 
										   THEN J10.J10_003_D 
										   ELSE J10.J10_014_D END) AS EmissaoNF, 
		       D04.D04_001_C AS PartNumber,
			   A03.A03_001_C AS CNPJEmpresaNF,
			   A03.A03_003_C AS EmpresaNF,
				-- SE FOR UMA NF DE COMPLEMENTO, DEVO DEIXAR O CAMPO QTD SEMPRE COM O VALOR 1 E OS CAMPOS ValorUnitarioNF E TotalItemNF 
				-- COM O VALOR DA SOMA DOS IMPOSTOS ICMSST E IPI (O CAMPO T04_503_N = 1 INDICA QUE É UM TIPO DE E/S PARA NF COMPLEMENTAR)
				--SCRUM-15463 - INICIO
				CASE WHEN J10.J10_032_N = 1  and (rtrim(isnull(D03PAI.D03_002_C,'')) = 'CISCO' or rtrim(isnull(D03PAI.D03_002_C,'')) = 'CISCO BR') THEN (CASE WHEN T04.T04_503_N = 1 THEN 1 ELSE J11.J11_003_B END )*-1 ELSE (CASE WHEN T04.T04_503_N = 1 THEN 1 ELSE J11.J11_003_B END) END AS Qtd,
				--SCRUM-15463 - FIM

				CASE WHEN T04.T04_503_N = 1 THEN ISNULL(TabIPI.IPI,0) + ISNULL(TabICMSST.ICMSST,0) ELSE J11.J11_005_B END AS ValorUnitarioNF,
				CASE WHEN T04.T04_503_N = 1 THEN ISNULL(TabIPI.IPI,0) + ISNULL(TabICMSST.ICMSST,0) ELSE J11.J11_006_B END AS TotalItemNF,				
				CASE WHEN (J10.J10_002_N = 1) 
				THEN
					ISNULL(D28.D28_006_B, 0)
				ELSE
					-- SE A NF DE DEV. NAO GEROU ESTOQUE
					CASE WHEN D14.UKEY IS NULL
					THEN
						0
					ELSE			
						ISNULL(D28_DEV.D28_006_B, 0)
					END
				END AS CustoMedioUn,
				--Atividade PRIME-1848 - Inicio
				CASE WHEN (J10.J10_002_N = 1) 
				THEN
					--CASE WHEN RTRIM(LEFT(J10.A36_CODE,3))='US$'  
					--THEN 
						ISNULL(D28.D28_009_B, 0)
					--ELSE 
					--	ISNULL(D28.D28_006_B, 0)
					--END 
				ELSE
					-- SE A NF DE DEV. NAO GEROU ESTOQUE
					CASE WHEN D14.UKEY IS NULL
					THEN
						0
					ELSE				
						--CASE WHEN RTRIM(LEFT(J10.A36_CODE,3))='US$'  
						--THEN 
							ISNULL(D28_DEV.D28_009_B, 0)
						--ELSE 
						--	ISNULL(D28_DEV.D28_006_B, 0)
						--END 	
					END
				END AS CustoMedioUnPeso,
				--Atividade PRIME-1848 - Fim
			CASE WHEN (J10.J10_002_N = 1) 
			THEN
				ISNULL(D28.D28_006_B, 0)
			ELSE
				-- SE A NF DE DEV. NAO GEROU ESTOQUE
				CASE WHEN D14.UKEY IS NULL
				THEN
					0
				ELSE			
					ISNULL(D28_DEV.D28_006_B, 0)
				END
			END * J11.J11_003_B AS CustoMedioTotal,	
			--Atividade PRIME-1848 - Inicio	
			CASE WHEN (J10.J10_002_N = 1) 
				THEN
					--CASE WHEN RTRIM(LEFT(J10.A36_CODE,3))='US$'  
					--THEN 
						ISNULL(D28.D28_009_B, 0)
					--ELSE 
					--	ISNULL(D28.D28_006_B, 0)
					--END 
				ELSE
					-- SE A NF DE DEV. NAO GEROU ESTOQUE
					CASE WHEN D14.UKEY IS NULL
					THEN
						0
					ELSE				
						--CASE WHEN RTRIM(LEFT(J10.A36_CODE,3))='US$'  
						--THEN 
							ISNULL(D28_DEV.D28_009_B, 0)
						--ELSE 
						--	ISNULL(D28_DEV.D28_006_B, 0)
						--END 	
					END
				END * J11.J11_003_B AS CustoMedioTotalPeso,	
				--Atividade PRIME-1848 - Fim	
			CASE WHEN (J10.J10_002_N = 1) 
			THEN
				ISNULL(D28.D28_009_B, 0)
			ELSE
				-- SE A NF DE DEV. NAO GEROU ESTOQUE
				CASE WHEN D14.UKEY IS NULL
				THEN
					0
				ELSE			
					ISNULL(D28_DEV.D28_009_B, 0)
				END
			END AS CustoMedioUnUSD,
			CASE WHEN (J10.J10_002_N = 1) 
			THEN
				ISNULL(D28.D28_009_B, 0)
			ELSE
				-- SE A NF DE DEV. NAO GEROU ESTOQUE
				CASE WHEN D14.UKEY IS NULL
				THEN
					0
				ELSE			
					ISNULL(D28_DEV.D28_009_B, 0)
				END
			END * J11.J11_003_B AS CustoMedioTotalUSD,								
			   CASE WHEN (J10.J10_002_N = 1) THEN ISNULL(J15.J15_002_B,0) ELSE (ISNULL(J15.J15_002_B,0) / J11_DEV.J11_003_B) * J11.J11_003_B END AS ProvisaoComissaoRevenda,
				CASE WHEN T04.T04_001_C='S01.95' OR J11.J11_005_B=0 OR T04.T04_503_N = 1
				THEN 
					0 
				ELSE  
					(CASE WHEN (J10.J10_002_N = 1) THEN ISNULL(J15.J15_002_B,0) ELSE (ISNULL(J15.J15_002_B,0) / J11_DEV.J11_003_B) * J11.J11_003_B END / (1 - 0.0925 - ISNULL ((TabICMS.ICMS), 0) / (J11.J11_003_B * J11.J11_005_B)) + J11.J11_003_B * J11.J11_005_B) 
				END AS TotalRevendaAntesComissao, 
				ISNULL(TabICMS.ICMS,0) AS ICMS, 
			CASE WHEN T04.T04_001_C IN ('S01.20ES','S01.12ES','E02.12ES') -- adicionado 02-set-2011 a pedido do wagner por JM
			THEN 
				0 
			ELSE
				ISNULL(TabPIS.PIS,0)  
			END AS PIS,
			CASE WHEN T04.T04_001_C IN ('S01.20ES','S01.12ES','E02.12ES') -- adicionado 02-set-2011 a pedido do wagner por JM
			THEN 
				0 
			ELSE 
				ISNULL(TabCOFINS.COFINS,0) 
			END AS COFINS, 
			ISNULL(TabIRRF.IRRF,0) AS IRRF, 
			ISNULL(TabCSLL.CSLL,0) AS CSLL,
			ISNULL(TabIPI.IPI,0) AS IPI,
			ISNULL(TabISS.ISS,0) AS ISS,
			ISNULL(TabICMSST.ICMSST,0) AS ICMSST,
			ISNULL(TabIVA.IVA,0) AS IVA,	
			0 AS SalesTax,					
			   A23.A23_002_C AS Estado,
			   A24.A24_001_C AS Cidade, 
			   isnull(A33.A33_003_C,A33_DEV.A33_003_C) AS VENDEDOR,			 
			isnull(J10_DEV.J10_001_C,'') AS NFDevolvida,
			J10.UKEY as J10_UKEY,
			J10.J09_UKEY,
			J10.CIA_UKEY as CIA_UKEY,
			A03.UKEY as A03_UKEY,
			J10.A36_CODE,
			RTRIM(LEFT(J10.A36_CODE,5)) AS Currency,
		CASE WHEN RTRIM(LEFT(J10.A36_CODE,5)) = RTRIM(LEFT(J07.A36_CODE,5))
		THEN 
			-- Se a moeda do pedido e nf forem iguais, não tem tx
			1 
		WHEN
			ISNULL(J07.A36_CODE,'') <> '' AND RTRIM(LEFT(J07.A36_CODE,5)) <> 'US$  ' 
		THEN
			-- Se o pedido tiver US$ específico, uso a data de emissão do pedido para buscar a tx
			(
				SELECT TOP 1 A37_002_B 
				FROM StarWestcon.dbo.A37 A37 (NoLock)
				WHERE A36_UKEYA='R$   '
				AND A36_UKEY=LEFT(J07.A36_CODE,5)
				AND A37_001_D= CONVERT(varchar(8),J07.J07_003_D,112)
			) 			
		ELSE
			-- Se não tiver ov para a nf, busco a tx do US$ na data do faturamento
			(
				SELECT TOP 1 A37_002_B 
				FROM StarWestcon.dbo.A37 A37 (NoLock)
				WHERE A36_UKEYA='R$   '
				AND A36_UKEY='US$  '
				AND A37_001_D=J10.J10_003_D
			) 
		END USDRate,
				[Westcon].[StarSoft].[FN_GetOVGlobalCode](J07.J07_001_C,1) AS CodPedido,
			1 AS CodERP,
			(
				RTRIM(LTRIM(A03_005_C)) + -- ENDERECO
				CASE WHEN ISNULL(A03_005_C,'') <> '' THEN ', ' + RTRIM(LTRIM(A03_014_C)) ELSE '' END -- NUMERO
			)AS EnderecoFatura,	
			A03_004_C as BairroFatura,
			A03_006_C as CEPFatura,
			A22_001_C as PaisFatura,
CASE WHEN J10.J10_002_N = 1 THEN 
    CASE WHEN SUBSTRING(LTRIM(ISNULL(T04.T04_001_C,'')),1,3) = 'S10' THEN 'SERVICE' ELSE 'PRODUCT' END 
 ELSE 
    CASE WHEN SUBSTRING(LTRIM(ISNULL((SELECT T04_001_C FROM StarWestcon.dbo.T04 T04_ORG WHERE T04_ORG.UKEY = (SELECT J11_ORG.T04_UKEY FROM StarWestcon.dbo.J11 J11_ORG WHERE J11_ORG.UKEY = J11_DEV.UKEY)),'')),1,3) = 'S10' THEN 'SERVICE' ELSE 'PRODUCT' END
 
END AS RevenueType,	
			--CASE WHEN SUBSTRING(LTRIM(ISNULL(T04.T04_001_C,'')),1,3) = 'S10' THEN 'SERVICE' ELSE 'PRODUCT' END AS RevenueType,
			[Westcon].[StarSoft].[fnGetPOBillingAtWMS](CASE WHEN J10.J10_002_N = 1 THEN J11.UKEY ELSE J11_DEV.UKEY END) AS POEFETIVA,
			J11.J11_998_C AS InvoiceLineNumber,
		-- Se for devolução de venda o fator será negativo
		CASE WHEN J10.J10_002_N = 1 AND T04.T04_001_C <> 'E90.04' THEN 1 ELSE -1 END AS FATOR,
		T04.T04_503_N AS COMPLEMENT,
		J11.UKEY AS J11_UKEY,
		CASE A03.A03_504_N WHEN 1 THEN 'No' WHEN 2 THEN 'Intercompany' WHEN 3 THEN 'Related' END AS Intercompany,
		ISNULL(
			(	
			SELECT SUM(J15_002_B) AS J15_002_B
			FROM StarWestcon.dbo.J15 (NOLOCK) 
			WHERE CASE WHEN (J10.J10_002_N = 1) THEN J11.UKEY ELSE J11_DEV.UKEY END = J15.J15_UKEYP AND J15.J15_500_N = 2 -- INDICA QUE É A COMISSÃO DE MKT
		),0) AS VendorMKT, 
		ISNULL(
			(	
			SELECT SUM(J15_002_B) AS J15_002_B
			FROM StarWestcon.dbo.J15 (NOLOCK) 
			WHERE CASE WHEN (J10.J10_002_N = 1) THEN J11.UKEY ELSE J11_DEV.UKEY END = J15.J15_UKEYP AND J15.J15_500_N = 1 -- INDICA QUE É A COMISSÃO DE FIDELIZAÇÃO
		),0) AS ResselerMKT,
			J08.J08_INTRANETUKEY AS ID_INTRANET,
		CASE WHEN J10.J10_046_B=0 THEN 1 ELSE J10.J10_046_B END  AS TAX1,  
		ISNULL((SELECT TOP 1 A37_002_B 
				FROM StarWestcon.dbo.A37 A37 (NOLOCK)
				WHERE A36_UKEYA=(SELECT CIA.A36_UKEY FROM StarWestcon.DBO.CIA (NOLOCK) WHERE CIA.UKEY = J10.CIA_UKEY)
				AND A36_UKEY=LEFT(J10.A36_CODE,5)
				AND A37_001_D= CONVERT(VARCHAR(8),J10.J10_003_D,112)
			),1)  AS TAX2, 
		 (SELECT CIA.A36_UKEY FROM StarWestcon.DBO.CIA (NOLOCK) WHERE CIA.UKEY = J10.CIA_UKEY) AS CURRENCY_CIA,
		 D03PAI.D03_002_C AS FABRICANTE,
		 D03FILHO.D03_002_C AS FAMILIA,
		 D04_501_N AS MAINTENANCE, -- PRIME-902 
		 D04_502_N AS CLOUD --PRIME-916

	FROM            StarWestcon.dbo.J10 J10 (NOLOCK) 
	INNER JOIN      StarWestcon.dbo.A03 A03 (NOLOCK) ON J10.A03_UKEY = A03.UKEY 
	INNER JOIN      StarWestcon.dbo.J11 J11 (NOLOCK) ON J10.UKEY = J11.J10_UKEY AND J11.CIA_UKEY = '7MZMQ'
	INNER JOIN      StarWestcon.dbo.T04 T04 (NOLOCK) ON J11.T04_UKEY = T04.UKEY 
	INNER JOIN      StarWestcon.dbo.D04 D04 (NOLOCK) ON J11.D04_UKEY = D04.UKEY 
	LEFT JOIN       StarWestcon.dbo.D03 D03FILHO (NOLOCK) ON D04.D03_UKEY = D03FILHO.UKEY 
	LEFT JOIN       StarWestcon.dbo.D03 D03PAI (NOLOCK) ON D03FILHO.D03_UKEY = D03PAI.UKEY 
	LEFT OUTER JOIN StarWestcon.dbo.D22 D22 (NOLOCK) ON J11.UKEY = D22.D22_IUKEYP 
	LEFT OUTER JOIN StarWestcon.dbo.D28 D28 (NOLOCK) ON D22.UKEY = D28.D28_UKEYP 
	LEFT OUTER JOIN StarWestcon.dbo.D14 D14 (NOLOCK) ON J11.UKEY = D14.D14_IUKEYP 
	LEFT OUTER JOIN StarWestcon.dbo.D28 D28_1 (NOLOCK) ON D14.UKEY = D28_1.D28_UKEYP 
	LEFT OUTER JOIN StarWestcon.dbo.J11 J11_DEV (nolock) ON J11.J11_UKEYP = J11_DEV.UKEY AND J11_DEV.CIA_UKEY = '7MZMQ'
	LEFT OUTER JOIN StarWestcon.dbo.D22 D22_DEV WITH (NOLOCK) ON J11_DEV.UKEY = D22_DEV.D22_IUKEYP
	LEFT OUTER JOIN StarWestcon.dbo.D28 D28_DEV WITH (NOLOCK) ON D22_DEV.UKEY = D28_DEV.D28_UKEYP 		
	LEFT OUTER JOIN StarWestcon.dbo.J10 J10_DEV (nolock) ON J11_DEV.J10_UKEY = J10_DEV.UKEY AND J10_DEV.CIA_UKEY = '7MZMQ'
	LEFT OUTER JOIN StarWestcon.dbo.A33 A33_DEV (NOLOCK) ON J10_DEV.A33_UKEY = A33_DEV.UKEY
			--SCRUM-15463 - INICIO
	LEFT OUTER JOIN StarWestcon.dbo.J08 J08 (NOLOCK) ON 
													CASE 
														WHEN (J11.J08_UKEYWE <> '' AND @CanceledInvoices = 1) 
															THEN 'J08' 
														WHEN (J10.J10_002_N = 1) 
															THEN J11.J11_PAR 
															ELSE J11_DEV.J11_PAR END
														 ='J08' and 
													CASE 
														WHEN (J11.J08_UKEYWE <> '' AND @CanceledInvoices = 1) 
															THEN J11.J08_UKEYWE 
														WHEN (J10.J10_002_N = 1) 
															THEN J11.J11_UKEYP 
															ELSE J11_DEV.J11_UKEYP END
													 =J08.UKEY AND J08.CIA_UKEY = '7MZMQ'
	--SCRUM-15463 - FIM
	LEFT OUTER JOIN StarWestcon.dbo.J07 J07 (NOLOCK) ON J08.J07_UKEY=J07.UKEY AND J07.CIA_UKEY = '7MZMQ'
	LEFT OUTER JOIN (	
						SELECT SUM(J15_002_B) AS J15_002_B,  J15.J15_UKEYP
						FROM StarWestcon.dbo.J15 (NOLOCK) 
						WHERE J15.J15_500_N = 0 -- INDICA QUE É A COMISSÃO DA NF E NÃO É UMA COMISSO DE MKT NEM FIDELIZAÇÃO
						GROUP BY  J15.J15_UKEYP
					) J15 ON CASE WHEN (J10.J10_002_N = 1) THEN J11.UKEY ELSE J11_DEV.UKEY END = J15.J15_UKEYP 
	LEFT OUTER JOIN StarWestcon.dbo.A22 A22 (NOLOCK) ON A03.A22_UKEY = A22.UKEY 					   
	LEFT OUTER JOIN StarWestcon.dbo.A23 A23 (NOLOCK) ON A03.A23_UKEY = A23.UKEY
	LEFT OUTER JOIN StarWestcon.dbo.A24 A24 (NOLOCK) ON A03.A24_UKEY = A24.UKEY 
	LEFT OUTER JOIN StarWestcon.dbo.A33 A33 (NOLOCK) ON J10.A33_UKEY = A33.UKEY 
	LEFT OUTER JOIN	(SELECT J22.J22_UKEYP,SUM(ISNULL(J22.J22_004_B+ J22.J22_049_B + J22.J22_050_B,0)) AS ICMS
					FROM StarWestcon.dbo.J22 J22 (NOLOCK)
			WHERE J22.A40_UKEY=(select UKEY FROM StarWestcon.dbo.A40 A40 (NOLOCK) 
					WHERE A40.A40_001_C='ICMS') AND J22.CIA_UKEY = '7MZMQ'
			GROUP BY J22.J22_UKEYP) TabICMS 
				ON J11.UKEY=TabICMS.J22_UKEYP
	LEFT OUTER JOIN	(SELECT J22.J22_UKEYP,SUM(ISNULL(J22.J22_004_B,0)) AS IPI
					FROM StarWestcon.dbo.J22 J22 (NOLOCK)
			WHERE J22.A40_UKEY=(select UKEY FROM StarWestcon.dbo.A40 A40 (NOLOCK) 
					WHERE A40.A40_001_C='IPI') AND J22.CIA_UKEY = '7MZMQ'
			GROUP BY J22.J22_UKEYP) TabIPI 
				ON J11.UKEY=TabIPI.J22_UKEYP
	LEFT OUTER JOIN	(SELECT J22.J22_UKEYP,SUM(ISNULL(J22.J22_004_B,0)) AS IRRF
					FROM StarWestcon.dbo.J22 J22 (NOLOCK)
			WHERE J22.A40_UKEY=(select UKEY FROM StarWestcon.dbo.A40 A40 (NOLOCK) 
					WHERE A40.A40_001_C='IRRF') AND J22.CIA_UKEY = '7MZMQ'
			GROUP BY J22.J22_UKEYP) TabIRRF 
				ON J11.UKEY=TabIRRF.J22_UKEYP
	LEFT OUTER JOIN	(SELECT J22.J22_UKEYP,SUM(ISNULL(J22.J22_004_B,0)) AS CSLL
					FROM StarWestcon.dbo.J22 J22 (NOLOCK)
			WHERE J22.A40_UKEY=(select UKEY FROM StarWestcon.dbo.A40 A40 (NOLOCK) 
					WHERE A40.A40_001_C='CSLL') AND J22.CIA_UKEY = '7MZMQ'
			GROUP BY J22.J22_UKEYP) TabCSLL 
				ON J11.UKEY=TabCSLL.J22_UKEYP
	LEFT OUTER JOIN	(SELECT J22.J22_UKEYP,SUM(ISNULL(J22.J22_004_B,0)) AS ICMSST
					FROM StarWestcon.dbo.J22 J22 (NOLOCK)
			WHERE J22.A40_UKEY=(select UKEY FROM StarWestcon.dbo.A40 A40 (NOLOCK) 
					WHERE A40.A40_001_C='ICMS_ST') AND J22.CIA_UKEY = '7MZMQ'
			GROUP BY J22.J22_UKEYP) TabICMSST 
				ON J11.UKEY=TabICMSST.J22_UKEYP
	LEFT OUTER JOIN	(SELECT J22.J22_UKEYP,SUM(ISNULL(J22.J22_004_B,0)) AS IVA
					FROM StarWestcon.dbo.J22 J22 (NOLOCK)
			WHERE J22.A40_UKEY=(select UKEY FROM StarWestcon.dbo.A40 A40 (NOLOCK) 
					WHERE A40.A40_001_C='IVA') AND J22.CIA_UKEY = '7MZMQ'
			GROUP BY J22.J22_UKEYP) TabIVA
				ON J11.UKEY=TabIVA.J22_UKEYP
	LEFT OUTER JOIN	(
						SELECT J22.J22_UKEYP,SUM(ISNULL(J22.J22_004_B,0)) AS PIS
						FROM StarWestcon.dbo.J22 J22 (NOLOCK)
						WHERE J22.A40_UKEY=(select UKEY FROM StarWestcon.dbo.A40 A40 (NOLOCK) WHERE A40.A40_001_C='PIS')
						GROUP BY J22.J22_UKEYP
					) TabPIS ON J11.UKEY=TabPIS.J22_UKEYP	
	LEFT OUTER JOIN	(
						SELECT J22.J22_UKEYP,SUM(ISNULL(J22.J22_004_B,0)) AS COFINS
						FROM StarWestcon.dbo.J22 J22 (NOLOCK)
						WHERE J22.A40_UKEY=(select UKEY FROM StarWestcon.dbo.A40 A40 (NOLOCK) WHERE A40.A40_001_C='COFINS')
						GROUP BY J22.J22_UKEYP
					) TabCOFINS ON J11.UKEY=TabCOFINS.J22_UKEYP	
	LEFT OUTER JOIN	(
						SELECT J22.J22_UKEYP,SUM(ISNULL(J22.J22_004_B,0)) AS ISS
						FROM StarWestcon.dbo.J22 J22 (NOLOCK)
						WHERE J22.A40_UKEY=(select UKEY FROM StarWestcon.dbo.A40 A40 (NOLOCK) WHERE A40.A40_001_C='ISS')
						GROUP BY J22.J22_UKEYP
					) TabISS ON J11.UKEY=TabISS.J22_UKEYP					
				
	WHERE J10.CIA_UKEY = '7MZMQ' AND	
		(
			(
				J10.J10_002_N <> 2  
				AND T04.T04_001_C <> 'E90.04'
				AND J10.J10_003_D >= @FromYYYYMMDD--CONVERT(DATETIME, @FromYYYYMMDD + ' 00:00:00', 102) 
				AND J10.J10_003_D <= @ToYYYYMMDD--CONVERT(DATETIME, @ToYYYYMMDD + ' 23:59:59', 102) 
			)
			OR (
				J10.J10_002_N = 2 
				AND J10.J10_014_D >= @FromYYYYMMDD--CONVERT(DATETIME, @FromYYYYMMDD + ' 00:00:00', 102) 
				AND J10.J10_014_D <= @ToYYYYMMDD--CONVERT(DATETIME, @ToYYYYMMDD + ' 23:59:59', 102) 
			)
		)
		AND 
		--SCRUM-15463 - inicio
		((@CanceledInvoices= 0 and J10.J10_032_N = 0) or (@CanceledInvoices= 1 and J10.J10_032_N = 1 and  cast(isnull(j10.j10_111_t,j10.timestamp) as date) <> cast(isnull(j10.j10_003_d,'') as date)  ) )
		--SCRUM-15463 - fim
		 
		AND T04_501_N = 1
		AND J10.Array_736 <> 1
		AND J11.I14_UKEY IS NULL 
		AND J11_DEV.I14_UKEY IS NULL
			--T04.T04_001_C='S01.0101'
			--or T04.T04_001_C='S01.0201'
			--or T04.T04_001_C='S01.0501'
			--or T04.T04_001_C='S01.0601'
			--or T04.T04_001_C='S01.0901'
			--or T04.T04_001_C='S01.1001'
			--or T04.T04_001_C='S01.1201'
			--or T04.T04_001_C='S01.1901'
			--or T04.T04_001_C='S01.2001'
			--or T04.T04_001_C='S01.2101'
			--or T04.T04_001_C='S01.2201'
			--or T04.T04_001_C='S01.9401'
			--or T04.T04_001_C='S01.9501'
			--or T04.T04_001_C='S01.9801'
			--or T04.T04_001_C='S01.9901'
			--or T04.T04_001_C='S02.0301'
			--or T04.T04_001_C='S02.0401'
			--or T04.T04_001_C='S02.0601'
			--or T04.T04_001_C='E02.0101'
			--or T04.T04_001_C='E02.0401' 
			--or T04.T04_001_C='E02.0601'
			--or T04.T04_001_C='E02.9801'
			--or T04.T04_001_C='E90.0401'
		
		
		
	UNION ALL
	-- PARTE : WAREHOUSE DE SAO PAULO
	SELECT     J07.J07_001_C AS PedidoVenda, 
			   [Westcon].[StarSoft].[FN_GetOVGlobalCode](J07.J07_001_C,2) AS PedidoVendaTrimmed,
			   J10.J10_001_C AS NF,
			   T04.T04_001_C AS TipoES,
			   CONVERT(smalldatetime, CASE WHEN ((J10.J10_002_N <> 2) AND T04.T04_001_C <> 'E90.04W8') 
										   THEN J10.J10_003_D 
										   ELSE J10.J10_014_D END) AS EmissaoNF, 
	 		   D04.D04_001_C AS PartNumber,
			   A03.A03_001_C AS CNPJEmpresaNF,
			   A03.A03_003_C AS EmpresaNF,
				-- SE FOR UMA NF DE COMPLEMENTO, DEVO DEIXAR O CAMPO QTD SEMPRE COM O VALOR 1 E OS CAMPOS ValorUnitarioNF E TotalItemNF 
				-- COM O VALOR DA SOMA DOS IMPOSTOS ICMSST E IPI (O CAMPO T04_503_N = 1 INDICA QUE É UM TIPO DE E/S PARA NF COMPLEMENTAR)
				--SCRUM-15463 - INICIO
				CASE WHEN J10.J10_032_N = 1 and (rtrim(isnull(D03PAI.D03_002_C,'')) = 'CISCO' or rtrim(isnull(D03PAI.D03_002_C,'')) = 'CISCO BR') THEN (CASE WHEN T04.T04_503_N = 1 THEN 1 ELSE J11.J11_003_B END )*-1 ELSE (CASE WHEN T04.T04_503_N = 1 THEN 1 ELSE J11.J11_003_B END) END AS Qtd,
				--SCRUM-15463 - FIM
				CASE WHEN T04.T04_503_N = 1 THEN ISNULL(TabIPI.IPI,0) + ISNULL(TabICMSST.ICMSST,0) ELSE J11.J11_005_B END AS ValorUnitarioNF,
				CASE WHEN T04.T04_503_N = 1 THEN ISNULL(TabIPI.IPI,0) + ISNULL(TabICMSST.ICMSST,0) ELSE J11.J11_006_B END AS TotalItemNF,				
				CASE WHEN (J10.J10_002_N = 1) 
				THEN
					ISNULL(D28.D28_006_B, 0)
				ELSE
					-- SE A NF DE DEV. NAO GEROU ESTOQUE
					CASE WHEN D14.UKEY IS NULL
					THEN
						0
					ELSE			
						ISNULL(D28_DEV.D28_006_B, 0)
					END
				END AS CustoMedioUn,
				--Atividade PRIME-1848 - Inicio
				CASE WHEN (J10.J10_002_N = 1) 
				THEN
					--CASE WHEN RTRIM(LEFT(J10.A36_CODE,3))='US$'  
					--THEN 
						ISNULL(D28.D28_009_B, 0)
					--ELSE 
					--	ISNULL(D28.D28_006_B, 0)
					--END 
				ELSE
					-- SE A NF DE DEV. NAO GEROU ESTOQUE
					CASE WHEN D14.UKEY IS NULL
					THEN
						0
					ELSE				
						--CASE WHEN RTRIM(LEFT(J10.A36_CODE,3))='US$'  
						--THEN 
							ISNULL(D28_DEV.D28_009_B, 0)
						--ELSE 
						--	ISNULL(D28_DEV.D28_006_B, 0)
						--END 	
					END
				END AS CustoMedioUnPeso,
				--Atividade PRIME-1848 - Fim
			CASE WHEN (J10.J10_002_N = 1) 
			THEN
				ISNULL(D28.D28_006_B, 0)
			ELSE
				-- SE A NF DE DEV. NAO GEROU ESTOQUE
				CASE WHEN D14.UKEY IS NULL
				THEN
					0
				ELSE			
					ISNULL(D28_DEV.D28_006_B, 0)
				END
			END * J11.J11_003_B AS CustoMedioTotal,		
			--Atividade PRIME-1848 - Inicio
			CASE WHEN (J10.J10_002_N = 1) 
				THEN
					--CASE WHEN RTRIM(LEFT(J10.A36_CODE,3))='US$'  
					--THEN 
						ISNULL(D28.D28_009_B, 0)
					--ELSE 
					--	ISNULL(D28.D28_006_B, 0)
					--END 
				ELSE
					-- SE A NF DE DEV. NAO GEROU ESTOQUE
					CASE WHEN D14.UKEY IS NULL
					THEN
						0
					ELSE				
						--CASE WHEN RTRIM(LEFT(J10.A36_CODE,3))='US$'  
						--THEN 
							ISNULL(D28_DEV.D28_009_B, 0)
						--ELSE 
						--	ISNULL(D28_DEV.D28_006_B, 0)
						--END 	
					END
				END * J11.J11_003_B AS CustoMedioTotalPeso,	
				--Atividade PRIME-1848 - Fim		
			CASE WHEN (J10.J10_002_N = 1) 
			THEN
				ISNULL(D28.D28_009_B, 0)
			ELSE
				-- SE A NF DE DEV. NAO GEROU ESTOQUE
				CASE WHEN D14.UKEY IS NULL
				THEN
					0
				ELSE			
					ISNULL(D28_DEV.D28_009_B, 0)
				END
			END AS CustoMedioUnUSD,
			CASE WHEN (J10.J10_002_N = 1) 
			THEN
				ISNULL(D28.D28_009_B, 0)
			ELSE
				-- SE A NF DE DEV. NAO GEROU ESTOQUE
				CASE WHEN D14.UKEY IS NULL
				THEN
					0
				ELSE			
					ISNULL(D28_DEV.D28_009_B, 0)
				END
			END * J11.J11_003_B AS CustoMedioTotalUSD,							
			   CASE WHEN (J10.J10_002_N = 1) THEN ISNULL(J15.J15_002_B,0) ELSE (ISNULL(J15.J15_002_B,0) / J11_DEV.J11_003_B) * J11.J11_003_B END AS ProvisaoComissaoRevenda,
				CASE WHEN T04.T04_001_C='S01.95W8' OR J11.J11_005_B=0 OR T04.T04_503_N = 1
				THEN 
					0 
				ELSE  
					(CASE WHEN (J10.J10_002_N = 1) THEN ISNULL(J15.J15_002_B,0) ELSE (ISNULL(J15.J15_002_B,0) / J11_DEV.J11_003_B) * J11.J11_003_B END / (1 - 0.0925 - ISNULL ((TabICMS.ICMS), 0) / (J11.J11_003_B * J11.J11_005_B)) + J11.J11_003_B * J11.J11_005_B) 
				END AS TotalRevendaAntesComissao, 
				ISNULL(TabICMS.ICMS,0) AS ICMS, 
			CASE WHEN T04.T04_001_C='S01.20W8' or T04.T04_001_C='S01.12W8'
			THEN 
				0 
			ELSE
				ISNULL(TabPIS.PIS,0)  
			END AS PIS,
			CASE WHEN T04.T04_001_C='S01.20W8' or T04.T04_001_C='S01.12W8'
			THEN 
				0 
			ELSE
				ISNULL(TabCOFINS.COFINS,0) 
			END AS COFINS, 
			ISNULL(TabIRRF.IRRF,0) AS IRRF, 
			ISNULL(TabCSLL.CSLL,0) AS CSLL,
			ISNULL(TabIPI.IPI,0) AS IPI,
			ISNULL(TabISS.ISS,0) AS ISS,
			ISNULL(TabICMSST.ICMSST,0) AS ICMSST,
			ISNULL(TabIVA.IVA,0) AS IVA,	
			0 AS SalesTax,						
		   A23.A23_002_C AS Estado,
		   A24.A24_001_C AS Cidade, 
		   isnull(A33.A33_003_C,A33_DEV.A33_003_C) AS VENDEDOR,		
		isnull(J10_DEV.J10_001_C,'') AS NFDevolvida,
		J10.UKEY as J10_UKEY,
		J10.J09_UKEY,
		J10.CIA_UKEY as CIA_UKEY,
		A03.UKEY as A03_UKEY,
		J10.A36_CODE,
		RTRIM(LEFT(J10.A36_CODE,5)) AS Currency,
		CASE WHEN RTRIM(LEFT(J10.A36_CODE,5)) = RTRIM(LEFT(J07.A36_CODE,5))
		THEN 
			-- Se a moeda do pedido e nf forem iguais, não tem tx
			1 
		WHEN
			ISNULL(J07.A36_CODE,'') <> '' AND RTRIM(LEFT(J07.A36_CODE,5)) <> 'US$  ' 
		THEN
			-- Se o pedido tiver US$ específico, uso a data de emissão do pedido para buscar a tx
			(
				SELECT TOP 1 A37_002_B 
				FROM StarWestcon.dbo.A37 A37 (NoLock)
				WHERE A36_UKEYA='R$   '
				AND A36_UKEY=LEFT(J07.A36_CODE,5)
				AND A37_001_D= CONVERT(varchar(8),J07.J07_003_D,112)
			) 			
		ELSE
			-- Se não tiver ov para a nf, busco a tx do US$ na data do faturamento
			(
				SELECT TOP 1 A37_002_B 
				FROM StarWestcon.dbo.A37 A37 (NoLock)
				WHERE A36_UKEYA='R$   '
				AND A36_UKEY='US$  '
				AND A37_001_D=J10.J10_003_D
			) 
		END USDRate,
			[Westcon].[StarSoft].[FN_GetOVGlobalCode](J07.J07_001_C,1) AS CodPedido,
			1 AS CodERP,
			(
				RTRIM(LTRIM(A03_005_C)) + -- ENDERECO
				CASE WHEN ISNULL(A03_005_C,'') <> '' THEN ', ' + RTRIM(LTRIM(A03_014_C)) ELSE '' END -- NUMERO
			)AS EnderecoFatura,	
			A03_004_C as BairroFatura,			
			A03_006_C as CEPFatura,
			A22_001_C as PaisFatura,
CASE WHEN J10.J10_002_N = 1 THEN 
    CASE WHEN SUBSTRING(LTRIM(ISNULL(T04.T04_001_C,'')),1,3) = 'S10' THEN 'SERVICE' ELSE 'PRODUCT' END 
 ELSE 
    CASE WHEN SUBSTRING(LTRIM(ISNULL((SELECT T04_001_C FROM StarWestcon.dbo.T04 T04_ORG WHERE T04_ORG.UKEY = (SELECT J11_ORG.T04_UKEY FROM StarWestcon.dbo.J11 J11_ORG WHERE J11_ORG.UKEY = J11_DEV.UKEY)),'')),1,3) = 'S10' THEN 'SERVICE' ELSE 'PRODUCT' END 

END AS RevenueType,	
			--CASE WHEN SUBSTRING(LTRIM(ISNULL(T04.T04_001_C,'')),1,3) = 'S10' THEN 'SERVICE' ELSE 'PRODUCT' END AS RevenueType,
			[Westcon].[StarSoft].[fnGetPOBillingAtWMS](CASE WHEN J10.J10_002_N = 1 THEN J11.UKEY ELSE J11_DEV.UKEY END) AS POEFETIVA,
			J11.J11_998_C AS InvoiceLineNumber,
		-- Se for devolução de venda o fator será negativo
		CASE WHEN J10.J10_002_N = 1 AND T04.T04_001_C <> 'E90.04W8' THEN 1 ELSE -1 END AS FATOR,
		T04.T04_503_N AS COMPLEMENT,
		J11.UKEY AS J11_UKEY,
		CASE A03.A03_504_N WHEN 1 THEN 'No' WHEN 2 THEN 'Intercompany' WHEN 3 THEN 'Related' END AS Intercompany,
		ISNULL(
			(	
			SELECT SUM(J15_002_B) AS J15_002_B
			FROM StarWestcon.dbo.J15 (NOLOCK) 
			WHERE CASE WHEN (J10.J10_002_N = 1) THEN J11.UKEY ELSE J11_DEV.UKEY END = J15.J15_UKEYP AND J15.J15_500_N = 2 -- INDICA QUE É A COMISSÃO DE MKT
		),0) AS VendorMKT, 
		ISNULL(
			(	
			SELECT SUM(J15_002_B) AS J15_002_B
			FROM StarWestcon.dbo.J15 (NOLOCK) 
			WHERE CASE WHEN (J10.J10_002_N = 1) THEN J11.UKEY ELSE J11_DEV.UKEY END = J15.J15_UKEYP AND J15.J15_500_N = 1 -- INDICA QUE É A COMISSÃO DE FIDELIZAÇÃO
		),0) AS ResselerMKT,
			J08.J08_INTRANETUKEY AS ID_INTRANET,
		CASE WHEN J10.J10_046_B=0 THEN 1 ELSE J10.J10_046_B END  AS TAX1,  
		ISNULL((SELECT TOP 1 A37_002_B 
				FROM StarWestcon.dbo.A37 A37 (NOLOCK)
				WHERE A36_UKEYA=(SELECT CIA.A36_UKEY FROM StarWestcon.DBO.CIA (NOLOCK) WHERE CIA.UKEY = J10.CIA_UKEY)
				AND A36_UKEY=LEFT(J10.A36_CODE,5)
				AND A37_001_D= CONVERT(VARCHAR(8),J10.J10_003_D,112)
			),1)  AS TAX2, 
		 (SELECT CIA.A36_UKEY FROM StarWestcon.DBO.CIA (NOLOCK) WHERE CIA.UKEY = J10.CIA_UKEY) AS CURRENCY_CIA,
		 D03PAI.D03_002_C AS FABRICANTE,
		 D03FILHO.D03_002_C AS FAMILIA, 
		 D04_501_N AS MAINTENANCE, -- PRIME-902 
		 D04_502_N AS CLOUD --PRIME-916

	FROM            StarWestcon.dbo.J10 J10 (NOLOCK) 
	INNER JOIN      StarWestcon.dbo.A03 A03 (NOLOCK) ON J10.A03_UKEY = A03.UKEY 
	INNER JOIN      StarWestcon.dbo.J11 J11 (NOLOCK) ON J10.UKEY = J11.J10_UKEY
	INNER JOIN      StarWestcon.dbo.T04 T04 (NOLOCK) ON J11.T04_UKEY = T04.UKEY 
	INNER JOIN      StarWestcon.dbo.D04 D04 (NOLOCK) ON J11.D04_UKEY = D04.UKEY 
	LEFT JOIN       StarWestcon.dbo.D03 D03FILHO (NOLOCK) ON D04.D03_UKEY = D03FILHO.UKEY 
	LEFT JOIN       StarWestcon.dbo.D03 D03PAI (NOLOCK) ON D03FILHO.D03_UKEY = D03PAI.UKEY 
	LEFT OUTER JOIN StarWestcon.dbo.D22 D22 (NOLOCK) ON J11.UKEY = D22.D22_IUKEYP
	LEFT OUTER JOIN StarWestcon.dbo.D28 D28 (NOLOCK) ON D22.UKEY = D28.D28_UKEYP
	LEFT OUTER JOIN StarWestcon.dbo.D14 D14 (NOLOCK) ON J11.UKEY = D14.D14_IUKEYP
	LEFT OUTER JOIN StarWestcon.dbo.D28 D28_1 (NOLOCK) ON D14.UKEY = D28_1.D28_UKEYP
	LEFT OUTER JOIN StarWestcon.dbo.J11 J11_DEV (nolock) ON J11.J11_UKEYP = J11_DEV.UKEY
	LEFT OUTER JOIN StarWestcon.dbo.D22 D22_DEV WITH (NOLOCK) ON J11_DEV.UKEY = D22_DEV.D22_IUKEYP
	LEFT OUTER JOIN StarWestcon.dbo.D28 D28_DEV WITH (NOLOCK) ON D22_DEV.UKEY = D28_DEV.D28_UKEYP 		
	LEFT OUTER JOIN StarWestcon.dbo.J10 J10_DEV (nolock) ON J11_DEV.J10_UKEY = J10_DEV.UKEY
	LEFT OUTER JOIN StarWestcon.dbo.A33 A33_DEV (NOLOCK) ON J10_DEV.A33_UKEY = A33_DEV.UKEY
		--SCRUM-15463 - INICIO
	LEFT OUTER JOIN StarWestcon.dbo.J08 J08 (NOLOCK) ON 
													CASE 
														WHEN (J11.J08_UKEYWE <> '' AND @CanceledInvoices = 1) 
															THEN 'J08' 
														WHEN (J10.J10_002_N = 1) 
															THEN J11.J11_PAR 
															ELSE J11_DEV.J11_PAR END
														 ='J08' and 
													CASE 
														WHEN (J11.J08_UKEYWE <> '' AND @CanceledInvoices = 1) 
															THEN J11.J08_UKEYWE 
														WHEN (J10.J10_002_N = 1) 
															THEN J11.J11_UKEYP 
															ELSE J11_DEV.J11_UKEYP END
													 =J08.UKEY 
	--SCRUM-15463 - FIM

	LEFT OUTER JOIN StarWestcon.dbo.J07 J07 (NOLOCK) ON J08.J07_UKEY=J07.UKEY
	LEFT OUTER JOIN (	
						SELECT SUM(J15_002_B) AS J15_002_B,  J15.J15_UKEYP
						FROM StarWestcon.dbo.J15 (NOLOCK) 
						WHERE J15.J15_500_N = 0 -- INDICA QUE É A COMISSÃO DA NF E NÃO É UMA COMISSO DE MKT NEM FIDELIZAÇÃO
						GROUP BY  J15.J15_UKEYP
					) J15 ON CASE WHEN (J10.J10_002_N = 1) THEN J11.UKEY ELSE J11_DEV.UKEY END = J15.J15_UKEYP 
	LEFT OUTER JOIN StarWestcon.dbo.A22 A22 (NOLOCK) ON A03.A22_UKEY = A22.UKEY 					   
	LEFT OUTER JOIN StarWestcon.dbo.A23 A23 (NOLOCK) ON A03.A23_UKEY = A23.UKEY
	LEFT OUTER JOIN StarWestcon.dbo.A24 A24 (NOLOCK) ON A03.A24_UKEY = A24.UKEY 
	LEFT OUTER JOIN StarWestcon.dbo.A33 A33 (NOLOCK) ON J10.A33_UKEY = A33.UKEY 
	LEFT OUTER JOIN	(SELECT J22.J22_UKEYP,SUM(ISNULL(J22.J22_004_B+ J22.J22_049_B + J22.J22_050_B,0)) AS ICMS
					FROM StarWestcon.dbo.J22 J22 (NOLOCK)
			WHERE J22.A40_UKEY=(select UKEY FROM StarWestcon.dbo.A40 A40 (NOLOCK) 
					WHERE A40.A40_001_C='ICMS')
			GROUP BY J22.J22_UKEYP) TabICMS 
				ON J11.UKEY=TabICMS.J22_UKEYP
	LEFT OUTER JOIN	(SELECT J22.J22_UKEYP,SUM(ISNULL(J22.J22_004_B,0)) AS IPI
					FROM StarWestcon.dbo.J22 J22 (NOLOCK)
			WHERE J22.A40_UKEY=(select UKEY FROM StarWestcon.dbo.A40 A40 (NOLOCK) 
					WHERE A40.A40_001_C='IPI')
			GROUP BY J22.J22_UKEYP) TabIPI 
				ON J11.UKEY=TabIPI.J22_UKEYP
	LEFT OUTER JOIN	(SELECT J22.J22_UKEYP,SUM(ISNULL(J22.J22_004_B,0)) AS IRRF
					FROM StarWestcon.dbo.J22 J22 (NOLOCK)
			WHERE J22.A40_UKEY=(select UKEY FROM StarWestcon.dbo.A40 A40 (NOLOCK) 
					WHERE A40.A40_001_C='IRRF')
			GROUP BY J22.J22_UKEYP) TabIRRF 
				ON J11.UKEY=TabIRRF.J22_UKEYP
	LEFT OUTER JOIN	(SELECT J22.J22_UKEYP,SUM(ISNULL(J22.J22_004_B,0)) AS CSLL
					FROM StarWestcon.dbo.J22 J22 (NOLOCK)
			WHERE J22.A40_UKEY=(select UKEY FROM StarWestcon.dbo.A40 A40 (NOLOCK) 
					WHERE A40.A40_001_C='CSLL')
			GROUP BY J22.J22_UKEYP) TabCSLL 
				ON J11.UKEY=TabCSLL.J22_UKEYP
	LEFT OUTER JOIN	(SELECT J22.J22_UKEYP,SUM(ISNULL(J22.J22_004_B,0)) AS ICMSST
					FROM StarWestcon.dbo.J22 J22 (NOLOCK)
			WHERE J22.A40_UKEY=(select UKEY FROM StarWestcon.dbo.A40 A40 (NOLOCK) 
					WHERE A40.A40_001_C='ICMS_ST')
			GROUP BY J22.J22_UKEYP) TabICMSST 
				ON J11.UKEY=TabICMSST.J22_UKEYP
	LEFT OUTER JOIN	(SELECT J22.J22_UKEYP,SUM(ISNULL(J22.J22_004_B,0)) AS IVA
					FROM StarWestcon.dbo.J22 J22 (NOLOCK)
			WHERE J22.A40_UKEY=(select UKEY FROM StarWestcon.dbo.A40 A40 (NOLOCK) 
					WHERE A40.A40_001_C='IVA')
			GROUP BY J22.J22_UKEYP) TabIVA
				ON J11.UKEY=TabIVA.J22_UKEYP
	LEFT OUTER JOIN	(
						SELECT J22.J22_UKEYP,SUM(ISNULL(J22.J22_004_B,0)) AS PIS
						FROM StarWestcon.dbo.J22 J22 (NOLOCK)
						WHERE J22.A40_UKEY=(select UKEY FROM StarWestcon.dbo.A40 A40 (NOLOCK) WHERE A40.A40_001_C='PIS')
						GROUP BY J22.J22_UKEYP
					) TabPIS ON J11.UKEY=TabPIS.J22_UKEYP	
	LEFT OUTER JOIN	(
						SELECT J22.J22_UKEYP,SUM(ISNULL(J22.J22_004_B,0)) AS COFINS
						FROM StarWestcon.dbo.J22 J22 (NOLOCK)
						WHERE J22.A40_UKEY=(select UKEY FROM StarWestcon.dbo.A40 A40 (NOLOCK) WHERE A40.A40_001_C='COFINS')
						GROUP BY J22.J22_UKEYP
					) TabCOFINS ON J11.UKEY=TabCOFINS.J22_UKEYP	
	LEFT OUTER JOIN	(
						SELECT J22.J22_UKEYP,SUM(ISNULL(J22.J22_004_B,0)) AS ISS
						FROM StarWestcon.dbo.J22 J22 (NOLOCK)
						WHERE J22.A40_UKEY=(select UKEY FROM StarWestcon.dbo.A40 A40 (NOLOCK) WHERE A40.A40_001_C='ISS')
						GROUP BY J22.J22_UKEYP
					) TabISS ON J11.UKEY=TabISS.J22_UKEYP					
				
	WHERE J10.CIA_UKEY = 'XY5JG' AND
		(
			(
				J10.J10_002_N <> 2  
				AND T04.T04_001_C <> 'E90.04W8'
				AND J10.J10_003_D >= @FromYYYYMMDD--CONVERT(DATETIME, @FromYYYYMMDD + ' 00:00:00', 102) 
				AND J10.J10_003_D <= @ToYYYYMMDD--CONVERT(DATETIME, @ToYYYYMMDD + ' 23:59:59', 102) 
			)
			OR (
				J10.J10_002_N = 2 
				AND J10.J10_014_D >= @FromYYYYMMDD--CONVERT(DATETIME, @FromYYYYMMDD + ' 00:00:00', 102) 
				AND J10.J10_014_D <= @ToYYYYMMDD--CONVERT(DATETIME, @ToYYYYMMDD + ' 23:59:59', 102) 
			)
		)

		AND 

		--SCRUM-15463 - inicio
		((@CanceledInvoices= 0 and J10.J10_032_N = 0) or (@CanceledInvoices= 1 and J10.J10_032_N = 1 and  cast(isnull(j10.j10_111_t,j10.timestamp) as date) <> cast(isnull(j10.j10_003_d,'') as date)  ) )
		--SCRUM-15463 - fim

		AND T04_501_N = 1
		AND J10.Array_736 <> 1
		AND J11.I14_UKEY IS NULL 
		AND J11_DEV.I14_UKEY IS NULL

	UNION ALL
	-- PARTE : AFINA
	SELECT     J07.J07_001_C AS PedidoVenda, 
			   [Westcon].[StarSoft].[FN_GetOVGlobalCode](J07.J07_001_C,2) AS PedidoVendaTrimmed,
			   J10.J10_001_C AS NF,
			   T04.T04_001_C AS TipoES,
			   CONVERT(smalldatetime, CASE WHEN ((J10.J10_002_N <> 2) AND T04.T04_001_C <> 'E90.04W8') 
										   THEN J10.J10_003_D 
										   ELSE J10.J10_014_D END) AS EmissaoNF, 
	 		   D04.D04_001_C AS PartNumber,
			   A03.A03_001_C AS CNPJEmpresaNF,
			   A03.A03_003_C AS EmpresaNF,
				-- SE FOR UMA NF DE COMPLEMENTO, DEVO DEIXAR O CAMPO QTD SEMPRE COM O VALOR 1 E OS CAMPOS ValorUnitarioNF E TotalItemNF 
				-- COM O VALOR DA SOMA DOS IMPOSTOS ICMSST E IPI (O CAMPO T04_503_N = 1 INDICA QUE É UM TIPO DE E/S PARA NF COMPLEMENTAR)
				--SCRUM-15463 - INICIO
				CASE WHEN J10.J10_032_N = 1  and (rtrim(isnull(D03PAI.D03_002_C,'')) = 'CISCO' or rtrim(isnull(D03PAI.D03_002_C,'')) = 'CISCO BR') THEN (CASE WHEN T04.T04_503_N = 1 THEN 1 ELSE J11.J11_003_B END )*-1 ELSE (CASE WHEN T04.T04_503_N = 1 THEN 1 ELSE J11.J11_003_B END) END AS Qtd,
				--SCRUM-15463 - FIM
				CASE WHEN T04.T04_503_N = 1 THEN ISNULL(TabIPI.IPI,0) + ISNULL(TabICMSST.ICMSST,0) ELSE J11.J11_005_B END AS ValorUnitarioNF,
				CASE WHEN T04.T04_503_N = 1 THEN ISNULL(TabIPI.IPI,0) + ISNULL(TabICMSST.ICMSST,0) ELSE J11.J11_006_B END AS TotalItemNF,				
				CASE WHEN (J10.J10_002_N = 1) 
				THEN
					ISNULL(D28.D28_006_B, 0)
				ELSE
					-- SE A NF DE DEV. NAO GEROU ESTOQUE
					CASE WHEN D14.UKEY IS NULL
					THEN
						0
					ELSE			
						ISNULL(D28_DEV.D28_006_B, 0)
					END
				END AS CustoMedioUn,
				--Atividade PRIME-1848 - Inicio
				CASE WHEN (J10.J10_002_N = 1) 
				THEN
					--CASE WHEN RTRIM(LEFT(J10.A36_CODE,3))='US$'  
					--THEN 
						ISNULL(D28.D28_009_B, 0)
					--ELSE 
					--	ISNULL(D28.D28_006_B, 0)
					--END 
				ELSE
					-- SE A NF DE DEV. NAO GEROU ESTOQUE
					CASE WHEN D14.UKEY IS NULL
					THEN
						0
					ELSE				
						--CASE WHEN RTRIM(LEFT(J10.A36_CODE,3))='US$'  
						--THEN 
							ISNULL(D28_DEV.D28_009_B, 0)
						--ELSE 
						--	ISNULL(D28_DEV.D28_006_B, 0)
						--END 	
					END
				END AS CustoMedioUnPeso,
				--Atividade PRIME-1848 - Fim
			CASE WHEN (J10.J10_002_N = 1) 
			THEN
				ISNULL(D28.D28_006_B, 0)
			ELSE
				-- SE A NF DE DEV. NAO GEROU ESTOQUE
				CASE WHEN D14.UKEY IS NULL
				THEN
					0
				ELSE			
					ISNULL(D28_DEV.D28_006_B, 0)
				END
			END * J11.J11_003_B AS CustoMedioTotal,	
			--Atividade PRIME-1848 - Inicio	
			CASE WHEN (J10.J10_002_N = 1) 
				THEN
					--CASE WHEN RTRIM(LEFT(J10.A36_CODE,3))='US$'  
					--THEN 
						ISNULL(D28.D28_009_B, 0)
					--ELSE 
					--	ISNULL(D28.D28_006_B, 0)
					--END 
				ELSE
					-- SE A NF DE DEV. NAO GEROU ESTOQUE
					CASE WHEN D14.UKEY IS NULL
					THEN
						0
					ELSE				
						--CASE WHEN RTRIM(LEFT(J10.A36_CODE,3))='US$'  
						--THEN 
							ISNULL(D28_DEV.D28_009_B, 0)
						--ELSE 
						--	ISNULL(D28_DEV.D28_006_B, 0)
						--END 	
					END
				END * J11.J11_003_B AS CustoMedioTotalPeso,	
				--Atividade PRIME-1848 - Fim		
			CASE WHEN (J10.J10_002_N = 1) 
			THEN
				ISNULL(D28.D28_009_B, 0)
			ELSE
				-- SE A NF DE DEV. NAO GEROU ESTOQUE
				CASE WHEN D14.UKEY IS NULL
				THEN
					0
				ELSE			
					ISNULL(D28_DEV.D28_009_B, 0)
				END
			END AS CustoMedioUnUSD,
			CASE WHEN (J10.J10_002_N = 1) 
			THEN
				ISNULL(D28.D28_009_B, 0)
			ELSE
				-- SE A NF DE DEV. NAO GEROU ESTOQUE
				CASE WHEN D14.UKEY IS NULL
				THEN
					0
				ELSE			
					ISNULL(D28_DEV.D28_009_B, 0)
				END
			END * J11.J11_003_B AS CustoMedioTotalUSD,		
			   CASE WHEN (J10.J10_002_N = 1) THEN ISNULL(J15.J15_002_B,0) ELSE (ISNULL(J15.J15_002_B,0) / J11_DEV.J11_003_B) * J11.J11_003_B END AS ProvisaoComissaoRevenda,
				CASE WHEN T04.T04_001_C='S01.95W8' OR J11.J11_005_B=0 OR T04.T04_503_N = 1
				THEN 
					0 
				ELSE  
					(CASE WHEN (J10.J10_002_N = 1) THEN ISNULL(J15.J15_002_B,0) ELSE (ISNULL(J15.J15_002_B,0) / J11_DEV.J11_003_B) * J11.J11_003_B END / (1 - 0.0925 - ISNULL ((TabICMS.ICMS), 0) / (J11.J11_003_B * J11.J11_005_B)) + J11.J11_003_B * J11.J11_005_B) 
				END AS TotalRevendaAntesComissao, 
				ISNULL(TabICMS.ICMS,0) AS ICMS, 
			CASE WHEN T04.T04_001_C='S01.20W8' or T04.T04_001_C='S01.12W8'
			THEN 
				0 
			ELSE
				ISNULL(TabPIS.PIS,0)  
			END AS PIS,
			CASE WHEN T04.T04_001_C='S01.20W8' or T04.T04_001_C='S01.12W8'
			THEN 
				0 
			ELSE
				ISNULL(TabCOFINS.COFINS,0) 
			END AS COFINS, 
			ISNULL(TabIRRF.IRRF,0) AS IRRF, 
			ISNULL(TabCSLL.CSLL,0) AS CSLL,
			ISNULL(TabIPI.IPI,0) AS IPI,
			ISNULL(TabISS.ISS,0) AS ISS,
			ISNULL(TabICMSST.ICMSST,0) AS ICMSST,
			ISNULL(TabIVA.IVA,0) AS IVA,	
			0 AS SalesTax,						
		   A23.A23_002_C AS Estado,
		   A24.A24_001_C AS Cidade, 
		   isnull(A33.A33_003_C,A33_DEV.A33_003_C) AS VENDEDOR,		
		isnull(J10_DEV.J10_001_C,'') AS NFDevolvida,
		J10.UKEY as J10_UKEY,
		J10.J09_UKEY,
		J10.CIA_UKEY as CIA_UKEY,
		A03.UKEY as A03_UKEY,
		J10.A36_CODE,
		RTRIM(LEFT(J10.A36_CODE,5)) AS Currency,
		CASE WHEN RTRIM(LEFT(J10.A36_CODE,5)) = RTRIM(LEFT(J07.A36_CODE,5))
		THEN 
			-- Se a moeda do pedido e nf forem iguais, não tem tx
			1 
		WHEN
			ISNULL(J07.A36_CODE,'') <> '' AND RTRIM(LEFT(J07.A36_CODE,5)) <> 'US$  ' 
		THEN
			-- Se o pedido tiver US$ específico, uso a data de emissão do pedido para buscar a tx
			(
				SELECT TOP 1 A37_002_B 
				FROM StarWestcon.dbo.A37 A37 (NoLock)
				WHERE A36_UKEYA='R$   '
				AND A36_UKEY=LEFT(J07.A36_CODE,5)
				AND A37_001_D= CONVERT(varchar(8),J07.J07_003_D,112)
			) 			
		ELSE
			-- Se não tiver ov para a nf, busco a tx do US$ na data do faturamento
			(
				SELECT TOP 1 A37_002_B 
				FROM StarWestcon.dbo.A37 A37 (NoLock)
				WHERE A36_UKEYA='R$   '
				AND A36_UKEY='US$  '
				AND A37_001_D=J10.J10_003_D
			) 
		END USDRate,
			[Westcon].[StarSoft].[FN_GetOVGlobalCode](J07.J07_001_C,1) AS CodPedido,
			1 AS CodERP,
			(
				RTRIM(LTRIM(A03_005_C)) + -- ENDERECO
				CASE WHEN ISNULL(A03_005_C,'') <> '' THEN ', ' + RTRIM(LTRIM(A03_014_C)) ELSE '' END -- NUMERO
			)AS EnderecoFatura,	
			A03_004_C as BairroFatura,			
			A03_006_C as CEPFatura,
			A22_001_C as PaisFatura,
CASE WHEN J10.J10_002_N = 1 THEN 
    CASE WHEN SUBSTRING(LTRIM(ISNULL(T04.T04_001_C,'')),1,3) = 'S10' THEN 'SERVICE' ELSE 'PRODUCT' END 
 ELSE 
    CASE WHEN SUBSTRING(LTRIM(ISNULL((SELECT T04_001_C FROM StarWestcon.dbo.T04 T04_ORG WHERE T04_ORG.UKEY = (SELECT J11_ORG.T04_UKEY FROM StarWestcon.dbo.J11 J11_ORG WHERE J11_ORG.UKEY = J11_DEV.UKEY)),'')),1,3) = 'S10' THEN 'SERVICE' ELSE 'PRODUCT' END 

END AS RevenueType,	
			--CASE WHEN SUBSTRING(LTRIM(ISNULL(T04.T04_001_C,'')),1,3) = 'S10' THEN 'SERVICE' ELSE 'PRODUCT' END AS RevenueType,
			[Westcon].[StarSoft].[fnGetPOBillingAtWMS](CASE WHEN J10.J10_002_N = 1 THEN J11.UKEY ELSE J11_DEV.UKEY END) AS POEFETIVA,
			J11.J11_998_C AS InvoiceLineNumber,
		-- Se for devolução de venda o fator será negativo
		CASE WHEN J10.J10_002_N = 1 AND T04.T04_001_C <> 'E90.04W8' THEN 1 ELSE -1 END AS FATOR,
		T04.T04_503_N AS COMPLEMENT,
		J11.UKEY AS J11_UKEY,
		CASE A03.A03_504_N WHEN 1 THEN 'No' WHEN 2 THEN 'Intercompany' WHEN 3 THEN 'Related' END AS Intercompany,
		ISNULL(
			(	
			SELECT SUM(J15_002_B) AS J15_002_B
			FROM StarWestcon.dbo.J15 (NOLOCK) 
			WHERE CASE WHEN (J10.J10_002_N = 1) THEN J11.UKEY ELSE J11_DEV.UKEY END = J15.J15_UKEYP AND J15.J15_500_N = 2 -- INDICA QUE É A COMISSÃO DE MKT
		),0) AS VendorMKT, 
		ISNULL(
			(	
			SELECT SUM(J15_002_B) AS J15_002_B
			FROM StarWestcon.dbo.J15 (NOLOCK) 
			WHERE CASE WHEN (J10.J10_002_N = 1) THEN J11.UKEY ELSE J11_DEV.UKEY END = J15.J15_UKEYP AND J15.J15_500_N = 1 -- INDICA QUE É A COMISSÃO DE FIDELIZAÇÃO
		),0) AS ResselerMKT,
			J08.J08_INTRANETUKEY AS ID_INTRANET,
		CASE WHEN J10.J10_046_B=0 THEN 1 ELSE J10.J10_046_B END  AS TAX1,  
		ISNULL((SELECT TOP 1 A37_002_B 
				FROM StarWestcon.dbo.A37 A37 (NOLOCK)
				WHERE A36_UKEYA=(SELECT CIA.A36_UKEY FROM StarWestcon.DBO.CIA (NOLOCK) WHERE CIA.UKEY = J10.CIA_UKEY)
				AND A36_UKEY=LEFT(J10.A36_CODE,5)
				AND A37_001_D= CONVERT(VARCHAR(8),J10.J10_003_D,112)
			),1)  AS TAX2, 
		 (SELECT CIA.A36_UKEY FROM StarWestcon.DBO.CIA (NOLOCK) WHERE CIA.UKEY = J10.CIA_UKEY) AS CURRENCY_CIA,
		 D03PAI.D03_002_C AS FABRICANTE,
		 D03FILHO.D03_002_C AS FAMILIA, 
		D04_501_N AS MAINTENANCE, -- PRIME-902 
		D04_502_N AS CLOUD --PRIME-916

	FROM            StarWestcon.dbo.J10 J10 (NOLOCK) 
	INNER JOIN      StarWestcon.dbo.A03 A03 (NOLOCK) ON J10.A03_UKEY = A03.UKEY 
	INNER JOIN      StarWestcon.dbo.J11 J11 (NOLOCK) ON J10.UKEY = J11.J10_UKEY
	INNER JOIN      StarWestcon.dbo.T04 T04 (NOLOCK) ON J11.T04_UKEY = T04.UKEY 
	INNER JOIN      StarWestcon.dbo.D04 D04 (NOLOCK) ON J11.D04_UKEY = D04.UKEY 
	LEFT JOIN       StarWestcon.dbo.D03 D03FILHO (NOLOCK) ON D04.D03_UKEY = D03FILHO.UKEY 
	LEFT JOIN       StarWestcon.dbo.D03 D03PAI (NOLOCK) ON D03FILHO.D03_UKEY = D03PAI.UKEY 
	LEFT OUTER JOIN StarWestcon.dbo.D22 D22 (NOLOCK) ON J11.UKEY = D22.D22_IUKEYP
	LEFT OUTER JOIN StarWestcon.dbo.D28 D28 (NOLOCK) ON D22.UKEY = D28.D28_UKEYP
	LEFT OUTER JOIN StarWestcon.dbo.D14 D14 (NOLOCK) ON J11.UKEY = D14.D14_IUKEYP
	LEFT OUTER JOIN StarWestcon.dbo.D28 D28_1 (NOLOCK) ON D14.UKEY = D28_1.D28_UKEYP
	LEFT OUTER JOIN StarWestcon.dbo.J11 J11_DEV (nolock) ON J11.J11_UKEYP = J11_DEV.UKEY
	LEFT OUTER JOIN StarWestcon.dbo.D22 D22_DEV WITH (NOLOCK) ON J11_DEV.UKEY = D22_DEV.D22_IUKEYP
	LEFT OUTER JOIN StarWestcon.dbo.D28 D28_DEV WITH (NOLOCK) ON D22_DEV.UKEY = D28_DEV.D28_UKEYP 		
	LEFT OUTER JOIN StarWestcon.dbo.J10 J10_DEV (nolock) ON J11_DEV.J10_UKEY = J10_DEV.UKEY
	LEFT OUTER JOIN StarWestcon.dbo.A33 A33_DEV (NOLOCK) ON J10_DEV.A33_UKEY = A33_DEV.UKEY
	--SCRUM-15463 - INICIO
	LEFT OUTER JOIN StarWestcon.dbo.J08 J08 (NOLOCK) ON 
													CASE 
														WHEN (J11.J08_UKEYWE <> '' AND @CanceledInvoices = 1) 
															THEN 'J08' 
														WHEN (J10.J10_002_N = 1) 
															THEN J11.J11_PAR 
															ELSE J11_DEV.J11_PAR END
														 ='J08' and 
													CASE 
														WHEN (J11.J08_UKEYWE <> '' AND @CanceledInvoices = 1) 
															THEN J11.J08_UKEYWE 
														WHEN (J10.J10_002_N = 1) 
															THEN J11.J11_UKEYP 
															ELSE J11_DEV.J11_UKEYP END
													 =J08.UKEY 
	--SCRUM-15463 - FIM

	LEFT OUTER JOIN StarWestcon.dbo.J07 J07 (NOLOCK) ON J08.J07_UKEY=J07.UKEY
	LEFT OUTER JOIN (	
						SELECT SUM(J15_002_B) AS J15_002_B,  J15.J15_UKEYP
						FROM StarWestcon.dbo.J15 (NOLOCK) 
						WHERE J15.J15_500_N = 0 -- INDICA QUE É A COMISSÃO DA NF E NÃO É UMA COMISSO DE MKT NEM FIDELIZAÇÃO
						GROUP BY  J15.J15_UKEYP
					) J15 ON CASE WHEN (J10.J10_002_N = 1) THEN J11.UKEY ELSE J11_DEV.UKEY END = J15.J15_UKEYP 
	LEFT OUTER JOIN StarWestcon.dbo.A22 A22 (NOLOCK) ON A03.A22_UKEY = A22.UKEY 					   
	LEFT OUTER JOIN StarWestcon.dbo.A23 A23 (NOLOCK) ON A03.A23_UKEY = A23.UKEY
	LEFT OUTER JOIN StarWestcon.dbo.A24 A24 (NOLOCK) ON A03.A24_UKEY = A24.UKEY 
	LEFT OUTER JOIN StarWestcon.dbo.A33 A33 (NOLOCK) ON J10.A33_UKEY = A33.UKEY 
	LEFT OUTER JOIN	(SELECT J22.J22_UKEYP,SUM(ISNULL(J22.J22_004_B+ J22.J22_049_B + J22.J22_050_B,0)) AS ICMS
					FROM StarWestcon.dbo.J22 J22 (NOLOCK)
			WHERE J22.A40_UKEY=(select UKEY FROM StarWestcon.dbo.A40 A40 (NOLOCK) 
					WHERE A40.A40_001_C='ICMS')
			GROUP BY J22.J22_UKEYP) TabICMS 
				ON J11.UKEY=TabICMS.J22_UKEYP
	LEFT OUTER JOIN	(SELECT J22.J22_UKEYP,SUM(ISNULL(J22.J22_004_B,0)) AS IPI
					FROM StarWestcon.dbo.J22 J22 (NOLOCK)
			WHERE J22.A40_UKEY=(select UKEY FROM StarWestcon.dbo.A40 A40 (NOLOCK) 
					WHERE A40.A40_001_C='IPI')
			GROUP BY J22.J22_UKEYP) TabIPI 
				ON J11.UKEY=TabIPI.J22_UKEYP
	LEFT OUTER JOIN	(SELECT J22.J22_UKEYP,SUM(ISNULL(J22.J22_004_B,0)) AS IRRF
					FROM StarWestcon.dbo.J22 J22 (NOLOCK)
			WHERE J22.A40_UKEY=(select UKEY FROM StarWestcon.dbo.A40 A40 (NOLOCK) 
					WHERE A40.A40_001_C='IRRF')
			GROUP BY J22.J22_UKEYP) TabIRRF 
				ON J11.UKEY=TabIRRF.J22_UKEYP
	LEFT OUTER JOIN	(SELECT J22.J22_UKEYP,SUM(ISNULL(J22.J22_004_B,0)) AS CSLL
					FROM StarWestcon.dbo.J22 J22 (NOLOCK)
			WHERE J22.A40_UKEY=(select UKEY FROM StarWestcon.dbo.A40 A40 (NOLOCK) 
					WHERE A40.A40_001_C='CSLL')
			GROUP BY J22.J22_UKEYP) TabCSLL 
				ON J11.UKEY=TabCSLL.J22_UKEYP
	LEFT OUTER JOIN	(SELECT J22.J22_UKEYP,SUM(ISNULL(J22.J22_004_B,0)) AS ICMSST
					FROM StarWestcon.dbo.J22 J22 (NOLOCK)
			WHERE J22.A40_UKEY=(select UKEY FROM StarWestcon.dbo.A40 A40 (NOLOCK) 
					WHERE A40.A40_001_C='ICMS_ST')
			GROUP BY J22.J22_UKEYP) TabICMSST 
				ON J11.UKEY=TabICMSST.J22_UKEYP
	LEFT OUTER JOIN	(SELECT J22.J22_UKEYP,SUM(ISNULL(J22.J22_004_B,0)) AS IVA
					FROM StarWestcon.dbo.J22 J22 (NOLOCK)
			WHERE J22.A40_UKEY=(select UKEY FROM StarWestcon.dbo.A40 A40 (NOLOCK) 
					WHERE A40.A40_001_C='IVA')
			GROUP BY J22.J22_UKEYP) TabIVA
				ON J11.UKEY=TabIVA.J22_UKEYP
	LEFT OUTER JOIN	(
						SELECT J22.J22_UKEYP,SUM(ISNULL(J22.J22_004_B,0)) AS PIS
						FROM StarWestcon.dbo.J22 J22 (NOLOCK)
						WHERE J22.A40_UKEY=(select UKEY FROM StarWestcon.dbo.A40 A40 (NOLOCK) WHERE A40.A40_001_C='PIS')
						GROUP BY J22.J22_UKEYP
					) TabPIS ON J11.UKEY=TabPIS.J22_UKEYP	
	LEFT OUTER JOIN	(
						SELECT J22.J22_UKEYP,SUM(ISNULL(J22.J22_004_B,0)) AS COFINS
						FROM StarWestcon.dbo.J22 J22 (NOLOCK)
						WHERE J22.A40_UKEY=(select UKEY FROM StarWestcon.dbo.A40 A40 (NOLOCK) WHERE A40.A40_001_C='COFINS')
						GROUP BY J22.J22_UKEYP
					) TabCOFINS ON J11.UKEY=TabCOFINS.J22_UKEYP	
	LEFT OUTER JOIN	(
						SELECT J22.J22_UKEYP,SUM(ISNULL(J22.J22_004_B,0)) AS ISS
						FROM StarWestcon.dbo.J22 J22 (NOLOCK)
						WHERE J22.A40_UKEY=(select UKEY FROM StarWestcon.dbo.A40 A40 (NOLOCK) WHERE A40.A40_001_C='ISS')
						GROUP BY J22.J22_UKEYP
					) TabISS ON J11.UKEY=TabISS.J22_UKEYP					
				
	WHERE J10.CIA_UKEY = 'OSL0R' AND
		(
			(
				J10.J10_002_N <> 2  
				AND T04.T04_001_C <> 'E90.04W8'
				AND J10.J10_003_D >= @FromYYYYMMDD--CONVERT(DATETIME, @FromYYYYMMDD + ' 00:00:00', 102) 
				AND J10.J10_003_D <= @ToYYYYMMDD--CONVERT(DATETIME, @ToYYYYMMDD + ' 23:59:59', 102) 
			)
			OR (
				J10.J10_002_N = 2 
				AND J10.J10_014_D >= @FromYYYYMMDD--CONVERT(DATETIME, @FromYYYYMMDD + ' 00:00:00', 102) 
				AND J10.J10_014_D <= @ToYYYYMMDD--CONVERT(DATETIME, @ToYYYYMMDD + ' 23:59:59', 102) 
			)
		)

		AND 
		--SCRUM-15463 - inicio
		((@CanceledInvoices= 0 and J10.J10_032_N = 0) or (@CanceledInvoices= 1 and J10.J10_032_N = 1 and  cast(isnull(j10.j10_111_t,j10.timestamp) as date) <> cast(isnull(j10.j10_003_d,'') as date)  ) )
		--SCRUM-15463 - fim
		AND T04_501_N = 1
		AND J10.Array_736 <> 1
		AND J11.I14_UKEY IS NULL 
		AND J11_DEV.I14_UKEY IS NULL
			
					
		
	)









