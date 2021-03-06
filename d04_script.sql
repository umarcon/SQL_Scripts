USE [StarWestcon]
GO
/****** Object:  Table [dbo].[D04]    Script Date: 02/06/2018 16:20:04 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[D04](
	[USR_NOTE] [text] NULL,
	[UKEY] [char](20) NOT NULL DEFAULT (' '),
	[TIMESTAMP] [datetime] NULL,
	[STATUS] [char](10) NOT NULL DEFAULT (' '),
	[SQLCMD] [text] NULL,
	[MYCONTROL] [char](1) NOT NULL DEFAULT (' '),
	[INTEGRATED] [char](26) NOT NULL DEFAULT (' '),
	[CIA_UKEY] [char](5) NOT NULL DEFAULT (' '),
	[A36_CODE0] [char](13) NOT NULL DEFAULT (' '),
	[A36_UKEYA] [char](5) NULL,
	[A36_UKEYB] [char](5) NULL,
	[A36_UKEYC] [char](5) NULL,
	[A36_UKEYD] [char](5) NULL,
	[A36_UKEYE] [char](5) NULL,
	[A36_UKEYF] [char](5) NULL,
	[A36_UKEYG] [char](5) NULL,
	[A36_UKEYH] [char](5) NULL,
	[ARRAY_036] [numeric](3, 0) NOT NULL DEFAULT (0),
	[ARRAY_036A] [numeric](3, 0) NOT NULL DEFAULT (0),
	[ARRAY_036B] [numeric](3, 0) NOT NULL DEFAULT (0),
	[ARRAY_050] [numeric](3, 0) NOT NULL DEFAULT (0),
	[ARRAY_060] [numeric](3, 0) NOT NULL DEFAULT (0),
	[ARRAY_098] [numeric](3, 0) NOT NULL DEFAULT (0),
	[ARRAY_234] [numeric](3, 0) NOT NULL DEFAULT (0),
	[C11_UKEY] [char](20) NULL,
	[D01_UKEY] [char](20) NULL,
	[D02_UKEY] [char](20) NULL,
	[D03_UKEY] [char](20) NULL,
	[D04_002_B] [numeric](28, 6) NOT NULL DEFAULT (0),
	[D04_003_B] [numeric](28, 6) NOT NULL DEFAULT (0),
	[D04_004_B] [numeric](28, 6) NOT NULL DEFAULT (0),
	[D04_005_B] [numeric](28, 6) NOT NULL DEFAULT (0),
	[D04_006_D] [smalldatetime] NULL,
	[D04_007_N] [numeric](1, 0) NOT NULL DEFAULT (0),
	[D04_009_B] [numeric](28, 6) NOT NULL DEFAULT (0),
	[D04_010_B] [numeric](28, 6) NOT NULL DEFAULT (0),
	[D04_011_B] [numeric](28, 6) NOT NULL DEFAULT (0),
	[D04_012_B] [numeric](28, 6) NOT NULL DEFAULT (0),
	[D04_013_N] [numeric](1, 0) NOT NULL DEFAULT (0),
	[D04_014_N] [numeric](1, 0) NOT NULL DEFAULT (0),
	[D04_015_D] [smalldatetime] NULL,
	[D04_016_D] [smalldatetime] NULL,
	[D04_017_N] [numeric](1, 0) NOT NULL DEFAULT (0),
	[D04_018_N] [numeric](1, 0) NOT NULL DEFAULT (0),
	[D04_019_C] [char](30) NOT NULL DEFAULT (' '),
	[D04_020_C] [char](40) NOT NULL DEFAULT (' '),
	[D04_021_B] [numeric](28, 6) NOT NULL DEFAULT (0),
	[D04_022_B] [numeric](28, 6) NOT NULL DEFAULT (0),
	[D04_023_B] [numeric](28, 6) NOT NULL DEFAULT (0),
	[D04_024_B] [numeric](28, 6) NOT NULL DEFAULT (0),
	[D04_025_N] [numeric](1, 0) NOT NULL DEFAULT (0),
	[D04_026_B] [numeric](28, 6) NOT NULL DEFAULT (0),
	[D04_027_C] [char](20) NOT NULL DEFAULT (' '),
	[D04_028_B] [numeric](28, 6) NOT NULL DEFAULT (0),
	[D04_029_B] [numeric](28, 6) NOT NULL DEFAULT (0),
	[D04_030_N] [numeric](3, 0) NOT NULL DEFAULT (0),
	[D04_031_N] [numeric](3, 0) NOT NULL DEFAULT (0),
	[D04_032_M] [text] NULL,
	[D04_033_B] [numeric](28, 6) NOT NULL DEFAULT (0),
	[D04_035_B] [numeric](28, 6) NOT NULL DEFAULT (0),
	[D04_037_N] [numeric](1, 0) NOT NULL DEFAULT (0),
	[D04_038_N] [numeric](1, 0) NOT NULL DEFAULT (0),
	[D04_039_N] [numeric](3, 0) NOT NULL DEFAULT (0),
	[D04_040_B] [numeric](28, 6) NOT NULL DEFAULT (0),
	[D04_041_D] [smalldatetime] NULL,
	[D04_042_N] [numeric](1, 0) NOT NULL DEFAULT (0),
	[D04_043_D] [smalldatetime] NULL,
	[D04_054_D] [smalldatetime] NULL,
	[D04_083_B] [numeric](28, 6) NOT NULL DEFAULT (0),
	[D04_084_N] [numeric](1, 0) NOT NULL DEFAULT (0),
	[D04_085_N] [numeric](1, 0) NOT NULL DEFAULT (0),
	[D04_094_N] [numeric](8, 0) NOT NULL DEFAULT (0),
	[D04_095_B] [numeric](28, 6) NOT NULL DEFAULT (0),
	[D04_100_D] [smalldatetime] NULL,
	[D04_101_M] [text] NULL,
	[D04_154_D] [smalldatetime] NULL,
	[D04_UKEYA] [char](20) NULL,
	[D07_UKEY] [char](20) NULL,
	[D07_UKEY0] [char](20) NULL,
	[D11_UKEY] [char](20) NULL,
	[D16_UKEY] [char](20) NULL,
	[D21_UKEY] [char](20) NULL,
	[D25_UKEY] [char](20) NULL,
	[D30_UKEY] [char](20) NULL,
	[D31_UKEY] [char](20) NULL,
	[T02_UKEY] [char](20) NULL,
	[T02_UKEY1] [char](20) NULL,
	[T02_UKEY2] [char](20) NULL,
	[T05_UKEY] [char](20) NULL,
	[T71_UKEY] [char](20) NULL,
	[D04_055_C] [char](100) NOT NULL DEFAULT (' '),
	[D04_034_C] [char](3) NOT NULL DEFAULT (' '),
	[D04_036_C] [char](20) NOT NULL DEFAULT (' '),
	[D04_044_N] [numeric](1, 0) NOT NULL DEFAULT (0),
	[D04_045_N] [numeric](1, 0) NOT NULL DEFAULT (0),
	[D04_046_C] [char](40) NOT NULL DEFAULT (' '),
	[D49_UKEY] [char](20) NULL,
	[A11_UKEY] [char](20) NULL,
	[A56_UKEY] [char](20) NULL,
	[B11_UKEY] [char](20) NULL,
	[D04_096_C] [char](100) NOT NULL DEFAULT (' '),
	[D04_097_C] [char](15) NOT NULL DEFAULT (' '),
	[D04_098_N] [int] NOT NULL DEFAULT (0),
	[D04_099_B] [numeric](28, 6) NOT NULL DEFAULT (0),
	[D04_102_N] [int] NOT NULL DEFAULT (0),
	[D04_104_B] [numeric](28, 6) NOT NULL DEFAULT (0),
	[D55_UKEY] [char](20) NULL,
	[D56_UKEY] [char](20) NULL,
	[G01_UKEY] [char](20) NULL,
	[G12_UKEY] [char](20) NULL,
	[G13_UKEY] [char](20) NULL,
	[T02_UKEY3] [char](20) NULL,
	[T21_UKEY] [char](20) NULL,
	[T22_UKEY] [char](20) NULL,
	[T23_UKEY] [char](20) NULL,
	[D04_500_C] [char](20) NULL,
	[D04_047_N] [int] NOT NULL DEFAULT (0),
	[D04_200_B] [numeric](28, 6) NOT NULL DEFAULT (0),
	[D04_155_C] [char](60) NOT NULL DEFAULT (' '),
	[D04_156_C] [char](60) NOT NULL DEFAULT (' '),
	[D04_001_C] [char](100) NOT NULL DEFAULT (' '),
	[ARRAY_840] [numeric](2, 0) NOT NULL DEFAULT ((1)),
	[D04_158_C] [char](20) NOT NULL DEFAULT (' '),
	[D04_048_C] [char](9) NOT NULL DEFAULT (' '),
	[D04_049_C] [char](21) NOT NULL DEFAULT (' '),
	[A05_UKEY] [char](20) NULL,
	[A05_UKEYA] [char](20) NULL,
	[D04_157_N] [numeric](1, 0) NOT NULL DEFAULT ((0)),
	[D04_159_B] [numeric](28, 6) NOT NULL DEFAULT ((0)),
	[L52_UKEY] [char](20) NULL,
	[D04_008_C] [char](120) NOT NULL DEFAULT (' '),
	[D04_050_B] [numeric](28, 6) NOT NULL DEFAULT ((0)),
	[ARRAY_897] [numeric](1, 0) NOT NULL DEFAULT ((0)),
	[ARRAY_898] [numeric](1, 0) NOT NULL DEFAULT ((0)),
	[ARRAY_899] [numeric](1, 0) NOT NULL DEFAULT ((0)),
	[ARRAY_930] [numeric](2, 0) NOT NULL DEFAULT ((0)),
	[D04_105_N] [numeric](1, 0) NOT NULL DEFAULT ((0)),
	[D67_UKEY] [char](20) NULL,
	[D68_UKEY] [char](20) NULL,
	[WE97_UKEY] [char](20) NULL,
	[ARRAY_1127] [numeric](1, 0) NOT NULL DEFAULT ((1)),
	[ARRAY_1136] [numeric](2, 0) NOT NULL DEFAULT ((1)),
	[ARRAY_781] [numeric](2, 0) NOT NULL DEFAULT ((1)),
	[ARRAY_792] [numeric](2, 0) NOT NULL DEFAULT ((1)),
	[ARRAY_794] [numeric](2, 0) NOT NULL DEFAULT ((1)),
	[D04_056_N] [numeric](1, 0) NOT NULL DEFAULT ((0)),
	[D04_057_N] [numeric](3, 0) NOT NULL DEFAULT ((0)),
	[D04_058_N] [numeric](1, 0) NOT NULL DEFAULT ((0)),
	[D04_059_N] [numeric](1, 0) NOT NULL DEFAULT ((0)),
	[D04_060_N] [numeric](1, 0) NOT NULL DEFAULT ((0)),
	[D04_061_B] [numeric](19, 2) NOT NULL DEFAULT ((0)),
	[D04_062_N] [numeric](1, 0) NOT NULL DEFAULT ((0)),
	[D04_063_N] [numeric](3, 0) NOT NULL DEFAULT ((0)),
	[D04_160_N] [int] NOT NULL DEFAULT ((0)),
	[D04_161_C] [char](10) NOT NULL DEFAULT (' '),
	[D04_162_D] [smalldatetime] NULL,
	[D04_163_M] [text] NULL,
	[D04_165_C] [char](11) NOT NULL DEFAULT (' '),
	[D04_166_B] [numeric](28, 6) NOT NULL DEFAULT ((0)),
	[D04_167_B] [numeric](28, 6) NOT NULL DEFAULT ((0)),
	[D04_168_B] [numeric](28, 6) NOT NULL DEFAULT ((0)),
	[D04_169_N] [numeric](1, 0) NOT NULL DEFAULT ((0)),
	[D04_103_N] [int] NOT NULL DEFAULT ((1)),
	[D74_UKEY] [char](20) NULL,
	[D73_UKEY] [char](20) NULL,
	[A22_UKEY] [char](20) NULL,
	[D75_UKEY] [char](20) NULL,
	[D75W_UKEY] [char](20) NULL,
	[D04_170_M] [text] NULL,
	[J63_UKEY] [char](20) NULL,
	[O82_UKEY] [char](20) NULL,
	[D04_501_N] [int] NOT NULL DEFAULT ((0)),
	[D04_502_N] [numeric](1, 0) NOT NULL DEFAULT ((0)),
	[D04_503_N] [numeric](1, 0) NOT NULL DEFAULT ((0)),
	[D04_050_N] [numeric](5, 2) NOT NULL DEFAULT ((0)),
	[D04_171_B] [numeric](28, 6) NOT NULL DEFAULT ((0)),
	[D76_UKEY] [char](20) NULL,
	[D78_UKEY] [char](20) NULL,
	[T02_UKEY4] [char](20) NULL,
	[D04_164_N] [numeric](2, 0) NOT NULL DEFAULT ((0)),
 CONSTRAINT [I_D04_10V0N12M6] PRIMARY KEY NONCLUSTERED 
(
	[UKEY] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Index [I_D04_10V0N12LI]    Script Date: 02/06/2018 16:20:05 ******/
