USE [Westcon]
GO
/****** Object:  UserDefinedFunction [Starsoft].[fnWmsInvoiceMX]    Script Date: 16/08/2016 11:19:09 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

--select * from [Starsoft].[fnWmsInvoiceMX]('AP87773OC-MX')

ALTER FUNCTION [Starsoft].[fnWmsEntradaMX]
(
	@PLC_PO as varchar(20),
	@PLC_ITEM as varchar(50)
)
RETURNS TABLE
AS

RETURN
(
	select e08_001_c as PO, d04_001_c as partnumber, estoque as total_estoque, entrada as total_entrada, REPLACE(REPLACE(REPLACE(SERIE,'<B D41_001_C =',''),'/>','/'),'"','') AS SERIE
	FROM (
		select e08_001_c ,d04_001_c, d28_008_b as estoque, d28_007_b as entrada, d28_004_b as qtde,
		(select ltrim(rtrim(d41_001_c)) d41_001_c from StarWestconMX.dbo.d41 (nolock)
			left join StarWestconMX.dbo.d42 (nolock) on d42.d41_ukey = d41.ukey
			join StarWestconMX.dbo.d14 (nolock) on d42.d42_ukeyp = d14.ukey
			where d14.d14_iukeyp = e11.ukey and d41_002_n = 0
			for xml raw('B')
		) as serie
		from StarWestconMX.DBO.e11 (Nolock) 
		join StarWestconMX.DBO.e10 (Nolock) on e11.e10_ukey = e10.ukey
		join StarWestconMX.DBO.e09 (Nolock) on e11.e11_ukeyp = e09.ukey
		join StarWestconMX.DBO.e08 (Nolock) on e09.e08_ukey = e08.ukey
		join StarWestconMX.DBO.d04 (Nolock) on e09.d04_ukey = d04.ukey
		join StarWestconMX.DBO.d14 (nolock) on d14.d14_iukeyp = e11.ukey
		join StarWestconMX.DBO.d28 (nolock) on d28.d28_ukeyp = d14.ukey
		where e08_001_c = @PLC_PO and d04_001_c = @PLC_ITEM
		--group by e08_001_c, d04_001_c, e11.ukey
	)TMP
)
