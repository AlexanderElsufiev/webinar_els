
----- ПРИ СБОЕ ТАБЛИЦ ПИСАТЬ ШИРМАН ЕЛЕНЕ ПАВЛОВНЕ!
--abd->schemas->svod

--скрипт на создание новой схемы, куда будут писаться результаты всех пригородных вычислений
--  CREATE SCHEMA l3_prig AUTHORIZATION asul;


/** /
DELETE FROM l3_prig.prig_times;
DELETE FROM l3_prig.prig_work;
 
 DELETE FROM l3_prig.prig_mars;
 DELETE FROM l3_prig.prig_dats;
 DELETE FROM l3_prig.prig_bil;
 DELETE FROM l3_prig.prig_bad;
 DELETE FROM l3_prig.prig_itog;
 --DELETE FROM l3_prig.prig_lgotniki;
 delete from  l3_prig.prig_lgot_reestr;
 delete from  l3_prig.prig_lgot_stat; 
 delete from l3_prig.prig_analit;
 DELETE FROM l3_prig.prig_peregoni; --
 --DELETE FROM l3_prig.prig_agr_kst;
 --DELETE FROM l3_prig.prig_agr_pereg;
/ **/

/*	*  /
 DROP TABLE l3_prig.prig_times;
 DROP TABLE l3_prig.prig_work;
 
 DROP TABLE l3_prig.prig_mars;
 DROP TABLE l3_prig.prig_dats;
 DROP TABLE l3_prig.prig_bil;
 DROP TABLE l3_prig.prig_bad;
 DROP TABLE l3_prig.prig_itog;
 --DROP TABLE l3_prig.prig_lgotniki;
 DROP TABLE l3_prig.prig_lgot_reestr;
 DROP TABLE l3_prig.prig_lgot_stat;
 DROP TABLE l3_prig.prig_analit;
 drop table l3_prig.prig_peregoni; --
 --drop table l3_prig.prig_agr_kst;
 --drop table l3_prig.prig_agr_pereg;
/ *  */

/*
delete from  l3_prig.prig_times;
delete from  l3_prig.prig_work;
delete from  l3_prig.prig_itog;

delete from  l3_prig.prig_dats;

/ **/


--select *  from l3_prig.prig_lgot_reestr limit 100;



/*
CREATE INDEX IF NOT EXISTS l2_pass_main_ind0
    ON rawdl2.l2_pass_main USING btree
    (request_date ASC NULLS LAST, request_num ASC NULLS LAST, term_dor COLLATE pg_catalog."default" ASC NULLS LAST)
    TABLESPACE pg_default;
	
Посмотреть индексы - На таблицу встаёшь, и выбираешь вкладку SQL. В конце скрипта будут индексы.	
	
	
	CREATE INDEX l2_prig_main_ind0
    ON rawdl2.l2_prig_main USING btree
    (kodbl COLLATE pg_catalog."default" ASC NULLS LAST)
    TABLESPACE pg_default;
	
	CREATE INDEX l2_prig_main_indid
    ON rawdl2.l2_prig_main USING btree
    (id ASC NULLS LAST, doc_num ASC NULLS LAST)
    TABLESPACE pg_default;
	
	ALTER TABLE rawdl2.l2_prig_main
    ADD CONSTRAINT l2_prig_main_pkey PRIMARY KEY (idnum);
	
*/




---------------СОЗДАНИЕ ТАБЛИЦЫ НУЖНЫХ ДАТ----------------
CREATE TABLE l3_prig.prig_times
(date date,time char(12),time2 numeric,dann char(20),oper char(20),date_zap date,part_zap dec(7),rezult bigint,
 min_id bigint,max_id bigint,min_id_svod bigint,max_id_svod bigint,shema char(20),libr char(20),itog char(8),yyyymm dec(7) ) TABLESPACE pg_default;
ALTER TABLE l3_prig.prig_times OWNER to asul;
GRANT ALL ON TABLE l3_prig.prig_times TO asul;



----------------БЛОК ЗАПОЛНЕНИЯ ДАТ ДЛЯ ЧТЕНИЯ МЕСЯЧНЫЕ (ОКТЖД)--------------

delete from l3_prig.prig_times where dann='prig' and oper in('dann','dannie','dann1');

--  select * from l3_prig.prig_times where dann='prig'

