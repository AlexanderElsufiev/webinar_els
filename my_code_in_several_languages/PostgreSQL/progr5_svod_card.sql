


select /*count(*)*/ distinct service_vatrate from rawdl2m.l2_cards 

select count(*) from rawdl2s.l2_cards 

 
  select count(*) from rawdl2s.l2_pass_main
  
  
--         select * from NSI.SOBPER


delete from  l3_mes.svod_work;




insert into l3_mes.svod_work
(rez,id_svod,yyyy,mm,oper_cnt,request_date,agent_code,subagent_code,term_pos,term_dor,otd,term_trm, 
sale_station,carrier_cnt,carrier_code,registration_method,paymenttype,sale_channel,oper_channel,flg_pakr, 
flg_checktape,flg_internet,payment_code,els_code,kodagnels,koddorels,prdogels,flg_elssubag,rate_date,vatrate,
doc_qty,doc_vz,card_cost,vat_cost,sum_sbv,vat_sum,vatrate_vz,idnum)

with
dats as (select min_id_svod,date_zap,min_id,max_id from l3_mes.prig_times where 'dannie'=oper and dann='svod_card'),

gos as(select g_kod,G_PRSNG as SNG,g_vid from nsi.gosk,dats where date_zap between g_datani and g_dataki and  date_zap between g_datan and g_datak),--СНГ
dor as (select distinct d_nom3,d_kod,d_vidgos from NSI.DORK,dats where date_zap between d_datani and d_dataki and date_zap between d_datan and d_datak),


cards as
(select * from rawdl2m.l2_cards 
 where request_date in (select date_zap from dats) and idnum between (select min_id from dats) and (select max_id from dats)
 and arxiv_code in(17,25) and no_use is null),

dann as
(select idnum,yyyymm,
case when gg.g_kod='20' then '20' else '0' end as oper_cnt,
request_date,agent_code,subagent_code,term_pos,term_dor,term_trm,carrier_code,registration_method,paymenttype,sale_channel,oper_channel,
cast(otd as smallint) as otd,
cast(sale_station as dec(7)) as sale_station,
0  as carrier_cnt,
'?' as flg_pakr,
'?' as flg_checktape,
flg_internet,
case when oper='V' then 0 when oper_g='N' then 1 else -1 end as doc_qty,
case when oper='O' then 0 when oper_g='N' then -1 else 1 end as doc_vz,
payment_code,
'?' as els_code,
0 as kodagnels,
'?' as koddorels,
'?' as prdogels,
case when subagent_code=0 then '0' else '1' end as flg_elssubag,
card_saledate as rate_date,card_cost,service_vat  as vat_cost,
service_vatrate  as vatrate,0 as sum_sbv,0 as vat_sum,0 as vatrate_vz

from cards as a 
 left join nsi.stanv as b on b.STAN = a.sale_station and a.request_date between b.datand and b.datakd and a.request_date between b.datani and  b.dataki
 left join dor as g on a.term_dor=g.d_kod
 left join gos as gg  on g.d_vidgos=gg.g_vid),

grupp1 as
(select 
count(*) over(order by yyyymm, oper_cnt, request_date, agent_code, subagent_code, term_pos,term_dor, otd, term_trm, 
sale_station, carrier_cnt, carrier_code, registration_method, paymenttype, sale_channel, oper_channel, flg_pakr, 
flg_checktape, flg_internet,payment_code, els_code, kodagnels, koddorels, prdogels, flg_elssubag, rate_date, vatrate) as idd1, *
 from dann),
   
