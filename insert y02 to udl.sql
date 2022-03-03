USE [StarWestcon]
GO

insert into udl
SELECT [CHKSUM]
      ,''[GROUP]
      ,[TIMESTAMP]
      ,y02_002_c [UKEY]
      ,null[SAP_HANA]
      ,null[FILES]
      ,null[FILTERS]
      ,null[ORACLE]
      ,[PROPERTIES]
      ,y02_010_m [SQL]
      ,y02_010_m [DSQLSYNTAX]
      ,1 [ARRAY_098]
      ,null[SSA_REP_M]
      ,null[UDA_UKEY]
      ,[Y02_003_N]
      ,[Y02_005_L]
      ,null[FORMLIST]
      ,[OWNER]
      ,y02_008_c [TITLE]
  FROM [dbo].[y02]
order by ukey 
GO


