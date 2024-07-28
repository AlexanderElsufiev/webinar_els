
--delete from spb_prig.prig_itog  where date_zap='2021-07-01';

--ПРОГРАММА НАРАБОТКИ АГРЕГАТОВ ПО ПЕРЕГОНАМ


------непонятно - появились перегоны от станции до неё же.



--- ввод времени начала операции
insert into  spb_prig.prig_times(time,date,oper,time2,date_zap)
with a as
(select current_date as date,substr(cast(current_time as char(50)),1,12) as time_,substr(cast(clock_timestamp()::time as char(50)),1,12) as time),
b as
(select date_zap from  spb_prig.prig_times where oper='dannie')
select time,date,'prig_pereg 1_beg' as oper,
(cast(substr(time,1,2) as dec(3))*60+cast(substr(time,4,2) as dec(3)))*60+cast(substr(time,7,6) as dec(7,3)) as time2,date_zap
from a left join b on 1=1;

--------собственно вычисление

insert into spb_prig.prig_work
(rez,date_zap,YYYYMM,TERM_DOR,nom_bil,date,agent,chp,reg,dor,lin,st1,st2,peregon,
 d_plata,d_poteri,kol_pas,pass_km,otpr_pas,prib_pas)

with
ish as
(select nom_bil,nom_mar,YYYYMM,date_zap,TERM_DOR,date,agent,chp,FLG_tuda_obr,nom,reg,
 d_plata,d_poteri,kol_pas
from spb_prig.prig_itog  as a where flg_bag='0' --and (d_plata!=0 or d_poteri!=0 or kol_pas!=0)
 
 --and nom_bil=382
),

date as (select distinct date_zap from ish),


bileti as
(select nomer_bil,nom_bil 
from  spb_prig.prig_bil as a join 
 (select * from spb_prig.prig_bileti where nomer_bil in 
  (select nomer_bil from spb_prig.prig_bileti_using where substr(spr_name,1,15)='prig_agr_pereg ')) as b
on (a.k_pas=b.k_pas or b.k_pas is null)
and (a.srok_bil=b.srok_bil or b.srok_bil is null)
and (a.srok_mon=b.srok_mon or b.srok_mon is null)
and (a.flg_bag=b.flg_bag or b.flg_bag is null)
and (a.FLG_tuda_obr=b.FLG_tuda_obr or b.FLG_tuda_obr is null)
and (a.flg_rab_day=b.flg_rab_day or b.flg_rab_day is null)
and (a.flg_ruch=b.flg_ruch or b.flg_ruch is null)
and (a.vid_rasch=b.vid_rasch or b.vid_rasch is null)
and (a.FLG_CHILD=b.FLG_CHILD or b.FLG_CHILD is null)
and (a.flg_voin=b.flg_voin or b.flg_voin is null)
and (a.FLG_MILITARY=b.FLG_MILITARY or b.FLG_MILITARY is null)
and (a.flg_lgt=b.flg_lgt or b.flg_lgt is null)
and (a.FLG_BSP=b.FLG_BSP or b.FLG_BSP is null)
and (a.FLG_SO=b.FLG_SO or b.FLG_SO is null)
and (a.FLG_NU=b.FLG_NU or b.FLG_NU is null)
and (a.FLG_TT=b.FLG_TT or b.FLG_TT is null)
and (a.klass=b.klass or b.klass is null)
and (a.kod_lgt=b.kod_lgt or b.kod_lgt is null)
and (a.lgt_reg=b.lgt_reg or b.lgt_reg is null)
and (a.bag_vid=b.bag_vid or b.bag_vid is null)
and (a.bag_ves=b.bag_ves or b.bag_ves is null)
and (a.proc_lgt=b.proc_lgt or b.proc_lgt is null)
and (a.ABONEMENT_TYPE=b.ABONEMENT_TYPE or b.ABONEMENT_TYPE is null)
and (a.TRAIN_CATEGORY=b.TRAIN_CATEGORY or b.TRAIN_CATEGORY is null)
and (a.TRAIN_NUM=b.TRAIN_NUM or b.TRAIN_NUM is null)
and (a.grup_lgt=b.grup_lgt or b.grup_lgt is null)	
),


