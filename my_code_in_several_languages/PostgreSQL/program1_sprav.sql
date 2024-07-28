
--СПРАВОЧНИК ВИДОВ БИЛЕТОВ
--ЕЩЁ НУЖЕН СПРАВОЧКИЕ КУСКОВ КОМПАНИЙ, И СПРАВОЧНИК ПО ПЕРЕГОНАМ 

/*
DROP TABLE spb_prig.prig_bileti;
drop table spb_prig.prig_bileti_using;

SELECT * FROM spb_prig.prig_bileti

SELECT * FROM spb_prig.prig_bileti_using

SELECT * FROM spb_prig.prig_bil
*/



CREATE TABLE spb_prig.prig_bileti
(
	nomer_bil dec(7),name char(50),
	k_pas smallint,srok_bil smallint,srok_mon smallint,flg_bag char(1),FLG_tuda_obr char(1),flg_rab_day char(1),	
	flg_ruch char(1),vid_rasch char(1),FLG_CHILD char(1),flg_voin smallint,FLG_MILITARY char(1),
	flg_lgt char(1),FLG_BSP char(1),FLG_SO char(1),FLG_NU char(1),FLG_TT char(1),	
	klass  char(1),kod_lgt smallint,lgt_reg smallint,bag_vid char(1),bag_ves smallint,proc_lgt smallint,	
	ABONEMENT_TYPE character(3),TRAIN_CATEGORY char(1),TRAIN_NUM char(5),grup_lgt  smallint,date_zap date	
	)
TABLESPACE pg_default;
ALTER TABLE spb_prig.prig_bileti OWNER to asul;
GRANT ALL ON TABLE spb_prig.prig_bileti TO asul;


insert into spb_prig.prig_bileti(nomer_bil,name)
values (1,'ВСЕГО');

insert into spb_prig.prig_bileti(nomer_bil,name,kod_lgt)
values (2,'НЕЛЬГОТНЫЕ',0);

insert into spb_prig.prig_bileti(nomer_bil,name,kod_lgt,flg_child)
values (3,'НЕЛЬГОТНЫЕ ДЕТСКИЕ',0,1);

insert into spb_prig.prig_bileti(nomer_bil,name,flg_child)
values (4,'ВСЕГО ДЕТСКИЕ',1);

insert into spb_prig.prig_bileti(nomer_bil,name,flg_voin)
values (5,'ВОИНСКИЕ',1);

insert into spb_prig.prig_bileti(nomer_bil,name,abonement_type,flg_bag)
values (6,'РАЗОВЫЕ','0','0');

insert into spb_prig.prig_bileti(nomer_bil,name,flg_bag)
values (7,'БАГАЖ','1');


insert into spb_prig.prig_bileti(nomer_bil,name,abonement_type)
values (8,'АБОНЕМЕНТЫ МНОГОМЕСЯЧНЫЕ','1');
insert into spb_prig.prig_bileti(nomer_bil,name,abonement_type)
values (8,'АБОНЕМЕНТЫ МНОГОМЕСЯЧНЫЕ','3');
insert into spb_prig.prig_bileti(nomer_bil,name,abonement_type)
values (8,'АБОНЕМЕНТЫ МНОГОМЕСЯЧНЫЕ','5');
insert into spb_prig.prig_bileti(nomer_bil,name,abonement_type)
values (8,'АБОНЕМЕНТЫ МНОГОМЕСЯЧНЫЕ','7');

insert into spb_prig.prig_bileti(nomer_bil,name,abonement_type)
values (9,'АБОНЕМЕНТЫ ВЫХОДНОГО ДНЯ','5');

insert into spb_prig.prig_bileti(nomer_bil,name,abonement_type)
values (10,'АБОНЕМЕНТЫ МНОГОДНЕВНЫЕ','2');
insert into spb_prig.prig_bileti(nomer_bil,name,abonement_type)
values (10,'АБОНЕМЕНТЫ МНОГОДНЕВНЫЕ','4');
insert into spb_prig.prig_bileti(nomer_bil,name,abonement_type)
values (10,'АБОНЕМЕНТЫ МНОГОДНЕВНЫЕ','6');
insert into spb_prig.prig_bileti(nomer_bil,name,abonement_type)
values (10,'АБОНЕМЕНТЫ МНОГОДНЕВНЫЕ','8');

