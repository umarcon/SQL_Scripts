SELECT distinct CIA_006_C AS CNPJ_CIA, A03_010_C AS CNPJ_CLI, A03_003_C AS NOME_CLI, A03_037_C AS CONTATO, A03_043_C AS EMAIL, LTRIM(RTRIM(A03_034_C))+LTRIM(RTRIM(A03_035_C)) AS FONE, A03_005_C AS ENDERECO, A03_014_C AS NUMERO, 
A03_004_C AS BAIRRO, A03_006_C AS CEP, A03_158_C AS COMPLEMENTO, A24_001_C AS CIDADE, A23_002_C AS ESTADO, J10_001_C AS NOTA, J10_003_D AS EMISSAO,
F12.F12_013_B AS VALOR,F13_001_C, F13.F13_010_B - F13.F13_029_B - F13.F13_025_B - F13.F13_021_B AS ABERTO, 
CASE WHEN F13_997_D IS NULL THEN F13_003_D ELSE F13_997_D END AS VENCIMENTO, 
CASE WHEN A03.ARRAY_CARTEIRA = 1 THEN 'AMARELO' WHEN A03.ARRAY_CARTEIRA = 2 THEN 'AZUL' ELSE 'VERDE' END AS CART, F13.UKEY AS F13_UKEY
FROM J10 (NOLOCK)
INNER JOIN CIA (NOLOCK) ON J10.CIA_UKEY = CIA.UKEY
INNER JOIN A03 (NOLOCK) ON J10.A03_UKEY = A03.UKEY
LEFT JOIN A23 (NOLOCK) ON A03.A23_UKEY = A23.UKEY
LEFT JOIN A24 (NOLOCK) ON A03.A24_UKEY = A24.UKEY
INNER JOIN F12 (NOLOCK) ON F12.F12_IUKEYP = J10.UKEY
INNER JOIN F13 (NOLOCK) ON F13.F12_UKEY = F12.UKEY
WHERE (F13.F13_010_B - F13.F13_029_B - F13.F13_025_B - F13.F13_021_B) > 0 AND F13WS_014_N = 0 AND ISNULL(F13_997_D,F13_003_D) <= GETDATE()-1 AND A03.ARRAY_CARTEIRA <> 3
AND (F13.F13WS_004_N = 0 OR (F13.F13WS_004_N = 1 AND F13.F13WS_007_D < GETDATE()))

UNION ALL

SELECT distinct CIA_006_C AS CNPJ_CIA, A03_010_C AS CNPJ_CLI, A03_003_C AS NOME_CLI, A03_037_C AS CONTATO, A03_043_C AS EMAIL, LTRIM(RTRIM(A03_034_C))+LTRIM(RTRIM(A03_035_C)) AS FONE, A03_005_C AS ENDERECO, A03_014_C AS NUMERO, 
A03_004_C AS BAIRRO, A03_006_C AS CEP, A03_158_C AS COMPLEMENTO, A24_001_C AS CIDADE, A23_002_C AS ESTADO, J10_001_C AS NOTA, J10_003_D AS EMISSAO,
F12.F12_013_B AS VALOR, F13.F13_001_C, F13.F13_010_B - F13.F13_029_B - F13.F13_025_B - F13.F13_021_B AS ABERTO, 
CASE WHEN F13.F13_997_D IS NULL THEN F13.F13_003_D ELSE F13.F13_997_D END AS VENCIMENTO, 
CASE WHEN A03.ARRAY_CARTEIRA = 1 THEN 'AMARELO' WHEN A03.ARRAY_CARTEIRA = 2 THEN 'AZUL' ELSE 'VERDE' END AS CART, F13.UKEY AS F13_UKEY
FROM J10 (NOLOCK)
INNER JOIN F12 (NOLOCK) ON F12.F12_IUKEYP = J10.UKEY
INNER JOIN F15 (NOLOCK) ON F15.F12_UKEY = F12.UKEY
INNER JOIN F18 (NOLOCK) ON F15.F18_UKEY = F18.UKEY AND F18_002_C = '028'
INNER JOIN F13 (NOLOCK) ON F13.F12_UKEY = F12.UKEY
INNER JOIN CIA (NOLOCK) ON J10.CIA_UKEY = CIA.UKEY
INNER JOIN A03 (NOLOCK) ON J10.A03_UKEY = A03.UKEY
LEFT JOIN A23 (NOLOCK) ON A03.A23_UKEY = A23.UKEY
LEFT JOIN A24 (NOLOCK) ON A03.A24_UKEY = A24.UKEY
WHERE(F13.F13_010_B - F13.F13_029_B - F13.F13_025_B - F13.F13_021_B) > 0 AND F13WS_014_N = 0 AND ISNULL(F13.F13_997_D,F13.F13_003_D) <= GETDATE()-1 AND A03.ARRAY_CARTEIRA <> 3
AND (F13.F13WS_004_N = 0 OR (F13.F13WS_004_N = 1 AND F13.F13WS_007_D < GETDATE()))
ORDER BY CIA_006_C, J10_001_C, J10_003_D