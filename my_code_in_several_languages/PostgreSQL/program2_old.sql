
delete from spb_prig.prig_work;

insert into spb_prig.prig_work(
	rez,nom_bil,nom_mar,YYYYMM,date_zap,id,doc_num,TERM_POS,TERM_DOR,date,agent,chp,stp,stp_reg,
	sto,stn,sto_reg,stn_reg,srasst,k_pas,srok_bil,srok_mon,flg_bag,FLG_tuda_obr,flg_rab_day,kol_bil,plata,poteri,perebor,
	nedobor,nom,reg,d_plata,d_poteri,sf_pas,kol_pas,
	flg_ruch,vid_rasch,FLG_CHILD,flg_voin,FLG_MILITARY,flg_lgt,
	FLG_BSP,FLG_SO,FLG_NU,FLG_TT,klass,kod_lgt,lgt_reg,
	bag_vid,bag_ves,proc_lgt,ABONEMENT_TYPE,TRAIN_CATEGORY,TRAIN_NUM,
	marshr,st1,st2,rst,sto_zone,stn_zone,sti,sti_zone )
 

with

RECURSIVE r AS (SELECT 0 AS i
    UNION SELECT i+1 AS i FROM r WHERE i < 1000),

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

from rawdl2.l2_prig_main   where REQUEST_DATE='2021-07-04'	),


date as
(select distinct date_zap from prig_main),


lin as --структура всех линий
(select cast(nom3d as dec(3)) as dor,cast(noml as dec(3)) as lin,cast(stan as dec(7)) as kst,rstk as rst,cast(sf as dec(3)) as reg
from  nsi.lines as a,date as b where date_zap between datand and datakd and date_zap between datani and dataki),


prig_cost as --исходник пригород по перегонам по субъектам
(select  ID,DOC_NUM,doc_reg as nom,
--YYYYMM,REQUEST_DATE,REQUEST_NUM,TERM_POS,TERM_DOR,TERM_TRM,ARXIV_CODE,REPLY_CODE, --не нужны
ROUTE_NUM as marshr,cast(ROUTE_DISTANCE as dec(7)) as rasst,
sum(cast(ROUTE_DISTANCE as dec(7))) over(partition by ID,DOC_NUM) as srasst,
TARIFF_SUM as d_plata,DEPARTMENT_SUM as d_poteri,
DEPARTURE_STATION as st1,ARRIVAL_STATION as st2,REGION_CODE as reg,
max(doc_reg) over (partition by ID,DOC_NUM) as max_nom,
sum(TARIFF_SUM) over (partition by ID,DOC_NUM) as s_plata,
sum(DEPARTMENT_SUM) over (partition by ID,DOC_NUM) as s_poteri
 
 
from rawdl2.l2_prig_cost where REQUEST_DATE in(select date_zap from date)),


marshr_ish as --список всех маршрутов
(select ssm_nmar as marshr,round(ssm_rst) as rst,cast(ssm_stan as decimal(7)) as kst,
 case when ssm_ksf=' ' then 0 else cast(ssm_ksf as decimal(3)) end as reg,
	case when ssm_prgr='1' or ssm_prgs='1' then '1' else '0' end as perelom,
	ROW_NUMBER() over (partition by ssm_nmar order by ssm_rst) nom
	from prig.submars ),

marshr as ----список всех маршрутов, имеющихся в приг выборке
(select marshr,rst,kst,reg,perelom,nom
	from marshr_ish where marshr in (select distinct marshr from prig_cost )),

sts as --список всех ВАРИАНТОВ  по перегонам-регионам маршрутов
(select a.marshr,st1,st2,rasst,b.rst as rst1,c.rst as rst2,regg,1 as edin,mid from
(select marshr,st1,st2,rasst,reg as regg,min(id) as mid
 from prig_cost group by 1,2,3,4,5) as a
 	left join marshr as b on a.marshr=b.marshr and st1=b.kst
	left join marshr as c on a.marshr=c.marshr and st2=c.kst),

sts2 as --список каких станций не хватает в маршрутах  --29 штук
(select distinct marshr,kst from 
(select  marshr,st1 as kst,rst1 as rst from sts union all select  marshr,st2,rst2  from sts)  as a
		where rst is null),
		

mar_b as --список плохих маршрутов на починку   --18 записей
(select * from marshr where marshr in(select  marshr from sts2)),

lin2 as --структура линий, в которых есть нехватающие станции --46 записей
(select * from lin where (dor,lin) in
	   (select distinct dor,lin from lin where kst in(select distinct kst from sts2))
	and (kst in(select distinct kst from mar_b) or kst in(select distinct kst from sts2))  ),
	
