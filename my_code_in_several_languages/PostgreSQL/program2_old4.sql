
--ПРОГРАММА ПЕРВИЧНОЙ ПЕРЕРАБОТКИ ДАННЫХ, НАРАБОТКА СПРАВОЧНИКА БИЛЕТВ И МАРШРУТОВ, 
--ПОЛУЧЕНИЕ ОТПРАВЛЕННЫХ ПАССАЖИРОВ ПО ДАТАМ ОТПРАВЛЕНИЯ СОКРАЩЕНИЕ ЧИСЛА ЗАПИСЕЙ БЕЗ ПОТЕРИ ИНФОРМАЦИИ



--- ввод времени начала операции
insert into  spb_prig.prig_times(time,date,oper,time2,date_zap)
with a as
(select current_date as date,substr(cast(current_time as char(50)),1,12) as time_,substr(cast(clock_timestamp()::time as char(50)),1,12) as time),
b as
(select date_zap from  spb_prig.prig_times where oper='dannie')
select time,date,'prig_work 1_beg' as oper,
(cast(substr(time,1,2) as dec(3))*60+cast(substr(time,4,2) as dec(3)))*60+cast(substr(time,7,6) as dec(7,3)) as time2,date_zap
from a left join b on 1=1;




delete from spb_prig.prig_work;
delete from spb_prig.prig_itog;

insert into spb_prig.prig_work(
	rez,nom_bil,nom_mar,YYYYMM,date_zap,date_beg,id,doc_num,TERM_POS,TERM_DOR,date,agent,chp,stp,stp_reg,
	sto,stn,sto_reg,stn_reg,srasst,k_pas,srok_bil,srok_mon,flg_bag,FLG_tuda_obr,flg_rab_day,kol_bil,plata,poteri,perebor,
	nedobor,nom,reg,d_plata,d_poteri,sf_pas,kol_pas,
	flg_ruch,vid_rasch,FLG_CHILD,flg_voin,FLG_MILITARY,flg_lgt,
	FLG_BSP,FLG_SO,FLG_NU,FLG_TT,klass,kod_lgt,lgt_reg,
	bag_vid,bag_ves,proc_lgt,ABONEMENT_TYPE,TRAIN_CATEGORY,TRAIN_NUM,
	marshr,st1,st2,rst,sto_zone,stn_zone,sti,sti_zone,dor,lin )


with

RECURSIVE rrr AS (SELECT 0 AS i
    UNION SELECT i+1 AS i FROM rrr WHERE i < 1000),
	

date as  --дата загружаемых данных
(select date_zap from  spb_prig.prig_times where oper='dannie'),

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

from rawdl2.l2_prig_main   where REQUEST_DATE ----='2021-07-04' 
			 in (select date_zap from date)
				--	and	 id=316230800
			),


--date as --дата загружаемых данных
--(select distinct date_zap from prig_main),


lin_ as --структура всех линий
(select dor,lin,kst,rst,reg,ROW_NUMBER() over (partition by dor,lin order by rst) as nom from
(select cast(nom3d as dec(3)) as dor,cast(noml as dec(3)) as lin,cast(stan as dec(7)) as kst,rstk as rst,cast(sf as dec(3)) as reg
	from nsi.lines as a,date as b where date_zap between datand and datakd and date_zap between datani and dataki) as a),


lin as --в линиях исправлены регионы, и добавлены порядковые номера регионов
(select dor,lin,rst,kst,nom,reg,nreg,max(reg) over (partition by dor,lin,nreg) as reglin,10000*dor+lin as dorlin from
(select dor,lin,rst,kst,nom,reg,rg,sum(nn) over (partition by dor,lin order by nom) as nreg from
(select d.dor,d.lin,rst,kst,d.nom,reg,case when nn=1 then 0 else reg end as rg,
 case when d.nom=1 or reg=0 or nn=1 then 1 else 0 end as nn
from lin_ as d left join
(select a.dor,a.lin,a.nom,1 as nn from lin_ as a,lin_ as b
	where a.dor=b.dor and a.lin=b.lin and a.nom=b.nom+1 and a.reg!=0 and b.reg!=0 and a.reg!=b.reg) as c
	on d.dor=c.dor and d.lin=c.lin and d.nom=c.nom) as e) as f),

dorlin as
(select distinct dor,lin,dorlin from lin),


linp as --по линиям - все промежуточные пары станций
(select a.dorlin,a.kst as kst_1,b.kst as kst_2,a.nom as nom1,b.nom as nom2,a.rst as r_1,b.rst as r_2,
 case when a.nom<b.nom then 1 else -1 end as napr_lin,
 case when a.reg>0 and a.nom<b.nom then a.reg when b.reg>0 and b.nom<a.nom then b.reg
 when a.reg>0 then a.reg else b.reg end as reg
from lin as a,lin as b where a.dorlin=b.dorlin and abs(a.nom-b.nom)=1),




prig_cost as --исходник пригород по перегонам по субъектам
(select  ID,DOC_NUM,doc_reg as nom,
--YYYYMM,REQUEST_DATE,REQUEST_NUM,TERM_POS,TERM_DOR,TERM_TRM,ARXIV_CODE,REPLY_CODE, --не нужны
	ROUTE_NUM as marshr,cast(ROUTE_DISTANCE as dec(7)) as rasst,
	sum(cast(ROUTE_DISTANCE as dec(7))) over(partition by ID,DOC_NUM) as srasst,
	TARIFF_SUM as d_plata,DEPARTMENT_SUM as d_poteri,
	DEPARTURE_STATION as st1,ARRIVAL_STATION as st2,
 case when id=275367223*0 then 0 else REGION_CODE end as reg,
	max(doc_reg) over (partition by ID,DOC_NUM) as max_nom,
	sum(TARIFF_SUM) over (partition by ID,DOC_NUM) as s_plata,
	sum(DEPARTMENT_SUM) over (partition by ID,DOC_NUM) as s_poteri 
from rawdl2.l2_prig_cost where REQUEST_DATE in(select date_zap from date) 
   --  and id=316230800
),

marshr_ish as --список всех маршрутов
(select ssm_nmar as marshr,round(ssm_rst) as rst,cast(ssm_stan as decimal(7)) as kst,
 case when ssm_ksf=' ' then 0 else cast(ssm_ksf as decimal(3)) end as reg,
	case when ssm_prgr='1' or ssm_prgs='1' then '1' else '0' end as perelom,
	ROW_NUMBER() over (partition by ssm_nmar order by ssm_rst) as nom
	from prig.submars ),


mar_n as
(select a.marshr,b.nom,1 as k
	from marshr_ish as a,marshr_ish as b where a.marshr=b.marshr and a.nom=b.nom-1 and a.reg!=b.reg),

marshr as --маршрут расписанный с метками начала действия нового региона
(select marshr,rst,kst,reg,perelom,nom,k,
 SUM(k) OVER (partition by marshr order by rst) as nomk
 from
(select a.marshr,rst,kst,reg,perelom,a.nom,case when k=1 or a.nom=1 or perelom='1' then 1 else 0 end as k
from marshr_ish as a left join mar_n as b on a.marshr=b.marshr and a.nom=b.nom 
 where a.marshr in (select distinct marshr from prig_cost )
) as c),


sts as --список всех ВАРИАНТОВ  по перегонам-регионам маршрутов
(select marshr,st1,st2,rasst,regg,mid, 
 ROW_NUMBER() over (order by marshr,st1,st2,rasst,regg) as nom_sts
 from
 (select marshr,st1,st2,rasst,reg as regg,min(id) as mid
 from prig_cost group by 1,2,3,4,5) as a),


sts1_0 as --список всех ВАРИАНТОВ  найденых в маршрутах
(select a.marshr,st1,st2,rasst,b.rst as rst1,c.rst as rst2,regg,mid,nom_sts,
 b.nomk as nomk1,c.nomk as nomk2,b.nom as nom1,c.nom as nom2,b.reg as reg1,c.reg as reg2
 from sts as a
 	left join marshr as b on a.marshr=b.marshr and st1=b.kst
	left join marshr as c on a.marshr=c.marshr and st2=c.kst),
	
	
stan_bad as --список каких станций не хватает в маршрутах  --29 штук
(select marshr,kst,min(mid) as mid from 
(select  marshr,st1 as kst,rst1 as rst,mid from sts1_0 union all select  marshr,st2,rst2,mid  from sts1_0)  as a
		where rst is null group by 1,2),	
	
