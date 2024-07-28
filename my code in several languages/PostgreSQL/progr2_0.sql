
----- заменить одиночный апостроф на два апострофа

----- заменить rawdl2. на '||shema2||'.
---- строку 'tst_prig' заменить на '||shema||'  в итоге получается  '''||shema||'''
---- строку l3_prig. заменить на '||load_shema||'.



-- ПРОГРАММА ФОРМИРОВАНИЯ БЛОКА ДЛЯ ЧТЕНИЯ ИЗ ИМЕЮЩИХСЯ ДАННЫХ.


----------------------------------------------------------------------------------------------------
--БЛОК НЕНОРМАЛЬНОЙ РАБОТЫ - ЕСЛИ СКАЗАНО УДАЛИТЬ ПРОЧИТАННЫЕ ДАННЫЕ


select * from l3_prig.prig_times where dann='prig' and oper='dann' order by date_zap,part_zap

--установка удаляемой порции
update l3_prig.prig_times set itog='delet' where dann='prig' and oper='dann' and date_zap='2023-01-31' and itog is null

--распространить удаление на целые сутки
update l3_prig.prig_times set itog='delet' where oper='dann' and (dann,shema,libr,date_zap) in
(select dann,shema,libr,date_zap from l3_prig.prig_times where dann='prig' and itog='delet') and itog is null

--удаление прочитанных данных


delete from l3_prig.prig_lgot_reestr where part_zap in(select part_zap from l3_prig.prig_times where dann='prig' and itog='delet');
delete from l3_prig.prig_analit where part_zap in(select part_zap from l3_prig.prig_times where dann='prig' and itog='delet');
delete from l3_prig.prig_itog where part_zap in(select part_zap from l3_prig.prig_times where dann='prig' and itog='delet');


update l3_prig.prig_times set itog='deleted' where part_zap in(select part_zap from l3_prig.prig_times where dann='prig' and itog='delet')











----------------------------------------------------------------------------------------------------
--БЛОК НЕНОРМАЛЬНОЙ РАБОТЫ - ЕСЛИ СКАЗАНО УДАЛИТЬ ПРОЧИТАННЫЕ ДАННЫЕ -  ДЛЯ РЕАЛЬНЫХ ДАННЫХ


select * from l3_mes.prig_times where dann='svod_pas' and oper='dann' order by date_zap,part_zap


select date_zap,count(*) as kol from l3_mes.prig_times where  oper='dann' group by 1 order by 1

select * from l3_mes.prig_times where date_zap='2023-03-01' --and itog is not null 
order by part_zap,time


select * from l3_mes.prig_times where dann='svod_pas' order by date_zap,oper




--------------------=====================================================================
--установка удаляемой порции
update l3_mes.prig_times set itog='delet' where  oper='dann' and date_zap='2023-03-01' and itog is null

--распространить удаление на целые сутки
update l3_mes.prig_times set itog='delet' where /*oper='dann' and*/ (dann,shema,libr,date_zap) in
(select dann,shema,libr,date_zap from l3_mes.prig_times where /*dann='prig' and*/ itog='delet') and itog is null

--удаление прочитанных данных пригород


delete from l3_mes.prig_lgot_reestr where part_zap in(select part_zap from l3_mes.prig_times where dann='prig' and itog='delet');
delete from l3_mes.prig_analit 		where part_zap in(select part_zap from l3_mes.prig_times where dann='prig' and itog='delet');
delete from l3_mes.prig_itog 		where part_zap in(select part_zap from l3_mes.prig_times where dann='prig' and itog='delet');

--удаление прочитанных данных СВОДЫ

select id_svod_pass from rawdl2_day.svod_pass_main where request_date in(select distinct date_zap from  l3_mes.prig_times where itog='delet' and oper='dann' and dann='svod_pas')
limit 100

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









--ОТМЕТКА ОБ УДАЛЕНИИ ДАННЫХ
update l3_mes.prig_times set itog='deleted' where part_zap in(select part_zap from l3_mes.prig_times where  itog='delet')










