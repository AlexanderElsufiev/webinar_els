
---- ПЕРЕВОД В РЕАЛЬНУЮ ПРОГРАММУ
---- 1. ЗАМЕНИТЬ '  НА ''
---- 2.  ЗАМЕНИТЬ  from rawdl2m.  НА  from '||libr||'.
---- 3. ЗАМЕНИТЬ строку l3_prig ИЛИ l3_mes НА '||load_||'





--select distinct f_tick[9] from  rawdl2.l2_pass_main  

--------------------------------

-------- РАЗБОР ПОЛЯ FLG_TT

/*

select  distinct f_lgot,substr(lgot_info,1,1) as flg_tt_bad,
CASE 
WHEN (paymenttype = 'Ж' AND a.benefitcnt_code='20') THEN
	case 
	when f_lgot[1] and not(f_lgot[2]) then
		case when substr(lgot_info,1,1)='Р' then 'Л' else 'П' end
	--Признак Л(личные, работник ): l2_pass_main.f_lgot =tf + шифр категории пассажира l2_pass_ex.lgot_info (1-й знак–буква) равен Р);
	--Признак П (прочие, не работник): l2_pass_main.f_lgot =tf + шифр категории пассажира l2_pass_ex.lgot_info (1-й знак–буква) НЕ равен Р)
	when f_lgot[1] and f_lgot[2] then 'С'
	--Признак С (служебные): первые 2 символа l2_pass_main.f_lgot=tt
	else '' end
WHEN (a.benefitcnt_code>'20') THEN
	case 
	when f_lgot[1] and not(f_lgot[2]) then 'Л' 
	--Признак Л(личные, работник ): l2_pass_main.f_lgot =tf + шифр категории пассажира l2_pass_ex.lgot_info (1-й знак–буква) равен Р);
	--Признак П (прочие, не работник): l2_pass_main.f_lgot =tf + шифр категории пассажира l2_pass_ex.lgot_info (1-й знак–буква) НЕ равен Р)
	when f_lgot[1] and f_lgot[2] then 'С'
	--Признак С (служебные): первые 2 символа l2_pass_main.f_lgot=tt
	else '' end
ELSE '' END as flg_tt
 from rawdl2m.l2_pass_ex as b join rawdl2m.l2_pass_main as a on a.idnum=b.idnum limit 100




select distinct benefitcnt_code from rawdl2m.l2_pass_ex order by 1

select distinct benefitcnt_code from rawdl2m.l2_pass_main order by 1



select paymenttype from rawdl2.l2_pass_ex 

select paymenttype from rawdl2.l2_pass_main






select count(*) from rawdl2.l2_pass_ex 
union all
select count(*) from rawdl2.l2_pass_main


Общее условие:
ЕСЛИ
[
вид расчета Ж (l2_pass_main.paymenttype = Ж)
По требованиям РФ  =(l2_pass_main.benefitcnt_code=20)
для пригородного сообщения =(l2_pass_main.train_num >0801 и <899 и буква(train_num) = (А,Г,М, Х,И,Й))
По требованиям РФ =(l2_pass_main.benefitcnt_code=20)
дальнее сообщение (НЕ ПРИГОРОД):
	]
ТО:
[
Признак С (служебные ): первые 2 символа l2_pass_main.f_lgot=tt 
Признак Л(личные, работник ): l2_pass_main.f_lgot =tf + шифр категории пассажира l2_pass_ex.lgot_info (1-й знак–буква) равен Р); 
Признак П (прочие, не работник): l2_pass_main.f_lgot =tf + шифр категории пассажира l2_pass_ex.lgot_info (1-й знак–буква) НЕ равен Р)
 ] ,
ЕСЛИ 
По требованиям СНГ и ИНО дорог
(l2_pass_main.benefitcnt_code>20):
ТО:
[
Признак С (служебные): первые 2 символа l2_pass_main.f_lgot=tt
Признак Л(личные, работник ): l2_pass_main.f_lgot =tf;
 ]
Иначе- пробел




select distinct --train,
case when substr(train_num,2,1)='8' and substr(train_num,5,1) in('А','М','Г','Х','И','Й') then '1' else '0' end as prig,
case when substr(lgot_info,1,1)='Р' then 'Р' else '-' end as c1,
case when substr(lgot_info,6,1)='Р' then 'Р' else '' end as c6
 from rawdl2.l2_pass_ex as b join rawdl2.l2_pass_main as a on a.idnum=b.idnum 
 order by 1,2,3

*/




