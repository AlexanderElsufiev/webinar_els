
---  ОТЧЁТ ВЫДАЁТСЯ ЗА ОДИН yymm = МЕСЯЦ ПРОДАЖИ

-- НАДО - ПОДГОТОВИТЬ ВЫДАЧУ АНАЛИИЧЕСКОЙ ОТЧЁТНОСТИ, В МИЗЕРНЫХ РАЗМЕРАХ - 4 СВЕРЛЕНИЯ (3+1), БЕЗ СТАНЦИЙ

	   
	   
------- ПРОВЕРКА ИТОГОВ	   
	   
select yymm,par_name,count(*) as kol,
 sum(kol_bil) as kol_bil,sum(plata) as plata,sum(poteri) as poteri,sum(kol_pas) as kol_pas,sum(pass_km) as pass_km
from l3_mes.prig_analit group by 1,2 order by 1,2
/*
						kol,	kol_bil,	plata,			 poteri,		kol_pas,	pass_km
202304	"bag       "	6662	=168999		=70528399		=2355000		=183877		9707108
202304	"bag_pereb "	244		0			=13473			=-129584		0			0
202304	"kom_sbor  "	1673	0			=162848600		963200			0			0
202304	"otpr      "	219618	0			39413741542		23183256610		87320749	2582234801
202304	"perebor   "	977		0			=6438735		=-55423518		0			0
202304	"prod      "	19080	71211684	39413741542		23183256610		87320589	2582226681
*/


select yymm,flg_bag,flg_bil_sbor,count(*) as kol,
 sum(kol_bil) as kol_bil,sum(plata) as plata,sum(poteri) as poteri,--sum(kol_pas) as kol_pas,sum(pass_km) as pass_km
 sum(perebor) as perebor,sum(nedobor) as nedobor,sum(kom_sbor) as kom_sbor,sum(kom_sbor_vz) as kom_sbor_vz,
 sum(kol_bil*k_pas*cast(flg_tuda_obr as dec(3))) as kol_pas
from l3_mes.prig_itog as a join l3_mes.prig_bil as b on a.nom_bil=b.nom_bil  group by 1,2,3 order by 1,2,3
/*
				kol, 	kol_bil,	plata,			poteri,			perebor,	nedobor,	kom_sbor,	kom_sbor_vz
202304	"0"	13486951	71209140	39403486952		23180253600		=6438735	=-55423518	=162848600	931700
202304	"1"	139277		+168999		+70528399		+2355000		+13473		=-129584	1291000		0

				kol, 		kol_bil,	plata,			poteri,			perebor,	nedobor,	kom_sbor,	kom_sbor_vz		kol_pas
202304	"0"	"B"	13388932	71209140	39403486952		23180253600		=6438735	=-55423518	0			931700			87318045
202304	"0"	"S"	98019		0			0				0				0			0			=162848600	0				0
202304	"1"	"B"	138094		=168999		=70528399		=2355000		=13473		=-129584	0			0				=183877
202304	"1"	"S"	1183		0			0				0				0			0			1291000		0				0
	
	

	
*/

select * from l3_mes.prig_itog limit 100

select * from l3_mes.prig_bil limit 100

select distinct flg_tuda_obr,abonement_type from l3_mes.prig_bil limit 100

select * from l3_mes.prig_analit limit 100


select yymm,count(*) as kol,
 sum(kol_bil) as kol_bil,sum(plata) as plata,sum(poteri) as poteri,sum(kol_pas) as kol_pas,sum(pass_km) as pass_km
from l3_mes.prig_analit group by 1 order by 1


 anal_rasch 

select anal_rasch,count(*) as kol,
 sum(kol_bil) as kol_bil,sum(plata) as plata,sum(poteri) as poteri,sum(kol_pas) as kol_pas,sum(pass_km) as pass_km
from l3_mes.prig_analit group by 1 order by 1


select anal_vid_bil,count(*) as kol,
 sum(kol_bil) as kol_bil,sum(plata) as plata,sum(poteri) as poteri,sum(kol_pas) as kol_pas,sum(pass_km) as pass_km
from l3_mes.prig_analit group by 1 order by 1

----------------------------------------------------------------------

select part_zap,count(*) from l3_mes.prig_analit group by 1 order by 1
--where par_name='kom_sbor'