sts1 as -- если внутри маршрута несколько вариантов - оставить 1 вариант. лучший по расстоянию
(select marshr,st1,st2,rasst,rst1,rst2,regg,mid,nom_sts,nom1,nom2,nomk1,nomk2,reg1,reg2,
 case when rst1<rst2 then 1 else -1 end as napr_mar,rasst-abs(rst1-rst2) as dd
 from
(select *,ROW_NUMBER() over (partition by  nom_sts order by dd) as nd
 from
(select marshr,st1,st2,rasst,rst1,rst2,regg,mid,nom_sts,nom1,nom2,nomk1,nomk2,reg1,reg2,
 abs(rasst-abs(rst1-rst2)) as dd
 from sts1_0 where rst1 is not null and rst2 is not null) as a) as b where nd=1
union all
 select marshr,st1,st2,rasst,NULL as rst1,NULL as rst2,regg,mid,nom_sts,
 0 as nom1,0 as nom2,0 as nomk1,0 as nomk2,0 as reg1,0 as reg2,0 as napr_mar,NULL as dd
  from (select distinct marshr,st1,st2,rasst,regg,mid,nom_sts from sts1_0  where rst1 is null or rst2 is null) as c
),
	
	
	
		
rast_bad as --список пар станций с неправильно установленными расстояниями
(select marshr,st1,st2,rasst,min(mid) as mid from sts1 where dd>0 and dd is not null group by 1,2,3,4),
		
		
sts_good as --список вариантов, укладывающихся строго в 1 регион
(select marshr,st1,st2,rasst,regg,rst1,rst2,reg1 as reg,nom_sts from sts1 where nomk1=nomk2 and nomk1>0 and dd=0),

sts2 as -- нужные к поиску пары станций, в обоих направлениях
(select marshr,st1,st2,rasst,regg,rst1,rst2,nom1,nom2,nomk1,nomk2,mid,nom_sts,
 --case when rst1<rst2 then 1 else -1 end as 
 napr_mar,
 ROW_NUMBER() over (order by marshr,st1,st2,rasst,regg,rst1,rst2,nom1,nom2,nomk1,nomk2,reg1) as nnnn
 from sts1 --where nomk1!=nomk2 
),

/*mars_p as --пары станций маршрута внутри 1 региона, туда
(select a.marshr,a.kst as kst1,b.kst as kst2,a.nom as nom1,b.nom as nom2,a.nomk,a.k as beg_,b.k as end_,b.rst-a.rst as rst,
 case when a.reg=0 then b.reg when b.reg=0 then a.reg
 	when a.perelom='1' then b.reg when b.perelom='1' then a.reg 
 	when a.reg!=b.reg then -1 else a.reg end as reg
from marshr as a,marshr as b where a.marshr=b.marshr and 
 a.nom<b.nom and ((a.nomk=b.nomk-1 and  b.k=1) or (a.nomk=b.nomk and a.k=1 and a.nom>1))	
),*/

mars_p as --пары станций маршрута внутри 1 региона, туда
(select a.marshr,a.kst as kst1,b.kst as kst2,a.nom as nom1,b.nom as nom2,a.nomk,abs(b.rst-a.rst) as rast,
 case when a.nom<b.nom then 1 else -1 end as napr_mar,
 case when a.reg=0 then b.reg when b.reg=0 then a.reg
 	when a.perelom='1' then b.reg when b.perelom='1' then a.reg 
 	when a.reg!=b.reg then -1 else a.reg end as reg
from marshr as a,marshr as b where a.marshr=b.marshr and 
 --a.nom<b.nom and ((a.nomk=b.nomk-1 and  b.k=1) or (a.nomk=b.nomk and a.k=1 and a.nom>1))	
 abs(a.nom-b.nom)=1
),

sts_3 as -- нужные к поиску пары станций, в направлении маршрута
(select marshr,st1,st2,rasst,regg,rst1,rst2,nom1,nom2,nomk1,nomk2,napr_mar,nnnn,mid,nom_sts
  from sts2 where napr_mar=1
union all
 select marshr,st1,st2,rasst,regg,rst2,rst1,nom2,nom1,nomk2,nomk1,napr_mar,nnnn,mid,nom_sts
  from sts2 where napr_mar=-1),


umn as --роспись всех кусков, только в направлении маршрута
(select a.marshr,st1,st2,rasst,regg,a.napr_mar,nnnn,kst1,kst2,b.nom1,b.nom2,rast,b.reg,mid,nom_sts
		from sts_3 as a,mars_p as b
where a.marshr=b.marshr and b.nom1 between a.nom1 and a.nom2 and b.nom2 between a.nom1 and a.nom2
 and a.napr_mar=b.napr_mar
--	and ((a.nomk1<nomk and beg_=1) or a.nom1=b.nom1) and ((a.nomk2>nomk and end_=1) or a.nom2=b.nom2) 
),
	
	
umn_1 as --роспись всех кусков, только в направлении маршрута
(select marshr,st1,st2,rasst,regg,nom_sts,mid,napr_mar as napr,kst1,kst2,nom1,nom2,rast,reg,nnnn,
ROW_NUMBER() over (partition by nom_sts order by napr_mar*nom1) as nom_mar
from
(select marshr,st1,st2,rasst,regg,nom_sts,mid,napr_mar,nnnn,kst1,kst2,nom1,nom2,rast,reg
		from umn
union all
select marshr,st1,st2,rasst,regg,nom_sts,mid,napr_mar,0 as nnnn,st1 as kst1,st2 as kst2,nom1,nom2,rasst as rast,0 as reg
		from sts1 where napr_mar=0
 ) as a),
	
stsm as --список всех перегонов по линиям
(select *,ROW_NUMBER() over (order by kst1,kst2,rast) as nom_stsm from
(select distinct kst1,kst2,rast from umn_1) as a),
	
	
--НАДО поставить возможность неточного определения расстояния, если точное никак нельзя
stsm_1 as --кого смогли найти внутри 1 линии, минимальное отличие расстояний
--добавил rst_lin- получившеся расстояние по линиям, возможно отлично от rast. И dr - разница расстояний
(select nom_stsm,kst1,kst2,rast,dorlin,r1,r2,reg1,reg2,nreg1,nreg2,nom1,nom2,rst_lin,abs(rast-rst_lin) as dr from
(select nom_stsm,kst1,kst2,rast,dorlin,r1,r2,reg1,reg2,nreg1,nreg2,nom1,nom2,rst_lin,
 ROW_NUMBER() over (partition by nom_stsm order by dr,dorlin) as nom
 from
(select nom_stsm,kst1,kst2,rast,b.dorlin,b.rst as r1,c.rst as r2,b.reglin as reg1,c.reglin as reg2,abs(b.rst-c.rst) as rst_lin,
 b.nreg as nreg1,c.nreg as nreg2,b.nom as nom1,c.nom as nom2,abs(rast-abs(b.rst-c.rst)) as dr
 from stsm as a join lin as b on kst1=b.kst join lin as c on kst2=c.kst and b.dorlin=c.dorlin) as d)as e where nom=1),
	
	

lin2 as -- пересечения всех линий
(select a.dorlin,a.kst,a.rst,b.dorlin as dorlinp,b.rst as rstp,a.nom,b.nom as nomp
from lin as a,lin as b where a.kst=b.kst and (a.dorlin!=b.dorlin)),


stsm_2 as --поиск по точному совпадению растояний, по 2 линиям
--добавил rst_lin- получившеся расстояние по линиям, возможно отлично от rast. И dr - разница расстояний
(select * from
(select *,row_number() over (partition by nom_stsm order by dr) as nn
 from
(select *,abs(abs(rst1-rst_1)+abs(rst2-rstp1)-rast) as dr,abs(rst1-rst_1)+abs(rst2-rstp1) as rst_lin
 from
(select kst1,kst2,rast,nom_stsm,b.dorlin as dorlin1,b.rst as rst1,b.nom as nom1,c.dorlin as dorlin2,c.rst as rst2,c.nom as nom2,
	d.kst as kst_1,d.rst as rst_1,d.nom as nom_1,d.rstp as rstp1,d.nomp as nomp1, d.dorlinp
--	e.kst as kst_2,e.rst as rst_2,e.nom as nom_2,e.rstp as rstp2,e.nomp as nomp2
from  (select * from stsm
 where nom_stsm not in(select nom_stsm from stsm_1 where dr=0)) as a
join lin as b on kst1=b.kst join lin as c on kst2=c.kst
join lin2 as d on b.dorlin=d.dorlin and c.dorlin=d.dorlinp) as f
) as g) as h where nn=1),


