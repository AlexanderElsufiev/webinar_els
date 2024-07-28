
----- from rawdl2m.    from '||libr||'.
------ строку 'tst_prig' заменить на '||shema||'  в итоге получается  '''||shema||'''
---- строку 'l3_mes' заменить на '||load_||'



-- DROP PROCEDURE svod.svod_card(text)


CREATE OR REPLACE PROCEDURE svod.svod_card(load_ text)
    
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

--RAISE INFO ' Обработка данных для свода по картам, рабочая схема записи=(%)',  load_;	  

--чтение даты обработки
execute 'select date_zap,part_zap,rezult,libr,dann,cast(current_time as char(50)) from  '||load_||'.prig_times where oper=''dannie''  '
		into date_zap,part_zap,rezult,libr,dann,calc_time;


if dann='svod_card' then begin --начало работы если надо


RAISE INFO ' СВОД ПО КАРТАМ. Время Начала=% рабочая схема записи=%   схема чтения %  номер порции данных=% объём порции записей=%',  calc_time, load_, libr, part_zap, rezult;		

	

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
(rez,id_svod,yyyy,mm,oper_cnt,request_date,agent_code,subagent_code,term_pos,term_dor,otd,term_trm, 
sale_station,carrier_cnt,carrier_code,registration_method,paymenttype,sale_channel,oper_channel,flg_pakr, 
flg_checktape,flg_internet,payment_code,els_code,kodagnels,koddorels,prdogels,flg_elssubag,rate_date,vatrate,
doc_qty,doc_vz,card_cost,vat_cost,sum_sbv,vat_sum,vatrate_vz,idnum)

with
dats as (select min_id_svod,date_zap,min_id,max_id from '||load_||'.prig_times where ''dannie''=oper and dann=''svod_card''),

gos as(select g_kod,G_PRSNG as SNG,g_vid from nsi.gosk,dats where date_zap between g_datani and g_dataki and  date_zap between g_datan and g_datak),--СНГ
dor as (select distinct d_nom3,d_kod,d_vidgos from NSI.DORK,dats where date_zap between d_datani and d_dataki and date_zap between d_datan and d_datak),


cards as
(select * from '||libr||'.l2_cards 
 where request_date in (select date_zap from dats) and idnum between (select min_id from dats) and (select max_id from dats)
 and arxiv_code in(17,25) and no_use is null),

dann as
(select idnum,yyyymm,
case when gg.g_kod=''20'' then ''20'' else ''0'' end as oper_cnt,
request_date,agent_code,subagent_code,term_pos,term_dor,term_trm,carrier_code,registration_method,paymenttype,sale_channel,oper_channel,
cast(otd as smallint) as otd,
cast(sale_station as dec(7)) as sale_station,
0  as carrier_cnt,
''?'' as flg_pakr,
''?'' as flg_checktape,
flg_internet,
case when oper=''V'' then 0 when oper_g=''N'' then 1 else -1 end as doc_qty,
case when oper=''O'' then 0 when oper_g=''N'' then -1 else 1 end as doc_vz,
payment_code,
''?'' as els_code,
0 as kodagnels,
''?'' as koddorels,
''?'' as prdogels,
case when subagent_code=0 then ''0'' else ''1'' end as flg_elssubag,
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
		

-- ЗАГРУЗКА ОСНОВНОЙ ТАБЛИЦЫ СВОДА по картам
execute ' 	
		

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
from  '||load_||'.svod_work where rez=1;


';		
	
GET DIAGNOSTICS rezult := ROW_COUNT;
RAISE INFO 'ШАГ 2. Записано % записей в основную таблицу свода по картам. За % дату % порция', rezult,date_zap, part_zap;	
	
	
		
		
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
		
insert into rawdl2_day.link_svod_cards (id_svod_cards,id_num_cards)
select id_svod as id_svod_cards,array_agg(idnum order by idnum) as id_num_cards
from '||load_||'.svod_work where rez=2 group by 1;

';		
	
GET DIAGNOSTICS rezult := ROW_COUNT;
RAISE INFO 'ШАГ 3. Записано % записей в таблицу линков свода по картам. За % дату % порция', rezult,date_zap, part_zap;	
	
	
		
		
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
end  if;--if dann='svod_meal' then begin --начало работы если надо							
							
							
							

--return 'Success prig_obog_1';
end;
$BODY$;


ALTER PROCEDURE svod.svod_card(text) OWNER TO asul; --компилляция!


--    call svod.svod_card('l3_mes');    --непосредственно запуск процедуры
						