umn0 as
(select nomer_bil,nom_mar,YYYYMM,date_zap,TERM_DOR,date,agent,chp,FLG_tuda_obr,nom,reg,
 sum(d_plata) as d_plata,sum(d_poteri) as d_poteri,sum(kol_pas) as kol_pas
from ish as a left join bileti as b on a.nom_bil=b.nom_bil
 group by 1,2,3,4,5,6,7,8,9,10,11),


lin_ as --структура всех линий
(select dor,lin,kst,rst,reg,ROW_NUMBER() over (partition by dor,lin order by rst) as nom from
(select cast(nom3d as dec(3)) as dor,cast(noml as dec(3)) as lin,cast(stan as dec(7)) as kst,rstk as rst,cast(sf as dec(3)) as reg
	from nsi.lines as a,date as b where date_zap between datand and datakd and date_zap between datani and dataki) as a),


lin as --в линиях исправлены регионы, и добавлены порядковые номера регионов
(select dor,lin,rst,kst,nom,reg,nreg,max(reg) over (partition by dor,lin,nreg) as reglin,10000*dor+lin as dorlin from
(select dor,lin,rst,kst,nom,reg,rg,sum(nn) over (partition by dor,lin order by nom) as nreg from
(select d.dor,d.lin,rst,kst,d.nom,reg,case when nn=1 then 0 else reg end as rg,
 case when d.nom=1 or reg=0 or nn=1 then 1 else 0 end as nn
from lin_ as d left join
(select a.dor,a.lin,a.nom,1 as nn from lin_ as a,lin_ as b
	where a.dor=b.dor and a.lin=b.lin and a.nom=b.nom+1 and a.reg!=0 and b.reg!=0 and a.reg!=b.reg) as c
	on d.dor=c.dor and d.lin=c.lin and d.nom=c.nom) as e) as f),


mars as
(select *,10000*dor+lin as dorlin,
 case when nom=1 then 1 else 0 end as beg_,
 case when nom=(max(nom) over (partition by nom_mar)) then 1 else 0 end as end_
 from spb_prig.prig_mars),
 
dorlin as (select distinct dorlin,dor,lin from mars),


umn1 as --исходные данные переведены в каждый кусочек маршрута, уже расписанный по ВСЕМ линиям
(select nomer_bil,YYYYMM,date_zap,TERM_DOR,date,agent,chp,FLG_tuda_obr,st1,st2,rast,reg,dorlin,beg_,end_,d_plata,d_poteri,kol_pas,
 row_number() over (order by nomer_bil,YYYYMM,date_zap,TERM_DOR,date,agent,chp,FLG_tuda_obr,st1,st2,rast,reg,dorlin,beg_,end_) as nnnn
 from
(select  nomer_bil,YYYYMM,a.date_zap,TERM_DOR,date,agent,chp,FLG_tuda_obr,beg_,end_,
 st1,st2,rst as rast,b.reg,dorlin,
	sum(d_plata) as d_plata,sum(d_poteri) as d_poteri,sum(kol_pas) as kol_pas
from umn0 as a join mars as b on a.nom_mar=b.nom_mar and (a.nom=0 or a.nom=b.nom)
 group by 1,2,3,4,5,6,7,8,9,10,11,12,13,14,15
) as c),


linp as
(select a.dorlin,a.kst as kst1,b.kst as kst2,a.nom as n1,b.nom as n2,a.rst as r1,b.rst as r2,
case when a.nom<b.nom then 1 else -1 end as napr
from lin as a,lin as b where a.dorlin=b.dorlin and abs(a.nom-b.nom)=1),


