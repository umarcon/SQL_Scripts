--select * from uda_ssa (nolock) where ukey in (
--select y02_002_c from y02 (nolock) where y02_002_c like '%j10%')


--update udl set ARRAY_098 = 2 where ukey in (
select *  from udl (nolock) where ukey in (
select ukey from uda_ssa (nolock) where ukey like '%j10%')
--)

delete from udl where ukey in (
select ukey from uda_ssa (nolock) where ukey like '%j10%')

select *  from y02 (nolock) where y02_002_c in (
select ukey from uda_ssa (nolock) where ukey like '%j10%')

--delete from y02 where y02_002_c in (
--select ukey from uda_ssa (nolock) where ukey like '%j10%')

insert into y02 select * from #y02tmp
insert into udl select * from #udltmp
--drop table #udltmp