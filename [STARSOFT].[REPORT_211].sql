use [westcon]
go 

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [STARSOFT].[REPORT_211]
	@TipoData as datetime,
	@DataIni as datetime,
	@DataFim as datetime

AS
BEGIN


	select
				e.NomeEmpresa as [Razao Social],
				e.CGC as CNPJ,
				t.NomeTipoEmpresa as [Tipo],
				g.NomeGrupo as [Grupo Econômico],
				g.CustomerID as [Código do Grupo],
				ea.DataCadastro as [Data do cadastro],
				e.DataAtualizacao as [Data de atualização],
				e.NomeAtualizacao [Usuário],
				u.NomeUsuario as [Nome vendedor],
				(SELECT stuff(
				(
				SELECT  NomeDivisao + '; '
				FROM tblUsuarioDivisao ud (NOLOCK)
				INNER JOIN tbldivisao d (NOLOCK) ON ud.CodDivisao = d.CodDivisao
				WHERE ud.CodUsuario = u.CodUsuario And u.CodUsuario = uw.IdUsuario And CodERP = 1
				FOR XML PATH('')),1,0,'')
				)as [Divisão Vendedor],
				case when a03.array_309 = 1 then 'Privada' when A03.array_309 = 2 then 'Pública' else '' end [tipo empresa],
				case when a03.array_795 = 1 then '01 – Retenção por órgãos, autarquias e fundações federais'
					when a03.array_795 = 2 then '02 – Retenção por outras entidades da administração pública federal'
					when a03.array_795 = 3 then '03 – Retenção por pessoas jurídicas de direito privado'
					when a03.array_795 = 4 then '04 – Recolhimento por sociedade cooperativa'
					when a03.array_795 = 5 then '05 – Retenção por fabricante de máquinas e veículos'
					when a03.array_795 = 6 then '99 – Outras retenções'
					else '' end [Retenção na Fonte],
				case when a03.a03_075_n = 1 then 'Sim' when a03.a03_075_n = 0 then 'Não' else '' end [Consumidor Final],
				case when a03.a03ws_003_n = 1 then 'Sim' when a03.a03ws_003_n = 0 then 'Não' else '' end [Revendedor],
				case when a03.a03ws_004_n = 1 then 'Sim' when a03.a03ws_004_n = 0 then 'Não' else '' end [Consumidor CSP],
				case when a03.ARRAY_797WS = 1 then 'Sim' when a03.ARRAY_797WS = 2 then 'Não' else '' end [Partner Portal Cisco],
				a03.a03ws_006_d [Expira em]
				from tblEmpresaRel e (NOLOCK)
				inner join tblGrupoEconomico g (NOLOCK) on e.CustomerID = g.CustomerID
				inner join tblTipoEmpresa t (NOLOCK) on e.CodTipoEmpresa = t.CodTipoEmpresa
				left join tblEmpresaApplication ea (NOLOCK) on e.CGC = ea.CGC and e.CGCDuplicado = ea.CGCDuplicado
				left join wcnUsuarioWestcon uw (NOLOCK) ON Isnull(e.codVendedor,0) = uw.CodVendedor And rTrim(LTrim(e.CodVendedor)) = ''  AND uw.CodVendedor IS NOT NULL
				left join tblUsuario u (NOLOCK) ON uw.IDUsuario = u.CodUsuario
				left join starwestcon.dbo.a03 (nolock) on e.codigo = a03.A03_001_C
				where
				g.CodERP = 1
				and(
			@TipoData = 1 and e.DataAtualizacao > @DataIni and  e.DataAtualizacao < DATEADD (dd, 1, @DataFim) 
			or @TipoData = 1 and ea.DataCadastro >= @DataIni and  ea.DataCadastro < DATEADD (dd, 1, @DataFim)
			)
	order by
		e.DataAtualizacao,
		e.NomeEmpresa
end