stsm_2_1 as --преобразование найденного к нормальному списочному виду
(select  kst1,kst2,rast,nom_stsm,rst_lin,dr,kst1 as st1,kst_1 as st2,dorlin1 as dorlin,nom1,nom_1 as nom2,
 rst1 as r1,rst_1 as r2,1 as np
from stsm_2
union all
select  kst1,kst2,rast,nom_stsm,rst_lin,dr,kst_1 as st1,kst2 as st2,dorlin2 as dorlin,nomp1 as nom1,nom2,
 rstp1 as r1,rst2 as r2,2 as np
from stsm_2),




stsm_3 as --поиск по точному совпадению растояний, по 3 линиям
--добавил rst_lin- получившеся расстояние по линиям, возможно отлично от rast. И dr - разница расстояний
(select * from
(select *,row_number() over (partition by nom_stsm order by dr) as nn
 from
(select *,abs(abs(rst1-rst_1)+abs(rst2-rst_2)+abs(rstp1-rstp2)-rast) as dr,abs(rst1-rst_1)+abs(rst2-rst_2)+abs(rstp1-rstp2) as rst_lin
 from
(select kst1,kst2,rast,nom_stsm,b.dorlin as dorlin1,b.rst as rst1,b.nom as nom1,c.dorlin as dorlin2,c.rst as rst2,c.nom as nom2,
	d.kst as kst_1,d.rst as rst_1,d.nom as nom_1,d.dorlinp,d.rstp as rstp1,d.nomp as nomp1,
	e.kst as kst_2,e.rst as rst_2,e.nom as nom_2,e.rstp as rstp2,e.nomp as nomp2
from  (select * from stsm
 where nom_stsm not in(select nom_stsm from stsm_1 where dr=0) and nom_stsm not in(select nom_stsm from stsm_2 where dr=0)) as a
join lin as b on kst1=b.kst join lin as c on kst2=c.kst
join lin2 as d on b.dorlin=d.dorlin 
join lin2 as e on c.dorlin=e.dorlin and d.dorlinp=e.dorlinp) as f
--where rast=abs(rst1-rst_1)+abs(rst2-rst_2)+abs(rstp1-rstp2)
) as g) as h where nn=1),


stsm_3_1 as --преобразование найденного к нормальному списочному виду
(select  kst1,kst2,rast,nom_stsm,rst_lin,dr,kst1 as st1,kst_1 as st2,dorlin1 as dorlin,nom1,nom_1 as nom2,
 rst1 as r1,rst_1 as r2,1 as np
from stsm_3
union all
select  kst1,kst2,rast,nom_stsm,rst_lin,dr,kst_1 as st1,kst_2 as st2,dorlinp as dorlin,nomp1 as nom1,nomp2 as nom2,
 rstp1 as r1,rstp2 as r2,2 as np
from stsm_3
union all 
select  kst1,kst2,rast,nom_stsm,rst_lin,dr,kst_2 as st1,kst2 as st2,dorlin2 as dorlin,nom_2 as nom1,nom2,
 rst_2 as r1,rst2 as r2,3 as np
from stsm_3),




stsm_4 as --поиск по точному совпадению растояний, по 4 линиям
--добавил rst_lin- получившеся расстояние по линиям, возможно отлично от rast. И dr - разница расстояний
(select * from
(select *,row_number() over (partition by nom_stsm order by dr) as nn
 from
(select *,
 abs(rst1-rst_1)+abs(rstp1-rstp_1)+abs(rstp2-rstp_2)+abs(rst2-rst_2) as rst_lin,
 abs(abs(rst1-rst_1)+abs(rstp1-rstp_1)+abs(rstp2-rstp_2)+abs(rst2-rst_2)-rast) as dr
 from
(select
 kst1,kst2,rast,nom_stsm,b.dorlin as dorlin1,b.rst as rst1,b.nom as nom1,c.dorlin as dorlin2,c.rst as rst2,c.nom as nom2,
	d.kst as kst_1,d.rst as rst_1,d.nom as nom_1,d.dorlinp as dorlinp1,d.rstp as rstp1,d.nomp as nomp1,
	e.kst as kst_2,e.rst as rst_2,e.nom as nom_2,e.dorlinp as dorlinp2,e.rstp as rstp2,e.nomp as nomp2,
 	f.kst as kstp,f.rst as rstp_1,f.nom as nomp_1,f.rstp as rstp_2,f.nomp as nomp_2
from  (select * from stsm
 where nom_stsm not in(select nom_stsm from stsm_1 where dr=0) and nom_stsm not in(select nom_stsm from stsm_2 where dr=0)
	   and nom_stsm not in(select nom_stsm from stsm_3 where dr=0)) as a
join lin as b on kst1=b.kst join lin as c on kst2=c.kst
join lin2 as d on b.dorlin=d.dorlin 
join lin2 as e on c.dorlin=e.dorlin --and d.dorlinp=e.dorlinp
 join lin2 as f on d.dorlinp=f.dorlin and f.dorlinp=e.dorlinp
) as f 
 --where rast= abs(rst1-rst_1)+abs(rstp1-rstp_1)+abs(rstp2-rstp_2)+abs(rst2-rst_2)
) as g) as h where nn=1),



stsm_4_1 as --преобразование найденного к нормальному списочному виду
--добавил rst_lin- получившеся расстояние по линиям, возможно отлично от rast. И dr - разница расстояний
(select  kst1,kst2,rast,nom_stsm,rst_lin,dr,kst1 as st1,kst_1 as st2,dorlin1 as dorlin,nom1,nom_1 as nom2,
 rst1 as r1,rst_1 as r2,1 as np
from stsm_4
union all 
select  kst1,kst2,rast,nom_stsm,rst_lin,dr,kst_1 as st1,kstp as st2,dorlinp1 as dorlin,nomp1 as nom1,nomp_1 as nom2,
 rstp1 as r1,rstp_1 as r2,2 as np
from stsm_4
union all  
select  kst1,kst2,rast,nom_stsm,rst_lin,dr,kstp as st1,kst_2 as st2,dorlinp2 as dorlin,nomp_2 as nom1,nomp2 as nom2,
 rstp_2 as r1,rstp2 as r2,3 as np
from stsm_4
union all  
select  kst1,kst2,rast,nom_stsm,rst_lin,dr,kst_2 as st1,kst2 as st2,dorlin2 as dorlin,nom_2 as nom1,nom2,
 rst_2 as r1,rst2 as r2,4 as np
from stsm_4),





stsm_p_0  as --объединение всех найденных
(select nom_stsm,kst1,kst2,rast,dorlin,st_1,st_2,np,r1,r2,nom1,nom2,rst_lin,dr,ff,
 case when nreg1=nreg2 then reg1 when nom1=nom2-1 then reg1 when nom1=nom2+1 then reg2 else 0 end as reg,
	case when r1<r2 then 1 else -1 end as napr_lin,abs(r1-r2) as rst,
 sum(abs(r1-r2)) over (partition by nom_stsm,ff) as srst,sum(abs(r1-r2)) over (partition by nom_stsm,ff order by np) as srst_
 from 
(select nom_stsm,kst1,kst2,rast,rst_lin,dr,dorlin,r1,r2,reg1,reg2,kst1 as st_1,kst2 as st_2,nreg1,nreg2,nom1,nom2,0 as np,1 as ff from stsm_1 
 union all
 select  nom_stsm,kst1,kst2,rast,rst_lin,dr,dorlin,r1,r2,0 as reg1,0 as reg2,st1 as st_1,st2 as st_2,
 0 as nreg1,0 as nreg2,nom1,nom2, np,2 as ff
 from stsm_2_1 
 union all
 select  nom_stsm,kst1,kst2,rast,rst_lin,dr,dorlin,r1,r2,0 as reg1,0 as reg2,st1 as st_1,st2 as st_2,
 0 as nreg1,0 as nreg2,nom1,nom2, np,3 as ff 
 from stsm_3_1 
 union all
 select  nom_stsm,kst1,kst2,rast,rst_lin,dr,dorlin,r1,r2,0 as reg1,0 as reg2,st1 as st_1,st2 as st_2,
 0 as nreg1,0 as nreg2,nom1,nom2, np,4 as ff 
 from stsm_4_1
) as a),


