
--  CREATE SCHEMA l3_mes AUTHORIZATION asul;




/*  --выдача итогов на печать
 select * from l3_mes.prig_co22_t1 order by p2 ;
 select * from l3_mes.prig_co22_t2 order by p3,p4;
 select * from l3_mes.prig_co22_t3 order by p3,p4;
 select * from l3_mes.prig_co22_t4 order by p3,p4; 
 select * from l3_mes.prig_co22_t5;
 select * from l3_mes.prig_co22_t6 order by p3,p4;

*/


--select * from l3_mes.prig_co22_t1 where request_num in(  9730 , 28276      )  order by p2 ;

/*
delete from l3_mes.prig_co22_t0;
delete from l3_mes.prig_co22_t1;
delete from l3_mes.prig_co22_t2;
delete from l3_mes.prig_co22_t3;
delete from l3_mes.prig_co22_t4;
delete from l3_mes.prig_co22_t5;
delete from l3_mes.prig_co22_t6;
*/

/* СОЗДАНИЕ ТАБЛИЦ ОТЧЁТА ЦО-22	* /
DROP TABLE l3_mes.prig_co22_t0;
DROP TABLE l3_mes.prig_co22_t1;
DROP TABLE l3_mes.prig_co22_t2;
DROP TABLE l3_mes.prig_co22_t3;
DROP TABLE l3_mes.prig_co22_t4;
DROP TABLE l3_mes.prig_co22_t5;
DROP TABLE l3_mes.prig_co22_t6;



-------------------------------

CREATE TABLE l3_mes.prig_co22_t0
(yymm dec(7),idnum bigint,request_num dec(7),date_zap date,
 p1 char(4),p2 integer,p3 char(4),p4 char(2),p5 char(3),p6 char(3),p7 char(3),p8 char(9),p9 char(9),p10 char(2),
 p11 char(5),p12 char(4),p13 char(3),p14 char(2),p15 char(7),p16 char(2),p17 char(5),p18 char(3),p19 char(1),p20 char(2),
 p21 char(1),p22 char(1),p23 char(1),p24 char(4),p25 char(1),p26 char(2),p27 char(3),p28 char(2),p29 char(2),p30 char(5),
 p31 char(3),p32 smallint,p33 dec(9),p34 dec(11),p35 dec(11),p36 dec(11),p37 dec(11),p38 dec(11),p39 dec(11),p40 dec(11),
 p41 dec(11),p42 dec(11),p43 dec(11),p44 dec(11),p45 dec(11),p46 dec(11),p47 dec(11),p48 dec(11),p49 dec(11),p50 dec(11),
 p51 dec(9),p52 char(1),p53 char(4),p54 char(7),p55 char(1),p56 char(3),p57 char(1),p58 char(1),p59 char(1),p60 char(3),
 p61 char(1),p62 smallint,p63 char(1),
 d1 smallint,d2 smallint,d3 smallint,d4 smallint,d5 smallint,d6 char(5),d7 smallint
) TABLESPACE pg_default;
ALTER TABLE l3_mes.prig_co22_t0 OWNER to asul;
GRANT ALL ON TABLE l3_mes.prig_co22_t0 TO asul;

-------------------------------
CREATE TABLE l3_mes.prig_co22_t1
(yymm dec(7),request_num dec(7),date_zap date,
 p1 char(4),p2 integer,p3 char(4), p4 char(2),p5 char(3),p6 char(3),p7 char(3),p8 char(9),p9 char(9),p10 char(2),
 p11 char(5),p12 char(4),p13 char(3),p14 char(2),p15 char(7),p16 char(2),p17 char(5),p18 char(3),p19 char(1),p20 char(2),
 p21 char(1),p22 char(1),p23 char(1),p24 char(4),p25 char(1),p26 char(2),p27 char(3),p28 char(2),p29 char(2),p30 char(5),
 p31 char(3),p32 smallint,p33 dec(9),p34 dec(11),p35 dec(11),p36 dec(11),p37 dec(11),p38 dec(11),p39 dec(11),p40 dec(11),
 p41 dec(11),p42 dec(11),p43 dec(11),p44 dec(11),p45 dec(11),p46 dec(11),p47 dec(11),p48 dec(11),p49 dec(11),p50 dec(11),
 p51 dec(9),p52 char(1),p53 char(4),p54 char(7),p55 char(1),p56 char(3),p57 char(1),p58 char(1),p59 char(1),p60 char(3),
 p61 char(1),p62 smallint,p63 char(1),idnum bigint
) TABLESPACE pg_default;
ALTER TABLE l3_mes.prig_co22_t1 OWNER to asul;
GRANT ALL ON TABLE l3_mes.prig_co22_t1 TO asul;

-----------------------------
CREATE TABLE l3_mes.prig_co22_t2
(yymm dec(7),p1 char(4),p2 char(3),p3 integer,p4 smallint,p5 char(3),p6 char(2),p7 smallint
) TABLESPACE pg_default;
ALTER TABLE l3_mes.prig_co22_t2 OWNER to asul;
GRANT ALL ON TABLE l3_mes.prig_co22_t2 TO asul;


------------------------------
CREATE TABLE l3_mes.prig_co22_t3
(yymm dec(7),p1 char(4),p2 char(3),p3 integer,p4 smallint,p5 char(2),p6 char(5),p7 smallint
) TABLESPACE pg_default;
ALTER TABLE l3_mes.prig_co22_t3 OWNER to asul;
GRANT ALL ON TABLE l3_mes.prig_co22_t3 TO asul;


------------------------------
CREATE TABLE l3_mes.prig_co22_t4
(yymm dec(7),p1 char(4),p2 char(3),p3 integer,p4 smallint,p5 char(3),p6 char(5),p7 dec(11),p8 dec(11), p9 smallint
) TABLESPACE pg_default;
ALTER TABLE l3_mes.prig_co22_t4 OWNER to asul;
GRANT ALL ON TABLE l3_mes.prig_co22_t4 TO asul;


------------------------------
CREATE TABLE l3_mes.prig_co22_t5
(yymm dec(7),p1 char(4),p2 char(3),p3 integer,p4 integer,p5 integer,p6 dec(13),p7 dec(15),p8 dec(15),p9 dec(15),p10 dec(15)
) TABLESPACE pg_default;
ALTER TABLE l3_mes.prig_co22_t5 OWNER to asul;
GRANT ALL ON TABLE l3_mes.prig_co22_t5 TO asul;


------------------------------
CREATE TABLE l3_mes.prig_co22_t6
(yymm dec(7),p1 char(4),p2 char(3),p3 integer,p4 smallint,p5 char(2),p6 integer,p7 smallint
) TABLESPACE pg_default;
ALTER TABLE l3_mes.prig_co22_t6 OWNER to asul;
GRANT ALL ON TABLE l3_mes.prig_co22_t6 TO asul;


/ **/



/**/
---------Понять какие данные принципиално надо читать

