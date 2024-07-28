
/*

 l2_bag_main.oper_type22


select oper_type22,request_type,request_subtype,count(*) as kol from rawdl2s.l2_bag_main group by 1,2,3 order by 1,2,3


select oper_x,request_type,request_subtype,count(*) as kol from rawdl2m.l2_pass_main group by 1,2,3 order by 1,2,3

select count(*) from rawdl2.l2_pass_main  -- 812

/*  -- ручная кладь с превышением веса
select * from
(select case when CARRYON_TYPE='' then '0' else CARRYON_TYPE end as bag_vid,
 case when REGISTRATION_METHOD='1' and FLG_CARRYON='1' and CARRYON_WEIGHT=0 then
	case  when CARRYON_TYPE in ('Ж','В') then 20 when CARRYON_TYPE='Т' then 30 else CARRYON_WEIGHT end
	else CARRYON_WEIGHT end /* *(case when oper_g='G' then -1 else 1 end)*/ as bag_ves, --в поле указан вес одного багажа, а не всех, и не возврата
 *
 from rawdl2.l2_prig_main ) as a
 where bag_vid='Р' and bag_ves>36
*/





select distinct oper_type22   from rawdl2.l2_bag_main ;

--select distinct flg_tt from rawdl2.l2_pass_main ;
*/



-- select * from l3_mes.prig_times  where oper='dannie';



------------- сама программа чтения

--   delete from l3_mes.svod_work

insert into l3_mes.svod_work
(rez,id_svod,yyyy,mm,oper_cnt,request_date,agent_code,subagent_code,term_pos,term_dor,otd,term_trm,sale_station,
flg_oper,carrier_cnt,carrier_code,registration_method,shipment_type,flg_soob,flg_sng,flg_mg,military_code,
paymenttype,sale_channel,oper_channel,flg_pakr,flg_checktape,tick_group,flg_tt,els_code,kodagnels,koddorels,
prdogels,flg_elssubag,terminal_posruc,rate_date,doc_qty,doc_vz,idnum,
sum_code,cnt_code,dor_code,sum_nde,vat_sum,vatrate)

with 
dats as (select min_id_svod,date_zap,min_id,max_id from l3_mes.prig_times where oper='dannie' and dann='svod_bag'),

gos as
(select g_kod,G_PRSNG as SNG,g_vid from nsi.gosk,dats where date_zap between g_datani and g_dataki and  date_zap between g_datan and g_datak),--СНГ

dor as (select distinct d_nom3,d_kod,d_vidgos from NSI.DORK,dats where date_zap between d_datani and d_dataki and date_zap between d_datan and d_datak),

main as
(select * from rawdl2m.l2_bag_main 
 where request_date in (select date_zap from dats) and idnum between (select min_id from dats) and (select max_id from dats)
 and arxiv_code in(17,25) and no_use is null),

cost as
(select idnum,sum_code,cnt_code,cast(dor_code as smallint) as dor_code,paymenttype,sum_nde,vat_sum,vatrate 
 from rawdl2m.l2_bag_cost 
 where request_date in (select date_zap from dats) and idnum between (select min_id from dats) and (select max_id from dats) ),

dann as
(select idnum,yyyymm,
case when gg.g_kod='20' then '20' else '0' end as oper_cnt,
request_date,agent_code,subagent_code,term_pos,term_dor,
cast(b.otd as smallint) as otd,
term_trm,
cast(sale_station as dec(7)) as sale_station,
case when oper_type22 in(5,6) then '1' else '0' end as flg_oper, 
cast(carrier_gos as smallint) as carrier_cnt,
carrier_code,registration_method,shipment_type,
case when c.dor!=d.dor then '3' when c.dor!=term_dor then '2' else '1' end as flg_soob,
case when (c.gos!='20' or d.gos!='20') and ca.sng='1' and da.sng='1'  then '1' else '0' end as flg_sng,
case when ca.sng='0' or da.sng='0' then '1' else '2' end as flg_mg, 
military_code,paymenttype,sale_channel,oper_channel,flg_efreestr as flg_pakr,flg_checktape,
case when oper='V' then 0 when oper_g='N' then 1 else -1 end as doc_qty,
case when oper='O' then 0 when oper_g='N' then -1 else 1 end as doc_vz,
case when (c.gos!='20' or d.gos!='20') then ' ' 
	when tt_ticketgrcode is null then ' '
	else substr(tt_ticketgrcode,3,1) end as tick_group,
case when carriage_kind in ('4','5')  then 'Л' 
  when carriage_kind in ('6','7','8')  then 'С' else '' end as flg_tt,
coalesce(els_code,'') as els_code,agent_code as kodagnels,
 0 as koddorels,
0 as prdogels,
flg_elssubag,
case when registration_method='1' then coalesce(term_pos,'') else '' end as terminal_posruc,
rate_date

from main as a
left join nsi.stanv as b on b.STAN = a.sale_station and
	a.departure_date between b.datand and b.datakd and a.request_date between b.datani and  b.dataki
left join nsi.stanv as c on c.STAN = a.departure_station and
	a.departure_date between c.datand and c.datakd and a.request_date between c.datani and  c.dataki
left join nsi.stanv as d on d.STAN = a.arrival_station and
	a.departure_date between d.datand and d.datakd and a.request_date between d.datani and  d.dataki
left join gos as ca on c.gos=ca.g_kod
left join gos as da on d.gos=da.g_kod
left join dor as g on a.term_dor=g.d_kod 
left join gos as gg  on g.d_vidgos=gg.g_vid
 ),
 

