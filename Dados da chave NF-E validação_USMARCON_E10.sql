
--select * from E10 where E10_001_c like '%57452' and E10_003_d ='20140327'


declare @NOTA AS VARCHAR(20), @DATA_1 AS VARCHAR(8), @DATA_2 AS VARCHAR(8),@NUM int 
SET @NOTA = 'DS8WFRQK55_4140PWEK4'
SET @DATA_1 = '20140101'
SET @DATA_2 = '20171231'
SET @NUM= (select e10.e10_001_c from e10 where ukey = @Nota)
  
SELECT 

RTRIM(LTRIM(COD_UF))+
SUBSTRING(REPLACE(CONVERT(CHAR,ENTRADA,2),'.',''),1,4)+
RTRIM(LTRIM(CNPJ))+
RTRIM(LTRIM(MODELO))+
RTRIM(LTRIM(SERIE))+
RTRIM(LTRIM(NUMERO_NFE))
+RTRIM(LTRIM(DV_01)) as Chave_fak FROM 
(SELECT   
'ENTRADA' Chave_nota,
e10.e10_075_C Chave,
'35' Cod_UF,
e10_014_d ENTRADA,
(SELECT CIA_006_c FROM CIA WHERE CIA.UKEY = e10.CIA_UKEY) CNPJ, 
'55' Modelo, 
J09_001_C Serie,
right(replicate('0',9)+cast(@num as varchar(9)),9) aS Numero_NFE,
'1101010109'as 'DV_01' 
FROM e10 (nolock)    
LEFT JOIN T89(nolock) ON e10.T89_UKEY = T89.UKEY   
LEFT JOIN J09(nolock) ON e10.J09_UKEY = J09.UKEY   
INNER JOIN (SELECT 1 TIPO,A03.UKEY UKEY,A03_001_C,A03_010_C,A03_003_C, ARRAY_009 FROM A03 A03  
     UNION ALL  
  SELECT 2 TIPO,A08.UKEY UKEY,A08_001_C A03_001_C,A08_010_C A03_010_C,A08_003_C A03_003_C, ARRAY_009 ARRAY_009 FROM A08 A08) 
     A03T ON e10_UKEYP = A03T.UKEY  
WHERE e10_014_D BETWEEN @DATA_1 AND @DATA_2
and e10.ukey = @NOTA)TEMP




