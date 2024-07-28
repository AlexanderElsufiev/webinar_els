

--ПРОГРАММА ВЫЧИСЛЕНИЯ ПОСТАНЦИОННЫХ АГРЕГАТОВ из наработки обогащения

/**/
--- ввод времени начала операции
delete from l3_prig.prig_times where oper='to_agregate_kst';

insert into  l3_prig.prig_times(date_zap,part_zap,shema,rezult,oper,date,time,time2)
select date_zap,part_zap,shema,rezult,oper,date,time,
(cast(substr(time,1,2) as dec(3))*60+cast(substr(time,4,2) as dec(3)))*60+cast(substr(time,7,6) as dec(7,3)) as time2
from
(select date_zap,part_zap,shema,rezult,'to_agregate_kst' as oper,
 current_date as date,substr(cast(clock_timestamp()::time as char(50)),1,12) as time
from
(select date_zap,part_zap,shema,oper,rezult,row_number() over (order by part_zap) as nom
 from  l3_prig.prig_times
 	where oper in('write','prig_work 2_4_itog') and part_zap not in(select part_zap from  l3_prig.prig_times where oper='write_agr_kst' )) as a
	where  nom=1) as b;
----------------------------------------------

--select * from l3_prig.prig_times where oper='to_agregate_kst' 

--update l3_prig.prig_times set date_zap='2021-08-20' where oper='to_agregate_kst' 


-- delete from l3_prig.prig_agr_kst;
----------------------------------------------
/**/

--Поле date_beg убрать - было нужно лишь для расследования!!!
insert into l3_prig.prig_agr_kst
(YYYYMM,nom_bil,date_zap,part_zap,date,/*date_beg,*/TERM_DOR,term_pos,term_trm,agent,chp,kst,reg,par_name,param1,param2,FLG_CHILD,FLG_MILITARY,kod_lgt,ABONEMENT_TYPE,prod)
 
with

prig as
(select *
 --YYYYMM,nom_mar,nom_bil,nom_dat,date_zap,part_zap,date_beg,date_pr,TERM_DOR,term_pos,term_trm,agent,chp,stp,stp_reg,k_bil,kol_bil,plata,poteri,perebor,nedobor
 from l3_prig.prig_itog where part_zap in (select part_zap from l3_prig.prig_times where oper='to_agregate_kst')
--and nom_bil=253 and term_dor='О' and chp=23  and nom_mar=5497
),
 
isp_bil as
(select nom_bil,flg_ruch,vid_rasch,FLG_CHILD,flg_voin,FLG_MILITARY,flg_lgt,FLG_BSP,FLG_SO,FLG_NU,FLG_TT,
klass,kod_lgt,lgt_reg,flg_bag,bag_vid,bag_ves,flg_rab_day,proc_lgt,ABONEMENT_TYPE,prod,
k_pas,srok_bil,srok_mon,TRAIN_CATEGORY,TRAIN_NUM,grup_lgt,
cast(FLG_tuda_obr as dec(3)) as k_tuda_obr
from l3_prig.prig_bil where nom_bil in (select distinct nom_bil from  prig)),



isp_mar as
(select nom_mar,sto,stn,srasst,marshr,nom,reg,st1,st2,rst,sto_zone,stn_zone,sti,sti_zone,dor,lin,/*date_zap,*/otd,dcs,d_plata,d_poteri,
 max(nom) over (partition by nom_mar) as max_nom 
from l3_prig.prig_mars where nom_mar in (select distinct nom_mar from  prig)),

isp_mar2 as
(select distinct nom_mar,sto,stn,srasst,
 sum(case when nom=1 then reg else 0 end) over (partition by nom_mar) as sto_reg,
 sum(case when nom=max_nom then reg else 0 end) over (partition by nom_mar) as stn_reg
 from isp_mar),

isp_dat as
(select nom_dat,cast(plus_dat as integer) as plus_dat,kpas_day,
 sum(kpas_day) over(partition by nom_dat) as skpas,sum(kpas_day) over(partition by nom_dat order by plus_dat) as sk_pas
from l3_prig.prig_dats where nom_dat in (select distinct nom_dat from  prig)),

