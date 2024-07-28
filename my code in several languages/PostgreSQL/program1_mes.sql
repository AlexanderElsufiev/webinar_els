
----- ПРИ СБОЕ ТАБЛИЦ ПИСАТЬ ШИРМАН ЕЛЕНЕ ПАВЛОВНЕ!


--скрипт на создание новой схемы, куда будут писаться результаты всех пригородных вычислений
  --     CREATE SCHEMA l3_mes AUTHORIZATION asul;

/*  
 DROP TABLE l3_mes.prig_bileti;
 DROP TABLE l3_mes.prig_bileti_using;
 DROP TABLE l3_mes.prig_comp;
 DROP TABLE l3_mes.prig_comp_lin;
 DROP TABLE l3_mes.prig_unikod;
 DROP TABLE l3_mes.prig_prognoz;
 DROP TABLE l3_mes.prig_prognoz_date;

  --drop SCHEMA l3_mes ;
*/


/** /
DELETE FROM l3_mes.prig_times where dann='prig' ;
DELETE FROM l3_mes.prig_work;
 
 DELETE FROM l3_mes.prig_mars;
 DELETE FROM l3_mes.prig_dats;
 DELETE FROM l3_mes.prig_bil;
 DELETE FROM l3_mes.prig_bad;
 DELETE FROM l3_mes.prig_itog;
 delete from l3_mes.prig_lgot_reestr;
 delete from l3_mes.prig_lgot_stat; 
 delete from l3_mes.prig_analit;
 DELETE FROM l3_mes.prig_peregoni; --
 DELETE FROM l3_mes.prig_agr_kst;
 DELETE FROM l3_mes.prig_agr_pereg;
 
 delete from l3_mes.prig_co22_t0;
delete from l3_mes.prig_co22_t1;
delete from l3_mes.prig_co22_t2;
delete from l3_mes.prig_co22_t3;
delete from l3_mes.prig_co22_t4;
delete from l3_mes.prig_co22_t5;
delete from l3_mes.prig_co22_t6;
/ **/


/*УДАЛЕНИЕ ПО СВОДАМ - ТАБЛИЦЫ НЕ МОИ!* /
delete from l3_mes.prig_times where substr(dann,1,4)='svod';

delete from rawdl2_day.svod_pass_main;
delete from rawdl2_day.link_svod_pass_main;
delete from rawdl2_day.svod_pass_cost;

delete from rawdl2_day.svod_bag_main;
delete from rawdl2_day.link_svod_bag_main;
delete from rawdl2_day.svod_bag_cost;

delete from rawdl2_day.svod_krs;
delete from rawdl2_day.link_svod_krs;

delete from rawdl2_day.svod_meal;
delete from rawdl2_day.link_svod_meal;

delete from rawdl2_day.svod_cards;
delete from rawdl2_day.link_svod_cards;
/ **/




/*	*  /
 DROP TABLE l3_mes.prig_times;
 DROP TABLE l3_mes.prig_work;
 
 DROP TABLE l3_mes.prig_mars;
 DROP TABLE l3_mes.prig_dats;
 DROP TABLE l3_mes.prig_bil;
 DROP TABLE l3_mes.prig_bad;
 DROP TABLE l3_mes.prig_itog;
 --DROP TABLE l3_mes.prig_lgotniki;
 DROP TABLE l3_mes.prig_lgot_reestr;
 DROP TABLE l3_mes.prig_lgot_stat;
 DROP TABLE l3_mes.prig_analit;
 drop table l3_mes.prig_peregoni; --
 drop table l3_mes.prig_agr_kst;
 drop table l3_mes.prig_agr_pereg;
 
 -----СОЗДАНИЕ ТАБЛИЦ ОТЧЁТА ЦО-22
DROP TABLE l3_mes.prig_co22_t0;
DROP TABLE l3_mes.prig_co22_t1;
DROP TABLE l3_mes.prig_co22_t2;
DROP TABLE l3_mes.prig_co22_t3;
DROP TABLE l3_mes.prig_co22_t4;
DROP TABLE l3_mes.prig_co22_t5;
DROP TABLE l3_mes.prig_co22_t6;
/ *  */


/*
delete from  l3_mes.prig_times;
delete from  l3_mes.prig_work;
delete from  l3_mes.prig_itog;

delete from  l3_mes.prig_dats;

/ **/

-- select *  from l3_mes.prig_lgot_reestr limit 100;

-- ДОБАВЛЕНИЕ НОВОГО ПОЛЯ -- Alter table l3_prig.prig_lgot_reestr  Add column porcia dec(3);

  

