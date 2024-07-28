


-- Запкск F8, затем либо открыть блокнотом, либо показать положение в папке, откуда и открыть опять же блокнотом
--ДОПИСАТЬ САМ АЛГОРИТМ  РАБОТЫ ПРОГРАММЫ РЕЕСТРА


--update l3_prig.prig_itog set request_num=0 where date_zap>'2023-02-06';

/*
select yymm,count(*) from l3_mes.prig_lgot_reestr group by 1

202303	1235746
202304	13287131
202305	682549
*/

select * from l3_mes.prig_lgot_reestr where p1 between 1 and 5 limit 100

select yymm,p4,count(*) as kol from l3_mes.prig_lgot_reestr group by 1,2 order by 1,2


select yymm,p4,count(*) as kol from l3_prig.prig_lgot_reestr group by 1,2 order by 1,2



select
 case when request_type in (64,10) then 0
 when request_type=97 and request_subtype=266 then 1 else 2 end as vid_oforml_4,count(*) from l3_mes.prig_bil group by 1


select distinct request_subtype from l3_mes.prig_bil where request_type=97 order by 1


-----------------------------------
--СОЗДАНИЕ КЕОНТРОЛЬНОЙ ТАБЛИЦЫ


CREATE TABLE l3_mes.prig_lgot_stat
(	yymm dec(7),list char(5),dor char(3),kol_zap integer,kol_del integer,kol_raz integer,kol_abon integer,kol_ab_k integer,
 plata dec(13,2),poteri dec(13,2),kol_porc dec(5),date_zap date
 )
TABLESPACE pg_default;
ALTER TABLE l3_mes.prig_lgot_stat OWNER to asul;
GRANT ALL ON TABLE l3_mes.prig_lgot_stat TO asul;


 
-------------------------- 
 
SELECT * from l3_mes.prig_lgot_stat order by yymm



--  SELECT * from l3_mes.prig_lgot_reestr  limit 1000

  SELECT * from l3_prig.prig_lgot_reestr  limit 1000


SELECT * from l3_prig.prig_lgot_stat order by yymm

SELECT * from l3_prig.prig_lgot_reestr
where yymm=202304 and list='R064G'



select yymm,list,
/*cast(p2 as dec(3))*/17+(case when p4='1' then 300 else 200 end) as dor,--АСОКУПЭ идут в 3**-е значения, а Экспресс и ручники оба скопом - в 2**-е значения
sum(case when deleted='0' then 1 else 0 end) as kol_zap,sum(case when deleted='1' then 1 else 0 end) as kol_del,
sum(case when p18='0' and deleted='0' then p16 else 0 end) as kol_raz,
sum(case when p18 between '1' and '4' and deleted='0' then p16 else 0 end) as kol_abon,
sum(case when p18='5' and deleted='0' then p16 else 0 end) as kol_ab_k,
sum(case when deleted='0' then p28 else 0 end) as poteri,
sum(case when deleted='0' then p27 else 0 end) as plata,max(date_zap) as date_zap
from l3_prig.prig_lgot_reestr where yymm=202304 and list='R064G'
 group by 1,2,3 order by 1,2,3


-----------------------------------
--  delete from l3_mes.prig_work where rez in(11,12);

-----БЛОК РАБОТЫ С КОНТРОЛЬНОЙ ТАБЛИЦЕЙ, И УДАЛЕНИЕ ВОЗВРАТОВ ВНУТРИ МЕСЯЦА
--ПРЕДВАРИТЕЛЬНАЯ РАБОТА ПО ЛЬГОТНИКАМ - КАКИЕ ИМЕННО МЕСЯЦА СЕЙЧАС ИЗМЕНЯЮТСЯ
insert into l3_mes.prig_work (yymm,date_zap,part_zap,rez)
select yymm,date_zap,part_zap,11 as rez from
(select yymm,date_zap,part_zap,count(*) from l3_mes.prig_work  where rez=9 group by 1,2,3) as a;

