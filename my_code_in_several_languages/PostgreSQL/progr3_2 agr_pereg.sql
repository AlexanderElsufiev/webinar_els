
--ПРОГРАММА ВЫЧИСЛЕНИЯ АГРЕГАТОВ ПО ПЕРЕГОНАМ из наработки обогащения


/**/
--- ввод времени начала операции
delete from spb_prig.prig_times where oper='to_agregate_per';

insert into  spb_prig.prig_times(date_zap,rezult,oper,date,time,time2)
select date_zap,rezult,oper,date,time,
(cast(substr(time,1,2) as dec(3))*60+cast(substr(time,4,2) as dec(3)))*60+cast(substr(time,7,6) as dec(7,3)) as time2
from
(select date_zap,rezult,'to_agregate_per' as oper,
 current_date as date,substr(cast(clock_timestamp()::time as char(50)),1,12) as time
from
(select date_zap,rezult,row_number() over (order by date_zap) as nom
 from  spb_prig.prig_times
 	where oper in('write','prig_work 2_4_itog') and date_zap not in(select date_zap from  spb_prig.prig_times where oper='write_agr_pereg' )) as a
	where  nom=1) as b;
----------------------------------------------

-- delete from spb_prig.prig_agr_kst;
----------------------------------------------
/**/

/**/
insert into spb_prig.prig_agr_pereg
(YYYYMM,nom_bil,date_zap,date,TERM_DOR,agent,chp,reg,st1,st2,rst,dor,lin,otd,dcs,peregon,par_name,plata,poteri,per_pas,otpr_pas,prib_pas)
/**/ 
with

prig as
(select id,doc_num,YYYYMM,nom_mar,nom_bil,nom_dat,date_zap,date_beg,date_pr,TERM_DOR,term_pos,term_trm,agent,chp,stp,stp_reg,k_bil,kol_bil,plata,poteri,perebor,nedobor
 from spb_prig.prig_itog where date_zap in (select date_zap from spb_prig.prig_times where oper='to_agregate_per')),
 
isp_bil as
(select nom_bil,flg_ruch,vid_rasch,FLG_CHILD,flg_voin,FLG_MILITARY,flg_lgt,FLG_BSP,FLG_SO,FLG_NU,FLG_TT,
klass,kod_lgt,lgt_reg,flg_bag,bag_vid,bag_ves,flg_rab_day,proc_lgt,ABONEMENT_TYPE,
k_pas,srok_bil,srok_mon,TRAIN_CATEGORY,TRAIN_NUM,grup_lgt,
cast(FLG_tuda_obr as dec(3)) as k_tuda_obr
from spb_prig.prig_bil where nom_bil in (select distinct nom_bil from  prig) and flg_bag='0'),

isp_dat as
(select nom_dat,cast(plus_dat as integer) as plus_dat,kpas_day,
 sum(kpas_day) over(partition by nom_dat) as skpas,sum(kpas_day) over(partition by nom_dat order by plus_dat) as sk_pas
from spb_prig.prig_dats where nom_dat in (select distinct nom_dat from  prig)),



isp_mar as
(select nom_mar,nom,reg,st1,st2,rst,dor,lin,otd,dcs,d_plata,d_poteri,peregon,--sto,stn,srasst,marshr,sto_zone,stn_zone,sti,sti_zone,
 max(nom) over (partition by nom_mar) as max_nom 
from spb_prig.prig_mars where nom_mar in (select distinct nom_mar from  prig)),



isp_mar2 as
(select *,sum(case when rst=s_rst then p_plata else 0 end) over (partition by nom_mar order by part) as sd_plata,
 sum(case when rst=s_rst then p_poteri else 0 end) over (partition by nom_mar order by part) as sd_poteri,
 case when nom=1 then '1' else '0' end as pr_otpr,case when nom=max_nom then '1' else '0' end as pr_prib
 from
(select *,sum(d_plata) over (partition by nom_mar,part) as p_plata,sum(d_poteri) over (partition by nom_mar,part) as p_poteri,
 sum(rst) over (partition by nom_mar,part) as p_rst,sum(rst) over (partition by nom_mar,part order by nom) as s_rst
 from
(select *,-sum(case when d_plata is not null then 1 else 0 end) over (partition by nom_mar order by -nom) as part,
 sum(d_plata) over (partition by nom_mar) as s_plata,
 sum(d_poteri) over (partition by nom_mar) as s_poteri
from isp_mar) as a) as b),