/** /
--МЕСЯЧНАЯ БАЗА пригородная
insert into  l3_prig.prig_times(dann,oper,date_zap,rezult,shema,libr)
 select distinct 'prig' as dann,'dann1' as oper,date_zap,rezult,'mon_prig' as shema,'rawdl2m' as libr from 
 (select REQUEST_DATE as date_zap,count(*) as rezult from rawdl2m.l2_prig_main where REQUEST_DATE>='2023-01-01'
 group by 1) as a 
 --where date_zap in('2023-02-04','2023-02-06','2023-02-11','2023-02-16','2023-02-12','2023-02-08','2023-02-09','2023-02-15','2023-02-10','2023-02-14','2023-02-13')
   order by date_zap;
/ ** /   -- месячная база  пассажирская
insert into  l3_prig.prig_times(dann,oper,date_zap,rezult,shema,libr)
 select distinct 'prig' as dann,'dann1' as oper,date_zap,rezult,'mon_pass','rawdl2m' as libr from 
 (select REQUEST_DATE as date_zap,count(*) as rezult from rawdl2m.l2_pass_main group by 1) as a 
 where date_zap>='2023-01-01'  order by date_zap;
   
/ **/


/** /
--СУТОЧНАЯ БАЗА
insert into  l3_prig.prig_times(dann,oper,date_zap,rezult,shema,libr)
 select distinct 'prig' as dann,'dann1' as oper,date_zap,rezult,'day_prig','rawdl2s' as libr from 
 (select REQUEST_DATE as date_zap,count(*) as rezult from rawdl2s.l2_prig_main group by 1) as a;
 
insert into  l3_prig.prig_times(dann,oper,date_zap,rezult,shema,libr)
 select distinct 'prig' as dann,'dann1' as oper,date_zap,rezult,'day_pass','rawdl2s' as libr from 
 (select REQUEST_DATE as date_zap,count(*) as rezult from rawdl2s.l2_pass_main group by 1) as a;
/ **/




/**/
--ОТЛАДОЧНАЯ БАЗА пригород
insert into  l3_prig.prig_times(dann,oper,date_zap,rezult,min_id,max_id,shema,libr,yyyymm)
 select distinct 'prig' as dann,'dann1' as oper,date_zap,rezult,min_id,max_id,'tst_prig','rawdl2' as libr,yyyymm from 
 (select REQUEST_DATE as date_zap,count(*) as rezult,min(idnum) as min_id,max(idnum) as max_id,min(yyyymm) as yyyymm
  from rawdl2.l2_prig_main group by 1) as a
 --where date_zap in ('2023-04-25')
 ;

--ОТЛАДОЧНАЯ БАЗА пассажирские
insert into  l3_prig.prig_times(dann,oper,date_zap,rezult,min_id,max_id,shema,libr,yyyymm)
 select distinct 'prig' as dann,'dann1' as oper,date_zap,rezult,min_id,max_id,'tst_pass','rawdl2' as libr,yyyymm from 
 (select REQUEST_DATE as date_zap,count(*) as rezult,min(idnum) as min_id,max(idnum) as max_id,min(yyyymm) as yyyymm
  from rawdl2.l2_pass_main group by 1) 
 as a 
 where date_zap in --('2023-03-16');
 (select distinct date_zap from l3_prig.prig_times where shema='tst_prig')
 ;
--ОТЛАДКА ИСКАНДЕРЫ -- ВРЕМЕННО ОТМЕНЕНЫ ДО ИСПРАВЛЕНИЯ СТРУКТУРЫ

insert into  l3_prig.prig_times(dann,oper,date_zap,rezult,min_id,max_id,shema,libr,yyyymm)
 select distinct 'prig' as dann,'dann1' as oper,date_zap,rezult,min_id,max_id,'tsttprig','rawd_ng' as libr,yyyymm from 
 (select REQUEST_DATE as date_zap,count(*) as rezult,min(idnum) as min_id,max(idnum) as max_id,min(yyyymm) as yyyymm
  from rawd_ng.l2_prig_main group by 1) as a  --where date_zap in ('2022-11-29')
 ;

/**/ 

--  select * from l3_prig.prig_times
-----ЗАГРУЗКА ОПРЕДЕЛЕНИЙ О ЧИТАЕМЫХ ТАБЛИЦАХ!
insert into l3_prig.prig_times(dann,shema,libr,itog,oper)
	values('prig','tst_prig','rawdl2','table','l2_prig_main');
insert into l3_prig.prig_times(dann,shema,libr,itog,oper)
	values('prig','tst_pass','rawdl2','table','l2_pass_main');