CREATE NONCLUSTERED INDEX [I_D04_10V0N12LI] ON [dbo].[D04]
(
	[ARRAY_098] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = ON, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80) ON [PRIMARY]
GO
SET ANSI_PADDING ON

GO
/****** Object:  Index [I_D04_10V0N12LM]    Script Date: 02/06/2018 16:20:05 ******/
CREATE NONCLUSTERED INDEX [I_D04_10V0N12LM] ON [dbo].[D04]
(
	[D03_UKEY] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = ON, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80) ON [PRIMARY]
GO
SET ANSI_PADDING ON

GO
/****** Object:  Index [I_D04_10V0N12LO]    Script Date: 02/06/2018 16:20:05 ******/
CREATE NONCLUSTERED INDEX [I_D04_10V0N12LO] ON [dbo].[D04]
(
	[D04_008_C] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = ON, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80) ON [PRIMARY]
GO
SET ANSI_PADDING ON

GO
/****** Object:  Index [I_D04_10V0N12LP]    Script Date: 02/06/2018 16:20:05 ******/
CREATE NONCLUSTERED INDEX [I_D04_10V0N12LP] ON [dbo].[D04]
(
	[D04_020_C] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = ON, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80) ON [PRIMARY]
GO
/****** Object:  Index [I_D04_10V0N12LQ]    Script Date: 02/06/2018 16:20:05 ******/
CREATE NONCLUSTERED INDEX [I_D04_10V0N12LQ] ON [dbo].[D04]
(
	[D04_039_N] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = ON, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80) ON [PRIMARY]
