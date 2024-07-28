

--ПРОГРАММА ВЫЧИСЛЕНИЯ ПОСТАНЦИОННЫХ АГРЕГАТОВ из наработки обогащения
-- select distinct dann   from l3_mes.prig_times

--  delete from l3_mes.prig_times where oper='write_agr_kst';
-- delete from l3_mes.prig_agr_kst

/**/
--- ввод времени начала операции
delete from l3_mes.prig_times where oper='to_agregate_kst';

insert into  l3_mes.prig_times(date_zap,part_zap,shema,rezult,oper,date,time,time2)
select date_zap,part_zap,shema,rezult,oper,date,time,
(cast(substr(time,1,2) as dec(3))*60+cast(substr(time,4,2) as dec(3)))*60+cast(substr(time,7,6) as dec(7,3)) as time2
from
(select date_zap,part_zap,shema,rezult,'to_agregate_kst' as oper,
 current_date as date,substr(cast(clock_timestamp()::time as char(50)),1,12) as time
from
(select date_zap,part_zap,shema,oper,rezult,row_number() over (order by part_zap) as nom
 from  l3_mes.prig_times
 	where oper in('write','prig_work 2_4_itog') and part_zap not in(select part_zap from  l3_mes.prig_times where oper='write_agr_kst' )) as a
	where  nom=1) as b;
/**/	

/* --все даты сразу
insert into  l3_mes.prig_times(date_zap,part_zap,shema,rezult,oper,date,time,time2)	
select date_zap,part_zap,shema,rezult,'to_agregate_kst' as oper,date,time,time2
 from  l3_mes.prig_times
 	where oper in('write','prig_work 2_4_itog');
*/	
	
----------------------------------------------

--select * from l3_mes.prig_times where oper='to_agregate_kst' 

--update l3_mes.prig_times set date_zap='2021-08-20' where oper='to_agregate_kst' 


-- delete from l3_mes.prig_agr_kst;
----------------------------------------------
/**/





/*
dor as (select nomd3 as dor3,kodd,vc from nsi.dor as a,dates as b where date_zap between datan and datak),
dor2 as
(select a.dor3,a.kodd,a.vc,b.dor3 as dor_vc from dor as a,dor as  b where a.vc=b.kodd),

prig1 as
(select * from prig as a join dor2 on term_dor=kodd),  
*/


--select distinct TERM_DOR,term_pos,term_trm from l3_mes.prig_itog order by 1,2,3


--kol_bil,plata,poteri,kol_pas,pass_km


--Поле date_beg убрать - было нужно лишь для расследования!!!
insert into l3_mes.prig_agr_kst
(YYYYMM,nom_bil,date_zap,part_zap,date,TERM_DOR,agent,chp,kst,reg,par_name,kol_bil,plata,poteri,kol_pas,pass_km
 ,FLG_CHILD,FLG_MILITARY,kod_lgt,ABONEMENT_TYPE,prod)
 
with

prig as
(select *
 --YYYYMM,nom_mar,nom_bil,nom_dat,date_zap,part_zap,date_pr,date_beg,TERM_DOR,agent,chp,stp,stp_reg,k_bil,kol_bil,plata,poteri,perebor,nedobor
 from l3_mes.prig_itog where part_zap in (select part_zap from l3_mes.prig_times where oper='to_agregate_kst')
--and nom_bil=253 and term_dor='О' and chp=23  and nom_mar=5497
),
 
isp_bil as
(select nom_bil,flg_ruch,vid_rasch,FLG_CHILD,flg_voin,FLG_MILITARY,flg_lgt,FLG_BSP,FLG_SO,FLG_NU,FLG_TT,
klass,kod_lgt,lgt_reg,flg_bag,bag_vid,bag_ves,flg_rab_day,proc_lgt,ABONEMENT_TYPE,prod,
k_pas,srok_bil,srok_mon,TRAIN_CATEGORY,TRAIN_NUM,grup_lgt,
cast(FLG_tuda_obr as dec(3)) as k_tuda_obr
from l3_mes.prig_bil where nom_bil in (select distinct nom_bil from  prig)),



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
(select nom_dat,cast(plus_dat as integer) as plus_dat,kpas_day,
 sum(kpas_day) over(partition by nom_dat) as skpas,sum(kpas_day) over(partition by nom_dat order by plus_dat) as sk_pas
from l3_mes.prig_dats where nom_dat in (select distinct nom_dat from  prig)),

