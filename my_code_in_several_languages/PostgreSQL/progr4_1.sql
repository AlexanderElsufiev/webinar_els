






--  select * from l3_prig.prig_work;



--ПРОГРАММА ВЫЧИСЛЕНИЯ НАИМЕНЬШИХ ДАННЫХ ДЛЯ ЦО-22
--МАРШРУТ И ВИД БИЛЕТА ОСТАЮТСЯ КАК БЫЛИ, БЕЗ ИЗМЕНЕНИЯ, ИСЧЕЗАЕТ ТОЛЬКО ДАТА МЕСЯЦА

/** /
--- ввод времени начала операции
delete from spb_prig.prig_times where oper='to_agregate_kst';

insert into  spb_prig.prig_times(date_zap,rezult,oper,date,time,time2)
select date_zap,rezult,oper,date,time,
(cast(substr(time,1,2) as dec(3))*60+cast(substr(time,4,2) as dec(3)))*60+cast(substr(time,7,6) as dec(7,3)) as time2
from
(select date_zap,rezult,'to_agregate_kst' as oper,
 current_date as date,substr(cast(clock_timestamp()::time as char(50)),1,12) as time
from
(select date_zap,rezult,row_number() over (order by date_zap) as nom
 from  spb_prig.prig_times
 	where oper='write' and date_zap not in(select date_zap from  spb_prig.prig_times where oper='write_agr_kst' )) as a
	where  nom=1) as b;
----------------------------------------------

--select * from spb_prig.prig_times where oper='to_agregate_kst' 

--update spb_prig.prig_times set date_zap='2021-08-20' where oper='to_agregate_kst' 


-- delete from spb_prig.prig_agr_kst;
----------------------------------------------
/ **/

select 
--1	Идентификатор задачи/ номер таблицы	Char	4
--2	Порядковый номер строки	
extract(year from date_pr) as year, --3	Год операции продажи/возврата	Char	4
extract(month from date_pr) as mon,	--Номер месяца операции (продажи/возврата)	Char	2
term_dor, --5	Код дороги ИВЦ	Char	3
--6	Код дороги производства операции	Char	3 20
--7	Код дороги формирования	Char	3
stp,--8	Код станции операции продажи/возврата	Char	9
chp,--9	Код перевозчика и структурное подразделение. 	Char	9
stp_reg,--10	Код субъекта РФ производства операции (при отсутствии – ‘00’)	Char	2
--11	Код  субъекта ОКАТО  производства операции (при отсутствии – ‘00000’)	Char	5 48
extract(year from date_otpr)*100+extract(month from date_otpr) as ym_otpr,--12	Год, месяц отправления. Формат: ГГММ	Char	4
sto.dor as sto_dor--13	Код дороги отправления	Char	3
sto.otd as sto_otd, --14	Номер отделения отправления	Char	2
sto,--15	Код станции отправления 	Char	7
sto.sf as sto_sf, --16	Код субъекта РФ отправления (при отсутствии – ‘00’)	Char	2
sto.sf.okato as sto_okato,--17	Код субъекта ОКАТО отправления (при отсутствии – ‘00000’)	Char	5 71
sto.nopr as sto_nopr,--18	Код района отправления	Char	3
--???--19	Категория поезда:
/*1 – пригородные пассажирские,
2 – скорые дальние поезда без услуг,
3 – скорые дальние поезда с услугами,
4 – скорые пригородные с предоставлением мест (7XXX(8xx-c АМГ)),
5 – скорые пригородные поезда без предоставления мест (7ХХХ),
6 – скорые пригородные поезда типа «Спутник» (7ХХХ),
7 – рельсовые автобусы 7000-е,
8 – рельсовые автобусы 6000-е
9 – городские линии
Л – скоростной пригородный поезд	Char	1 */
klass--20	Класс обслуживания: «01» - 1 класс, «02» - 2 класс, «03» - 3 класс 	Char	2

case when FLG_tuda_obr='1' then '2'
	when ABONEMENT_TYPE='0' then '3'
	...
	when flg_bag='1' then '6' ... end as vid_bil
