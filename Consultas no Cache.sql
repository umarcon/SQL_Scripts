SELECT deqs.last_execution_time AS [Time], dest.TEXT AS [Query]
SELECT top(10) st.[text] as Consulta, 
qs.execution_count as QtdExec, 
qs.total_elapsed_time as TempoExec
FROM sys .dm_exec_query_stats AS qs
CROSS APPLY sys.dm_exec_sql_text( qs.sql_handle ) AS st
where st.[text] is not null 
and st.[text] not like 'FETCH%' 
and st.[text] not like '%CREATE%'
ORDER BY qs.execution_count DESC

FROM sys.dm_exec_query_stats AS deqs
CROSS APPLY sys.dm_exec_sql_text(deqs.sql_handle) AS dest
ORDER BY deqs.last_execution_time DESC


DECLARE @MinCount BIGINT
SET @MinCount = 5000
SELECT st.[text], qs.execution_count, qs.total_elapsed_time
FROM sys .dm_exec_query_stats AS qs
CROSS APPLY sys.dm_exec_sql_text( qs.sql_handle ) AS st
WHERE qs.execution_count > @MinCount
--ORDER BY qs.execution_count DESC
ORDER BY qs.total_elapsed_time DESC

/*
You can use the query in Listing 1 to find the plans that have been used only once. 
This query looks for objects of type Compiled Plan. 
It doesn't look for objects of type Compiled Plan Stub because the amount of memory 
consumed by all these stubs is typically fairly small. Plus, they're among the first 
objects to be removed from the plan cache by SQL Server when memory pressure exists.
*/

SELECT text, cp.objtype, cp.size_in_bytes
FROM sys.dm_exec_cached_plans AS cp
CROSS APPLY sys.dm_exec_sql_text(cp.plan_handle) st
WHERE cp.cacheobjtype = N'Compiled Plan'
AND cp.objtype IN(N'Adhoc', N'Prepared')
AND cp.usecounts = 1
ORDER BY cp.size_in_bytes DESC
OPTION (RECOMPILE);

/*
You can quickly find the plans that have missing indexes by using a script like that 
in Listing 2. However, before adding indexes to your tables, you need to thoroughly 
test them to make sure that they don't negatively affect any delete, 
update, and insert operations.
*/
;WITH XMLNAMESPACES(DEFAULT
 N'http://schemas.microsoft.com/sqlserver/2004/07/showplan')
 SELECT dec.usecounts, dec.refcounts, dec.objtype
   , dec.cacheobjtype, des.dbid, des.text,deq.query_plan
 FROM sys.dm_exec_cached_plans AS dec
 CROSS APPLY sys.dm_exec_sql_text(dec.plan_handle) AS des
 CROSS APPLY sys.dm_exec_query_plan(dec.plan_handle) AS deq
 WHERE
 deq.query_plan.exist
 (N'/ShowPlanXML/BatchSequence/Batch/Statements/StmtSimple
 /QueryPlan/MissingIndexes/MissingIndexGroup') <> 0
 ORDER BY dec.usecounts DESC

/*
To look for plans that have implicit conversion warnings, you can use the script in Listing 3. Implicit conversion warnings indicate a mismatch between the data type used in the query and the data type defined in the database. The most common mismatch is using an integer value in a query that's run against a column defined as VARCHAR or NVARCHAR in the database.
*/
;WITH XMLNAMESPACES(DEFAULT
 N'http://schemas.microsoft.com/sqlserver/2004/07/showplan')
 SELECT
 cp.query_hash, cp.query_plan_hash,
 ConvertIssue =
   operators.value('@ConvertIssue','nvarchar(250)'),
 Expression =
   operators.value('@Expression','nvarchar(250)'),
   qp.query_plan
 FROM sys.dm_exec_query_stats cp
 CROSS APPLY sys.dm_exec_query_plan(cp.plan_handle) qp
 CROSS APPLY query_plan.nodes('//Warnings/PlanAffectingConvert')
   rel(operators)

/*
To look for plans that have Key Lookup or Clustered Index Seek operators, you can use the script in Listing 4. It returns a row for every operator inside of every plan in your cache. Note that this script might take a few minutes to run on a system with a large plan cache.
*/
;WITH XMLNAMESPACES(DEFAULT
 N'http://schemas.microsoft.com/sqlserver/2004/07/showplan')
 SELECT
 cp.query_hash, cp.query_plan_hash,
 PhysicalOperator =
   operators.value('@PhysicalOp','nvarchar(50)'),
 LogicalOp = operators.value('@LogicalOp','nvarchar(50)'),
 AvgRowSize = operators.value('@AvgRowSize','nvarchar(50)'),
 EstimateCPU =
   operators.value('@EstimateCPU','nvarchar(50)'),
 EstimateIO = operators.value('@EstimateIO','nvarchar(50)'),
 EstimateRebinds =
   operators.value('@EstimateRebinds','nvarchar(50)'),
 EstimateRewinds =
   operators.value('@EstimateRewinds','nvarchar(50)'),
 EstimateRows =
   operators.value('@EstimateRows','nvarchar(50)'),
 Parallel = operators.value('@Parallel','nvarchar(50)'),
 NodeId = operators.value('@NodeId','nvarchar(50)'),
 EstimatedTotalSubtreeCost =
   operators.value('@EstimatedTotalSubtreeCost','nvarchar(50)')
 FROM sys.dm_exec_query_stats cp
 CROSS APPLY sys.dm_exec_query_plan(cp.plan_handle) qp
 CROSS APPLY query_plan.nodes('//RelOp') rel(operators)





