
----- заменить одиночный апостроф на два апострофа

----- заменить rawdl2. на '||shema2||'.
---- строку 'tst_prig' заменить на '||shema||'  в итоге получается  '''||shema||'''
---- строку 'l3_prig' заменить на '||load_shema||'

--ИЗМЕНЕНО!!rawd_ng 


--ПРОГРАММА ПЕРВИЧНОЙ ПЕРЕРАБОТКИ ДАННЫХ, НАРАБОТКА СПРАВОЧНИКА БИЛЕТВ И МАРШРУТОВ, 
--ПОЛУЧЕНИЕ ОТПРАВЛЕННЫХ ПАССАЖИРОВ ПО ДАТАМ ОТПРАВЛЕНИЯ СОКРАЩЕНИЕ ЧИСЛА ЗАПИСЕЙ БЕЗ ПОТЕРИ ИНФОРМАЦИИ

--ТОЛЬКО ПРОЦЕДУРА ОБОГАЩЕНИЯ, НЕ БОЛЕЕ ТОГО!!! 


/* TERM_DOR character(1),agent smallint,chp smallint,stp dec(7),stp_reg smallint,kol_bil dec(7),plata dec(11),poteri dec(11),perebor dec(11),nedobor dec(11) */
/* TERM_DOR,agent,chp,stp,stp_reg,kol_bil,plata,poteri,perebor */

/**/
--удаление старья
delete from l3_prig.prig_work;
--delete from l3_prig.prig_itog;  --таблица обогащения данных!


delete from l3_prig.prig_times where part_zap in(select part_zap from l3_prig.prig_times where oper='dannie' and substr(shema,5,4)='prig')
	and oper not in('dann','dannie');


--- ввод времени начала операции
insert into  l3_prig.prig_times(time,date,oper,time2,date_zap,part_zap,shema)
with a as
(select date_zap,part_zap,shema,current_date as date,substr(cast(current_time as char(50)),1,12) as time 
 from  l3_prig.prig_times where oper='dannie' --and shema in('mon_prig','day_prig') 
)
select time,date,'prig_work 2_1_beg' as oper,
(cast(substr(time,1,2) as dec(3))*60+cast(substr(time,4,2) as dec(3)))*60+cast(substr(time,7,6) as dec(7,3)) as time2,date_zap,part_zap,shema
from a;



insert into l3_prig.prig_work(
	rez,nom_bil,nom_mar,nom_dat,YYYYMM,date_zap,part_zap,date_beg,date_end,date_pr,id,doc_num,request_num,TERM_DOR,term_pos,term_trm,time_zap,server_reqnum,drac,
	agent,subagent,chp,stp,stp_reg,
	sto,stn,sto_reg,stn_reg,srasst,k_pas,srok_bil,srok_mon,oper,oper_g,flg_bag,FLG_tuda_obr,flg_rab_day,kol_bil,k_bil,plata,poteri,perebor,kom_sbor,kom_sbor_vz,
	nom,reg,d_plata,d_poteri,
	flg_ruch,request_type,request_subtype,web_id,vid_rasch,FLG_CHILD,flg_voin,FLG_MILITARY,flg_lgt,
	FLG_BSP,FLG_SO,FLG_NU,FLG_TT,klass,kod_lgt,lgt_reg,
	bag_vid,bag_ves,proc_lgt,rzd_fpk,ABONEMENT_TYPE,ABONEMENT_SUBTYPE,FLG_OFFICIAL_BENEFIT,TRAIN_CATEGORY,TRAIN_NUM,employee_cat,prod,flg_sbor,flg_bil_sbor,
	marshr,st1,st2,rst,sto_zone,stn_zone,sti,sti_zone,dor,lin,
fio,fio_2,snils,ticket,benefit_doc,benefit_podr,bilgroup --поля для реестра льгнотников
	)
/**/

with

RECURSIVE rrr AS (SELECT 0 AS i
    UNION SELECT i+1 AS i FROM rrr WHERE i < 10000),

rrr0 as (select distinct i from rrr where i>0),

dates as  --дата загружаемых данных
(select distinct date_zap,part_zap from  l3_prig.prig_times  where oper='dannie' and substr(shema,5,4)='prig'
   --where date_zap= '2023-01-31' -- and part_zap=2
),