/** /
--Таблица агрегатов аналитическая
CREATE TABLE l3_prig.prig_analit
(	yymm dec(7),date_zap date,part_zap dec(7),date date,TERM_DOR char(1),agent smallint,chp smallint,reg smallint,par_name char(10),
 anal_rasch char(7),anal_vid_bil char(9),anal_oper char(1),train_category char(1),
 kol_bil dec(13),plata dec(13),poteri dec(13),kol_pas dec(13),pass_km dec(13)
 	)
TABLESPACE pg_default;
ALTER TABLE l3_prig.prig_analit OWNER to asul;
GRANT ALL ON TABLE l3_prig.prig_analit TO asul;



CREATE TABLE l3_mes.prig_analit
(	yymm dec(7),date_zap date,part_zap dec(7),date date,TERM_DOR char(1),agent smallint,chp smallint,reg smallint,par_name char(10),
 anal_rasch char(7),anal_vid_bil char(9),anal_oper char(1),train_category char(1),
 kol_bil dec(13),plata dec(13),poteri dec(13),kol_pas dec(13),pass_km dec(13)
 	)
TABLESPACE pg_default;
ALTER TABLE l3_mes.prig_analit OWNER to asul;
GRANT ALL ON TABLE l3_mes.prig_analit TO asul;


drop table l3_mes.prig_analit;
drop table l3_prig.prig_analit;

/ **/


   

----------------------------------------------------------------------

-- ВЫДАЧАВСЕХ ПАРАМЕТРОВ СРАЗУ!

select distinct
case
when vid_rasch='6' then '3-bezn' --если Платёжные поручения, безналичные
when vid_rasch='8' and web_id in('0000','-1','NULL') then '2-bank' --если пустой ID эл.площадки, и НЕ Наличка, то это банковская
when vid_rasch='8' and web_id not in('0000','-1','NULL') then '4-elek' --Электронный кошелёк
when vid_rasch='1' and web_id not in('0000','-1','NULL') then '4-el-n' --если непустой ID эл.площадки, и Наличка - тоже Электронный кошелёк
when vid_rasch='1' then '1-nal' --наличка
else vid_rasch||'-neizv' --неизвестно что, льготные
end as anal_rasch,
case 
  when abonement_type='0' and flg_bil_sbor='B' and flg_bag='0' then '1.1.raz' --разовыые
  when ABONEMENT_TYPE='1' then '1.2.ab_k' -- на 10-20-60-90 поездок
  when ABONEMENT_TYPE='3' then '1.3.ez_m' --абонемент на ежедневные поездки месяцы
  when ABONEMENT_TYPE='4' then '1.4.ez_d' --абонемент Ежедневно на количество дней - вообще-то это абонмено на 5-25 дней на 5-20 поездок
  when flg_rab_day='2' and ABONEMENT_TYPE in('7','8') then '1.5.ab_rd' --абонементы рабочего дня
  when flg_rab_day='1' and ABONEMENT_TYPE in('5','6') then '1.6.ab_vd' --абонементы выходные
  when ABONEMENT_TYPE='2' then '1.7.ab_dt' --абонемент на определённые даты
  when flg_bil_sbor='S' then '2.5.sbor' --сбор за оформление в поезде
  --when par_name='kom_sbor' and flg_bil_sbor='B' then '2.6-7.kom_prod_vozv'
  when flg_bag='1' and bag_vid='Ж' then '2.4.bag_z'--багаж живность
  when flg_bag='1' and bag_vid='Т' then '2.2.bag_t' --багаж телевизор
  when flg_bag='1' and bag_vid='Р' then '2.1.bag_r' --багаж ручная кладь вес
  when flg_bag='1' and bag_vid='В' then '2.3.bag_v' -- багаж велосипед
  when flg_bag='1' then '2.*.bag_?' --неизвестный вид багажа
 end as anal_vid_bil, 
case when oper='O' and oper_g='N' then '1' else '2' end as anal_oper,
train_category
from l3_mes.prig_bil 
--132 варианта!!!
	   
	   
	   
	   
	   
	   
	   
	   
	   
	   
----------------------------------------------------------------------
--PAYMENTTYPE as vid_rasch, --вид расчёта (=1,6,8)=(' ','П','Э') = (Наличка, Платёжные поручения, Электронное=банковские карты)
 --  ==("9","Б","В") - неизвестные

Вид расчета выбирается из списка:
•	детализация;
1•	наличный;
2•	банковские карты (втч электронный кошелёк);
3•	безналичный (ПЮ);
4•	электронный кошелек;