prig_dat as
(select YYYYMM,nom_mar,nom_bil,date_zap,part_zap,TERM_DOR,agent,chp,stp,stp_reg,date_otpr,k_tuda_obr,
 sum(kol_pas1*k_bil) as kol_pas1,sum(p_plata*k_bil) as p_plata,sum(p_poteri*k_bil) as p_poteri
 from
(select YYYYMM,nom_mar,a.nom_bil,date_zap,part_zap,TERM_DOR,agent,chp,stp,stp_reg,
 plus_dat,kpas_day,skpas,sk_pas,date_beg+plus_dat as date_otpr,kol_bil*kpas_day as kol_pas1,k_tuda_obr,k_bil,
 --для билета туда-обратно и нечётной суммы надо в конце особое разбиение, без округления
 case when sk_pas=skpas then plata-(round(plata*(sk_pas-kpas_day)/(skpas*k_tuda_obr)))*k_tuda_obr
 else (round(plata*sk_pas/(skpas*k_tuda_obr))-round(plata*(sk_pas-kpas_day)/(skpas*k_tuda_obr)))*k_tuda_obr end as p_plata,
 case when sk_pas=skpas then poteri-(round(poteri*(sk_pas-kpas_day)/(skpas*k_tuda_obr)))*k_tuda_obr
 else (round(poteri*sk_pas/(skpas*k_tuda_obr))-round(poteri*(sk_pas-kpas_day)/(skpas*k_tuda_obr)))*k_tuda_obr end as p_poteri
 from prig as a join isp_bil as b on a.nom_bil=b.nom_bil
 join isp_dat as c on a.nom_dat=c.nom_dat) as a
 group by YYYYMM,nom_mar,nom_bil,date_zap,part_zap,TERM_DOR,agent,chp,stp,stp_reg,date_otpr,k_tuda_obr),



prig_dat_mar2 as
(select YYYYMM,sto,stn,sto_reg,stn_reg,srasst,a.nom_bil,k_tuda_obr,date_zap,part_zap,TERM_DOR,agent,chp,stp,stp_reg,date_otpr,
 sum(kol_pas1) as kol_pas1,sum(p_plata) as p_plata,sum(p_poteri) as p_poteri
 from prig_dat as a join isp_mar2 as b on a.nom_mar=b.nom_mar
 --join isp_bil as c on a.nom_bil=c.nom_bil
group by YYYYMM,sto,stn,sto_reg,stn_reg,srasst,a.nom_bil,k_tuda_obr,date_zap,part_zap,TERM_DOR,agent,chp,stp,stp_reg,date_otpr
),


prig_bil_mar as
(select YYYYMM,a.nom_bil,date_zap,part_zap,date_pr,TERM_DOR,agent,chp,stp,stp_reg,
 sum(kol_bil*k_bil) as kol_bil,sum(plata*k_bil) as plata,sum(poteri*k_bil) as poteri,sum(perebor) as perebor,sum(nedobor) as nedobor,
 sum(kol_bil*k_bil*k_pas*k_tuda_obr) as kol_pas,sum(kol_bil*k_bil*k_pas*srasst*k_tuda_obr) as kol_pkm,
 sum(kom_sbor*k_bil) as kom_sbor,sum(kom_sbor_vz*k_bil) as kom_sbor_vz
 from prig as a join isp_bil as b on a.nom_bil=b.nom_bil
 join isp_mar2 as c on a.nom_mar=c.nom_mar
 group by YYYYMM,a.nom_bil,date_zap,part_zap,date_pr,TERM_DOR,agent,chp,stp,stp_reg
),
 