---------------СОЗДАНИЕ ТАБЛИЦЫ НУЖНЫХ ДАТ----------------
	
CREATE TABLE l3_mes.prig_times
(date date,time char(12),time2 numeric,dann char(20),oper char(20),date_zap date,part_zap dec(7),rezult bigint,
 min_id bigint,max_id bigint,min_id_svod bigint,max_id_svod bigint,shema char(20),libr char(20),itog char(8),yyyymm dec(7) ) TABLESPACE pg_default;
 ALTER TABLE l3_prig.prig_times OWNER to asul;
GRANT ALL ON TABLE l3_prig.prig_times TO asul;



----------------БЛОК ЗАПОЛНЕНИЯ ДАТ ДЛЯ ЧТЕНИЯ МЕСЯЧНЫЕ (ОКТЖД)--------------

delete from l3_mes.prig_times where dann='prig' and oper in('dann','dannie','dann1');

-- select * from l3_mes.prig_times where dann='prig' and oper in('dann','dannie','dann1');

/** /
-----Все дороги вместе
--МЕСЯЧНАЯ БАЗА пригородная
insert into  l3_mes.prig_times(dann,oper,date_zap,rezult,min_id,max_id,shema,libr)
 select distinct 'prig' as dann,'dann1' as oper,date_zap,rezult,min_id,max_id,'mon_prig' as shema,'zzz_rawdl2' as libr from 
 (select REQUEST_DATE as date_zap,count(*) as rezult,min(idnum) as min_id,max(idnum) as max_id
  from zzz_rawdl2.l2_prig_main where REQUEST_DATE>='2023-04-01' and REQUEST_DATE<='2023-05-05' -- and id=2395584551
 group by 1) as a 
    order by date_zap;
	
/**/   -- месячная база  пассажирская
insert into  l3_mes.prig_times(dann,oper,date_zap,rezult,min_id,max_id,shema,libr)
 select distinct 'prig' as dann,'dann1' as oper,date_zap,rezult,min_id,max_id,'mon_pass','zzz_rawdl2' as libr from 
 (select REQUEST_DATE as date_zap,count(*) as rezult,min(idnum) as min_id,max(idnum) as max_id
  from zzz_rawdl2.l2_pass_main where REQUEST_DATE>='2023-04-01' and REQUEST_DATE<='2023-05-05' -- and id=2395584551
  group by 1) as a 
  order by date_zap;
/ **/   
   
   
   
   
   
   
   
/*   
----Только ОктЖД
--МЕСЯЧНАЯ БАЗА пригородная
insert into  l3_mes.prig_times(dann,oper,date_zap,rezult,min_id,max_id,shema,libr,yyyymm)
 select distinct 'prig' as dann,'dann1' as oper,date_zap,rezult,min_id,max_id,'mon_prig' as shema,'rawdl2m' as libr,yyyymm from 
 (select REQUEST_DATE as date_zap,count(*) as rezult,min(idnum) as min_id,max(idnum) as max_id,min(yyyymm) as yyyymm
  from rawdl2m.l2_prig_main --where REQUEST_DATE>='2023-04-01' and REQUEST_DATE<='2023-05-05' -- and id=2395584551
 group by 1) as a 
    order by date_zap;
	
/**/   -- месячная база  пассажирская
insert into  l3_mes.prig_times(dann,oper,date_zap,rezult,min_id,max_id,shema,libr,yyyymm)
 select distinct 'prig' as dann,'dann1' as oper,date_zap,rezult,min_id,max_id,'mon_pass','rawdl2m' as libr,yyyymm from 
 (select REQUEST_DATE as date_zap,count(*) as rezult,min(idnum) as min_id,max(idnum) as max_id,min(yyyymm) as yyyymm
  from rawdl2m.l2_pass_main --where REQUEST_DATE>='2023-04-01' and REQUEST_DATE<='2023-05-05' -- and id=2395584551
  group by 1) as a 
  order by date_zap;