lin3 as  --линии перенумерованы, поле dorl- заменяет дорогу и линию одновременно
(select dorl,rst as rs,kst,reg  from
(select  dor,lin,ROW_NUMBER() over (order by dor,lin) as dorl   from
(select distinct dor,lin from lin2) as a) as b,lin2 as c where b.dor=c.dor and b.lin=c.lin),

mar_b2 as --к маршрута приписали все возм линии  --21 zap
(select marshr,rst,a.kst,a.reg,perelom,nom,dorl,rs
from mar_b as a,lin3 as b where a.kst=b.kst),

mar_b3 as --привести маршруты в пары станций --16 записей
(select a.marshr,a.nom,a.rst as rst1,b.rst as rst2,a.kst as kst1,b.kst as kst2,a.dorl,a.rs as rs1,b.rs as rs2
  --,abs(a.rst-b.rst)-abs(a.rs-b.rs) as dd
from mar_b2 as a,mar_b2 as b where a.marshr=b.marshr and a.dorl=b.dorl and a.nom+1=b.nom
and abs(a.rst-b.rst)=abs(a.rs-b.rs)
),

mar_b4 as --найти все возможные промежуточные станции, для добавки в маршруты
(select marshr,--nom,rst1,rst2,kst1,kst2,a.dorl,rs1,rs2,rs,
 kst,reg, rst1+abs(rs-rs1) as rst
from mar_b3 as a,lin3 as b
where a.dorl=b.dorl and (rs between rs1 and rs2 or rs between rs2 and rs1)
and rs!=rs1 and rs!=rs2),

marshr_new as --список всех маршрутов, имеющихся в приг выборке
(select marshr,rst,kst,reg,perelom,
ROW_NUMBER() over (partition by marshr order by rst) nom
from
(select marshr,rst,kst,reg,perelom,nom from marshr
 union all
 select marshr,rst,kst,reg,'0' as perelom,0 as nom from mar_b4) as a),
  
mar_n as
(select a.marshr,b.nom,1 as k
	from marshr_new as a,marshr_new as b where a.marshr=b.marshr and a.nom=b.nom-1 and a.reg!=b.reg),

mars as --маршрут расписанный с метками начала действия нового региона
(select marshr,rst,kst,reg,perelom,nom,k,
 SUM(k) OVER (partition by marshr order by rst) as nomk
 from
(select a.marshr,rst,kst,reg,perelom,a.nom,case when k=1 or a.nom=1 or perelom='1' then 1 else 0 end as k
from marshr_new as a left join mar_n as b on a.marshr=b.marshr and a.nom=b.nom
) as c),
 

 sts_new as --список всех ВАРИАНТОВ  по перегонам-регионам НОВЫХ маршрутов
(select a.marshr,st1,st2,rasst,regg,edin,b.rst as rst1,c.rst as rst2,rasst-abs(b.rst-c.rst) as dd,
 b.nom as nom1,c.nom as nom2,b.nomk as nomk1,c.nomk as nomk2,b.reg,mid
 from sts as a
 	left join mars as b on a.marshr=b.marshr and st1=b.kst
	left join mars as c on a.marshr=c.marshr and st2=c.kst),
	

stan_bad as --список каких станций не хватает в маршрутах  --29 штук
(select marshr,kst,min(mid) as mid from 
(select  marshr,st1 as kst,rst1 as rst,mid from sts_new union all select  marshr,st2,rst2,mid  from sts_new)  as a
		where rst is null group by 1,2),	
		
rast_bad as --список пар станций с неправильно установленными расстояниями
(select marshr,st1,st2,rasst,min(mid) as mid from sts_new where dd>0 and dd is not null group by 1,2,3,4),
		
sts_good as --список вариантов, укладывающихся строго в 1 регион
(select marshr,st1,st2,rasst,regg,edin,rst1,rst2,reg from sts_new where nomk1=nomk2 and nomk1 is not null and dd=0),

sts_2 as -- нужные к поиску пары станций, в обоих направлениях
(select marshr,st1,st2,rasst,regg,edin,rst1,rst2,nom1,nom2,nomk1,nomk2,mid,
 case when rst1<rst2 then 1 else -1 end as napr,
 ROW_NUMBER() over (order by marshr,st1,st2,rasst,regg,edin,rst1,rst2,nom1,nom2,nomk1,nomk2,reg) as nnnn
 from sts_new where nomk1!=nomk2 ),

