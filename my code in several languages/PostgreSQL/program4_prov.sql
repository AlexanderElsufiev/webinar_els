
select REQUEST_DATE,count(*) from rawdl2.l2_prig_main group by 1 order by 1

select date_zap,count(*) from spb_prig.prig_agr_pereg group by 1 order by 1;

select yyyymm,count(*) from spb_prig.prig_agr_kst group by 1 order by 1;

-- select * from spb_prig.prig_times
--  update spb_prig.prig_times set date_zap='2021-08-21' where oper='dannie'


-----------------------------------------------------------

-- проверка возможности данных для оперативки
--2004633	"2021-08-07"

select * from spb_prig.prig_agr_kst where par_name='kol_bil' fetch first 5 rows only;

select *,round(100*par2/param) as proc,extract(dow from date) as wd from
(select yyyymm,date,sum(param) as param,sum(case when nnn>1 then param else 0 end) as par2 from
(select *,ROW_NUMBER() over (partition by yyyymm,kst,date order by date_zap) as nnn  from
(select distinct yyyymm,kst,date,date_zap,sum(param) as param 
 from spb_prig.prig_agr_kst where par_name='kol_bil' and chp=23 and yyyymm>202107
 group by yyyymm,kst,date,date_zap) as a
) as b
group by yyyymm,date) as c where par2>param/10
order by yyyymm,date


---------------------------------------------------------------
--ИТОГО!!! Считать оперативку имеющейся. с момента поступления ПЕРВЫХ данных по нужной станции (всё прочее не более 6%)
--А до этого момента - брать некий прогноз.
--При поступлении новой порции данных - оперативку просто уточнять.



select *,round(100*par2/param) as proc,extract(dow from date) as wd from
(select yyyymm,date,kst,sum(param) as param,sum(case when nnn>1 then param else 0 end) as par2 from
(select *,ROW_NUMBER() over (partition by yyyymm,kst,date order by date_zap) as nnn  from
(select distinct yyyymm,kst,date,date_zap,sum(param) as param 
 from spb_prig.prig_agr_kst where par_name='kol_bil' and chp=23 and yyyymm>202107
 and kst between 2004001 and 2004006
 group by yyyymm,kst,date,date_zap) as a
) as b
group by yyyymm,date,kst) as c --where par2>param/10
order by kst,yyyymm,date,kst


-----------------------------------------------
-- ИССЛЕДОВАНИЕ НА САМ ПРОГНОЗ


with ish as 
(select *,cast(extract(dow from date) as numeric) as wd from
(select yyyymm,kst,date,sum(param) as param 
	from spb_prig.prig_agr_kst where par_name='kol_bil' and chp=23 and yyyymm>202107
	and kst between 2004001 and 2004006 group by yyyymm,kst,date) as a),
 
s_wd as
(select kst,wd,round(1000*param*s_kol/(s_par*kol)) as zn from
(select *,sum(param) over(partition by kst) as s_par,sum(kol) over(partition by kst) as s_kol from
(select kst,wd,sum(param) as param,count(*) as kol from ish group by 1,2) as a) as b),

prov as
(select yyyymm,date,a.kst,a.wd,param,round(param*1000/zn) as sred
 from ish as a,s_wd as b where a.kst=b.kst and a.wd=b.wd)
 
select *  from prov order by kst,date,kst




select yyyymm,kst,date,date_zap,nom_bil,sum(param) as param,count(*) as kol_zap from spb_prig.prig_agr_kst 
where par_name='kol_bil' and kst=2010148 and date in('2021-08-15','2021-08-18') and nom_bil=76
group by yyyymm,kst,date,date_zap,nom_bil order by date,date_zap,nom_bil



select * from spb_prig.prig_agr_kst 
where par_name='kol_bil' and kst=2010148 and date in('2021-08-15','2021-08-18') and nom_bil=76
 order by date,date_zap

-- понять что значит тип билета 76
select * from spb_prig.prig_bil where  nom_bil=76

select * from spb_prig.prig_bil where kod_lgt=2204 and flg_tuda_obr='1' and train_num='99999' and train_category='7'
order by nom_bil
--FLG_1WAYTICKET='1' and BENEFIT_CODE=2204 and train_num='99999' and train_category='7'


