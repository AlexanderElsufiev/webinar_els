
----- заменить одиночный апостроф на два апострофа

---- строку 'l3_prig' заменить на '||load_shema||'


--ПРОГРАММА ПЕРВИЧНОЙ ПЕРЕРАБОТКИ ДАННЫХ, НАРАБОТКА СПРАВОЧНИКА БИЛЕТВ И МАРШРУТОВ, 
--ПОЛУЧЕНИЕ ОТПРАВЛЕННЫХ ПАССАЖИРОВ ПО ДАТАМ ОТПРАВЛЕНИЯ СОКРАЩЕНИЕ ЧИСЛА ЗАПИСЕЙ БЕЗ ПОТЕРИ ИНФОРМАЦИИ

--ТОЛЬКО ПРОЦЕДУРА ОБОГАЩЕНИЯ, ТРЕТЬЯ ЧАСТЬ ОБРАБОТКИ - ОКОНЧАНИЕ ПО МАРШРУТАМ. СОЗДАНИЕ ХЭШЕЙ И ВЫЧИСЛЕНИЕ УНИКАЛЬНЫХ МАРШРУТОВ


/**/
--- ввод времени начала операции
insert into  l3_prig.prig_times(time,date,dann,libr,oper,time2,date_zap,part_zap,shema)
with a as
(select date_zap,part_zap,dann,libr,shema,current_date as date,substr(cast(current_time as char(50)),1,12) as time 
 from  l3_prig.prig_times where dann='prig' and oper='dannie')
select time,date,dann,libr,'prig_work 2_3_beg' as oper,
(cast(substr(time,1,2) as dec(3))*60+cast(substr(time,4,2) as dec(3)))*60+cast(substr(time,7,6) as dec(7,3)) as time2,date_zap,part_zap,shema
from a ;





insert into l3_prig.prig_work(
	rez,idnum,request_num,YYMM,nom_mar,nom_bil,nom_dat,sto,stn,marshr,mcd,nom,reg,otd,dcs,st1,st2,rst,sto_zone,stn_zone,sti,sti_zone,
 d_plata,d_poteri,dor,lin,srasst,k_bil,date_zap,part_zap,date_beg,date_end,date_pr,TERM_DOR,term_pos,term_trm,time_zap,server_reqnum,drac,
	agent,subagent,chp,stp,stp_reg,train_num,kol_bil,plata,poteri,perebor,kom_sbor,kom_sbor_vz )
/**/

with

dates as  --дата загружаемых данных
(select distinct date_zap,part_zap from  l3_prig.prig_times where dann='prig' and oper='dannie'),

prig_opis_mars as --роспись всех маршрутов в виде минимальных перегонов        -- 143003  7sek  --165212
(select idnum,opis,sto,stn,marshr,mcd,nom,reg,st1,st2,rst,sto_zone,stn_zone,sti,sti_zone,d_plata,d_poteri,dor,lin,otd,dcs,srasst  
from l3_prig.prig_work where rez=6) ,
 
prig_cost_opis as  --соответствия билет - номер описания  -- 176103 =4sek
(select IDNUM,k_bil,opis from l3_prig.prig_work where rez=7),

prig_opis_hash as  -- 11054 37sek 
(select IDNUM,opis, hash1||'-'||cast(hash2 as char(32)) as hash --считаем сдвоенных хэш заведомо сильным
 from
(select IDNUM,opis,hash1,sum(('x'||md5(hash2))::bit(64)::bigint) as hash2
 from 
(select IDNUM,opis,
  cast(sto as char(7))||'-'||cast(stn as char(7))||'-'||cast(srasst as char(7))||'-'||cast(sto_zone as char(7)) 
 ||'-'||cast(stn_zone as char(7)) ||'-'||cast(sti as char(7)) ||'-'||cast(sti_zone as char(7))
 ||'-'||cast(sum(d_plata) over (partition by IDNUM) as char(7))
 ||'-'||cast(sum(d_poteri) over (partition by IDNUM) as char(7))
 as hash1,
 cast(nom as char(7))||'-'||cast(st1 as char(7))||'-'||cast(st2 as char(7))||'-'||cast(rst as char(7))||'-'||cast(mcd as char(3))
 ||'-'||cast(reg as char(7))||'-'||cast(10000*dor+lin as char(7))||'-'||cast(otd as char(7))||'-'||cast(dcs as char(7))
 ||'-'||case when d_plata is null then '.' else cast(d_plata as char(7)) end 
 ||'-'||case when d_poteri is null then '.' else cast(d_poteri as char(7)) end  as hash2
from prig_opis_mars) as a group by 1,2,3) as b),

