
--ПЕРЕГОН ПОЛУЧЕННЫХ ДАННЫХ В СПРАВОЧНИКИ БИЛЕТОВ И МАРШРУТОВ, РАСЧЁТ ПЕРВИЧНЫХ АГРЕГАТОВ ПО СТАНЦИЯМ

/*
delete from spb_prig.prig_bad;
delete from spb_prig.prig_mars;
delete from spb_prig.prig_bil;
delete from spb_prig.prig_itog;
delete from spb_prig.prig_agr_kst;
delete from spb_prig.prig_agr_pereg;
*/


--select * from spb_prig.prig_work


--- ввод времени начала операции
insert into  spb_prig.prig_times(time,date,oper,time2,date_zap)
with a as
(select current_date as date,substr(cast(current_time as char(50)),1,12) as time_,substr(cast(clock_timestamp()::time as char(50)),1,12) as time),
b as
(select date_zap from  spb_prig.prig_times where oper='dannie')
select time,date,'prig_agr 1_beg' as oper,
(cast(substr(time,1,2) as dec(3))*60+cast(substr(time,4,2) as dec(3)))*60+cast(substr(time,7,6) as dec(7,3)) as time2,date_zap
from a left join b on 1=1;


insert into spb_prig.prig_mars
(nom_mar,sto,stn,srasst,marshr,nom,reg,st1,st2,rst,sto_zone,stn_zone,sti,sti_zone,dor,lin,date_zap)
select
nom_mar,sto,stn,srasst,marshr,nom,reg,st1,st2,rst,sto_zone,stn_zone,sti,sti_zone,dor,lin,date_zap
from spb_prig.prig_work where rez=3;-- and nom_mar<=500;

delete from spb_prig.prig_work where rez=3;

--запись всех видов ошибок в маршрутах
insert into spb_prig.prig_bad
(marshr,st1,st2,rst,reg,dor,lin,date_zap,id)
select
marshr,st1,st2,rst,reg,dor,lin,date_zap,id
from spb_prig.prig_work where rez=9;-- and nom_mar<=500;




insert into spb_prig.prig_bil
(nom_bil,flg_ruch,vid_rasch,FLG_CHILD,flg_voin,FLG_MILITARY,flg_lgt,FLG_BSP,FLG_SO,FLG_NU,FLG_TT,
klass,kod_lgt,lgt_reg,flg_bag,bag_vid,bag_ves,FLG_tuda_obr,flg_rab_day,proc_lgt,ABONEMENT_TYPE,
k_pas,srok_bil,srok_mon,TRAIN_CATEGORY,TRAIN_NUM,date_zap,grup_lgt)
select
nom_bil,flg_ruch,vid_rasch,FLG_CHILD,flg_voin,FLG_MILITARY,flg_lgt,FLG_BSP,FLG_SO,FLG_NU,FLG_TT,
klass,kod_lgt,lgt_reg,flg_bag,bag_vid,bag_ves,FLG_tuda_obr,flg_rab_day,proc_lgt,ABONEMENT_TYPE,
k_pas,srok_bil,srok_mon,TRAIN_CATEGORY,TRAIN_NUM,date_zap,
cast(substr(cast(kod_lgt as char(4)),1,2) as dec(3)) as grup_lgt
from spb_prig.prig_work where rez=2;    -- and nom_bil<=400;



insert into spb_prig.prig_itog
(nom_bil,nom_mar,YYYYMM,date_zap,date_beg,id,doc_num,TERM_POS,TERM_DOR,date,agent,chp,stp,stp_reg,
sto,stn,sto_reg,stn_reg,srasst,flg_bag,FLG_tuda_obr,kol_bil,plata,poteri,perebor,
 nedobor,nom,reg,d_plata,d_poteri,sf_pas,kol_pas)

select nom_bil,nom_mar,YYYYMM,date_zap,date_beg,id,doc_num,TERM_POS,TERM_DOR,date,agent,chp,stp,stp_reg,
sto,stn,sto_reg,stn_reg,srasst,flg_bag,FLG_tuda_obr,kol_bil,plata,poteri,perebor,
 nedobor,nom,reg,d_plata,d_poteri,sf_pas,kol_pas
from spb_prig.prig_work where rez=1;



--- ввод времени начала операции
insert into  spb_prig.prig_times(time,date,oper,time2,date_zap)
with a as
(select current_date as date,substr(cast(current_time as char(50)),1,12) as time_,substr(cast(clock_timestamp()::time as char(50)),1,12) as time),
b as
(select date_zap from  spb_prig.prig_times where oper='dannie')
select time,date,'prig_agr 2_vvod' as oper,
(cast(substr(time,1,2) as dec(3))*60+cast(substr(time,4,2) as dec(3)))*60+cast(substr(time,7,6) as dec(7,3)) as time2,date_zap
from a left join b on 1=1;





