select * from d28 (nolock)
inner join d07 (nolock) on d28.d07_ukey = d07.ukey
inner join d04 (nolock) on d28.d04_ukey = d04.ukey
where d07_001_c = ?VPA_Seek[1] and d28_001_t >= getdate()-60 and d04.ukey = ?VPA_Seek[2]