mars_opis_hash as
(select nom_mar,hash1||'-'||cast(hash2 as char(32)) as hash --считаем сдвоенных хэш заведомо сильным
 from
(select nom_mar,hash1,sum(('x'||md5(hash2))::bit(64)::bigint) as hash2
 from 
(select nom_mar,nom,
  cast(sto as char(7))||'-'||cast(stn as char(7))||'-'||cast(srasst as char(7))||'-'||cast(sto_zone as char(7)) 
 ||'-'||cast(stn_zone as char(7)) ||'-'||cast(sti as char(7)) ||'-'||cast(sti_zone as char(7))
 ||'-'||cast(sum(d_plata) over (partition by nom_mar) as char(7))
 ||'-'||cast(sum(d_poteri) over (partition by nom_mar) as char(7))
 as hash1,
 cast(nom as char(7))||'-'||cast(st1 as char(7))||'-'||cast(st2 as char(7))||'-'||cast(rst as char(7))||'-'||cast(mcd as char(3))
 ||'-'||cast(reg as char(7))||'-'||cast(10000*dor+lin as char(7))||'-'||cast(otd as char(7))||'-'||cast(dcs as char(7))
 ||'-'||case when d_plata is null then '.' else cast(d_plata as char(7)) end 
 ||'-'||case when d_poteri is null then '.' else cast(d_poteri as char(7)) end  as hash2
from l3_prig.prig_mars) as a group by 1,2) as b),

prig_opis_nom_mar as --поставить новые значения маршрутов   -- 11054 37sek 
(select opis,min(mopis) as mopis,min(is_new) as is_new,min(nom_mar) as nom_mar from -- для ускорения вместо distinct полставил min ... group by...
(select opis,mopis,is_new, 
 max(case when is_new=1 then mnom_mar+plus else nom_mar end) over(partition by mopis) as nom_mar
 from
(select opis,mopis,nom_mar,is_new,
 case when mnom_mar is null then 0 else mnom_mar end as mnom_mar,
 row_number(*) over (partition by nom_mar,is_new order by opis) as plus
 from
(select opis,mopis,nom_mar,
 case when nom_mar is null and opis=mopis then 1 else 0 end as is_new
 from
(select opis,a.hash,nom_mar,
 min(opis) over (partition by a.hash) as mopis
from prig_opis_hash as a left join mars_opis_hash as b on a.hash=b.hash
) as c) as d,(select max(nom_mar) as mnom_mar from mars_opis_hash) as e) as g) as h group by opis),

prig_opis_nom_mar_new as --поставить новые значения маршрутов   -- 11054 37sek 
(select distinct opis,nom_mar from prig_opis_nom_mar   where is_new=1),

new_mar as  -- список новых маршрутов в базу  -- 133023 37sek  --143003 42сек  --145857 8sek
(select idnum,nom_mar,sto,stn,marshr,mcd,nom,reg,otd,dcs,st1,st2,rst,sto_zone,stn_zone,sti,sti_zone,d_plata,d_poteri,dor,lin,srasst
 from prig_opis_mars as a join prig_opis_nom_mar_new as b on a.opis=b.opis),

prig_cost_opis_mar as  --соответствия билет - номер описания,=итог обогащения  -- 176103 7sek 
(select distinct IDNUM,k_bil,a.opis,nom_mar
 from prig_cost_opis as a join prig_opis_nom_mar as b on a.opis=b.opis),
  
