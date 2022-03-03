USE [Westcon]
GO

/****** Object:  StoredProcedure [Starsoft].[Reports_CommissionsMap]    Script Date: 16/06/2016 10:40:07 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


-- =============================================
-- Author:		<rpaulista>
-- Create date: <28/05/2015>
-- Description:	<Mapeamento das comissões a pagar por pais>
-- =============================================

/*
- Alterado por ELCruz em 11-02-2016 (INC0345771)
Correção na query pois estavam sendo demonstradas comissões de OVs de revendas diferentes para uma revenda especifica e também
não estavam sendo demontradas comissões de NF que não geravam titulos a receber, somente comissões

*/


-- execute westcon.[Starsoft].[Reports_CommissionsMap] 1, 4, 1, 5, '', '',  '', '', '', '', '', '', 1, 'B002763271'
ALTER PROCEDURE [Starsoft].[Reports_CommissionsMap]

	@CodERP int = 0 -- CodERP 1 - Brasil / 2 - Cala / 3 - Mexico / 4 - Colombia 
	,@PLN_StatusNota int = 1 -- 1- Aberto / 2 - Quitado Total / 3 - Quitado Parcial / 4 - Todos 
	,@PLN_StatusComissao int = 1 -- 1 - Todos / 2 - Aberto / 3 - Estorno
	,@PLN_TipoComissao int = 5 -- 1 - Venda / 2 - Marketing All / 3 - Marketing Fidelização / 4 -Marketing Fabricante / 5 - Todos
	,@PLD_Emissao datetime = ''
	,@PLD_Vencimento datetime = ''
	,@PLC_Titulo varchar(max) = ''
	,@PLC_CodigoCliente varchar(max) = ''
	,@PLC_NomeCliente varchar(max) = ''
	,@PLC_CodigoFornecedor varchar(max) = ''
	,@PLC_NomeFornecedor varchar(max) = ''
	,@PLC_NotaFiscalSaida varchar(max) = ''
	,@PLC_EmAberto int = 1 -- Valor em aberto 0 - Não e 1 - sim
	,@PLC_OV varchar(max) = ''

AS
BEGIN

