USE [Westcon]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
--exec [Starsoft].[IncluiCodServ]  '016','testando tudo'

CREATE PROCEDURE [Starsoft].[AlteraBlackOut] 
@CodErp as int,
@CodCli as varchar(20),
@Dia01 as int,
@Dia02 as int

AS

declare @UkeyBr as char(20), @UkeyCa as char(20), @UkeyMx as char(20), @UkeyB as char(20), @Erro as int

set nocount on

IF @CodServico <> ''
	BEGIN
		
		Select @UkeyBr = ISNULL(UKEY,'') from StarWestcon.dbo.D75W (Nolock) Where D75W_001_C = @CodServico
		Select @UkeyCa = ISNULL(UKEY,'') from StarWestconCala2.dbo.D75W (Nolock) Where D75W_001_C = @CodServico
		Select @UkeyMx = ISNULL(UKEY,'') from StarWestconMX.dbo.D75W (Nolock) Where D75W_001_C = @CodServico

		--Trecho de inserção/update na base do Brasil
		IF ISNULL(@UkeyBr,'') = ''
			BEGIN
				exec spIDGerador 'D75W', @Erro, @UkeyB OUT
				Insert into StarWestcon.dbo.D75W (UKEY, TIMESTAMP, STATUS, CIA_UKEY, D75W_001_C, D75W_002_C) 
					values (@UkeyB, Convert(varchar, GetDate(), 112) + ' ' + Convert(varchar, GetDate(), 108) + ':000', 'W', 'V5LRC', @CodServico, @Descricao)
			END
		ELSE
			BEGIN
				update StarWestcon.dbo.D75W set D75W_001_c = @CodServico, D75W_002_C = @Descricao where ukey = @UkeyBr
			END
		--*************************************************
		
		--Trecho de inserção/update na base de Cala/Colombia
		IF ISNULL(@UkeyCa,'') = ''
			BEGIN
				exec spIDGerador 'D75W', @Erro, @UkeyB OUT
				Insert into StarWestconCala2.dbo.D75W (UKEY, TIMESTAMP, STATUS, CIA_UKEY, D75W_001_C, D75W_002_C) 
					values (@UkeyB, Convert(varchar, GetDate(), 112) + ' ' + Convert(varchar, GetDate(), 108) + ':000', 'W', 'STAR_', @CodServico, @Descricao)
			END
		ELSE
			BEGIN
				update StarWestconCala2.dbo.D75W set D75W_001_c = @CodServico, D75W_002_C = @Descricao where ukey = @UkeyCa
			END
		--*************************************************

		--Trecho de inserção/update na base do México
		IF ISNULL(@UkeyMx,'') = ''
			BEGIN
				exec spIDGerador 'D75W', @Erro, @UkeyB OUT
				Insert into StarWestconMx.dbo.D75W (UKEY, TIMESTAMP, STATUS, CIA_UKEY, D75W_001_C, D75W_002_C) 
					values (@UkeyB, Convert(varchar, GetDate(), 112) + ' ' + Convert(varchar, GetDate(), 108) + ':000', 'W', 'ZG5OF', @CodServico, @Descricao)
			END
		ELSE
			BEGIN
				update StarWestconMx.dbo.D75W set D75W_001_c = @CodServico, D75W_002_C = @Descricao where ukey = @UkeyMx
			END
		--*************************************************
	END
ELSE
	BEGIN
		SELECT 'ERRO'
	END