prig_dat as
(select YYYYMM,nom_mar,nom_bil,date_zap,part_zap,TERM_DOR,term_pos,term_trm,agent,chp,stp,stp_reg,date_beg,date_otpr,k_tuda_obr,
 sum(kol_pas1) as kol_pas1,sum(p_plata) as p_plata,sum(p_poteri) as p_poteri
 from
(select YYYYMM,nom_mar,a.nom_bil,date_zap,part_zap,date_beg,TERM_DOR,term_pos,term_trm,agent,chp,stp,stp_reg,
 plus_dat,kpas_day,skpas,sk_pas,date_beg+plus_dat as date_otpr,kol_bil*kpas_day as kol_pas1,k_tuda_obr,
 --для билета туда-обратно и нечётной суммы надов конце особое разбиение, без округления
 case when sk_pas=skpas then plata-(round(plata*(sk_pas-kpas_day)/(skpas*k_bil*k_tuda_obr)))*k_bil*k_tuda_obr
 else (round(plata*sk_pas/(skpas*k_bil*k_tuda_obr))-round(plata*(sk_pas-kpas_day)/(skpas*k_bil*k_tuda_obr)))*k_bil*k_tuda_obr end as p_plata,
 case when sk_pas=skpas then poteri-(round(poteri*(sk_pas-kpas_day)/(skpas*k_bil*k_tuda_obr)))*k_bil*k_tuda_obr
 else (round(poteri*sk_pas/(skpas*k_bil*k_tuda_obr))-round(poteri*(sk_pas-kpas_day)/(skpas*k_bil*k_tuda_obr)))*k_bil*k_tuda_obr end as p_poteri
 from prig as a join isp_bil as b on a.nom_bil=b.nom_bil
 join isp_dat as c on a.nom_dat=c.nom_dat) as a
 group by YYYYMM,nom_mar,nom_bil,date_zap,part_zap,TERM_DOR,term_pos,term_trm,agent,chp,stp,stp_reg,date_beg,date_otpr,k_tuda_obr),



prig_dat_mar2 as
(select YYYYMM,sto,stn,sto_reg,stn_reg,srasst,a.nom_bil,k_tuda_obr,date_zap,part_zap,TERM_DOR,term_pos,term_trm,agent,chp,stp,stp_reg,date_beg,date_otpr,
 sum(kol_pas1) as kol_pas1,sum(p_plata) as p_plata,sum(p_poteri) as p_poteri
 from prig_dat as a join isp_mar2 as b on a.nom_mar=b.nom_mar
 --join isp_bil as c on a.nom_bil=c.nom_bil
group by YYYYMM,sto,stn,sto_reg,stn_reg,srasst,a.nom_bil,k_tuda_obr,date_zap,part_zap,TERM_DOR,term_pos,term_trm,agent,chp,stp,stp_reg,date_beg,date_otpr
)


,prig_bil_mar as
(select YYYYMM,a.nom_bil,date_zap,part_zap,date_pr,date_beg,TERM_DOR,term_pos,term_trm,agent,chp,stp,stp_reg,
 sum(kol_bil) as kol_bil,sum(plata) as plata,sum(poteri) as poteri,sum(perebor) as perebor,sum(nedobor) as nedobor,
 sum(kol_bil*k_pas*k_tuda_obr) as kol_pas,sum(kol_bil*k_pas*srasst*k_tuda_obr) as kol_pkm
 from prig as a join isp_bil as b on a.nom_bil=b.nom_bil
 join isp_mar2 as c on a.nom_mar=c.nom_mar
 group by YYYYMM,a.nom_bil,date_zap,part_zap,date_pr,date_beg,TERM_DOR,term_pos,term_trm,agent,chp,stp,stp_reg
)
 