case
when vid_rasch='6' then '3-bezn-py' --если Платёжные поручения
when vid_rasch='8' and web_id in('0000','-1','NULL') then '2-bank' --если пустой ID эл.площадки, и НЕ Наличка, то это банковская
when vid_rasch='8' and web_id not in('0000','-1','NULL') then '4-elek' --Электронный кошелёк
when vid_rasch='1' and web_id not in('0000','-1','NULL') then '4-elek-nal' --если непустой ID эл.площадки, и Наличка - тоже Электронный кошелёк
when vid_rasch='1' then '1-nal' --наличка
else vid_rasch||'-neizv' --неизвестно что, льготные
end as vid_rasch_anal




--------------------------------------------------------------------------

Вид проездного документа выбирается из списка:
•	детализация;
1.1•	разовый;
1.2•	абонементный на количество поездок;
1.3•	абонементный билет «ежедневно» месяцы;
1.4•	абонементный билет «ежедневно» дни;
1.5•	абонементный билет «рабочего дня»;
1.6•	абонементный билет «выходного дня»;
1.7•	абонементный билет «на определенные даты (четные/нечетные)»


Вид перевозочного документа выбирается из списка:
•	детализация;
2.1•	ручная кладь по весу;
2.2•	ручная кладь – телевизор;
2.3•	ручная кладь – велосипед;
2.4•	ручная кладь – живность;
2.5•	сбор за оформление в поезде;
2.6•	комсбор за продажу;
2.7•	комсбор за возврат


 case 
  when abonement_type='0' and flg_bil_sbor='B' and flg_bag='0' then '1.1.raz'
  when ABONEMENT_TYPE='1' then '1.2.kol_poezdok' -- на 10-20-60-90 поездок
  when ABONEMENT_TYPE='3' then '1.3.ezednev_mes'
  when ABONEMENT_TYPE='4' then '1.4.ezednev_dni' --абонемент Ежедневно - вообще-то это абонмено на 5-25 дней на 5-20 поездок
  when flg_rab_day='2' and ABONEMENT_TYPE in('7','8') then '1.5.rab_day' --абонементы рабочего дня
  when flg_rab_day='1' and ABONEMENT_TYPE in('5','6') then '1.6.vixodn' --абонементы выходные
  when ABONEMENT_TYPE='2' then '1.7.dati' --абонемент на определённые даты
  
  when flg_bil_sbor='S' then '2.5.sbor_of_pzd' 
  --when par_name='kom_sbor' and flg_bil_sbor='B' then '2.6-7.kom_prod_vozv'
  when flg_bag='1' and bag_vid='Ж' then '2.4.bag_zivn'
  when flg_bag='1' and bag_vid='Т' then '2.2.bag_telev'
  when flg_bag='1' and bag_vid='Р' then '2.1.bag_ruch_ves'
  when flg_bag='1' and bag_vid='В' then '2.3.bag_velos'
  when flg_bag='1' then '2.*.bag_????'
  
  
 end as vid_bil_anal, 




select distinct bag_vid from l3_prig.prig_bil where flg_bag='1'
"Б"
"В" велосипед, вес
"Ж" живность
"Р" 
телевизор



select distinct bag_vid from l3_mes.prig_bil where flg_bag='1'


TRAIN_NUM char(5),


 
--------------------------------------------------------------------------

Вид перевозочного документа выбирается из списка:
•	детализация;
•	ручная кладь по весу;
•	ручная кладь – телевизор;
•	ручная кладь – велосипед;
•	ручная кладь – живность;
•	сбор за оформление в поезде;
•	комсбор за продажу;
•	комсбор за возврат


 case
 when bag_vid='Ж' then '1' -- живность
 when bag_vid='Т' then '2' -- телевизор
 when bag_vid='В' then '3' --велосипед
 when bag_vid='Р' and bag_ves>36 then '4' -- ручная кладь  излишний вес (свыше 36 кило).
 when bag_vid='Р' then '4' -- ручная кладь НЕ излишний вес. Вместо 0 всё равно пишем 4
 else  bag_vid end as bag_vid_,


--------------------------------------------------------------------------

Вид операции выбирается из списка:
•	детализация;
1•	оформление;
2•	возврат.(втч гашение и отказ)

case when oper='O' and oper_g='N' then 1 else 2 end as oper_anal



--------------------------------------------------------------------------


Для отправления
Дополнительные параметры
Категория поезда: выпадающий список:
1•	 Пригородный пассажирский поезд «О»;
2•	Скорый пригородный поезд типа Спутник «С»;
3•	Скорый пригородный поезд без предоставления мест «7»;
4•	Рельсовый автобус 6000-ой нумерации «А»;
5•	Рельсовый автобус 7000-ой нумерации «Б»;
6•	Городские линии «Г»;
7•	Скоростной пригородный поезд «Л»;
Возможность детализации.