stsm_p as
(select b.nom_stsm,kst1,kst2,rast,dorlin,st_1,st_2,np,r1,r2,nom1,nom2,rst_lin,dr,b.ff,reg,napr_lin,rst,srst,srst_
 from
(select nom_stsm,ff from
(select nom_stsm,ff,row_number() over(partition by nom_stsm order by dr,ff,np) as nn
from stsm_p_0) as a where nn=1) as b join stsm_p_0 as c on b.nom_stsm=c.nom_stsm and b.ff=c.ff),

--select * from stsm_p where nom_stsm=10263 order by nom_stsm,ff,np;

/*		*/
		
umn_2 as --полная роспись всех кусков, только в направлении маршрута
(select marshr,st1,st2,rasst,regg,nom_sts,mid,napr_mar,nnnn,/*nom_mar,*/
 nom_stsm,dorlin,/*np,r1,r2,*/nom1,nom2,napr_lin,/*rst,srst,*/
 case when regg>0 then regg when reg_mar>0 then reg_mar else reg_lin end as reg_mar,
 case when np>0 then st_1 else kst1 end as kst1,
 case when np>0 then st_2 else kst2 end as kst2,
 case when np=0 or np is null then rast
 	when rast=srst then rst else round(srst_*rast/srst)-round((srst_-rst)*rast/srst) end as rast,
 ROW_NUMBER() over (partition by nom_sts order by nom_mar,np) as nom_mar
 from 
(select marshr,st1,st2,rasst,regg,nom_sts,mid,napr as napr_mar,a.kst1,a.kst2,a.rast,a.reg as reg_mar,nnnn,nom_mar, 
 nom_stsm,dorlin,st_1,st_2,np,r1,r2,b.nom1,b.nom2,b.reg as reg_lin,napr_lin,rst,srst,srst_
from umn_1 as a left join stsm_p as b
on a.kst1=b.kst1 and a.kst2=b.kst2 and a.rast=b.rast order by nom_sts,nom_mar,np) as c),
	

stsm_rez as
(select marshr,st1,st2,rasst,regg,nom_sts,mid,napr_mar,nnnn,nom_mar,nom_stsm,dorlin,napr_lin,reg_mar,
 kst1,kst2,np,
 case when rasst=srst then rst else round(srst_*rasst/srst)-round((srst_-rst)*rasst/srst) end as rast 
 from 
(select marshr,st1,st2,rasst,regg,nom_sts,mid,napr_mar,nnnn,nom_mar,nom_stsm,a.dorlin,a.napr_lin,reg as reg_mar,/*kst1,kst2,*/rast,
 b.nom1,b.nom2,kst_1 as kst1,kst_2 as kst2,r_1,r_2,abs(r_1-r_2) as rst,
 sum(abs(r_1-r_2)) over (partition by nom_stsm) as srst,
 sum(abs(r_1-r_2)) over (partition by nom_stsm order by nom_mar,a.napr_lin*b.nom1) as srst_,
 ROW_NUMBER() over (partition by nom_stsm order by nom_mar,a.napr_lin*b.nom1) as np
 from
(select marshr,st1,st2,rasst,regg,nom_sts,mid,napr_mar,nnnn,nom_mar,nom_stsm,dorlin,napr_lin,reg_mar,/*kst1,kst2,*/rast,
 case when nom1<nom2 then nom1 else nom2 end as nom1,case when nom1<nom2 then nom2 else nom1 end as nom2
 from umn_2 where reg_mar=0 and dorlin is not null)   as a join linp as b
 on a.dorlin=b.dorlin  and a.napr_lin=b.napr_lin and b.nom1 between a.nom1 and a.nom2 and b.nom2 between a.nom1 and a.nom2 
 ) as c),
	
	
	
	
umn_3 as --полная роспись всех кусков
(select marshr,st1,st2,rasst,regg,nom_sts,mid,napr_mar,nnnn,reg_mar,kst1,kst2,rast,
 --nom_stsm,dorlin,napr_lin,
 case when nom_stsm is null then 0 else nom_stsm end as nom_stsm,
 case when dorlin is null then 0 else dorlin end as dorlin,
 case when napr_lin is null then 0 else napr_lin end as napr_lin,
  ROW_NUMBER() over (partition by nom_sts order by nom_mar,np) as nom_mar
 from
(select marshr,st1,st2,rasst,regg,nom_sts,mid,napr_mar,nnnn,nom_mar,
 nom_stsm,dorlin,napr_lin,reg_mar,kst1,kst2,rast,0 as np
 from umn_2 where not (reg_mar=0 and dorlin is not null)
	union all
select marshr,st1,st2,rasst,regg,nom_sts,mid,napr_mar,nnnn,nom_mar,
 nom_stsm,dorlin,napr_lin,reg_mar,kst1,kst2,rast,np
 from stsm_rez) as a),
 

 umn_4 as
(select marshr,st1,st2,rasst,regg,nom_sts,mid,nom_mar,dorlin,reg_mar,kst1,kst2,
 round(rasst*rs1/rss) as rs1,round(rasst*rs2/rss) as rs2,round(rasst*rs2/rss)-round(rasst*rs1/rss) as rast
 from
 (select marshr,st1,st2,rasst,regg,nom_sts,mid,k as nom_mar,dorlin,rast,reg_mar,kst1,kst2,
  sum(rast) over (partition by nom_sts order by k) as rs2,(sum(rast) over (partition by nom_sts order by k))-rast as rs1,
  sum(rast) over (partition by nom_sts) as rss
 from
(select marshr,st1,st2,rasst,regg,nom_sts,mid,k,nom_mar,napr_mar,napr_lin,dorlin,srst as rast,reg_mar,nom1,
   sum(case when nom_mar=nom1 then kst1 else 0 end) over (partition by nom_sts,k) as kst1,
   sum(case when nom_mar=nom2 then kst2 else 0 end) over (partition by nom_sts,k) as kst2
  from 
 (select marshr,st1,st2,rasst,regg,nom_sts,nom_mar,mid,napr_mar,nnnn,nom_stsm,dorlin,napr_lin,reg_mar,kst1,kst2,rast,k,
  sum(rast) over (partition by nom_sts,k) as srst,
  min(nom_mar) over (partition by nom_sts,k) as nom1,max(nom_mar) over (partition by nom_sts,k) as nom2
  from
 (select marshr,st1,st2,rasst,regg,c.nom_sts,c.nom_mar,mid,napr_mar,nnnn,nom_stsm,dorlin,napr_lin,reg_mar,kst1,kst2,rast,
  sum(case when c.nom_mar=1 or k=1 then 1 else 0 end) over (partition by c.nom_sts order by c.nom_mar) as k
 from umn_3 as c left join
	(select distinct a.nom_sts,b.nom_mar,1 as k
	from umn_3 as a join umn_3 as b on a.nom_sts=b.nom_sts and a.nom_mar=b.nom_mar-1
	and (a.marshr!=b.marshr or a.napr_mar!=b.napr_mar or a.napr_lin!=b.napr_lin or a.dorlin!=b.dorlin or a.reg_mar!=b.reg_mar)
	) as d
  on c.nom_sts=d.nom_sts and c.nom_mar=d.nom_mar) as e) as f) as g where nom_mar=nom1) as h),
	
	
	
/*	
umn2 as --полная роспись всех кусков по регионам, в обоих направлениях, включая элементарные куски из 1 поездки
(select distinct marshr,st1,st2,rasst,regg,napr,nnnn,kst1,kst2,rst,reg,nnom,srst-rst as rs1,srst as rs2,
	mid,nom_sts
 from
(select marshr,st1,st2,rasst,regg,napr,nnnn,kst1,kst2,rst,reg,mid,nom_sts,
	ROW_NUMBER() over (partition by nnnn order by nom1) as nnom,
 	sum(rst) over (partition by nnnn order by nom1) as srst
 from	
(select marshr,st1,st2,rasst,regg,napr,nnnn,kst1,kst2,nom1,nom2,rast as rst,reg,mid,nom_sts from umn_1 where napr=1
 union all
select marshr,st2,st1,rasst,regg,napr,nnnn,kst2,kst1,-nom2,-nom1,rast as rst,reg,mid,nom_sts from umn_1 where napr=-1
) as a) as b
 /**/