itog as
(select YYYYMM,b.nom_bil,date_zap,part_zap,date,TERM_DOR,agent,chp,0 as kst,reg,par_name,kol_bil,plata,poteri,kol_pas,pass_km,
 FLG_CHILD,FLG_MILITARY,kod_lgt,ABONEMENT_TYPE,prod,flg_bag
 from
(select YYYYMM,nom_bil,date_zap,part_zap,date,TERM_DOR,agent,chp,/*kst,*/reg,par_name,
 sum(kol_bil) as kol_bil,sum(plata) as plata,sum(poteri) as poteri,sum(kol_pas) as kol_pas,sum(pass_km) as pass_km
  from

(
--По станции и дате продажи	
 select YYYYMM,nom_bil,date_zap,part_zap,date_pr as date,TERM_DOR,agent,chp,stp as kst,stp_reg as reg,
 'prod' as par_name,kol_bil,plata,poteri,kol_pas,kol_pkm as pass_km
 from prig_bil_mar 
 
 union all
 select YYYYMM,nom_bil,date_zap,part_zap,date_pr as date,TERM_DOR,agent,chp,stp as kst,stp_reg as reg,
 'perebor' as par_name,0 as kol_bil,perebor as plata,nedobor as poteri,0 as kol_pas,0 as pass_km
 from prig_bil_mar where perebor!=0 or nedobor!=0
 
 
 union all
 select YYYYMM,nom_bil,date_zap,part_zap,date_pr as date,TERM_DOR,agent,chp,stp as kst,stp_reg as reg,
 'kom_sbor' as par_name,0 as kol_bil,kom_sbor as plata,kom_sbor_vz as poteri,0 as kol_pas,0 as pass_km
 from prig_bil_mar where kom_sbor!=0 or kom_sbor_vz!=0	
 /*
 --сформированные данные - по станции продажи но дате отправлени
 union all
 select YYYYMM,nom_bil,date_zap,part_zap,date_otpr as date,TERM_DOR,agent,chp,stp as kst,stp_reg as reg,
 'sform' as par_name,0 as kol_bil,p_plata as plata,p_poteri as poteri,kol_pas1*k_tuda_obr as kol_pas,kol_pas1*k_tuda_obr*srasst as pass_km
 from prig_dat_mar2 */
 -- по дате и станции отправления
  union all
 select YYYYMM,nom_bil,date_zap,part_zap,date_otpr as date,TERM_DOR,agent,chp,sto as kst,sto_reg as reg,
 'otpr' as par_name,0 as kol_bil,round(p_plata/k_tuda_obr) as plata,round(p_poteri/k_tuda_obr)  as poteri,kol_pas1 as kol_pas,kol_pas1*srasst as pass_km
 from prig_dat_mar2  
 union all
 select YYYYMM,nom_bil,date_zap,part_zap,date_otpr as date,TERM_DOR,agent,chp,stn as kst,stn_reg as reg,
 'otpr' as par_name,0 as kol_bil,p_plata-round(p_plata/k_tuda_obr) as plata,p_poteri-round(p_poteri/k_tuda_obr)  as poteri,kol_pas1 as kol_pas,kol_pas1*srasst as pass_km
 from prig_dat_mar2  where k_tuda_obr=2 
 

 -----------------------------
 ) as a
 group by  YYYYMM,nom_bil,date_zap,part_zap,date,TERM_DOR,agent,chp,/*kst,*/reg,par_name) as b
 join isp_bil as c on b.nom_bil=c.nom_bil
 where kol_bil!=0 or plata!=0 or poteri!=0 or kol_pas!=0 or pass_km!=0),
  
itog2 as
(select * from 
(select YYYYMM,nom_bil,date_zap,part_zap,date,TERM_DOR,agent,chp,kst,reg,kol_bil,plata,poteri,kol_pas,pass_km,
 FLG_CHILD,FLG_MILITARY,kod_lgt,ABONEMENT_TYPE,prod,
 case when flg_bag in('0','?') then par_name
 	when par_name='prod' then 'bag'
    when par_name='perebor' then 'bag_pereb'
 	else '' end as par_name
 from itog) as a where par_name!='')
 
 
select YYYYMM,nom_bil,date_zap,part_zap,date,TERM_DOR,agent,chp,kst,reg,par_name,kol_bil,plata,poteri,kol_pas,pass_km,FLG_CHILD,FLG_MILITARY,kod_lgt,ABONEMENT_TYPE,prod
	from itog2;


 
/**/ 
 
insert into  l3_mes.prig_times(date_zap,part_zap,shema,rezult,oper,date,time,time2)
with 
dat as (select date_zap,part_zap,shema from l3_mes.prig_times where oper='to_agregate_kst')

select date_zap,part_zap,shema,rezult,oper,date,time,
(cast(substr(time,1,2) as dec(3))*60+cast(substr(time,4,2) as dec(3)))*60+cast(substr(time,7,6) as dec(7,3)) as time2
from
(select date_zap,part_zap,shema,rezult,'write_agr_kst' as oper,
 current_date as date,substr(cast(clock_timestamp()::time as char(50)),1,12) as time
 from
(select count(*) as rezult from l3_mes.prig_agr_kst where part_zap in (select part_zap from dat)) as a,dat as b) as c;

update l3_mes.prig_times set oper='agregate_kst' where oper='to_agregate_kst';




--  select * from l3_mes.prig_times where oper in ('to_agregate_kst','agregate_kst','write_agr_kst') ; -- order by date_zap descending 


--  delete from  l3_mes.prig_agr_kst;
--  delete from l3_mes.prig_times where oper in ('to_agregate','to_agregate_kst','write_agr_kst');

/** /



select yyyymm,count(*) from l3_mes.prig_agr_kst where kst=0 group by 1;
/*
202303	763081
202304	8174121
202305	311298

202303	900394
202304	9650264
202305	345676

202303	137313
202304	1476143
202305	34378
*/


select * from l3_mes.prig_agr_kst where yyyymm=202305 fetch first 100 rows only;

/ **/



