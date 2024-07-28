
--ПРОГРАММА ЧИСТО ДЛЯ ПОСТРОЕНИЯ АЛГОРИТМА ПРОГНОЗИРОВАНИЯ
--НАЧАЛЬНАЯ ДАТА УСЛОВНО '2021-10-12' - исходя из того. что есть на этот момент


--ОШИБКА - все станции СЗППК в 78 регионе!!!


/*
DROP TABLE spb_prig.prig_prognoz;
DROP TABLE spb_prig.prig_prognoz_date;
*/

/*
CREATE TABLE spb_prig.prig_prognoz
(date_progn date,date date,kst numeric,grup smallint,par_name char(10),chp smallint,reg smallint,dor smallint,
	tip char(5),param dec(11)
) TABLESPACE pg_default;
ALTER TABLE spb_prig.prig_prognoz OWNER to asul;
GRANT ALL ON TABLE spb_prig.prig_prognoz TO asul;


CREATE TABLE spb_prig.prig_prognoz_date
(date_progn date,date_beg date,date_dann date ) TABLESPACE pg_default;
ALTER TABLE spb_prig.prig_prognoz_date OWNER to asul;
GRANT ALL ON TABLE spb_prig.prig_prognoz_date TO asul;

insert into spb_prig.prig_prognoz_date(date_progn,date_beg,date_dann) values ('2021-10-01','2021-09-01','2021-10-01');


delete from spb_prig.prig_prognoz_date;
insert into spb_prig.prig_prognoz_date(date_progn,date_beg,date_dann) values ('2021-09-05','2021-08-01','2021-09-01');

--Дата, после которой считается нет данных и начинается сам прогноз
--И дата, начиная с которой реальные данные используются для прогноза (целый месяц точно, + что есть в текущем месяце).
--И дата, начиная с которой реальные данные обоих типовв записываются в прогноз (с начала ТЕКУЩЕГО месяца, =date_beg +1month)

select * from spb_prig.prig_prognoz_date;

update spb_prig.prig_prognoz_date set date_progn=date_progn+5;

select * from spb_prig.prig_prognoz_date;

*/



insert into spb_prig.prig_prognoz(date_progn,kst,date,grup,par_name,chp,reg,dor,tip,param)

with

RECURSIVE rrr AS (SELECT 0 AS i
    UNION SELECT i+1 AS i FROM rrr WHERE i < 90),

ish_0 as 
(select kst,date,date_zap,par_name,chp,reg,dor,
 case when grup in (21,22,23,24,25,26) then 21
 	when grup in (27,28,29,30,31) then 27 when grup=0 then 0 else 50 end as grup,
 	sum(param) as param  from
(select kst,date,date_zap,par_name,chp,reg,dor,
 cast(substr(cast(kod_lgt as char(4)),1,2) as dec) as grup,sum(param) as param 
 	from spb_prig.prig_agr_kst 
 	where par_name in('kol_bil','plata','poteri','sf_pas','sf_pkm' ) and chp in(23,41)
	and  date>=(select date_beg from spb_prig.prig_prognoz_date)
 	group by 1,2,3,4,5,6,7,8) as a group by 1,2,3,4,5,6,7,8) , 
 
ish as --то что мы знаем =real1, и на основе этого делаем прогнозы
(select * from ish_0 where date_zap<=(select date_progn from spb_prig.prig_prognoz_date)),
ish_real as --то чего мы не знаем, но точно будет, =real2
(select kst,date,par_name,chp,reg,dor,grup,sum(param) as param 
	from ish_0 where date_zap> (select date_progn from spb_prig.prig_prognoz_date)
	group by 1,2,3,4,5,6,7),

nreg as
(select chp,reg,dor,ROW_NUMBER() over (order by chp,reg,dor) as nreg from
(select distinct chp,reg,dor from ish) as a),

ish_r as
(select kst,date,date_zap,par_name,nreg,grup,param  
 from ish as a,nreg as b where a.chp=b.chp and a.reg=b.reg and a.dor=b.dor),
 
max_d as (select kst,nreg,max(date) as max_dt from ish_r where par_name='kol_bil' group by 1,2),
dats as (select date+i as date,i from (select min(date) as date from ish) as a,rrr),
grup as (select distinct grup from ish),
par_name as (select distinct par_name,max(date) as dt from ish group by 1),

dann_nul as
(select kst,nreg,max_dt,date,i,grup,par_name,0 as param,case when date<=max_dt then 1 else 0 end as dn
 from max_d as a,dats as b,grup as c,par_name as d
where date<=max_dt+35), 
 