grup1 as
(select 
count(*) over(order by yyyymm,oper_cnt,request_date,agent_code,subagent_code,term_pos,term_dor,otd,term_trm,sale_station,
flg_oper,carrier_cnt,carrier_code,registration_method,shipment_type,flg_soob,flg_sng,flg_mg,military_code,
paymenttype,sale_channel,oper_channel,flg_pakr,flg_checktape,tick_group,flg_tt,els_code,kodagnels,koddorels,
prdogels,flg_elssubag,terminal_posruc,rate_date) as idd1, *
from dann),

grup2 as
(select row_number() over(order by idd1)   +min_id_svod  as id_svod,idd1,
 round(yyyymm/100) as yyyy,mod(yyyymm,100) as mm,
oper_cnt,request_date,agent_code,subagent_code,term_pos,term_dor,otd,term_trm,sale_station,
flg_oper,carrier_cnt,carrier_code,registration_method,shipment_type,flg_soob,flg_sng,flg_mg,military_code,
paymenttype,sale_channel,oper_channel,flg_pakr,flg_checktape,tick_group,flg_tt,els_code,kodagnels,koddorels,
prdogels,flg_elssubag,terminal_posruc,rate_date,doc_qty,doc_vz
 from
(select idd1,yyyymm,oper_cnt,request_date,agent_code,subagent_code,term_pos,term_dor,otd,term_trm,sale_station,
flg_oper,carrier_cnt,carrier_code,registration_method,shipment_type,flg_soob,flg_sng,flg_mg,military_code,
paymenttype,sale_channel,oper_channel,flg_pakr,flg_checktape,tick_group,flg_tt,els_code,kodagnels,koddorels,
prdogels,flg_elssubag,terminal_posruc,rate_date,
sum(doc_qty) as doc_qty,sum(doc_vz) as doc_vz
from grup1
group by idd1,yyyymm,oper_cnt,request_date,agent_code,subagent_code,term_pos,term_dor,otd,term_trm,sale_station,
flg_oper,carrier_cnt,carrier_code,registration_method,shipment_type,flg_soob,flg_sng,flg_mg,military_code,
paymenttype,sale_channel,oper_channel,flg_pakr,flg_checktape,tick_group,flg_tt,els_code,kodagnels,koddorels,
prdogels,flg_elssubag,terminal_posruc,rate_date) as a ,dats as b),

grup3 as 
(select idnum,id_svod from grup1 as a join grup2 as b on a.idd1=b.idd1),

cost2 as
(select id_svod,sum_code,cnt_code,dor_code,paymenttype,vatrate,
 sum(sum_nde) as sum_nde,sum(vat_sum) as vat_sum
from cost as a join grup3 as b on a.idnum=b.idnum
 group by id_svod,sum_code,cnt_code,dor_code,paymenttype,vatrate),

 
