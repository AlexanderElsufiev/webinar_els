

НАДО
1.ЛОГИ
2.ОПИСАНИЕ 2 И 3 УРОВНЯ, АЛГОРИТМ ЗАПОЛНЕНИЯ
3.ПЕРЕДАЧА В ГВЦ ДАННЫХ СОГЛАСНО МАКЕТА. в минимально необходимых объёмах
4.НЕДОСТАЮЩИЕДАННЫЕ ПО КЛАССУ 4 ИЗ НЕКОЕЙ ИНОЙ ТАБЛИЦЫ
5.ОРГАНИЗОВАТЬ ЧТЕНИЕ ИЗ ПАССАЖИРСКОЙ БАЗЫ 800-Е ПОЕЗДА

льгота по пригороду интернету бывает только "дети в ласточке 9013" - из старого пригорода.






select cast(stan as dec(7)) as kst,gos,koddcs as dcs,cast(otd as dec(3)) as otd,cast(sf as dec(3)) as sf,prgrotd as gr_otd,prgrsf as gr_sf
 from nsi.stanv where '2022-01-01' between datand and datakd and '2022-01-01' between datani and dataki  and
 stan in ('2000001','2000105','2001210','2000605','2000235','2001250','2001410')



select * from nsi.stanv where '2022-01-01' between datand and datakd and '2022-01-01' between datani and dataki  and otd='0'

select distinct otd
 from nsi.stanv order by 1
 where '2022-01-01' between datand and datakd and '2022-01-01' between datani and dataki  and



select  ID,DOC_NUM,doc_reg as nom,
--YYYYMM,REQUEST_DATE,REQUEST_NUM,TERM_POS,TERM_DOR,TERM_TRM,ARXIV_CODE,REPLY_CODE, --не нужны
	ROUTE_NUM as marshr,cast(ROUTE_DISTANCE as dec(7)) as rasst,
	sum(cast(ROUTE_DISTANCE as dec(7))) over(partition by ID,DOC_NUM) as srasst,
	TARIFF_SUM as d_plata,DEPARTMENT_SUM as d_poteri,
	DEPARTURE_STATION as st1,ARRIVAL_STATION as st2,
 REGION_CODE as reg,
	max(doc_reg) over (partition by ID,DOC_NUM) as max_nom, 
	sum(TARIFF_SUM) over (partition by ID,DOC_NUM) as s_plata,
	sum(DEPARTMENT_SUM) over (partition by ID,DOC_NUM) as s_poteri 
from rawdl22.l2_prig_cost where
id=383584483


select ssm_nmar as marshr,round(ssm_rst) as rst,cast(ssm_stan as decimal(7)) as kst,ssm_prmcd as pr_mcd,
 case when ssm_ksf=' ' then 0 else cast(ssm_ksf as decimal(3)) end as reg,
	case when ssm_prgr='1' or ssm_prgs='1' then '1' else '0' end as perelom,
	ROW_NUMBER() over (partition by ssm_nmar order by ssm_rst) as nom
	from prig.submars where ssm_nmar=17138




select nom3d,cast(nom3d as dec(3)) as dor,noml,cast(noml as dec(3)) as lin,cast(stan as dec(7)) as kst,rstn as rst,cast(sf as dec(3)) as sf,*
	from nsi.lines where --'2022-01-01' between datand and datakd and '2022-01-01' between datani and dataki 	and 
	nom3d='017' and noml='098' and stan='2001210'
	





select * from l3_prig.prig_mars where sto=2000225 and stn=2000460 order by nom_mar,nom


select ssm_nmar as marshr,round(ssm_rst) as rst,cast(ssm_stan as decimal(7)) as kst,ssm_prmcd as pr_mcd,
 case when ssm_ksf=' ' then 0 else cast(ssm_ksf as decimal(3)) end as reg,
	case when ssm_prgr='1' or ssm_prgs='1' then '1' else '0' end as perelom,
	ROW_NUMBER() over (partition by ssm_nmar order by ssm_rst) as nom
	from prig.submars  where '2022-10-01' between ssm_datan and ssm_datak and  ssm_nmar =17138


383584483

select train_num,id,request_num,* from rawdl22.l2_prig_main where id=383584483

select train_num,id,request_num,* from rawdl22.l2_pass_main where id=383584483


select train_num,* from rawdl22.l2_prig_cost where id=383584483

request_num =1536 = Номер запроса




383584483  =Заказы 1536



select yyyymm,request_date,count(*) from rawdl2m.l2_pass_main group by 1,2 order by 1,2

select oper,oper_g,count(*) as kol from rawdl2m.l2_pass_main where substr(train_num,1,1)='8' and substr(train_num,4,1) in('А','М','Г','Х','И','Й')
--and DEPARTURE_STATION=2004001 and ARRIVAL_STATION=2004400 
group by 1,2
and oper_g='O'
fetch first 5 rows only


select *
from rawdl2m.l2_pass_main where substr(train_num,1,1)='8' and substr(train_num,4,1) in('А','М','Г','Х','И','Й')
--and DEPARTURE_STATION=2004001 and ARRIVAL_STATION=2004400 --AND OPER_G='o'
and benefit_code>0
fetch first 5 rows only


select * from rawdl2m.l2_pass_cost where id in (358429305,358428960,358428823,358429138,358442171)

select * from rawdl2m.l2_pass_main where id in (358429305,358428960,358428823,358429138,358442171)


select distinct benefit_code
from rawdl2m.l2_pass_main where substr(train_num,1,1)='8' and substr(train_num,4,1) in('А','М','Г','Х','И','Й')
and DEPARTURE_STATION=2004001 and ARRIVAL_STATION=2004400 --AND OPER_G='o'
fetch first 5 rows only


