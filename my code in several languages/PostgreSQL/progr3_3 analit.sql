



--ПОИСК  СБОЯ В АНАЛИТИКЕ
select * from l3_mes.prig_analit where date='2023-04-20'  and agent=15 and chp=15 and par_name='prod' 
order by plata

limit 10

select * from l3_mes.prig_analit where part_zap=149 and par_name in('prod','bag') and anal_rasch='1-nal' and anal_vid_bil='1.1.raz'

select sum(plata) from l3_mes.prig_analit where part_zap=149 and par_name in('prod','bag')  -- 36760 --36760.00000000000000000000  --- prod=16050


select * from l3_mes.prig_itog where part_zap=147-- and nom_mar=27234


select * from l3_mes.prig_mars where nom_mar=27234



select nom_bil,sum(plata) from l3_mes.prig_itog where part_zap=149 group by 1--16050
/*
2998	-5400
3004	-130
2997	3600
2999	35000
3006	11150
3003	6950
3002	-35000
3005	130
3001	-11150
160	10900
*/

10900.0000000000000000
-5400.0000000000000000
10900
-5400





46251007201
46251007301
46251008501




select * from l3_mes.prig_times where part_zap=149




--ПРОГРАММА ВЫЧИСЛЕНИЯ АНАЛИТИЧЕСКОЙ ОТЧЁТНОСТИ

/**/
--- ввод времени начала операции
select * from l3_mes.prig_times where oper='to_agr_analit';

delete from l3_mes.prig_times where oper='to_agr_analit';

insert into  l3_mes.prig_times(date_zap,part_zap,shema,rezult,dann,libr,oper,date,time,time2)
with times as (select * from l3_mes.prig_times where dann='prig' and itog is null and substr(shema,5,4)='prig')
-- С заплаткой - данные по скоростным электричкам не обрабатывать. брать только чистый пригород
select date_zap,part_zap,shema,rezult,dann,'to_agr_analit' as oper,libr,date,time,
(cast(substr(time,1,2) as dec(3))*60+cast(substr(time,4,2) as dec(3)))*60+cast(substr(time,7,6) as dec(7,3)) as time2
from
(select date_zap,part_zap,shema,rezult,dann,libr,
 current_date as date,substr(cast(clock_timestamp()::time as char(50)),1,12) as time
from
(select date_zap,part_zap,shema,oper,rezult,dann,libr,row_number() over (order by part_zap) as nom
 from times
 	where oper='work 2_4_itog' and rezult>0 and part_zap not in(select part_zap from times where oper='write_analit' )) as a
	where  nom=1) as b;
	
	
	
----------------------------------------------
--  select * from l3_mes.prig_times where oper='to_agr_analit';

 
----------------------------------------------
/**/

--Поле date_beg убрать - было нужно лишь для расследования!!!

/*
insert into l3_mes.prig_analit
(yymm,date_zap,part_zap,date,TERM_DOR,agent,chp,reg,par_name,anal_rasch,anal_vid_bil,anal_oper,train_category,kol_bil,plata,poteri,kol_pas,pass_km)
*/

with

prig as
(select 
 yymm,nom_mar,nom_bil,nom_dat,date_zap,part_zap,date_pr,date_beg,TERM_DOR,agent,chp,stp,stp_reg,k_bil,
 kol_bil/k_bil as kol_bil,plata/k_bil as plata,poteri/k_bil as poteri,kom_sbor/k_bil as kom_sbor,kom_sbor_vz/k_bil as kom_sbor_vz,perebor,nedobor
 from l3_mes.prig_itog where part_zap in (select part_zap from l3_mes.prig_times where dann='prig' and oper='to_agr_analit')
),
 
isp_bil as
(select nom_bil,flg_ruch,vid_rasch,FLG_CHILD,flg_voin,FLG_MILITARY,flg_lgt,FLG_BSP,FLG_SO,FLG_NU,FLG_TT,
klass,kod_lgt,lgt_reg,flg_bag,bag_vid,bag_ves,flg_rab_day,proc_lgt,ABONEMENT_TYPE,prod,
k_pas,srok_bil,srok_mon,TRAIN_CATEGORY,/*TRAIN_NUM,*/grup_lgt,
cast(FLG_tuda_obr as dec(3)) as k_tuda_obr
from l3_mes.prig_bil where nom_bil in (select distinct nom_bil from  prig)),

