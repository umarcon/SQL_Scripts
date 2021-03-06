USE [Westcon]
GO
/****** Object:  StoredProcedure [Starsoft].[SP_INSERT_D04]    Script Date: 25/10/2016 15:54:19 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
- Alterado dia 14/09/2016 -SCRUM-15341 - inclui o campo d74_ukey = CEST

- Alterado por ELCruz 24/08/16
Incluído o cadastramento do partnumber para a empresa Afina do Brasil, pois o código estava comentado aguardando o go-live da empresa
W
- Alterado por ELCruz 11/08/16
Após reunião com João Brasil, Rafael e Yuri ficou decidido que não teríamos que fazer nenhuma ação com o parâmetro CEST, pois inicialmente esse campo seria informado pelo time MDM,
porém após analisarem melhor o caso chegaram a conclusão que esse cadastro será feito diretamente no Applications. Sendo assim todos os pontos que utilizam esse parâmetro foram removidos
e estou aguardando a alteração da Intranet para não enviar mais esse parâmetro ao executar a SP, após essa remoção por parte deles esse parâmetro será removido da SP

Alterado por Marcelo Ayabe 31/05/16
	Alterações para permitir efetuar a carga de cadastro de Partnumber para a empresa do Peru (ROLLOUT-146)

Alterado por Marlon de Oliveira 08/04/16
	Passaremos a guardar o Parâmetro @GrupoSoftwareServico em uma tabela no Application 

Alterado por Marlon de Oliveira 19/11/15
	Adicionado o parâmetro @CodCest

Alterado por Thiago Rodrigues	15/10/15
	Alterado os parametros  abaixo para receber o a descrição do item ao inves do codigo do item 
		set @DescricaoFabricante 
		set @DescricaoFaturamento

-- ELCRUZ - 08/09/15
Publicada em produção com a parte de geração do partnumber para a empresa Afina Brasil comentada, pois essa empresa ainda não esta cadastrada em produção
*/

ALTER PROCEDURE [Starsoft].[SP_INSERT_D04]
(
	@CodERP 		INT,			-- CodERP 1 - Brasil / 2 - Cala / 3 - Mexico / 4 - Colombia / 5 - Peru
	@Partnumber varchar(max),
	@DescricaoFabricante varchar(max),
	@DescricaoFaturamento varchar(max),
	@Status numeric(1) = 1,
	@Familia varchar(100),
	@Preco float,
	@Tipo int,
	@GrupoDesconto varchar(100),
	@ClassificacaoFiscal varchar(50),
	@Origem int,
	@Inventario int,
	@Kardex int,
	@CodigoServicoPadrao varchar(50),
	@GrupoSoftwareServico varchar(50),
	@CodCest varchar(7)
)

AS 

--exec [Starsoft].[SP_INSERT_D04] 1, 'teste111', 'teste111@DescricaoFabricante', 'teste111@DescricaoFaturamento', 1, '2501', 1, 3, '', 'A19', 1, 1, 1, '1.05', '', ''

-- Trunco o tamanho dos campos para evitar erros
set @Partnumber				= SUBSTRING(@Partnumber, 1, 100)
set @DescricaoFabricante	= SUBSTRING(@DescricaoFabricante, 1, 40)
set @DescricaoFaturamento	= SUBSTRING(@DescricaoFaturamento, 1, 120)

declare @UkeyAgrupamento	as varchar(20)
declare @d03_ukey			as varchar(20)
declare @d16_ukey			as varchar(20) 
declare @d74_ukey			as varchar(20)  -- SCRUM-15341
declare @d55_ukey			as varchar(20) 
declare @serial				as int					-- Indica se o partnumber trabalha com seriais
declare @datetime			as datetime				-- Data/hora de alteração do registro
declare @D75W_UKEY			as varchar(20) = null	-- Grupo de Serviço

set @datetime = CONVERT(DATETIME, CONVERT(VARCHAR(20), getdate(), 120))


--Serviços Municipais
declare @Servico as int
declare @ukeyd04 as varchar(20)
declare @ukeyd04afina as varchar(20)
set @Servico = 0