select distinct sum_nde,vat_sum,vatrate from rawdl2m.l2_pass_cost where (id,doc_num) in
(select distinct ID,doc_num
from rawdl2m.l2_pass_main where substr(train_num,1,1)='8' and substr(train_num,4,1) in('А','М','Г','Х','И','Й')
and DEPARTURE_STATION=2004001 and ARRIVAL_STATION=2004400 --fetch first 5 rows only
)



select * from
(select id,doc_num,count(*) as kol from rawdl2m.l2_pass_cost 
 where (id,doc_num) in
(select distinct ID,doc_num
from rawdl2m.l2_pass_main where substr(train_num,1,1)='8' and substr(train_num,4,1) in('А','М','Г','Х','И','Й')
--and DEPARTURE_STATION=2004001 and ARRIVAL_STATION=2004400 --fetch first 5 rows only
)
 group by 1,2) as a where kol=2 fetch first 5 rows only
 

select * from rawdl2m.l2_pass_main where id in (366989876,366989989)
select * from rawdl2m.l2_pass_cost where id in (366989876,366989989)










select max(kol) from
(
	select * --id,doc_num,count(*) as kol 
	from rawdl2m.l2_pass_cost where (id,doc_num) in
(select distinct ID,doc_num
from rawdl2m.l2_pass_main where substr(train_num,1,1)='8' and substr(train_num,4,1) in('А','М','Г','Х','И','Й')
--and DEPARTURE_STATION=2004001 and ARRIVAL_STATION=2004400 
 and benefit_code>0
 fetch first 5 rows only
) group by 1,2) as a