--delete from spb_prig.prig_agr_kst;

--заполнение постанционных агрегатов
insert into spb_prig.prig_agr_kst
(YYYYMM,date_zap,date_beg,TERM_DOR,nom_bil,date,agent,chp,kst,reg,FLG_CHILD,FLG_MILITARY,kod_lgt,ABONEMENT_TYPE,dor,lin,par_name,param)



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
(select c.kst,name,c.dor,vc,otd,case when lin is null then 0 else lin end as lin--,reg
 from
(select kst,name,cast(dor3 as smallint) as dor,vc,cast(otd as smallint) as otd--,reg
from stan_ as a,dor as b where a.dor=b.dor) as c
left join (select kst,dor,min(lin) as lin from lin group by 1,2) as d on c.kst=d.kst and c.dor=d.dor
),

mars as
(select nom_mar,--sto,stn,
 max(case when nom=1 then dor else 0 end) as dor1,max(case when nom=1 then lin else 0 end) as lin1,
 max(case when nom=mnom then dor else 0 end) as dor2,max(case when nom=mnom then lin else 0 end) as lin2

  from
(select nom_mar,sto,stn,srasst,marshr,nom,reg,st1,st2,rst,sto_zone,stn_zone,sti,sti_zone,dor,lin,
 max(nom) over(partition by nom_mar) as mnom from spb_prig.prig_mars) as a group by 1),

dann as
(select nom_bil,YYYYMM,date_zap,date_beg,id,doc_num,TERM_POS,TERM_DOR,date,agent,chp,stp,stp_reg,--a.nom_mar,
sto,stn,sto_reg,stn_reg,srasst,flg_bag,FLG_tuda_obr,kol_bil,plata,poteri,perebor,
 nedobor,nom,reg,d_plata,d_poteri,sf_pas,kol_pas,dor1,lin1,dor2,lin2,c.dor as dorp,c.lin as linp,
 cast(flg_tuda_obr as dec(3)) as k_to
 from spb_prig.prig_itog as a left join mars as b on a.nom_mar=b.nom_mar
left join stan as c on stp=kst
 where date_zap in(select distinct date_zap from date)
)
 

