USE [Westcon]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
--exec [Starsoft].[AlteraBlackOut]  1,'28268233000784', 3, 4

CREATE PROCEDURE [Starsoft].[AlteraBlackOut] 
@CodErp as int, --1-BR, 2-Cala, 3-MX, 4-Colo, 5-Peru
@CodCli as varchar(20),
@Dia01 as int,
@Dia02 as int

AS

declare @UkeyCli as char(20)

set nocount on

IF @CodErp = 1
	BEGIN
		Select @UkeyCli = ISNULL(UKEY,'') from StarWestcon.dbo.A03 (Nolock) Where A03_001_C = @CodCli

		update StarWestcon.dbo.A03 set A03_501_N = 1, A03_502_N = @Dia01, A03_503_N = @Dia02 where ukey = @UkeyCli
	END

IF @CodErp = 2
	BEGIN
		Select @UkeyCli = ISNULL(UKEY,'') from StarWestconCala2.dbo.A03 (Nolock) Where A03_001_C = @CodCli and CIA_UKEY = 'STAR_'

		update StarWestconCala2.dbo.A03 set A03_501_N = 1, A03_502_N = @Dia01, A03_503_N = @Dia02 where ukey = @UkeyCli and cia_ukey = 'STAR_'
	END

IF @CodErp = 3
	BEGIN
		Select @UkeyCli = ISNULL(UKEY,'') from StarWestconMX.dbo.A03 (Nolock) Where A03_001_C = @CodCli

		update StarWestconMX.dbo.A03 set A03_501_N = 1, A03_502_N = @Dia01, A03_503_N = @Dia02 where ukey = @UkeyCli
	END

IF @CodErp = 4
	BEGIN
		Select @UkeyCli = ISNULL(UKEY,'') from StarWestconCala2.dbo.A03 (Nolock) Where A03_001_C = @CodCli and cia_ukey in ('M8530','M8531')

		update StarWestconCala2.dbo.A03 set A03_501_N = 1, A03_502_N = @Dia01, A03_503_N = @Dia02 where ukey = @UkeyCli and cia_ukey in ('M8530','M8531')
	END

IF @CodErp = 5
	BEGIN
		Select @UkeyCli = ISNULL(UKEY,'') from StarWestconCala2.dbo.A03 (Nolock) Where A03_001_C = @CodCli and cia_ukey = 'P6SIH'

		update StarWestconCala2.dbo.A03 set A03_501_N = 1, A03_502_N = @Dia01, A03_503_N = @Dia02 where ukey = @UkeyCli and cia_ukey = 'P6SIH'
	END