--21	Вид билета: 
/*«1» – Проездной документ (для 800-х дальних и пригородных поездов)
«2» -Разовый “туда”,
«3» -Разовый “туда+обратно”,
«4» -Билет выходного дня,
«5» -Абонементный,
«6» - Перевозочный документ (для багажа),
«7» – Перевозочный документ (для грузобогажа),
«8» - Квитанция за оформление в поезде.	ABONEMENT_TYPE +
FLG_tuda_obr
+  flg_bag	1 */

case when flg_bsp='1' then '4' when kod_lgt>0 then '3' when flg_child='1' then '2' else '1' end as prizn_pas,
--22	Признак пассажира: ‘1’-полный, ‘2’-детский,’3’- льготный, «4»-бесплатный. 	Char	1
--???--23	Вид тарифа:’1’-зонный, ‘3’-покилометовый, ‘4’ – общий	Char	1 80
kod_lgt,--24	Код льготы дальнего/пригородного сообщения	Char	4
--???--25	Вид расчета: 
/*«1» – льготный (все льготные и 100% и 50% и т.д. и воинские)
«2» – наличный (и полные, и детские)
«3» – б/нал. Банковские карты
«4» – б/нал. Интернет
«5» – б/нал для юридических лиц 
«6» - электронный кошелек	Char	1 */
--???--26	Признак включения в отчетность	Char	2
stn.dor, --27	Код дороги назначения	Char	3 90
stn.otd, --28	Номер отделения назначения	Char	2
stn.sf, --29	Номер субъекта РФ назначения. Пока «0»	Char	2
stn.sf.okato, --30	Код субъекта назначения ОКАТО	Char	5
stn.nopr,--31	Код района назначения	Char	3 102
rasst, --32	Общее расстояние следования	Smallint	2
kol_pas (сумма замесяц отправки)--33	Кол-во пассажиров для видов билета «1-5» или кол-во багажа/грузобагажа (кг) для вида билета «6» и «7»	Decimal	9
0,--34	Сумма других государств НДЕ (гривенники), руб.	Decimal	11
0,--35	Сумма других государств НДЕ (Шв. Сантимы), руб.	Decimal	11
plata,--36	Сумма в НДЕ по территории РФ (гривенники)*. 	Decimal	11
0,--37	Сумма локомотивной составляющей в НДЕ. Сейчас 0.	Decimal	11
0,--38	Сумма инфраструктурной составляющей в НДЕ. Сейчас 0.	Decimal	11
0,--39	Вокзальная составляющая в НДЕ (комиссионные сборы)	Decimal	11
0,--40	Вагонная составляющая в НДЕ (плацкарта)	Decimal	11
0,--41	Сумма НДС в НДЕ	Decimal	11
0,--42	Страховой сбор в НДЕ	Decimal	11
0,--43	Сумма составляющей за класс обслуживания в НДЕ. 	Decimal	11
poteri,--44	Сумма выпадающего дохода в НДЕ по территории РФ (гривенники)	Decimal	11
0,--45	Сумма выпадающего дохода в НДЕ. Локомотивная составляющая 	Decimal	11
0,--46	Сумма выпадающего дохода в НДЕ. Инфраструктурная составляющая. 	Decimal	11
0,--47	Сумма выпадающего дохода в НДЕ. Вокзальная  составляющая (комиссионные сборы)	Decimal	11
0,--48	Сумма выпадающего дохода в НДЕ. Вагонная составляющая 	Decimal	11
0,--49	Сумма выпадающего страхового сбора	Decimal	11
0,--50	Сумма выпадающего дохода в НДЕ. За класс обслуживания 	Decimal	11
kol_bil,--51	Количество оформленных документов	Decimal	9
52	Способ оформления документов:
/*1 – через систему «Экспресс»;
2 – через АСОКУПЭ-Л;
3 – по ручной технологии;
4 – через автономную билетопечатающую технику;
5 – через иные автоматизированные системы;
6 – ТТС.
7 – веб-сайт
8 – мобильное приложение веб-портала ОАО «РЖД» ( Включая ООО «УФС»)
9 (А/B/C…) –   мобильные приложения пригородных пассажирских компаний	Char	1 103*/
agent,--53	Код агента продажи	Char	4 

 
stn, --54	Код станции назначения	Char	7 110
55	Вид абонементного билета:
«1» - билет «ежедневно»;
«2» - билет «выходного дня»;
«3» - билет «рабочего дня»;
«4» - билет на определенные даты;
«5» - билет на количество поездок;
«6» - билет на определенные нечетные даты,
«7» - билет на определенные четные даты,
	ABONEMENT_TYPE	1