isp_bil_anal as
(
select nom_bil,
case
when vid_rasch='6' then '3-bezn' --если Платёжные поручения, безналичные
when vid_rasch='8' and web_id in('0000','-1','NULL') then '2-bank' --если пустой ID эл.площадки, и НЕ Наличка, то это банковская
when vid_rasch='8' and web_id not in('0000','-1','NULL') then '4-elek' --Электронный кошелёк
when vid_rasch='1' and web_id not in('0000','-1','NULL') then '4-el-n' --если непустой ID эл.площадки, и Наличка - тоже Электронный кошелёк
when vid_rasch='1' then '1-nal' --наличка
else vid_rasch||'-neizv' --неизвестно что, льготные
end as anal_rasch,
case 
  when abonement_type='0' and flg_bil_sbor='B' and flg_bag='0' then '1.1.raz' --разовыые
  when ABONEMENT_TYPE='1' then '1.2.ab_k' -- на 10-20-60-90 поездок
  when ABONEMENT_TYPE='3' then '1.3.ez_m' --абонемент на ежедневные поездки месяцы
  when ABONEMENT_TYPE='4' then '1.4.ez_d' --абонемент Ежедневно на количество дней - вообще-то это абонмено на 5-25 дней на 5-20 поездок
  when flg_rab_day='2' and ABONEMENT_TYPE in('7','8') then '1.5.ab_rd' --абонементы рабочего дня
  when flg_rab_day='1' and ABONEMENT_TYPE in('5','6') then '1.6.ab_vd' --абонементы выходные
  when ABONEMENT_TYPE='2' then '1.7.ab_dt' --абонемент на определённые даты
  when flg_bil_sbor='S' then '2.5.sbor' --сбор за оформление в поезде
  --when par_name='kom_sbor' and flg_bil_sbor='B' then '2.6-7.kom_prod_vozv'
  when flg_bag='1' and bag_vid='Ж' then '2.4.bag_z'--багаж живность
  when flg_bag='1' and bag_vid='Т' then '2.2.bag_t' --багаж телевизор
  when flg_bag='1' and bag_vid='Р' then '2.1.bag_r' --багаж ручная кладь вес
  when flg_bag='1' and bag_vid='В' then '2.3.bag_v' -- багаж велосипед
  when flg_bag='1' then '2.*.bag_?' --неизвестный вид багажа
 end as anal_vid_bil, 
case when oper='O' and oper_g='N' then '1' else '2' end as anal_oper,
train_category
from l3_mes.prig_bil),

isp_mar as
(select nom_mar,sto,stn,srasst,marshr,nom,reg,st1,st2,rst,sto_zone,stn_zone,sti,sti_zone,dor,lin,/*date_zap,*/otd,dcs,d_plata,d_poteri,
 max(nom) over (partition by nom_mar) as max_nom 
from l3_mes.prig_mars where nom_mar in (select distinct nom_mar from  prig)),

isp_mar2 as
(select distinct nom_mar,sto,stn,srasst,
 sum(case when nom=1 then reg else 0 end) over (partition by nom_mar) as sto_reg,
 sum(case when nom=max_nom then reg else 0 end) over (partition by nom_mar) as stn_reg
 from isp_mar),

isp_dat as
(select nom_dat,plus_dat,kpas_day,sk_pas,
 case when skpas=0 then 1 else skpas end as skpas --заплатка на редкую ошибку - нет ни одной отправки, возврат был до отправления
from
(select nom_dat,cast(plus_dat as integer) as plus_dat,kpas_day,
 sum(kpas_day) over(partition by nom_dat) as skpas,sum(kpas_day) over(partition by nom_dat order by plus_dat) as sk_pas
from l3_mes.prig_dats where nom_dat in (select distinct nom_dat from  prig)) as a),

prig_dat as
(select yymm,nom_mar,nom_bil,date_zap,part_zap,TERM_DOR,agent,chp,stp,stp_reg,date_otpr,k_tuda_obr,
 sum(kol_pas1*k_bil) as kol_pas1,sum(p_plata*k_bil) as p_plata,sum(p_poteri*k_bil) as p_poteri
 from
(select yymm,nom_mar,a.nom_bil,date_zap,part_zap,TERM_DOR,agent,chp,stp,stp_reg,
 plus_dat,kpas_day,skpas,sk_pas,date_beg+plus_dat as date_otpr,kol_bil*kpas_day as kol_pas1,k_tuda_obr,k_bil,
 --для билета туда-обратно и нечётной суммы надо в конце особое разбиение, без округления
 case when sk_pas=skpas then plata-(round(plata*(sk_pas-kpas_day)/(skpas*k_tuda_obr)))*k_tuda_obr
 else (round(plata*sk_pas/(skpas*k_tuda_obr))-round(plata*(sk_pas-kpas_day)/(skpas*k_tuda_obr)))*k_tuda_obr end as p_plata,
 case when sk_pas=skpas then poteri-(round(poteri*(sk_pas-kpas_day)/(skpas*k_tuda_obr)))*k_tuda_obr
 else (round(poteri*sk_pas/(skpas*k_tuda_obr))-round(poteri*(sk_pas-kpas_day)/(skpas*k_tuda_obr)))*k_tuda_obr end as p_poteri
 from prig as a join isp_bil as b on a.nom_bil=b.nom_bil
 join isp_dat as c on a.nom_dat=c.nom_dat) as a
 group by yymm,nom_mar,nom_bil,date_zap,part_zap,TERM_DOR,agent,chp,stp,stp_reg,date_otpr,k_tuda_obr),