---------------------------==================================================== ДАЛЕЕ ЦИКЛ


--удаление старья
delete from l3_mes.svod_work;
--delete from l3_mes.prig_itog;  --таблица обогащения данных!


delete from l3_mes.prig_times where part_zap in
(select part_zap from l3_mes.prig_times where oper='dannie' and dann in('svod_pas','svod_bag','svod_krs','svod_card','svod_meal') )
	and oper not in('dann','dannie');


--- ввод времени начала операции
insert into  l3_mes.prig_times(time,date,oper,time2,date_zap,part_zap,dann,shema,libr)
with a as
(select date_zap,part_zap,dann,shema,libr,current_date as date,substr(cast(current_time as char(50)),1,12) as time 
 from  l3_mes.prig_times where oper='dannie' and dann in('svod_pas','svod_bag','svod_krs','svod_card','svod_meal')
)
select time,date,'work_beg' as oper,
(cast(substr(time,1,2) as dec(3))*60+cast(substr(time,4,2) as dec(3)))*60+cast(substr(time,7,6) as dec(7,3)) as time2,date_zap,part_zap,dann,shema,libr
from a;






------------- сама программа чтения
--  delete from l3_mes.svod_work;


insert into l3_mes.svod_work
(rez,id_svod,yyyy,mm,oper_cnt,request_date,agent_code,subagent_code,term_pos,term_dor,otd,term_trm,sale_station,flg_oper,carrier_cnt,carrier_code,
registration_method,flg_soob,flg_sng,flg_mg,flg_prig,military_code,paymenttype,benefitcnt_code,sale_channel,oper_channel,
flg_pakr,flg_checktape,payment_code,tick_group,doc_qty,doc_vz,flg_tt,els_code,kodagnels,koddorels,prdogels,flg_elssubag,terminal_posruc,rate_date,
 idnum,sum_code,cnt_code,dor_code,sum_nde,vat_sum,vatrate)

with 
dats as (select min_id_svod,date_zap,min_id,max_id from l3_mes.prig_times where 'dannie'=oper and dann='svod_pas'),

gos as
(select g_kod,G_PRSNG as SNG,g_vid from nsi.gosk,dats where date_zap between g_datani and g_dataki and  date_zap between g_datan and g_datak),--СНГ

dor as (select distinct d_nom3,d_kod,d_vidgos from NSI.DORK,dats where date_zap between d_datani and d_dataki and date_zap between d_datan and d_datak),

pass as
(select *,case when substr(train_num,2,1)='8' and substr(train_num,5,1) in('А','М','Г','Х','И','Й') then '1' else '0' end as prig,
 case when substr(train_num,2,1)='8' and substr(train_num,5,1) in('А','М','Г','Х','И','Й') then 6 else 1 end as prig_zn
 from rawdl2m.l2_pass_main
 where request_date in (select date_zap from dats) and idnum between (select min_id from dats) and (select max_id from dats)
 	and no_use is null and arxiv_code in(17,25) ),

cost1 as
(select id,doc_num,idnum,sum_code,cnt_code,cast(dor_code as smallint) as dor_code,paymenttype,sum_nde,vat_sum,vatrate
 from rawdl2m.l2_pass_cost where request_date in (select date_zap from dats) and idnum between (select min_id from dats) and (select max_id from dats) ),	

bilgr as
(select distinct * from
(select distinct id,doc_num,
case when substr(lgot_info,2,1)='-' and substr(lgot_info,8,1)='-' and substr(lgot_info,19,1)='-' then substr(lgot_info,3,5)
	when position('-' in lgot_info)>0 then substr(lgot_info,position('-' in lgot_info )+3,5)  end as bilgroup,
 lgot_info
 from rawdl2m.l2_pass_ex  where request_date in (select date_zap from dats) and idnum between (select min_id from dats) and (select max_id from dats) )
 as a where bilgroup is not null),