--УДАЛЕНИЕ ИЗ КОНТРОЛЬНОЙ ТАБЛИЦЫ ИЗМЕНИВШИХСЯ ЗАПИСЕЙ
delete from l3_mes.prig_lgot_stat where yymm in(select yymm from l3_mes.prig_work where rez=11);

-- УДАЛЕНИЕ ПАР ПОДАЖА-ВОЗВРАТ С НУЛЕВОЙ ИТОГОВОЙ СУММОЙ - ИЗ НОВОЙ РАБОЧЕЙ БАЗЫ
--1. ПОИСК ПАР ПРОДАЖА-ВОЗВРАТ, даже если с разными видами  работы или дорогой продажи, но строго с одинаковыми  list
insert into l3_mes.prig_work (yymm,fio,ticket,rez,kol_bil)
with del as
(select yymm,list,ticket,kol from
(select yymm,list,ticket,count(*) as kol,sum(p27) as plata,sum(p28) as poteri,sum(p16) as kol_bil
from l3_mes.prig_lgot_reestr where yymm in(select yymm from l3_mes.prig_work where rez=11)
 group by 1,2,3) as a where kol=2*round(kol/2) and plata=0 and poteri=0 and kol_bil=0  )
select yymm,list,ticket,12 as rez,kol as kol_bil from del;

--2.АПДЕЙТ УДАЛЕНИЕ ПАР ПРОДАЖА-ВОЗВРАТ
update l3_mes.prig_lgot_reestr set deleted='1'  where (yymm,ticket,list) in (select yymm,ticket,fio from l3_mes.prig_work where rez=12);



--ЗАПОЛНЕНИЕ контрольной таблицы
insert into l3_mes.prig_lgot_stat(yymm,list,dor,kol_zap,kol_del,kol_raz,kol_abon,kol_ab_k,plata,poteri,kol_porc,date_zap)
with ish as
(select yymm,list,
/*cast(p2 as dec(3))*/17+(case when p4='1' then 300 else 200 end) as dor,--АСОКУПЭ идут в 3**-е значения, а Экспресс и ручники оба скопом - в 2**-е значения
sum(case when deleted='0' then 1 else 0 end) as kol_zap,sum(case when deleted='1' then 1 else 0 end) as kol_del,
sum(case when p18='0' and deleted='0' then p16 else 0 end) as kol_raz,
sum(case when p18 between '1' and '4' and deleted='0' then p16 else 0 end) as kol_abon,
sum(case when p18='5' and deleted='0' then p16 else 0 end) as kol_ab_k,
sum(case when deleted='0' then p28 else 0 end) as poteri,
sum(case when deleted='0' then p27 else 0 end) as plata,max(date_zap) as date_zap
from l3_mes.prig_lgot_reestr where yymm in (select yymm from l3_mes.prig_work where rez=11)
 group by 1,2,3 order by 1,2,3)
/*,kol as (select list,sum(kol_zap) as kol_zap,sum(kol_del) as kol_del,max(date_zap) as date_zap from ish group by 1)
select a.yymm,a.list,cast(dor as char(3)),b.kol_zap,b.kol_del,kol_raz,kol_abon,kol_ab_k,plata,poteri,0 as kol_porc,a.date_zap
from ish as a,kol as b where a.list=b.list;*/
select yymm,list,cast(dor as char(3)),kol_zap,kol_del,kol_raz,kol_abon,kol_ab_k,plata,poteri,0 as kol_porc,date_zap
from ish;






---------------------------------------------------

-- УДАЛЕНИЕ ПАР ПОДАЖА-ВОЗВРАТ С НУЛЕВОЙ ИТОГОВОЙ СУММОЙ
/** /
with del as
(select yymm,TICKET from
(select yymm,TICKET,count(*) as kol,sum(plata) as plata,sum(poteri) as poteri,sum(kol_bil) as kol_bil,sum(kom_sbor) as kom_sbor,sum(perebor) as perebor
from l3_prig.prig_lgotniki group by 1,2) as a where kol=2 and plata=0 and poteri=0 and kol_bil=0 and kom_sbor=0 and perebor=0)

--delete from l3_prig.prig_lgotniki as a where (yymm,ticket) in (select yymm,ticket from del);
select count(*) from del
/ **/





