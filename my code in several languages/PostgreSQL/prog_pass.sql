
/*
НАДО
1.ЛОГИ
2.ОПИСАНИЕ 2 И 3 УРОВНЯ, АЛГОРИТМ ЗАПОЛНЕНИЯ
3.ПЕРЕДАЧА В ГВЦ ДАННЫХ СОГЛАСНО МАКЕТА. в минимально необходимых объёмах
4.НЕДОСТАЮЩИЕДАННЫЕ ПО КЛАССУ 4 ИЗ НЕКОЕЙ ИНОЙ ТАБЛИЦЫ



---   select count(*) from rawdl2m.l2_pass_main  -- 23 916 715 - база пассажирских перевозок

select distinct train_category from rawdl2m.l2_prig_main -- все классы поезда в базе

select * from rawdl2m.l2_pass_main 
fetch first 5 rows only



select * from rawdl2m.l2_pass_cost
fetch first 5 rows only

*/

ЗАГРУЗКИ НЕТ И НЕ БУДЕТ - ТАБЛИЦЫ СОВССЕМ ИНОЙ СТРУКТУРЫ. ПРОЩЕ ДОБАТИТЬ АГРЕГАТЫ ОТ ВЫЧИСЛЕНИЙ ЧУЖОЙ ПРОГРАММЫ



/**/

select * from rawdl2m.l2_pass_main   where --REQUEST_DATE  in (select distinct date_zap from  spb_prig.prig_times where oper='dannie') and
	 substr(train_num,1,1)='8' and substr(train_num,4,1) in ('А','М','Г','Х','И','Й')
	and AGENT_CODE=41 and SALE_STATION =2006200 and DEPARTURE_STATION=2006200 and ARRIVAL_STATION=2004451
	and departure_date='2021-08-02'  --TICKET_BEGDATE ='2021-08-02'
	
SELECT * FROM  rawdl2m.l2_pass_cost
where id in (select id from rawdl2m.l2_pass_main   where --REQUEST_DATE  in (select distinct date_zap from  spb_prig.prig_times where oper='dannie') and
	 substr(train_num,1,1)='8' and substr(train_num,4,1) in ('А','М','Г','Х','И','Й')
	and AGENT_CODE=41 and SALE_STATION =2006200 and DEPARTURE_STATION=2006200 and ARRIVAL_STATION=2004451
	and departure_date='2021-08-02')
	


select max(kol) from
(SELECT id,doc_num,count(*) as kol FROM  rawdl2m.l2_pass_cost where REQUEST_DATE='2021-08-02' group by 1,2) as a


select * from
(SELECT id,doc_num,count(*) as kol FROM  rawdl2m.l2_pass_cost where REQUEST_DATE='2021-08-02' group by 1,2) as a where kol=20


select * FROM  rawdl2m.l2_pass_cost where  id=311226484

select * FROM  rawdl2m.l2_pass_main where  id=311226484

/**/



with

RECURSIVE rrr AS (SELECT 0 AS i
    UNION SELECT i+1 AS i FROM rrr WHERE i < 10000),

rrr0 as (select distinct i from rrr where i>0),

dates as  --дата загружаемых данных
(select distinct date_zap from  spb_prig.prig_times where oper='dannie'),