prig_dat_mar2 as ----------***
(select yymm,sto,stn,sto_reg,stn_reg,srasst,a.nom_bil,k_tuda_obr,date_zap,part_zap,TERM_DOR,agent,chp,stp,stp_reg,date_otpr,
 sum(kol_pas1) as kol_pas1,sum(p_plata) as p_plata,sum(p_poteri) as p_poteri
 from prig_dat as a join isp_mar2 as b on a.nom_mar=b.nom_mar
group by yymm,sto,stn,sto_reg,stn_reg,srasst,a.nom_bil,k_tuda_obr,date_zap,part_zap,TERM_DOR,agent,chp,stp,stp_reg,date_otpr
),


prig_bil_mar as
(select yymm,a.nom_bil,date_zap,part_zap,date_pr,TERM_DOR,agent,chp,stp,stp_reg,
 sum(kol_bil*k_bil) as kol_bil,sum(plata*k_bil) as plata,sum(poteri*k_bil) as poteri,sum(perebor) as perebor,sum(nedobor) as nedobor,
 sum(kol_bil*k_bil*k_pas*k_tuda_obr) as kol_pas,sum(kol_bil*k_bil*k_pas*srasst*k_tuda_obr) as kol_pkm,
 sum(kom_sbor*k_bil) as kom_sbor,sum(kom_sbor_vz*k_bil) as kom_sbor_vz
 from prig as a join isp_bil as b on a.nom_bil=b.nom_bil
 join isp_mar2 as c on a.nom_mar=c.nom_mar
 group by yymm,a.nom_bil,date_zap,part_zap,date_pr,TERM_DOR,agent,chp,stp,stp_reg
),
 

itog as
(select yymm,b.nom_bil,date_zap,part_zap,date,TERM_DOR,agent,chp,0 as kst,reg,par_name,kol_bil,plata,poteri,kol_pas,pass_km,
 FLG_CHILD,FLG_MILITARY,kod_lgt,ABONEMENT_TYPE,prod,flg_bag
 from
(select yymm,nom_bil,date_zap,part_zap,date,TERM_DOR,agent,chp,/*kst,*/reg,par_name,
 sum(kol_bil) as kol_bil,sum(plata) as plata,sum(poteri) as poteri,sum(kol_pas) as kol_pas,sum(pass_km) as pass_km
  from

(
--По станции и дате продажи	
 select yymm,nom_bil,date_zap,part_zap,date_pr as date,TERM_DOR,agent,chp,stp as kst,stp_reg as reg,
 'prod' as par_name,kol_bil,plata,poteri,kol_pas,kol_pkm as pass_km
 from prig_bil_mar 
 
 union all
 select yymm,nom_bil,date_zap,part_zap,date_pr as date,TERM_DOR,agent,chp,stp as kst,stp_reg as reg,
 'perebor' as par_name,0 as kol_bil,perebor as plata,nedobor as poteri,0 as kol_pas,0 as pass_km
 from prig_bil_mar where perebor!=0 or nedobor!=0
 
 
 union all
 select yymm,nom_bil,date_zap,part_zap,date_pr as date,TERM_DOR,agent,chp,stp as kst,stp_reg as reg,
 'kom_sbor' as par_name,0 as kol_bil,kom_sbor as plata,kom_sbor_vz as poteri,0 as kol_pas,0 as pass_km
 from prig_bil_mar where kom_sbor!=0 or kom_sbor_vz!=0	
 /*
 --сформированные данные - по станции продажи но дате отправлени
 union all
 select yymm,nom_bil,date_zap,part_zap,date_otpr as date,TERM_DOR,agent,chp,stp as kst,stp_reg as reg,
 'sform' as par_name,0 as kol_bil,p_plata as plata,p_poteri as poteri,kol_pas1*k_tuda_obr as kol_pas,kol_pas1*k_tuda_obr*srasst as pass_km
 from prig_dat_mar2 */
 -- по дате и станции отправления
  union all
 select yymm,nom_bil,date_zap,part_zap,date_otpr as date,TERM_DOR,agent,chp,sto as kst,sto_reg as reg,
 'otpr' as par_name,0 as kol_bil,round(p_plata/k_tuda_obr) as plata,round(p_poteri/k_tuda_obr)  as poteri,kol_pas1 as kol_pas,kol_pas1*srasst as pass_km
 from prig_dat_mar2  
 union all
 select yymm,nom_bil,date_zap,part_zap,date_otpr as date,TERM_DOR,agent,chp,stn as kst,stn_reg as reg,
 'otpr' as par_name,0 as kol_bil,p_plata-round(p_plata/k_tuda_obr) as plata,p_poteri-round(p_poteri/k_tuda_obr)  as poteri,kol_pas1 as kol_pas,kol_pas1*srasst as pass_km
 from prig_dat_mar2  where k_tuda_obr=2 
 

 -----------------------------
 ) as a
 group by  yymm,nom_bil,date_zap,part_zap,date,TERM_DOR,agent,chp,/*kst,*/reg,par_name) as b
 join isp_bil as c on b.nom_bil=c.nom_bil
 where kol_bil!=0 or plata!=0 or poteri!=0 or kol_pas!=0 or pass_km!=0),
  
