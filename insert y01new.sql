USE [StarWestcon]
GO
/****** Object:  Table [dbo].[y01new]    Script Date: 04/06/2018 17:30:21 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[y01new](
	[USR_NOTE] [text] NULL,
	[UKEY] [char](20) NOT NULL,
	[TIMESTAMP] [datetime] NULL,
	[STATUS] [char](10) NOT NULL,
	[SQLCMD] [text] NULL,
	[MYCONTROL] [char](1) NOT NULL,
	[INTEGRATED] [char](26) NOT NULL,
	[CIA_UKEY] [char](5) NOT NULL,
	[CHKSUM] [numeric](10, 2) NOT NULL,
	[CODE] [char](60) NOT NULL,
	[ENGLISH] [text] NULL,
	[MORE_ENGL] [text] NULL,
	[MORE_INFO] [text] NULL,
	[MORE_PORT] [text] NULL,
	[MORE_SPAN] [text] NULL,
	[OWNER] [char](30) NOT NULL,
	[PORTUGUESE] [text] NULL,
	[PROPERTIES] [text] NULL,
	[SPANISH] [text] NULL,
	[TABLEID] [char](5) NOT NULL,
	[TYPE] [int] NOT NULL,
	[USED_IN] [text] NULL,
	[ARRAY_718] [numeric](2, 0) NOT NULL,
	[FRENCH] [text] NULL,
	[GERMAN] [text] NULL,
	[ITALIAN] [text] NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
INSERT [dbo].[y01new] ([USR_NOTE], [UKEY], [TIMESTAMP], [STATUS], [SQLCMD], [MYCONTROL], [INTEGRATED], [CIA_UKEY], [CHKSUM], [CODE], [ENGLISH], [MORE_ENGL], [MORE_INFO], [MORE_PORT], [MORE_SPAN], [OWNER], [PORTUGUESE], [PROPERTIES], [SPANISH], [TABLEID], [TYPE], [USED_IN], [ARRAY_718], [FRENCH], [GERMAN], [ITALIAN]) VALUES (NULL, N'_53K0YJ7DJ          ', CAST(0x0000A85C0109A76C AS DateTime), N'W         ', NULL, N' ', N'                          ', N'STAR_', CAST(26501.00 AS Numeric(10, 2)), N'msg_valorzerado                                             ', N'The value of the Incoming Note item: @1, is reduced to value zero, the document can not be generated.', N'The value of the Incoming Note item: @1, is reduced to value zero, the document can not be generated.', N'', N'', N'El valor del elemento: @1, de la Nota de Entrada está zerado, no se puede generar el documento.', N'MARCELO TERUO AYABE (STARSOFT)', N'O valor do item: @1, da Nota de Entrada está zerado, não é possível gerar o documento.', N'', N'El valor del elemento: @1, de la Nota de Entrada está zerado, no se puede generar el documento.', N'     ', 2, N'', CAST(1 AS Numeric(2, 0)), NULL, NULL, NULL)
INSERT [dbo].[y01new] ([USR_NOTE], [UKEY], [TIMESTAMP], [STATUS], [SQLCMD], [MYCONTROL], [INTEGRATED], [CIA_UKEY], [CHKSUM], [CODE], [ENGLISH], [MORE_ENGL], [MORE_INFO], [MORE_PORT], [MORE_SPAN], [OWNER], [PORTUGUESE], [PROPERTIES], [SPANISH], [TABLEID], [TYPE], [USED_IN], [ARRAY_718], [FRENCH], [GERMAN], [ITALIAN]) VALUES (NULL, N'_53K0YKKVN          ', CAST(0x0000A85C0109FE24 AS DateTime), N'W         ', NULL, N' ', N'                          ', N'STAR_', CAST(26311.00 AS Numeric(10, 2)), N'valor zerado                                                ', N'Reduced to zero value', N'Reduced to zero value', N'', N'', N'Valor Zerado', N'MARCELO TERUO AYABE (STARSOFT)', N'Valor Zerado', N'', N'Valor Zerado', N'     ', 0, N'', CAST(1 AS Numeric(2, 0)), NULL, NULL, NULL)
INSERT [dbo].[y01new] ([USR_NOTE], [UKEY], [TIMESTAMP], [STATUS], [SQLCMD], [MYCONTROL], [INTEGRATED], [CIA_UKEY], [CHKSUM], [CODE], [ENGLISH], [MORE_ENGL], [MORE_INFO], [MORE_PORT], [MORE_SPAN], [OWNER], [PORTUGUESE], [PROPERTIES], [SPANISH], [TABLEID], [TYPE], [USED_IN], [ARRAY_718], [FRENCH], [GERMAN], [ITALIAN]) VALUES (NULL, N'_53K161PY9          ', CAST(0x0000A85C01437CE4 AS DateTime), N'W         ', NULL, N' ', N'                          ', N'STAR_', CAST(38687.00 AS Numeric(10, 2)), N'um.form.f18_042.call_b06                                    ', N'The request is missing a valid API key. -> ''forbidden''', N'<googleTranslate/>', N'', NULL, N'<googleTranslate/>', N'RUI ANDERSON (STARSOFT)       ', N'Integração Contábil', N'favorite = .t.
module = F
formtype = 3
formgroup = "second"
accessname = um.form.b06
parameter = dotriggers:call_b06', N'The request is missing a valid API key. -> ''forbidden''', N'     ', 13, N'', CAST(1 AS Numeric(2, 0)), NULL, NULL, NULL)
INSERT [dbo].[y01new] ([USR_NOTE], [UKEY], [TIMESTAMP], [STATUS], [SQLCMD], [MYCONTROL], [INTEGRATED], [CIA_UKEY], [CHKSUM], [CODE], [ENGLISH], [MORE_ENGL], [MORE_INFO], [MORE_PORT], [MORE_SPAN], [OWNER], [PORTUGUESE], [PROPERTIES], [SPANISH], [TABLEID], [TYPE], [USED_IN], [ARRAY_718], [FRENCH], [GERMAN], [ITALIAN]) VALUES (NULL, N'_53V0W4783          ', CAST(0x0000A86700F874B0 AS DateTime), N'W         ', NULL, N' ', N'                          ', N'STAR_', CAST(34077.00 AS Numeric(10, 2)), N'aliquota reduzida operacao interna                          ', N'Reduced Tax Internal Operation', N'Reduced Tax Internal Operation', N'', N'', N'Taxa Reduzida Operación Interna', N'MARCELO TERUO AYABE (STARSOFT)', N'Alíquota Reduzida Operação Interna', N'', N'Taxa Reduzida Operación Interna', N'     ', 0, N'', CAST(1 AS Numeric(2, 0)), NULL, NULL, NULL)
INSERT [dbo].[y01new] ([USR_NOTE], [UKEY], [TIMESTAMP], [STATUS], [SQLCMD], [MYCONTROL], [INTEGRATED], [CIA_UKEY], [CHKSUM], [CODE], [ENGLISH], [MORE_ENGL], [MORE_INFO], [MORE_PORT], [MORE_SPAN], [OWNER], [PORTUGUESE], [PROPERTIES], [SPANISH], [TABLEID], [TYPE], [USED_IN], [ARRAY_718], [FRENCH], [GERMAN], [ITALIAN]) VALUES (NULL, N'_5411EPYMJ          ', CAST(0x0000A86D01863624 AS DateTime), N'W         ', NULL, N' ', N'                          ', N'STAR_', CAST(25029.00 AS Numeric(10, 2)), N'msg_debcred                                                 ', N'There is a difference between Debits and Credits!', N'There is a difference between Debits and Credits!', N'', N'', N'Existe diferencia entre Debitos y Creditos!', N'MARCELO TERUO AYABE (STARSOFT)', N'Há uma diferença entre Débitos e Créditos!', N'DialogBoxButtons="OK"
WindowTiTle="atencao"
Icon="!"
DefaultButton=1', N'Existe diferencia entre Debitos y Creditos!', N'     ', 2, N'', CAST(1 AS Numeric(2, 0)), NULL, NULL, NULL)
INSERT [dbo].[y01new] ([USR_NOTE], [UKEY], [TIMESTAMP], [STATUS], [SQLCMD], [MYCONTROL], [INTEGRATED], [CIA_UKEY], [CHKSUM], [CODE], [ENGLISH], [MORE_ENGL], [MORE_INFO], [MORE_PORT], [MORE_SPAN], [OWNER], [PORTUGUESE], [PROPERTIES], [SPANISH], [TABLEID], [TYPE], [USED_IN], [ARRAY_718], [FRENCH], [GERMAN], [ITALIAN]) VALUES (NULL, N'_5461D21AO          ', CAST(0x0000A8720179547C AS DateTime), N'W         ', NULL, N' ', N'                          ', N'STAR_', CAST(8407.00 AS Numeric(10, 2)), N'um.form.y65.y65_add                                         ', N'Additional Information', N'Additional Information', N'', N'', N'Datos Adicionales', N'MARCELO TERUO AYABE (STARSOFT)', N'Dados Adicionais', N'favorite = .t.
module = D
formtype = 3
formgroup = "second"
accessname = um.form.y65_add
parameter = dotriggers:call_y65_add', N'Datos Adicionales', N'     ', 13, N'', CAST(1 AS Numeric(2, 0)), NULL, NULL, NULL)
INSERT [dbo].[y01new] ([USR_NOTE], [UKEY], [TIMESTAMP], [STATUS], [SQLCMD], [MYCONTROL], [INTEGRATED], [CIA_UKEY], [CHKSUM], [CODE], [ENGLISH], [MORE_ENGL], [MORE_INFO], [MORE_PORT], [MORE_SPAN], [OWNER], [PORTUGUESE], [PROPERTIES], [SPANISH], [TABLEID], [TYPE], [USED_IN], [ARRAY_718], [FRENCH], [GERMAN], [ITALIAN]) VALUES (NULL, N'_54H02N5SA          ', CAST(0x0000A87D0014C274 AS DateTime), N'W         ', NULL, N' ', N'                          ', N'STAR_', CAST(55824.00 AS Numeric(10, 2)), N'um.form.f11_003.call_b06                                    ', N'Accounting Integration', N'Accounting Integration', N'', NULL, N'Contabilidad Integración', N'MARCELO TERUO AYABE (STARSOFT)', N'Integração Contábil', N'favorite = .t.
module = F
formtype = 3
formgroup = "second"
accessname = um.form.b06
parameter = dotriggers:call_b06', N'Contabilidad Integración', N'     ', 13, N'', CAST(1 AS Numeric(2, 0)), NULL, NULL, NULL)
INSERT [dbo].[y01new] ([USR_NOTE], [UKEY], [TIMESTAMP], [STATUS], [SQLCMD], [MYCONTROL], [INTEGRATED], [CIA_UKEY], [CHKSUM], [CODE], [ENGLISH], [MORE_ENGL], [MORE_INFO], [MORE_PORT], [MORE_SPAN], [OWNER], [PORTUGUESE], [PROPERTIES], [SPANISH], [TABLEID], [TYPE], [USED_IN], [ARRAY_718], [FRENCH], [GERMAN], [ITALIAN]) VALUES (NULL, N'_54H02RCTC          ', CAST(0x0000A87D001559A0 AS DateTime), N'W         ', NULL, N' ', N'                          ', N'STAR_', CAST(43060.00 AS Numeric(10, 2)), N'usertab_caption_f18_021                                     ', N'Specific', N'Specific', N'', NULL, N'Específicos', N'MARCELO TERUO AYABE (STARSOFT)', N'Específicos', NULL, N'Específicos', N'     ', 0, N'', CAST(1 AS Numeric(2, 0)), NULL, NULL, NULL)
INSERT [dbo].[y01new] ([USR_NOTE], [UKEY], [TIMESTAMP], [STATUS], [SQLCMD], [MYCONTROL], [INTEGRATED], [CIA_UKEY], [CHKSUM], [CODE], [ENGLISH], [MORE_ENGL], [MORE_INFO], [MORE_PORT], [MORE_SPAN], [OWNER], [PORTUGUESE], [PROPERTIES], [SPANISH], [TABLEID], [TYPE], [USED_IN], [ARRAY_718], [FRENCH], [GERMAN], [ITALIAN]) VALUES (NULL, N'_54H02S86P          ', CAST(0x0000A87D001583D0 AS DateTime), N'W         ', NULL, N' ', N'                          ', N'STAR_', CAST(34593.00 AS Numeric(10, 2)), N'numero claims                                               ', N'Número Claims ', N'Número Claims ', N'', NULL, N'Número Claims ', N'MARCELO TERUO AYABE (STARSOFT)', N'Número Claims ', NULL, N'Número Claims ', N'     ', 0, N'', CAST(1 AS Numeric(2, 0)), NULL, NULL, NULL)
INSERT [dbo].[y01new] ([USR_NOTE], [UKEY], [TIMESTAMP], [STATUS], [SQLCMD], [MYCONTROL], [INTEGRATED], [CIA_UKEY], [CHKSUM], [CODE], [ENGLISH], [MORE_ENGL], [MORE_INFO], [MORE_PORT], [MORE_SPAN], [OWNER], [PORTUGUESE], [PROPERTIES], [SPANISH], [TABLEID], [TYPE], [USED_IN], [ARRAY_718], [FRENCH], [GERMAN], [ITALIAN]) VALUES (NULL, N'_54H02T2AW          ', CAST(0x0000A87D0015CB4C AS DateTime), N'W         ', NULL, N' ', N'                          ', N'STAR_', CAST(33065.00 AS Numeric(10, 2)), N'valor claims                                                ', N'Valor Claims', N'Valor Claims', N'', NULL, N'Valor Claims', N'MARCELO TERUO AYABE (STARSOFT)', N'Valor Claims', NULL, N'Valor Claims', N'     ', 0, N'', CAST(1 AS Numeric(2, 0)), NULL, NULL, NULL)
INSERT [dbo].[y01new] ([USR_NOTE], [UKEY], [TIMESTAMP], [STATUS], [SQLCMD], [MYCONTROL], [INTEGRATED], [CIA_UKEY], [CHKSUM], [CODE], [ENGLISH], [MORE_ENGL], [MORE_INFO], [MORE_PORT], [MORE_SPAN], [OWNER], [PORTUGUESE], [PROPERTIES], [SPANISH], [TABLEID], [TYPE], [USED_IN], [ARRAY_718], [FRENCH], [GERMAN], [ITALIAN]) VALUES (NULL, N'_54H02U61G          ', CAST(0x0000A87D00160134 AS DateTime), N'W         ', NULL, N' ', N'                          ', N'STAR_', CAST(36306.00 AS Numeric(10, 2)), N'gera adiantamento a pagar                                   ', N'Gera Adiantamento a Pagar', N'Gera Adiantamento a Pagar', N'', NULL, N'Gera Adiantamento a Pagar', N'MARCELO TERUO AYABE (STARSOFT)', N'Gera Adiantamento a Pagar', NULL, N'Gera Adiantamento a Pagar', N'     ', 0, N'', CAST(1 AS Numeric(2, 0)), NULL, NULL, NULL)
INSERT [dbo].[y01new] ([USR_NOTE], [UKEY], [TIMESTAMP], [STATUS], [SQLCMD], [MYCONTROL], [INTEGRATED], [CIA_UKEY], [CHKSUM], [CODE], [ENGLISH], [MORE_ENGL], [MORE_INFO], [MORE_PORT], [MORE_SPAN], [OWNER], [PORTUGUESE], [PROPERTIES], [SPANISH], [TABLEID], [TYPE], [USED_IN], [ARRAY_718], [FRENCH], [GERMAN], [ITALIAN]) VALUES (NULL, N'_55D0N95M4          ', CAST(0x0000A89D00B305B0 AS DateTime), N'W         ', NULL, N' ', N'                          ', N'STAR_', CAST(34570.00 AS Numeric(10, 2)), N'um.ribbon_vendas.changeinvdchar                             ', N'Remove special characters Signup', N'Remove special characters Signup', N'', NULL, N'Remover caracteres especiais de Cadastro', N'MARCELO TERUO AYABE (STARSOFT)', N'Remover caracteres especiais de Cadastro', N'favorite = .t.
module = J
formtype = 4
formid = 951046
helpid = 951046
formgroup = "second"
accessname = um.form.changeinvdchar
parameter = dotriggers:changeinvdchar', N'Remover caracteres especiais de Cadastro', N'     ', 13, N'', CAST(1 AS Numeric(2, 0)), NULL, NULL, NULL)
INSERT [dbo].[y01new] ([USR_NOTE], [UKEY], [TIMESTAMP], [STATUS], [SQLCMD], [MYCONTROL], [INTEGRATED], [CIA_UKEY], [CHKSUM], [CODE], [ENGLISH], [MORE_ENGL], [MORE_INFO], [MORE_PORT], [MORE_SPAN], [OWNER], [PORTUGUESE], [PROPERTIES], [SPANISH], [TABLEID], [TYPE], [USED_IN], [ARRAY_718], [FRENCH], [GERMAN], [ITALIAN]) VALUES (NULL, N'_55D0NGULX          ', CAST(0x0000A89D00B499FC AS DateTime), N'W         ', NULL, N' ', N'                          ', N'STAR_', CAST(33130.00 AS Numeric(10, 2)), N'um.ribbon_vendas.ta8                                        ', N'Enquadramento IPI', N'Enquadramento IPI', N'', NULL, N'Enquadramento IPI', N'MARCELO TERUO AYABE (STARSOFT)', N'Enquadramento IPI', N'favorite = .t.
formtype = 3
formgroup =second
module = j
accessname = "ta8"
accesssearch = ""
parameter = doform:ta8
formid = 751047
helpid = 751047', N'Enquadramento IPI', N'     ', 13, N'', CAST(1 AS Numeric(2, 0)), NULL, NULL, NULL)
INSERT [dbo].[y01new] ([USR_NOTE], [UKEY], [TIMESTAMP], [STATUS], [SQLCMD], [MYCONTROL], [INTEGRATED], [CIA_UKEY], [CHKSUM], [CODE], [ENGLISH], [MORE_ENGL], [MORE_INFO], [MORE_PORT], [MORE_SPAN], [OWNER], [PORTUGUESE], [PROPERTIES], [SPANISH], [TABLEID], [TYPE], [USED_IN], [ARRAY_718], [FRENCH], [GERMAN], [ITALIAN]) VALUES (NULL, N'_55D0NMQ06          ', CAST(0x0000A89D00B7A9F8 AS DateTime), N'W         ', NULL, N' ', N'                          ', N'STAR_', CAST(22224.00 AS Numeric(10, 2)), N'um.ribbon_livros.ta8                                        ', N'Enquadramento IPI', N'Enquadramento IPI', N'', NULL, N'Enquadramento IPI', N'MARCELO TERUO AYABE (STARSOFT)', N'Enquadramento IPI', N'favorite = .t.
formtype = 3
formgroup = main
module = e
accessname = "ta8"
parameter = doform:ta8
formid = 851046
helpid = 851046
', N'Enquadramento IPI', N'     ', 13, N'', CAST(1 AS Numeric(2, 0)), NULL, NULL, NULL)
INSERT [dbo].[y01new] ([USR_NOTE], [UKEY], [TIMESTAMP], [STATUS], [SQLCMD], [MYCONTROL], [INTEGRATED], [CIA_UKEY], [CHKSUM], [CODE], [ENGLISH], [MORE_ENGL], [MORE_INFO], [MORE_PORT], [MORE_SPAN], [OWNER], [PORTUGUESE], [PROPERTIES], [SPANISH], [TABLEID], [TYPE], [USED_IN], [ARRAY_718], [FRENCH], [GERMAN], [ITALIAN]) VALUES (NULL, N'_53V0W0ZD2          ', CAST(0x0000A8A3011ABF34 AS DateTime), N'W         ', NULL, N' ', N'                          ', N'STAR_', CAST(27112.00 AS Numeric(10, 2)), N'rbnuc.options1.cac_a23                                      ', N'Reduced Tax Internal Operation', N'Reduced Tax Internal Operation', N'', N'', N'Taxa Reduzida Operación Interna', N'ALEXANDRE TORRE (STARSOFT)    ', N'Alíquota Reduzida Operação Interna', N'
<option type="1" 
id="667101" 
parameter = "doform: a23_dadosadicionais"          
icon="" flags="0"             
caption="Complementar"  
begingroup="0"     
descriptiontext=""/>
', N'Taxa Reduzida Operación Interna', N'     ', 13, N'', CAST(1 AS Numeric(2, 0)), NULL, NULL, NULL)
INSERT [dbo].[y01new] ([USR_NOTE], [UKEY], [TIMESTAMP], [STATUS], [SQLCMD], [MYCONTROL], [INTEGRATED], [CIA_UKEY], [CHKSUM], [CODE], [ENGLISH], [MORE_ENGL], [MORE_INFO], [MORE_PORT], [MORE_SPAN], [OWNER], [PORTUGUESE], [PROPERTIES], [SPANISH], [TABLEID], [TYPE], [USED_IN], [ARRAY_718], [FRENCH], [GERMAN], [ITALIAN]) VALUES (NULL, N'20180315TORREK0RF3CS', CAST(0x0000A8A400D3B030 AS DateTime), N'W         ', NULL, N' ', N'                          ', N'MDQJW', CAST(24851.00 AS Numeric(10, 2)), N'visualizacao do log                                         ', N'Log View', NULL, NULL, NULL, NULL, N'ALEXANDRE TORRE (STARSOFT)    ', N'Visualização do Log', NULL, N'Visualización del registro', N'     ', 0, NULL, CAST(3 AS Numeric(2, 0)), NULL, NULL, NULL)
INSERT [dbo].[y01new] ([USR_NOTE], [UKEY], [TIMESTAMP], [STATUS], [SQLCMD], [MYCONTROL], [INTEGRATED], [CIA_UKEY], [CHKSUM], [CODE], [ENGLISH], [MORE_ENGL], [MORE_INFO], [MORE_PORT], [MORE_SPAN], [OWNER], [PORTUGUESE], [PROPERTIES], [SPANISH], [TABLEID], [TYPE], [USED_IN], [ARRAY_718], [FRENCH], [GERMAN], [ITALIAN]) VALUES (NULL, N'20180315TORREK0RK9AA', CAST(0x0000A8A400D4394C AS DateTime), N'W         ', NULL, N' ', N'                          ', N'MDQJW', CAST(5555.00 AS Numeric(10, 2)), N'caminhos nfe                                                ', N'nfe paths', NULL, NULL, NULL, NULL, N'ALEXANDRE TORRE (STARSOFT)    ', N'Caminhos NFE', NULL, N'Caminos NFE', N'     ', 4, NULL, CAST(1 AS Numeric(2, 0)), NULL, NULL, NULL)
INSERT [dbo].[y01new] ([USR_NOTE], [UKEY], [TIMESTAMP], [STATUS], [SQLCMD], [MYCONTROL], [INTEGRATED], [CIA_UKEY], [CHKSUM], [CODE], [ENGLISH], [MORE_ENGL], [MORE_INFO], [MORE_PORT], [MORE_SPAN], [OWNER], [PORTUGUESE], [PROPERTIES], [SPANISH], [TABLEID], [TYPE], [USED_IN], [ARRAY_718], [FRENCH], [GERMAN], [ITALIAN]) VALUES (NULL, N'20180315TORREK0RLZNR', CAST(0x0000A8A400D45FF8 AS DateTime), N'W         ', NULL, N' ', N'                          ', N'MDQJW', CAST(65320.00 AS Numeric(10, 2)), N'parametros nfe                                              ', N'The request is missing a valid API key. -> ''forbidden''', NULL, NULL, NULL, NULL, N'ALEXANDRE TORRE (STARSOFT)    ', N'Parâmetros NFE', NULL, NULL, N'     ', 0, NULL, CAST(3 AS Numeric(2, 0)), NULL, NULL, NULL)
INSERT [dbo].[y01new] ([USR_NOTE], [UKEY], [TIMESTAMP], [STATUS], [SQLCMD], [MYCONTROL], [INTEGRATED], [CIA_UKEY], [CHKSUM], [CODE], [ENGLISH], [MORE_ENGL], [MORE_INFO], [MORE_PORT], [MORE_SPAN], [OWNER], [PORTUGUESE], [PROPERTIES], [SPANISH], [TABLEID], [TYPE], [USED_IN], [ARRAY_718], [FRENCH], [GERMAN], [ITALIAN]) VALUES (NULL, N'20180315TORREK0RN3J3', CAST(0x0000A8A400D49CE8 AS DateTime), N'W         ', NULL, N' ', N'                          ', N'MDQJW', CAST(17608.00 AS Numeric(10, 2)), N'especificos                                                 ', NULL, NULL, NULL, NULL, NULL, N'ALEXANDRE TORRE (STARSOFT)    ', N'Específicos', NULL, NULL, N'     ', 0, NULL, CAST(3 AS Numeric(2, 0)), NULL, NULL, NULL)
INSERT [dbo].[y01new] ([USR_NOTE], [UKEY], [TIMESTAMP], [STATUS], [SQLCMD], [MYCONTROL], [INTEGRATED], [CIA_UKEY], [CHKSUM], [CODE], [ENGLISH], [MORE_ENGL], [MORE_INFO], [MORE_PORT], [MORE_SPAN], [OWNER], [PORTUGUESE], [PROPERTIES], [SPANISH], [TABLEID], [TYPE], [USED_IN], [ARRAY_718], [FRENCH], [GERMAN], [ITALIAN]) VALUES (NULL, N'_5030X07DZ          ', CAST(0x0000A8A400D4B7DC AS DateTime), N'W         ', NULL, N' ', N'                          ', N'STAR_', CAST(26399.00 AS Numeric(10, 2)), N'rbnuc.options1.adm_cia                                      ', N'Entity', N'Entity', N'PRIME - 987', NULL, N'Entity', N'ALEXANDRE TORRE (STARSOFT)    ', N'Entity', N'<option 
type="1" id="00001"  
parameter = "dotriggers:call_cia_log"          
icon="" flags="1"             
caption="visualizacao do log"  
begingroup="0" descriptiontext="" />
<option 
type="1" id="00002" 
parameter = "dotriggers:call_cia_ces"
icon="" flags="1"             
caption="configuracoes de entrada e saida"  
begingroup="0" descriptiontext="" />
<option 
type="1" id="00003"  
parameter = "doform: dadosadicionais"          
icon="" flags="1"             
caption="dadosadicionais"  
begingroup="0" descriptiontext="" />
<option 
type="1" id="00004" 
parameter = "dotriggers:call_sc05_001"          
icon="" flags="1"             
caption="caminhos nfe"  
begingroup="0" descriptiontext="" />
<option 
type="1" id="00005"  
parameter = "dotriggers:call_sc05_002"          
icon="" flags="1"             
caption="parametros nfe"  
begingroup="0" descriptiontext="" />
<option 
type="1" id="00006" 
parameter = "doform:cia_compl"          
icon="" flags="1"             
caption="especificos"  
begingroup="0" descriptiontext="" />', N'Entity', N'     ', 13, N'', CAST(1 AS Numeric(2, 0)), NULL, NULL, NULL)
INSERT [dbo].[y01new] ([USR_NOTE], [UKEY], [TIMESTAMP], [STATUS], [SQLCMD], [MYCONTROL], [INTEGRATED], [CIA_UKEY], [CHKSUM], [CODE], [ENGLISH], [MORE_ENGL], [MORE_INFO], [MORE_PORT], [MORE_SPAN], [OWNER], [PORTUGUESE], [PROPERTIES], [SPANISH], [TABLEID], [TYPE], [USED_IN], [ARRAY_718], [FRENCH], [GERMAN], [ITALIAN]) VALUES (NULL, N'20180316TORREL0OGXBD', CAST(0x0000A8A500C23F58 AS DateTime), N'W         ', NULL, N' ', N'                          ', N'MDQJW', CAST(59981.00 AS Numeric(10, 2)), N'rbnuc.options1.cac_a13                                      ', N'Entity', N'Entity', N'PRIME - 987', NULL, N'Entity', N'ALEXANDRE TORRE (STARSOFT)    ', N'Entity', N'<option 
type="1" id="00001"  
accessname = "um.form.call_a13_viewlog"
parameter = "dotriggers:call_a13_viewlog"
icon="" flags="1"             
caption="visualizacao do log"  
begingroup="0" descriptiontext="" />
<option 
type="1" id="00002" 
accessname = "um.form.a13.call_visualizalogalteracaoa13"
parameter = "dotriggers:call_visualizalogalteracaoa13"
icon="" flags="1"             
caption="logs de alteracao"  
begingroup="0" descriptiontext="" />', N'Entity', N'     ', 13, NULL, CAST(1 AS Numeric(2, 0)), NULL, NULL, NULL)
INSERT [dbo].[y01new] ([USR_NOTE], [UKEY], [TIMESTAMP], [STATUS], [SQLCMD], [MYCONTROL], [INTEGRATED], [CIA_UKEY], [CHKSUM], [CODE], [ENGLISH], [MORE_ENGL], [MORE_INFO], [MORE_PORT], [MORE_SPAN], [OWNER], [PORTUGUESE], [PROPERTIES], [SPANISH], [TABLEID], [TYPE], [USED_IN], [ARRAY_718], [FRENCH], [GERMAN], [ITALIAN]) VALUES (NULL, N'20180316TORREL0PE0FJ', CAST(0x0000A8A500C35190 AS DateTime), N'W         ', NULL, N' ', N'                          ', N'MDQJW', CAST(39073.00 AS Numeric(10, 2)), N'logs de alteracao                                           ', NULL, NULL, NULL, NULL, NULL, N'ALEXANDRE TORRE (STARSOFT)    ', N'LOGs de Alteração', NULL, NULL, N'     ', 0, NULL, CAST(3 AS Numeric(2, 0)), NULL, NULL, NULL)
INSERT [dbo].[y01new] ([USR_NOTE], [UKEY], [TIMESTAMP], [STATUS], [SQLCMD], [MYCONTROL], [INTEGRATED], [CIA_UKEY], [CHKSUM], [CODE], [ENGLISH], [MORE_ENGL], [MORE_INFO], [MORE_PORT], [MORE_SPAN], [OWNER], [PORTUGUESE], [PROPERTIES], [SPANISH], [TABLEID], [TYPE], [USED_IN], [ARRAY_718], [FRENCH], [GERMAN], [ITALIAN]) VALUES (NULL, N'_3TI0TW2BB          ', CAST(0x0000A8A900BDF7A4 AS DateTime), N'W         ', NULL, N' ', N'                          ', N'STAR_', CAST(16063.00 AS Numeric(10, 2)), N'um.form.f11_001.call_logesp                                 ', N'', N'', N'', N'', N'', N'ULISSES SANTANA MARCON        ', N'Visualização do Log', N'favorite = .t.
module = D
formtype = 3
formgroup = "second"
accessname = um.form.call_logesp
parameter = dotriggers:call_logesp', N'', N'     ', 13, N'', CAST(7 AS Numeric(2, 0)), NULL, NULL, NULL)
INSERT [dbo].[y01new] ([USR_NOTE], [UKEY], [TIMESTAMP], [STATUS], [SQLCMD], [MYCONTROL], [INTEGRATED], [CIA_UKEY], [CHKSUM], [CODE], [ENGLISH], [MORE_ENGL], [MORE_INFO], [MORE_PORT], [MORE_SPAN], [OWNER], [PORTUGUESE], [PROPERTIES], [SPANISH], [TABLEID], [TYPE], [USED_IN], [ARRAY_718], [FRENCH], [GERMAN], [ITALIAN]) VALUES (NULL, N'_4LA0WKPUO          ', CAST(0x0000A8A900BE5564 AS DateTime), N'W         ', NULL, N' ', N'                          ', N'STAR_', CAST(28054.00 AS Numeric(10, 2)), N'um.form.f11_001.call_invpdf                                 ', N'', N'<googleTranslate/>', N'', N'', N'<googleTranslate/>', N'ULISSES SANTANA MARCON        ', N'Documento Anexado', N'favorite = .t.
module = D
formtype = 3
formgroup = "second"
accessname = um.form.call_invpdf
parameter = dotriggers:call_invpdf', N'', N'     ', 13, N'', CAST(7 AS Numeric(2, 0)), NULL, NULL, NULL)
INSERT [dbo].[y01new] ([USR_NOTE], [UKEY], [TIMESTAMP], [STATUS], [SQLCMD], [MYCONTROL], [INTEGRATED], [CIA_UKEY], [CHKSUM], [CODE], [ENGLISH], [MORE_ENGL], [MORE_INFO], [MORE_PORT], [MORE_SPAN], [OWNER], [PORTUGUESE], [PROPERTIES], [SPANISH], [TABLEID], [TYPE], [USED_IN], [ARRAY_718], [FRENCH], [GERMAN], [ITALIAN]) VALUES (NULL, N'20180320XFUAEP0OVL5D', CAST(0x0000A8A900BF6544 AS DateTime), N'W         ', NULL, N' ', N'                          ', N'MDQJW', CAST(60785.00 AS Numeric(10, 2)), N'form_f18_026_esp                                            ', N'Retorno de CNAB a pagar (ESPECÍFICA)', N'Retorno de CNAB a receber (ESPECÍFICA)', NULL, NULL, N'Retorno de CNAB a receber (ESPECÍFICA)', N'ULISSES SANTANA MARCON        ', N'Retorno de CNAB a pagar (ESPECÍFICA)', NULL, N'Retorno de CNAB a pagar (ESPECÍFICA)', N'     ', 0, NULL, CAST(3 AS Numeric(2, 0)), NULL, NULL, NULL)
INSERT [dbo].[y01new] ([USR_NOTE], [UKEY], [TIMESTAMP], [STATUS], [SQLCMD], [MYCONTROL], [INTEGRATED], [CIA_UKEY], [CHKSUM], [CODE], [ENGLISH], [MORE_ENGL], [MORE_INFO], [MORE_PORT], [MORE_SPAN], [OWNER], [PORTUGUESE], [PROPERTIES], [SPANISH], [TABLEID], [TYPE], [USED_IN], [ARRAY_718], [FRENCH], [GERMAN], [ITALIAN]) VALUES (NULL, N'_3NM0LZ6DP          ', CAST(0x0000A8A900C4CC14 AS DateTime), N'W         ', NULL, N' ', N'                          ', N'STAR_', CAST(12245.00 AS Numeric(10, 2)), N'um.form.j10.t76                                             ', N'The request is missing a valid API key. -> ''forbidden''', NULL, N'Gestão NFE', N'', NULL, N'ALEXANDRE TORRE (STARSOFT)    ', N'Reenvio de DANFE - Vendas', N'favorite = .t.
module = J
formtype = 3
formgroup = "second"
accessname = um.form.T76
parameter = dotriggers:call_t76_ez001', N'The request is missing a valid API key. -> ''forbidden''', N'     ', 13, N'', CAST(1 AS Numeric(2, 0)), NULL, NULL, NULL)
INSERT [dbo].[y01new] ([USR_NOTE], [UKEY], [TIMESTAMP], [STATUS], [SQLCMD], [MYCONTROL], [INTEGRATED], [CIA_UKEY], [CHKSUM], [CODE], [ENGLISH], [MORE_ENGL], [MORE_INFO], [MORE_PORT], [MORE_SPAN], [OWNER], [PORTUGUESE], [PROPERTIES], [SPANISH], [TABLEID], [TYPE], [USED_IN], [ARRAY_718], [FRENCH], [GERMAN], [ITALIAN]) VALUES (NULL, N'_4MC0ZX69T          ', CAST(0x0000A8A900CABE58 AS DateTime), N'W         ', NULL, N' ', N'                          ', N'0E2PB', CAST(30591.00 AS Numeric(10, 2)), N'um.form.f11_001.call_b06                                    ', N'Accounting Integration', N'Accounting Integration', N'', N'', N'Contabilidad Integración', N'ULISSES SANTANA MARCON        ', N'Integração Contábil', N'favorite = .t.
module = F
formtype = 3
formgroup = "second"
accessname = um.form.b06
parameter = dotriggers:call_b06', N'Contabilidad Integración', N'     ', 13, N'', CAST(7 AS Numeric(2, 0)), NULL, NULL, NULL)
INSERT [dbo].[y01new] ([USR_NOTE], [UKEY], [TIMESTAMP], [STATUS], [SQLCMD], [MYCONTROL], [INTEGRATED], [CIA_UKEY], [CHKSUM], [CODE], [ENGLISH], [MORE_ENGL], [MORE_INFO], [MORE_PORT], [MORE_SPAN], [OWNER], [PORTUGUESE], [PROPERTIES], [SPANISH], [TABLEID], [TYPE], [USED_IN], [ARRAY_718], [FRENCH], [GERMAN], [ITALIAN]) VALUES (NULL, N'20180420XFUAEK0ZQG5A', CAST(0x0000A8C80112EA20 AS DateTime), N'W         ', NULL, N' ', N'                          ', N'MDQJW', CAST(6477.00 AS Numeric(10, 2)), N'transparencia fiscal                                        ', N'The request is missing a valid API key. -> ''forbidden''', NULL, NULL, NULL, NULL, N'ULISSES SANTANA MARCON        ', N'Transparência Fiscal', NULL, N'The request is missing a valid API key. -> ''forbidden''', N'     ', 4, NULL, CAST(1 AS Numeric(2, 0)), NULL, NULL, NULL)
INSERT [dbo].[y01new] ([USR_NOTE], [UKEY], [TIMESTAMP], [STATUS], [SQLCMD], [MYCONTROL], [INTEGRATED], [CIA_UKEY], [CHKSUM], [CODE], [ENGLISH], [MORE_ENGL], [MORE_INFO], [MORE_PORT], [MORE_SPAN], [OWNER], [PORTUGUESE], [PROPERTIES], [SPANISH], [TABLEID], [TYPE], [USED_IN], [ARRAY_718], [FRENCH], [GERMAN], [ITALIAN]) VALUES (NULL, N'20180420XFUAEK0ZSLTU', CAST(0x0000A8C80113490C AS DateTime), N'W         ', NULL, N' ', N'                          ', N'MDQJW', CAST(44088.00 AS Numeric(10, 2)), N'atualiza iva-protocolo                                      ', N'The request is missing a valid API key. -> ''forbidden''', NULL, NULL, NULL, NULL, N'ULISSES SANTANA MARCON        ', N'Atualiza IVA-Protocolo', NULL, N'The request is missing a valid API key. -> ''forbidden''', N'     ', 4, NULL, CAST(1 AS Numeric(2, 0)), NULL, NULL, NULL)
INSERT [dbo].[y01new] ([USR_NOTE], [UKEY], [TIMESTAMP], [STATUS], [SQLCMD], [MYCONTROL], [INTEGRATED], [CIA_UKEY], [CHKSUM], [CODE], [ENGLISH], [MORE_ENGL], [MORE_INFO], [MORE_PORT], [MORE_SPAN], [OWNER], [PORTUGUESE], [PROPERTIES], [SPANISH], [TABLEID], [TYPE], [USED_IN], [ARRAY_718], [FRENCH], [GERMAN], [ITALIAN]) VALUES (NULL, N'20180420XFUAEK0ZT9UE', CAST(0x0000A8C8011370E4 AS DateTime), N'W         ', NULL, N' ', N'                          ', N'MDQJW', CAST(46120.00 AS Numeric(10, 2)), N'atualiza icms interno                                       ', NULL, NULL, NULL, NULL, NULL, N'ULISSES SANTANA MARCON        ', N'Atualiza ICMS Interno', NULL, NULL, N'     ', 4, NULL, CAST(1 AS Numeric(2, 0)), NULL, NULL, NULL)
INSERT [dbo].[y01new] ([USR_NOTE], [UKEY], [TIMESTAMP], [STATUS], [SQLCMD], [MYCONTROL], [INTEGRATED], [CIA_UKEY], [CHKSUM], [CODE], [ENGLISH], [MORE_ENGL], [MORE_INFO], [MORE_PORT], [MORE_SPAN], [OWNER], [PORTUGUESE], [PROPERTIES], [SPANISH], [TABLEID], [TYPE], [USED_IN], [ARRAY_718], [FRENCH], [GERMAN], [ITALIAN]) VALUES (NULL, N'_4YC11MCCB          ', CAST(0x0000A8CB01119FA8 AS DateTime), N'W         ', NULL, N' ', N'                          ', N'STAR_', CAST(37187.00 AS Numeric(10, 2)), N'rbnuc.options1.est_d16                                      ', N'Datos Adicionales', N'Datos Adicionales', N'', NULL, N'Específicos', N'ULISSES SANTANA MARCON        ', N'Dados Complementares', N'
<option type="1" 
id="00001" 
parameter = "dotriggers:call_d16_add"          
icon="" flags="0"             
caption="dadosadicionais"  
begingroup="0"     
descriptiontext=""/>

<option type="1" 
id="00002" 
parameter = "dotriggers:call_d16_esp"          
icon="" flags="0"             
caption="transparencia fiscal"  
begingroup="0"     
descriptiontext=""/>

<option type="1" 
id="00003" 
parameter = "dotriggers:call_d16_iva"          
icon="" flags="0"             
caption="atualiza iva-protocolo"  
begingroup="0"     
descriptiontext=""/>

<option type="1" 
id="00004" 
parameter = "dotriggers:call_d16_wm0a"          
icon="" flags="0"             
caption="atualiza icms interno"  
begingroup="0"     
descriptiontext=""/>', N'Específicos', N'     ', 13, N'', CAST(1 AS Numeric(2, 0)), NULL, NULL, NULL)
INSERT [dbo].[y01new] ([USR_NOTE], [UKEY], [TIMESTAMP], [STATUS], [SQLCMD], [MYCONTROL], [INTEGRATED], [CIA_UKEY], [CHKSUM], [CODE], [ENGLISH], [MORE_ENGL], [MORE_INFO], [MORE_PORT], [MORE_SPAN], [OWNER], [PORTUGUESE], [PROPERTIES], [SPANISH], [TABLEID], [TYPE], [USED_IN], [ARRAY_718], [FRENCH], [GERMAN], [ITALIAN]) VALUES (NULL, N'20180423XFUAEN0ZPP9M', CAST(0x0000A8CB0112B1E0 AS DateTime), N'W         ', NULL, N' ', N'                          ', N'MDQJW', CAST(27101.00 AS Numeric(10, 2)), N'form_d16_esp                                                ', N'The request is missing a valid API key. -> ''forbidden''', NULL, NULL, NULL, NULL, N'ULISSES SANTANA MARCON        ', N'Transparência Fiscal', NULL, N'The request is missing a valid API key. -> ''forbidden''', N'     ', 4, NULL, CAST(1 AS Numeric(2, 0)), NULL, NULL, NULL)
INSERT [dbo].[y01new] ([USR_NOTE], [UKEY], [TIMESTAMP], [STATUS], [SQLCMD], [MYCONTROL], [INTEGRATED], [CIA_UKEY], [CHKSUM], [CODE], [ENGLISH], [MORE_ENGL], [MORE_INFO], [MORE_PORT], [MORE_SPAN], [OWNER], [PORTUGUESE], [PROPERTIES], [SPANISH], [TABLEID], [TYPE], [USED_IN], [ARRAY_718], [FRENCH], [GERMAN], [ITALIAN]) VALUES (NULL, N'20180423XFUAEN0ZQ9IO', CAST(0x0000A8CB0112D3DC AS DateTime), N'W         ', NULL, N' ', N'                          ', N'MDQJW', CAST(19227.00 AS Numeric(10, 2)), N'aliquota importada                                          ', NULL, NULL, NULL, NULL, NULL, N'ULISSES SANTANA MARCON        ', N'Alíquota Importada', NULL, NULL, N'     ', 4, NULL, CAST(1 AS Numeric(2, 0)), NULL, NULL, NULL)
INSERT [dbo].[y01new] ([USR_NOTE], [UKEY], [TIMESTAMP], [STATUS], [SQLCMD], [MYCONTROL], [INTEGRATED], [CIA_UKEY], [CHKSUM], [CODE], [ENGLISH], [MORE_ENGL], [MORE_INFO], [MORE_PORT], [MORE_SPAN], [OWNER], [PORTUGUESE], [PROPERTIES], [SPANISH], [TABLEID], [TYPE], [USED_IN], [ARRAY_718], [FRENCH], [GERMAN], [ITALIAN]) VALUES (NULL, N'20180423XFUAEN0ZSLQU', CAST(0x0000A8CB0115EC0C AS DateTime), N'W         ', NULL, N' ', N'                          ', N'MDQJW', CAST(57424.00 AS Numeric(10, 2)), N'atualizacao incremental                                     ', N'The request is missing a valid API key. -> ''forbidden''', NULL, NULL, NULL, NULL, N'ULISSES SANTANA MARCON        ', N'Atualização Incremental', NULL, N'The request is missing a valid API key. -> ''forbidden''', N'     ', 4, NULL, CAST(1 AS Numeric(2, 0)), NULL, NULL, NULL)
INSERT [dbo].[y01new] ([USR_NOTE], [UKEY], [TIMESTAMP], [STATUS], [SQLCMD], [MYCONTROL], [INTEGRATED], [CIA_UKEY], [CHKSUM], [CODE], [ENGLISH], [MORE_ENGL], [MORE_INFO], [MORE_PORT], [MORE_SPAN], [OWNER], [PORTUGUESE], [PROPERTIES], [SPANISH], [TABLEID], [TYPE], [USED_IN], [ARRAY_718], [FRENCH], [GERMAN], [ITALIAN]) VALUES (NULL, N'20180423XFUAEN0ZT3DT', CAST(0x0000A8CB011E3E84 AS DateTime), N'W         ', NULL, N' ', N'                          ', N'MDQJW', CAST(65535.00 AS Numeric(10, 2)), N'we09 option2                                                ', NULL, NULL, NULL, NULL, NULL, N'ULISSES SANTANA MARCON        ', N'Substituir definições antigas de IVA e de ICMS reduzido', NULL, NULL, N'     ', 4, NULL, CAST(1 AS Numeric(2, 0)), NULL, NULL, NULL)
INSERT [dbo].[y01new] ([USR_NOTE], [UKEY], [TIMESTAMP], [STATUS], [SQLCMD], [MYCONTROL], [INTEGRATED], [CIA_UKEY], [CHKSUM], [CODE], [ENGLISH], [MORE_ENGL], [MORE_INFO], [MORE_PORT], [MORE_SPAN], [OWNER], [PORTUGUESE], [PROPERTIES], [SPANISH], [TABLEID], [TYPE], [USED_IN], [ARRAY_718], [FRENCH], [GERMAN], [ITALIAN]) VALUES (NULL, N'20180424XFUAEO0OWK6S', CAST(0x0000A8CC00C2F754 AS DateTime), N'W         ', NULL, N' ', N'                          ', N'MDQJW', CAST(19557.00 AS Numeric(10, 2)), N'TABLE_JJ03                                                  ', N'The request is missing a valid API key. -> ''forbidden''', NULL, NULL, NULL, NULL, N'ULISSES SANTANA MARCON        ', N'Avalia Faturamento Atualiza', NULL, N'The request is missing a valid API key. -> ''forbidden''', N'     ', 5, NULL, CAST(12 AS Numeric(2, 0)), NULL, NULL, NULL)
INSERT [dbo].[y01new] ([USR_NOTE], [UKEY], [TIMESTAMP], [STATUS], [SQLCMD], [MYCONTROL], [INTEGRATED], [CIA_UKEY], [CHKSUM], [CODE], [ENGLISH], [MORE_ENGL], [MORE_INFO], [MORE_PORT], [MORE_SPAN], [OWNER], [PORTUGUESE], [PROPERTIES], [SPANISH], [TABLEID], [TYPE], [USED_IN], [ARRAY_718], [FRENCH], [GERMAN], [ITALIAN]) VALUES (NULL, N'20180427XFUAER0WKUXL', CAST(0x0000A8CF00FAB414 AS DateTime), N'W         ', NULL, N' ', N'                          ', N'MDQJW', CAST(31826.00 AS Numeric(10, 2)), N'um.form.a54.a54_adicional                                   ', N'The request is missing a valid API key. -> ''forbidden''', NULL, NULL, NULL, NULL, N'ULISSES SANTANA MARCON        ', N'Dados adicionais', N'favorite = .t.
module = D
formtype = 3
formgroup = "second"
accessname = um.form.a54_adicional
parameter = dotriggers:call_a54_adicional', N'The request is missing a valid API key. -> ''forbidden''', N'     ', 4, NULL, CAST(1 AS Numeric(2, 0)), NULL, NULL, NULL)
INSERT [dbo].[y01new] ([USR_NOTE], [UKEY], [TIMESTAMP], [STATUS], [SQLCMD], [MYCONTROL], [INTEGRATED], [CIA_UKEY], [CHKSUM], [CODE], [ENGLISH], [MORE_ENGL], [MORE_INFO], [MORE_PORT], [MORE_SPAN], [OWNER], [PORTUGUESE], [PROPERTIES], [SPANISH], [TABLEID], [TYPE], [USED_IN], [ARRAY_718], [FRENCH], [GERMAN], [ITALIAN]) VALUES (NULL, N'_4BO0NA7DT          ', CAST(0x0000A8D2010EC6C0 AS DateTime), N'W         ', NULL, N' ', N'                          ', N'STAR_', CAST(21216.00 AS Numeric(10, 2)), N'importacao de xml da nf-e para geracao de nf de entrada     ', N'The request is missing a valid API key. -> ''forbidden''', N'<googleTranslate/>', N'', N'', N'<googleTranslate/>', N'ALEXANDRE TORRE (STARSOFT)    ', N'Importação de XML da NF-e para Geração de NF de Entrada - NFe 3.10', N'favorite=.T.  
module = D
formtype = 3
formid = "7099912"
helpid = "7099912"
formgroup  = "main"
acessname = e10_017_new
parameter = doform:e10_017_new', N'The request is missing a valid API key. -> ''forbidden''', N'     ', 13, N'', CAST(1 AS Numeric(2, 0)), NULL, NULL, NULL)
INSERT [dbo].[y01new] ([USR_NOTE], [UKEY], [TIMESTAMP], [STATUS], [SQLCMD], [MYCONTROL], [INTEGRATED], [CIA_UKEY], [CHKSUM], [CODE], [ENGLISH], [MORE_ENGL], [MORE_INFO], [MORE_PORT], [MORE_SPAN], [OWNER], [PORTUGUESE], [PROPERTIES], [SPANISH], [TABLEID], [TYPE], [USED_IN], [ARRAY_718], [FRENCH], [GERMAN], [ITALIAN]) VALUES (NULL, N'_4ZP0W579K          ', CAST(0x0000A8D20127C530 AS DateTime), N'W         ', NULL, N' ', N'                          ', N'STAR_', CAST(22749.00 AS Numeric(10, 2)), N'relacao de titulos a pagar por baixa e tipo de quitacao     ', N'', N'<googleTranslate/>', N'', N'', N'<googleTranslate/>', N'ALEXANDRE TORRE (STARSOFT)    ', N'Relação de Títulos a Pagar por Baixa e Tipo de Quitação (Excel)', NULL, N'', N'     ', 9, N'', CAST(1 AS Numeric(2, 0)), NULL, NULL, NULL)
INSERT [dbo].[y01new] ([USR_NOTE], [UKEY], [TIMESTAMP], [STATUS], [SQLCMD], [MYCONTROL], [INTEGRATED], [CIA_UKEY], [CHKSUM], [CODE], [ENGLISH], [MORE_ENGL], [MORE_INFO], [MORE_PORT], [MORE_SPAN], [OWNER], [PORTUGUESE], [PROPERTIES], [SPANISH], [TABLEID], [TYPE], [USED_IN], [ARRAY_718], [FRENCH], [GERMAN], [ITALIAN]) VALUES (NULL, N'_54H02PBTQ          ', CAST(0x0000A8D30017CA3C AS DateTime), N'W         ', NULL, N' ', N'                          ', N'STAR_', CAST(25235.00 AS Numeric(10, 2)), N'um.form.f18_034.call_b06                                    ', N'Accounting Integration', N'Accounting Integration', N'', NULL, N'Contabilidad Integración', N'ALEXANDRE TORRE (STARSOFT)    ', N'Integração Contábil', N'favorite = .t.
module = F
formtype = 3
formgroup = "second"
accessname = um.form.b06
parameter = dotriggers:call_b06', N'Contabilidad Integración', N'     ', 13, N'', CAST(1 AS Numeric(2, 0)), NULL, NULL, NULL)
INSERT [dbo].[y01new] ([USR_NOTE], [UKEY], [TIMESTAMP], [STATUS], [SQLCMD], [MYCONTROL], [INTEGRATED], [CIA_UKEY], [CHKSUM], [CODE], [ENGLISH], [MORE_ENGL], [MORE_INFO], [MORE_PORT], [MORE_SPAN], [OWNER], [PORTUGUESE], [PROPERTIES], [SPANISH], [TABLEID], [TYPE], [USED_IN], [ARRAY_718], [FRENCH], [GERMAN], [ITALIAN]) VALUES (NULL, N'_4MC0ZZQO7          ', CAST(0x0000A8D401050A2C AS DateTime), N'W         ', NULL, N' ', N'                          ', N'0E2PB', CAST(60359.00 AS Numeric(10, 2)), N'rbnuc.options1.fin_f18_006                                  ', N'Accounting Integration', N'Accounting Integration', N'', N'', N'Contabilidad Integración', N'ULISSES SANTANA MARCON        ', N'Integração Contábil', N'<option 
type="1" id="00001"  
accessname = "um.form.b06"
parameter = "dotriggers:call_b06"
icon="" flags="1"             
caption="integracao contabil" 
begingroup="0" descriptiontext="" />', N'Contabilidad Integración', N'     ', 13, N'', CAST(1 AS Numeric(2, 0)), NULL, NULL, NULL)
INSERT [dbo].[y01new] ([USR_NOTE], [UKEY], [TIMESTAMP], [STATUS], [SQLCMD], [MYCONTROL], [INTEGRATED], [CIA_UKEY], [CHKSUM], [CODE], [ENGLISH], [MORE_ENGL], [MORE_INFO], [MORE_PORT], [MORE_SPAN], [OWNER], [PORTUGUESE], [PROPERTIES], [SPANISH], [TABLEID], [TYPE], [USED_IN], [ARRAY_718], [FRENCH], [GERMAN], [ITALIAN]) VALUES (NULL, N'20180502XFUAEW0XZ0SE', CAST(0x0000A8D401054848 AS DateTime), N'W         ', NULL, N' ', N'                          ', N'MDQJW', CAST(52063.00 AS Numeric(10, 2)), N'integracao contabil                                         ', N'The request is missing a valid API key. -> ''forbidden''', NULL, NULL, NULL, NULL, N'ULISSES SANTANA MARCON        ', N'Integração Contábil', NULL, N'The request is missing a valid API key. -> ''forbidden''', N'     ', 4, NULL, CAST(1 AS Numeric(2, 0)), NULL, NULL, NULL)
INSERT [dbo].[y01new] ([USR_NOTE], [UKEY], [TIMESTAMP], [STATUS], [SQLCMD], [MYCONTROL], [INTEGRATED], [CIA_UKEY], [CHKSUM], [CODE], [ENGLISH], [MORE_ENGL], [MORE_INFO], [MORE_PORT], [MORE_SPAN], [OWNER], [PORTUGUESE], [PROPERTIES], [SPANISH], [TABLEID], [TYPE], [USED_IN], [ARRAY_718], [FRENCH], [GERMAN], [ITALIAN]) VALUES (NULL, N'_4IN0TSKDU          ', CAST(0x0000A8D40117504C AS DateTime), N'W         ', NULL, N' ', N'                          ', N'7MZMQ', CAST(40846.00 AS Numeric(10, 2)), N'rbnuc.options1.cac_a11                                      ', N'', N'<googleTranslate/>', N'', N'', N'<googleTranslate/>', N'ULISSES SANTANA MARCON        ', N'Visualização do LOG', N'<option 
type="1" id="00001"  
accessname = "um.form.a11.call_a11_log"
parameter = "dotriggers:call_a11_log"
icon="" flags="1"             
caption="visualizacao de log"  
begingroup="0" descriptiontext="" />

<option 
type="1" id="00002"  
accessname = "um.form.a11.call_a11_grupo"
parameter = "dotriggers:call_a11_grupo"
icon="" flags="1"             
caption="usertab_caption_a11"  
begingroup="0" descriptiontext="" />', N'', N'     ', 13, N'', CAST(1 AS Numeric(2, 0)), NULL, NULL, NULL)
INSERT [dbo].[y01new] ([USR_NOTE], [UKEY], [TIMESTAMP], [STATUS], [SQLCMD], [MYCONTROL], [INTEGRATED], [CIA_UKEY], [CHKSUM], [CODE], [ENGLISH], [MORE_ENGL], [MORE_INFO], [MORE_PORT], [MORE_SPAN], [OWNER], [PORTUGUESE], [PROPERTIES], [SPANISH], [TABLEID], [TYPE], [USED_IN], [ARRAY_718], [FRENCH], [GERMAN], [ITALIAN]) VALUES (NULL, N'20180503XFUAEX0WO2AU', CAST(0x0000A8D500FB5BA8 AS DateTime), N'W         ', NULL, N' ', N'                          ', N'MDQJW', CAST(36987.00 AS Numeric(10, 2)), N'voa_999ws                                                   ', N'The request is missing a valid API key. -> ''forbidden''
The request is missing a valid API key. -> ''forbidden''
The request is missing a valid API key. -> ''forbidden''
The request is missing a valid API key. -> ''forbidden''', NULL, NULL, NULL, NULL, N'ULISSES SANTANA MARCON        ', N'Cliente
Fornecedor
Estoque
Banco', NULL, N'The request is missing a valid API key. -> ''forbidden''
The request is missing a valid API key. -> ''forbidden''
The request is missing a valid API key. -> ''forbidden''
The request is missing a valid API key. -> ''forbidden''', N'     ', 4, NULL, CAST(1 AS Numeric(2, 0)), NULL, NULL, NULL)
INSERT [dbo].[y01new] ([USR_NOTE], [UKEY], [TIMESTAMP], [STATUS], [SQLCMD], [MYCONTROL], [INTEGRATED], [CIA_UKEY], [CHKSUM], [CODE], [ENGLISH], [MORE_ENGL], [MORE_INFO], [MORE_PORT], [MORE_SPAN], [OWNER], [PORTUGUESE], [PROPERTIES], [SPANISH], [TABLEID], [TYPE], [USED_IN], [ARRAY_718], [FRENCH], [GERMAN], [ITALIAN]) VALUES (NULL, N'20180503XFUAEX0ZESU5', CAST(0x0000A8D501105404 AS DateTime), N'W         ', NULL, N' ', N'                          ', N'MDQJW', CAST(29908.00 AS Numeric(10, 2)), N'form_abertura                                               ', N'The request is missing a valid API key. -> ''forbidden''', NULL, NULL, NULL, NULL, N'ULISSES SANTANA MARCON        ', N'Abertura de Módulos ou Áreas', NULL, N'The request is missing a valid API key. -> ''forbidden''', N'     ', 4, NULL, CAST(1 AS Numeric(2, 0)), NULL, NULL, NULL)
INSERT [dbo].[y01new] ([USR_NOTE], [UKEY], [TIMESTAMP], [STATUS], [SQLCMD], [MYCONTROL], [INTEGRATED], [CIA_UKEY], [CHKSUM], [CODE], [ENGLISH], [MORE_ENGL], [MORE_INFO], [MORE_PORT], [MORE_SPAN], [OWNER], [PORTUGUESE], [PROPERTIES], [SPANISH], [TABLEID], [TYPE], [USED_IN], [ARRAY_718], [FRENCH], [GERMAN], [ITALIAN]) VALUES (NULL, N'20180504XFUAEY142S22', CAST(0x0000A8D601344594 AS DateTime), N'W         ', NULL, N' ', N'                          ', N'MDQJW', CAST(41503.00 AS Numeric(10, 2)), N'msg_1554                                                    ', N'Fill in the amount of the specific rate', NULL, NULL, NULL, NULL, N'ULISSES SANTANA MARCON        ', N'Preencher o valor da taxa especifica', N'DialogBoxButtons="OK"
WindowTiTle="atencao"
Icon="!"
DefaultButton=1', N'Rellenar el valor de la tasa específica', N'     ', 4, NULL, CAST(1 AS Numeric(2, 0)), NULL, NULL, NULL)
INSERT [dbo].[y01new] ([USR_NOTE], [UKEY], [TIMESTAMP], [STATUS], [SQLCMD], [MYCONTROL], [INTEGRATED], [CIA_UKEY], [CHKSUM], [CODE], [ENGLISH], [MORE_ENGL], [MORE_INFO], [MORE_PORT], [MORE_SPAN], [OWNER], [PORTUGUESE], [PROPERTIES], [SPANISH], [TABLEID], [TYPE], [USED_IN], [ARRAY_718], [FRENCH], [GERMAN], [ITALIAN]) VALUES (NULL, N'20180509XFUAE30X37LJ', CAST(0x0000A8E300CCE520 AS DateTime), N'W         ', NULL, N' ', N'                          ', N'MDQJW', CAST(29232.00 AS Numeric(10, 2)), N'msg_infoclas                                                ', N'The request is missing a valid API key. -> ''forbidden''', NULL, NULL, NULL, NULL, N'ULISSES SANTANA MARCON        ', N'Obrigatório informar o classificador.', N'DialogBoxButtons="OK"
WindowTiTle="atencao"
Icon="STOP"
DefaultButton=1', N'The request is missing a valid API key. -> ''forbidden''', N'     ', 4, NULL, CAST(1 AS Numeric(2, 0)), NULL, NULL, NULL)
INSERT [dbo].[y01new] ([USR_NOTE], [UKEY], [TIMESTAMP], [STATUS], [SQLCMD], [MYCONTROL], [INTEGRATED], [CIA_UKEY], [CHKSUM], [CODE], [ENGLISH], [MORE_ENGL], [MORE_INFO], [MORE_PORT], [MORE_SPAN], [OWNER], [PORTUGUESE], [PROPERTIES], [SPANISH], [TABLEID], [TYPE], [USED_IN], [ARRAY_718], [FRENCH], [GERMAN], [ITALIAN]) VALUES (NULL, N'20180517XFUAEB14FD3X', CAST(0x0000A8E30136EF9C AS DateTime), N'W         ', NULL, N' ', N'                          ', N'MDQJW', CAST(37601.00 AS Numeric(10, 2)), N'itens do ativo a depreciar                                  ', N'The request is missing a valid API key. -> ''forbidden''', NULL, NULL, NULL, NULL, N'ULISSES SANTANA MARCON        ', N'Itens do Ativo - A Depreciar', NULL, N'The request is missing a valid API key. -> ''forbidden''', N'     ', 4, NULL, CAST(1 AS Numeric(2, 0)), NULL, NULL, NULL)
INSERT [dbo].[y01new] ([USR_NOTE], [UKEY], [TIMESTAMP], [STATUS], [SQLCMD], [MYCONTROL], [INTEGRATED], [CIA_UKEY], [CHKSUM], [CODE], [ENGLISH], [MORE_ENGL], [MORE_INFO], [MORE_PORT], [MORE_SPAN], [OWNER], [PORTUGUESE], [PROPERTIES], [SPANISH], [TABLEID], [TYPE], [USED_IN], [ARRAY_718], [FRENCH], [GERMAN], [ITALIAN]) VALUES (NULL, N'20180524XFUAEI0V0YES', CAST(0x0000A8EA00F16A58 AS DateTime), N'W         ', NULL, N' ', N'                          ', N'MGVJM', CAST(65535.00 AS Numeric(10, 2)), N'um.ribbon_ativo.call_g02                                    ', NULL, NULL, NULL, NULL, NULL, N'ULISSES SANTANA MARCON        ', N'Cálculo do Ativo', N'favorite=.T.  
module = G
formtype = 3
formid = 196213
helpid = 194213
formgroup  = main
acessname = um.ribbon_ativo.call_g02
parameter = dotriggers:call_g02', NULL, N'     ', 4, NULL, CAST(1 AS Numeric(2, 0)), NULL, NULL, NULL)