pass_main as(select
--REQUEST_NUM,TERM_TRM,ARXIV_CODE,REPLY_CODE,REQUEST_TIME,REQUEST_TYPE,REQUEST_SUBTYPE,ELS_CODE,PAYAGENT_ID,WEB_ID,TICKET_SER,TICKET_NUM,
--DOC_TYPE,RETURN_DATE,FEE_SUM,FEE_VAT,REFUNDFEE_SUM,REFUNDDEPART_SUM,DATE_TEMPLATE, --уходят без переработки, совсем, за ненадобностью
--OPER,OPER_G,FLG_2WAYTICKET,FLG_1WAYTICKET,SEATSTICK_LIMIT -- ушли с переработкой
--TICKET_ENDDATE --ушло ввиду откровенной грязи

ID,DOC_NUM,row_number() over (order by id,doc_num) as idd,
YYYYMM,REQUEST_DATE as date_zap,TERM_POS,TERM_DOR,term_trm,

oper_date as date_pr --OPERATION_DATE as date_pr,
departure_date as date_beg, --TICKET_BEGDATE as date_beg,
--TRAIN_CATEGORY,
TRAIN_NUM,
oper||'-'||oper_g||'-'||oper_x as oper
case when oper_g='G' then -1 else 1 end as koef, --если гашение, то взять с коэф=-1 все параметры
REGISTRATION_METHOD as flg_ruch, --флаг 0=ручник, 1=экспресс
AGENT_CODE as agent, --агент продажи
carrier_code as chp,  --вместо CARRIAGE_CODE as chp,--перевозчик
PAYMENTTYPE as vid_rasch, --вид расчёта (=1,6,8)

SALE_STATION as stp,
saleregion_code as stp_reg, --REGION_CODE as stp_reg,
DEPARTURE_STATION as sto,
99 as sto_zone,
ARRIVAL_STATION as stn,
99 as stn_zone,
0 as sti,0 as sti_zone,

--FLG_CHILD,
--FLG_MILITARY,
--FLG_BENEFIT as flg_lgt,
--FLG_BSP,
--FLG_SO,
--FLG_NU,
--FLG_TT,
MILITARY_CODE as flg_voin,

CARRIAGE_CLASS as klass, --некий класс
BENEFIT_CODE as kod_lgt
--,BENEFIT_REGION as lgt_reg,

--FLG_CARRYON as flg_bag,
--case when CARRYON_TYPE='' then '-' else CARRYON_TYPE end as bag_vid,
--CARRYON_WEIGHT as bag_ves, --в поле указан вес одного багажа, а не всех, и не возврата

--case when FLG_2WAYTICKET='1' then '2' 
--	when FLG_1WAYTICKET='1' then '1' else '2' end as FLG_tuda_obr, --признак туда=1, туда-обратно=2
--case when FLG_2WAYTICKET='1' then 2 
--	when FLG_1WAYTICKET='1' then 1 else 2 end as k_tuda_obr, --коэф туда=1, туда-обратно=2

persons_qty as kol_pas,seats_qty as kol_pas2
--PASS_QTY*(case when oper_g='G' then -1 else 1 end) as kol_bil, --в том числе и багажные билеты, по многу штук.
--TARIFF_SUM*(case when oper_g='G' then -1 else 1 end) as plata,
--DEPARTMENT_SUM*(case when oper_g='G' then -1 else 1 end) as poteri,
--(case when TOTAL_SUM=0 then 0
--	when abs(TARIFF_SUM+DEPARTMENT_SUM-TOTAL_SUM)<abs(TARIFF_SUM-TOTAL_SUM) then TOTAL_SUM-TARIFF_SUM-DEPARTMENT_SUM
--	else TOTAL_SUM-TARIFF_SUM end)
--*(case when oper_g='G' then -1 else 1 end) as perebor,

--case --when FLG_BSP='1' then 100 
--	when BENEFIT_PERCENT=0 then 0
--	else 100-BENEFIT_PERCENT end as proc_lgt,

--ABONEMENT_TYPE, --тип абонемента
--cast(case when ABONEMENT_TYPE='0' then 1
--	when ABONEMENT_TYPE='1' then SEATSTICK_LIMIT/2
--	when ABONEMENT_TYPE='2' then SEATSTICK_LIMIT
--	when ABONEMENT_TYPE='3' then SEATSTICK_LIMIT*25
--	when ABONEMENT_TYPE='4' and SEATSTICK_LIMIT=5 then 5 --заплатка
--	when ABONEMENT_TYPE='4' then SEATSTICK_LIMIT*0.8
--	when ABONEMENT_TYPE='5' then SEATSTICK_LIMIT*6
--	when ABONEMENT_TYPE='6' then SEATSTICK_LIMIT*0
--	when ABONEMENT_TYPE='7' then SEATSTICK_LIMIT*21
--	when ABONEMENT_TYPE='8' then 
--		case when SEATSTICK_LIMIT=15 then 10
--		when SEATSTICK_LIMIT=25 then 18
--		else SEATSTICK_LIMIT*0.7 end
--end as dec(5)) as k_pas, --количество поездок по 1 билету в 1 сторону за весь срок действия билета

--case when ABONEMENT_TYPE in('5','6') then '1' --выходного дня
	 --when ABONEMENT_TYPE in('7','8') then '2' --рабочего дня
	--else '0' end as flg_rab_day,

/*case when ABONEMENT_TYPE='0' then 1
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
*/
from rawdl2m.l2_pass_main   where REQUEST_DATE  in (select date_zap from dates)
	and substr(train_num,1,1)='8' and substr(train_num,4,1) in ('А','М','Г','Х','И','Й')

			--	 and id in (314788575)
			)
			
select count(*) from pass_main			












