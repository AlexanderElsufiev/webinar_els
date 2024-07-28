
select yyyymm,count(*) from spb_prig.prig_agr_kst group by 1;
/*
202108	5428201
202109	5902593
202110	5782238
*/

select yyyymm,count(*) from 
(select YYYYMM,date_zap,date,TERM_DOR,agent,chp,kst,reg,FLG_CHILD,FLG_MILITARY,kod_lgt,ABONEMENT_TYPE, nom_bil,
	dor,lin,predpr,par_name,sum(param) as param
from spb_prig.prig_agr_kst 
 group by YYYYMM,date_zap,date,TERM_DOR,agent,chp,kst,reg,FLG_CHILD,FLG_MILITARY,kod_lgt,ABONEMENT_TYPE,nom_bil,
	dor,lin,predpr,par_name) as a
	group by 1 order by 1;
/*
202108	1957632
202109	2103004
202110	2105036

C nom_bil=
202108	3947779
202109	4276854
202110	4216815
*/	

select count(*) as kol from spb_prig.prig_agr_kst /*  18.249.740 */
select par_name,count(*) as kol from spb_prig.prig_agr_kst group by 1 order by 1
/*"bag_bil   "	73275
"bag_plata "	73272
"bag_poteri"	1
"d_plata   "	1164955
"d_poteri  "	2328737
"kol_bil   "	1652055
"kol_pas   "	3824496
"kol_pkm   "	3824496
"nedobor   "	13317
"perebor   "	8121
"plata     "	665357
"poteri    "	1317548
"sf_pas    "	1652055
"sf_pkm    "	1652055*/


select distinct ABONEMENT_TYPE from spb_prig.prig_agr_kst order by 1


select YYYYMM,count(*) from 
(select distinct YYYYMM,date_zap,date,TERM_DOR,agent,chp,kst,reg,/*FLG_CHILD,FLG_MILITARY,*/kod_lgt,ABONEMENT_TYPE, nom_bil,
	dor,lin,predpr,par_name
from (select *,extract(month from date) as mon from spb_prig.prig_agr_kst) as aa) as a
	group by 1 order by 1;

/*
mon
202108	446902
202109	450760
202110	475535
mon + nom_bil
202108	1101518
202109	1148371
202110	1155848


date
202108	1892394
202109	2056136
202110	2058003

all
202108	3947779
202109	4276854
202110	4216815
*/





--Вывод Маршруты пары станций

select count(*) as kol from
(
	
select a.YYYYMM,
a.DEPARTURE_STATION as sto,a.ARRIVAL_STATION as stn,
b.DEPARTURE_STATION as st1,b.ARRIVAL_STATION as st2,ROUTE_NUM as marshr,
 cast(ROUTE_DISTANCE as dec(7)) as rasst,
sum(PASS_QTY*(case when oper_g='G' then -1 else 1 end) ) as kol_bil --в том числе и багажные билеты, по многу штук.
from rawdl2.l2_prig_cost as b join rawdl2.l2_prig_main as a on a.id=b.id
group by 1,2,3,4,5,6,7

) as c

-- 124313



ID,DOC_NUM,doc_reg as nom,
--YYYYMM,REQUEST_DATE,REQUEST_NUM,TERM_POS,TERM_DOR,TERM_TRM,ARXIV_CODE,REPLY_CODE, --не нужны
	ROUTE_NUM as marshr,cast(ROUTE_DISTANCE as dec(7)) as rasst,
	sum(cast(ROUTE_DISTANCE as dec(7))) over(partition by ID,DOC_NUM) as srasst,
	TARIFF_SUM as d_plata,DEPARTMENT_SUM as d_poteri,
	DEPARTURE_STATION as st1,ARRIVAL_STATION as st2,
 case when id=275367223*0 then 0 else REGION_CODE end as reg,
	max(doc_reg) over (partition by ID,DOC_NUM) as max_nom,
	sum(TARIFF_SUM) over (partition by ID,DOC_NUM) as s_plata,
	sum(DEPARTMENT_SUM) over (partition by ID,DOC_NUM) as s_poteri 
