/**********************************************************************
 Livro: Otimizando Consultas no Microsoft SQL Server
 Autor: Landry Duailibe Salles Filho

 Data: 19/07/2014

 Scripts Capitulo 02

 Descrição: Consultas utilizadas no corpo do livro
***********************************************************************/

/*********************
 Script 2.1
**********************/ 
SELECT top(10) 
st.[text] as Consulta, 
execution_count as QtdExec, 
last_elapsed_time  as Tempo_UltimaExec,
last_logical_reads as LeituraIO_UltimaExec, 
last_logical_writes as EscritaIO_UltimaExec,
last_worker_time as CPU_UltimaExec
FROM sys .dm_exec_query_stats AS qs
CROSS APPLY sys.dm_exec_sql_text(qs.sql_handle) AS st
where st.[text] is not null 
and st.[text] not like 'FETCH%' 
and st.[text] not like '%CREATE%'
ORDER BY execution_count DESC


/*********************
 Script 2.2
**********************/
SELECT top(10) 
st.[text] as Consulta, 
execution_count as QtdExec, 
last_elapsed_time  as Tempo_UltimaExec,
last_logical_reads as LeituraIO_UltimaExec, 
last_logical_writes as EscritaIO_UltimaExec,
last_worker_time as CPU_UltimaExec,
pl.query_plan as Plano_Exec 
FROM sys.dm_exec_query_stats qs  
CROSS APPLY sys.dm_exec_sql_text(qs.sql_handle) st 
OUTER APPLY sys.dm_exec_query_plan(qs.plan_handle) pl 
where st.[text] is not null 
and st.[text] not like 'FETCH%' 
and st.[text] not like '%CREATE%'
ORDER BY execution_count DESC

/*********************
 Script 2.3
**********************/
SELECT top(10) 
st.[text] as Consulta, 
execution_count as QtdExec, 
last_elapsed_time  as Tempo_UltimaExec,
last_logical_reads as LeituraIO_UltimaExec, 
last_logical_writes as EscritaIO_UltimaExec,
last_worker_time as CPU_UltimaExec,
pl.query_plan as Plano_Exec 
FROM sys.dm_exec_query_stats qs  
CROSS APPLY sys.dm_exec_sql_text(qs.sql_handle) st 
OUTER APPLY sys.dm_exec_query_plan(qs.plan_handle) pl 
where st.[text] is not null 
and st.[text] not like 'FETCH%' 
and st.[text] not like '%CREATE%'
and pl.query_plan.exist
(N'/ShowPlanXML/BatchSequence/Batch/Statements/StmtSimple
/QueryPlan/MissingIndexes/MissingIndexGroup') <> 0
ORDER BY execution_count DESC
