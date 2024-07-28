


--ТОЛЬКО ПРОЦЕДУРА ОБОГАЩЕНИЯ, ЧЕТВЁРТАЯ ПОСЛЕДНЯЯ ЧАСТЬ ОБРАБОТКИ - ЗАГРУЗКА В ИТОГИ


--   select rez,count(*) as rezult from l3_prig.prig_work group by 1


--- ввод времени начала операции
insert into  l3_prig.prig_times(time,date,oper,time2,date_zap,part_zap,shema)
with a as
(select date_zap,part_zap,shema,current_date as date,substr(cast(current_time as char(50)),1,12) as time
	from  l3_prig.prig_times where oper='dannie')
select time,date,'prig_agr 4_beg' as oper,
(cast(substr(time,1,2) as dec(3))*60+cast(substr(time,4,2) as dec(3)))*60+cast(substr(time,7,6) as dec(7,3)) as time2,date_zap,part_zap,shema
from a ;



--справочник расписки дат поездок относительно даты начала действия билета
insert into l3_prig.prig_dats 
(nom_dat,plus_dat,kpas_day,idnum,date_zap,part_zap) 
select nom_dat,kol_bil as plus_dat,k_pas as kpas_day,idnum,date_zap,part_zap from l3_prig.prig_work where rez=1;



--справочник видов билетов
insert into l3_prig.prig_bil
(nom_bil,flg_ruch,request_type,request_subtype,web_id,vid_rasch,FLG_CHILD,flg_voin,FLG_MILITARY,flg_lgt,FLG_BSP,FLG_SO,FLG_NU,FLG_TT,
klass,kod_lgt,lgt_reg,flg_bag,bag_vid,bag_ves,FLG_tuda_obr,flg_rab_day,proc_lgt,rzd_fpk,ABONEMENT_TYPE,ABONEMENT_SUBTYPE,FLG_OFFICIAL_BENEFIT,
k_pas,srok_bil,srok_mon,oper,oper_g,TRAIN_CATEGORY,employee_cat,prod,flg_sbor,flg_bil_sbor,grup_lgt,date_zap,part_zap,idnum)
select
nom_bil,flg_ruch,request_type,request_subtype,web_id,
vid_rasch,FLG_CHILD,flg_voin,FLG_MILITARY,flg_lgt,FLG_BSP,FLG_SO,FLG_NU,FLG_TT,
klass,kod_lgt,lgt_reg,flg_bag,bag_vid,bag_ves,FLG_tuda_obr,flg_rab_day,proc_lgt,rzd_fpk,ABONEMENT_TYPE,ABONEMENT_SUBTYPE,FLG_OFFICIAL_BENEFIT,
k_pas,srok_bil,srok_mon,oper,oper_g,TRAIN_CATEGORY,employee_cat,prod,flg_sbor,flg_bil_sbor,
cast(substr(cast(kod_lgt as char(4)),1,2) as dec(3)) as grup_lgt,date_zap,part_zap,idnum
from l3_prig.prig_work where rez=2 ;   -- and nom_bil<=400;



--справочник всех маршрутов - добавить номера перегонов
--пополнение справочника перегонов
insert into l3_prig.prig_peregoni(dor,lin,st1,st2,rasst,peregon,date_zap,part_zap)
with 
per1 as
(select dor,lin,st1,st2,min(date_zap) as date_zap,min(rst) as rst,min(part_zap) as part_zap from 
(select distinct dor,lin,st1,st2,rst,date_zap,part_zap from l3_prig.prig_work where rez=8) as a
 group by dor,lin,st1,st2),
 
per2 as
(select dor,lin,st1,st2,rst,date_zap,part_zap from
(select a.dor,a.lin,a.st1,a.st2,a.rst,peregon,a.date_zap,a.part_zap
 from per1 as a left join l3_prig.prig_peregoni as b on a.dor=b.dor and a.lin=b.lin and a.st1=b.st1 and a.st2=b.st2) as c
 where peregon is null),
 