itog as
(select 1 as rez,id_svod,yyyy,mm,oper_cnt,request_date,agent_code,subagent_code,term_pos,term_dor,otd,term_trm,sale_station,
flg_oper,carrier_cnt,carrier_code,registration_method,shipment_type,flg_soob,flg_sng,flg_mg,military_code,
paymenttype,sale_channel,oper_channel,flg_pakr,flg_checktape,tick_group,flg_tt,els_code,kodagnels,koddorels,
prdogels,flg_elssubag,terminal_posruc,rate_date,doc_qty,doc_vz,0 as idnum,
0 as sum_code,NULL as cnt_code,0 as dor_code,0 as sum_nde,0 as vat_sum,0 as vatrate
 from grup2
 union all
 select 2 as rez,id_svod,NULL as yyyy,NULL as mm,NULL as oper_cnt,NULL as request_date,NULL as agent_code,NULL as subagent_code,
 NULL as term_pos,NULL as term_dor,NULL as otd,NULL as term_trm,NULL as sale_station,NULL as flg_oper,NULL as carrier_cnt,
 NULL as carrier_code,NULL as registration_method,NULL as shipment_type,NULL as flg_soob,NULL as flg_sng,NULL as flg_mg,
 NULL as military_code,NULL as paymenttype,NULL as sale_channel,NULL as oper_channel,NULL as flg_pakr,NULL as flg_checktape,
 NULL as tick_group,NULL as flg_tt,NULL as els_code,NULL as kodagnels,NULL as koddorels,NULL as prdogels,NULL as flg_elssubag,
 NULL as terminal_posruc,NULL as rate_date,NULL as doc_qty,NULL as doc_vz,idnum,
 0 as sum_code,NULL as cnt_code,NULL as dor_code,0 as sum_nde,0 as vat_sum,0 as vatrate
 from grup3
 union all
 
 select 3 as rez,id_svod,NULL as yyyy,NULL as mm,NULL as oper_cnt,NULL as request_date,NULL as agent_code,NULL as subagent_code,
 NULL as term_pos,NULL as term_dor,NULL as otd,NULL as term_trm,NULL as sale_station,NULL as flg_oper,NULL as carrier_cnt,
 NULL as carrier_code,NULL as registration_method,NULL as shipment_type,NULL as flg_soob,NULL as flg_sng,NULL as flg_mg,
 NULL as military_code,paymenttype,NULL as sale_channel,NULL as oper_channel,NULL as flg_pakr,NULL as flg_checktape,
 NULL as tick_group,NULL as flg_tt,NULL as els_code,NULL as kodagnels,NULL as koddorels,NULL as prdogels,NULL as flg_elssubag,
 NULL as terminal_posruc,NULL as rate_date,NULL as doc_qty,NULL as doc_vz,NULL as idnum,
 sum_code,cnt_code,dor_code,sum_nde,vat_sum,vatrate
 from cost2
)

select * from itog



----------------------------------

--   select cnt_code,* from  l3_mes.svod_work order by id_svod,rez
--   select rez,count(*) as kol from  l3_mes.svod_work group by 1 order by 1

--  delete from rawdl2_day.svod_bag_main;

--  select * from rawdl2_day.svod_bag_main;


insert into rawdl2_day.svod_bag_main
(id_svod_bag,yyyy,mm,oper_cnt,request_date,agent_code,subagent_code,term_pos,term_dor,otd,term_trm,
sale_station,flg_oper,carrier_gos,carrier_code,registration_method,shipment_type,flg_soob,flg_sng,
flg_mg,military_code,paymenttype,sale_channel,oper_channel,flg_pakr,flg_checktape,doc_qty,doc_vz,
tick_group,flg_tt,els_code,kodagnels,koddorels,prdogels,flg_elssubag,terminal_posruc,rate_date)
select 
id_svod as id_svod_bag,yyyy,mm,oper_cnt,request_date,agent_code,subagent_code,term_pos,term_dor,otd,term_trm,
sale_station,flg_oper,carrier_cnt as carrier_gos,carrier_code,registration_method,shipment_type,flg_soob,flg_sng,
flg_mg,military_code,paymenttype,sale_channel,oper_channel,flg_pakr,flg_checktape,doc_qty,doc_vz,
tick_group,flg_tt,els_code,kodagnels,koddorels,prdogels,flg_elssubag,terminal_posruc,rate_date
from l3_mes.svod_work where rez=1;



----------------------------------



--   select * from rawdl2_day.link_svod_bag_main ;
--   delete from rawdl2_day.link_svod_bag_main ;

insert into  rawdl2_day.link_svod_bag_main(id_svod_bag,id_num_bag_main)
select id_svod as id_svod_bag,array_agg(idnum order by idnum) as id_num_bag_main
from l3_mes.svod_work where rez=2 group by 1;



----------------------------------

--   select * from rawdl2_day.svod_bag_cost
--  delete from  rawdl2_day.svod_bag_cost


insert into rawdl2_day.svod_bag_cost
(id_svod_bag,sum_code,cnt_code,dor_code,paymenttype,sum_nde,vat_sum,vatrate)
select id_svod as id_svod_bag,sum_code,cnt_code,dor_code,paymenttype,sum_nde,vat_sum,vatrate
from l3_mes.svod_work where rez=3;




select distinct cnt_code
from l3_mes.svod_work where rez=3;




----------------------------------

 
 coalesce(flg_tt,'')
 
 
 
select distinct  coalesce(flg_tt,''),flg_tt from rawdl2_day.svod_bag_main limit 1000
 
 
 
 
select oper_cnt, flg_oper,* from rawdl2_day.svod_bag_main limit 1000


select * from rawdl2_day.svod_pass_main limit 1000
 
 

















/**/