select * from l3_mes.prig_times where oper='read' and dann='prig' and itog is null order by date_zap


select yymm,count(*),max(date_zap) from l3_mes.prig_itog group by 1 order by 1

2208	6	"2022-08-04"
2209	10	"2022-09-20"
2210	28	"2022-10-28"
2211	19	"2022-11-29"
2301	196837	"2023-02-02"
2302	1424188	"2023-02-25"


select  yyyymm,sum(rezult),max(date_zap) from l3_mes.prig_times where oper='read' and dann='prig' and itog is null group by 1 order by 1

202207	3	"2022-07-14"
202208	36	"2022-08-26"
202209	101	"2022-09-27"
202210	135	"2022-10-28"
202211	26	"2022-11-29"
202212	65	"2022-12-28"
202301	540307	"2023-02-02"
202302	3354680	"2023-02-27"



select  * from l3_mes.prig_times where oper='read' and dann='prig' and itog is null and yyyymm=202212


insert into l3_mes.prig_times(date,dann,oper,yyyymm,rezult)
select current_date,'prig' as dann,'co22' as oper,202212 as yyyymm,0 as rezult


with
yymm as (select max(yyyymm) as yymm from l3_mes.prig_times where oper='co-22' and dann='prig' and itog is null),
rd as (select min(yyyymm) as yymm1,max(yyyymm) as yymm2
	   from l3_mes.prig_times where oper='read' and dann='prig' and itog is null and yyyymm> (select coalesce(yymm,0) from yymm))
--select * from rd 
select yymm1 from rd where yymm1<yymm2
--select coalesce(yymm,0) from yymm





/**/

-----ЗАГРУЗКА ОБЩАЯ ДАННЫЕ ВСЕХ ТАБЛИЦ
--- ТАБЛИЦА 1
insert into l3_mes.prig_co22_t0 
(yymm,idnum,date_zap,request_num,
p1,p2,p3,p4,p5,p6,p7,p8,p9,p10,p11,p12,p13,p14,p15,p16,p17,p18,p19,p20,
p21,p22,p23,p24,p25,p26,p27,p28,p29,p30,p31,p32,p33,p34,p35,p36,p37,p38,p39,p40,								 
p41,p42,p43,p44,p45,p46,p47,p48,p49,p50,p51,p52,p53,p54,p55,p56,p57,p58,p59,p60,p61,p62,p63,
d1,d2,d3,d4,d5,d6,d7)
/**/



WITH

prig as
(select row_number() over (order by idnum,nom_bil) as nom_str,idnum,request_num,
 --case when request_num>0 then date_zap end as date_zap,
 date_zap,
 yymm,kol_bil,k_bil,nom_mar,nom_bil,nom_dat,date_beg,date_pr,term_dor,agent,subagent,chp,stp,stp_reg,plata,poteri,kom_sbor
 from l3_mes.prig_itog --where --date_zap>='2023-03-15'  --'2023-01-01'  --'2023-02-20'  --'2022-11-29' -- '2023-01-23'             --'2023-01-23'     --'2022-11-29' --  '2022-10-11'  '2022-10-04' 
 		where yymm=2304
 --and request_num=9985
-- id=  436999204    --438908228 --or date_zap='2023-02-04' 
 --date_zap='2023-02-11'  -- исходно=5791 записей
 --date_zap='2023-02-06'  -- оставлен номера запросов
),   
	   
	   

dates as(select max(date_zap) as date_zap from prig),
stan as (select cast(stan as dec(7)) as kst,nopr 
 from nsi.stanv as a,dates as b where date_zap between datand and datakd and date_zap between datani and dataki),

dat1 as
(select distinct date_pr,date_beg,nom_dat from prig),

dat2 as
/*(select *,extract(year from date_pr) as yy_pr,extract(month from date_pr) as mon_pr
 ,extract(year from date_otpr) as yy_otpr,extract(month from date_otpr) as mon_otpr
 from*/
(select date_pr,date_beg,a.nom_dat,plus_dat,kpas_day,date_beg+plus_dat as date_otpr
 from dat1 as a, l3_mes.prig_dats as b where a.nom_dat=b.nom_dat and kpas_day!=0), -- as a),
 
dat3 as 
(select *,cast(extract(year from date_pr) as dec(5)) as yy_pr,cast(extract(month from date_pr) as dec(5)) as mon_pr
 from
(select  date_pr,date_beg,nom_dat,yy,mon,sum(kbil) as kbil,sum(kpas_day) as kpas_day from 
(select  date_pr,date_beg,nom_dat,extract(year from date_otpr) as yy,extract(month from date_otpr) as mon,0 as kbil,kpas_day from dat2
 union all
 select  date_pr,date_beg,nom_dat,extract(year from date_pr) as yy,extract(month from date_pr) as mon,1 as kbil,0 as kpas_day from dat1) as a
group by 1,2,3,4,5) as  b),



dor as (select nomd3 as dor3,kodd,vc from nsi.dor as a,dates as b where date_zap between datan and datak),
dor2 as
(select a.dor3,a.kodd,a.vc,b.dor3 as dor_vc from dor as a,dor as  b where a.vc=b.kodd),



prig1 as
(select nom_str,idnum,request_num,
 case when request_num>0 then date_zap end as date_zap,
 yymm,kol_bil,k_bil,nom_mar,nom_bil,nom_dat,date_beg,date_pr,term_dor,agent,subagent,chp,stp,stp_reg,plata,poteri,kom_sbor,
 dor3,dor_vc
 from prig as a join dor2 on term_dor=kodd),   


OKATO AS
(select cast(sf_kod2 as dec(3)) as sf_reg,sf_kodokato as okato from nsi.sf
where sf_dataki='2100-01-01' and  sf_datak='2100-01-01'),

mar1 as
(select max(nom) over(partition by nom_mar) as max_nom,*
 from l3_mes.prig_mars where nom_mar in (select distinct nom_mar from prig)),
 
mar2 as
 (select nom_mar,max_nom,sto,stn,srasst,
 sum(case when nom=1 then dor else 0 end) as sto_dor,
 sum(case when nom=max_nom then dor else 0 end) as stn_dor,
 sum(case when nom=1 then otd else 0 end) as sto_otd,
 sum(case when nom=max_nom then otd else 0 end) as stn_otd,
 sum(case when nom=1 then reg else 0 end) as sto_reg,
 sum(case when nom=max_nom then reg else 0 end) as stn_reg,
 max(mcd) as mcd,sum(case when mcd>0 then rst else 0 end) as mcd_rst,
 sum(case when nom=1 and mcd>0 then 1 else 0 end) as mcd_1,
 sum(case when nom=max_nom and mcd>0 then 1 else 0 end) as mcd_2
 from mar1 group by 1,2,3,4,5),
 
