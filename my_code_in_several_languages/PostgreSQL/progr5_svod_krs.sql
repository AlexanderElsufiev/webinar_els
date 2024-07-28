







select count(*) from rawdl2.l2_krs  where arxiv_code in(17,25) and no_use is null -- 73 --41 реально


select request_date,no_use,arxiv_code,count(*) from rawdl2s.l2_krs  group by 1,2,3-- 2631 реально




---------------------------------------------------

--    delete from l3_mes.svod_work


insert into l3_mes.svod_work
(rez,id_svod,yyyy,mm,oper_cnt,request_date,agent_code,subagent_code,term_pos,term_dor,otd,term_trm,sale_station,flg_oper, 
 carrier_cnt,carrier_code,registration_method, military_code,paymenttype,sale_channel,oper_channel,flg_pakr,
 flg_checktape,payment_code,kodagnels,koddorels,prdogels,flg_elssubag,els_code ,terminal_posruc,rate_date,vatrate,
 doc_qty,doc_vz,usl_qty,sum_sb,sum_sbv,vat_sum,idnum)

with 
dats as (select min_id_svod,date_zap,min_id,max_id from l3_mes.prig_times where oper='dannie' and dann='svod_krs'),
gos as (select g_kod,G_PRSNG as SNG,g_vid from nsi.gosk,dats where date_zap between g_datani and g_dataki and  date_zap between g_datan and g_datak),
dor as (select distinct d_nom3,d_kod,d_vidgos from NSI.DORK,dats where date_zap between d_datani and d_dataki and date_zap between d_datan and d_datak),

krs as
(select * from rawdl2m.l2_krs
 where request_date in (select date_zap from dats) and idnum between (select min_id from dats) and (select max_id from dats) 
 and arxiv_code in(17,25) and no_use is null),

dann as
(select
idnum,yyyymm,request_date,agent_code,subagent_code,term_pos,term_dor,term_trm,
cast(sale_station as dec(7)) sale_station,
case when gg.g_kod='20' then '20' else '0' end as oper_cnt,
cast(b.otd as smallint) as otd,
case when request_type= 17 and request_subtype=773 then '2' else '4' end  as flg_oper,
carrier_cnt,
carrier_code,registration_method,military_code,paymenttype,sale_channel,oper_channel,flg_pakr,flg_checktape,
case when oper='V' then 0 when oper_g='N' then 1 else -1 end as doc_qty,
case when oper='O' then 0 when oper_g='N' then -1 else 1 end as doc_vz,
case when request_type=17 and request_subtype=783 then group_code
	when request_type=17 and request_subtype=773 then adult_qty+child_qty else 0 end as usl_qty,
pay_code as payment_code,els_code,agent_code as kodagnels,
'?'  as koddorels,
'?' as prdogels,
case when subagent_code=0 then '0' else '1' end as flg_elssubag,
case when registration_method='1' then term_pos else '' end as terminal_posruc,
oper_date as rate_date,sum_sb,sum_sbv,vat_sum,vatrate

from krs as a
left join nsi.stanv as b on b.STAN = a.sale_station and a.request_date between b.datand and b.datakd and a.request_date between b.datani and  b.dataki
left join  DOR as g on a.term_dor=g.d_kod 
left join gos as gg  on g.d_vidgos=gg.g_vid ),

grup1 as
(select 
count(*) over(order by yyyymm,oper_cnt,request_date,agent_code,subagent_code,term_pos,term_dor,otd,term_trm,sale_station,
flg_oper,carrier_cnt,carrier_code,registration_method, military_code,paymenttype,sale_channel,oper_channel,flg_pakr,
flg_checktape,payment_code,kodagnels,koddorels,prdogels,flg_elssubag,els_code ,terminal_posruc,rate_date,vatrate) as idd1, *
from dann),

grup2 as
(select row_number() over(order by idd1)   +min_id_svod   as id_svod,idd1,
 round(yyyymm/100) as yyyy,mod(yyyymm,100) as mm,
 oper_cnt,request_date,agent_code,subagent_code,term_pos,term_dor,otd,term_trm,sale_station,flg_oper, 
 carrier_cnt,carrier_code,registration_method, military_code,paymenttype,sale_channel,oper_channel,flg_pakr,
 flg_checktape,payment_code,kodagnels,koddorels,prdogels,flg_elssubag,els_code ,terminal_posruc,rate_date,vatrate,
 doc_qty,doc_vz,usl_qty,sum_sb,sum_sbv,vat_sum
 from
(select idd1,yyyymm,oper_cnt,request_date,agent_code,subagent_code,term_pos,term_dor,otd,term_trm,sale_station,flg_oper, 
carrier_cnt,carrier_code,registration_method, military_code,paymenttype,sale_channel,oper_channel,flg_pakr,
flg_checktape,payment_code,kodagnels,koddorels,prdogels,flg_elssubag,els_code ,terminal_posruc,rate_date,vatrate,
 sum(doc_qty) as doc_qty,sum(doc_vz) as doc_vz,
 sum(usl_qty) as usl_qty,sum(sum_sb) as sum_sb,
 sum(sum_sbv) as sum_sbv,sum(vat_sum) as vat_sum 
from grup1
group by idd1,yyyymm,oper_cnt,request_date,agent_code,subagent_code,term_pos,term_dor,otd,term_trm,sale_station,flg_oper, 
carrier_cnt,carrier_code,registration_method, military_code,paymenttype,sale_channel,oper_channel,flg_pakr,
flg_checktape,payment_code,kodagnels,koddorels,prdogels,flg_elssubag,els_code ,terminal_posruc,rate_date,vatrate) as a ,dats as b),