-- УДАЛЕНИЕ ПАР ПОДАЖА-ВОЗВРАТ С НУЛЕВОЙ ИТОГОВОЙ СУММОЙ - ИЗ НОВОЙ БАЗЫ
-- p27=plata, p28=poteri
/** /
with del as
(select yymm,ticket from
(select yymm,ticket,count(*) as kol,sum(p27) as plata,sum(p28) as poteri,sum(p16) as kol_bil/*,sum(kom_sbor) as kom_sbor,sum(perebor) as perebor*/
from l3_prig.prig_lgot_reestr group by 1,2) as a where kol=2 and plata=0 and poteri=0 and kol_bil=0 /*and kom_sbor=0 and perebor=0*/ )
--delete from l3_prig.prig_lgot_reestr as a where (yymm,ticket) in (select yymm,ticket from del);
select * from del
/ **/



---------------------------------------------------

-- УДАЛЕНИЕ ПАР ПОДАЖА-ВОЗВРАТ С НУЛЕВОЙ ИТОГОВОЙ СУММОЙ - ИЗ НОВОЙ РАБОЧЕЙ БАЗЫ
/**/

with del as
(select yymm,ticket,list,p4 from
(select yymm,ticket,list,p4,count(*) as kol,sum(p27) as plata,sum(p28) as poteri,sum(p16) as kol_bil/*,sum(kom_sbor) as kom_sbor,sum(perebor) as perebor*/
from l3_mes.prig_lgot_reestr group by 1,2,3,4) as a where kol=2 and plata=0 and poteri=0 and kol_bil=0 /*and kom_sbor=0 and perebor=0*/ )
--update l3_mes.prig_lgot_reestr set deleted='1'  where (yymm,ticket) in (select yymm,ticket from del);
select count(*) from del

--146   -- UPDATE 292
/ **/

select * from l3_prig.prig_lgot_reestr limit 100



--продажа и возврат по разным способам оплаты - Экспресс и Ручник
with del as
(select yymm,ticket,list,p41,p42 from
(select yymm,ticket,list,count(*) as kol,sum(p27) as plata,sum(p28) as poteri,sum(p16) as kol_bil,min(p4) as p41,max(p4) as p42
from l3_mes.prig_lgot_reestr group by 1,2,3) as a where kol=2 and plata=0 and poteri=0 and kol_bil=0  )
--update l3_mes.prig_lgot_reestr set deleted='1'  where (yymm,ticket) in (select yymm,ticket from del);
--select count(*) from del where p41!=p42
select * from del where p41!=p42 limit 100


select * from l3_mes.prig_lgot_reestr  where ticket='ИЩ484616'





---------------------------------------------------
--ПРЕДНУМЕРАЦИЯ ДАННЫХ!
















---------------------------------------------------



/**/
insert into l3_prig.prig_lgot_reestr
(yymm,date_zap,part_zap,request_num,id,ticket,list,p1,p2,p3,p4,p5,p6,p7,p8,p9,p10,
p11,p12,p13,p14,p15,p16,p17,p18,p19,p20,p21,p22,p23,p24,p25,p26,p27,p28,p29,p30,p31,p32,p33,deleted)
/**/

WITH

bil0 as (select * from l3_prig.prig_bil where kod_lgt>0 
		 and flg_bil_sbor='B' --только билетные записи, без сбора за оформление в пути
		and (request_type!=97 or request_subtype!=266) and (flg_voin=0)    --реестр не по 97-110 работе. и не по воинским!!!
		),

ish as
(select id,doc_num,yymm,nom_mar,nom_bil,nom_dat,date_zap,part_zap,date_beg,date_end,date_pr,TERM_DOR,term_pos,term_trm,time_zap,server_reqnum,drac,
agent,subagent,chp,stp,stp_reg,kol_bil*k_bil as kol_bil,plata*k_bil as plata,poteri*k_bil as poteri,perebor,kom_sbor,nedobor
from l3_prig.prig_work where rez=9 and nom_bil in (select nom_bil from bil0)),