from rawdl2.l2_prig_cost


select * 
from rawdl2.l2_prig_cost
fetch first 100 rows only




prig_main as(select
--REQUEST_NUM,TERM_TRM,ARXIV_CODE,REPLY_CODE,REQUEST_TIME,REQUEST_TYPE,REQUEST_SUBTYPE,ELS_CODE,PAYAGENT_ID,WEB_ID,TICKET_SER,TICKET_NUM,
--DOC_TYPE,RETURN_DATE,FEE_SUM,FEE_VAT,REFUNDFEE_SUM,REFUNDDEPART_SUM,DATE_TEMPLATE, --уходят без переработки, совсем, за ненадобностью
--OPER,OPER_G,FLG_2WAYTICKET,FLG_1WAYTICKET,SEATSTICK_LIMIT -- ушли с переработкой
--TICKET_ENDDATE --ушло ввиду откровенной грязи

ID,DOC_NUM,YYYYMM,REQUEST_DATE as date_zap,TERM_POS,TERM_DOR,OPERATION_DATE as date_pr,TICKET_BEGDATE as date_beg,
TRAIN_CATEGORY,TRAIN_NUM,

case when oper_g='G' then -1 else 1 end as koef, --если гашение, то взять с коэф=-1 все параметры
REGISTRATION_METHOD as flg_ruch, --флаг 0=ручник, 1=экспресс
AGENT_CODE as agent, --агент продажи
CARRIAGE_CODE as chp,--перевозчик
PAYMENTTYPE as vid_rasch, --вид расчёта (=1,6,8)

SALE_STATION as stp,REGION_CODE as stp_reg,
DEPARTURE_STATION as sto,DEPARTURE_ZONE as sto_zone,
ARRIVAL_STATION as stn,ARRIVAL_ZONE as stn_zone,
INTERMED_STATION as sti,INTERMED_ZONE as sti_zone,

FLG_CHILD,FLG_MILITARY,FLG_BENEFIT as flg_lgt,FLG_BSP,FLG_SO,FLG_NU,FLG_TT,
MILITARY_CODE as flg_voin,

CARRIAGE_CLASS as klass, --некий класс
BENEFIT_CODE as kod_lgt,
BENEFIT_REGION as lgt_reg,

FLG_CARRYON as flg_bag,
case when CARRYON_TYPE='' then '-' else CARRYON_TYPE end as bag_vid,
CARRYON_WEIGHT /* *(case when oper_g='G' then -1 else 1 end)*/ as bag_ves, --в поле указан вес одного багажа, а не всех, и не возврата

case when FLG_2WAYTICKET='1' then '2' 
	when FLG_1WAYTICKET='1' then '1' else '2' end as FLG_tuda_obr, --признак туда=1, туда-обратно=2
case when FLG_2WAYTICKET='1' then 2 
	when FLG_1WAYTICKET='1' then 1 else 2 end as k_tuda_obr, --коэф туда=1, туда-обратно=2

PASS_QTY*(case when oper_g='G' then -1 else 1 end) as kol_bil, --в том числе и багажные билеты, по многу штук.
TARIFF_SUM*(case when oper_g='G' then -1 else 1 end) as plata,
DEPARTMENT_SUM*(case when oper_g='G' then -1 else 1 end) as poteri,
(case when TOTAL_SUM=0 then 0
	when abs(TARIFF_SUM+DEPARTMENT_SUM-TOTAL_SUM)<abs(TARIFF_SUM-TOTAL_SUM) then TOTAL_SUM-TARIFF_SUM-DEPARTMENT_SUM
	else TOTAL_SUM-TARIFF_SUM end)
*(case when oper_g='G' then -1 else 1 end) as perebor,

case when FLG_BSP='1' then 100 
	when BENEFIT_PERCENT=0 then 0
	else 100-BENEFIT_PERCENT end as proc_lgt,

ABONEMENT_TYPE, --тип абонемента
cast(case when ABONEMENT_TYPE='0' then 1
	when ABONEMENT_TYPE='1' then SEATSTICK_LIMIT/2
	when ABONEMENT_TYPE='2' then SEATSTICK_LIMIT
	when ABONEMENT_TYPE='3' then SEATSTICK_LIMIT*25	 
	when ABONEMENT_TYPE='4' and SEATSTICK_LIMIT=5 then 5 --заплатка
	when ABONEMENT_TYPE='4' then SEATSTICK_LIMIT*0.8
	when ABONEMENT_TYPE='5' then SEATSTICK_LIMIT*6
	when ABONEMENT_TYPE='6' then SEATSTICK_LIMIT*0
	when ABONEMENT_TYPE='7' then SEATSTICK_LIMIT*21
	when ABONEMENT_TYPE='8' then 
		case when SEATSTICK_LIMIT=15 then 10
		when SEATSTICK_LIMIT=25 then 18
		else SEATSTICK_LIMIT*0.7 end
end as dec(5)) as k_pas, --количество поездок по 1 билету в 1 сторону за весь срок действия билета

case when ABONEMENT_TYPE in('5','6') then '1' --выходного дня
	 when ABONEMENT_TYPE in('7','8') then '2' --рабочего дня
	else '0' end as flg_rab_day,

case when ABONEMENT_TYPE='0' then 1
	when ABONEMENT_TYPE='1' then 
		case when SEATSTICK_LIMIT=60 then 120
		when SEATSTICK_LIMIT=90 then 180
		else 30 end
	when ABONEMENT_TYPE='2' then SEATSTICK_LIMIT
	when ABONEMENT_TYPE='3' then SEATSTICK_LIMIT*30
	when ABONEMENT_TYPE='4' then SEATSTICK_LIMIT
	when ABONEMENT_TYPE='5' then SEATSTICK_LIMIT*30
	when ABONEMENT_TYPE='6' then SEATSTICK_LIMIT*0
	when ABONEMENT_TYPE='7' then SEATSTICK_LIMIT*30
	when ABONEMENT_TYPE='8' then SEATSTICK_LIMIT
end as srok_bil, --срок действия билета, в днях

case when ABONEMENT_TYPE in('0','2','4','6','8') then 0
	when ABONEMENT_TYPE='1' then 
		case when SEATSTICK_LIMIT=60 then 4
		when SEATSTICK_LIMIT=90 then 6
		else 1 end
	when ABONEMENT_TYPE in('3','5','7') then SEATSTICK_LIMIT
end as srok_mon --срок действия билета, в месяцах

from rawdl2.l2_prig_main 




















--проверка итогов прогнзирования

select *,cast(round(1000*(sprogn/sreal-1))/10 as dec(5,1)) as sproc,round(100*(sprg/sprogn))as pr_prg 
from
(select *,case when progn!=0 and real!=0 then round(100*(progn/real-1)) end as proc,
sum(real) over (partition by par_name,date_progn order by date) as sreal,
sum(progn) over (partition by par_name,date_progn order by date) as sprogn,
sum(prg) over (partition by par_name,date_progn order by date) as sprg
from
(select par_name,date_progn,date,
sum(case when tip in('real1','real2') then param else 0 end) as real,
sum(case when tip in('progn','real1') then param else 0 end) as progn,
 sum(case when tip in('progn') then param else 0 end) as prg
from spb_prig.prig_prognoz where chp=23 --and kst=2004001
 --and par_name='plata' 
 and date>='2021-10-01' and date<=date_progn+5
group by 1,2,3) as a where progn!=0 and real!=0) as b
where date_progn=date
order by 1,2,3




select *
from spb_prig.prig_prognoz where chp=23 and kst=2004001 and grup=0
 and par_name='plata' and date='2021-10-01' and date<=date_progn+5 order by date_progn,tip



--всего по СЗППК "2021-10-16"	103588460	136107865	31 - наихудшее отличие
--               "2021-10-23"	92012590	135687586	47	1638606300	1896552692	16 - ещё хуже!
--СПб главный    "2021-10-16"	6682040	7169973	7
-- 2004004       "2021-10-16"	14377610	22201984	54


select *,case when progn!=0 and real!=0 then round(100*(progn/real-1)) end as proc
from
(select kst,
sum(case when tip='real' then param else 0 end) as real,
sum(case when tip='progn' then param else 0 end) as progn
from spb_prig.prig_prognoz where chp=23 --and kst=2004001
 and par_name='plata' and date='2021-10-16'
group by 1) as a where progn!=0 and real!=0
order by -progn




select *,round(100*(sprogn/sreal-1))as sproc
from
(select *,case when progn!=0 and real!=0 then round(100*(progn/real-1)) end as proc,
sum(real) over (order by date) as sreal,
sum(progn) over (order by date) as sprogn
from
(select date,
sum(case when tip='real' then param else 0 end) as real,
sum(case when tip='progn' then param else 0 end) as progn
from spb_prig.prig_prognoz where chp=23 and kst=2004004 and grup=0
 and par_name='plata' 
group by 1) as a where progn!=0 and real!=0) as b
order by 1


/*
по 2004004 дата реально 	прогноз %превыш
"2021-10-08"	13001660	16547567	27
"2021-10-09"	19271030	21928784	14
"2021-10-10"	13826270	16241208	17
"2021-10-11"	9343740		9526778		2
"2021-10-12"	8407320		9448592		12
"2021-10-13"	7610530		9442595		24
"2021-10-14"	8440790		10207742	21
"2021-10-15"	11977470	16767532	40
"2021-10-16"	14377610	22201984	54
*/

/*
только по группе =0
"2021-10-08"	11307720	14339031	27
"2021-10-09"	16554240	19335076	17
"2021-10-10"	12037000	14601268	21
"2021-10-11"	8524210	8597105	1
"2021-10-12"	7665530	8496725	11
"2021-10-13"	6958550	8462508	22
"2021-10-14"	7649990	8987241	17
"2021-10-15"	10300850	14416738	40
"2021-10-16"	12581500	19439776	55
*/






/*
--проверка на наличие ошибки!  разница между суммой plata и d_plata
select * from
(select yyyymm,date_zap,chp,
sum(case when par_name='plata' then param else 0 end) as plata,
sum(case when par_name='d_plata' then param else 0 end) as d_plata,
sum(case when par_name='poteri' then param else 0 end) as poteri,
sum(case when par_name='d_poteri' then param else 0 end) as d_poteri
from spb_prig.prig_agr_kst where par_name in('plata','d_plata','poteri','d_poteri','bag_plata') 
--yyyymm=202111 and date_zap='2021-11-02'
--and chp=23
group by 1,2,3 order by 1,2,3) as a
where plata!=d_plata or poteri!=d_poteri;
--------------------------------------------------



select par_name,sum(param) as param
from spb_prig.prig_agr_kst group by 1


select dor,reg,sum(param) as param
from spb_prig.prig_agr_kst where --kst in(2004672,2004001) and
 par_name='sf_pas' group by 1,2
 
 
select reg,par_name,sum(param) as param
from spb_prig.prig_agr_kst where chp=23 group by 1,2



select * from spb_prig.prig_agr_kst where par_name='kol_bil' and kst=2004001 fetch first 5 rows only;



select  REGION_CODE as stp_reg,SALE_STATION as stp,count(*) as kol
from rawdl2.l2_prig_main where CARRIAGE_CODE=23 and yyyymm>=202108 group by 1,2;


select REGION_CODE as stp_reg,SALE_STATION as stp,*
from rawdl2.l2_prig_main where SALE_STATION=2004672 and yyyymm=202110
fetch first 5 rows only
*/


