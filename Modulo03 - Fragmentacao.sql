/**********************************************
 Curso Query Tuning
 Autor: Landry D. Salles Filho
 Módulo 03 - Exercício 1
***********************************************/

-- Cria tabela no banco TEMPDB
USE tempdb
go
if object_id('tbFragmentacao') is not null
DROP TABLE tbFragmentacao
go

CREATE TABLE tbFragmentacao (c1 uniqueidentifier not null primary key, c2 int not null, c3 CHAR(2000), c4 VARCHAR(1000))
go

-- Carregando tabela com 100.000 linhas
DECLARE @i INT
SELECT @i = 0

WHILE (@i < 100000) BEGIN
  INSERT INTO tbFragmentacao VALUES (newid(),@i, 'SQL Server', replicate ('a', 1000))
SET @i = @i + 1
END
go
-- Leva 30seg 


-- Verifica Fragmentação
SELECT object_name(object_id),index_type_desc,index_level, avg_fragmentation_in_percent, 
avg_page_space_used_in_percent, record_count,forwarded_record_count
FROM sys.dm_db_index_physical_stats 
(DB_ID(), object_id('tbFragmentacao'), NULL, NULL, 'DETAILED')


-- Limpa Buffer Cache
checkpoint
dbcc dropcleanbuffers

-- Teste de execução com tabela fragmentada
select * from tbFragmentacao order by c1 
-- 50seg

-- Resolve Fragmentação da tabela
ALTER TABLE tbFragmentacao REBUILD

-- Teste de execução com tabela SEM fragmentação
select * from tbFragmentacao order by c1 
-- 17seg
