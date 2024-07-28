
with
 lin as --структура всех линий
(select cast(nom3d as smallint) as dor,cast(noml as smallint) as lin,
  cast(stan as dec(7)) as kst,rstk as rst,--cast(sf as dec(3)) as reg,
  datand,datakd,datani,dataki
  from nsi.lines ),

 comp_lin as
  (select predpr,dor,lin,st1,st2,date_beg,date_end from spb_prig.prig_comp_lin),
 
  lin1 as  
  (select * from
  (select predpr,a.dor,a.lin,least(b.rst,c.rst) as rst1,GREATEST(b.rst,c.rst) as rst2,
   GREATEST(date_beg,b.datani,c.datani) as dat1,least(date_end,b.dataki,c.dataki) as dat2
  from comp_lin as a
   join lin as b on a.dor=b.dor and a.lin=b.lin and st1=b.kst
   join lin as c on a.dor=c.dor and a.lin=c.lin and st2=c.kst
  ) as d where dat1<=dat2),
 
 lin2 as
 (select * from
 (select predpr,a.dor,a.lin, rst1,rst2,kst,rst,--dat1,dat2,datani,dataki
   GREATEST(dat1,b.datani) as date_beg,least(dat2,b.dataki) as date_end
 from lin1 as a join lin as b on a.dor=b.dor and a.lin=b.lin and rst between rst1 and rst2) as c
   where date_beg<=date_end),
  
pred1 as
(select predpr,kst,min(tp) as tp,min(date_beg) as date_beg,max(date_end) as date_end from
(select predpr,st1 as kst,date_beg,date_end,1 as tp from comp_lin where st1=st2
union all
select predpr,kst,date_beg,date_end,2 as tp from lin2 ) as a group by 1,2),

pred2 as
(select predpr,a.kst,date_beg,date_end from pred1 as a,
(select kst,count(*) as kol,min(tp) as mtp from pred1 group by 1) as b
 where a.kst=b.kst and tp=mtp),

stan as
(select distinct kst from spb_prig.prig_agr_kst )

--select count(*) from pred2 --where kst=2004006

select * from stan where kst not in(select kst from pred2)

--select * from pred2 where kst=2004006

 

--select * from lin2 where kst is null

--select * from lin2 where kst=2004006

--select * from lin where kst=2004442







with
date as
(select date_zap from  spb_prig.prig_times where oper='dannie'),
 lin as --структура всех линий
(select cast(nom3d as smallint) as dor,cast(noml as smallint) as lin,
  cast(stan as dec(7)) as kst,rstk as rst --,cast(sf as dec(3)) as reg,
  from nsi.lines join date on date_zap between datand and datakd and date_zap between datani and dataki),
 stan_ as
 (select cast(stan as dec(7)) as kst,snazv as name,dor,otd,admr as arn,
  case when sf='' then 0 else cast(sf as smallint) end as reg
  from nsi.stanv join date on date_zap between datand and datakd
  where gos='20' -- and stan in ('2004001','2009778')
 ),
 dor as (select kodd as dor,nomd3 as dor3,vc,datan,datak 
		 from nsi.dor  join date on date_zap between datan and datak where kodg='20'),
stan as
(select kst,name,cast(dor3 as smallint) as dor,vc,cast(otd as smallint) as otd,reg
from stan_ as a,dor as b where a.dor=b.dor)

 
 select * from stan
 --select distinct vc,dor,dor3 from dor order by 1,2,3
 --fetch first 5 rows only




select * from nsi.dor