----------------- B R A S I L -----------------------
if @CodERP = 1 
	begin
		SET @d03_ukey = (SELECT D03.ukey  FROM StarWestcon.dbo.D03 D03 (nolock) where d03.D03_001_C = @familia AND D03.ARRAY_017 = 2)
		set @d16_ukey = (SELECT D16.ukey  FROM StarWestcon.dbo.D16 (nolock) where d16.d16_001_c = @ClassificacaoFiscal)		
		set @d74_ukey = (SELECT D16.d74_ukey  FROM StarWestcon.dbo.D16 (nolock) where d16.d16_001_c = @ClassificacaoFiscal)	--	SCRUM-15341
		set @d55_ukey = (SELECT D55.ukey  FROM StarWestcon.dbo.D55 (nolock) where d55.ukey = @d16_ukey) -- É A MESMA UKEY DA CF(TABELA D16)
		set @D75W_UKEY = (SELECT D75W.ukey  FROM StarWestcon.dbo.D75W (nolock) where d75w.d75w_001_c = @GrupoSoftwareServico)

		IF @Tipo = 1 --Hardware
			BEGIN
				set @UkeyAgrupamento = 'STAR_W525U_12C0NA4NE'
			END
		IF @Tipo = 3 --Servico
			BEGIN
				set @UkeyAgrupamento = '20140514OF79AG17A5EP'
				if @familia LIKE '64%' -- Se for a familia SERVICIO, informo o agrupamento com custo
					begin
						set @UkeyAgrupamento = 'STAR_W525U_12C0NBHNT'
					end
			END
		IF @Tipo = 5 --Software
			BEGIN
				set @UkeyAgrupamento = 'STAR_W525U_12C0NC7DV'
			END
		IF @Tipo = 7 --Software Caixa
			BEGIN
				set @UkeyAgrupamento = 'STAR_STAR__1290MJQEN'
			END
		IF @Tipo = 2 --Consumo
			BEGIN
				set @UkeyAgrupamento = 'STAR_W525U_12C0NB7AV'
			END
		IF @Tipo = 4 --Ativo Fixo
			BEGIN
				set @UkeyAgrupamento = 'STAR_W525U_12C0NBRB0'
			END
		

		-- Verifico se existe um item com o mesmo código.
		declare tmpd04 cursor keyset
		for 
			select d04.ukey from StarWestcon.dbo.d04 (nolock) where d04_001_c = @Partnumber and cia_ukey = 'STAR_'
		
		open tmpd04



		-----Serviços Municipais------
		delete from StarWestcon.dbo.a85  
		where a85.d04_ukey in 
		(select d04.ukey from StarWestcon.dbo.d04 
		where d04.d04_001_c = @Partnumber and d04.cia_ukey in ('STAR_', 'OSL0R'))
					


		if @@cursor_rows > 0
			begin
				PRINT 'UPDATE BR'
				set @ukeyd04 = (select d04.ukey from StarWestcon.dbo.d04 (nolock) where d04_001_c = @Partnumber and cia_ukey = 'STAR_')
				
				-- SCRUM-15341 - INCLUI D74_UKEY
				update  StarWestcon.dbo.d04 set d04_020_c = @DescricaoFabricante, d04_008_c = @DescricaoFaturamento, 
				array_098 = @Status, d03_ukey = @d03_ukey, @Preco = 0, t05_ukey = @UkeyAgrupamento,
				d16_ukey = @d16_ukey, d55_ukey = @d55_ukey, ARRAY_050 = @Origem, D04_007_N = @Inventario, D04_038_N = @Kardex,
				D75W_UKEY = @D75W_UKEY, TIMESTAMP = @datetime, d74_ukey = @d74_ukey 
				where d04.d04_001_c = @Partnumber and cia_ukey = 'STAR_'

			end

		if @@cursor_rows = 0
			begin
				print 'INSERT BR'
				--Cria um registro para as demais empresas compartilihadas
				
				
				--Serviços Municipais
				set @ukeyd04 = 'STAR_STAR_'+(RIGHT(NEWID(),10))
				--fim

				-- SCRUM-15341 - INCLUI O D74_UKEY
				INSERT INTO [StarWestcon].[dbo].[D04]
					([USR_NOTE],[UKEY],[TIMESTAMP],[STATUS],[SQLCMD],[MYCONTROL],[INTEGRATED],[CIA_UKEY],[A36_CODE0],[A36_UKEYA],[A36_UKEYB],[A36_UKEYC],[A36_UKEYD],[A36_UKEYE],[A36_UKEYF],[A36_UKEYG],[A36_UKEYH],[ARRAY_036],[ARRAY_036A],[ARRAY_036B]
					,[ARRAY_050],[ARRAY_060],[ARRAY_098],[ARRAY_234],[C11_UKEY],[D01_UKEY],[D02_UKEY],[D03_UKEY],[D04_002_B],[D04_003_B],[D04_004_B],[D04_005_B],[D04_006_D],[D04_007_N],[D04_009_B],[D04_010_B],[D04_011_B],[D04_012_B],[D04_013_N],[D04_014_N]
					,[D04_015_D],[D04_016_D],[D04_017_N],[D04_018_N],[D04_019_C],[D04_020_C],[D04_021_B],[D04_022_B],[D04_023_B],[D04_024_B],[D04_025_N],[D04_026_B],[D04_027_C],[D04_028_B],[D04_029_B],[D04_030_N],[D04_031_N],[D04_032_M],[D04_033_B],[D04_035_B]
					,[D04_037_N],[D04_038_N],[D04_039_N],[D04_040_B],[D04_041_D],[D04_042_N],[D04_043_D],[D04_054_D],[D04_083_B],[D04_084_N],[D04_085_N],[D04_094_N],[D04_095_B],[D04_100_D],[D04_101_M],[D04_154_D],[D04_UKEYA],[D07_UKEY],[D07_UKEY0],[D11_UKEY]
					,[D16_UKEY],[D21_UKEY],[D25_UKEY],[D30_UKEY],[D31_UKEY],[T02_UKEY],[T02_UKEY1],[T02_UKEY2],[T05_UKEY],[T71_UKEY],[D04_055_C],[D04_034_C],[D04_036_C],[D04_044_N],[D04_045_N],[D04_046_C],[D49_UKEY],[A11_UKEY],[A56_UKEY],[B11_UKEY]
					,[D04_096_C],[D04_097_C],[D04_098_N],[D04_099_B],[D04_102_N],[D04_103_N],[D04_104_B],[D55_UKEY],[D56_UKEY],[G01_UKEY],[G12_UKEY],[G13_UKEY],[T02_UKEY3],[T21_UKEY],[T22_UKEY],[T23_UKEY],[D04_500_C],[D04_047_N],[D04_200_B],[D04_155_C]
					,[D04_156_C],[D04_001_C],[ARRAY_840],[D04_158_C],[D04_048_C],[D04_049_C],[A05_UKEY],[A05_UKEYA],[D04_157_N],[D04_159_B],[L52_UKEY],[D04_008_C],[D04_050_B],[ARRAY_897],[ARRAY_898],[ARRAY_899],[ARRAY_930],[D04_105_N],[D67_UKEY],[D68_UKEY]
					,[WE97_UKEY],[ARRAY_1127],[ARRAY_1136],[ARRAY_781],[ARRAY_792],[ARRAY_794],[D04_056_N],[D04_057_N],[D04_058_N],[D04_059_N],[D04_060_N],[D04_061_B],[D04_062_N],[D04_063_N],[D04_160_N],[D04_161_C],[D04_162_D],[D04_163_M],[D04_164_N],[D04_165_C]
					,[D04_166_B],[D04_167_B],[D04_168_B],[D04_169_N], [D75W_UKEY], [D74_UKEY])
				VALUES
					(null, @ukeyd04,@datetime,'W',null,'','','STAR_','R$   '+SUBSTRING(CONVERT(CHAR, @datetime, 112),1,8) ,NULL,NULL,NULL,'R$   ',NULL,NULL,NULL,'US$  ',1,1,1
					,@Origem ,0,@status,1,NULL,NULL,NULL,@d03_ukey,0,0,0,0,null,@Inventario,0,0,0,0,0,0
					,@datetime,@datetime,0,1,'',@DescricaoFabricante,0,0,0,0,0,0,'',0,0,0,0,null,0,0
					,0,@Kardex,0,0,@datetime,0,null,null,0,0,1,0,0,0,null,null,null,null,null,null
					,@d16_ukey,null,null,null,null,'STAR_STAR__1440PRBVX','STAR_STAR__1440PRBVX',NULL,@UkeyAgrupamento,null,'','','',0,0,'',null,null,null,null
					,'','',0,0,0,0,0,@d55_ukey,null,null,null,null,null,null,null,null,'',0,0,''
					,'',@Partnumber,1,'','','',null,null,0,0,null,@DescricaoFaturamento,0,0,0,0,0,0,null,null
					,null,0,0,0,0,0,0,0,0,0,0,0,0,0,0,'',null,null,0,''
					,0,0,0,0, @D75W_UKEY,@D74_UKEY)
			end

	

		CLOSE tmpd04
		DEALLOCATE tmpd04
		--Cria um registro para Empresa Afina 'OSL0R'


		IF @Tipo = 5 --Software
			BEGIN
				set @UkeyAgrupamento = '20140514OF79AG17A5EP'
				if @familia = '6401'
					begin
						set @UkeyAgrupamento = 'STAR_W525U_12C0NBHNT'
					end
			END

		-- Verifico se existe um item com o mesmo código AFINA.
		declare tmpd04 cursor keyset
		for 
			select d04.ukey from StarWestcon.dbo.d04 (nolock) where d04_001_c = @Partnumber and cia_ukey = 'OSL0R'
		
		open tmpd04
		if @@cursor_rows > 0
			begin
				PRINT 'UPDATE AFINA'
				set @ukeyd04afina = (select d04.ukey from StarWestcon.dbo.d04 (nolock) where d04_001_c = @Partnumber and cia_ukey = 'OSL0R')
				-- SCRUM-15341 - INLCUI O D74_UKEY
				update  StarWestcon.dbo.d04 set d04_020_c = @DescricaoFabricante, d04_008_c = @DescricaoFaturamento, 
				array_098 = @Status, d03_ukey = @d03_ukey, @Preco = 0, t05_ukey = @UkeyAgrupamento,
				d16_ukey = @d16_ukey, ARRAY_050 = @Origem, D04_007_N = @Inventario, D04_038_N = @Kardex,
				D75W_UKEY = @D75W_UKEY, TIMESTAMP = @datetime, d74_ukey = @d74_ukey
				where d04.d04_001_c = @Partnumber and cia_ukey = 'OSL0R'
			end
			
		if @@cursor_rows = 0
			begin
				PRINT 'INSERT AFINA'

				set @ukeyd04afina = 'STAR_OSL0R'+(RIGHT(NEWID(),10))
				
				-- SCRUM-15341 - INLCUI O D74_UKEY

				INSERT INTO [StarWestcon].[dbo].[D04]
					([USR_NOTE],[UKEY],[TIMESTAMP],[STATUS],[SQLCMD],[MYCONTROL],[INTEGRATED],[CIA_UKEY],[A36_CODE0],[A36_UKEYA],[A36_UKEYB],[A36_UKEYC],[A36_UKEYD],[A36_UKEYE],[A36_UKEYF],[A36_UKEYG],[A36_UKEYH],[ARRAY_036],[ARRAY_036A],[ARRAY_036B]
					,[ARRAY_050],[ARRAY_060],[ARRAY_098],[ARRAY_234],[C11_UKEY],[D01_UKEY],[D02_UKEY],[D03_UKEY],[D04_002_B],[D04_003_B],[D04_004_B],[D04_005_B],[D04_006_D],[D04_007_N],[D04_009_B],[D04_010_B],[D04_011_B],[D04_012_B],[D04_013_N],[D04_014_N]
					,[D04_015_D],[D04_016_D],[D04_017_N],[D04_018_N],[D04_019_C],[D04_020_C],[D04_021_B],[D04_022_B],[D04_023_B],[D04_024_B],[D04_025_N],[D04_026_B],[D04_027_C],[D04_028_B],[D04_029_B],[D04_030_N],[D04_031_N],[D04_032_M],[D04_033_B],[D04_035_B]
					,[D04_037_N],[D04_038_N],[D04_039_N],[D04_040_B],[D04_041_D],[D04_042_N],[D04_043_D],[D04_054_D],[D04_083_B],[D04_084_N],[D04_085_N],[D04_094_N],[D04_095_B],[D04_100_D],[D04_101_M],[D04_154_D],[D04_UKEYA],[D07_UKEY],[D07_UKEY0],[D11_UKEY]
					,[D16_UKEY],[D21_UKEY],[D25_UKEY],[D30_UKEY],[D31_UKEY],[T02_UKEY],[T02_UKEY1],[T02_UKEY2],[T05_UKEY],[T71_UKEY],[D04_055_C],[D04_034_C],[D04_036_C],[D04_044_N],[D04_045_N],[D04_046_C],[D49_UKEY],[A11_UKEY],[A56_UKEY],[B11_UKEY]
					,[D04_096_C],[D04_097_C],[D04_098_N],[D04_099_B],[D04_102_N],[D04_103_N],[D04_104_B],[D55_UKEY],[D56_UKEY],[G01_UKEY],[G12_UKEY],[G13_UKEY],[T02_UKEY3],[T21_UKEY],[T22_UKEY],[T23_UKEY],[D04_500_C],[D04_047_N],[D04_200_B],[D04_155_C]
					,[D04_156_C],[D04_001_C],[ARRAY_840],[D04_158_C],[D04_048_C],[D04_049_C],[A05_UKEY],[A05_UKEYA],[D04_157_N],[D04_159_B],[L52_UKEY],[D04_008_C],[D04_050_B],[ARRAY_897],[ARRAY_898],[ARRAY_899],[ARRAY_930],[D04_105_N],[D67_UKEY],[D68_UKEY]
					,[WE97_UKEY],[ARRAY_1127],[ARRAY_1136],[ARRAY_781],[ARRAY_792],[ARRAY_794],[D04_056_N],[D04_057_N],[D04_058_N],[D04_059_N],[D04_060_N],[D04_061_B],[D04_062_N],[D04_063_N],[D04_160_N],[D04_161_C],[D04_162_D],[D04_163_M],[D04_164_N],[D04_165_C]
					,[D04_166_B],[D04_167_B],[D04_168_B],[D04_169_N], [D75W_UKEY], [D74_UKEY])
				VALUES
					(null, @ukeyd04afina,@datetime,'W',null,'','','OSL0R','R$   '+SUBSTRING(CONVERT(CHAR, @datetime, 112),1,8) ,NULL,NULL,NULL,'R$   ',NULL,NULL,NULL,'US$  ',1,1,1
					,@Origem ,0,@status,1,NULL,NULL,NULL,@d03_ukey,0,0,0,0,null,@Inventario,0,0,0,0,0,0
					,@datetime,@datetime,0,1,'',@DescricaoFabricante,0,0,0,0,0,0,'',0,0,0,0,null,0,0
					,0,@Kardex,0,0,@datetime,0,null,null,0,0,1,0,0,0,null,null,null,null,null,null
					,@d16_ukey,null,null,null,null,'STAR_STAR__1440PRBVX','STAR_STAR__1440PRBVX',NULL,@UkeyAgrupamento,null,'','','',0,0,'',null,null,null,null
					,'','',0,0,0,0,0,@d55_ukey,null,null,null,null,null,null,null,null,'',0,0,''
					,'',@Partnumber,1,'','','',null,null,0,0,null,@DescricaoFaturamento,0,0,0,0,0,0,null,null
					,null,0,0,0,0,0,0,0,0,0,0,0,0,0,0,'',null,null,0,''
					,0,0,0,0, @D75W_UKEY,@D74_UKEY)

			END
			CLOSE tmpd04
			DEALLOCATE tmpd04



	-----------Serviços Municipais - inicio--------------------------------
		declare @d56_ukey as varchar(20)
		declare @d56_ukeya  as varchar(20)
		declare @d56_ukeyb as varchar(20)
		declare @a22_ukey  as varchar(20)
		declare @a23_ukey as varchar(20)
		declare @a24_ukey as varchar(20)
		declare @a22_ukeya as varchar(20)
		declare @a23_ukeya as varchar(20)
		declare @a24_ukeya as varchar(20)
		declare @a22_ukeyb as varchar(20)
		declare @a23_ukeyb as varchar(20)
		declare @a24_ukeyb as varchar(20)

	

		declare tmpd561 cursor keyset
		for 
			select  d56_dp.D56_UKEY, d56_dp.D56_UKEYA, d56_dp.D56_UKEYB, d56.a22_ukey , d56.a23_ukey, d56.a24_ukey 
			, d56a.a22_ukey as a22_ukeya, d56a.a23_ukey as a23_ukeya, d56a.a24_ukey as a24_ukeya
			, d56b.a22_ukey as a22_ukeyb, d56b.a23_ukey as a23_ukeyb, d56b.a24_ukey as a24_ukeyb
			from starwestcon.dbo.d56_dp (nolock) 
			left join starwestcon.dbo.d56 (nolock) on d56_dp.d56_ukey = d56.ukey
			left join starwestcon.dbo.d56 d56a (nolock) on d56_dp.d56_ukeya = d56a.ukey
			left join starwestcon.dbo.d56 d56b (nolock) on d56_dp.d56_ukeyb = d56b.ukey
			where d56.d56_001_c = @CodigoServicoPadrao

		open tmpd561
		if @@cursor_rows > 0

			begin
				
				FETCH FIRST FROM tmpd561 INTO	@D56_UKEY, @D56_UKEYA, @D56_UKEYB, 
												@a22_ukey , @a23_ukey, @a24_ukey 
											  , @a22_ukeya, @a23_ukeya, @a24_ukeya
											  , @a22_ukeyb, @a23_ukeyb, @a24_ukeyb

				------------------------- Crio Código de Serviço para SP-Sao Paulo --------------------------
				if isnull(@d56_ukey ,'') <> ''
					begin
						INSERT INTO starwestcon.dbo.A85
							([USR_NOTE],[UKEY],[TIMESTAMP],[STATUS],[SQLCMD],[MYCONTROL],[INTEGRATED],[CIA_UKEY],
							[A22_UKEY],[A23_UKEY],[A24_UKEY],[D04_UKEY],[D56_UKEY],[D56_UKEYA])
						SELECT 
							null [USR_NOTE],
							'STAR_STAR_'+(RIGHT(NEWID(),10)) [UKEY],
							@datetime [TIMESTAMP],
							'W' [STATUS],
							null [SQLCMD],'' [MYCONTROL],''[INTEGRATED],'STAR_' [CIA_UKEY]
							,@a22_ukey [A22_UKEY],@a23_ukey [A23_UKEY],@a24_ukey [A24_UKEY]
							,@ukeyd04 [D04_UKEY],@d56_ukey [D56_UKEY],@d56_ukey [D56_UKEYA]
						UNION ALL
						SELECT 
							null , 'STAR_OSL0R'+(RIGHT(NEWID(),10)),@datetime,'W',null,'','','OSL0R'
							,@a22_ukey,@a23_ukey,@a24_ukey
							,@ukeyd04afina,@d56_ukey,@d56_ukey
					end
									
							
				-------------------------Crio Código de Serviço para RJ- Rio--------------------------
				if isnull(@d56_ukeya ,'') <> '' and		(
															isnull(@d56_ukeya ,'') not in (isnull(@d56_ukey,''), isnull(@d56_ukeyb,'')) or 
															isnull(@a22_ukeya ,'') not in (isnull(@a22_ukey,''), isnull(@a22_ukeyb,'')) or 
															isnull(@a23_ukeya ,'') not in (isnull(@a23_ukey,''), isnull(@a23_ukeyb,'')) or
															isnull(@a24_ukeya ,'') not in (isnull(@a24_ukey,''), isnull(@a24_ukeyb,''))

														)
					begin
						INSERT INTO starwestcon.dbo.A85
							([USR_NOTE],[UKEY],[TIMESTAMP],[STATUS],[SQLCMD],[MYCONTROL],[INTEGRATED],[CIA_UKEY],
							[A22_UKEY],[A23_UKEY],[A24_UKEY],[D04_UKEY],[D56_UKEY],[D56_UKEYA])
						SELECT 
							null [USR_NOTE],
							'STAR_STAR_'+(RIGHT(NEWID(),10)) [UKEY],
							@datetime [TIMESTAMP],
							'W' [STATUS],
							null [SQLCMD],'' [MYCONTROL],''[INTEGRATED],'STAR_' [CIA_UKEY]
							,@a22_ukeya [A22_UKEY],@a23_ukeya [A23_UKEY],@a24_ukeya [A24_UKEY]
							,@ukeyd04 [D04_UKEY],@d56_ukeya [D56_UKEY],@d56_ukeya [D56_UKEYA]
						UNION ALL
						SELECT 
							null , 'STAR_OSL0R'+(RIGHT(NEWID(),10)),@datetime,'W',null,'','','OSL0R'
							,@a22_ukeya,@a23_ukeya,@a24_ukeya
							,@ukeyd04afina,@d56_ukeya,@d56_ukeya
					end


				------------------------- Crio Código de Serviço para ES-Serra--------------------------
				if isnull(@d56_ukeyb ,'') <> '' and		(
															isnull(@d56_ukeyb ,'') not in (isnull(@d56_ukey,''), isnull(@d56_ukeya,'')) or 
															isnull(@a22_ukeyb ,'') not in (isnull(@a22_ukey,''), isnull(@a22_ukeya,'')) or 
															isnull(@a23_ukeyb ,'') not in (isnull(@a23_ukey,''), isnull(@a23_ukeya,'')) or
															isnull(@a24_ukeyb ,'') not in (isnull(@a24_ukey,''), isnull(@a24_ukeya,''))

														)
					begin
											
						INSERT INTO starwestcon.dbo.A85
							([USR_NOTE],[UKEY],[TIMESTAMP],[STATUS],[SQLCMD],[MYCONTROL],[INTEGRATED],[CIA_UKEY],
							[A22_UKEY],[A23_UKEY],[A24_UKEY],[D04_UKEY],[D56_UKEY],[D56_UKEYA])
						SELECT 
							null [USR_NOTE],
							'STAR_STAR_'+(RIGHT(NEWID(),10)) [UKEY],
							@datetime [TIMESTAMP],
							'W' [STATUS],
							null [SQLCMD],'' [MYCONTROL],''[INTEGRATED],'STAR_' [CIA_UKEY]
							,@a22_ukeyb [A22_UKEY],@a23_ukeyb [A23_UKEY],@a24_ukeyb [A24_UKEY]
							,@ukeyd04 [D04_UKEY],@d56_ukeyb [D56_UKEY],@d56_ukeyb [D56_UKEYA]
						UNION ALL
						SELECT 
							null , 'STAR_OSL0R'+(RIGHT(NEWID(),10)),@datetime,'W',null,'','','OSL0R'
							,@a22_ukeyb,@a23_ukeyb,@a24_ukeyb
							,@ukeyd04afina,@d56_ukeyb,@d56_ukeyb
					end
			end

			CLOSE tmpd561
			DEALLOCATE tmpd561
			-----------Serviços Municipais - fim--------------------------------


	end

	------------------- C O L O M B I A-----------------------