dann as
(select a.id,a.doc_num,a.idnum,
 yyyymm,request_date,agent_code,subagent_code,term_pos,term_dor,term_trm,sale_station, 
case when gg.g_kod='20' then '20' else '0' end as oper_cnt,
cast(b.otd as smallint) as otd,
case when oper_x='D' then 1  when oper_x='P' then 3
  when request_type= 17 and request_subtype=115 then 2 else 4 end  as flg_oper,

oper_x,request_type, request_subtype,carrier_cnt,carrier_code,registration_method,
case when c.dor!=d.dor then '3' when c.dor!=term_dor then '2' else '1' end as flg_soob,
case when (c.gos!='20' or d.gos!='20') and ca.sng='1' and da.sng='1'  then '1' else '0' end as flg_sng,
case when ca.sng='0' or da.sng='0' then '1' else '0' end as flg_mg,
case when substr(train_num,1,2)='08' and substr(train_num,5,1) in ('А','Г','М','Х','И','Й') then '2'
	when substr(train_num,1,2)='08' then '1' else '0' end as   flg_prig,
military_code,paymenttype,benefitcnt_code,sale_channel,oper_channel,flg_pakr,flg_checktape,
case when oper='V' then 0 when oper_g='N' then 1 else -1 end as doc_qty,
case when oper='O' then 0 when oper_g='N' then -1 else 1 end as doc_vz,
case when f_tick[8] then coalesce(kodpl,'') else '' end as payment_code,

case when paymenttype='Ж' then 
 case when benefitcnt_code!='20' then '3'
	when substr(bilgroup,3,1) in ('0','1','2','3','4') then '1'
 	when substr(bilgroup,3,1) in ('5','6','7','8','9') then '2'
	else '0' end else '0' end as tick_group,
CASE 
WHEN (paymenttype = 'Ж' AND a.benefitcnt_code='20') THEN
	case 
	when f_lgot[1] and not(f_lgot[2]) then
		case when substr(lgot_info,prig_zn,1)='Р' then 'Л' else 'П' end
	--Признак Л(личные, работник ): l2_pass_main.f_lgot =tf + шифр категории пассажира l2_pass_ex.lgot_info (1-й знак (приг =6знак)–буква) равен Р);
	--Признак П (прочие, не работник): l2_pass_main.f_lgot =tf + шифр категории пассажира l2_pass_ex.lgot_info (1-й знак–буква(приг =6знак)) НЕ равен Р)
	when f_lgot[1] and f_lgot[2] then 'С'
	--Признак С (служебные): первые 2 символа l2_pass_main.f_lgot=tt
	else '' end
WHEN (a.benefitcnt_code>'20') THEN
	case 
	when f_lgot[1] and not(f_lgot[2]) then 'Л' 
	--Признак Л(личные, работник ): l2_pass_main.f_lgot =tf + шифр категории пассажира l2_pass_ex.lgot_info (1-й знак–буква) равен Р);
	--Признак П (прочие, не работник): l2_pass_main.f_lgot =tf + шифр категории пассажира l2_pass_ex.lgot_info (1-й знак–буква) НЕ равен Р)
	when f_lgot[1] and f_lgot[2] then 'С'
	--Признак С (служебные): первые 2 символа l2_pass_main.f_lgot=tt
	else '' end
ELSE '' END as flg_tt,
coalesce(els_code,'') as els_code,
agent_code as kodagnels,
/*dor_code*/ h.d_kod  as koddorels,
'?' as prdogels,
case when subagent_code>0 then '1' else '0' end   as flg_elssubag,
coalesce(cast(terminal_posruc as char(3)),'') as terminal_posruc,
rate_date --??? вопрос, кто именно нужен - дата курса валют, или операции?


from pass as a 
left join nsi.stanv as b on b.STAN = a.sale_station and
	a.departure_date between b.datand and b.datakd and a.request_date between b.datani and  b.dataki