dn_l as --данные за последний месяц, + будущее на 30 дней вперёд максимум - для прогнозирования! 
(select *,cast(extract(dow from date) as dec(3)) as weekd from
(select kst,nreg,date,grup,par_name,sum(param) as param,max(dn) as dn,max(i) as i  from 
(select kst,nreg,date,grup,par_name,param,1 as dn,0 as i  from ish_r 
union all
 select kst,nreg,date,grup,par_name,0 as param,dn,i  from dann_nul 
) as a group by 1,2,3,4,5) as b ),


week_0 as
(select kst,nreg,grup,weekd,par_name,sum(param) as spar,sum(dn) as dn
 from dn_l group by 1,2,3,4,5),
 
week_1 as
(select nreg,kst,grup,case when spar<1000 then 1 else 0 end as bad from
(select nreg,kst,grup,sum(spar) as spar from week_0 where par_name='kol_bil' group by 1,2,3) as a),

week_2 as
(select a.kst,a.nreg,a.grup,weekd,par_name,spar,dn,bad,
  case when spar=0 then 0 else cast(round(spar/dn) as dec(11)) end as par_week 
 from week_0 as a,week_1 as b where a.kst=b.kst and a.nreg=b.nreg and a.grup=b.grup),

week_3 as
(select nreg,grup,weekd,par_name,   --spar,dn,
 case when spar=0 then 0 
 when spar<dn then 1 --заплатка на совсем уж мизерные варианты
 else cast(round(spar/dn) as dec(11)) end as par_weekb 
 from
(select nreg,grup,weekd,par_name,sum(spar) as spar,max(dn) as dn
 from week_2 where bad=1 group by 1,2,3,4) as a),
 
week as
(select kst,nreg,grup,weekd,par_name,case when bad=0 then par_week else par_weekb end as par_week
 from
(select kst,a.nreg,a.grup,a.weekd,a.par_name,bad,par_week,par_weekb
from week_2 as a left join week_3 as b
 on a.nreg=b.nreg and a.grup=b.grup and a.weekd=b.weekd and a.par_name=b.par_name) as c),
--НАДО изменить week на случай очень малых групп билетов или станций


dn_w as
(select a.kst,a.nreg,date,i,a.grup,a.par_name,a.weekd,param,dn,par_week,
 case when param=0 then 0 else cast(round(param*10000/par_week) as dec(7)) end as dpar
 from dn_l as a left join week as b 
on a.kst=b.kst and a.grup=b.grup and a.weekd=b.weekd and a.par_name=b.par_name and a.nreg=b.nreg),

kv_f as 
(select kst,grup,par_name,
 -(p13*p22-p23*p12)/(p11*p22-p12*p12) as kk,
 (p13*p12-p23*p11)/(p11*p22-p12*p12) as mm 
from
(select kst,grup,par_name,
 sum(i*i) as p11,sum(i*1) as p12,sum(-i*dpar) as p13,
 sum(1*1) as p22,sum(-1*dpar) as p23,sum(dpar*dpar) as p33
from dn_w where dn=1 group by 1,2,3) as a),
 
prognoz as
(select kst,nreg,date,grup,par_name,--param,dn,
 case when pr_param<0 then 0 else pr_param end as progn
 from 
(select kst,nreg,date,grup,par_name,param,dn,--i,weekd,par_week,dpar,pr_dpar,
 cast(round(pr_dpar*par_week/10000) as dec(13)) as pr_param
 from 
(select a.kst,nreg,date,i,a.grup,a.par_name,weekd,param,dn,par_week,dpar,--kk,mm,
 cast(round(kk*i+mm) as dec(7)) as pr_dpar
 from dn_w as a left join kv_f as b 
on a.kst=b.kst and a.grup=b.grup and a.par_name=b.par_name) as a ) as b where dn=0),


itog as
(select * from
(select kst,date,grup,par_name,chp,reg,dor,'progn' as tip,progn as param from
(select kst,date,grup,par_name,chp,reg,dor,progn
 from prognoz as a join nreg as b on a.nreg=b.nreg) as c where progn!=0
 union all
 select kst,date,grup,par_name,chp,reg,dor,'real2' as tip,param from ish_real
union all
 select kst,date,grup,par_name,chp,reg,dor,'real1' as tip,param from ish						 	
) as d
 where date>=(select date_dann from spb_prig.prig_prognoz_date) )
 
 
select date_progn,kst,date,grup,par_name,chp,reg,dor,tip,param from itog as a,spb_prig.prig_prognoz_date as b;




update spb_prig.prig_prognoz_date set date_progn=date_progn+5;
select * from spb_prig.prig_prognoz_date;