if @CodERP = 4
	begin
		SET @d03_ukey = (SELECT D03.ukey  FROM StarWestconcala2.dbo.D03 (nolock) where d03.D03_001_C = @familia AND D03.ARRAY_017 = 2 AND D03.CIA_UKEY IN  ('M8530','M8531') )
		set @d16_ukey = (SELECT D16.ukey  FROM StarWestconcala2.dbo.D16 (nolock) where d16.d16_001_c = @ClassificacaoFiscal AND D16.CIA_UKEY IN  ('M8530','M8531') )
		set @D75W_UKEY = (SELECT D75w.ukey  FROM StarWestconcala2.dbo.D75w (nolock) where d75w.d75w_001_c = @GrupoSoftwareServico)
		
		--Cria um registro para as demais empresas compartilihadas

		IF @Tipo = 1 --Hardware
			BEGIN
				set @UkeyAgrupamento = '20081021STAR_R0O8C3O'
			END
		IF @Tipo = 3 --Servico
			BEGIN
				set @UkeyAgrupamento = '20140514R8ZPZG170UQT'
				if @familia LIKE '64%' OR @familia LIKE '79%' -- Se for a familia SERVICIO OU WESTCONCALA, informo o agrupamento sem custo
					begin
						set @UkeyAgrupamento =  '20081021STAR_R0OAJ1O'
					end
			END


		IF @Tipo = 5 --Software
			BEGIN
				set @UkeyAgrupamento = '20081021STAR_R0ODVQQ'
			END
		IF @Tipo = 7 --Software Caixa
			BEGIN
				set @UkeyAgrupamento = '20081021STAR_R0ODVQQ'
			END
		IF @Tipo = 2 --Consumo
			BEGIN
				set @UkeyAgrupamento = '20081021STAR_R0O9CV0'
			END
		IF @Tipo = 4 --Ativo Fixo
			BEGIN
				set @UkeyAgrupamento = '20081021STAR_R0OCZZI'
			END

		-------------- Verifico se existe um item com o mesmo código.
		declare tmpd04 cursor keyset
		for 
			select d04.ukey from StarWestconcala2.dbo.d04 (nolock) where d04_001_c = @Partnumber and cia_ukey IN  ('M8530','M8531')
		
		open tmpd04
		if @@cursor_rows > 0
			begin
				PRINT 'UPDATE CO'
				update  StarWestconcala2.dbo.d04 set d04_020_c = @DescricaoFabricante, d04_008_c = @DescricaoFaturamento, 
				array_098 = @Status, d03_ukey = @d03_ukey, @Preco = 0, t05_ukey = @UkeyAgrupamento,
				d16_ukey = @d16_ukey, ARRAY_050 = @Origem, D04_007_N = @Inventario, D04_038_N = @Kardex, D75W_UKEY = @D75W_UKEY, TIMESTAMP = @datetime
				where d04.d04_001_c = @Partnumber and cia_ukey IN  ('M8530','M8531')
			end
			
		if @@cursor_rows = 0
			begin
				print 'INSERT CO'
		
					INSERT INTO [StarWestconcala2].[dbo].[D04]
							([USR_NOTE],[UKEY],[TIMESTAMP],[STATUS],[SQLCMD],[MYCONTROL],[INTEGRATED],[CIA_UKEY],[A36_CODE0],[A36_UKEYA],[A36_UKEYB],[A36_UKEYC],[A36_UKEYD],[A36_UKEYE],[A36_UKEYF],[A36_UKEYG],[A36_UKEYH],[ARRAY_036],[ARRAY_036A],[ARRAY_036B]
							,[ARRAY_050],[ARRAY_060],[ARRAY_098],[ARRAY_234],[C11_UKEY],[D01_UKEY],[D02_UKEY],[D03_UKEY],[D04_002_B],[D04_003_B],[D04_004_B],[D04_005_B],[D04_006_D],[D04_007_N],[D04_009_B],[D04_010_B],[D04_011_B],[D04_012_B],[D04_013_N],[D04_014_N]
							,[D04_015_D],[D04_016_D],[D04_017_N],[D04_018_N],[D04_019_C],[D04_020_C],[D04_021_B],[D04_022_B],[D04_023_B],[D04_024_B],[D04_025_N],[D04_026_B],[D04_027_C],[D04_028_B],[D04_029_B],[D04_030_N],[D04_031_N],[D04_032_M],[D04_033_B],[D04_035_B]
							,[D04_037_N],[D04_038_N],[D04_039_N],[D04_040_B],[D04_041_D],[D04_042_N],[D04_043_D],[D04_054_D],[D04_083_B],[D04_084_N],[D04_085_N],[D04_094_N],[D04_095_B],[D04_100_D],[D04_101_M],[D04_154_D],[D04_UKEYA],[D07_UKEY],[D07_UKEY0],[D11_UKEY]
							,[D16_UKEY],[D21_UKEY],[D25_UKEY],[D30_UKEY],[D31_UKEY],[T02_UKEY],[T02_UKEY1],[T02_UKEY2],[T05_UKEY],[T71_UKEY],[D04_055_C],[D04_034_C],[D04_036_C],[D04_044_N],[D04_045_N],[D04_046_C],[D49_UKEY],[A11_UKEY],[A56_UKEY],[B11_UKEY]
							,[D04_096_C],[D04_097_C],[D04_098_N],[D04_099_B],[D04_102_N],[D04_103_N],[D04_104_B],[D55_UKEY],[D56_UKEY],[G01_UKEY],[G12_UKEY],[G13_UKEY],[T02_UKEY3],[T21_UKEY],[T22_UKEY],[T23_UKEY],[D04_500_C],[D04_047_N],[D04_155_C]
							,[D04_156_C],[D04_001_C],[ARRAY_840],[D04_158_C],[D04_048_C],[D04_049_C],[A05_UKEY],[A05_UKEYA],[D04_157_N],[D04_159_B],[L52_UKEY],[D04_008_C],[ARRAY_897],[ARRAY_898],[ARRAY_899],[ARRAY_930],[D04_105_N],[D67_UKEY],[D68_UKEY]
							,[ARRAY_1127],[ARRAY_1136],[ARRAY_781],[ARRAY_792],[ARRAY_794],[D04_056_N],[D04_057_N],[D04_058_N],[D04_059_N],[D04_060_N],[D04_061_B],[D04_062_N],[D04_063_N],[D04_160_N],[D04_161_C],[D04_162_D],[D04_163_M],[D04_164_N],[D04_165_C]
							,[D04_166_B],[D04_167_B],[D04_168_B],[D04_169_N], [D75W_UKEY])
							VALUES
							(null, 'STAR_M8530'+(RIGHT(NEWID(),10)),@datetime,'W',null,'','','M8530','$    '+SUBSTRING(CONVERT(CHAR, @datetime, 112),1,8) ,NULL,NULL,NULL,'$    ',NULL,NULL,NULL,'US$  ',1,1,1
							,@Origem ,0,@status,1,NULL,NULL,NULL,@d03_ukey,0,0,0,0,null,@Inventario,0,0,0,0,0,0
							,@datetime,@datetime,0,1,'',@DescricaoFabricante,0,0,0,0,0,0,'',0,0,0,0,null,0,0
							,0,@Kardex,0,0,@datetime,0,null,null,0,0,1,0,0,0,null,null,null,null,null,null
							,@d16_ukey,null,null,null,null,'20120905R8ZPZ911EECN','20120905R8ZPZ911EECN',NULL,@UkeyAgrupamento,null,'','','',0,0,'',null,null,null,null
							,'','',0,0,0,0,0,null,null,null,null,null,null,null,null,null,'',0,''
							,'',@Partnumber,1,'','','',null,null,0,0,null,@DescricaoFaturamento,0,0,0,0,0,null,null
							,0,0,0,0,0,0,0,0,0,0,0,0,0,0,'',null,null,0,''
							,0,0,0,0, @D75W_UKEY)
		END 
		CLOSE tmpd04
		DEALLOCATE tmpd04