umn2 as
(select nomer_bil,YYYYMM,date_zap,TERM_DOR,date,agent,chp,FLG_tuda_obr,
 st1,st2,rast,reg,dorlin,d_plata,d_poteri,kol_pas,rst1,rst2,nnnn,beg_,end_,
 case when dorlin=0 then 0 when nom1<nom2 then 1 else -1 end as napr,abs(rst1-rst2) as rr,
 case when nom1<nom2 then nom1 else nom2 end as nom1,case when nom1>nom2 then nom1 else nom2 end as nom2
 from
(select nomer_bil,YYYYMM,date_zap,TERM_DOR,date,agent,chp,FLG_tuda_obr,nnnn,beg_,end_,
 st1,st2,rast,a.reg,a.dorlin,d_plata,d_poteri,kol_pas,b.nom as nom1,b.rst as rst1,c.nom as nom2,c.rst as rst2
from umn1 as a left join lin as b on a.dorlin=b.dorlin and st1=b.kst
 left join lin as c on a.dorlin=c.dorlin and st2=c.kst) as d),
 
 
umn3 as
(select nomer_bil,YYYYMM,date_zap,TERM_DOR,date,agent,chp,FLG_tuda_obr,reg,dorlin,st1,st2,beg_,end_,rast,
 sum(d_plata) as d_plata,sum(d_poteri) as d_poteri,sum(kol_pas) as kol_pas 
 from
(select nomer_bil,YYYYMM,date_zap,TERM_DOR,date,agent,chp,FLG_tuda_obr,nnnn,reg,a.dorlin,
 case when a.dorlin=0 then st1 else kst1 end as st1,case when a.dorlin=0 then st2 else kst2 end as st2,
 (case when r1=rst1 or a.dorlin=0 then 1 else 0 end)*beg_ as beg_,(case when r2=rst2 or a.dorlin=0 then 1 else 0 end)*end_ as end_,
 case when a.dorlin=0 then rast else a.napr*(round((r2-rst1)*rast/rr)- round((r1-rst1)*rast/rr)) end as rast,
 case when a.dorlin=0 then d_plata else a.napr*(round((r2-rst1)*d_plata/rr)- round((r1-rst1)*d_plata/rr)) end as d_plata,
 case when a.dorlin=0 then d_poteri else a.napr*(round((r2-rst1)*d_poteri/rr)- round((r1-rst1)*d_poteri/rr)) end as d_poteri,
 kol_pas 
 from umn2 as a left join linp as b on a.dorlin=b.dorlin and
 n1 between nom1 and nom2 and n2 between nom1 and nom2 and a.napr=b.napr
) as c group by 1,2,3,4,5,6,7,8,9,10,11,12,13,14,15),



umn4 as --окончательное разбиение в нужных направлениях
(select nomer_bil,YYYYMM,a.date_zap,TERM_DOR,agent,chp,reg,dorlin,st1,st2,
 to_date((extract(year from date)*10000+extract(month from date)*100+28)::text, 'YYYYMMDD') as date,
 sum(d_plata) as d_plata,sum(d_poteri) as d_poteri,sum(kol_pas) as kol_pas,sum(kol_pas*rast) as pass_km,
 sum(kol_pas*beg_) as otpr_pas,sum(kol_pas*end_) as prib_pas,min(rast) as rast
 from
(select nomer_bil,YYYYMM,date_zap,TERM_DOR,date,agent,chp,reg,dorlin,st1,st2,beg_,end_,rast,
 d_plata,d_poteri,kol_pas 
 from umn3 where FLG_tuda_obr='1'
union all 
 select nomer_bil,YYYYMM,date_zap,TERM_DOR,date,agent,chp,reg,dorlin,st1,st2,beg_,end_,rast,
 round(d_plata/2) as d_plata,round(d_poteri/2) as d_poteri,kol_pas 
 from umn3 where FLG_tuda_obr='2'    --было из umn2
union all
select nomer_bil,YYYYMM,date_zap,TERM_DOR,date,agent,chp,reg,dorlin,st2 as st1,st1 as st2,end_ as beg_,beg_ as end_,rast,
 d_plata-round(d_plata/2) as d_plata,d_poteri-round(d_poteri/2) as d_poteri,kol_pas 
 from umn3 where FLG_tuda_obr='2'    --было из umn2
) as a
  --left join bileti as b on a.nom_bil=b.nom_bil
   group by 1,2,3,4,5,6,7,8,9,10,11),
   
   