If @CODERP = 1 -- Brasil
	begin
		SELECT	
			J07.J07_001_C as 'OV'
			,ISNULL(A03T.A03_003_C,A08T.A08_003_C) as 'Customer_OV'
			,RTRIM(J10.J10_001_C) +'/'+ LTRIM(ISNULL(F13_001_C,'')) as 'Invoice_Number'
			,J10.J10_003_D as 'Issue_Date'
			,CLI.A03_001_C as 'Cod_Supplier'
			,CLI.A03_003_C  as 'Revenda/Supplier'				
			,F13.F13_002_D as 'Invoice_Maturity_Date'
			,cast(round(J06.J06_001_B,2) as numeric(12,2)) as 'Total_Invoice'
			,isnull(F18.F18_001_c,'') as 'Payment_Number'
			,F13.F13_002_D as 'Invoice_Payment_Date'
			,cast(round(F13.F13_021_B,2) as numeric(12,2)) as 'Invoice_Payment_Amount'
			,cast(round((F13.F13_010_B - F13.F13_029_B - F13.F13_025_B - F13.F13_021_B),2) as numeric(12,2)) as 'Invoice_Open_Amount'
			,F09.F09_001_C as 'Commission_Group'
			,RTRIM(F11.F11_001_C) +'/ '+ RIGHT(RTRIM(F14.F14_001_C),2) as 'Commission_Number'
			,cast(round(F14.F14_009_B,2) as numeric(12,2)) as 'Commission Total'
			,cast(round(F14.F14_029_B,2) as numeric(12,2)) as 'Commission_Reserve_Total'
			,cast(round((F14.F14_010_B - F14.F14_029_B - F14.F14_025_B - F14.F14_021_B),2) as numeric(12,2)) as 'Open_Total'
			,substring(F14.A36_CODE0,1,2) as 'Currency'
			,a21.a21_002_c as 'Provision_type'

		FROM 
			STARWESTCON.DBO.F11 F11 (NOLOCK)
			LEFT JOIN STARWESTCON.DBO.A33 A33 (NOLOCK) ON F11.F11_UKEYP = A33.UKEY
			LEFT JOIN STARWESTCON.DBO.A03 A03 (NOLOCK) ON F11.F11_UKEYP = A03.UKEY
			LEFT JOIN STARWESTCON.DBO.A08 A08 (NOLOCK) ON F11.F11_UKEYP = A08.UKEY
			LEFT OUTER JOIN (
								SELECT
									1 AS FLAG,
									A03A.UKEY ,   /* UNIQUE KEY */
									A03A.A03_001_C ,   /* CÓDIGO DO CLIENTE */
									A03A.A03_002_C ,   /* NOME FANTASIA */
									A03A.A03_003_C

								FROM 
									STARWESTCON.DBO.A03 A03A (NOLOCK)

								UNION ALL

								SELECT
									2 AS FLAG,
									A08A.UKEY ,   /* UNIQUE KEY */
									A08A.A08_001_C ,   /* CÓDIGO DO FORNECEDOR */
									A08A.A08_002_C ,   /* NOME FANTASIA */
									A08A.A08_003_C

								FROM 
									STARWESTCON.DBO.A08 A08A (NOLOCK)

								UNION ALL

								SELECT
									3 AS FLAG,
									A33A.UKEY ,   /* UNIQUE KEY */
									A33A.A33_001_C ,   /* CÓDIGO DO VENDEDOR */
									A33A.A33_002_C ,   /* NOME FANTASIA */
									A33A.A33_003_C

								FROM 
									STARWESTCON.DBO.A33 A33A (NOLOCK)      
							) CLI ON F11.F11_UKEYP = CLI.UKEY
			LEFT OUTER JOIN STARWESTCON.DBO.F14 F14 (NOLOCK) ON F14.F11_UKEY = F11.UKEY
			LEFT OUTER JOIN STARWESTCON.DBO.J10 J10 (NOLOCK) ON F11_IUKEYP = J10.UKEY
			LEFT OUTER JOIN STARWESTCON.DBO.J06 J06 (NOLOCK) ON J06.J06_UKEYP = J10.UKEY AND J06.ARRAY_241 = 2
			LEFT OUTER JOIN STARWESTCON.DBO.F12 F12 (NOLOCK) ON F12.F12_IUKEYP = J10.UKEY
			LEFT OUTER JOIN STARWESTCON.DBO.F13 F13 (NOLOCK) ON F13.F12_UKEY = F12.UKEY AND F13.F13_001_C = F14.F14_001_C
			LEFT OUTER JOIN STARWESTCON.DBO.A21 A21 (NOLOCK) ON F14.A21_UKEY = A21.UKEY
			LEFT OUTER JOIN STARWESTCON.DBO.J07 J07 (NOLOCK) ON J10.J07_UKEY = J07.UKEY
			LEFT OUTER JOIN STARWESTCON.DBO.A03 A03T (NOLOCK) ON J10.J10_UKEYP = A03T.UKEY
			LEFT OUTER JOIN STARWESTCON.DBO.A08 A08T (NOLOCK) ON J10.J10_UKEYP = A08T.UKEY
			LEFT OUTER JOIN STARWESTCON.DBO.F16 F16 (NOLOCK) ON F16.F14_UKEY = F14.UKEY
			LEFT OUTER JOIN STARWESTCON.DBO.F09 F09 (NOLOCK) ON F09.UKEY = F14.F09_UKEY
			LEFT OUTER JOIN STARWESTCON.DBO.F18 F18 (NOLOCK) ON F18.UKEY = F16.F18_UKEY

		WHERE
			F11.F11_016_C = '002' AND -- SOMENTE COMISSÃO
			 ( /* Status da nota = 1- Aberto / 2 - Quitado Total / 3 - Quitado Parcial / 4 - Todos */
				@PLN_StatusNota = 1 AND (
										(F13.F13_015_N = 0 OR F13.F13_015_N = 2) 
										AND F13.F13_024_N = 0
									)  
				OR ( @PLN_StatusNota = 2 AND F13.F13_015_N = 1 )     
				OR ( @PLN_StatusNota = 3 AND F13.F13_015_N = 2 ) 
				OR ( @PLN_StatusNota = 4 )
			)
			AND 
				( /* Status da comissão = 1 - Todos / 2 - Aberto / 3 - Estorno */
					( 
						@PLN_StatusComissao = 2 AND 
							(
								F14.F14_028_N = 0 OR F14.F14_028_N = 2
							)
					) 
					OR ( @PLN_StatusComissao = 3 AND F14.F14_028_N = 1 )
					OR ( @PLN_StatusComissao = 1 )
				)
			AND 
				(
					(
						@PLC_EmAberto = 1 AND  
						( /* Valor em aberto maior que zero*/					
							F14.F14_010_B - F14.F14_029_B - F14.F14_025_B - F14.F14_021_B - F14.F14_022_B  
						) > 0	
					) 
					OR
					(
						@PLC_EmAberto = 0 AND  
						( /* Valor em aberto maior que zero*/					
							F14.F14_010_B - F14.F14_029_B - F14.F14_025_B - F14.F14_021_B - F14.F14_022_B  
						) <= 0	
					) 							
				)
			AND 
				( /*Tipo da Comissão = 1 - Venda / 2 - Marketing All / 3 - Marketing Fidelização / 4 -Marketing Fabricante / 5 - Todos */
					( @PLN_TipoComissao = 2 AND A21.A21_001_C IN('15.96','15.97')) 
					OR ( @PLN_TipoComissao = 3 AND A21.A21_001_C ='15.96')
					OR ( @PLN_TipoComissao = 4 AND A21.A21_001_C ='15.97') 
					OR ( @PLN_TipoComissao = 1 AND A21.A21_001_C NOT IN('15.96','15.97'))
					OR ( @PLN_TipoComissao = 5)
				)
			AND -- número do titulo a pagar
				(
					@PLC_Titulo = '' OR F12.F12_001_C = @PLC_Titulo
				)
			AND -- Data do vencimento das parcelas a pagar
				(
					@PLD_Vencimento = '' OR F13.F13_003_D >= @PLD_Vencimento
				)
			AND -- Código do cliente
				(
					@PLC_CodigoCliente = '' OR A03.A03_001_C = @PLC_CodigoCliente
				)
			AND -- Nome do cliente iniciado por
				(
					@PLC_NomeCliente = '' OR A03.A03_003_C like @PLC_NomeCliente + '%'
				)
			AND -- Codigo do fornecedor
				(
					@PLC_CodigoFornecedor = '' OR A08.A08_001_C = @PLC_CodigoFornecedor
				)
			AND -- Nome do fornecedor iniciado por
				(
					@PLC_NomeFornecedor = '' OR A08.A08_003_C like @PLC_NomeFornecedor + '%'
				)
			AND -- Data de emissão da comissão
				(
					@PLD_Emissao = '' OR F11.F11_002_D >= @PLD_Emissao
				)
			AND -- Número da nota fiscal
				(
					@PLC_NotaFiscalSaida = '' or J10.J10_001_c = @PLC_NotaFiscalSaida
				)
			AND -- Número da OV -- incluso por rpaulisat - 22/07/2015 - Scrum 14681
				(
					@PLC_OV = '' or J07.J07_001_C like '%' + @PLC_OV + '%'
				)

		ORDER BY
			CLI.A03_001_C, OV, J10.J10_001_C
	end 

