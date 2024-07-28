

--В маршрутнике есть флаг принадлежности станции МЦД. По расписанному маршруту пассажира мы видим, что есть какое-то МЦД. 
--		А сам номер МЦД сидит в поле номер поезда Q64NP. Если там '1' или '2' или  '3', то это номер МЦД, которое мы нашли в маршруте пассажира.
--ПРОГРАММА ПЕРВИЧНОЙ ПЕРЕРАБОТКИ ДАННЫХ, НАРАБОТКА СПРАВОЧНИКА БИЛЕТВ И МАРШРУТОВ, 
--ПОЛУЧЕНИЕ ОТПРАВЛЕННЫХ ПАССАЖИРОВ ПО ДАТАМ ОТПРАВЛЕНИЯ СОКРАЩЕНИЕ ЧИСЛА ЗАПИСЕЙ БЕЗ ПОТЕРИ ИНФОРМАЦИИ

--ТОЛЬКО ПРОЦЕДУРА ОБОГАЩЕНИЯ, НЕ БОЛЕЕ ТОГО!!! Вторая часть - переработка маршрутов


/**/
--- ввод времени начала операции
insert into  l3_prig.prig_times(time,date,dann,libr,oper,time2,date_zap,part_zap,shema)
with a as
(select date_zap,part_zap,dann,libr,oper,shema,current_date as date,substr(cast(current_time as char(50)),1,12) as time
	from  l3_prig.prig_times where dann='prig' and oper='dannie')
select time,date,dann,libr,'prig_work 2_22_beg' as oper,
(cast(substr(time,1,2) as dec(3))*60+cast(substr(time,4,2) as dec(3)))*60+cast(substr(time,7,6) as dec(7,3)) as time2,date_zap,part_zap,shema
from a;



/*СОБСТВЕННО ПРОГРАММА*/


-- marshr   train_num  mcd


/**/
insert into l3_prig.prig_work(
	rez,idnum,opis,sto,stn,marshr,mcd,nom,st1,st2,rst,sto_zone,stn_zone,sti,sti_zone,d_plata,d_poteri,dor,lin,otd,dcs,reg,srasst,k_bil )
/**/

with

dates as  --дата загружаемых данных
(select distinct date_zap,part_zap from  l3_prig.prig_times where dann='prig' and oper='dannie'),

prig_opis as
(select  IDNUM,opis,nom,marshr,rst as rasst,st1,st2,reg as regg,/*max_nom,*/sto,stn,srasst,sto_zone,stn_zone,sti,sti_zone,d_plata,d_poteri,mcd
 from l3_prig.prig_work where rez=51),

/* ВСЕ СПРАВОЧНИКИ */
marshr_ish as --список всех маршрутов
(select ssm_nmar as marshr,round(ssm_rst) as rst,cast(ssm_stan as decimal(7)) as kst,ssm_prmcd as pr_mcd,
 case when ssm_ksf=' ' then 0 else cast(ssm_ksf as decimal(3)) end as reg,
	case when ssm_prgr='1' or ssm_prgs='1' then '1' else '0' end as perelom,
	ROW_NUMBER() over (partition by ssm_nmar order by ssm_rst) as nom
	from prig.submars  as a,dates as b where date_zap between ssm_datan and ssm_datak),
	
	
stan as --принадлежности станций НОДам и ДЦСам и субъектам
(select cast(stan as dec(7)) as kst,gos,koddcs as dcs,cast(otd as dec(3)) as otd,cast(sf as dec(3)) as sf,prgrotd as gr_otd,prgrsf as gr_sf
 from nsi.stanv as a,dates as b where date_zap between datand and datakd and date_zap between datani and dataki
/* --ПРАВИЛЬНЫЙ СПОСОБ СКЛЕЙКИ!!!
 on b.STAN = l2_pass_main.sale_station
departure_date between datand and datakd and request_date between datani and  dataki
 */
),
 
lin_ish as
(select dor,lin,kst,rst,sf,ROW_NUMBER() over (partition by dor,lin order by rst) as nom from
(select cast(nom3d as dec(3)) as dor,cast(noml as dec(3)) as lin,cast(stan as dec(7)) as kst,rstn as rst,cast(sf as dec(3)) as sf
	from nsi.lines as a,dates as b where date_zap between datand and datakd and date_zap between datani and dataki) as a),
	