mar as
 (select nom_mar,max_nom,sto,stn,srasst,sto_dor,stn_dor,sto_reg,stn_reg,mcd_rst,mcd_1,mcd_2,  
  to_char(sto_otd,'fm00') as sto_otd,to_char(stn_otd,'fm00') as stn_otd,
  case when mcd=0 then 0 else (4-2*mcd_2-mcd_1) end as mcd_vid,mcd,
  b.okato as sto_okato,c.okato as stn_okato,d.nopr as sto_nopr,e.nopr as stn_nopr
 from mar2 join okato as b on sto_reg=b.sf_reg  join okato as c on stn_reg=c.sf_reg
 join stan as d on sto=d.kst join stan as e on stn=e.kst
 ),
 
bil as
(select *, 
 case 
 when flg_bil_sbor='S' then '8' --сбор за оплату в поезде
 when flg_bag='1' then '6' --перевозоыный документ для багажа, впрос с 7=грузобагаж
 when prod in('i','m') then '1' --интернет продажа 800-х АМГХИЙ
 when abonement_type='0' and flg_tuda_obr='2' then '3'
 when abonement_type='0' and flg_tuda_obr='1' then '2'
 when flg_rab_day='1' then '4' --абонементы выходные
 when flg_bag='0' then '5' --все прочие абонементы
 else '0' end as vid_bil, 
 
 case 
 --when flg_bsp='1' then '4' -- признак бесплатные, отменён - их больше нет, это льготные.
 when flg_child='1' then '2'
 when kod_lgt=0 then '1' else '3' end as prizn_pas,
 '3' as tarif, --1=зонный 2=покилометровый 3=общий
 --PAYMENTTYPE as vid_rasch, --вид расчёта (=1,6,8)=(' ','П','Э')
 
case
 --От Корзун - (vid_rasch=1-6) разные расчёты в кассе, =(7-9) разные  электронные кошельки
 --PAYMENTTYPE as vid_rasch, --вид расчёта (=1,6,8)=(' ','П','Э') = (Наличка, Платёжные поручения, Электронное=банковские карты)
when kod_lgt>0 then '1' --все виды льготных
when prod='i' then '4' --Продажа ИНТЕРНЕТ, из базы пассажирских перевозок == третья буква серии бланка =И
when vid_rasch='1' and web_id not in('0000','-1','NULL') then '6' --если непустой ID эл.площадки, и Наличка - то Электронный кошелёк
--when /*vid_rasch='8' and*/ web_id not in('0000','-1','NULL') then '3' --если непустой ID эл.площадки, и НЕ Наличка, то это банковская карта (='3')
when vid_rasch='8' and web_id in('0000','-1','NULL') then '3' --если пустой ID эл.площадки, и НЕ Наличка, то это банковская карта (='3')
when vid_rasch='8' and web_id not in('0000','-1','NULL') then '6' --Электронный кошелёк
when vid_rasch='6' then '5' --если Платёжные поручения, то 5=ЕШ
else '2'
end as vid_rasch2, --вид расчёта
 '?' AS flg_otch,
 
case when flg_ruch='0' then '1'
when tsite is not null then cast(cast(tsite as smallint) as char(1))
when request_subtype in(10,20,25) then '4'
when request_type!=64 and request_subtype>=200 and request_subtype<=299 then '2' --64=Экспресс, из прочих 2**-е = АСОКУПЕ-Л
else '5' end as vid_oforml,
 
case 
 when ABONEMENT_TYPE='1' then '4'||cast(k_pas*2 as char(2)) --эта строка должнабыть ПЕРВОЙ
 when srok_mon>0 and srok_mon<10 then '00'||cast(srok_mon as char(1))
 when srok_mon>9 then '0'||cast(srok_mon as char(12))
 
 when ABONEMENT_TYPE>'1' and srok_bil<10 then '10'||cast(srok_bil as char(2))
 when ABONEMENT_TYPE>'1' then '1'||cast(srok_bil as char(2))
 else '000' end as srok_abon,
 
 case
 when bag_vid='Ж' then '1' -- живность
 when bag_vid='Т' then '2' -- телевизор
 when bag_vid='В' then '3' --велосипед
 when bag_vid='Р' and bag_ves>36 then '4' -- ручная кладь  излишний вес (свыше 36 кило).
 when bag_vid='Р' then '4' -- ручная кладь НЕ излишний вес. Вместо 0 всё равно пишем 4
 else  bag_vid end as bag_vid_,
 
 --ABONEMENT_SUBTYPE = Подтип абонемента на кокретные даты (1- на нечет.дни, 2 - на четн.дни) 
 case when ABONEMENT_TYPE='3' then '1' --абонемент ежедневно
 when ABONEMENT_TYPE in('5','6') then '2' --выходного дня
  when ABONEMENT_TYPE in('7','8') then '3' --рабочего дня
 when ABONEMENT_TYPE='4' then '1' --абонемент Ежедневно - вообще-то это абонмено на 5-25 дней на 5-20 поездок
 when ABONEMENT_TYPE='1' then '5' -- на 10-20-60-90 поездок
 when ABONEMENT_TYPE='2' and ABONEMENT_SUBTYPE='1' then '6' --абонемент на определённые нечётные даты
 when ABONEMENT_TYPE='2' and ABONEMENT_SUBTYPE='2' then '7' --абонемент на определённые чётные даты
 when ABONEMENT_TYPE='2' then '4' --абонемент на определённые даты
 else ABONEMENT_TYPE end as abonement_tip,
 
 --case when flg_so='1' or flg_tt='1' then '1' else '0' end  as flg_zd_fpk
case when rzd_fpk='5' then '1' else '0' end as flg_zd_fpk,
 
case when employee_cat in('Ф','Д') then 1 else 0 end as flg_zd_fpk_f 
--case when FLG_OFFICIAL_BENEFIT in ('Д','Ф') then '1' else FLG_OFFICIAL_BENEFIT end as flg_zd_fpk_f
  
 from l3_mes.prig_bil as a left join nsi.site as b on a.web_id=b.idsite and current_date between datan and datak 
),
 
/*
prig2 as
(select row_number() over (order by id,doc_num) as nom_str,id,doc_num,request_num,--flg_bil_sbor,--flg_fee_onboard,
 yymm,kol_bil,k_bil,nom_mar,nom_bil,nom_dat,date_zap,date_beg,date_pr,term_dor,agent,subagent,chp,stp,stp_reg,plata,poteri,kom_sbor
 from prig --as a,bil as b where a.nom_bil=b.nom_bil
),
 */
 
