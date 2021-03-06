USE [Westcon]
GO
/****** Object:  UserDefinedFunction [dbo].[getTitulosERPBR]    Script Date: 19/12/2016 14:11:33 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
/*
	*PRION : SCRUM-14867
		- Adicionado retorno de campo StatusCobranca(F40_001_C) e join com StarWestcon.dbo.F40

*/

-- Author:		Danilo Cruz
-- Update date: 27-jan-2015
-- Description:	Alteração no join com tblEmpresaRel prevendo o campo CGCDuplicado.
-- =============================================
-- =============================================
-- Author:		Andres Irazabal
-- Create date: 04-set-2010
-- Description:	Função criada para acelerar queries de Titulos do ERP Brasil
-- =============================================
ALTER FUNCTION [dbo].[getTitulosERPBR]
(	
	@CustomerID numeric
)
RETURNS TABLE 
AS

RETURN 
(
	SELECT  IsNull(es.CustomerID, 0) as CustomerID, 
		A03.UKEY, 
		A03.A03_001_C AS Codigo, 
		A03.A03_007_D as DataCadastro, 
		A03.ARRAY_003 as Situacao, 
		F12.F12_001_C AS Titulo, 
		F12.ARRAY_098 AS Ativo, 
		F12.F12_002_D AS DataEmissao, 
		F12.F12_013_B as ValorFatura, 
		F12.F12_014_N AS Quitado, -- Quitado integralmente
		F12.F12_015_N AS Estornado, -- indica se o título foi estornado
		F12.F12_016_C AS Tipo, --[001] Titulo, [002] Comissao, [003] Adiantamento
		F13.F13_003_D AS DataVencimento, 
		F13.F13_997_D AS DataProrrogacao,
		F13.F13_010_B AS ValorLiquido, -- parcela
		F13.F13_021_B AS ValorQuitado, -- parcela
		F13.F13_029_B AS ValorEstornado, --parcela
		F13.F13_026_N AS Parcelado, 
		ISNULL(A21.A21_001_C,'') AS TIPO_DOC,
		F13.UKEY as F13UKEY,
		F13.F13_999_D as DataRenegociada,
		F40.F40_001_C as StatusCobranca,
		F27.F27_001_B as SaldoCliente --Scrum-15671 
	FROM    StarWestcon.dbo.F12 F12 (nolock) 
		INNER JOIN StarWestcon.dbo.F13 F13 (nolock) ON F12.UKEY = F13.F12_UKEY
		LEFT JOIN StarWestcon.dbo.A21 A21 (nolock) ON A21.UKEY = F13.A21_UKEY 
		INNER JOIN StarWestcon.dbo.A03 A03 (nolock) ON F12.A03_UKEY = A03.UKEY 
		LEFT JOIN StarWestcon.dbo.F40 F40 (nolock) ON F13.F40_UKEY = F40.UKEY 
		LEFT JOIN StarWestcon.dbo.F19 F19 (nolock) ON F19.F19_001_C = A03.A03_001_C--Scrum-15671 
		LEFT JOIN StarWestcon.dbo.F27 F27 (nolock) ON F27.F27_UKEYP = F19.UKEY--Scrum-15671 
		LEFT OUTER JOIN tblEmpresaRel es (nolock) ON es.Codigo = A03.A03_001_C AND es.CGCDuplicado = A03.A03_023_C AND es.CodERP = 1 
	WHERE es.CustomerID=@CustomerID
)

--grant SELECT on [dbo].[getTitulosERPBR] TO Logados












