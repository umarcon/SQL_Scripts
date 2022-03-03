USE [Westcon]
GO
/****** Object:  StoredProcedure [Starsoft].[Reports_CommissionsMap]    Script Date: 06/04/2016 12:13:55 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- execute [Starsoft].[Reports_CriticaAtivoFixo] '20120101', '20160510', ''
alter PROCEDURE [Starsoft].[Reports_CriticaAtivoFixo]
	@PLD_EMISSAOINICIAL			DATE = null ,
	@PLD_EMISSAOFINAL			DATE = null,
	@PLC_DOCUMENTO				varchar(20) = ''
AS
BEGIN

	SELECT * FROM (
		​​SELECT G03_001_C AS CÓDIGO,
		G03_007_C AS NOMEITEM,
		G03_006_C AS DOCUMENTO,
		CAST(G21_001_B AS DECIMAL (15,2)) AS 'VALOR DE COMPRA',
		CAST(G21_002_B AS DECIMAL (15,2)) AS 'VALOR DE ENTRADA',
		G03_002_D AS DATA_DE_COMPRA,
		G03_003_D AS DATA_DE_ENTRADA,
		CASE WHEN G03_004_D IS NULL THEN '' ELSE CONVERT(VARCHAR(10),G03_004_D,105) END AS 'BAIXA',
		CASE WHEN G03_028_N = 1 THEN 'SIM' ELSE 'NÃO' END 'EXECUTA CÁLCULO',
		CASE WHEN G03_041_N = 1 THEN 'SIM' ELSE 'NÃO' END 'EFD PIS/COFINS',
		CASE WHEN T22_002_C IS NULL THEN '' ELSE T22_002_C END AS MARCA,
		CASE WHEN T21_002_C IS NULL THEN '' ELSE T21_002_C END AS MODELO,
		CASE WHEN T23_002_C IS NULL THEN '' ELSE T23_002_C END AS TIPO,
		CASE WHEN G15_002_c IS NULL THEN '' ELSE G15_002_C END AS CÁLCULO,
		CASE WHEN G10_002_B IS NULL THEN '0.00' ELSE CONVERT(NUMERIC(15,2),G10_002_B) END AS TAXA,
		CASE WHEN G03_036_N = 1 THEN 'SIM' ELSE 'NÃO' END  'CÁLCULO CIAP',
		G03_033_N AS 'TOTAL DE PARCELAS',
		G03_035_N AS 'NÚMERO DA PARCELA',
		CONVERT(NUMERIC(15),G03_037_B) AS 'ALIQUOTA',
		CONVERT(NUMERIC(15,2),G03_039_B) AS 'ICMS A APROPRIAR',
		CASE WHEN B11_001_C IS NULL THEN '' ELSE B11_001_C END AS CONTA,
		CASE WHEN B11_003_C IS NULL THEN '' ELSE B11_003_C END AS B11DESCRIÇÃO,
		CASE WHEN A11_001_C IS NULL THEN '' ELSE A11_001_C END AS CRD,
		CASE WHEN A11_003_C IS NULL THEN '' ELSE A11_003_C END AS A11DESCRIÇÃO, 
		ISNULL(
		CASE
		WHEN ARRAY_781 = 1 THEN '01-Aquisição de bens para revenda'
		WHEN ARRAY_781 = 2 THEN '02-Aquisição de bens utilizados como insumo'
		WHEN ARRAY_781 = 3 THEN '03-Aquisição de serviços utilizados como insumo'
		WHEN ARRAY_781 = 4 THEN '04-Energia elétrica e térmica, inclusive sob a forma de vapor'
		WHEN ARRAY_781 = 5 THEN '05-Aluguéis de prédios'
		WHEN ARRAY_781 = 6 THEN '06-Aluguéis de máquinas e equipamentos'
		WHEN ARRAY_781 = 7 THEN '07-Armazenagem de mercadoria e frete na operação de venda'
		WHEN ARRAY_781 = 8 THEN '08-Contraprestações de arrendamento mercantil'
		WHEN ARRAY_781 = 9 THEN '09-Máquinas, equipamentos e outros bens incorporados ao ativo imobilizado (crédito sobre encargos de depreciação)'
		WHEN ARRAY_781 = 10 THEN '10-Máquinas, equipamentos e outros bens incorporados ao ativo imobilizado (crédito com base no valor de aquisição)'
		WHEN ARRAY_781 = 11 THEN '11-Amortização de edificações e benfeitorias em imóveis'
		WHEN ARRAY_781 = 12 THEN '12-Devolução de vendas sujeitas à incidência não-cumulativa'
		WHEN ARRAY_781 = 13 THEN '13-Outras operações com direito a crédito'
		WHEN ARRAY_781 = 14 THEN '14-Atividade de transporte de cargas – subcontratação'
		WHEN ARRAY_781 = 15 THEN '17-Atividade de prestação de serviços de limpeza, conservação e manutenção' END, '') AS 'BASE DO CRÉDITO',
		ISNULL(
		CASE
		WHEN ARRAY_792 = 1 THEN '01 – Edificações e benfeitorias em imóveis próprios'
		WHEN ARRAY_792 = 2 THEN '02 – Edificações e benfeitorias em imóveis de terceiros'
		WHEN ARRAY_792 = 3 THEN '03 – Instalações'
		WHEN ARRAY_792 = 4 THEN '04 – Máquinas'
		WHEN ARRAY_792 = 5 THEN '05 – Equipamentos'
		WHEN ARRAY_792 = 6 THEN '06 – Veículos'
		WHEN ARRAY_792 = 7 THEN '99 – Outros' END, '') AS 'IDENTIFICAÇÃO DOS BENS',
		ISNULL(
		CASE
		WHEN ARRAY_794 = 1 THEN '1 – Produção de bens destinados a venda'
		WHEN ARRAY_794 = 2 THEN '2 – Prestação de serviços'
		WHEN ARRAY_794 = 3 THEN '3 – Locação a terceiros'
		WHEN ARRAY_794 = 4 THEN ' 9 – Outros' END, '') AS 'UTILIZAÇÃO DOS BENS',
		CASE WHEN G21_001_B <> isnull((SELECT TOP 1 CAST(E11_005_B AS DECIMAL (15,2)) FROM STARWESTCON.DBO.E11 (NOLOCK) INNER JOIN STARWESTCON.DBO.E38 (NOLOCK) ON E38.E11_UKEY = E11.UKEY WHERE E38.G03_UKEY = G03.UKEY ),0) THEN 'O valor de compra do bem '+ltrim(rtrim(G03_007_C))+' difere do valor de compra do item no documento de entrada.' ELSE '' END AS CRITICA01,
		CASE WHEN G03_028_N = 0 THEN 'O flag "Executa Cálculo" está desmarcado.' ELSE '' END AS CRITICA02,
		CASE WHEN ((B11_001_C = '1304150001') OR (B11_001_C = '1304070001')) AND G03_036_N = 0 THEN 'Bens que possuem a conta contábil (1304150001, 1304070001) devem possuir integração com o CIAP.' ELSE '' END AS CRITICA03,
		CASE WHEN ISNULL(A11_001_C,'') = '' THEN 'O centro de custos do ativo não foi informado.' ELSE '' END AS CRITICA04,
		CASE WHEN ISNULL(B11_001_C,'') = '' THEN 'A conta contábil do bem não foi informada.' ELSE '' END AS CRITICA05,
		CASE WHEN B24.B11_UKEYA = '' AND B24.B11_UKEYB = '' THEN 'As contas de depreciação do bem não foram informadas.' ELSE '' END AS CRITICA06,
		CASE WHEN ISNULL(T22_002_C,'') = '' THEN 'A Marca do bem não foi informada.' ELSE '' END AS CRITICA07,
		CASE WHEN ISNULL(T21_002_C,'') = '' THEN 'O Modelo do bem não foi informado.' ELSE '' END AS CRITICA08,
		CASE WHEN ISNULL(T23_002_C,'') = '' THEN 'O Tipo do bem não foi informado.' ELSE '' END AS CRITICA09,
		CASE WHEN ISNULL(G03_001_C,'') = '' THEN 'O Código do bem não foi informado.' ELSE '' END AS CRITICA10,
		CASE WHEN ISNULL(G03_007_C,'') = '' THEN 'A descrição do bem não foi informada.' ELSE '' END AS CRITICA11,
		CASE WHEN ISNULL(G03_006_C,'') = '' THEN 'O número do documento referente ao bem não foi informado.' ELSE '' END AS CRITICA12,
		CASE WHEN ((B11_001_C = '1304150001') OR (B11_001_C = '1304070001')) AND G03_041_N = 0 THEN 'O campo "Declarar EFD" está desmarcado.' ELSE '' END AS CRITICA13,
		CASE WHEN G03_036_N = 1 AND G03_033_N <> 48 THEN 'Flag ''Cálculo do Ciap" marcado e total de parcelas diferente de 48.' ELSE '' END AS CRITICA14,
		CASE WHEN G03_036_N = 1 AND G03_035_N = 0 THEN 'Flag ''Cálculo do Ciap" marcado e número da parcela está vazio.' ELSE '' END AS CRITICA15,
		CASE WHEN G03_036_N = 1 AND G03_037_B = 0 THEN 'Flag ''Cálculo do Ciap" marcado e alíquota do ICMS está vazia.' ELSE '' END AS CRITICA16,
		CASE WHEN G03_036_N = 1 AND G03_039_B = 0 THEN 'Flag ''Cálculo do Ciap" marcado e ICMS a apropriar está zerado.' ELSE '' END AS CRITICA17,
		CASE WHEN G03_036_N = 1 AND (((G03_037_B*G21_001_B)-G03_039_B) < 10 ) THEN 'Valor do ICMS a apropriar difere da multiplicação da aliquota x valor de compra do bem.' ELSE '' END AS CRITICA18,
		CASE WHEN G03.ARRAY_781 <> 9 AND G03.ARRAY_781 <> 10 THEN 'Base de Crédito diferente de  9 - Crédito com base na Depreciação ou 10 - Crédito com base Aquisição.' ELSE '' END AS CRITICA19,
		CASE WHEN ISNULL((SELECT TOP 1 G15A.G15_001_C FROM STARWESTCON.DBO.G10 G10A (NOLOCK) INNER JOIN STARWESTCON.DBO.G15 G15A (NOLOCK) ON G10A.G15_UKEY = G15A.UKEY WHERE G10A.G03_UKEY = G03.UKEY AND LTRIM(RTRIM(G15A.G15_001_C)) = 'F$ MENSAL'),'') = '' THEN 'Taxa de depreciação FISCAL não cadastrada no bem.' ELSE '' END AS CRITICA20,
		CASE WHEN ISNULL((SELECT TOP 1 G15A.G15_001_C FROM STARWESTCON.DBO.G10 G10A (NOLOCK) INNER JOIN STARWESTCON.DBO.G15 G15A (NOLOCK) ON G10A.G15_UKEY = G15A.UKEY WHERE G10A.G03_UKEY = G03.UKEY AND LTRIM(RTRIM(G15A.G15_001_C)) = 'R$ MENSAL'),'') = '' THEN 'Taxa de depreciação REAL não cadastrada no bem.' ELSE '' END AS CRITICA21,
		CASE WHEN E11_003_B <> (SELECT COUNT(E38A.G03_UKEY) FROM STARWESTCON.DBO.E38 E38A (NOLOCK) WHERE E38A.E11_UKEY = E11.UKEY) THEN 'Total de itens integrados para o ativo difere da quantidade de itens da nota fiscal.' ELSE '' END AS CRITICA22
		FROM STARWESTCON.DBO.G03 (NOLOCK)
		LEFT JOIN STARWESTCON.DBO.G21 (NOLOCK) ON G21.G03_UKEY = G03.UKEY
		LEFT JOIN STARWESTCON.DBO.G10 (NOLOCK) ON G10.G03_UKEY = G03.UKEY
		LEFT JOIN STARWESTCON.DBO.G15 (NOLOCK) ON G10.G15_UKEY = G15.UKEY
		LEFT JOIN STARWESTCON.DBO.G17 (NOLOCK) ON G17.G03_UKEY = G03.UKEY
		LEFT JOIN STARWESTCON.DBO.B11 (NOLOCK) ON G17.B11_UKEYA = B11.UKEY
		LEFT JOIN STARWESTCON.DBO.T21 (NOLOCK) ON G03.T21_UKEY = T21.UKEY
		LEFT JOIN STARWESTCON.DBO.T22 (NOLOCK) ON G03.T22_UKEY = T22.UKEY
		LEFT JOIN STARWESTCON.DBO.T23 (NOLOCK) ON G03.T23_UKEY = T23.UKEY
		LEFT JOIN STARWESTCON.DBO.A11 (NOLOCK) ON G17.A11_UKEYA = A11.UKEY
		LEFT JOIN STARWESTCON.DBO.E38 (NOLOCK) ON E38.G03_UKEY = G03.UKEY
		LEFT JOIN STARWESTCON.DBO.E11 (NOLOCK) ON E38.E11_UKEY = E11.UKEY
		LEFT JOIN STARWESTCON.DBO.B24 (NOLOCK) ON B24.B24_UKEYP1 = G03.UKEY
		WHERE G03_003_D BETWEEN @PLD_EMISSAOINICIAL AND @PLD_EMISSAOFINAL AND (@PLC_DOCUMENTO = '' OR G03_006_C LIKE @PLC_DOCUMENTO+'%')
	)TMP
	WHERE CRITICA01 <> '' OR CRITICA02 <> '' OR CRITICA03 <> '' OR CRITICA04 <> '' OR CRITICA05 <> '' OR CRITICA06 <> '' OR CRITICA07 <> '' OR CRITICA08 <> '' OR CRITICA09 <> '' OR CRITICA10 <> '' OR CRITICA11 <> '' OR CRITICA12 <> '' OR CRITICA13 <> ''
	OR CRITICA14 <> '' OR CRITICA15 <> '' OR CRITICA16 <> '' OR CRITICA17 <> '' OR CRITICA18 <> '' OR CRITICA19 <> '' OR CRITICA20 <> '' OR CRITICA21 <> '' OR CRITICA22 <> ''
	ORDER BY TMP.DATA_DE_COMPRA DESC
END