itog1 as
(select a.yymm,a.date_zap,
 a.idnum,request_num,a.nom_mar,
'tab1' as tab_1,nom_str as nom_str_2,
yy_pr as year_3,mon_pr as month_4,
dor_vc as kod_vc_5,dor3 as kod_dor_pr_6,dor3 as kod_dor_of_7,
stp as stp_8,chp as chp_9,stp_reg as stp_reg_10, --10
b.okato as stp_okato_11,
substr(cast(yy as char(4)),3,2)||
 case when mon>9 then cast(mon as char(2)) else '0'||cast(mon as char(2)) end as dt_otp_12,
sto_dor as sto_dor_13,sto_otd as sto_otd_14,sto as sto_15,sto_reg as sto_reg_16,sto_okato as sto_oksto_17,sto_nopr as sto_nopr_18,

case --вариант "О" - без проверки/ О - это обычная пригородная электричка.
 when train_category='С' then '6'
 when train_category='7' then '5'
 when train_category='А' then '8'
 when train_category='Г' then '9'
 when train_category='Л' then 'Л'
 when train_category='Б' then '7'
 when train_category in('1','М') then '4'
 when prod in('i','m') then '4' --если из базы данных ппассажирской (интернет или местные поезда) то с местами
 else '1' end as kateg_pzd_19,--иначе обычные без мест

substr(klass,1,1) as klass_20, --20
vid_bil as vid_bil_21,
 prizn_pas as prizn_pas_22,tarif as tarif_23,kod_lgt as kod_lgt_24,
--web_id,vid_rasch,
vid_rasch2 as vid_rasch_25,flg_otch as flg_otch_26, --26
stn_dor as stn_dor_27,stn_otd as stn_otd_28,stn_reg as stn_reg_29,stn_okato as stn_okato_30,stn_nopr as stn_nopr_31, --31
srasst as srasst_32,
 
/*k_bil* */kol_bil*(case when flg_bag='1' then bag_ves else kpas_day end) as kol_pas_33, 
0 as sum_34,0 as sum_35,
/*k_bil* */(plata*kbil+kom_sbor) as plata_36,0 as sum_37,0 as sum_38,0 as sum_39,0 as sum_40,0 as sum_41,0 as sum_42,0 as sum_43,
/*k_bil* */poteri*kbil as poteri_44,0 as sum_45,0 as sum_46,0 as sum_47,0 as sum_48,0 as sum_49,0 as sum_50,
/*k_bil* */kol_bil*kbil as kol_bil_51,--kol_bil,kbil, -- 51
vid_oforml as vid_oforml_52, --tsite,request_subtype,web_id,--52
agent as agent_53,stn as stn_54,--54
abonement_tip as abonement_tip_55,--ABONEMENT_TYPE,srok_bil,srok_mon,--SEATSTICK_LIMIT,
srok_abon as srok_abon_56,
bag_vid_ as bag_vid_57,
flg_zd_fpk as flg_zd_fpk_58, --58
flg_zd_fpk_f as flg_zd_fpk_f_59,
subagent as subagent_60,
 --train_num,
 mcd as mcd_61,mcd_rst as mcd_rst_62,mcd_vid as mcd_vid_63--,* --63


from prig1 as a join okato as b on a.stp_reg=b.sf_reg
join mar as c on a.nom_mar=c.nom_mar
join bil as d on a.nom_bil=d.nom_bil 
 join dat3 as f on a.date_pr=f.date_pr and a.date_beg=f.date_beg and a.nom_dat=f.nom_dat
),





itog2_0 as --вводится нумерация групп данных, ещё несквозная, с большими пробелами
(select yymm,idnum,request_num,date_zap,nom_mar,tab_1,--row_number() over (order by nom_str_2_) as nom_str_2, 
 row_number() over (order by request_num,date_zap,year_3,month_4,kod_vc_5,kod_dor_pr_6,kod_dor_of_7,stp_8,chp_9,stp_reg_10,
 stp_okato_11,sto_dor_13,sto_otd_14,sto_15,sto_reg_16,sto_oksto_17,sto_nopr_18,kateg_pzd_19,klass_20, 
 vid_bil_21,prizn_pas_22,tarif_23,kod_lgt_24,vid_rasch_25,flg_otch_26,stn_dor_27,stn_otd_28,stn_reg_29,stn_okato_30,
 stn_nopr_31,srasst_32,
 vid_oforml_52,agent_53,stn_54,abonement_tip_55,srok_abon_56,bag_vid_57,
 flg_zd_fpk_58,flg_zd_fpk_f_59,subagent_60,mcd_61,mcd_rst_62,mcd_vid_63,dt_otp_12) +1-
 
  row_number() over (partition by request_num,date_zap,year_3,month_4,kod_vc_5,kod_dor_pr_6,kod_dor_of_7,stp_8,chp_9,stp_reg_10,
 stp_okato_11,sto_dor_13,sto_otd_14,sto_15,sto_reg_16,sto_oksto_17,sto_nopr_18,kateg_pzd_19,klass_20, 
 vid_bil_21,prizn_pas_22,tarif_23,kod_lgt_24,vid_rasch_25,flg_otch_26,stn_dor_27,stn_otd_28,stn_reg_29,stn_okato_30,
 stn_nopr_31,srasst_32,
 vid_oforml_52,agent_53,stn_54,abonement_tip_55,srok_abon_56,bag_vid_57,
 flg_zd_fpk_58,flg_zd_fpk_f_59,subagent_60,mcd_61,mcd_rst_62,mcd_vid_63 order by dt_otp_12) as nom_str_z2,
 
 year_3,month_4,kod_vc_5,kod_dor_pr_6,kod_dor_of_7,stp_8,chp_9,stp_reg_10,
 stp_okato_11,dt_otp_12,sto_dor_13,sto_otd_14,sto_15,sto_reg_16,sto_oksto_17,sto_nopr_18,kateg_pzd_19,klass_20, 
 vid_bil_21,prizn_pas_22,tarif_23,kod_lgt_24,vid_rasch_25,flg_otch_26,stn_dor_27,stn_otd_28,stn_reg_29,stn_okato_30,
 stn_nopr_31,srasst_32,
 kol_pas_33,sum_34,sum_35,plata_36,sum_37,sum_38,sum_39,sum_40,sum_41,sum_42,sum_43,poteri_44,sum_45,sum_46,sum_47,sum_48,sum_49,sum_50,kol_bil_51, 
 vid_oforml_52,agent_53,stn_54,abonement_tip_55,srok_abon_56,bag_vid_57,
 flg_zd_fpk_58,flg_zd_fpk_f_59,subagent_60,mcd_61,mcd_rst_62,mcd_vid_63 
 from --- внутри идёт подсуммирование
(select yymm,request_num,date_zap,nom_mar,
 tab_1,year_3,month_4,kod_vc_5,kod_dor_pr_6,kod_dor_of_7,stp_8,chp_9,stp_reg_10,
 stp_okato_11,dt_otp_12,sto_dor_13,sto_otd_14,sto_15,sto_reg_16,sto_oksto_17,sto_nopr_18,kateg_pzd_19,klass_20, 
 vid_bil_21,prizn_pas_22,tarif_23,kod_lgt_24,vid_rasch_25,flg_otch_26,stn_dor_27,stn_otd_28,stn_reg_29,stn_okato_30,
 stn_nopr_31,srasst_32,vid_oforml_52,agent_53,stn_54,abonement_tip_55,srok_abon_56,bag_vid_57,
 flg_zd_fpk_58,flg_zd_fpk_f_59,subagent_60,mcd_61,mcd_rst_62,mcd_vid_63,  
 min(idnum) as idnum,min(nom_str_2) as nom_str_2_,
 sum(kol_pas_33) as kol_pas_33,sum(sum_34) as sum_34,sum(sum_35) as sum_35,
 sum(plata_36) as plata_36,sum(sum_37) as sum_37,sum(sum_38) as sum_38,sum(sum_39) as sum_39,sum(sum_40) as sum_40,
 sum(sum_41) as sum_41,sum(sum_42) as sum_42,sum(sum_43) as sum_43,sum(poteri_44) as poteri_44,sum(sum_45) as sum_45,
 sum(sum_46) as sum_46,sum(sum_47) as sum_47,sum(sum_48) as sum_48,sum(sum_49) as sum_49,sum(sum_50) as sum_50,
 sum(kol_bil_51) as kol_bil_51--,count(*) as kol
from itog1 group by yymm,request_num,date_zap,nom_mar,
 tab_1,year_3,month_4,kod_vc_5,kod_dor_pr_6,kod_dor_of_7,stp_8,chp_9,stp_reg_10,
 stp_okato_11,dt_otp_12,sto_dor_13,sto_otd_14,sto_15,sto_reg_16,sto_oksto_17,sto_nopr_18,kateg_pzd_19,klass_20, 
 vid_bil_21,prizn_pas_22,tarif_23,kod_lgt_24,vid_rasch_25,flg_otch_26,stn_dor_27,stn_otd_28,stn_reg_29,stn_okato_30,
 stn_nopr_31,srasst_32,vid_oforml_52,agent_53,stn_54,abonement_tip_55,srok_abon_56,bag_vid_57,
 flg_zd_fpk_58,flg_zd_fpk_f_59,subagent_60,mcd_61,mcd_rst_62,mcd_vid_63
) as a),