lin as 
(select dor,lin,10000*dor+lin as dorlin,b.kst,rst,nom,gos,otd,dcs,gr_otd,gr_sf,case when b.sf=0 then c.sf else b.sf end as sf
 -- 0 as gos,0 as otd,0 as dcs,0 as gr_otd,0 as gr_sf,0 as sf
	from  lin_ish as b left join stan as c on b.kst=c.kst
),


linp_1 as
(select a.dor,a.lin,a.dorlin,a.kst as kst_1,b.kst as kst_2,a.nom as nom1,b.nom as nom2,a.rst as r_1,b.rst as r_2,
  case when a.nom<b.nom then 1 else -1 end as napr_lin,
 case when a.gr_sf='1' or a.sf=0 or a.sf is null then b.sf else a.sf end as sf,
 case when a.gr_otd='1' or a.otd=0 or a.otd is null then b.otd else a.otd end as otd,
 case when (a.gr_sf='1' or a.gr_otd='1' or a.dcs=0 or a.dcs is null) and b.dcs!=0 then b.dcs else a.dcs end as dcs 
from lin as a,lin as b where /*a.dor=b.dor and a.lin=b.lin*/ a.dorlin=b.dorlin and a.nom=b.nom-1
),

linp as
(select dor,lin,dorlin,kst_1,kst_2,nom1,nom2,r_1,r_2,napr_lin,sf,otd,dcs from linp_1
 union all
 select dor,lin,dorlin,kst_2,kst_1,nom2,nom1,r_2,r_1,-1 as napr_lin,sf,otd,dcs from linp_1),


dorlin as
(select distinct dor,lin,dorlin from lin),



mar_n as
(select a.marshr,b.nom,1 as k
	from marshr_ish as a,marshr_ish as b where a.marshr=b.marshr and a.nom=b.nom-1 and a.reg!=b.reg),

marshr as --маршрут расписанный с метками начала действия нового региона
(select marshr,rst,kst,pr_mcd,reg,perelom,nom,k,
 SUM(k) OVER (partition by marshr order by rst) as nomk
 from
(select a.marshr,rst,kst,pr_mcd,reg,perelom,a.nom,case when k=1 or a.nom=1 or perelom='1' then 1 else 0 end as k
from marshr_ish as a left join mar_n as b on a.marshr=b.marshr and a.nom=b.nom 
 where a.marshr in (select distinct marshr from prig_opis)
) as c),


sts as --список всех ВАРИАНТОВ  по перегонам-регионам маршрутов
(select marshr,st1,st2,rasst,regg,
 ROW_NUMBER() over (order by marshr,st1,st2,rasst,regg) as nom_sts
 from
 (select distinct marshr,st1,st2,rasst,regg from prig_opis) as a),


sts1_0 as --список всех ВАРИАНТОВ  найденых в маршрутах
(select a.marshr,st1,st2,rasst,b.rst as rst1,c.rst as rst2,regg,nom_sts,
 b.nomk as nomk1,c.nomk as nomk2,b.nom as nom1,c.nom as nom2,b.reg as reg1,c.reg as reg2
 from sts as a
 	left join marshr as b on a.marshr=b.marshr and st1=b.kst
	left join marshr as c on a.marshr=c.marshr and st2=c.kst),
	
	
stan_bad as --список каких станций не хватает в маршрутах  --29 штук
(select distinct marshr,kst from 
(select  marshr,st1 as kst,rst1 as rst from sts1_0 union all 
 select  marshr,st2 as kst,rst2 as rst  from sts1_0)  as a
		where rst is null ),	
	