*/      
	  
	  

	  
/** /	  
---- СУТОЧНАЯ БАЗА
--СУТОЧНАЯ БАЗА пригородная
insert into  l3_mes.prig_times(dann,oper,date_zap,rezult,min_id,max_id,shema,libr)
 select distinct 'prig' as dann,'dann1' as oper,date_zap,rezult,min_id,max_id,'sut_prig' as shema,'rawdl2s' as libr from 
 (select REQUEST_DATE as date_zap,count(*) as rezult,min(idnum) as min_id,max(idnum) as max_id
  from rawdl2s.l2_prig_main --where REQUEST_DATE>='2023-04-01' and REQUEST_DATE<='2023-05-05' -- and id=2395584551
 group by 1) as a 
    order by date_zap;
	
/**/   -- СУТОЧНАЯ БАЗА  пассажирская
insert into  l3_mes.prig_times(dann,oper,date_zap,rezult,min_id,max_id,shema,libr)
 select distinct 'prig' as dann,'dann1' as oper,date_zap,rezult,min_id,max_id,'sut_pass','rawdl2s' as libr from 
 (select REQUEST_DATE as date_zap,count(*) as rezult,min(idnum) as min_id,max(idnum) as max_id
  from rawdl2s.l2_pass_main --where REQUEST_DATE>='2023-04-01' and REQUEST_DATE<='2023-05-05' -- and id=2395584551
  group by 1) as a 
  order by date_zap;
  
/ **/      
	  
   
   
   

--ЧАСТЬ 0. постановка информации о том, из каких таблиц читать
--ПО ПРИГОРОДУ
insert into l3_mes.prig_times(dann,shema,libr,itog,oper)
	values('prig','mon_pass','rawdl2m','table','l2_pass_main');
insert into l3_mes.prig_times(dann,shema,libr,itog,oper)
	values('prig','sut_pass','rawdl2s','table','l2_pass_main');
insert into l3_mes.prig_times(dann,shema,libr,itog,oper)
	values('prig','sut_prig','rawdl2s','table','l2_prig_main');
insert into l3_mes.prig_times(dann,shema,libr,itog,oper)
	values('prig','mon_prig','rawdl2m','table','l2_prig_main');
insert into l3_mes.prig_times(dann,shema,libr,itog,oper)
	values('prig','dan_prig','rawdl2','table','l2_prig_main');
insert into l3_mes.prig_times(dann,shema,libr,itog,oper)
	values('prig','dan_pass','rawdl2','table','l2_pass_main');
	
--ПО СВОДАМ	
insert into l3_mes.prig_times(dann,shema,libr,itog,oper)
	values('svod_bag','mes','rawdl2m','table','l2_bag_main');
insert into l3_mes.prig_times(dann,shema,libr,itog,oper)
	values('svod_pas','mes','rawdl2m','table','l2_pass_main');
insert into l3_mes.prig_times(dann,shema,libr,itog,oper)
	values('svod_krs','mes','rawdl2m','table','l2_krs');
insert into l3_mes.prig_times(dann,shema,libr,itog,oper)
	values('svod_meal','mes','rawdl2m','table','l2_meal');
insert into l3_mes.prig_times(dann,shema,libr,itog,oper)
	values('svod_card','mes','rawdl2m','table','l2_cards');


   
   
   
   
-- delete from    l3_mes.prig_times where shema= 'mon_prig'; 
-- select * from    l3_mes.prig_times where dann= 'prig' and part_zap>40 order by part_zap,date_zap,time; 
   
   
--select * from  l3_mes.prig_times where dann= 'prig' and oper in('read','read_analit','write_analit') order by shema,part_zap,date_zap,time;    

   
/**/



--select * from l3_mes.prig_times where 2395584551 between min_id and max_id








--           select * from l3_mes.prig_times where dann='prig'  order by date_zap,part_zap,oper;

--  delete from l3_mes.prig_times where oper='dann1' and (date_zap,shema) in(select  date_zap,shema from l3_mes.prig_times where oper='read')




-------------------------------------СОЗДАНИЕ РАБОЧЕЙ ТАБЛИЦЫ ВРЕМЕННЫХ ДАННЫХ ---------------