GO
SET ANSI_PADDING ON

GO
/****** Object:  Index [I_D04_10V0N12LR]    Script Date: 02/06/2018 16:20:05 ******/
CREATE NONCLUSTERED INDEX [I_D04_10V0N12LR] ON [dbo].[D04]
(
	[D04_UKEYA] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = ON, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80) ON [PRIMARY]
GO
SET ANSI_PADDING ON

GO
/****** Object:  Index [I_D04_10V0N12LU]    Script Date: 02/06/2018 16:20:05 ******/
CREATE NONCLUSTERED INDEX [I_D04_10V0N12LU] ON [dbo].[D04]
(
	[D11_UKEY] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = ON, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80) ON [PRIMARY]
GO
SET ANSI_PADDING ON

GO
/****** Object:  Index [I_D04_10V0N12LV]    Script Date: 02/06/2018 16:20:05 ******/
CREATE NONCLUSTERED INDEX [I_D04_10V0N12LV] ON [dbo].[D04]
(
	[D16_UKEY] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = ON, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80) ON [PRIMARY]
GO
SET ANSI_PADDING ON

GO
/****** Object:  Index [I_D04_10V0N12LW]    Script Date: 02/06/2018 16:20:05 ******/
CREATE NONCLUSTERED INDEX [I_D04_10V0N12LW] ON [dbo].[D04]
(
	[D21_UKEY] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = ON, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80) ON [PRIMARY]