union all
 select marshr,st1,st2,rasst,regg,0 as napr,0 as nnnn,st1 as kst1,st2 as kst2,abs(rst1-rst2) as rst,reg,1 as nnom,
 0 as rs1,abs(rst1-rst2) as rs2,0 as mid,nom_sts from sts_good
 /**/
),

umn_bad as --неправильные регионы в маршруте
(select marshr,st1,st2,rasst,regg,min(mid) as mid from umn2 where regg>0 and regg!=reg group by 1,2,3,4,5),


umn3 as --список всех найденых маршрутов с регионами, без привлечения линий по сути
(select marshr,st1,st2,rasst,regg,napr,nnnn,kst1,kst2,rst,reg,nnom,rs1,rs2,nom_sts,mid
 from umn2 where regg=0  union all
select distinct marshr,st1,st2,rasst,regg,napr,nnnn,st1 as kst1,st2 as kst2,rasst as rst,
 regg as reg,1 as nnom,0 as rs1,0 as rs2,nom_sts,mid
from umn2 where regg>0) ,
 
umn3_1 as --поиск маршрутов, где не нашли по маршруту, из за неправильного справочника
(select marshr,st1,st2,rasst,regg,mid,nom_sts  from sts where nom_sts not in(select nom_sts from umn3)),

umn3_2 as --кого смогли найти внутри 1 линии, минимальное отличие расстояний
(select marshr,st1,st2,rasst,regg,mid,nom_sts,dor,lin,r1,r2,reg1,reg2 from
(select marshr,st1,st2,rasst,regg,mid,nom_sts,dor,lin,r1,r2,reg1,reg2,dr,
 ROW_NUMBER() over (partition by nom_sts order by dr,dor,lin) as nom
 from
(select marshr,st1,st2,rasst,regg,mid,nom_sts,b.dor,b.lin,b.rst as r1,c.rst as r2,b.reg as reg1,c.reg as reg2,
 abs(rasst-abs(b.rst-c.rst)) as dr
 from umn3_1 as a join lin as b on st1=b.kst join lin as c on st2=c.kst and b.dor=c.dor and b.lin=c.lin) as d)as e where nom=1),

umn3_3 as --кого нашли в 2 соседних линиях, точное значение расстояний
(select * from 
(select nom_sts,regg,marshr,st1,st2,mid,kst,rasst,k,dor,lin,r0,reg0,rst,kst2,reg2,
 sum(abs(r0-rst)) over (partition by nom_sts,kst2) as sr,
 sum(k) over (partition by nom_sts,kst2) as sk
 from
(select nom_sts,regg,marshr,st1,st2,mid,c.kst,rasst,k,c.dor,c.lin,r0,reg0,d.rst,d.kst as kst2,d.reg as reg2 from
(select nom_sts,regg,marshr,st1,st2,mid,a.kst,rasst,k,dor,lin,rst as r0,reg as reg0 from
(select nom_sts,regg,marshr,st1,st2,mid,st1 as kst,rasst,1 as k from umn3_1
union all
select nom_sts,regg,marshr,st1,st2,mid,st2 as kst,rasst,2 as k from umn3_1) as a join lin as b on a.kst=b.kst
where nom_sts not in(select nom_sts from umn3_2) ) as c,lin as d
 where c.dor=d.dor and c.lin=d.lin) as e) as f where sk=3 and sr=rasst),

umn3_4 as --объединение найденных
(select marshr,st1,st2,rasst,regg,mid,nom_sts,dor,lin,reg1,reg2,kst1,kst2,np,
 	case when r1<r2 then r1 else r2 end as r1,case when r1>r2 then r1 else r2 end as r2,
	case when r1<r2 then 1 else -1 end as napr
 from 
(select marshr,st1,st2,rasst,regg,mid,nom_sts,dor,lin,r1,r2,reg1,reg2,st1 as kst1,st2 as kst2,1 as np from umn3_2
 union all
 select marshr,st1,st2,rasst,regg,mid,nom_sts,dor,lin,r0 as r1,rst as r2,reg0 as reg1,reg2,st1 as kst1,kst2 as kst2,1 as np 
 from umn3_3 where k=1
 union all
 select marshr,st1,st2,rasst,regg,mid,nom_sts,dor,lin,rst as r1,r0 as r2,reg2 as reg1,reg0 as reg2,kst2 as kst1,st2 as kst2,2 as np 
 from umn3_3 where k=2) as a),

*/





 
prig_cost2 as --исходник пригород по перегонам по субъектам, с добавкой числа билетов
(select  a.ID,a.DOC_NUM,nom,marshr,rasst,st1,st2,reg as regg,max_nom,kol_bil,sto,stn,srasst,sto_zone,stn_zone,sti,sti_zone,
 /*(case when kol_bil<0 then -1 else 1 end)*d_plata as d_plata,(case when kol_bil<0 then -1 else 1 end)*d_poteri as d_poteri,*/
 s_plata,s_poteri,plata,poteri,
 case when s_plata=0 and plata!=0 and nom=1 then plata
 	when s_plata=0 and plata!=0 and nom>1 then 0 
 	else (case when kol_bil<0 then -1 else 1 end)*d_plata end as d_plata,
 case when s_poteri=0 and poteri!=0 and nom=1 then poteri
 	when s_poteri=0 and poteri!=0 and nom>1 then 0 
 	else (case when kol_bil<0 then -1 else 1 end)*d_poteri end as d_poteri 
 
from prig_cost as a left join prig_main as b on a.id=b.id and a.doc_num=b.doc_num),


prig_cost3 as 
(select id,doc_num,sto,stn,srasst,kol_bil,marshr,nom,reg,st1,st2,rst,sto_zone,stn_zone,sti,sti_zone,d_plata,d_poteri,
 case when dorlin is null then 0 else dorlin end as dorlin,
 max(nom) over (partition by id,doc_num) as mnom,sum(rst) over (partition by id,doc_num order by nom) as srst
 from
(select id,doc_num,sto,stn,srasst,kol_bil,a.marshr,sto_zone,stn_zone,sti,sti_zone,dorlin,
ROW_NUMBER() over (partition by id,doc_num order by nom,nom_mar) as nom,
case /*when a.regg>0 then a.regg*/ when b.reg_mar is null then a.regg else b.reg_mar end as reg,
case when b.st1 is null then a.st1 else b.kst1 end as st1,
case when b.st1 is null then a.st2 else b.kst2 end as st2,
case when b.st1 is null then a.rasst else b.rast end as rst,

case --when a.regg>0 or b.st1 is null then d_plata 
	when d_plata=round(d_plata/kol_bil)*kol_bil then (round(d_plata*rs2/(a.rasst*kol_bil))-round(d_plata*rs1/(a.rasst*kol_bil)))*kol_bil
	else round(d_plata*rs2/a.rasst)-round(d_plata*rs1/a.rasst) end as d_plata, 
case --when a.regg>0 or b.st1 is null then d_poteri 
	when d_poteri=round(d_poteri/kol_bil)*kol_bil then (round(d_poteri*rs2/(a.rasst*kol_bil))-round(d_poteri*rs1/(a.rasst*kol_bil)))*kol_bil
	else round(d_poteri*rs2/a.rasst)-round(d_poteri*rs1/a.rasst) end as d_poteri
from prig_cost2 as a left join umn_4 as b 
on a.marshr=b.marshr and a.st1=b.st1 and a.st2=b.st2 and a.rasst=b.rasst and a.regg=b.regg) as c),

/*

 umn_4 as
 (select marshr,st1,st2,rasst,regg,nom_sts,mid,k as nom_mar,dor,lin,rast,reg_mar,kst1,kst2,
  sum(rast) over (partition by nom_sts,k) as rs2,(sum(rast) over (partition by nom_sts,k))-rast as rs1
 from
*/


hash_0 as
(select id,doc_num,mnom,srasst,hh1,sum(hh2) as hh2,
 sum(case when nom=1 then reg else 0 end) as sto_reg,sum(case when nom=mnom then reg else 0 end) as stn_reg
 from 
(select id,doc_num,nom,mnom,srasst,reg,
/*('x'||md5(hh1))::bit(64)::bigint as*/ hh1,('x'||md5(hh2))::bit(64)::bigint as hh2
from
(select id,doc_num,nom,mnom,srasst,reg,
 cast(sto as char(7))||'-'||cast(stn as char(7))||'-'||cast(srasst as char(7))||'-'||cast(sto_zone as char(7)) 
 ||'-'||cast(stn_zone as char(7)) ||'-'||cast(sti as char(7)) ||'-'||cast(sti_zone as char(7)) as hh1,
 cast(nom as char(7))||'-'||cast(st1 as char(7))||'-'||cast(st2 as char(7))||'-'||cast(rst as char(7))
 ||'-'||cast(marshr as char(7))||'-'||cast(reg as char(7))||'-'||cast(dorlin as char(7)) as hh2
from prig_cost3) as a) as b group by 1,2,3,4,5),