end

------------------- C A L A -----------------------

if @CodERP = 2
	begin
		SET @d03_ukey = (SELECT D03.ukey  FROM StarWestconcala2.dbo.D03 (nolock) where d03.D03_001_C = @familia AND D03.ARRAY_017 = 2 and d03.cia_ukey = 'STAR_')
		set @d16_ukey = (SELECT D16.ukey  FROM StarWestconcala2.dbo.D16 (nolock) where d16.d16_001_c = @ClassificacaoFiscal and d16.cia_ukey = 'STAR_')
		set @D75W_UKEY = (SELECT D75w.ukey  FROM StarWestconcala2.dbo.D75w (nolock) where d75w.d75w_001_c = @GrupoSoftwareServico)

		--Cria um registro para as demais empresas compartilihadas

		IF @Tipo = 1 --Hardware
			BEGIN
				set @UkeyAgrupamento = 'STAR_W525U_12C0NA4NE'
			END
		IF @Tipo = 3 --Servico
			BEGIN
				set @UkeyAgrupamento = '20140514R8ZPZG172KFO'
				if @familia LIKE '64%' OR @familia LIKE '79%' -- Se for a familia SERVICIO OU WESTCONCALA, informo o agrupamento sem custo
					begin
						set @UkeyAgrupamento =  'STAR_W525U_12C0NBHNT'
					end
			END


		IF @Tipo = 5 --Software
			BEGIN
				set @UkeyAgrupamento = 'STAR_W525U_12C0NC7DV'
			END
		IF @Tipo = 7 --Software Caixa
			BEGIN
				set @UkeyAgrupamento = 'STAR_STAR__1290MJQEN'
			END
		IF @Tipo = 2 --Consumo
			BEGIN
				set @UkeyAgrupamento = 'STAR_W525U_12C0NB7AV'
			END
		IF @Tipo = 4 --Ativo Fixo
			BEGIN
				set @UkeyAgrupamento = 'STAR_W525U_12C0NBRB0'
			END

		-------------- Verifico se existe um item com o mesmo código.
		declare tmpd04 cursor keyset
		for 
			select d04.ukey from StarWestconcala2.dbo.d04 (nolock) where d04_001_c = @Partnumber and cia_ukey = 'STAR_'
		
		open tmpd04
		if @@cursor_rows > 0
			begin
				PRINT 'UPDATE CALA'
				update  StarWestconcala2.dbo.d04 set d04_020_c = @DescricaoFabricante, d04_008_c = @DescricaoFaturamento, 
				array_098 = @Status, d03_ukey = @d03_ukey, @Preco = 0, t05_ukey = @UkeyAgrupamento,
				d16_ukey = @d16_ukey, ARRAY_050 = @Origem, D04_007_N = @Inventario, D04_038_N = @Kardex, D75W_UKEY = @D75W_UKEY, TIMESTAMP = @datetime
				where d04.d04_001_c = @Partnumber and cia_ukey = 'STAR_'
			end
			
		if @@cursor_rows = 0
			begin
				print 'INSERT CALA'
		
		
					INSERT INTO [StarWestconcala2].[dbo].[D04]
							([USR_NOTE],[UKEY],[TIMESTAMP],[STATUS],[SQLCMD],[MYCONTROL],[INTEGRATED],[CIA_UKEY],[A36_CODE0],[A36_UKEYA],[A36_UKEYB],[A36_UKEYC],[A36_UKEYD],[A36_UKEYE],[A36_UKEYF],[A36_UKEYG],[A36_UKEYH],[ARRAY_036],[ARRAY_036A],[ARRAY_036B]
							,[ARRAY_050],[ARRAY_060],[ARRAY_098],[ARRAY_234],[C11_UKEY],[D01_UKEY],[D02_UKEY],[D03_UKEY],[D04_002_B],[D04_003_B],[D04_004_B],[D04_005_B],[D04_006_D],[D04_007_N],[D04_009_B],[D04_010_B],[D04_011_B],[D04_012_B],[D04_013_N],[D04_014_N]
							,[D04_015_D],[D04_016_D],[D04_017_N],[D04_018_N],[D04_019_C],[D04_020_C],[D04_021_B],[D04_022_B],[D04_023_B],[D04_024_B],[D04_025_N],[D04_026_B],[D04_027_C],[D04_028_B],[D04_029_B],[D04_030_N],[D04_031_N],[D04_032_M],[D04_033_B],[D04_035_B]
							,[D04_037_N],[D04_038_N],[D04_039_N],[D04_040_B],[D04_041_D],[D04_042_N],[D04_043_D],[D04_054_D],[D04_083_B],[D04_084_N],[D04_085_N],[D04_094_N],[D04_095_B],[D04_100_D],[D04_101_M],[D04_154_D],[D04_UKEYA],[D07_UKEY],[D07_UKEY0],[D11_UKEY]
							,[D16_UKEY],[D21_UKEY],[D25_UKEY],[D30_UKEY],[D31_UKEY],[T02_UKEY],[T02_UKEY1],[T02_UKEY2],[T05_UKEY],[T71_UKEY],[D04_055_C],[D04_034_C],[D04_036_C],[D04_044_N],[D04_045_N],[D04_046_C],[D49_UKEY],[A11_UKEY],[A56_UKEY],[B11_UKEY]
							,[D04_096_C],[D04_097_C],[D04_098_N],[D04_099_B],[D04_102_N],[D04_103_N],[D04_104_B],[D55_UKEY],[D56_UKEY],[G01_UKEY],[G12_UKEY],[G13_UKEY],[T02_UKEY3],[T21_UKEY],[T22_UKEY],[T23_UKEY],[D04_500_C],[D04_047_N],[D04_155_C]
							,[D04_156_C],[D04_001_C],[ARRAY_840],[D04_158_C],[D04_048_C],[D04_049_C],[A05_UKEY],[A05_UKEYA],[D04_157_N],[D04_159_B],[L52_UKEY],[D04_008_C],[ARRAY_897],[ARRAY_898],[ARRAY_899],[ARRAY_930],[D04_105_N],[D67_UKEY],[D68_UKEY]
							,[ARRAY_1127],[ARRAY_1136],[ARRAY_781],[ARRAY_792],[ARRAY_794],[D04_056_N],[D04_057_N],[D04_058_N],[D04_059_N],[D04_060_N],[D04_061_B],[D04_062_N],[D04_063_N],[D04_160_N],[D04_161_C],[D04_162_D],[D04_163_M],[D04_164_N],[D04_165_C]
							,[D04_166_B],[D04_167_B],[D04_168_B],[D04_169_N], [D75W_UKEY])
							VALUES
							(null, 'STAR_STAR_'+(RIGHT(NEWID(),10)),@datetime,'W',null,'','','STAR_','US$  '+SUBSTRING(CONVERT(CHAR, @datetime, 112),1,8) ,NULL,NULL,NULL,'US$  ',NULL,NULL,NULL,'US$  ',1,1,1
							,@Origem ,0,@status,1,NULL,NULL,NULL,@d03_ukey,0,0,0,0,null,@Inventario,0,0,0,0,0,0
							,@datetime,@datetime,0,1,'',@DescricaoFabricante,0,0,0,0,0,0,'',0,0,0,0,null,0,0
							,0,@Kardex,0,0,@datetime,0,null,null,0,0,1,0,0,0,null,null,null,null,null,null
							,@d16_ukey,null,null,null,null,'STAR_STAR__1290N2MU3','STAR_STAR__1290N2MU3',NULL,@UkeyAgrupamento,null,'','','',0,0,'',null,null,null,null
							,'','',0,0,0,0,0,null,null,null,null,null,null,null,null,null,'',0,''
							,'',@Partnumber,1,'','','',null,null,0,0,null,@DescricaoFaturamento,0,0,0,0,0,null,null
							,0,0,0,0,0,0,0,0,0,0,0,0,0,0,'',null,null,0,''
							,0,0,0,0, @D75W_UKEY)
		END 
		CLOSE tmpd04
		DEALLOCATE tmpd04