sts1 as -- если внутри маршрута несколько вариантов - оставить 1 вариант. лучший по расстоянию
(select marshr,st1,st2,rasst,rst1,rst2,regg,nom_sts,nom1,nom2,nomk1,nomk2,reg1,reg2,
 case when rst1<rst2 then 1 else -1 end as napr_mar,rasst-abs(rst1-rst2) as dd
 from
(select *,ROW_NUMBER() over (partition by  nom_sts order by dd) as nd
 from
(select marshr,st1,st2,rasst,rst1,rst2,regg,nom_sts,nom1,nom2,nomk1,nomk2,reg1,reg2,
 abs(rasst-abs(rst1-rst2)) as dd
 from sts1_0 where rst1 is not null and rst2 is not null) as a) as b where nd=1
union all
 select marshr,st1,st2,rasst,NULL as rst1,NULL as rst2,regg,nom_sts,
 0 as nom1,0 as nom2,0 as nomk1,0 as nomk2,0 as reg1,0 as reg2,0 as napr_mar,NULL as dd
  from (select distinct marshr,st1,st2,rasst,regg,nom_sts from sts1_0  where rst1 is null or rst2 is null) as c
),
	
		
--rast_bad as --список пар станций с неправильно установленными расстояниями
--(select marshr,st1,st2,rasst,min(midnum) as midnum from sts1 where dd>0 and dd is not null group by 1,2,3,4),
		
		
sts_good as --список вариантов, укладывающихся строго в 1 регион
(select marshr,st1,st2,rasst,regg,rst1,rst2,reg1 as reg,nom_sts from sts1 where nomk1=nomk2 and nomk1>0 and dd=0),

sts2 as -- нужные к поиску пары станций, в обоих направлениях
(select marshr,st1,st2,rasst,regg,rst1,rst2,nom1,nom2,nomk1,nomk2,nom_sts,
 --case when rst1<rst2 then 1 else -1 end as 
 napr_mar,
 ROW_NUMBER() over (order by marshr,st1,st2,rasst,regg,rst1,rst2,nom1,nom2,nomk1,nomk2,reg1) as nnnn
 from sts1 --where nomk1!=nomk2 
),


mars_p as --пары станций маршрута внутри 1 региона, туда
(select a.marshr,a.kst as kst1,b.kst as kst2,a.nom as nom1,b.nom as nom2,a.nomk,abs(b.rst-a.rst) as rast,
 case when a.nom<b.nom then 1 else -1 end as napr_mar,
 case when a.reg=0 then b.reg when b.reg=0 then a.reg
 	when a.perelom='1' then b.reg when b.perelom='1' then a.reg 
 	when a.reg!=b.reg then -1 else a.reg end as reg,
 case when a.pr_mcd='1' and b.pr_mcd='1' then '1' else '0' end as pr_mcd
from marshr as a,marshr as b where a.marshr=b.marshr and 
 --a.nom<b.nom and ((a.nomk=b.nomk-1 and  b.k=1) or (a.nomk=b.nomk and a.k=1 and a.nom>1))	
 abs(a.nom-b.nom)=1
),

sts_3 as -- нужные к поиску пары станций, в направлении маршрута
(select marshr,st1,st2,rasst,regg,rst1,rst2,nom1,nom2,nomk1,nomk2,napr_mar,nnnn,nom_sts
  from sts2 where napr_mar=1
union all
 select marshr,st1,st2,rasst,regg,rst2,rst1,nom2,nom1,nomk2,nomk1,napr_mar,nnnn,nom_sts
  from sts2 where napr_mar=-1),


umn as --роспись всех кусков, только в направлении маршрута
(select a.marshr,st1,st2,rasst,regg,a.napr_mar,nnnn,kst1,kst2,b.nom1,b.nom2,rast,b.reg,nom_sts,pr_mcd
		from sts_3 as a,mars_p as b
where a.marshr=b.marshr and b.nom1 between a.nom1 and a.nom2 and b.nom2 between a.nom1 and a.nom2
 and a.napr_mar=b.napr_mar
--	and ((a.nomk1<nomk and beg_=1) or a.nom1=b.nom1) and ((a.nomk2>nomk and end_=1) or a.nom2=b.nom2) 
),
	
	
umn_1 as --роспись всех кусков, только в направлении маршрута
(select marshr,pr_mcd,st1,st2,rasst,regg,nom_sts,napr_mar as napr,kst1,kst2,nom1,nom2,rast,reg,nnnn,
ROW_NUMBER() over (partition by nom_sts order by napr_mar*nom1) as nom_mar
from
(select marshr,pr_mcd,st1,st2,rasst,regg,nom_sts,napr_mar,nnnn,kst1,kst2,nom1,nom2,rast,reg
		from umn
union all
select marshr,'0' as pr_mcd,st1,st2,rasst,regg,nom_sts,napr_mar,0 as nnnn,st1 as kst1,st2 as kst2,nom1,nom2,rasst as rast,0 as reg
		from sts1 where napr_mar=0 --добавление маршрутов ошибок - ни туда, ни обратно
 ) as a),
	
