







--select no_use,count(*) from rawdl2s.l2_pass_main group by 1 -- 812  -- s=708724 -- m=673519


-- select no_use,count(*) from zzz_rawdl2.l2_pass_main group by 1 -- 812  -- s=708724 -- m=673519






---------------СОЗДАНИЕ ТАБЛИЦЫ НУЖНЫХ ДАТ----------------
--   delete from  l3_mes.prig_times;
--  drop table l3_mes.prig_times;

CREATE TABLE l3_mes.prig_times
(date date,time char(12),time2 numeric,dann char(20),oper char(20),date_zap date,part_zap dec(7),rezult bigint,
 min_id bigint,max_id bigint,min_id_svod bigint,max_id_svod bigint,shema char(20),libr char(20),itog char(8) ) TABLESPACE pg_default;
ALTER TABLE l3_prig.prig_times OWNER to asul;
GRANT ALL ON TABLE l3_prig.prig_times TO asul;
-- разбил одно поле OPER на 2 поля  DANN +OPER



---------------------------====================================================
--      sale_station
-- drop table l3_mes.svod_work;

create table l3_mes.svod_work
(rez smallint,id_svod bigint,yyyy smallint,mm smallint,oper_cnt char(2),request_date date,agent_code smallint,subagent_code smallint,
term_pos char(3),term_dor char(1),otd smallint,term_trm char(2),sale_station char(7),flg_oper char(1),carrier_cnt char(2),carrier_code smallint,
registration_method char(1),flg_soob char(1),flg_sng char(1),flg_mg char(1),flg_prig char(1),military_code smallint,paymenttype char(1),
 benefitcnt_code char(2),sale_channel char(1),oper_channel char(1),flg_pakr char(1),flg_checktape char(1),payment_code char(4),tick_group char(1),
 doc_qty smallint,doc_vz smallint,
 flg_tt char(1),els_code char(10),kodagnels integer,koddorels char(1),prdogels char(1),flg_elssubag char(1),terminal_posruc char(3),rate_date date,
 idnum bigint,sum_code smallint,cnt_code char(2),dor_code smallint,
 sum_nde dec(15,2),vat_sum dec(15,2),vatrate dec(15,2),
 shipment_type char(3),flg_internet char(1),card_cost dec(7),vat_cost dec(15,2),sum_sbv dec(15,2),vatrate_vz dec(3,2),
 addrat_cost dec(13,2),addrat_vat dec(13,2),usl_qty smallint,sum_sb dec(15,2)
) TABLESPACE pg_default;
ALTER TABLE l3_mes.svod_work OWNER to asul;
GRANT ALL ON TABLE l3_mes.svod_work TO asul;


/* --БОЛЬШАЯ ЧИСТКА ВСЕХ ВВЕДЁННЫХ ДАННЫХ
delete from l3_mes.prig_times where substr(dann,1,4)='svod';

delete from rawdl2_day.svod_pass_main;
delete from rawdl2_day.link_svod_pass_main;
delete from rawdl2_day.svod_pass_cost;

delete from rawdl2_day.svod_bag_main;
delete from rawdl2_day.link_svod_bag_main;
delete from rawdl2_day.svod_bag_cost;

delete from rawdl2_day.svod_krs;
delete from rawdl2_day.link_svod_krs;

delete from rawdl2_day.svod_meal;
delete from rawdl2_day.link_svod_meal;

delete from rawdl2_day.svod_cards;
delete from rawdl2_day.link_svod_cards;



*/



-----------------------
--подготовка таблицы необходимых записей

--   select *  from rawdl2s.l2_pass_main limit 100;
--   delete from  l3_mes.prig_times where shema='sut'
/** /
insert into  l3_mes.prig_times(dann,oper,date_zap,rezult,min_id,max_id,shema,libr,part_zap,min_id_svod,max_id_svod)
 select distinct 'svod_pas' as dann,'dann1' as oper,date_zap,rezult,min_id,max_id,'sut' as shema,'rawdl2s' as libr,0 as part_zap,0 as min_id_svod,0 as max_id_svod from 
 (select REQUEST_DATE as date_zap,count(*) as rezult,min(idnum) as min_id,max(idnum) as max_id
  from rawdl2s.l2_pass_main group by 1) as a ; 
/ **/  
  
  
/**/
insert into  l3_mes.prig_times(dann,oper,date_zap,rezult,min_id,max_id,shema,libr,part_zap,min_id_svod,max_id_svod)
 select distinct 'svod_pas' as dann,'dann1' as oper,date_zap,rezult,min_id,max_id,'mes' as shema,'rawdl2m' as libr,0 as part_zap,0 as min_id_svod,0 as max_id_svod from 
 (select REQUEST_DATE as date_zap,count(*) as rezult,min(idnum) as min_id,max(idnum) as max_id
  from rawdl2m.l2_pass_main group by 1) as a ; 
  
