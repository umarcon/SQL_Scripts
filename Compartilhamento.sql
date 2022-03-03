use starwestconcala2

select * from sys10 (nolock) where tab_id = 'WE30'
select * from sys10 (nolock) where tab_id = 'WE31'

update sys10 set tab_prop = ';P6SIH;' where sys07_ukey in (select ukey from sys07 (nolock) where tab_id = 'WE30') and cia_ukey = 'P6SIH' and tab_id = 'WE30'
update sys10 set tab_prop = ';STAR_;' where sys07_ukey in (select ukey from sys07 (nolock) where tab_id = 'WE30') and cia_ukey in ('M8O85','STAR_') and tab_id = 'WE30'
update sys10 set tab_prop = ';M8530;M8531;' where sys07_ukey in (select ukey from sys07 (nolock) where tab_id = 'WE30') and cia_ukey = 'M8530' and tab_id = 'WE30'
update sys10 set tab_prop = ';M8530;M8531;' where sys07_ukey in (select ukey from sys07 (nolock) where tab_id = 'WE30') and cia_ukey = 'M8531' and tab_id = 'WE30'
update sys10 set tab_prop = ';5DTR4;' where sys07_ukey in (select ukey from sys07 (nolock) where tab_id = 'WE30') and cia_ukey = '5DTR4' and tab_id = 'WE30'
update sys10 set tab_prop = ';5HV8Z;' where sys07_ukey in (select ukey from sys07 (nolock) where tab_id = 'WE30') and cia_ukey = '5HV8Z' and tab_id = 'WE30'
update sys10 set tab_prop = ';5J6PB;' where sys07_ukey in (select ukey from sys07 (nolock) where tab_id = 'WE30') and cia_ukey = '5J6PB' and tab_id = 'WE30'


update sys10 set tab_prop = ';P6SIH;' where sys07_ukey in (select ukey from sys07 (nolock) where tab_id = 'WE31') and cia_ukey = 'P6SIH' and tab_id = 'WE31'
update sys10 set tab_prop = ';STAR_;' where sys07_ukey in (select ukey from sys07 (nolock) where tab_id = 'WE31') and cia_ukey in ('M8O85','STAR_') and tab_id = 'WE31'
update sys10 set tab_prop = ';M8530;M8531;' where sys07_ukey in (select ukey from sys07 (nolock) where tab_id = 'WE31') and cia_ukey = 'M8530' and tab_id = 'WE31'
update sys10 set tab_prop = ';M8530;M8531;' where sys07_ukey in (select ukey from sys07 (nolock) where tab_id = 'WE31') and cia_ukey = 'M8531' and tab_id = 'WE31'
update sys10 set tab_prop = ';5DTR4;' where sys07_ukey in (select ukey from sys07 (nolock) where tab_id = 'WE31') and cia_ukey = '5DTR4' and tab_id = 'WE31'
update sys10 set tab_prop = ';5HV8Z;' where sys07_ukey in (select ukey from sys07 (nolock) where tab_id = 'WE31') and cia_ukey = '5HV8Z' and tab_id = 'WE31'
update sys10 set tab_prop = ';5J6PB;' where sys07_ukey in (select ukey from sys07 (nolock) where tab_id = 'WE31') and cia_ukey = '5J6PB' and tab_id = 'WE31'
