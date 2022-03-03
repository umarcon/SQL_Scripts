


/*
12/01/2018 - Ulisses
Alterado para contemplar a atividade PRIME-1395.
Modificação para análise do estado para que, caso seja ES, buscar do valor do novo campo de aliquota

11-09-2018 - Peterson
alterado a declaração da variavel @aliquota de: decimal para decimal(6,2) e o Retorno para decimal(6,2)
estava arrendondando os valores com 2 casas decimais ex: 17.50 estava retornando 18


2015-12-16
Referente a Emenda Constitucional 87/15.
A pedido da Eliana foi alterada a condição de retorno da aliquota por classificação fiscal para a seguinte maneira: 

SE O CLIENTE FOR CONTRIBUINTE, DEVO RETORNAR O CAMPO ALIQUOTA CONTRIBUINTE DA TABELA DE CF CONFORME O ESTADO DE ORIGEM E DESTINO DA VENDA

SE O CLIENTE NÃO FOR CONTRIBUINTE, DEVO CONSIDERAR AS SEGUINTES REGRAS:
	- DEVO RETORNAR O CAMPO ALIQUOTA CONTRIBUINTE DA TABELA DE CF CONFORME O ESTADO DE DESTINO DA VENDA
	- SE NÃO ENCONTRAR NA TABELA DE ICMS DA CF, USAR O ICMS INTERNO DO ESTADO DE DESTINO PADRÃO DA TABELA GERAL


2013-12-18 por ELCruz.
- Juntamente com o Gaucho a pedido da Eliana foi alterada a condição de retorno da aliquota por classificação fiscal para a seguinte maneira:
SE O CLIENTE FOR CONTRIBUINTE, DEVO RETORNAR O CAMPO ALIQUOTA CONTRIBUINTE DA TABELA DE CF CONFORME O ESTADO DE ORIGEM E DESTINO DA VENDA
SE O CLIENTE NÃO FOR CONTRIBUINTE, DEVO CONSIDERAR AS SEGUINTES REGRAS:
- SE ESTADO DE ORIGEM FOR IGUAL AO ESTADO DE DESTINO, USAR CAMPO ICMS CONTRIBUINTE DO ESTADO DE ORIGEM, 
- SE ESTADO DE ORIGEM FOR DIFERENTE DO ESTADO DE DESTINO, USAR O CAMPO ICMS NÃO CONTRIBUINTE DO ESTADO DE ORIGEM
- SE NÃO ENCONTRAR NA TABLA DE ICMS DA CF, USAR O ICMS INTERNO PADRÃO DA TABELA GERAL DO ESTADO DE ORIGEM DA VENDA.

2013-12-09 por ELCruz.
- Juntamente com o Gaucho a pedido da Eliana foi alterada a condição de retorno da aliquota por classificação fiscal para a seguinte maneira:
SE O ESTADO ORIGEM E DESTINO FOREM DIFERENTES E O CLIENTE NÃO FOR CONTRIBUINTE DO ICMS DEVERÁ RETORNAR O CAMPO DE ALIQUOTA NÃO CONTRIBUINTE,
CASO CONTRARIO SERÁ O CAMPO ALIQUOTA CONTRIBUINTE

--Trecho incluido em atendimento a PRIME 1271 em 27/09/2017 por Rui Anderson Santos
Para os não contribuinte a Rotina passou a buscar a aliquota interestadual e fazer uma comparação com a aliquota do destino e retornando nesse cenario a aliquota maior.


*/

/*
	OBSERVACAO: TODA ALTERAÇÃO NA REGRA DE RETORNO DA ALIQUOTA POR CLASSIFICAÇÃO FISCAL, OU SEJA, INFORMAÇÕES DA TABELA WE09, TAMBÉM DEVERÁ SER FEITA 
	NA FUNÇAO [Starsoft].[fnGetAliquotaEspecificaImpostoPorCF], POIS AMBAS DEVEM RETORNAR A MESMA INFORMAÇÃO
*/