select YYYYMM,b.date_zap,date_beg,TERM_DOR,b.nom_bil,date,agent,chp,kst,reg,FLG_CHILD,FLG_MILITARY,kod_lgt,ABONEMENT_TYPE,dor,lin,par_name,param
from 
(select YYYYMM,date_zap,date_beg,TERM_DOR,nom_bil,date,agent,chp,kst,reg,dor,lin,par_name,sum(param) as param from 
(
select id,YYYYMM,date_zap,date_beg,TERM_DOR,nom_bil,date,agent,chp,stp as kst,stp_reg as reg,dorp as dor,linp as lin,'plata' as par_name,plata as param
from dann where plata!=0 and flg_bag='0'

union all
select id,YYYYMM,date_zap,date_beg,TERM_DOR,nom_bil,date,agent,chp,stp as kst,stp_reg as reg,dorp as dor,linp as lin,'poteri' as par_name,poteri as param
from dann where poteri!=0 and flg_bag='0'

union all
select id,YYYYMM,date_zap,date_beg,TERM_DOR,nom_bil,date,agent,chp,stp as kst,stp_reg as reg,dorp as dor,linp as lin,'perebor' as par_name,perebor as param
from dann where perebor!=0
union all
select id,YYYYMM,date_zap,date_beg,TERM_DOR,nom_bil,date,agent,chp,stp as kst,stp_reg as reg,dorp as dor,linp as lin,'nedobor' as par_name,nedobor as param
from dann where nedobor!=0

union all
select id,YYYYMM,date_zap,date_beg,TERM_DOR,nom_bil,date,agent,chp,stp as kst,stp_reg as reg,dorp as dor,linp as lin,'bag_plata' as par_name,plata as param
from dann where plata!=0 and flg_bag='1'
union all

select id,YYYYMM,date_zap,date_beg,TERM_DOR,nom_bil,date,agent,chp,stp as kst,stp_reg as reg,dorp as dor,linp as lin,'bag_poteri' as par_name,poteri as param
from dann where poteri!=0 and flg_bag='1'

union all
select id,YYYYMM,date_zap,date_beg,TERM_DOR,nom_bil,date,agent,chp,stp as kst,stp_reg as reg,dorp as dor,linp as lin,'kol_bil' as par_name,kol_bil as param
from dann where kol_bil!=0 and flg_bag='0'

union all
select id,YYYYMM,date_zap,date_beg,TERM_DOR,nom_bil,date,agent,chp,stp as kst,stp_reg as reg,dorp as dor,linp as lin,'bag_bil' as par_name,kol_bil as param
from dann where kol_bil!=0 and flg_bag='1'

union all
select id,YYYYMM,date_zap,date_beg,TERM_DOR,nom_bil,date,agent,chp,stp as kst,stp_reg as reg,dorp as dor,linp as lin,'sf_pas' as par_name,
sf_pas*k_to as param
from dann where sf_pas!=0 and flg_bag='0'

union all
select id,YYYYMM,date_zap,date_beg,TERM_DOR,nom_bil,date,agent,chp,stp as kst,stp_reg as reg,dorp as dor,linp as lin,'sf_pkm' as par_name,
sf_pas*k_to*srasst as param
from dann where sf_pas!=0 and flg_bag='0'


union all
select id,YYYYMM,date_zap,date_beg,TERM_DOR,nom_bil,date,agent,chp,stp as kst,reg,0 as dor,0 as lin,'d_plata' as par_name,d_plata as param
from dann where d_plata!=0 and flg_bag='0'

union all
select id,YYYYMM,date_zap,date_beg,TERM_DOR,nom_bil,date,agent,chp,stp as kst,reg,0 as dor,0 as lin,'d_poteri' as par_name,d_poteri as param
from dann where d_poteri!=0 and flg_bag='0'


union all
select id,YYYYMM,date_zap,date_beg,TERM_DOR,nom_bil,date,agent,chp,sto as kst,sto_reg as reg,dor1 as dor,lin1 as lin,'kol_pas' as par_name,kol_pas as param
from dann where kol_pas!=0 and flg_bag='0'

union all
select id,YYYYMM,date_zap,date_beg,TERM_DOR,nom_bil,date,agent,chp,sto as kst,sto_reg as reg,dor1 as dor,lin1 as lin,'kol_pkm' as par_name,
kol_pas*srasst as param
from dann where kol_pas!=0 and flg_bag='0'


union all
select id,YYYYMM,date_zap,date_beg,TERM_DOR,nom_bil,date,agent,chp,stn as kst,stn_reg as reg,dor2 as dor,lin2 as lin,'kol_pas' as par_name,
kol_pas as param
from dann where kol_pas!=0 and flg_bag='0' and flg_tuda_obr='2'

union all
select id,YYYYMM,date_zap,date_beg,TERM_DOR,nom_bil,date,agent,chp,stn as kst,stn_reg as reg,dor2 as dor,lin2 as lin,'kol_pkm' as par_name,
kol_pas*srasst as param
from dann where kol_pas!=0 and flg_bag='0' and flg_tuda_obr='2'
	) as a
group by 1,2,3,4,5,6,7,8,9,10,11,12,13 ) as b join spb_prig.prig_bil as c on b.nom_bil=c.nom_bil
--where b.date_zap in(select distinct date_zap from date)
;




--- ввод времени окончания операции
insert into  spb_prig.prig_times(time,date,oper,time2,date_zap)
with a as
(select current_date as date,substr(cast(current_time as char(50)),1,12) as time_,substr(cast(clock_timestamp()::time as char(50)),1,12) as time),
b as
(select date_zap from  spb_prig.prig_times where oper='dannie')
select time,date,'prig_agr 3_agr' as oper,
(cast(substr(time,1,2) as dec(3))*60+cast(substr(time,4,2) as dec(3)))*60+cast(substr(time,7,6) as dec(7,3)) as time2,date_zap
from a left join b on 1=1;



--- ввод времени окончания операции ситоговым числом записей
insert into  spb_prig.prig_times(time,date,oper,time2,date_zap,rezult)
with a as
(select current_date as date,substr(cast(clock_timestamp()::time as char(50)),1,12) as time),
b as
(select date_zap from  spb_prig.prig_times where oper='dannie'),
c as (select count(*) as rezult from spb_prig.prig_agr_kst where date_zap in(select date_zap from b))
select time,date,'prig_agr 4_rez' as oper,
(cast(substr(time,1,2) as dec(3))*60+cast(substr(time,4,2) as dec(3)))*60+cast(substr(time,7,6) as dec(7,3)) as time2,date_zap,rezult
from a left join b on 1=1 left join c on 1=1;



--  select distinct par_name,dor,lin from spb_prig.prig_agr_kst where kst=2004162 fetch first 100 rows only

select date_zap,count(*) as rezult from spb_prig.prig_agr_kst group by 1;
