select * from rawdl2.l2_prig_main  where OPERATION_DATE='2021-08-18' and SALE_STATION=2010148 
	and FLG_1WAYTICKET='1' and BENEFIT_CODE=2204 and train_num='99999' and train_category='7'
 fetch first 50 rows only;


select count(*) from  rawdl2.l2_prig_main

select * from  rawdl2.l2_prig_main where sale_station=
fetch first 5 rows only

-- проверка возможности данных для оперативки
-----------------------------------------------------------

select sum(param) as param from spb_prig.prig_agr_kst 
where  par_name='kol_bil' and agent=23 and yyyymm=202108    --- есть 5749488 надо 5758420= 5749488+8932


select par_name,sum(param) as param from spb_prig.prig_agr_kst 
where  agent=23 and yyyymm=202108  and date<'2021-09-01' group by 1   
-- "plata =	4295102110  надо=4295102110
--"poteri    "	3641720660  надо=3641720660
--"bag_bil   "	91657       надо=91657
--"bag_plata "	39142520    надо=39142520
--"kol_pas   "	было 7096582 стало 7096426 текущих  надо=7096458 +140427 учтёных , или исправленых надо 7096394


select kod_lgt,sum(param) as param from spb_prig.prig_agr_kst 
where  par_name='kol_pas' and agent=23 and yyyymm=202108   and date<'2021-09-01' group by 1 order by 1
--0	4050438 надо=4050464
--2204	59445 --59451

select kst,sum(param) as param from spb_prig.prig_agr_kst 
where  par_name='kol_pas' and agent=23 and yyyymm=202108 and kod_lgt=2204    and date<'2021-09-01'  group by 1 order by 1
--2004001	7149 ==7152
--2004107	1937 ==1938
--2004148	2335 ==2336
--2004164	1827 ==1828....






select abonement_type,sum(param) from spb_prig.prig_agr_kst 
where  par_name='kol_pas' and agent=23 and yyyymm=202108 and kod_lgt=2204 and date<'2021-09-01'
and kst=2004164 and par_name='kol_pas' group by 1
--"7  "	263 ==264


select abonement_type,date_beg,sum(param) from spb_prig.prig_agr_kst 
where  par_name='kol_pas' and agent=23 and yyyymm=202108 and kod_lgt=2204 and date<'2021-09-01'
and kst=2004164 and par_name='kol_pas' and abonement_type='7' group by 1,2
--"2021-08-23"	12 ==13


select * from spb_prig.prig_agr_kst 
where  par_name='kol_pas' and agent=23 and yyyymm=202108 and kod_lgt=2204 --and date<'2021-09-01' 
and kst=2004164 and abonement_type='7' and date_beg='2021-08-23'
order by date_zap,date_beg,date



select date,sum(param) as param from spb_prig.prig_agr_kst 
where  par_name='kol_pas' and agent=23 and yyyymm=202108 and kod_lgt=5002 and kst=2004006 --and date<'2021-09-01'
and date_beg='2021-08-23'
group by 1 order by 1


-- 2004006	30 надо 51, 2004001	252 надо 273 .....
 
--ищем исходник на 2 уровне

select TICKET_BEGDATE,REQUEST_DATE,* from rawdl2.l2_prig_main where --SALE_STATION=2004570 and 
BENEFIT_CODE=2204 and (departure_station=2004164  or arrival_station=2004164)
and TICKET_BEGDATE='2021-08-23' and ABONEMENT_TYPE='7'
-- id= 314084955,314084956, всего 2 билета, вроде всё правильно. Значит ошибка у меня?!

select ID,DOC_NUM,* from rawdl2.l2_prig_cost where id in( 314084955,314084956)


select ID,DOC_NUM,* from rawdl2.l2_prig_main where id in( 314084955,314084956)

--******************************************************************************************

select * from spb_prig.prig_agr_kst where kod_lgt=2220 and par_name='kol_bil' and agent=23 and yyyymm=202108


select * from spb_prig.prig_agr_kst where kst=2003797 and par_name='kol_bil' 