itog2 as --Нумерация делается сквозной, без пробелов
(select yymm,idnum,date_zap,request_num,nom_mar,tab_1,nom_str_2,  
 year_3,month_4,kod_vc_5,kod_dor_pr_6,kod_dor_of_7,stp_8,chp_9,stp_reg_10,
 stp_okato_11,dt_otp_12,sto_dor_13,sto_otd_14,sto_15,sto_reg_16,sto_oksto_17,sto_nopr_18,kateg_pzd_19,klass_20, 
 vid_bil_21,prizn_pas_22,tarif_23,kod_lgt_24,vid_rasch_25,flg_otch_26,stn_dor_27,stn_otd_28,stn_reg_29,stn_okato_30,
 stn_nopr_31,srasst_32,
 kol_pas_33,sum_34,sum_35,plata_36,sum_37,sum_38,sum_39,sum_40,sum_41,sum_42,sum_43,poteri_44,sum_45,sum_46,sum_47,sum_48,sum_49,sum_50,kol_bil_51, 
 vid_oforml_52,agent_53,stn_54,abonement_tip_55,srok_abon_56,bag_vid_57,
 flg_zd_fpk_58,flg_zd_fpk_f_59,subagent_60,mcd_61,mcd_rst_62,mcd_vid_63 
 from
(select nom_str_z2,row_number() over (order by date_zap,request_num,nom_str_z2) as nom_str_2 from
(select distinct date_zap,request_num,nom_str_z2 from itog2_0) as a) as b 
 join itog2_0 as c on b.nom_str_z2=c.nom_str_z2),



mar_otd as
(select nom_mar,nnom,dor,otd,sum(rst) as rst from 
(select nom_mar,nom,dor,otd,rst,plus,
 sum(plus)over (partition by nom_mar order by nom) as nnom
 from 
(select a.nom_mar,a.nom,a.dor,a.otd,a.rst,
 case when a.dor=b.dor and a.otd=b.otd then 0 else 1 end as plus,
 case when b.nom is not null then 1 else 0 end as pluss
 from mar1 as a left join mar1 as b 
on a.nom_mar=b.nom_mar and a.nom=b.nom+1
 order by nom
)  as c) as d group by nom_mar,nnom,dor,otd),


itog_mar_otd as
(select distinct yymm,'tab2' as tab_1,kod_vc_5 as kod_vc_2,nom_str_2 as nom_str_3,nnom as nom_4,dor as dor_5,otd as otd_6,rst as rst_7
 from itog2 as a left join mar_otd as b on a.nom_mar=b.nom_mar
 --join dor as e on term_dor=kodd
), 
 
 
mar_reg as
(select nom_mar,nnom,reg,sum(rst) as rst from 
(select nom_mar,nom,reg,rst,plus,
 1+sum(plus)over (partition by nom_mar order by nom) as nnom
 from 
(select a.nom_mar,a.nom,a.reg,a.rst,
 case when b.nom is not null then 1 else 0 end as plus
 from mar1 as a left join mar1 as b 
on a.nom_mar=b.nom_mar and a.nom=b.nom+1 and (a.reg!=b.reg)
) as c) as d group by nom_mar,nnom,reg),


itog_mar_reg as
(select distinct yymm,'tab3' as tab_1,kod_vc_5 as kod_vc_2,nom_str_2 as nom_str_3,nnom as nom_4,reg as reg_5,okato as okato_6,rst as rst_7
 from itog2 as a join mar_reg as b on a.nom_mar=b.nom_mar
 --join dor as c on term_dor=kodd
join okato  as d on b.reg=sf_reg ),




mar_dcs as
(select nom_mar,nnom,dor,dcs,sum(rst) as rst from 
(select nom_mar,nom,dor,dcs,rst,plus,
 sum(plus)over (partition by nom_mar order by nom) as nnom
 from 
(select a.nom_mar,a.nom,a.dor,a.dcs,a.rst,
 case when a.dor=b.dor and a.dcs=b.dcs then 0 else 1 end as plus,
 case when b.nom is not null then 1 else 0 end as pluss
 from mar1 as a left join mar1 as b 
on a.nom_mar=b.nom_mar and a.nom=b.nom+1
 order by nom
)  as c) as d group by nom_mar,nnom,dor,dcs),


itog_mar_dcs as
(select distinct yymm,'tab6' as tab_1,kod_vc_5 as kod_vc_2,nom_str_2 as nom_str_3,nnom as nom_4,dor as dor_5,dcs as dcs_6,rst as rst_7
 from itog2 as a join mar_dcs as b on a.nom_mar=b.nom_mar
 --join dor as e on term_dor=kodd
),