stsm as --список всех перегонов по линиям
(select *,ROW_NUMBER() over (order by kst1,kst2,rast) as nom_stsm from
(select distinct kst1,kst2,rast from umn_1) as a),
	
	
--НАДО поставить возможность неточного определения расстояния, если точное никак нельзя
stsm_1 as --кого смогли найти внутри 1 линии, минимальное отличие расстояний
--добавил rst_lin- получившеся расстояние по линиям, возможно отлично от rast. И dr - разница расстояний
(select nom_stsm,kst1,kst2,rast,dorlin,r1,r2,/*reg1,reg2,nreg1,nreg2,*/nom1,nom2,rst_lin,abs(rast-rst_lin) as dr from
(select nom_stsm,kst1,kst2,rast,dorlin,r1,r2,/*reg1,reg2,nreg1,nreg2,*/nom1,nom2,rst_lin,
 ROW_NUMBER() over (partition by nom_stsm order by dr,dorlin) as nom
 from
(select nom_stsm,kst1,kst2,rast,b.dorlin,b.rst as r1,c.rst as r2,abs(b.rst-c.rst) as rst_lin,
 /*b.reglin as reg1,c.reglin as reg2,b.nreg as nreg1,c.nreg as nreg2,*/
 b.nom as nom1,c.nom as nom2,abs(rast-abs(b.rst-c.rst)) as dr
 from stsm as a join lin as b on kst1=b.kst join lin as c on kst2=c.kst and b.dorlin=c.dorlin) as d)as e where nom=1),
	
	

lin2 as -- пересечения всех линий
(select a.dorlin,a.kst,a.rst,b.dorlin as dorlinp,b.rst as rstp,a.nom,b.nom as nomp
from lin as a,lin as b where a.kst=b.kst and (a.dorlin!=b.dorlin)),


stsm_2 as --поиск по точному совпадению растояний, по 2 линиям
--добавил rst_lin- получившеся расстояние по линиям, возможно отлично от rast. И dr - разница расстояний
(select * from
(select *,row_number() over (partition by nom_stsm order by dr) as nn
 from
(select *,abs(abs(rst1-rst_1)+abs(rst2-rstp1)-rast) as dr,abs(rst1-rst_1)+abs(rst2-rstp1) as rst_lin
 from
(select kst1,kst2,rast,nom_stsm,b.dorlin as dorlin1,b.rst as rst1,b.nom as nom1,c.dorlin as dorlin2,c.rst as rst2,c.nom as nom2,
	d.kst as kst_1,d.rst as rst_1,d.nom as nom_1,d.rstp as rstp1,d.nomp as nomp1, d.dorlinp
--	e.kst as kst_2,e.rst as rst_2,e.nom as nom_2,e.rstp as rstp2,e.nomp as nomp2
from  (select * from stsm
 where nom_stsm not in(select nom_stsm from stsm_1 where dr=0)) as a
join lin as b on kst1=b.kst join lin as c on kst2=c.kst
join lin2 as d on b.dorlin=d.dorlin and c.dorlin=d.dorlinp) as f
) as g) as h where nn=1),


stsm_2_1 as --преобразование найденного к нормальному списочному виду
(select  kst1,kst2,rast,nom_stsm,rst_lin,dr,kst1 as st1,kst_1 as st2,dorlin1 as dorlin,nom1,nom_1 as nom2,
 rst1 as r1,rst_1 as r2,1 as np
from stsm_2
union all
select  kst1,kst2,rast,nom_stsm,rst_lin,dr,kst_1 as st1,kst2 as st2,dorlin2 as dorlin,nomp1 as nom1,nom2,
 rstp1 as r1,rst2 as r2,2 as np
from stsm_2),