56	Срок действия абонементных билетов:
000 – срок действия не указан;
001 – 1 месяц;
002 – 2 месяца;
003 – 3 месяца;
004 – 4 месяца;
005 – 5 месяцев;
006 – 6 месяцев;
012 – 12 месяцев;
105 – 5 дней;
106 – 6 дней;
107 – 7 дней;
108 – 8 дней;
109 – 9 дней;
110 – 10 дней;
111 – 11 дней;
112 – 12 дней;
113 – 13 дней;
114 – 14 дней;
115 – 15 дней;
116 – 16 дней;
120 – 20 дней;
125 – 25 дней;
410 – 10 поездок;
420 – 20 поездок;
460 – 60 поездок;
490 – 90 поездок.	,srok_bil srok_mon 	3
bag_vid (fun("Р","В","Т","Ж")), --57	Вид ручной клади для вида билета «6»:
/*«1» - живность;
«2» - телевизор;
«3» - велосипед;
«4» - излишний вес р.клади в килограммах	Char	1 */
 

58	Принадлежность железнодорожника.
Для группы льгот 22:
0 – документ выдан по транспортному требованию РЖД;
1 – документ выдан по транспортному требованию ФПК	Char	1
59	Категория пассажира Ф,Д
Для группы льгот 22:
0 – документ выдан по транспортному требованию РЖД сотруднику РЖД (не Ф,Д);
1 – документ выдан по транспортному требованию РЖД, сотруднику сторонней организации (Ф,Д)	Char	1
60	Код субагента	Char	3 120
61	МЦД:
0 – не МЦД
1 – МЦД1
2 – МЦД2 	Char	1
62	Расстояние по МЦД	Smallint	2
63	Вид перевозки:
0 – не МЦД
1 –внутри МЦД (начальная и конечная станция МЦД)
2 – въезд (конечная станция МЦД)
3 – выезд (начальная станция МЦД)
4 – транзит (начальная и конечная станция не МЦД)
	Char	1 124





insert into spb_prig.prig_agr_kst
(YYYYMM,nom_bil,date_zap,date,date_beg,TERM_DOR,term_pos,term_trm,agent,chp,kst,reg,par_name,param1,param2,FLG_CHILD,FLG_MILITARY,kod_lgt,ABONEMENT_TYPE)

/ **/




--select * from spb_prig.prig_times where date_zap='2021-09-17'





with

prig as
(select yyyymm,nom_mar,nom_bil,nom_dat,date_zap,date_beg,date_pr,TERM_DOR,term_pos,term_trm,agent,chp,stp,stp_reg,kol_bil,plata,poteri,perebor,nedobor,k_bil,
 extract(year from date_pr)*100+extract(month from date_pr) as ym_pr,
  extract(year from date_beg)*100+extract(month from date_beg) as ym_otpr
      --YYYYMM,nom_mar,nom_bil,nom_dat,date_zap,date_beg,date_pr,TERM_DOR,term_pos,term_trm,agent,chp,stp,stp_reg,k_bil,kol_bil,plata,poteri,perebor,nedobor
 from spb_prig.prig_itog where yyyymm=202109
),

dats as
(select distinct date_beg,nom_dat from prig),

