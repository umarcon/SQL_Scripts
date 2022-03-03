USE [Westcon]
GO
/****** Object:  StoredProcedure [Starsoft].[Reports_AtualizaBI_Receita]    Script Date: 11/07/2016 10:48:25 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


alter PROCEDURE [Starsoft].[BiReceitaContabil]
        @CodERP INT, --CodERP vindo da Intranet de(1 = Brasil, 2 = Cala, 3 = Mexico, 4 = Colombia)
        @DATAINI DATE, -- Data Inicial da Emissão da NF
        @DATAFIM DATE -- Data Final da Emissão da NF

--EXEC [Starsoft].[BiReceitaContabil] 1, '20160301', '20160531'

as

IF @CodErp = 1
	BEGIN
		insert into Reports.BIReceita (fabricante, familia, nf, emissaonf, customediototal, CodPedido, CodERP, Currency, USDRate, RebateNumber, ExtendedClaimAmount, NomeERP, NomeRegiao, NomeDivisao, ReceitaLiquida, LucroVenda, CodRegiao, J11_UKEY, PartNumber, 
							ValorUnitarioNF, NFDevolvida, Complement, Intercompany)
		select 'Hyperion Expenses' as fabricante, 
		'Hyperion Expenses' as familia, 
		'Hyperion Exp'+rtrim(ltrim(iif(len(cast(year(b06_002_d) as char))=1,'0'+cast(year(b06_002_d) as char),cast(year(b06_002_d) as char))))+
		ltrim(rtrim(iif(len(cast(month(b06_002_d) as char))=1,'0'+cast(month(b06_002_d) as char),cast(month(b06_002_d) as char))))+
		ltrim(rtrim(iif(len(cast(day(b06_002_d) as char))=1,'0'+cast(day(b06_002_d) as char),cast(day(b06_002_d) as char)))) as nf, 
		B06_002_D as emissaonf, 
		case when substring(b06.a36_code0,1,3) = 'R$ ' then iif(sum(b07_007_b *  B07_012_N) - sum(b07_007_b * B07_011_N) < 0, (sum(b07_007_b *  B07_012_N) - sum(b07_007_b * B07_011_N)*-1), sum(b07_007_b *  B07_012_N) - sum(b07_007_b * B07_011_N)) / A37TAX.A37_002_B else sum(b07_007_b *  B07_012_N) - sum(b07_007_b * B07_011_N) end as customediototal, 
		'-1' as CodPedido, 
		@CodErp as CodERP, 
		'US$' as Currency, 
		A37tax.a37_002_b as USDRate, 
		'' as RebateNumber, 
		0 as ExtendedClaimAmount,
		(select nomeerp from westcon.dbo.tblERP where CodERP = @CodERP) as NomeERP, 
		(select top 1 nomeregiao from westcon.[dbo].[fnBIDadosPedidosIntranet](@CodErp)) as NomeRegiao,
		(select top 1 nomedivisao from westcon.[dbo].[fnBIDadosPedidosIntranet](@CodErp)) as NomeDivisao, 
		0 as ReceitaLiquida, 
		case when substring(b06.a36_code0,1,3) = 'R$ ' then sum(b07_007_b *  B07_012_N) - sum(b07_007_b * B07_011_N) / A37TAX.A37_002_B else sum(b07_007_b *  B07_012_N) - sum(b07_007_b * B07_011_N) end as LucroVenda,
		(select top 1 CodRegiao from westcon.[dbo].[fnBIDadosPedidosIntranet](@CodErp)) as CodRegiao, 
		'Hyperion Exp'+rtrim(ltrim(iif(len(cast(year(b06_002_d) as char))=1,'0'+cast(year(b06_002_d) as char),cast(year(b06_002_d) as char))))+
		ltrim(rtrim(iif(len(cast(month(b06_002_d) as char))=1,'0'+cast(month(b06_002_d) as char),cast(month(b06_002_d) as char))))+
		ltrim(rtrim(iif(len(cast(day(b06_002_d) as char))=1,'0'+cast(day(b06_002_d) as char),cast(day(b06_002_d) as char)))) as J11_UKEY, 
		'Hyperion Exp'+rtrim(ltrim(iif(len(cast(year(b06_002_d) as char))=1,'0'+cast(year(b06_002_d) as char),cast(year(b06_002_d) as char))))+
		ltrim(rtrim(iif(len(cast(month(b06_002_d) as char))=1,'0'+cast(month(b06_002_d) as char),cast(month(b06_002_d) as char))))+
		ltrim(rtrim(iif(len(cast(day(b06_002_d) as char))=1,'0'+cast(day(b06_002_d) as char),cast(day(b06_002_d) as char)))) as PartNumber, 
		0 as ValorUnitarioNF,
		'' as NFDevolvida, 
		0 as Complement, 
		'No' as Intercompany
		FROM StarWestcon.dbo.B07 B07 WITH (NoLock)
		INNER JOIN StarWestcon.dbo.B06 B06 WITH (NoLock) ON B07.B06_UKEY = B06.UKEY 
		INNER JOIN StarWestcon.dbo.B11 B11 WITH (NoLock) ON B07.B11_UKEY = B11.UKEY 
		INNER JOIN 	(
						SELECT 
						/* PARA TAXA MENSAM (A54.A54_013_N = 1) É TRATADO PARA DEIXAR O CAMPO A37.A37_001_D COM O DIA 01 */
						CASE A54.A54_013_N WHEN 1 THEN SUBSTRING(CONVERT(CHAR, A37.A37_001_D, 112),1 , 6) + '01' ELSE A37.A37_001_D END AS A37_001_D,
						A37.A37_002_B,
						A37.A36_UKEYA,
						A37.A36_UKEY,
						A54.A54_013_N
						FROM StarWestcon.dbo.A36 (NOLOCK) 
						INNER JOIN StarWestcon.dbo.A54 (nolock) on A54.A36_UKEY = A36.UKEY
						INNER JOIN StarWestcon.dbo.A37 (nolock) on A37.A36_UKEY = A36.UKEY
						) A37TAX ON CASE A37TAX.A54_013_N WHEN 0 THEN B06.B06_002_D ELSE SUBSTRING(CONVERT(CHAR, B06.B06_002_D, 112),1 , 6) + '01' END = A37TAX.A37_001_D
		where a37TAX.a36_ukey = SUBSTRING(B06.A36_CODE0,1,5) AND A37TAX.A36_UKEYA = 'US$  ' and 
		 b06.b06_002_d between @DATAINI and @DATAFIM
		 and  (b11_001_c like '3302%' or b11_001_c like '3303%') and b11_001_c <> '3302050002'
		group by substring(b11_001_c,1,4), year(b06_002_d),month(b06_002_d), day(b06_002_d), b06_002_d, B06.a36_code0, A37tax.a37_002_b
		order by month(b06_002_d), day(b06_002_d) 

	END