insert into  l3_mes.prig_times(dann,oper,date_zap,rezult,min_id,max_id,shema,libr,part_zap,min_id_svod,max_id_svod)
 select distinct 'svod_bag' as dann,'dann1' as oper,date_zap,rezult,min_id,max_id,'mes' as shema,'rawdl2m' as libr,0 as part_zap,0 as min_id_svod,0 as max_id_svod from 
 (select REQUEST_DATE as date_zap,count(*) as rezult,min(idnum) as min_id,max(idnum) as max_id
  from rawdl2m.l2_bag_main group by 1) as a ; 

insert into  l3_mes.prig_times(dann,oper,date_zap,rezult,min_id,max_id,shema,libr,part_zap,min_id_svod,max_id_svod)
 select distinct 'svod_krs' as dann,'dann1' as oper,date_zap,rezult,min_id,max_id,'mes' as shema,'rawdl2m' as libr,0 as part_zap,0 as min_id_svod,0 as max_id_svod from 
 (select REQUEST_DATE as date_zap,count(*) as rezult,min(idnum) as min_id,max(idnum) as max_id
  from rawdl2m.l2_krs group by 1) as a ; 

insert into  l3_mes.prig_times(dann,oper,date_zap,rezult,min_id,max_id,shema,libr,part_zap,min_id_svod,max_id_svod)
 select distinct 'svod_card' as dann,'dann1' as oper,date_zap,rezult,min_id,max_id,'mes' as shema,'rawdl2m' as libr,0 as part_zap,0 as min_id_svod,0 as max_id_svod from 
 (select REQUEST_DATE as date_zap,count(*) as rezult,min(idnum) as min_id,max(idnum) as max_id
  from rawdl2m.l2_cards group by 1) as a ; 

insert into  l3_mes.prig_times(dann,oper,date_zap,rezult,min_id,max_id,shema,libr,part_zap,min_id_svod,max_id_svod)
 select distinct 'svod_meal' as dann,'dann1' as oper,date_zap,rezult,min_id,max_id,'mes' as shema,'rawdl2m' as libr,0 as part_zap,0 as min_id_svod,0 as max_id_svod from 
 (select REQUEST_DATE as date_zap,count(*) as rezult,min(idnum) as min_id,max(idnum) as max_id
  from rawdl2m.l2_meal group by 1) as a ; 
/**/

/*
insert into  l3_mes.prig_times(dann,oper,date_zap,rezult,min_id,max_id,shema,libr,part_zap,min_id_svod,max_id_svod)
 select distinct 'svod_pas' as dann,'dann1' as oper,date_zap,rezult,min_id,max_id,'mes' as shema,'rawdl2' as libr,0 as part_zap,0 as min_id_svod,0 as max_id_svod from 
 (select REQUEST_DATE as date_zap,count(*) as rezult,min(idnum) as min_id,max(idnum) as max_id
  from rawdl2.l2_pass_main group by 1) as a ; 
  
insert into  l3_mes.prig_times(dann,oper,date_zap,rezult,min_id,max_id,shema,libr,part_zap,min_id_svod,max_id_svod)
 select distinct 'svod_bag' as dann,'dann1' as oper,date_zap,rezult,min_id,max_id,'mes' as shema,'rawdl2' as libr,0 as part_zap,0 as min_id_svod,0 as max_id_svod from 
 (select REQUEST_DATE as date_zap,count(*) as rezult,min(idnum) as min_id,max(idnum) as max_id
  from rawdl2.l2_bag_main group by 1) as a ; 

insert into  l3_mes.prig_times(dann,oper,date_zap,rezult,min_id,max_id,shema,libr,part_zap,min_id_svod,max_id_svod)
 select distinct 'svod_krs' as dann,'dann1' as oper,date_zap,rezult,min_id,max_id,'mes' as shema,'rawdl2' as libr,0 as part_zap,0 as min_id_svod,0 as max_id_svod from 
 (select REQUEST_DATE as date_zap,count(*) as rezult,min(idnum) as min_id,max(idnum) as max_id
  from rawdl2.l2_krs group by 1) as a ; 

insert into  l3_mes.prig_times(dann,oper,date_zap,rezult,min_id,max_id,shema,libr,part_zap,min_id_svod,max_id_svod)
 select distinct 'svod_card' as dann,'dann1' as oper,date_zap,rezult,min_id,max_id,'mes' as shema,'rawdl2' as libr,0 as part_zap,0 as min_id_svod,0 as max_id_svod from 
 (select REQUEST_DATE as date_zap,count(*) as rezult,min(idnum) as min_id,max(idnum) as max_id
  from rawdl2.l2_cards group by 1) as a ; 

insert into  l3_mes.prig_times(dann,oper,date_zap,rezult,min_id,max_id,shema,libr,part_zap,min_id_svod,max_id_svod)
 select distinct 'svod_meal' as dann,'dann1' as oper,date_zap,rezult,min_id,max_id,'mes' as shema,'rawdl2' as libr,0 as part_zap,0 as min_id_svod,0 as max_id_svod from 
 (select REQUEST_DATE as date_zap,count(*) as rezult,min(idnum) as min_id,max(idnum) as max_id
  from rawdl2.l2_meal group by 1) as a ; 
*/





