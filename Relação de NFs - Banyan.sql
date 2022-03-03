--Gerar relatório em Excel com os dados do Applications, pegando os dados da tela da Nota Fiscal de Entrada, obedecendo as regras:
 
--Período: 2013 à 2014
--Familia: Cisco BR
--Fornecedor: Banyan
--Itens: Iniciado Por CON- // Terminado Por: -BR
 
--O relatório tem que ter as colunas:
 
---> Numero da NF de Entrada
---> Data de Emissão
---> Item
---> Família
---> Valor


--SELECT * FROM D03 (NOLOCK)  where d03_002_c like 'cisco%'
--SELECT * FROM A08 (NOLOCK) WHERE A08_003_C LIKE 'BANYAN%'

SELECT E10_001_C AS NF, E10_003_D AS EMISSAO, D04_001_C AS ITEM, D03_002_C AS FAMILIA, E11_021_B AS VALOR
FROM E10 (NOLOCK)
INNER JOIN E11 (NOLOCK) ON E11.E10_UKEY = E10.UKEY
INNER JOIN D04 (NOLOCK) ON E11.D04_UKEY = D04.UKEY
INNER JOIN D03 (NOLOCK) ON D04.D03_UKEY = D03.UKEY
WHERE E10_014_D BETWEEN '20130101' AND '20141231' AND D03.UKEY IN ('STAR_STAR__21Y0YACWU','STAR_STAR__21Y0YACWV') AND ((D04.D04_001_C LIKE 'CON%') AND (D04.D04_001_C LIKE '%BR'))
AND E10.A08_UKEY IN ('STAR_4JYM5_2RS0XZSWS','STAR_PSFO7_2E40VC3UU')
ORDER BY E10_003_D, E10_001_C