--old_hash as --Сделать выборку из справочника, когда будет создан
--(select mnom,hh1,hh2,1 as nom_mar from hash_0 where mnom=0),


old_hash as
(select nom_mar,srasst,hh1,sum(hh2) as hh2,max(nom) as mnom,
 sum(case when nom=1 then reg else 0 end) as sto_reg,sum(case when nom=mnom then reg else 0 end) as stn_reg from 
(select nom_mar,nom,srasst,reg,hh1,('x'||md5(hh2))::bit(64)::bigint as hh2,
 max(nom) over(partition by nom_mar) as mnom
from
(select nom_mar,nom,srasst,reg,
 cast(sto as char(7))||'-'||cast(stn as char(7))||'-'||cast(srasst as char(7))||'-'||cast(sto_zone as char(7)) 
 ||'-'||cast(stn_zone as char(7)) ||'-'||cast(sti as char(7)) ||'-'||cast(sti_zone as char(7)) as hh1,
 cast(nom as char(7))||'-'||cast(st1 as char(7))||'-'||cast(st2 as char(7))||'-'||cast(rst as char(7))
 ||'-'||cast(marshr as char(7))||'-'||cast(reg as char(7))||'-'||cast((dor*10000+lin) as char(7)) as hh2
from spb_prig.prig_mars) as a) as b group by 1,2,3),




all_hash as
(select mnom,hh1,hh2,
 case when nom_mar<0 then 1 else 0 end as new_mar,
 case when min_mar<0 then 1 else 0 end as isp_mar,
 ROW_NUMBER() over ( order by (nom_mar<0),nom_mar) as nom_mar from
(select mnom,hh1,hh2,max(nom_mar) as nom_mar,min(nom_mar) as min_mar from
(select distinct mnom,hh1,hh2,-1 as nom_mar from hash_0
union
select mnom,hh1,hh2,nom_mar from old_hash) as a group by 1,2,3) as b),


new_hash_zapis as
(select * from 
(select nom_mar,sto,stn,srasst,marshr,nom,reg,st1,st2,rst,mnom,srst,sto_zone,stn_zone,sti,sti_zone,
 case when dor is not null then dor else 0 end as dor,case when lin is not null then lin else 0 end as lin
 from
(select id,doc_num,nom_mar   from
(select id,doc_num,mnom,hh1,hh2,row_number() over (partition by mnom,hh1,hh2 order by id,doc_num) as nn
from hash_0) as a,all_hash as b where a.mnom=b.mnom and a.hh1=b.hh1 and a.hh2=b.hh2 and nn=1 and new_mar=1) as c join
 prig_cost3 as d on c.id=d.id and c.doc_num=d.doc_num 
 left join dorlin as dd on d.dorlin=dd.dorlin
) as e,date as f),
 
  
prig_cost4 as
(select c.id,c.doc_num,nom_mar,nom,mnom,srasst,reg,rst,d_plata,d_poteri,sto_reg,stn_reg
 from
(select id,doc_num,nom_mar,sto_reg,stn_reg from all_hash as a,hash_0 as b where a.mnom=b.mnom and a.hh1=b.hh1 and a.hh2=b.hh2) as c,
prig_cost3 as d 
 where c.id=d.id and d.doc_num=d.doc_num),


bil as
(select distinct flg_ruch,vid_rasch,FLG_CHILD,flg_voin,FLG_MILITARY,flg_lgt,FLG_BSP,FLG_SO,FLG_NU,FLG_TT,
klass,kod_lgt,lgt_reg,flg_bag,bag_vid,bag_ves,FLG_tuda_obr,flg_rab_day,proc_lgt,ABONEMENT_TYPE,k_pas,srok_bil,srok_mon,TRAIN_CATEGORY,TRAIN_NUM
 from prig_main),

old_bil as --Сделать выборку из справочника, когда будет создан
(select * from spb_prig.prig_bil),

all_bil as 
(select flg_ruch,vid_rasch,FLG_CHILD,flg_voin,FLG_MILITARY,flg_lgt,FLG_BSP,FLG_SO,FLG_NU,FLG_TT,
klass,kod_lgt,lgt_reg,flg_bag,bag_vid,bag_ves,FLG_tuda_obr,flg_rab_day,proc_lgt,ABONEMENT_TYPE,k_pas,srok_bil,srok_mon,TRAIN_CATEGORY,TRAIN_NUM,
 case when nom_bil<0 then 1 else 0 end as new_bil,
 case when min_bil<0 then 1 else 0 end as isp_bil,
 ROW_NUMBER() over ( order by (nom_bil<0),nom_bil) as nom_bil
 from 
(select flg_ruch,vid_rasch,FLG_CHILD,flg_voin,FLG_MILITARY,flg_lgt,FLG_BSP,FLG_SO,FLG_NU,FLG_TT,
klass,kod_lgt,lgt_reg,flg_bag,bag_vid,bag_ves,FLG_tuda_obr,flg_rab_day,proc_lgt,ABONEMENT_TYPE,k_pas,srok_bil,srok_mon,TRAIN_CATEGORY,TRAIN_NUM,
 max(nom_bil) as nom_bil,min(nom_bil) as min_bil from 
(select flg_ruch,vid_rasch,FLG_CHILD,flg_voin,FLG_MILITARY,flg_lgt,FLG_BSP,FLG_SO,FLG_NU,FLG_TT,
klass,kod_lgt,lgt_reg,flg_bag,bag_vid,bag_ves,FLG_tuda_obr,flg_rab_day,proc_lgt,ABONEMENT_TYPE,k_pas,srok_bil,srok_mon,TRAIN_CATEGORY,TRAIN_NUM,
 -1 as nom_bil from bil
union
select flg_ruch,vid_rasch,FLG_CHILD,flg_voin,FLG_MILITARY,flg_lgt,FLG_BSP,FLG_SO,FLG_NU,FLG_TT,
klass,kod_lgt,lgt_reg,flg_bag,bag_vid,bag_ves,FLG_tuda_obr,flg_rab_day,proc_lgt,ABONEMENT_TYPE,k_pas,srok_bil,srok_mon,TRAIN_CATEGORY,TRAIN_NUM,nom_bil
 from old_bil) as a
 group by flg_ruch,vid_rasch,FLG_CHILD,flg_voin,FLG_MILITARY,flg_lgt,FLG_BSP,FLG_SO,FLG_NU,FLG_TT,
klass,kod_lgt,lgt_reg,flg_bag,bag_vid,bag_ves,FLG_tuda_obr,flg_rab_day,proc_lgt,ABONEMENT_TYPE,k_pas,srok_bil,srok_mon,TRAIN_CATEGORY,TRAIN_NUM) as b),

new_bil_zapis as --билеты на запись в справочник
(select * from all_bil as a,date as b where new_bil=1),

isp_bil as
(select * from all_bil where isp_bil=1),


prig_main_bil as
(select ID,DOC_NUM,YYYYMM,date_zap,TERM_POS,TERM_DOR,date_pr,date_beg,
agent,chp,stp,stp_reg,sto,stn,sto_zone,stn_zone,sti,sti_zone,nom_bil,a.k_pas,a.srok_bil,a.srok_mon,a.flg_bag,a.FLG_tuda_obr,a.flg_rab_day,
kol_bil,plata,poteri,perebor
 from prig_main as a join isp_bil as b on
 a.flg_ruch =b.flg_ruch and a.vid_rasch =b.vid_rasch and a.FLG_CHILD =b.FLG_CHILD and
 a.flg_voin =b.flg_voin and a.FLG_MILITARY =b.FLG_MILITARY and a.flg_lgt =b.flg_lgt and
 a.FLG_BSP =b.FLG_BSP and a.FLG_SO =b.FLG_SO and a.FLG_NU =b.FLG_NU and
 a.FLG_TT =b.FLG_TT and a.klass =b.klass and a.kod_lgt =b.kod_lgt and
 a.lgt_reg =b.lgt_reg and a.flg_bag =b.flg_bag and a.bag_vid =b.bag_vid and
 a.bag_ves =b.bag_ves and a.FLG_tuda_obr =b.FLG_tuda_obr and a.proc_lgt =b.proc_lgt and
 a.ABONEMENT_TYPE =b.ABONEMENT_TYPE and a.k_pas=b.k_pas and a.srok_bil=b.srok_bil and a.srok_mon=b.srok_mon and
 a.TRAIN_CATEGORY=b.TRAIN_CATEGORY and a.TRAIN_NUM=b.TRAIN_NUM and a.flg_rab_day=b.flg_rab_day
),