---------------------------------------------------------------------------------------------
--ПРОВЕРКА РАБОТЫ

select * from l3_mes.prig_times where oper='dann1' and dann!='prig'

--УДАЛЕНИЕ ИЗ СПИСКА УЖЕ ПРОЧИТАННОЙ ПОРЦИИ
select * from l3_mes.prig_times where dann in('svod_pas','svod_bag','svod_krs','svod_card','svod_meal') and oper='dann1'
and (dann,date_zap,shema,min_id,max_id) in
(select distinct dann,date_zap,shema,min_id,max_id from l3_mes.prig_times where oper in('read','dann') and itog is null);


--ЧАСТЬ 1 - ВВОДИМ НОЫВЕ ПОРЦИИ ДЛЯ ЧТЕНИЯ, если есть 
insert into  l3_mes.prig_times(dann,oper,date_zap,rezult,min_id,max_id,shema,libr,part_zap)
with
part as(select max(part_zap) as part from l3_mes.prig_times),
dn as
(select dann,'dann' as oper,date_zap,rezult,min_id,max_id,shema,libr, 
 (case when part is null then 0 else part end)+
 row_number() over(order by date_zap,dann) as part_zap
 from
(select distinct date_zap,rezult,min_id,max_id,shema,libr,part_zap,dann
 from l3_mes.prig_times where dann in('svod_pas','svod_bag','svod_krs','svod_card','svod_meal') and oper='dann1') as a,
 part as b ) 
select dann,oper,date_zap,rezult,min_id,max_id,shema,libr,part_zap from dn;


--УДАЛЕНИЕ ИЗ СПИСКА УЖЕ ПРОЧИТАННОЙ ПОРЦИИ - копия НаВсякийСлучай
delete from l3_mes.prig_times where dann in('svod_pas','svod_bag','svod_krs','svod_card','svod_meal') and oper='dann1'
and (dann,date_zap,shema,min_id,max_id) in
(select distinct dann,date_zap,shema,min_id,max_id from l3_mes.prig_times where oper in('read','dann') and itog is null);







----------------------------------------------------------------------------------
-- ПРОГРАММА ЗАГРУЗКИ ПО СПРАВОЧНИКУ ВСЕХ ПОРЦИЙ ЧТЕНИЯ

--УДАЛЕНИЕ ИЗ СПИСКА УЖЕ ПРОЧИТАННОЙ ПОРЦИИ
delete from l3_mes.prig_times where dann in('svod_pas','svod_bag','svod_krs','svod_card','svod_meal') and oper='dann1'
and (dann,date_zap,shema,min_id,max_id) in
(select distinct dann,date_zap,shema,min_id,max_id from l3_mes.prig_times where oper in('read','dann'));


--ЧАСТЬ 1 - ВВОДИМ НОЫВЕ ПОРЦИИ ДЛЯ ЧТЕНИЯ, если есть 
insert into  l3_mes.prig_times(dann,oper,date_zap,rezult,min_id,max_id,shema,libr,part_zap)
with
part as(select max(part_zap) as part from l3_mes.prig_times),
dn as
(select dann,'dann' as oper,date_zap,rezult,min_id,max_id,shema,libr, 
 (case when part is null then 0 else part end)+
 row_number() over(order by date_zap,dann) as part_zap
 from
(select distinct date_zap,rezult,min_id,max_id,shema,libr,part_zap,dann
 from l3_mes.prig_times where dann in('svod_pas','svod_bag','svod_krs','svod_card','svod_meal') and oper='dann1') as a,
 part as b ) 
select dann,oper,date_zap,rezult,min_id,max_id,shema,libr,part_zap from dn;


