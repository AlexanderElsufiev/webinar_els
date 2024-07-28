







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









------------- сама программа чтения
with gos as
(select g_kod,max(G_PRSNG) as SNG from nsi.gosk group by 1),--СНГ в предположении неизменности по датам
bilgr as
(select distinct * from
(select distinct id,doc_num,
case when substr(lgot_info,2,1)='-' and substr(lgot_info,8,1)='-' and substr(lgot_info,19,1)='-' then substr(lgot_info,3,5)
	when position('-' in lgot_info)>0 then substr(lgot_info,position('-' in lgot_info )+3,5)  end as bilgroup,
 substr(lgot_info,1,1) as flg_tt,lgot_info
 from rawdl2.l2_pass_ex ) as a where bilgroup is not null),

itog as
(select a.id,a.doc_num,a.idnum,
 yyyymm,
case when gg.g_kod='20' then '20' else  '0' end as oper_cnt,--D_VIDGOS,gg.g_kod, ----------------------- не нужно
request_date,
 agent_code,subagent_code,term_pos,term_dor,
b.otd as otd,
term_trm,sale_station,
 
 
case when oper_x='D' then 1  when oper_x='P' then 3
  when request_type= 17 and request_subtype=115 then 2 else 4 end  as flg_oper,
oper_x,request_type, request_subtype,
cast(carrier_cnt as smallint) as carrier_cnt,carrier_code,registration_method,
case when c.dor!=d.dor then '3' when c.dor!=term_dor then '2' else '1' end as flg_soob,
case when (c.gos!='20' or d.gos!='20') and ca.sng='1' and da.sng='1'  then '1' else '0' end as flg_sng,
case when ca.sng='0' or da.sng='0' then '1' else '0' end as flg_mg,
case when substr(train_num,1,2)='08' and substr(train_num,5,1) in ('А','Г','М','Х','И','Й') then '2'
	when substr(train_num,1,2)='08' then '1' else '0' end as   flg_prig,
military_code,paymenttype,benefitcnt_code,sale_channel,oper_channel,flg_pakr,flg_checktape,
case when oper='V' then 0 when oper_g='N' then 1 else -1 end as doc_qty,
case when oper='O' then 0 when oper_g='N' then -1 else 1 end as doc_vz,
case when f_tick[8] then kodpl end as payment_code,

--bilgroup,lgot_info,-----------------------==============НЕ НУЖНЫ!!!
case when paymenttype='Ж' then 
 case when benefitcnt_code!='20' then '3'
	when substr(bilgroup,3,1) in ('0','1','2','3','4') then '1'
 	when substr(bilgroup,3,1) in ('5','6','7','8','9') then '2'
	else '0' end else '0' end as tick_group,
flg_tt,els_code,
agent_code as kodagnels,
dor_code  as koddorels,
'?' as prdogels,
case when subagent_code>0 then '1' else '0' end   as flg_elssubag,
terminal_posruc,
rate_date --??? вопрос, кто именно нужен - дата курса валют, или операции?


from rawdl2.l2_pass_main as a left join nsi.stanv as b
on b.STAN = a.sale_station and
a.departure_date between b.datand and b.datakd and a.request_date between b.datani and  b.dataki

left join nsi.stanv as c
on c.STAN = a.departure_station and
a.departure_date between c.datand and c.datakd and a.request_date between c.datani and  c.dataki

left join nsi.stanv as d
on d.STAN = a.arrival_station and
a.departure_date between d.datand and d.datakd and a.request_date between d.datani and  d.dataki

left join gos as ca on c.gos=ca.g_kod
left join gos as da on d.gos=da.g_kod
left join bilgr as e on a.id=e.id and a.doc_num=e.doc_num
left join nsi.tatp as f on PER= a.carrier_code and cast(VU as dec(3))=a.vcd_code and request_date between dn and dk
 
left join  NSI.DORK as g on a.term_dor=g.d_kod and 
 a.departure_date between d_datan and d_datak and a.request_date between d_datani and  d_dataki
 
left join NSI.gosk as gg  on d_vidgos=g_vid and 
a.departure_date between g_datan and g_datak and a.request_date between g_datani and g_dataki
 where arxiv_code in(17,25) and no_use is NULL
),
grupp1 as
(select count(*) over(order by yyyymm,oper_cnt,request_date,agent_code,subagent_code,term_pos,term_dor,otd,term_trm,sale_station,flg_oper,carrier_cnt,carrier_code,
registration_method,flg_soob,flg_sng,flg_mg,flg_prig,military_code,paymenttype,benefitcnt_code,sale_channel,oper_channel,
flg_pakr,flg_checktape,payment_code,tick_group) as idd1,* from itog),

