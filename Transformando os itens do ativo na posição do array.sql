select d04_001_c, d04_008_c, d04_102_n, d04_164_n from d04 (nolock) where d04_102_n = 1

update d04 set d04_164_n = 6 where ukey in (select ukey from d04 (nolock) where d04_102_n = 1)