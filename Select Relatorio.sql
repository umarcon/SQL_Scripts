SELECT  CASE J10.ARRAY_005 WHEN 1 THEN 'CIF' WHEN 2 THEN 'FOB' WHEN 3 THEN 'EXW' WHEN 4 THEN 'FCA' WHEN 5 THEN 'FAS' WHEN 6 THEN 'CFR' WHEN 7 THEN 'CPT' WHEN 8 THEN 'CIP' WHEN 9 THEN 'DAF' WHEN 10 THEN 'DES' WHEN 11 THEN 'DEQ' WHEN 12 THEN 'DDU' 
	WHEN 13 THEN 'DDP' WHEN 14 THEN 'DAT' WHEN 15 THEN 'DAP' END AS "TIPO_FRETE",
J10.USR_NOTE AS 'J10_NOTE',J11.J11_006_B, 
ISNULL((SELECT SUM(J22A.J22_004_B) AS 'J22_004_B' 
		FROM J22 J22A (NOLOCK) 
		INNER JOIN A40 A40A (NOLOCK) ON J22A.A40_UKEY = A40A.UKEY 
		INNER JOIN J11 J11A (NOLOCK) ON J22A.J22_UKEYP = J11A.UKEY WHERE J11A.J10_UKEY = J10.UKEY), 0) AS 'J22_004_B', 