GO
SET ANSI_PADDING ON

GO
/****** Object:  Index [I_D04_10V0N12LX]    Script Date: 02/06/2018 16:20:05 ******/
CREATE NONCLUSTERED INDEX [I_D04_10V0N12LX] ON [dbo].[D04]
(
	[D25_UKEY] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = ON, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80) ON [PRIMARY]
GO
SET ANSI_PADDING ON

GO
/****** Object:  Index [I_D04_10V0N12LY]    Script Date: 02/06/2018 16:20:05 ******/
CREATE NONCLUSTERED INDEX [I_D04_10V0N12LY] ON [dbo].[D04]
(
	[D30_UKEY] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = ON, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80) ON [PRIMARY]
GO
SET ANSI_PADDING ON

GO
/****** Object:  Index [I_D04_10V0N12LZ]    Script Date: 02/06/2018 16:20:05 ******/
CREATE NONCLUSTERED INDEX [I_D04_10V0N12LZ] ON [dbo].[D04]
(
	[D31_UKEY] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = ON, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80) ON [PRIMARY]
GO
SET ANSI_PADDING ON

GO
/****** Object:  Index [I_D04_10V0N12M3]    Script Date: 02/06/2018 16:20:05 ******/
CREATE NONCLUSTERED INDEX [I_D04_10V0N12M3] ON [dbo].[D04]
(
	[T05_UKEY] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = ON, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80) ON [PRIMARY]
