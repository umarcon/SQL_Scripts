USE [Westcon]
GO
/****** Object:  StoredProcedure [Starsoft].[ParteFamiliaAltera]    Script Date: 23/03/2016 16:12:45 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO



/****** Object:  Stored Procedure Starsoft.ParteFamiliaAltera    Script Date: 4/19/2004 9:40:48 AM ******/
ALTER PROCEDURE [Starsoft].[ParteFamiliaAltera] 
@CodERP as int,
@CodParteFamilia as varchar(20),
@Descricao as varchar(50),
@CodVendor as varchar(255),
@Codigo as varchar(20),
@CodVendorN as varchar(255),
@CodigoN as varchar(20),
@CodigoP as varchar(20), 
@CodCRD as varchar(20)


AS

declare @Erro as int, @Ukey as varchar(20), @UkeyB as varchar(20)

set nocount on


if @CodVendorN = @CodVendor
	BEGIN
		if @CodCRD = ''
			BEGIN
				if @CodERP = 1
					Begin
						Update StarWestcon.dbo.D03 set D03_002_C = @Descricao Where D03_001_C = @Codigo
					end

				if @CodERP = 2
					Begin
						Update StarWestconCALA2.dbo.D03 set D03_002_C = @Descricao Where D03_001_C = @Codigo
					End

				if @CodERP = 3
					Begin
						Update StarWestconMX.dbo.D03 set D03_002_C = @Descricao Where D03_001_C = @Codigo
					End

				if @CodERP = 4
					Begin
						Update StarWestconCALA2.dbo.D03 set D03_002_C = @Descricao Where D03_001_C = @Codigo
					End
			END
		else
			BEGIN
				if @CodERP = 1
					Begin
						--Buscar a Ukey do Fabricante
						Select @Ukey = UKEY from StarWestcon.dbo.D03 (NOLOCK) Where D03_001_C = @Codigo

						Update StarWestcon.dbo.D03 set D03_002_C = @Descricao Where D03_001_C = @Codigo
						Update StarWestcon.dbo.B04 set A11_UKEY = @CodCRD Where B04_Ukeyp = @Ukey
					end

				if @CodERP = 2
					Begin
						--Buscar a Ukey do Fabricante
						Select @Ukey = UKEY from StarWestconCALA2.dbo.D03 (NOLOCK) Where D03_001_C = @Codigo AND CIA_UKEY = 'STAR_'

						Update StarWestconCALA2.dbo.D03 set D03_002_C = @Descricao Where D03_001_C = @Codigo AND CIA_UKEY = 'STAR_'
						Update StarWestconCALA2.dbo.B04 set A11_UKEY = @CodCRD Where B04_Ukeyp = @Ukey
					End

				if @CodERP = 3
					Begin
						--Buscar a Ukey do Fabricante
						Select @Ukey = UKEY from StarWestconMX.dbo.D03 (NOLOCK) Where D03_001_C = @Codigo 

						Update StarWestconMX.dbo.D03 set D03_002_C = @Descricao Where D03_001_C = @Codigo
						Update StarWestconMX.dbo.B04 set A11_UKEY = @CodCRD Where B04_Ukeyp = @Ukey
					End

				if @CodERP = 4
					Begin
						--Buscar a Ukey do Fabricante
						Select @Ukey = UKEY from StarWestconCALA2.dbo.D03 (NOLOCK) Where D03_001_C = @Codigo AND CIA_UKEY = 'M8530'

						Update StarWestconCALA2.dbo.D03 set D03_002_C = @Descricao Where D03_001_C = @Codigo AND CIA_UKEY = 'M8530'
						Update StarWestconCALA2.dbo.B04 set A11_UKEY = @CodCRD Where B04_Ukeyp = @Ukey
					End
			END
		END