per3 as
(select dor,lin,st1,st2,min(date_zap) as date_zap,min(rst) as rst,min(part_zap) as part_zap from 
(select dor,lin,st1,st2,rst,date_zap,part_zap from per2
 union all 
 select dor,lin,st2 as st1,st1 as st2,rst,date_zap,part_zap from per2)
 as a where st1<st2 group by 1,2,3,4),

per4 as
(select distinct dor,lin,st1,st2,rst,date_zap,part_zap,
 (row_number() over (order by dor,lin,st1,st2,rst))+(case when mper is NULL then 10000 else mper end) as peregon
 from per3 as a,
 (select max(peregon) as mper from l3_prig.prig_peregoni) as b),
 
 itog as
 (select dor,lin,st1,st2,rst,peregon,date_zap,part_zap from per4
 union all
 select dor,lin,st2 as st1,st1 as st2,rst,-peregon,date_zap,part_zap as peregon from per4)
 
 select dor,lin,st1,st2,rst,peregon,date_zap,part_zap from itog 
 ;

 
-- Собственно запись маршрутов, с указанием номера перегона

insert into l3_prig.prig_mars
(nom_mar,sto,stn,srasst,marshr,mcd,nom,reg,st1,st2,rst,sto_zone,stn_zone,sti,sti_zone,dor,lin,otd,dcs,d_plata,d_poteri,date_zap,part_zap,idnum,peregon)

select 
 nom_mar,sto,stn,srasst,marshr,mcd,nom,reg,a.st1,a.st2,rst,sto_zone,stn_zone,sti,sti_zone,a.dor,a.lin,otd,dcs,d_plata,d_poteri,a.date_zap,a.part_zap,idnum,peregon
from
(select
nom_mar,sto,stn,srasst,marshr,mcd,nom,reg,st1,st2,rst,sto_zone,stn_zone,sti,sti_zone,dor,lin,otd,dcs,d_plata,d_poteri,date_zap,part_zap,idnum
from l3_prig.prig_work where rez=8) as a
join l3_prig.prig_peregoni as b on a.dor=b.dor and a.lin=b.lin and a.st1=b.st1 and a.st2=b.st2
;



--запись всех видов ошибок в маршрутах
insert into l3_prig.prig_bad
(marshr,st1,st2,rst,reg,dor,lin,date_zap,part_zap,idnum)
select
marshr,st1,st2,rst,reg,dor,lin,date_zap,part_zap,idnum
from l3_prig.prig_work where rez=99;-- and nom_mar<=500;





--Обогащение пригорода, с уменьшением количества записей по абсолютно идентичным вариантам

insert into l3_prig.prig_itog
	(idnum,request_num,yymm,nom_mar,nom_bil,nom_dat,date_zap,part_zap,date_beg,date_end,date_pr,TERM_DOR,term_pos,term_trm,agent,subagent,chp,stp,stp_reg,train_num,
	 k_bil,kol_bil,plata,poteri,kom_sbor,kom_sbor_vz,perebor,nedobor)

with ish as
(select idnum,request_num,yymm,k_bil,nom_mar,nom_bil,nom_dat,date_zap,part_zap,date_beg,date_end,date_pr,TERM_DOR,term_pos,term_trm,agent,subagent,
 chp,stp,stp_reg,train_num,kol_bil,plata,poteri,kom_sbor,kom_sbor_vz,
 case when perebor>0 then perebor else 0 end as perebor,
 case when perebor<0 then perebor else 0 end as nedobor,
 row_number() over (order by idnum) as idd
from l3_prig.prig_work where rez=9),