----------------------------------------------------------------------------------------------------
--БЛОК НОРМАЛЬНОЙ РАБОТЫ
/*
select * from l3_mes.prig_times where dann='prig' and oper='dann1'

select * from l3_mes.prig_times where dann='prig' and date_zap='2023-04-07' and  oper in('dann','dann1')

select * from l3_mes.prig_times where dann='prig' and oper='dann1' and (date_zap,shema,libr) in
(select distinct date_zap,shema,libr from l3_mes.prig_times where dann='prig' and oper='dann' and itog is null);
*/


----------------------------------------------------------------------------------------------------
--БЛОК НОРМАЛЬНОЙ РАБОТЫ


--ЧАСТЬ 0 - УДАЛЕНИЕ ИЗ СПИСКА УЖЕ ПРОЧИТАННОЙ ПОРЦИИ
delete from l3_mes.prig_times where dann='prig' and oper='dann1' and (date_zap,shema,libr) in
(select distinct date_zap,shema,libr from l3_mes.prig_times where dann='prig' and oper='dann' and itog is null);


--ЧАСТЬ 1 - ВВОДИМ НОВУЮ РОВНО ОДНУ ДАТУ МИНИМАЛЬНУЮ, И ЕСЛИ МНОГО ЗАПИСЕЙ В ЧТЕНИИ ИЗ ПРИГОРОДА - С ОТРИЦАТЕЛЬНЫМ НОМЕРОМ ПОРЦИИ
insert into  l3_mes.prig_times(dann,oper,date_zap,rezult,min_id,max_id,shema,libr,part_zap)
with
times as (select * from l3_mes.prig_times where dann='prig' and itog is null),
dat as (select min(date_zap) as max_date from times where oper='dann1'),
part as(select max(part_zap) as part from l3_mes.prig_times),
iz as (select count(*) as kol from times where part_zap!=0 and oper='dann' and part_zap not in(select part_zap from times where oper='read')),
dn as
(select date_zap,rezult,min_id,max_id,shema,libr,
 case when rezult>700000 and substr(shema,5,4)='prig' then -part_zap else part_zap end as part_zap from
(select date_zap,rezult,min_id,max_id,shema,libr, 
 (case when part is null then 0 else part end)+zap as part_zap from
 (select date_zap,rezult,min_id,max_id,shema,libr,part_zap,row_number() over(order by shema,libr) as zap
 from times,dat where date_zap=max_date and oper='dann1') as a,part,iz where kol=0 and zap=1) as b)
select 'prig' as dann,'dann' as oper,date_zap,rezult,min_id,max_id,shema,libr,part_zap from dn;






 
/* 
insert into  '||load_shema||'.prig_times(oper,date_zap,rezult,min_id,max_id,shema,libr,part_zap)
with
dat as (select min(date_zap) as max_date from '||load_shema||'.prig_times where oper=''dann1''),
part as(select max(part_zap) as part from '||load_shema||'.prig_times),
iz as (select count(*) as kol from '||load_shema||'.prig_times where part_zap!=0 and oper=''dann''),
dn as
(select oper,date_zap,rezult,min_id,max_id,shema,libr,
 case when rezult>700000 and substr(shema,5,4)=''prig'' then -part_zap else part_zap end as part_zap from
(select ''dann'' as oper,date_zap,rezult,min_id,max_id,shema,libr,part+zap as part_zap from
(select date_zap,rezult,min_id,max_id,shema,libr,part_zap,row_number() over(order by (substr(shema,5,4)=''prig''),shema,libr) as zap
 from '||load_shema||'.prig_times,dat where date_zap=max_date and oper=''dann1'') as a,part,iz where kol=0 and zap=1) as b)
select oper,date_zap,rezult,min_id,max_id,shema,libr,part_zap from dn; */
 