prig_mar as --сперва разбивка денег по кускам маршрута, до перегонов
(select id,YYYYMM,nom_mar,nom_bil,nom_dat,date_zap,date_beg,date_pr,TERM_DOR,agent,chp,stp,stp_reg,k_bil,kol_bil,--plata,poteri,
 nom,reg,st1,st2,rst,dor,lin,otd,dcs,pr_otpr,pr_prib,peregon,k_tuda_obr,k_pas,--d_plata,d_poteri,s_plata,s_poteri,p_plata,p_poteri,sd_plata,sd_poteri,p_rst,s_rst,pl,pot,
 case when s_rst=p_rst then pl-round(pl*(s_rst-rst)/(p_rst*k_bil*k_tuda_obr))*k_bil*k_tuda_obr
 	else (round(pl*s_rst/(p_rst*k_bil*k_tuda_obr))-round(pl*(s_rst-rst)/(p_rst*k_bil*k_tuda_obr)))*k_bil*k_tuda_obr end as d_plata,
 case when s_rst=p_rst then pot-round(pot*(s_rst-rst)/(p_rst*k_bil*k_tuda_obr))*k_bil*k_tuda_obr
 	else (round(pot*s_rst/(p_rst*k_bil*k_tuda_obr))-round(pot*(s_rst-rst)/(p_rst*k_bil*k_tuda_obr)))*k_bil*k_tuda_obr end as d_poteri
 from
(select id,YYYYMM,a.nom_mar,a.nom_bil,nom_dat,date_zap,date_beg,date_pr,TERM_DOR,agent,chp,stp,stp_reg,k_bil,kol_bil,--plata,poteri,
 nom,reg,st1,st2,rst,dor,lin,otd,dcs,d_plata,d_poteri,s_plata,s_poteri,p_plata,p_poteri,sd_plata,sd_poteri,p_rst,s_rst,pr_otpr,pr_prib,peregon,k_tuda_obr,k_pas,
 case when sd_plata=s_plata then plata-round(plata*(sd_plata-p_plata)/(s_plata*k_bil))*k_bil
 	else (round(plata*sd_plata/(s_plata*k_bil))-round(plata*(sd_plata-p_plata)/(s_plata*k_bil)))*k_bil end as pl,
 case when sd_poteri=s_poteri then poteri-round(poteri*(sd_poteri-p_poteri)/(s_poteri*k_bil))*k_bil
 	else (round(poteri*sd_poteri/(s_poteri*k_bil))-round(poteri*(sd_poteri-p_poteri)/(s_poteri*k_bil)))*k_bil end as pot
 from prig as a join isp_mar2 as b on a.nom_mar=b.nom_mar
  join isp_bil as c on a.nom_bil=c.nom_bil
) as c),

 
 
prig_mar_dat as --далее подразбивка по датам отправления
/*
(select YYYYMM,nom_bil,date_zap,TERM_DOR,agent,chp,reg,st1,st2,rst,dor,lin,otd,dcs,date_otpr,pr_otpr,pr_prib,peregon,
 sum(kol_pas1) as kol_pas1,sum(p_plata) as p_plata,sum(p_poteri) as p_poteri 
 from  */
(select YYYYMM,nom_bil,date_zap,date_pr,TERM_DOR,agent,chp,stp,stp_reg,reg,st1,st2,rst,dor,lin,otd,dcs,pr_otpr,pr_prib,peregon,k_tuda_obr,
 date_beg+plus_dat as date_otpr,
 kol_bil*kpas_day as kol_pas1,
 case when sk_pas=skpas then d_plata-round(d_plata*(sk_pas-kpas_day)/(skpas*k_bil*k_tuda_obr))*k_bil*k_tuda_obr 
 	else (round(d_plata*sk_pas/(skpas*k_bil*k_tuda_obr))-round(d_plata*(sk_pas-kpas_day)/(skpas*k_bil*k_tuda_obr)))*k_bil*k_tuda_obr end as p_plata,
 case when sk_pas=skpas then d_poteri-round(d_poteri*(sk_pas-kpas_day)/(skpas*k_bil*k_tuda_obr))*k_bil*k_tuda_obr
 	else (round(d_poteri*sk_pas/(skpas*k_bil*k_tuda_obr))-round(d_poteri*(sk_pas-kpas_day)/(skpas*k_bil*k_tuda_obr)))*k_bil*k_tuda_obr end as p_poteri 
 from prig_mar as a join isp_dat as b on a.nom_dat=b.nom_dat),
 --as a group by YYYYMM,nom_bil,date_zap,TERM_DOR,agent,chp,reg,st1,st2,rst,dor,lin,otd,dcs,date_otpr,pr_otpr,pr_prib,peregon),
 
 
prig_mar_dat2 as --последняя подразбивка по денег по туда-обратно
(select YYYYMM,-1 as nom_bil,date_zap,date_pr,TERM_DOR,agent,chp,stp,stp_reg,reg,st1,st2,rst,dor,lin,otd,dcs,pr_otpr,pr_prib,peregon,k_tuda_obr,
 date_otpr,kol_pas1 as kol_pas,
 round(p_plata/k_tuda_obr) as p_plata,round(p_poteri/k_tuda_obr) as p_poteri
 from prig_mar_dat
 union all
 select YYYYMM,-1 as nom_bil,date_zap,date_pr,TERM_DOR,agent,chp,stp,stp_reg,reg,st2 as st1,st1 as st2,rst,dor,lin,otd,dcs,
 pr_prib as pr_otpr,pr_otpr as pr_prib,-peregon as peregon,k_tuda_obr,date_otpr,kol_pas1 as kol_pas,
 p_plata-round(p_plata/k_tuda_obr) as p_plata,p_poteri-round(p_poteri/k_tuda_obr) as p_poteri
 from prig_mar_dat where k_tuda_obr=2),
 
 
 
