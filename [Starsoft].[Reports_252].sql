-- =============================================
-- Author:		ELCruz (Starsoft)
-- Create date: 03-25-2014
-- Description:	Deverá relacionar todos os lançamentos contábeis feitos no período selecionado na conta de clientes e comparar seu valor com o valor
-- do documento de origem do lançamento. Tratameno semelhante a SP [Starsoft].[Reports_CustomerAccountVSGeneralLedger], porém nessa deverão ser
-- apresentados todos os lançamentos ao invés de somente lançamentos com diferenças de valores
-- =============================================
/*
===================================================================================================
 Alterado por: Thiago Rodrigues
 Data: 12-05-2015
 Atividade 14527 do Scrum 

 - Incluido o campo F15.UKEY na select onde busca todas as quitações no periodo
 - Alterdo  a select que busca diferenças entre os titulo e parcelas movimentados no periodo 
 incluido a condição (TMP_RAZAO.B07_UKEYP = TMP_QUITACAO.F15_UKEY AND TMP_RAZAO.B07_PAR ='F15') 
 - Incluido tratamento para as Saidas em contas Bancarias 
===================================================================================================
 Alterado por: Peterson Ricardo - Starsoft
 Data: 06-07-2015
 
 incluido variavel para receber os parametros da SP e utilizando as variaveis na query
 esse procedimento deixou a SP 10x mais rápida.
===================================================================================================
*/

-- exec [Starsoft].[Reports_CustomerAccountVSGeneralLedgerBR_ALL_14527] '20170201','20170228'


ALTER PROCEDURE [Starsoft].[Reports_252]
	@CodERP integer,
	@PLD_INITIAL DATE, -- Data de inicio da pesquisa
	@PLD_FINAL DATE -- Data final da pesquisa

AS
BEGIN

    declare @initial_date as date
	declare @final_date as date

    set @initial_date = @PLD_INITIAL
	set @final_date = @PLD_FINAL

	SET NOCOUNT ON;

	IF @CodERP = 1
		BEGIN
			EXEC [Starsoft].[Reports_252_BR]@initial_date, @final_date
		END

	IF @CodERP = 2
		BEGIN
			EXEC [WESTCON].[STARSOFT].[Reports_252_CA] @PLD_INITIAL, @PLD_FINAL
		END
	IF @CodERP = 3
		BEGIN
			EXEC [WESTCON].[STARSOFT].[Reports_252_MX] @PLD_INITIAL, @PLD_FINAL
		END

	IF @CodERP = 4
		BEGIN
			EXEC [WESTCON].[STARSOFT].[Reports_252_CO] @PLD_INITIAL, @PLD_FINAL
		END

	IF @CodERP = 5
		BEGIN
			EXEC [WESTCON].[STARSOFT].[Reports_252_PE] @PLD_INITIAL, @PLD_FINAL
		END

	IF @CodERP = 6
		BEGIN
			EXEC [WESTCON].[STARSOFT].[Reports_252_EQ] @PLD_INITIAL, @PLD_FINAL
		END

	IF @CodERP = 7
		BEGIN
			EXEC [WESTCON].[STARSOFT].[Reports_252_AR] @PLD_INITIAL, @PLD_FINAL
		END

	IF @CodERP = 8
		BEGIN
			EXEC [WESTCON].[STARSOFT].[Reports_252_CH] @PLD_INITIAL, @PLD_FINAL
		END

END