/********************************************************************************************
 Curso 6232 - Módulo 02
 Tamanho máximo da linha

 * SQL 6.5 --> pg (2Kb) linha (1962bytes)

 * SQL 7.0 --> pg (8Kb) linha (8060bytes) - erro mesmo com coluna de tamanho variável
 
 * SQL 2000 -> pg (8Kb) linha (8060bytes) - com coluna de tamanho variável deixa criar,
                                            porém retorna um warning.
 
 * SQL 2005 -> pg (8Kb) linha (xxxxbytes) - pode criar tabela com linha maior que 8060,
                                            porém o total das colunas de tamanho fixo 
                                            ainda não podem ultrapassar o limite dos
                                            8060 bytes.

*********************************************************************************************/

use tempdb
go

/***** Tabela com tamanho de linha menor que 8060 bytes */
create table dbo.Menor8k
(PkId int identity not null, col2 char(4000), col3 char(4000))

/***** Tabela com tamanho de linha igual a 9004 bytes e colunas de tamanho fixo */
create table dbo.Maior8k
(PkId int identity not null, col2 char(4000), col3 char(4000), col4 char(1000))
-- Msg 1701, Level 16, State 1, Line 2
-- Creating or altering table 'Maior8k' failed because the minimum row size would be 9011, including 7 bytes of internal overhead. This exceeds the maximum allowable table row size of 8060 bytes.

-- continua limite de 8060 bytes para coluna de tamanho fixo
-- drop table Maior8k

/***** Tabela com tamanho de linha igual a 9004 bytes e colunas de tamanho variável */
create table Maior8k
(PkId int identity not null, col2 char(4000), col3 char(4000), col4 varchar(1000))
-- criou a tabela porque a tabela possui uma coluna varchar
-- drop table Maior8k

SELECT object_name(object_id) Nome,partition_number pnum,hobt_id,rows,
       a.allocation_unit_id au_id,a.[type],
	   case a.[type] when 1 then 'InRow' when 3 then 'OutRow' else 'Outros' end TypeOfPages,
	   a.total_pages pages
FROM sys.partitions p JOIN sys.system_internals_allocation_units a
ON p.partition_id = a.container_id
WHERE object_name(object_id) LIKE '%8k' ORDER BY 1

-- Type 3 indica que o valor de uma coluna varchar() ultrapassou o limite dos 8060 bytes,
-- deixando um ponteiro junto da linha e armazenando as informacoes em paginas out-of-row.

-- Type 1 indica pagina dentro da linha.