mar_nomera as
(select nom_mar,nom,reg,dor,otd,rst,d_plata,d_poteri,
 sum(plus_otd) over(partition by nom_mar order by nom) as nom_otd,
 sum(plus_reg) over(partition by nom_mar order by nom) as nom_reg,
 sum(plus_pl) over(partition by nom_mar order by nom) as nom_pl,
 sum(plus_pl_reg) over(partition by nom_mar order by nom) as nom_plat
 from
(select a.nom_mar,a.nom,a.reg,a.dor,a.otd,a.rst,a.d_plata,a.d_poteri,
 case when a.dor=b.dor and a.otd=b.otd then 0 else 1 end as plus_otd,
 case when a.reg=b.reg then 0 else 1 end as plus_reg,
 case when b.d_plata is not null or b.nom is null then 1 else 0 end as plus_pl,
 case when b.d_plata is not null --or b.nom is null 
 	or a.reg!=b.reg or a.dor!=b.dor or a.nom=1 then 1 else 0 end as plus_pl_reg 
 from mar1 as a left join mar1 as b on a.nom_mar=b.nom_mar and a.nom=b.nom+1) as c),
 
mar_pl as
 (select nom_mar,nom_plat,nom_pl,nom_reg,reg,dor,rst,okato,--d_plata,d_poteri,
  sum(rst) over (partition by nom_mar,nom_pl order by nom_plat) as s_rst,
  sum(rst) over (partition by nom_mar,nom_pl) as p_rst,  
  sum(d_plata) over (partition by nom_mar,nom_pl) as sd_plata,
  sum(d_plata) over (partition by nom_mar) as s_plata,
  sum(d_poteri) over (partition by nom_mar,nom_pl) as sd_poteri,
  sum(d_poteri) over (partition by nom_mar) as s_poteri
  from 
 (select nom_mar,nom_plat,nom_pl,nom_reg,reg,dor,sum(rst) as rst,sum(d_plata) as d_plata,sum(d_poteri) as d_poteri
  from mar_nomera group by nom_mar,nom_plat,nom_pl,nom_reg,reg,dor) as a,okato as b where reg=sf_reg),
  
itog_plat_ as --разбивка денег точная по каждому билету
  (select nom_mar,nom_reg,dor_vc,nom_str,dor,okato,plata,poteri,--nom_plat,
   sum(dd_plata) as d_plata,sum(dd_poteri) as d_poteri,sum(rst) as rst
   from 
  (select *,
  k_bil*(round(d_plata*s_rst/p_rst)-round(d_plata*(s_rst-rst)/p_rst)) as dd_plata,
  k_bil*(round(d_poteri*s_rst/p_rst)-round(d_poteri*(s_rst-rst)/p_rst)) as dd_poteri
  from
  (select nom_str,term_dor,dor_vc,k_bil,a.nom_mar,nom_plat,nom_pl,nom_reg,reg,dor,okato,rst,sd_plata,s_plata,sd_poteri,s_poteri,s_rst,p_rst,plata,poteri,
   round(plata*sd_plata/(k_bil*s_plata)) as d_plata,round(poteri*sd_poteri/(k_bil*s_poteri)) as d_poteri
  from prig1 as a join mar_pl as b on a.nom_mar=b.nom_mar
  ) as b) as c --left join dor as d on term_dor=kodd
  group by nom_mar,nom_reg,dor_vc,nom_str,dor,okato,plata,poteri
  ),



itog2_plat_ as  --разбивка денег ПРИБЛИЖЁННАЯ!!!
  (select yymm,nom_mar,nom_reg,kod_vc_2,nom_str_3,dor,okato,--plata,poteri,--nom_plat,
   sum(dd_plata) as d_plata,sum(dd_poteri) as d_poteri,sum(rst) as rst
   from 
  (select *,
  (round(d_plata*s_rst/p_rst)-round(d_plata*(s_rst-rst)/p_rst)) as dd_plata,
  (round(d_poteri*s_rst/p_rst)-round(d_poteri*(s_rst-rst)/p_rst)) as dd_poteri
  from
  (select yymm,nom_str_2 as nom_str_3,kod_vc_5 as kod_vc_2,a.nom_mar,nom_plat,nom_pl,nom_reg,reg,dor,okato,rst,sd_plata,s_plata,sd_poteri,s_poteri,s_rst,p_rst,--plata,poteri,
   round(plata_36*sd_plata/(s_plata)) as d_plata,round(poteri_44*sd_poteri/(s_poteri)) as d_poteri
  from itog2 as a join mar_pl as b on a.nom_mar=b.nom_mar
  ) as b) as c 
  group by yymm,nom_mar,nom_reg,kod_vc_2,nom_str_3,dor,okato--,plata,poteri
  ),


itog_plat as
  (select yymm,'tab4' as tab_1,kod_vc_2,nom_str_3,nom_reg as nom_4,dor as dor_5,okato as okato_6,
   d_plata as d_plata_7,d_poteri as d_poteri_8,rst as rst_9
   from  itog2_plat_),


itog_5 as
(select yymm,'tab5' as tab_1,kod_vc_5 as kod_vc_2,kol1 as kol1_3,kol2 as kol2_4,kol3 as kol3_5,kol_pas as kol_pas_6,0 as sum_7,0 as sum_8,plata as plata_9,poteri as poteri_10
 from 
 (select yymm,kod_vc_5,count(*) as kol1,sum(kol_pas_33) as kol_pas,sum(plata_36) as plata,sum(poteri_44) as poteri
	   from itog2 group by 1,2) as a
 join (select kod_vc_2,count(*) as kol2 from itog_mar_otd group by 1) as b on a.kod_vc_5=b.kod_vc_2
 join (select kod_vc_2,count(*) as kol3 from itog_mar_reg group by 1) as c on a.kod_vc_5=c.kod_vc_2
 join (select kod_vc_2,count(*) as kol4 from itog_plat group by 1) as d on a.kod_vc_5=d.kod_vc_2
)



