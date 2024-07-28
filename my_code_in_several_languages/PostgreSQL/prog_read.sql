
----- заменить одиночный апостроф на два апострофа

----- заменить rawdl2. на '||shema2||'.
---- строку 'tst_prig' заменить на '||shema||'  в итоге получается  '''||shema||'''
---- строку l3_prig. заменить на '||load_||'.



-- ПРОГРАММА РЕГУЛЯРНОГО ЧТЕНИЯ ИНФОРМАЦИИ ОБО ВСЕХ ТАБЛИЦАХ



--ЧАСТЬ 0. постановка информации о том, из каких таблиц читать

insert into l3_mes.prig_times(dann,shema,libr,itog,oper)
	values('prig','mon_pass','rawdl2m','table','l2_pass_main');
insert into l3_mes.prig_times(dann,shema,libr,itog,oper)
	values('prig','sut_pass','rawdl2s','table','l2_pass_main');
insert into l3_mes.prig_times(dann,shema,libr,itog,oper)
	values('prig','sut_prig','rawdl2s','table','l2_prig_main');
insert into l3_mes.prig_times(dann,shema,libr,itog,oper)
	values('prig','mon_prig','rawdl2m','table','l2_prig_main');
insert into l3_mes.prig_times(dann,shema,libr,itog,oper)
	values('svod_bag','mes','rawdl2m','table','l2_bag_main');
insert into l3_mes.prig_times(dann,shema,libr,itog,oper)
	values('svod_pas','mes','rawdl2m','table','l2_pass_main');
insert into l3_mes.prig_times(dann,shema,libr,itog,oper)
	values('svod_krs','mes','rawdl2m','table','l2_krs');
insert into l3_mes.prig_times(dann,shema,libr,itog,oper)
	values('svod_meal','mes','rawdl2m','table','l2_meal');
insert into l3_mes.prig_times(dann,shema,libr,itog,oper)
	values('svod_card','mes','rawdl2m','table','l2_cards');

/*
insert into l3_mes.prig_times(dann,shema,libr,itog,oper)
	values('prig','dan_prig','rawdl2','table','l2_prig_main');
insert into l3_mes.prig_times(dann,shema,libr,itog,oper)
	values('prig','dan_pass','rawdl2','table','l2_pass_main');
	*/

----------------------------------------------------------------------------------------------------
--1. ПОСТАНОВКА МЕТКИ ОБ УДАЛЕНИИ ДАННЫХ


-- select * from l3_mes.prig_times where dann='prig' and oper='dann' order by date_zap,part_zap

-- select oper,date_zap,count(*) from l3_mes.prig_times where oper in('dann','read') and itog is null group by 1,2 order by 1,2


--установка удаляемой порции
update l3_mes.prig_times set itog='delet' where  oper='dann' and date_zap='2023-03-01' and itog is null





--распространить удаление на целые сутки
update l3_mes.prig_times set itog='delet' where oper='dann' and (dann,shema,libr,date_zap) in
(select dann,shema,libr,date_zap from l3_mes.prig_times where itog='delet') and itog is null

--удаление прочитанных данных ПРИГОРОД
delete from l3_mes.prig_lgot_reestr where part_zap in(select part_zap from l3_mes.prig_times where dann='prig' and itog='delet');
delete from l3_mes.prig_analit where part_zap in(select part_zap from l3_mes.prig_times where dann='prig' and itog='delet');
delete from l3_mes.prig_itog where part_zap in(select part_zap from l3_mes.prig_times where dann='prig' and itog='delet');


--удаление прочитанных данных СВОДЫ
--удаление по пассажирам
delete from rawdl2_day.svod_pass_cost where id_svod_pass in
(select id_svod_pass from rawdl2_day.svod_pass_main where request_date in(select distinct date_zap from  l3_mes.prig_times where itog='delet' and oper='dann' and dann='svod_pas'));

delete from rawdl2_day.link_svod_pass_main where id_svod_pass in
(select id_svod_pass from rawdl2_day.svod_pass_main where request_date in(select distinct date_zap from  l3_mes.prig_times where itog='delet' and oper='dann' and dann='svod_pas'));

