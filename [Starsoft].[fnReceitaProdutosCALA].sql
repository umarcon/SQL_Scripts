USE [Westcon]
GO
/****** Object:  UserDefinedFunction [Starsoft].[fnReceitaProdutosCALA]    Script Date: 13/03/2018 20:28:32 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

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

- Alterado por Thviotto 09/05/2016 14:56:20 - Solicitação - SCRUM-15091
--Criei o campo Tax


- Alterado em 08/06/2015 Por Baiano e identificado por Andrés
Alteração para acerto das devoluções, a query não retornava o código da OV devolvida.

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
Foi adicionada a nova coluna chamada COMPLEMENT, que indicará se a nf é complementar. Nesse momento foi add apenas para evitar erros pois esse campo esta sendo usado apenas pelo BR

alterado em 09/10/13 por ELCruz
Foi adicionada uma nova regra para o campo ProvisaoComissaoRevenda para os casos de NF de devolução, onde deverá ser pego o valor da comissão do item devolvido 
na NF de origem rateado pela qtd faturada do item e esse valor deverá ser multiplicado pela qtd devolvida na NF de Devolução

- Alterado em 01-out-2013
retirado o tipo S010 a pedido do Wagner - SCRUM-4344

- Alterado em 19-02-2013 para demonstrar o campo RevenueType por ELCruz
* Foi incluído o campo revenueType onde se o tipo de e/s for S008 deverá retornar a descrição 'Service', caso contrário 'Product'

- Alterado em 19-02-2013 para contemplar a demonstração do código global da OV por ELCruz
* Foi criada a Função [Westcon].[StarSoft].[FN_GetOVGlobalCode] onde será passado como parâmetro o código da OV no SSA e deverá retornar o Código Global da OV,
usado tanto na intranet quanto no SSA. (Essa função irá preencher o campo CodPedido)

Alterado em 06/fev/2013 por JM (SCRUM-1061)
*Adicionado o tipo S011


Alterado em 06-10-2015 por Thiago Rodrigues
Criado a condição 
CASE WHEN J11.J11_006_B = 0 THEN 1.00 ELSE J11.J11_006_B END AS TotalItemNF
CASE WHEN E11.E11_006_B = 0 THEN 1.00 ELSE E11.E11_006_B END AS TotalItemNF
quando o campo TotalItemNF ficava com o valor igual a 0  dava erro no Reports_AtualizaBI_Receita


*/
--select * from [Starsoft].[fnReceitaProdutosCALA]('20140601','20140630',2)


ALTER FUNCTION [Starsoft].[fnReceitaProdutosCALA]
(
	@FromYYYYMMDD as date,
	@ToYYYYMMDD as date,
	@CodERP as int
)

RETURNS TABLE
AS

