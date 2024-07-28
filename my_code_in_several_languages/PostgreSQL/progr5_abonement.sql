




select part_zap,date_zap,rez,count(*) as kol from l3_mes.prig_work group by 1,2,3 order by 1,2,3



--------- ВОЗВРАТЫ ТЕСТОВЫЕ ПРИМЕРЫ ДЕЛЕНИЯ РАССТОЯНИЙ


  
select kodbl,oper,oper_g,TARIFF_SUM as plata,DEPARTMENT_SUM as poteri,*  from rawdl2.l2_prig_main where REQUEST_DATE='2023-08-15' order by kodbl,oper



  
select *  from rawdl2.l2_prig_cost where REQUEST_DATE='2023-08-15' and id in(100929,100946) order by id



select term_dor,oper,oper_g,count(*),min(REQUEST_DATE),max(REQUEST_DATE) from rawdl2m.l2_prig_main group by 1,2,3 -- 4231301	"2023-02-01"	"2023-03-02"
-- "О"	3952324	"2023-02-01"	"2023-03-02"


select term_dor,count(*),min(REQUEST_DATE),max(REQUEST_DATE) from rawdl2m.l2_prig_main group by 1 -- 4231301	"2023-02-01"	"2023-03-02"
-- "О"	3952324	"2023-02-01"	"2023-03-02"


select term_dor,count(*),min(REQUEST_DATE),max(REQUEST_DATE) from rawdl2m.l2_pass_main group by 1 -- "О"	673516	"2023-02-01"	"2023-03-03"




select term_dor,count(*),min(REQUEST_DATE),max(REQUEST_DATE) from zzz_rawdl2.l2_prig_main where yyyymm=202304 group by 1 -- 4231301	"2023-02-01"	"2023-03-02"
--"М"	12650919	"2023-04-06"	"2023-05-02"
--"Н"	691372	"2023-04-08"	"2023-05-02"
--"О"	4365221	"2023-04-01"	"2023-05-02"

select term_dor,count(*),min(REQUEST_DATE),max(REQUEST_DATE) from zzz_rawdl2.l2_pass_main where yyyymm=202304 group by 1 -- 4231301	"2023-02-01"	"2023-03-02"
--"М"	24884886	"2023-04-01"	"2023-05-02"
--"Н"	358549	"2023-04-01"	"2023-05-02"
--"О"	1003490	"2023-04-01"	"2023-05-02"



select oper,oper_g,BENEFITGROUP_CODE,BENEFIT_CODe,*  from rawdl2m.l2_prig_main where oper!='O' limit 100


select term_dor,oper,oper_g,count(*),min(REQUEST_DATE),max(REQUEST_DATE) from zzz_rawdl2.l2_prig_main where yyyymm=202304 and term_dor='О' group by 1,2,3 -- 4231301	"2023-02-01"	"2023-03-02"
/*
"О"	"O"	"G"	63
"О"	"O"	"N"	4364979
"О"	"O"	"O"	179
*/


------- парыпродажа-гашение 
select term_dor,oper,oper_g,count(*),min(REQUEST_DATE),max(REQUEST_DATE) from rawdl2m.l2_prig_main group by 1,2,3 
--"О"	"O"	"G"	2
--"О"	"O"	"N"	3952319
--"О"	"O"	"O"	3

select * from rawdl2m.l2_prig_main where oper_g='G' and term_dor='О'


select kodbl,oper,oper_g,* from rawdl2m.l2_prig_main where KODBL  IN ('О   01857302302083','О   01913892302083') order by 1,2,3,id

---------------------------------
select oper,oper_g,* from rawdl2m.l2_pass_main where no_use='1' limit 100 -- 4231301	"2023-02-01"	"2023-03-02"

select oper,oper_g,* from rawdl2m.l2_prig_main where no_use='1' limit 100 -- 4231301	"2023-02-01"	"2023-03-02"