end


------------------- M E X I C O -----------------------

if @CodERP = 3
	begin
		SET @d03_ukey = (SELECT D03.ukey  FROM StarWestconMX.dbo.D03 (nolock) where d03.D03_001_C = @familia AND D03.ARRAY_017 = 2)
		set @d16_ukey = (SELECT D16.ukey  FROM StarWestconMX.dbo.D16 (nolock) where d16.d16_001_c = @ClassificacaoFiscal)		
		set @D75W_UKEY = (SELECT D75w.ukey  FROM StarWestconMX.dbo.D75w (nolock) where d75w.d75w_001_c = @GrupoSoftwareServico)

		-- Indica se o partnumber trabalha com seriais (Usado somente pelo MX pois nos outros paises não é usado o controle de seriais do padrão)
		set @serial = 0

		--Cria um registro para as demais empresas compartilihadas

		IF @Tipo = 1 --Hardware
			BEGIN
				set @UkeyAgrupamento = '20081021STAR_R0O8C3O'
				-- Indica se o partnumber trabalha com seriais (Usado somente pelo MX pois nos outros paises não é usado o controle de seriais do padrão)
				--set @serial = 1
			END
		IF @Tipo = 3 --Servico
			BEGIN
				set @UkeyAgrupamento = '20081021STAR_R0OAJ1O'
			END
		IF @Tipo = 5 --Software
			BEGIN
				set @UkeyAgrupamento = '20081021STAR_R0ODVQQ'
			END
		IF @Tipo = 7 --Software Caixa
			BEGIN
				set @UkeyAgrupamento = '20081021STAR_R0ODVQQ'
			END
		IF @Tipo = 2 --Consumo
			BEGIN
				set @UkeyAgrupamento = '20081021STAR_R0O9CV0'
			END
		IF @Tipo = 4 --Ativo Fixo
			BEGIN
				set @UkeyAgrupamento = '20081021STAR_R0OCZZI'
			END