prig_mar2 as --сумма итогов по дате продажи
(select YYYYMM,nom_bil,date_zap,date_pr,TERM_DOR,agent,chp,reg,st1,st2,rst,dor,lin,otd,dcs,pr_otpr,pr_prib,peregon,
 sum(p_plata) as d_plata,sum(p_poteri) as d_poteri,sum(kol_pas) as kol_pas
  from prig_mar_dat2
 group by YYYYMM,nom_bil,date_zap,date_pr,TERM_DOR,agent,chp,reg,st1,st2,rst,dor,lin,otd,dcs,pr_otpr,pr_prib,peregon),
 
 
 prig_mar_dat3 as 
 (select YYYYMM,nom_bil,date_zap,TERM_DOR,agent,chp,reg,st1,st2,rst,dor,lin,otd,dcs,date_otpr,pr_otpr,pr_prib,peregon,
 sum(kol_pas) as kol_pas,sum(p_plata) as p_plata,sum(p_poteri) as p_poteri 
 from prig_mar_dat2
 group by YYYYMM,nom_bil,date_zap,TERM_DOR,agent,chp,reg,st1,st2,rst,dor,lin,otd,dcs,date_otpr,pr_otpr,pr_prib,peregon),
 
  
  
itog as
(select YYYYMM,nom_bil,date_zap,date,TERM_DOR,agent,chp,reg,st1,st2,rst,dor,lin,otd,dcs,peregon,par_name,
 sum(plata) as plata,sum(poteri) as poteri,sum(kol_pas) as per_pas,sum(otpr_pas) as otpr_pas,sum(prib_pas) as prib_pas
 from
(select YYYYMM,nom_bil,date_zap,date_pr as date,TERM_DOR,agent,chp,reg,st1,st2,rst,dor,lin,otd,dcs,peregon,
 'prod' as par_name,d_plata as plata,d_poteri as poteri,kol_pas,
 case when pr_otpr='1' then kol_pas else 0 end as otpr_pas,case when pr_prib='1' then kol_pas else 0 end as prib_pas
 from prig_mar2
 union all
 select YYYYMM,nom_bil,date_zap,date_otpr as date,TERM_DOR,agent,chp,reg,st1,st2,rst,dor,lin,otd,dcs,peregon,--pr_otpr,pr_prib,
 'otpr' as par_name,p_plata as plata,p_poteri as poteri,kol_pas,
 case when pr_otpr='1' then kol_pas else 0 end as otpr_pas,case when pr_prib='1' then kol_pas else 0 end as prib_pas
 from prig_mar_dat3) as a
 group by YYYYMM,nom_bil,date_zap,date,TERM_DOR,agent,chp,reg,st1,st2,rst,dor,lin,otd,dcs,peregon,par_name)
 
select YYYYMM,nom_bil,date_zap,date,TERM_DOR,agent,chp,reg,st1,st2,rst,dor,lin,otd,dcs,peregon,par_name,plata,poteri,per_pas,otpr_pas,prib_pas
from itog ;

/** /
select count(*) from prig
union all
select count(*) from prig_mar
union all
select count(*) from prig_mar2  -- 395334 -- 128686
union all
select count(*) from (select distinct reg,st1,st2,rst from prig_mar2) as a  --2213
union all
select count(*) from prig_mar_dat -- 1342942 -- 211631 -- +otpr+prib=264517
union all
select count(*) from prig_mar_dat2 -- 1342942 -- 211631 -- +otpr+prib=264517
union all
select count(*) from prig_mar_dat3 -- 1265697 -- 1223087
union all
select count(*) from itog
/ **/








/** /
insert into  spb_prig.prig_times(date_zap,rezult,oper,date,time,time2)
with 
dat as (select date_zap from spb_prig.prig_times where oper='to_agregate_per')

select date_zap,rezult,oper,date,time,
(cast(substr(time,1,2) as dec(3))*60+cast(substr(time,4,2) as dec(3)))*60+cast(substr(time,7,6) as dec(7,3)) as time2
from
(select date_zap,rezult,'write_agr_pereg' as oper,
 current_date as date,substr(cast(clock_timestamp()::time as char(50)),1,12) as time
 from
(select count(*) as rezult from spb_prig.prig_agr_pereg where date_zap in (select date_zap from dat)) as a,dat as b) as c;


update spb_prig.prig_times set oper='agregate_per' where oper='to_agregate_per';


select * from spb_prig.prig_times where oper in ('agregate_per','write_agr_pereg');



--  delete from  spb_prig.prig_agr_pereg;
--  delete from spb_prig.prig_times where oper in ('agregate_per','to_agregate_per','write_agr_pereg');

/ **/


