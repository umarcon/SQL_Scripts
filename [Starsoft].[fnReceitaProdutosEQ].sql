USE [Westcon]
GO
/****** Object:  UserDefinedFunction [Starsoft].[fnReceitaProdutosEQ]    Script Date: 13/03/2018 20:28:44 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

--select * from [StarSoft].[fnReceitaProdutosPE]('20160901','20160914')

ALTER FUNCTION [Starsoft].[fnReceitaProdutosEQ]
(
	@FromYYYYMMDD as date,
	@ToYYYYMMDD as date
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
Starsoft.Reports_AtualizaBI_Receita, conforme atividade: PRIME-902.

- Alterado em 07/11/2016 por Marlon de Oliveira - SCRUM-15174 (Habilitar o Processo de Provisão de Marketing para MCA)
  Incluido as colunas VendedorMTK e ResselerMTK 

- Alterado em 28/06/16 por ELCruz
Adicionado as colunas Fabricante e Familia para efetuar o preenchimento na BIReceita quando a NF do Appl não possuir OV da Intranet associada

- Alterado por Thviotto 06/05/2016 17:59:54 - Solicitação - SCRUM-15091
--Criei o campo Tax

- Alterado em 12/02/16 por ELCruz
Foi criada uma nova versão com base na versão do MX pois elas funcionam de maneira semelhante, onde a unica mudanã é que o MX usa a moeda1
do estoque como US$ e a Colombia usa a moeda1 como $(Peso)
Obs: Foi criado um bkp da versão anterior com o nome [Starsoft].[fnReceitaProdutosCO_20160212]

- Alterado em 02/07/14 por ELCruz
Alteração no preenchimento das colunas CustoMedioUn, CustoMedioTotal, CustoMedioUnPeso e CustoMedioTotalPeso para checar se a NF de Devolução NÃO gerou Movimento
no estoque, pois nesse caso os campos referentes a CM deverão permanecer com valores zerados

- Alterado em 04/06/14 por ELCruz
Alteração na forma de obter o CM das NF de Devolução de Venda para pegar o CM do Movimento da NF que foi devolvida.
Obs: Conversa com Nelio, Andres e Wagner via skype para obter essa conclusão
Alterações nas colunas CustoMedioUn e CustoMedioTotal

- Alterado em 02/05/14 por ELCruz (SCRUM-7909)
Alteração na forma de obter o CM das NF de Devolução de Venda para pegar o CM do Movimento ao invés do CM anterior.
Alterações nas colunas CustoMedioUn e CustoMedioTotal

- Alterado em 06/12/13 por ELCruz
Foi adicionada a coluna J11_UKEY para permitir criar uma chave única na tabela BIReceita contendo os campos CODERP, CIA_UKEY, J10_UKEY, J11_UKEY
Foi adicionada a coluna "Intercompany" referente ao cadastro do cliente para facilitar na visualização dos retlatórios
A Coluna "InvoiceLineNumber" foi alterada para retornar a informação exata contida na tabela do applications, pois no applications essa informação é iniciada e inclementada por 5,
porém anteriormente estavámos dividindo essa numeração por 5 para demonstra-la como número sequencial

alterado em 27/11/13 por ELCruz
Foi adicionada a nova coluna chamada COMPLEMENT, que indicará se a nf é complementar. Nesse momento foi add apenas para evitar erros pois esse campo esta sendo usado apenas pelo BR

alterado em 09/10/13 por ELCruz
Foi adicionada uma nova regra para o campo ProvisaoComissaoRevenda para os casos de NF de devolução, onde deverá ser pego o valor da comissão do item devolvido 
na NF de origem rateado pela qtd faturada do item e esse valor deverá ser multiplicado pela qtd devolvida na NF de Devolução

-2013-06-05 JM
* Incluindo o tipo nota E05.11 a pedido do Wagner https://jira.westcon.com.br/browse/SCRUM-2858

-2013-05-02 JM
* Incluindo o tipo nota E05.08 a pedido do Wagner https://jira.westcon.com.br/browse/SCRUM-2364

-2013-05-02 JM
* Incluindo o tipo nota E05.10 a pedido do Marco Bourget, com autorização do Wagner https://jira.westcon.com.br/browse/SCRUM-2351

- Alterado em 19-02-2013 para demonstrar o campo RevenueType por ELCruz
* Foi incluído o campo revenueType onde se o tipo de e/s for S03.01 deverá retornar a descrição 'Service', caso contrário 'Product'

- Alterado em 19-02-2013 para contemplar a demonstração do código global da OV por ELCruz
* Foi criada a Função [Westcon].[StarSoft].[FN_GetOVGlobalCode] onde será passado como parâmetro o código da OV no SSA e deverá retornar o Código Global da OV,
usado tanto na intranet quanto no SSA. (Essa função irá preencher o campo CodPedido)

Alterado em 17/maio/2011 por Andrés Irazábal
	* Campos Custo médio unitário e custom médio total agora estão pegando o "CM1 anterior" (se moeda for US$) 
	  ou "CM2 anterior" (se moeda <>US$). Antigamente a regra para devoluções era diferente e sempre retornava valores em dólar.
	  Antigamente, no caso de devoluções, o campo CM1 unitário era usado.
Alterado em 2/jun/2010 por Andrés Irazábal
	* Campo "EmissaoNF" em Notas de entrada deve ser obtido de J10_014_D e não mais de J10_006_D.
	  J10_014_D corresponde a Data de Entrada no caso de notas de entrada. J10_006_D corresponde a data de entrega.

Alterado em 06-10-2015 por Thiago Rodrigues
Criado a condição CASE WHEN J11.J11_006_B = 0 THEN 1.00 ELSE J11.J11_006_B END AS TotalItemNF
quando o campo TotalItemNF ficava com o valor igual a 0  dava erro no Reports_AtualizaBI_Receita

*/
RETURN
(
SELECT J07.J07_001_C AS PedidoVenda, 
	   [Westcon].[StarSoft].[FN_GetOVGlobalCode](J07.J07_001_C,2) AS PedidoVendaTrimmed,
	 		   LTRIM(RTRIM(J10.J10_001_C))
				+	CASE WHEN ISNULL(T89.T89_001_C,'') IN ('GR','GN') AND 
							 ISNULL(T89T.T89_001_C,'')='FV' AND J10T.J10_001_C IS NOT NULL THEN 
							 '->'+RTRIM(LTRIM(J10T.J10_001_C)) ELSE '' END 

			   
			   
			   AS NF,
			   T04.T04_001_C AS TipoES,
			   CONVERT(smalldatetime, CASE WHEN (J10.J10_002_N <> 2) 
										   THEN J10.J10_003_D 
										   ELSE J10.J10_014_D END) AS EmissaoNF, 
		D04.D04_001_C AS PartNumber,
		A03.A03_001_C AS CNPJEmpresaNF,
		A03.A03_003_C AS EmpresaNF,
		J11.J11_003_B AS Qtd,
		J11.J11_005_B AS ValorUnitarioNF,
		--J11.J11_006_B AS TotalItemNF,
		-- ALTERADO. DIRETOR DO JULIO DO PERU NÃO ACEITOU
		--CASE WHEN J11.J11_006_B = 0 THEN 0 ELSE J11.J11_006_B END AS TotalItemNF,

		J11.J11_006_B AS TotalItemNF,

		CASE WHEN (J10.J10_002_N = 1) 
		THEN
			CASE WHEN RTRIM(LEFT(J10.A36_CODE,3))='US$'  
			THEN 
				ISNULL(D28.D28_006_B, 0)
			ELSE 
				ISNULL(D28.D28_009_B, 0)
			END 
		ELSE
			-- SE A NF DE DEV. NAO GEROU ESTOQUE
			CASE WHEN D14.UKEY IS NULL
			THEN
				0
			ELSE		
				CASE WHEN RTRIM(LEFT(J10.A36_CODE,3))='US$'
				THEN 
					ISNULL(D28_DEV.D28_006_B, 0)
				ELSE
					ISNULL(D28_DEV.D28_009_B, 0)
				END
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
			CASE WHEN RTRIM(LEFT(J10.A36_CODE,3))='US$'  
			THEN 
				ISNULL(D28.D28_006_B, 0)
			ELSE 
				ISNULL(D28.D28_009_B, 0)
			END 
		ELSE
			-- SE A NF DE DEV. NAO GEROU ESTOQUE
			CASE WHEN D14.UKEY IS NULL
			THEN
				0
			ELSE				
				CASE WHEN RTRIM(LEFT(J10.A36_CODE,3))='US$'  
				THEN 
					ISNULL(D28_DEV.D28_006_B, 0)
				ELSE 
					ISNULL(D28_DEV.D28_009_B, 0)
				END 
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
		CASE WHEN (J10.J10_002_N = 1) THEN ISNULL(J15.J15_002_B,0) ELSE (ISNULL(J15.J15_002_B,0) / J11_DEV.J11_003_B) * J11.J11_003_B END AS ProvisaoComissaoRevenda,
		CASE WHEN T04.T04_001_C='S01.95' OR J11.J11_005_B=0 
		THEN 
			0 
		ELSE  
			(CASE WHEN (J10.J10_002_N = 1) THEN ISNULL(J15.J15_002_B,0) ELSE (ISNULL(J15.J15_002_B,0) / J11_DEV.J11_003_B) * J11.J11_003_B END / 1 / (J11.J11_003_B * J11.J11_005_B)) + J11.J11_003_B * J11.J11_005_B
		END AS TotalRevendaAntesComissao, 
		0 AS ICMS, 	
		0 AS PIS,
		0 AS COFINS, 
		0 AS ISS,
		0 AS ICMSST,
		ISNULL(TabIRRF.IRRF,0) AS IRRF, 
		ISNULL(TabCSLL.CSLL,0) AS CSLL,	
		0 AS IPI,	
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
			ISNULL(J07.A36_CODE,'') <> '' AND RTRIM(LEFT(J07.A36_CODE,3)) = 'US$' AND RTRIM(LEFT(J07.A36_CODE,5)) <> 'US$  ' 
		THEN
			-- Se o pedido tiver US$ específico, uso a data de emissão do pedido para buscar a tx
			(
				SELECT TOP 1 A37_002_B 
				FROM StarWestconCala2.WPeru.A37 A37 (NoLock)
				WHERE A36_UKEYA=CIA.A36_UKEY
				AND A36_UKEY=LEFT(J07.A36_CODE,5)
				AND A37_001_D= CONVERT(varchar(8),J07.J07_003_D,112)
			) 			
		ELSE
			-- Se não tiver ov para a nf, busco a tx do US$ na data do faturamento
			(
				SELECT TOP 1 A37_002_B 
				FROM StarWestconCala2.WPeru.A37 A37 (NoLock)
				WHERE A36_UKEYA=CIA.A36_UKEY
				AND A36_UKEY='US$  '
				AND A37_001_D=ISNULL(J10.J10_047_D,J10.J10_003_D)
			) 
		END USDRate,
			[Westcon].[StarSoft].[FN_GetOVGlobalCode](J07.J07_001_C,1) AS CodPedido,
			6 AS CodERP,
			(
				RTRIM(LTRIM(A03_005_C)) + -- ENDERECO
				CASE WHEN ISNULL(A03_005_C,'') <> '' THEN ', ' + RTRIM(LTRIM(A03_014_C)) ELSE '' END -- NUMERO
			)AS EnderecoFatura,	
			A03_004_C as BairroFatura,
			A03_006_C as CEPFatura,
			A22_001_C as PaisFatura,
			CASE WHEN T04.T04_001_C = 'S03.01' THEN 'SERVICE' ELSE 'PRODUCT' END AS RevenueType,
			null as POEFETIVA,
			J11.J11_998_C AS InvoiceLineNumber,
		-- Se for devolução de venda o fator será negativo
		CASE WHEN J10.J10_002_N = 1 THEN 1 ELSE -1 END AS FATOR,
		0 AS COMPLEMENT,
		J11.UKEY AS J11_UKEY,
		CASE A03.A03_504_N WHEN 1 THEN 'No' WHEN 2 THEN 'Intercompany' WHEN 3 THEN 'Related' END AS Intercompany,
		J08.J08_INTRANETUKEY AS ID_INTRANET,
		CASE WHEN J10.J10_046_B=0 THEN 1 ELSE J10.J10_046_B END  AS TAX1,  
		ISNULL((SELECT TOP 1 A37_002_B 
				FROM StarWestconCala2.dbo.A37 A37 (NOLOCK)
				WHERE A36_UKEYA=(SELECT CIA.A36_UKEY FROM STARWESTCONCALA2.DBO.CIA (NOLOCK) WHERE CIA.UKEY = J10.CIA_UKEY)
				AND A36_UKEY=LEFT(J10.A36_CODE,5)
				AND A37_001_D= CONVERT(VARCHAR(8),J10.J10_003_D,112)
			),1)  AS TAX2, 
		 CIA.A36_UKEY AS CURRENCY_CIA,
		 D03PAI.D03_002_C AS FABRICANTE,
		 D03FILHO.D03_002_C AS FAMILIA,
		D04_501_N AS MAINTENANCE, -- PRIME-902 
		ISNULL((SELECT SUM(J15_002_B) AS J15_002_B
			    FROM StarWestconCala2.dbo.J15 (NOLOCK) 
			    WHERE CASE WHEN (J10.J10_002_N = 1) THEN J11.UKEY ELSE J11_DEV.UKEY END = J15.J15_UKEYP AND J15.J15_500_N = 2 -- INDICA QUE É A COMISSÃO DE MKT
		),0) AS VendedorMTK,
		ISNULL((SELECT SUM(J15_002_B) AS J15_002_B
			    FROM StarWestconCala2.dbo.J15 (NOLOCK) 
			    WHERE CASE WHEN (J10.J10_002_N = 1) THEN J11.UKEY ELSE J11_DEV.UKEY END = J15.J15_UKEYP AND J15.J15_500_N = 1 -- INDICA QUE É A COMISSÃO DE FIDELIZAÇÃO
		),0) AS ResselerMTK,
		D04_502_N AS CLOUD --PRIME-916
	FROM            
		StarWestconCala2.dbo.J10 J10 WITH (NOLOCK) 
		INNER JOIN STARWESTCONCALA2.DBO.CIA WITH (NOLOCK) ON CIA.UKEY = J10.CIA_UKEY
		INNER JOIN StarWestconCala2.dbo.A03 A03 WITH (NOLOCK) ON J10.A03_UKEY = A03.UKEY 
		INNER JOIN StarWestconCala2.dbo.T89 T89 WITH (NOLOCK) ON J10.T89_UKEY =T89.UKEY 
		INNER JOIN StarWestconCala2.dbo.J11 J11 WITH (NOLOCK) ON J10.UKEY = J11.J10_UKEY 

		LEFT  JOIN StarWestconCala2.dbo.J11 J11T WITH (NOLOCK) ON J11T.UKEY = J11.J11_UKEYJ11 
		LEFT  JOIN StarWestconCala2.dbo.J10 J10T WITH (NOLOCK) ON J11T.J10_UKEY = J10T.UKEY
		LEFT  JOIN StarWestconCala2.dbo.T89 T89T WITH (NOLOCK) ON J10T.T89_UKEY =T89T.UKEY 

		INNER JOIN StarWestconCala2.dbo.T04 T04 WITH (NOLOCK) ON J11.T04_UKEY = T04.UKEY 
		INNER JOIN StarWestconCala2.dbo.D04 D04 WITH (NOLOCK) ON J11.D04_UKEY = D04.UKEY 
		LEFT JOIN       StarWestconCALA2.dbo.D03 D03FILHO (NOLOCK) ON D04.D03_UKEY = D03FILHO.UKEY 
		LEFT JOIN       StarWestconCALA2.dbo.D03 D03PAI (NOLOCK) ON D03FILHO.D03_UKEY = D03PAI.UKEY 
		LEFT OUTER JOIN StarWestconCala2.dbo.D22 D22 WITH (NOLOCK) ON J11.UKEY = D22.D22_IUKEYP 
		LEFT OUTER JOIN StarWestconCala2.dbo.D28 D28 WITH (NOLOCK) ON D22.UKEY = D28.D28_UKEYP 
		LEFT OUTER JOIN StarWestconCala2.dbo.D14 D14 WITH (NOLOCK) ON J11.UKEY = D14.D14_IUKEYP 
		LEFT OUTER JOIN StarWestconCala2.dbo.D28 D28_1 WITH (NOLOCK) ON D14.UKEY = D28_1.D28_UKEYP 
		LEFT OUTER JOIN StarWestconCala2.dbo.J11 J11_DEV WITH (NOLOCK) ON J11.J11_UKEYP = J11_DEV.UKEY 
		LEFT OUTER JOIN StarWestconCala2.dbo.D22 D22_DEV WITH (NOLOCK) ON J11_DEV.UKEY = D22_DEV.D22_IUKEYP
		LEFT OUTER JOIN StarWestconCala2.dbo.D28 D28_DEV WITH (NOLOCK) ON D22_DEV.UKEY = D28_DEV.D28_UKEYP 
		LEFT OUTER JOIN StarWestconCala2.dbo.J10 J10_DEV WITH (NOLOCK) ON J11_DEV.J10_UKEY = J10_DEV.UKEY 
		LEFT OUTER JOIN StarWestconCala2.dbo.A33 A33_DEV WITH (NOLOCK) ON J10_DEV.A33_UKEY = A33_DEV.UKEY
		LEFT OUTER JOIN StarWestconCala2.dbo.J08 J08 WITH (NOLOCK) ON CASE WHEN (J10.J10_002_N = 1 ) THEN J11.J11_PAR ELSE J11_DEV.J11_PAR END ='J08' and CASE WHEN (J10.J10_002_N = 1 ) THEN J11.J11_UKEYP ELSE J11_DEV.J11_UKEYP END =J08.UKEY
		LEFT JOIN StarWestconCala2.dbo.T04 T04T WITH (NOLOCK) ON J08.T04_UKEY = T04T.UKEY
		LEFT OUTER JOIN StarWestconCala2.dbo.J07 J07 WITH (NOLOCK) ON J08.J07_UKEY=J07.UKEY

		LEFT OUTER JOIN 
		(
			SELECT SUM(J15_C.J15_002_B) as J15_002_B,  J15_C.J15_UKEYP 
			FROM 
				StarWestconCala2.dbo.J15 J15_C WITH (NOLOCK) 
				INNER JOIN StarWestconCala2.dbo.J11 J11_C WITH (NOLOCK) ON J11_C.UKEY = J15_C.J15_UKEYP
				INNER JOIN StarWestconCala2.dbo.J10 J10_C WITH (NOLOCK) ON J11_C.J10_UKEY = J10_C.UKEY
			WHERE J15_C.J15_PAR = 'J11' AND J15_C.J15_500_N = 0 -- INDICA QUE É A COMISSÃO DA NF E NÃO É UMA COMISSO DE MKT NEM FIDELIZAÇÃO
			GROUP BY  J15_C.J15_UKEYP
		) J15 ON CASE WHEN (J10.J10_002_N = 1) THEN J11.UKEY ELSE J11_DEV.UKEY END = J15.J15_UKEYP 

        LEFT OUTER JOIN StarWestconCala2.dbo.A22 A22 (NOLOCK) ON A03.A22_UKEY = A22.UKEY		
		LEFT OUTER JOIN StarWestconCala2.dbo.A23 A23 WITH (NOLOCK) ON A03.A23_UKEY = A23.UKEY
		LEFT OUTER JOIN StarWestconCala2.dbo.A24 A24 WITH (NOLOCK) ON A03.A24_UKEY = A24.UKEY 
		LEFT OUTER JOIN StarWestconCala2.dbo.A33 A33 WITH (NOLOCK) ON J10.A33_UKEY = A33.UKEY 
		LEFT OUTER JOIN	(SELECT J22.J22_UKEYP,SUM(J22.J22_004_B) AS IVA
						FROM StarWestconCala2.dbo.J22 J22 WITH (NOLOCK)
				WHERE J22.A40_UKEY=(select UKEY FROM StarWestconCala2.dbo.A40 A40 WITH (NOLOCK) 
						WHERE A40.A40_001_C='IGV')
				GROUP BY J22.J22_UKEYP) TabIVA 
					ON J11.UKEY=TabIVA.J22_UKEYP
		LEFT OUTER JOIN	(SELECT J22.J22_UKEYP,SUM(J22.J22_004_B) AS IRRF
						FROM StarWestconCala2.dbo.J22 J22 WITH (NOLOCK)
				WHERE J22.A40_UKEY=(select UKEY FROM StarWestconCala2.dbo.A40 A40 WITH (NOLOCK) 
						WHERE A40.A40_001_C='IGVRV')
				GROUP BY J22.J22_UKEYP) TabIRRF 
					ON J11.UKEY=TabIRRF.J22_UKEYP
		LEFT OUTER JOIN	(SELECT J22.J22_UKEYP,SUM(J22.J22_004_B) AS CSLL
						FROM StarWestconCala2.dbo.J22 J22 WITH (NOLOCK)
				WHERE J22.A40_UKEY=(select UKEY FROM StarWestconCala2.dbo.A40 A40 WITH (NOLOCK) 
						WHERE A40.A40_001_C='DETRAC')
				GROUP BY J22.J22_UKEYP) TabCSLL 
					ON J11.UKEY=TabCSLL.J22_UKEYP
WHERE    

		(
			(
				J10.J10_002_N <> 2 
				AND J10.J10_003_D >= @FromYYYYMMDD--CONVERT(DATETIME, @FromYYYYMMDD + ' 00:00:00', 102) 
				AND J10.J10_003_D <= @ToYYYYMMDD--CONVERT(DATETIME, @ToYYYYMMDD + ' 23:59:59', 102) 
			)
			OR (
				J10.J10_002_N = 2 
				AND J10.J10_014_D >= @FromYYYYMMDD--CONVERT(DATETIME, @FromYYYYMMDD + ' 00:00:00', 102) 
				AND J10.J10_014_D <= @ToYYYYMMDD--CONVERT(DATETIME, @ToYYYYMMDD + ' 23:59:59', 102) 
			)
		)
		AND (J10.J10_032_N = 0) 
		AND T04.T04_501_N = 1 -- SOMENTE CES COM A MARCAÇÃO DE RECEITA
		AND J10.CIA_UKEY IN ('5HV8Z')

	-- CASO TENHA GUIA DE REEMISSAO OU GUIA DE REEMISAO NAO IMPRESSA PARA PEDIDOS DE SERVIÇOS ENTÃO NAO DEVE SAIR
	AND NOT (T89.T89_001_C IN('GR', 'GN') AND T04T.T04_001_C='S03.01')





		--AND (
		--	T04.T04_001_C='S01.01'
		--	OR T04.T04_001_C='S01.03'
		--	OR T04.T04_001_C='S02.01'
		--	OR T04.T04_001_C='S03.01' -- Serviços
		--	OR T04.T04_001_C='E05.01'
		--	OR T04.T04_001_C='E05.10' -- SCRUM-2351
		--	OR T04.T04_001_C='E05.08' -- SCRUM-2364
		--	OR T04.T04_001_C='E05.11' -- SCRUM-2858
		--	OR T04.T04_001_C='S01.11'
		--)


)