--УДАЛЕНИЕ ИЗ СПИСКА УЖЕ ПРОЧИТАННОЙ ПОРЦИИ - копия НаВсякийСлучай
delete from l3_mes.prig_times where dann in('svod_pas','svod_bag','svod_krs','svod_card','svod_meal') and oper='dann1'
and (dann,date_zap,shema,min_id,max_id) in
(select distinct dann,date_zap,shema,min_id,max_id from l3_mes.prig_times where oper in('read','dann'));



---------------------------==================================================== ДАЛЕЕ ОРГАНИЗАЦИЯ ДЛЯ ЦИКЛА  

--УСТАНОВКА НОМЕРА КОНКРЕТНОЙ НОВОЙ ЧИТАЕМОЙ ПОРЦИИ
delete from l3_mes.prig_times where oper='dannie';

insert into  l3_mes.prig_times(dann,oper,date_zap,shema,libr,part_zap,rezult,min_id,max_id,min_id_svod)
with times as
(select * from l3_mes.prig_times where part_zap>0 and dann in('svod_pas','svod_bag','svod_krs','svod_card','svod_meal')),
id_svod as 
(select case when min_id_svod is null then 0 else min_id_svod end as min_id_svod
 from (select max(max_id_svod) as min_id_svod from times) as a)

select dann,oper,date_zap,shema,libr,part_zap,rezult,min_id,max_id,min_id_svod from
(select dann,'dannie' as oper,date_zap,shema,libr,part_zap,rezult,min_id,max_id,row_number() over(order by part_zap) as nn
from times where oper='dann'
and (dann,part_zap) not in(select dann,part_zap from times where oper='read')
) as a,id_svod where nn=1;














----------------------------------------------------------------------------------------------------
--БЛОК НЕНОРМАЛЬНОЙ РАБОТЫ - ЕСЛИ СКАЗАНО УДАЛИТЬ ПРОЧИТАННЫЕ ДАННЫЕ


select * from l3_prig.prig_times where dann='prig' and oper='read' order by date_zap

--установка удаляемой порции
update l3_prig.prig_times set itog='delet' where dann='prig' and oper='read' and date_zap='2023-01-31' and itog is null

--удаление прочитанных данных


delete from l3_prig.prig_lgot_reestr where part_zap in(select part_zap from l3_prig.prig_times where dann='prig' and itog='delet');
delete from l3_prig.prig_analit where part_zap in(select part_zap from l3_prig.prig_times where dann='prig' and itog='delet');
delete from l3_prig.prig_itog where part_zap in(select part_zap from l3_prig.prig_times where dann='prig' and itog='delet');


update l3_prig.prig_times set itog='deleted' where part_zap in(select part_zap from l3_prig.prig_times where dann='prig' and itog='delet')





select * from l3_prig.prig_times where part_zap in(select part_zap from l3_prig.prig_times where dann='prig' and itog='delet')
and oper like '%2_4%22%%';


--понять откуда теперь читать


----------------- ВЫЧИСЛЕНИЕ - КАКУЮ ТАБЛИЦУ С КАКОГО МОМЕНТА ЧИТАТЬ? с учётом удалённых строк  

select * from l3_mes.prig_times where oper='dann' order by date_zap



with
ish as 
(select *,
 max(case when itog is null then 1 else 0 end) over (partition by dann,shema,libr,date_zap) as itog2,
 row_number() over(partition by dann,shema,libr,oper order by date_zap desc) as nnn
 from l3_prig.prig_times where (oper='read') or itog='table')
select * from ish where nnn=1 or itog2!=1
 
 
 select * from ish where dann='prig' order by dann,shema,libr,oper,date_zap
 
 
 
 
with 
ish as 
(select dann,shema,libr,itog,oper,min(min_id) as  min_id from
(select row_number() over(partition by dann,shema,libr,itog,oper order by date_zap desc) as nnn,*
 from l3_mes.prig_times where (oper='read') or itog='table') as a where nnn<=3 group by 1,2,3,4,5)
/* 
select a.dann,a.shema,a.libr,a.oper,coalesce(b.min_id,0) as min_id--,num
from (select *,row_number() over(order by dann,shema,libr,itog,oper) as num from ish where itog='table') as a --where itog='table' 
left join (select * from ish where oper='read' /*and dann!='svod_krs'*/) as b on a.dann=b.dann and a.libr=b.libr and a.shema=b.shema
--order by dann,shema,libr,itog,oper
--where num=4
*/





















---------------------------====================================================



-- ПРОГРАММА НАРАБОТКИ ЧТЕНИЯ ДАННЫХ

