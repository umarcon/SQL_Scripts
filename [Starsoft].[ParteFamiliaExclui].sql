USE [Westcon]
GO
/****** Object:  StoredProcedure [Starsoft].[ParteFamiliaExclui]    Script Date: 23/03/2016 12:32:55 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO

/****** Object:  Stored Procedure dbo.spParteFamiliaExclui    Script Date: 4/19/2004 9:40:48 AM ******/
ALTER PROCEDURE [Starsoft].[ParteFamiliaExclui] 
@Codigo as varchar(20),
@CodigoSubs as varchar(20),
@Bool as bit

AS


declare 	@Ukey as varchar(20), @UkeySubs as varchar(20)

set nocount on


--Informações da Intranet X Siscorp
Select @Ukey = D03.UKEY from StarWestcon.dbo.D03 D03 Where D03.D03_001_C = @Codigo
Select @UkeySubs = D03.UKEY from StarWestcon.dbo.D03 D03 Where D03.D03_001_C = @CodigoSubs

if (@Ukey is not null) and (@UkeySubs is not null)
begin
	--Atualiza os Part-Numbers
	Update StarWestcon.dbo.D04 set D03_UKEY = @UkeySubs Where D03_UKEY = @Ukey

	if @Bool = 0
	begin
		---Deleta a Família
		Delete from StarWestcon.dbo.B04 Where B04_UKEYP = @Ukey
		Delete from StarWestcon.dbo.D03 Where UKEY = @Ukey

	end
end


--Informações da Intranet X Siscorp Cala
Select @Ukey = D03.UKEY from StarWestconCala2.dbo.D03 D03 Where D03.D03_001_C = @Codigo AND D03.CIA_UKEY = 'STAR_'
Select @UkeySubs = D03.UKEY from StarWestconCala2.dbo.D03 D03 Where D03.D03_001_C = @CodigoSubs AND D03.CIA_UKEY = 'STAR_'

if (@Ukey is not null) and (@UkeySubs is not null)
begin
	--Atualiza os Part-Numbers
	Update StarWestconCala2.dbo.D04 set D03_UKEY = @UkeySubs Where D03_UKEY = @Ukey AND D04.CIA_UKEY = 'STAR_'

	if @Bool = 0
	begin
		---Deleta a Família
		Delete from StarWestconCala2.dbo.B04 Where B04_UKEYP = @Ukey AND B04.CIA_UKEY = 'STAR_'
		Delete from StarWestconCala2.dbo.D03 Where UKEY = @Ukey AND D03.CIA_UKEY = 'STAR_'

	end
end

--Informações da Intranet X Siscorp Colombia
Select @Ukey = D03.UKEY from StarWestconCala2.dbo.D03 D03 Where D03.D03_001_C = @Codigo AND D03.CIA_UKEY = 'M8530'
Select @UkeySubs = D03.UKEY from StarWestconCala2.dbo.D03 D03 Where D03.D03_001_C = @CodigoSubs AND D03.CIA_UKEY = 'M8530'

if (@Ukey is not null) and (@UkeySubs is not null)
begin
	--Atualiza os Part-Numbers
	Update StarWestconCala2.dbo.D04 set D03_UKEY = @UkeySubs Where D03_UKEY = @Ukey AND D04.CIA_UKEY = 'M8530'

	if @Bool = 0
	begin
		---Deleta a Família
		Delete from StarWestconCala2.dbo.B04 Where B04_UKEYP = @Ukey AND B04.CIA_UKEY = 'M8530'
		Delete from StarWestconCala2.dbo.D03 Where UKEY = @Ukey AND D03.CIA_UKEY = 'M8530'

	end
end

--Informações da Intranet X Siscorp 
Select @Ukey = D03.UKEY from StarWestconMX.dbo.D03 D03 Where D03.D03_001_C = @Codigo 
Select @UkeySubs = D03.UKEY from StarWestconMX.dbo.D03 D03 Where D03.D03_001_C = @CodigoSubs 

if (@Ukey is not null) and (@UkeySubs is not null)
begin
	--Atualiza os Part-Numbers
	Update StarWestconMX.dbo.D04 set D03_UKEY = @UkeySubs Where D03_UKEY = @Ukey

	if @Bool = 0
	begin
		---Deleta a Família
		Delete from StarWestconMX.dbo.B04 Where B04_UKEYP = @Ukey
		Delete from StarWestconMX.dbo.D03 Where UKEY = @Ukey

	end
end