-------------- Verifico se existe um item com o mesmo código.
		declare tmpd04 cursor keyset
		for 
			select d04.ukey from StarWestconMX.dbo.d04 (nolock) where d04_001_c = @Partnumber and cia_ukey = 'ZG5OF'
		
		open tmpd04
		if @@cursor_rows > 0
			begin
				PRINT 'UPDATE MX'
				update  StarWestconMX.dbo.d04 set d04_020_c = @DescricaoFabricante, d04_008_c = @DescricaoFaturamento, 
				array_098 = @Status, d03_ukey = @d03_ukey, @Preco = 0, t05_ukey = @UkeyAgrupamento,
				d16_ukey = @d16_ukey, ARRAY_050 = @Origem, D04_007_N = @Inventario, D04_037_N = @serial, D04_038_N = @Kardex, D75W_UKEY = @D75W_UKEY, TIMESTAMP = @datetime
				where d04.d04_001_c = @Partnumber and cia_ukey = 'ZG5OF'
			end
			
		if @@cursor_rows = 0
			begin
				print 'INSERT MX'
		
		
				INSERT INTO [StarWestconMX].[dbo].[D04]
						([USR_NOTE],[UKEY],[TIMESTAMP],[STATUS],[SQLCMD],[MYCONTROL],[INTEGRATED],[CIA_UKEY],[A36_CODE0],[A36_UKEYA],[A36_UKEYB],[A36_UKEYC],[A36_UKEYD],[A36_UKEYE],[A36_UKEYF],[A36_UKEYG],[A36_UKEYH],[ARRAY_036],[ARRAY_036A],[ARRAY_036B]
						,[ARRAY_050],[ARRAY_060],[ARRAY_098],[ARRAY_234],[C11_UKEY],[D01_UKEY],[D02_UKEY],[D03_UKEY],[D04_002_B],[D04_003_B],[D04_004_B],[D04_005_B],[D04_006_D],[D04_007_N],[D04_009_B],[D04_010_B],[D04_011_B],[D04_012_B],[D04_013_N],[D04_014_N]
						,[D04_015_D],[D04_016_D],[D04_017_N],[D04_018_N],[D04_019_C],[D04_020_C],[D04_021_B],[D04_022_B],[D04_023_B],[D04_024_B],[D04_025_N],[D04_026_B],[D04_027_C],[D04_028_B],[D04_029_B],[D04_030_N],[D04_031_N],[D04_032_M],[D04_033_B],[D04_035_B]
						,[D04_037_N],[D04_038_N],[D04_039_N],[D04_040_B],[D04_041_D],[D04_042_N],[D04_043_D],[D04_054_D],[D04_083_B],[D04_084_N],[D04_085_N],[D04_094_N],[D04_095_B],[D04_100_D],[D04_101_M],[D04_154_D],[D04_UKEYA],[D07_UKEY],[D07_UKEY0],[D11_UKEY]
						,[D16_UKEY],[D21_UKEY],[D25_UKEY],[D30_UKEY],[D31_UKEY],[T02_UKEY],[T02_UKEY1],[T02_UKEY2],[T05_UKEY],[T71_UKEY],[D04_055_C],[D04_034_C],[D04_036_C],[D04_044_N],[D04_045_N],[D04_046_C],[D49_UKEY],[A11_UKEY],[A56_UKEY],[B11_UKEY]
						,[D04_096_C],[D04_097_C],[D04_098_N],[D04_099_B],[D04_102_N],[D04_103_N],[D04_104_B],[D55_UKEY],[D56_UKEY],[G01_UKEY],[G12_UKEY],[G13_UKEY],[T02_UKEY3],[T21_UKEY],[T22_UKEY],[T23_UKEY],[D04_047_N],[D04_155_C]
						,[D04_156_C],[D04_001_C],[ARRAY_840],[D04_158_C],[D04_048_C],[D04_049_C],[A05_UKEY],[A05_UKEYA],[D04_157_N],[D04_159_B],[L52_UKEY],[D04_008_C],[ARRAY_897],[ARRAY_898],[ARRAY_899],[ARRAY_930],[D04_105_N],[D67_UKEY],[D68_UKEY]
						,[ARRAY_1127],[ARRAY_1136],[ARRAY_781],[ARRAY_792],[ARRAY_794],[D04_056_N],[D04_057_N],[D04_058_N],[D04_059_N],[D04_060_N],[D04_061_B],[D04_062_N],[D04_063_N],[D04_160_N],[D04_161_C],[D04_162_D],[D04_163_M],[D04_164_N],[D04_165_C]
						,[D04_166_B],[D04_167_B],[D04_168_B],[D04_169_N], [D75W_UKEY])
						VALUES
						(null, 'STAR_ZG5OF'+(RIGHT(NEWID(),10)),@datetime,'W',null,'','','ZG5OF','US$  '+SUBSTRING(CONVERT(CHAR, @datetime, 112),1,8) ,NULL,NULL,NULL,'US$  ',NULL,NULL,NULL,'MN   ',1,1,1
						,@Origem ,0,@status,1,NULL,NULL,NULL,@d03_ukey,0,0,0,0,null,@Inventario,0,0,0,0,0,0
						,@datetime,@datetime,0,1,'',@DescricaoFabricante,0,0,0,0,0,0,'',0,0,0,0,null,0,0
						,@serial,@Kardex,0,0,@datetime,0,null,null,0,0,1,0,0,0,null,null,null,null,null,null
						,@d16_ukey,null,null,null,null,'20081203STAR_Y12MNRR','20081203STAR_Y12MNRR',NULL,@UkeyAgrupamento,null,'','','',0,0,'',null,null,null,null
						,'','',0,0,0,0,0,null,null,null,null,null,null,null,null,null,0,''
						,'',@Partnumber,1,'','','',null,null,0,0,null,@DescricaoFaturamento,0,0,0,0,0,null,null
						,0,0,0,0,0,0,0,0,0,0,0,0,0,0,'',null,null,0,''
						,0,0,0,0, @D75W_UKEY)
			END 
		CLOSE tmpd04
		DEALLOCATE tmpd04