If @CODERP = 2 or @CODERP = 4
	begin
		Declare @Ukey_Empresa char(05)
		-- Se for 4 é colombia, caso contrario Cala
		If @CodERP = 4
				Set @Ukey_Empresa = 'M8530'
		Else
				Set @Ukey_Empresa = 'STAR_'


	SELECT	
			J07.J07_001_C as 'OV'
			,ISNULL(A03T.A03_003_C,A08T.A08_003_C) as 'Customer_OV'
			,RTRIM(J10.J10_001_C) +'/'+ LTRIM(ISNULL(F13_001_C,'')) as 'Invoice_Number'
			,J10.J10_003_D as 'Issue_Date'
			,CLI.A03_001_C as 'Cod_Supplier'
			,CLI.A03_003_C  as 'Revenda/Supplier'				
			,F13.F13_002_D as 'Invoice_Maturity_Date'
			,cast(round(J06.J06_001_B,2) as numeric(12,2)) as 'Total_Invoice'
			,isnull(F18.F18_001_c,'') as 'Payment_Number'
			,F13.F13_002_D as 'Invoice_Payment_Date'
			,cast(round(F13.F13_021_B,2) as numeric(12,2)) as 'Invoice_Payment_Amount'
			,cast(round((F13.F13_010_B - F13.F13_029_B - F13.F13_025_B - F13.F13_021_B),2) as numeric(12,2)) as 'Invoice_Open_Amount'
			,F09.F09_001_C as 'Commission_Group'
			,RTRIM(F11.F11_001_C) +'/ '+ RIGHT(RTRIM(F14.F14_001_C),2) as 'Commission_Number'
			,cast(round(F14.F14_009_B,2) as numeric(12,2)) as 'Commission Total'
			,cast(round(F14.F14_029_B,2) as numeric(12,2)) as 'Commission_Reserve_Total'
			,cast(round((F14.F14_010_B - F14.F14_029_B - F14.F14_025_B - F14.F14_021_B),2) as numeric(12,2)) as 'Open_Total'
			,substring(F14.A36_CODE0,1,3) as 'Currency'
			,a21.a21_002_c as 'Provision_type'

		FROM 
			STARWESTCONCALA2.DBO.F11 F11 (NOLOCK)
			LEFT JOIN STARWESTCONCALA2.DBO.A33 A33 (NOLOCK) ON F11.F11_UKEYP = A33.UKEY
			LEFT JOIN STARWESTCONCALA2.DBO.A03 A03 (NOLOCK) ON F11.F11_UKEYP = A03.UKEY
			LEFT JOIN STARWESTCONCALA2.DBO.A08 A08 (NOLOCK) ON F11.F11_UKEYP = A08.UKEY
			LEFT OUTER JOIN (
								SELECT
									1 AS FLAG,
									A03A.UKEY ,   /* UNIQUE KEY */
									A03A.A03_001_C ,   /* CÓDIGO DO CLIENTE */
									A03A.A03_002_C ,   /* NOME FANTASIA */
									A03A.A03_003_C

								FROM 
									STARWESTCONCALA2.DBO.A03 A03A (NOLOCK)

								UNION ALL

								SELECT
									2 AS FLAG,
									A08A.UKEY ,   /* UNIQUE KEY */
									A08A.A08_001_C ,   /* CÓDIGO DO FORNECEDOR */
									A08A.A08_002_C ,   /* NOME FANTASIA */
									A08A.A08_003_C

								FROM 
									STARWESTCONCALA2.DBO.A08 A08A (NOLOCK)

								UNION ALL

								SELECT
									3 AS FLAG,
									A33A.UKEY ,   /* UNIQUE KEY */
									A33A.A33_001_C ,   /* CÓDIGO DO VENDEDOR */
									A33A.A33_002_C ,   /* NOME FANTASIA */
									A33A.A33_003_C

								FROM 
									STARWESTCONCALA2.DBO.A33 A33A (NOLOCK)      
							) CLI ON F11.F11_UKEYP = CLI.UKEY
			LEFT OUTER JOIN STARWESTCONCALA2.DBO.F14 F14 (NOLOCK) ON F14.F11_UKEY = F11.UKEY
			LEFT OUTER JOIN STARWESTCONCALA2.DBO.J10 J10 (NOLOCK) ON F11_IUKEYP = J10.UKEY
			LEFT OUTER JOIN STARWESTCONCALA2.DBO.J06 J06 (NOLOCK) ON J06.J06_UKEYP = J10.UKEY AND J06.ARRAY_241 = 2
			LEFT OUTER JOIN STARWESTCONCALA2.DBO.F12 F12 (NOLOCK) ON F12.F12_IUKEYP = J10.UKEY
			LEFT OUTER JOIN STARWESTCONCALA2.DBO.F13 F13 (NOLOCK) ON F13.F12_UKEY = F12.UKEY AND F13.F13_001_C = F14.F14_001_C
			LEFT OUTER JOIN STARWESTCONCALA2.DBO.A21 A21 (NOLOCK) ON F14.A21_UKEY = A21.UKEY
			LEFT OUTER JOIN STARWESTCONCALA2.DBO.J07 J07 (NOLOCK) ON J10.J07_UKEY = J07.UKEY
			LEFT OUTER JOIN STARWESTCONCALA2.DBO.A03 A03T (NOLOCK) ON J10.J10_UKEYP = A03T.UKEY
			LEFT OUTER JOIN STARWESTCONCALA2.DBO.A08 A08T (NOLOCK) ON J10.J10_UKEYP = A08T.UKEY
			LEFT OUTER JOIN STARWESTCONCALA2.DBO.F16 F16 (NOLOCK) ON F16.F14_UKEY = F14.UKEY
			LEFT OUTER JOIN STARWESTCONCALA2.DBO.F09 F09 (NOLOCK) ON F09.UKEY = F14.F09_UKEY
			LEFT OUTER JOIN STARWESTCONCALA2.DBO.F18 F18 (NOLOCK) ON F18.UKEY = F16.F18_UKEY

		WHERE
			F11.F11_016_C = '002' AND -- SOMENTE COMISSÃO
			F11.CIA_UKEY = @Ukey_Empresa
			AND
				 ( /* Status da nota = 1- Aberto / 2 - Quitado Total / 3 - Quitado Parcial / 4 - Todos */
					@PLN_StatusNota = 1 AND (
											(F13.F13_015_N = 0 OR F13.F13_015_N = 2) 
											AND F13.F13_024_N = 0
										)  
					OR ( @PLN_StatusNota = 2 AND F13.F13_015_N = 1 )     
					OR ( @PLN_StatusNota = 3 AND F13.F13_015_N = 2 ) 
					OR ( @PLN_StatusNota = 4 )
				)
			AND 
				( /* Status da comissão = 1 - Todos / 2 - Aberto / 3 - Estorno */
					( 
						@PLN_StatusComissao = 2 AND 
							(
								F14.F14_028_N = 0 OR F14.F14_028_N = 2
							)
					) 
					OR ( @PLN_StatusComissao = 3 AND F14.F14_028_N = 1 )
					OR ( @PLN_StatusComissao = 1 )
				)
			AND 
				(
					(
						@PLC_EmAberto = 1 AND  
						( /* Valor em aberto maior que zero*/					
							F14.F14_010_B - F14.F14_029_B - F14.F14_025_B - F14.F14_021_B - F14.F14_022_B  
						) > 0	
					) 
					OR
					(
						@PLC_EmAberto = 0 AND  
						( /* Valor em aberto maior que zero*/					
							F14.F14_010_B - F14.F14_029_B - F14.F14_025_B - F14.F14_021_B - F14.F14_022_B  
						) <= 0	
					) 							
				)			
			AND 
				( /*Tipo da Comissão = 1 - Venda / 2 - Marketing All / 3 - Marketing Fidelização / 4 -Marketing Fabricante / 5 - Todos */
					( @PLN_TipoComissao = 2 AND A21.A21_001_C IN('15.96','15.97')) 
					OR ( @PLN_TipoComissao = 3 AND A21.A21_001_C ='15.96')
					OR ( @PLN_TipoComissao = 4 AND A21.A21_001_C ='15.97') 
					OR ( @PLN_TipoComissao = 1 AND A21.A21_001_C NOT IN('15.96','15.97'))
					OR ( @PLN_TipoComissao = 5)
				)
			AND -- número do titulo a pagar
				(
					@PLC_Titulo = '' OR F12.F12_001_C = @PLC_Titulo
				)
			AND -- Data do vencimento das parcelas a pagar
				(
					@PLD_Vencimento = '' OR F13.F13_003_D >= @PLD_Vencimento
				)
			AND -- Código do cliente
				(
					@PLC_CodigoCliente = '' OR A03.A03_001_C = @PLC_CodigoCliente
				)
			AND -- Nome do cliente iniciado por
				(
					@PLC_NomeCliente = '' OR A03.A03_003_C like @PLC_NomeCliente + '%'
				)
			AND -- Codigo do fornecedor
				(
					@PLC_CodigoFornecedor = '' OR A08.A08_001_C = @PLC_CodigoFornecedor
				)
			AND -- Nome do fornecedor iniciado por
				(
					@PLC_NomeFornecedor = '' OR A08.A08_003_C like @PLC_NomeFornecedor + '%'
				)
			AND -- Data de emissão da comissão
				(
					@PLD_Emissao = '' OR F11.F11_002_D >= @PLD_Emissao
				)
			AND -- Número da nota fiscal
				(
					@PLC_NotaFiscalSaida = '' or J10.J10_001_c = @PLC_NotaFiscalSaida
				)
			AND -- Número da OV -- incluso por rpaulisat - 22/07/2015 - Scrum 14681
				(
					@PLC_OV = '' or J07.J07_001_C like '%' + @PLC_OV + '%'
				)

		ORDER BY
			CLI.A03_001_C, OV

	end