---- МАРШРУТЫ РАССТОЯНИЯ
SELECT * FROM nsi.passkm_estimate_for_gos_and_dor('0001Э','А','2023-03-01',2,'2000001','2000002')
union all
SELECT * FROM nsi.passkm_estimate_for_gos_and_dor('0001Э','А','2023-03-01',2,'2000001')
union all
SELECT * FROM nsi.passkm_estimate_for_gos_and_dor('0001Э','А','2023-03-01',2);  


SELECT * FROM nsi.passkm_estimate_for_stan_dcs_sf ('0001Э','А','2023-03-01',4,'2000001','2000002');    



SELECT * FROM nsi.passkm_estimate_for_gos_and_dor('0001Э','А','2023-03-01',1,'2000001','2000002')
union all
SELECT * FROM nsi.passkm_estimate_for_gos_and_dor('0001Э','А','2023-03-01',2,'2000001','2000002')
union all
SELECT * FROM nsi.passkm_estimate_for_gos_and_dor('0001Э','А','2023-03-01',3,'2000001','2000002')
union all
SELECT * FROM nsi.passkm_estimate_for_gos_and_dor('0001Э','А','2023-03-01',4,'2000001','2000002')
union all
SELECT * FROM nsi.passkm_estimate_for_gos_and_dor('0001Э','А','2023-03-01',5,'2000001','2000002')
union all
SELECT * FROM nsi.passkm_estimate_for_gos_and_dor('0001Э','А','2023-03-01',6,'2000001','2000002')


-------- БИЛЕТЫ С ПУСТОЙ СЕРИЕЙ
ticket

select id,ticket_ser,ticket_num,to_char(ticket_num,'fm0000000') as ticket,* from zzz_rawdl2.l2_prig_main where ticket_ser is null and yyyymm=202304 
and id  between 2322049856 and 2339353701 and term_dor='М' limit 10


select distinct date_zap,min_id,max_id from l3_mes.prig_times where shema='mon_prig' and min_id  is not null


select id,ticket_ser,ticket_num,to_char(ticket_num,'fm0000000') as ticket,* from zzz_rawdl2.l2_prig_main where ticket_ser is null and yyyymm=202304 
and id  between 2322049856 and 2339353701  limit 10

-----------


select * from l3_mes.prig_times where oper in('dann','dannie')



select list,count(*) from l3_mes.prig_lgot_reestr where yymm=2304 and deleted='1' group by 1




--- НАДО - ПРОВЕРИТЬ КАК ОБРАБАТЫВАЮТСЯ ПРОДАЖИ И ВОЗВРАТЫ АБОНЕМЕНТОВ, ОДИНАКОВЫЕ ЛИ МАРШРУТЫ (РАЗБИВКИ ДЕНЕГ)???


select kodbl,date_zap,request_num,id,p16,p18,p27,p28,* from l3_mes.prig_lgot_reestr where deleted='1' order by kodbl --and list='R064G' order by ticket
limit 100


---- СЛИШКОМ МНОГО ЗАПИСЕ НА 1 КОДБЛАНКА!!! 25 И 18 ШТУК

select * from (select count(*) over(partition by kodbl) as kol,* from l3_mes.prig_lgot_reestr where deleted='0' and yymm=2304) as a
where kol>1 order by -kol,kodbl --and list='R064G' order by ticket
limit 100

---- СЛИШКОМ МНОГО ЗАПИСЕ НА 1 КОДБЛАНКА!!! 25 И 18 ШТУК

select count(*) over(partition by kodbl),* from l3_mes.prig_lgot_reestr where kodbl in('М   02229032304203','М   03931152304243','ОСИ 00949922304041') order by kodbl


select count(*) over(partition by kodbl),* from l3_mes.prig_lgot_reestr where kodbl in('М   03931152304243') order by kodbl

"М   03931152304243"
-- 'М   02229032304203','М   03931152304243'

select distinct list,id from l3_mes.prig_lgot_reestr where kodbl in('М   03931152304243') 



select cast(BENEFIT_CODE as dec(5)) as kod_lgt,* from zzz_rawdl2.l2_prig_main where id in(2377730195,2380829084,2383627008)





---- СЛИШКОМ МНОГО ЗАПИСЕ НА 1 КОДБЛАНКА!!! а есть ли с возвратами?