end


	------------------- P E R U -----------------------

if @CodERP = 5
	begin
		SET @d03_ukey = (SELECT D03.ukey  FROM StarWestconcala2.dbo.D03 (nolock) where d03.D03_001_C = @familia AND D03.ARRAY_017 = 2 AND D03.CIA_UKEY IN  ('P6SIH') )
		set @d16_ukey = (SELECT D16.ukey  FROM StarWestconcala2.dbo.D16 (nolock) where d16.d16_001_c = @ClassificacaoFiscal AND D16.CIA_UKEY IN  ('P6SIH') )
		set @D75W_UKEY = (SELECT D75w.ukey  FROM StarWestconcala2.dbo.D75w (nolock) where d75w.d75w_001_c = @GrupoSoftwareServico)

		--Cria um registro para as demais empresas compartilihadas

		IF @Tipo = 1 --Hardware
			BEGIN
				set @UkeyAgrupamento = 'P6SIH021STAR_R0O8C3O'
			END
		IF @Tipo = 3 --Servico
			BEGIN
				set @UkeyAgrupamento = 'P6SIH514R8ZPZG170UQT'
				if @familia LIKE '64%' OR @familia LIKE '79%' -- Se for a familia SERVICIO OU WESTCONCALA, informo o agrupamento sem custo
					begin
						set @UkeyAgrupamento =  'P6SIH021STAR_R0OAJ1O'
					end
			END


		IF @Tipo = 5 --Software
			BEGIN
				set @UkeyAgrupamento = 'P6SIH021STAR_R0ODVQQ'
			END
		IF @Tipo = 7 --Software Caixa
			BEGIN
				set @UkeyAgrupamento = 'P6SIH021STAR_R0ODVQQ'
			END
		IF @Tipo = 2 --Consumo
			BEGIN
				set @UkeyAgrupamento = 'P6SIH021STAR_R0O9CV0'
			END
		IF @Tipo = 4 --Ativo Fixo
			BEGIN
				set @UkeyAgrupamento = 'P6SIH021STAR_R0OCZZI'
			END

		-------------- Verifico se existe um item com o mesmo código.
		declare tmpd04 cursor keyset
		for 
			select d04.ukey from StarWestconcala2.dbo.d04 (nolock) where d04_001_c = @Partnumber and cia_ukey IN  ('P6SIH')
		
		open tmpd04
		if @@cursor_rows > 0
			begin
				PRINT 'UPDATE CO'
				update  StarWestconcala2.dbo.d04 set d04_020_c = @DescricaoFabricante, d04_008_c = @DescricaoFaturamento, 
				array_098 = @Status, d03_ukey = @d03_ukey, @Preco = 0, t05_ukey = @UkeyAgrupamento,
				d16_ukey = @d16_ukey, ARRAY_050 = @Origem, D04_007_N = @Inventario, D04_038_N = @Kardex, D75W_UKEY = @D75W_UKEY, TIMESTAMP = @datetime
				where d04.d04_001_c = @Partnumber and cia_ukey IN  ('P6SIH')
			end
			
		if @@cursor_rows = 0
			begin
				print 'INSERT CO'
		
					INSERT INTO [StarWestconcala2].[dbo].[D04]
							([USR_NOTE],[UKEY],[TIMESTAMP],[STATUS],[SQLCMD],[MYCONTROL],[INTEGRATED],[CIA_UKEY],[A36_CODE0],[A36_UKEYA],[A36_UKEYB],[A36_UKEYC],[A36_UKEYD],[A36_UKEYE],[A36_UKEYF],[A36_UKEYG],[A36_UKEYH],[ARRAY_036],[ARRAY_036A],[ARRAY_036B]
							,[ARRAY_050],[ARRAY_060],[ARRAY_098],[ARRAY_234],[C11_UKEY],[D01_UKEY],[D02_UKEY],[D03_UKEY],[D04_002_B],[D04_003_B],[D04_004_B],[D04_005_B],[D04_006_D],[D04_007_N],[D04_009_B],[D04_010_B],[D04_011_B],[D04_012_B],[D04_013_N],[D04_014_N]
							,[D04_015_D],[D04_016_D],[D04_017_N],[D04_018_N],[D04_019_C],[D04_020_C],[D04_021_B],[D04_022_B],[D04_023_B],[D04_024_B],[D04_025_N],[D04_026_B],[D04_027_C],[D04_028_B],[D04_029_B],[D04_030_N],[D04_031_N],[D04_032_M],[D04_033_B],[D04_035_B]
							,[D04_037_N],[D04_038_N],[D04_039_N],[D04_040_B],[D04_041_D],[D04_042_N],[D04_043_D],[D04_054_D],[D04_083_B],[D04_084_N],[D04_085_N],[D04_094_N],[D04_095_B],[D04_100_D],[D04_101_M],[D04_154_D],[D04_UKEYA],[D07_UKEY],[D07_UKEY0],[D11_UKEY]
							,[D16_UKEY],[D21_UKEY],[D25_UKEY],[D30_UKEY],[D31_UKEY],[T02_UKEY],[T02_UKEY1],[T02_UKEY2],[T05_UKEY],[T71_UKEY],[D04_055_C],[D04_034_C],[D04_036_C],[D04_044_N],[D04_045_N],[D04_046_C],[D49_UKEY],[A11_UKEY],[A56_UKEY],[B11_UKEY]
							,[D04_096_C],[D04_097_C],[D04_098_N],[D04_099_B],[D04_102_N],[D04_103_N],[D04_104_B],[D55_UKEY],[D56_UKEY],[G01_UKEY],[G12_UKEY],[G13_UKEY],[T02_UKEY3],[T21_UKEY],[T22_UKEY],[T23_UKEY],[D04_500_C],[D04_047_N],[D04_155_C]
							,[D04_156_C],[D04_001_C],[ARRAY_840],[D04_158_C],[D04_048_C],[D04_049_C],[A05_UKEY],[A05_UKEYA],[D04_157_N],[D04_159_B],[L52_UKEY],[D04_008_C],[ARRAY_897],[ARRAY_898],[ARRAY_899],[ARRAY_930],[D04_105_N],[D67_UKEY],[D68_UKEY]
							,[ARRAY_1127],[ARRAY_1136],[ARRAY_781],[ARRAY_792],[ARRAY_794],[D04_056_N],[D04_057_N],[D04_058_N],[D04_059_N],[D04_060_N],[D04_061_B],[D04_062_N],[D04_063_N],[D04_160_N],[D04_161_C],[D04_162_D],[D04_163_M],[D04_164_N],[D04_165_C]
							,[D04_166_B],[D04_167_B],[D04_168_B],[D04_169_N], [D75W_UKEY])
							VALUES
							(null, 'STAR_P6SIH'+(RIGHT(NEWID(),10)),@datetime,'W',null,'','','P6SIH','PEN  '+SUBSTRING(CONVERT(CHAR, @datetime, 112),1,8) ,NULL,NULL,NULL,'PEN  ',NULL,NULL,NULL,'US$  ',1,1,1
							,@Origem ,0,@status,1,NULL,NULL,NULL,@d03_ukey,0,0,0,0,null,@Inventario,0,0,0,0,0,0
							,@datetime,@datetime,0,1,'',@DescricaoFabricante,0,0,0,0,0,0,'',0,0,0,0,null,0,0
							,0,@Kardex,0,0,@datetime,0,null,null,0,0,1,0,0,0,null,null,null,null,null,null
							,@d16_ukey,null,null,null,null,'P6SIH905R8ZPZ911EECN','P6SIH905R8ZPZ911EECN',NULL,@UkeyAgrupamento,null,'','','',0,0,'',null,null,null,null
							,'','',0,0,0,0,0,null,null,null,null,null,null,null,null,null,'',0,''
							,'',@Partnumber,1,'','','',null,null,0,0,null,@DescricaoFaturamento,0,0,0,0,0,null,null
							,0,0,0,0,0,0,0,0,0,0,0,0,0,0,'',null,null,0,''
							,0,0,0,0, @D75W_UKEY)
		END 
		CLOSE tmpd04
		DEALLOCATE tmpd04
end