pereg1 as
(select dorlin,st1,st2,sum(kol_pas) as kol_pas,sum(pass_km) as pass_km,min(rast) as rast,min(date_zap) as date_zap from
(select dorlin,case when st1<st2 then st1 else st2 end as st1,case when st1>st2 then st1 else st2 end as st2,kol_pas,pass_km,rast,date_zap
 from 
 (select dorlin,st1,st2,sum(kol_pas) as kol_pas,sum(pass_km) as pass_km,min(rast) as rast,min(date_zap) as date_zap
	   from umn4 group by 1,2,3) as a) as b group by 1,2,3),
 
pereg_old as (
select 10000*dor+lin as dorlin,st1,st2,peregon
	from spb_prig.prig_peregoni where peregon>10000),
	
	
pereg2 as
(select dorlin,st1,st2,rasst,izz,date_zap,
 case when izz=1 then peregon else mper+nom end as peregon
from
(select dorlin,st1,st2,peregon,rasst,date_zap,
 case when mper is null then 10000 else mper end as mper,izz,
 row_number() over (partition by izz order by dorlin,st1,st2) as nom
 from
(select a.dorlin,a.st1,a.st2,peregon,date_zap,
 case when kol_pas!=0 then round(pass_km/kol_pas) else rast end as rasst,
 case when peregon is null then 0 else 1 end as izz
from pereg1 as a left join pereg_old as b
on a.dorlin=b.dorlin and a.st1=b.st1 and a.st2=b.st2
) as c left join (select max(peregon) as mper from pereg_old) as d on 1=1) as e),


pereg3 as
(select a.dorlin,st1,st2,peregon,dor,lin,rasst,izz,date_zap from 
(select dorlin,st1,st2,peregon,rasst,izz,date_zap from pereg2 
 union all
 select dorlin,st2 as st1,st1 as st2,-peregon as peregon,rasst,izz,date_zap from pereg2) as a
 left join dorlin as b on a.dorlin=b.dorlin),
 
 
 
umn5 as --окончательное разбиение в нужных направлениях
(select nomer_bil,YYYYMM,a.date_zap,TERM_DOR,agent,chp,reg,a.dorlin,dor,lin,a.st1,a.st2,date,
 d_plata,d_poteri,kol_pas,pass_km,otpr_pas,prib_pas,peregon
 from umn4 as a left join pereg3 as b on a.dorlin=b.dorlin and a.st1=b.st1 and a.st2=b.st2)




--select * from umn2 where rr=0;
--select count(*) from umn2   --- 1762769 записи
--select count(*) from umn3   --- 1929713 записи, очень долго
--select count(*) from umn4   --- 54325 записей

--select count(*) from umn5 --- ERROR: ОШИБКА:  деление на ноль

--select count(*) from pereg3 ---ERROR: ОШИБКА:  деление на ноль

--select count(*),sum(case when kol_pas=0 then 1 else 0 end) from pereg1 --- 14309	1
--select * from pereg1 where kol_pas=0 --- 630021	2024120	2024546	0	0	"2021-07-04" = dorlin,st1,st2,sum(kol_pas) as kol_pas,sum(pass_km) as pass_km,min(date_zap) as date_zap

--select * from umn4 where dorlin=630021 and st1=2024120 and st2=2024546
--1	202107	"2021-07-04"	"Й"	49	49	58	630021	2024120	2024546	"2021-08-28"	0	0	0	0	0	0
--1	202107	"2021-07-04"	"Й"	49	49	58	630021	2024120	2024546	"2021-07-28"	0	0	0	0	0	0

--select * from umn3 where  dorlin=630021 and st1 in(2024120,2024546)  and st2 in (2024120,2024546) and st1!=st2
--select * from pereg2 where dorlin=630021 and st1=2024120 and st2=2024546


--select * from umn3 where  dorlin=630021 and st1 in(2024120,2024546)  and st1=st2

--select * from pereg3 where izz=0 and peregon>0  and st1=st2


------ ERROR: ОШИБКА:  деление на ноль



select 11 as rez,date_zap,YYYYMM,TERM_DOR,nomer_bil as nom_bil,date,agent,chp,reg,dor,lin,st1,st2,peregon,
 d_plata,d_poteri,kol_pas,pass_km,otpr_pas,prib_pas
	from umn5