alter function [Starsoft].[BR_GetIcms](@UFOrigem varchar(2), @UFDestino varchar(2), @CodPart as varchar(255), @Contribuinte as int, @UsoConsumo as int)
returns decimal(6,2) 
as 
begin 
	declare @Aliquota decimal(6,2)
	declare @VLC_UKEYESTADOORIGEM varchar(20)
	declare @VLC_UKEYESTADODESTINO varchar(20)
	declare @VLC_D16UKEY varchar(20)
	declare @VLN_ICMSINTERESTADUAL decimal(6,2)
	
	

	
	/*ESTADO ORIGEM A23_UKEY*/ 
	/*ESTADO DESTINO A23_UKEY*/ 
	/*ICMS REDUZIDO D18WE_001_N*/ 
	/*CODIGO DE PARTNUMBER @D04_001_C*/

	IF (@Contribuinte = 1)
		begin 
			--buscando ukey do estado de origem --Trecho incluido em atendimento a PRIME 1395 por Ulisses Marcon
			SET @VLC_UKEYESTADOORIGEM = (SELECT UKEY FROM Starwestcon.dbo.A23 WHERE A23_002_C = @UFOrigem)

			--buscando ukey do estado de destino --Trecho incluido em atendimento a PRIME 1395 por Ulisses Marcon
			SET @VLC_UKEYESTADODESTINO = (SELECT UKEY FROM Starwestcon.dbo.A23 WHERE A23_002_C = @UFDestino)

			SELECT 
				@Aliquota = CASE WHEN @VLC_UKEYESTADOORIGEM = 'star_soft_ES' AND @VLC_UKEYESTADODESTINO = 'star_soft_ES' AND @UsoConsumo = 0
					THEN (SELECT A23_500_B FROM STARWESTCON.DBO.A23 (NOLOCK) WHERE UKEY = @VLC_UKEYESTADODESTINO) 
				WHEN D18WE_001_N=1 AND WE09.UKEY IS NOT NULL 
					THEN WE09_001_B
				ELSE 
					(SELECT WE11_001_B FROM Starwestcon.dbo.WE11 (NOLOCK)WHERE RIGHT(RTRIM(WE11.A23_UKEYA),2)=@UFOrigem AND RIGHT(RTRIM(WE11.A23_UKEY),2) = @UFDestino AND A40_UKEY ='STAR_STAR__12C0KW0S8') 
				END 
			FROM Starwestcon.dbo.D04 (NOLOCK) 
				LEFT JOIN Starwestcon.dbo.D16 (NOLOCK) ON D04.D16_UKEY=D16.UKEY 
				LEFT JOIN Starwestcon.dbo.D18 (NOLOCK) ON D18.D18_UKEYP=D16.UKEY AND D18_PAR='D16' AND A40_UKEY = 'STAR_STAR__12C0KW0S8' 
				LEFT JOIN Starwestcon.dbo.WE09 (NOLOCK) ON WE09.D18_UKEY=D18.UKEY AND RIGHT(RTRIM(WE09.A23_UKEYL),2) = @UFOrigem AND RIGHT(RTRIM(WE09.A23_UKEY),2) = @UFDestino 
			WHERE D04_001_C= @CodPart
		end
		
	ELSE
		BEGIN

			--Trecho incluido em atendimento a PRIME 1271 em 27/09/2017 por Rui Anderson Santos
			
			--buscando ukey do estado de origem --Trecho incluido em atendimento a PRIME 1271 em 27/09/2017 por Rui Anderson Santos
			SET @VLC_UKEYESTADOORIGEM = (SELECT UKEY FROM Starwestcon.dbo.A23 WHERE A23_002_C = @UFOrigem)

			--buscando ukey do estado de destino --Trecho incluido em atendimento a PRIME 1271 em 27/09/2017 por Rui Anderson Santos
			SET @VLC_UKEYESTADODESTINO = (SELECT UKEY FROM Starwestcon.dbo.A23 WHERE A23_002_C = @UFDestino)
			
			--BUSCO A CLASSIFICACAO FISCAL DO ITEM --Trecho incluido em atendimento a PRIME 1271 em 27/09/2017 por Rui Anderson Santos
			SELECT 
				@VLC_D16UKEY = D16.UKEY 
			FROM 
			StarWestcon.dbo.D16 D16 (NOLOCK) 
				INNER JOIN StarWestcon.dbo.D04 D04 (NOLOCK) ON D04.D16_UKEY=D16.UKEY 
			WHERE 
				D04.D04_001_C = @CodPart

			--buscando aliquota com base na classificação fiscal do Item --Trecho incluido em atendimento a PRIME 1271 em 27/09/2017 por Rui Anderson Santos
			SET @VLN_ICMSINTERESTADUAL = [Westcon].[StarSoft].[fnGetAliquotaEspecificaImpostoPorCF](@VLC_D16UKEY, @VLC_UKEYESTADOORIGEM, @VLC_UKEYESTADODESTINO, 'ICMS', @Contribuinte)

			--Se não encontrar aliquota pela CF BUSCO A ALIQUOTA PADRAO DE OPERACOES INTERESTADUAIS ENTRE OS ESTADOS DE ORIGEM DA VENDA PARA O ESTADO DO CLIENTE
			--Trecho incluido em atendimento a PRIME 1271 em 27/09/2017 por Rui Anderson Santos
			if(isnull(@VLN_ICMSINTERESTADUAL,-1) = -1)
			SET @VLN_ICMSINTERESTADUAL = [Westcon].[StarSoft].[fnGetAliquotaEspecificaImpostoPorEstadoOrigemDestino](@VLC_UKEYESTADOORIGEM, @VLC_UKEYESTADODESTINO, 'ICMS')

			SELECT 
				@Aliquota = CASE WHEN D18WE_001_N=1 AND WE09.UKEY IS NOT NULL 
					THEN WE09_001_B
				ELSE 
					(SELECT WE11_001_B FROM Starwestcon.dbo.WE11 (NOLOCK)WHERE RIGHT(RTRIM(WE11.A23_UKEYA),2)=@UFDestino AND RIGHT(RTRIM(WE11.A23_UKEY),2) = @UFDestino AND A40_UKEY ='STAR_STAR__12C0KW0S8') 
				END 
			FROM Starwestcon.dbo.D04 (NOLOCK) 
				LEFT JOIN Starwestcon.dbo.D16 (NOLOCK) ON D04.D16_UKEY=D16.UKEY 
				LEFT JOIN Starwestcon.dbo.D18 (NOLOCK) ON D18.D18_UKEYP=D16.UKEY AND D18_PAR='D16' AND A40_UKEY = 'STAR_STAR__12C0KW0S8' 
				LEFT JOIN Starwestcon.dbo.WE09 (NOLOCK) ON WE09.D18_UKEY=D18.UKEY AND RIGHT(RTRIM(WE09.A23_UKEYL),2) = @UFDestino AND RIGHT(RTRIM(WE09.A23_UKEY),2) = @UFDestino 
			WHERE D04_001_C= @CodPart

			--se aliquota interna for menor que aliquota interestadual retorno aliquota interestadual, senão retorna aliquota interna
			--Trecho incluido em atendimento a PRIME 1271 em 27/09/2017 por Rui Anderson Santos
			set @Aliquota = iif(@Aliquota < @VLN_ICMSINTERESTADUAL,@VLN_ICMSINTERESTADUAL,@Aliquota)

		
		/*

			-- Estado de origem igual ao estado de destino, usar o ICMS interno do estado de origem, campo ICMS contribuinte
			IF ( @UFOrigem = @UFDestino)
				SELECT 
					@Aliquota = CASE WHEN D18WE_001_N=1 AND WE09.UKEY IS NOT NULL 
						THEN WE09_001_B
					ELSE 
						(SELECT WE11_001_B FROM Starwestcon.dbo.WE11 (NOLOCK)WHERE RIGHT(RTRIM(WE11.A23_UKEYA),2)=@UFOrigem AND RIGHT(RTRIM(WE11.A23_UKEY),2) = @UFOrigem AND A40_UKEY ='STAR_STAR__12C0KW0S8') 
					END 
				FROM Starwestcon.dbo.D04 (NOLOCK) 
					LEFT JOIN Starwestcon.dbo.D16 (NOLOCK) ON D04.D16_UKEY=D16.UKEY 
					LEFT JOIN Starwestcon.dbo.D18 (NOLOCK) ON D18.D18_UKEYP=D16.UKEY AND D18_PAR='D16' AND A40_UKEY = 'STAR_STAR__12C0KW0S8' 
					LEFT JOIN Starwestcon.dbo.WE09 (NOLOCK) ON WE09.D18_UKEY=D18.UKEY AND RIGHT(RTRIM(WE09.A23_UKEYL),2) = @UFOrigem AND RIGHT(RTRIM(WE09.A23_UKEY),2) = @UFOrigem 
				WHERE D04_001_C= @CodPart		
			ELSE
				-- Estado de origem diferente do estado de destino, usar o ICMS interno do estado de origem, campo ICMS NÃO contribuinte
				SELECT 
					@Aliquota = CASE WHEN D18WE_001_N = 1 AND WE09.UKEY IS NOT NULL 
						THEN WE09_003_B
					ELSE 
						(SELECT WE11_001_B FROM Starwestcon.dbo.WE11 (NOLOCK)WHERE RIGHT(RTRIM(WE11.A23_UKEYA),2)=@UFOrigem AND RIGHT(RTRIM(WE11.A23_UKEY),2) = @UFOrigem AND A40_UKEY ='STAR_STAR__12C0KW0S8') 
					END 
				FROM Starwestcon.dbo.D04 (NOLOCK) 
					LEFT JOIN Starwestcon.dbo.D16 (NOLOCK) ON D04.D16_UKEY=D16.UKEY 
					LEFT JOIN Starwestcon.dbo.D18 (NOLOCK) ON D18.D18_UKEYP=D16.UKEY AND D18_PAR='D16' AND A40_UKEY = 'STAR_STAR__12C0KW0S8' 
					LEFT JOIN Starwestcon.dbo.WE09 (NOLOCK) ON WE09.D18_UKEY=D18.UKEY AND RIGHT(RTRIM(WE09.A23_UKEYL),2) = @UFOrigem AND RIGHT(RTRIM(WE09.A23_UKEY),2) = @UFOrigem 
				WHERE D04_001_C= @CodPart	
				
				*/				
		END

	return @Aliquota

end