prig_main_rez1 as  --билеты = в том числе и багажные билеты, по многу штук. 
(select c.ID,d.DOC_NUM,YYYYMM,date_zap,TERM_POS,TERM_DOR,date_pr,date_beg,
agent,chp,stp,stp_reg,sto,stn,srasst,nom_bil,nom_mar,k_pas,srok_bil,srok_mon,flg_bag,FLG_tuda_obr,flg_rab_day,
 kol_bil,plata,poteri,mnom,nom,reg,rst,d_plata,d_poteri,sto_reg,stn_reg,
 case when perebor>0 then perebor else 0 end as perebor,
 case when perebor<0 then perebor else 0 end as nedobor
 from prig_main_bil as c join prig_cost4 as d on c.id=d.id and c.doc_num=d.doc_num),
 

dats as --варианты сроков действия билетов
(select *, ROW_NUMBER() over (order by date_beg,k_pas,srok_bil,srok_mon,flg_rab_day) as ndt  from
(select distinct date_beg,k_pas,srok_bil,srok_mon,flg_rab_day--,flg_bag,FLG_tuda_obr
from prig_main) as a),


dats2 as --роспись вариантов по датам отправления. Не проверена только разбивка по месяцам, может врать.
(select date_beg,k_pas,srok_bil,srok_mon,flg_rab_day,ndt,dt,kk  from
(select *,round(k_pas*nday/kday)-round(k_pas*(nday-1)/kday) as kk
from
(select *,ROW_NUMBER() over (partition by ndt order by dt) as nday,cast(count(*) over (partition by ndt ) as numeric) as kday 
from
(select *,date_beg+i as dt,extract(dow from date_beg+i) as weekd from dats,rrr ) as a
where i<srok_bil
 /*((i<srok_bil and srok_mon=0)  or 
	(srok_mon>0 and (12*extract(year from dt)+extract(month from dt) <12*extract(year from date_beg)+extract(month from date_beg)+srok_mon ))
	or
	(srok_mon>0 and (12*extract(year from dt)+extract(month from dt)=12*extract(year from date_beg)+extract(month from date_beg)+srok_mon ) and 
	extract(day from dt)<extract(day from date_beg)	)  ) */ 
	   and (flg_rab_day='0' or (flg_rab_day='1' and weekd in (0,6)) or (flg_rab_day='2' and weekd not in (0,6)))
) as b) as c where kk>0),

 

prig_main_rez2 as  --разбиваю на билеты с деньгами, и пассажиров с долями денег
(--билеты и деньги
select ID,DOC_NUM,YYYYMM,date_zap,date_beg,agent,chp,TERM_POS,TERM_DOR,
stp,stp_reg,sto,stn,sto_reg,stn_reg,srasst,nom_bil,nom_mar,k_pas,srok_bil,srok_mon,flg_bag,FLG_tuda_obr,date_pr as date,
 kol_bil,plata,poteri, perebor,nedobor,
 case when nom=mnom and stp_reg=reg then nom else 0 end as nom,
 srasst as rst,stp_reg as reg,0 as d_plata,0 as d_poteri,kol_bil*k_pas as sf_pas,0 as kol_pas,1 as tp
 from prig_main_rez1 where nom=1 --билеты, деньги, сформированы пассажиры
 
	
 union all
 --разбивка денег по регионам
 select ID,DOC_NUM,YYYYMM,date_zap,date_beg,agent,chp,
	/*case when nom=mnom and stp_reg=reg then TERM_POS else NULL end as*/ TERM_POS,TERM_DOR,
	/*case when nom=mnom and stp_reg=reg then stp else NULL end as*/ stp,
	/*case when nom=mnom and stp_reg=reg then stp_reg else NULL end as*/ stp_reg,
	sto,stn,sto_reg,stn_reg,srasst,nom_bil,nom_mar,k_pas,srok_bil,srok_mon,flg_bag,FLG_tuda_obr,
	date_pr as date,
 0 as kol_bil,0 as plata,0 as poteri,0 as perebor,0 as nedobor,nom,rst,reg,d_plata,d_poteri,0 as sf_pas,0 as kol_pas,2 as tp
  from prig_main_rez1 
	
 union all
 --пассажиры
 select ID,DOC_NUM,YYYYMM,date_zap,a.date_beg,agent,chp,
	case when nom=mnom and stp_reg=reg then TERM_POS else NULL end as TERM_POS,TERM_DOR,
	case when nom=mnom and stp_reg=reg then stp else NULL end as stp,
	case when nom=mnom and stp_reg=reg then stp_reg else NULL end as stp_reg,
	sto,stn,sto_reg,stn_reg,srasst,nom_bil,nom_mar,a.k_pas,a.srok_bil,a.srok_mon,flg_bag,FLG_tuda_obr,
	--case when nom=mnom and stp_reg=reg then date_pr else NULL end as date_pr,
 dt as date,
 0 as kol_bil,0 as plata,0 as poteri,0 as perebor,0 as nedobor,
	 case when nom=mnom and stp_reg=reg then nom else 0 end as nom,srasst as rst,reg,0 as d_plata,0 as d_poteri,0 as sf_pas,kol_bil*kk as kol_pas,3 as tp
  from prig_main_rez1 as a join dats2 as b on 
 a.date_beg=b.date_beg and a.k_pas=b.k_pas and a.srok_bil=b.srok_bil and a.srok_mon=b.srok_mon and a.flg_rab_day=b.flg_rab_day  where nom=1 --,ndt,dt,kk
 ),


prig_main_rez as
(select *,row_number() over (partition by id order by nom) as doc_num from 
(select YYYYMM,date_zap,date_beg,TERM_POS,TERM_DOR,date,agent,chp,stp,stp_reg,
	sto,stn,sto_reg,stn_reg,srasst,nom_bil,nom_mar,k_pas,srok_bil,srok_mon,flg_bag,FLG_tuda_obr,nom,reg,/*rst,*/
	min(ID) as id,sum(kol_bil) as kol_bil,sum(plata) as plata,sum(poteri) as poteri,sum(perebor) as perebor,sum(nedobor) as nedobor,
 	sum(d_plata) as d_plata,sum(d_poteri) as d_poteri,sum(sf_pas) as sf_pas,sum(kol_pas) as kol_pas,min(tp) as tp,count(*) as koll
  from prig_main_rez2 
 group by YYYYMM,date_zap,date_beg,TERM_POS,TERM_DOR,date,agent,chp,stp,stp_reg,
	sto,stn,sto_reg,stn_reg,srasst,nom_bil,nom_mar,k_pas,srok_bil,srok_mon,flg_bag,FLG_tuda_obr,nom,reg/*,rst*/) as a),


bads_ as
 (select st1,st2,rasst,min(mid) as mid from umn_4 where dorlin is null or dorlin=0 group by 1,2,3),

bads as
(select distinct -1 as marshr,st1,st2,rasst,0 as reg,mid,-1 as dor,-1 as lin from bads_ --кто не обнаружился в линиях
union all	
select marshr,kst as st1,0 as st2,0 as rasst,-1 as reg,mid,0 as dor,0 as lin from stan_bad --каких станций нет в маршруте
union all	 
select distinct marshr,st1,st2,rasst,-1 as reg,mid,0 as dor,0 as lin from rast_bad --неправильные расстояния в маршруте 
 union all
select -1 as marshr,kst as st1,0 as st2,-1 as rasst,0 as reg,0 mid,-1 as dor,-1 as lin from
 (select distinct kst from 
	 (select st1 as kst from bads_ union all select st2 as kst from bads_) as a
  where kst not in(select kst from lin)) as b
),