CREATE TABLE l3_mes.prig_work
(
	rez dec(3),opis bigint,idnum bigint,request_num dec(7),yymm smallint,
	k_bil dec(7),nom_mar dec(7),nom_bil dec(7),nom_dat dec(7),
    date_zap date,time_zap char(10),server_reqnum char(10),drac char(10),part_zap dec(7),date_beg date,date_end date,date_pr date,	
    term_dor character(1),term_pos character(3),term_trm char(2),	
	agent smallint,subagent smallint,chp smallint,stp dec(7),stp_reg smallint,
	kol_bil dec(7),plata dec(11),poteri dec(11),perebor dec(11),nedobor dec(11),kom_sbor dec(11),kom_sbor_vz dec(11),
	k_pas smallint,srok_bil smallint,srok_mon smallint,oper char(1),oper_g char(1),flg_bag char(1),FLG_tuda_obr char(1),flg_rab_day char(1),flg_ruch char(1),
	vid_rasch char(1),FLG_CHILD char(1),flg_voin smallint,FLG_MILITARY char(1),
	flg_lgt char(1),FLG_BSP char(1),FLG_SO char(1),FLG_NU char(1),FLG_TT char(1),
	klass  char(2),kod_lgt smallint,lgt_reg smallint,bag_vid char(1),bag_ves smallint,proc_lgt smallint,rzd_fpk char(1),
	--rzd_fpk = признак железнодорожник РЖД = 0 или ФПК =5, ПРОЧЕЕ=0, берётся как 3-й символ билетной группы (bilgroup char(5) )
	ABONEMENT_TYPE character(3),ABONEMENT_SUBTYPE char(1),FLG_OFFICIAL_BENEFIT char(1),TRAIN_CATEGORY char(1),TRAIN_NUM char(5),employee_cat char(1), 
	--employee_cat = шифр категории пассажира
	--ABONEMENT_SUBTYPE = Подтип абонемента на кокретные даты (1- на нечет.дни, 2 - на четн.дни) 
	--FLG_OFFICIAL_BENEFIT = Признак "Льгота РЖД по служебным надобностям"
	flg_sbor char(4),flg_bil_sbor char(1),request_type smallint,request_subtype smallint,web_id char(4),		
	prod char(1),Plus_dat Dec(3),Kpas_day Dec(3), --эти 2 поля избыточны, заполняются из других	
	sto dec(7),stn dec(7),srasst smallint,sto_zone dec(3),stn_zone  dec(3),sti dec(7),sti_zone dec(3),
	sto_reg smallint,stn_reg smallint,nom smallint,reg smallint,marshr dec(7),
	st1 dec(7),st2 dec(7),rst dec(3),dor smallint,lin smallint,mcd smallint, 	
	d_plata dec(11),d_poteri dec(11),otd dec(3),dcs dec(5),
	
	
	--sf_pas dec(7),kol_pas dec(7),pass_km dec(9),otpr_pas dec(7),prib_pas dec(7),	
	--peregon dec(7),  тоже здесь не нужно!
	fio char(45),fio_2 char(20),snils char(11),ticket char(10),kodbl char(18),benefit_doc char(14),benefit_podr char(10),bilgroup char(5)  --поля для реестра льгнотников
	)
TABLESPACE pg_default;
ALTER TABLE l3_mes.prig_work OWNER to asul;
GRANT ALL ON TABLE l3_mes.prig_work TO asul;




CREATE TABLE l3_mes.prig_mars
(
	nom_mar dec(7),sto dec(7),stn dec(7),srasst smallint,sto_zone dec(3),stn_zone  dec(3),sti dec(7),sti_zone dec(3),
	nom smallint,reg smallint,marshr dec(7),mcd smallint,st1 dec(7),st2 dec(7),rst dec(3),dor smallint,lin smallint,
	d_plata dec(13),d_poteri dec(13),otd dec(3),dcs dec(5),peregon dec(7),
	idnum bigint,date_zap date,part_zap dec(7) --для удобства расследований
) TABLESPACE pg_default;
ALTER TABLE l3_mes.prig_mars OWNER to asul;
GRANT ALL ON TABLE l3_mes.prig_mars TO asul;

CREATE INDEX l3_mes_prig_mars_ind ON l3_mes.prig_mars (nom_mar)  TABLESPACE pg_default;



CREATE TABLE l3_mes.prig_dats --справочник расписки дат поездок относительно даты начала действия билета
(nom_dat dec(7),plus_dat integer,kpas_day dec(3),
 idnum bigint,date_zap date,part_zap dec(7) --для удобства расследований
) TABLESPACE pg_default;
ALTER TABLE l3_mes.prig_dats OWNER to asul;
GRANT ALL ON TABLE l3_mes.prig_dats TO asul;

CREATE INDEX l3_mes_prig_dats_ind ON l3_mes.prig_dats (nom_dat)  TABLESPACE pg_default;