grupp2 as
(select (row_number() over())+min_id_svod as id_svod,idd1,
 round(yyyymm/100) as yyyy,mod(yyyymm,100) as mm,
 oper_cnt, request_date, agent_code, subagent_code, term_pos,term_dor, otd, term_trm, 
 sale_station, carrier_cnt, carrier_code, registration_method, paymenttype, sale_channel, oper_channel, flg_pakr, 
 flg_checktape, flg_internet,payment_code, els_code, kodagnels, koddorels, prdogels, flg_elssubag, rate_date, vatrate,
 doc_qty,doc_vz,  card_cost, vat_cost, sum_sbv, vat_sum,vatrate_vz
 from
(select idd1, yyyymm, oper_cnt, request_date, agent_code, subagent_code, term_pos,term_dor, otd, term_trm, 
 sale_station, carrier_cnt, carrier_code, registration_method, paymenttype, sale_channel, oper_channel, flg_pakr, 
 flg_checktape, flg_internet,payment_code, els_code, kodagnels, koddorels, prdogels, flg_elssubag, rate_date, vatrate,
 sum(doc_qty) as doc_qty,sum(doc_vz) as doc_vz,sum(card_cost) as card_cost,sum(vat_cost) as vat_cost,
 sum(sum_sbv) as  sum_sbv,sum(vat_sum) as vat_sum,sum(vatrate_vz) as vatrate_vz
from grupp1
group by idd1,yyyymm, oper_cnt, request_date, agent_code, subagent_code, term_pos,term_dor, otd, term_trm, 
sale_station, carrier_cnt, carrier_code, registration_method, paymenttype, sale_channel, oper_channel, flg_pakr, 
flg_checktape, flg_internet,payment_code, els_code, kodagnels, koddorels, prdogels, flg_elssubag, rate_date, vatrate) as a,dats as b),
 
grupp3 as
(select id_svod,idnum from grupp1 as a join grupp2 as b on a.idd1=b.idd1),

itog as
(select 1 as rez,id_svod,yyyy,mm,oper_cnt, request_date, agent_code, subagent_code, term_pos,term_dor, otd, term_trm, 
sale_station, carrier_cnt, carrier_code, registration_method, paymenttype, sale_channel, oper_channel, flg_pakr, 
flg_checktape, flg_internet,payment_code, els_code, kodagnels, koddorels, prdogels, flg_elssubag, rate_date, vatrate,
  doc_qty,doc_vz,  card_cost, vat_cost, sum_sbv, vat_sum,vatrate_vz,
 0 as idnum
  from grupp2
  union all
  select 2 as rez,id_svod,NULL as yyyy,NULL as mm,NULL as oper_cnt,NULL as request_date,NULL as agent_code,NULL as subagent_code,
 NULL as term_pos,NULL as term_dor,NULL as otd,NULL as term_trm,NULL as sale_station,NULL as carrier_cnt,
 NULL as carrier_code,NULL as registration_method,NULL as paymenttype,NULL as sale_channel,NULL as oper_channel,NULL as flg_pakr, 
 NULL as flg_checktape,NULL as flg_internet,NULL as payment_code,NULL as els_code,NULL as kodagnels,NULL as koddorels, 
 NULL as prdogels,NULL as flg_elssubag,NULL as rate_date,NULL as vatrate,
 NULL as doc_qty,NULL as doc_vz,NULL as card_cost,NULL as vat_cost,NULL as sum_sbv,NULL as vat_sum,NULL as vatrate_vz,
 idnum
  from grupp3)

select * from itog ;





select * from l3_mes.svod_work;




----------------------------------------------------------------------------

delete from rawdl2_day.svod_cards;


insert into rawdl2_day.svod_cards
(id_svod_cards,yyyy,mm,oper_cnt,request_date,agent_code,subagent_code,term_pos,term_dor,
otd,term_trm,sale_station,carrier_gos,carrier_code,registration_method,paymenttype,sale_channel,
oper_channel,flg_pakr,flg_checktape,flg_internet,doc_qty,payment_code,els_code,kodagnels,
koddorels,prdogels,flg_elssubag,rate_date,card_cost,vat_cost,vatrate)
select
id_svod as id_svod_cards,yyyy,mm,oper_cnt,request_date,agent_code,subagent_code,term_pos,term_dor,
otd,term_trm,sale_station,carrier_cnt as carrier_gos,carrier_code,registration_method,paymenttype,sale_channel,
oper_channel,flg_pakr,flg_checktape,flg_internet,doc_qty,payment_code,els_code,kodagnels,
koddorels,prdogels,flg_elssubag,rate_date,card_cost,vat_cost,vatrate
from  l3_mes.svod_work where rez=1;


--  select * from rawdl2_day.svod_cards

/*terminal_posruc,*/
----------------------------------------------------------------------------


delete from rawdl2_day.link_svod_cards;

insert into rawdl2_day.link_svod_cards (id_svod_cards,id_num_cards)
select id_svod as id_svod_cards,array_agg(idnum order by idnum) as id_num_cards
from l3_mes.svod_work where rez=2 group by 1;


----------------------------------------------------------------------------



 select * from rawdl2m.l2_meal limit 100
 
 
 
 
 
 
 
 

















/**/