GO
SET ANSI_PADDING ON

GO
/****** Object:  Index [I_D04_10V0N12M4]    Script Date: 02/06/2018 16:20:05 ******/
CREATE NONCLUSTERED INDEX [I_D04_10V0N12M4] ON [dbo].[D04]
(
	[CIA_UKEY] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = ON, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80) ON [PRIMARY]
GO
/****** Object:  Index [I_D04_10V0N12M5]    Script Date: 02/06/2018 16:20:05 ******/
CREATE NONCLUSTERED INDEX [I_D04_10V0N12M5] ON [dbo].[D04]
(
	[TIMESTAMP] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = ON, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80) ON [PRIMARY]
GO
SET ANSI_PADDING ON

GO
/****** Object:  Index [I_D04_11U0OYXNH]    Script Date: 02/06/2018 16:20:05 ******/
CREATE NONCLUSTERED INDEX [I_D04_11U0OYXNH] ON [dbo].[D04]
(
	[T71_UKEY] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = ON, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80) ON [PRIMARY]
GO
SET ANSI_PADDING ON

GO
/****** Object:  Index [I_D04_1FL0MTKHE]    Script Date: 02/06/2018 16:20:05 ******/
CREATE NONCLUSTERED INDEX [I_D04_1FL0MTKHE] ON [dbo].[D04]
(
	[D04_055_C] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = ON, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80) ON [PRIMARY]
GO
SET ANSI_PADDING ON

