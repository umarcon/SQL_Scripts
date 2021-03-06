USE [Westcon]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
--exec [Starsoft].[CodServDelete]  '016'

CREATE PROCEDURE [Starsoft].[CodServDelete] 
@CodServico as varchar(5),
@Erro as int OUT
AS

declare @UkeyBr as char(20), @UkeyCa as char(20), @UkeyMx as char(20)

set nocount on

IF @CodServico <> ''
	BEGIN
		
		Select @UkeyBr = ISNULL(UKEY,'') from StarWestcon.dbo.D75W (Nolock) Where D75W_001_C = @CodServico
		Select @UkeyCa = ISNULL(UKEY,'') from StarWestconCala2.dbo.D75W (Nolock) Where D75W_001_C = @CodServico
		Select @UkeyMx = ISNULL(UKEY,'') from StarWestconMX.dbo.D75W (Nolock) Where D75W_001_C = @CodServico

		--Trecho de deleção na base do Brasil
		IF ISNULL(@UkeyBr,'') <> ''
			BEGIN
				Delete from StarWestcon.dbo.D75W Where Ukey = @UkeyBr

				If @@ERROR <> 0
					begin
						set @Erro = 1
					end
				Else
					begin
						set @Erro = 0
					end
			END
		--*************************************************
		
		--Trecho de deleção na base de Cala/Colombia
		IF ISNULL(@UkeyCa,'') <> ''
			BEGIN
				Delete from StarWestconCala2.dbo.D75W Where Ukey = @UkeyCa

				If @@ERROR <> 0
					begin
						set @Erro = 1
					end
				Else
					begin
						set @Erro = 0
					end
			END
		--*************************************************

		--Trecho de inserção/update na base do México
		IF ISNULL(@UkeyMx,'') <> ''
			BEGIN
				Delete from StarWestconMx.dbo.D75W Where Ukey = @UkeyMx

				If @@ERROR <> 0
					begin
						set @Erro = 1
					end
				Else
					begin
						set @Erro = 0
					end
			END
		--*************************************************
	END