isp_dat as
(select nom_dat,cast(plus_dat as integer) as plus_dat,kpas_day,
 sum(kpas_day) over(partition by nom_dat) as skpas,sum(kpas_day) over(partition by nom_dat order by plus_dat) as sk_pas
from spb_prig.prig_dats where nom_dat in (select distinct nom_dat from  prig)),

dats2 as

(select date_beg,nom_dat,ym_otpr,sum(kpas_day) as kpas_mon from
(select date_beg,nom_dat,date_otpr,kpas_day,
 extract(year from date_otpr)*100+extract(month from date_otpr) as ym_otpr
 from
(select date_beg,nom_dat,date_beg+plus_dat as date_otpr,kpas_day from
(select date_beg,a.nom_dat,cast(plus_dat as integer) as plus_dat,kpas_day from dats as a,spb_prig.prig_dats as b where a.nom_dat=b.nom_dat) as c) as d) as e
group by 1,2,3),


prig_prod as
(select yyyymm,nom_mar,nom_bil,ym_pr,ym_otpr,TERM_DOR,term_pos,term_trm,agent,chp,stp,stp_reg,
 sum(kol_bil) as kol_bil,sum(plata) as plata,sum(poteri) as poteri,sum(perebor) as perebor,sum(nedobor) as nedobor
from prig group by yyyymm,nom_mar,nom_bil,ym_pr,ym_otpr,TERM_DOR,term_pos,term_trm,agent,chp,stp,stp_reg),

prig_otpr as
(select yyyymm,nom_mar,nom_bil,ym_pr,ym_otpr,TERM_DOR,term_pos,term_trm,agent,chp,stp,stp_reg,
 sum(kol_bil*kpas_mon) as kol_pas
from
(select yyyymm,nom_mar,nom_bil,a.nom_dat,date_zap,a.date_beg,date_pr,TERM_DOR,term_pos,term_trm,agent,chp,stp,stp_reg,kol_bil,plata,poteri,perebor,nedobor,k_bil,
 ym_pr,b.ym_otpr,kpas_mon
      --YYYYMM,nom_mar,nom_bil,nom_dat,date_zap,date_beg,date_pr,TERM_DOR,term_pos,term_trm,agent,chp,stp,stp_reg,k_bil,kol_bil,plata,poteri,perebor,nedobor
from prig as a join dats2 as b on a.date_beg=b.date_beg and a.nom_dat=b.nom_dat) as c
group by  yyyymm,nom_mar,nom_bil,ym_pr,ym_otpr,TERM_DOR,term_pos,term_trm,agent,chp,stp,stp_reg),
 
