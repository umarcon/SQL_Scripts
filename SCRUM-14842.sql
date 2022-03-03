USE [Westcon]
GO

/****** Object:  StoredProcedure [Starsoft].[Reports_ListDemoItems]    Script Date: 24/11/2015 15:48:38 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO





--exec [StarSoft].[Reports_ListDemoItems] '20130101',3,'','',2
--exec [StarSoft].[Reports_ListDemoItems] 1,'2013-01-01',3,'','0',1
--exec [StarSoft].[Reports_ListDemoItems] @DataIni, @Tipo,	@CodigoEmpresa, @CodVendor,	@Affinity


ALTER PROCEDURE [Starsoft].[Reports_ListDemoItems] 
	@CodERP as int, -- Indica a empresa a ser processada : 1- Brasil, 2- Cala, 3- México, 4- Colômbia
	@DataIni as date, -- Data Nota Fiscal Demo (Serão Filtradas Notas a Partir dessa Data)
	@Tipo as int, -- 1 = não retornadas, 2 = retornadas, 3 = todas
	@CodigoEmpresa as varchar(50) = NULL, -- Código do cliente
	@CodVendor as varchar(50) = '0', -- Nome do Fabricante (Familia do item do estoque no SSA)
	@Affinity as int -- 1- "Demonstração", 2- "Comodato"
	
WITH RECOMPILE
	
AS
BEGIN

	SET NOCOUNT ON;

	declare 
		@sql as varchar(8000),
		@sqlBrasil as varchar(8000),
		@sqlCALA2 as varchar(8000),
		@sqlMX as varchar(8000),
		@sqlColombia as varchar(8000)
		

	-- Select Genérica de Notas de Saída para o local de demonstração (Considerando sempre Notas que efetuam Transferências de Locais como Notas de Demonstração)
	-- Essa select com esse método será utilizada para todas as empresas, iremos mudar apenas os parâmetros de banco e local de demosntração
	
	set @sql='
	select
		@CodERP as CodERP,
		''@BASE'' as Base,
		''dbo'' as Owner,
		''@BusinessUnit'' as BusinessUnit, 
		CIA.CIA_006_C @COLLATION as IssuerCode, 
		D07destino.D07_001_C AS Local,
		CIA.CIA_001_C @COLLATION as Issuer, 
		J09.J09_001_C @COLLATION as ShipDocSeries, 
		J10SaidaDemo.J10_001_C @COLLATION as ShipDocNumber, 
		J10SaidaDemo.USR_NOTE @COLLATION as ShipDocNotes, 
		J10SaidaDemo.J10_003_D as ShipDocDate, 
		A03.A03_001_C @COLLATION as CustomerCode, 
		A03.A03_002_C @COLLATION as CustomerAlias, 
		A03.A03_003_C @COLLATION as CustomerName, 
		D04.D04_001_C @COLLATION as Item, 
		J11SaidaDemo.J11_003_B as DemoQty, 
		J11SaidaDemo.J11_006_B as DemoTotalAmount,
		LEFT(J10SaidaDemo.A36_CODE,5) @COLLATION AS Currency,
		ISNULL(J11RetornoDemo.J11_003_B,0) as ReturnedQty, 
		CASE WHEN J11SaidaDemo.J11_003_B=ISNULL(J11RetornoDemo.J11_003_B,0) THEN ''RETURNED'' ELSE '''' END as [Returned],
		J11SaidaDemo.UKEY @COLLATION as J11UKEY,
		J11SaidaDemo.CIA_UKEY @COLLATION as J11CIAUKEY,
		--tblVendor.NomeVendor @COLLATION as Vendor,
		[Westcon].[Intranet].[Reports_PartNumberVendor](D04.D04_001_C @COLLATION) AS VENDOR,
		J11RetornoDemo.LastReturnDate AS LastReturnDate,
		DATEDIFF(dd,J10SaidaDemo.J10_003_D,ISNULL(J11RetornoDemo.LastReturnDate,getdate())) as DemoDays,
		J07.J07_001_C AS NUM_OV, 
		A33.A33_002_C AS AM,
		(SELECT top 1 RTRIM(WE01_003_C) AS SerialNumber
			FROM StarWestcon.dbo.J07 J07A (NOLOCK)
				INNER JOIN StarWestcon.dbo.J08 J08A (NOLOCK) ON J08A.J07_UKEY=J07A.UKEY
				INNER JOIN StarWestcon.dbo.WE02 (NOLOCK) ON WE02_UKEYP=J08A.UKEY AND WE02_PAR=''J08''
				INNER JOIN StarWestcon.dbo.WE01 (NOLOCK) ON WE02.WE01_UKEY=WE01.UKEY
			WHERE J07A.J07_503_N = J07.J07_503_N
			order by we01_006_d desc			
			) serialnumber,
		GECON.NomeGrupoEconomico AS GRP_ECONOMICO_S
		
	from 
		@Base.dbo.D14 D14 WITH (NoLock) -- entrada: é aqui que deve estar a referência ao local demo 0201 nas saídas de demo
		INNER JOIN @Base.dbo.D22 D22 WITH (NoLock) ON D14.D22_UKEY = D22.UKEY 
		INNER JOIN @Base.dbo.D07 D07origem WITH (NoLock) ON D22.D07_UKEY=D07origem.UKEY
		INNER JOIN @Base.dbo.D07 D07destino WITH (NoLock) ON D14.D07_UKEY=D07destino.UKEY
		INNER JOIN @Base.dbo.J11 J11SaidaDemo WITH (NoLock) ON D22_IUKEYP=J11SaidaDemo.UKEY 
		INNER JOIN @Base.dbo.J10 J10SaidaDemo WITH (NoLock) ON J11SaidaDemo.J10_UKEY=J10SaidaDemo.UKEY 
		INNER JOIN @Base.dbo.D04 D04 WITH (NoLock) ON J11SaidaDemo.D04_UKEY=D04.UKEY
		INNER JOIN @Base.dbo.CIA CIA WITH (NoLock) ON J10SaidaDemo.CIA_UKEY=CIA.UKEY
		--LEFT OUTER JOIN Westcon.dbo.tblParte1 tblParte1 WITH (NoLock) ON D04.D04_001_C @COLLATION=tblParte1.CodParte
		--LEFT OUTER JOIN Westcon.dbo.tblVendor tblVendor WITH (NoLock) ON tblVendor.CodVendor=tblParte1.CodVendor
		LEFT OUTER JOIN @Base.dbo.J09 J09 WITH (NoLock) ON J10SaidaDemo.J09_UKEY=J09.UKEY
		LEFT OUTER JOIN @Base.dbo.j07 (nolock) on J10SaidaDemo.j07_ukey = j07.ukey
		LEFT OUTER JOIN @Base.DBO.A33 (NOLOCK) ON J10SAIDADEMO.A33_UKEY = A33.UKEY
		INNER JOIN @Base.dbo.A03 A03 WITH (NoLock) ON J10SaidaDemo.A03_UKEY=A03.UKEY
		left JOIN [WESTCON].[INTRANET].[EMPRESASGRUPOSECONOMICOS] GECON ON GECON.CNPJ = A03.A03_010_C
		LEFT OUTER JOIN 
			(	SELECT J11T.J11_UKEYP, SUM(J11T.J11_003_B) AS J11_003_B, MAX(J10T.J10_003_D) as LastReturnDate
				FROM 
					@Base.dbo.J11 J11T WITH (NoLock) 
					INNER JOIN @Base.dbo.J10 J10T WITH (NoLock) ON J11T.J10_UKEY=J10T.UKEY
				GROUP BY J11T.J11_UKEYP
			) J11RetornoDemo ON J11RetornoDemo.J11_UKEYP=J11SaidaDemo.UKEY
	where 
		D07destino.D07_001_C in (''@LocalDemo'')
		AND D14.D22_UKEY is not null AND J11SaidaDemo.D07_UKEY0 IS NOT NULL -- Indica que é uma Transferência entre ou Para Locais
		AND D22_IPAR=''J11''
		AND J10SaidaDemo.J10_003_D >= ''@DataIni''
		-- AND ( (''@CodVendor'' = '''') OR (tblParte1.CodVendor=''@CodVendor'') )
		AND ( (''@CodVendor'' = ''0'') OR ( [Westcon].[Intranet].[Reports_PartNumberVendor](D04.D04_001_C @COLLATION) =''@CodVendor'') )
		AND -- Tipo: 1 = não retornadas, 2 = retornadas, 3 = todas
			(
				( @Tipo=1 AND J11SaidaDemo.J11_003_B > isnull(J11RetornoDemo.J11_003_B,0) )
				OR ( @Tipo=2 AND J11SaidaDemo.J11_003_B = J11RetornoDemo.J11_003_B)
				OR ( @Tipo=3 )
			)
		AND ( (''@CodigoEmpresa'' = '''') OR (A03.A03_001_C=''@CodigoEmpresa'') )
	'
	
	-- Configuração dos Parâmetros utilizados por todas as empresas
	select @sql = replace(@sql,'@Tipo',convert(varchar,@Tipo)); -- Tipo: 1 = não retornadas, 2 = retornadas, 3 = todas
	select @sql = replace(@sql,'@DataIni',@DataIni); -- Serão Filtradas Notas a Partir dessa Data
	select @sql = replace(@sql,'@CodigoEmpresa',ISNULL(@CodigoEmpresa,'''')); -- Código do Cliente de Destino da Nota
	select @sql = replace(@sql,'@CodVendor',ISNULL(@CodVendor,''''));	 -- Nome do Fabricante do Item (Familia do item no SSA)
	
	
	-- Configuração dos parâmetros para as empresas do Brasil
	set @sqlBrasil = @sql

	select @sqlBrasil = replace(@sqlBrasil,'@Base','StarWestcon') -- Nome do Banco de Dados do Brasil
	select @sqlBrasil = replace(@sqlBrasil,'@CodERP','1') -- Padrão utilizado pela Westcon para Identificação das Empresas (1 - Brasil)
	select @sqlBrasil = replace(@sqlBrasil,'@BusinessUnit','Brasil') -- Unidade de Negócio
	
	-- Verifico qual afinidade quero consultar: 1- "Demonstração", 2- "Comodato"
	if (@Affinity = 1)	
		select @sqlBrasil = replace(@sqlBrasil,'@LocalDemo','02010001'',''02090001') -- Código do Local de Demonstração
	ELSE  	
		select @sqlBrasil = replace(@sqlBrasil,'@LocalDemo','02020001'',''02100001'',''02100002') -- Código do Local de Comodato
			
	select @sqlBrasil = replace(@sqlBrasil,'@COLLATION','') -- Configuração da Collation do Banco
	
	-- Configuração dos parâmetros para a empresa de CALA
	set @sqlCALA2 = @sql
	
	select @sqlCALA2 = replace(@sqlCALA2,'@Base','StarWestconCALA2') -- Nome do Banco de Dados de Cala
	select @sqlCALA2 = replace(@sqlCALA2,'@CodERP','2') -- Padrão utilizado pela Westcon para Identificação das Empresas (2 - Cala)	
	select @sqlCALA2 = replace(@sqlCALA2,'@BusinessUnit','CALA') -- Unidade de Negócio
	select @sqlCALA2 = replace(@sqlCALA2,'@LocalDemo','NOT SUPPORTED') -- Código do Local de Demonstração
	select @sqlCALA2 = replace(@sqlCALA2,'@COLLATION','COLLATE SQL_Latin1_General_CP1_CI_AS') -- Configuração da Collation do Banco
	-- Filtro somente NFs de Cala, pois o banco é junto com a empresa da Colômbia
	set @sqlCALA2 = @sqlCALA2 + ' AND J10SaidaDemo.CIA_UKEY = ''STAR_'' '
	
	-- Configuração dos parâmetros para a empresa do México
	set @sqlMX = @sql
	
	select @sqlMX = replace(@sqlMX,'@Base','StarWestconMX') -- Nome do Banco de Dados do México
	select @sqlMX = replace(@sqlMX,'@CodERP','3') -- Padrão utilizado pela Westcon para Identificação das Empresas (3 - México)	
	select @sqlMX = replace(@sqlMX,'@BusinessUnit','Mexico') -- Unidade de Negócio
	select @sqlMX = replace(@sqlMX,'@LocalDemo','0102002') -- Código do Local de Demonstração
	select @sqlMX = replace(@sqlMX,'@COLLATION','') -- Configuração da Collation do Banco

	-- Configuração dos parâmetros para a empresa da Colômbia
	set @sqlColombia = @sql
	
	select @sqlColombia = replace(@sqlColombia,'@Base','StarWestconCALA2') -- Nome do Banco de Dados da Colômbia
	select @sqlColombia = replace(@sqlColombia,'@CodERP','4') -- Padrão utilizado pela Westcon para Identificação das Empresas (4 - Colômbia)
	select @sqlColombia = replace(@sqlColombia,'@BusinessUnit','Colombia') -- Unidade de Negócio
	select @sqlColombia = replace(@sqlColombia,'@LocalDemo','NOT SUPPORTED') -- Código do Local de Demonstração
	select @sqlColombia = replace(@sqlColombia,'@COLLATION','COLLATE SQL_Latin1_General_CP1_CI_AS') -- Configuração da Collation do Banco
	-- Filtro somente NFs de Colômbia, pois o banco é junto com a empresa da Cala
	set @sqlColombia = @sqlColombia + ' AND J10SaidaDemo.CIA_UKEY = ''M8530'' '	

	-- Executo a query para todas as Empresas
	IF ( @CodERP = 1)
		execute( '' + @sqlBrasil);
	ELSE IF ( @CodERP = 2)
		execute( '' + @sqlCALA2);
	ELSE IF ( @CodERP = 3)
		execute( '' + @sqlMX);		
	ELSE IF ( @CodERP = 4)
		execute( '' + @sqlColombia);			

	
END



GO