-------------------------------------СОЗДАНИЕ РАБОЧЕЙ ТАБЛИЦЫ ВРЕМЕННЫХ ДАННЫХ ---------------

CREATE TABLE l3_prig.prig_work
(
	rez dec(3),opis bigint,idnum bigint,request_num dec(7),YYMM smallint,
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
ALTER TABLE l3_prig.prig_work OWNER to asul;
GRANT ALL ON TABLE l3_prig.prig_work TO asul;




CREATE TABLE l3_prig.prig_mars
(
	nom_mar dec(7),sto dec(7),stn dec(7),srasst smallint,sto_zone dec(3),stn_zone  dec(3),sti dec(7),sti_zone dec(3),
	nom smallint,reg smallint,marshr dec(7),mcd smallint,st1 dec(7),st2 dec(7),rst dec(3),dor smallint,lin smallint,
	d_plata dec(13),d_poteri dec(13),otd dec(3),dcs dec(5),peregon dec(7),
	idnum bigint,date_zap date,part_zap dec(7) --для удобства расследований
) TABLESPACE pg_default;
ALTER TABLE l3_prig.prig_mars OWNER to asul;
GRANT ALL ON TABLE l3_prig.prig_mars TO asul;

CREATE INDEX l3_prig_prig_mars_ind ON l3_prig.prig_mars (nom_mar)  TABLESPACE pg_default;


CREATE TABLE l3_prig.prig_dats --справочник расписки дат поездок относительно даты начала действия билета
(nom_dat dec(7),plus_dat integer,kpas_day dec(3),
 idnum bigint,date_zap date,part_zap dec(7) --для удобства расследований
) TABLESPACE pg_default;
ALTER TABLE l3_prig.prig_dats OWNER to asul;
GRANT ALL ON TABLE l3_prig.prig_dats TO asul;

CREATE INDEX l3_prig_prig_dats_ind ON l3_prig.prig_dats (nom_dat)  TABLESPACE pg_default;




CREATE TABLE l3_prig.prig_bil
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
ALTER TABLE l3_prig.prig_bil OWNER to asul;
GRANT ALL ON TABLE l3_prig.prig_bil TO asul;
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

CREATE INDEX l3_prig_prig_bil_ind ON l3_prig.prig_bil (nom_bil)  TABLESPACE pg_default;




CREATE TABLE l3_prig.prig_bad
(
	marshr dec(7), st1 dec(7),st2 dec(7),rst dec(3),reg smallint,dor smallint,lin smallint,date_zap date,part_zap dec(7),idnum bigint
) TABLESPACE pg_default;
ALTER TABLE l3_prig.prig_bad OWNER to asul;
GRANT ALL ON TABLE l3_prig.prig_bad TO asul;




--Таблица обогащения пригорода
CREATE TABLE l3_prig.prig_itog
(
	idnum bigint,request_num dec(7),YYMM smallint,k_bil dec(7),nom_mar dec(7),nom_bil dec(7),nom_dat dec(7),date_zap date,part_zap dec(7),
	date_beg date,date_end date,date_pr date,TERM_DOR character(1),term_pos character(3),term_trm char(2),
	agent smallint,subagent smallint,chp smallint,stp dec(7),stp_reg smallint,train_num char(5),kol_bil dec(7),
	plata dec(11),poteri dec(11),perebor dec(11),nedobor dec(11),kom_sbor dec(11),kom_sbor_vz dec(11)
	
	)
TABLESPACE pg_default;
ALTER TABLE l3_prig.prig_itog OWNER to asul;
GRANT ALL ON TABLE l3_prig.prig_itog TO asul;

CREATE INDEX l3_prig_prig_itog_indp ON l3_prig.prig_itog (part_zap)  TABLESPACE pg_default;
CREATE INDEX l3_prig_prig_itog_indd ON l3_prig.prig_itog (yymm,date_zap)  TABLESPACE pg_default;
--delete l3_prig_prig_itog_indp;
--select * from l3_prig.prig_mars limit 100



--Таблица по льготникам новая
CREATE TABLE l3_prig.prig_lgot_reestr
(	YYMM smallint,date_zap date,part_zap dec(7),request_num dec(7),idnum bigint,list char(5),/*ticket char(10),*/kodbl char(18),
	p1 dec(7),p2 char(3),p3 char(2),p4 char(1),p5 char(1),p6 char(1),p7 char(4),
	p8 char(4),p9 char(5),p10 char(14),p11 char(5),p12 char(10),p13 char(1),p14 char(45),p15 char(20),p16 dec(3),
	p17 char(1),p18 char(3),p19 dec(3),p20 char(1),p21 char(2),p22 char(6),p23 char(6),p24 char(8),p25 char(7),p26 char(7),
	p27 dec(9,2),p28 dec(9,2),p29 char(5),p30 char(10),p31 char(7),p32 char(11),p33 dec(3),deleted char(1)
	)
TABLESPACE pg_default;
ALTER TABLE l3_prig.prig_lgot_reestr OWNER to asul;
GRANT ALL ON TABLE l3_prig.prig_lgot_reestr TO asul;



--Таблица контрольных сумм по реестру льгот
CREATE TABLE l3_prig.prig_lgot_stat
(YYMM smallint,list char(5),dor char(3),kol_zap integer,kol_del integer,kol_raz integer,kol_abon integer,kol_ab_k integer,
 plata dec(13,2),poteri dec(13,2),kol_porc dec(5),date_zap date
 )
TABLESPACE pg_default;
ALTER TABLE l3_prig.prig_lgot_stat OWNER to asul;
GRANT ALL ON TABLE l3_prig.prig_lgot_stat TO asul;


-----------------------------------------------------

--Таблица агрегатов аналитическая
CREATE TABLE l3_prig.prig_analit
(YYMM smallint,date_zap date,part_zap dec(7),date date,TERM_DOR char(1),agent smallint,chp smallint,reg smallint,par_name char(10),
 anal_rasch char(7),anal_vid_bil char(9),anal_oper char(1),train_category char(1),
 kol_bil dec(13),plata dec(13),poteri dec(13),kol_pas dec(13),pass_km dec(13)
 	)
TABLESPACE pg_default;
ALTER TABLE l3_prig.prig_analit OWNER to asul;
GRANT ALL ON TABLE l3_prig.prig_analit TO asul;

---====================================================================================



	
	
	

CREATE TABLE l3_prig.prig_peregoni
(peregon dec(7),dor smallint,lin smallint,st1 dec(7),st2 dec(7),name char(50),rasst dec(5),date_zap date,part_zap dec(7)
) TABLESPACE pg_default;
ALTER TABLE l3_prig.prig_peregoni OWNER to asul;
GRANT ALL ON TABLE l3_prig.prig_peregoni TO asul;

CREATE INDEX l3_prig_prig_peregoni_ind ON l3_prig.prig_peregoni (peregon)  TABLESPACE pg_default;
	
	
/** /
--    Таблица агрегатов по перегонам
CREATE TABLE l3_prig.prig_agr_pereg
(	date_zap date,part_zap dec(7),YYMM smallint,TERM_DOR char(1),nom_bil dec(7),prod char(1),date date,agent smallint,chp smallint,reg smallint,
	dor smallint,lin smallint,otd dec(3),dcs dec(5),st1 dec(7),st2 dec(7),rst smallint,peregon dec(7),par_name char(8),
	plata dec(11),poteri dec(11),per_pas dec(7),pass_km dec(9),otpr_pas dec(7),prib_pas dec(7)	
	)
TABLESPACE pg_default;
ALTER TABLE l3_prig.prig_agr_pereg OWNER to asul;
GRANT ALL ON TABLE l3_prig.prig_agr_pereg TO asul;



--Таблица агрегатов останционных
CREATE TABLE l3_prig.prig_agr_kst
(	date_zap date,part_zap dec(7),YYMM smallint,TERM_DOR char(1),term_pos char(3),term_trm char(2),nom_bil dec(7),date date,date_beg date,
 	agent smallint,chp smallint,kst dec(7),reg smallint,	
	FLG_CHILD char(1),FLG_MILITARY char(1),kod_lgt smallint,ABONEMENT_TYPE character(3),prod char(1),
	--dor smallint,lin smallint,predpr smallint,
	par_name char(10),param1 dec(11),param2 dec(11)
	)
TABLESPACE pg_default;
ALTER TABLE l3_prig.prig_agr_kst OWNER to asul;
GRANT ALL ON TABLE l3_prig.prig_agr_kst TO asul;
/ **/






--GRANT SELECT ON TABLE rawdl2.l2_prig_main TO PUBLIC;
/*
COMMENT ON TABLE rawdl2.l2_prig_main
    IS 'Пригород, основная таблица';

COMMENT ON COLUMN rawdl2.l2_prig_main.id
    IS 'Идентификатор';

COMMENT ON COLUMN rawdl2.l2_prig_main.yymm
    IS 'Отчетный месяц (операции)';

COMMENT ON COLUMN rawdl2.l2_prig_main.request_date
    IS 'Дата запроса';

COMMENT ON COLUMN rawdl2.l2_prig_main.request_num
    IS 'Номер запроса';

COMMENT ON COLUMN rawdl2.l2_prig_main.term_pos
    IS 'Пункт продажи';

COMMENT ON COLUMN rawdl2.l2_prig_main.term_dor
    IS 'Мнемоника дороги продажи';

COMMENT ON COLUMN rawdl2.l2_prig_main.term_trm
    IS 'Номер терминала';

COMMENT ON COLUMN rawdl2.l2_prig_main.arxiv_code
    IS 'Код записи в архив';

COMMENT ON COLUMN rawdl2.l2_prig_main.reply_code
    IS 'Код ответа';

COMMENT ON COLUMN rawdl2.l2_prig_main.request_time
    IS 'Время запроса';

COMMENT ON COLUMN rawdl2.l2_prig_main.request_type
    IS 'Вид работы';

COMMENT ON COLUMN rawdl2.l2_prig_main.request_subtype
    IS 'Подвид работы';

COMMENT ON COLUMN rawdl2.l2_prig_main.oper
    IS 'Вид операции: O  - продажа, V  - возврат';

COMMENT ON COLUMN rawdl2.l2_prig_main.oper_g
    IS 'Признак гашения: N - не гашение, G - гашение, O - отказ';

COMMENT ON COLUMN rawdl2.l2_prig_main.registration_method
    IS 'Способ оформления: Экспресс-0/ручник-1';

COMMENT ON COLUMN rawdl2.l2_prig_main.operation_date
    IS 'Дата операции';

COMMENT ON COLUMN rawdl2.l2_prig_main.ticket_begdate
    IS 'Дата начала действия билета';

COMMENT ON COLUMN rawdl2.l2_prig_main.train_category
    IS 'Категория поезда';

COMMENT ON COLUMN rawdl2.l2_prig_main.train_num
    IS 'Номер поезда';

COMMENT ON COLUMN rawdl2.l2_prig_main.agent_code
    IS 'Код агента';

COMMENT ON COLUMN rawdl2.l2_prig_main.carriage_code
    IS 'Код перевозчика';

COMMENT ON COLUMN rawdl2.l2_prig_main.paymenttype
    IS 'Вид расчета';

COMMENT ON COLUMN rawdl2.l2_prig_main.els_code
    IS 'Код ЕЛС';

COMMENT ON COLUMN rawdl2.l2_prig_main.sale_station
    IS 'Код станции фин учета';

COMMENT ON COLUMN rawdl2.l2_prig_main.region_code
    IS 'Код субъекта продажи';

COMMENT ON COLUMN rawdl2.l2_prig_main.payagent_id
    IS 'Идентификатор платежного агента';

COMMENT ON COLUMN rawdl2.l2_prig_main.web_id
    IS 'Идентификатор Web-площадки';

COMMENT ON COLUMN rawdl2.l2_prig_main.doc_num
    IS 'Номер документа по порядку';

COMMENT ON COLUMN rawdl2.l2_prig_main.ticket_ser
    IS 'Серия бланка';

COMMENT ON COLUMN rawdl2.l2_prig_main.ticket_num
    IS 'Номер бланка';

COMMENT ON COLUMN rawdl2.l2_prig_main.departure_station
    IS 'Станция отправления';

COMMENT ON COLUMN rawdl2.l2_prig_main.arrival_station
    IS 'Станция назначения';

COMMENT ON COLUMN rawdl2.l2_prig_main.intermed_station
    IS 'Промежуточная станция';

COMMENT ON COLUMN rawdl2.l2_prig_main.departure_zone
    IS 'Зона отправления';

COMMENT ON COLUMN rawdl2.l2_prig_main.arrival_zone
    IS 'Зона назначения';

COMMENT ON COLUMN rawdl2.l2_prig_main.intermed_zone
    IS 'Промежуточная зона';

COMMENT ON COLUMN rawdl2.l2_prig_main.doc_type
    IS 'Вид документа: 0 - пассажир/1 - ручная кладь';

COMMENT ON COLUMN rawdl2.l2_prig_main.pass_qty
    IS 'Количество пассажиров';

COMMENT ON COLUMN rawdl2.l2_prig_main.carryon_type
    IS 'Вид ручной клади';

COMMENT ON COLUMN rawdl2.l2_prig_main.carryon_weight
    IS 'Вес ручной клади';

COMMENT ON COLUMN rawdl2.l2_prig_main.flg_2wayticket
    IS 'Признак разовый туда-обратно';

COMMENT ON COLUMN rawdl2.l2_prig_main.flg_1wayticket
    IS 'Признак разовый туда';

COMMENT ON COLUMN rawdl2.l2_prig_main.flg_child
    IS 'Признак детский/взрослый: детский - 1. иначе 0';

COMMENT ON COLUMN rawdl2.l2_prig_main.flg_military
    IS 'Признак кредитовый';

COMMENT ON COLUMN rawdl2.l2_prig_main.flg_benefit
    IS 'признак льготный';

COMMENT ON COLUMN rawdl2.l2_prig_main.flg_so
    IS 'Признак СО: CTOPOHHИE OPГAHИЗAЦИИ';

COMMENT ON COLUMN rawdl2.l2_prig_main.flg_nu
    IS 'Признак НУ: HEГOCУДAPCTBEHHЫE УЧPEЖДEHИЯ';

COMMENT ON COLUMN rawdl2.l2_prig_main.flg_tt
    IS 'Признак ТТ: TPAHCПOPTHOE TPEБOBAHИE';

COMMENT ON COLUMN rawdl2.l2_prig_main.seatstick_limit
    IS 'Срок действия абонемента/число поездок';

COMMENT ON COLUMN rawdl2.l2_prig_main.carriage_class
    IS 'Класс';

COMMENT ON COLUMN rawdl2.l2_prig_main.benefit_code
    IS 'Код льготы';

COMMENT ON COLUMN rawdl2.l2_prig_main.flg_bsp
    IS 'Признак бесплатный';

COMMENT ON COLUMN rawdl2.l2_prig_main.ticket_enddate
    IS 'Дата окончания действия';

COMMENT ON COLUMN rawdl2.l2_prig_main.return_date
    IS 'Дата возврата';

COMMENT ON COLUMN rawdl2.l2_prig_main.benefit_region
    IS 'Код субъекта льготы';

COMMENT ON COLUMN rawdl2.l2_prig_main.total_sum
    IS 'Сумма введенная';

COMMENT ON COLUMN rawdl2.l2_prig_main.tariff_sum
    IS 'Сумма тарифа';

COMMENT ON COLUMN rawdl2.l2_prig_main.department_sum
    IS 'Сумма потерь';

COMMENT ON COLUMN rawdl2.l2_prig_main.fee_sum
    IS 'Сумма к/сбора';

COMMENT ON COLUMN rawdl2.l2_prig_main.fee_vat
    IS 'НДС с к/сбора';

COMMENT ON COLUMN rawdl2.l2_prig_main.refundfee_sum
    IS 'Сумма к/сбора за возврат';

COMMENT ON COLUMN rawdl2.l2_prig_main.refunddepart_sum
    IS 'Сумма возвращаемых потерь';

COMMENT ON COLUMN rawdl2.l2_prig_main.military_code
    IS 'Номер воинского м-ва';

COMMENT ON COLUMN rawdl2.l2_prig_main.benefit_percent
    IS 'Процент льготы';

COMMENT ON COLUMN rawdl2.l2_prig_main.abonement_type
    IS 'Вид абонемента';

COMMENT ON COLUMN rawdl2.l2_prig_main.date_template
    IS 'Шаблон дат';

COMMENT ON COLUMN rawdl2.l2_prig_main.flg_carryon
    IS 'Признак билет пассажирский-багажный (0- пасс, 1-багаж)';
	*/
	
	
	
	
	--  select * from rawdl2.l2_prig_main limit 100
	
	
	
	
	
	






/*
--ИСКАНДЕРЫ
select BENEFITGROUP_CODE,* from rawd_ng.l2_prig_main limit 100

-- ОБЫЧНЫЕ
select BENEFITGROUP_CODE,* from rawdl2.l2_prig_main limit 100




select cnt_code,* from rawdl2.l2_pass_cost limit 100

select cnt_code,* from rawdl2.l2_bag_cost limit 100


*/














/**/
	
	
	
	
	
	
	