CREATE TABLE l3_mes.prig_bil
(
	nom_bil dec(7),	
	k_pas smallint,srok_bil smallint,srok_mon smallint,oper char(1),oper_g char(1),flg_bag char(1),FLG_tuda_obr char(1),flg_rab_day char(1),	
	flg_ruch char(1),request_type smallint,request_subtype smallint,web_id char(4),	
	vid_rasch char(1),FLG_CHILD char(1),flg_voin smallint,FLG_MILITARY char(1),
	flg_lgt char(1),FLG_BSP char(1),FLG_SO char(1),FLG_NU char(1),FLG_TT char(1),	
	klass  char(2),kod_lgt smallint,lgt_reg smallint,bag_vid char(1),bag_ves smallint,proc_lgt smallint,rzd_fpk char(1),
	--rzd_fpk = признак железнодорожник РЖД = 0 или ФПК =5, ПРОЧЕЕ=0, берётся как 3-й символ билетной группы
	ABONEMENT_TYPE character(3),ABONEMENT_SUBTYPE char(1),FLG_OFFICIAL_BENEFIT char(1),TRAIN_CATEGORY char(1),/*TRAIN_NUM char(5),*/employee_cat char(1),	
	grup_lgt smallint,prod char(1),flg_sbor char(4),flg_bil_sbor char(1),
	date_zap date,part_zap dec(7),idnum bigint --для удобства расследований
	)
TABLESPACE pg_default;
ALTER TABLE l3_mes.prig_bil OWNER to asul;
GRANT ALL ON TABLE l3_mes.prig_bil TO asul;
/* 
flg_voin=(0,1,3,5)
flg_bsp=бесплатные
FLG_SO=сторонние организации
FLG_NU = негос учреждения
FLG_TT= трансп требования
	klass =(1,2,3)
	kod_lgt smallint,lgt_reg smallint,bag_vid char(1),bag_ves smallint,proc_lgt smallint,ABONEMENT_TYPE character(3),
	TRAIN_CATEGORY =("7","А","Г","Л","О","С") char(1),
	TRAIN_NUM char(5),grup_lgt smallint,date_zap date,
*/

CREATE INDEX l3_mes_prig_bil_ind ON l3_mes.prig_bil (nom_bil)  TABLESPACE pg_default;




CREATE TABLE l3_mes.prig_bad
(
	marshr dec(7), st1 dec(7),st2 dec(7),rst dec(3),reg smallint,dor smallint,lin smallint,date_zap date,part_zap dec(7),idnum bigint
) TABLESPACE pg_default;
ALTER TABLE l3_mes.prig_bad OWNER to asul;
GRANT ALL ON TABLE l3_mes.prig_bad TO asul;




--Таблица обогащения пригорода
CREATE TABLE l3_mes.prig_itog
(
	idnum bigint,request_num dec(7),yymm smallint,k_bil dec(7),nom_mar dec(7),nom_bil dec(7),nom_dat dec(7),date_zap date,part_zap dec(7),
	date_beg date,date_end date,date_pr date,TERM_DOR character(1),term_pos character(3),term_trm char(2),
	agent smallint,subagent smallint,chp smallint,stp dec(7),stp_reg smallint,TRAIN_NUM char(5),kol_bil dec(7),
	plata dec(11),poteri dec(11),perebor dec(11),nedobor dec(11),kom_sbor dec(11),kom_sbor_vz dec(11)
	
	)
TABLESPACE pg_default;
ALTER TABLE l3_mes.prig_itog OWNER to asul;
GRANT ALL ON TABLE l3_mes.prig_itog TO asul;


CREATE INDEX l3_mes_prig_itog_indp ON l3_mes.prig_itog (part_zap)  TABLESPACE pg_default;
CREATE INDEX l3_mes_prig_itog_indd ON l3_mes.prig_itog (yymm,date_zap)  TABLESPACE pg_default;



--Таблица по льготникам новая
CREATE TABLE l3_mes.prig_lgot_reestr
(	yymm smallint,date_zap date,part_zap dec(7),request_num dec(7),idnum bigint,list char(5),/*ticket char(10),*/kodbl char(18),
	p1 dec(7),p2 char(3),p3 char(2),p4 char(1),p5 char(1),p6 char(1),p7 char(4),
	p8 char(4),p9 char(5),p10 char(14),p11 char(5),p12 char(10),p13 char(1),p14 char(45),p15 char(20),p16 dec(3),
	p17 char(1),p18 char(3),p19 dec(3),p20 char(1),p21 char(2),p22 char(6),p23 char(6),p24 char(8),p25 char(7),p26 char(7),
	p27 dec(9,2),p28 dec(9,2),p29 char(5),p30 char(10),p31 char(7),p32 char(11),p33 dec(3),deleted char(1)
	)
TABLESPACE pg_default;
ALTER TABLE l3_mes.prig_lgot_reestr OWNER to asul;
GRANT ALL ON TABLE l3_mes.prig_lgot_reestr TO asul;