If @CODERP = 3 -- México
	begin
		SELECT	
			J07.J07_001_C as 'OV'
			,ISNULL(A03T.A03_003_C,A08T.A08_003_C) as 'Customer_OV'
			,RTRIM(J10.J10_001_C) +'/'+ LTRIM(ISNULL(F13_001_C,'')) as 'Invoice_Number'
			,J10.J10_003_D as 'Issue_Date'
			,CLI.A03_001_C as 'Cod_Supplier'
			,CLI.A03_003_C  as 'Revenda/Supplier'				
			,F13.F13_002_D as 'Invoice_Maturity_Date'
			,cast(round(J06.J06_001_B,2) as numeric(12,2)) as 'Total_Invoice'
			,isnull(F18.F18_001_c,'') as 'Payment_Number'
			,F13.F13_002_D as 'Invoice_Payment_Date'
			,cast(round(F13.F13_021_B,2) as numeric(12,2)) as 'Invoice_Payment_Amount'
			,cast(round((F13.F13_010_B - F13.F13_029_B - F13.F13_025_B - F13.F13_021_B),2) as numeric(12,2)) as 'Invoice_Open_Amount'
			,F09.F09_001_C as 'Commission_Group'
			,RTRIM(F11.F11_001_C) +'/ '+ RIGHT(RTRIM(F14.F14_001_C),2) as 'Commission_Number'
			,cast(round(F14.F14_009_B,2) as numeric(12,2)) as 'Commission Total'
			,cast(round(F14.F14_029_B,2) as numeric(12,2)) as 'Commission_Reserve_Total'
			,cast(round((F14.F14_010_B - F14.F14_029_B - F14.F14_025_B - F14.F14_021_B),2) as numeric(12,2)) as 'Open_Total'
			,substring(F14.A36_CODE0,1,2) as 'Currency'
			,a21.a21_002_c as 'Provision_type'

		FROM 
			STARWESTCONMX.DBO.F11 F11 (NOLOCK)
			LEFT JOIN STARWESTCONMX.DBO.A33 A33 (NOLOCK) ON F11.F11_UKEYP = A33.UKEY
			LEFT JOIN STARWESTCONMX.DBO.A03 A03 (NOLOCK) ON F11.F11_UKEYP = A03.UKEY
			LEFT JOIN STARWESTCONMX.DBO.A08 A08 (NOLOCK) ON F11.F11_UKEYP = A08.UKEY
			LEFT OUTER JOIN (
								SELECT
									1 AS FLAG,
									A03A.UKEY ,   /* UNIQUE KEY */
									A03A.A03_001_C ,   /* CÓDIGO DO CLIENTE */
									A03A.A03_002_C ,   /* NOME FANTASIA */
									A03A.A03_003_C

								FROM 
									STARWESTCONMX.DBO.A03 A03A (NOLOCK)

								UNION ALL

								SELECT
									2 AS FLAG,
									A08A.UKEY ,   /* UNIQUE KEY */
									A08A.A08_001_C ,   /* CÓDIGO DO FORNECEDOR */
									A08A.A08_002_C ,   /* NOME FANTASIA */
									A08A.A08_003_C

								FROM 
									STARWESTCONMX.DBO.A08 A08A (NOLOCK)

								UNION ALL

								SELECT
									3 AS FLAG,
									A33A.UKEY ,   /* UNIQUE KEY */
									A33A.A33_001_C ,   /* CÓDIGO DO VENDEDOR */
									A33A.A33_002_C ,   /* NOME FANTASIA */
									A33A.A33_003_C

								FROM 
									STARWESTCONMX.DBO.A33 A33A (NOLOCK)      
							) CLI ON F11.F11_UKEYP = CLI.UKEY
			LEFT OUTER JOIN STARWESTCONMX.DBO.F14 F14 (NOLOCK) ON F14.F11_UKEY = F11.UKEY
			LEFT OUTER JOIN STARWESTCONMX.DBO.J10 J10 (NOLOCK) ON F11_IUKEYP = J10.UKEY
			LEFT OUTER JOIN STARWESTCONMX.DBO.J06 J06 (NOLOCK) ON J06.J06_UKEYP = J10.UKEY AND J06.ARRAY_241 = 2
			LEFT OUTER JOIN STARWESTCONMX.DBO.F12 F12 (NOLOCK) ON F12.F12_IUKEYP = J10.UKEY
			LEFT OUTER JOIN STARWESTCONMX.DBO.F13 F13 (NOLOCK) ON F13.F12_UKEY = F12.UKEY AND F13.F13_001_C = F14.F14_001_C
			LEFT OUTER JOIN STARWESTCONMX.DBO.A21 A21 (NOLOCK) ON F14.A21_UKEY = A21.UKEY
			LEFT OUTER JOIN STARWESTCONMX.DBO.J07 J07 (NOLOCK) ON J10.J07_UKEY = J07.UKEY
			LEFT OUTER JOIN STARWESTCONMX.DBO.A03 A03T (NOLOCK) ON J10.J10_UKEYP = A03T.UKEY
			LEFT OUTER JOIN STARWESTCONMX.DBO.A08 A08T (NOLOCK) ON J10.J10_UKEYP = A08T.UKEY
			LEFT OUTER JOIN STARWESTCONMX.DBO.F16 F16 (NOLOCK) ON F16.F14_UKEY = F14.UKEY
			LEFT OUTER JOIN STARWESTCONMX.DBO.F09 F09 (NOLOCK) ON F09.UKEY = F14.F09_UKEY
			LEFT OUTER JOIN STARWESTCONMX.DBO.F18 F18 (NOLOCK) ON F18.UKEY = F16.F18_UKEY

		WHERE
			F11.F11_016_C = '002' AND -- SOMENTE COMISSÃO
			 ( /* Status da nota = 1- Aberto / 2 - Quitado Total / 3 - Quitado Parcial / 4 - Todos */
				@PLN_StatusNota = 1 AND (
										(F13.F13_015_N = 0 OR F13.F13_015_N = 2) 
										AND F13.F13_024_N = 0
									)  
				OR ( @PLN_StatusNota = 2 AND F13.F13_015_N = 1 )     
				OR ( @PLN_StatusNota = 3 AND F13.F13_015_N = 2 ) 
				OR ( @PLN_StatusNota = 4 )
			)
			AND 
				( /* Status da comissão = 1 - Todos / 2 - Aberto / 3 - Estorno */
					( 
						@PLN_StatusComissao = 2 AND 
							(
								F14.F14_028_N = 0 OR F14.F14_028_N = 2
							)
					) 
					OR ( @PLN_StatusComissao = 3 AND F14.F14_028_N = 1 )
					OR ( @PLN_StatusComissao = 1 )
				)
			AND 
				(
					(
						@PLC_EmAberto = 1 AND  
						( /* Valor em aberto maior que zero*/					
							F14.F14_010_B - F14.F14_029_B - F14.F14_025_B - F14.F14_021_B - F14.F14_022_B  
						) > 0	
					) 
					OR
					(
						@PLC_EmAberto = 0 AND  
						( /* Valor em aberto maior que zero*/					
							F14.F14_010_B - F14.F14_029_B - F14.F14_025_B - F14.F14_021_B - F14.F14_022_B  
						) <= 0	
					) 							
				)			
			AND 
				( /*Tipo da Comissão = 1 - Venda / 2 - Marketing All / 3 - Marketing Fidelização / 4 -Marketing Fabricante / 5 - Todos */
					( @PLN_TipoComissao = 2 AND A21.A21_001_C IN('15.96','15.97')) 
					OR ( @PLN_TipoComissao = 3 AND A21.A21_001_C ='15.96')
					OR ( @PLN_TipoComissao = 4 AND A21.A21_001_C ='15.97') 
					OR ( @PLN_TipoComissao = 1 AND A21.A21_001_C NOT IN('15.96','15.97'))
					OR ( @PLN_TipoComissao = 5)
				)
			AND -- número do titulo a pagar
				(
					@PLC_Titulo = '' OR F12.F12_001_C = @PLC_Titulo
				)
			AND -- Data do vencimento das parcelas a pagar
				(
					@PLD_Vencimento = '' OR F13.F13_003_D >= @PLD_Vencimento
				)
			AND -- Código do cliente
				(
					@PLC_CodigoCliente = '' OR A03.A03_001_C = @PLC_CodigoCliente
				)
			AND -- Nome do cliente iniciado por
				(
					@PLC_NomeCliente = '' OR A03.A03_003_C like @PLC_NomeCliente + '%'
				)
			AND -- Codigo do fornecedor
				(
					@PLC_CodigoFornecedor = '' OR A08.A08_001_C = @PLC_CodigoFornecedor
				)
			AND -- Nome do fornecedor iniciado por
				(
					@PLC_NomeFornecedor = '' OR A08.A08_003_C like @PLC_NomeFornecedor + '%'
				)
			AND -- Data de emissão da comissão
				(
					@PLD_Emissao = '' OR F11.F11_002_D >= @PLD_Emissao
				)
			AND -- Número da nota fiscal
				(
					@PLC_NotaFiscalSaida = '' or J10.J10_001_c = @PLC_NotaFiscalSaida
				)
			AND -- Número da OV -- incluso por rpaulisat - 22/07/2015 - Scrum 14681
				(
					@PLC_OV = '' or J07.J07_001_C like '%' + @PLC_OV + '%'
				)

		ORDER BY
			CLI.A03_001_C, OV
	end
end
GO