stsm_3 as --поиск по точному совпадению растояний, по 3 линиям
--добавил rst_lin- получившеся расстояние по линиям, возможно отлично от rast. И dr - разница расстояний
(select * from
(select *,row_number() over (partition by nom_stsm order by dr) as nn
 from
(select *,abs(abs(rst1-rst_1)+abs(rst2-rst_2)+abs(rstp1-rstp2)-rast) as dr,abs(rst1-rst_1)+abs(rst2-rst_2)+abs(rstp1-rstp2) as rst_lin
 from
(select kst1,kst2,rast,nom_stsm,b.dorlin as dorlin1,b.rst as rst1,b.nom as nom1,c.dorlin as dorlin2,c.rst as rst2,c.nom as nom2,
	d.kst as kst_1,d.rst as rst_1,d.nom as nom_1,d.dorlinp,d.rstp as rstp1,d.nomp as nomp1,
	e.kst as kst_2,e.rst as rst_2,e.nom as nom_2,e.rstp as rstp2,e.nomp as nomp2
from  (select * from stsm
 where nom_stsm not in(select nom_stsm from stsm_1 where dr=0) and nom_stsm not in(select nom_stsm from stsm_2 where dr=0)) as a
join lin as b on kst1=b.kst join lin as c on kst2=c.kst
join lin2 as d on b.dorlin=d.dorlin 
join lin2 as e on c.dorlin=e.dorlin and d.dorlinp=e.dorlinp) as f
--where rast=abs(rst1-rst_1)+abs(rst2-rst_2)+abs(rstp1-rstp2)
) as g) as h where nn=1),


stsm_3_1 as --преобразование найденного к нормальному списочному виду
(select  kst1,kst2,rast,nom_stsm,rst_lin,dr,kst1 as st1,kst_1 as st2,dorlin1 as dorlin,nom1,nom_1 as nom2,
 rst1 as r1,rst_1 as r2,1 as np
from stsm_3
union all
select  kst1,kst2,rast,nom_stsm,rst_lin,dr,kst_1 as st1,kst_2 as st2,dorlinp as dorlin,nomp1 as nom1,nomp2 as nom2,
 rstp1 as r1,rstp2 as r2,2 as np
from stsm_3
union all 
select  kst1,kst2,rast,nom_stsm,rst_lin,dr,kst_2 as st1,kst2 as st2,dorlin2 as dorlin,nom_2 as nom1,nom2,
 rst_2 as r1,rst2 as r2,3 as np
from stsm_3),




stsm_4 as --поиск по точному совпадению растояний, по 4 линиям
--добавил rst_lin- получившеся расстояние по линиям, возможно отлично от rast. И dr - разница расстояний
(select * from
(select *,row_number() over (partition by nom_stsm order by dr) as nn
 from
(select *,
 abs(rst1-rst_1)+abs(rstp1-rstp_1)+abs(rstp2-rstp_2)+abs(rst2-rst_2) as rst_lin,
 abs(abs(rst1-rst_1)+abs(rstp1-rstp_1)+abs(rstp2-rstp_2)+abs(rst2-rst_2)-rast) as dr
 from
(select
 kst1,kst2,rast,nom_stsm,b.dorlin as dorlin1,b.rst as rst1,b.nom as nom1,c.dorlin as dorlin2,c.rst as rst2,c.nom as nom2,
	d.kst as kst_1,d.rst as rst_1,d.nom as nom_1,d.dorlinp as dorlinp1,d.rstp as rstp1,d.nomp as nomp1,
	e.kst as kst_2,e.rst as rst_2,e.nom as nom_2,e.dorlinp as dorlinp2,e.rstp as rstp2,e.nomp as nomp2,
 	f.kst as kstp,f.rst as rstp_1,f.nom as nomp_1,f.rstp as rstp_2,f.nomp as nomp_2
from  (select * from stsm
 where nom_stsm not in(select nom_stsm from stsm_1 where dr=0) and nom_stsm not in(select nom_stsm from stsm_2 where dr=0)
	   and nom_stsm not in(select nom_stsm from stsm_3 where dr=0)) as a
join lin as b on kst1=b.kst join lin as c on kst2=c.kst
join lin2 as d on b.dorlin=d.dorlin 
join lin2 as e on c.dorlin=e.dorlin --and d.dorlinp=e.dorlinp
 join lin2 as f on d.dorlinp=f.dorlin and f.dorlinp=e.dorlinp
) as f 
 --where rast= abs(rst1-rst_1)+abs(rstp1-rstp_1)+abs(rstp2-rstp_2)+abs(rst2-rst_2)
) as g) as h where nn=1),



