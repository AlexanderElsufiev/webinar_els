




--В маршрутнике есть флаг принадлежности станции МЦД. По расписанному маршруту пассажира мы видим, что есть какое-то МЦД. А сам номер МЦД сидит в поле номер поезда Q64NP. Если там '1' или '2' или  '3', то это номер МЦД, которое мы нашли в маршруте пассажира.

--ПРОГРАММА ПЕРВИЧНОЙ ПЕРЕРАБОТКИ ДАННЫХ, НАРАБОТКА СПРАВОЧНИКА БИЛЕТВ И МАРШРУТОВ, 
--ПОЛУЧЕНИЕ ОТПРАВЛЕННЫХ ПАССАЖИРОВ ПО ДАТАМ ОТПРАВЛЕНИЯ СОКРАЩЕНИЕ ЧИСЛА ЗАПИСЕЙ БЕЗ ПОТЕРИ ИНФОРМАЦИИ

--ТОЛЬКО ПРОЦЕДУРА ОБОГАЩЕНИЯ, НЕ БОЛЕЕ ТОГО!!! Вторая часть - переработка маршрутов


/**/
--- ввод времени начала операции
insert into  l3_prig.prig_times(time,date,dann,libr,oper,time2,date_zap,part_zap,shema)
with a as
(select date_zap,part_zap,dann,libr,shema,current_date as date,substr(cast(current_time as char(50)),1,12) as time
	from  l3_prig.prig_times where dann='prig' and oper='dannie')
select time,date,dann,libr,'prig_work 2_21_beg' as oper,
(cast(substr(time,1,2) as dec(3))*60+cast(substr(time,4,2) as dec(3)))*60+cast(substr(time,7,6) as dec(7,3)) as time2,date_zap,part_zap,shema
from a;



/*СОБСТВЕННО ПРОГРАММА*/
/**/

insert into l3_prig.prig_work(
	rez,IDNUM,opis,nom,marshr,mcd,rst,st1,st2,reg,sto,stn,srasst,sto_zone,stn_zone,sti,sti_zone,d_plata,d_poteri,k_bil )
/**/

with

dates as  --дата загружаемых данных
(select distinct date_zap,part_zap from  l3_prig.prig_times where dann='prig' and oper='dannie'),


prig_cost as --возвращение маршрутов  prig_cost2_nodd   -- 221139 =2sek
(select idnum,sto,stn,nom,reg,srasst,k_bil,d_plata,d_poteri,marshr,st1,st2,rst as rasst,sto_zone,stn_zone,sti,sti_zone,
 /*case when length(train_num)>2 or train_num is null then 0 else cast(train_num as smallint) end as*/ mcd,
 max(nom) over (partition by IDNUM) as max_nom
	from l3_prig.prig_work where rez=5),



/*ПЕРВЫЙ ВАРИАНТ ПОДПРОГРАММЫ, ИНОГДА ТОРМОЗИТ*/
prig_cost_hash as  -- хэши на первичное описание разбиений маршрутов  -- 176103 =3sek
(select IDNUM,k_bil,hash,(('x'||md5(hash))::bit(64)::bigint) as hh
 from
(select IDNUM,k_bil,--max_nom,srasst,sto_reg,stn_reg, --считаем сдвоенных хэш заведомо сильным
 hash1 ||'-'||cast(max_nom as char(7))||'-'||cast(sto_reg as char(7))||'-'||cast(stn_reg as char(7))||'-'||cast(hash2 as char(32)) 
 as hash
 from
(select IDNUM,max_nom,srasst,hash1,k_bil,
 sum(case when nom=1 then regg else 0 end) as sto_reg,sum(case when nom=max_nom then regg else 0 end) as stn_reg,
 sum(('x'||md5(hash2))::bit(64)::bigint) as hash2
 from 
(select IDNUM,nom,max_nom,srasst,reg as regg,k_bil,
 cast(sto as char(7))||'-'||cast(stn as char(7))||'-'||cast(srasst as char(7))||'-'||cast(sto_zone as char(7)) 
 ||'-'||cast(stn_zone as char(7)) ||'-'||cast(sti as char(7)) ||'-'||cast(sti_zone as char(7))
 ||'-'||cast(sum(d_plata) over (partition by IDNUM) as char(7))
 ||'-'||cast(sum(d_poteri) over (partition by IDNUM) as char(7))
 as hash1,
 cast(nom as char(7))||'-'||cast(st1 as char(7))||'-'||cast(st2 as char(7))||'-'||cast(rasst as char(7))
 ||'-'||cast(marshr as char(7))||'-'||cast(mcd as char(3))
 ||'-'||cast(reg as char(7))--||'-'||cast(dorlin as char(7))
 ||'-'||case when d_plata is null then '.' else cast(d_plata as char(7)) end 
 ||'-'||case when d_poteri is null then '.' else cast(d_poteri as char(7)) end  as hash2
from prig_cost) as a group by 1,2,3,4,5) as b) as c),
 
prig_cost_opis as  --соответствия билет - номер описания  -- 176103 =4sek
(select IDNUM,min(k_bil) as k_bil,min(opis) as opis from --для ускорения вместо distinct
(select IDNUM,k_bil,min(IDNUM) over (partition by hash) as opis from prig_cost_hash as a)
 as b group by IDNUM),

--select * from prig_cost_opis

prig_opis as -- список всех уникальных описаний   -- 14610 =4sek
(select a.IDNUM,opis,nom,marshr,mcd,rasst,st1,st2,reg as regg,max_nom,sto,stn,srasst,sto_zone,stn_zone,sti,sti_zone,d_plata,d_poteri--,nom_sts
 from prig_cost as a
 join (select * from prig_cost_opis where IDNUM=opis) as b on a.idnum=b.idnum),



itog as
(select  51 as rez,IDNUM,opis,nom,marshr,mcd,rasst,st1,st2,regg,sto,stn,srasst,sto_zone,stn_zone,sti,sti_zone,d_plata,d_poteri,0 as k_bil
 from prig_opis
 union all
 select  7 as rez,IDNUM,opis,0 as nom,0 as marshr,0 as mcd,0 as rasst,0 as st1,0 as st2,0 as regg,0 as sto,0 as stn,0 as srasst,
 0 as sto_zone,0 as stn_zone,0 as sti,0 as sti_zone,0 as d_plata,0 as d_poteri,k_bil
 from prig_cost_opis
)

select rez,IDNUM,opis,nom,marshr,mcd,rasst as rst,st1,st2,regg as reg,sto,stn,srasst,sto_zone,stn_zone,sti,sti_zone,d_plata,d_poteri,k_bil
from itog
; 
 
 


--- ввод времени окончания операции с итоговым числом записей
insert into  l3_prig.prig_times(time,date,dann,libr,oper,time2,date_zap,part_zap,shema,rezult)
with a as
(select date_zap,part_zap,dann,libr,shema,current_date as date,substr(cast(clock_timestamp()::time as char(50)),1,12) as time
	from  l3_prig.prig_times where dann='prig' and oper='dannie'),
b as (select count(*) as rezult from l3_prig.prig_work)
select time,date,dann,libr,'prig_work 2_21_rez' as oper,
(cast(substr(time,1,2) as dec(3))*60+cast(substr(time,4,2) as dec(3)))*60+cast(substr(time,7,6) as dec(7,3)) as time2,date_zap,part_zap,shema,rezult
from a, b;





-- select * from l3_prig.prig_times where part_zap in(select part_zap from l3_prig.prig_times where oper='dannie')



--   select * from  l3_prig.prig_work where rez=51


/**/






