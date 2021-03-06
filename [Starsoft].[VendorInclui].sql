USE [Westcon]
GO
/****** Object:  StoredProcedure [Starsoft].[VendorInclui]    Script Date: 23/03/2016 11:12:10 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO

/*
	stored procedure alterada em 26/01/2016



*/

ALTER PROCEDURE [Starsoft].[VendorInclui] 
--Parametros passados pela Intranet
@CodERP as int,
@Codigo as varchar(20),
@NomeVendor as varchar(50),
@CodCRD as varchar(20)
AS


declare	@Erro as int, @Ukey char(20), @UkeyP as char(20), @UkeyB as char(20)



--Siscorp
IF @CodERP = 1
	Begin 
		Select @UkeyP = UKEY from StarWestcon.dbo.A11 (Nolock) Where A11_001_C = '161107'

		exec spIDGerador 'D03', @Erro OUT, @Ukey OUT
		Insert into StarWestcon.dbo.D03 (UKEY, TIMESTAMP, STATUS, CIA_UKEY, ARRAY_017, ARRAY_050, D03_001_C, D03_002_C, D03_003_C, D03_UKEY, T02_UKEY, A11_UKEY) 
			values (@Ukey, Convert(varchar, GetDate(), 112) + ' ' + Convert(varchar, GetDate(), 108) + ':000', 'W', 'STAR_', 1, 3, @Codigo, @NomeVendor, '01', null, 'STAR_STAR__1440PRBVX', @UkeyP)

		exec spIDGerador 'B04', @Erro, @UkeyB OUT
		insert into StarWestcon.dbo.B04 (USR_NOTE, UKEY, TIMESTAMP, STATUS, CIA_UKEY, A11_UKEY, B04_001_B, B04_002_B, B04_003_C, B04_005_N, B04_006_B, B04_PAR, B04_UKEYP) 
			values ('Carga', @UkeyB, Convert(varchar, GetDate(), 112) + ' ' + Convert(varchar, GetDate(), 108) + ':000', 'W', 'STAR_', @CodCRD, 0.00, 100.00, 'A', 1, 0.00, 'D03', @Ukey)
	End

IF @CodERP = 2 
	BEgin 
		exec spIDGerador 'D03', @Erro OUT, @Ukey OUT
		Insert into StarWestconCala2.dbo.D03 (UKEY, TIMESTAMP, STATUS, CIA_UKEY, ARRAY_017, ARRAY_050, D03_001_C, D03_002_C, D03_003_C, D03_UKEY, T02_UKEY) 
			values (@Ukey, Convert(varchar, GetDate(), 112) + ' ' + Convert(varchar, GetDate(), 108) + ':000', 'W', 'STAR_', 1, 3, @Codigo, @NomeVendor, '01', null, 'STAR_STAR__1290N2MU3')
	
		exec spIDGerador 'B04', @Erro, @UkeyB OUT
		insert into StarWestconCala2.dbo.B04 (USR_NOTE, UKEY, TIMESTAMP, STATUS, CIA_UKEY, A11_UKEY, B04_001_B, B04_002_B, B04_003_C, B04_005_N, B04_006_B, B04_PAR, B04_UKEYP) 
			values ('Carga', @UkeyB, Convert(varchar, GetDate(), 112) + ' ' + Convert(varchar, GetDate(), 108) + ':000', 'W', 'STAR_', @CodCRD, 0.00, 100.00, 'A', 1, 0.00, 'D03', @Ukey)
	END

IF @CodERP = 4
	Begin
		exec spIDGerador 'D03', @Erro OUT, @Ukey OUT
		Insert into StarWestconCala2.dbo.D03 (UKEY, TIMESTAMP, STATUS, CIA_UKEY, ARRAY_017, ARRAY_050, D03_001_C, D03_002_C, D03_003_C, D03_UKEY, T02_UKEY) 
			values (@Ukey, Convert(varchar, GetDate(), 112) + ' ' + Convert(varchar, GetDate(), 108) + ':000', 'W', 'M8530', 1, 3, @Codigo, @NomeVendor, '01', null, '20120905R8ZPZ911EECN')

		exec spIDGerador 'B04', @Erro, @UkeyB OUT
		insert into StarWestconCala2.dbo.B04 (USR_NOTE, UKEY, TIMESTAMP, STATUS, CIA_UKEY, A11_UKEY, B04_001_B, B04_002_B, B04_003_C, B04_005_N, B04_006_B, B04_PAR, B04_UKEYP) 
			values ('Carga', @UkeyB, Convert(varchar, GetDate(), 112) + ' ' + Convert(varchar, GetDate(), 108) + ':000', 'W', 'M8530', @CodCRD, 0.00, 100.00, 'A', 1, 0.00, 'D03', @Ukey)
	End