IF @CodErp = 2
	BEGIN
		insert into Reports.BIReceita (fabricante, familia, nf, emissaonf, customediototal, CodPedido, CodERP, Currency, USDRate, RebateNumber, ExtendedClaimAmount, NomeERP, NomeRegiao, NomeDivisao, ReceitaLiquida, LucroVenda, CodRegiao, J11_UKEY, PartNumber, 
							ValorUnitarioNF, NFDevolvida, Complement, Intercompany)
		select 'Hyperion Expenses' as fabricante, 
		'Hyperion Expenses' as familia, 
		'Hyperion Exp'+rtrim(ltrim(iif(len(cast(year(b06_002_d) as char))=1,'0'+cast(year(b06_002_d) as char),cast(year(b06_002_d) as char))))+
		ltrim(rtrim(iif(len(cast(month(b06_002_d) as char))=1,'0'+cast(month(b06_002_d) as char),cast(month(b06_002_d) as char))))+
		ltrim(rtrim(iif(len(cast(day(b06_002_d) as char))=1,'0'+cast(day(b06_002_d) as char),cast(day(b06_002_d) as char)))) as nf, 
		B06_002_D as emissaonf, 
		case when substring(b06.a36_code0,1,3) <> 'US$' then sum(b07_007_b *  B07_012_N) - sum(b07_007_b * B07_011_N) / A37TAX.A37_002_B else sum(b07_007_b *  B07_012_N) - sum(b07_007_b * B07_011_N) end as customediototal, 
		'-1' as CodPedido, 
		@CodErp as CodERP, 
		'US$' as Currency, 
		A37tax.a37_002_b as USDRate, 
		'' as RebateNumber, 
		0 as ExtendedClaimAmount,
		(select nomeerp from westcon.dbo.tblERP where CodERP = @CodERP) as NomeERP, 
		(select top 1 nomeregiao from westcon.[dbo].[fnBIDadosPedidosIntranet](@CodErp)) as NomeRegiao,
		(select top 1 nomedivisao from westcon.[dbo].[fnBIDadosPedidosIntranet](@CodErp)) as NomeDivisao, 
		0 as ReceitaLiquida, 
		case when substring(b06.a36_code0,1,3) <> 'US$' then sum(b07_007_b *  B07_012_N) - sum(b07_007_b * B07_011_N) / A37TAX.A37_002_B else sum(b07_007_b *  B07_012_N) - sum(b07_007_b * B07_011_N) end as LucroVenda,
		(select top 1 CodRegiao from westcon.[dbo].[fnBIDadosPedidosIntranet](@CodErp)) as CodRegiao, 
		'Hyperion Exp'+rtrim(ltrim(iif(len(cast(year(b06_002_d) as char))=1,'0'+cast(year(b06_002_d) as char),cast(year(b06_002_d) as char))))+
		ltrim(rtrim(iif(len(cast(month(b06_002_d) as char))=1,'0'+cast(month(b06_002_d) as char),cast(month(b06_002_d) as char))))+
		ltrim(rtrim(iif(len(cast(day(b06_002_d) as char))=1,'0'+cast(day(b06_002_d) as char),cast(day(b06_002_d) as char)))) as J11_UKEY, 
		'Hyperion Exp'+rtrim(ltrim(iif(len(cast(year(b06_002_d) as char))=1,'0'+cast(year(b06_002_d) as char),cast(year(b06_002_d) as char))))+
		ltrim(rtrim(iif(len(cast(month(b06_002_d) as char))=1,'0'+cast(month(b06_002_d) as char),cast(month(b06_002_d) as char))))+
		ltrim(rtrim(iif(len(cast(day(b06_002_d) as char))=1,'0'+cast(day(b06_002_d) as char),cast(day(b06_002_d) as char)))) as PartNumber, 
		0 as ValorUnitarioNF,
		'' as NFDevolvida, 
		0 as Complement, 
		'No' as Intercompany
		FROM StarWestconCala2.dbo.B07 B07 WITH (NoLock)
		INNER JOIN StarWestconCala2.dbo.B06 B06 WITH (NoLock) ON B07.B06_UKEY = B06.UKEY 
		INNER JOIN StarWestconCala2.dbo.B11 B11 WITH (NoLock) ON B07.B11_UKEY = B11.UKEY 
		INNER JOIN 	(
						SELECT 
						/* PARA TAXA MENSAM (A54.A54_013_N = 1) É TRATADO PARA DEIXAR O CAMPO A37.A37_001_D COM O DIA 01 */
						CASE A54.A54_013_N WHEN 1 THEN SUBSTRING(CONVERT(CHAR, A37.A37_001_D, 112),1 , 6) + '01' ELSE A37.A37_001_D END AS A37_001_D,
						A37.A37_002_B,
						A37.A36_UKEYA,
						A37.A36_UKEY,
						A54.A54_013_N
						FROM StarWestconcala2.dbo.A36 (NOLOCK) 
						INNER JOIN StarWestconCala2.dbo.A54 (nolock) on A54.A36_UKEY = A36.UKEY
						INNER JOIN StarWestconCala2.dbo.A37 (nolock) on A37.A36_UKEY = A36.UKEY AND A37.CIA_UKEY = 'STAR_'
						) A37TAX ON CASE A37TAX.A54_013_N WHEN 0 THEN B06.B06_002_D ELSE SUBSTRING(CONVERT(CHAR, B06.B06_002_D, 112),1 , 6) + '01' END = A37TAX.A37_001_D
		where a37TAX.a36_ukey = SUBSTRING(B06.A36_CODE0,1,5) AND A37TAX.A36_UKEYA = 'US$  ' and b06.cia_ukey = 'star_' and
		 b06.b06_002_d between @DATAINI and @DATAFIM
		 and  (b11_001_c like '3302%' or b11_001_c like '3303%') and b11_001_c <> '3302050002'
		group by substring(b11_001_c,1,4), year(b06_002_d),month(b06_002_d), day(b06_002_d), b06_002_d, B06.a36_code0, A37tax.a37_002_b, b06.cia_ukey
		order by month(b06_002_d), day(b06_002_d) 

	END