train_category

select distinct train_category,prod,klass from l3_mes.prig_bil order by 2,1

"7"	"p"
"О"	"p"
"Г"	"p"
"1"	"m"


"1"	"i" =Л=7
"1"	"m"

"7"	"p" 3
"А"	"p" 4
"Б"	"p" 5
"Г"	"p" 6
"Л"	"p" 7
"О"	"p" 1
"С"	"p" 2












---------- РАССМОТРЕНИЕ ПРАВИЛЬНО ЛИ ПОСЧИТАНЫ K_BIL KOL_BIL

select k_bil,kol_bil,count(*) from l3_mes.prig_itog where k_bil>1 and kol_bil!=1 
--and nom_bil in(select nom_bil from l3_mes.prig_bil where prod!='p')
group by 1,2 

select * from l3_mes.prig_itog where k_bil=2 and kol_bil=33


select * from l3_mes.prig_itog where id=2323945639


select * from l3_mes.prig_bil where nom_bil=7628

select * from l3_mes.prig_mars where nom_mar=3284 order by nom




select * from l3_mes.prig_itog where nom_bil=7628 and nom_mar=3284 and date_zap='2023-04-02'


select k_bil,kol_bil,plata,poteri,round(1000*plata/kol_bil) as cen,* from l3_mes.prig_itog where nom_bil=7628 and nom_mar=3284 and date_zap='2023-04-02'
	order by cen


select sum(k_bil*kol_bil) as kol_bil,sum(k_bil*plata) as plata from l3_mes.prig_itog where nom_bil=7628 and nom_mar=3284 and date_zap='2023-04-02'

--много почти одинаковых билетов с разными ценами, как будто старые автоматы по  продаже.
select PASS_QTY as kol_bil, --в том числе и багажные билеты, по многу штук.
TARIFF_SUM*10 as plata,
DEPARTMENT_SUM*10 as poteri,BENEFIT_CODE as kod_lgt,* from zzz_rawdl2.l2_prig_main where id in (2324106748,2323935704,2323971583)






--ИТОГ - БИЛЕТ КРАТЕН 10, НО НЕ ПОДЕЛЕН НА 10 БЛОКОВ!!! 

select PASS_QTY as kol_bil, --в том числе и багажные билеты, по многу штук.
TARIFF_SUM*10 as plata,
DEPARTMENT_SUM*10 as poteri,BENEFIT_CODE as kod_lgt,* from zzz_rawdl2.l2_prig_main where id=2323945639 and doc_num=1

select TARIFF_SUM as d_plata,DEPARTMENT_SUM as d_poteri,* from zzz_rawdl2.l2_prig_cost where id=2322106418 and doc_num=1

select *
from zzz_rawdl2.l2_prig_main   where --REQUEST_DATE  in (select date_zap from dates) 		and	
id=2324485578 and doc_num=1


select * from zzz_rawdl2.l2_prig_main where id=2322106418


----------------------------- 
 




--------------------------------------------------------------------------
--разборка - сколько денег и билетов не пропорциональны числу билетов??? ВОЗМОЖНО УКРАДЕНО?!