CIA.USR_NOTE AS 'CIA_NOTE', A06.A06_001_C, A06.A06_002_C, A24_C.A24_001_C AS CIDADE1,A22_C.A22_001_C AS PAIS1, A23_C.A23_002_C AS ESTADO1, T04.T04_002_C, 
(SELECT J07A.ARRAY_005 FROM J07 J07A (NOLOCK) WHERE J07A.UKEY = (SELECT J08.J07_UKEY FROM J08 WHERE J08.UKEY = J11.J11_UKEYP)) AS ARRAY_005, J10.ARRAY_005 AS ARRAY_005I,
(SELECT J07A.J07_001_C FROM J07 J07A (NOLOCK) WHERE J07A.UKEY = (SELECT J08.J07_UKEY FROM J08 WHERE J08.UKEY = J11.J11_UKEYP)) AS J07_001_C, J11.D07_UKEY, J11.UKEY AS UKEY1, D04.UKEY AS UKEYD04, J11.T06_UKEY, J11.J11_998_C, J11.J11_037_B,  J11.J11_040_B, 
J11.J11_003_B,  J11.J11_005_B, J11.ARRAY_114, J10.UKEY,J10.UKEY AS 'J10_UKEY', J10.A36_CODE AS  'MOEDA' ,J10.ARRAY_005, J10.J10_001_C, J10.J10_002_N, J10.USR_NOTE, J11.USR_NOTE AS COMENT, J10.J10_005_M, J10.J10_011_B,  J10.J10_012_B, J10.J10_030_N,  
J10.J10_031_C, J10.J10_003_D, J10.J10_014_D, J09.J09_001_C, D16.D16_001_C, D16.D16_003_C, A03.A03_003_C, A03.A03_010_C, A03.ARRAY_009, A03.A03_005_C, A03.A03_004_C, A03.A03_006_C,A03_037_C,  A03.A03_035_C, A03.A03_011_C, A03.A03_012_C, A28.A28_002_C, 
A28.A28_001_C, D04.D04_001_C, D04.ARRAY_050, D04.D04_008_C, A24.A24_001_C AS CIDADE, A23.A23_002_C AS ESTADO, A24_A.A24_001_C AS CIDTRANS, A23.A23_004_C, A23.A23_011_C, A23_A.A23_002_C AS ESTTRANS, A14.A14_003_C, A14.A14_002_C, A14.A14_011_C, A14.A14_005_C, 
A14.ARRAY_009 AS TIPTRANS, A14.A14_010_C, A15.A15_005_C, T02.T02_002_C,A03.A03_034_C, A03.A03_037_c AS CONTATO, CIA.CIA_025_C,CIA_006_C,CIA.CIA_069_C, (SELECT COUNT(J11A.UKEY) FROM J11 J11A (NOLOCK) WHERE J11A.J10_UKEY = J10.UKEY)  REGPAGE, A13.A13_001_C, 
J10.J10_006_D, A33.A33_002_C,  A06.USR_NOTE AS EMPRESAENTREGA, A24.A24_001_C, A23.A23_002_C, A22.A22_001_C AS PAIS, A10.A10_001_C AS CONTATOENTREGA, A10_010A_C AS TELCONTATO, A06.A06_003_C AS ZIPCODEENTREGA,  A03.A03_006_C AS ZIPCODE    
,SPACE(300) AS 'numero_serie', SPACE(1000) AS 'comentario_capa',
(SELECT J05_004_B FROM J05 (NOLOCK) WHERE J05_UKEYP = J10.UKEY AND J05_PAR='J10' AND J05_001_C='00001') AS VALOR_1, (select J05_004_B from J05 (NOLOCK) WHERE J05_UKEYP = J10.UKEY AND J05_PAR='J10' AND J05_001_C='00002') AS VALOR_2,
(select J05_003_D from J05 (NOLOCK) WHERE J05_UKEYP = J10.UKEY AND J05_PAR='J10' AND J05_001_C='00001') AS VENC_1, (select J05_003_D from J05 (NOLOCK) WHERE J05_UKEYP = J10.UKEY AND J05_PAR='J10' AND J05_001_C='00002') AS VENC_2
,SUBSTRING(J10.A36_CODE,1,3)AS MOEDA, (SELECT SUM(j11_003_b*j11_005_b) FROM j11 j11A (NOLOCK) INNER JOIN J10 J10A ON J11A.J10_UKEY=J10A.UKEY WHERE J10A.UKEY=J10.UKEY) AS TOTAL_ITEM
FROM J11 (NOLOCK)     
INNER JOIN J10 (NOLOCK) ON J11.J10_UKEY = J10.UKEY     
LEFT OUTER JOIN T04 (NOLOCK) ON J11.T04_UKEY = T04.UKEY     
LEFT OUTER JOIN D16 (NOLOCK) ON J11.D16_UKEY = D16.UKEY     
INNER JOIN A03 (NOLOCK) ON J10.J10_PAR = 'A03' AND J10.J10_UKEYP = A03.UKEY     
LEFT OUTER JOIN A24 (NOLOCK) ON A03.A24_UKEY = A24.UKEY     
LEFT OUTER JOIN A23 (NOLOCK) ON A03.A23_UKEY = A23.UKEY     
LEFT OUTER JOIN A22 A22  (NOLOCK) ON A23.A22_UKEY = A22.UKEY       
LEFT JOIN J09 (NOLOCK) ON J10.J09_UKEY = J09.UKEY     
INNER JOIN D04 (NOLOCK) ON J11.D04_UKEY = D04.UKEY     
LEFT OUTER JOIN A28 (NOLOCK) ON J11.A28_UKEY = A28.UKEY     
LEFT OUTER JOIN A14 (NOLOCK) ON J10.A14_UKEY0 = A14.UKEY     
LEFT OUTER JOIN A24 A24_A (NOLOCK) ON A14.A24_UKEY = A24_A.UKEY     
LEFT OUTER JOIN A23 A23_A (NOLOCK) ON A14.A23_UKEY = A23_A.UKEY    
LEFT OUTER JOIN A22 A22_A  (NOLOCK) ON A23_A.A22_UKEY = A22_A.UKEY        
LEFT OUTER JOIN A15 (NOLOCK) ON J10.A15_UKEY = A15.UKEY     
LEFT OUTER JOIN T02 (NOLOCK) ON J11.T02_UKEY0 = T02.UKEY      
LEFT OUTER JOIN A06 (NOLOCK) ON A06.UKEY = J10.A06_UKEY      
LEFT OUTER JOIN A24 A24_C (NOLOCK) ON A06.A24_UKEY = A24_C.UKEY     
LEFT OUTER JOIN A23 A23_C (NOLOCK) ON A06.A23_UKEY= A23_C.UKEY    
LEFT OUTER JOIN A22 A22_c  (NOLOCK) ON A23_C.A22_UKEY = A22_C.UKEY       
LEFT OUTER  JOIN CIA (NOLOCK) ON J11.CIA_UKEY = CIA.UKEY   
LEFT OUTER JOIN A13 A13 (NOLOCK) ON J10.A13_UKEY = A13.UKEY 
LEFT OUTER JOIN A33 A33 (NOLOCK) ON J10.A33_UKEY = A33.UKEY  
LEFT OUTER JOIN A10 A10  (NOLOCK) ON A10.A10_PAR='A06' AND A10.A10_UKEYP = A06.UKEY   AND SUBSTRING(J10.UKEY,9,5)=A10.USR_UKEY
WHERE J10.J10_061_N <> 1 AND  J10.J10_002_N =1  AND    |NUMERO| AND |PERIODO| AND ((?VOA_RVG[1]=2 AND J10_063_N=0) OR (?VOA_RVG[1]=1 AND J10_063_N = 1)) AND (?VOA_RVA[1] = 1 OR ?VOA_RVA[1] = 3) AND |CLIENTE|