--вспомогательные данные о бибилиотеке
--select  max(libr) as libr,count(*) as kol from  l3_prig.prig_times where dann='prig' and oper='dann' and part_zap<0 




--ЧАСТЬ 2 - ОТРИЦАТЕЛЬНЫЙ НОМЕР ПОРЦИИ (ТОЛЬКО ПРИГОРОД) ДЕЛИМ НА 3 ЧАСТИ, ДВЕ ДЛИНОЙ ПО  МАКСИМУМУ, ПОСЛЕДНЯЯ КАК ПРИДЁТСЯ
insert into  l3_prig.prig_times(dann,oper,date_zap,shema,libr,part_zap,rezult,min_id,max_id)
with
dn as (select dann,oper,date_zap,rezult,min_id,max_id,shema,libr,part_zap from l3_prig.prig_times where  dann='prig' and oper='dann' and part_zap<0 and itog is null),
zn as
(select count(*) as rezult1,min(idnum) as min_id1,max(idnum) as max_id1 from
(select idnum from rawdl2.l2_prig_main where  REQUEST_DATE in(select date_zap from dn)
and idnum between (select min_id from dn) and (select max_id from dn)
 offset 500000 limit 500000
) as a),
rez1 as (select dann,oper,date_zap,rezult,min_id,max_id,shema,libr,part_zap,rezult1,min_id1,max_id1 from dn,zn),
rez2 as 
(select dann,oper,date_zap,shema,libr,-part_zap as part_zap,500000 as rezult,min_id,min_id1-1 as max_id from rez1
union all
 select dann,oper,date_zap,shema,libr,-part_zap+1 as part_zap,rezult1 as rezult,min_id1 as min_id,max_id1 as max_id from rez1
 union all
 select dann,oper,date_zap,shema,libr,-part_zap+2 as part_zap,rezult-500000-rezult1 as rezult,max_id1+1 as min_id,max_id from rez1
)
select dann,oper,date_zap,shema,libr,case when rezult>700000 then -part_zap else part_zap end as part_zap,rezult,min_id,max_id 
from rez2;




delete from l3_prig.prig_times where dann='prig' and part_zap<0 and part_zap in(select -part_zap from l3_prig.prig_times where dann='prig' and itog is null );
delete from l3_prig.prig_times where dann='prig' and oper='dann1' and (date_zap,shema,libr) in 
	(select date_zap,shema,libr from l3_prig.prig_times where part_zap!=0 and dann='prig' and oper='dann' and itog is null);
delete from l3_prig.prig_times where dann='prig' and min_id>max_id and itog is null;

--УСТАНОВКА НОМЕРА НОВОЙ ЧИТАЕМОЙ ПОРЦИИ из нескольких возможных вариантов
delete from l3_prig.prig_times where dann='prig' and oper='dannie';

insert into l3_prig.prig_times(dann,oper,date_zap,shema,libr,part_zap,rezult,min_id,max_id)
with ish as (select * from l3_prig.prig_times where dann='prig' and itog is null)
select dann,'dannie' as oper,date_zap,shema,libr,part_zap,rezult,min_id,max_id from
(select dann,date_zap,shema,libr,part_zap,rezult,min_id,max_id,row_number() over(order by part_zap) as nn
from ish where oper='dann'  and part_zap>0 and part_zap not in(select part_zap from ish where oper='read')
) as a where nn=1;



--удаление старья
delete from l3_prig.prig_work;
--delete from l3_prig.prig_itog;  --таблица обогащения данных!

delete from l3_prig.prig_times where dann='prig' and part_zap in
(select part_zap from l3_prig.prig_times where dann='prig' and oper='dannie'  and itog is null)
	and oper not in('dann','dannie');





--------------------



/*
select count(*) from l3_mes.prig_analit;

select * from l3_mes.prig_analit limit 100

select yymm,count(*) from l3_mes.prig_analit where date='2023-02-08' group by 1 order by 1
*/






















/**/

