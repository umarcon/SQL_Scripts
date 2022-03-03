USE [StarWestcon]
GO

UPDATE [dbo].[cia]
   SET 
       [cia_500_m] = (select cia_500_m from ciaold where ciaold.ukey = cia.ukey)
      ,[cia_501_m] = (select cia_501_m from ciaold where ciaold.ukey = cia.ukey)
      ,[cia_502_m] = (select cia_502_m from ciaold where ciaold.ukey = cia.ukey)
      ,[cia_503_m] = (select cia_503_m from ciaold where ciaold.ukey = cia.ukey)
      ,[cia_504_m] = (select cia_504_m from ciaold where ciaold.ukey = cia.ukey)
      ,[CIA_506_M] = (select CIA_506_M from ciaold where ciaold.ukey = cia.ukey)
      ,[CIA_507_M] = (select CIA_507_M from ciaold where ciaold.ukey = cia.ukey)
      ,[cia_505_m] = (select cia_505_m from ciaold where ciaold.ukey = cia.ukey)
      ,[CIA_509_M] = (select CIA_509_M from ciaold where ciaold.ukey = cia.ukey)
      ,[ARRAY_782] = (select ARRAY_782 from ciaold where ciaold.ukey = cia.ukey)
      ,[ARRAY_791] = (select ARRAY_791 from ciaold where ciaold.ukey = cia.ukey)
      ,[array_ambiente] = (select array_ambiente from ciaold where ciaold.ukey = cia.ukey)
      ,[array_contingencia] = (select array_contingencia from ciaold where ciaold.ukey = cia.ukey)
      ,[ARRAY_DBO] = (select ARRAY_DBO from ciaold where ciaold.ukey = cia.ukey)
      ,[ARRAY_Enquad] = (select ARRAY_Enquad from ciaold where ciaold.ukey = cia.ukey)
      ,[ARRAY_RegimeTributario] = (select ARRAY_RegimeTributario from ciaold where ciaold.ukey = cia.ukey)
      ,[ARRAY_VersaoNFe] = (select ARRAY_VersaoNFe from ciaold where ciaold.ukey = cia.ukey)
      ,[CIA_508_N] = (select CIA_508_N from ciaold where ciaold.ukey = cia.ukey)
      ,[CIASC_254_N] = (select CIASC_254_N from ciaold where ciaold.ukey = cia.ukey)
      ,[CIASC_255_N] = (select CIASC_255_N from ciaold where ciaold.ukey = cia.ukey)
      ,[CIASC_256_N] = (select CIASC_256_N from ciaold where ciaold.ukey = cia.ukey)
      ,[CIASC_257_N] = (select CIASC_257_N from ciaold where ciaold.ukey = cia.ukey)
      ,[CIASC_258_N] = (select CIASC_258_N from ciaold where ciaold.ukey = cia.ukey)
      ,[CIASC_259_N] = (select CIASC_259_N from ciaold where ciaold.ukey = cia.ukey)
      ,[CIASC_260_N] = (select CIASC_260_N from ciaold where ciaold.ukey = cia.ukey)
      ,[CIASC_261_N] = (select CIASC_261_N from ciaold where ciaold.ukey = cia.ukey)
      ,[CIASC_264_N] = (select CIASC_264_N from ciaold where ciaold.ukey = cia.ukey)
      ,[CIASC_262_C] = (select CIASC_262_C from ciaold where ciaold.ukey = cia.ukey)
      ,[CIASC_263_C] = (select CIASC_263_C from ciaold where ciaold.ukey = cia.ukey)
      ,[ARRAY_098] = (select ARRAY_098 from ciaold where ciaold.ukey = cia.ukey)
      ,[CIASC_266_C] = (select CIASC_266_C from ciaold where ciaold.ukey = cia.ukey)
      ,[CIASC_267_C] = (select CIASC_267_C from ciaold where ciaold.ukey = cia.ukey)
      ,[CIASC_268_C] = (select CIASC_268_C from ciaold where ciaold.ukey = cia.ukey)
      ,[CIASC_269_C] = (select CIASC_269_C from ciaold where ciaold.ukey = cia.ukey)
      ,[CIASC_270_D] = (select CIASC_270_D from ciaold where ciaold.ukey = cia.ukey)
      ,[CIASC_265_C] = (select CIASC_265_C from ciaold where ciaold.ukey = cia.ukey)
      ,[ARRAY_100] = (select ARRAY_100 from ciaold where ciaold.ukey = cia.ukey)
