USE [Westcon]
GO
/****** Object:  UserDefinedFunction [Starsoft].[fnWmsInvoiceMX]    Script Date: 16/08/2016 11:19:09 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

--select * from [Starsoft].[fnWmsInvoiceMX]('CI93033CSY-CBN',"")

alter FUNCTION [Starsoft].[fnWmsInvoiceMX]
(
	@PLC_PO as varchar(20),
	@PLC_ITEM as varchar(50)
)
RETURNS TABLE
AS

RETURN
(
	SELECT distinct U05_001_C AS PO, D04_001_C AS PARTNUMBER, entrada as total_entrada, estoque as total_estoque, REPLACE(REPLACE(REPLACE(SERIE,'<A D41_001_C=',''),'/>',' '),'"','') AS SERIE
	FROM (
		select u05_001_c, d04_001_c, d28_008_b as estoque, d28_007_b as entrada, d28_004_b as qtde,
		(select LTRIM(RTRIM(d41_001_c)) D41_001_C from StarWestconMX.dbo.d41 (nolock)
			left join StarWestconMX.dbo.d42 (nolock) on d42.D41_UKEY = d41.ukey
			join StarWestconMX.dbo.d14 (nolock) on d42.D42_UKEYP = d14.ukey
			join StarWestconMX.dbo.e11 (nolock) on d14.D14_IUKEYP = e11.ukey
			join StarWestconMX.dbo.u14 (nolock) on e11.e11_ukeyp = u14.ukey
			where u14.u14_ukeyp = u11.ukey AND D41_002_N = 0
			FOR XML RAW('A')
		) as serie
	
		from StarWestconMX.dbo.u05 (Nolock) 
		join StarWestconMX.dbo.u06 (Nolock) on u06.u05_ukey = u05.ukey
		join StarWestconMX.dbo.u11 (Nolock) on u11.u11_ukeyp = u06.ukey
		join StarWestconMX.dbo.u10 (Nolock) on u11.u10_ukey = u10.ukey
		join StarWestconMX.dbo.d04 (Nolock) on u11.d04_ukey = d04.ukey
		join StarWestconMX.dbo.u14 (nolock) on u14.u14_ukeyp = u11.ukey
		join StarWestconMX.dbo.e11 (Nolock) on e11.e11_ukeyp = u14.ukey
		join StarWestconMX.DBO.d14 (nolock) on d14.d14_iukeyp = e11.ukey
		join StarWestconMX.DBO.d28 (nolock) on d28.d28_ukeyp = d14.ukey
		where u05_001_c = @PLC_PO and d04_001_c = @PLC_Item
		--group by d04_001_c, u05_001_c, u11.ukey
	) TMP
	
)