prig_main as(select
--REQUEST_NUM,ARXIV_CODE,REPLY_CODE,REQUEST_TIME,ELS_CODE,PAYAGENT_ID,WEB_ID,TICKET_SER,TICKET_NUM,
--DOC_TYPE,RETURN_DATE,FEE_SUM,FEE_VAT,REFUNDFEE_SUM,REFUNDDEPART_SUM,DATE_TEMPLATE, --уходят без переработки, совсем, за ненадобностью
--OPER,OPER_G,FLG_2WAYTICKET,FLG_1WAYTICKET,SEATSTICK_LIMIT -- ушли с переработкой
--TICKET_ENDDATE --ушло ввиду откровенной грязи

ID,DOC_NUM,
case when substr('tst_prig',1,3)='tst' then request_num else 0 end as request_num, --для нетестовых номер запроса делаем =0			 
			 row_number() over (order by id,doc_num) as idd,
YYYYMM,REQUEST_DATE as date_zap,TERM_POS,TERM_DOR,term_trm,
			 --cast(request_time as char(8)) 
server_datetime as time_zap,server_reqnum,server_stcode as drac,
OPERATION_DATE as date_pr,TICKET_BEGDATE as date_beg,
case when return_date is NULL then '1990-01-01' else return_date end as return_date,--дата  возврата билета
			 TRAIN_CATEGORY,TRAIN_NUM,
'p' as prod, --ОБЫЧНАЯ ПРИГОРОДНАЯ ПРОДАЖА (=КАССЫ и в поезде)			
FLG_FEE_ONBOARD||flg_fee_o||flg_fee_v||flg_service as flg_sbor, --'Признак Сбор за оформление в поезде, Комсбор за продажу, Комсбор за возврат, Сервисные услуги';


(case when oper_g='N' then 1 else -1 end)*(case when oper='O' then 1 else -1 end) as koef, --если гашение или возврат, то взять с коэф=-1 все параметры
REGISTRATION_METHOD as flg_ruch, --флаг 1=ручник, 0=экспресс, аквивалент поля request_type  1=>97(=ручники) , 0=>64(=экспресс)
request_type,request_subtype,
case when web_id='' then '-1' when web_id is NULL then 'NULL' else web_id end as web_id,
AGENT_CODE as agent, --агент продажи
CARRIAGE_CODE as chp,--перевозчик
PAYMENTTYPE as vid_rasch, --вид расчёта (=1,6,8)=(' ','П','Э') = (Наличка, Платёжные поручения, Электронное=банковские карты)

SALE_STATION as stp,REGION_CODE as stp_reg,
DEPARTURE_STATION as sto,DEPARTURE_ZONE as sto_zone,
ARRIVAL_STATION as stn,ARRIVAL_ZONE as stn_zone,
INTERMED_STATION as sti,INTERMED_ZONE as sti_zone,

FLG_CHILD,FLG_MILITARY,FLG_BENEFIT as flg_lgt,FLG_BSP,FLG_SO,FLG_NU,FLG_TT,
MILITARY_CODE as flg_voin,

CARRIAGE_CLASS as klass, --некий класс
BENEFIT_CODE as kod_lgt,
BENEFIT_REGION as lgt_reg,

FLG_CARRYON as flg_bag,--абсолютно эквивалентно полю doc_type
case when CARRYON_TYPE='' then '0' else CARRYON_TYPE end as bag_vid,
			 
case when REGISTRATION_METHOD='1' and FLG_CARRYON='1' and CARRYON_WEIGHT=0 then
	case  when CARRYON_TYPE in ('Ж','В') then 20 when CARRYON_TYPE='Т' then 30 else CARRYON_WEIGHT end
	else CARRYON_WEIGHT end /* *(case when oper_g='G' then -1 else 1 end)*/ as bag_ves, --в поле указан вес одного багажа, а не всех, и не возврата

case when FLG_2WAYTICKET='1' then '2' 
	when FLG_1WAYTICKET='1' then '1' else '2' end as FLG_tuda_obr, --признак туда=1, туда-обратно=2
case when FLG_2WAYTICKET='1' then 2 
	when FLG_1WAYTICKET='1' then 1 else 2 end as k_tuda_obr, --коэф туда=1, туда-обратно=2

PASS_QTY as kol_bil, --в том числе и багажные билеты, по многу штук.
TARIFF_SUM*10 as plata,
DEPARTMENT_SUM*10 as poteri,
(case when TOTAL_SUM=0 then 0
	when abs(TARIFF_SUM+DEPARTMENT_SUM-TOTAL_SUM)<abs(TARIFF_SUM-TOTAL_SUM) then TOTAL_SUM-TARIFF_SUM-DEPARTMENT_SUM
	else TOTAL_SUM-TARIFF_SUM end)*10 as perebor,
fee_sum*10 as kom_sbor,0 as kom_sbor_vz,
			 
case when FLG_BSP='1' then 100 
	when BENEFIT_PERCENT=0 then 0
	else 100-BENEFIT_PERCENT end as proc_lgt,

ABONEMENT_TYPE, --тип абонемента
case  when ABONEMENT_SUBTYPE is NULL then '0' else ABONEMENT_SUBTYPE end as ABONEMENT_SUBTYPE,
case  when FLG_OFFICIAL_BENEFIT is NULL then '0' else FLG_OFFICIAL_BENEFIT end as FLG_OFFICIAL_BENEFIT,
cast(case when ABONEMENT_TYPE='0' then 1
	when ABONEMENT_TYPE='1' then SEATSTICK_LIMIT/2
	when ABONEMENT_TYPE='2' then SEATSTICK_LIMIT --абонемент на определённые даты
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
end as srok_mon, --срок действия билета, в месяцах
oper,oper_g
			
from rawdl2.l2_prig_main   where REQUEST_DATE  in (select date_zap from dates)
		--and	 id=432136230
			-- request_num in( -9122,  -48479, 9730 , 28276 )
			),



prig_cost as --исходник пригород по перегонам по субъектам
(select  ID,DOC_NUM,doc_reg as nom,
--YYYYMM,REQUEST_DATE,REQUEST_NUM,TERM_POS,TERM_DOR,TERM_TRM,ARXIV_CODE,REPLY_CODE, --не нужны
	ROUTE_NUM as marshr,cast(ROUTE_DISTANCE as dec(7)) as rasst,
	sum(cast(ROUTE_DISTANCE as dec(7))) over(partition by ID,DOC_NUM) as srasst,
	TARIFF_SUM as d_plata,DEPARTMENT_SUM as d_poteri,
	DEPARTURE_STATION as st1,ARRIVAL_STATION as st2,
 REGION_CODE as reg,
	max(doc_reg) over (partition by ID,DOC_NUM) as max_nom, 
	sum(TARIFF_SUM) over (partition by ID,DOC_NUM) as s_plata,
	sum(DEPARTMENT_SUM) over (partition by ID,DOC_NUM) as s_poteri 
from rawdl2.l2_prig_cost where REQUEST_DATE in(select date_zap from dates) and 
 	id in(select id from prig_main)
),

prig_fio as
(select ID,DOC_NUM,substr(surname||' '||initials,1,45) as fio,
	substr(dependent_surname||' '||dependent_initials,1,20) as fio_2,
 case when bilgroup_code is NULL and bilgroup_secur is NULL then '00000' else bilgroup_code||bilgroup_secur end as bilgroup,
 	case when ticket_ser is null then '--' else substr(ticket_ser,1,2) end ||
		to_char(ticket_num,'fm000000') as ticket,
	benefit_doc,employee_unit as benefit_podr,snils,
 case when employee_cat is null then '-' else employee_cat end as employee_cat
	from rawdl2.l2_prig_adi where REQUEST_DATE in(select date_zap from dates) and 
 		id in(select id from prig_main)
),

prig_main_ as 
(select a.ID,a.DOC_NUM,request_num,idd,YYYYMM,date_zap,TERM_POS,TERM_DOR,term_trm,
time_zap,server_reqnum,drac,date_pr,date_beg,return_date,TRAIN_CATEGORY,TRAIN_NUM,prod,flg_sbor,
koef, --если гашение или возврат, то взять с коэф=-1 все параметры
flg_ruch,request_type,request_subtype,web_id,
agent,chp,vid_rasch,stp,stp_reg,sto,sto_zone,stn,stn_zone,sti,sti_zone,
FLG_CHILD,FLG_MILITARY,flg_lgt,FLG_BSP,FLG_SO,FLG_NU,FLG_TT,
flg_voin,klass,kod_lgt,lgt_reg,flg_bag,bag_vid,bag_ves,FLG_tuda_obr,k_tuda_obr,

kol_bil*koef as kol_bil, --в том числе и багажные билеты, по многу штук.
plata*koef as plata,poteri*koef as poteri,perebor*koef as perebor,
kom_sbor*koef as kom_sbor,kom_sbor_vz*koef as kom_sbor_vz,			 
proc_lgt,ABONEMENT_TYPE,ABONEMENT_SUBTYPE,FLG_OFFICIAL_BENEFIT,k_pas,flg_rab_day,srok_bil,srok_mon,oper,oper_g, 
bilgroup,employee_cat,fio,fio_2,ticket,benefit_doc,benefit_podr,snils,
case when bilgroup is NULL then '0' else substr(bilgroup,3,1) end as rzd_fpk  
 from prig_main as a left join prig_fio as b on a.id=b.id and a.doc_num=b.doc_num),
 
 
	
prig_cost2 as --исходник пригород по перегонам по субъектам, с добавкой числа билетов
(select  a.ID,a.DOC_NUM,idd,nom,a.marshr,train_num,a.rasst,a.st1,a.st2,a.reg as regg,max_nom,sto,stn,srasst,sto_zone,stn_zone,sti,sti_zone,
 case when kol_bil=0 then 1 else kol_bil end as kol_bil, --заплатка  от нулевого значения
 s_plata,s_poteri,plata,poteri,kom_sbor,kom_sbor_vz,--mnom,
 case when max_nom=1 then kol_bil 
 	when s_plata=0 and s_poteri=0 and nom=max_nom then 1
 	when s_plata=0 and s_poteri=0 then NULL
 	when s_plata=0 and plata!=0 and nom=max_nom then plata
 	when s_plata=0 and plata!=0 /*and nom>1*/ then 0 
 	when plata=0 then 0
 	else (case when kol_bil<0 then -1 else 1 end)*d_plata end as d_plata,
 case when max_nom=1 then kol_bil 
 	when s_plata=0 and s_poteri=0 and nom=max_nom then 1
 	when s_plata=0 and s_poteri=0 then NULL
 	when s_poteri=0 and poteri!=0 and nom=max_nom then poteri
 	when s_poteri=0 and poteri!=0 /*and nom>1*/ then 0 
 	when poteri=0 then 0
 	else (case when kol_bil<0 then -1 else 1 end)*d_poteri end as d_poteri  
from prig_cost as a join prig_main as b on a.id=b.id and a.doc_num=b.doc_num
),


---------------------------БЛОК ОПРЕДЕЛЕНИЯ НОД ДЛЯ ЧИСЛА БИЛЕТОВ-----------------------

prig_cost2_kbil_nod as 
(select ID,DOC_NUM,1 as k_bil from --определяем 1 как максимальный делитель для плохих. а хорошим оставляем реальные количества билетов
(select distinct ID,DOC_NUM from prig_cost2 where mod(plata,kol_bil)!=0 or mod(poteri,kol_bil)!=0
 		or mod(kom_sbor,kol_bil)!=0 or mod(kom_sbor_vz,kol_bil)!=0
 		or mod(d_plata,kol_bil)!=0 or mod(d_poteri,kol_bil)!=0) as a),



prig_cost2_kbil as
(select ID,DOC_NUM,idd,nom,marshr,train_num,rasst,st1,st2,regg,max_nom,sto,stn,srasst,sto_zone,stn_zone,sti,sti_zone,k_bil,
 	cast(plata/k_bil as dec(13)) as plata,cast(poteri/k_bil as dec(13)) as poteri,
 	cast(d_plata/k_bil as dec(13)) as d_plata,cast(d_poteri/k_bil as dec(13)) as d_poteri
 	from
(select a.ID,a.DOC_NUM,idd,nom,marshr,train_num,rasst,st1,st2,regg,max_nom,kol_bil,sto,stn,srasst,sto_zone,stn_zone,sti,sti_zone,
 	plata,poteri,d_plata,d_poteri,
 	case when k_bil is not null then k_bil else abs(kol_bil) end as k_bil 
 from prig_cost2 as a left join prig_cost2_kbil_nod as b on a.id=b.id and  a.doc_num=b.doc_num
	) as c),


 


---------------------------БЛОК ОПРЕДЕЛЕНИЯ НОД ДЛЯ СУММ ДЕНЕГ ПО ПЕРЕГОНАМ-----------------------


prig_cost2_nodd as --определение НОД (долей платы и потерь по маршруту) только по степеням 2,3,5,7,11,13,17
(select ID,DOC_NUM,
 idd,nom,marshr,train_num,rasst,st1,st2,regg,max_nom,sto,stn,srasst,sto_zone,stn_zone,sti,sti_zone,k_bil,
 case when max_nom=1 then 1 when plata=0 then d_poteri else d_plata end as d_plata, --если плата=0, то разбивка по потерям, и наоборот
 case when max_nom=1 then 1 when poteri=0 then d_plata else d_poteri end as d_poteri
from
(select ID,DOC_NUM,idd,nom,marshr,train_num,rasst,st1,st2,regg,max_nom,sto,stn,srasst,sto_zone,stn_zone,sti,sti_zone,k_bil,
 	round(round(plata/dpl)/dpl_) as plata,round(round(poteri/dpot)/dpot_) as poteri,
 	round(round(d_plata/dpl)/dpl_) as d_plata,round(round(d_poteri/dpot)/dpot_) as d_poteri
from
(select ID,DOC_NUM,idd,nom,marshr,train_num,rasst,st1,st2,regg,max_nom,sto,stn,srasst,sto_zone,stn_zone,sti,sti_zone,k_bil,
 	plata,poteri,d_plata,d_poteri,
 	dpl2*dpl3*dpl5*dpl7 as dpl,dpl11*dpl13*dpl17 as dpl_,dpot2*dpot3*dpot5*dpot7 as dpot,dpot11*dpot13*dpot17 as dpot_
	from
(select ID,DOC_NUM,idd,nom,marshr,train_num,rasst,st1,st2,regg,max_nom,sto,stn,srasst,sto_zone,stn_zone,sti,sti_zone,k_bil,
 	plata,poteri,d_plata,d_poteri,
 min(case when mod(d_plata,64)=0 then 64 when mod(d_plata,32)=0 then 32 when mod(d_plata,16)=0 then 16
 	when mod(d_plata,8)=0 then 8 when mod(d_plata,4)=0 then 4 when mod(d_plata,2)=0 then 2 else 1 end) 
 	over (partition by idd) as dpl2,
 min(case when mod(d_plata,729)=0 then 729 when mod(d_plata,243)=0 then 243 when mod(d_plata,81)=0 then 81
 	when mod(d_plata,27)=0 then 27 when mod(d_plata,9)=0 then 9 when mod(d_plata,3)=0 then 3 else 1 end) 
 	over (partition by idd) as dpl3,
 min(case when mod(d_plata,125)=0 then 125 when mod(d_plata,25)=0 then 25 when mod(d_plata,5)=0 then 5 else 1 end) 
 	over (partition by idd) as dpl5,
 min(case when mod(d_plata,49)=0 then 49 when mod(d_plata,7)=0 then 7 else 1 end) 
 	over (partition by idd) as dpl7,
 min(case when mod(d_plata,11)=0 then 11 else 1 end) over (partition by idd) as dpl11,
 min(case when mod(d_plata,13)=0 then 13 else 1 end) over (partition by idd) as dpl13,
 min(case when mod(d_plata,17)=0 then 17 else 1 end) over (partition by idd) as dpl17,
 
 min(case when mod(d_poteri,64)=0 then 64 when mod(d_poteri,32)=0 then 32 when mod(d_poteri,16)=0 then 16
 	when mod(d_poteri,8)=0 then 8 when mod(d_poteri,4)=0 then 4 when mod(d_poteri,2)=0 then 2 else 1 end) 
 	over (partition by idd) as dpot2,
 min(case when mod(d_poteri,729)=0 then 729 when mod(d_poteri,243)=0 then 243 when mod(d_poteri,81)=0 then 81
 	when mod(d_poteri,27)=0 then 27 when mod(d_poteri,9)=0 then 9 when mod(d_poteri,3)=0 then 3 else 1 end) 
 	over (partition by idd) as dpot3,
 min(case when mod(d_poteri,125)=0 then 125 when mod(d_poteri,25)=0 then 25 when mod(d_poteri,5)=0 then 5 else 1 end) 
 	over (partition by idd) as dpot5,
 min(case when mod(d_poteri,49)=0 then 49 when mod(d_poteri,7)=0 then 7 else 1 end) 
 	over (partition by idd) as dpot7, 
 min(case when mod(d_poteri,11)=0 then 11 else 1 end) over (partition by idd) as dpot11,
 min(case when mod(d_poteri,13)=0 then 13 else 1 end) over (partition by idd) as dpot13,
 min(case when mod(d_poteri,17)=0 then 17 else 1 end) over (partition by idd) as dpot17
	from prig_cost2_kbil) as a) as b) as c),



-------------БЛОК ОБРАБОТКИ ВИДОВ БИЛЕТОВ-------------------


bil_ as --не просто distinct ДЛЯ ТОГО, ЧТОБЫ НАЙТИ представителя (ID,DOC_NUM)
(select flg_ruch,request_type,request_subtype,web_id,vid_rasch,FLG_CHILD,flg_voin,FLG_MILITARY,flg_lgt,FLG_BSP,FLG_SO,FLG_NU,FLG_TT,
klass,kod_lgt,lgt_reg,flg_bag,bag_vid,bag_ves,FLG_tuda_obr,flg_rab_day,proc_lgt,rzd_fpk,ABONEMENT_TYPE,ABONEMENT_SUBTYPE,FLG_OFFICIAL_BENEFIT,
k_pas,srok_bil,srok_mon,oper,oper_g,TRAIN_CATEGORY,TRAIN_NUM,employee_cat,prod,flg_sbor,id,doc_num 
 from
(select flg_ruch,request_type,request_subtype,web_id,vid_rasch,FLG_CHILD,flg_voin,FLG_MILITARY,flg_lgt,FLG_BSP,FLG_SO,FLG_NU,FLG_TT,
klass,kod_lgt,lgt_reg,flg_bag,bag_vid,bag_ves,FLG_tuda_obr,flg_rab_day,proc_lgt,rzd_fpk,ABONEMENT_TYPE,ABONEMENT_SUBTYPE,FLG_OFFICIAL_BENEFIT,
 k_pas,srok_bil,srok_mon,oper,oper_g,TRAIN_CATEGORY,TRAIN_NUM,employee_cat,prod,flg_sbor,id,doc_num,idd,
 min(idd) over(partition by flg_ruch,request_type,request_subtype,web_id,vid_rasch,FLG_CHILD,flg_voin,FLG_MILITARY,flg_lgt,FLG_BSP,FLG_SO,FLG_NU,FLG_TT,
klass,kod_lgt,lgt_reg,flg_bag,bag_vid,bag_ves,FLG_tuda_obr,flg_rab_day,proc_lgt,rzd_fpk,ABONEMENT_TYPE,ABONEMENT_SUBTYPE,FLG_OFFICIAL_BENEFIT,
k_pas,srok_bil,srok_mon,oper,oper_g,TRAIN_CATEGORY,TRAIN_NUM,employee_cat,prod,flg_sbor) as midd
 from prig_main_
) as a where idd=midd),


bil as --добавляется значение поля flg_bil_sbor с раздвоеием записи - если запись типа Сбор в пути следования.  20/02/2023
(select  id,doc_num,flg_ruch,request_type,request_subtype,web_id,vid_rasch,FLG_CHILD,flg_voin,FLG_MILITARY,flg_lgt,FLG_BSP,FLG_SO,FLG_NU,FLG_TT,
klass,kod_lgt,lgt_reg,flg_bag,bag_vid,bag_ves,FLG_tuda_obr,flg_rab_day,proc_lgt,rzd_fpk,ABONEMENT_TYPE,ABONEMENT_SUBTYPE,FLG_OFFICIAL_BENEFIT,
 k_pas,srok_bil,srok_mon,oper,oper_g,TRAIN_CATEGORY,TRAIN_NUM,employee_cat,prod,flg_sbor,'B' as flg_bil_sbor
 from bil_
 union all
 select  id,doc_num,flg_ruch,request_type,request_subtype,web_id,vid_rasch,FLG_CHILD,flg_voin,FLG_MILITARY,flg_lgt,FLG_BSP,FLG_SO,FLG_NU,FLG_TT,
klass,kod_lgt,lgt_reg,flg_bag,bag_vid,bag_ves,FLG_tuda_obr,flg_rab_day,proc_lgt,rzd_fpk,ABONEMENT_TYPE,ABONEMENT_SUBTYPE,FLG_OFFICIAL_BENEFIT,
 k_pas,srok_bil,srok_mon,oper,oper_g,TRAIN_CATEGORY,TRAIN_NUM,employee_cat,prod,flg_sbor,'S' as flg_bil_sbor
 from bil_ where substr(flg_sbor,1,1)='1'),

old_bil as --Сделать выборку из справочника, когда будет создан
(select * from l3_prig.prig_bil),

all_bil as 
(select flg_ruch,request_type,request_subtype,web_id,vid_rasch,FLG_CHILD,flg_voin,FLG_MILITARY,flg_lgt,FLG_BSP,FLG_SO,FLG_NU,FLG_TT,
klass,kod_lgt,lgt_reg,flg_bag,bag_vid,bag_ves,FLG_tuda_obr,flg_rab_day,proc_lgt,rzd_fpk,ABONEMENT_TYPE,ABONEMENT_SUBTYPE,FLG_OFFICIAL_BENEFIT,
 k_pas,srok_bil,srok_mon,oper,oper_g,TRAIN_CATEGORY,TRAIN_NUM,employee_cat,prod,flg_sbor,flg_bil_sbor,
 case when nom_bil<0 then 1 else 0 end as new_bil,
 case when min_bil<0 then 1 else 0 end as isp_bil,
 ROW_NUMBER() over ( order by (nom_bil<0),nom_bil) as nom_bil,id,doc_num
 from 
(select flg_ruch,request_type,request_subtype,web_id,vid_rasch,FLG_CHILD,flg_voin,FLG_MILITARY,flg_lgt,FLG_BSP,FLG_SO,FLG_NU,FLG_TT,
klass,kod_lgt,lgt_reg,flg_bag,bag_vid,bag_ves,FLG_tuda_obr,flg_rab_day,proc_lgt,rzd_fpk,ABONEMENT_TYPE,ABONEMENT_SUBTYPE,FLG_OFFICIAL_BENEFIT,
 k_pas,srok_bil,srok_mon,oper,oper_g,TRAIN_CATEGORY,TRAIN_NUM,employee_cat,prod,flg_sbor,flg_bil_sbor,
 max(nom_bil) as nom_bil,min(nom_bil) as min_bil,min(id) as id,min(doc_num) as doc_num
 from 
(select flg_ruch,request_type,request_subtype,web_id,vid_rasch,FLG_CHILD,flg_voin,FLG_MILITARY,flg_lgt,FLG_BSP,FLG_SO,FLG_NU,FLG_TT,
klass,kod_lgt,lgt_reg,flg_bag,bag_vid,bag_ves,FLG_tuda_obr,flg_rab_day,proc_lgt,rzd_fpk,ABONEMENT_TYPE,ABONEMENT_SUBTYPE,FLG_OFFICIAL_BENEFIT,
 k_pas,srok_bil,srok_mon,oper,oper_g,TRAIN_CATEGORY,TRAIN_NUM,employee_cat,prod,flg_sbor,flg_bil_sbor,
 -1 as nom_bil,ID,DOC_NUM from bil
union
select flg_ruch,request_type,request_subtype,web_id,vid_rasch,FLG_CHILD,flg_voin,FLG_MILITARY,flg_lgt,FLG_BSP,FLG_SO,FLG_NU,FLG_TT,
klass,kod_lgt,lgt_reg,flg_bag,bag_vid,bag_ves,FLG_tuda_obr,flg_rab_day,proc_lgt,rzd_fpk,ABONEMENT_TYPE,ABONEMENT_SUBTYPE,FLG_OFFICIAL_BENEFIT,
 k_pas,srok_bil,srok_mon,oper,oper_g,TRAIN_CATEGORY,TRAIN_NUM,employee_cat,prod,flg_sbor,flg_bil_sbor,
 nom_bil,0 as ID,0 as DOC_NUM
 from old_bil) as a
 group by flg_ruch,request_type,request_subtype,web_id,vid_rasch,FLG_CHILD,flg_voin,FLG_MILITARY,flg_lgt,FLG_BSP,FLG_SO,FLG_NU,FLG_TT,
klass,kod_lgt,lgt_reg,flg_bag,bag_vid,bag_ves,FLG_tuda_obr,flg_rab_day,proc_lgt,rzd_fpk,ABONEMENT_TYPE,ABONEMENT_SUBTYPE,FLG_OFFICIAL_BENEFIT,
 k_pas,srok_bil,srok_mon,oper,oper_g,TRAIN_CATEGORY,TRAIN_NUM,employee_cat,prod,flg_sbor,flg_bil_sbor) as b),

new_bil_zapis as --билеты на запись в справочник
(select * from all_bil /*as a,dates as b*/ where new_bil=1),

isp_bil as
(select * from all_bil where isp_bil=1),

 
-----------------------------БЛОК ОБРАБОТКИ ДАТ ОТПРАВЛЕНИЙ------------------------- 

dats as --варианты сроков действия билетов
(select date_beg,return_date,k_pas,srok_bil,srok_mon,flg_rab_day,id,doc_num,
 	ROW_NUMBER() over (order by date_beg,return_date,k_pas,srok_bil,srok_mon,flg_rab_day) as ndt  from
(select date_beg,return_date,k_pas,srok_bil,srok_mon,flg_rab_day,id,doc_num,idd,
 	min(idd) over (partition by date_beg,return_date,k_pas,srok_bil,srok_mon,flg_rab_day) as midd
from prig_main) as a where idd=midd),


dats_2 as --список дат интервала действия билета, по месяцам
(select *,date_beg+i as dat,extract(dow from date_beg+i) as weekd,substr(cast(date_beg+i as char(10)),1,7) as dm
 from dats,rrr where i<srok_bil
 /*((i<srok_bil and srok_mon=0)  or 
	(srok_mon>0 and (12*extract(year from dt)+extract(month from dt) <12*extract(year from date_beg)+extract(month from date_beg)+srok_mon ))
	or
	(srok_mon>0 and (12*extract(year from dt)+extract(month from dt)=12*extract(year from date_beg)+extract(month from date_beg)+srok_mon ) and 
	extract(day from dt)<extract(day from date_beg)	)  ) */ 
),


dats_3 as --вычисление числа поездок на каждый месяц 
(select ndt,dm,pas_mes,case when mi<max_mi or max_mi=0 then kpas_mes else k_pas-skpas end as kpas_mes  from 
(select *,sum(kpas_mes) over (partition by ndt) as skpas from --сумма пассажиров по всем месяцам, кроме возможно последнего
 
(select *,
 case when srok_mon>0 and mi=min_mi and kol_d<=30 then round(kol_d*pas_mes/30)
 		when srok_mon>0 and mi<max_mi then pas_mes
 		when srok_mon=0 and mi=min_mi and kol_d>=srok_bil then k_pas
 		when srok_mon=0 and mi=min_mi then round(k_pas*kol_d/srok_bil)
 		else 0 end as kpas_mes --количество пассажиров в каждом месяце, кроме последнего
 from 
(select *,min(mi) over (partition by ndt) as min_mi,max(mi) over (partition by ndt) as max_mi,
 case when srok_mon>0 then round(mes*k_pas/srok_mon)-round((mes-1)*k_pas/srok_mon) else 0 end as pas_mes
 from

(select *,row_number() over (partition by ndt order by dm) as mes
 from
(select ndt,dm,k_pas,srok_bil,srok_mon,min(i) as mi,count(*) as kol_d from dats_2 group by 1,2,3,4,5) as a) as aa) as b)  
 as c) as d),



dats_4 as --вычисление числа поездок в сутки
(select ndt,date_beg,return_date,k_pas,srok_bil,srok_mon,flg_rab_day,i,dat,
 	case when dat<return_date then 0 else kpas_day end as kpas_day from
(select ndt,date_beg,return_date,k_pas,srok_bil,srok_mon,flg_rab_day,i,dat,
 	round(kpas_mes*kiz/siz)-round(kpas_mes*(kiz-1)/siz) as kpas_day from --число поездок в сутки
(select *,sum(iz) over (partition by ndt,dm order by i) as kiz,sum(iz) over (partition by ndt,dm) as siz from
(select ndt,date_beg,return_date,k_pas,srok_bil,srok_mon,flg_rab_day,i,dat,dm,pas_mes,kpas_mes,
 case when siz=0 and i=mi then 1 else iz end as iz --заплатка, если в куске месяца нет ни одного дня поездок
 from
(select *,sum(iz) over (partition by ndt,dm) as siz,min(i) over (partition by ndt,dm) as mi  --сколько раз в месяц возможно
 	from
(select a.ndt,date_beg,return_date,k_pas,srok_bil,srok_mon,flg_rab_day,i,dat,weekd,a.dm,pas_mes,kpas_mes,
 case when (flg_rab_day='0' or (flg_rab_day='1' and weekd in (0,6)) or (flg_rab_day='2' and weekd not in (0,6))) then 1 else 0 end as iz      
 from dats_2 as a join dats_3 as b on a.ndt=b.ndt and a.dm=b.dm) as c) as e) as f where iz=1) as g) as h where kpas_day!=0),


dats_all as --совмещение старых и новых вариантов разбивки дат
(select nom_dat,0 as ndt,plus_dat as i,kpas_day from l3_prig.prig_dats
union all
 select 0 as nom_dat,ndt,i,kpas_day from dats_4),

dats_hash as --вычисление хэш-функций для дат
(select *,max(nom_dat) over (partition by hash) as mnom_dat,max(ndt) over (partition by hash) as mndt,
 	count(*) over (partition by hash) as kol from
(select nom_dat,ndt,mplus_dat,hash2||'-'||cast(hash as char(30)) as hash from --сдвоенных хэш - по числу поездок, сумме дат и их свадратов, и реальному хэшу - считаем сильным хэшем
 (select nom_dat,ndt,sum(('x'||md5( cast(i as char(3))||'-'||cast(kpas_day as char(3)) ))::bit(64)::bigint) as hash,
 	cast(sum(kpas_day) as char(5))||'-'||cast(sum(i) as char(5))||'-'||cast(sum(i*i) as char(8)) as hash2,max(i) as mplus_dat
from dats_all group by 1,2) as a) as b),
 
dats_hash_new as --сперва нашли как заведомо новые маршруты
(select ndt,hash,mnom_dat+(count(*) over (order by ndt)) as nom_dat from
	(select ndt,hash from dats_hash where mnom_dat=0 and mndt=ndt) as a,
 	(select max(nom_dat) as mnom_dat from dats_hash) as b),

dats_hash_new_zapis as --список новых разбивок дат - на запись в справочник
(select c.ndt,nom_dat,i,kpas_day,e.id,e.doc_num from
(select a.ndt,nom_dat,i,kpas_day from dats_4 as a,dats_hash_new as b where a.ndt=b.ndt) as c 
	/*join dates as d on 1=1*/ join dats as e on c.ndt=e.ndt),
	
dats_itog as --список переводов ndt в уникальные комбинации
(select ndt,nom_dat,mplus_dat from
(select ndt,hash,mplus_dat from dats_hash where ndt>0) as a,
(select nom_dat,hash from dats_hash where nom_dat>0
	union all select nom_dat,hash from dats_hash_new) as b where a.hash=b.hash),


dats_all2 as --совмещение старых и новых вариантов разбивки дат
(select nom_dat,cast(i as integer) as i,kpas_day,count(*) over(partition by nom_dat) as kol_zap  from
(select nom_dat,i,kpas_day from dats_all where ndt=0
union all
 select nom_dat,i,kpas_day from dats_hash_new_zapis) as a),



dats2 as --роспись вариантов по датам отправления.
(select c.ndt,i,k_pas,date_beg,return_date,kpas_day as kk,srok_bil,srok_mon,flg_rab_day,date_beg+i as dt,substr(cast(date_beg+i as char(10)),1,7),nom_dat from
(select a.nom_dat,ndt,i,kpas_day from dats_itog as a,dats_all2 as b where a.nom_dat=b.nom_dat) as c 
 	join dats as d on c.ndt=d.ndt),

dats_itog2 as --список переводов билетов в уникальные комбинации
(select id,doc_num,idd,nom_dat,c.date_beg,c.return_date,mplus_dat+c.date_beg as date_end,date_pr from prig_main as c join
(select date_beg,return_date,k_pas,srok_bil,srok_mon,flg_rab_day,nom_dat,mplus_dat
 from dats as a join dats_itog as b on a.ndt=b.ndt) as d 
 on c.date_beg=d.date_beg and c.return_date=d.return_date and c.k_pas=d.k_pas and c.srok_bil=d.srok_bil 
 	and c.srok_mon=d.srok_mon and c.flg_rab_day=d.flg_rab_day),


-------------------БЛОК ПРИКЛЕИВАНИЯ К ДАННЫМ ССЫЛОК НА МАРШРУТЫ, БИЛЕТЫ И ДАТЫ----------------------------

prig_main_bil as
(select a.ID,a.doc_num,request_num,idd,YYYYMM,date_zap,nom_bil,TERM_DOR,term_pos,term_trm,time_zap,server_reqnum,drac,agent,chp,stp,stp_reg,
 case when flg_bil_sbor='B' then kol_bil else 0 end as kol_bil, 
 case when flg_bil_sbor='B' then plata else 0 end as plata,
 case when flg_bil_sbor='B' then poteri else 0 end as poteri,
 case when flg_bil_sbor='B' then perebor else 0 end as perebor,
 case when flg_bil_sbor='S' then kom_sbor else 0 end as kom_sbor,
 case when flg_bil_sbor='S' then kom_sbor_vz else 0 end as kom_sbor_vz
 from prig_main_ as a join isp_bil as b on
 a.flg_ruch =b.flg_ruch and a.request_type=b.request_type and a.request_subtype=b.request_subtype and a.web_id=b.web_id and 
 a.vid_rasch =b.vid_rasch and a.FLG_CHILD =b.FLG_CHILD and
 a.flg_voin =b.flg_voin and a.FLG_MILITARY =b.FLG_MILITARY and a.flg_lgt =b.flg_lgt and
 a.FLG_BSP =b.FLG_BSP and a.FLG_SO =b.FLG_SO and a.FLG_NU =b.FLG_NU and
 a.FLG_TT =b.FLG_TT and a.klass =b.klass and a.kod_lgt =b.kod_lgt and
 a.lgt_reg =b.lgt_reg and a.flg_bag =b.flg_bag and a.bag_vid =b.bag_vid and
 a.bag_ves =b.bag_ves and a.FLG_tuda_obr =b.FLG_tuda_obr and a.proc_lgt =b.proc_lgt and a.rzd_fpk=b.rzd_fpk and
 a.ABONEMENT_TYPE =b.ABONEMENT_TYPE and a.ABONEMENT_SUBTYPE=b.ABONEMENT_SUBTYPE and
 a.FLG_OFFICIAL_BENEFIT=b.FLG_OFFICIAL_BENEFIT and
 a.k_pas=b.k_pas and a.srok_bil=b.srok_bil and a.srok_mon=b.srok_mon and a.oper=b.oper and a.oper_g=b.oper_g and
 a.TRAIN_CATEGORY=b.TRAIN_CATEGORY and a.TRAIN_NUM=b.TRAIN_NUM and a.employee_cat=b.employee_cat
 and a.prod=b.prod and a.flg_sbor=b.flg_sbor and a.flg_rab_day=b.flg_rab_day
),


----------СБОРКА ИТОГОВ----------
itog as 
(
	
--обогощение по датам
select 4 as rez,NULL as nom_bil,0 as nom_mar,nom_dat,0 as YYYYMM,/*NULL as date_zap,*/date_beg,date_end,date_pr,
 id,doc_num,0 request_num,NULL as TERM_DOR,NULL as term_pos,NULL as term_trm,NULL as time_zap,NULL as server_reqnum,NULL as drac,
 0 as agent,0 as chp,0 as stp,0 as stp_reg,0 as sto,0 as stn,0 as sto_reg,0 as stn_reg,0 as srasst,
 NULL as k_pas,NULL as srok_bil,NULL as srok_mon,NULL as oper,NULL as oper_g,NULL as flg_bag,NULL as FLG_tuda_obr,NULL as flg_rab_day,0 as kol_bil,0 as k_bil,
 0 as plata,0 as poteri,0 as perebor,0 as kom_sbor,0 as kom_sbor_vz,0 as nom,0 as reg,0 as d_plata,0 as d_poteri,
 NULL as flg_ruch,0 as request_type,0 as request_subtype,NULL as web_id,NULL as vid_rasch,NULL as FLG_CHILD,NULL as flg_voin,NULL as FLG_MILITARY,NULL as flg_lgt,NULL as FLG_BSP,
 NULL as FLG_SO,NULL as FLG_NU,NULL as FLG_TT,NULL as klass,NULL as kod_lgt,NULL as lgt_reg,NULL as bag_vid,NULL as bag_ves,
 NULL as proc_lgt,NULL as rzd_fpk,NULL as ABONEMENT_TYPE,NULL as ABONEMENT_SUBTYPE,NULL as FLG_OFFICIAL_BENEFIT,
 NULL as TRAIN_CATEGORY,NULL as TRAIN_NUM,NULL as employee_cat,NULL as prod,NULL as flg_sbor,NULL as flg_bil_sbor,
 0 as marshr,NULL as st1,NULL as st2,NULL as rst,NULL as sto_zone,NULL as stn_zone,NULL as sti,NULL as sti_zone,
 NULL as dor,NULL as lin,
 NULL as fio,NULL as fio_2,NULL as snils,NULL as ticket,NULL as benefit_doc,NULL as benefit_podr,NULL as bilgroup 
 from dats_itog2

union all 
select   --расписывание уникальных дат  
 1 as rez,0 as nom_bil,0 as nom_mar,nom_dat,0 as YYYYMM,/*date_zap,*/ NULL as date_beg,NULL as date_end,NULL as date_pr,id,doc_num,0 as request_num,
 NULL as TERM_DOR,NULL as term_pos,NULL as term_trm,NULL as time_zap,NULL as server_reqnum,NULL as drac,0 as agent,0 as chp,0 as stp,0 as stp_reg,
 0 as sto,0 as stn,0 as sto_reg,0 as stn_reg,0 as srasst,kpas_day as k_pas,0 as srok_bil,
 0 as srok_mon,NULL as oper,NULL as oper_g,NULL as flg_bag,NULL as FLG_tuda_obr,NULL as flg_rab_day,i as kol_bil,0 as k_bil,
 0 as plata,0 as poteri,0 as perebor,0 as kom_sbor,0 as kom_sbor_vz,0 as nom,0 as reg,
 0 as d_plata,0 as d_poteri,
 NULL as flg_ruch,0 as request_type,0 as request_subtype,NULL as web_id,NULL as vid_rasch,NULL as FLG_CHILD,0 as flg_voin,NULL as FLG_MILITARY,NULL as flg_lgt,
 NULL as FLG_BSP,NULL as FLG_SO,NULL as FLG_NU,NULL as FLG_TT,NULL as klass,0 as kod_lgt,0 as lgt_reg,
 NULL as bag_vid,0 as bag_ves,0 as proc_lgt,NULL as rzd_fpk,NULL as ABONEMENT_TYPE,NULL as ABONEMENT_SUBTYPE,NULL as FLG_OFFICIAL_BENEFIT,
 NULL as TRAIN_CATEGORY,NULL as TRAIN_NUM,NULL as employee_cat,NULL as prod,NULL as flg_sbor,NULL as flg_bil_sbor,
 0 as marshr,0 as st1,0 as st2,0 as rst,0 as sto_zone,0 as stn_zone,0 as sti,0 as sti_zone,
 0 as dor,0 as lin,
 NULL as fio,NULL as fio_2,NULL as snils,NULL as ticket,NULL as benefit_doc,NULL as benefit_podr,NULL as bilgroup 
 from dats_hash_new_zapis 
 
 
union all --расписывание уникальных  видов билетов
select 2 as rez,nom_bil,0 as nom_mar,NULL as nom_dat,0 as YYYYMM,/*date_zap,*/NULL as date_beg,NULL as date_end,NULL as date_pr,
 id,doc_num,0 as request_num,NULL as TERM_DOR,NULL as term_pos,NULL as term_trm,NULL as time_zap,NULL as server_reqnum,NULL as drac,
 0 as agent,0 as chp,0 as stp,0 as stp_reg,0 as sto,0 as stn,0 as sto_reg,0 as stn_reg,0 as srasst,
 k_pas,srok_bil,srok_mon,oper,oper_g,flg_bag,FLG_tuda_obr,flg_rab_day,0 as kol_bil,0 as k_bil,0 as plata,0 as poteri,0 as perebor,0 as kom_sbor,0 as kom_sbor_vz,
 0 as nom,0 as reg,0 as d_plata,0 as d_poteri,
 flg_ruch,request_type,request_subtype,web_id,vid_rasch,FLG_CHILD,flg_voin,FLG_MILITARY,flg_lgt,FLG_BSP,FLG_SO,FLG_NU,FLG_TT,
klass,kod_lgt,lgt_reg,bag_vid,bag_ves,proc_lgt,rzd_fpk,ABONEMENT_TYPE,ABONEMENT_SUBTYPE,FLG_OFFICIAL_BENEFIT,TRAIN_CATEGORY,TRAIN_NUM,employee_cat,prod,flg_sbor,flg_bil_sbor,
 0 as marshr,NULL as st1,NULL as st2,NULL as rst,NULL as sto_zone,NULL as stn_zone,NULL as sti,NULL as sti_zone,
 NULL as dor,NULL as lin,
 NULL as fio,NULL as fio_2,NULL as snils,NULL as ticket,NULL as benefit_doc,NULL as benefit_podr,NULL as bilgroup 
 from new_bil_zapis
	
	
union all --обогощение по видам билетов
select 3 as rez,nom_bil,0 as nom_mar,NULL as nom_dat,YYYYMM,/*date_zap,*/NULL as date_beg,NULL as date_end,NULL as date_pr,
 id,doc_num,request_num,TERM_DOR,term_pos,term_trm,time_zap,server_reqnum,drac,
 agent,chp,stp,stp_reg,0 as sto,0 as stn,0 as sto_reg,0 as stn_reg,0 as srasst,
 NULL as k_pas,NULL as srok_bil,NULL as srok_mon,NULL as oper,NULL as oper_g,NULL as flg_bag,NULL as FLG_tuda_obr,NULL as flg_rab_day,kol_bil,0 as k_bil,
 plata,poteri,perebor,kom_sbor,kom_sbor_vz,0 as nom,0 as reg,0 as d_plata,0 as d_poteri,
 NULL as flg_ruch,0 as request_type,0 as request_subtype,NULL as web_id,NULL as vid_rasch,NULL as FLG_CHILD,NULL as flg_voin,NULL as FLG_MILITARY,NULL as flg_lgt,NULL as FLG_BSP,
 NULL as FLG_SO,NULL as FLG_NU,NULL as FLG_TT,NULL as klass,NULL as kod_lgt,NULL as lgt_reg,NULL as bag_vid,NULL as bag_ves,
 NULL as proc_lgt,NULL as rzd_fpk,NULL as ABONEMENT_TYPE,NULL as ABONEMENT_SUBTYPE,NULL as FLG_OFFICIAL_BENEFIT,
 NULL as TRAIN_CATEGORY,NULL as TRAIN_NUM,NULL as employee_cat,NULL as prod,NULL as flg_sbor,NULL as flg_bil_sbor,
 0 as marshr,NULL as st1,NULL as st2,NULL as rst,NULL as sto_zone,NULL as stn_zone,NULL as sti,NULL as sti_zone,
 NULL as dor,NULL as lin,
 NULL as fio,NULL as fio_2,NULL as snils,NULL as ticket,NULL as benefit_doc,NULL as benefit_podr,NULL as bilgroup 
 from prig_main_bil
	
	
	union all --промежуточный итог по маршрутам, НОД и число билетов
select 5 as rez,NULL as nom_bil,0 as nom_mar,NULL as nom_dat,0 as YYYYMM,/*NULL as date_zap,*/NULL as date_beg,NULL as date_end,NULL as date_pr,
 id,doc_num,0 as request_num,NULL as TERM_DOR,NULL as term_pos,NULL as term_trm,NULL as time_zap,NULL as server_reqnum,NULL as drac,
 0 as agent,0 as chp,0 as stp,0 as stp_reg,sto,stn,0 as sto_reg,0 as stn_reg,srasst,
 NULL as k_pas,NULL as srok_bil,NULL as srok_mon,NULL as oper,NULL as oper_g,NULL as flg_bag,NULL as FLG_tuda_obr,NULL as flg_rab_day,0 as kol_bil,k_bil,
 0 as plata,0 as poteri,0 as perebor,0 as kom_sbor,0 as kom_sbor_vz,nom,regg as reg,d_plata,d_poteri,
 NULL as flg_ruch,0 as request_type,0 as request_subtype,NULL as web_id,NULL as vid_rasch,NULL as FLG_CHILD,NULL as flg_voin,NULL as FLG_MILITARY,NULL as flg_lgt,NULL as FLG_BSP,
 NULL as FLG_SO,NULL as FLG_NU,NULL as FLG_TT,NULL as klass,NULL as kod_lgt,NULL as lgt_reg,NULL as bag_vid,NULL as bag_ves,
 NULL as proc_lgt,NULL as rzd_fpk,NULL as ABONEMENT_TYPE,NULL as ABONEMENT_SUBTYPE,NULL as FLG_OFFICIAL_BENEFIT,
 NULL as TRAIN_CATEGORY,TRAIN_NUM,NULL as employee_cat,NULL as prod,NULL as flg_sbor,NULL as flg_bil_sbor,
 marshr,st1,st2,rasst as rst,sto_zone,stn_zone,sti,sti_zone,
 NULL as dor,NULL as lin,
 NULL as fio,NULL as fio_2,NULL as snils,NULL as ticket,NULL as benefit_doc,NULL as benefit_podr,NULL as bilgroup 
 from prig_cost2_nodd
	
	
	union all 
select   --расписывание фамилии для реестра
 0 as rez,0 as nom_bil,0 as nom_mar,0 as nom_dat,0 as YYYYMM,/*date_zap,*/ NULL as date_beg,NULL as date_end,NULL as date_pr,id,doc_num,0 as request_num,
 NULL as TERM_DOR,NULL as term_pos,NULL as term_trm,NULL as time_zap,NULL as server_reqnum,NULL as drac,0 as agent,0 as chp,0 as stp,0 as stp_reg,
 0 as sto,0 as stn,0 as sto_reg,0 as stn_reg,0 as srasst,0 as k_pas,0 as srok_bil,
 0 as srok_mon,NULL as oper,NULL as oper_g,NULL as flg_bag,NULL as FLG_tuda_obr,NULL as flg_rab_day,0 as kol_bil,0 as k_bil,
 0 as plata,0 as poteri,0 as perebor,0 as kom_sbor,0 as kom_sbor_vz,0 as nom,0 as reg,
 0 as d_plata,0 as d_poteri,
 NULL as flg_ruch,0 as request_type,0 as request_subtype,NULL as web_id,NULL as vid_rasch,NULL as FLG_CHILD,0 as flg_voin,NULL as FLG_MILITARY,NULL as flg_lgt,
 NULL as FLG_BSP,NULL as FLG_SO,NULL as FLG_NU,NULL as FLG_TT,NULL as klass,0 as kod_lgt,0 as lgt_reg,
 NULL as bag_vid,0 as bag_ves,0 as proc_lgt,NULL as rzd_fpk,NULL as ABONEMENT_TYPE,NULL as ABONEMENT_SUBTYPE,NULL as FLG_OFFICIAL_BENEFIT,
 NULL as TRAIN_CATEGORY,NULL as TRAIN_NUM,NULL as employee_cat,NULL as prod,NULL as flg_sbor,NULL as flg_bil_sbor,
 0 as marshr,0 as st1,0 as st2,0 as rst,0 as sto_zone,0 as stn_zone,0 as sti,0 as sti_zone,
0 as dor,0 as lin,
fio,fio_2,snils,ticket,benefit_doc,benefit_podr,bilgroup 
 from prig_main_ where kod_lgt>0 
)



/**/
select rez,nom_bil,nom_mar,nom_dat,YYYYMM,date_zap,part_zap,date_beg,date_end,date_pr,id,doc_num,request_num,TERM_DOR,term_pos,term_trm,time_zap,server_reqnum,drac,
	agent,0 as subagent,chp,stp,stp_reg,
	sto,stn,sto_reg,stn_reg,srasst,k_pas,srok_bil,srok_mon,oper,oper_g,flg_bag,FLG_tuda_obr,flg_rab_day,kol_bil,k_bil,plata,poteri,perebor,kom_sbor,0 as kom_sbor_vz,
	nom,reg,d_plata,d_poteri,
	flg_ruch,request_type,request_subtype,web_id,vid_rasch,FLG_CHILD,flg_voin,FLG_MILITARY,flg_lgt,
	FLG_BSP,FLG_SO,FLG_NU,FLG_TT,klass,kod_lgt,lgt_reg,
	bag_vid,bag_ves,proc_lgt,rzd_fpk,ABONEMENT_TYPE,ABONEMENT_SUBTYPE,FLG_OFFICIAL_BENEFIT,TRAIN_CATEGORY,TRAIN_NUM,employee_cat,prod,flg_sbor,flg_bil_sbor,
	marshr,st1,st2,rst,sto_zone,stn_zone,sti,sti_zone,dor,lin,
	fio,fio_2,snils,ticket,benefit_doc,benefit_podr,bilgroup 
	from itog,dates 
	;
/**/


/**/

--- ввод времени окончания операции с итоговым числом записей
insert into  l3_prig.prig_times(time,date,oper,time2,date_zap,part_zap,shema,rezult)
with a as
(select date_zap,part_zap,shema,current_date as date,substr(cast(clock_timestamp()::time as char(50)),1,12) as time
 from  l3_prig.prig_times where oper='dannie' --and substr(shema,5,4)='prig'
),
b as (select count(*) as rezult from l3_prig.prig_work)
select time,date,'prig_work 2_1_rez' as oper,
(cast(substr(time,1,2) as dec(3))*60+cast(substr(time,4,2) as dec(3)))*60+cast(substr(time,7,6) as dec(7,3)) as time2,date_zap,part_zap,shema,rezult
from a left join b on 1=1 ;

/**/












--------------------