delete from rawdl2_day.svod_pass_main where request_date in(select distinct date_zap from  l3_mes.prig_times where itog='delet' and oper='dann' and dann='svod_pas');


--удаление по багажу
delete from rawdl2_day.svod_bag_cost where id_svod_bag in
(select id_svod_bag from rawdl2_day.svod_bag_main where request_date in(select distinct date_zap from  l3_mes.prig_times where itog='delet' and oper='dann' and dann='svod_bag'));

delete from rawdl2_day.link_svod_bag_main where id_svod_bag in
(select id_svod_bag from rawdl2_day.svod_bag_main where request_date in(select distinct date_zap from  l3_mes.prig_times where itog='delet' and oper='dann' and dann='svod_bag'));

delete from rawdl2_day.svod_bag_main where request_date in(select distinct date_zap from  l3_mes.prig_times where itog='delet' and oper='dann' and dann='svod_bag');


--удаление КРС
delete from rawdl2_day.link_svod_krs where id_svod_krs in
(select id_svod_krs from rawdl2_day.svod_krs where request_date in(select distinct date_zap from  l3_mes.prig_times where itog='delet' and oper='dann' and dann='svod_krs'));

delete from rawdl2_day.svod_krs where request_date in(select distinct date_zap from  l3_mes.prig_times where itog='delet' and oper='dann' and dann='svod_krs');

--удаление Питание
delete from rawdl2_day.link_svod_meal where id_svod_meal in
(select id_svod_meal from rawdl2_day.svod_meal where request_date in(select distinct date_zap from  l3_mes.prig_times where itog='delet' and oper='dann' and dann='svod_meal'));

delete from rawdl2_day.svod_meal where request_date in(select distinct date_zap from  l3_mes.prig_times where itog='delet' and oper='dann' and dann='svod_meal');


--удаление Карты
delete from rawdl2_day.link_svod_cards where id_svod_cards in
(select id_svod_cards from rawdl2_day.svod_cards where request_date in(select distinct date_zap from  l3_mes.prig_times where itog='delet' and oper='dann' and dann='svod_card'));

delete from rawdl2_day.svod_cards where request_date in(select distinct date_zap from  l3_mes.prig_times where itog='delet' and oper='dann' and dann='svod_card');



--ОТМЕТКА О РЕАЛЬНОМ УДАЛЕНИИ ДАННЫХ
update l3_mes.prig_times set itog='deleted' where part_zap in(select part_zap from l3_mes.prig_times where  itog='delet')










----------------------------------------------------------------------------------------------------

select * from l3_mes.prig_times where date_zap='2023-03-01' and dann='prig' and oper in('dann','dann1','read')

select * from l3_mes.prig_times where oper='dann1'

select dann,shema,libr,itog,oper from l3_mes.prig_times where itog='table'
--delete from l3_mes.prig_times where itog='table'

select count(*) as kol from
(select distinct dann,shema,libr,itog,oper from l3_mes.prig_times where itog='table') as a


select dann,shema,libr,itog,oper from
(select *,row_number() over(order by dann,shema,libr,itog,oper) as num
from (select distinct dann,shema,libr,itog,oper from l3_mes.prig_times where itog='table') as a) as b
where num=3


select distinct dann,shema,libr,itog,oper from l3_mes.prig_times where (oper='read' and itog is null) or itog='table'  order by 1,2,3,4,5


----------------- ВЫЧИСЛЕНИЕ - КАКУЮ ТАБЛИЦУ С КАКОГО МОМЕНТА ЧИТАТЬ

--delete from l3_mes.prig_times where oper='dann1'

select *  from l3_mes.prig_times where itog='table'

select *  from l3_mes.prig_times where dann='svod_bag' and oper='dann' order by date_zap


with ish as 
(select row_number() over(partition by dann,shema,libr,oper order by date_zap desc) as nnn,
 count(*) over(partition by dann,shema,libr,oper order by date_zap desc,-part_zap) as nnnk,
 min(case when itog='deleted' then 1 else 0 end) over(partition by dann,shema,libr,oper,date_zap) as dell,*
 from l3_mes.prig_times where (oper='dann' /* or oper='read'*/ or itog='table') and shema='mon_prig'
) 
 