/*
 umn_4 as
 (select marshr,st1,st2,rasst,regg,nom_sts,mid,k as nom_mar,dor,lin,rast,reg_mar,kst1,kst2,
  sum(rast) over (partition by nom_sts,k) as rs2,(sum(rast) over (partition by nom_sts,k))-rast as rs1
 */ 

itog as
(select 1 as rez,nom_bil,nom_mar,YYYYMM,date_zap,date_beg,id,doc_num,TERM_POS,TERM_DOR,date,agent,chp,stp,stp_reg,
sto,stn,sto_reg,stn_reg,srasst,k_pas,srok_bil,srok_mon,flg_bag,FLG_tuda_obr,NULL as flg_rab_day,kol_bil,plata,poteri,perebor,
 nedobor,nom,reg,d_plata,d_poteri,sf_pas,kol_pas,
NULL as flg_ruch,NULL as vid_rasch,NULL as FLG_CHILD,NULL as flg_voin,NULL as FLG_MILITARY,NULL as flg_lgt,
 NULL as FLG_BSP,NULL as FLG_SO,NULL as FLG_NU,NULL as FLG_TT,NULL as klass,NULL as kod_lgt,NULL as lgt_reg,
 NULL as bag_vid,NULL as bag_ves,NULL as proc_lgt,NULL as ABONEMENT_TYPE,NULL as TRAIN_CATEGORY,NULL as TRAIN_NUM,
 0 as marshr,0 as st1,0 as st2,0 as rst,0 as sto_zone,0 as stn_zone,0 as sti,0 as sti_zone,
 0 as dor,0 as lin
from prig_main_rez 
 
 
union all
select 2 as rez,nom_bil,NULL as nom_mar,NULL as YYYYMM,date_zap,NULL as date_beg,NULL as id,NULL as doc_num,NULL as TERM_POS,NULL as TERM_DOR,
 NULL as date,NULL as agent,NULL as chp,NULL as stp,NULL as stp_reg,NULL as sto,NULL as stn,NULL as sto_reg,NULL as stn_reg,NULL as srasst,
 k_pas,srok_bil,srok_mon,flg_bag,FLG_tuda_obr,flg_rab_day,NULL as kol_bil,NULL as plata,NULL as poteri,NULL as perebor, 
 NULL as nedobor,NULL as nom,NULL as reg,NULL as d_plata,NULL as d_poteri,NULL as sf_pas,NULL as kol_pas,
 flg_ruch,vid_rasch,FLG_CHILD,flg_voin,FLG_MILITARY,flg_lgt,FLG_BSP,FLG_SO,FLG_NU,FLG_TT,
klass,kod_lgt,lgt_reg,bag_vid,bag_ves,proc_lgt,ABONEMENT_TYPE,TRAIN_CATEGORY,TRAIN_NUM,
 0 as marshr,NULL as st1,NULL as st2,NULL as rst,NULL as sto_zone,NULL as stn_zone,NULL as sti,NULL as sti_zone,
 NULL as dor,NULL as lin
 from new_bil_zapis
  
 
 union all
select 3 as rez,NULL as nom_bil,nom_mar,NULL as YYYYMM,date_zap,NULL as date_beg,NULL as id,NULL as doc_num,NULL as TERM_POS,NULL as TERM_DOR,
 NULL as date,NULL as agent,NULL as chp,NULL as stp,NULL as stp_reg,sto,stn,NULL as sto_reg,NULL as stn_reg,srasst,
 NULL as k_pas,NULL as srok_bil,NULL as srok_mon,NULL as flg_bag,NULL as FLG_tuda_obr,NULL as flg_rab_day,
 NULL as kol_bil,NULL as plata,NULL as poteri,NULL as perebor,
 NULL as nedobor,nom,reg,NULL as d_plata,NULL as d_poteri,NULL as sf_pas,NULL as kol_pas, 
 NULL as flg_ruch,NULL as vid_rasch,NULL as FLG_CHILD,NULL as flg_voin,NULL as FLG_MILITARY,
 NULL as flg_lgt,NULL as FLG_BSP,NULL as FLG_SO,NULL as FLG_NU,NULL as FLG_TT,
 NULL as klass,NULL as kod_lgt,NULL as lgt_reg,NULL as bag_vid,NULL as bag_ves,NULL as proc_lgt,NULL as ABONEMENT_TYPE,
 NULL as TRAIN_CATEGORY,NULL as TRAIN_NUM,
  marshr, st1,st2,rst,sto_zone,stn_zone,sti,sti_zone,dor,lin
 from new_hash_zapis  
 
 
 union all
select 9 as rez,NULL as nom_bil,NULL as nom_mar,NULL as YYYYMM,date_zap,NULL as date_beg,mid as id,NULL as doc_num,NULL as TERM_POS,NULL as TERM_DOR,
 NULL as date,NULL as agent,NULL as chp,NULL as stp,NULL as stp_reg,NULL as sto,NULL as stn,NULL as sto_reg,NULL as stn_reg,NULL as srasst,
 NULL as k_pas,NULL as srok_bil,NULL as srok_mon,NULL as flg_bag,NULL as FLG_tuda_obr,NULL as flg_rab_day,
 NULL as kol_bil,NULL as plata,NULL as poteri,NULL as perebor,
 NULL as nedobor,NULL as nom,reg,NULL as d_plata,NULL as d_poteri,NULL as sf_pas,NULL as kol_pas, 
 NULL as flg_ruch,NULL as vid_rasch,NULL as FLG_CHILD,NULL as flg_voin,NULL as FLG_MILITARY,
 NULL as flg_lgt,NULL as FLG_BSP,NULL as FLG_SO,NULL as FLG_NU,NULL as FLG_TT,
 NULL as klass,NULL as kod_lgt,NULL as lgt_reg,NULL as bag_vid,NULL as bag_ves,NULL as proc_lgt,NULL as ABONEMENT_TYPE,
 NULL as TRAIN_CATEGORY,NULL as TRAIN_NUM,
 marshr, st1,st2,rasst as rst,NULL as sto_zone,NULL as stn_zone,NULL as sti,NULL as sti_zone,dor,lin 
from bads as a,date as b 
 
)



select rez,nom_bil,nom_mar,YYYYMM,date_zap,date_beg,id,doc_num,TERM_POS,TERM_DOR,date,agent,chp,stp,stp_reg,
	sto,stn,sto_reg,stn_reg,srasst,k_pas,srok_bil,srok_mon,flg_bag,FLG_tuda_obr,flg_rab_day,kol_bil,plata,poteri,perebor,
	nedobor,nom,reg,d_plata,d_poteri,sf_pas,kol_pas,
	flg_ruch,vid_rasch,FLG_CHILD,flg_voin,FLG_MILITARY,flg_lgt,
	FLG_BSP,FLG_SO,FLG_NU,FLG_TT,klass,kod_lgt,lgt_reg,
	bag_vid,bag_ves,proc_lgt,ABONEMENT_TYPE,TRAIN_CATEGORY,TRAIN_NUM,
	marshr,st1,st2,rst,sto_zone,stn_zone,sti,sti_zone,dor,lin from itog;
	
	
	

--- ввод времени окончания операции
insert into  spb_prig.prig_times(time,date,oper,time2,date_zap)
with a as
(select current_date as date,substr(cast(clock_timestamp()::time as char(50)),1,12) as time),
b as
(select date_zap from  spb_prig.prig_times where oper='dannie')
select time,date,'prig_work 2_end' as oper,
(cast(substr(time,1,2) as dec(3))*60+cast(substr(time,4,2) as dec(3)))*60+cast(substr(time,7,6) as dec(7,3)) as time2,date_zap
from a left join b on 1=1;


--- ввод времени окончания операции ситоговым числом записей
insert into  spb_prig.prig_times(time,date,oper,time2,date_zap,rezult)
with a as
(select current_date as date,substr(cast(clock_timestamp()::time as char(50)),1,12) as time),
b as
(select date_zap from  spb_prig.prig_times where oper='dannie'),
c as (select count(*) as rezult from spb_prig.prig_work)
select time,date,'prig_work 3_rez' as oper,
(cast(substr(time,1,2) as dec(3))*60+cast(substr(time,4,2) as dec(3)))*60+cast(substr(time,7,6) as dec(7,3)) as time2,date_zap,rezult
from a left join b on 1=1 left join c on 1=1;


--------------------

--select date_zap,count(*) as rezult from spb_prig.prig_work group by 1
