select * from sys10 where tab_id = 'd04' order by cia_ukey
select * from sys10 where tab_id = 'b11' order by cia_ukey
select * from sys10 where tab_id = 'b23' order by cia_ukey
select * from sys10 where tab_id = 'b14' order by cia_ukey

BEGIN TRAN
COMMIT
ROLLBACK

UPDATE SYS10 SET TAB_PROP = ';0E2PB;383ZY;7MZMQ;DK247;MDQJW;MGVJM;STAR_;V5LRC;XOQ5M;XY5JG;' WHERE TAB_ID = 'D04'
AND CIA_UKEY IN ('0E2PB','383ZY','7MZMQ','DK247','MDQJW','MGVJM','STAR_','V5LRC','XOQ5M','XY5JG')

UPDATE SYS10 SET TAB_PROP = ';OSL0R;' WHERE TAB_ID = 'D04' AND CIA_UKEY = 'OSL0R'