IF @CodErp = 3
	BEGIN
		insert into Reports.BIReceita (fabricante, familia, nf, emissaonf, customediototal, CodPedido, CodERP, Currency, USDRate, RebateNumber, ExtendedClaimAmount, NomeERP, NomeRegiao, NomeDivisao, ReceitaLiquida, LucroVenda, CodRegiao, J11_UKEY, PartNumber, 
					ValorUnitarioNF, NFDevolvida, Complement, Intercompany)
		select 'Hyperion Expenses' as fabricante, 
		'Hyperion Expenses' as familia, 
		'Hyperion Exp'+rtrim(ltrim(iif(len(cast(year(b06_002_d) as char))=1,'0'+cast(year(b06_002_d) as char),cast(year(b06_002_d) as char))))+
		ltrim(rtrim(iif(len(cast(month(b06_002_d) as char))=1,'0'+cast(month(b06_002_d) as char),cast(month(b06_002_d) as char))))+
		ltrim(rtrim(iif(len(cast(day(b06_002_d) as char))=1,'0'+cast(day(b06_002_d) as char),cast(day(b06_002_d) as char)))) as nf, 
		B06_002_D as emissaonf, 
		case when substring(b06.a36_code0,1,3) = 'MN ' then sum(b07_007_b *  B07_012_N) - sum(b07_007_b * B07_011_N) / A37TAX.A37_002_B else sum(b07_007_b *  B07_012_N) - sum(b07_007_b * B07_011_N) end as customediototal, 
		'-1' as CodPedido, 
		@CodErp as CodERP, 
		'US$' as Currency, 
		A37tax.a37_002_b as USDRate, 
		'' as RebateNumber, 
		0 as ExtendedClaimAmount
		, (select nomeerp from westcon.dbo.tblERP where CodERP = @CodERP) as NomeERP, (select top 1 nomeregiao from westcon.[dbo].[fnBIDadosPedidosIntranet](@CodErp)) as NomeRegiao
		, (select top 1 nomedivisao from westcon.[dbo].[fnBIDadosPedidosIntranet](@CodErp)) as NomeDivisao, 0 as ReceitaLiquida, 
		case when substring(b06.a36_code0,1,3) = 'MN ' then sum(b07_007_b *  B07_012_N) - sum(b07_007_b * B07_011_N) / A37TAX.A37_002_B else sum(b07_007_b *  B07_012_N) - sum(b07_007_b * B07_011_N) end as LucroVenda
		, (select top 1 CodRegiao from westcon.[dbo].[fnBIDadosPedidosIntranet](@CodErp)) as CodRegiao, 
		'Hyperion Exp'+rtrim(ltrim(iif(len(cast(year(b06_002_d) as char))=1,'0'+cast(year(b06_002_d) as char),cast(year(b06_002_d) as char))))+
		ltrim(rtrim(iif(len(cast(month(b06_002_d) as char))=1,'0'+cast(month(b06_002_d) as char),cast(month(b06_002_d) as char))))+
		ltrim(rtrim(iif(len(cast(day(b06_002_d) as char))=1,'0'+cast(day(b06_002_d) as char),cast(day(b06_002_d) as char)))) as J11_UKEY, 
		'Hyperion Exp'+rtrim(ltrim(iif(len(cast(year(b06_002_d) as char))=1,'0'+cast(year(b06_002_d) as char),cast(year(b06_002_d) as char))))+
		ltrim(rtrim(iif(len(cast(month(b06_002_d) as char))=1,'0'+cast(month(b06_002_d) as char),cast(month(b06_002_d) as char))))+
		ltrim(rtrim(iif(len(cast(day(b06_002_d) as char))=1,'0'+cast(day(b06_002_d) as char),cast(day(b06_002_d) as char)))) as PartNumber, 
		0 as ValorUnitarioNF,
		'' as NFDevolvida, 
		0 as Complement, 
		'No' as Intercompany
		FROM StarWestconMx.dbo.B07 B07 WITH (NoLock)
		INNER JOIN StarWestconMx.dbo.B06 B06 WITH (NoLock) ON B07.B06_UKEY = B06.UKEY 
		INNER JOIN StarWestconMx.dbo.B11 B11 WITH (NoLock) ON B07.B11_UKEY = B11.UKEY 
		INNER JOIN 	(
						SELECT 
						/* PARA TAXA MENSAM (A54.A54_013_N = 1) É TRATADO PARA DEIXAR O CAMPO A37.A37_001_D COM O DIA 01 */
						CASE A54.A54_013_N WHEN 1 THEN SUBSTRING(CONVERT(CHAR, A37.A37_001_D, 112),1 , 6) + '01' ELSE A37.A37_001_D END AS A37_001_D,
						A37.A37_002_B,
						A37.A36_UKEYA,
						A37.A36_UKEY,
						A54.A54_013_N
						FROM StarWestconMx.dbo.A36 (NOLOCK) 
						INNER JOIN StarWestconMx.dbo.A54 (nolock) on A54.A36_UKEY = A36.UKEY
						INNER JOIN StarWestconMx.dbo.A37 (nolock) on A37.A36_UKEY = A36.UKEY
						) A37TAX ON CASE A37TAX.A54_013_N WHEN 0 THEN B06.B06_002_D ELSE SUBSTRING(CONVERT(CHAR, B06.B06_002_D, 112),1 , 6) + '01' END = A37TAX.A37_001_D
		where a37TAX.a36_ukey = SUBSTRING(B06.A36_CODE0,1,5) AND A37TAX.A36_UKEYA = 'US$  ' and 
		 b06.b06_002_d between @DATAINI and @DATAFIM
		 and  (b11_001_c like '3302%' or b11_001_c like '3303%') and b11_001_c <> '3302050002'
		group by substring(b11_001_c,1,4), year(b06_002_d),month(b06_002_d), day(b06_002_d), b06_002_d, B06.a36_code0, A37tax.a37_002_b
		order by month(b06_002_d), day(b06_002_d) 
	END