grupp2 as
(select row_number() over() as idd,* from
(select idd1,yyyymm,oper_cnt,request_date,agent_code,subagent_code,term_pos,term_dor,otd,term_trm,sale_station,flg_oper,carrier_cnt,carrier_code,
registration_method,flg_soob,flg_sng,flg_mg,flg_prig,military_code,paymenttype,benefitcnt_code,sale_channel,oper_channel,
flg_pakr,flg_checktape,payment_code,tick_group,
sum(doc_qty) as doc_qty,sum(doc_vz) as doc_vz
from grupp1
group by idd1,yyyymm,oper_cnt,request_date,agent_code,subagent_code,term_pos,term_dor,otd,term_trm,sale_station,flg_oper,carrier_cnt,carrier_code,
registration_method,flg_soob,flg_sng,flg_mg,flg_prig,military_code,paymenttype,benefitcnt_code,sale_channel,oper_channel,
flg_pakr,flg_checktape,payment_code,tick_group) as a),
 
grupp3 as
(select idnum,idd from grupp1 as a join grupp2 as b on a.idd1=b.idd1),

cost1 as
(select id,doc_num,idnum,sum_code,cnt_code,dor_code,paymenttype,sum_nde,vat_sum,vatrate
 from rawdl2.l2_pass_cost),
 
cost2 as 
(select idd,sum_code,cnt_code,dor_code,paymenttype,sum(sum_nde) as sum_nde,sum(vat_sum) as vat_sum,sum(vatrate) as vatrate
from cost1 as a join grupp3 as b on a.idnum=b.idnum group by idd,sum_code,cnt_code,dor_code,paymenttype)
 
 
 





--select count(*) from itog   -- 829 записей == 681 реально используемо
--union all
--select count(*) from grupp2  -- 334 записи ==313 реально используемо
--union all
--select count(*) from grupp3  -- ==681 реально используемо

select * from cost2 order by 1,2,3,4,5 -- 334 записи ==681 реально используемо

--select * from grupp2 order by idd -- 334 записи ==313 реально используемо
--select * from itog

--select distinct g_kod from itog

--select distinct paymenttype,bilgroup,lgot_info,benefitcnt_code from itog where paymenttype='Ж'

limit 100


-----------------------
----- ВТОРАЯ ПРОГРАММА - ПО СТОИМОСТЯМ



select * from rawdl2.l2_pass_cost limit 100




select id,doc_num,idnum,
sum_code,
cnt_code,
dor_code,
paymenttype,
sum_nde,
vat_sum,
vatrate
 from rawdl2.l2_pass_cost
 order by idnum,sum_code,cnt_code,dor_code,paymenttype  limit 100





-----------------------




select count(*) from rawdl2s.l2_pass_main --708724


---------------СОЗДАНИЕ ТАБЛИЦЫ НУЖНЫХ ДАТ----------------
CREATE TABLE l3_prig.prig_times
(	date date,time char(12),time2 numeric,oper char(20),date_zap date,part_zap dec(7),rezult bigint,min_id bigint,max_id bigint,min_id_svod bigint,max_id_svod bigint,
	shema char(20),libr char(20),itog char(8)
) TABLESPACE pg_default;
ALTER TABLE l3_prig.prig_times OWNER to asul;
GRANT ALL ON TABLE l3_prig.prig_times TO asul;


-----------------------
--подготовка таблицы необходимых записей

--   delete from  l3_prig.prig_times
/*
insert into  l3_prig.prig_times(oper,date_zap,rezult,min_id,max_id,shema,libr,part_zap,min_id_svod)
 select distinct 'xran_pas_dann1' as oper,date_zap,rezult,min_id,max_id,'sut_xr_p' as shema,'rawdl2' as libr,0 as part_zap,0 as min_id_svod from 
 (select REQUEST_DATE as date_zap,count(*) as rezult,min(idnum) as min_id,max(idnum) as max_id
  from rawdl2s.l2_pass_main group by 1) as a
*/  
  
  

insert into  l3_prig.prig_times(oper,date_zap,rezult,min_id,max_id,shema,libr,part_zap,min_id_svod,max_id_svod)
 select distinct 'xran_pas_dann1' as oper,date_zap,rezult,min_id,max_id,'tst_xran_pass' as shema,'rawdl2' as libr,0 as part_zap,0 as min_id_svod,0 as max_id_svod from 
 (select REQUEST_DATE as date_zap,count(*) as rezult,min(idnum) as min_id,max(idnum) as max_id
  from rawdl2.l2_pass_main group by 1) as a ; 
  