IF @CodERP = 3
	Begin
		exec spIDGerador 'D03', @Erro OUT, @Ukey OUT
		Insert into StarWestconMX.dbo.D03 (UKEY, TIMESTAMP, STATUS, CIA_UKEY, ARRAY_017, ARRAY_050, D03_001_C, D03_002_C, D03_003_C, D03_UKEY, T02_UKEY) 
			values (@Ukey, Convert(varchar, GetDate(), 112) + ' ' + Convert(varchar, GetDate(), 108) + ':000', 'W', 'ZG5OF', 1, 3, @Codigo, @NomeVendor, '01', null, '20081203STAR_Y12MNRR')

		exec spIDGerador 'B04', @Erro, @UkeyB OUT
		insert into StarWestconMX.dbo.B04 (USR_NOTE, UKEY, TIMESTAMP, STATUS, CIA_UKEY, A11_UKEY, B04_001_B, B04_002_B, B04_003_C, B04_005_N, B04_006_B, B04_PAR, B04_UKEYP) 
			values ('Carga', @UkeyB, Convert(varchar, GetDate(), 112) + ' ' + Convert(varchar, GetDate(), 108) + ':000', 'W', 'ZG5OF', @CodCRD, 0.00, 100.00, 'A', 1, 0.00, 'D03', @Ukey)
	End
	


-- BACKUP FEITO POR TMZ EM 01/09/2009

/****** Object:  Stored Procedure dbo.spVendorInclui    Script Date: 4/19/2004 9:40:51 AM ******/
/*
CREATE PROCEDURE [spVendorInclui] 
@CodVendor as varchar(255),
@NomeVendor as varchar(50)

AS


declare	@ID as int, @Codigo as varchar(20), @Erro as int, @Ukey char(20), @UkeyP as char(20), @Ajuste_N_1 as int


begin transaction

SELECT TOP 1 @Ajuste_N_1 = Ajuste_N_1 + 1 FROM tblVendor WHERE (Ajuste_N_1 <> 99) ORDER BY Ajuste_N_1 DESC

Select Top 1 @ID = (Convert(int, D03_001_C) + 1) from StarWestcon.dbo.D03 Where (left(Rtrim(D03_001_C), 2) <> '99') AND (D03_UKEY is null) Order By Convert(int, D03_001_C) Desc
if len(Convert(varchar, @ID)) = 1
	set @Codigo = '0' + Convert(varchar, @ID)
else
	set @Codigo = Convert(varchar, @ID)


--Intranet
Insert into tblVendor (CodVendor, NomeVendor, Codigo, ID, Ajuste_N_1) values (@CodVendor, @NomeVendor, @Codigo, @ID, @Ajuste_N_1)
if @@Error <> 0
	goto trata_erro

Insert into tblParteFamilia (CodParteFamilia, Descricao, CodVendor, Codigo) values (@CodVendor, @NomeVendor, @CodVendor, @Codigo + '01')
if @@Error <> 0
	goto trata_erro





--Siscorp
exec spIDGerador 'D03', @Erro OUT, @Ukey OUT
if @@Error <> 0
	goto trata_erro

if @Erro <> 0
	goto trata_erro

Insert into StarWestcon.dbo.D03 (UKEY, TIMESTAMP, STATUS, CIA_UKEY, ARRAY_017, ARRAY_050, D03_001_C, D03_002_C, D03_003_C, D03_UKEY, T02_UKEY) 
	values (@Ukey, Convert(varchar, GetDate(), 112) + ' ' + Convert(varchar, GetDate(), 108) + ':000', 'W', 'STAR_', 1, 3, @Codigo, @NomeVendor, '01', null, 'STAR_STAR__1290N2MU3')
if @@Error <> 0
	goto trata_erro




exec spIDGerador 'D03', @Erro OUT, @UkeyP OUT
if @@Error <> 0
	goto trata_erro

if @Erro <> 0
	goto trata_erro

Insert into StarWestcon.dbo.D03 (UKEY, TIMESTAMP, STATUS, CIA_UKEY, ARRAY_017, ARRAY_050, D03_001_C, D03_002_C, D03_003_C, D03_UKEY, T02_UKEY) 
	values (@UkeyP, Convert(varchar, GetDate(), 112) + ' ' + Convert(varchar, GetDate(), 108) + ':000', 'W', 'STAR_', 2, 3, @Codigo + '01', @NomeVendor, '02', @Ukey, 'STAR_STAR__1290N2MU3')
if @@Error <> 0
	goto trata_erro




if @@Error = 0
begin
	commit transaction
	Select Erro = 0
	return
end


trata_erro:
	rollback transaction
	Select Erro = 1
	return
*/