IF @CodErp = 4
	BEGIN
		insert into Reports.BIReceita (fabricante, familia, nf, emissaonf, customediototal, CodPedido, CodERP, Currency, USDRate, RebateNumber, ExtendedClaimAmount, NomeERP, NomeRegiao, NomeDivisao, ReceitaLiquida, LucroVenda, CodRegiao, J11_UKEY, PartNumber, 
					ValorUnitarioNF, NFDevolvida, Complement, Intercompany)
		select 'Hyperion Expenses' as fabricante, 
		'Hyperion Expenses' as familia, 
		'Hyperion Exp'+rtrim(ltrim(iif(len(cast(year(b06_002_d) as char))=1,'0'+cast(year(b06_002_d) as char),cast(year(b06_002_d) as char))))+
		ltrim(rtrim(iif(len(cast(month(b06_002_d) as char))=1,'0'+cast(month(b06_002_d) as char),cast(month(b06_002_d) as char))))+
		ltrim(rtrim(iif(len(cast(day(b06_002_d) as char))=1,'0'+cast(day(b06_002_d) as char),cast(day(b06_002_d) as char)))) as nf, 
		B06_002_D as emissaonf, 
		case when substring(b06.a36_code0,1,3) = '$  ' then sum(b07_007_b *  B07_012_N) - sum(b07_007_b * B07_011_N) / A37TAX.A37_002_B else sum(b07_007_b *  B07_012_N) - sum(b07_007_b * B07_011_N) end as customediototal, 
		'-1' as CodPedido, 
		@CodErp as CodERP, 
		'US$' as Currency, 
		A37tax.a37_002_b as USDRate, 
		'' as RebateNumber, 
		0 as ExtendedClaimAmount
		, (select nomeerp from westcon.dbo.tblERP where CodERP = @CodERP) as NomeERP, 
		(select top 1 nomeregiao from westcon.[dbo].[fnBIDadosPedidosIntranet](@CodErp)) as NomeRegiao
		, (select top 1 nomedivisao from westcon.[dbo].[fnBIDadosPedidosIntranet](@CodErp)) as NomeDivisao, 
		0 as ReceitaLiquida, 
		case when substring(b06.a36_code0,1,3) = '$  ' then sum(b07_007_b *  B07_012_N) - sum(b07_007_b * B07_011_N) / A37TAX.A37_002_B else sum(b07_007_b *  B07_012_N) - sum(b07_007_b * B07_011_N) end as LucroVenda
		, (select top 1 CodRegiao from westcon.[dbo].[fnBIDadosPedidosIntranet](@CodErp)) as CodRegiao, 
		'Hyperion Exp'+rtrim(ltrim(iif(len(cast(year(b06_002_d) as char))=1,'0'+cast(year(b06_002_d) as char),cast(year(b06_002_d) as char))))+
		ltrim(rtrim(iif(len(cast(month(b06_002_d) as char))=1,'0'+cast(month(b06_002_d) as char),cast(month(b06_002_d) as char))))+
		ltrim(rtrim(iif(len(cast(day(b06_002_d) as char))=1,'0'+cast(day(b06_002_d) as char),cast(day(b06_002_d) as char)))) as J11_UKEY, 
		'Hyperion Exp'+rtrim(ltrim(iif(len(cast(year(b06_002_d) as char))=1,'0'+cast(year(b06_002_d) as char),cast(year(b06_002_d) as char))))+
		ltrim(rtrim(iif(len(cast(month(b06_002_d) as char))=1,'0'+cast(month(b06_002_d) as char),cast(month(b06_002_d) as char))))+
		ltrim(rtrim(iif(len(cast(day(b06_002_d) as char))=1,'0'+cast(day(b06_002_d) as char),cast(day(b06_002_d) as char)))) as PartNumber, 
		0 as ValorUnitarioNF,
		'' as NFDevolvida, 
		0 as Complement, 
		'No' as Intercompany
		FROM StarWestcon.dbo.B07 B07 WITH (NoLock)
		INNER JOIN StarWestcon.dbo.B06 B06 WITH (NoLock) ON B07.B06_UKEY = B06.UKEY 
		INNER JOIN StarWestcon.dbo.B11 B11 WITH (NoLock) ON B07.B11_UKEY = B11.UKEY 
		INNER JOIN 	(
						SELECT 
						/* PARA TAXA MENSAM (A54.A54_013_N = 1) É TRATADO PARA DEIXAR O CAMPO A37.A37_001_D COM O DIA 01 */
						CASE A54.A54_013_N WHEN 1 THEN SUBSTRING(CONVERT(CHAR, A37.A37_001_D, 112),1 , 6) + '01' ELSE A37.A37_001_D END AS A37_001_D,
						A37.A37_002_B,
						A37.A36_UKEYA,
						A37.A36_UKEY,
						A54.A54_013_N
						FROM StarWestcon.dbo.A36 (NOLOCK) 
						INNER JOIN StarWestcon.dbo.A54 (nolock) on A54.A36_UKEY = A36.UKEY
						INNER JOIN StarWestcon.dbo.A37 (nolock) on A37.A36_UKEY = A36.UKEY
						) A37TAX ON CASE A37TAX.A54_013_N WHEN 0 THEN B06.B06_002_D ELSE SUBSTRING(CONVERT(CHAR, B06.B06_002_D, 112),1 , 6) + '01' END = A37TAX.A37_001_D
		where a37TAX.a36_ukey = SUBSTRING(B06.A36_CODE0,1,5) AND A37TAX.A36_UKEYA = 'US$  ' and b06.cia_ukey in ('M8530','M8531') and
		 b06.b06_002_d between @DATAINI and @DATAFIM
		 and  (b11_001_c like '3302%' or b11_001_c like '3303%') and b11_001_c <> '3302050002'
		group by substring(b11_001_c,1,4), year(b06_002_d),month(b06_002_d), day(b06_002_d), b06_002_d, B06.a36_code0, A37tax.a37_002_b, b06.cia_ukey
		order by month(b06_002_d), day(b06_002_d) 

	END