lgot_fio as
(select id,doc_num,request_num,fio,fio_2,snils,ticket,benefit_doc,benefit_podr,bilgroup
from l3_prig.prig_work where rez=0 /*and snils is not null*/),

lgot as
(select a.id,a.doc_num,request_num,yymm,nom_mar,nom_bil,nom_dat,date_zap,part_zap,date_beg,date_end,date_pr,TERM_DOR,term_pos,term_trm,time_zap,server_reqnum,drac,
agent,subagent,chp,stp,stp_reg,kol_bil,plata,poteri,perebor,kom_sbor,nedobor,fio,fio_2,snils,ticket,benefit_doc,benefit_podr,bilgroup
  from ish as a,lgot_fio as b where a.id=b.id and a.doc_num=b.doc_num),

dates as(select max(date_zap) as date_zap from ish),

dor as (select nomd3 as dor3,kodd,vc from nsi.dor as a,dates as b where date_zap between datan and datak),
dor2 as
(select a.dor3,a.kodd,a.vc,b.dor3 as dor_vc from dor as a,dor as b where a.vc=b.kodd),

OKATO AS
(select sf_kod2,cast(sf_kod2 as dec(3)) as sf_reg,sf_kodokato as okato from nsi.sf
where sf_dataki='2100-01-01' and  sf_datak='2100-01-01'),

stan as 
(select kst,nopr,dor,otd,sf,okato as okato_st from
(select cast(stan as dec(7)) as kst,nopr,dor,otd,sf--,substr(kodokato,1,5) as okato_st
from nsi.stanv as a,dates as b where date_zap between datand and datakd and date_zap between datani and dataki) as c,
 okato as d where c.sf=d.sf_kod2),

site as 
(select  * from nsi.site as a,dates as b where date_zap between datan and datak),