marshr_ish as --список всех маршрутов
(select ssm_nmar as marshr,round(ssm_rst) as rst,cast(ssm_stan as decimal(7)) as kst,
 case when ssm_ksf=' ' then 0 else cast(ssm_ksf as decimal(3)) end as reg,
	case when ssm_prgr='1' or ssm_prgs='1' then '1' else '0' end as perelom,
	ROW_NUMBER() over (partition by ssm_nmar order by ssm_rst) as nom

 select distinct ssm_datan,ssm_datak,datakor
 from prig.submars 


select distinct web_id, payagent_id, user_id, payment_id  from rawdl2s.l2_prig_main fetch first 5 rows only

select * from magic_nsi.payment_type

select spectarif_code,count(*) as kol from rawdl2m.l2_prig_cost group by 1

select tarif_type,count(*) as kol from rawdl2m.l2_prig_cost group by 1


web_id, payagent_id, user_id, payment_id 

fetch first 5 rows only
" "	14980884
"В"	99805
"Ж"	150483
"Р"	13073
"Т"	36

select *,count(*) over(partition by kod_lgt) as kk from
(select distinct FLG_BSP,proc_lgt,grup_lgt,kod_lgt,flg_child from spb_prig.prig_bil) as a order by 1,2,3,4

select distinct bag_vid from spb_prig.prig_bil


select * from (select surname,count(*) as kol from rawdl2s.l2_prig_adi group by 1) as a order by -kol 
fetch first 5 rows only

select request_date,count(*) as kol from rawdl2s.l2_prig_adi group by 1 --"2021-12-31"	1576366  "2022-01-01"	413034  "2022-01-02"	5

select request_date,count(*) as kol from rawdl2s.l2_prig_main group by 1 --"2021-12-31"	1576366
"2022-01-01"	413034
"2022-01-02"	5
fetch first 5 rows only


select distinct ID_SITE,count(*) as kol from rawdl2m.l2_prig_main --where SALE_STATION>=2090000 --and DEPARTURE_STATION=2004001 and ARRIVAL_STATION=2004400
group by 1
fetch first 5 rows only




select TERM_DOR,* from rawdl2s.l2_prig_main where term_dor='М'
fetch first 5 rows only


stan as --принадлежности станций НОДам и ДЦСам и субъектам
(select cast(stan as dec(7)) as kst,gos,koddcs as dcs,dor,cast(otd as dec(3)) as otd,cast(sf as dec(3)) as sf,kodokato as okato,
 prgrotd as gr_otd,prgrsf as gr_sf
 from nsi.stanv as a,dates as b where date_zap between datand and datakd and date_zap between datani and dataki),
 
select * from nsi.sf 
 

select distinct sf,kodokato
 from nsi.stanv where '2021-09-01' between datand and datakd and '2021-09-01' between datani and dataki order by 1,2

select distinct sf,admr,nopr
from nsi.stanv where '2021-09-01' between datand and datakd and '2021-09-01' between datani and dataki and gos='20' --and dor='1' 
and sf in('47','78')
order by 1,2,3


with sts as
(select distinct train_num,DEPARTURE_STATION as sto,ARRIVAL_STATION as stn 
from rawdl2s.l2_prig_main where cast(train_num as dec(5))<99 order by 1),
sts2 as
(select distinct * from
(select train_num,sto as kst from sts
union all
select train_num,sto as kst from sts
) as a order by 1,2),
lin_ as --структура всех линий
(select dor,lin,kst,rst,reg,ROW_NUMBER() over (partition by dor,lin order by rst) as nom from
(select cast(nom3d as dec(3)) as dor,cast(noml as dec(3)) as lin,cast(stan as dec(7)) as kst,rstk as rst,cast(sf as dec(3)) as reg
	from nsi.lines /*as a,dates as b where date_zap*/
 where '2021-09-01' between datand and datakd and /*date_zap*/ '2021-09-01'  between datani and dataki) as a)
 
select train_num,dor,lin,kst,rst,reg,nom,count(*) over(partition by train_num,kst) as kk
from
(select train_num,dor,lin,a.kst,rst,reg,nom,count(*) over(partition by train_num,dor,lin) as qq
from sts2 as a,lin_ as b where a.kst=b.kst ) as c where qq>1 order by train_num,dor,lin,nom



select distinct train_num  from rawdl2s.l2_prig_main order by 1

select distinct ssm_prmcd,count(*) as kol
	from prig.submars group by 1 fetch first 5 rows only



select distinct ssm_datan,ssm_datak 	from prig.submars 

select distinct ssm_stan,ssm_ksf from prig.submars where ssm_prmcd='1'

select * from prig.submars where ssm_prmcd='1'


select distinct sf,kodokato from nsi.stanv --fetch first 5 rows only

select dor,stan,snazv,* from nsi.stanv --fetch first 5 rows only
where stan in(select ssm_stan from prig.submars where ssm_prmcd='1') and datakd>'2021-09-01' order by dor


select cast(nom3d as dec(3)) as dorr,cast(noml as dec(3)) as lin,* from nsi.lines
where stan in(select ssm_stan from prig.submars where ssm_prmcd='1') and datakd>'2021-09-01' and dataki>'2021-09-01' order by dorr,lin,rstn


with lin as
(select cast(nom3d as dec(3)) as dor,cast(noml as dec(3)) as lin,rstn,stan from nsi.lines
where  datakd>'2021-09-01' and dataki>'2021-09-01')
select a.dor,lin,rstn,a.stan,sf,kodokato,prgrsf,*  from lin as a,nsi.stanv as b where a.stan=b.stan and datakd>'2021-09-01' 
order by a.dor,lin,rstn



select * from prig.submars where ssm_nmar in(select ssm_nmar from prig.submars where ssm_prmcd!='0') order by  ssm_nmar,ssm_rst



select * from prig.submars where ssm_nmar in(17007,17010) order by  ssm_nmar,ssm_rst

select *
/*ssm_nmar as marshr,round(ssm_rst) as rst,cast(ssm_stan as decimal(7)) as kst,
 case when ssm_ksf=' ' then 0 else cast(ssm_ksf as decimal(3)) end as reg,
	case when ssm_prgr='1' or ssm_prgs='1' then '1' else '0' end as perelom,
	ROW_NUMBER() over (partition by ssm_nmar order by ssm_rst) as nom*/
	from prig.submars  fetch first 5 rows only


select distinct ABONEMENT_TYPE from spb_prig.prig_bil order by 1;

select distinct srok_bil,srok_mon from spb_prig.prig_bil order by 1,2;

/*
CREATE TABLE spb_prig.prig_bil
(
	nom_bil dec(7),	
	k_pas smallint,srok_bil smallint,srok_mon smallint,flg_bag char(1),FLG_tuda_obr char(1),flg_rab_day char(1),	
	flg_ruch char(1),vid_rasch char(1),FLG_CHILD char(1),flg_voin smallint,FLG_MILITARY char(1),
	flg_lgt char(1),FLG_BSP char(1),FLG_SO char(1),FLG_NU char(1),FLG_TT char(1),	
	klass  char(1),kod_lgt smallint,lgt_reg smallint,bag_vid char(1),bag_ves smallint,proc_lgt smallint,	
	ABONEMENT_TYPE character(3),TRAIN_CATEGORY char(1),TRAIN_NUM char(5),grup_lgt smallint,date_zap date,
	id bigint,doc_num smallint --для удобства расследований
	)
	*/

---select count(*) from rawdl2m.l2_pass_main  -- 23 916 715 - база пассажирских перевозок

--  delete from spb_prig.prig_times where oper like '%agr%';

-- поиск причин расхождения "О"	41	41	"kol_pas   "	165139	4336646	175200573  ==(-171 пасс, -5 001 пкм)  надо tek_pas=4336817 =  - РАЗОБРАТЬСЯ!!!!!
---поиск их в итоге!
--ПЛОХО - ЕСТЬ РЕГИОН reg=0 НА ОТПРАВКЕ  ПАССАЖИРА

--поиск в 1 уровне


SELECT * FROM spb_rawd.t1_0905  where id in (314566809,314572643,314566808,314573386,314573387,314573388)	--9 строк, ВТЧ 3 штуки doc_nom=2
 where
 abonement_type='0' and flg_child='0'
	and BENEFIT_CODE=0000  and FLG_1WAYTICKET='1' and PAYMENTTYPE='8' and FLG_CARRYON='0' 
	and yyyymm=202108 and term_dor='О' 
	and AGENT_CODE=41 and SALE_STATION =2006200 and DEPARTURE_STATION=2006200 and ARRIVAL_STATION=2004451
	and TICKET_BEGDATE ='2021-08-02'
FETCH FIRST 5 ROWS ONLY; 

/*
SELECT * FROM spb_rawd.t1_0901 where id in (314566809,314572643,314566808,314573386,314573387,314573388)		--6 строк
FETCH FIRST 5 ROWS ONLY; 

SELECT * FROM spb_rawd.t1_0905 where id in (314566809,314572643,314566808,314573386,314573387,314573388)	--9 строк, ВТЧ 3 штуки doc_nom=2
FETCH FIRST 5 ROWS ONLY; 

SELECT * FROM spb_rawd.t1_0906 where id in (314566809,314572643,314566808,314573386,314573387,314573388)	--9 строк, ВТЧ 3 штуки doc_nom=2.  нет даты начала

SELECT * FROM spb_rawd.t1_0914 --where id in (314566809,314572643,314566808,314573386,314573387,314573388)	--0 строк
FETCH FIRST 5 ROWS ONLY; 

SELECT * FROM spb_rawd.t1_common where id in (314566809,314572643,314566808,314573386,314573387,314573388)	--6 строк. нет даты начала
FETCH FIRST 5 ROWS ONLY; 
*/

-----------=================================================
--ВЫБОРКА ИЗ ИСХОДНИКА 2 УРОВНЯ
select PASS_QTY*(case when oper_g='G' then -1 else 1 end) as kol_bil,ID,DOC_NUM, * from rawdl2m.l2_prig_main where
 abonement_type='0' and flg_child='0'
	and BENEFIT_CODE=0000  and FLG_1WAYTICKET='1' and PAYMENTTYPE='8' and FLG_CARRYON='0' 
	and yyyymm=202108 and term_dor='О' 
	and AGENT_CODE=41 and SALE_STATION =2006200 and DEPARTURE_STATION=2006200 and ARRIVAL_STATION=2004451
	and TICKET_BEGDATE ='2021-08-02'
	
	
select PASS_QTY*(case when oper_g='G' then -1 else 1 end) as kol_bil,ID,DOC_NUM, * from rawdl2m.l2_prig_main 
where id in (314566809,314572643,314566808,314573386,314573387,314573388)	

select count(*) from rawdl2m.l2_prig_main where request_date='2021-08-20'  -- 621736
SELECT count(*) FROM spb_rawd.t1_0905  where _m_date='2021-08-20'  -- 621736


select distinct train_category from rawdl2m.l2_prig_main -- все классы поезда в базе


select count(*) from rawdl2m.l2_prig_main where TICKET_BEGDATE ='2021-08-02'  -- 109435

SELECT count(*) FROM spb_rawd.t1_0901  where ticket_begdate='2021-08-02'  -- 97067

select count(*) from (select distinct id from rawdl2m.l2_prig_main where TICKET_BEGDATE ='2021-08-02') as a  -- 96362
select count(*) from (select distinct id from spb_rawd.t1_0901  where ticket_begdate='2021-08-02') as a  -- 97067

select * from spb_rawd.t1_0901 where id in
(select distinct id from spb_rawd.t1_0901  where ticket_begdate='2021-08-02' 
 and id not in (select distinct id from rawdl2m.l2_prig_main where TICKET_BEGDATE ='2021-08-02'))
 and agent_code=41 and SALE_STATION =2006200 -- and DEPARTURE_STATION=2006200  and ARRIVAL_STATION=2004451

/*
14	314573386	202108
56	314566808	202108
1	314572643	202108
10	314573388	202108
93	314566809	202108
28	314573387	202108
*/


---------------------------------------------------------------------- не хватает 1 пассажира уже в обогащении
with
bil as(select * from spb_prig.prig_bil where abonement_type='0' and flg_child='0'
	and kod_lgt=0000  and flg_tuda_obr='1' and vid_rasch='8' and flg_bag='0'),
mar as(select * from spb_prig.prig_mars where sto=2006200 and nom=1 and stn=2004451 
	  )
--select stn,sum(kol_bil) from (
--,prig as(
	select * 
from spb_prig.prig_itog 
	 where yyyymm=202108 and term_dor='О' 
	and agent=41 and stp=2006200
	and nom_mar in(select nom_mar from mar) and nom_bil in(select nom_bil from bil) and date_beg='2021-08-02'
	--) as a,mar as b  where a.nom_mar=b.nom_mar group by 1  -- =6759   stp=2006200 =5856
/*
314566808	1	202108	70
314572643	1	202108	1
314573388	1	202108	10
314566809	1	202108	121
*/	
--select  * from bil where nom_bil in(select nom_bil from prig)

/*
stn=2004451	   	202   =203
*/

--711	2054
--1451	3802

/*
select * from  spb_prig.prig_bil where nom_bil in(select distinct nom_bil
	from spb_prig.prig_agr_kst where yyyymm=202108 and term_dor='О' and abonement_type='0' and flg_child='0' 
	and date between '2021-08-01' and '2021-08-31' and agent=41 and par_name in('kol_pas','sf_pas-') and kod_lgt=0000  and kst=2006200)
	and flg_tuda_obr='1' and vid_rasch='8'
*/	
select date_beg,par_name,sum(param1) as param1,sum(param2) as param2 
	from spb_prig.prig_agr_kst as a join  spb_prig.prig_bil as b on a.nom_bil=b.nom_bil
	where yyyymm=202108 and term_dor='О' and a.abonement_type='0' and a.flg_child='0'
	and date between '2021-08-01' and '2021-08-31' and agent=41 and par_name in('kol_pas') and a.kod_lgt=0000  and kst=2006200
	and flg_tuda_obr='1' and vid_rasch='8' and flg_bag='0'
	group by 1,2 order by 1,2	

*/

------------------------------------------------


select date_beg,sum(param1) as param1,sum(param2) as param2 
	from spb_prig.prig_agr_kst where yyyymm=202108 and term_dor='О' and abonement_type='0' and flg_child='0'
	and date between '2021-08-01' and '2021-08-31' and agent=41 and par_name in('kol_pas','sf_pas-') and kod_lgt=0000 and kst=2006200
	and nom_bil=1086
	group by 1



select a.nom_bil,par_name,sum(param1) as param1,sum(param2) as param2 
	from spb_prig.prig_agr_kst as a join  spb_prig.prig_bil as b on a.nom_bil=b.nom_bil
	where yyyymm=202108 and term_dor='О' and a.abonement_type='0' and a.flg_child='0'
	and date between '2021-08-01' and '2021-08-31' and agent=41 and par_name in('kol_pas','sf_pas-') and a.kod_lgt=0000  and kst=2006200
	and flg_tuda_obr='1'
	group by 1,2 order by 1,2




select * from  spb_prig.prig_bil where nom_bil in(select distinct nom_bil
	from spb_prig.prig_agr_kst where yyyymm=202108 and term_dor='О' and abonement_type='0' and flg_child='0' 
	and date between '2021-08-01' and '2021-08-31' and agent=41 and par_name in('kol_pas','sf_pas-') and kod_lgt=0000  and kst=2006200)
	and flg_tuda_obr='1' and vid_rasch='8'

select train_category,
sum(case when par_name='kol_pas' then param1 else 0 end) as kol_pas,
sum(case when par_name='kol_bil' then param1 else 0 end) as kol_bil
	from spb_prig.prig_agr_kst as a join  spb_prig.prig_bil as b on a.nom_bil=b.nom_bil
	where yyyymm=202108 and term_dor='О' and a.abonement_type='0' and a.flg_child='0'
	and date between '2021-08-01' and '2021-08-31' and agent=41 and par_name in('kol_pas') and a.kod_lgt=0000  and kst=2006200
	and flg_tuda_obr='1' and vid_rasch='8' and date_beg='2021-08-02'
	group by 1 order by 1
-- "Л"	2411	0
-- "О"	4348	0
ещё надо -5 и +10 пасс по 1 и 4 типу!!!





select *
--sum(case when par_name='kol_pas' then param1 else 0 end) as kol_pas 

	from spb_prig.prig_agr_kst as a join  spb_prig.prig_bil as b on a.nom_bil=b.nom_bil
	where yyyymm=202108 and term_dor='О' and a.abonement_type='0' and a.flg_child='0'
	and date between '2021-08-01' and '2021-08-31' and agent=41 and par_name in('kol_pas') and a.kod_lgt=0000  and kst=2006200
		and date_beg='2021-08-02'
	and flg_tuda_obr='1' and vid_rasch='8'
	group by 1 order by 1
--"1"	65952	68157  ==65956  =-4
--"8"	208622	189940 ==208627  =-5

select date_beg,par_name,sum(param1) as param1,sum(param2) as param2 
	from spb_prig.prig_agr_kst as a join  spb_prig.prig_bil as b on a.nom_bil=b.nom_bil
	where yyyymm=202108 and term_dor='О' and a.abonement_type='0' and a.flg_child='0'
	and date between '2021-08-01' and '2021-08-31' and agent=41 and par_name in('kol_pas','sf_pas-') and a.kod_lgt=0000  and kst=2006200
	and flg_tuda_obr='1' and vid_rasch='8'
	group by 1,2 order by 1,2
/*  and vid_rasch='8'   0	"kol_pas   "	208622	6708093  ==208627
"2021-08-01"	"kol_pas   "	7031	224459
"2021-08-02"	"kol_pas   "	6759	210031 =6760
"2021-08-03"	"kol_pas   "	6729	211179
"2021-08-04"	"kol_pas   "	6639	206580 =6640
"2021-08-05"	"kol_pas   "	6614	209939
"2021-08-06"	"kol_pas   "	7122	238187 =7123
"2021-08-07"	"kol_pas   "	6126	205166
"2021-08-08"	"kol_pas   "	4918	163883
"2021-08-09"	"kol_pas   "	6909	216179
"2021-08-10"	"kol_pas   "	6766	211471
"2021-08-11"	"kol_pas   "	5600	182874
"2021-08-12"	"kol_pas   "	6448	203074
"2021-08-13"	"kol_pas   "	7859	261151
"2021-08-14"	"kol_pas   "	6869	232286 =6870
"2021-08-15"	"kol_pas   "	5720	187554
"2021-08-16"	"kol_pas   "	7062	219997
"2021-08-17"	"kol_pas   "	6730	209199
"2021-08-18"	"kol_pas   "	6679	213638
"2021-08-19"	"kol_pas   "	6735	213700
"2021-08-20"	"kol_pas   "	8152	275244
"2021-08-21"	"kol_pas   "	6181	212030
"2021-08-22"	"kol_pas   "	5571	178882
"2021-08-23"	"kol_pas   "	7129	221348
"2021-08-24"	"kol_pas   "	6880	217379
"2021-08-25"	"kol_pas   "	7186	224981
"2021-08-26"	"kol_pas   "	6945	217302
"2021-08-27"	"kol_pas   "	8349	275500
"2021-08-28"	"kol_pas   "	7215	244548
"2021-08-29"	"kol_pas   "	5829	184600
"2021-08-30"	"kol_pas   "	6989	218649
"2021-08-31"	"kol_pas   "	6881	217083 =6882





"2021-08-01"	"kol_pas   "	9598	298383
"2021-08-02"	"kol_pas   "	8966	277737  ==8967  =1
"2021-08-03"	"kol_pas   "	8875	276193
"2021-08-04"	"kol_pas   "	8777	269356 ==8778  =1
"2021-08-05"	"kol_pas   "	8753	274399
"2021-08-06"	"kol_pas   "	9359	312025 ==9360  =1
"2021-08-07"	"kol_pas   "	8044	263838
"2021-08-08"	"kol_pas   "	6571	212709
"2021-08-09"	"kol_pas   "	9077	279579
"2021-08-10"	"kol_pas   "	8787	272784
"2021-08-11"	"kol_pas   "	8230	260880
"2021-08-12"	"kol_pas   "	8535	268126
"2021-08-13"	"kol_pas   "	10127	332690
"2021-08-14"	"kol_pas   "	9024	300638 =9025  =1
"2021-08-15"	"kol_pas   "	7540	242947
"2021-08-16"	"kol_pas   "	9338	287456
"2021-08-17"	"kol_pas   "	8802	271705
"2021-08-18"	"kol_pas   "	8801	278317
"2021-08-19"	"kol_pas   "	8806	276265
"2021-08-20"	"kol_pas   "	10474	349339
"2021-08-21"	"kol_pas   "	8223	278654
"2021-08-22"	"kol_pas   "	7371	233193
"2021-08-23"	"kol_pas   "	9385	288459
"2021-08-24"	"kol_pas   "	8985	278879 ==8987  =2
"2021-08-25"	"kol_pas   "	9331	289029
"2021-08-26"	"kol_pas   "	9015	280296
"2021-08-27"	"kol_pas   "	10750	353883
"2021-08-28"	"kol_pas   "	9275	308850
"2021-08-29"	"kol_pas   "	7654	241161
"2021-08-30"	"kol_pas   "	9135	284331  =9136 =1
"2021-08-31"	"kol_pas   "	8966	281541  ==8968 =2

*/

select kst,par_name,sum(param1) as param1,sum(param2) as param2 
	from spb_prig.prig_agr_kst where yyyymm=202108 and term_dor='О' and flg_child='0'
	and date between '2021-08-01' and '2021-08-31' and agent=41 and par_name in('kol_pas-','sf_pas') and kod_lgt=0000 and abonement_type='0'
	group by 1,2 order by 1,2
/*
2004764	"sf_pas    "	72542	1473163   ==72604  ==-62
2006200	"sf_pas    "	334875	10390225 ==334884  ==-9     stp=2006200
*/


select flg_tuda_obr,par_name,sum(param1) as param1,sum(param2) as param2 
	from spb_prig.prig_agr_kst as a join  spb_prig.prig_bil as b on a.nom_bil=b.nom_bil
	where yyyymm=202108 and term_dor='О' and a.abonement_type='0' and a.flg_child='0'
	and date between '2021-08-01' and '2021-08-31' and agent=41 and par_name in('kol_pas','sf_pas-') and a.kod_lgt=0000  and kst=2006200
	group by 1,2 order by 1,2
/*  
"1"	"kol_pas   "	274574	8723642  ==274583
"2"	"kol_pas   "	65941	1732304
*/
	

select * from  spb_prig.prig_bil where nom_bil in(select distinct nom_bil
	from spb_prig.prig_agr_kst where yyyymm=202108 and term_dor='О' and abonement_type='0' and flg_child='0' 
	and date between '2021-08-01' and '2021-08-31' and agent=41 and par_name in('kol_pas','sf_pas-') and kod_lgt=0000  and kst=2006200)
	and flg_tuda_obr='1'


select nom_bil,par_name,sum(param1) as param1,sum(param2) as param2 
	from spb_prig.prig_agr_kst where yyyymm=202108 and term_dor='О' and abonement_type='0' and flg_child='0'
	and date between '2021-08-01' and '2021-08-31' and agent=41 and par_name in('kol_pas','sf_pas-') and kod_lgt=0000  and kst=2006200
	group by 1,2 order by 1,2



select flg_child,par_name,sum(param1) as param1,sum(param2) as param2 
	from spb_prig.prig_agr_kst where yyyymm=202108 and term_dor='О' and abonement_type='0'
	and date between '2021-08-01' and '2021-08-31' and agent=41 and par_name in('kol_pas','sf_pas-') and kod_lgt=0000  and kst=2006200
	group by 1,2 order by 1,2
/*
"0"	"kol_pas   "	340515	10455946  ==340524
*/

select kst,par_name,sum(param1) as param1,sum(param2) as param2 
	from spb_prig.prig_agr_kst where yyyymm=202108 and term_dor='О' 
	and date between '2021-08-01' and '2021-08-31' and agent=41 and par_name in('kol_pas','sf_pas-') and kod_lgt=0000 and abonement_type='0'
	group by 1,2 order by 1,2
/*
2004600	"kol_pas   "	147322	17948504  =147350 	==-28

2006004	"kol_pas   "	470644	30615107  ==470678  ==-34
2006200	"kol_pas   "	342390	10523241  ==342399  ==-9


*/	


select reg,par_name,sum(param1) as param1,sum(param2) as param2 
	from spb_prig.prig_agr_kst where yyyymm=202108 and term_dor='О' 
	and date between '2021-08-01' and '2021-08-31' and agent=41 and par_name in('kol_pas','sf_pas-')and kod_lgt=0 and abonement_type='0'
	group by 1,2 order by 1,2
/*
0	"kol_pas   "	3	24   --ПЛОХО, НЕ ДОЛЖНО БЫТЬ РЕГИОНА=0
50	"kol_pas   "	1010566	28012636
53	"kol_pas   "	214	7567
60	"kol_pas   "	3368	210762
69	"kol_pas   "	368766	29694409
76	"kol_pas   "	464	30952
77	"kol_pas   "	1326924	51239048
*/

select abonement_type,par_name,sum(param1) as param1,sum(param2) as param2 
	from spb_prig.prig_agr_kst where yyyymm=202108 and term_dor='О' 
	and date between '2021-08-01' and '2021-08-31' and agent=41 and par_name in('kol_pas-','sf_pas') and kod_lgt=0
	--fetch first 5 rows only
	group by 1,2 order by 1,2
/*
"0  "	"sf_pas    "	2710305	109195398  	=2710376		=-71
"1  "	"sf_pas    "	15632	464770		=15298			=+334
"2  "	"sf_pas    "	23062	694718 +
"3  "	"sf_pas    "	51674	1417264		=51566			=+108
"4  "	"sf_pas    "	158232	4414522+
"5  "	"sf_pas    "	2382	105498		=2378			=+4
"7  "	"sf_pas    "	143978	4713806		=144424			=-446
"8  "	"sf_pas    "	40156	1166114		=40236			=-80
*/


select kod_lgt,par_name,sum(param1) as param1,sum(param2) as param2 
	from spb_prig.prig_agr_kst where yyyymm=202108 and term_dor='О' 
	and date between '2021-08-01' and '2021-08-31' and agent=41 and par_name in('kol_pas','sf_pas-')
	group by 1,2 order by 1,2

/*
0	"kol_pas   "	3145421	122172090  		=3145572   =-151
..............
2204	"kol_pas   "	50017	2768007 	=50037 		=-20
.........
*/
-- поиск причин расхождения "О"	41	41	"kol_pas   "	165139	4336646	175200573  ==(-171 пасс, -5 001 пкм)  надо tek_pas=4336817 =  - РАЗОБРАТЬСЯ!!!!!



/*
старый пригород август 2021

DORP=0 CHP=0 AGT=0 kol_bil=10279292 kol_pas=13301957 pass_km=541392285 tek_pas=12834067 tek_pkm=526790435 plata=9576790239
s_pot=5827152141 bag_bil=121118 bag_plat=49521336

DORP=1 CHP=15 AGT=15 kol_bil=25932 kol_pas=33470 pass_km=3636779 tek_pas=32151 tek_pkm=3486292 plata=60268715 s_pot=31379860
bag_bil=208 bag_plat=167147

DORP=1 CHP=23 AGT=23 kol_bil=5749488 kol_pas=7236885 pass_km=304015605 tek_pas=7096458 tek_pkm=299655505 plata=4295102110
s_pot=3641720660 bag_bil=91657 bag_plat=39142520
DORP=1 CHP=41 AGT=41 kol_bil=3274602 kol_pas=4648204 pass_km=184719087 tek_pas=4336817 tek_pkm=175205574 plata=4183434654
s_pot=1857670043 bag_bil=14265 bag_plat=6251095
DORP=10 CHP=53 AGT=53 kol_bil=607370 kol_pas=665873 pass_km=20244902 tek_pas=659926 tek_pkm=20097277 plata=390574320
s_pot=29448200 bag_bil=6172 bag_plat=1128260
DORP=17 CHP=23 AGT=23 kol_bil=8932 kol_pas=9500 pass_km=1680401 tek_pas=8130 tek_pkm=1434234 plata=50580825 s_pot=0 bag_bil=0
bag_plat=0
DORP=28 CHP=52 AGT=1 kol_bil=38 kol_pas=522 pass_km=7014 tek_pas=424 tek_pkm=5512 plata=225120 s_pot=103040 bag_bil=0 bag_plat=0
DORP=28 CHP=52 AGT=52 kol_bil=612930 kol_pas=707503 pass_km=27088497 tek_pas=700161 tek_pkm=26906041 plata=596604495
s_pot=266830338 bag_bil=8816 bag_plat=2832314


*/



select term_dor,agent,chp,par_name,count(*) as kol,sum(param1) as param1,sum(param2) as param2 
	from spb_prig.prig_agr_kst where yyyymm=202108 and term_dor='О' 
	and date between '2021-08-01' and '2021-08-31'
	group by 1,2,3,4 order by 1,2,3,4
/*

DORP=1 CHP=15 AGT=15 kol_bil=25932 kol_pas=33470 pass_km=3636779 tek_pas=32151 tek_pkm=3486292 plata=60268715 s_pot=31379860
bag_bil=208 bag_plat=167147

"О"	15	15	"bag_bil   "	86	+ 208	0
"О"	15	15	"bag_plat  "	86	+ 167147	0
"О"	15	15	"kol_bil   "	1259	+ 25932	0
"О"	15	15	"kol_pas   "	4000	32153	3486496
"О"	15	15	"plata     "	1259	+ 60268715	+ 31379860
"О"	15	15	"p_plata   "	4000	58975769	30419070
"О"	15	15	"pr_pas    "	1259	33907	3679647
"О"	15	15	"sf_pas    "	1330	32153	3486496  == +2пас  +204пкм - РАЗОБРАТЬСЯ!!!!!
"О"	15	15	"sf_plat   "	1330	58975769	30419070

DORP=1 CHP=23 AGT=23 kol_bil=5749488 kol_pas=7236885 pass_km=304015605 tek_pas=7096458 tek_pkm=299655505 plata=4295102110
s_pot=3641720660 bag_bil=91657 bag_plat=39142520

"О"	23	23	"bag_bil   "	16582	+ 91657	0
"О"	23	23	"bag_plat  "	16582	+ 39142520	0
"О"	23	23	"kol_bil   "	190368	+ 5749488	0
"О"	23	23	"kol_pas   "	432388	7096434	299649378
"О"	23	23	"perebor   "	2858	281740	-4157030
"О"	23	23	"plata     "	190368	+ 4295102110	+ 3641720660
"О"	23	23	"p_plata   "	432388	4226863502	3585291400
"О"	23	23	"pr_pas    "	190368	7273659	304848559
"О"	23	23	"sf_pas    "	252070	7096434	299649378 ====(-24 пас, --6127 пкм)
"О"	23	23	"sf_plat   "	252070	4226863502	3585291400

DORP=1 CHP=41 AGT=41 kol_bil=3274602 kol_pas=4648204 pass_km=184719087 tek_pas=4336817 tek_pkm=175205574 plata=4183434654
s_pot=1857670043 bag_bil=14265 bag_plat=6251095

"О"	41	41	"bag_bil   "	3521	+14265	0
"О"	41	41	"bag_plat  "	3521	+6251095	0
"О"	41	41	"kol_bil   "	76293	3274531	0
"О"	41	41	"kol_pas   "	165139	4336646	175200573  ==(-171 пасс, -5 001 пкм)
"О"	41	41	"plata     "	76293	4182938534	1857670043  ==(-496 120 руб,  0 потерь)
"О"	41	41	"p_plata   "	165139	3942626032	1819254646
"О"	41	41	"pr_pas    "	76293	4731231	186873323
"О"	41	41	"sf_pas    "	96589	4336646	175200573
"О"	41	41	"sf_plat   "	96589	3942626032	1819254646
*/


select yyyymm,par_name,count(*) as kol,sum(param1) as param1,sum(param2) as param2 
	from spb_prig.prig_agr_kst where yyyymm=202108 group by 1,2 order by 1,2

/*
202108	"bag_bil   "	25708	121118	0
202108	"bag_plat  "	25706	49521336	0
202108	"kol_bil   "	322463	10270337	0
202108	"kol_pas   "	885521	13413277	542735465
202108	"perebor   "	4116	2242830	-6152161
202108	"plata     "	322463	9525881626	5827325141
202108	"p_plata   "	885525	9525881626	5827325141
202108	"pr_pas    "	322463	13413277	542735465
202108	"sf_pas    "	485574	13413277	542735465
202108	"sf_plat   "	485574	9525881626	5827325141
*/



select yyyymm,par_name,count(*) as kol,sum(plata) as plata,sum(poteri) as poteri,
	sum(per_pas) as per_pas,sum(otpr_pas) as otpr_pas,sum(prib_pas) as prib_pas,sum(per_pas*rst) as per_pkm
	from spb_prig.prig_agr_pereg where yyyymm=202108 --and par_name='otpr'
	group by 1,2 order by 1,2
/*
202108	"otpr    "	419378	7883009078	4774221116	131829836	10859537	10859537	449154162
202108	"prod    "	196177	7883009078	4774221116	131829836	10859537	10859537	449154162
*/

select term_dor,agent,chp,par_name,count(*) as kol,sum(plata) as plata,sum(poteri) as poteri,
	sum(per_pas) as per_pas,sum(otpr_pas) as otpr_pas,sum(prib_pas) as prib_pas,sum(per_pas*rst) as per_pkm
	from spb_prig.prig_agr_pereg where yyyymm=202108 and par_name='otpr' group by 1,2,3,4 order by 1,2,3,4
/*
"9"	53	53	"otpr    "	26172	390574320	29448200	4964925	665686	665686	20233445
"О"	15	15	"otpr    "	4026	60268715	31379860	864904	33907	33907	3679647
"О"	23	23	"otpr    "	230772	3438944320	2934405270	68909392	5816149	5816149	244809306
"О"	41	41	"otpr    "	60679	3396236956	1511881408	51187430	3635011	3635011	153331689
"Я"	1	52	"otpr    "	3004	320320	159040	5702	766	766	11618
"Я"	52	52	"otpr    "	94725	596664447	266947338	5897483	708018	708018	27088457
*/


select * from
(select date_zap,par_name,term_dor,agent,chp,count(*) as kol,sum(plata) as plata,sum(poteri) as poteri,
	sum(per_pas) as per_pas,sum(otpr_pas) as otpr_pas,sum(prib_pas) as prib_pas,sum(per_pas*rst) as per_pkm
	from spb_prig.prig_agr_pereg where yyyymm=202108 and par_name='otpr'
	group by 1,2,3,4,5) as a where otpr_pas!=prib_pas order by otpr_pas

-----------------

select * from
(select nom_bil,par_name,term_dor,agent,chp,count(*) as kol,sum(plata) as plata,sum(poteri) as poteri,
	sum(per_pas) as per_pas,sum(otpr_pas) as otpr_pas,sum(prib_pas) as prib_pas,sum(per_pas*rst) as per_pkm
	from spb_prig.prig_agr_pereg where yyyymm=202108 and par_name='otpr' and date_zap='2021-08-25' and nom_bil=1088
	group by 1,2,3,4,5) as a where otpr_pas!=prib_pas order by otpr_pas
	
	
select * from spb_prig.prig_agr_pereg where yyyymm=202108 and par_name='otpr' and date_zap='2021-08-25' and nom_bil=1088	
-- от 2010250 до 2010001
--select * from spb_prig.prig_peregoni where peregon in(10726,10727)
--ОДИНАКОВЫЕ ПЕРЕГОНЫ С РАЗНЫМ РАССТОЯНИЕМ!!!


select * from spb_prig.prig_itog where yyyymm=202108 and date_zap='2021-08-25' and nom_bil=1088	

select * from spb_prig.prig_bil where nom_bil=1088	--ТОЛЬКО ТУДА, НЕ ОБРАТНО!!!
select * from spb_prig.prig_mars where nom_mar=62930 order by nom

select * from spb_prig.prig_peregoni where peregon in(10726,10727)
--28	7	2010250	2010347	10726		1	"2021-08-16"
--28	7	2010250	2010347	10727		2	"2021-08-16"


select * from spb_prig.prig_peregoni where st1 in(2010250,2010347) and  st2 in(2010250,2010347)