stsm_4_1 as --преобразование найденного к нормальному списочному виду
--добавил rst_lin- получившеся расстояние по линиям, возможно отлично от rast. И dr - разница расстояний
(select  kst1,kst2,rast,nom_stsm,rst_lin,dr,kst1 as st1,kst_1 as st2,dorlin1 as dorlin,nom1,nom_1 as nom2,
 rst1 as r1,rst_1 as r2,1 as np
from stsm_4
union all 
select  kst1,kst2,rast,nom_stsm,rst_lin,dr,kst_1 as st1,kstp as st2,dorlinp1 as dorlin,nomp1 as nom1,nomp_1 as nom2,
 rstp1 as r1,rstp_1 as r2,2 as np
from stsm_4
union all  
select  kst1,kst2,rast,nom_stsm,rst_lin,dr,kstp as st1,kst_2 as st2,dorlinp2 as dorlin,nomp_2 as nom1,nomp2 as nom2,
 rstp_2 as r1,rstp2 as r2,3 as np
from stsm_4
union all  
select  kst1,kst2,rast,nom_stsm,rst_lin,dr,kst_2 as st1,kst2 as st2,dorlin2 as dorlin,nom_2 as nom1,nom2,
 rst_2 as r1,rst2 as r2,4 as np
from stsm_4),





stsm_p_0  as --объединение всех найденных
(select nom_stsm,kst1,kst2,rast,dorlin,st_1,st_2,np,r1,r2,nom1,nom2,rst_lin,dr,ff,
 /*case when nreg1=nreg2 then reg1 when nom1=nom2-1 then reg1 when nom1=nom2+1 then reg2 else 0 end as reg,*/
	case when r1<r2 then 1 else -1 end as napr_lin,abs(r1-r2) as rst,
 sum(abs(r1-r2)) over (partition by nom_stsm,ff) as srst,sum(abs(r1-r2)) over (partition by nom_stsm,ff order by np) as srst_
 from 
(select nom_stsm,kst1,kst2,rast,rst_lin,dr,dorlin,r1,r2,/*reg1,reg2,*/kst1 as st_1,kst2 as st_2,/*nreg1,nreg2,*/nom1,nom2,0 as np,1 as ff from stsm_1 
 union all
 select  nom_stsm,kst1,kst2,rast,rst_lin,dr,dorlin,r1,r2,/*0 as reg1,0 as reg2,*/st1 as st_1,st2 as st_2,
 /*0 as nreg1,0 as nreg2,*/nom1,nom2, np,2 as ff
 from stsm_2_1 
 union all
 select  nom_stsm,kst1,kst2,rast,rst_lin,dr,dorlin,r1,r2,/*0 as reg1,0 as reg2,*/st1 as st_1,st2 as st_2,
 /*0 as nreg1,0 as nreg2,*/nom1,nom2, np,3 as ff 
 from stsm_3_1 
 union all
 select  nom_stsm,kst1,kst2,rast,rst_lin,dr,dorlin,r1,r2,/*0 as reg1,0 as reg2,*/st1 as st_1,st2 as st_2,
 /*0 as nreg1,0 as nreg2,*/nom1,nom2, np,4 as ff 
 from stsm_4_1
) as a),