left join nsi.stanv as c on c.STAN = a.departure_station and
	a.departure_date between c.datand and c.datakd and a.request_date between c.datani and  c.dataki
left join nsi.stanv as d on d.STAN = a.arrival_station and
	a.departure_date between d.datand and d.datakd and a.request_date between d.datani and  d.dataki
left join gos as ca on c.gos=ca.g_kod
left join gos as da on d.gos=da.g_kod
left join bilgr as e on a.id=e.id and a.doc_num=e.doc_num
left join nsi.tatp as f on PER= a.carrier_code and cast(VU as dec(3))=a.vcd_code and request_date between dn and dk 
left join dor as g  on a.term_dor=g.d_kod  
left join gos as gg on g.d_vidgos=gg.g_vid 
left join dor as h on a.dor_code=h.d_nom3
),




grupp1 as
(select count(*) over(order by yyyymm,oper_cnt,request_date,agent_code,subagent_code,term_pos,term_dor,otd,term_trm,sale_station,flg_oper,carrier_cnt,carrier_code,
registration_method,flg_soob,flg_sng,flg_mg,flg_prig,military_code,paymenttype,benefitcnt_code,sale_channel,oper_channel,
flg_pakr,flg_checktape,payment_code,tick_group,flg_tt,els_code,kodagnels,koddorels,prdogels,flg_elssubag,terminal_posruc,rate_date) as idd1,* from dann),

grupp2 as
(select (row_number() over(order by idd1))  +min_id_svod  as id_svod,idd1,
 round(yyyymm/100) as yyyy,mod(yyyymm,100) as mm,
oper_cnt,request_date,agent_code,subagent_code,term_pos,term_dor,otd,term_trm,sale_station,flg_oper,carrier_cnt,carrier_code,
registration_method,flg_soob,flg_sng,flg_mg,flg_prig,military_code,paymenttype,benefitcnt_code,sale_channel,oper_channel,
flg_pakr,flg_checktape,payment_code,tick_group,doc_qty,doc_vz,flg_tt,els_code,kodagnels,koddorels,prdogels,flg_elssubag,terminal_posruc,rate_date
 from
(select idd1,yyyymm,oper_cnt,request_date,agent_code,subagent_code,term_pos,term_dor,otd,term_trm,sale_station,flg_oper,carrier_cnt,carrier_code,
registration_method,flg_soob,flg_sng,flg_mg,flg_prig,military_code,paymenttype,benefitcnt_code,sale_channel,oper_channel,
flg_pakr,flg_checktape,payment_code,tick_group,flg_tt,els_code,kodagnels,koddorels,prdogels,flg_elssubag,terminal_posruc,rate_date,
sum(doc_qty) as doc_qty,sum(doc_vz) as doc_vz
from grupp1
group by idd1,yyyymm,oper_cnt,request_date,agent_code,subagent_code,term_pos,term_dor,otd,term_trm,sale_station,flg_oper,carrier_cnt,carrier_code,
registration_method,flg_soob,flg_sng,flg_mg,flg_prig,military_code,paymenttype,benefitcnt_code,sale_channel,oper_channel,
flg_pakr,flg_checktape,payment_code,tick_group,flg_tt,els_code,kodagnels,koddorels,prdogels,flg_elssubag,terminal_posruc,rate_date) as a
 ,dats as b
),
 
grupp3 as
(select idnum,id_svod from grupp1 as a join grupp2 as b on a.idd1=b.idd1),


 
cost2 as 
(select id_svod,sum_code,cnt_code,dor_code,paymenttype,vatrate,sum(sum_nde) as sum_nde,sum(vat_sum) as vat_sum
from cost1 as a join grupp3 as b on a.idnum=b.idnum group by id_svod,sum_code,cnt_code,dor_code,paymenttype,vatrate),