grup3 as (select idnum,id_svod from grup1 as a join grup2 as b on a.idd1=b.idd1),

itog as
(select 1 as rez,id_svod,yyyy,mm,oper_cnt,request_date,agent_code,subagent_code,term_pos,term_dor,otd,term_trm,sale_station,flg_oper, 
carrier_cnt,carrier_code,registration_method, military_code,paymenttype,sale_channel,oper_channel,flg_pakr,
flg_checktape,payment_code,kodagnels,koddorels,prdogels,flg_elssubag,els_code ,terminal_posruc,rate_date,vatrate,
 doc_qty,doc_vz,usl_qty,sum_sb,sum_sbv,vat_sum,0 as idnum
 from grup2
 union all
 select 2 as rez,id_svod,NULL as yyyy,NULL as mm,NULL as oper_cnt,NULL as request_date,NULL as agent_code,NULL as subagent_code,
 NULL as term_pos,NULL as term_dor,NULL as otd,NULL as term_trm,NULL as sale_station,NULL as flg_oper,NULL as carrier_cnt,
 NULL as carrier_code,NULL as registration_method,NULL as military_code,NULL as paymenttype,NULL as sale_channel,
 NULL as oper_channel,NULL as flg_pakr,NULL as flg_checktape,NULL as payment_code,NULL as kodagnels,NULL as koddorels,
 NULL as prdogels,NULL as flg_elssubag,NULL as els_code,NULL as terminal_posruc,NULL as rate_date,NULL as vatrate,
 NULL as doc_qty,NULL as doc_vz,NULL as usl_qty,NULL as sum_sb,NULL as sum_sbv,NULL as vat_sum,idnum
 from grup3)

select * from itog;

--select rez,count(*) as kol from itog group by 1


--------

--- запись данных

--  delete from rawdl2_day.svod_krs;


insert into rawdl2_day.svod_krs
(id_svod_krs,yyyy,mm,oper_cnt,request_date,agent_code,subagent_code,term_pos,term_dor,otd,term_trm,sale_station,flg_oper
,carrier_cnt,carrier_code,registration_method, military_code,paymenttype,sale_channel,oper_channel,flg_pakr
,flg_checktape,payment_code,kodagnels,koddorels,prdogels,flg_elssubag,els_code,terminal_posruc,rate_date,vatrate
,doc_qty,doc_vz,usl_qty,sum_sb,sum_sbv,vat_sum
)
select id_svod as id_svod_krs,yyyy,mm,oper_cnt,request_date,agent_code,subagent_code,term_pos,term_dor,otd,term_trm,sale_station,flg_oper
,carrier_cnt,carrier_code,registration_method, military_code,paymenttype,sale_channel,oper_channel,flg_pakr
,flg_checktape,payment_code,kodagnels,koddorels,prdogels,flg_elssubag,els_code,terminal_posruc,rate_date,vatrate,
doc_qty,doc_vz,usl_qty,sum_sb,sum_sbv,vat_sum
from  l3_mes.svod_work where rez=1;



/* 
select * from rawdl2_day.svod_krs;

id_svod_krs,yyyy,mm,oper_cnt,request_date,agent_code,subagent_code,term_pos,term_dor,otd,term_trm,sale_station,flg_oper, 
carrier_cnt,carrier_code,registration_method, military_code,paymenttype,sale_channel,oper_channel,flg_pakr,
flg_checktape,payment_code,kodagnels,koddorels,prdogels,flg_elssubag,els_code ,terminal_posruc,rate_date,vatrate,
doc_qty,doc_vz,usl_qty,sum_sb,sum_sbv,vat_sum
*/




----------------------------------


--   delete from rawdl2_day.link_svod_krs;

insert into  rawdl2_day.link_svod_krs(id_svod_krs,id_num_krs)
select id_svod as id_svod_krs,array_agg(idnum order by idnum) as id_num_krs
from l3_mes.svod_work where rez=2 group by 1;




----------------------------------
















 
 
 
 
 
 
 
 
 
 
 

















/**/