UNION ALL

SELECT  CASE J10.ARRAY_005 WHEN 1 THEN 'CIF' WHEN 2 THEN 'FOB' WHEN 3 THEN 'EXW' WHEN 4 THEN 'FCA' WHEN 5 THEN 'FAS' WHEN 6 THEN 'CFR' WHEN 7 THEN 'CPT' WHEN 8 THEN 'CIP' WHEN 9 THEN 'DAF' WHEN 10 THEN 'DES' WHEN 11 THEN 'DEQ' WHEN 12 THEN 'DDU' 
		WHEN 13 THEN 'DDP' WHEN 14 THEN 'DAT' WHEN 15 THEN 'DAP' END AS "TIPO_FRETE", J10.USR_NOTE AS 'J10_NOTE',J11.J11_006_B, 
ISNULL((SELECT SUM(J22A.J22_004_B) AS 'J22_004_B' FROM J22 J22A (NOLOCK) INNER JOIN A40 A40A (NOLOCK) ON J22A.A40_UKEY = A40A.UKEY INNER JOIN J11 J11A (NOLOCK) ON J22A.J22_UKEYP = J11A.UKEY WHERE J11A.J10_UKEY = J10.UKEY), 0) AS 'J22_004_B', 
CIA.USR_NOTE AS 'CIA_NOTE', A06.A06_001_C, A06.A06_002_C, A24_C.A24_001_C AS CIDADE1,A22_C.A22_001_C AS PAIS1, A23_C.A23_002_C AS ESTADO1, T04.T04_002_C, 
(SELECT J07A.ARRAY_005 FROM J07 J07A (NOLOCK) WHERE J07A.UKEY = (SELECT J08.J07_UKEY FROM J08 WHERE J08.UKEY = J11.J11_UKEYP)) AS ARRAY_005,J10.ARRAY_005 AS ARRAY_005I,
(SELECT J07A.J07_001_C FROM J07 J07A (NOLOCK) WHERE J07A.UKEY = (SELECT J08.J07_UKEY FROM J08 WHERE J08.UKEY = J11.J11_UKEYP)) AS J07_001_C, J11.D07_UKEY, J11.UKEY AS UKEY1, D04.UKEY AS UKEYD04, J11.T06_UKEY, J11.J11_998_C, J11.J11_037_B,  J11.J11_040_B, 
J11.J11_003_B,  J11.J11_005_B, J11.ARRAY_114, J10.UKEY,J10.UKEY AS 'J10_UKEY', J10.A36_CODE AS  'MOEDA' ,J10.ARRAY_005, J10.J10_001_C, J10.J10_002_N, J10.USR_NOTE, J11.USR_NOTE AS COMENT, J10.J10_005_M, J10.J10_011_B,  J10.J10_012_B, J10.J10_030_N,  
J10.J10_031_C, J10.J10_003_D, J10.J10_014_D, J09.J09_001_C, D16.D16_001_C, D16.D16_003_C, a08.a08_003_C, a08.a08_010_C, a08.ARRAY_009, a08.a08_005_C, a08.a08_004_C, a08.a08_006_C,a08_037_C,  a08.a08_035_C, a08.a08_011_C, a08.a08_012_C, A28.A28_002_C, 
A28.A28_001_C, D04.D04_001_C, D04.ARRAY_050, D04.D04_008_C, A24.A24_001_C AS CIDADE, A23.A23_002_C AS ESTADO, A24_A.A24_001_C AS CIDTRANS, A23.A23_004_C, A23.A23_011_C, A23_A.A23_002_C AS ESTTRANS, A14.A14_003_C, A14.A14_002_C, A14.A14_011_C, A14.A14_005_C, 
A14.ARRAY_009 AS TIPTRANS, A14.A14_010_C, A15.A15_005_C, T02.T02_002_C,a08.a08_034_C, a08.a08_037_c AS CONTATO, CIA.CIA_025_C,CIA_006_C,CIA.CIA_069_C, (SELECT COUNT(J11A.UKEY) FROM J11 J11A (NOLOCK) WHERE J11A.J10_UKEY = J10.UKEY)  REGPAGE, A13.A13_001_C, 
J10.J10_006_D, A33.A33_002_C,  A06.USR_NOTE AS EMPRESAENTREGA, A24.A24_001_C, A23.A23_002_C, A22.A22_001_C AS PAIS, A10.A10_001_C AS CONTATOENTREGA, A10_010A_C AS TELCONTATO, A06.A06_003_C AS ZIPCODEENTREGA,  a08.a08_006_C AS ZIPCODE    
,SPACE(300) AS 'numero_serie', SPACE(1000) AS 'comentario_capa',
(SELECT J05_004_B FROM J05 (NOLOCK) WHERE J05_UKEYP = J10.UKEY AND J05_PAR='J10' AND J05_001_C='00001') AS VALOR_1, (select J05_004_B from J05 (NOLOCK) WHERE J05_UKEYP = J10.UKEY AND J05_PAR='J10' AND J05_001_C='00002') AS VALOR_2,
(select J05_003_D from J05 (NOLOCK) WHERE J05_UKEYP = J10.UKEY AND J05_PAR='J10' AND J05_001_C='00001') AS VENC_1, (select J05_003_D from J05 (NOLOCK) WHERE J05_UKEYP = J10.UKEY AND J05_PAR='J10' AND J05_001_C='00002') AS VENC_2
,SUBSTRING(J10.A36_CODE,1,3)AS MOEDA, (SELECT SUM(j11_003_b*j11_005_b) FROM j11 j11A (NOLOCK) INNER JOIN J10 J10A ON J11A.J10_UKEY=J10A.UKEY WHERE J10A.UKEY=J10.UKEY) AS TOTAL_ITEM
FROM J11 (NOLOCK)     
INNER JOIN J10 (NOLOCK) ON J11.J10_UKEY = J10.UKEY     
LEFT OUTER JOIN T04 (NOLOCK) ON J11.T04_UKEY = T04.UKEY     
LEFT OUTER JOIN D16 (NOLOCK) ON J11.D16_UKEY = D16.UKEY     
INNER JOIN a08 (NOLOCK) ON J10.J10_PAR = 'a08' AND J10.J10_UKEYP = a08.UKEY     
LEFT OUTER JOIN A24 (NOLOCK) ON a08.A24_UKEY = A24.UKEY     
LEFT OUTER JOIN A23 (NOLOCK) ON a08.A23_UKEY = A23.UKEY     
LEFT OUTER JOIN A22 A22  (NOLOCK) ON A23.A22_UKEY = A22.UKEY       
LEFT JOIN J09 (NOLOCK) ON J10.J09_UKEY = J09.UKEY     
INNER JOIN D04 (NOLOCK) ON J11.D04_UKEY = D04.UKEY     
LEFT OUTER JOIN A28 (NOLOCK) ON J11.A28_UKEY = A28.UKEY     
LEFT OUTER JOIN A14 (NOLOCK) ON J10.A14_UKEY0 = A14.UKEY     
LEFT OUTER JOIN A24 A24_A (NOLOCK) ON A14.A24_UKEY = A24_A.UKEY     
LEFT OUTER JOIN A23 A23_A (NOLOCK) ON A14.A23_UKEY = A23_A.UKEY    
LEFT OUTER JOIN A22 A22_A  (NOLOCK) ON A23_A.A22_UKEY = A22_A.UKEY        
LEFT OUTER JOIN A15 (NOLOCK) ON J10.A15_UKEY = A15.UKEY     
LEFT OUTER JOIN T02 (NOLOCK) ON J11.T02_UKEY0 = T02.UKEY      
LEFT OUTER JOIN A06 (NOLOCK) ON A06.UKEY = J10.A06_UKEY      
LEFT OUTER JOIN A24 A24_C (NOLOCK) ON A06.A24_UKEY = A24_C.UKEY     
LEFT OUTER JOIN A23 A23_C (NOLOCK) ON A06.A23_UKEY= A23_C.UKEY    
LEFT OUTER JOIN A22 A22_c  (NOLOCK) ON A23_C.A22_UKEY = A22_C.UKEY       
LEFT OUTER  JOIN CIA (NOLOCK) ON J11.CIA_UKEY = CIA.UKEY   
LEFT OUTER JOIN A13 A13 (NOLOCK) ON J10.A13_UKEY = A13.UKEY 
LEFT OUTER JOIN A33 A33 (NOLOCK) ON J10.A33_UKEY = A33.UKEY  
LEFT OUTER JOIN A10 A10  (NOLOCK) ON A10.A10_PAR='A06' AND A10.A10_UKEYP = A06.UKEY   AND SUBSTRING(J10.UKEY,9,5)=A10.USR_UKEY
WHERE J10.J10_061_N <> 1 AND  J10.J10_002_N =1  AND    |NUMERO| AND |PERIODO| AND ((?VOA_RVG[1]=2 AND J10_063_N=0) OR (?VOA_RVG[1]=1 AND J10_063_N = 1)) AND (?VOA_RVA[1] = 2  OR ?VOA_RVA[1] = 3) AND |FORNEC|