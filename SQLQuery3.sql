USE [Westcon]
GO
/****** Object:  StoredProcedure [Starsoft].[SP_INSERT_D04]    Script Date: 22/07/2015 10:15:22 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

ALTER PROCEDURE [Starsoft].[SP_INSERT_D04]
(
	@CodERP 		INT,			-- CodERP 1 - Brasil / 2 - Cala / 3 - Mexico / 4 - Colombia
	@Partnumber varchar(50),
	@DescricaoFabricante varchar(200),
	@DescricaoFaturamento varchar(200),
	@Status numeric(1),
	@Familia varchar(100),
	@Preco float,
	@Tipo int,
	@GrupoDesconto varchar(100),
	@ClassificacaoFiscal varchar(50),
	@Origem int,
	@Inventario int,
	@Kardex int,
	@CodigoServicoPadrao varchar(50),
	@GrupoSoftwareServico varchar(50)

)

AS 

declare  @UkeyAgrupamento as varchar(50)
declare @d03_ukey as varchar(100)
declare @d16_ukey as varchar(100) 
declare @status1 as int

--Serviços Municipais
declare @Servico as int
declare @ukeyd04 as varchar(20)
set @Servico = 0


----------------- B R A S I L -----------------------
if @CodERP = 1 
	begin
		set @status1 = 1
		SET @d03_ukey = (SELECT D03.ukey  FROM StarWestcon.dbo.D03 (nolock) where d03.d03_001_c = @familia)
		set @d16_ukey = (SELECT D16.ukey  FROM StarWestcon.dbo.D16 (nolock) where d16.d16_001_c = @ClassificacaoFiscal)		
		if @Status = 0
			begin
				set @status1 = 2
			end

		IF @Tipo = 1 --Hardware
			BEGIN
				set @UkeyAgrupamento = 'STAR_W525U_12C0NA4NE'
			END
		IF @Tipo = 3 --Servico
			BEGIN
				set @UkeyAgrupamento = '20140514OF79AG17A5EP'
				if @familia = '6401'
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
		where d04.d04_001_c = @Partnumber and d04.cia_ukey = 'STAR_')
					


		if @@cursor_rows > 0
			begin
				PRINT 'UPDATE BR'
				set @ukeyd04 = (select d04.ukey from StarWestcon.dbo.d04 (nolock) where d04_001_c = @Partnumber and cia_ukey = 'STAR_')

				update  StarWestcon.dbo.d04 set d04_020_c = @DescricaoFabricante, d04_008_c = @DescricaoFaturamento, 
				array_098 = @Status1, d03_ukey = @d03_ukey, @Preco = 0, t05_ukey = @UkeyAgrupamento,
				d16_ukey = @d16_ukey, ARRAY_050 = @Origem, D04_007_N = @Inventario, D04_038_N = @Kardex 
				where d04.d04_001_c = @Partnumber and cia_ukey = 'STAR_'

			end

		if @@cursor_rows = 0
			begin
				print 'INSERT BR'
				--Cria um registro para as demais empresas compartilihadas
				
				
				--Serviços Municipais
				set @ukeyd04 = 'STAR_STAR_'+(RIGHT(NEWID(),10)) 
				--fim

				
				INSERT INTO [StarWestcon].[dbo].[D04]
					([USR_NOTE],[UKEY],[TIMESTAMP],[STATUS],[SQLCMD],[MYCONTROL],[INTEGRATED],[CIA_UKEY],[A36_CODE0],[A36_UKEYA],[A36_UKEYB],[A36_UKEYC],[A36_UKEYD],[A36_UKEYE],[A36_UKEYF],[A36_UKEYG],[A36_UKEYH],[ARRAY_036],[ARRAY_036A],[ARRAY_036B]
					,[ARRAY_050],[ARRAY_060],[ARRAY_098],[ARRAY_234],[C11_UKEY],[D01_UKEY],[D02_UKEY],[D03_UKEY],[D04_002_B],[D04_003_B],[D04_004_B],[D04_005_B],[D04_006_D],[D04_007_N],[D04_009_B],[D04_010_B],[D04_011_B],[D04_012_B],[D04_013_N],[D04_014_N]
					,[D04_015_D],[D04_016_D],[D04_017_N],[D04_018_N],[D04_019_C],[D04_020_C],[D04_021_B],[D04_022_B],[D04_023_B],[D04_024_B],[D04_025_N],[D04_026_B],[D04_027_C],[D04_028_B],[D04_029_B],[D04_030_N],[D04_031_N],[D04_032_M],[D04_033_B],[D04_035_B]
					,[D04_037_N],[D04_038_N],[D04_039_N],[D04_040_B],[D04_041_D],[D04_042_N],[D04_043_D],[D04_054_D],[D04_083_B],[D04_084_N],[D04_085_N],[D04_094_N],[D04_095_B],[D04_100_D],[D04_101_M],[D04_154_D],[D04_UKEYA],[D07_UKEY],[D07_UKEY0],[D11_UKEY]
					,[D16_UKEY],[D21_UKEY],[D25_UKEY],[D30_UKEY],[D31_UKEY],[T02_UKEY],[T02_UKEY1],[T02_UKEY2],[T05_UKEY],[T71_UKEY],[D04_055_C],[D04_034_C],[D04_036_C],[D04_044_N],[D04_045_N],[D04_046_C],[D49_UKEY],[A11_UKEY],[A56_UKEY],[B11_UKEY]
					,[D04_096_C],[D04_097_C],[D04_098_N],[D04_099_B],[D04_102_N],[D04_103_N],[D04_104_B],[D55_UKEY],[D56_UKEY],[G01_UKEY],[G12_UKEY],[G13_UKEY],[T02_UKEY3],[T21_UKEY],[T22_UKEY],[T23_UKEY],[D04_500_C],[D04_047_N],[D04_200_B],[D04_155_C]
					,[D04_156_C],[D04_001_C],[ARRAY_840],[D04_158_C],[D04_048_C],[D04_049_C],[A05_UKEY],[A05_UKEYA],[D04_157_N],[D04_159_B],[L52_UKEY],[D04_008_C],[D04_050_B],[ARRAY_897],[ARRAY_898],[ARRAY_899],[ARRAY_930],[D04_105_N],[D67_UKEY],[D68_UKEY]
					,[WE97_UKEY],[ARRAY_1127],[ARRAY_1136],[ARRAY_781],[ARRAY_792],[ARRAY_794],[D04_056_N],[D04_057_N],[D04_058_N],[D04_059_N],[D04_060_N],[D04_061_B],[D04_062_N],[D04_063_N],[D04_160_N],[D04_161_C],[D04_162_D],[D04_163_M],[D04_164_N],[D04_165_C]
					,[D04_166_B],[D04_167_B],[D04_168_B],[D04_169_N])
				VALUES
					(null, @ukeyd04,getdate(),'W',null,'','','STAR_','US$  '+SUBSTRING(CONVERT(CHAR, GETDATE(), 112),1,8) ,NULL,NULL,NULL,'US$  ',NULL,NULL,NULL,'US$  ',1,1,1
					,@Origem ,0,@status1,1,NULL,NULL,NULL,@d03_ukey,0,0,0,0,null,@Inventario,0,0,0,0,0,0
					,getdate(),getdate(),0,0,'',@DescricaoFabricante,0,0,0,0,0,0,'',0,0,0,0,null,0,0
					,0,@Kardex,0,0,getdate(),0,null,null,0,0,0,0,0,0,null,null,null,null,null,null
					,@d16_ukey,null,null,null,null,'STAR_STAR__1440PRBVX','STAR_STAR__1440PRBVX',NULL,@UkeyAgrupamento,null,'','','',0,0,'',null,null,null,null
					,'','',0,0,0,0,0,null,null,null,null,null,null,null,null,null,'',0,0,''
					,'',@Partnumber,1,'','','',null,null,0,0,null,@DescricaoFaturamento,0,0,0,0,0,0,null,null
					,null,0,0,0,0,0,0,0,0,0,0,0,0,0,0,'',null,null,0,''
					,0,0,0,0)
			end

	

		CLOSE tmpd04
		DEALLOCATE tmpd04
		--Cria um registro para Empresa Afina 'XY5JG'


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
			select d04.ukey from StarWestcon.dbo.d04 (nolock) where d04_001_c = @Partnumber and cia_ukey = 'XY5JG'
		
		open tmpd04
		if @@cursor_rows > 0
			begin
				PRINT 'UPDATE AFINA'
				update  StarWestcon.dbo.d04 set d04_020_c = @DescricaoFabricante, d04_008_c = @DescricaoFaturamento, 
				array_098 = @Status1, d03_ukey = @d03_ukey, @Preco = 0, t05_ukey = @UkeyAgrupamento,
				d16_ukey = @d16_ukey, ARRAY_050 = @Origem, D04_007_N = @Inventario, D04_038_N = @Kardex 
				where d04.d04_001_c = @Partnumber and cia_ukey = 'XY5JG'
			end
			
		if @@cursor_rows = 0
			begin
				PRINT 'INSERT AFINA'

				INSERT INTO [StarWestcon].[dbo].[D04]
							([USR_NOTE],[UKEY],[TIMESTAMP],[STATUS],[SQLCMD],[MYCONTROL],[INTEGRATED],[CIA_UKEY],[A36_CODE0],[A36_UKEYA],[A36_UKEYB],[A36_UKEYC],[A36_UKEYD],[A36_UKEYE],[A36_UKEYF],[A36_UKEYG],[A36_UKEYH],[ARRAY_036],[ARRAY_036A],[ARRAY_036B]
							,[ARRAY_050],[ARRAY_060],[ARRAY_098],[ARRAY_234],[C11_UKEY],[D01_UKEY],[D02_UKEY],[D03_UKEY],[D04_002_B],[D04_003_B],[D04_004_B],[D04_005_B],[D04_006_D],[D04_007_N],[D04_009_B],[D04_010_B],[D04_011_B],[D04_012_B],[D04_013_N],[D04_014_N]
							,[D04_015_D],[D04_016_D],[D04_017_N],[D04_018_N],[D04_019_C],[D04_020_C],[D04_021_B],[D04_022_B],[D04_023_B],[D04_024_B],[D04_025_N],[D04_026_B],[D04_027_C],[D04_028_B],[D04_029_B],[D04_030_N],[D04_031_N],[D04_032_M],[D04_033_B],[D04_035_B]
							,[D04_037_N],[D04_038_N],[D04_039_N],[D04_040_B],[D04_041_D],[D04_042_N],[D04_043_D],[D04_054_D],[D04_083_B],[D04_084_N],[D04_085_N],[D04_094_N],[D04_095_B],[D04_100_D],[D04_101_M],[D04_154_D],[D04_UKEYA],[D07_UKEY],[D07_UKEY0],[D11_UKEY]
							,[D16_UKEY],[D21_UKEY],[D25_UKEY],[D30_UKEY],[D31_UKEY],[T02_UKEY],[T02_UKEY1],[T02_UKEY2],[T05_UKEY],[T71_UKEY],[D04_055_C],[D04_034_C],[D04_036_C],[D04_044_N],[D04_045_N],[D04_046_C],[D49_UKEY],[A11_UKEY],[A56_UKEY],[B11_UKEY]
							,[D04_096_C],[D04_097_C],[D04_098_N],[D04_099_B],[D04_102_N],[D04_103_N],[D04_104_B],[D55_UKEY],[D56_UKEY],[G01_UKEY],[G12_UKEY],[G13_UKEY],[T02_UKEY3],[T21_UKEY],[T22_UKEY],[T23_UKEY],[D04_500_C],[D04_047_N],[D04_200_B],[D04_155_C]
							,[D04_156_C],[D04_001_C],[ARRAY_840],[D04_158_C],[D04_048_C],[D04_049_C],[A05_UKEY],[A05_UKEYA],[D04_157_N],[D04_159_B],[L52_UKEY],[D04_008_C],[D04_050_B],[ARRAY_897],[ARRAY_898],[ARRAY_899],[ARRAY_930],[D04_105_N],[D67_UKEY],[D68_UKEY]
							,[WE97_UKEY],[ARRAY_1127],[ARRAY_1136],[ARRAY_781],[ARRAY_792],[ARRAY_794],[D04_056_N],[D04_057_N],[D04_058_N],[D04_059_N],[D04_060_N],[D04_061_B],[D04_062_N],[D04_063_N],[D04_160_N],[D04_161_C],[D04_162_D],[D04_163_M],[D04_164_N],[D04_165_C]
							,[D04_166_B],[D04_167_B],[D04_168_B],[D04_169_N])
							VALUES
							(null, 'STAR_XY5JG'+(RIGHT(NEWID(),10)),getdate(),'W',null,'','','XY5JG','US$  '+SUBSTRING(CONVERT(CHAR, GETDATE(), 112),1,8) ,NULL,NULL,NULL,'US$  ',NULL,NULL,NULL,'US$  ',1,1,1
							,@Origem ,0,@status1,1,NULL,NULL,NULL,@d03_ukey,0,0,0,0,null,@Inventario,0,0,0,0,0,0
							,getdate(),getdate(),0,0,'',@DescricaoFabricante,0,0,0,0,0,0,'',0,0,0,0,null,0,0
							,0,@Kardex,0,0,getdate(),0,null,null,0,0,0,0,0,0,null,null,null,null,null,null
							,@d16_ukey,null,null,null,null,'STAR_STAR__1440PRBVX','STAR_STAR__1440PRBVX',NULL,@UkeyAgrupamento,null,'','','',0,0,'',null,null,null,null
							,'','',0,0,0,0,0,null,null,null,null,null,null,null,null,null,'',0,0,''
							,'',@Partnumber,1,'','','',null,null,0,0,null,@DescricaoFaturamento,0,0,0,0,0,0,null,null
							,null,0,0,0,0,0,0,0,0,0,0,0,0,0,0,'',null,null,0,''
							,0,0,0,0)

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
			, d56a.a22_ukey as a22_ukeya, d56a.a23_ukey as a23_ukeya, d56b.a24_ukey as a24_ukeya
			, d56b.a22_ukey as a22_ukeyb, d56b.a23_ukey as a23_ukeyb, d56b.a24_ukey as a24_ukeyb
			from starwestcon.dbo.d56_dp (nolock) 
			left join starwestcon.dbo.d56 (nolock) on d56_dp.d56_ukey = d56.ukey
			left join starwestcon.dbo.d56 d56a (nolock) on d56_dp.d56_ukeya = d56a.ukey
			left join starwestcon.dbo.d56 d56b (nolock) on d56_dp.d56_ukeyb = d56b.ukey
			where d56.d56_001_c = @CodigoServicoPadrao

		open tmpd561
		if @@cursor_rows > 0

			begin
				
				FETCH FIRST FROM tmpd561 INTO @D56_UKEY, @D56_UKEYA, @D56_UKEYB, @a22_ukey , @a23_ukey, @a24_ukey 
											, @a22_ukeya, @a23_ukeya, @a24_ukeya
											, @a22_ukeyb, @a23_ukeyb, @a24_ukeyb

				------------------------- Crio Código de Serviço para SP-Sao Paulo --------------------------
				if isnull(@d56_ukey ,'') <> ''
					begin
						INSERT INTO starwestcon.dbo.A85
							([USR_NOTE],[UKEY],[TIMESTAMP],[STATUS],[SQLCMD],[MYCONTROL],[INTEGRATED],[CIA_UKEY],
							[A22_UKEY],[A23_UKEY],[A24_UKEY],[D04_UKEY],[D56_UKEY],[D56_UKEYA])
						VALUES
							(null,'STAR_STAR_'+(RIGHT(NEWID(),10)),getdate(),'W',null,'','','STAR_'
							,@a22_ukey,@a23_ukey,@a24_ukey
							,@ukeyd04,@d56_ukey,@d56_ukey)
					end
									
							
				------------------------- Crio Código de Serviço para RJ- Rio--------------------------
				if isnull(@d56_ukeya ,'') <> ''
					begin
						INSERT INTO starwestcon.dbo.A85
							([USR_NOTE],[UKEY],[TIMESTAMP],[STATUS],[SQLCMD],[MYCONTROL],[INTEGRATED],[CIA_UKEY],
							[A22_UKEY],[A23_UKEY],[A24_UKEY],[D04_UKEY],[D56_UKEY],[D56_UKEYA])
						VALUES
							(null,'STAR_STAR_'+(RIGHT(NEWID(),10)),getdate(),'W',null,'','','STAR_'
							,@a22_ukeya,@a23_ukeya,@a24_ukeya,@ukeyd04,@d56_ukeya,@d56_ukeya)
					end
									
									
				------------------------- Crio Código de Serviço para ES-Serra--------------------------									
				if isnull(@d56_ukeyb ,'') <> ''
					begin
											
						INSERT INTO starwestcon.dbo.A85
							([USR_NOTE],[UKEY],[TIMESTAMP],[STATUS],[SQLCMD],[MYCONTROL],[INTEGRATED],[CIA_UKEY],
							[A22_UKEY],[A23_UKEY],[A24_UKEY],[D04_UKEY],[D56_UKEY],[D56_UKEYA])
						VALUES
							(null,'STAR_STAR_'+(RIGHT(NEWID(),10)),getdate(),'W',null,'','','STAR_'
							,@a22_ukeyb,@a23_ukeyb,@a24_ukeyb,@ukeyd04,@d56_ukeyb,@d56_ukeyb)
					end
			end

			CLOSE tmpd561
			DEALLOCATE tmpd561
			-----------Serviços Municipais - fim--------------------------------


	end

	------------------- C O L O M B I A-----------------------

if @CodERP = 4
	begin
		set @status1 = 1
		SET @d03_ukey = (SELECT D03.ukey  FROM StarWestconcala2.dbo.D03 (nolock) where D03.CIA_UKEY =  'M8530' AND d03.d03_001_c = @familia)
		set @d16_ukey = (SELECT D16.ukey  FROM StarWestconcala2.dbo.D16 (nolock) where D16.CIA_UKEY = 'M8530' AND d16.d16_001_c = @ClassificacaoFiscal)		
		if @Status = 0
			begin
				set @status1 = 2
			end

		--Cria um registro para as demais empresas compartilihadas

		IF @Tipo = 1 --Hardware
			BEGIN
				set @UkeyAgrupamento = '20081021STAR_R0O8C3O'
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
			select d04.ukey from StarWestconcala2.dbo.d04 (nolock) where d04_001_c = @Partnumber and cia_ukey = 'M8530'
		
		open tmpd04
		if @@cursor_rows > 0
			begin
				PRINT 'UPDATE CO'
				update  StarWestconcala2.dbo.d04 set d04_020_c = @DescricaoFabricante, d04_008_c = @DescricaoFaturamento, 
				array_098 = @Status1, d03_ukey = @d03_ukey, @Preco = 0, t05_ukey = @UkeyAgrupamento,
				d16_ukey = @d16_ukey, ARRAY_050 = @Origem, D04_007_N = @Inventario, D04_038_N = @Kardex 
				where d04.d04_001_c = @Partnumber and cia_ukey = 'M8530'
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
							,[D04_166_B],[D04_167_B],[D04_168_B],[D04_169_N])
							VALUES
							(null, 'STAR_M8530'+(RIGHT(NEWID(),10)),getdate(),'W',null,'','','M8530','US$  '+SUBSTRING(CONVERT(CHAR, GETDATE(), 112),1,8) ,NULL,NULL,NULL,'US$  ',NULL,NULL,NULL,'US$  ',1,1,1
							,@Origem ,0,@status1,1,NULL,NULL,NULL,@d03_ukey,0,0,0,0,null,@Inventario,0,0,0,0,0,0
							,getdate(),getdate(),0,0,'',@DescricaoFabricante,0,0,0,0,0,0,'',0,0,0,0,null,0,0
							,0,@Kardex,0,0,getdate(),0,null,null,0,0,0,0,0,0,null,null,null,null,null,null
							,@d16_ukey,null,null,null,null,'STAR_STAR__1440PRBVX','STAR_STAR__1440PRBVX',NULL,@UkeyAgrupamento,null,'','','',0,0,'',null,null,null,null
							,'','',0,0,0,0,0,null,null,null,null,null,null,null,null,null,'',0,''
							,'',@Partnumber,1,'','','',null,null,0,0,null,@DescricaoFaturamento,0,0,0,0,0,null,null
							,0,0,0,0,0,0,0,0,0,0,0,0,0,0,'',null,null,0,''
							,0,0,0,0)
		END 
		CLOSE tmpd04
		DEALLOCATE tmpd04
end

------------------- C A L A -----------------------

if @CodERP = 2
	begin
		set @status1 = 1
		SET @d03_ukey = (SELECT D03.ukey  FROM StarWestconcala2.dbo.D03 (nolock) where d03.d03_001_c = @familia)
		set @d16_ukey = (SELECT D16.ukey  FROM StarWestconcala2.dbo.D16 (nolock) where d16.d16_001_c = @ClassificacaoFiscal)		
		if @Status = 0
			begin
				set @status1 = 2
			end

		--Cria um registro para as demais empresas compartilihadas

		IF @Tipo = 1 --Hardware
			BEGIN
				set @UkeyAgrupamento = 'STAR_W525U_12C0NA4NE'
			END
		IF @Tipo = 3 --Servico
			BEGIN
				set @UkeyAgrupamento = 'STAR_W525U_12C0NBHNT'
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
				array_098 = @Status1, d03_ukey = @d03_ukey, @Preco = 0, t05_ukey = @UkeyAgrupamento,
				d16_ukey = @d16_ukey, ARRAY_050 = @Origem, D04_007_N = @Inventario, D04_038_N = @Kardex 
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
							,[D04_166_B],[D04_167_B],[D04_168_B],[D04_169_N])
							VALUES
							(null, 'STAR_STAR_'+(RIGHT(NEWID(),10)),getdate(),'W',null,'','','STAR_','US$  '+SUBSTRING(CONVERT(CHAR, GETDATE(), 112),1,8) ,NULL,NULL,NULL,'US$  ',NULL,NULL,NULL,'US$  ',1,1,1
							,@Origem ,0,@status1,1,NULL,NULL,NULL,@d03_ukey,0,0,0,0,null,@Inventario,0,0,0,0,0,0
							,getdate(),getdate(),0,0,'',@DescricaoFabricante,0,0,0,0,0,0,'',0,0,0,0,null,0,0
							,0,@Kardex,0,0,getdate(),0,null,null,0,0,0,0,0,0,null,null,null,null,null,null
							,@d16_ukey,null,null,null,null,'STAR_STAR__1440PRBVX','STAR_STAR__1440PRBVX',NULL,@UkeyAgrupamento,null,'','','',0,0,'',null,null,null,null
							,'','',0,0,0,0,0,null,null,null,null,null,null,null,null,null,'',0,''
							,'',@Partnumber,1,'','','',null,null,0,0,null,@DescricaoFaturamento,0,0,0,0,0,null,null
							,0,0,0,0,0,0,0,0,0,0,0,0,0,0,'',null,null,0,''
							,0,0,0,0)
		END 
		CLOSE tmpd04
		DEALLOCATE tmpd04
end


------------------- M E X I C O -----------------------

if @CodERP = 3
	begin
		set @status1 = 1
		SET @d03_ukey = (SELECT D03.ukey  FROM StarWestconMX.dbo.D03 (nolock) where d03.d03_001_c = @familia)
		set @d16_ukey = (SELECT D16.ukey  FROM StarWestconMX.dbo.D16 (nolock) where d16.d16_001_c = @ClassificacaoFiscal)		
		if @Status = 0
			begin
				set @status1 = 2
			end

		--Cria um registro para as demais empresas compartilihadas

		IF @Tipo = 1 --Hardware
			BEGIN
				set @UkeyAgrupamento = '20081021STAR_R0O8C3O'
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
				array_098 = @Status1, d03_ukey = @d03_ukey, @Preco = 0, t05_ukey = @UkeyAgrupamento,
				d16_ukey = @d16_ukey, ARRAY_050 = @Origem, D04_007_N = @Inventario, D04_038_N = @Kardex 
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
						,[D04_166_B],[D04_167_B],[D04_168_B],[D04_169_N])
						VALUES
						(null, 'STAR_ZG5OF'+(RIGHT(NEWID(),10)),getdate(),'W',null,'','','ZG5OF','US$  '+SUBSTRING(CONVERT(CHAR, GETDATE(), 112),1,8) ,NULL,NULL,NULL,'US$  ',NULL,NULL,NULL,'US$  ',1,1,1
						,@Origem ,0,@status1,1,NULL,NULL,NULL,@d03_ukey,0,0,0,0,null,@Inventario,0,0,0,0,0,0
						,getdate(),getdate(),0,0,'',@DescricaoFabricante,0,0,0,0,0,0,'',0,0,0,0,null,0,0
						,0,@Kardex,0,0,getdate(),0,null,null,0,0,0,0,0,0,null,null,null,null,null,null
						,@d16_ukey,null,null,null,null,'20081203STAR_Y12MNRR','20081203STAR_Y12MNRR',NULL,@UkeyAgrupamento,null,'','','',0,0,'',null,null,null,null
						,'','',0,0,0,0,0,null,null,null,null,null,null,null,null,null,0,''
						,'',@Partnumber,1,'','','',null,null,0,0,null,@DescricaoFaturamento,0,0,0,0,0,null,null
						,0,0,0,0,0,0,0,0,0,0,0,0,0,0,'',null,null,0,''
						,0,0,0,0)
			END 
		CLOSE tmpd04
		DEALLOCATE tmpd04
end