select * from l3_prig.prig_times  ;
  
 --where date_zap in ('2023-04-25')


----------------------------------------------------------------------------------
-- ПРОГРАММА ЗАГРУЗКИ ПО СПРАВОЧНИКУ








--УДАЛЕНИЕ ИЗ СПИСКА УЖЕ ПРОЧИТАННОЙ ПОРЦИИ
delete from l3_prig.prig_times where oper='xran_pas_dann1' and (part_zap,date_zap,shema,min_id,max_id) in
(select distinct part_zap,date_zap,shema,min_id,max_id from l3_prig.prig_times where oper='xran_pas_read');


--ЧАСТЬ 1 - ВВОДИМ НОВУЮ ДАТУ МИНИМАЛЬНУЮ, И ЕСЛИ МНОГО ЗАПИСЕЙ В ЧТЕНИИ ИЗ ПРИГОРОДА - С ОТРИЦАТЕЛЬНЫМ НОМЕРОМ ПОРЦИИ
insert into  l3_prig.prig_times(oper,date_zap,rezult,min_id,max_id,shema,libr,part_zap,min_id_svod)
with
dat as (select min(date_zap) as max_date from l3_prig.prig_times where oper='xran_pas_dann1' and rezult>20),
part as(select max(part_zap) as part from l3_prig.prig_times),
iz as (select max(max_id_svod) as min_id_svod from l3_prig.prig_times where  oper='xran_pas_read'),

dn as
--(select oper,date_zap,rezult,min_id,max_id,shema,libr,part_zap from
 
(select 'xran_pas_dann' as oper,date_zap,rezult,min_id,max_id,shema,libr, 
 (case when part is null then 0 else part end)+1 as part_zap,
 case when min_id_svod is null then 0 else min_id_svod end as min_id_svod
 from
  (select date_zap,rezult,min_id,max_id,shema,libr,part_zap
 from l3_prig.prig_times,dat where date_zap=max_date and oper='xran_pas_dann1') as a,part as b,iz as c ) -- as b)
select oper,date_zap,rezult,min_id,max_id,shema,libr,part_zap,min_id_svod from dn;






---------------------------====================================================

select * from l3_prig.prig_times where 'xran_pas_dann'=oper;

idnum between 37425900401 and 37425924501  and request_date ='2022-05-26'





------------- сама программа чтения

insert into l3_prig.svod_work
(rez,id_svod,yyyy,mm,oper_cnt,request_date,agent_code,subagent_code,term_pos,term_dor,otd,term_trm,sale_station,flg_oper,carrier_cnt,carrier_code,
registration_method,flg_soob,flg_sng,flg_mg,flg_prig,military_code,paymenttype,benefitcnt_code,sale_channel,oper_channel,
flg_pakr,flg_checktape,payment_code,tick_group,doc_qty,doc_vz,idnum,sum_code,cnt_code,dor_code,sum_nde,vat_sum,vatrate)

with 
dats as (select min_id_svod,date_zap from l3_prig.prig_times where 'xran_pas_dann'=oper),

gos as
(select g_kod,max(G_PRSNG) as SNG from nsi.gosk,dats where date_zap between g_datani and g_dataki group by 1),--СНГ в предположении неизменности по датам

bilgr as
(select distinct * from
(select distinct id,doc_num,
case when substr(lgot_info,2,1)='-' and substr(lgot_info,8,1)='-' and substr(lgot_info,19,1)='-' then substr(lgot_info,3,5)
	when position('-' in lgot_info)>0 then substr(lgot_info,position('-' in lgot_info )+3,5)  end as bilgroup,
 substr(lgot_info,1,1) as flg_tt,lgot_info
 from rawdl2.l2_pass_ex ) as a where bilgroup is not null),

pass as
(select * from rawdl2.l2_pass_main where idnum between 37425900401 and 37425924501  and request_date ='2022-05-26' 
 	and no_use is null and arxiv_code in(17,25)  ),