-----------НОВОЕ!!!
CREATE INDEX l3_mes_prig_lgot_reestr_indm ON l3_mes.prig_lgot_reestr (yymm,date_zap,part_zap)  TABLESPACE pg_default;
CREATE INDEX l3_mes_prig_lgot_reestr_indp ON l3_mes.prig_lgot_reestr (part_zap)  TABLESPACE pg_default;



-- Alter table l3_prig.prig_lgot_reestr  Add column porcia dec(3);




--Таблица контрольных сумм по реестру льгот
CREATE TABLE l3_mes.prig_lgot_stat
(	yymm smallint,list char(5),dor char(3),kol_zap integer,kol_del integer,kol_raz integer,kol_abon integer,kol_ab_k integer,
 plata dec(13,2),poteri dec(13,2),kol_porc dec(5),date_zap date
 )
TABLESPACE pg_default;
ALTER TABLE l3_mes.prig_lgot_stat OWNER to asul;
GRANT ALL ON TABLE l3_mes.prig_lgot_stat TO asul;

-----------НОВОЕ!!!
CREATE INDEX l3_mes_prig_lgot_stat_ind ON l3_mes.prig_lgot_stat (yymm)  TABLESPACE pg_default;

-----------------------------------------------------

--Таблица агрегатов аналитическая
CREATE TABLE l3_mes.prig_analit
(YYMM smallint,date_zap date,part_zap dec(7),date date,TERM_DOR char(1),agent smallint,chp smallint,reg smallint,par_name char(10),
 anal_rasch char(7),anal_vid_bil char(9),anal_oper char(1),train_category char(1),
 kol_bil dec(13),plata dec(13),poteri dec(13),kol_pas dec(13),pass_km dec(13)
 	)
TABLESPACE pg_default;
ALTER TABLE l3_mes.prig_analit OWNER to asul;
GRANT ALL ON TABLE l3_mes.prig_analit TO asul;


---====================================================================================



	
	
	

CREATE TABLE l3_mes.prig_peregoni
(peregon dec(7),dor smallint,lin smallint,st1 dec(7),st2 dec(7),name char(50),rasst dec(5),date_zap date,part_zap dec(7)
) TABLESPACE pg_default;
ALTER TABLE l3_mes.prig_peregoni OWNER to asul;
GRANT ALL ON TABLE l3_mes.prig_peregoni TO asul;

	
CREATE INDEX l3_mes_prig_peregoni_ind ON l3_mes.prig_peregoni (peregon)  TABLESPACE pg_default;	
	
	
/**/
--    Таблица агрегатов по перегонам
CREATE TABLE l3_mes.prig_agr_pereg
(	date_zap date,part_zap dec(7),YYMM smallint,TERM_DOR char(1),nom_bil dec(7),prod char(1),date date,agent smallint,chp smallint,reg smallint,
	dor smallint,lin smallint,otd dec(3),dcs dec(5),st1 dec(7),st2 dec(7),rst smallint,peregon dec(7),par_name char(8),
	plata dec(11),poteri dec(11),per_pas dec(7),pass_km dec(9),otpr_pas dec(7),prib_pas dec(7)	
	)
TABLESPACE pg_default;
ALTER TABLE l3_mes.prig_agr_pereg OWNER to asul;
GRANT ALL ON TABLE l3_mes.prig_agr_pereg TO asul;


--Таблица агрегатов останционных
CREATE TABLE l3_mes.prig_agr_kst
(	date_zap date,part_zap dec(7),YYMM smallint,TERM_DOR char(1),/*term_pos char(3),term_trm char(2),*/nom_bil dec(7),date date,
 	agent smallint,chp smallint,kst dec(7),reg smallint,	
	FLG_CHILD char(1),FLG_MILITARY char(1),kod_lgt smallint,ABONEMENT_TYPE character(3),prod char(1),
	--dor smallint,lin smallint,predpr smallint,
	par_name char(10),kol_bil dec(11),plata dec(11),poteri dec(11),kol_pas dec(11),pass_km dec(11)
	)
TABLESPACE pg_default;
ALTER TABLE l3_mes.prig_agr_kst OWNER to asul;
GRANT ALL ON TABLE l3_mes.prig_agr_kst TO asul;
/**/
	
	
	

--  select * from  l3_mes.prig_analit

	
	
	
----------------------------------------------------------------------------------------------------------------	
	
	
	
	
/**/	
	