bil as
(select nom_bil,employee_cat,ABONEMENT_TYPE,/*train_num,*/
case when prod='p' and kod_lgt between 2200 and 2299 then 'R064Z'
 when prod='p'  then 'R064G'
 when  kod_lgt between 2200 and 2299 then 'R800Z' else 'R800G' end as list,
 
 
/*case --копия реестра поездок (vid_oforml_52 из ЦО22), значения на 1 меньше, и всё свыше 3 =2
when flg_ruch='0' then '0' --Экспресс
when request_type!=64 and request_subtype>=200 and request_subtype<=299 then '1' --64=Экспресс, из прочих 2**-е = АСОКУПЕ-Л
-- when tsite is not null then cast(cast(tsite as smallint) as char(1))
--when request_subtype in(10,20,25) then '4'
else '2' end as vid_oforml_4,*/
 
 --oper_g= N (=не гашение) G (=гашение) O=(=отказ)
 --Код операции: «1» - продажа; «2» - гашение; «3» - возврат; «4» - отказ.
case  when oper='O' and oper_g='N' then '1' --оформление
 when oper='O' and oper_g='G' then '2' --гашение
 when oper='V' and oper_g='N' then '3' --возврат
 when oper='O' and oper_g='O' then '4' --отказ
 else '?' end  as kod_oper_5,
 --Код операции: «1» - продажа; «2» - гашение; «3» - возврат; «4» - отказ.

 --0 = Р64 и Р10 , 1 = Р97 R110 АСОКУПЭ (только Беларусь), 2 = Р97 – ручной ввод -- работа 110 = (1*256+10=266)
 --Для Цо-22 мы определяем так: -P64 - Экспресс, P97r1xx - АСУ-КУПЭ, p97R2xx - иные системы нижнего уровня, P97R0хх - БПМФ/ручник. 
 case when request_type in (64,10) then 0 --Экспресс
 when request_type=97 and request_subtype between 256+1 and 256+99 then 1 --АСОКУПЭ
 else 2 end as vid_oforml_4, --2=ручники
 
 case when flg_bag='1' then /*bag_ves*/ 0 
	when srok_mon>0 then 0 --многомесячным абонементам поездки =0, показывать только для немесячных
	when ABONEMENT_TYPE='0' then 0 --по разовым - тоже =0
	else k_pas end as kol_poezdok_ab_d,srok_mon,


case --вариант "О" - без проверки/ О - это обычная пригородная электричка.
when train_category in('1','М') then '1' --скорые пригородные с предоставлением мест (7XXX(8xx-c АМГ)),
else train_category end as kateg_pzd_6,
kod_lgt as kod_lgt_7, kod_lgt,

case  when ABONEMENT_TYPE>'0' then 0 --абонементам признак туда-обратно - принудительно=0
 when flg_tuda_obr='2' then '1' else '0' end as tuda_obr_17,
 
case when ABONEMENT_TYPE='3' then '1' --абонемент ежедневно
 when ABONEMENT_TYPE in('5','6') then '2' --выходного дня
 when ABONEMENT_TYPE in('7','8') then '3' --рабочего дня
 when ABONEMENT_TYPE='4' then '1' --абонемент Ежедневно - вообще-то это абонмено на 5-25 дней на 5-20 поездок
 when ABONEMENT_TYPE='1' then '5' -- на 10-20-60-90 поездок
 when ABONEMENT_TYPE='2' then '4' --абонемент на определённые даты
 else ABONEMENT_TYPE end as abonement_tip_18,
 flg_bag,k_pas,
 
 case 
 when flg_rab_day='1' then '2' --абонементы выходные
 when flg_rab_day='2' and srok_mon>0  then '4' --абонементы рабочего дня многомесячные
 when flg_rab_day='2' and srok_mon=0  then '5' --абонементы рабочего дня многодневные 
 when srok_mon>0  then '0' --все многомесячные
 when ABONEMENT_TYPE='1' then '?' -- на 10,20,60, 90 поездок
 when ABONEMENT_TYPE>'1' then '1' --все многодневные
  else '0' --разовые
 	end as pr_srok_abon_20,
 case when ABONEMENT_TYPE='0' then 0 
 	when srok_mon>0 then srok_mon else  srok_bil end as srok_bil_21, --если разовые - то срок=0, многомесячные - срок в месяцах, иначе в днях.
 bag_ves,oper,oper_g

 

from bil0 as a left join site as b on a.web_id=b.idsite 
),

lgot_okato as
(select distinct cast(lg as dec(5)) as kod_lgt,okato
 from prig.sublx where datak='2100-01-01' and n_tlgot!='' and n_tlgot!='000'),
 
 
mar1 as
(select max(nom) over(partition by nom_mar) as max_nom,*
 from l3_prig.prig_mars where nom_mar in (select distinct nom_mar from lgot)),
 
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