else
	BEGIN
		if @CodCRD = ''
			BEGIN
				if @CodERP = 1
					Begin
						--Buscar a Ukey do Novo Fabricante
						Select @Ukey = UKEY from StarWestcon.dbo.D03 (NOLOCK) Where D03_001_C = @CodigoP	

						Update StarWestcon.dbo.D03 set D03_002_C = @Descricao, D03_UKEY = @Ukey, D03_001_C = @CodigoN Where D03_001_C = @Codigo
					End

				if @CodERP = 2
					Begin
						--Buscar a Ukey do Novo Fabricante
						Select @Ukey = UKEY from StarWestcon.dbo.D03 (NOLOCK) Where D03_001_C = @CodigoP	

						Update StarWestconCALA2.dbo.D03 set D03_002_C = @Descricao, D03_UKEY = @Ukey, D03_001_C = @CodigoN Where D03_001_C = @Codigo
					End

				if @CodERP = 3
					Begin
						--Buscar a Ukey do Novo Fabricante
						Select @Ukey = UKEY from StarWestcon.dbo.D03 (NOLOCK) Where D03_001_C = @CodigoP	
					End

				if @CodERP = 4
					Begin
						--Buscar a Ukey do Novo Fabricante
						Select @Ukey = UKEY from StarWestcon.dbo.D03 (NOLOCK) Where D03_001_C = @CodigoP	

						Update StarWestconCALA2.dbo.D03 set D03_002_C = @Descricao, D03_UKEY = @Ukey, D03_001_C = @CodigoN Where D03_001_C = @Codigo
					End
			END
		else
			BEGIN
				if @CodERP = 1
					Begin
						--Buscar a Ukey do Novo Fabricante
						Select @Ukey = UKEY from StarWestcon.dbo.D03 (NOLOCK) Where D03_001_C = @CodigoP	
						Select @UkeyB = UKEY from StarWestcon.dbo.D03 (NOLOCK) Where D03_001_C = @Codigo

						Update StarWestcon.dbo.D03 set D03_002_C = @Descricao, D03_UKEY = @Ukey, D03_001_C = @CodigoN Where D03_001_C = @Codigo
						Update StarWestcon.dbo.B04 set A11_UKEY = @CodCRD Where B04_UKEYP = @UkeyB
					End

				if @CodERP = 2
					Begin
						--Buscar a Ukey do Novo Fabricante
						Select @Ukey = UKEY from StarWestconCala2.dbo.D03 (NOLOCK) Where D03_001_C = @CodigoP	
						Select @UkeyB = UKEY from StarWestconCala2.dbo.D03 (NOLOCK) Where D03_001_C = @Codigo

						Update StarWestconCALA2.dbo.D03 set D03_002_C = @Descricao, D03_UKEY = @Ukey, D03_001_C = @CodigoN Where D03_001_C = @Codigo
						Update StarWestconCALA2.dbo.B04 set A11_UKEY = @CodCRD Where B04_UKEYP = @UkeyB
					End

				if @CodERP = 3
					Begin
						--Buscar a Ukey do Novo Fabricante
						Select @Ukey = UKEY from StarWestconMX.dbo.D03 (NOLOCK) Where D03_001_C = @CodigoP	
						Select @UkeyB = UKEY from StarWestconMX.dbo.D03 (NOLOCK) Where D03_001_C = @Codigo

						Update StarWestconMX.dbo.D03 set D03_002_C = @Descricao, D03_UKEY = @Ukey, D03_001_C = @CodigoN Where D03_001_C = @Codigo
						Update StarWestconMX.dbo.B04 set A11_UKEY = @CodCRD Where B04_UKEYP = @UkeyB
					End

				if @CodERP = 4
					Begin
						--Buscar a Ukey do Novo Fabricante
						Select @Ukey = UKEY from StarWestconCala2.dbo.D03 (NOLOCK) Where D03_001_C = @CodigoP	
						Select @UkeyB = UKEY from StarWestconCala2.dbo.D03 (NOLOCK) Where D03_001_C = @Codigo

						Update StarWestconCALA2.dbo.D03 set D03_002_C = @Descricao, D03_UKEY = @Ukey, D03_001_C = @CodigoN Where D03_001_C = @Codigo
						Update StarWestconCALA2.dbo.B04 set A11_UKEY = @CodCRD Where B04_UKEYP = @UkeyB
					End
			END
	END