select *,cast(bil_bad*100/kol_bil as dec(10,3)) as pr_bil,--cast(pl_bad*100/plata as dec(10,3)) as pr_plat,
--case when poteri!=0 then cast(pot_bad*100/poteri as dec(10,3)) end as pr_poteti,
cast((pl_bad+pot_bad)*100/(plata+poteri) as dec(10,3)) as pr_deng,
cast(pas_bad*100/kol_pas as dec(10,3)) as pr_pas,cast(pkm_bad*100/kol_pkm as dec(10,3)) as pr_pkm,
case when pl_bad!=0 then cast((pkm_bad*(plata+poteri))/(kol_pkm*(pl_bad+pot_bad)) as dec(10,3)) else 0 end as otn,
cast((plata+poteri)/kol_pkm as dec(10,3)) as cena
from
(select term_dor,lgot,agent,/*flg_bag,*/sum(kol_bil) as kol_bil,sum(plata) as plata,sum(poteri) as poteri,sum(kol_pas) as kol_pas,sum(kol_pkm) as kol_pkm,
sum(case when iz=2 then kol_bil else 0 end) as bil_bad,
sum(case when iz=2 then plata else 0 end) as pl_bad,sum(case when iz=2 then poteri else 0 end) as pot_bad,
 sum(case when iz=2 then kol_pas else 0 end) as pas_bad,
 sum(case when iz=2 then kol_pkm else 0 end) as pkm_bad
from
(select term_dor,iz,flg_bag,lgot,agent,sum(kol_bil) as kol_bil,sum(plata) as plata,sum(poteri) as poteri,sum(kol_pas) as kol_pas,sum(kol_pkm) as kol_pkm,count(*) as kol from
(select case when abs(kol_bil)<2 then 1 else 2 end as iz,yymm ,agent,term_dor,flg_bag,
 kol_bil*k_bil as kol_bil,plata*k_bil as plata,poteri*k_bil as poteri,kol_bil*k_bil*kk as kol_pas,kol_bil*k_bil*kk*srasst as kol_pkm,
 case when flg_bag='1' then 2 when poteri!=0 then 1 else 0 end as lgot
 from l3_mes.prig_itog as a1 join
 (select nom_bil,flg_bag,case when flg_tuda_obr='1' then 1 else 2*k_pas end as kk  from l3_mes.prig_bil) as a2 on a1.nom_bil=a2.nom_bil 
 join (select nom_mar,srasst from l3_mes.prig_mars where nom=1) as a3 on a1.nom_mar=a3.nom_mar
 where yymm=202304 and term_dor='М') as a
group by 1,2,3,4,5) as b group by 1,2,3) as c
order by agent,lgot



ПРОВЕРИТЬ!!!!! id=2325539817   kol_bil=k_bil=78074   plata=poteri=0 
/*select max(k_bil) from l3_mes.prig_itog

select * from l3_mes.prig_itog where k_bil=78074

select * from l3_mes.prig_bil where nom_bil=639
*/






--------------------------------------------------------------------------
--ПРОГРАММА РАСЧЁТА l3_mes.prig_agr_kst НАХОДИТСЯ В PROGR3_1(_MES)  






 select max(k_bil) from l3_mes.prig_itog where plata!=0

select * from l3_mes.prig_itog where k_bil=6270



--- ввод времени начала операции
delete from l3_mes.prig_times where oper='to_agregate_kst';

insert into  l3_mes.prig_times(date_zap,part_zap,shema,rezult,oper,date,time,time2)
select date_zap,part_zap,shema,rezult,oper,date,time,
(cast(substr(time,1,2) as dec(3))*60+cast(substr(time,4,2) as dec(3)))*60+cast(substr(time,7,6) as dec(7,3)) as time2
from
(select date_zap,part_zap,shema,rezult,'to_agregate_kst' as oper,
 current_date as date,substr(cast(clock_timestamp()::time as char(50)),1,12) as time
from
(select date_zap,part_zap,shema,oper,rezult,row_number() over (order by part_zap) as nom
 from  l3_mes.prig_times
 	where oper in('write','prig_work 2_4_itog') and part_zap not in(select part_zap from  l3_mes.prig_times where oper='write_agr_kst' )) as a
	where  nom=1) as b;







insert into l3_mes.prig_analit
(yymm,date_zap,part_zap,date,TERM_DOR,agent,chp,reg,par_name,anal_rasch,anal_vid_bil,anal_oper,train_category,kol_bil,plata,poteri,kol_pas,pass_km)

--Поле date_beg убрать - было нужно лишь для расследования!!!
/*
insert into l3_mes.prig_agr_kst
(yymm,nom_bil,date_zap,part_zap,date,TERM_DOR,agent,chp,kst,reg,par_name,kol_bil,plata,poteri,kol_pas,pass_km
 ,FLG_CHILD,FLG_MILITARY,kod_lgt,ABONEMENT_TYPE,prod)
 */
with

prig as
(select 
 yymm,nom_mar,nom_bil,nom_dat,date_zap,part_zap,date_pr,date_beg,TERM_DOR,agent,chp,stp,stp_reg,k_bil,
 kol_bil/k_bil as kol_bil,plata/k_bil as plata,poteri/k_bil as poteri,kom_sbor/k_bil as kom_sbor,kom_sbor_vz/k_bil as kom_sbor_vz,perebor,nedobor
 from l3_mes.prig_itog where part_zap in (select part_zap from l3_mes.prig_times where oper='to_agregate_kst')
--and nom_bil=253 and term_dor='О' and chp=23  and nom_mar=5497
),
 