itog as
(select  yymm,date_zap,part_zap,request_num,id,ticket,list,
row_number() over (partition by yymm,list order by date_zap,request_num,id,doc_num) as nom_str_1,
c.dor_vc as kod_dor_2,
substr(b.otd,2,2) as otd_3,--перевести по справочнику в код дороги
vid_oforml_4,kod_oper_5,--oper,oper_g,
kateg_pzd_6,
kod_lgt_7,chp as kod_dir_8,
case when kod_lgt_7 between 2100 and 2599 then '00000'
when kod_lgt_7>2700 then e.okato
 else b.okato_st
 --добавить ОКАТО станции продажи
 end as lgot_okato_9,
benefit_doc as benefit_doc_10,bilgroup as bilgroup_11,
benefit_podr as benefit_podr_12,

 /*employee_cat =
 Р 01 РАБОТНИКИ ОАО "РЖД"
П 02 ПЕНСИОНЕРЫ ОАО "РЖД"
И 03 ИЖДЕВЕНЦЫ РАБОТНИКОВ И ИНВАЛИДОВ ОАО "РЖД"
Б 04 ЛИЦА, ПОЛУЧИВШИЕ ТРАН. ТРЕБ. НА БЕЗВОЗМЕЗД. ОСНОВЕ
Н 05 ДЕТИ ПОГИБШИХ РОДИТЕЛЕЙ
Д 06 РАБОТНИКИ СТОРОННИХ ОРГ. ПО ДОГОВОРАМ С ОАО "РЖД"
Ф 07 РАБОТНИКИ НЕГОСУДАРСТВЕННЫХ УЧРЕЖДЕНИЙ
М 08 РАБОТНИКИ СТОРОННИХ ОРГ. ПО МЕЖДУНАРОД. ДОГОВОРАМ
Ж 09 "ПОЧЕТНЫЕ ЖЕЛЕЗНОДОРОЖНИКИ" ПЕНСИОНЕРЫ НЕ ОАО "РЖД"
Г 10 ИЖДИВЕНЦЫ ПЕНСИОНЕРОВ*/
--case when employee_cat in('Ф','Д') then 1 else 0 end as shifr_13,
 employee_cat as shifr_13,--Поправка от Аганиной 29.05.2023, не надо 0 или 1 - надо ВСЕ значения
fio as fio_14,fio_2 as fio2_15,
--case when  abonement_type>'0' then 0 else kol_bil end as raz_per_16, -- отменилось - чтобы знать количество абонементных билетов тоже
kol_bil as raz_per_16,
tuda_obr_17,abonement_tip_18,
kol_bil*kol_poezdok_ab_d  as kol_poezdok_19,--srok_mon,ABONEMENT_TYPE,
pr_srok_abon_20,srok_bil_21,

to_char(date_pr,'ddmmyy') as date_pr_22,to_char(date_beg,'ddmmyy') as date_beg_23,

ticket as ticket_24,
sto as sto_25,stn as stn_26,
plata/10 as plata_27,poteri/10 as poteri_28,
drac as drac_29,

--to_char(date_zap,'ddmmyy') ||'-'||substr(time_zap,1,5) as 
time_zap as date_time_30,
server_reqnum as nom_str_31,
snils as snils_32,
bag_ves*kol_bil as bag_ves_33,
'0' as deleted

from lgot as a
join stan as b on a.stp=b.kst
join dor2 as c on /*term_dor*/ b.dor=kodd
join bil as d on a.nom_bil=d.nom_bil
left join lgot_okato as e on d.kod_lgt=e.kod_lgt
join mar2 as f on a.nom_mar=f.nom_mar)


select * from itog 
----where request_num in( 927, 1007, 1044, 1052, 1310 )
ORDER BY list,NOM_STR_1
;




 
-----------------------------------------


  
-----БЛОК РАБОТЫ С КОНТРОЛЬНОЙ ТАБЛИЦЕЙ, И УДАЛЕНИЕ ВОЗВРАТОВ ВНУТРИ МЕСЯЦА
--ПРЕДВАРИТЕЛЬНАЯ РАБОТА ПО ЛЬГОТНИКАМ - КАКИЕ ИМЕННО МЕСЯЦА СЕЙЧАС ИЗМЕНЯЮТСЯ
insert into l3_mes.prig_work (yymm,date_zap,part_zap,rez)
select yymm,date_zap,part_zap,11 as rez from
(select yymm,date_zap,part_zap,count(*) from l3_mes.prig_work  where rez=9 group by 1,2,3) as a;

--УДАЛЕНИЕ ИЗ КОНТРОЛЬНОЙ ТАБЛИЦЫ ИЗМЕНИВШИХСЯ ЗАПИСЕЙ
delete from l3_mes.prig_lgot_stat where yymm in(select yymm from l3_mes.prig_work where rez=11);



-- УДАЛЕНИЕ ПАР ПОДАЖА-ВОЗВРАТ С НУЛЕВОЙ ИТОГОВОЙ СУММОЙ - ИЗ НОВОЙ РАБОЧЕЙ БАЗЫ
--1. ПОИСК ПАР ПРОДАЖА-ВОЗВРАТ, даже если с разными видами  работы или дорогой продажи, но строго с одинаковыми  list
insert into l3_mes.prig_work (yymm,fio,kodbl,rez,kol_bil)
with del as
(select yymm,list,kodbl,kol from
(select yymm,list,kodbl,count(*) as kol,sum(p27) as plata,sum(p28) as poteri,sum(p16) as kol_bil
from l3_mes.prig_lgot_reestr where yymm in(select yymm from l3_mes.prig_work where rez=11)
 group by 1,2,3) as a where kol=2*round(kol/2) and plata=0 and poteri=0 and kol_bil=0  )