obr as
(select idnum,yymm,k_bil,nom_mar,nom_bil,nom_dat,date_zap,part_zap,request_num,date_beg,date_end,date_pr,TERM_DOR,term_pos,term_trm,agent,subagent,chp,stp,stp_reg,train_num,
 	kol_bil,plata,poteri,kom_sbor,kom_sbor_vz,  perebor,nedobor,idd,
 sum(k_bil) over (partition by yymm,nom_mar,nom_bil,nom_dat,date_zap,part_zap,request_num,date_beg,date_end,date_pr,TERM_DOR,term_pos,term_trm,agent,subagent,chp,stp,stp_reg,train_num,
 	kol_bil,plata,poteri,kom_sbor,kom_sbor_vz) as sk_bil,
 sum(perebor) over (partition by yymm,nom_mar,nom_bil,nom_dat,date_zap,part_zap,request_num,date_beg,date_end,date_pr,TERM_DOR,term_pos,term_trm,agent,subagent,chp,stp,stp_reg,train_num,
 	kol_bil,plata,poteri,kom_sbor,kom_sbor_vz) as sperebor,
 sum(nedobor) over (partition by yymm,nom_mar,nom_bil,nom_dat,date_zap,part_zap,request_num,date_beg,date_end,date_pr,TERM_DOR,term_pos,term_trm,agent,subagent,chp,stp,stp_reg,train_num,
 	kol_bil,plata,poteri,kom_sbor,kom_sbor_vz) as snedobor,
 min(idd) over (partition by yymm,nom_mar,nom_bil,nom_dat,date_zap,part_zap,request_num,date_beg,date_end,date_pr,TERM_DOR,term_pos,term_trm,agent,subagent,chp,stp,stp_reg,train_num,
 	kol_bil,plata,poteri,kom_sbor,kom_sbor_vz) as midd
from ish 
)
--- на время тестирования склейка одинаковых не пройдёт - по разным request_num
--03.07.2023 количествабилетов и денег  домножил начисло групп - дляпростоты понимания и дальнейшей работы (там где не надо делить деньги на кусочки)
select idnum,request_num,yymm,nom_mar,nom_bil,nom_dat,date_zap,part_zap,date_beg,date_end,date_pr,TERM_DOR,term_pos,term_trm,agent,subagent,chp,stp,stp_reg,train_num,
sk_bil as k_bil,kol_bil*sk_bil as kol_bil,plata*sk_bil as plata,poteri*sk_bil as poteri,kom_sbor*sk_bil as kom_sbor,kom_sbor_vz*sk_bil as kom_sbor_vz,sperebor as perebor,snedobor as nedobor
  from obr where idd=midd;
  
  
  









  
  
--- ЗАГРУЗКА ЛЬГОТНИКОВ ПО НОВОМУ




/**/
insert into l3_prig.prig_lgot_reestr
(yymm,date_zap,part_zap,request_num,idnum,kodbl,list,p1,p2,p3,p4,p5,p6,p7,p8,p9,p10,
p11,p12,p13,p14,p15,p16,p17,p18,p19,p20,p21,p22,p23,p24,p25,p26,p27,p28,p29,p30,p31,p32,p33,deleted)
/**/

WITH

bil0 as (select * from l3_prig.prig_bil where kod_lgt>0 
		 and flg_bil_sbor='B' --только билетные записи, без сбора за оформление в пути
		and (request_type!=97 or request_subtype!=266) and (flg_voin=0)    --реестр не по 97-110 работе. и не по воинским!!!
		),

ish as
(select idnum,yymm,nom_mar,nom_bil,nom_dat,date_zap,part_zap,date_beg,date_end,date_pr,TERM_DOR,term_pos,term_trm,time_zap,server_reqnum,drac,
agent,subagent,chp,stp,stp_reg,k_bil,kol_bil*k_bil as kol_bil,plata*k_bil as plata,poteri*k_bil as poteri,perebor,kom_sbor,nedobor
from l3_prig.prig_work where rez=9 and nom_bil in (select nom_bil from bil0)),

lgot_fio as
(select idnum,request_num,fio,fio_2,snils,ticket,kodbl,benefit_doc,benefit_podr,bilgroup
from l3_prig.prig_work where rez=0 /*and snils is not null*/),

