
---- H_E10_DOTES

SELECT
SUM(VALR_COMPRA_DEVOL_TRANSF) AS VALR_COMPRA_DEVOL_TRANSF,
SUM(VALR_COMPRA_FORA_EST) AS VALR_COMPRA_FORA_EST,
SUM(VALR_COMPRA_EXTERIOR) AS VALR_COMPRA_EXTERIOR

FROM (
SELECT     SUM(CASE WHEN A28.A28_001_C LIKE '1%' THEN J11_021_B ELSE 0 END ) AS VALR_COMPRA_DEVOL_TRANSF, 
           SUM(CASE WHEN A28.A28_001_C LIKE '2%' THEN J11_021_B ELSE 0 END ) AS VALR_COMPRA_FORA_EST, 
           SUM(CASE WHEN A28.A28_001_C LIKE '3%' THEN J11_021_B ELSE 0 END ) AS VALR_COMPRA_EXTERIOR
                       
FROM       STARWESTCON.DBO.J10 J10 (NOLOCK) 
INNER JOIN STARWESTCON.DBO.J11 J11 (NOLOCK) ON J11.J10_UKEY = J10.UKEY 
INNER JOIN STARWESTCON.DBO.D04 D04 (NOLOCK) ON J11.D04_UKEY = D04.UKEY 
INNER JOIN STARWESTCON.DBO.T05 T05 (NOLOCK) ON T05.UKEY=D04.T05_UKEY 
INNER JOIN STARWESTCON.DBO.A28 A28 (NOLOCK) ON A28.UKEY=J11.A28_UKEY 
WHERE J10.CIA_UKEY = ?VPA_SEEK[3] AND NOT T05.ARRAY_051 IN (4,5,11,12) AND J10_014_D BETWEEN ?VPA_SEEK[1] AND ?VPA_SEEK[2] AND J10_032_N=0 AND 
A28_001_c NOT IN(
'1128','1153','1251','1253','1254','1255','1256','1257','1301','1302','1303','1304','1305','1306','1351','1354','1355','1356','1406','1407','1414','1415','1505','1506','1551','1552','1553','1554','1555','1556','1557','1601','1603','1605','1663','1664','1904','1905','1906','1907','1908','1909','1912','1913','1914','1915','1916','1917','1918','1919','1920','1921','1922','1923','1933','1934',
'2128','2153','2251','2253','2254','2255','2256','2257','2301','2302','2303','2304','2305','2306','2351','2354','2355','2356','2406','2407','2414','2415','2505','2506','2551','2552','2553','2554','2555','2556','2557','2603','2663','2664','2904','2905','2906','2907','2908','2909','2912','2913','2914','2915','2916','2917','2918','2919','2920','2921','2922','2923','2933','2934',
'3128','3251','3301','3351','3354','3355','3356','3551','3553','3556','3930')

union all

SELECT     SUM(CASE WHEN A28.A28_001_C LIKE '1%' THEN E11_021_B ELSE 0 END ) AS VALR_COMPRA_DEVOL_TRANSF, 
           SUM(CASE WHEN A28.A28_001_C LIKE '2%' THEN E11_021_B ELSE 0 END ) AS VALR_COMPRA_FORA_EST, 
           SUM(CASE WHEN A28.A28_001_C LIKE '3%' THEN E11_021_B ELSE 0 END ) AS VALR_COMPRA_EXTERIOR
           
FROM       STARWESTCON.DBO.E10 E10 (NOLOCK) 
INNER JOIN STARWESTCON.DBO.E11 E11 (NOLOCK) ON E11.E10_UKEY = E10.UKEY 
INNER JOIN STARWESTCON.DBO.D04 D04 (NOLOCK) ON E11.D04_UKEY = D04.UKEY 
INNER JOIN STARWESTCON.DBO.T05 T05 (NOLOCK) ON T05.UKEY=D04.T05_UKEY 
INNER JOIN STARWESTCON.DBO.A28 A28 (NOLOCK) ON A28.UKEY=E11.A28_UKEY 
WHERE E10.CIA_UKEY = ?VPA_SEEK[3] AND NOT T05.ARRAY_051 IN (4,5,11,12) AND E10_014_D BETWEEN ?VPA_SEEK[1] AND ?VPA_SEEK[2] AND E10_032_N=0 AND 
A28_001_c NOT IN(
'1128','1153','1251','1253','1254','1255','1256','1257','1301','1302','1303','1304','1305','1306','1351','1354','1355','1356','1406','1407','1414','1415','1505','1506','1551','1552','1553','1554','1555','1556','1557','1601','1603','1605','1663','1664','1904','1905','1906','1907','1908','1909','1912','1913','1914','1915','1916','1917','1918','1919','1920','1921','1922','1923','1933','1934',
'2128','2153','2251','2253','2254','2255','2256','2257','2301','2302','2303','2304','2305','2306','2351','2354','2355','2356','2406','2407','2414','2415','2505','2506','2551','2552','2553','2554','2555','2556','2557','2603','2663','2664','2904','2905','2906','2907','2908','2909','2912','2913','2914','2915','2916','2917','2918','2919','2920','2921','2922','2923','2933','2934',
'3128','3251','3301','3351','3354','3355','3356','3551','3553','3556','3930')
) TMP