prig_all as
(select yyyymm,nom_mar,nom_bil,ym_pr,ym_otpr,TERM_DOR,term_pos,term_trm,agent,chp,stp,stp_reg,
 sum(kol_bil) as kol_bil,sum(plata) as plata,sum(poteri) as poteri,sum(perebor) as perebor,sum(nedobor) as nedobor,sum(kol_pas) as kol_pas
from 
(select yyyymm,0 as nom_mar,nom_bil,ym_pr,/*ym_pr as*/ ym_otpr,TERM_DOR,term_pos,term_trm,agent,chp,stp,stp_reg,
 kol_bil,plata,poteri,perebor,nedobor,0 as kol_pas
from prig_prod
 union all
 select yyyymm,nom_mar,nom_bil,ym_pr,ym_otpr,TERM_DOR,'0' as term_pos,'0' as term_trm,agent,chp,0 as stp,stp_reg,
 0 as kol_bil,0 as plata,0 as poteri,0 as perebor,0 as nedobor,kol_pas
from prig_otpr)as a group by yyyymm,nom_mar,nom_bil,ym_pr,ym_otpr,TERM_DOR,term_pos,term_trm,agent,chp,stp,stp_reg)
 
 
--select count(*) from dats union all select count(*) from dats2 --954 2009
 
 select count(*) from prig
 union all 
 select count(*) from prig_all 
 -- 2021-08 == 2439617 436664 =5.58    2439617 434951   2439617 300650
 -- 2021-09 == 2405935 440283 =5.46    2405935 438729   2405935 314348
 /*
 202107	636556
202108	3585121
202109	3589502
202110	3306230
202111	491
202203	718915
202204	3406817
202205	649
*/ 
 
 /*
isp_bil as
(select nom_bil,flg_ruch,vid_rasch,FLG_CHILD,flg_voin,FLG_MILITARY,flg_lgt,FLG_BSP,FLG_SO,FLG_NU,FLG_TT,
klass,kod_lgt,lgt_reg,flg_bag,bag_vid,bag_ves,flg_rab_day,proc_lgt,ABONEMENT_TYPE,
k_pas,srok_bil,srok_mon,TRAIN_CATEGORY,TRAIN_NUM,grup_lgt,
cast(FLG_tuda_obr as dec(3)) as k_tuda_obr
from spb_prig.prig_bil where nom_bil in (select distinct nom_bil from  prig)),



isp_mar as
(select nom_mar,sto,stn,srasst,marshr,nom,reg,st1,st2,rst,sto_zone,stn_zone,sti,sti_zone,dor,lin,date_zap,otd,dcs,d_plata,d_poteri,
 max(nom) over (partition by nom_mar) as max_nom 
from spb_prig.prig_mars where nom_mar in (select distinct nom_mar from  prig)),

isp_mar2 as
(select distinct nom_mar,sto,stn,srasst,
 sum(case when nom=1 then reg else 0 end) over (partition by nom_mar) as sto_reg,
 sum(case when nom=max_nom then reg else 0 end) over (partition by nom_mar) as stn_reg
 from isp_mar),

isp_dat as
(select nom_dat,cast(plus_dat as integer) as plus_dat,kpas_day,
 sum(kpas_day) over(partition by nom_dat) as skpas,sum(kpas_day) over(partition by nom_dat order by plus_dat) as sk_pas
from spb_prig.prig_dats where nom_dat in (select distinct nom_dat from  prig)),

prig_dat as
(select YYYYMM,nom_mar,nom_bil,date_zap,TERM_DOR,term_pos,term_trm,agent,chp,stp,stp_reg,date_beg,date_otpr,
 sum(kol_pas1) as kol_pas1,sum(p_plata) as p_plata,sum(p_poteri) as p_poteri
 from
(select YYYYMM,nom_mar,a.nom_bil,date_zap,date_beg,TERM_DOR,term_pos,term_trm,agent,chp,stp,stp_reg,
 plus_dat,kpas_day,skpas,sk_pas,date_beg+plus_dat as date_otpr,kol_bil*kpas_day as kol_pas1,
 --для билета туда-обратно и нечётной суммы надов конце особое разбиение, без округления
 case when sk_pas=skpas then plata-(round(plata*(sk_pas-kpas_day)/(skpas*k_bil*k_tuda_obr)))*k_bil*k_tuda_obr
 else (round(plata*sk_pas/(skpas*k_bil*k_tuda_obr))-round(plata*(sk_pas-kpas_day)/(skpas*k_bil*k_tuda_obr)))*k_bil*k_tuda_obr end as p_plata,
 case when sk_pas=skpas then poteri-(round(poteri*(sk_pas-kpas_day)/(skpas*k_bil*k_tuda_obr)))*k_bil*k_tuda_obr
 else (round(poteri*sk_pas/(skpas*k_bil*k_tuda_obr))-round(poteri*(sk_pas-kpas_day)/(skpas*k_bil*k_tuda_obr)))*k_bil*k_tuda_obr end as p_poteri
 from prig as a join isp_bil as b on a.nom_bil=b.nom_bil
 join isp_dat as c on a.nom_dat=c.nom_dat) as a
 group by YYYYMM,nom_mar,nom_bil,date_zap,TERM_DOR,term_pos,term_trm,agent,chp,stp,stp_reg,date_beg,date_otpr),



prig_dat_mar2 as
(select YYYYMM,sto,stn,sto_reg,stn_reg,srasst,a.nom_bil,k_tuda_obr,date_zap,TERM_DOR,term_pos,term_trm,agent,chp,stp,stp_reg,date_beg,date_otpr,
 sum(kol_pas1) as kol_pas1,sum(p_plata) as p_plata,sum(p_poteri) as p_poteri
 from prig_dat as a join isp_mar2 as b on a.nom_mar=b.nom_mar
 join isp_bil as c on a.nom_bil=c.nom_bil
group by YYYYMM,sto,stn,sto_reg,stn_reg,srasst,a.nom_bil,k_tuda_obr,date_zap,TERM_DOR,term_pos,term_trm,agent,chp,stp,stp_reg,date_beg,date_otpr
)


,prig_bil_mar as
(select YYYYMM,a.nom_bil,date_zap,date_pr,date_beg,TERM_DOR,term_pos,term_trm,agent,chp,stp,stp_reg,
 sum(kol_bil) as kol_bil,sum(plata) as plata,sum(poteri) as poteri,sum(perebor) as perebor,sum(nedobor) as nedobor,
 sum(kol_bil*k_pas*k_tuda_obr) as kol_pas,sum(kol_bil*k_pas*srasst*k_tuda_obr) as kol_pkm
 from prig as a join isp_bil as b on a.nom_bil=b.nom_bil
 join isp_mar2 as c on a.nom_mar=c.nom_mar
 group by YYYYMM,a.nom_bil,date_zap,date_pr,date_beg,TERM_DOR,term_pos,term_trm,agent,chp,stp,stp_reg
)
 

,itog as
(select YYYYMM,b.nom_bil,date_zap,date,date_beg,TERM_DOR,term_pos,term_trm,agent,chp,kst,reg,par_name,param1,param2,
 FLG_CHILD,FLG_MILITARY,kod_lgt,ABONEMENT_TYPE,flg_bag
 from
(select YYYYMM,nom_bil,date_zap,date,date_beg,TERM_DOR,term_pos,term_trm,agent,chp,kst,reg,par_name,
 sum(param1) as param1,sum(param2) as param2
 from

(select YYYYMM,nom_bil,date_zap,date_pr as date,date_beg,TERM_DOR,term_pos,term_trm,agent,chp,stp as kst,stp_reg as reg,
 'kol_bil' as par_name,kol_bil as param1,0 as param2 --,kol_bil,plata,poteri,perebor,nedobor,kol_pas,kol_pkm
 from prig_bil_mar
 union all
 select YYYYMM,nom_bil,date_zap,date_pr as date,date_beg,TERM_DOR,term_pos,term_trm,agent,chp,stp as kst,stp_reg as reg,
 'plata' as par_name,plata as param1,poteri as param2 --,kol_bil,plata,poteri,perebor,nedobor,kol_pas,kol_pkm
 from prig_bil_mar
 
 union all
 select YYYYMM,nom_bil,date_zap,date_pr as date,date_beg,TERM_DOR,term_pos,term_trm,agent,chp,stp as kst,stp_reg as reg,
 'perebor' as par_name,perebor as param1,nedobor as param2 --,kol_bil,plata,poteri,perebor,nedobor,kol_pas,kol_pkm
 from prig_bil_mar
 
 union all
 select YYYYMM,nom_bil,date_zap,date_pr as date,date_beg,TERM_DOR,term_pos,term_trm,agent,chp,stp as kst,stp_reg as reg,
 'pr_pas' as par_name,kol_pas as param1,kol_pkm as param2 --,kol_bil,plata,poteri,perebor,nedobor,kol_pas,kol_pkm
 from prig_bil_mar
 ----------------------------- 
 union all
 select YYYYMM,nom_bil,date_zap,date_otpr as date,date_beg,TERM_DOR,'0' as term_pos,'0' as term_trm,agent,chp,stp as kst,stp_reg as reg,
 'sf_pas' as par_name,kol_pas1*k_tuda_obr as param1,kol_pas1*k_tuda_obr*srasst as param2 
 from prig_dat_mar2 
 union all
 select YYYYMM,nom_bil,date_zap,date_otpr as date,date_beg,TERM_DOR,'0' as term_pos,'0' as term_trm,agent,chp,stp as kst,stp_reg as reg,
 'sf_plat' as par_name,p_plata as param1,p_poteri as param2 
 from prig_dat_mar2 
 -----------------------------
  union all
 select YYYYMM,nom_bil,date_zap,date_otpr as date,date_beg,TERM_DOR,'0' as term_pos,'0' as term_trm,agent,chp,sto as kst,sto_reg as reg,
 'kol_pas' as par_name,kol_pas1 as param1,kol_pas1*srasst as param2 
 from prig_dat_mar2 
  union all
 select YYYYMM,nom_bil,date_zap,date_otpr as date,date_beg,TERM_DOR,'0' as term_pos,'0' as term_trm,agent,chp,stn as kst,stn_reg as reg,
 'kol_pas' as par_name,kol_pas1 as param1,kol_pas1*srasst as param2 
 from prig_dat_mar2  where k_tuda_obr=2 
 
  union all
 select YYYYMM,nom_bil,date_zap,date_otpr as date,date_beg,TERM_DOR,'0' as term_pos,'0' as term_trm,agent,chp,sto as kst,sto_reg as reg,
 'p_plata' as par_name,round(p_plata/k_tuda_obr) as param1,round(p_poteri/k_tuda_obr)  as param2 
 from prig_dat_mar2 
  union all
 select YYYYMM,nom_bil,date_zap,date_otpr as date,date_beg,TERM_DOR,'0' as term_pos,'0' as term_trm,agent,chp,stn as kst,stn_reg as reg,
 'p_plata' as par_name,p_plata-round(p_plata/k_tuda_obr) as param1,p_poteri-round(p_poteri/k_tuda_obr)  as param2 
 from prig_dat_mar2  where k_tuda_obr=2
 -----------------------------
 ) as a
 group by  YYYYMM,nom_bil,date_zap,date,date_beg,TERM_DOR,term_pos,term_trm,agent,chp,kst,reg,par_name) as b
 join isp_bil as c on b.nom_bil=c.nom_bil
 where param1!=0 or param2!=0),
  
itog2 as
(select * from 
(select YYYYMM,nom_bil,date_zap,date,date_beg,TERM_DOR,term_pos,term_trm,agent,chp,kst,reg,param1,param2,
 FLG_CHILD,FLG_MILITARY,kod_lgt,ABONEMENT_TYPE,
 case when flg_bag='0' then par_name
 	when par_name='kol_bil' then 'bag_bil'
 	when par_name='plata' then 'bag_plat'
 	else '' end as par_name
 from itog) as a where par_name!='')
 
 
select YYYYMM,nom_bil,date_zap,date,date_beg,TERM_DOR,term_pos,term_trm,agent,chp,kst,reg,par_name,param1,param2,FLG_CHILD,FLG_MILITARY,kod_lgt,ABONEMENT_TYPE
	from itog2;


 
/**/ 
 
insert into  spb_prig.prig_times(date_zap,rezult,oper,date,time,time2)
with 
dat as (select date_zap from spb_prig.prig_times where oper='to_agregate_kst')

select date_zap,rezult,oper,date,time,
(cast(substr(time,1,2) as dec(3))*60+cast(substr(time,4,2) as dec(3)))*60+cast(substr(time,7,6) as dec(7,3)) as time2
from
(select date_zap,rezult,'write_agr_kst' as oper,
 current_date as date,substr(cast(clock_timestamp()::time as char(50)),1,12) as time
 from
(select count(*) as rezult from spb_prig.prig_agr_kst where date_zap in (select date_zap from dat)) as a,dat as b) as c;

update spb_prig.prig_times set oper='agregate_kst' where oper='to_agregate_kst';




select * from spb_prig.prig_times where oper in ('to_agregate_kst','agregate_kst','write_agr_kst') ; -- order by date_zap descending 


--  delete from  spb_prig.prig_agr_kst;
--  delete from spb_prig.prig_times where oper in ('to_agregate','to_agregate_kst','write_agr_kst');

/ **/



