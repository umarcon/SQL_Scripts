SELECT *  FROM (
SELECT   1 AS QUEBRA, 1 AS ORDEM, 'INVOICE' AS TYPE, A03.A03_001_C AS CODIGO, A03.A03_003_C AS DESCRICAO, F12.F12_002_D, RTRIM(F12.F12_001_C)+' - '+RTRIM(F13.F13_001_C) AS F12_001_C, F12.F12_001_C AS TITULO, SPACE(250) AS J07_001_C , 
F13.F13_003_D, CASE WHEN CAST(?VOA_RV9[1] AS INT)
- CAST(F12.F12_002_D AS INT) < 0 THEN 0 ELSE CAST(?VOA_RV9[1] AS INT)- CAST(F12.F12_002_D AS INT) END AS AGING, 
CASE WHEN LTRIM(RTRIM(SUBSTRING(F13.A36_CODE0,1,3))) = 'US$' THEN F13.F13_010_B ELSE 0 END AS AMOUNTDOLAR, CASE WHEN LTRIM(RTRIM(SUBSTRING(F13.A36_CODE0,1,3))) = 'US$' THEN F13.F13_010_B ELSE 0 END AS OPENBALANCEDOLAR, 
CASE WHEN LTRIM(RTRIM(SUBSTRING(F13.A36_CODE0,1,3))) = 'MN' THEN F13.F13_010_B ELSE 0 END AS AMOUNTMN, CASE WHEN LTRIM(RTRIM(SUBSTRING(F13.A36_CODE0,1,3))) = 'MN' THEN F13.F13_010_B ELSE 0 END AS OPENBALANCEMN, 
J10.UKEY , A21.A21_001_C , 
CASE WHEN LTRIM(RTRIM(SUBSTRING(F13.A36_CODE0,1,3))) = 'US$' THEN F13.F13_010_B - ISNULL((SELECT SUM(F15.F15_002_B) FROM STAR_DATA@F15 (NOLOCK) INNER JOIN STAR_DATA@F18 (NOLOCK) ON F18.UKEY = F15.F18_UKEY 
 WHERE F18_004_N = 1 AND F15.F13_UKEY = F13.UKEY AND F15.F15_005_C IN ('002','028','031') AND  F15.F15_004_D <=?VOA_RV9[1]),0) ELSE 0 END AS ABERTODOLAR, 
CASE WHEN LTRIM(RTRIM(SUBSTRING(F13.A36_CODE0,1,3))) = 'MN' THEN F13.F13_010_B - ISNULL((SELECT SUM(F15.F15_002_B) FROM STAR_DATA@F15 (NOLOCK) INNER JOIN STAR_DATA@F18 (NOLOCK) ON F18.UKEY = F15.F18_UKEY 
 WHERE F18_004_N = 1 AND F15.F13_UKEY = F13.UKEY AND F15.F15_005_C IN ('002','028','031') AND  F15.F15_004_D <=?VOA_RV9[1]),0) ELSE 0 END AS ABERTOMN, 0 AS SALDOINI
FROM 
STAR_DATA@F13 (NOLOCK)
INNER JOIN STAR_DATA@F12 (NOLOCK) ON F13.F12_UKEY = F12.UKEY
INNER JOIN STAR_DATA@A03 (NOLOCK) ON F12.F12_UKEYP = A03.UKEY
LEFT JOIN STAR_DATA@J10 (NOLOCK) ON F12.F12_IPAR='J10' AND F12.F12_IUKEYP = J10.UKEY
LEFT JOIN STAR_DATA@A21 (NOLOCK) ON F13.A21_UKEY = A21.UKEY
WHERE F12.F12_PAR = 'A03'  AND F12.F12_016_C = '001'  AND |CLIENTE| AND |NOMEFANTCLI| AND F12.F12_002_D <= ?VOA_RV9[1]
AND 
(F13.F13_010_B -  ISNULL((SELECT SUM(F15.F15_002_B) FROM STAR_DATA@F15 (NOLOCK) WHERE F15.F13_UKEY = F13.UKEY AND F15.F15_005_C IN ('002','028','031') AND F15.F15_004_D <= ?VOA_RV9[1] 
),0) > 0) 

UNION ALL

SELECT 1 AS QUEBRA,2 AS ORDEM, 'PAYMENT' AS TYPE, A03.A03_001_C AS CODIGO, A03.A03_003_C AS DESCRICAO, F18.F18_003_D, F18.F18_001_C,  RTRIM(F12.F12_001_C)+' - '+RTRIM(F13.F13_001_C)  AS TITULO, SPACE(250)  AS DATA, F13.F13_003_D, CASE WHEN CAST(?VOA_RV9[1] AS INT)- CAST(F12.F12_002_D AS INT) < 0 THEN 0 ELSE CAST(?VOA_RV9[1] AS INT)- CAST(F12.F12_002_D AS INT) END AS AGING, 
CASE WHEN LTRIM(RTRIM(SUBSTRING(F15.A36_CODE0,1,3))) = 'US$' THEN F15.F15_013_B * (-1) ELSE 0 END AS AMOUNTDOLAR,  
CASE WHEN LTRIM(RTRIM(SUBSTRING(F15.A36_CODE0,1,3))) = 'US$' THEN F13.F13_010_B -  ISNULL((SELECT SUM(F15A.F15_002_B) FROM STAR_DATA@F15 F15A (NOLOCK) WHERE 
F15A.F13_UKEY = F13.UKEY AND F15A.F15_005_C IN ('002' ) AND F15A.F15_004_D <= F15.F15_004_D  AND F15A.F15_004_D <= '20160101')  ,0) ELSE 0 END AS OPENBALANCEDOLAR, 
CASE WHEN LTRIM(RTRIM(SUBSTRING(F15.A36_CODE0,1,3))) = 'MN' THEN F15.F15_013_B * (-1) ELSE 0 END AS AMOUNTMN,  
CASE WHEN LTRIM(RTRIM(SUBSTRING(F15.A36_CODE0,1,3))) = 'MN' THEN F13.F13_010_B -  ISNULL((SELECT SUM(F15A.F15_002_B) FROM STAR_DATA@F15 F15A (NOLOCK) WHERE 
F15A.F13_UKEY = F13.UKEY AND F15A.F15_005_C IN ('002' ) AND F15A.F15_004_D <= F15.F15_004_D  AND F15A.F15_004_D <= '20160101')  ,0) ELSE 0 END AS OPENBALANCEMN, 
'' AS UKEY, A21.A21_001_C, 0 AS ABERTODOLAR, 0 AS ABERTOMN, 0 AS SALDOINI
FROM 
STAR_DATA@F13 (NOLOCK)
INNER JOIN STAR_DATA@F12 (NOLOCK) ON F13.F12_UKEY = F12.UKEY
INNER JOIN STAR_DATA@F15 (NOLOCK) ON F15.F13_UKEY = F13.UKEY
INNER JOIN STAR_DATA@F18 (NOLOCK) ON F15.F18_UKEY = F18.UKEY
INNER JOIN STAR_DATA@A03 (NOLOCK) ON F12.F12_UKEYP = A03.UKEY
LEFT JOIN STAR_DATA@A21 (NOLOCK) ON F13.A21_UKEY = A21.UKEY
WHERE F18.F18_004_N = 1 AND F12.F12_016_C = '001'  AND F12.F12_PAR = 'A03'  AND F15.F15_004_D <= ?VOA_RV9[1] AND F15.F15_005_C = '002' AND F13.F13_010_B 
-  ISNULL((SELECT SUM(F15.F15_002_B) FROM STAR_DATA@F15 (NOLOCK) INNER JOIN STAR_DATA@F18 (NOLOCK) ON F15.F18_UKEY = F18.UKEY WHERE F18.F18_004_N = 1 AND F15.F13_UKEY = F13.UKEY  AND F15.F15_005_C IN ('002','028','031') AND F15.F15_004_D <= ?VOA_RV9[1] ),0) > 0 
AND |CLIENTE| AND |NOMEFANTCLI| AND F12.F12_002_D <= ?VOA_RV9[1]

UNION ALL

SELECT 1 AS QUEBRA,3 AS ORDEM, 'REVERSAL' AS TYPE, A03.A03_001_C AS CODIGO, A03.A03_003_C AS DESCRICAO, F18.F18_003_D, F18.F18_001_C ,  RTRIM(F12.F12_001_C)+' - '+RTRIM(F13.F13_001_C) AS TITULO, SPACE(250)  AS DATA, F13.F13_003_D, CASE WHEN CAST(?VOA_RV9[1] AS INT)- CAST(F12.F12_002_D AS INT) < 0 THEN 0 ELSE CAST(?VOA_RV9[1] AS INT)
- CAST(F12.F12_002_D AS INT) END AS AGING, 
CASE WHEN LTRIM(RTRIM(SUBSTRING(F15.A36_CODE0,1,3))) = 'US$' THEN F15.F15_013_B * (-1) ELSE 0 END  AS AMOUNTDOLAR, 
CASE WHEN LTRIM(RTRIM(SUBSTRING(F15.A36_CODE0,1,3))) = 'US$' THEN F13.F13_010_B -  ISNULL((SELECT SUM(F15.F15_002_B) FROM STAR_DATA@F15 (NOLOCK) WHERE F15.F13_UKEY = F13.UKEY AND F15.F15_005_C IN ('031','002','028' ) AND F15.F15_004_D <= '20160101'),0) ELSE 0 END AS OPENBALANCEDOLAR,  
CASE WHEN LTRIM(RTRIM(SUBSTRING(F15.A36_CODE0,1,3))) = 'MN' THEN F15.F15_013_B * (-1) ELSE 0 END  AS AMOUNTMN, 
CASE WHEN LTRIM(RTRIM(SUBSTRING(F15.A36_CODE0,1,3))) = 'MN' THEN F13.F13_010_B -  ISNULL((SELECT SUM(F15.F15_002_B) FROM STAR_DATA@F15 (NOLOCK) WHERE F15.F13_UKEY = F13.UKEY AND F15.F15_005_C IN ('031','002','028' ) AND F15.F15_004_D <= '20160101'),0) ELSE 0 END AS OPENBALANCEMN,    
'' AS UKEY, A21.A21_001_C, 0 AS ABERTODOLAR, 0 AS ABERTOMN, 0 AS SALDOINI
FROM 
STAR_DATA@F13 (NOLOCK)
INNER JOIN STAR_DATA@F12 (NOLOCK) ON F13.F12_UKEY = F12.UKEY
INNER JOIN STAR_DATA@F15 (NOLOCK) ON F15.F13_UKEY = F13.UKEY
INNER JOIN STAR_DATA@F18 (NOLOCK) ON F15.F18_UKEY = F18.UKEY
INNER JOIN STAR_DATA@A03 (NOLOCK) ON F12.F12_UKEYP = A03.UKEY
LEFT JOIN STAR_DATA@A21 (NOLOCK) ON F13.A21_UKEY = A21.UKEY
WHERE F12.F12_PAR = 'A03'  AND F15.F15_005_C IN ('031') AND F12.F12_016_C = '001'  AND F13.F13_010_B 
-  ISNULL((SELECT SUM(F15.F15_002_B) FROM STAR_DATA@F15 (NOLOCK) INNER JOIN STAR_DATA@F18 (NOLOCK) ON F15.F18_UKEY = F18.UKEY WHERE F18.F18_004_N = 1 AND F15.F13_UKEY = F13.UKEY AND F15.F15_005_C IN ('002','028','031') AND F15.F15_004_D <= ?VOA_RV9[1]),0) > 0 
AND |CLIENTE| AND |NOMEFANTCLI| AND F18.F18_003_D <= ?VOA_RV9[1]  

UNION ALL

SELECT  2 AS QUEBRA, 4 AS ORDEM , CASE WHEN F15.F15_005_C = '020'  THEN 'ADVANCE PMT'  ELSE 'ADVANCE'  END AS TYPE , A03.A03_001_C AS CODIGO , A03.A03_003_C AS DESCRICAO , F18.F18_003_D , F18.F18_001_C ,  RTRIM(F12.F12_001_C)+' - '+RTRIM(F13.F13_001_C) AS  TITULO , SPACE(250)  AS DATA , F13.F13_003_D , CASE WHEN CAST(?VOA_RV9[1] AS INT) 
- CAST(F12.F12_002_D AS INT) < 0 THEN 0 ELSE CAST(?VOA_RV9[1] AS INT) - CAST(F12.F12_002_D AS INT) END AS AGING , 
IIF(LTRIM(RTRIM(SUBSTRING(F15.A36_CODE0,1,3))) = 'US$',IIF(F15.F15_005_C = '022',(F15.F15_002_B*-1),(F15.F15_002_B*1)),0) AS AMOUNTDOLAR ,  
IIF(LTRIM(RTRIM(SUBSTRING(F15.A36_CODE0,1,3))) = 'US$',IIF(F15.F15_005_C = '022',(F15.F15_002_B*-1),((F13_010_B - F13_029_B - F13_021_B - F13_025_B)*-1)),0) AS OPENBALANCEDOLAR ,
IIF(LTRIM(RTRIM(SUBSTRING(F15.A36_CODE0,1,3))) = 'MN',IIF(F15.F15_005_C = '022',(F15.F15_002_B*-1),(F15.F15_002_B*1)),0) AS AMOUNTMN ,  
IIF(LTRIM(RTRIM(SUBSTRING(F15.A36_CODE0,1,3))) = 'MN',IIF(F15.F15_005_C = '022',(F15.F15_002_B*-1),((F13_010_B - F13_029_B - F13_021_B - F13_025_B)*-1)),0) AS OPENBALANCEMN ,  
'' AS UKEY, A21.A21_001_C  ,
IIF(LTRIM(RTRIM(SUBSTRING(F15.A36_CODE0,1,3))) = 'US$',IIF(F15.F15_005_C = '022',(F13_010_B - ISNULL((SELECT SUM(F15.F15_002_B) FROM F15 (NOLOCK) WHERE F15.F13_UKEY = F13.UKEY AND F15.F15_005_C IN ('020','035') AND F15.F15_004_D <= ?VOA_RV9[1] ),0))*-1, 0),0) AS ABERTODOLAR, 
IIF(LTRIM(RTRIM(SUBSTRING(F15.A36_CODE0,1,3))) = 'MN',IIF(F15.F15_005_C = '022',(F13_010_B - ISNULL((SELECT SUM(F15.F15_002_B) FROM F15 (NOLOCK) WHERE F15.F13_UKEY = F13.UKEY AND F15.F15_005_C IN ('020','035') AND F15.F15_004_D <= ?VOA_RV9[1] ),0))*-1, 0),0) AS ABERTOMN,
0 AS SALDOINI
FROM STAR_DATA@F13 (NOLOCK)
INNER JOIN STAR_DATA@F12 (NOLOCK) ON F13.F12_UKEY = F12.UKEY
INNER JOIN STAR_DATA@A03 (NOLOCK) ON F12.F12_UKEYP = A03.UKEY
INNER JOIN STAR_DATA@F15 (NOLOCK) ON F15.F13_UKEY = F13.UKEY
INNER JOIN STAR_DATA@F18 (NOLOCK) ON F15.F18_UKEY = F18.UKEY
LEFT JOIN STAR_DATA@A21 (NOLOCK) ON F13.A21_UKEY = A21.UKEY
WHERE F12.F12_PAR = 'A03'  AND F12.F12_016_C = '003'  AND ISNULL ((SELECT MAX(F18_004_N) FROM STAR_DATA@F18 (NOLOCK) JOIN STAR_DATA@F15 (NOLOCK) ON F15.F18_UKEY = F18.UKEY WHERE  
F15.F13_UKEY = F13.UKEY AND F15_005_C = '022' AND F18.F18_003_D <= ?VOA_RV9[1] ),0 ) = 1 AND F13.F13_010_B -  ISNULL((SELECT SUM(F15.F15_002_B) FROM STAR_DATA@F15 (NOLOCK) WHERE F15.F13_UKEY = F13.UKEY AND F15.F15_005_C IN ('020','035') AND F15.F15_004_D <= ?VOA_RV9[1]
),0 ) > 0 AND |CLIENTE| AND |NOMEFANTCLI| AND F18.F18_003_D <= ?VOA_RV9[1]  

UNION ALL


SELECT DISTINCT  3 AS QUEBRA, 5 AS ORDEM, CASE WHEN F22_003_C = 'S' THEN 'CHECK ACCT OUT' ELSE 'CHECK ACCT IN' END AS TYPE, A03.A03_001_C AS CODIGO, 
A03.A03_003_C AS DESCRICAO, f22.f22_002_D, 
F19.F19_001_C AS F12_001_C, J10T.J10_001_C AS TITULO , NULL  AS DATA, NULL AS DATA, CASE WHEN CAST(?VOA_RV9[1] AS INT)
- CAST(F22.F22_002_D AS INT) < 0 THEN 0 ELSE CAST(?VOA_RV9[1] AS INT)- CAST(F22.F22_002_D AS INT) END AS AGING,
0 AS AMOUNTDOLAR, 
IIF(LTRIM(RTRIM(SUBSTRING(F22.A36_CODE0,1,3))) = 'US$',IIF(F22.F22_003_C = 'E',F22.F22_005_B,(F22.F22_005_B * - 1)),0)* (-1) AS OPENBALANCEDOLAR,
0 AS AMOUNTMN, 
IIF(LTRIM(RTRIM(SUBSTRING(F22.A36_CODE0,1,3))) = 'MN',IIF(F22.F22_003_C = 'E',F22.F22_005_B,(F22.F22_005_B * - 1)),0)* (-1) AS OPENBALANCEMN,
F18.F18_001_C AS UKEY, J10.J10_001_C AS A21_001_C, 
0 AS ABERTODOLAR, 0 AS ABERTOMN
, CASE WHEN  ?VOA_RV9[1]  <= F19.F19_002_D THEN 0 ELSE  F19.F19_004_B*(-1) END AS SALDOINI
FROM STAR_DATA@F22 (NOLOCK) 
INNER JOIN STAR_DATA@A03 (NOLOCK) ON F22.A03_UKEY = A03.UKEY
INNER JOIN STAR_DATA@F19 (NOLOCK) ON F22.F19_UKEY = F19.UKEY
INNER JOIN STAR_DATA@F18 (NOLOCK) ON F22.F18_UKEY = F18.UKEY
LEFT JOIN STAR_DATA@J10 (NOLOCK) ON F18.F18_DUKEYP = J10.UKEY
LEFT JOIN STAR_DATA@J10 J10T (NOLOCK) ON F18.F18_IUKEYP = J10T.UKEY
WHERE  |CLIENTE| AND |NOMEFANTCLI|  and ISNULL((SELECT SUM(CASE WHEN F22A.F22_003_C = 'E' THEN F22A.F22_005_B ELSE (F22A.F22_005_B * - 1) END ) 
FROM STAR_DATA@F22 F22A (NOLOCK) WHERE F22A.F19_UKEY = F19.UKEY AND F22A.A03_UKEY = A03.UKEY  AND F22A.F22_002_D <=  ?VOA_RV9[1]),0) >0  AND F18.F18_003_D <= ?VOA_RV9[1]  


) AS RESULT

ORDER BY  CODIGO, DESCRICAO, QUEBRA, ORDEM