mars_p as --пары станций маршрута внутри 1 региона, туда
(select a.marshr,a.kst as kst1,b.kst as kst2,a.nom as nom1,b.nom as nom2,a.nomk,a.k as beg_,b.k as end_,b.rst-a.rst as rst,
 case when a.reg=0 then b.reg when b.reg=0 then a.reg
 	when a.perelom='1' then b.reg when b.perelom='1' then a.reg 
 	when a.reg!=b.reg then -1 else a.reg end as reg
from mars as a,mars as b where a.marshr=b.marshr and 
 a.nom<b.nom and ((a.nomk=b.nomk-1 and  b.k=1) or (a.nomk=b.nomk and a.k=1 and a.nom>1))	
),

sts_3 as -- нужные к поиску пары станций, в направлении маршрута
(select marshr,st1,st2,rasst,regg,edin,rst1,rst2,nom1,nom2,nomk1,nomk2,napr,nnnn,mid
  from sts_2 where napr=1
union all
 select marshr,st2,st1,rasst,regg,edin,rst2,rst1,nom2,nom1,nomk2,nomk1,napr,nnnn,mid
  from sts_2 where napr=-1),

umn as --роспись всех кусков, только в направлении маршрута
(select a.marshr,st1,st2,rasst,regg,edin,napr,nnnn,kst1,kst2,b.nom1,b.nom2,rst,b.reg,mid
		from sts_3 as a,mars_p as b
where a.marshr=b.marshr and a.nom1<=b.nom1 and a.nom2>=b.nom2 
	and ((a.nomk1<nomk and beg_=1) or a.nom1=b.nom1) and ((a.nomk2>nomk and end_=1) or a.nom2=b.nom2)),
	
umn2 as --полная роспись всех кусков по регионам, в обоих направлениях, включая элементарные куски из 1 поездки
(select distinct marshr,st1,st2,rasst,regg,edin,napr,nnnn,kst1,kst2,rst,reg,nnom,srst-rst as rs1,srst as rs2,
	case when rasst=rst then 1 else 0 end as odin,mid
 from
(select marshr,st1,st2,rasst,regg,edin,napr,nnnn,kst1,kst2,rst,reg,mid,
	ROW_NUMBER() over (partition by nnnn order by nom1) as nnom,
 	sum(rst) over (partition by nnnn order by nom1) as srst
 from	
(select marshr,st1,st2,rasst,regg,edin,napr,nnnn,kst1,kst2,nom1,nom2,rst,reg,mid from umn where napr=1
 union all
select marshr,st2,st1,rasst,regg,edin,napr,nnnn,kst2,kst1,-nom2,-nom1,rst,reg,mid from umn where napr=-1
) as a) as b
 /**/
union all
 select marshr,st1,st2,rasst,regg,edin,0 as napr,0 as nnnn,st1 as kst1,st2 as kst2,abs(rst1-rst2) as rst,reg,1 as nnom,
 0 as rs1,abs(rst1-rst2) as rs2,1 as odin,0 as mid from sts_good
 /**/
),

umn_bad as
(select marshr,st1,st2,rasst,regg,min(mid) as mid from umn2 where regg>0 and regg!=reg group by 1,2,3,4,5),


umn3 as
(select marshr,st1,st2,rasst,regg,edin,napr,nnnn,kst1,kst2,rst,reg,nnom,rs1,rs2,odin
 from umn2 where regg=0  union all
select distinct marshr,st1,st2,rasst,regg,edin,napr,nnnn,st1 as kst1,st2 as kst2,rasst as rst,regg as reg,1 as nnom,0 as rs1,0 as rs2,1 as odin
from umn2 where regg>0) ,
 
 
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
 --TRAIN_CATEGORY,TRAIN_NUM,
 max(nom) over (partition by id,doc_num) as mnom,sum(rst) over (partition by id,doc_num order by nom) as srst
 from