--select * from ish order by date_zap,part_zap
 
select a.dann,a.shema,a.libr,a.oper,b.date_zap,coalesce(b.min_id,0) as min_id--,num
from (select *,row_number() over(order by dann,shema,libr,itog,oper) as num from ish where itog='table') as a
left join 
(select dann,shema,libr,oper,min(date_zap) as date_zap,min(min_id-1) as min_id
from ish where (nnn=1 or dell=1) and oper='dann' group by dann,shema,libr,oper) as b 
on a.dann=b.dann and a.libr=b.libr and a.shema=b.shema
--where num=4






select *  from l3_mes.prig_times where dann!='prig' and date_zap='2023-03-01' and oper in('dann','read')

"prig                "	"mon_pass            "



----------------------------------------------------------------------
execute '
insert into  '||load_||'.prig_times(dann,oper,date_zap,rezult,min_id,max_id,shema,libr,part_zap,min_id_svod,max_id_svod)
 select distinct '||dann||' as dann,''dann1'' as oper,date_zap,rezult,min_id,max_id,''mes'' as shema,'||libr||' as libr,0 as part_zap,0 as min_id_svod,0 as max_id_svod from 
 (select REQUEST_DATE as date_zap,count(*) as rezult,min(idnum) as min_id,max(idnum) as max_id
  from '||libr||'.'||tabl||' where idnum>='||min_id||' group by 1) as a ; 
';

----------------------------------------------------------------------

--    DROP PROCEDURE svod.prig_read(text)













CREATE OR REPLACE /*FUNCTION*/ PROCEDURE svod.all_read(load_ text,date_zap text,dann text)
  --  RETURNS text 
    LANGUAGE 'plpgsql'
  --  COST 100
  --  VOLATILE 
    
AS $BODY$
--Программа - УДАЛЕНИЕ НЕНУЖНЫХ ДАННЫХ, И ПОСЛЕДУЮЩЕЕ ЧТЕНИЕ ВСЕХ НУЖНЫХ, СТАРЫХ И НОВЫХ, ПРИГОРОДА И СВОДОВ
declare
	kol integer;num integer;rezult integer;min_id bigint;
	date_zap	date;
	part_zap integer;
	shema text;dann text;libr text;tabl text;
	calc_time char(20);
	tabname text;
	
	
begin  --1
load_=$1;date_zap=$2;dann=$3;

-------------БЛОК ПОМЕТКИ ДАННЫХ НА УДАЛЕНИЕ И ПЕРЕПРОЧТЕНИЕ
RAISE INFO 'Таблица %, Дата=%, Тип данных=%, ', load_,date_zap,dann;	

if date_zap is not NULL then begin --2
RAISE INFO 'Удаляю Таблица %, Дата=%, Тип данных=%, ', load_,date_zap,dann;	