select date_zap,sum(param) as param from spb_prig.prig_agr_kst where  par_name='kol_bil' and agent=23 and yyyymm=202108 group by 1 order by 1

select date_zap,agent,sum(param) as param from spb_prig.prig_agr_kst where  par_name='kol_bil' group by 1,2 order by 1,2



select kst,sum(param) as param from spb_prig.prig_agr_kst 
where  par_name='kol_bil' and agent=23 and yyyymm=202108 group by 1 order by 1


--Итоги числа билетов СЗППК по датам начала действия
select date_beg,sum(param) as param from spb_prig.prig_agr_kst 
where  par_name='kol_bil' and agent=23 and yyyymm=202108 and kst=2004001 group by 1 order by 1



select * from spb_prig.prig_agr_kst 
where  par_name='kol_bil' and agent=23 and yyyymm=202108 and kst=2004001 and kod_lgt=2415





select * from spb_prig.prig_times order by oper,date_zap;

select distinct date_zap from spb_prig.prig_itog;

select TERM_DOR,agent,count(*) from spb_prig.prig_agr_kst group by 1,2 order by 1,2;

select count(*) from spb_prig.prig_agr_pereg;
select count(*) from spb_prig.prig_peregoni;



select date_zap,count(*) from spb_prig.prig_peregoni group by 1 order by 1

select * from spb_prig.prig_peregoni where dor=0

select * from spb_prig.prig_peregoni where st1=2001154 or st2=2001154



with
stan as
(select distinct kst from spb_prig.prig_agr_kst),

date as (select min(date_zap) as date_zap from spb_prig.prig_times),
lin as --структура всех линий
(select dor,lin,kst,rst,reg,ROW_NUMBER() over (partition by dor,lin order by rst) as nom from
(select cast(nom3d as dec(3)) as dor,cast(noml as dec(3)) as lin,cast(stan as dec(7)) as kst,rstk as rst,cast(sf as dec(3)) as reg
	from nsi.lines as a,date as b where date_zap between datand and datakd and date_zap between datani and dataki) as a)

--select * from stan where kst not in(select kst from lin)

--select * from lin where kst in(2041633,2043640)


select * from spb_prig.prig_peregoni where dor=0 and st1 in(select kst from lin)  and st2 in(select kst from lin)



select * from lin where kst=2001154



select * from nsi.lines where nom3d='080' and noml in('013','034') and ((noml='013' and rstk between 820 and 850)or(noml='034' and rstk<20)) order by noml,rstk


with
a as(select *,row_number() over (order by date,time2) as nn
		 from spb_prig.prig_times),
b as (select a.nn,a.date_zap,a.oper,a.date,a.time,a.rezult,a.time2-b.time2 as dt
	 from a as a left join a as b on a.nn=b.nn+1 and substr(a.oper,1,8)=substr(b.oper,1,8)
	 )		 
select * from b order by oper,date_zap




delete from  spb_prig.prig_times where oper!='dannie';


 select count(*) from spb_prig.prig_work;


 select count(*) from rawdl2.l2_prig_main   where REQUEST_DATE ='2021-07-01' 
 
 
 select REQUEST_DATE,YYYYMM,count(*) from rawdl2.l2_prig_main group by 1,2 order by 1,2
 

select *
 from spb_prig.prig_work where nom_mar=1288

select * from spb_prig.prig_peregoni where dor=0 and lin=0



select * from spb_prig.prig_peregoni where st1=st2;


select date_zap,sum(d_plata) as d_plata,sum(d_poteri) as d_poteri,sum(kol_pas) as kol_pas,sum(pass_km) as pass_km,
sum(otpr_pas) as otpr_pas,sum(prib_pas) as prib_pas
from spb_prig.prig_agr_pereg where nomer_bil=1 group by 1;




/*
d_plata,d_poteri,kol_pas,pass_km,otpr_pas,prib_pas = 
153874811	151490767	2296338	11352138	292057	292057
==           ==                    =?         ==      ==
*/


select date_zap,par_name,sum(param) as param
from spb_prig.prig_agr_kst group by 1,2