itog as
(select 1 as rez,id_svod,yyyy,mm,oper_cnt,request_date,agent_code,subagent_code,term_pos,term_dor,otd,term_trm,sale_station,flg_oper,carrier_cnt,carrier_code,
registration_method,flg_soob,flg_sng,flg_mg,flg_prig,military_code,paymenttype,benefitcnt_code,sale_channel,oper_channel,
flg_pakr,flg_checktape,payment_code,tick_group,doc_qty,doc_vz,flg_tt,els_code,kodagnels,koddorels,prdogels,flg_elssubag,terminal_posruc,rate_date,
 0 as idnum,
 0 as sum_code,'--' as cnt_code,0 as dor_code,0 as sum_nde,0 as vat_sum,0 as vatrate
 from grupp2  
union all
select 2 as rez,id_svod,0 as yyyy,0 as mm,NUll as oper_cnt,NUll as request_date,NUll as agent_code,NUll as subagent_code,NUll as term_pos,NUll as term_dor,NUll as otd,
 NUll as term_trm,NUll as sale_station,NUll as flg_oper,NUll as carrier_cnt,NUll as carrier_code,
NUll as registration_method,NUll as flg_soob,NUll as flg_sng,NUll as flg_mg,NUll as flg_prig,NUll as military_code,NUll as paymenttype,NUll as benefitcnt_code,
 NUll as sale_channel,NUll as oper_channel,NUll as flg_pakr,NUll as flg_checktape,NUll as payment_code,NUll as tick_group,NUll as doc_qty,NUll as doc_vz,
 NUll as flg_tt,NUll as els_code,NUll as kodagnels,NUll as koddorels,NUll as prdogels,NUll as flg_elssubag,NUll as terminal_posruc,NUll as rate_date,
 idnum,
 NUll as sum_code,NUll as cnt_code,NUll as dor_code,0 as sum_nde,0 as vat_sum,0 as vatrate
 from grupp3  
union all
select 3 as rez,id_svod,NUll as yyyy,NUll as mm,NUll as oper_cnt,NUll as request_date,NUll as agent_code,NUll as subagent_code,NUll as term_pos,NUll as term_dor,NUll as otd,
 NUll as term_trm,NUll as sale_station,NUll as flg_oper,NUll as carrier_cnt,NUll as carrier_code,
NUll as registration_method,NUll as flg_soob,NUll as flg_sng,NUll as flg_mg,NUll as flg_prig,NUll as military_code,paymenttype,NUll as benefitcnt_code,
 NUll as sale_channel,NUll as oper_channel,NUll as flg_pakr,NUll as flg_checktape,NUll as payment_code,NUll as tick_group,NUll as doc_qty,NUll as doc_vz,
 NUll as flg_tt,NUll as els_code,NUll as kodagnels,NUll as koddorels,NUll as prdogels,NUll as flg_elssubag,NUll as terminal_posruc,NUll as rate_date,
 NUll as idnum,
 sum_code,cnt_code,dor_code,sum_nde,vat_sum,vatrate
 from cost2 
)
 
select * from itog ;
 
 
 
 
 
 
--- ввод времени окончания операции с итоговым числом записей
insert into  l3_mes.prig_times(time,date,dann,libr,oper,time2,date_zap,part_zap,shema,rezult,min_id_svod,max_id_svod)
with a as
(select date_zap,part_zap,shema,dann,libr,current_date as date,substr(cast(clock_timestamp()::time as char(50)),1,12) as time
 from  l3_mes.prig_times where oper='dannie' and dann in('svod_pas','svod_bag','svod_krs','svod_card','svod_meal')
),
b as (select count(*) as rezult,min(id_svod) as min_id_svod,max(id_svod) as max_id_svod from l3_mes.svod_work)
select time,date,dann,libr,'work rez' as oper,
(cast(substr(time,1,2) as dec(3))*60+cast(substr(time,4,2) as dec(3)))*60+cast(substr(time,7,6) as dec(7,3)) as time2,
date_zap,part_zap,shema,rezult,min_id_svod,max_id_svod
from a left join b on 1=1 ;


------
-- select * from l3_mes.prig_times




 
-------------------------------------------------------------------

-- select rez,count(*) as kol from l3_mes.svod_work group by 1
 

-------------------------------------------------------------------