dann as
(select a.id,a.doc_num,a.idnum,
 yyyymm,
case when gg.g_kod='20' then 20 else 0 end as oper_cnt,--D_VIDGOS,gg.g_kod, ----------------------- не нужно
request_date,
 agent_code,subagent_code,term_pos,term_dor,
cast(b.otd as smallint) as otd,
term_trm,cast(sale_station as dec(7)) as sale_station, 
 
case when oper_x='D' then 1  when oper_x='P' then 3
  when request_type= 17 and request_subtype=115 then 2 else 4 end  as flg_oper,

oper_x,request_type, request_subtype,
cast(carrier_cnt as smallint) as carrier_cnt,carrier_code,registration_method,
case when c.dor!=d.dor then '3' when c.dor!=term_dor then '2' else '1' end as flg_soob,
case when (c.gos!='20' or d.gos!='20') and ca.sng='1' and da.sng='1'  then '1' else '0' end as flg_sng,
case when ca.sng='0' or da.sng='0' then '1' else '0' end as flg_mg,
case when substr(train_num,1,2)='08' and substr(train_num,5,1) in ('А','Г','М','Х','И','Й') then '2'
	when substr(train_num,1,2)='08' then '1' else '0' end as   flg_prig,
military_code,paymenttype,
cast(benefitcnt_code as smallint) as benefitcnt_code,
sale_channel,oper_channel,flg_pakr,flg_checktape,
case when oper='V' then 0 when oper_g='N' then 1 else -1 end as doc_qty,
case when oper='O' then 0 when oper_g='N' then -1 else 1 end as doc_vz,
case when f_tick[8] then kodpl end as payment_code,

--bilgroup,lgot_info,-----------------------==============НЕ НУЖНЫ!!!
case when paymenttype='Ж' then 
 case when benefitcnt_code!='20' then '3'
	when substr(bilgroup,3,1) in ('0','1','2','3','4') then '1'
 	when substr(bilgroup,3,1) in ('5','6','7','8','9') then '2'
	else '0' end else '0' end as tick_group,
flg_tt,els_code,
agent_code as kodagnels,
dor_code  as koddorels,
'?' as prdogels,
case when subagent_code>0 then '1' else '0' end   as flg_elssubag,
terminal_posruc,
rate_date --??? вопрос, кто именно нужен - дата курса валют, или операции?


from pass as a left join nsi.stanv as b
on b.STAN = a.sale_station and
a.departure_date between b.datand and b.datakd and a.request_date between b.datani and  b.dataki

left join nsi.stanv as c
on c.STAN = a.departure_station and
a.departure_date between c.datand and c.datakd and a.request_date between c.datani and  c.dataki

left join nsi.stanv as d
on d.STAN = a.arrival_station and
a.departure_date between d.datand and d.datakd and a.request_date between d.datani and  d.dataki

left join gos as ca on c.gos=ca.g_kod
left join gos as da on d.gos=da.g_kod
left join bilgr as e on a.id=e.id and a.doc_num=e.doc_num
left join nsi.tatp as f on PER= a.carrier_code and cast(VU as dec(3))=a.vcd_code and request_date between dn and dk
 
left join  NSI.DORK as g on a.term_dor=g.d_kod and 
 a.departure_date between d_datan and d_datak and a.request_date between d_datani and  d_dataki
 
left join NSI.gosk as gg  on d_vidgos=g_vid and 
a.departure_date between g_datan and g_datak and a.request_date between g_datani and g_dataki
 
),
grupp1 as
(select count(*) over(order by yyyymm,oper_cnt,request_date,agent_code,subagent_code,term_pos,term_dor,otd,term_trm,sale_station,flg_oper,carrier_cnt,carrier_code,
registration_method,flg_soob,flg_sng,flg_mg,flg_prig,military_code,paymenttype,benefitcnt_code,sale_channel,oper_channel,
flg_pakr,flg_checktape,payment_code,tick_group) as idd1,* from dann),

grupp2 as
(select row_number() over() as id_svod,idd1,
 round(yyyymm/100) as yyyy,mod(yyyymm,100) as mm,
oper_cnt,request_date,agent_code,subagent_code,term_pos,term_dor,otd,term_trm,sale_station,flg_oper,carrier_cnt,carrier_code,
registration_method,flg_soob,flg_sng,flg_mg,flg_prig,military_code,paymenttype,benefitcnt_code,sale_channel,oper_channel,
flg_pakr,flg_checktape,payment_code,tick_group,doc_qty,doc_vz
 from
(select idd1,yyyymm,oper_cnt,request_date,agent_code,subagent_code,term_pos,term_dor,otd,term_trm,sale_station,flg_oper,carrier_cnt,carrier_code,
registration_method,flg_soob,flg_sng,flg_mg,flg_prig,military_code,paymenttype,benefitcnt_code,sale_channel,oper_channel,
flg_pakr,flg_checktape,payment_code,tick_group,
sum(doc_qty) as doc_qty,sum(doc_vz) as doc_vz
from grupp1
group by idd1,yyyymm,oper_cnt,request_date,agent_code,subagent_code,term_pos,term_dor,otd,term_trm,sale_station,flg_oper,carrier_cnt,carrier_code,
registration_method,flg_soob,flg_sng,flg_mg,flg_prig,military_code,paymenttype,benefitcnt_code,sale_channel,oper_channel,
flg_pakr,flg_checktape,payment_code,tick_group) as a),
 