(select id,doc_num,sto,stn,srasst,kol_bil,a.marshr,sto_zone,stn_zone,sti,sti_zone,
ROW_NUMBER() over (partition by id,doc_num order by nom,nnom) as nom,
case when a.regg>0 then a.regg when b.reg is null then 0 else b.reg end as reg,
case when a.regg>0 or b.st1 is null then a.st1 else b.kst1 end as st1,
case when a.regg>0 or b.st1 is null then a.st2 else b.kst2 end as st2,
case when a.regg>0 or b.st1 is null then a.rasst else b.rst end as rst,
/*case when a.regg>0 or b.st1 is null then c_plat else round(c_plat*rs2/a.rasst)-round(c_plat*rs1/a.rasst) end as c_plat,
case when a.regg>0 or b.st1 is null then c_spot else round(c_spot*rs2/a.rasst)-round(c_spot*rs1/a.rasst) end as c_spot,* /
0 as c_plat,0 as c_spot,*/
case when a.regg>0 or b.st1 is null then d_plata 
	when d_plata=round(d_plata/kol_bil)*kol_bil then (round(d_plata*rs2/(a.rasst*kol_bil))-round(d_plata*rs1/(a.rasst*kol_bil)))*kol_bil
	else round(d_plata*rs2/a.rasst)-round(d_plata*rs1/a.rasst) end as d_plata, 
case when a.regg>0 or b.st1 is null then d_poteri 
	when d_poteri=round(d_poteri/kol_bil)*kol_bil then (round(d_poteri*rs2/(a.rasst*kol_bil))-round(d_poteri*rs1/(a.rasst*kol_bil)))*kol_bil
	else round(d_poteri*rs2/a.rasst)-round(d_poteri*rs1/a.rasst) end as d_poteri
from prig_cost2 as a left join umn3 as b 
on a.marshr=b.marshr and a.st1=b.st1 and a.st2=b.st2 and a.rasst=b.rasst and a.regg=b.regg) as c),




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
 ||'-'||cast(marshr as char(7))||'-'||cast(reg as char(7)) as hh2
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
 ||'-'||cast(marshr as char(7))||'-'||cast(reg as char(7)) as hh2
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
(select nom_mar,sto,stn,srasst,marshr,nom,reg,st1,st2,rst,mnom,srst,sto_zone,stn_zone,sti,sti_zone
 from
(select id,doc_num,nom_mar   from
(select id,doc_num,mnom,hh1,hh2,row_number() over (partition by mnom,hh1,hh2 order by id,doc_num) as nn
from hash_0) as a,all_hash as b where a.mnom=b.mnom and a.hh1=b.hh1 and a.hh2=b.hh2 and nn=1 and new_mar=1) as c,
 prig_cost3 as d where c.id=d.id and c.doc_num=d.doc_num) as e,date as f),
 
 
 
 
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
(select *,ROW_NUMBER() over (partition by ndt order by dt) as nday,count(*) over (partition by ndt ) as kday 
from
(select *,date_beg+i as dt,extract(dow from date_beg+i) as weekd from dats,r ) as a
where ((i<srok_bil and srok_mon=0)  or 
	(srok_mon>0 and (12*extract(year from dt)+extract(month from dt) <12*extract(year from date_beg)+extract(month from date_beg)+srok_mon ))
	or
	(srok_mon>0 and (12*extract(year from dt)+extract(month from dt)=12*extract(year from date_beg)+extract(month from date_beg)+srok_mon ) and 
	extract(day from dt)<extract(day from date_beg)	)
	   ) 
	   and (flg_rab_day='0' or (flg_rab_day='1' and weekd in (0,6)) or (flg_rab_day='2' and weekd not in (0,6)))
) as b) as c where kk>0),

 