itog2 as --=просто постанционные агрегаты
(select * from 
(select yymm,nom_bil,date_zap,part_zap,date,TERM_DOR,agent,chp,kst,reg,kol_bil,plata,poteri,kol_pas,pass_km,
 FLG_CHILD,FLG_MILITARY,kod_lgt,ABONEMENT_TYPE,prod,
 case when flg_bag in('0','?') then par_name
 	when par_name='prod' then 'bag'
    when par_name='perebor' then 'bag_pereb'
 	else '' end as par_name
 from itog) as a where par_name!=''),
 
itog_anal as
(select yymm,date_zap,part_zap,date,TERM_DOR,agent,chp,reg,par_name,anal_rasch,anal_vid_bil,anal_oper,train_category,
 sum(kol_bil) as kol_bil,sum(plata) as plata,sum(poteri) as poteri,sum(kol_pas) as kol_pas,sum(pass_km) as pass_km

	from itog2 as a,isp_bil_anal as b where a.nom_bil=b.nom_bil
group by yymm,date_zap,part_zap,date,TERM_DOR,agent,chp,reg,par_name,anal_rasch,anal_vid_bil,anal_oper,train_category
)


--select yymm,date_zap,part_zap,date,TERM_DOR,agent,chp,reg,par_name,anal_rasch,anal_vid_bil,anal_oper,train_category,kol_bil,plata,poteri,kol_pas,pass_km 
--from itog_anal;

select count(*) from itog_anal;

/*
select yymm,nom_mar,a.nom_bil,date_zap,part_zap,TERM_DOR,agent,chp,stp,stp_reg,
 plus_dat,kpas_day,skpas,sk_pas,date_beg+plus_dat as date_otpr,kol_bil*kpas_day as kol_pas1,k_tuda_obr,k_bil,
 /*--для билета туда-обратно и нечётной суммы надо в конце особое разбиение, без округления
 case when sk_pas=skpas then plata-(round(plata*(sk_pas-kpas_day)/(skpas*k_tuda_obr)))*k_tuda_obr
 else (round(plata*sk_pas/(skpas*k_tuda_obr))-round(plata*(sk_pas-kpas_day)/(skpas*k_tuda_obr)))*k_tuda_obr end as p_plata,
 case when sk_pas=skpas then poteri-(round(poteri*(sk_pas-kpas_day)/(skpas*k_tuda_obr)))*k_tuda_obr
 else (round(poteri*sk_pas/(skpas*k_tuda_obr))-round(poteri*(sk_pas-kpas_day)/(skpas*k_tuda_obr)))*k_tuda_obr end as p_poteri
 */
 skpas,k_tuda_obr
 from prig as a join isp_bil as b on a.nom_bil=b.nom_bil
 join isp_dat as c on a.nom_dat=c.nom_dat
	where skpas=0 */

--select * from isp_dat where nom_dat<3--skpas=0




 
/**/ 
 
insert into  l3_mes.prig_times(date_zap,part_zap,shema,rezult,dann,libr,oper,date,time,time2)
with 
dat as (select date_zap,part_zap,dann,libr,shema from l3_mes.prig_times where oper='to_agr_analit')
select date_zap,part_zap,shema,rezult,dann,oper,date,time,
(cast(substr(time,1,2) as dec(3))*60+cast(substr(time,4,2) as dec(3)))*60+cast(substr(time,7,6) as dec(7,3)) as time2
from
(select date_zap,part_zap,shema,rezult,dann,libr,'write_analit' as oper,
 current_date as date,substr(cast(clock_timestamp()::time as char(50)),1,12) as time
 from
(select count(*) as rezult from l3_mes.prig_analit where part_zap in (select part_zap from dat)) as a,dat as b) as c;

update l3_mes.prig_times set oper='read_analit' where oper='to_agr_analit';



-------------------










/**/