lgot as
(select a.idnum,request_num,yymm,nom_mar,nom_bil,nom_dat,date_zap,part_zap,date_beg,date_end,date_pr,TERM_DOR,term_pos,term_trm,time_zap,server_reqnum,drac,
agent,subagent,chp,stp,stp_reg,kol_bil,plata,poteri,perebor,kom_sbor,nedobor,fio,fio_2,snils,ticket,kodbl,benefit_doc,benefit_podr,bilgroup
  from ish as a,lgot_fio as b where a.idnum=b.idnum),

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
 case when request_type in (64,10) then 0
 when request_type=97 and request_subtype=266 then 1 else 2 end as vid_oforml_4,
 
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
(select  yymm,date_zap,part_zap,request_num,idnum,kodbl,list,
row_number() over (partition by yymm,list order by date_zap,request_num,idnum) as nom_str_1,
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


  
  
  
-----БЛОК РАБОТЫ С КОНТРОЛЬНОЙ ТАБЛИЦЕЙ, И УДАЛЕНИЕ ВОЗВРАТОВ ВНУТРИ МЕСЯЦА
--ПРЕДВАРИТЕЛЬНАЯ РАБОТА ПО ЛЬГОТНИКАМ - КАКИЕ ИМЕННО МЕСЯЦА СЕЙЧАС ИЗМЕНЯЮТСЯ
insert into l3_mes.prig_work (yymm,date_zap,part_zap,rez)
select yymm,date_zap,part_zap,11 as rez from
(select yymm,date_zap,part_zap,count(*) from l3_mes.prig_work  where rez=9 group by 1,2,3) as a;

--УДАЛЕНИЕ ИЗ КОНТРОЛЬНОЙ ТАБЛИЦЫ ИЗМЕНИВШИХСЯ ЗАПИСЕЙ
delete from l3_mes.prig_lgot_stat where yymm in(select yymm from l3_mes.prig_work where rez=11);

----------
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
----------






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
select yymm,list,cast(dor as char(3)),kol_zap,kol_del,kol_raz,kol_abon,kol_ab_k,plata,poteri,0 as kol_porc,date_zap
from ish;




  
  
  
  
  
  

--- ввод времени окончания операции с итоговым числом записей	
insert into  l3_prig.prig_times(time,date,oper,time2,date_zap,part_zap,shema,rezult)
with a as
(select date_zap,part_zap,shema,current_date as date,substr(cast(current_time as char(50)),1,12) as time 
	from  l3_prig.prig_times where oper='dannie'),
b as (select count(*) as rezult from l3_prig.prig_itog where part_zap in(select part_zap from l3_prig.prig_times where oper='dannie'))
select time,date,'prig_work 2_4_itog' as oper,
(cast(substr(time,1,2) as dec(3))*60+cast(substr(time,4,2) as dec(3)))*60+cast(substr(time,7,6) as dec(7,3)) as time2,date_zap,part_zap,shema,rezult
from a left join b on 1=1;




















--Запись итога
--Помечание прочтённой полностью даты
update l3_prig.prig_times set oper='read',date=current_date,time=substr(cast(current_time as char(50)),1,12)
	where oper='dannie' and dann='prig' and itog is null--and part_zap in (select distinct part_zap from l3_prig.prig_times where oper='dannie')
	;
	
/**/	

--Удаление старой даты прочтения - БОЛЬШЕ НЕ НУЖНО!
--delete from l3_prig.prig_times where oper in('dannie');
 

/*
insert into  l3_prig.prig_times(oper,date_zap,shema,part_zap,rezult,min_id,max_id)
with ish as (select * from l3_prig.prig_times where dann='prig' and itog is null)
select oper,date_zap,shema,part_zap,rezult,min_id,max_id from
(select 'dannie' as oper,date_zap,shema,part_zap,rezult,min_id,max_id,row_number() over(order by part_zap) as nn
from ish where oper='dann' and part_zap not in(select part_zap from ish where oper='read')) as a where nn=1;
*/


--удаление старья
delete from l3_prig.prig_work;

---------------------------------------------------

-- select * from l3_prig.prig_times where date_zap in(select date_zap from l3_prig.prig_times where oper='dannie') order by part_zap



-- select * from l3_prig.prig_times where part_zap in(select part_zap from l3_prig.prig_times where oper='dannie')


-- select * from l3_prig.prig_times where part_zap in(55)