stsm_p as
(select b.nom_stsm,kst1,kst2,rast,dorlin,st_1,st_2,np,r1,r2,nom1,nom2,rst_lin,dr,b.ff,/*reg,*/napr_lin,rst,srst,srst_
 from
(select nom_stsm,ff from
(select nom_stsm,ff,row_number() over(partition by nom_stsm order by dr,ff,np) as nn
from stsm_p_0) as a where nn=1) as b join stsm_p_0 as c on b.nom_stsm=c.nom_stsm and b.ff=c.ff),

		
umn_2 as --полная роспись всех кусков, только в направлении маршрута
(select marshr,pr_mcd,st1,st2,rasst,regg,nom_sts,napr_mar,nnnn,
 nom_stsm,dorlin,/*np,r1,r2,*/nom1,nom2,napr_lin,
 case when np>0 then st_1 else kst1 end as kst1,
 case when np>0 then st_2 else kst2 end as kst2,
 case when rast=0 and marshr=0 then abs(r1-r2)  --заплатка на пустой маршрут 13.12.2021
 	when np=0 or np is null then rast
 	when rast=srst then rst else round(srst_*rast/srst)-round((srst_-rst)*rast/srst) end as rast,
 ROW_NUMBER() over (partition by nom_sts order by nom_mar,np) as nom_mar
 from 
(select marshr,pr_mcd,st1,st2,rasst,regg,nom_sts,napr as napr_mar,a.kst1,a.kst2,a.rast,a.reg as reg_mar,nnnn,nom_mar, 
 nom_stsm,dorlin,st_1,st_2,np,r1,r2,b.nom1,b.nom2,/*b.reg as reg_lin,*/napr_lin,rst,srst,srst_
from umn_1 as a left join stsm_p as b
on a.kst1=b.kst1 and a.kst2=b.kst2 and a.rast=b.rast order by nom_sts,nom_mar,np) as c),

	
stsm_rez as
(select marshr,pr_mcd,st1,st2,rasst,regg,nom_sts,napr_mar,nnnn,nom_mar,nom_stsm,dorlin,napr_lin,kst1,kst2,np,sf,otd,dcs,
 case when rasst=srst then rst else round(srst_*rasst/srst)-round((srst_-rst)*rasst/srst) end as rast
 --не нужные поля  ,srst,rst,srst_
 from 
(select marshr,pr_mcd,st1,st2,rasst,regg,nom_sts,napr_mar,nnnn,nom_mar,nom_stsm,a.dorlin,a.napr_lin,rast,sf,otd,dcs,
 b.nom1,b.nom2,kst_1 as kst1,kst_2 as kst2,r_1,r_2,abs(r_1-r_2) as rst,
 sum(abs(r_1-r_2)) over (partition by nom_sts) as srst,
 sum(abs(r_1-r_2)) over (partition by nom_sts order by nom_mar,a.napr_lin*b.nom1) as srst_,
 ROW_NUMBER() over (partition by nom_sts order by nom_mar,a.napr_lin*b.nom1) as np
 from
(select marshr,pr_mcd,st1,st2,rasst,regg,nom_sts,napr_mar,nnnn,nom_mar,nom_stsm,dorlin,napr_lin,rast,
 case when nom1<nom2 then nom1 else nom2 end as nom1,case when nom1<nom2 then nom2 else nom1 end as nom2
 from umn_2 where dorlin is not null)   as a join linp as b
 on a.dorlin=b.dorlin  and a.napr_lin=b.napr_lin and b.nom1 between a.nom1 and a.nom2 and b.nom2 between a.nom1 and a.nom2 
 ) as c),
	
/*	
umn_3 as --полная роспись всех кусков  -- 100059 =35sek  ==108462 35сек
(select distinct marshr,pr_mcd,st1,st2,rasst,regg,nom_sts,napr_mar,nnnn,kst1,kst2,rast,
 case when nom_stsm is null then 0 else nom_stsm end as nom_stsm,
 case when dorlin is null then 0 else dorlin end as dorlin,
 case when napr_lin is null then 0 else napr_lin end as napr_lin,
  ROW_NUMBER() over (partition by nom_sts order by nom_mar,np) as nom_mar,sf,otd,dcs,
 max(nom_mar) over (partition by marshr,st1,st2,rasst,regg) as max_nom_mar
 from
(select marshr,pr_mcd,st1,st2,rasst,regg,nom_sts,napr_mar,nnnn,nom_mar,
 nom_stsm,dorlin,napr_lin,kst1,kst2,rast,np,sf,otd,dcs
 from stsm_rez
 	union all
	select marshr,pr_mcd,st1,st2,rasst,regg,nom_sts,napr_mar,nnnn,nom_mar,
 nom_stsm,dorlin,napr_lin,kst1,kst2,rast,0 as np,0 as sf,0 as otd,0 dcs
 from umn_2 where  dorlin is null) as a ) ,*/
 
 

umn_3 as --полная роспись всех кусков  -- 100059 =35sek  ==108462 35сек
(select  *,max(nom_mar) over (partition by marshr,st1,st2,rasst,regg) as max_nom_mar
from
(select distinct marshr,pr_mcd,st1,st2,rasst,regg,nom_sts,napr_mar,nnnn,kst1,kst2,rast,
 case when nom_stsm is null then 0 else nom_stsm end as nom_stsm,
 case when dorlin is null then 0 else dorlin end as dorlin,
 case when napr_lin is null then 0 else napr_lin end as napr_lin,
  ROW_NUMBER() over (partition by nom_sts order by nom_mar,np) as nom_mar,sf,otd,dcs
 from
(select marshr,pr_mcd,st1,st2,rasst,regg,nom_sts,napr_mar,nnnn,nom_mar,
 nom_stsm,dorlin,napr_lin,kst1,kst2,rast,np,sf,otd,dcs
 from stsm_rez
 	union all
	select marshr,pr_mcd,st1,st2,rasst,regg,nom_sts,napr_mar,nnnn,nom_mar,
 nom_stsm,dorlin,napr_lin,kst1,kst2,rast,0 as np,0 as sf,0 as otd,0 dcs
 from umn_2 where  dorlin is null) as a ) as b),

 
 
