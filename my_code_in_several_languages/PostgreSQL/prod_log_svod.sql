
----- from rawdl2m.    from '||libr||'.
------ строку 'tst_prig' заменить на '||shema||'  в итоге получается  '''||shema||'''
---- строку 'l3_mes' заменить на '||load_||'



-- DROP PROCEDURE svod.svod_bag(text)


CREATE OR REPLACE PROCEDURE svod.svod_dann_poln(load_ text)
    
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
part_zap=1;

--call svod.prig_read(load_); --чтение - есть ли новые данные

-- начало цикла обработки всех возможных для чтения порций данных по сводам
 WHILE  (part_zap is not null) LOOP  --3

--RAISE INFO ' Установка порции чтения для свода, рабочая схема записи=(%)',  load_;	  

execute '

-- ПРОГРАММА ЗАГРУЗКИ ПО СПРАВОЧНИКУ ВСЕХ ПОРЦИЙ ЧТЕНИЯ
--УДАЛЕНИЕ ИЗ СПИСКА УЖЕ ПРОЧИТАННОЙ ПОРЦИИ
delete from '||load_||'.prig_times where dann in(''svod_pas'',''svod_bag'',''svod_krs'',''svod_card'',''svod_meal'') and oper=''dann1''
and (dann,date_zap,shema,min_id,max_id) in
(select distinct dann,date_zap,shema,min_id,max_id from '||load_||'.prig_times where oper in(''read'',''dann'') and itog is null);

--ЧАСТЬ 1 - ВВОДИМ НОЫВЕ ПОРЦИИ ДЛЯ ЧТЕНИЯ, если есть 
insert into  '||load_||'.prig_times(dann,oper,date_zap,rezult,min_id,max_id,shema,libr,yyyymm,part_zap)
with
part as(select max(part_zap) as part from '||load_||'.prig_times),
dn as
(select dann,''dann'' as oper,date_zap,rezult,min_id,max_id,shema,libr, yyyymm,
 (case when part is null then 0 else part end)+
 row_number() over(order by date_zap,dann) as part_zap
 from
(select distinct date_zap,rezult,min_id,max_id,shema,libr,yyyymm,part_zap,dann
 from '||load_||'.prig_times where dann in(''svod_pas'',''svod_bag'',''svod_krs'',''svod_card'',''svod_meal'') and oper=''dann1'') as a,
 part as b ) 
select dann,oper,date_zap,rezult,min_id,max_id,shema,libr,yyyymm,part_zap from dn;

--УДАЛЕНИЕ ИЗ СПИСКА УЖЕ ПРОЧИТАННОЙ ПОРЦИИ - копия НаВсякийСлучай
delete from '||load_||'.prig_times where dann in(''svod_pas'',''svod_bag'',''svod_krs'',''svod_card'',''svod_meal'') and oper=''dann1''
and (dann,date_zap,shema,min_id,max_id) in
(select distinct dann,date_zap,shema,min_id,max_id from '||load_||'.prig_times where oper in(''read'',''dann'') and itog is null);

--УСТАНОВКА НОМЕРА КОНКРЕТНОЙ НОВОЙ ЧИТАЕМОЙ ПОРЦИИ
delete from '||load_||'.prig_times where oper=''dannie'';

insert into  '||load_||'.prig_times(dann,oper,date_zap,shema,libr,yyyymm,part_zap,rezult,min_id,max_id,min_id_svod)
with times as
(select * from '||load_||'.prig_times where part_zap>0 and dann in(''svod_pas'',''svod_bag'',''svod_krs'',''svod_card'',''svod_meal'')),
id_svod as 
(select case when min_id_svod is null then 0 else min_id_svod end as min_id_svod
 from (select max(max_id_svod) as min_id_svod from times) as a)

select dann,oper,date_zap,shema,libr,yyyymm,part_zap,rezult,min_id,max_id,min_id_svod from
(select dann,''dannie'' as oper,date_zap,shema,libr,yyyymm,part_zap,rezult,min_id,max_id,row_number() over(order by part_zap) as nn
from times where oper=''dann''
and (dann,part_zap) not in(select dann,part_zap from times where oper=''read'')
) as a,id_svod where nn=1;

--удаление старья из рабочей области на всякий случай 
delete from '||load_||'.svod_work;
' ;


--чтение даты обработки
execute 'select date_zap,part_zap,rezult,libr,dann,cast(current_time as char(50)) from  '||load_||'.prig_times where oper=''dannie''  '
		into date_zap,part_zap,rezult,libr,dann,calc_time;


if dann='svod_bag' then begin --начало работы если надо
call svod.svod_bag(load_); 
end;end  if;
							
if dann='svod_pas' then begin --начало работы если надо
call svod.svod_pas(load_); 
end;end  if;
							
if dann='svod_krs' then begin --начало работы если надо
call svod.svod_krs(load_); 
end;end  if;

if dann='svod_meal' then begin --начало работы если надо
call svod.svod_meal(load_); 
end;end  if;

if dann='svod_card' then begin --начало работы если надо
call svod.svod_card(load_); 
end;end  if;
							

END loop;--END LOOP; --3

--return 'Success prig_obog_1';
end;
$BODY$;


ALTER PROCEDURE svod.svod_dann_poln(text) OWNER TO asul; --компилляция!


--    call svod.svod_dann_poln('l3_mes');    --непосредственно запуск процедуры
						