,rezult as
(select  yymm,idnum,date_zap,request_num,
tab_1,nom_str_2,year_3,month_4,kod_vc_5,kod_dor_pr_6,kod_dor_of_7,stp_8,chp_9,stp_reg_10,
stp_okato_11,dt_otp_12,sto_dor_13,sto_otd_14,sto_15,sto_reg_16,sto_oksto_17,sto_nopr_18,kateg_pzd_19,klass_20, 
vid_bil_21,prizn_pas_22,tarif_23,kod_lgt_24,vid_rasch_25,flg_otch_26,stn_dor_27,stn_otd_28,stn_reg_29,stn_okato_30,
stn_nopr_31,srasst_32,kol_pas_33,sum_34,sum_35,plata_36,sum_37,sum_38,sum_39,sum_40,
sum_41,sum_42,sum_43,poteri_44,sum_45,sum_46,sum_47,sum_48,sum_49,sum_50,
kol_bil_51,vid_oforml_52,agent_53,stn_54,abonement_tip_55,srok_abon_56,bag_vid_57,flg_zd_fpk_58,flg_zd_fpk_f_59,subagent_60,
mcd_61,mcd_rst_62,mcd_vid_63,
 0 as nom_4,0 as dor_5,0 as otd_6,0 as rst_7,0 as reg_5,'0' as okato_6,0 as dcs_6
from itog2  
 
union all 
 select  yymm,NULL as idnum,NULL as date_zap,NULL as request_num,
 'tab2' as tab_1,nom_str_3 as nom_str_2,NULL as year_3,NULL as month_4,kod_vc_2 as kod_vc_5,
 NULL as kod_dor_pr_6,NULL as kod_dor_of_7,NULL as stp_8,NULL as chp_9,NULL as stp_reg_10,
 NULL as stp_okato_11,NULL as dt_otp_12,NULL as sto_dor_13,NULL as sto_otd_14,NULL as sto_15,
 NULL as sto_reg_16,NULL as sto_oksto_17,NULL as sto_nopr_18,NULL as kateg_pzd_19,NULL as klass_20, 
 NULL as vid_bil_21,NULL as prizn_pas_22,NULL as tarif_23,NULL as kod_lgt_24,NULL as vid_rasch_25,
 NULL as flg_otch_26,NULL as stn_dor_27,NULL as stn_otd_28,NULL as stn_reg_29,NULL as stn_okato_30,
 NULL as stn_nopr_31,NULL as srasst_32,NULL as kol_pas_33,NULL as sum_34,NULL as sum_35,
 NULL as plata_36,NULL as sum_37,NULL as sum_38,NULL as sum_39,NULL as sum_40,
 NULL as sum_41,NULL as sum_42,NULL as sum_43,NULL as poteri_44,NULL as sum_45,
 NULL as sum_46,NULL as sum_47,NULL as sum_48,NULL as sum_49,NULL as sum_50,
 NULL as kol_bil_51,NULL as vid_oforml_52,NULL as agent_53,NULL as stn_54,NULL as abonement_tip_55,
 NULL as srok_abon_56,NULL as bag_vid_57,NULL as flg_zd_fpk_58,NULL as flg_zd_fpk_f_59,NULL as subagent_60,
 NULL as mcd_61,NULL as mcd_rst_62,NULL as mcd_vid_63,
 nom_4,dor_5,otd_6,rst_7,0 as reg_5,'0' as okato_6,0 as dcs_6
from itog_mar_otd 

 union all 
 select  yymm,NULL as idnum,NULL as date_zap,NULL as request_num,
 'tab3' as tab_1,nom_str_3 as nom_str_2,NULL as year_3,NULL as month_4,kod_vc_2 as kod_vc_5,
 NULL as kod_dor_pr_6,NULL as kod_dor_of_7,NULL as stp_8,NULL as chp_9,NULL as stp_reg_10,
 NULL as stp_okato_11,NULL as dt_otp_12,NULL as sto_dor_13,NULL as sto_otd_14,NULL as sto_15,
 NULL as sto_reg_16,NULL as sto_oksto_17,NULL as sto_nopr_18,NULL as kateg_pzd_19,NULL as klass_20, 
 NULL as vid_bil_21,NULL as prizn_pas_22,NULL as tarif_23,NULL as kod_lgt_24,NULL as vid_rasch_25,
 NULL as flg_otch_26,NULL as stn_dor_27,NULL as stn_otd_28,NULL as stn_reg_29,NULL as stn_okato_30,
 NULL as stn_nopr_31,NULL as srasst_32,NULL as kol_pas_33,NULL as sum_34,NULL as sum_35,
 NULL as plata_36,NULL as sum_37,NULL as sum_38,NULL as sum_39,NULL as sum_40,
 NULL as sum_41,NULL as sum_42,NULL as sum_43,NULL as poteri_44,NULL as sum_45,
 NULL as sum_46,NULL as sum_47,NULL as sum_48,NULL as sum_49,NULL as sum_50,
 NULL as kol_bil_51,NULL as vid_oforml_52,NULL as agent_53,NULL as stn_54,NULL as abonement_tip_55,
 NULL as srok_abon_56,NULL as bag_vid_57,NULL as flg_zd_fpk_58,NULL as flg_zd_fpk_f_59,NULL as subagent_60,
 NULL as mcd_61,NULL as mcd_rst_62,NULL as mcd_vid_63,
 nom_4,0 as dor_5,0 as otd_6,rst_7,reg_5,okato_6,0 as dcs_6 
from itog_mar_reg 

union all 
 select  yymm,NULL as idnum,NULL as date_zap,NULL as request_num,
 'tab4' as tab_1,nom_str_3 as nom_str_2,NULL as year_3,NULL as month_4,kod_vc_2 as kod_vc_5,
 NULL as kod_dor_pr_6,NULL as kod_dor_of_7,NULL as stp_8,NULL as chp_9,NULL as stp_reg_10,
 NULL as stp_okato_11,NULL as dt_otp_12,NULL as sto_dor_13,NULL as sto_otd_14,NULL as sto_15,
 NULL as sto_reg_16,NULL as sto_oksto_17,NULL as sto_nopr_18,NULL as kateg_pzd_19,NULL as klass_20, 
 NULL as vid_bil_21,NULL as prizn_pas_22,NULL as tarif_23,NULL as kod_lgt_24,NULL as vid_rasch_25,
 NULL as flg_otch_26,NULL as stn_dor_27,NULL as stn_otd_28,NULL as stn_reg_29,NULL as stn_okato_30,
 NULL as stn_nopr_31,NULL as srasst_32,NULL as kol_pas_33,NULL as sum_34,NULL as sum_35,
 d_plata_7 as plata_36,NULL as sum_37,NULL as sum_38,NULL as sum_39,NULL as sum_40,
 NULL as sum_41,NULL as sum_42,NULL as sum_43,d_poteri_8 as poteri_44,NULL as sum_45,
 NULL as sum_46,NULL as sum_47,NULL as sum_48,NULL as sum_49,NULL as sum_50,
 NULL as kol_bil_51,NULL as vid_oforml_52,NULL as agent_53,NULL as stn_54,NULL as abonement_tip_55,
 NULL as srok_abon_56,NULL as bag_vid_57,NULL as flg_zd_fpk_58,NULL as flg_zd_fpk_f_59,NULL as subagent_60,
 NULL as mcd_61,NULL as mcd_rst_62,NULL as mcd_vid_63,
  nom_4,dor_5,0 as otd_6,rst_9 as rst_7,0 as reg_5,okato_6,0 as dcs_6 
from itog_plat
 
 union all  
 select  yymm,NULL as idnum,NULL as date_zap,NULL as request_num,
 'tab6' as tab_1,nom_str_3 as nom_str_2,NULL as year_3,NULL as month_4,kod_vc_2 as kod_vc_5,
 NULL as kod_dor_pr_6,NULL as kod_dor_of_7,NULL as stp_8,NULL as chp_9,NULL as stp_reg_10,
 NULL as stp_okato_11,NULL as dt_otp_12,NULL as sto_dor_13,NULL as sto_otd_14,NULL as sto_15,
 NULL as sto_reg_16,NULL as sto_oksto_17,NULL as sto_nopr_18,NULL as kateg_pzd_19,NULL as klass_20, 
 NULL as vid_bil_21,NULL as prizn_pas_22,NULL as tarif_23,NULL as kod_lgt_24,NULL as vid_rasch_25,
 NULL as flg_otch_26,NULL as stn_dor_27,NULL as stn_otd_28,NULL as stn_reg_29,NULL as stn_okato_30,
 NULL as stn_nopr_31,NULL as srasst_32,NULL as kol_pas_33,NULL as sum_34,NULL as sum_35,
 NULL as plata_36,NULL as sum_37,NULL as sum_38,NULL as sum_39,NULL as sum_40,
 NULL as sum_41,NULL as sum_42,NULL as sum_43,NULL as poteri_44,NULL as sum_45,
 NULL as sum_46,NULL as sum_47,NULL as sum_48,NULL as sum_49,NULL as sum_50,
 NULL as kol_bil_51,NULL as vid_oforml_52,NULL as agent_53,NULL as stn_54,NULL as abonement_tip_55,
 NULL as srok_abon_56,NULL as bag_vid_57,NULL as flg_zd_fpk_58,NULL as flg_zd_fpk_f_59,NULL as subagent_60,
 NULL as mcd_61,NULL as mcd_rst_62,NULL as mcd_vid_63,
  nom_4,dor_5,0 as otd_6,rst_7,0 as reg_5,'0' as okato_6,dcs_6 
from itog_mar_dcs  
 
)





