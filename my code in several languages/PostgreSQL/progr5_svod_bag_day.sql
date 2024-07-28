

select * from rawdl2_day.bag_main_day where id_bag_main_day in(561364,560048)
limit 100

--select * from rawdl2_day.svod_bag_main limit 100

select * from rawdl2_day.bag_priz_day where id_bag_main_day in(561364,560048)
limit 100

select * from rawdl2_day.bag_cost_day where id_bag_main_day in(561364,560048) limit 100

rawdl2_day.bag_main_day, rawdl2_day.bag_priz_day, rawdl2_day.bag_cost_day. 


select request_date,count(*) as kol from rawdl2_day.bag_main_day group by 1 limit 100




select max(kol) from
(select id_bag_main_day,count(*) as kol from rawdl2_day.bag_main_day where request_date='2023-03-22' group by 1) as a
--1

select max(kol) from
(select id_bag_main_day,count(*) as kol from rawdl2_day.bag_priz_day where request_date='2023-03-22' group by 1) as a
--4

select * from
(select id_bag_main_day,count(*) as kol from rawdl2_day.bag_cost_day where request_date='2023-03-22' group by 1) as a
where kol=6
id_bag_main_day=559009
--6

select * from
(select id_bag_priz_day,count(*) as kol from rawdl2_day.bag_cost_day where request_date='2023-03-22' group by 1) as a
where kol=4
--4
id_bag_priz_day in (577198,576355,576420,576186,577304,576187,576341,576618,576143)





select carr_kind,* from rawdl2_day.bag_main_day where id_bag_main_day=559009

select flg_category_gd,* from rawdl2_day.bag_priz_day where id_bag_main_day=559009

select sum_code,paymenttype,* from rawdl2_day.bag_cost_day where id_bag_main_day=559009

sum_code


select tarif_cost,mileage,* from rawdl2_day.bag_priz_day where id_bag_main_day=369398

select * from
(select id_bag_main_day,count(*) as kol from rawdl2_day.bag_priz_day where mileage<0 group by 1) as a
where kol=2 limit 10




select distinct carr_kind from rawdl2_day.bag_priz_day order by 1

select * --distinct kol,kk 
from
(select id_bag_priz_day,
sum(case when sum_code in(113, 116, 118) and paymenttype in('С','Ж') then 1 else 0 end) as kk,count(*) as kol
 from rawdl2_day.bag_cost_day group by 1) as a where kol=2 and kk=1
 and id_bag_priz_day in(select id_bag_priz_day from rawdl2_day.bag_priz_day where flg_category_gd='1')
 limit 10


430152

select * from rawdl2_day.bag_main_day where id_bag_main_day=558328

select flg_category_gd,tarif_cost,* from rawdl2_day.bag_priz_day where id_bag_main_day=558328

select * from rawdl2_day.bag_cost_day where id_bag_main_day=558328



select 
case when sum_code in(113, 116, 118) and paymenttype='С' then sum_nde else  0 end as pot1,
case when sum_code in(113, 116, 118) and paymenttype='Ж' then sum_nde else  0 end as pot2,
sum_code,paymenttype,sum_nde,* from rawdl2_day.bag_cost_day where id_bag_priz_day=430152



-------------------------------------------------------------------------------------------


with
main as (select * from rawdl2_day.bag_main_day where request_date='2023-03-22'),
priz as (select id_bag_main_day,id_bag_priz_day,sale_station,carriage_type,place_qty,passqty,
	carriage_qty,weight,tarif_cost,flg_category_gd,mileage,cargo_turn,distance,carr_kind,registration_method,
	flg_forcedinput,flg_pkh,flg_carriagerepairs,flg_animals,flg_carriagepass,flg_car,flg_handluggage
	from rawdl2_day.bag_priz_day where request_date='2023-03-22'),
cost as (select id_bag_priz_day,
	sum(case when sum_code in(113, 116, 118) and paymenttype='С' then sum_nde else  0 end) as pot1,
	sum(case when sum_code in(113, 116, 118) and paymenttype='Ж' then sum_nde else  0 end) as pot2
		 from rawdl2_day.bag_cost_d+ay where request_date='2023-03-22' group by 1),

itog as
(select m.id_bag_main_day,
yyyy,mm,term_gos,term_dor,shipment_type,
extract(month from departure_date) as departure_month,
extract(month from traindep_date) as traindep_month ,
sale_station,carriage_type,carrier_gos,carrier_code,agent_code,train_speed,
p.place_qty,p.passqty,p.carriage_qty,p.weight,p.tarif_cost as tarif_cost_pl,
pot1+(case when flg_category_gd='1' then pot2 else 0 end) as tarif_cost_poter,
p.mileage,p.cargo_turn,p.distance,
departure_dor,destination_dor,train_num,train_thread,departure_station,arrival_station,carr_kind,
registration_method,flg_forcedinput,flg_pkh,flg_carriagerepairs,flg_animals,flg_carriagepass,flg_car,
flg_handluggage,flg_speckupe,carriage_kind,military_code,
extract(year from departure_date) as god_op,
--0 as flg_gd, --флаг работник ЖД
case when flg_category_gd ='1' and carrier_code in ('0','40') then '0'     
     when flg_category_gd ='1' and carrier_code='1' then '1' 
     when flg_category_gd ='2' and carrier_code in ('0','40') then '1'      
     when p.flg_category_gd ='2' and m.carrier_code='1' then '0' else '' end flg_gd,
carriageserv_dor

from main as m join priz as p on m.id_bag_main_day=p.id_bag_main_day
join cost as c on /*m.id_bag_main_day=c.id_bag_main_day and*/ p.id_bag_priz_day=c.id_bag_priz_day)

select * from itog where tarif_cost_pl!=0 order by 1
limit 10





-----------------------------------------------------------






--select count(*) from l3_mes.prig_analit;









select count(*) as kol,min(request_date),max(request_date) from zzz_rawdl2.l2_prig_main

select count(*) as kol,min(request_date),max(request_date) from zzz_rawdl2.l2_pass_main


--353 247 665
--408 895 453	"2022-07-01"	"2023-10-16"

select count(*) as kol,min(request_date),max(request_date) from zzz_rawdl2.l2_bag_main
--3 176 141	"2022-07-01"	"2023-10-16"









/**/