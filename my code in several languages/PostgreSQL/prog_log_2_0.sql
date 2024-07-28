
----- from rawdl2m.    from '||libr||'.
---- строку 'tst_prig' заменить на '||shema||'  в итоге получается  '''||shema||'''
---- строку 'l3_prig' заменить на '||load_||'

--  DROP PROCEDURE svod.prig_obog_0(text)




CREATE OR REPLACE PROCEDURE svod.prig_obog_0(load_ text)
    
    LANGUAGE 'plpgsql'
    
AS $BODY$
--ПРОГРАММА ПЕРВИЧНОЙ ПЕРЕРАБОТКИ ДАННЫХ, НАРАБОТКА СПРАВОЧНИКА БИЛЕТВ И МАРШРУТОВ, 
--ПОЛУЧЕНИЕ ОТПРАВЛЕННЫХ ПАССАЖИРОВ ПО ДАТАМ ОТПРАВЛЕНИЯ СОКРАЩЕНИЕ ЧИСЛА ЗАПИСЕЙ БЕЗ ПОТЕРИ ИНФОРМАЦИИ
--ТОЛЬКО ПРОЦЕДУРА ОБОГАЩЕНИЯ, первая половина, НЕ БОЛЕЕ ТОГО!!! 
declare
	integer_var integer;
	part_zap integer;
	--calc_date	date;
	shema text;
	dann text;
	libr text;
	load_ text;
	--calc_time char(20);
begin

load_=$1;

RAISE INFO ' рабочая схема записи=(%)',  load_;	  
RAISE INFO ' НАЧАТА ВЫБОРКА ДОСТУПНЫХ ДАТ ЧТЕНИЯ';	






--RAISE INFO ' база %   Время Начала=% рабочая схема записи=%   схема чтения %  номер порции данных=% объём порции записей=%',  shema, calc_time, load_, libr, part_zap, integer_var;		

--- заменяю 700К на 400К,  а 500К на 300К

--удаление возможно неполностью записанного  из базы данных
execute '


--ЧАСТЬ 0 - УДАЛЕНИЕ ИЗ СПИСКА УЖЕ ПРОЧИТАННОЙ ПОРЦИИ
delete from '||load_||'.prig_times where dann=''prig'' and oper=''dann1'' and (date_zap,shema,libr) in
(select distinct date_zap,shema,libr from '||load_||'.prig_times where dann=''prig'' and oper=''dann'' and itog is null);

--ЧАСТЬ 1 - ВВОДИМ НОВУЮ РОВНО ОДНУ ДАТУ МИНИМАЛЬНУЮ, И ЕСЛИ МНОГО ЗАПИСЕЙ В ЧТЕНИИ ИЗ ПРИГОРОДА - С ОТРИЦАТЕЛЬНЫМ НОМЕРОМ ПОРЦИИ
insert into  '||load_||'.prig_times(date,time,dann,oper,date_zap,rezult,min_id,max_id,shema,libr,yyyymm,part_zap)
with
times as (select * from '||load_||'.prig_times where dann=''prig'' and itog is null),
dat as (select min(date_zap) as max_date from times where oper=''dann1''),
part as(select max(part_zap) as part from '||load_||'.prig_times),
iz as (select count(*) as kol from times where part_zap!=0 and oper=''dann'' and part_zap not in(select part_zap from times where oper=''read'')),
dn as
(select date_zap,rezult,min_id,max_id,shema,libr,yyyymm,
 case when rezult>400000 and substr(shema,5,4)=''prig'' then -part_zap else part_zap end as part_zap from
(select date_zap,rezult,min_id,max_id,shema,libr,yyyymm, 
 (case when part is null then 0 else part end)+zap as part_zap from
 (select date_zap,rezult,min_id,max_id,shema,libr,yyyymm,part_zap,row_number() over(order by shema,libr) as zap
 from times,dat where date_zap=max_date and oper=''dann1'') as a,part,iz where kol=0 and zap=1) as b)
select current_date as date,substr(cast(current_time as char(50)),1,12) as time,''prig'' as dann,''dann'' as oper,date_zap,rezult,min_id,max_id,
shema,libr,yyyymm,part_zap from dn;



';

--чтение имени нужной библиотеки
execute 'select max(libr) as libr,count(*) as kol from  '||load_||'.prig_times where dann=''prig'' and oper=''dann'' and part_zap<0  and itog is null'
		into libr,integer_var;

if integer_var>0 then begin

execute '

