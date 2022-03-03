/**********************************************************************
 Livro: Otimizando Consultas no Microsoft SQL Server
 Autor: Landry Duailibe Salles Filho

 Data: 19/07/2014

 Scripts Capitulo 03

 Descrição: Scripts utilizados no corpo do livro
***********************************************************************/

/***********************************************************
 Script 3.1
 - Fowarding Pointers e sys.dm_db_index_physical_stats
************************************************************/
USE tempdb
go

-- Cria tabela no banco TEMPDB
if object_id('tbExemplo') is not null
DROP TABLE tbExemplo
go

CREATE TABLE tbExemplo (c1 INT, c2 CHAR(100), c3 INT, c4 VARCHAR(1000))
go

-- Carregando tabela com 1.000 linhas
DECLARE @i INT
SELECT @i = 0

WHILE (@i < 1000) BEGIN
  INSERT INTO tbExemplo VALUES (@i, 'SQL Server', @i+10000, replicate ('a', 100))
SET @i = @i + 1
END

--select * from tbExemplo

-- Criando índice na coluna c1
CREATE INDEX idx_tbExemplo_c1 ON tbExemplo(c1)

-- UPDATE para provocar Forwarded Pointes
UPDATE tbExemplo SET c4 = replicate ('b', 1000)

-- Analisando Fragmentação e Forwarded Pointers
SELECT index_type_desc,index_level, avg_fragmentation_in_percent, 
avg_page_space_used_in_percent, record_count,forwarded_record_count
FROM sys.dm_db_index_physical_stats 
(DB_ID(), object_id('tbExemplo'), NULL, NULL, 'DETAILED')


/***********************************************************
 Script 3.2
 - Resolvendo fragmentação
************************************************************/
-- Para resolver a fragmentação do índice
ALTER INDEX idx_tbExemplo_c1 ON tbExemplo REORGANIZE
-- ou
ALTER INDEX idx_tbExemplo_c1 ON tbExemplo REBUILD

/***********************************************************
 Script 3.3
 - Resolvendo Forwarded Records e fragmentação na tabela
************************************************************/
-- Para resolver a fragmentação da tabela e ocorrência de Forwarded Records
ALTER TABLE tbExemplo REBUILD


/***********************************************************
 Script 3.4
 - Compactação de tabela
************************************************************/

-- Tabela SEM compactação
CREATE TABLE TabelaSemComp (id int, FName char(100), LName char(100))
go

DECLARE @n int
SET @n = 0

WHILE @n <= 10000 BEGIN
  INSERT TabelaSemComp VALUES (1,'Adam','Smith')
  INSERT TabelaSemComp VALUES (2,'Maria','carter')
  INSERT TabelaSemComp VALUES (3,'Walter','zenegger')
  INSERT TabelaSemComp VALUES (4,'Marianne','smithsonian')
  SET @n = @n + 1
END
go

-- Tabela COM compactação
CREATE TABLE TabelaComp (id int, FName char(100), LName char(100)) 
WITH (Data_compression = PAGE)
go

DECLARE @n int
SET @n = 0
WHILE @n <= 10000 BEGIN
  INSERT TabelaComp VALUES (1,'Adam','Smith')
  INSERT TabelaComp VALUES (2,'Maria','carter')
  INSERT TabelaComp VALUES (3,'Walter','zenegger')
  INSERT TabelaComp VALUES (4,'Marianne','smithsonian')
  SET @n = @n + 1
END
go

EXEC sp_spaceused TabelaSemComp
EXEC sp_spaceused TabelaComp
/*
name			rows		reserved	data	index_size	unused
TabelaSemComp	40004       8712 KB		8656 KB	8 KB		48 KB
TabelaComp		40004      	904 KB		896 KB	8 KB		0 KB
*/

Exec sp_estimate_data_compression_savings 'dbo','TabelaSemComp',NULL,NULL,'PAGE'
Exec sp_estimate_data_compression_savings 'dbo','TabelaSemComp',NULL,NULL,'ROW'

SET STATISTICS IO ON

SELECT * FROM TabelaSemComp
--Table 'TabelaSemComp'. Scan count 1, logical reads 1082

SELECT * FROM TabelaComp
-- Table 'TabelaComp'. Scan count 1, logical reads 112