prig_main_rez2 as  --разбиваю на билеты с деньгами, и пассажиров с долями денег
(--билеты и деньги
select ID,DOC_NUM,YYYYMM,date_zap,agent,chp,TERM_POS,TERM_DOR,
stp,stp_reg,sto,stn,sto_reg,stn_reg,srasst,nom_bil,nom_mar,k_pas,srok_bil,srok_mon,flg_bag,FLG_tuda_obr,date_pr as date,
 kol_bil,plata,poteri, perebor,nedobor,
 case when nom=mnom and stp_reg=reg then nom else 0 end as nom,
 srasst as rst,stp_reg as reg,0 as d_plata,0 as d_poteri,kol_bil*k_pas as sf_pas,0 as kol_pas,1 as tp
 from prig_main_rez1 where nom=1 --билеты, деньги, сформированы пассажиры
 
	
 union all
 --разбивка денег по регионам
 select ID,DOC_NUM,YYYYMM,date_zap,agent,chp,
	/*case when nom=mnom and stp_reg=reg then TERM_POS else NULL end as*/ TERM_POS,TERM_DOR,
	/*case when nom=mnom and stp_reg=reg then stp else NULL end as*/ stp,
	/*case when nom=mnom and stp_reg=reg then stp_reg else NULL end as*/ stp_reg,
	sto,stn,sto_reg,stn_reg,srasst,nom_bil,nom_mar,k_pas,srok_bil,srok_mon,flg_bag,FLG_tuda_obr,
	date_pr as date,
 0 as kol_bil,0 as plata,0 as poteri,0 as perebor,0 as nedobor,nom,rst,reg,d_plata,d_poteri,0 as sf_pas,0 as kol_pas,2 as tp
  from prig_main_rez1 
	
 union all
 --пассажиры
 select ID,DOC_NUM,YYYYMM,date_zap,agent,chp,
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
(select YYYYMM,date_zap,TERM_POS,TERM_DOR,date,agent,chp,stp,stp_reg,
	sto,stn,sto_reg,stn_reg,srasst,nom_bil,nom_mar,k_pas,srok_bil,srok_mon,flg_bag,FLG_tuda_obr,nom,reg,/*rst,*/
	min(ID) as id,sum(kol_bil) as kol_bil,sum(plata) as plata,sum(poteri) as poteri,sum(perebor) as perebor,sum(nedobor) as nedobor,
 	sum(d_plata) as d_plata,sum(d_poteri) as d_poteri,sum(sf_pas) as sf_pas,sum(kol_pas) as kol_pas,min(tp) as tp,count(*) as koll
  from prig_main_rez2 
 group by YYYYMM,date_zap,TERM_POS,TERM_DOR,date,agent,chp,stp,stp_reg,
	sto,stn,sto_reg,stn_reg,srasst,nom_bil,nom_mar,k_pas,srok_bil,srok_mon,flg_bag,FLG_tuda_obr,nom,reg/*,rst*/) as a),


bads as
(select marshr,st1,st2,rasst,regg as reg,mid from umn_bad
union all	
select marshr,kst as st1,kst as st2,0 as rasst,-1 as reg,mid from stan_bad
union all	 
select distinct marshr,st1,st2,rasst,-1 as reg,mid from rast_bad 
),