grupp3 as
(select idnum,id_svod from grupp1 as a join grupp2 as b on a.idd1=b.idd1),

cost1 as
(select id,doc_num,idnum,sum_code,cast(cnt_code as smallint) as cnt_code,cast(dor_code as smallint) as dor_code,paymenttype,sum_nde,vat_sum,vatrate
 from rawdl2.l2_pass_cost where idnum between 37425900401 and 37425924501  and request_date ='2022-05-26'),
 
cost2 as 
(select id_svod,sum_code,cnt_code,dor_code,paymenttype,sum(sum_nde) as sum_nde,sum(vat_sum) as vat_sum,sum(vatrate) as vatrate
from cost1 as a join grupp3 as b on a.idnum=b.idnum group by id_svod,sum_code,cnt_code,dor_code,paymenttype),


itog as
(select 1 as rez,id_svod,yyyy,mm,oper_cnt,request_date,agent_code,subagent_code,term_pos,term_dor,otd,term_trm,sale_station,flg_oper,carrier_cnt,carrier_code,
registration_method,flg_soob,flg_sng,flg_mg,flg_prig,military_code,paymenttype,benefitcnt_code,sale_channel,oper_channel,
flg_pakr,flg_checktape,payment_code,tick_group,doc_qty,doc_vz,0 as idnum,
 0 as sum_code,0 as cnt_code,0 as dor_code,0 as sum_nde,0 as vat_sum,0 as vatrate
 from grupp2  
union all
select 2 as rez,id_svod,0 as yyyy,0 as mm,NUll as oper_cnt,NUll as request_date,NUll as agent_code,NUll as subagent_code,NUll as term_pos,NUll as term_dor,NUll as otd,
 NUll as term_trm,NUll as sale_station,NUll as flg_oper,NUll as carrier_cnt,NUll as carrier_code,
NUll as registration_method,NUll as flg_soob,NUll as flg_sng,NUll as flg_mg,NUll as flg_prig,NUll as military_code,NUll as paymenttype,NUll as benefitcnt_code,
 NUll as sale_channel,NUll as oper_channel,NUll as flg_pakr,NUll as flg_checktape,NUll as payment_code,NUll as tick_group,NUll as doc_qty,NUll as doc_vz,
 idnum,
 NUll as sum_code,NUll as cnt_code,NUll as dor_code,0 as sum_nde,0 as vat_sum,0 as vatrate
 from grupp3  
union all
select 3 as rez,id_svod,0 as yyyy,0 as mm,NUll as oper_cnt,NUll as request_date,NUll as agent_code,NUll as subagent_code,NUll as term_pos,NUll as term_dor,NUll as otd,
 NUll as term_trm,NUll as sale_station,NUll as flg_oper,NUll as carrier_cnt,NUll as carrier_code,
NUll as registration_method,NUll as flg_soob,NUll as flg_sng,NUll as flg_mg,NUll as flg_prig,NUll as military_code,paymenttype,NUll as benefitcnt_code,
 NUll as sale_channel,NUll as oper_channel,NUll as flg_pakr,NUll as flg_checktape,NUll as payment_code,NUll as tick_group,NUll as doc_qty,NUll as doc_vz,
 NUll as idnum,
 sum_code,cnt_code,dor_code,sum_nde,vat_sum,vatrate
 from cost2 


)
 
 select * from itog
 




-------------------------------======================================================





create table l3_prig.svod_work
(rez smallint,id_svod bigint,yyyy smallint,mm smallint,oper_cnt smallint,request_date date,agent_code smallint,subagent_code smallint,
term_pos char(3),term_dor char(1),otd smallint,term_trm char(2),sale_station integer,flg_oper char(1),carrier_cnt smallint,carrier_code smallint,
registration_method char(1),flg_soob char(1),flg_sng char(1),flg_mg char(1),flg_prig char(1),military_code smallint,paymenttype char(1),
 benefitcnt_code smallint,sale_channel char(1),oper_channel char(1),flg_pakr char(1),flg_checktape char(1),payment_code char(4),tick_group char(1),
 doc_qty smallint,doc_vz smallint,idnum bigint,sum_code smallint,cnt_code smallint,dor_code smallint,
 sum_nde dec(15,2),vat_sum dec(15,2),vatrate dec(15,2)
) TABLESPACE pg_default;
ALTER TABLE l3_prig.svod_work OWNER to asul;
GRANT ALL ON TABLE l3_prig.svod_work TO asul;






----------------------------------------------------

select rez,count(*) as kol from l3_prig.svod_work group by 1 order by 1




















*/