prig_mar_bil_dat as  --соответствия билет - номер описания,=итог обогащения  -- 176103 7sek 
(select a.IDNUM,request_num,YYMM,k_bil,opis,nom_mar,nom_bil,nom_dat,TERM_DOR,term_pos,term_trm,time_zap,server_reqnum,drac,agent,subagent,chp,stp,stp_reg,train_num,
 kol_bil/k_bil as kol_bil,plata/k_bil as plata,poteri/k_bil as poteri,kom_sbor/k_bil as kom_sbor,kom_sbor_vz/k_bil as kom_sbor_vz,
 perebor,date_beg,date_end,date_pr--перебор на число групп билетов - не делится 
 from prig_cost_opis_mar as a 
 join (select distinct idnum,request_num,YYMM,nom_bil,TERM_DOR,term_pos,term_trm,time_zap,server_reqnum,drac,
	   agent,subagent,chp,stp,stp_reg,train_num,kol_bil,plata,poteri,perebor,kom_sbor,kom_sbor_vz
	   from l3_prig.prig_work where rez=3) as b
 on a.idnum=b.idnum 
join (select distinct idnum,nom_dat,date_beg,date_end,date_pr from l3_prig.prig_work where rez=4) as c
 on a.idnum=c.idnum),
 
itog as
(
 select 9 as rez,idnum,request_num,YYMM,nom_mar,nom_bil,nom_dat,0 as sto,0 as stn,0 as marshr,0 as mcd,0 as nom,0 as reg,0 as otd,0 as dcs,0 as st1,0 as st2,0 as rst,
 0 as sto_zone,0 as stn_zone,0 as sti,0 as sti_zone,0 as d_plata,0 as d_poteri,0 as dor,0 as lin,0 as srasst,k_bil,
 TERM_DOR,term_pos,term_trm,time_zap,server_reqnum,drac,agent,subagent,chp,stp,stp_reg,train_num,kol_bil,plata,poteri,perebor,kom_sbor,kom_sbor_vz,date_beg,date_end,date_pr
 from prig_mar_bil_dat
 union all
 select 8 as rez,idnum,0 as request_num,0 as YYMM,nom_mar,0 as nom_bil,0 as nom_dat,sto,stn,marshr,mcd,nom,reg,otd,dcs,st1,st2,rst,sto_zone,stn_zone,sti,sti_zone,
 d_plata,d_poteri,dor,lin,srasst,0 as k_bil,'0' as TERM_DOR, '0' as term_pos,'0' as term_trm,NULL as time_zap,NULL as server_reqnum,NULL as drac,
 0 as agent,0 as subagent,0 as chp,0 as stp,0 as stp_reg,NULL as train_num,
 0 as kol_bil,0 as plata,0 as poteri,0 as perebor,0 as kom_sbor,0 as kom_sbor_vz,NULL as date_beg,NULL as date_end,NULL as date_pr
 from new_mar 
)
  
 select rez,idnum,request_num,YYMM,nom_mar,nom_bil,nom_dat,sto,stn,marshr,mcd,nom,reg,otd,dcs,st1,st2,rst,sto_zone,stn_zone,sti,sti_zone,
 d_plata,d_poteri,dor,lin,srasst,k_bil,date_zap,part_zap,date_beg,date_end,date_pr,TERM_DOR,term_pos,term_trm,time_zap,server_reqnum,drac,
 agent,subagent,chp,stp,stp_reg,train_num,kol_bil,plata,poteri,perebor,kom_sbor,kom_sbor_vz
 from itog as a,dates as b;
  
  
 

/**/

--- ввод времени окончания операции с итоговым числом записей
insert into  l3_prig.prig_times(time,date,dann,libr,oper,time2,date_zap,part_zap,shema,rezult)
with a as
(select date_zap,part_zap,dann,libr,shema,current_date as date,substr(cast(clock_timestamp()::time as char(50)),1,12) as time 
 from  l3_prig.prig_times where dann='prig' and oper='dannie'),
b as (select count(*) as rezult from l3_prig.prig_work)
select time,date,dann,libr,'prig_work 2_3_rez' as oper,
(cast(substr(time,1,2) as dec(3))*60+cast(substr(time,4,2) as dec(3)))*60+cast(substr(time,7,6) as dec(7,3)) as time2,date_zap,part_zap,shema,rezult
from a, b;



--   select * from l3_prig.prig_times where date_zap in(select date_zap from l3_prig.prig_times where oper='dannie')



-- select * from l3_prig.prig_times where part_zap in(select part_zap from l3_prig.prig_times where oper='dannie')

/**/