insert into spb_prig.prig_bileti(nomer_bil,name,grup_lgt)
values (11,'РЕГИОНАЛЬНЫЕ ЛЬГОТНИКИ',27);
insert into spb_prig.prig_bileti(nomer_bil,name,grup_lgt)
values (11,'РЕГИОНАЛЬНЫЕ ЛЬГОТНИКИ',28);
insert into spb_prig.prig_bileti(nomer_bil,name,grup_lgt)
values (11,'РЕГИОНАЛЬНЫЕ ЛЬГОТНИКИ',29);
insert into spb_prig.prig_bileti(nomer_bil,name,grup_lgt)
values (11,'РЕГИОНАЛЬНЫЕ ЛЬГОТНИКИ',30);




/*
select nomer_bil,count(*) as kol from
(select nomer_bil,nom_bil 
from  spb_prig.prig_bil as a join  spb_prig.prig_bileti as b
on (a.k_pas=b.k_pas or b.k_pas is null)
and (a.srok_bil=b.srok_bil or b.srok_bil is null)
and (a.srok_mon=b.srok_mon or b.srok_mon is null)
and (a.flg_bag=b.flg_bag or b.flg_bag is null)
and (a.FLG_tuda_obr=b.FLG_tuda_obr or b.FLG_tuda_obr is null)
and (a.flg_rab_day=b.flg_rab_day or b.flg_rab_day is null)
and (a.flg_ruch=b.flg_ruch or b.flg_ruch is null)
and (a.vid_rasch=b.vid_rasch or b.vid_rasch is null)
and (a.FLG_CHILD=b.FLG_CHILD or b.FLG_CHILD is null)
and (a.flg_voin=b.flg_voin or b.flg_voin is null)
and (a.FLG_MILITARY=b.FLG_MILITARY or b.FLG_MILITARY is null)
and (a.flg_lgt=b.flg_lgt or b.flg_lgt is null)
and (a.FLG_BSP=b.FLG_BSP or b.FLG_BSP is null)
and (a.FLG_SO=b.FLG_SO or b.FLG_SO is null)
and (a.FLG_NU=b.FLG_NU or b.FLG_NU is null)
and (a.FLG_TT=b.FLG_TT or b.FLG_TT is null)
and (a.klass=b.klass or b.klass is null)
and (a.kod_lgt=b.kod_lgt or b.kod_lgt is null)
and (a.lgt_reg=b.lgt_reg or b.lgt_reg is null)
and (a.bag_vid=b.bag_vid or b.bag_vid is null)
and (a.bag_ves=b.bag_ves or b.bag_ves is null)
and (a.proc_lgt=b.proc_lgt or b.proc_lgt is null)
and (a.ABONEMENT_TYPE=b.ABONEMENT_TYPE or b.ABONEMENT_TYPE is null)
and (a.TRAIN_CATEGORY=b.TRAIN_CATEGORY or b.TRAIN_CATEGORY is null)
and (a.TRAIN_NUM=b.TRAIN_NUM or b.TRAIN_NUM is null)
and (a.grup_lgt=b.grup_lgt or b.grup_lgt is null)	
) as c group by 1;
*/



CREATE TABLE spb_prig.prig_bileti_using
(
	spr_name char(50),nomer_bil dec(7),koef dec(3),par_name char(10),pole char(10)
	)
TABLESPACE pg_default;
ALTER TABLE spb_prig.prig_bileti_using OWNER to asul;
GRANT ALL ON TABLE spb_prig.prig_bileti_using TO asul;



insert into spb_prig.prig_bileti_using(spr_name,pole,nomer_bil,koef)
values ('prig_agr_pereg 1' ,'all',1,1);
insert into spb_prig.prig_bileti_using(spr_name,pole,nomer_bil,koef)
values ('prig_agr_pereg 1' ,'plat',2,1);
insert into spb_prig.prig_bileti_using(spr_name,pole,nomer_bil,koef)
values ('prig_agr_pereg 1' ,'lgot',1,1);
insert into spb_prig.prig_bileti_using(spr_name,pole,nomer_bil,koef)
values ('prig_agr_pereg 1' ,'lgot',2,-1);




select * from spb_prig.prig_bileti where nomer_bil in 
 (select nomer_bil from spb_prig.prig_bileti_using where substr(spr_name,1,15)='prig_agr_pereg ');


