USE [StarWestcon]
GO

/****** Object:  Table [dbo].[CIA]    Script Date: 20/03/2018 10:11:27 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

SET ANSI_PADDING ON
GO

drop table cia 

CREATE TABLE [dbo].[CIA](
	[UKEY] [char](5) NOT NULL,
	[MYCONTROL] [char](1) NOT NULL,
	[SQLCMD] [text] NULL,
	[STATUS] [char](10) NOT NULL,
	[TIMESTAMP] [datetime] NULL,
	[A36_CODE] [char](13) NULL,
	[USR_NOTE] [text] NULL,
	[CIA_UKEY] [char](5) NULL,
	[ARRAY_030] [numeric](15, 0) NOT NULL,
	[ARRAY_031] [numeric](15, 0) NOT NULL,
	[ARRAY_032] [numeric](15, 0) NOT NULL,
	[ARRAY_034] [numeric](15, 0) NOT NULL,
	[A01_UKEY] [char](20) NULL,
	[A22_UKEY] [char](20) NULL,
	[A23_UKEY] [char](20) NULL,
	[A24_UKEY] [char](20) NULL,
	[A25_UKEY] [char](20) NULL,
	[A27_UKEY] [char](20) NULL,
	[T24_UKEY] [char](20) NULL,
	[T60_UKEY] [char](20) NULL,
	[CIA_001_C] [char](60) NOT NULL,
	[CIA_002_C] [char](30) NOT NULL,
	[CIA_003_C] [char](55) NOT NULL,
	[CIA_004_C] [char](10) NOT NULL,
	[CIA_006_C] [char](20) NOT NULL,
	[CIA_007_C] [char](20) NOT NULL,
	[CIA_008_C] [char](20) NOT NULL,
	[CIA_009_C] [char](20) NOT NULL,
	[CIA_010_C] [char](20) NOT NULL,
	[CIA_011_C] [char](20) NOT NULL,
	[CIA_012_C] [char](40) NOT NULL,
	[CIA_013_C] [char](15) NOT NULL,
	[CIA_014_N] [numeric](13, 0) NOT NULL,
	[CIA_015_N] [numeric](13, 0) NOT NULL,
	[CIA_016_N] [numeric](13, 0) NOT NULL,
	[CIA_017_C] [char](6) NOT NULL,
	[CIA_018_C] [char](20) NOT NULL,
	[CIA_019_C] [char](10) NOT NULL,
	[CIA_020_C] [char](30) NOT NULL,
	[CIA_021_C] [char](6) NOT NULL,
	[CIA_022_C] [char](20) NOT NULL,
	[CIA_023_C] [char](10) NOT NULL,
	[CIA_024_C] [char](30) NOT NULL,
	[CIA_025_C] [char](20) NOT NULL,
	[CIA_026_C] [char](100) NOT NULL,
	[CIA_027_C] [char](100) NOT NULL,
	[CIA_028_N] [numeric](15, 0) NOT NULL,
	[CIA_029_N] [numeric](15, 0) NOT NULL,
	[CIA_030_C] [char](20) NOT NULL,
	[CIA_031_C] [char](20) NOT NULL,
	[CIA_032_C] [char](40) NOT NULL,
	[CIA_033_C] [char](100) NOT NULL,
	[CIA_034_C] [char](20) NOT NULL,
	[CIA_035_N] [numeric](13, 0) NOT NULL,
	[CIA_036_N] [numeric](13, 0) NOT NULL,
	[CIA_037_B] [numeric](20, 6) NOT NULL,
	[CIA_038_N] [numeric](14, 0) NOT NULL,
	[CIA_039_N] [numeric](14, 0) NOT NULL,
	[CIA_040_N] [numeric](14, 0) NOT NULL,
	[CIA_041_C] [char](20) NOT NULL,
	[CIA_042_N] [numeric](13, 0) NOT NULL,
	[CIA_043_B] [numeric](20, 6) NOT NULL,
	[CIA_044_B] [numeric](20, 6) NOT NULL,
	[CIA_045_B] [numeric](20, 6) NOT NULL,
	[CIA_046_M] [text] NULL,
	[CIA_047_M] [text] NULL,
	[CIA_048_M] [text] NULL,
	[CIA_049_C] [char](4) NOT NULL,
	[CIA_051_D] [datetime] NULL,
	[CIA_052_C] [char](20) NOT NULL,
	[CIA_053_C] [char](12) NOT NULL,
	[CIA_054_C] [char](6) NOT NULL,
	[CIA_055_C] [char](70) NOT NULL,
	[CIA_056_C] [char](70) NOT NULL,
	[CIA_057_M] [text] NULL,
	[CIA_058_M] [text] NULL,
	[CIA_059_M] [text] NULL,
	[CIA_060_M] [text] NULL,
	[CIA_061_M] [text] NULL,
	[CIA_062_N] [numeric](13, 0) NOT NULL,
	[CIA_064_C] [char](4) NOT NULL,
	[CIA_065_N] [numeric](14, 0) NOT NULL,
	[CIA_067_C] [char](5) NOT NULL,
	[CIA_068_C] [char](25) NOT NULL,
	[CIA_069_C] [char](60) NOT NULL,
	[CIA_070_N] [numeric](9, 0) NOT NULL,
	[CIA_071_N] [numeric](9, 0) NOT NULL,
	[ARRAY_309] [numeric](9, 0) NOT NULL,
	[ARRAY_827] [numeric](8, 0) NOT NULL,
	[ARRAY_828] [numeric](8, 0) NOT NULL,
	[ARRAY_829] [numeric](8, 0) NOT NULL,
	[ARRAY_830] [numeric](8, 0) NOT NULL,
	[CIA_072_N] [numeric](7, 0) NOT NULL,
	[CIA_073_M] [text] NULL,
	[CIA_074_M] [text] NULL,
	[CIA_075_N] [numeric](7, 0) NOT NULL,
	[T77_UKEY] [char](20) NULL,
	[CIA_076_N] [numeric](7, 0) NOT NULL,
	[CIA_077_M] [text] NULL,
	[ARRAY_534] [numeric](4, 0) NOT NULL,
	[ARRAY_535] [numeric](4, 0) NOT NULL,
	[CIA_078_M] [text] NULL,
	[CIA_079_M] [text] NULL,
	[CIA_080_M] [text] NULL,
	[CIA_081_N] [numeric](3, 0) NOT NULL,
	[CIA_082_C] [char](4) NOT NULL,
	[CIA_083_N] [numeric](3, 0) NOT NULL,
	[CIA_085_C] [char](40) NOT NULL,
	[CIA_086_D] [datetime] NULL,
	[CIA_087_D] [datetime] NULL,
	[CIA_088_C] [char](40) NOT NULL,
	[CIA_089_D] [datetime] NULL,
	[CIA_090_N] [numeric](10, 0) NOT NULL,
	[CIA_091_C] [char](60) NOT NULL,
	[CIA_092_C] [char](11) NOT NULL,
	[CIA_093_C] [char](15) NOT NULL,
	[CIA_094_C] [char](15) NOT NULL,
	[CIA_095_C] [char](15) NOT NULL,
	[CIA_096_C] [char](60) NOT NULL,
	[CIA_084_N] [numeric](3, 0) NOT NULL,
	[M85_UKEYA] [char](20) NULL,
	[M85_UKEYB] [char](20) NULL,
	[ARRAY_1001] [numeric](4, 0) NOT NULL,
	[ARRAY_1018] [numeric](4, 0) NOT NULL,
	[CIA_097_N] [numeric](3, 0) NOT NULL,
	[CIA_098_N] [numeric](3, 0) NOT NULL,
	[CIA_099_N] [numeric](3, 0) NOT NULL,
	[CIA_101_M] [text] NULL,
	[CIA_100_M] [text] NULL,
	[A36_UKEY] [char](5) NULL,
	[CIA_CNX_C] [char](100) NULL,
	[ARRAY_098] [numeric](4, 0) NULL,
 	[ARRAY_100] [numeric](4, 0) NULL,
	[ARRAY_782] [numeric](4, 0) NULL,
	[ARRAY_791] [numeric](4, 0) NULL,
	[array_ambiente] [numeric](4, 0) NULL,
	[array_contingencia] [numeric](4, 0) NULL,
	[ARRAY_DBO] [numeric](4, 0) NULL,
	[ARRAY_Enquad] [numeric](4, 0) NULL,
	[ARRAY_RegimeTributario] [numeric](4, 0) NULL,
	[ARRAY_VersaoNFe] [numeric](4, 0) NULL,
	[cia_500_m] [text] NULL,
	[cia_501_m] [text] NULL,
	[cia_502_m] [text] NULL,
	[cia_503_m] [text] NULL,
	[cia_504_m] [text] NULL,
	[cia_505_m] [text] NULL,
	[cia_506_m] [text] NULL,
	[cia_507_m] [text] NULL,
	[CIA_508_N] [numeric](14, 6) NULL,
	[cia_509_m] [text] NULL,
	[CIASC_254_N] [numeric](14, 6) NULL,
	[CIASC_255_N] [numeric](14, 6) NULL,
	[CIASC_256_N] [numeric](14, 6) NULL,
	[CIASC_257_N] [numeric](14, 6) NULL,
	[CIASC_258_N] [numeric](14, 6) NULL,
	[CIASC_259_N] [numeric](14, 6) NULL,
	[CIASC_260_N] [numeric](14, 6) NULL,
	[CIASC_261_N] [numeric](14, 6) NULL,
	[CIASC_264_N] [numeric](14, 6) NULL,
	[CIASC_262_C] [char](60) NULL,
	[CIASC_263_C] [char](200) NULL,
	[CIASC_265_C] [varchar](20) NULL,
	[CIASC_266_C] [varchar](200) NULL,
	[CIASC_267_C] [varchar](200) NULL,
	[CIASC_268_C] [varchar](200) NULL,
	[CIASC_269_C] [varchar](200) NULL,
	[CIASC_270_D] [smalldatetime] NULL,
CONSTRAINT [I_CIA_55P0LP94X] PRIMARY KEY CLUSTERED 
(
	[UKEY] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO

SET ANSI_PADDING OFF
GO

ALTER TABLE [dbo].[CIA] ADD  DEFAULT (' ') FOR [UKEY]
GO

ALTER TABLE [dbo].[CIA] ADD  DEFAULT (' ') FOR [MYCONTROL]
GO

ALTER TABLE [dbo].[CIA] ADD  DEFAULT (' ') FOR [STATUS]
GO

ALTER TABLE [dbo].[CIA] ADD  DEFAULT (' ') FOR [A36_CODE]
GO

ALTER TABLE [dbo].[CIA] ADD  DEFAULT ((0)) FOR [ARRAY_030]
GO

ALTER TABLE [dbo].[CIA] ADD  DEFAULT ((0)) FOR [ARRAY_031]
GO

ALTER TABLE [dbo].[CIA] ADD  DEFAULT ((0)) FOR [ARRAY_032]
GO

ALTER TABLE [dbo].[CIA] ADD  DEFAULT ((0)) FOR [ARRAY_034]
GO

ALTER TABLE [dbo].[CIA] ADD  DEFAULT (' ') FOR [CIA_001_C]
GO

ALTER TABLE [dbo].[CIA] ADD  DEFAULT (' ') FOR [CIA_002_C]
GO

ALTER TABLE [dbo].[CIA] ADD  DEFAULT (' ') FOR [CIA_003_C]
GO

ALTER TABLE [dbo].[CIA] ADD  DEFAULT (' ') FOR [CIA_004_C]
GO

ALTER TABLE [dbo].[CIA] ADD  DEFAULT (' ') FOR [CIA_006_C]
GO

ALTER TABLE [dbo].[CIA] ADD  DEFAULT (' ') FOR [CIA_007_C]
GO

ALTER TABLE [dbo].[CIA] ADD  DEFAULT (' ') FOR [CIA_008_C]
GO

ALTER TABLE [dbo].[CIA] ADD  DEFAULT (' ') FOR [CIA_009_C]
GO

ALTER TABLE [dbo].[CIA] ADD  DEFAULT (' ') FOR [CIA_010_C]
GO

ALTER TABLE [dbo].[CIA] ADD  DEFAULT (' ') FOR [CIA_011_C]
GO

ALTER TABLE [dbo].[CIA] ADD  DEFAULT (' ') FOR [CIA_012_C]
GO

ALTER TABLE [dbo].[CIA] ADD  DEFAULT (' ') FOR [CIA_013_C]
GO

ALTER TABLE [dbo].[CIA] ADD  DEFAULT ((0)) FOR [CIA_014_N]
GO

ALTER TABLE [dbo].[CIA] ADD  DEFAULT ((0)) FOR [CIA_015_N]
GO

ALTER TABLE [dbo].[CIA] ADD  DEFAULT ((0)) FOR [CIA_016_N]
GO

ALTER TABLE [dbo].[CIA] ADD  DEFAULT (' ') FOR [CIA_017_C]
GO

ALTER TABLE [dbo].[CIA] ADD  DEFAULT (' ') FOR [CIA_018_C]
GO

ALTER TABLE [dbo].[CIA] ADD  DEFAULT (' ') FOR [CIA_019_C]
GO

ALTER TABLE [dbo].[CIA] ADD  DEFAULT (' ') FOR [CIA_020_C]
GO

ALTER TABLE [dbo].[CIA] ADD  DEFAULT (' ') FOR [CIA_021_C]
GO

ALTER TABLE [dbo].[CIA] ADD  DEFAULT (' ') FOR [CIA_022_C]
GO

ALTER TABLE [dbo].[CIA] ADD  DEFAULT (' ') FOR [CIA_023_C]
GO

ALTER TABLE [dbo].[CIA] ADD  DEFAULT (' ') FOR [CIA_024_C]
GO

ALTER TABLE [dbo].[CIA] ADD  DEFAULT (' ') FOR [CIA_025_C]
GO

ALTER TABLE [dbo].[CIA] ADD  DEFAULT (' ') FOR [CIA_026_C]
GO

ALTER TABLE [dbo].[CIA] ADD  DEFAULT (' ') FOR [CIA_027_C]
GO

ALTER TABLE [dbo].[CIA] ADD  DEFAULT ((0)) FOR [CIA_028_N]
GO

ALTER TABLE [dbo].[CIA] ADD  DEFAULT ((0)) FOR [CIA_029_N]
GO

ALTER TABLE [dbo].[CIA] ADD  DEFAULT (' ') FOR [CIA_030_C]
GO

ALTER TABLE [dbo].[CIA] ADD  DEFAULT (' ') FOR [CIA_031_C]
GO

ALTER TABLE [dbo].[CIA] ADD  DEFAULT (' ') FOR [CIA_032_C]
GO

ALTER TABLE [dbo].[CIA] ADD  DEFAULT (' ') FOR [CIA_033_C]
GO

ALTER TABLE [dbo].[CIA] ADD  DEFAULT (' ') FOR [CIA_034_C]
GO

ALTER TABLE [dbo].[CIA] ADD  DEFAULT ((0)) FOR [CIA_035_N]
GO

ALTER TABLE [dbo].[CIA] ADD  DEFAULT ((0)) FOR [CIA_036_N]
GO

ALTER TABLE [dbo].[CIA] ADD  DEFAULT ((0)) FOR [CIA_037_B]
GO

ALTER TABLE [dbo].[CIA] ADD  DEFAULT ((0)) FOR [CIA_038_N]
GO

ALTER TABLE [dbo].[CIA] ADD  DEFAULT ((0)) FOR [CIA_039_N]
GO

ALTER TABLE [dbo].[CIA] ADD  DEFAULT ((0)) FOR [CIA_040_N]
GO

ALTER TABLE [dbo].[CIA] ADD  DEFAULT (' ') FOR [CIA_041_C]
GO

ALTER TABLE [dbo].[CIA] ADD  DEFAULT ((0)) FOR [CIA_042_N]
GO

ALTER TABLE [dbo].[CIA] ADD  DEFAULT ((0)) FOR [CIA_043_B]
GO

ALTER TABLE [dbo].[CIA] ADD  DEFAULT ((0)) FOR [CIA_044_B]
GO

ALTER TABLE [dbo].[CIA] ADD  DEFAULT ((0)) FOR [CIA_045_B]
GO

ALTER TABLE [dbo].[CIA] ADD  DEFAULT (' ') FOR [CIA_049_C]
GO

ALTER TABLE [dbo].[CIA] ADD  DEFAULT (' ') FOR [CIA_052_C]
GO

ALTER TABLE [dbo].[CIA] ADD  DEFAULT (' ') FOR [CIA_053_C]
GO

ALTER TABLE [dbo].[CIA] ADD  DEFAULT (' ') FOR [CIA_054_C]
GO

ALTER TABLE [dbo].[CIA] ADD  DEFAULT (' ') FOR [CIA_055_C]
GO

ALTER TABLE [dbo].[CIA] ADD  DEFAULT (' ') FOR [CIA_056_C]
GO

ALTER TABLE [dbo].[CIA] ADD  DEFAULT ((0)) FOR [CIA_062_N]
GO

ALTER TABLE [dbo].[CIA] ADD  DEFAULT (' ') FOR [CIA_064_C]
GO

ALTER TABLE [dbo].[CIA] ADD  DEFAULT ((0)) FOR [CIA_065_N]
GO

ALTER TABLE [dbo].[CIA] ADD  DEFAULT (' ') FOR [CIA_067_C]
GO

ALTER TABLE [dbo].[CIA] ADD  DEFAULT (' ') FOR [CIA_068_C]
GO

ALTER TABLE [dbo].[CIA] ADD  DEFAULT (' ') FOR [CIA_069_C]
GO

ALTER TABLE [dbo].[CIA] ADD  DEFAULT ((0)) FOR [CIA_070_N]
GO

ALTER TABLE [dbo].[CIA] ADD  DEFAULT ((0)) FOR [CIA_071_N]
GO

ALTER TABLE [dbo].[CIA] ADD  DEFAULT ((0)) FOR [ARRAY_309]
GO

ALTER TABLE [dbo].[CIA] ADD  DEFAULT ((0)) FOR [ARRAY_827]
GO

ALTER TABLE [dbo].[CIA] ADD  DEFAULT ((0)) FOR [ARRAY_828]
GO

ALTER TABLE [dbo].[CIA] ADD  DEFAULT ((0)) FOR [ARRAY_829]
GO

ALTER TABLE [dbo].[CIA] ADD  DEFAULT ((0)) FOR [ARRAY_830]
GO

ALTER TABLE [dbo].[CIA] ADD  DEFAULT ((0)) FOR [CIA_072_N]
GO

ALTER TABLE [dbo].[CIA] ADD  DEFAULT ((0)) FOR [CIA_075_N]
GO

ALTER TABLE [dbo].[CIA] ADD  DEFAULT ((0)) FOR [CIA_076_N]
GO

ALTER TABLE [dbo].[CIA] ADD  DEFAULT ((0)) FOR [ARRAY_534]
GO

ALTER TABLE [dbo].[CIA] ADD  DEFAULT ((0)) FOR [ARRAY_535]
GO

ALTER TABLE [dbo].[CIA] ADD  DEFAULT ((0)) FOR [CIA_081_N]
GO

ALTER TABLE [dbo].[CIA] ADD  DEFAULT (' ') FOR [CIA_082_C]
GO

ALTER TABLE [dbo].[CIA] ADD  DEFAULT ((0)) FOR [CIA_083_N]
GO

ALTER TABLE [dbo].[CIA] ADD  DEFAULT (' ') FOR [CIA_085_C]
GO

ALTER TABLE [dbo].[CIA] ADD  DEFAULT (' ') FOR [CIA_088_C]
GO

ALTER TABLE [dbo].[CIA] ADD  DEFAULT ((0)) FOR [CIA_090_N]
GO

ALTER TABLE [dbo].[CIA] ADD  DEFAULT (' ') FOR [CIA_091_C]
GO

ALTER TABLE [dbo].[CIA] ADD  DEFAULT (' ') FOR [CIA_092_C]
GO

ALTER TABLE [dbo].[CIA] ADD  DEFAULT (' ') FOR [CIA_093_C]
GO

ALTER TABLE [dbo].[CIA] ADD  DEFAULT (' ') FOR [CIA_094_C]
GO

ALTER TABLE [dbo].[CIA] ADD  DEFAULT (' ') FOR [CIA_095_C]
GO

ALTER TABLE [dbo].[CIA] ADD  DEFAULT (' ') FOR [CIA_096_C]
GO

ALTER TABLE [dbo].[CIA] ADD  DEFAULT ((0)) FOR [CIA_084_N]
GO

ALTER TABLE [dbo].[CIA] ADD  DEFAULT (' ') FOR [M85_UKEYA]
GO

ALTER TABLE [dbo].[CIA] ADD  DEFAULT (' ') FOR [M85_UKEYB]
GO

ALTER TABLE [dbo].[CIA] ADD  DEFAULT ((0)) FOR [ARRAY_1001]
GO

ALTER TABLE [dbo].[CIA] ADD  DEFAULT ((0)) FOR [ARRAY_1018]
GO

ALTER TABLE [dbo].[CIA] ADD  DEFAULT ((0)) FOR [CIA_097_N]
GO

ALTER TABLE [dbo].[CIA] ADD  DEFAULT ((0)) FOR [CIA_098_N]
GO

ALTER TABLE [dbo].[CIA] ADD  DEFAULT ((0)) FOR [CIA_099_N]
GO

ALTER TABLE [dbo].[CIA] ADD  DEFAULT (' ') FOR [CIA_CNX_C]
GO

ALTER TABLE [dbo].[CIA] ADD  DEFAULT ((0)) FOR [ARRAY_098]
GO

ALTER TABLE [dbo].[CIA] ADD  DEFAULT ((0)) FOR [ARRAY_100]
GO

ALTER TABLE [dbo].[CIA] ADD  DEFAULT ((0)) FOR [ARRAY_782]
GO

ALTER TABLE [dbo].[CIA] ADD  DEFAULT ((0)) FOR [ARRAY_791]
GO

ALTER TABLE [dbo].[CIA] ADD  DEFAULT ((0)) FOR [array_ambiente]
GO

ALTER TABLE [dbo].[CIA] ADD  DEFAULT ((0)) FOR [array_contingencia]
GO

ALTER TABLE [dbo].[CIA] ADD  DEFAULT ((0)) FOR [ARRAY_DBO]
GO

ALTER TABLE [dbo].[CIA] ADD  DEFAULT ((0)) FOR [ARRAY_Enquad]
GO

ALTER TABLE [dbo].[CIA] ADD  DEFAULT ((0)) FOR [ARRAY_RegimeTributario]
GO

ALTER TABLE [dbo].[CIA] ADD  DEFAULT ((0)) FOR [ARRAY_VersaoNFe]
GO

ALTER TABLE [dbo].[CIA] ADD  DEFAULT ((0)) FOR [CIA_508_N]
GO

ALTER TABLE [dbo].[CIA] ADD  DEFAULT ((0)) FOR [CIASC_254_N]
GO

ALTER TABLE [dbo].[CIA] ADD  DEFAULT ((0)) FOR [CIASC_255_N]
GO

ALTER TABLE [dbo].[CIA] ADD  DEFAULT ((0)) FOR [CIASC_256_N]
GO

ALTER TABLE [dbo].[CIA] ADD  DEFAULT ((0)) FOR [CIASC_257_N]
GO

ALTER TABLE [dbo].[CIA] ADD  DEFAULT ((0)) FOR [CIASC_258_N]
GO

ALTER TABLE [dbo].[CIA] ADD  DEFAULT ((0)) FOR [CIASC_259_N]
GO

ALTER TABLE [dbo].[CIA] ADD  DEFAULT ((0)) FOR [CIASC_260_N]
GO

ALTER TABLE [dbo].[CIA] ADD  DEFAULT ((0)) FOR [CIASC_261_N]
GO

ALTER TABLE [dbo].[CIA] ADD  DEFAULT ((0)) FOR [CIASC_264_N]
GO

ALTER TABLE [dbo].[CIA] ADD  DEFAULT (' ') FOR [CIASC_262_C]
GO

ALTER TABLE [dbo].[CIA] ADD  DEFAULT (' ') FOR [CIASC_263_C]
GO

ALTER TABLE [dbo].[CIA] ADD  DEFAULT (' ') FOR [CIASC_265_C]
GO

ALTER TABLE [dbo].[CIA] ADD  DEFAULT (' ') FOR [CIASC_266_C]
GO

ALTER TABLE [dbo].[CIA] ADD  DEFAULT (' ') FOR [CIASC_267_C]
GO

ALTER TABLE [dbo].[CIA] ADD  DEFAULT (' ') FOR [CIASC_268_C]
GO

ALTER TABLE [dbo].[CIA] ADD  DEFAULT (' ') FOR [CIASC_269_C]
GO

insert into cia
SELECT [UKEY]
      ,[MYCONTROL]
      ,[SQLCMD]
      ,[STATUS]
      ,[TIMESTAMP]
      ,[A36_CODE]
      ,[USR_NOTE]
      ,[CIA_UKEY]
      ,[ARRAY_030]
      ,[ARRAY_031]
      ,[ARRAY_032]
      ,[ARRAY_034]
      ,[A01_UKEY]
      ,[A22_UKEY]
      ,[A23_UKEY]
      ,[A24_UKEY]
      ,[A25_UKEY]
      ,[A27_UKEY]
      ,[T24_UKEY]
      ,[T60_UKEY]
      ,[CIA_001_C]
      ,[CIA_002_C]
      ,[CIA_003_C]
      ,[CIA_004_C]
      ,[CIA_006_C]
      ,[CIA_007_C]
      ,[CIA_008_C]
      ,[CIA_009_C]
      ,[CIA_010_C]
      ,[CIA_011_C]
      ,[CIA_012_C]
      ,[CIA_013_C]
      ,[CIA_014_N]
      ,[CIA_015_N]
      ,[CIA_016_N]
      ,[CIA_017_C]
      ,[CIA_018_C]
      ,[CIA_019_C]
      ,[CIA_020_C]
      ,[CIA_021_C]
      ,[CIA_022_C]
      ,[CIA_023_C]
      ,[CIA_024_C]
      ,[CIA_025_C]
      ,[CIA_026_C]
      ,[CIA_027_C]
      ,[CIA_028_N]
      ,[CIA_029_N]
      ,[CIA_030_C]
      ,[CIA_031_C]
      ,[CIA_032_C]
      ,[CIA_033_C]
      ,[CIA_034_C]
      ,[CIA_035_N]
      ,[CIA_036_N]
      ,[CIA_037_B]
      ,[CIA_038_N]
      ,[CIA_039_N]
      ,[CIA_040_N]
      ,[CIA_041_C]
      ,[CIA_042_N]
      ,[CIA_043_B]
      ,[CIA_044_B]
      ,[CIA_045_B]
      ,[CIA_046_M]
      ,[CIA_047_M]
      ,[CIA_048_M]
      ,[CIA_049_C]
      ,[CIA_051_D]
      ,[CIA_052_C]
      ,[CIA_053_C]
      ,[CIA_054_C]
      ,[CIA_055_C]
      ,[CIA_056_C]
      ,[CIA_057_M]
      ,[CIA_058_M]
      ,[CIA_059_M]
      ,[CIA_060_M]
      ,[CIA_061_M]
      ,[CIA_062_N]
      ,[CIA_064_C]
      ,[CIA_065_N]
      ,[CIA_067_C]
      ,[CIA_068_C]
      ,[CIA_069_C]
      ,[CIA_070_N]
      ,[CIA_071_N]
      ,[ARRAY_309]
      ,[ARRAY_827]
      ,[ARRAY_828]
      ,[ARRAY_829]
      ,[ARRAY_830]
      ,[CIA_072_N]
      ,[CIA_073_M]
      ,[CIA_074_M]
      ,[CIA_075_N]
      ,[T77_UKEY]
      ,[CIA_076_N]
      ,[CIA_077_M]
      ,[ARRAY_534]
      ,[ARRAY_535]
      ,[CIA_078_M]
      ,[CIA_079_M]
      ,[CIA_080_M]
      ,[CIA_081_N]
      ,[CIA_082_C]
      ,[CIA_083_N]
      ,[CIA_085_C]
      ,[CIA_086_D]
      ,[CIA_087_D]
      ,[CIA_088_C]
      ,[CIA_089_D]
      ,[CIA_090_N]
      ,[CIA_091_C]
      ,[CIA_092_C]
      ,[CIA_093_C]
      ,[CIA_094_C]
      ,[CIA_095_C]
      ,[CIA_096_C]
      ,[CIA_084_N]
      ,[M85_UKEYA]
      ,[M85_UKEYB]
      ,[ARRAY_1001]
      ,[ARRAY_1018]
      ,[CIA_097_N]
      ,[CIA_098_N]
      ,[CIA_099_N]
      ,[CIA_101_M]
      ,[CIA_100_M]
      ,[A36_UKEY]
      ,[CIA_CNX_C]
      ,[ARRAY_098]
      ,[ARRAY_100]
      ,[ARRAY_782]
      ,[ARRAY_791]
      ,[array_ambiente]
      ,[array_contingencia]
      ,[ARRAY_DBO]
      ,[ARRAY_Enquad]
      ,[ARRAY_RegimeTributario]
      ,[ARRAY_VersaoNFe]
      ,[cia_500_m]
      ,[cia_501_m]
      ,[cia_502_m]
      ,[cia_503_m]
      ,[cia_504_m]
      ,[cia_505_m]
      ,[cia_506_m]
      ,[cia_507_m]
      ,[CIA_508_N]
      ,[cia_509_m]
      ,[CIASC_254_N]
      ,[CIASC_255_N]
      ,[CIASC_256_N]
      ,[CIASC_257_N]
      ,[CIASC_258_N]
      ,[CIASC_259_N]
      ,[CIASC_260_N]
      ,[CIASC_261_N]
      ,[CIASC_264_N]
      ,[CIASC_262_C]
      ,[CIASC_263_C]
      ,[CIASC_265_C]
      ,[CIASC_266_C]
      ,[CIASC_267_C]
      ,[CIASC_268_C]
      ,[CIASC_269_C]
      ,[CIASC_270_D]
  FROM [dbo].[CIAold]
GO
