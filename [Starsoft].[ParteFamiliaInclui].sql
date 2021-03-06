USE [Westcon]
GO
/****** Object:  StoredProcedure [Starsoft].[ParteFamiliaInclui]    Script Date: 22/03/2016 15:22:37 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
--exec Starsoft.ParteFamiliaInclui 2, 'teste 3003 4', 'teste 3003 4', 'teste 3003 4', '170', '17001', '20120815R6XQCO143VDD'
/****** Object:  Stored Procedure dbo.spParteFamiliaInclui    Script Date: 4/19/2004 9:40:48 AM ******/
ALTER  PROCEDURE [Starsoft].[ParteFamiliaInclui] 
@CODERP as int,
@CodParteFamilia as varchar(20),
@Descricao as varchar(50),
@CodVendor as varchar(255),
@Codigo as varchar(20),
@CodigoP as varchar(20),
@CodCRD as varchar(20) --(1 = Brasil, 2 = Cala, 3 = Mexico, 4 = Colombia)
AS

declare @UkeyV as char(20), @UkeyP as char(20), @UkeyB as char(20), @UkeyA as char(20), @Erro as int

set nocount on

IF @CODERP = 1
	BEGIN
		Select @UkeyV = UKEY from StarWestcon.dbo.D03 (Nolock) Where D03_001_C = @Codigo
		Select @UkeyA = UKEY from StarWestcon.dbo.A11 (Nolock) Where A11_001_C = '161107'
		IF @UkeyV <> ''
			BEGIN
				exec spIDGerador 'D03', @Erro OUT, @UkeyP OUT
				Insert into StarWestcon.dbo.D03 (UKEY, TIMESTAMP, STATUS, CIA_UKEY, ARRAY_017, ARRAY_050, D03_001_C, D03_002_C, D03_003_C, D03_UKEY, T02_UKEY, A11_UKEY) 
					values (@UkeyP, Convert(varchar, GetDate(), 112) + ' ' + Convert(varchar, GetDate(), 108) + ':000', 'W', 'STAR_', 2, 3, @CodigoP, @Descricao, '02', @UkeyV, 'STAR_STAR__1440PRBVX', @UkeyA)

				exec spIDGerador 'B04', @Erro, @UkeyB OUT
				insert into StarWestcon.dbo.B04 (USR_NOTE, UKEY, TIMESTAMP, STATUS, CIA_UKEY, A11_UKEY, B04_001_B, B04_002_B, B04_003_C, B04_005_N, B04_006_B, B04_PAR, B04_UKEYP) 
					values ('Carga', @UkeyB, Convert(varchar, GetDate(), 112) + ' ' + Convert(varchar, GetDate(), 108) + ':000', 'W', 'STAR_', @CodCRD, 0.00, 100.00, 'A', 1, 0.00, 'D03', @UkeyP)
			END
	END

IF @CODERP = 2 
	BEGIN
		Select @UkeyV = UKEY from StarWestconCala2.dbo.D03 (Nolock) Where D03_001_C = @Codigo AND D03.CIA_UKEY = 'STAR_'

		IF @UkeyV <> ''
			BEGIN
				exec spIDGerador 'D03', @Erro OUT, @UkeyP OUT
				Insert into StarWestconCala2.dbo.D03 (UKEY, TIMESTAMP, STATUS, CIA_UKEY, ARRAY_017, ARRAY_050, D03_001_C, D03_002_C, D03_003_C, D03_UKEY, T02_UKEY) 
					values (@UkeyP, Convert(varchar, GetDate(), 112) + ' ' + Convert(varchar, GetDate(), 108) + ':000', 'W', 'STAR_', 2, 3, @CodigoP, @Descricao, '02', @UkeyV, 'STAR_STAR__1290N2MU3')

				exec spIDGerador 'B04', @Erro, @UkeyB OUT
				insert into StarWestconCala2.dbo.B04 (USR_NOTE, UKEY, TIMESTAMP, STATUS, CIA_UKEY, A11_UKEY, B04_001_B, B04_002_B, B04_003_C, B04_005_N, B04_006_B, B04_PAR, B04_UKEYP) 
					values ('Carga', @UkeyB, Convert(varchar, GetDate(), 112) + ' ' + Convert(varchar, GetDate(), 108) + ':000', 'W', 'STAR_', @CodCRD, 0.00, 100.00, 'A', 1, 0.00, 'D03', @UkeyP)
			END
	END

IF @CODERP = 4
	BEGIN
		Select @UkeyV = UKEY from StarWestconCala2.dbo.D03 (Nolock) Where D03_001_C = @Codigo AND D03.CIA_UKEY = 'M8530'

		IF @UkeyV <> ''
			BEGIN
				exec spIDGerador 'D03', @Erro OUT, @UkeyP OUT
				Insert into StarWestconCala2.dbo.D03 (UKEY, TIMESTAMP, STATUS, CIA_UKEY, ARRAY_017, ARRAY_050, D03_001_C, D03_002_C, D03_003_C, D03_UKEY, T02_UKEY) 
					values (@UkeyP, Convert(varchar, GetDate(), 112) + ' ' + Convert(varchar, GetDate(), 108) + ':000', 'W', 'M8530', 2, 3, @CodigoP, @Descricao, '02', @UkeyV, '20120905R8ZPZ911EECN')

				exec spIDGerador 'B04', @Erro, @UkeyB OUT
				insert into StarWestconCala2.dbo.B04 (USR_NOTE, UKEY, TIMESTAMP, STATUS, CIA_UKEY, A11_UKEY, B04_001_B, B04_002_B, B04_003_C, B04_005_N, B04_006_B, B04_PAR, B04_UKEYP) 
					values ('Carga', @UkeyB, Convert(varchar, GetDate(), 112) + ' ' + Convert(varchar, GetDate(), 108) + ':000', 'W', 'M8530', @CodCRD, 0.00, 100.00, 'A', 1, 0.00, 'D03', @UkeyP)
			END
	END

IF @CODERP = 3
	BEGIN

		Select @UkeyV = UKEY from StarWestconMx.dbo.D03 (Nolock) Where D03_001_C = @Codigo

		IF @UkeyV <> ''
			BEGIN
				exec spIDGerador 'D03', @Erro OUT, @UkeyP OUT
				Insert into StarWestconMX.dbo.D03 (UKEY, TIMESTAMP, STATUS, CIA_UKEY, ARRAY_017, ARRAY_050, D03_001_C, D03_002_C, D03_003_C, D03_UKEY, T02_UKEY) 
					values (@UkeyP, Convert(varchar, GetDate(), 112) + ' ' + Convert(varchar, GetDate(), 108) + ':000', 'W', 'ZG5OF', 2, 3, @CodigoP, @Descricao, '02', @UkeyV, '20081203STAR_Y12MNRR')

				exec spIDGerador 'B04', @Erro, @UkeyB OUT
				insert into StarWestconMX.dbo.B04 (USR_NOTE, UKEY, TIMESTAMP, STATUS, CIA_UKEY, A11_UKEY, B04_001_B, B04_002_B, B04_003_C, B04_005_N, B04_006_B, B04_PAR, B04_UKEYP) 
					values ('Carga', @UkeyB, Convert(varchar, GetDate(), 112) + ' ' + Convert(varchar, GetDate(), 108) + ':000', 'W', 'ZG5OF', @CodCRD, 0.00, 100.00, 'A', 1, 0.00, 'D03', @UkeyP)
			END
	END