IF @CodErp = 5
	BEGIN
		insert into Reports.BIReceita (fabricante, familia, nf, emissaonf, customediototal, CodPedido, CodERP, Currency, USDRate, RebateNumber, ExtendedClaimAmount, NomeERP, NomeRegiao, NomeDivisao, ReceitaLiquida, LucroVenda, CodRegiao, J11_UKEY, PartNumber, 
					ValorUnitarioNF, NFDevolvida, Complement, Intercompany)
		select 'Hyperion Expenses' as fabricante, 
		'Hyperion Expenses' as familia, 
		'Hyperion Exp'+rtrim(ltrim(iif(len(cast(year(b06_002_d) as char))=1,'0'+cast(year(b06_002_d) as char),cast(year(b06_002_d) as char))))+
		ltrim(rtrim(iif(len(cast(month(b06_002_d) as char))=1,'0'+cast(month(b06_002_d) as char),cast(month(b06_002_d) as char))))+
		ltrim(rtrim(iif(len(cast(day(b06_002_d) as char))=1,'0'+cast(day(b06_002_d) as char),cast(day(b06_002_d) as char)))) as nf, 
		B06_002_D as emissaonf, 
		case when substring(b06.a36_code0,1,3) = 'PEN' then sum(b07_007_b *  B07_012_N) - sum(b07_007_b * B07_011_N) / A37TAX.A37_002_B else sum(b07_007_b *  B07_012_N) - sum(b07_007_b * B07_011_N) end as customediototal, 
		'-1' as CodPedido, 
		@CodErp as CodERP, 
		'US$' as Currency, 
		A37tax.a37_002_b as USDRate, 
		'' as RebateNumber, 
		0 as ExtendedClaimAmount
		, (select nomeerp from westcon.dbo.tblERP where CodERP = @CodERP) as NomeERP, 
		(select top 1 nomeregiao from westcon.[dbo].[fnBIDadosPedidosIntranet](@CodErp)) as NomeRegiao
		, (select top 1 nomedivisao from westcon.[dbo].[fnBIDadosPedidosIntranet](@CodErp)) as NomeDivisao, 0 as ReceitaLiquida, 
		case when substring(b06.a36_code0,1,3) = 'PEN' then sum(b07_007_b *  B07_012_N) - sum(b07_007_b * B07_011_N) / A37TAX.A37_002_B else sum(b07_007_b *  B07_012_N) - sum(b07_007_b * B07_011_N) end as LucroVenda
		, (select top 1 CodRegiao from westcon.[dbo].[fnBIDadosPedidosIntranet](@CodErp)) as CodRegiao, 
		'Hyperion Exp'+rtrim(ltrim(iif(len(cast(year(b06_002_d) as char))=1,'0'+cast(year(b06_002_d) as char),cast(year(b06_002_d) as char))))+
		ltrim(rtrim(iif(len(cast(month(b06_002_d) as char))=1,'0'+cast(month(b06_002_d) as char),cast(month(b06_002_d) as char))))+
		ltrim(rtrim(iif(len(cast(day(b06_002_d) as char))=1,'0'+cast(day(b06_002_d) as char),cast(day(b06_002_d) as char)))) as J11_UKEY, 
		'Hyperion Exp'+rtrim(ltrim(iif(len(cast(year(b06_002_d) as char))=1,'0'+cast(year(b06_002_d) as char),cast(year(b06_002_d) as char))))+
		ltrim(rtrim(iif(len(cast(month(b06_002_d) as char))=1,'0'+cast(month(b06_002_d) as char),cast(month(b06_002_d) as char))))+
		ltrim(rtrim(iif(len(cast(day(b06_002_d) as char))=1,'0'+cast(day(b06_002_d) as char),cast(day(b06_002_d) as char)))) as PartNumber, 
		0 as ValorUnitarioNF,
		'' as NFDevolvida, 
		0 as Complement, 
		'No' as Intercompany
		FROM StarWestconCala2.dbo.B07 B07 WITH (NoLock)
		INNER JOIN StarWestconCala2.dbo.B06 B06 WITH (NoLock) ON B07.B06_UKEY = B06.UKEY 
		INNER JOIN StarWestconCala2.dbo.B11 B11 WITH (NoLock) ON B07.B11_UKEY = B11.UKEY 
		INNER JOIN 	(
						SELECT 
						/* PARA TAXA MENSAM (A54.A54_013_N = 1) É TRATADO PARA DEIXAR O CAMPO A37.A37_001_D COM O DIA 01 */
						CASE A54.A54_013_N WHEN 1 THEN SUBSTRING(CONVERT(CHAR, A37.A37_001_D, 112),1 , 6) + '01' ELSE A37.A37_001_D END AS A37_001_D,
						A37.A37_002_B,
						A37.A36_UKEYA,
						A37.A36_UKEY,
						A54.A54_013_N
						FROM StarWestconCala2.dbo.A36 (NOLOCK) 
						INNER JOIN StarWestconCala2.dbo.A54 (nolock) on A54.A36_UKEY = A36.UKEY
						INNER JOIN StarWestconCala2.dbo.A37 (nolock) on A37.A36_UKEY = A36.UKEY
						) A37TAX ON CASE A37TAX.A54_013_N WHEN 0 THEN B06.B06_002_D ELSE SUBSTRING(CONVERT(CHAR, B06.B06_002_D, 112),1 , 6) + '01' END = A37TAX.A37_001_D
		where a37TAX.a36_ukey = SUBSTRING(B06.A36_CODE0,1,5) AND A37TAX.A36_UKEYA = 'US$  ' and B06.cia_ukey = 'P6SIH' and
		 b06.b06_002_d between @DATAINI and @DATAFIM
		 and  (b11_001_c like '3302%' or b11_001_c like '3303%') and b11_001_c <> '3302050002'
		group by substring(b11_001_c,1,4), year(b06_002_d),month(b06_002_d), day(b06_002_d), b06_002_d, B06.a36_code0, A37tax.a37_002_b, b06.cia_ukey
		order by month(b06_002_d), day(b06_002_d) 
	END