--select * from itog1 order by nom_str_2,year_3,month_4   -- старый вариант первой таблицы
--select * from itog2 order by nom_str_2,year_3,month_4   

--select * from itog_mar_otd order by nom_str_3,nom_4
--select * from itog_mar_reg order by nom_str_3,nom_4
--select * from itog_plat order by nom_str_3,nom_4
--select * from itog_5  --- 13	6	9	22
--select * from itog_mar_dcs order by nom_str_3,nom_4


select * from rezult;-- =пять информ таблиц. без итоговых результатов





/*
select count(*) as kol from mar1
union all
select count(*) as kol from mar2
union all
select count(*) as kol from mar




select count(*)
from dat3

from prig1 as a join okato as b on a.stp_reg=b.sf_reg  --89
join mar as c on a.nom_mar=c.nom_mar  --0
join bil as d on a.nom_bil=d.nom_bil --119
 join dat3 as f on a.date_pr=f.date_pr and a.date_beg=f.date_beg and a.nom_dat=f.nom_dat  --107




 select count(*),max(nom_mar) from l3_mes.prig_mars
 */

----------------------------------------------------------------------------------------------------------



/** /

insert into l3_mes.prig_co22_t1 
(yymm,idnum,date_zap,request_num,p1,p2,p3,p4,p5,p6,p7,p8,p9,p10,p11,p12,p13,p14,p15,p16,p17,p18,p19,p20,
p21,p22,p23,p24,p25,p26,p27,p28,p29,p30,p31,p32,p33,p34,p35,p36,p37,p38,p39,p40,								 
p41,p42,p43,p44,p45,p46,p47,p48,p49,p50,p51,p52,p53,p54,p55,p56,p57,p58,p59,p60,p61,p62,p63)
select  yymm,idnum,date_zap,request_num,p1,p2,p3,p4,p5,p6,p7,p8,p9,p10,p11,p12,p13,p14,p15,p16,p17,p18,p19,p20,
p21,p22,p23,p24,p25,p26,p27,p28,p29,p30,p31,p32,p33,p34,p35,p36,p37,p38,p39,p40,								 
p41,p42,p43,p44,p45,p46,p47,p48,p49,p50,p51,p52,p53,p54,p55,p56,p57,p58,p59,p60,p61,p62,p63
from l3_mes.prig_co22_t0 where p1='tab1';

-----------------
insert into l3_mes.prig_co22_t2(yymm,p1,p2,p3,p4,p5,p6,p7)
select yymm,p1,p5 as p2,p2 as p3,d1 as p4,d2 as p5,d3 as p6,d4 as p7
from l3_mes.prig_co22_t0 where p1='tab2';

-----------------
insert into l3_mes.prig_co22_t3(yymm,p1,p2,p3,p4,p5,p6,p7)
select yymm,p1,p5 as p2,p2 as p3,d1 as p4,d5 as p5,d6 as p6,d4 as p7
from l3_mes.prig_co22_t0 where p1='tab3';

-----------------
insert into l3_mes.prig_co22_t4
(yymm,p1,p2,p3,p4,p5,p6,p7,p8,p9)
select yymm,p1,p5 as p2,p2 as p3,d1 as p4,d2 as p5,d6 as p6,p36 as p7,p44 as p8,d4 as p9
from l3_mes.prig_co22_t0 where p1='tab4';

-----------------
insert into l3_mes.prig_co22_t5(yymm,p1,p2,p3,p4,p5,p6,p7,p8,p9,p10)
select yymm,'tab5' as tab_1,a.p5 as kod_vc_2,kol1 as kol1_3,kol2 as kol2_4,kol3 as kol3_5,kol_pas as kol_pas_6,0 as sum_7,0 as sum_8,plata as plata_9,poteri as poteri_10
 from 
 (select yymm,p5,count(*) as kol1,sum(p33) as kol_pas,sum(p36) as plata,sum(p44) as poteri
	   from l3_mes.prig_co22_t0 where p1='tab1' group by 1,2) as a
 join (select p5,count(*) as kol2 from l3_mes.prig_co22_t0 where p1='tab2' group by 1) as b on a.p5=b.p5
 join (select p5,count(*) as kol3 from l3_mes.prig_co22_t0 where p1='tab3' group by 1) as c on a.p5=c.p5
 join (select p5,count(*) as kol4 from l3_mes.prig_co22_t0 where p1='tab4' group by 1) as d on a.p5=d.p5
;

-----------------
insert into l3_mes.prig_co22_t6(yymm,p1,p2,p3,p4,p5,p6,p7)
select yymm,p1,p5 as p2,p2 as p3,d1 as p4,d2 as p5,d7 as p6,d4 as p7
from l3_mes.prig_co22_t0 where p1='tab6';





/ **/







--   select * from l3_mes.prig_co22_t1 limit 100

--   select * from l3_mes.prig_co22_t5 limit 100




/*  --выдача итогов на печать
 select * from l3_mes.prig_co22_t1 where yymm=2309 order by p2 ;
 select * from l3_mes.prig_co22_t2 where yymm=2309 order by p3,p4;
 select * from l3_mes.prig_co22_t3 where yymm=2309 order by p3,p4;
 select * from l3_mes.prig_co22_t4 where yymm=2309 order by p3,p4; -- ошибка пустые значения суммм
 select * from l3_mes.prig_co22_t5 where yymm=2309;
 select * from l3_mes.prig_co22_t6 where yymm=2309 order by p3,p4;

*/

-------------------------------------------------

/*
select * from l3_mes.prig_co22_t1 where yymm=2308

select distinct date_zap,yymm from l3_mes.prig_co22_t0 order by 1,2
*/










/**/