isp_bil as
(select nom_bil,flg_ruch,vid_rasch,FLG_CHILD,flg_voin,FLG_MILITARY,flg_lgt,FLG_BSP,FLG_SO,FLG_NU,FLG_TT,
klass,kod_lgt,lgt_reg,flg_bag,bag_vid,bag_ves,flg_rab_day,proc_lgt,ABONEMENT_TYPE,prod,
k_pas,srok_bil,srok_mon,TRAIN_CATEGORY,/*TRAIN_NUM,*/grup_lgt,
cast(FLG_tuda_obr as dec(3)) as k_tuda_obr
from l3_mes.prig_bil where nom_bil in (select distinct nom_bil from  prig)),

isp_bil_anal as
(
select nom_bil,
case
when vid_rasch='6' then '3-bezn' --если Платёжные поручения, безналичные
when vid_rasch='8' and web_id in('0000','-1','NULL') then '2-bank' --если пустой ID эл.площадки, и НЕ Наличка, то это банковская
when vid_rasch='8' and web_id not in('0000','-1','NULL') then '4-elek' --Электронный кошелёк
when vid_rasch='1' and web_id not in('0000','-1','NULL') then '4-el-n' --если непустой ID эл.площадки, и Наличка - тоже Электронный кошелёк
when vid_rasch='1' then '1-nal' --наличка
else vid_rasch||'-neizv' --неизвестно что, льготные
end as anal_rasch,
case 
  when abonement_type='0' and flg_bil_sbor='B' and flg_bag='0' then '1.1.raz' --разовыые
  when ABONEMENT_TYPE='1' then '1.2.ab_k' -- на 10-20-60-90 поездок
  when ABONEMENT_TYPE='3' then '1.3.ez_m' --абонемент на ежедневные поездки месяцы
  when ABONEMENT_TYPE='4' then '1.4.ez_d' --абонемент Ежедневно на количество дней - вообще-то это абонмено на 5-25 дней на 5-20 поездок
  when flg_rab_day='2' and ABONEMENT_TYPE in('7','8') then '1.5.ab_rd' --абонементы рабочего дня
  when flg_rab_day='1' and ABONEMENT_TYPE in('5','6') then '1.6.ab_vd' --абонементы выходные
  when ABONEMENT_TYPE='2' then '1.7.ab_dt' --абонемент на определённые даты
  when flg_bil_sbor='S' then '2.5.sbor' --сбор за оформление в поезде
  --when par_name='kom_sbor' and flg_bil_sbor='B' then '2.6-7.kom_prod_vozv'
  when flg_bag='1' and bag_vid='Ж' then '2.4.bag_z'--багаж живность
  when flg_bag='1' and bag_vid='Т' then '2.2.bag_t' --багаж телевизор
  when flg_bag='1' and bag_vid='Р' then '2.1.bag_r' --багаж ручная кладь вес
  when flg_bag='1' and bag_vid='В' then '2.3.bag_v' -- багаж велосипед
  when flg_bag='1' then '2.*.bag_?' --неизвестный вид багажа
 end as anal_vid_bil, 
case when oper='O' and oper_g='N' then '1' else '2' end as anal_oper,
train_category
from l3_mes.prig_bil),



isp_mar as
(select nom_mar,sto,stn,srasst,marshr,nom,reg,st1,st2,rst,sto_zone,stn_zone,sti,sti_zone,dor,lin,/*date_zap,*/otd,dcs,d_plata,d_poteri,
 max(nom) over (partition by nom_mar) as max_nom 
from l3_mes.prig_mars where nom_mar in (select distinct nom_mar from  prig)),

isp_mar2 as
(select distinct nom_mar,sto,stn,srasst,
 sum(case when nom=1 then reg else 0 end) over (partition by nom_mar) as sto_reg,
 sum(case when nom=max_nom then reg else 0 end) over (partition by nom_mar) as stn_reg
 from isp_mar),

isp_dat as
(select nom_dat,cast(plus_dat as integer) as plus_dat,kpas_day,
 sum(kpas_day) over(partition by nom_dat) as skpas,sum(kpas_day) over(partition by nom_dat order by plus_dat) as sk_pas
from l3_mes.prig_dats where nom_dat in (select distinct nom_dat from  prig)),