--ЧАСТЬ 2 - ОТРИЦАТЕЛЬНЫЙ НОМЕР ПОРЦИИ (ТОЛЬКО ПРИГОРОД) ДЕЛИМ НА 3 ЧАСТИ, ДВЕ ДЛИНОЙ ПО  МАКСИМУМУ, ПОСЛЕДНЯЯ КАК ПРИДЁТСЯ
insert into  '||load_||'.prig_times(date,time,dann,oper,date_zap,shema,libr,yyyymm,part_zap,rezult,min_id,max_id)
with
dn as (select dann,oper,date_zap,rezult,min_id,max_id,shema,libr,yyyymm,part_zap from '||load_||'.prig_times where  dann=''prig'' and oper=''dann'' and part_zap<0 and itog is null),
zn as
(select count(*) as rezult1,min(idnum) as min_id1,max(idnum) as max_id1 from
(select idnum from '||libr||'.l2_prig_main where  REQUEST_DATE in(select date_zap from dn)
and idnum between (select min_id from dn) and (select max_id from dn)
 offset 300000 limit 300000
) as a),
rez1 as (select dann,oper,date_zap,rezult,min_id,max_id,shema,libr,yyyymm,part_zap,rezult1,min_id1,max_id1 from dn,zn),
rez2 as 
(select dann,oper,date_zap,shema,libr,yyyymm,-part_zap as part_zap,300000 as rezult,min_id,min_id1-1 as max_id from rez1
union all
 select dann,oper,date_zap,shema,libr,yyyymm,-part_zap+1 as part_zap,rezult1 as rezult,min_id1 as min_id,max_id1 as max_id from rez1
 union all
 select dann,oper,date_zap,shema,libr,yyyymm,-part_zap+2 as part_zap,rezult-300000-rezult1 as rezult,max_id1+1 as min_id,max_id from rez1
)
select current_date as date,substr(cast(current_time as char(50)),1,12) as time,dann,oper,date_zap,shema,libr,yyyymm,
case when rezult>400000 then -part_zap else part_zap end as part_zap,rezult,min_id,max_id 
from rez2;


';
end ;
end if;


execute '

delete from '||load_||'.prig_times where dann=''prig'' and part_zap<0 and part_zap in(select -part_zap from '||load_||'.prig_times where dann=''prig''  and itog is null);
delete from '||load_||'.prig_times where dann=''prig'' and oper=''dann1'' and (date_zap,shema,libr) in 
	(select date_zap,shema,libr from '||load_||'.prig_times where part_zap!=0 and dann=''prig'' and oper=''dann'' and itog is null);
delete from '||load_||'.prig_times where dann=''prig'' and min_id>max_id and itog is null;

--УСТАНОВКА НОМЕРА НОВОЙ ЧИТАЕМОЙ ПОРЦИИ из нескольких возможных вариантов
delete from '||load_||'.prig_times where dann=''prig'' and oper=''dannie'';

insert into '||load_||'.prig_times(dann,oper,date_zap,shema,libr,yyyymm,part_zap,rezult,min_id,max_id)
with ish as (select * from '||load_||'.prig_times where dann=''prig'' and itog is null)
select dann,''dannie'' as oper,date_zap,shema,libr,yyyymm,part_zap,rezult,min_id,max_id from
(select dann,date_zap,shema,libr,yyyymm,part_zap,rezult,min_id,max_id,row_number() over(order by part_zap) as nn
from ish where oper=''dann'' and part_zap>0 and part_zap not in(select part_zap from ish where oper=''read'')) as a where nn=1;
';


-----------------



--чтение даты обработки
execute 'select part_zap,shema,libr from  '||load_||'.prig_times where dann=''prig'' and oper=''dannie'' '
		into part_zap,shema,libr;
		
if part_zap is not null then begin

RAISE INFO ' Подчистка данных база % рабочая схема записи=%   схема чтения %  номер порции данных=%',  shema,  load_, libr, part_zap;		

execute '
--удаление возможно неполностью записанного  из базы данных
delete from '||load_||'.prig_itog where part_zap='||part_zap||';
delete from '||load_||'.prig_lgot_reestr where part_zap='||part_zap||';
delete from '||load_||'.prig_analit where part_zap='||part_zap||';

--удаление старья из рабочей области на всякий случай (вторично)
delete from '||load_||'.prig_work;

--удаление старья из таблицы логов за рабочую дату
delete from '||load_||'.prig_times where dann=''prig'' and part_zap in
(select part_zap from '||load_||'.prig_times where dann=''prig'' and oper=''dannie'' and itog is null )
	and oper not in(''dann'',''dannie'');	 
';

end; --2
end if; --2



RAISE INFO ' ЗАКОНЧЕНА ВЫБОРКА ДОСТУПНЫХ ДАТ ЧТЕНИЯ';


								  

--return 'Success prig_obog_0';
end;
$BODY$;


ALTER PROCEDURE svod.prig_obog_0(text) OWNER TO asul; --компилляция!


--    call svod.prig_obog_0('l3_prig');    --непосредственно запуск процедуры
						





