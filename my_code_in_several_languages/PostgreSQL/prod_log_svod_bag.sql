
----- from rawdl2m.    from '||libr||'.
------ строку 'tst_prig' заменить на '||shema||'  в итоге получается  '''||shema||'''
---- строку 'l3_mes' заменить на '||load_||'



-- DROP PROCEDURE svod.svod_bag(text)


CREATE OR REPLACE PROCEDURE svod.svod_bag(load_ text)
    
    LANGUAGE 'plpgsql'
    
AS $BODY$
--ПРОГРАММА ПЕРВИЧНОЙ ПЕРЕРАБОТКИ ДАННЫХ, НАРАБОТКА СПРАВОЧНИКА БИЛЕТВ И МАРШРУТОВ, 
--ПОЛУЧЕНИЕ ОТПРАВЛЕННЫХ ПАССАЖИРОВ ПО ДАТАМ ОТПРАВЛЕНИЯ СОКРАЩЕНИЕ ЧИСЛА ЗАПИСЕЙ БЕЗ ПОТЕРИ ИНФОРМАЦИИ
--ТОЛЬКО ПРОЦЕДУРА ОБОГАЩЕНИЯ, первая половина, НЕ БОЛЕЕ ТОГО!!! 
declare
	rezult integer; --integer_var
	part_zap integer; 
	date_zap date; 
	--shema text;
	dann text;
	libr text;
	load_ text;
	calc_time char(20);
begin

load_=$1;

--RAISE INFO ' Обработка данных для свода по багажу, рабочая схема записи=(%)',  load_;	  

--чтение даты обработки
execute 'select date_zap,part_zap,rezult,libr,dann,cast(current_time as char(50)) from  '||load_||'.prig_times where oper=''dannie''  '
		into date_zap,part_zap,rezult,libr,dann,calc_time;


if dann='svod_bag' then begin --начало работы если надо


RAISE INFO ' СВОД ПО БАГАЖУ. Время Начала=% рабочая схема записи=%   схема чтения %  номер порции данных=% объём порции записей=%',  calc_time, load_, libr, part_zap, rezult;		

	

--удаление возможно неполностью записанного  из базы данных
--execute 'delete from '||load_||'.prig_itog where part_zap='||part_zap||';' ;
--execute 'delete from '||load_||'.prig_lgot_reestr where part_zap='||part_zap||';' ;


--удаление старья из рабочей области на всякий случай (вторично)
execute 'delete from '||load_||'.svod_work;' ;


--удаление старья из таблицы логов за рабочую дату
execute '
delete from '||load_||'.prig_times where part_zap in
(select part_zap from '||load_||'.prig_times where oper=''dannie'' and dann in(''svod_pas'',''svod_bag'',''svod_krs'',''svod_card'',''svod_meal'') )
	and oper not in(''dann'',''dannie'');
';



--- ввод в лог времени начала операции
execute '
insert into  '||load_||'.prig_times(time,date,oper,min_id,max_id,time2,date_zap,part_zap,dann,shema,libr)
with a as
(select date_zap,part_zap,dann,shema,libr,min_id,max_id,current_date as date,substr(cast(current_time as char(50)),1,12) as time 
 from  '||load_||'.prig_times where oper=''dannie'' and dann in(''svod_pas'',''svod_bag'',''svod_krs'',''svod_card'',''svod_meal'')
)
select time,date,''work_beg'' as oper,min_id,max_id,
(cast(substr(time,1,2) as dec(3))*60+cast(substr(time,4,2) as dec(3)))*60+cast(substr(time,7,6) as dec(7,3)) as time2,date_zap,part_zap,dann,shema,libr
from a;
';

--RAISE INFO ' Начата первая часть обогащения За % дату % порция',  date_zap, part_zap;




execute  '  



insert into '||load_||'.svod_work
(rez,id_svod,yyyy,mm,oper_cnt,request_date,agent_code,subagent_code,term_pos,term_dor,otd,term_trm,sale_station,
flg_oper,carrier_cnt,carrier_code,registration_method,shipment_type,flg_soob,flg_sng,flg_mg,military_code,
paymenttype,sale_channel,oper_channel,flg_pakr,flg_checktape,tick_group,flg_tt,els_code,kodagnels,koddorels,
prdogels,flg_elssubag,terminal_posruc,rate_date,doc_qty,doc_vz,idnum,
sum_code,cnt_code,dor_code,sum_nde,vat_sum,vatrate)

with 
dats as (select min_id_svod,date_zap,min_id,max_id from '||load_||'.prig_times where oper=''dannie'' and dann=''svod_bag''),

gos as
(select g_kod,G_PRSNG as SNG,g_vid from nsi.gosk,dats where date_zap between g_datani and g_dataki and  date_zap between g_datan and g_datak),--СНГ

dor as (select distinct d_nom3,d_kod,d_vidgos from NSI.DORK,dats where date_zap between d_datani and d_dataki and date_zap between d_datan and d_datak),