,itog as
(select YYYYMM,b.nom_bil,date_zap,part_zap,date,/*date_beg,*/TERM_DOR,term_pos,term_trm,agent,chp,kst,reg,par_name,param1,param2,
 FLG_CHILD,FLG_MILITARY,kod_lgt,ABONEMENT_TYPE,prod,flg_bag
 from
(select YYYYMM,nom_bil,date_zap,part_zap,date,/*date_beg,*/TERM_DOR,term_pos,term_trm,agent,chp,kst,reg,par_name,
 sum(param1) as param1,sum(param2) as param2
 from

(select YYYYMM,nom_bil,date_zap,part_zap,date_pr as date,date_beg,TERM_DOR,term_pos,term_trm,agent,chp,stp as kst,stp_reg as reg,
 'kol_bil' as par_name,kol_bil as param1,0 as param2 --,kol_bil,plata,poteri,perebor,nedobor,kol_pas,kol_pkm
 from prig_bil_mar
 union all
 select YYYYMM,nom_bil,date_zap,part_zap,date_pr as date,date_beg,TERM_DOR,term_pos,term_trm,agent,chp,stp as kst,stp_reg as reg,
 'plata' as par_name,plata as param1,poteri as param2 --,kol_bil,plata,poteri,perebor,nedobor,kol_pas,kol_pkm
 from prig_bil_mar
 
 union all
 select YYYYMM,nom_bil,date_zap,part_zap,date_pr as date,date_beg,TERM_DOR,term_pos,term_trm,agent,chp,stp as kst,stp_reg as reg,
 'perebor' as par_name,perebor as param1,nedobor as param2 --,kol_bil,plata,poteri,perebor,nedobor,kol_pas,kol_pkm
 from prig_bil_mar
 
 union all
 select YYYYMM,nom_bil,date_zap,part_zap,date_pr as date,date_beg,TERM_DOR,term_pos,term_trm,agent,chp,stp as kst,stp_reg as reg,
 'pr_pas' as par_name,kol_pas as param1,kol_pkm as param2 --,kol_bil,plata,poteri,perebor,nedobor,kol_pas,kol_pkm
 from prig_bil_mar
 ----------------------------- 
 union all
 select YYYYMM,nom_bil,date_zap,part_zap,date_otpr as date,date_beg,TERM_DOR,'0' as term_pos,'0' as term_trm,agent,chp,stp as kst,stp_reg as reg,
 'sf_pas' as par_name,kol_pas1*k_tuda_obr as param1,kol_pas1*k_tuda_obr*srasst as param2 
 from prig_dat_mar2 
 union all
 select YYYYMM,nom_bil,date_zap,part_zap,date_otpr as date,date_beg,TERM_DOR,'0' as term_pos,'0' as term_trm,agent,chp,stp as kst,stp_reg as reg,
 'sf_plat' as par_name,p_plata as param1,p_poteri as param2 
 from prig_dat_mar2 
 -----------------------------
  union all
 select YYYYMM,nom_bil,date_zap,part_zap,date_otpr as date,date_beg,TERM_DOR,'0' as term_pos,'0' as term_trm,agent,chp,sto as kst,sto_reg as reg,
 'kol_pas' as par_name,kol_pas1 as param1,kol_pas1*srasst as param2 
 from prig_dat_mar2 
  union all
 select YYYYMM,nom_bil,date_zap,part_zap,date_otpr as date,date_beg,TERM_DOR,'0' as term_pos,'0' as term_trm,agent,chp,stn as kst,stn_reg as reg,
 'kol_pas' as par_name,kol_pas1 as param1,kol_pas1*srasst as param2 
 from prig_dat_mar2  where k_tuda_obr=2 
 
  union all
 select YYYYMM,nom_bil,date_zap,part_zap,date_otpr as date,date_beg,TERM_DOR,'0' as term_pos,'0' as term_trm,agent,chp,sto as kst,sto_reg as reg,
 'p_plata' as par_name,round(p_plata/k_tuda_obr) as param1,round(p_poteri/k_tuda_obr)  as param2 
 from prig_dat_mar2 
  union all
 select YYYYMM,nom_bil,date_zap,part_zap,date_otpr as date,date_beg,TERM_DOR,'0' as term_pos,'0' as term_trm,agent,chp,stn as kst,stn_reg as reg,
 'p_plata' as par_name,p_plata-round(p_plata/k_tuda_obr) as param1,p_poteri-round(p_poteri/k_tuda_obr)  as param2 
 from prig_dat_mar2  where k_tuda_obr=2
 -----------------------------
 ) as a
 group by  YYYYMM,nom_bil,date_zap,part_zap,date,/*date_beg,*/TERM_DOR,term_pos,term_trm,agent,chp,kst,reg,par_name) as b
 join isp_bil as c on b.nom_bil=c.nom_bil
 where param1!=0 or param2!=0),
  
itog2 as
(select * from 
(select YYYYMM,nom_bil,date_zap,part_zap,date,/*date_beg,*/TERM_DOR,term_pos,term_trm,agent,chp,kst,reg,param1,param2,
 FLG_CHILD,FLG_MILITARY,kod_lgt,ABONEMENT_TYPE,prod,
 case when flg_bag in('0','?') then par_name
 	when par_name='kol_bil' then 'bag_bil'
 	when par_name='plata' then 'bag_plat'
 	else '' end as par_name
 from itog) as a where par_name!='')
 
 
select YYYYMM,nom_bil,date_zap,part_zap,date,/*date_beg,*/TERM_DOR,term_pos,term_trm,agent,chp,kst,reg,par_name,param1,param2,FLG_CHILD,FLG_MILITARY,kod_lgt,ABONEMENT_TYPE,prod
	from itog2;


 
/**/ 
 
insert into  l3_prig.prig_times(date_zap,part_zap,shema,rezult,oper,date,time,time2)
with 
dat as (select date_zap,part_zap,shema from l3_prig.prig_times where oper='to_agregate_kst')

select date_zap,part_zap,shema,rezult,oper,date,time,
(cast(substr(time,1,2) as dec(3))*60+cast(substr(time,4,2) as dec(3)))*60+cast(substr(time,7,6) as dec(7,3)) as time2
from
(select date_zap,part_zap,shema,rezult,'write_agr_kst' as oper,
 current_date as date,substr(cast(clock_timestamp()::time as char(50)),1,12) as time
 from
(select count(*) as rezult from l3_prig.prig_agr_kst where part_zap in (select part_zap from dat)) as a,dat as b) as c;

update l3_prig.prig_times set oper='agregate_kst' where oper='to_agregate_kst';




--  select * from l3_prig.prig_times where oper in ('to_agregate_kst','agregate_kst','write_agr_kst') ; -- order by date_zap descending 


--  delete from  l3_prig.prig_agr_kst;
--  delete from l3_prig.prig_times where oper in ('to_agregate','to_agregate_kst','write_agr_kst');

/**/



select * from l3_prig.prig_agr_kst order by nom_bil,par_name

select * from l3_prig.prig_itog where date_zap='2022-08-04'



/**/