prig_dat as
(select yymm,nom_mar,nom_bil,date_zap,part_zap,TERM_DOR,agent,chp,stp,stp_reg,date_otpr,k_tuda_obr,
 sum(kol_pas1*k_bil) as kol_pas1,sum(p_plata*k_bil) as p_plata,sum(p_poteri*k_bil) as p_poteri
 from
(select yymm,nom_mar,a.nom_bil,date_zap,part_zap,TERM_DOR,agent,chp,stp,stp_reg,
 plus_dat,kpas_day,skpas,sk_pas,date_beg+plus_dat as date_otpr,kol_bil*kpas_day as kol_pas1,k_tuda_obr,k_bil,
 --для билета туда-обратно и нечётной суммы надо в конце особое разбиение, без округления
 case when sk_pas=skpas then plata-(round(plata*(sk_pas-kpas_day)/(skpas*k_tuda_obr)))*k_tuda_obr
 else (round(plata*sk_pas/(skpas*k_tuda_obr))-round(plata*(sk_pas-kpas_day)/(skpas*k_tuda_obr)))*k_tuda_obr end as p_plata,
 case when sk_pas=skpas then poteri-(round(poteri*(sk_pas-kpas_day)/(skpas*k_tuda_obr)))*k_tuda_obr
 else (round(poteri*sk_pas/(skpas*k_tuda_obr))-round(poteri*(sk_pas-kpas_day)/(skpas*k_tuda_obr)))*k_tuda_obr end as p_poteri
 from prig as a join isp_bil as b on a.nom_bil=b.nom_bil
 join isp_dat as c on a.nom_dat=c.nom_dat) as a
 group by yymm,nom_mar,nom_bil,date_zap,part_zap,TERM_DOR,agent,chp,stp,stp_reg,date_otpr,k_tuda_obr),



prig_dat_mar2 as
(select yymm,sto,stn,sto_reg,stn_reg,srasst,a.nom_bil,k_tuda_obr,date_zap,part_zap,TERM_DOR,agent,chp,stp,stp_reg,date_otpr,
 sum(kol_pas1) as kol_pas1,sum(p_plata) as p_plata,sum(p_poteri) as p_poteri
 from prig_dat as a join isp_mar2 as b on a.nom_mar=b.nom_mar
 --join isp_bil as c on a.nom_bil=c.nom_bil
group by yymm,sto,stn,sto_reg,stn_reg,srasst,a.nom_bil,k_tuda_obr,date_zap,part_zap,TERM_DOR,agent,chp,stp,stp_reg,date_otpr
),


prig_bil_mar as
(select yymm,a.nom_bil,date_zap,part_zap,date_pr,TERM_DOR,agent,chp,stp,stp_reg,
 sum(kol_bil*k_bil) as kol_bil,sum(plata*k_bil) as plata,sum(poteri*k_bil) as poteri,sum(perebor) as perebor,sum(nedobor) as nedobor,
 sum(kol_bil*k_bil*k_pas*k_tuda_obr) as kol_pas,sum(kol_bil*k_bil*k_pas*srasst*k_tuda_obr) as kol_pkm,
 sum(kom_sbor*k_bil) as kom_sbor,sum(kom_sbor_vz*k_bil) as kom_sbor_vz
 from prig as a join isp_bil as b on a.nom_bil=b.nom_bil
 join isp_mar2 as c on a.nom_mar=c.nom_mar
 group by yymm,a.nom_bil,date_zap,part_zap,date_pr,TERM_DOR,agent,chp,stp,stp_reg
),
 