itog as
(select 1 as rez,nom_bil,nom_mar,YYYYMM,date_zap,id,doc_num,TERM_POS,TERM_DOR,date,agent,chp,stp,stp_reg,
sto,stn,sto_reg,stn_reg,srasst,k_pas,srok_bil,srok_mon,flg_bag,FLG_tuda_obr,NULL as flg_rab_day,kol_bil,plata,poteri,perebor,
 nedobor,nom,reg,d_plata,d_poteri,sf_pas,kol_pas,
NULL as flg_ruch,NULL as vid_rasch,NULL as FLG_CHILD,NULL as flg_voin,NULL as FLG_MILITARY,NULL as flg_lgt,
 NULL as FLG_BSP,NULL as FLG_SO,NULL as FLG_NU,NULL as FLG_TT,NULL as klass,NULL as kod_lgt,NULL as lgt_reg,
 NULL as bag_vid,NULL as bag_ves,NULL as proc_lgt,NULL as ABONEMENT_TYPE,NULL as TRAIN_CATEGORY,NULL as TRAIN_NUM,
 0 as marshr,0 as st1,0 as st2,0 as rst,0 as sto_zone,0 as stn_zone,0 as sti,0 as sti_zone
from prig_main_rez
 
 
 
union all
select 2 as rez,nom_bil,NULL as nom_mar,NULL as YYYYMM,date_zap,NULL as id,NULL as doc_num,NULL as TERM_POS,NULL as TERM_DOR,
 NULL as date,NULL as agent,NULL as chp,NULL as stp,NULL as stp_reg,NULL as sto,NULL as stn,NULL as sto_reg,NULL as stn_reg,NULL as srasst,
 k_pas,srok_bil,srok_mon,flg_bag,FLG_tuda_obr,flg_rab_day,NULL as kol_bil,NULL as plata,NULL as poteri,NULL as perebor, 
 NULL as nedobor,NULL as nom,NULL as reg,NULL as d_plata,NULL as d_poteri,NULL as sf_pas,NULL as kol_pas,
 flg_ruch,vid_rasch,FLG_CHILD,flg_voin,FLG_MILITARY,flg_lgt,FLG_BSP,FLG_SO,FLG_NU,FLG_TT,
klass,kod_lgt,lgt_reg,bag_vid,bag_ves,proc_lgt,ABONEMENT_TYPE,TRAIN_CATEGORY,TRAIN_NUM,
 0 as marshr,NULL as st1,NULL as st2,NULL as rst,NULL as sto_zone,NULL as stn_zone,NULL as sti,NULL as sti_zone
 from new_bil_zapis
 
 
 
 
 union all
select 3 as rez,NULL as nom_bil,nom_mar,NULL as YYYYMM,date_zap,NULL as id,NULL as doc_num,NULL as TERM_POS,NULL as TERM_DOR,
 NULL as date,NULL as agent,NULL as chp,NULL as stp,NULL as stp_reg,sto,stn,NULL as sto_reg,NULL as stn_reg,srasst,
 NULL as k_pas,NULL as srok_bil,NULL as srok_mon,NULL as flg_bag,NULL as FLG_tuda_obr,NULL as flg_rab_day,
 NULL as kol_bil,NULL as plata,NULL as poteri,NULL as perebor,
 NULL as nedobor,nom,reg,NULL as d_plata,NULL as d_poteri,NULL as sf_pas,NULL as kol_pas, 
 NULL as flg_ruch,NULL as vid_rasch,NULL as FLG_CHILD,NULL as flg_voin,NULL as FLG_MILITARY,
 NULL as flg_lgt,NULL as FLG_BSP,NULL as FLG_SO,NULL as FLG_NU,NULL as FLG_TT,
 NULL as klass,NULL as kod_lgt,NULL as lgt_reg,NULL as bag_vid,NULL as bag_ves,NULL as proc_lgt,NULL as ABONEMENT_TYPE,
 NULL as TRAIN_CATEGORY,NULL as TRAIN_NUM,
  marshr, st1,st2,rst,sto_zone,stn_zone,sti,sti_zone 
 from new_hash_zapis 
 
 
 union all
select 9 as rez,NULL as nom_bil,NULL as nom_mar,NULL as YYYYMM,date_zap,mid as id,NULL as doc_num,NULL as TERM_POS,NULL as TERM_DOR,
 NULL as date,NULL as agent,NULL as chp,NULL as stp,NULL as stp_reg,NULL as sto,NULL as stn,NULL as sto_reg,NULL as stn_reg,NULL as srasst,
 NULL as k_pas,NULL as srok_bil,NULL as srok_mon,NULL as flg_bag,NULL as FLG_tuda_obr,NULL as flg_rab_day,
 NULL as kol_bil,NULL as plata,NULL as poteri,NULL as perebor,
 NULL as nedobor,NULL as nom,reg,NULL as d_plata,NULL as d_poteri,NULL as sf_pas,NULL as kol_pas, 
 NULL as flg_ruch,NULL as vid_rasch,NULL as FLG_CHILD,NULL as flg_voin,NULL as FLG_MILITARY,
 NULL as flg_lgt,NULL as FLG_BSP,NULL as FLG_SO,NULL as FLG_NU,NULL as FLG_TT,
 NULL as klass,NULL as kod_lgt,NULL as lgt_reg,NULL as bag_vid,NULL as bag_ves,NULL as proc_lgt,NULL as ABONEMENT_TYPE,
 NULL as TRAIN_CATEGORY,NULL as TRAIN_NUM,
 marshr, st1,st2,rasst as rst,NULL as sto_zone,NULL as stn_zone,NULL as sti,NULL as sti_zone 
from bads as a,date as b
 
 
 
)

--select * from prig_main
--where date_beg='2021-03-26' and srok_bil=10 and k_pas=7 and flg_rab_day='2'

--select tp,count(*) from prig_main_rez group by 1
--union all select 0 as tp,count(*) from prig_main_rez

select 
rez,nom_bil,nom_mar,YYYYMM,date_zap,id,doc_num,TERM_POS,TERM_DOR,date,agent,chp,stp,stp_reg,
sto,stn,sto_reg,stn_reg,srasst,k_pas,srok_bil,srok_mon,flg_bag,FLG_tuda_obr,flg_rab_day,kol_bil,plata,poteri,perebor,
 nedobor,nom,reg,d_plata,d_poteri,sf_pas,kol_pas,
flg_ruch,vid_rasch,FLG_CHILD,flg_voin,FLG_MILITARY,flg_lgt,
FLG_BSP,FLG_SO,FLG_NU,FLG_TT,klass,kod_lgt,lgt_reg,
 bag_vid,bag_ves,proc_lgt,ABONEMENT_TYPE,TRAIN_CATEGORY,TRAIN_NUM,
 marshr,st1,st2,rst,sto_zone,stn_zone,sti,sti_zone 
 
from itog   -- where nom_bil=1
--select * from new_bil_zapis where nom_bil<3
--select * from all_bil where nom_bil<3

--where nom=5 fetch first 5 rows only
--where id=275332609