main as
(select * from '||libr||'.l2_bag_main 
 where request_date in (select date_zap from dats) and idnum between (select min_id from dats) and (select max_id from dats)
 and arxiv_code in(17,25) and no_use is null),

cost as
(select idnum,sum_code,cnt_code,cast(dor_code as smallint) as dor_code,paymenttype,sum_nde,vat_sum,vatrate 
 from '||libr||'.l2_bag_cost 
 where request_date in (select date_zap from dats) and idnum between (select min_id from dats) and (select max_id from dats) ),

dann as
(select idnum,yyyymm,
case when gg.g_kod=''20'' then ''20'' else ''0'' end as oper_cnt,
request_date,agent_code,subagent_code,term_pos,term_dor,
cast(b.otd as smallint) as otd,
term_trm,
cast(sale_station as dec(7)) as sale_station,
case when oper_type22 in(5,6) then ''1'' else ''0'' end as flg_oper, 
cast(carrier_gos as smallint) as carrier_cnt,
carrier_code,registration_method,shipment_type,
case when c.dor!=d.dor then ''3'' when c.dor!=term_dor then ''2'' else ''1'' end as flg_soob,
case when (c.gos!=''20'' or d.gos!=''20'') and ca.sng=''1'' and da.sng=''1''  then ''1'' else ''0'' end as flg_sng,
case when ca.sng=''0'' or da.sng=''0'' then ''1'' else ''2'' end as flg_mg, 
military_code,paymenttype,sale_channel,oper_channel,flg_efreestr as flg_pakr,flg_checktape,
case when oper=''V'' then 0 when oper_g=''N'' then 1 else -1 end as doc_qty,
case when oper=''O'' then 0 when oper_g=''N'' then -1 else 1 end as doc_vz,
case when (c.gos!=''20'' or d.gos!=''20'') then '' '' 
	when tt_ticketgrcode is null then '' ''
	else substr(tt_ticketgrcode,3,1) end as tick_group,
case when carriage_kind in (''4'',''5'')  then ''Л'' 
  when carriage_kind in (''6'',''7'',''8'')  then ''С'' else '''' end as flg_tt,
coalesce(els_code,'''') as els_code,agent_code as kodagnels,
 0 as koddorels,
0 as prdogels,
flg_elssubag,
case when registration_method=''1'' then coalesce(term_pos,'''') else '''' end as terminal_posruc,
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


';
GET DIAGNOSTICS rezult := ROW_COUNT;
RAISE INFO 'ШАГ 1. Выбрано % записей. За % дату % порция', rezult,date_zap, part_zap;	
			
								  
--- ввод времени окончания операции с итоговым числом записей								  
execute ' 
insert into  '||load_||'.prig_times(time,date,dann,libr,oper,min_id,max_id,time2,date_zap,part_zap,shema,rezult,min_id_svod,max_id_svod)
with a as
(select date_zap,part_zap,shema,dann,libr,min_id,max_id,current_date as date,substr(cast(clock_timestamp()::time as char(50)),1,12) as time
 from  '||load_||'.prig_times where oper=''dannie'' and dann in(''svod_pas'',''svod_bag'',''svod_krs'',''svod_card'',''svod_meal'')
),
b as (select count(*) as rezult,min(id_svod) as min_id_svod,max(id_svod) as max_id_svod from '||load_||'.svod_work)
select time,date,dann,libr,''work rez'' as oper,min_id,max_id,
(cast(substr(time,1,2) as dec(3))*60+cast(substr(time,4,2) as dec(3)))*60+cast(substr(time,7,6) as dec(7,3)) as time2,
date_zap,part_zap,shema,rezult,min_id_svod,max_id_svod
from a left join b on 1=1 ; 
';
		

-- ЗАГРУЗКА ОСНОВНОЙ ТАБЛИЦЫ СВОДА  багажа
execute ' 	
		
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
from '||load_||'.svod_work where rez=1;
';		
	
GET DIAGNOSTICS rezult := ROW_COUNT;
RAISE INFO 'ШАГ 2. Записано % записей в основную таблицу свода по багажу. За % дату % порция', rezult,date_zap, part_zap;	
	
	
		
		
--- ввод времени окончания операции с итоговым числом записей								  
execute ' 		
insert into  '||load_||'.prig_times(time,date,dann,libr,oper,min_id,max_id,time2,date_zap,part_zap,shema,rezult)
with a as
(select date_zap,part_zap,shema,dann,libr,min_id,max_id,current_date as date,substr(cast(clock_timestamp()::time as char(50)),1,12) as time
 from  '||load_||'.prig_times where oper=''dannie'' and dann in(''svod_pas'',''svod_bag'',''svod_krs'',''svod_card'',''svod_meal'')
)
select time,date,dann,libr,''zap_main'' as oper,min_id,max_id,
(cast(substr(time,1,2) as dec(3))*60+cast(substr(time,4,2) as dec(3)))*60+cast(substr(time,7,6) as dec(7,3)) as time2,
date_zap,part_zap,shema,'||rezult||' as rezult
from a ;		
';		
		
		
		
		

-- ЗАГРУЗКА ТАБЛИЦЫ ЛИНКОВ
execute ' 		
		
insert into  rawdl2_day.link_svod_bag_main(id_svod_bag,id_num_bag_main)
select id_svod as id_svod_bag,array_agg(idnum order by idnum) as id_num_bag_main
from '||load_||'.svod_work where rez=2 group by 1;
';		
	
GET DIAGNOSTICS rezult := ROW_COUNT;
RAISE INFO 'ШАГ 3. Записано % записей в таблицу линков свода по багажу. За % дату % порция', rezult,date_zap, part_zap;	
	
	
		
		
--- ввод времени окончания операции с итоговым числом записей								  
execute ' 		
insert into  '||load_||'.prig_times(time,date,dann,libr,oper,min_id,max_id,time2,date_zap,part_zap,shema,rezult)
with a as
(select date_zap,part_zap,shema,dann,libr,min_id,max_id,current_date as date,substr(cast(clock_timestamp()::time as char(50)),1,12) as time
 from  '||load_||'.prig_times where oper=''dannie'' and dann in(''svod_pas'',''svod_bag'',''svod_krs'',''svod_card'',''svod_meal'')
)
select time,date,dann,libr,''zap_link'' as oper,min_id,max_id,
(cast(substr(time,1,2) as dec(3))*60+cast(substr(time,4,2) as dec(3)))*60+cast(substr(time,7,6) as dec(7,3)) as time2,
date_zap,part_zap,shema,'||rezult||' as rezult
from a ;		
';		
		
		
		
		
		
		
		

-- ЗАГРУЗКА ТАБЛИЦЫ СТОИМОСТЕЙ 
execute ' 		
	
insert into rawdl2_day.svod_bag_cost
(id_svod_bag,sum_code,cnt_code,dor_code,paymenttype,sum_nde,vat_sum,vatrate)
select id_svod as id_svod_bag,sum_code,cnt_code,dor_code,paymenttype,sum_nde,vat_sum,vatrate
from '||load_||'.svod_work where rez=3;
';		
	
GET DIAGNOSTICS rezult := ROW_COUNT;
RAISE INFO 'ШАГ 4. Записано % записей в таблицу стоимостей свода по багажу. За % дату % порция', rezult,date_zap, part_zap;	
	
	
		
		
--- ввод времени окончания операции с итоговым числом записей								  
execute ' 		
insert into  '||load_||'.prig_times(time,date,dann,libr,oper,min_id,max_id,time2,date_zap,part_zap,shema,rezult)
with a as
(select date_zap,part_zap,shema,dann,libr,min_id,max_id,current_date as date,substr(cast(clock_timestamp()::time as char(50)),1,12) as time
 from  '||load_||'.prig_times where oper=''dannie'' and dann in(''svod_pas'',''svod_bag'',''svod_krs'',''svod_card'',''svod_meal'')
)
select time,date,dann,libr,''zap_cost'' as oper,min_id,max_id,
(cast(substr(time,1,2) as dec(3))*60+cast(substr(time,4,2) as dec(3)))*60+cast(substr(time,7,6) as dec(7,3)) as time2,
date_zap,part_zap,shema,'||rezult||' as rezult
from a ;		
';		
		
		
		
--- запись признака окончания работы по программе						  
execute ' 
insert into  '||load_||'.prig_times(time,date,dann,libr,oper,min_id,max_id,time2,date_zap,part_zap,shema,rezult,min_id_svod,max_id_svod)
with a as
(select date_zap,part_zap,shema,dann,libr,min_id,max_id,rezult,min_id_svod,max_id_svod,
 current_date as date,substr(cast(clock_timestamp()::time as char(50)),1,12) as time
 from  '||load_||'.prig_times where part_zap in
 (select part_zap from '||load_||'.prig_times where oper=''dannie'' and dann in(''svod_pas'',''svod_bag'',''svod_krs'',''svod_card'',''svod_meal'') )
 and oper=''work rez'' and dann in(''svod_pas'',''svod_bag'',''svod_krs'',''svod_card'',''svod_meal'')
)
select time,date,dann,libr,''read'' as oper,min_id,max_id,
(cast(substr(time,1,2) as dec(3))*60+cast(substr(time,4,2) as dec(3)))*60+cast(substr(time,7,6) as dec(7,3)) as time2,
date_zap,part_zap,shema,rezult,min_id_svod,max_id_svod
from a 
';

		
		
				
end;
end  if;--if dann='svod_pas' then begin --начало работы если надо							
							
							
							

--return 'Success prig_obog_1';
end;
$BODY$;


ALTER PROCEDURE svod.svod_bag(text) OWNER TO asul; --компилляция!


--    call svod.svod_bag('l3_mes');    --непосредственно запуск процедуры
						