itog as
(select yymm,b.nom_bil,date_zap,part_zap,date,TERM_DOR,agent,chp,0 as kst,reg,par_name,kol_bil,plata,poteri,kol_pas,pass_km,
 FLG_CHILD,FLG_MILITARY,kod_lgt,ABONEMENT_TYPE,prod,flg_bag
 from
(select yymm,nom_bil,date_zap,part_zap,date,TERM_DOR,agent,chp,/*kst,*/reg,par_name,
 sum(kol_bil) as kol_bil,sum(plata) as plata,sum(poteri) as poteri,sum(kol_pas) as kol_pas,sum(pass_km) as pass_km
  from

(
--По станции и дате продажи	
 select yymm,nom_bil,date_zap,part_zap,date_pr as date,TERM_DOR,agent,chp,stp as kst,stp_reg as reg,
 'prod' as par_name,kol_bil,plata,poteri,kol_pas,kol_pkm as pass_km
 from prig_bil_mar 
 
 union all
 select yymm,nom_bil,date_zap,part_zap,date_pr as date,TERM_DOR,agent,chp,stp as kst,stp_reg as reg,
 'perebor' as par_name,0 as kol_bil,perebor as plata,nedobor as poteri,0 as kol_pas,0 as pass_km
 from prig_bil_mar where perebor!=0 or nedobor!=0
 
 
 union all
 select yymm,nom_bil,date_zap,part_zap,date_pr as date,TERM_DOR,agent,chp,stp as kst,stp_reg as reg,
 'kom_sbor' as par_name,0 as kol_bil,kom_sbor as plata,kom_sbor_vz as poteri,0 as kol_pas,0 as pass_km
 from prig_bil_mar where kom_sbor!=0 or kom_sbor_vz!=0	
 /*
 --сформированные данные - по станции продажи но дате отправлени
 union all
 select yymm,nom_bil,date_zap,part_zap,date_otpr as date,TERM_DOR,agent,chp,stp as kst,stp_reg as reg,
 'sform' as par_name,0 as kol_bil,p_plata as plata,p_poteri as poteri,kol_pas1*k_tuda_obr as kol_pas,kol_pas1*k_tuda_obr*srasst as pass_km
 from prig_dat_mar2 */
 -- по дате и станции отправления
  union all
 select yymm,nom_bil,date_zap,part_zap,date_otpr as date,TERM_DOR,agent,chp,sto as kst,sto_reg as reg,
 'otpr' as par_name,0 as kol_bil,round(p_plata/k_tuda_obr) as plata,round(p_poteri/k_tuda_obr)  as poteri,kol_pas1 as kol_pas,kol_pas1*srasst as pass_km
 from prig_dat_mar2  
 union all
 select yymm,nom_bil,date_zap,part_zap,date_otpr as date,TERM_DOR,agent,chp,stn as kst,stn_reg as reg,
 'otpr' as par_name,0 as kol_bil,p_plata-round(p_plata/k_tuda_obr) as plata,p_poteri-round(p_poteri/k_tuda_obr)  as poteri,kol_pas1 as kol_pas,kol_pas1*srasst as pass_km
 from prig_dat_mar2  where k_tuda_obr=2 
 

 -----------------------------
 ) as a
 group by  yymm,nom_bil,date_zap,part_zap,date,TERM_DOR,agent,chp,/*kst,*/reg,par_name) as b
 join isp_bil as c on b.nom_bil=c.nom_bil
 where kol_bil!=0 or plata!=0 or poteri!=0 or kol_pas!=0 or pass_km!=0),
  
itog2 as
(select * from 
(select yymm,nom_bil,date_zap,part_zap,date,TERM_DOR,agent,chp,kst,reg,kol_bil,plata,poteri,kol_pas,pass_km,
 FLG_CHILD,FLG_MILITARY,kod_lgt,ABONEMENT_TYPE,prod,
 case when flg_bag in('0','?') then par_name
 	when par_name='prod' then 'bag'
    when par_name='perebor' then 'bag_pereb'
 	else '' end as par_name
 from itog) as a where par_name!='')
 
 
,itog_anal as
(select yymm,date_zap,part_zap,date,TERM_DOR,agent,chp,reg,par_name,anal_rasch,anal_vid_bil,anal_oper,train_category,
 sum(kol_bil) as kol_bil,sum(plata) as plata,sum(poteri) as poteri,sum(kol_pas) as kol_pas,sum(pass_km) as pass_km

	from itog2 as a,isp_bil_anal as b where a.nom_bil=b.nom_bil
group by yymm,date_zap,part_zap,date,TERM_DOR,agent,chp,reg,par_name,anal_rasch,anal_vid_bil,anal_oper,train_category
)

 
 
/* 
select yymm,nom_bil,date_zap,part_zap,date,TERM_DOR,agent,chp,kst,reg,par_name,kol_bil,plata,poteri,kol_pas,pass_km,FLG_CHILD,FLG_MILITARY,kod_lgt,ABONEMENT_TYPE,prod
	from itog2;
--select count(*) from itog2  --для просто агрегатов постанционных
*/


--select count(*) from itog_anal

select 
yymm,date_zap,part_zap,date,TERM_DOR,agent,chp,reg,par_name,anal_rasch,anal_vid_bil,anal_oper,train_category,kol_bil,plata,poteri,kol_pas,pass_km
 from itog_anal















-----------------------------------------------------------------------------------------

/*

delete from l3_mes.prig_analit limit 100


select distinct train_category from l3_mes.prig_analit limit 100





delete from l3_mes.prig_times where oper like '%analit%';

 
 select * from l3_prig.prig_times where part_zap=6
 
*/






/**/