"bag_bil   "	2818
"bag_plata "	1137837
"d_plata   "	153874811 ==
"d_poteri  "	151490767 ==
"kol_bil   "	234362
"kol_pas   "	292057 ==
"kol_pkm   "	11352138 ==
"nedobor   "	-264424
"perebor   "	78566
"plata     "	153874811 ==
"poteri    "	151490767 ==
"sf_pas    "	292057 ==
"sf_pkm    "	11352138 ==










--заполнение постанционных агрегатов

select par_name,sum(param) as param from
(select YYYYMM,date_zap,TERM_DOR,nom_bil,date,agent,chp,kst,reg,par_name,sum(param) as param from 
(
select id,YYYYMM,date_zap,TERM_DOR,nom_bil,date,agent,chp,stp as kst,stp_reg as reg,'sf_pkm' as par_name,
sf_pas*cast(flg_tuda_obr as dec(3))*srasst as param
from spb_prig.prig_itog where sf_pas!=0 and flg_bag='0'
	) as a
group by 1,2,3,4,5,6,7,8,9,10 ) as b 
group by 1
---итог = "sf_pkm"	11352138

;

select * from spb_prig.prig_itog fetch first 5 rows only


select * from spb_prig.prig_mars fetch first 5 rows only




--по кому общее расстояние не равно сумме частных?! 9 штук!!!
select * from
(select nom_mar,srasst,sum(rst) as rst from spb_prig.prig_mars group by 1,2) as a
where srasst!=rst




select * from spb_prig.prig_itog where nom_mar=593   --- id=275501420

select * from spb_prig.prig_mars where nom_mar in(593,
147,
4678,
5525,
2146,
5883,
6438,
9227,
9219)
order by nom_mar





with

prig_cost as --исходник пригород по перегонам по субъектам
(select  ID,DOC_NUM,doc_reg as nom,
--YYYYMM,REQUEST_DATE,REQUEST_NUM,TERM_POS,TERM_DOR,TERM_TRM,ARXIV_CODE,REPLY_CODE, --не нужны
	ROUTE_NUM as marshr,cast(ROUTE_DISTANCE as dec(7)) as rasst,
	sum(cast(ROUTE_DISTANCE as dec(7))) over(partition by ID,DOC_NUM) as srasst,
	TARIFF_SUM as d_plata,DEPARTMENT_SUM as d_poteri,
	DEPARTURE_STATION as st1,ARRIVAL_STATION as st2,
 case when id=275367223*0 then 0 else REGION_CODE end as reg,
	max(doc_reg) over (partition by ID,DOC_NUM) as max_nom,
	sum(TARIFF_SUM) over (partition by ID,DOC_NUM) as s_plata,
	sum(DEPARTMENT_SUM) over (partition by ID,DOC_NUM) as s_poteri 
from rawdl2.l2_prig_cost where REQUEST_DATE='2021-07-01'
	--	and	 id=275501420
)

select * from prig_cost where nom=3 fetch first 5 rows only





select * from spb_prig.prig_peregoni   where st1=st2;



select date_zap,count(*) from spb_prig.prig_peregoni where st1=st2 group by 1  ;


select date_zap,rez,count(*) from spb_prig.prig_work group by 1,2


select date_zap,count(*) from spb_prig.prig_agr_pereg group by 1












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
(select nom_mar,sto,stn,
 max(case when nom=1 then dor else 0 end) as dor1,max(case when nom=1 then lin else 0 end) as lin1,
 max(case when nom=mnom then dor else 0 end) as dor2,max(case when nom=mnom then lin else 0 end) as lin2
  from
(select nom_mar,sto,stn,srasst,marshr,nom,reg,st1,st2,rst,sto_zone,stn_zone,sti,sti_zone,dor,lin,
 max(nom) over(partition by nom_mar) as mnom from spb_prig.prig_mars) as a group by 1,2,3)
 
 
 select * from mars where sto=2004162 or stn=2004162
 --select * from lin where kst=2004162




select * from  spb_prig.prig_mars where nom_mar=47478

2004162	2004927
2004927	2005007

select * from 


-- 47478	2004162	2005007	2	64	2	64


/*
"kol_pas   "	1	32
"kol_pas   "	2	2
"kol_pas   "	2	64
*/