select yymm,list,kodbl,12 as rez,kol as kol_bil from del;

--2.АПДЕЙТ УДАЛЕНИЕ ПАР ПРОДАЖА-ВОЗВРАТ
update l3_mes.prig_lgot_reestr set deleted='1'  where (yymm,kodbl,list) in (select yymm,kodbl,fio from l3_mes.prig_work where rez=12);

-------------------ВТОРАЯ ЧАСТЬ УДАЛЕНИЯ


insert into l3_mes.prig_work (yymm,fio,kodbl,request_num,rez,kol_bil)
with del as
(select yymm,list,kodbl,request_num,kol from
(select yymm,list,kodbl,request_num,count(*) as kol,sum(p27) as plata,sum(p28) as poteri,sum(p16) as kol_bil
from l3_mes.prig_lgot_reestr where yymm in(select yymm from l3_mes.prig_work where rez=11) and deleted='0'
 group by 1,2,3,4) as a where kol=2*round(kol/2) and plata=0 and poteri=0 and kol_bil=0  )
select yymm,list,kodbl,request_num,13 as rez,kol as kol_bil from del;

--2.АПДЕЙТ УДАЛЕНИЕ ПАР ПРОДАЖА-ВОЗВРАТ
update l3_mes.prig_lgot_reestr set deleted='1'  where (yymm,kodbl,request_num,list) in (select yymm,kodbl,request_num,fio from l3_mes.prig_work where rez=13);


-------------------ТРЕТЬЯ ЧАСТЬ УДАЛЕНИЯ


insert into l3_mes.prig_work (yymm,fio,kodbl,kod_lgt,sto,stn,rez,kol_bil)
with del as
(select yymm,list,kodbl,p7,p25,p26,kol from
(select yymm,list,kodbl,p7,p25,p26,count(*) as kol,sum(p27) as plata,sum(p28) as poteri,sum(p16) as kol_bil
from l3_mes.prig_lgot_reestr where yymm in(select yymm from l3_mes.prig_work where rez=11) and deleted='0'
 group by 1,2,3,4,5,6) as a where kol=2*round(kol/2) and plata=0 and poteri=0 and kol_bil=0  )
select yymm,list,kodbl,cast(p7 as smallint) as kol_lgt,cast(p25 as dec(7)) as sto,cast(p26 as dec(7)) as stn,14 as rez,kol as kol_bil from del;

--2.АПДЕЙТ УДАЛЕНИЕ ПАР ПРОДАЖА-ВОЗВРАТ
update l3_mes.prig_lgot_reestr set deleted='1'  where (yymm,list,kodbl,p7,p25,p26) in 
(select yymm,fio,kodbl,cast(kod_lgt as char(4)),cast(sto as char(7)),cast(stn as char(7)) from l3_mes.prig_work where rez=14);





insert into l3_mes.prig_work (yymm,fio,kodbl,kod_lgt,sto,stn,rez,kol_bil)
with del as
(select yymm,list,kodbl,p7,p25,p26,kol from
(select yymm,list,kodbl,p7,p25,p26,count(*) as kol,sum(p27) as plata,sum(p28) as poteri,sum(p16) as kol_bil
from l3_mes.prig_lgot_reestr where  deleted='0'
 group by 1,2,3,4,5,6) as a where kol=2*round(kol/2) and plata=0 and poteri=0 and kol_bil=0  )
select yymm,list,kodbl,cast(p7 as smallint) as kol_lgt,cast(p25 as dec(7)) as sto,cast(p26 as dec(7)) as stn,14 as rez,kol as kol_bil from del;




  

/**/