union all
select 12 as rez,date_zap,NULL as YYYYMM,NULL as TERM_DOR,NULL as nom_bil,NULL as date,NULL as agent,NULL as chp,NULL as reg,
dor,lin,st1,st2,peregon,
 NULL as d_plata,NULL as d_poteri,NULL as kol_pas,rasst as pass_km,NULL as otpr_pas,NULL as prib_pas
	from pereg3 where izz=0 and peregon>0

	;





--- ввод времени окончания операции
insert into  spb_prig.prig_times(time,date,oper,time2,date_zap)
with a as
(select current_date as date,substr(cast(current_time as char(50)),1,12) as time_,substr(cast(clock_timestamp()::time as char(50)),1,12) as time),
b as
(select date_zap from  spb_prig.prig_times where oper='dannie')
select time,date,'prig_pereg 2_agr' as oper,
(cast(substr(time,1,2) as dec(3))*60+cast(substr(time,4,2) as dec(3)))*60+cast(substr(time,7,6) as dec(7,3)) as time2,date_zap
from a left join b on 1=1;



--- ввод времени окончания операции ситоговым числом записей
insert into  spb_prig.prig_times(time,date,oper,time2,date_zap,rezult)
with a as
(select current_date as date,substr(cast(clock_timestamp()::time as char(50)),1,12) as time),
b as
(select date_zap from  spb_prig.prig_times where oper='dannie'),
c as (select count(*) as rezult from spb_prig.prig_work where rez in(11,12))
select time,date,'prig_pereg 3_rez' as oper,
(cast(substr(time,1,2) as dec(3))*60+cast(substr(time,4,2) as dec(3)))*60+cast(substr(time,7,6) as dec(7,3)) as time2,date_zap,rezult
from a left join b on 1=1 left join c on 1=1;


------ ERROR: ОШИБКА:  деление на ноль




insert into spb_prig.prig_agr_pereg
(date_zap,YYYYMM,TERM_DOR,nomer_bil,date,agent,chp,reg,dor,lin,st1,st2,peregon,
 d_plata,d_poteri,kol_pas,pass_km,otpr_pas,prib_pas)
 select 
date_zap,YYYYMM,TERM_DOR,nom_bil as nomer_bil,date,agent,chp,reg,dor,lin,st1,st2,peregon,
 d_plata,d_poteri,kol_pas,pass_km,otpr_pas,prib_pas
 from  spb_prig.prig_work where rez=11;




insert into spb_prig.prig_peregoni
(date_zap,dor,lin,st1,st2,peregon,rasst)
select date_zap,dor,lin,st1,st2,peregon,pass_km as rasst
 from  spb_prig.prig_work where rez=12;


delete  from  spb_prig.prig_work where rez in(11,12);




--- ввод времени окончания операции
insert into  spb_prig.prig_times(time,date,oper,time2,date_zap)
with a as
(select current_date as date,substr(cast(current_time as char(50)),1,12) as time_,substr(cast(clock_timestamp()::time as char(50)),1,12) as time),
b as
(select date_zap from  spb_prig.prig_times where oper='dannie')
select time,date,'prig_pereg 4_vvod' as oper,
(cast(substr(time,1,2) as dec(3))*60+cast(substr(time,4,2) as dec(3)))*60+cast(substr(time,7,6) as dec(7,3)) as time2,date_zap
from a left join b on 1=1;



--select date_zap,dor,lin,st1,st2,peregon,pass_km as rasst  from  spb_prig.prig_work where rez=12;
 
 
 
delete from spb_prig.prig_times where oper in('dannie');
delete from spb_prig.prig_times where oper='dann' and date_zap in
(select distinct date_zap from spb_prig.prig_times where oper!='dann');
 
 --select * from spb_prig.prig_times where oper='dann'
 
insert into  spb_prig.prig_times(oper,date_zap)
select 'dannie' as oper,min(date_zap) as date_zap from spb_prig.prig_times where oper='dann';


 
 

select date_zap,count(*) from spb_prig.prig_agr_pereg group by 1 order by 1 desc;