RETURN
(
		SELECT 
		J07.J07_001_C AS PedidoVenda, 
		[Westcon].[StarSoft].[FN_GetOVGlobalCode](J07.J07_001_C,2) AS PedidoVendaTrimmed,
		J10.J10_001_C AS NF,
		T04.T04_001_C AS TipoES,
		CONVERT(smalldatetime, 
			CASE WHEN (T04.T04_001_C <> 'E002' AND T04.T04_001_C <> 'E9004') OR (J10.J10_002_N <> 2) 
			THEN J10.J10_003_D 
			ELSE J10.J10_014_D END) AS EmissaoNF, 
		D04.D04_001_C AS PartNumber,
		A03.A03_001_C AS CNPJEmpresaNF,
		A03.A03_003_C AS EmpresaNF,
		J11.J11_003_B AS Qtd,
		J11.J11_005_B AS ValorUnitarioNF,
		--J11.J11_006_B AS TotalItemNF,
		CASE WHEN J11.J11_006_B = 0 THEN 1.00 ELSE J11.J11_006_B END AS TotalItemNF,
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
		CASE WHEN (J10.J10_002_N = 1) THEN ISNULL(J15.J15_002_B,0) ELSE (ISNULL(J15.J15_002_B,0) / J11_DEV.J11_003_B) * J11.J11_003_B END AS ProvisaoComissaoRevenda,
		CASE WHEN T04.T04_001_C='S01.95' OR J11.J11_005_B=0 
		THEN 
			0 
		ELSE  
			(CASE WHEN (J10.J10_002_N = 1) THEN ISNULL(J15.J15_002_B,0) ELSE (ISNULL(J15.J15_002_B,0) / J11_DEV.J11_003_B) * J11.J11_003_B END / (1 / (J11.J11_003_B * J11.J11_005_B)) + J11.J11_003_B * J11.J11_005_B) 
		END AS TotalRevendaAntesComissao, 
		0 AS ICMS, 
		0 AS PIS,
		0 AS COFINS, 
		0 AS IRRF, 
		0 AS CSLL,
		0 AS IPI,
		0 AS ISS,
		0 AS ICMSST,
		0 AS IVA,
		ISNULL(
				(
					SELECT MAX(J22.J22_004_B)
					FROM StarWestconCALA2.dbo.J22 J22 (NOLOCK) 
					INNER JOIN StarWestconCALA2.dbo.A40 A40 (NOLOCK) ON J22.A40_UKEY = A40.UKEY
					WHERE J22.J22_UKEYP = J11.UKEY AND UPPER(A40.A40_001_C) = 'TAX'	
				)	
		,0) AS SalesTax,
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
		CASE WHEN RTRIM(LEFT(J10.A36_CODE,5))='US$  '
			THEN 1 
			ELSE
			(
				SELECT TOP 1 A37_002_B 
				FROM StarWestconCALA2.dbo.A37 A37 (NoLock)
				WHERE A36_UKEYA=LEFT(J10.A36_CODE,5)
				AND A36_UKEY=LEFT(J07.A36_CODE,5)
				AND A37_001_D=CASE WHEN LEFT(J07.A36_CODE,5)='US$  ' THEN RIGHT(J10.A36_CODE,8) ELSE CONVERT(varchar(8),J07.J07_003_D,112) END
			) 
		END as USDRate,
			[Westcon].[StarSoft].[FN_GetOVGlobalCode](J07.J07_001_C,1) AS CodPedido,
			2 AS CodERP,			
			(
				RTRIM(LTRIM(A03_005_C)) + -- ENDERECO
				CASE WHEN ISNULL(A03_005_C,'') <> '' THEN ', ' + RTRIM(LTRIM(A03_014_C)) ELSE '' END -- NUMERO
			)AS EnderecoFatura,	
			A03_004_C as BairroFatura,
			A03_006_C as CEPFatura,
			A22_001_C as PaisFatura,
			CASE WHEN T04.T04_001_C = 'S008' THEN 'SERVICE' ELSE 'PRODUCT' END AS RevenueType,
			null as POEFETIVA,
			J11.J11_998_C AS InvoiceLineNumber,
		-- Se for devolução de venda o fator será negativo
		CASE WHEN J10.J10_002_N = 1 AND (T04.T04_001_C <> 'E002' AND T04.T04_001_C <> 'E9004') THEN 1 ELSE -1 END AS FATOR,
		0 COMPLEMENT,
		J11.UKEY AS J11_UKEY,
		CASE A03.A03_504_N WHEN 1 THEN 'No' WHEN 2 THEN 'Intercompany' WHEN 3 THEN 'Related' END AS Intercompany,
		J08.J08_INTRANETUKEY AS ID_INTRANET,
		
		CASE WHEN J10.J10_046_B=0 THEN 1 ELSE J10.J10_046_B END  AS TAX1,  
		ISNULL((SELECT TOP 1 A37_002_B 
				FROM StarWestconCALA2.dbo.A37 A37 (NOLOCK)
				WHERE A36_UKEYA=(SELECT CIA.A36_UKEY FROM StarWestconCALA2.DBO.CIA (NOLOCK) WHERE CIA.UKEY = J10.CIA_UKEY)
				AND A36_UKEY=LEFT(J10.A36_CODE,5)
				AND A37_001_D= CONVERT(VARCHAR(8),J10.J10_003_D,112)
			),1)  AS TAX2, 
		 (SELECT CIA.A36_UKEY FROM StarWestconCALA2.DBO.CIA (NOLOCK) WHERE CIA.UKEY = J10.CIA_UKEY) AS CURRENCY_CIA,
		 D03PAI.D03_002_C AS FABRICANTE,
		 D03FILHO.D03_002_C AS FAMILIA,
		D04_501_N AS MAINTENANCE, -- PRIME-902 
		ISNULL((SELECT SUM(J15_002_B) AS J15_002_B
			    FROM StarWestconCALA2.dbo.J15 (NOLOCK) 
			    WHERE CASE WHEN (J10.J10_002_N = 1) THEN J11.UKEY ELSE J11_DEV.UKEY END = J15.J15_UKEYP AND J15.J15_500_N = 2 -- INDICA QUE É A COMISSÃO DE MKT
		),0) AS VendedorMTK,
		ISNULL((SELECT SUM(J15_002_B) AS J15_002_B
			    FROM StarWestconCALA2.dbo.J15 (NOLOCK) 
			    WHERE CASE WHEN (J10.J10_002_N = 1) THEN J11.UKEY ELSE J11_DEV.UKEY END = J15.J15_UKEYP AND J15.J15_500_N = 1 -- INDICA QUE É A COMISSÃO DE FIDELIZAÇÃO
		),0) AS ResselerMTK,
		D04_502_N AS CLOUD --PRIME-916
	FROM            
		StarWestconCALA2.dbo.J10 J10 (NOLOCK) 
		INNER JOIN      StarWestconCALA2.dbo.A03 A03 (NOLOCK) ON J10.A03_UKEY = A03.UKEY 
		INNER JOIN      StarWestconCALA2.dbo.J11 J11 (NOLOCK) ON J10.UKEY = J11.J10_UKEY 
		INNER JOIN      StarWestconCALA2.dbo.T04 T04 (NOLOCK) ON J11.T04_UKEY = T04.UKEY 
		INNER JOIN      StarWestconCALA2.dbo.D04 D04 (NOLOCK) ON J11.D04_UKEY = D04.UKEY 
		LEFT JOIN       StarWestconCALA2.dbo.D03 D03FILHO (NOLOCK) ON D04.D03_UKEY = D03FILHO.UKEY 
		LEFT JOIN       StarWestconCALA2.dbo.D03 D03PAI (NOLOCK) ON D03FILHO.D03_UKEY = D03PAI.UKEY 
		LEFT OUTER JOIN StarWestconCALA2.dbo.D22 D22 (NOLOCK) ON J11.UKEY = D22.D22_IUKEYP 
		LEFT OUTER JOIN StarWestconCALA2.dbo.D28 D28 (NOLOCK) ON D22.UKEY = D28.D28_UKEYP 
		LEFT OUTER JOIN StarWestconCALA2.dbo.D14 D14 (NOLOCK) ON J11.UKEY = D14.D14_IUKEYP 
		LEFT OUTER JOIN StarWestconCALA2.dbo.D28 D28_1 (NOLOCK) ON D14.UKEY = D28_1.D28_UKEYP 
		LEFT OUTER JOIN StarWestconCALA2.dbo.J11 J11_DEV (nolock) ON J11.J11_UKEYP = J11_DEV.UKEY 
		LEFT OUTER JOIN StarWestconCALA2.dbo.D22 D22_DEV WITH (NOLOCK) ON J11_DEV.UKEY = D22_DEV.D22_IUKEYP
		LEFT OUTER JOIN StarWestconCALA2.dbo.D28 D28_DEV WITH (NOLOCK) ON D22_DEV.UKEY = D28_DEV.D28_UKEYP 		
		LEFT OUTER JOIN StarWestconCALA2.dbo.J10 J10_DEV (nolock) ON J11_DEV.J10_UKEY = J10_DEV.UKEY 
		LEFT OUTER JOIN StarWestconCALA2.dbo.A33 A33_DEV (NOLOCK) ON J10_DEV.A33_UKEY = A33_DEV.UKEY
		LEFT OUTER JOIN StarWestconCALA2.dbo.J08 J08 (NOLOCK) ON CASE WHEN (J10.J10_002_N = 1) THEN J11.J11_PAR ELSE J11_DEV.J11_PAR END ='J08' and CASE WHEN (J10.J10_002_N = 1) THEN J11.J11_UKEYP ELSE J11_DEV.J11_UKEYP END =J08.UKEY
		LEFT OUTER JOIN StarWestconCALA2.dbo.J07 J07 (NOLOCK) ON J08.J07_UKEY=J07.UKEY

		LEFT OUTER JOIN (SELECT SUM(J15_C.J15_002_B) as J15_002_B,  J15_C.J15_UKEYP 
						   FROM StarWestconCALA2.dbo.J15 J15_C (NOLOCK) 
						  INNER JOIN StarWestconCALA2.dbo.J11 J11_C (NOLOCK) ON J11_C.UKEY = J15_C.J15_UKEYP
						  INNER JOIN StarWestconCALA2.dbo.J10 J10_C (NOLOCK) ON J11_C.J10_UKEY = J10_C.UKEY
							WHERE J15_C.J15_PAR = 'J11' AND J15_C.J15_500_N = 0 -- INDICA QUE É A COMISSÃO DA NF E NÃO É UMA COMISSO DE MKT NEM FIDELIZAÇÃO
						  GROUP BY  J15_C.J15_UKEYP) J15 ON CASE WHEN (J10.J10_002_N = 1) THEN J11.UKEY ELSE J11_DEV.UKEY END = J15.J15_UKEYP 

        LEFT OUTER JOIN StarWestconCALA2.dbo.A22 A22 (NOLOCK) ON A03.A22_UKEY = A22.UKEY						  
		LEFT OUTER JOIN StarWestconCALA2.dbo.A23 A23 (NOLOCK) ON A03.A23_UKEY = A23.UKEY
		LEFT OUTER JOIN StarWestconCALA2.dbo.A24 A24 (NOLOCK) ON A03.A24_UKEY = A24.UKEY 
		LEFT OUTER JOIN StarWestconCALA2.dbo.A33 A33 (NOLOCK) ON J10.A33_UKEY = A33.UKEY 

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
		AND J10.CIA_UKEY = (SELECT CIA_UKEYpadrao FROM tblERP (NoLock) WHERE CodERP = @CodERP) 
		AND (J10.J10_032_N = 0) 
		AND (T04_501_N=1)
		--AND (T04.T04_001_C IN ('S001', 'S002', 'S005', 'S007', 'S009','S011', 'S012', 'S019', 'S021','S099', 'S003', 'S004', 'E001','E002', 'E9004', 'S008'))
		
			UNION ALL
	
	SELECT     
		'(entrada)' AS PedidoVenda, 
		'(entrada)' AS PedidoVendaTrimmed, 
		E10.E10_001_C AS NF, 
		T04.T04_001_C AS TipoES, 
		CONVERT(smalldatetime, E10.E10_006_D) AS EmissaoNF, 
		D04.D04_001_C AS PartNumber, 
		ISNULL(A03.A03_001_C, A08.A08_001_C) AS CNPJEmpresaNF, 
		ISNULL(A03.A03_003_C, A08.A08_003_C) AS EmpresaNF, 
		E11.E11_003_B AS Qtd, 
		E11.E11_005_B AS ValorUnitarioNF, 
		--E11.E11_006_B AS TotalItemNF, 
		CASE WHEN E11.E11_006_B  = 0 THEN 1.00 ELSE E11.E11_006_B END AS TotalItemNF,
		CASE WHEN (E10.E10_002_N = 1) AND (T04.T04_001_C <> 'E9004') 
		THEN 
			ISNULL(D28.D28_006_B, 0)
		ELSE 
			ISNULL(D28_1.D28_006_B, 0) 
		END AS CustoMedioUn, 
		--Atividade PRIME-1848 - Inicio
		CASE WHEN (E10.E10_002_N = 1) 
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
					ISNULL(D28_1.D28_009_B, 0)
				--ELSE 
				--	ISNULL(D28_DEV.D28_006_B, 0)
				--END 	
			END
		END AS CustoMedioUnPeso,
		CASE WHEN (E10.E10_002_N = 1) 
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
					ISNULL(D28_1.D28_009_B, 0)
				--ELSE 
				--	ISNULL(D28_DEV.D28_006_B, 0)
				--END 	
			END
		END * E11.E11_003_B AS CustoMedioTotalPeso,	
		--Atividade PRIME-1848 - Fim
		CASE WHEN (E10.E10_002_N = 1) AND (T04.T04_001_C <> 'E9004') 
		THEN 
			ISNULL(D28.D28_006_B, 0)
		ELSE 
			ISNULL(D28_1.D28_006_B, 0) 
		END * E11.E11_003_B AS CustoMedioTotal, 
		0 AS ProvisaoComissaoRevenda, 
		0 AS TotalRevendaAntesComissao, 
		0 AS ICMS, 
		0 AS PIS,
		0 AS COFINS, 
		0 AS IRRF, 
		0 AS CSLL,
		0 AS IPI,
		0 AS ISS,
		0 AS ICMSST,
		0 AS IVA,
		ISNULL(
				(
					SELECT MAX(E12.E12_004_B)
					FROM StarWestconCALA2.dbo.E12 E12 (NOLOCK) 
					INNER JOIN StarWestconCALA2.dbo.A40 A40 (NOLOCK) ON E12.A40_UKEY = A40.UKEY
					WHERE E12.E12_UKEYP = E11.UKEY AND UPPER(A40.A40_001_C) = 'TAX'	
				)	
		,0) AS SalesTax,	
		'' AS Estado,
		'' AS Cidade, 
		'' AS VENDEDOR, 
		isnull(E10.E10_001_C,'') AS NFDevolvida,
		E10_UKEY as J10_UKEY,
		'' as J09_UKEY,
		E10.CIA_UKEY as CIA_UKEY,
		A03.UKEY as A03_UKEY,
		E10.A36_CODE,
		RTRIM(LEFT(E10.A36_CODE,5)) AS Currency,
		CASE WHEN RTRIM(LEFT(E10.A36_CODE,5))='US$  ' 
		THEN 
			1 
		ELSE
			(
				SELECT TOP 1 A37_002_B 
				FROM StarWestconCALA2.dbo.A37 A37 (NoLock)
				WHERE A36_UKEYA=LEFT(E10.A36_CODE,5)
					AND A36_UKEY='US$  '
					AND A37_001_D=RIGHT(E10.A36_CODE,8)
			) 
		END as USDRate,
		0 as CodPedido,
		2 AS CodERP,			
		'' as EnderecoFatura,
		'' as BairroFatura,
		'' as CEPFatura,
		'' as PaisFatura,
		'' AS RevenueType,
		null as POEFETIVA,
		E11.E11_998_C AS InvoiceLineNumber,
		CASE WHEN (E10.E10_002_N = 1) AND (T04.T04_001_C <> 'E9004') THEN 1 ELSE -1 END AS FATOR,
		0 COMPLEMENT,
		E11.UKEY AS J11_UKEY,
		CASE A03.A03_504_N WHEN 1 THEN 'No' WHEN 2 THEN 'Intercompany' WHEN 3 THEN 'Related' END AS Intercompany,
		NULL AS ID_INTRANET	,
		1  AS TAX1,  
		1  AS TAX2, 
		 (SELECT CIA.A36_UKEY FROM StarWestconCALA2.DBO.CIA (NOLOCK) WHERE CIA.UKEY = E10.CIA_UKEY) AS CURRENCY_CIA,
		 D03PAI.D03_002_C AS FABRICANTE,
		 D03FILHO.D03_002_C AS FAMILIA,
		 D04_501_N AS MAINTENANCE, -- PRIME-902 
		0 AS VendedorMTK,
		0 AS ResselerMTK,
		D04_502_N AS CLOUD --PRIME-916

	FROM         StarWestconCALA2.dbo.A03 A03 (NOLOCK) 
				 RIGHT OUTER JOIN StarWestconCALA2.dbo.E10 E10 (NOLOCK) 
				 INNER JOIN  StarWestconCALA2.dbo.D04 D04 (NOLOCK) 
				 LEFT JOIN   StarWestconCALA2.dbo.D03 D03FILHO (NOLOCK) ON D04.D03_UKEY = D03FILHO.UKEY 
				 LEFT JOIN   StarWestconCALA2.dbo.D03 D03PAI (NOLOCK) ON D03FILHO.D03_UKEY = D03PAI.UKEY 
				 INNER JOIN  StarWestconCALA2.dbo.E11 E11 (NOLOCK) ON D04.UKEY = E11.D04_UKEY 
				 INNER JOIN  StarWestconCALA2.dbo.T04 T04 (NOLOCK) ON E11.T04_UKEY = T04.UKEY ON E10.UKEY = E11.E10_UKEY ON A03.UKEY = E10.A03_UKEY 
				 LEFT OUTER JOIN StarWestconCALA2.dbo.D22 D22 (NOLOCK) ON E11.UKEY = D22.D22_IUKEYP 
				 LEFT OUTER JOIN StarWestconCALA2.dbo.D28 D28 (NOLOCK) ON D22.UKEY = D28.D28_UKEYP 
				 LEFT OUTER JOIN StarWestconCALA2.dbo.D14 D14 (NOLOCK) ON E11.UKEY = D14.D14_IUKEYP
				 LEFT OUTER JOIN StarWestconCALA2.dbo.D28 D28_1 (NOLOCK) ON D14.UKEY = D28_1.D28_UKEYP 
				 LEFT OUTER JOIN StarWestconCALA2.dbo.A08 A08 (NOLOCK) ON E10.A08_UKEY = A08.UKEY
	WHERE
		(
			E10.E10_006_D >= @FromYYYYMMDD--CONVERT(DATETIME, @FromYYYYMMDD + ' 00:00:00', 102) 
			AND E10.E10_006_D <= @ToYYYYMMDD--CONVERT(DATETIME, @ToYYYYMMDD + ' 23:59:59', 102) 
		)
	    AND A03.CIA_UKEY = (SELECT CIA_UKEYpadrao FROM tblERP (NoLock) WHERE CodERP = @CodERP) AND 
	    (E10.E10_032_N = 0) 
	    AND T04_501_N = 1
	    --AND (T04.T04_001_C ='E9004')

)