select * from l3_mes.prig_times where dann='svod_pas' and oper='dann' order by date_zap


--delete from l3_mes.prig_times where itog='table';

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

with
ish as 
(select dann,shema,libr,itog,oper,min(min_id) as  min_id from
(select row_number() over(partition by dann,shema,libr,itog,oper order by date_zap desc) as nnn,*
 from l3_mes.prig_times where (oper='read' and itog is null) or itog='table') as a where nnn<=3 group by 1,2,3,4,5)
 
select a.dann,a.shema,a.libr,a.oper,coalesce(b.min_id,0) as min_id--,num
from (select *,row_number() over(order by dann,shema,libr,itog,oper) as num from ish where itog='table') as a --where itog='table' 
left join (select * from ish where oper='read' and dann!='svod_krs') as b on a.dann=b.dann and a.libr=b.libr and a.shema=b.shema
--order by dann,shema,libr,itog,oper
--where num=4


----------------------------------------------------------------------
execute '
insert into  '||load_||'.prig_times(dann,oper,date_zap,rezult,min_id,max_id,shema,libr,part_zap,min_id_svod,max_id_svod)
 select distinct '||dann||' as dann,''dann1'' as oper,date_zap,rezult,min_id,max_id,''mes'' as shema,'||libr||' as libr,0 as part_zap,0 as min_id_svod,0 as max_id_svod from 
 (select REQUEST_DATE as date_zap,count(*) as rezult,min(idnum) as min_id,max(idnum) as max_id
  from '||libr||'.'||tabl||' where idnum>='||min_id||' group by 1) as a ; 
';

----------------------------------------------------------------------



CREATE OR REPLACE /*FUNCTION*/ PROCEDURE svod.prig_read(load_ text --,load_date date,work_schema text
)
  --  RETURNS text 
    LANGUAGE 'plpgsql'
  --  COST 100
  --  VOLATILE 
    
AS $BODY$
--Программа - сборник блоков по обогащению пригорода.
declare
	kol integer;num integer;rezult integer;min_id bigint;
	date_zap	date;
	part_zap integer;
	shema text;dann text;libr text;tabl text;
	calc_time char(20);
	tabname text;
	
	
begin  --1
load_=$1;
part_zap=1;num=1;

execute 'select count(*) from (select distinct dann,shema,libr,itog,oper from '||load_||'.prig_times where itog=''table'' ) as a '
	into /*date_zap,part_zap,shema,calc_time*/ kol;

RAISE INFO ' Количество таблиц=% ', kol;	

WHILE  (num<=kol) LOOP  --3

execute 'with
ish as 
(select dann,shema,libr,itog,oper,min(min_id) as  min_id from
(select row_number() over(partition by dann,shema,libr,itog,oper order by date_zap desc) as nnn,*
 from '||load_||'.prig_times where (oper=''read'' and itog is null) or itog=''table'') as a where nnn<=3 group by 1,2,3,4,5)
 
select a.dann,a.shema,a.libr,a.oper,coalesce(b.min_id,0) as min_id
from (select *,row_number() over(order by dann,shema,libr,itog,oper) as num from ish where itog=''table'') as a --where itog=''table'' 
left join (select * from ish where oper=''read'' ) as b on a.dann=b.dann and a.libr=b.libr and a.shema=b.shema
where num='||num ||';'
	into dann,shema,libr,tabl,min_id;

RAISE INFO '% Количество таблиц=% , Таблица %  % % %', num, dann,shema,libr,tabl,min_id;	

execute 'insert into  '||load_||'.prig_times(dann,oper,date_zap,rezult,min_id,max_id,shema,libr,part_zap,min_id_svod,max_id_svod)
 select distinct '''||dann||''' as dann,''dann1'' as oper,date_zap,rezult,min_id,max_id,'''||shema||''' as shema,'''||libr||''' as libr,
 0 as part_zap,0 as min_id_svod,0 as max_id_svod from 
 (select REQUEST_DATE as date_zap,count(*) as rezult,min(idnum) as min_id,max(idnum) as max_id
  from '||libr||'.'||tabl||' where idnum>='||min_id||' group by 1) as a ; ';

GET DIAGNOSTICS rezult := ROW_COUNT;
RAISE INFO 'Записано % записей. ', rezult;	

num=num+1;END loop;--END LOOP; --3

end; --1
$BODY$;



ALTER /*FUNCTION*/ PROCEDURE svod.prig_read(text) OWNER TO asul; --компилляция!

 

------------------------------------------------

call svod.prig_read('l3_mes');





















/**/