--  delete from rawdl2_day.svod_pass_main

-- select  * from rawdl2_day.svod_pass_main limit 100



-- ЗАГРУЗКА ОСНОВНОЙ ТАБЛИЦЫ СВОДА  ПАССАЖИРОВ

insert into rawdl2_day.svod_pass_main
(id_svod_pass,yyyy,mm,oper_cnt,request_date,agent_code,subagent_code,term_pos,term_dor,otd,term_trm,sale_station,
flg_oper,carrier_cnt,carrier_code,registration_method,flg_soob,flg_sng,flg_mg,flg_prig,military_code,paymenttype,
benefitcnt_code,sale_channel,oper_channel,flg_pakr,flg_checktape,doc_qty,doc_vz,payment_code,tick_group,flg_tt,
els_code,kodagnels,koddorels,prdogels,flg_elssubag,terminal_posruc,rate_date
)
select id_svod as id_svod_pass,yyyy,mm,oper_cnt,request_date,agent_code,subagent_code,term_pos,term_dor,otd,term_trm,sale_station,
flg_oper,carrier_cnt,carrier_code,registration_method,flg_soob,flg_sng,flg_mg,flg_prig,military_code,paymenttype,
benefitcnt_code,sale_channel,oper_channel,flg_pakr,flg_checktape,doc_qty,doc_vz,payment_code,tick_group,flg_tt,
els_code,kodagnels,koddorels,prdogels,flg_elssubag,terminal_posruc,rate_date
from l3_mes.svod_work where rez=1     --   and rate_date='2023-02-01' ;


-- select * from rawdl2_day.svod_pass_main limit 100;

--  select * from l3_mes.svod_work limit 100;


--- ввод времени окончания операции с итоговым числом записей
insert into  l3_mes.prig_times(time,date,dann,libr,oper,time2,date_zap,part_zap,shema,rezult)
with a as
(select date_zap,part_zap,shema,dann,libr,current_date as date,substr(cast(clock_timestamp()::time as char(50)),1,12) as time
 from  l3_mes.prig_times where oper='dannie' and dann in('svod_pas','svod_bag','svod_krs','svod_card','svod_meal') )
select time,date,dann,libr,'zap_main' as oper,
(cast(substr(time,1,2) as dec(3))*60+cast(substr(time,4,2) as dec(3)))*60+cast(substr(time,7,6) as dec(7,3)) as time2,
date_zap,part_zap,shema,#1000# as rezult
from a ;


-------------------------------------------------------------------
-- ЗАГРУЗКА  ТАБЛИЦЫ ЛИНКОВ СВОДА ПАССАЖИРОВ
--select * from rawdl2_day.link_svod_pass_main

insert into rawdl2_day.link_svod_pass_main(id_svod_pass,id_num_pass_main)
select id_svod as id_svod_pass,array_agg(idnum order by idnum) as id_num_pass_main
from l3_mes.svod_work where rez=2 group by 1




-------------------------------------------------------------------
 
-- ЗАГРУЗКА  ТАБЛИЦЫ РАСПРЕДЕЛЕНИЯ СТОИМОСТЕЙ ПО СВОДАМ ПАССАЖИРОВ 
--  delete from rawdl2_day.svod_pass_cost   -- 21445
--  select * from rawdl2_day.svod_pass_cost limit 100

insert into rawdl2_day.svod_pass_cost
(id_svod_pass,sum_code,cnt_code,dor_code,paymenttype,sum_nde,vat_sum,vatrate)
select id_svod as id_svod_pass,sum_code,cnt_code,dor_code,paymenttype,sum_nde,vat_sum,vatrate
from l3_mes.svod_work where rez=3;



-------------------------------------------------------------------
 
--select rez,count(*) from l3_mes.svod_work group by 1



-------------------------------======================================================
/* --удаление всего загруженного
delete from rawdl2_day.link_svod_pass_main;
delete from rawdl2_day.svod_pass_main;
delete from rawdl2_day.svod_pass_cost;
*/


---------==========================

'rawdl2_day.link_svod_pass_main'

/**/