--------------------- mcd,mcd_,

prig_opis_mars as --роспись всех маршрутов в виде минимальных перегонов        -- 143003  7sek  --165212
(select idnum,opis,sto,stn,marshr,nom,regg,st1,st2,rst,sto_zone,stn_zone,sti,sti_zone,d_plata,d_poteri,dorlin,sf,otd,dcs,
 case when regg!=0 then regg else sf end as reg,
 case when marshr>0 then srasst else (sum(rst) over (partition by idnum)) end as srasst,
 case when pr_mcd='1' then mcd else 0 end as mcd
 from 
(select idnum,opis,sto,stn,srasst,a.marshr,mcd,pr_mcd,sto_zone,stn_zone,sti,sti_zone,
 case when dorlin is null then 0 else dorlin end as dorlin,a.regg,
ROW_NUMBER() over (partition by idnum order by nom,nom_mar) as nom,
case when b.nom_sts is null then a.st1 else b.kst1 end as st1,
case when b.nom_sts is null then a.st2 else b.kst2 end as st2,
case when b.nom_sts is null then a.rasst else b.rast end as rst,sf,otd,dcs,
 case when a.st2=kst2 and nom_mar=max_nom_mar then d_plata end as d_plata,
 case when a.st2=kst2 and nom_mar=max_nom_mar then d_poteri end as d_poteri
from prig_opis as a left join umn_3 as b 
 on   a.marshr=b.marshr and a.st1=b.st1 and a.st2=b.st2 and a.rasst=b.rasst and a.regg=b.regg
) as c) ,


err_opis_mars as
(select idnum,opis,dor,lin,st1,st2,regg as reg
from
(select idnum,opis,dorlin,st1,st2,regg,sf,round(dorlin/10000) as dor,mod(dorlin,10000) as lin,
 min(opis) over(partition by dorlin,st1,st2) as mopis
 from prig_opis_mars where regg>0 and regg!=sf) as a
 where opis=mopis),
 
  
itog as
(select 6 as rez,idnum,opis,sto,stn,marshr,mcd,nom,st1,st2,rst,sto_zone,stn_zone,sti,sti_zone,d_plata,d_poteri,
	round(dorlin/10000) as dor,mod(dorlin,10000) as lin,otd,dcs,reg,srasst,0 as k_bil
 from prig_opis_mars
union all	
select 99 as rez,IDNUM,opis,0 as sto,0 as stn,0 as marshr,0 as mcd,0 as nom,st1,st2,0 as rst,0 as sto_zone,0 as stn_zone,
	0 as sti,0 as sti_zone,0 as d_plata,0 as d_poteri,dor,lin,0 as otd,0 as dcs,reg,0 as srasst,0 as k_bil from err_opis_mars
)
 
/**/ 
select rez,idnum,opis,sto,stn,marshr,mcd,nom,st1,st2,rst,sto_zone,stn_zone,sti,sti_zone,d_plata,d_poteri,dor,lin,otd,dcs,reg,srasst,k_bil 
from itog
; 
/**/

--select count(*) from itog =645187
--err_opis_mars =7
--prig_opis_mars  =645180
--umn_3  =582478
-- prig_opis  51856



/**/
--- ввод времени окончания операции с итоговым числом записей
insert into  l3_prig.prig_times(time,date,dann,libr,oper,time2,date_zap,part_zap,shema,rezult)
with a as
(select date_zap,part_zap,dann,libr,shema,current_date as date,substr(cast(clock_timestamp()::time as char(50)),1,12) as time
	from  l3_prig.prig_times where dann='prig' and oper='dannie'),
b as (select count(*) as rezult from l3_prig.prig_work)
select time,date,dann,libr,'prig_work 2_22_rez' as oper,
(cast(substr(time,1,2) as dec(3))*60+cast(substr(time,4,2) as dec(3)))*60+cast(substr(time,7,6) as dec(7,3)) as time2,date_zap,part_zap,shema,rezult
from a, b;


/**/


-- select * from l3_prig.prig_times where part_zap in(select part_zap from l3_prig.prig_times where oper='dannie')






/**/