GO
/****** Object:  Index [I_D04_1RG0LSHAG]    Script Date: 02/06/2018 16:20:05 ******/
CREATE NONCLUSTERED INDEX [I_D04_1RG0LSHAG] ON [dbo].[D04]
(
	[D04_036_C] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = ON, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80) ON [PRIMARY]
GO
/****** Object:  Index [I_D04_1RG0LSHAI]    Script Date: 02/06/2018 16:20:05 ******/
CREATE NONCLUSTERED INDEX [I_D04_1RG0LSHAI] ON [dbo].[D04]
(
	[D04_044_N] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = ON, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80) ON [PRIMARY]
GO
SET ANSI_PADDING ON

GO
/****** Object:  Index [I_D04_1RG0LSHAJ]    Script Date: 02/06/2018 16:20:05 ******/
CREATE NONCLUSTERED INDEX [I_D04_1RG0LSHAJ] ON [dbo].[D04]
(
	[D04_046_C] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = ON, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80) ON [PRIMARY]
GO
SET ANSI_PADDING ON

GO
/****** Object:  Index [I_D04_1RG0LSHAU]    Script Date: 02/06/2018 16:20:05 ******/
CREATE NONCLUSTERED INDEX [I_D04_1RG0LSHAU] ON [dbo].[D04]
(
	[D49_UKEY] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = ON, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80) ON [PRIMARY]
GO
SET ANSI_PADDING ON

GO
/****** Object:  Index [I_D04_1YU119PKN]    Script Date: 02/06/2018 16:20:05 ******/
CREATE NONCLUSTERED INDEX [I_D04_1YU119PKN] ON [dbo].[D04]
(
	[D55_UKEY] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = ON, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80) ON [PRIMARY]
GO
SET ANSI_PADDING ON

GO
/****** Object:  Index [I_D04_1YU119PKO]    Script Date: 02/06/2018 16:20:05 ******/
CREATE NONCLUSTERED INDEX [I_D04_1YU119PKO] ON [dbo].[D04]
(
	[D56_UKEY] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = ON, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80) ON [PRIMARY]
GO
SET ANSI_PADDING ON

GO
/****** Object:  Index [I_D04_3S51DNJ44]    Script Date: 02/06/2018 16:20:05 ******/
CREATE NONCLUSTERED INDEX [I_D04_3S51DNJ44] ON [dbo].[D04]
(
	[A05_UKEY] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = ON, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80) ON [PRIMARY]
GO
SET ANSI_PADDING ON

GO
/****** Object:  Index [I_D04_3S51DNJ45]    Script Date: 02/06/2018 16:20:05 ******/
CREATE NONCLUSTERED INDEX [I_D04_3S51DNJ45] ON [dbo].[D04]
(
	[A05_UKEYA] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = ON, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80) ON [PRIMARY]
GO
SET ANSI_PADDING ON

GO
/****** Object:  Index [I_D04_46W0160S4]    Script Date: 02/06/2018 16:20:05 ******/
CREATE NONCLUSTERED INDEX [I_D04_46W0160S4] ON [dbo].[D04]
(
	[D04_001_C] ASC,
	[UKEY] ASC,
	[D16_UKEY] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = ON, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80) ON [PRIMARY]
GO
SET ANSI_PADDING ON

GO
/****** Object:  Index [I_D04_4H5126EIS]    Script Date: 02/06/2018 16:20:05 ******/
CREATE NONCLUSTERED INDEX [I_D04_4H5126EIS] ON [dbo].[D04]
(
	[D74_UKEY] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = ON, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80) ON [PRIMARY]
GO
SET ANSI_PADDING ON

GO
/****** Object:  Index [I_D04_55E131SSM]    Script Date: 02/06/2018 16:20:05 ******/
CREATE NONCLUSTERED INDEX [I_D04_55E131SSM] ON [dbo].[D04]
(
	[D76_UKEY] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