if dann is null then begin --3
execute 'update '||load_||'.prig_times set itog=''delet'' where  oper=''dann'' and date_zap='''||date_zap||''' and itog is null;';
GET DIAGNOSTICS rezult := ROW_COUNT;
end;
else begin
execute 'update '||load_||'.prig_times set itog=''delet'' where  oper=''dann'' and date_zap='''||date_zap||''' and dann='''||dann||'''   and itog is null;';
GET DIAGNOSTICS rezult := ROW_COUNT;
end;end if; --3
RAISE INFO 'Помечено к удалению % записей. ', rezult;	
end;end if; --2






------------БЛОК РЕАЛЬНОГО УДАЛЕНИЯ ДАННЫХ ИЗ ВСЕХ ТАБЛИЦ АГРЕГАТОВ  
part_zap=1;num=1;

execute 'select count(*) from  '||load_||'.prig_times where itog=''delet''  '
	into  kol;

if kol>0 then begin --2
--УДАЛЕНИЕ РЕАЛЬНО ПРОЧИТАННЫХ ДАННЫХ - ПРИ НЕОБХОДИМОСТИ
RAISE INFO ' Количество удаляемых порций данных=% ', kol;

execute '
--распространить удаление на целые сутки
update '||load_||'.prig_times set itog=''delet'' where oper=''dann'' and (dann,shema,libr,date_zap) in
(select dann,shema,libr,date_zap from '||load_||'.prig_times where itog=''delet'') and itog is null;

--удаление прочитанных данных ПРИГОРОД
delete from '||load_||'.prig_lgot_reestr where part_zap in(select part_zap from '||load_||'.prig_times where dann=''prig'' and itog=''delet'');
delete from '||load_||'.prig_analit where part_zap in(select part_zap from '||load_||'.prig_times where dann=''prig'' and itog=''delet'');
delete from '||load_||'.prig_itog where part_zap in(select part_zap from '||load_||'.prig_times where dann=''prig'' and itog=''delet'');


--удаление прочитанных данных СВОДЫ
--удаление по пассажирам
delete from rawdl2_day.svod_pass_cost where id_svod_pass in
(select id_svod_pass from rawdl2_day.svod_pass_main where request_date in(select distinct date_zap from  '||load_||'.prig_times where itog=''delet'' and oper=''dann'' and dann=''svod_pas''));

delete from rawdl2_day.link_svod_pass_main where id_svod_pass in
(select id_svod_pass from rawdl2_day.svod_pass_main where request_date in(select distinct date_zap from  '||load_||'.prig_times where itog=''delet'' and oper=''dann'' and dann=''svod_pas''));

delete from rawdl2_day.svod_pass_main where request_date in(select distinct date_zap from  '||load_||'.prig_times where itog=''delet'' and oper=''dann'' and dann=''svod_pas'');

--удаление по багажу
delete from rawdl2_day.svod_bag_cost where id_svod_bag in
(select id_svod_bag from rawdl2_day.svod_bag_main where request_date in(select distinct date_zap from  '||load_||'.prig_times where itog=''delet'' and oper=''dann'' and dann=''svod_bag''));

delete from rawdl2_day.link_svod_bag_main where id_svod_bag in
(select id_svod_bag from rawdl2_day.svod_bag_main where request_date in(select distinct date_zap from  '||load_||'.prig_times where itog=''delet'' and oper=''dann'' and dann=''svod_bag''));

delete from rawdl2_day.svod_bag_main where request_date in(select distinct date_zap from  '||load_||'.prig_times where itog=''delet'' and oper=''dann'' and dann=''svod_bag'');

--удаление КРС
delete from rawdl2_day.link_svod_krs where id_svod_krs in
(select id_svod_krs from rawdl2_day.svod_krs where request_date in(select distinct date_zap from  '||load_||'.prig_times where itog=''delet'' and oper=''dann'' and dann=''svod_krs''));

delete from rawdl2_day.svod_krs where request_date in(select distinct date_zap from  '||load_||'.prig_times where itog=''delet'' and oper=''dann'' and dann=''svod_krs'');

--удаление Питание
delete from rawdl2_day.link_svod_meal where id_svod_meal in
(select id_svod_meal from rawdl2_day.svod_meal where request_date in(select distinct date_zap from  '||load_||'.prig_times where itog=''delet'' and oper=''dann'' and dann=''svod_meal''));

delete from rawdl2_day.svod_meal where request_date in(select distinct date_zap from  '||load_||'.prig_times where itog=''delet'' and oper=''dann'' and dann=''svod_meal'');

--удаление Карты
delete from rawdl2_day.link_svod_cards where id_svod_cards in
(select id_svod_cards from rawdl2_day.svod_cards where request_date in(select distinct date_zap from  '||load_||'.prig_times where itog=''delet'' and oper=''dann'' and dann=''svod_card''));

delete from rawdl2_day.svod_cards where request_date in(select distinct date_zap from  '||load_||'.prig_times where itog=''delet'' and oper=''dann'' and dann=''svod_card'');

--ОТМЕТКА О РЕАЛЬНОМ УДАЛЕНИИ ДАННЫХ
update '||load_||'.prig_times set itog=''deleted'' where part_zap in(select part_zap from '||load_||'.prig_times where  itog=''delet'');

';
end;end if; --2


------------БЛОК ПЕРЕПРОЧТЕНИЯ ИНФОРМАЦИИ О НЕОБХОДИМОСТИ ЧИТАТЬ ИСХОДНЫЕ ДАННЫЕ НА ВСЕ ТАБЛИЦЫ
---ДЛЯ ЧТЕНИЯ - УЗНАТЬ КОЛИЧЕСТВО ОБНОВЛЯЕМЫХ ТАБЛИЦ
execute 'select count(*) from (select distinct dann,shema,libr,itog,oper from '||load_||'.prig_times where itog=''table'' ) as a '
	into /*date_zap,part_zap,shema,calc_time*/ kol;

RAISE INFO ' Количество таблиц=% ', kol;	

WHILE  (num<=kol) LOOP  --3

execute '
with ish as 
(select row_number() over(partition by dann,shema,libr,oper order by date_zap desc) as nnn,
 min(case when itog=''deleted'' then 1 else 0 end) over(partition by dann,shema,libr,oper,date_zap) as dell,*
 from '||load_||'.prig_times where oper=''dann'' or itog=''table'') 
 
select a.dann,a.shema,a.libr,a.oper,b.date_zap,coalesce(b.min_id,0) as min_id--,num
from (select *,row_number() over(order by dann,shema,libr,itog,oper) as num from ish where itog=''table'') as a
left join 
(select dann,shema,libr,oper,min(date_zap) as date_zap,min(min_id-1) as min_id
from ish where (nnn=1 or dell=1) and oper=''dann'' group by dann,shema,libr,oper) as b 
on a.dann=b.dann and a.libr=b.libr and a.shema=b.shema
where num='||num ||';'
	into dann,shema,libr,tabl,date_zap,min_id;

RAISE INFO 'Таблица %, Тип данных=%, Схема вида данных=%, схема=%, таблица=%, минимальная дата=%, минимальный idnum=%', num, dann,shema,libr,tabl,date_zap,min_id;	


execute 'insert into  '||load_||'.prig_times(dann,oper,date_zap,rezult,min_id,max_id,shema,libr,part_zap,min_id_svod,max_id_svod)
 select distinct '''||dann||''' as dann,''dann1'' as oper,date_zap,rezult,min_id,max_id,'''||shema||''' as shema,'''||libr||''' as libr,
 0 as part_zap,0 as min_id_svod,0 as max_id_svod from 
 (select REQUEST_DATE as date_zap,count(*) as rezult,min(idnum) as min_id,max(idnum) as max_id
  from '||libr||'.'||tabl||' where idnum>'||min_id||' group by 1) as a ; ';

GET DIAGNOSTICS rezult := ROW_COUNT;
RAISE INFO 'Записано % записей. ', rezult;	

num=num+1;END loop;--END LOOP; --3


---------------БЛОК ЧТЕНИЯ ВСЕХ НУЖНЫХ ДАННЫХ
--БЛОК ЧТЕНИЯ ПРИГОРОДА
call svod.prig_obog_poln(load_);
--БЛОК ЧТЕНИЯ СВОДОВ ПАССАЖИРСКИХ
call svod.svod_dann_poln(load_); 


end; --1
$BODY$;



ALTER /*FUNCTION*/ PROCEDURE svod.all_read(text,text,text) OWNER TO asul; --компилляция!

 

------------------------------------------------

call svod.all_read('l3_mes','2023-02-06',NULL);








----------------------------------------------------------

select * from l3_mes.prig_times where itog='deleted' 


select * from l3_mes.prig_times where shema='sut_prig' and oper in('dann','dann1','read') order by part_zap,oper









select * from
(select count(*)over(partition by dann,shema,libr,date_zap,min_id) as kol,*
from l3_mes.prig_times where  oper='dann' ) as a where kol>1 order by  dann,shema,libr,date_zap,min_id,itog


select * from l3_mes.prig_times where  oper='dann' and date_zap='2023-02-05'


















/**/