select * from 
(select count(*) over(partition by kodbl) as kol,
 sum(case when p27<0 or  p28<0 then 1 else 0 end) over(partition by kodbl) as kolv,
 * from l3_mes.prig_lgot_reestr where deleted='0' and yymm=2304 and substr(list,2,3)='064') as a
where kol>1 and kolv>0 order by -kol,kodbl --and list='R064G' order by ticket
limit 100

------
select kodbl,p24,p16,p27,p28,* from l3_mes.prig_lgot_reestr where kodbl in('ИАЩB03276942304073') order by kodbl


select distinct list,id from l3_mes.prig_lgot_reestr where kodbl in('ИАЩB03276942304073') 


select cast(BENEFIT_CODE as dec(5)) as kod_lgt,kodbl,ticket_ser,ticket_num,* from zzz_rawdl2.l2_prig_main where id in(2334544593,2334544953,2334545877,2334546631,2334547020)









select list,count(*) as kol from l3_mes.prig_lgot_reestr where deleted='1' group by 1


select * from l3_mes.prig_bil limit 100



insert into l3_mes.prig_work (yymm,fio,ticket,rez,kol_bil)
with del as
(select yymm,list,ticket,kol from
(select yymm,list,ticket,count(*) as kol,sum(p27) as plata,sum(p28) as poteri,sum(p16) as kol_bil
from l3_mes.prig_lgot_reestr where yymm in(2304)
 group by 1,2,3) as a where kol=2*round(kol/2) and plata=0 and poteri=0 and kol_bil=0  )
select yymm,list,ticket,12 as rez,kol as kol_bil from del;

--2.АПДЕЙТ УДАЛЕНИЕ ПАР ПРОДАЖА-ВОЗВРАТ
update l3_mes.prig_lgot_reestr set deleted='1'  where (yymm,ticket,list) in (select yymm,ticket,fio from l3_mes.prig_work where rez=12);




with del as
(select ticket,date_zap,request_num,id,list from l3_mes.prig_lgot_reestr where deleted='1' and list in ('R064G','R064Z' )),
dell as
(select * from l3_mes.prig_itog where id in(select id from del)),
rez as
(select ticket,list,a.id,nom_bil,nom_mar,nom_dat from del as a,dell as b where a.id=b.id)
select * from
(select *,count(*) over (partition by ticket) as kol,
min(nom_mar) over (partition by ticket) as min_mar,max(nom_mar) over (partition by ticket) as max_mar
from rez) as a
where kol>1 and min_mar<max_mar
order by ticket





with del as
(select ticket,date_zap,request_num,id,list from l3_mes.prig_lgot_reestr where deleted='1' and list in ('R064G','R064Z' )),
dell as
(select distinct nom_mar from l3_mes.prig_itog where id in(select id from del)),
mar as
(select * from l3_mes.prig_mars where nom_mar in(select nom_mar from  dell) and d_plata is not null)
select * from mar order by nom_mar,nom


-- неудалённые пары с неполными суммами

with del as
(select * from l3_mes.prig_lgot_reestr where deleted='0' and yymm=2304 and p27<0),
dell as
(select *,count(*) over (partition by kodbl) as kol from l3_mes.prig_lgot_reestr where yymm=2304 and kodbl in (select kodbl from del))
--select * from dell where kol>1 order by kodbl limit 100
select * from
(select kodbl,p24 as ticket,p25,p26,p7,count(*) as kol,sum(p27) as plata,sum(p28) as poteri from dell group by 1,2,3,4,5) as a where kol>1 order by -kol limit 1000

--"Е   01865602304293"	"186560  "
--"ЖАЯB06483692304293"	"АЯ648369"	"2014130"	"2014026"
"ЖАЯB06483592304273"	"АЯ648359"	"2014130"	"2014373"	"3024"
"--######  "	577854
"--205810  "	70
"--190569  "	67


select * from l3_mes.prig_lgot_reestr where kodbl='ЖАЯB06483592304273' and p24='АЯ648359';












/**/