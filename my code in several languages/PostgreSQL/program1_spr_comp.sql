
/*
drop table spb_prig.prig_comp_lin;
drop table spb_prig.prig_comp;
drop table spb_prig.prig_unikod;
*/


-- delete from spb_prig.prig_comp;

--- https://navalny.com/p/6535/


-- ВСЕ СТАНЦИИ
--  select stan,datand,datakd,sf,dor,otd,gos from nsi.stanv where stan in('2004001','2009778')

-- ВСЕ ДОРОГИ
--select distinct nomd2,nomd3,kodd,nazvd,kodg from nsi.dor where kodg='20' order by 1,2,3,4


--справочник принадлежности кусков линий компаниям
CREATE TABLE spb_prig.prig_comp_lin
( dor smallint,lin smallint,st1 dec(7),st2 dec(7),predpr smallint,date_beg date,date_end date
) TABLESPACE pg_default;
ALTER TABLE spb_prig.prig_comp_lin OWNER to asul;
GRANT ALL ON TABLE spb_prig.prig_comp_lin TO asul;




--справочник компаний
CREATE TABLE spb_prig.prig_comp
( comp smallint,podr smallint,comp_name char(30),podr_name char(30),predpr smallint,date_beg date,date_end date
) TABLESPACE pg_default;
ALTER TABLE spb_prig.prig_comp OWNER to asul;
GRANT ALL ON TABLE spb_prig.prig_comp TO asul;




--справочник единиц отчётности
CREATE TABLE spb_prig.prig_unikod
( unikod smallint,dor smallint,comp smallint,podr smallint,kst dec(7),reg smallint,name char(50),date_beg date,date_end date
) TABLESPACE pg_default;
ALTER TABLE spb_prig.prig_comp OWNER to asul;
GRANT ALL ON TABLE spb_prig.prig_comp TO asul;







insert into spb_prig.prig_comp(predpr,comp,podr,comp_name,podr_name,date_beg,date_end)
values(56,7,7,'СЗППК','ПЕТРОЗАВОДСКИЙ УЧАСТОК','2013-01-01','2100-01-01');
insert into spb_prig.prig_comp(predpr,comp,podr,comp_name,podr_name,date_beg,date_end)
values(26,7,6,'СЗППК','ПСКОВСКИЙ ХОД','2013-01-01','2100-01-01');
insert into spb_prig.prig_comp(predpr,comp,podr,comp_name,podr_name,date_beg,date_end)
values(16,7,8,'СЗППК','ФИНЛЯНДСКО-ЛАДОЖСКИЙ ХОД','2013-01-01','2100-01-01');
insert into spb_prig.prig_comp(predpr,comp,podr,comp_name,podr_name,date_beg,date_end)
values(2,7,3,'СЗППК','МОСКОВСКИЙ ХОД','2013-01-01','2100-01-01');
insert into spb_prig.prig_comp(predpr,comp,podr,comp_name,podr_name,date_beg,date_end)
values(8,7,2,'СЗППК','БАЛТИЙСКИЙ ХОД','2013-01-01','2100-01-01');
insert into spb_prig.prig_comp(predpr,comp,podr,comp_name,podr_name,date_beg,date_end)
values(12,7,4,'СЗППК','ФИНЛЯНДСКО-ВЫБОРГСКИЙ УЧАСТОК','2013-01-01','2100-01-01');
insert into spb_prig.prig_comp(predpr,comp,podr,comp_name,podr_name,date_beg,date_end)
values(19,7,5,'СЗППК','ВОЛХОВСКИЙ ХОД','2013-01-01','2100-01-01');
insert into spb_prig.prig_comp(predpr,comp,podr,comp_name,podr_name,date_beg,date_end)
values(43,7,1,'СЗППК','ВИТЕБСКИЙ ХОД','2013-01-01','2100-01-01');


--          select * from spb_prig.prig_comp;



insert into spb_prig.prig_comp_lin(predpr,dor,lin,st1,st2,date_beg,date_end)
values(2,1,1,2004001,2004660,'2013-01-01','2100-01-01');
insert into spb_prig.prig_comp_lin(predpr,dor,lin,st1,st2,date_beg,date_end)
values(2,1,2,2004578,2004750,'2013-01-01','2100-01-01');
insert into spb_prig.prig_comp_lin(predpr,dor,lin,st1,st2,date_beg,date_end)
values(2,1,3,2004579,2004627,'2013-01-01','2100-01-01');
insert into spb_prig.prig_comp_lin(predpr,dor,lin,st1,st2,date_beg,date_end)
values(2,1,29,2004148,2004240,'2013-01-01','2100-01-01');
insert into spb_prig.prig_comp_lin(predpr,dor,lin,st1,st2,date_beg,date_end)
values(2,1,35,2004151,2004634,'2013-01-01','2100-01-01');
insert into spb_prig.prig_comp_lin(predpr,dor,lin,st1,st2,date_beg,date_end)
values(2,1,36,2004660,2004670,'2013-01-01','2100-01-01');
insert into spb_prig.prig_comp_lin(predpr,dor,lin,st1,st2,date_beg,date_end)
values(2,1,41,2004594,2005184,'2013-01-01','2100-01-01');
insert into spb_prig.prig_comp_lin(predpr,dor,lin,st1,st2,date_beg,date_end)
values(2,1,44,2004826,2004108,'2013-01-01','2100-01-01');
insert into spb_prig.prig_comp_lin(predpr,dor,lin,st1,st2,date_beg,date_end)
values(2,1,52,2004148,2005306,'2013-01-01','2100-01-01');
insert into spb_prig.prig_comp_lin(predpr,dor,lin,st1,st2,date_beg,date_end)
values(2,1,86,2004162,2004006,'2013-01-01','2100-01-01');
insert into spb_prig.prig_comp_lin(predpr,dor,lin,st1,st2,date_beg,date_end)
values(2,1,87,2004001,2004002,'2013-01-01','2100-01-01');
insert into spb_prig.prig_comp_lin(predpr,dor,lin,st1,st2,date_beg,date_end)
values(2,1,88,2004006,2004001,'2013-01-01','2100-01-01');
insert into spb_prig.prig_comp_lin(predpr,dor,lin,st1,st2,date_beg,date_end)
values(2,1,95,2004001,2004003,'2013-01-01','2100-01-01');
insert into spb_prig.prig_comp_lin(predpr,dor,lin,st1,st2,date_beg,date_end)
values(2,1,97,2004845,2004831,'2013-01-01','2100-01-01');
insert into spb_prig.prig_comp_lin(predpr,dor,lin,st1,st2,date_beg,date_end)
values(8,1,11,2004639,2004636,'2013-01-01','2100-01-01');
insert into spb_prig.prig_comp_lin(predpr,dor,lin,st1,st2,date_beg,date_end)
values(8,1,12,2005460,2004642,'2013-01-01','2100-01-01');
insert into spb_prig.prig_comp_lin(predpr,dor,lin,st1,st2,date_beg,date_end)
values(8,1,15,2005035,20261,'2013-01-01','2100-01-01');
insert into spb_prig.prig_comp_lin(predpr,dor,lin,st1,st2,date_beg,date_end)
values(8,1,40,2004002,2005301,'2013-01-01','2100-01-01');
insert into spb_prig.prig_comp_lin(predpr,dor,lin,st1,st2,date_beg,date_end)
values(8,1,57,2004612,2004636,'2013-01-01','2100-01-01');
insert into spb_prig.prig_comp_lin(predpr,dor,lin,st1,st2,date_beg,date_end)
values(8,1,58,2004192,2005471,'2013-01-01','2100-01-01');
insert into spb_prig.prig_comp_lin(predpr,dor,lin,st1,st2,date_beg,date_end)
values(8,1,59,2004195,2005383,'2013-01-01','2100-01-01');
insert into spb_prig.prig_comp_lin(predpr,dor,lin,st1,st2,date_beg,date_end)
values(8,1,72,2004005,2005105,'2013-01-01','2100-01-01');
insert into spb_prig.prig_comp_lin(predpr,dor,lin,st1,st2,date_beg,date_end)
values(8,1,75,2005206,2005166,'2013-01-01','2100-01-01');
insert into spb_prig.prig_comp_lin(predpr,dor,lin,st1,st2,date_beg,date_end)
values(8,1,81,2004963,2005219,'2013-01-01','2100-01-01');
insert into spb_prig.prig_comp_lin(predpr,dor,lin,st1,st2,date_beg,date_end)
values(8,1,93,2004002,2004006,'2013-01-01','2100-01-01');
insert into spb_prig.prig_comp_lin(predpr,dor,lin,st1,st2,date_beg,date_end)
values(8,1,94,2004002,2004003,'2013-01-01','2100-01-01');
insert into spb_prig.prig_comp_lin(predpr,dor,lin,st1,st2,date_beg,date_end)
values(12,1,8,2004004,10208,'2013-01-01','2100-01-01');
insert into spb_prig.prig_comp_lin(predpr,dor,lin,st1,st2,date_beg,date_end)
values(12,1,60,2005045,2004231,'2013-01-01','2100-01-01');
insert into spb_prig.prig_comp_lin(predpr,dor,lin,st1,st2,date_beg,date_end)
values(12,1,61,2005366,2005404,'2013-01-01','2100-01-01');
insert into spb_prig.prig_comp_lin(predpr,dor,lin,st1,st2,date_beg,date_end)
values(12,1,62,2005404,2005159,'2013-01-01','2100-01-01');
insert into spb_prig.prig_comp_lin(predpr,dor,lin,st1,st2,date_beg,date_end)
values(12,1,63,2004682,2004256,'2013-01-01','2100-01-01');
insert into spb_prig.prig_comp_lin(predpr,dor,lin,st1,st2,date_beg,date_end)
values(12,1,64,2005351,10201,'2013-01-01','2100-01-01');
insert into spb_prig.prig_comp_lin(predpr,dor,lin,st1,st2,date_beg,date_end)
values(12,1,65,2005474,2005254,'2013-01-01','2100-01-01');
insert into spb_prig.prig_comp_lin(predpr,dor,lin,st1,st2,date_beg,date_end)
values(16,1,4,2004004,2004273,'2013-01-01','2100-01-01');
insert into spb_prig.prig_comp_lin(predpr,dor,lin,st1,st2,date_beg,date_end)
values(16,1,9,2004107,2005455,'2013-01-01','2100-01-01');
insert into spb_prig.prig_comp_lin(predpr,dor,lin,st1,st2,date_beg,date_end)
values(16,1,54,2005095,2004241,'2013-01-01','2100-01-01');
insert into spb_prig.prig_comp_lin(predpr,dor,lin,st1,st2,date_beg,date_end)
values(16,1,66,2004258,2005123,'2013-01-01','2100-01-01');
insert into spb_prig.prig_comp_lin(predpr,dor,lin,st1,st2,date_beg,date_end)
values(16,1,67,2004270,10203,'2013-01-01','2100-01-01');
insert into spb_prig.prig_comp_lin(predpr,dor,lin,st1,st2,date_beg,date_end)
values(16,1,68,2005055,2005050,'2013-01-01','2100-01-01');
insert into spb_prig.prig_comp_lin(predpr,dor,lin,st1,st2,date_beg,date_end)
values(16,1,69,2005050,2006104,'2013-01-01','2100-01-01');
insert into spb_prig.prig_comp_lin(predpr,dor,lin,st1,st2,date_beg,date_end)
values(16,1,70,2005050,2005290,'2013-01-01','2100-01-01');
insert into spb_prig.prig_comp_lin(predpr,dor,lin,st1,st2,date_beg,date_end)
values(16,1,76,2005055,2004107,'2013-01-01','2100-01-01');
insert into spb_prig.prig_comp_lin(predpr,dor,lin,st1,st2,date_beg,date_end)
values(16,1,86,2004006,2004241,'2013-01-01','2100-01-01');
insert into spb_prig.prig_comp_lin(predpr,dor,lin,st1,st2,date_beg,date_end)
values(16,1,89,2004006,2005055,'2013-01-01','2100-01-01');
insert into spb_prig.prig_comp_lin(predpr,dor,lin,st1,st2,date_beg,date_end)
values(19,1,7,2004273,2004678,'2013-01-01','2100-01-01');
insert into spb_prig.prig_comp_lin(predpr,dor,lin,st1,st2,date_beg,date_end)
values(19,1,20,2004632,2004669,'2013-01-01','2100-01-01');
insert into spb_prig.prig_comp_lin(predpr,dor,lin,st1,st2,date_beg,date_end)
values(19,1,21,2004634,2004562,'2013-01-01','2100-01-01');
insert into spb_prig.prig_comp_lin(predpr,dor,lin,st1,st2,date_beg,date_end)
values(19,1,25,2004619,2004658,'2013-01-01','2100-01-01');
insert into spb_prig.prig_comp_lin(predpr,dor,lin,st1,st2,date_beg,date_end)
values(19,1,27,2004673,2011251,'2013-01-01','2100-01-01');
insert into spb_prig.prig_comp_lin(predpr,dor,lin,st1,st2,date_beg,date_end)
values(19,1,32,2004162,2004681,'2013-01-01','2100-01-01');
insert into spb_prig.prig_comp_lin(predpr,dor,lin,st1,st2,date_beg,date_end)
values(19,1,34,2004615,2004672,'2013-01-01','2100-01-01');
insert into spb_prig.prig_comp_lin(predpr,dor,lin,st1,st2,date_beg,date_end)
values(19,1,50,2004154,2004134,'2013-01-01','2100-01-01');
insert into spb_prig.prig_comp_lin(predpr,dor,lin,st1,st2,date_beg,date_end)
values(19,1,51,2004634,2005148,'2013-01-01','2100-01-01');
insert into spb_prig.prig_comp_lin(predpr,dor,lin,st1,st2,date_beg,date_end)
values(19,1,54,2004158,2005095,'2013-01-01','2100-01-01');
insert into spb_prig.prig_comp_lin(predpr,dor,lin,st1,st2,date_beg,date_end)
values(19,1,77,2004006,2004101,'2013-01-01','2100-01-01');
insert into spb_prig.prig_comp_lin(predpr,dor,lin,st1,st2,date_beg,date_end)
values(19,1,84,2005221,2004134,'2013-01-01','2100-01-01');
insert into spb_prig.prig_comp_lin(predpr,dor,lin,st1,st2,date_beg,date_end)
values(19,1,85,2005221,2004941,'2013-01-01','2100-01-01');
insert into spb_prig.prig_comp_lin(predpr,dor,lin,st1,st2,date_beg,date_end)
values(19,1,98,2004431,2004673,'2013-01-01','2100-01-01');
insert into spb_prig.prig_comp_lin(predpr,dor,lin,st1,st2,date_beg,date_end)
values(26,1,10,2004641,21202,'2013-01-01','2100-01-01');
insert into spb_prig.prig_comp_lin(predpr,dor,lin,st1,st2,date_beg,date_end)
values(26,1,11,2004636,25202,'2013-01-01','2100-01-01');
insert into spb_prig.prig_comp_lin(predpr,dor,lin,st1,st2,date_beg,date_end)
values(26,1,19,2004479,2004503,'2013-01-01','2100-01-01');
insert into spb_prig.prig_comp_lin(predpr,dor,lin,st1,st2,date_beg,date_end)
values(26,1,24,2004503,20212,'2013-01-01','2100-01-01');
insert into spb_prig.prig_comp_lin(predpr,dor,lin,st1,st2,date_beg,date_end)
values(26,1,26,2004510,20251,'2013-01-01','2100-01-01');
insert into spb_prig.prig_comp_lin(predpr,dor,lin,st1,st2,date_beg,date_end)
values(26,1,36,2004670,2004533,'2013-01-01','2100-01-01');
insert into spb_prig.prig_comp_lin(predpr,dor,lin,st1,st2,date_beg,date_end)
values(26,1,38,2004550,2004503,'2013-01-01','2100-01-01');
insert into spb_prig.prig_comp_lin(predpr,dor,lin,st1,st2,date_beg,date_end)
values(26,1,78,2004435,20252,'2013-01-01','2100-01-01');
insert into spb_prig.prig_comp_lin(predpr,dor,lin,st1,st2,date_beg,date_end)
values(26,1,79,2004533,20263,'2013-01-01','2100-01-01');
insert into spb_prig.prig_comp_lin(predpr,dor,lin,st1,st2,date_beg,date_end)
values(26,1,80,2004533,20262,'2013-01-01','2100-01-01');
insert into spb_prig.prig_comp_lin(predpr,dor,lin,st1,st2,date_beg,date_end)
values(26,1,83,2005189,2004503,'2013-01-01','2100-01-01');
insert into spb_prig.prig_comp_lin(predpr,dor,lin,st1,st2,date_beg,date_end)
values(43,1,10,2004003,2004641,'2013-01-01','2100-01-01');
insert into spb_prig.prig_comp_lin(predpr,dor,lin,st1,st2,date_beg,date_end)
values(43,1,13,2004181,2005456,'2013-01-01','2100-01-01');
insert into spb_prig.prig_comp_lin(predpr,dor,lin,st1,st2,date_beg,date_end)
values(43,1,29,2004240,2005301,'2013-01-01','2100-01-01');
insert into spb_prig.prig_comp_lin(predpr,dor,lin,st1,st2,date_beg,date_end)
values(43,1,33,2004400,2004615,'2013-01-01','2100-01-01');
insert into spb_prig.prig_comp_lin(predpr,dor,lin,st1,st2,date_beg,date_end)
values(43,1,37,2004612,2004400,'2013-01-01','2100-01-01');
insert into spb_prig.prig_comp_lin(predpr,dor,lin,st1,st2,date_beg,date_end)
values(43,1,53,2005096,2005421,'2013-01-01','2100-01-01');
insert into spb_prig.prig_comp_lin(predpr,dor,lin,st1,st2,date_beg,date_end)
values(43,1,56,2004180,2005026,'2013-01-01','2100-01-01');
insert into spb_prig.prig_comp_lin(predpr,dor,lin,st1,st2,date_beg,date_end)
values(43,1,91,2005312,2005456,'2013-01-01','2100-01-01');
insert into spb_prig.prig_comp_lin(predpr,dor,lin,st1,st2,date_beg,date_end)
values(56,1,4,2004273,2004329,'2013-01-01','2100-01-01');
insert into spb_prig.prig_comp_lin(predpr,dor,lin,st1,st2,date_beg,date_end)
values(56,1,5,2004282,2004294,'2013-01-01','2100-01-01');
insert into spb_prig.prig_comp_lin(predpr,dor,lin,st1,st2,date_beg,date_end)
values(56,1,6,2004291,2005300,'2013-01-01','2100-01-01');
insert into spb_prig.prig_comp_lin(predpr,dor,lin,st1,st2,date_beg,date_end)
values(56,1,14,2004702,2004371,'2013-01-01','2100-01-01');
insert into spb_prig.prig_comp_lin(predpr,dor,lin,st1,st2,date_beg,date_end)
values(56,1,28,2004384,2004388,'2013-01-01','2100-01-01');
insert into spb_prig.prig_comp_lin(predpr,dor,lin,st1,st2,date_beg,date_end)
values(56,1,30,2004723,2004410,'2013-01-01','2100-01-01');
insert into spb_prig.prig_comp_lin(predpr,dor,lin,st1,st2,date_beg,date_end)
values(56,1,31,2004407,2004408,'2013-01-01','2100-01-01');
insert into spb_prig.prig_comp_lin(predpr,dor,lin,st1,st2,date_beg,date_end)
values(56,1,32,2004681,2004200,'2013-01-01','2100-01-01');
insert into spb_prig.prig_comp_lin(predpr,dor,lin,st1,st2,date_beg,date_end)
values(56,1,39,2004298,2004747,'2013-01-01','2100-01-01');
insert into spb_prig.prig_comp_lin(predpr,dor,lin,st1,st2,date_beg,date_end)
values(56,1,43,2004200,2005082,'2013-01-01','2100-01-01');
insert into spb_prig.prig_comp_lin(predpr,dor,lin,st1,st2,date_beg,date_end)
values(56,1,45,2004720,2005014,'2013-01-01','2100-01-01');
insert into spb_prig.prig_comp_lin(predpr,dor,lin,st1,st2,date_beg,date_end)
values(56,1,46,2004382,2005272,'2013-01-01','2100-01-01');
insert into spb_prig.prig_comp_lin(predpr,dor,lin,st1,st2,date_beg,date_end)
values(56,1,47,2004717,2005271,'2013-01-01','2100-01-01');
insert into spb_prig.prig_comp_lin(predpr,dor,lin,st1,st2,date_beg,date_end)
values(56,1,48,2004722,2005402,'2013-01-01','2100-01-01');
insert into spb_prig.prig_comp_lin(predpr,dor,lin,st1,st2,date_beg,date_end)
values(56,1,49,2004708,2004234,'2013-01-01','2100-01-01');
insert into spb_prig.prig_comp_lin(predpr,dor,lin,st1,st2,date_beg,date_end)
values(56,1,96,2004298,2004698,'2013-01-01','2100-01-01');

insert into spb_prig.prig_comp_lin(predpr,st1,st2,date_beg,date_end)
values(56,2004698,2004698,'2013-01-01','2100-01-01');
insert into spb_prig.prig_comp_lin(predpr,st1,st2,date_beg,date_end)
values(2,2004831,2004831,'2013-01-01','2100-01-01');
insert into spb_prig.prig_comp_lin(predpr,st1,st2,date_beg,date_end)
values(2,2004845,2004845,'2013-01-01','2100-01-01');
insert into spb_prig.prig_comp_lin(predpr,st1,st2,date_beg,date_end)
values(12,2005351,2005351,'2013-01-01','2100-01-01');
insert into spb_prig.prig_comp_lin(predpr,st1,st2,date_beg,date_end)
values(26,2004435,2004435,'2013-01-01','2100-01-01');
insert into spb_prig.prig_comp_lin(predpr,st1,st2,date_beg,date_end)
values(19,2004134,2004134,'2013-01-01','2100-01-01');
insert into spb_prig.prig_comp_lin(predpr,st1,st2,date_beg,date_end)
values(8,20261,20261,'2013-01-01','2100-01-01');
insert into spb_prig.prig_comp_lin(predpr,st1,st2,date_beg,date_end)
values(56,2004410,2004410,'2013-01-01','2100-01-01');
insert into spb_prig.prig_comp_lin(predpr,st1,st2,date_beg,date_end)
values(43,2005026,2005026,'2013-01-01','2100-01-01');
insert into spb_prig.prig_comp_lin(predpr,st1,st2,date_beg,date_end)
values(8,2005206,2005206,'2013-01-01','2100-01-01');
insert into spb_prig.prig_comp_lin(predpr,st1,st2,date_beg,date_end)
values(8,2005301,2005301,'2013-01-01','2100-01-01');
insert into spb_prig.prig_comp_lin(predpr,st1,st2,date_beg,date_end)
values(56,2005272,2005272,'2013-01-01','2100-01-01');
insert into spb_prig.prig_comp_lin(predpr,st1,st2,date_beg,date_end)
values(8,2005035,2005035,'2013-01-01','2100-01-01');
insert into spb_prig.prig_comp_lin(predpr,st1,st2,date_beg,date_end)
values(43,2004826,2004826,'2013-01-01','2100-01-01');
insert into spb_prig.prig_comp_lin(predpr,st1,st2,date_beg,date_end)
values(2,2005306,2005306,'2013-01-01','2100-01-01');
insert into spb_prig.prig_comp_lin(predpr,st1,st2,date_beg,date_end)
values(19,2004101,2004101,'2013-01-01','2100-01-01');
insert into spb_prig.prig_comp_lin(predpr,st1,st2,date_beg,date_end)
values(19,2004658,2004658,'2013-01-01','2100-01-01');
insert into spb_prig.prig_comp_lin(predpr,st1,st2,date_beg,date_end)
values(12,2005455,2005455,'2013-01-01','2100-01-01');
insert into spb_prig.prig_comp_lin(predpr,st1,st2,date_beg,date_end)
values(43,2005456,2005456,'2013-01-01','2100-01-01');
insert into spb_prig.prig_comp_lin(predpr,st1,st2,date_beg,date_end)
values(12,2005474,2005474,'2013-01-01','2100-01-01');
insert into spb_prig.prig_comp_lin(predpr,st1,st2,date_beg,date_end)
values(2,2004615,2004615,'2013-01-01','2100-01-01');
insert into spb_prig.prig_comp_lin(predpr,st1,st2,date_beg,date_end)
values(12,2005404,2005404,'2013-01-01','2100-01-01');
insert into spb_prig.prig_comp_lin(predpr,st1,st2,date_beg,date_end)
values(56,2004382,2004382,'2013-01-01','2100-01-01');
insert into spb_prig.prig_comp_lin(predpr,st1,st2,date_beg,date_end)
values(8,2004005,2004005,'2013-01-01','2100-01-01');
insert into spb_prig.prig_comp_lin(predpr,st1,st2,date_beg,date_end)
values(56,2005300,2005300,'2013-01-01','2100-01-01');
insert into spb_prig.prig_comp_lin(predpr,st1,st2,date_beg,date_end)
values(8,2005383,2005383,'2013-01-01','2100-01-01');
insert into spb_prig.prig_comp_lin(predpr,st1,st2,date_beg,date_end)
values(16,2005095,2005095,'2013-01-01','2100-01-01');
insert into spb_prig.prig_comp_lin(predpr,st1,st2,date_beg,date_end)
values(43,2005166,2005166,'2013-01-01','2100-01-01');
insert into spb_prig.prig_comp_lin(predpr,st1,st2,date_beg,date_end)
values(2,2004579,2004579,'2013-01-01','2100-01-01');
insert into spb_prig.prig_comp_lin(predpr,st1,st2,date_beg,date_end)
values(19,2004941,2004941,'2013-01-01','2100-01-01');
insert into spb_prig.prig_comp_lin(predpr,st1,st2,date_beg,date_end)
values(16,2005123,2005123,'2013-01-01','2100-01-01');
insert into spb_prig.prig_comp_lin(predpr,st1,st2,date_beg,date_end)
values(19,2004673,2004673,'2013-01-01','2100-01-01');
insert into spb_prig.prig_comp_lin(predpr,st1,st2,date_beg,date_end)
values(8,2004642,2004642,'2013-01-01','2100-01-01');
insert into spb_prig.prig_comp_lin(predpr,st1,st2,date_beg,date_end)
values(12,2005254,2005254,'2013-01-01','2100-01-01');
insert into spb_prig.prig_comp_lin(predpr,st1,st2,date_beg,date_end)
values(56,2004708,2004708,'2013-01-01','2100-01-01');
insert into spb_prig.prig_comp_lin(predpr,st1,st2,date_beg,date_end)
values(19,2004681,2004681,'2013-01-01','2100-01-01');
insert into spb_prig.prig_comp_lin(predpr,st1,st2,date_beg,date_end)
values(2,2004148,2004148,'2013-01-01','2100-01-01');
insert into spb_prig.prig_comp_lin(predpr,st1,st2,date_beg,date_end)
values(16,2005050,2005050,'2013-01-01','2100-01-01');
insert into spb_prig.prig_comp_lin(predpr,st1,st2,date_beg,date_end)
values(12,2004231,2004231,'2013-01-01','2100-01-01');
insert into spb_prig.prig_comp_lin(predpr,st1,st2,date_beg,date_end)
values(16,2005290,2005290,'2013-01-01','2100-01-01');
insert into spb_prig.prig_comp_lin(predpr,st1,st2,date_beg,date_end)
values(56,2004298,2004298,'2013-01-01','2100-01-01');
insert into spb_prig.prig_comp_lin(predpr,st1,st2,date_beg,date_end)
values(26,20251,20251,'2013-01-01','2100-01-01');
insert into spb_prig.prig_comp_lin(predpr,st1,st2,date_beg,date_end)
values(19,2004006,2004006,'2013-01-01','2100-01-01');
insert into spb_prig.prig_comp_lin(predpr,st1,st2,date_beg,date_end)
values(12,2005366,2005366,'2013-01-01','2100-01-01');
insert into spb_prig.prig_comp_lin(predpr,st1,st2,date_beg,date_end)
values(19,2004562,2004562,'2013-01-01','2100-01-01');
insert into spb_prig.prig_comp_lin(predpr,st1,st2,date_beg,date_end)
values(16,2005055,2005055,'2013-01-01','2100-01-01');
insert into spb_prig.prig_comp_lin(predpr,st1,st2,date_beg,date_end)
values(2,2004162,2004162,'2013-01-01','2100-01-01');
insert into spb_prig.prig_comp_lin(predpr,st1,st2,date_beg,date_end)
values(26,2005189,2005189,'2013-01-01','2100-01-01');
insert into spb_prig.prig_comp_lin(predpr,st1,st2,date_beg,date_end)
values(56,2004234,2004234,'2013-01-01','2100-01-01');
insert into spb_prig.prig_comp_lin(predpr,st1,st2,date_beg,date_end)
values(16,2006104,2006104,'2013-01-01','2100-01-01');
insert into spb_prig.prig_comp_lin(predpr,st1,st2,date_beg,date_end)
values(12,2005159,2005159,'2013-01-01','2100-01-01');
insert into spb_prig.prig_comp_lin(predpr,st1,st2,date_beg,date_end)
values(8,2004963,2004963,'2013-01-01','2100-01-01');
insert into spb_prig.prig_comp_lin(predpr,st1,st2,date_beg,date_end)
values(2,2005184,2005184,'2013-01-01','2100-01-01');
insert into spb_prig.prig_comp_lin(predpr,st1,st2,date_beg,date_end)
values(56,2005402,2005402,'2013-01-01','2100-01-01');
insert into spb_prig.prig_comp_lin(predpr,st1,st2,date_beg,date_end)
values(16,2004004,2004004,'2013-01-01','2100-01-01');
insert into spb_prig.prig_comp_lin(predpr,st1,st2,date_beg,date_end)
values(56,2004408,2004408,'2013-01-01','2100-01-01');
insert into spb_prig.prig_comp_lin(predpr,st1,st2,date_beg,date_end)
values(19,2005221,2005221,'2013-01-01','2100-01-01');
insert into spb_prig.prig_comp_lin(predpr,st1,st2,date_beg,date_end)
values(56,2004717,2004717,'2013-01-01','2100-01-01');
insert into spb_prig.prig_comp_lin(predpr,st1,st2,date_beg,date_end)
values(19,2004632,2004632,'2013-01-01','2100-01-01');
insert into spb_prig.prig_comp_lin(predpr,st1,st2,date_beg,date_end)
values(8,2004195,2004195,'2013-01-01','2100-01-01');
insert into spb_prig.prig_comp_lin(predpr,st1,st2,date_beg,date_end)
values(43,2005421,2005421,'2013-01-01','2100-01-01');
insert into spb_prig.prig_comp_lin(predpr,st1,st2,date_beg,date_end)
values(2,2004670,2004670,'2013-01-01','2100-01-01');
insert into spb_prig.prig_comp_lin(predpr,st1,st2,date_beg,date_end)
values(19,2004672,2004672,'2013-01-01','2100-01-01');
insert into spb_prig.prig_comp_lin(predpr,st1,st2,date_beg,date_end)
values(12,2005045,2005045,'2013-01-01','2100-01-01');
insert into spb_prig.prig_comp_lin(predpr,st1,st2,date_beg,date_end)
values(26,2004510,2004510,'2013-01-01','2100-01-01');
insert into spb_prig.prig_comp_lin(predpr,st1,st2,date_beg,date_end)
values(19,2005148,2005148,'2013-01-01','2100-01-01');
insert into spb_prig.prig_comp_lin(predpr,st1,st2,date_beg,date_end)
values(8,2005471,2005471,'2013-01-01','2100-01-01');
insert into spb_prig.prig_comp_lin(predpr,st1,st2,date_beg,date_end)
values(19,2004619,2004619,'2013-01-01','2100-01-01');
insert into spb_prig.prig_comp_lin(predpr,st1,st2,date_beg,date_end)
values(56,2004723,2004723,'2013-01-01','2100-01-01');
insert into spb_prig.prig_comp_lin(predpr,st1,st2,date_beg,date_end)
values(2,2004108,2004108,'2013-01-01','2100-01-01');
insert into spb_prig.prig_comp_lin(predpr,st1,st2,date_beg,date_end)
values(43,2004641,2004641,'2013-01-01','2100-01-01');
insert into spb_prig.prig_comp_lin(predpr,st1,st2,date_beg,date_end)
values(28,2004479,2004479,'2013-01-01','2100-01-01');
insert into spb_prig.prig_comp_lin(predpr,st1,st2,date_beg,date_end)
values(56,2004291,2004291,'2013-01-01','2100-01-01');
insert into spb_prig.prig_comp_lin(predpr,st1,st2,date_beg,date_end)
values(8,2004192,2004192,'2013-01-01','2100-01-01');
insert into spb_prig.prig_comp_lin(predpr,st1,st2,date_beg,date_end)
values(16,2004258,2004258,'2013-01-01','2100-01-01');
insert into spb_prig.prig_comp_lin(predpr,st1,st2,date_beg,date_end)
values(43,2005219,2005219,'2013-01-01','2100-01-01');
insert into spb_prig.prig_comp_lin(predpr,st1,st2,date_beg,date_end)
values(56,2004702,2004702,'2013-01-01','2100-01-01');
insert into spb_prig.prig_comp_lin(predpr,st1,st2,date_beg,date_end)
values(56,2004200,2004200,'2013-01-01','2100-01-01');
insert into spb_prig.prig_comp_lin(predpr,st1,st2,date_beg,date_end)
values(2,2004594,2004594,'2013-01-01','2100-01-01');
insert into spb_prig.prig_comp_lin(predpr,st1,st2,date_beg,date_end)
values(2,2004107,2004107,'2013-01-01','2100-01-01');
insert into spb_prig.prig_comp_lin(predpr,st1,st2,date_beg,date_end)
values(56,2004722,2004722,'2013-01-01','2100-01-01');
insert into spb_prig.prig_comp_lin(predpr,st1,st2,date_beg,date_end)
values(8,2004636,2004636,'2013-01-01','2100-01-01');
insert into spb_prig.prig_comp_lin(predpr,st1,st2,date_beg,date_end)
values(56,2004388,2004388,'2013-01-01','2100-01-01');
insert into spb_prig.prig_comp_lin(predpr,st1,st2,date_beg,date_end)
values(56,2004407,2004407,'2013-01-01','2100-01-01');
insert into spb_prig.prig_comp_lin(predpr,st1,st2,date_beg,date_end)
values(19,2004158,2004158,'2013-01-01','2100-01-01');
insert into spb_prig.prig_comp_lin(predpr,st1,st2,date_beg,date_end)
values(43,2004181,2004181,'2013-01-01','2100-01-01');
insert into spb_prig.prig_comp_lin(predpr,st1,st2,date_beg,date_end)
values(43,2004400,2004400,'2013-01-01','2100-01-01');
insert into spb_prig.prig_comp_lin(predpr,st1,st2,date_beg,date_end)
values(26,2004503,2004503,'2013-01-01','2100-01-01');
insert into spb_prig.prig_comp_lin(predpr,st1,st2,date_beg,date_end)
values(56,2005014,2005014,'2013-01-01','2100-01-01');
insert into spb_prig.prig_comp_lin(predpr,st1,st2,date_beg,date_end)
values(16,2004256,2004256,'2013-01-01','2100-01-01');
insert into spb_prig.prig_comp_lin(predpr,st1,st2,date_beg,date_end)
values(16,2004241,2004241,'2013-01-01','2100-01-01');
insert into spb_prig.prig_comp_lin(predpr,st1,st2,date_beg,date_end)
values(19,2004634,2004634,'2013-01-01','2100-01-01');
insert into spb_prig.prig_comp_lin(predpr,st1,st2,date_beg,date_end)
values(56,2004384,2004384,'2013-01-01','2100-01-01');
insert into spb_prig.prig_comp_lin(predpr,st1,st2,date_beg,date_end)
values(43,2004180,2004180,'2013-01-01','2100-01-01');
insert into spb_prig.prig_comp_lin(predpr,st1,st2,date_beg,date_end)
values(28,2004660,2004660,'2013-01-01','2100-01-01');
insert into spb_prig.prig_comp_lin(predpr,st1,st2,date_beg,date_end)
values(43,2005312,2005312,'2013-01-01','2100-01-01');
insert into spb_prig.prig_comp_lin(predpr,st1,st2,date_beg,date_end)
values(56,2004747,2004747,'2013-01-01','2100-01-01');
insert into spb_prig.prig_comp_lin(predpr,st1,st2,date_beg,date_end)
values(26,2004612,2004612,'2013-01-01','2100-01-01');
insert into spb_prig.prig_comp_lin(predpr,st1,st2,date_beg,date_end)
values(56,2005271,2005271,'2013-01-01','2100-01-01');
insert into spb_prig.prig_comp_lin(predpr,st1,st2,date_beg,date_end)
values(56,2004294,2004294,'2013-01-01','2100-01-01');
insert into spb_prig.prig_comp_lin(predpr,st1,st2,date_beg,date_end)
values(56,2005082,2005082,'2013-01-01','2100-01-01');
insert into spb_prig.prig_comp_lin(predpr,st1,st2,date_beg,date_end)
values(12,10201,10201,'2013-01-01','2100-01-01');
insert into spb_prig.prig_comp_lin(predpr,st1,st2,date_beg,date_end)
values(19,2004431,2004431,'2013-01-01','2100-01-01');
insert into spb_prig.prig_comp_lin(predpr,st1,st2,date_beg,date_end)
values(8,2004002,2004002,'2013-01-01','2100-01-01');
insert into spb_prig.prig_comp_lin(predpr,st1,st2,date_beg,date_end)
values(26,2004550,2004550,'2013-01-01','2100-01-01');
insert into spb_prig.prig_comp_lin(predpr,st1,st2,date_beg,date_end)
values(43,2005096,2005096,'2013-01-01','2100-01-01');
insert into spb_prig.prig_comp_lin(predpr,st1,st2,date_beg,date_end)
values(26,2004533,2004533,'2013-01-01','2100-01-01');
insert into spb_prig.prig_comp_lin(predpr,st1,st2,date_beg,date_end)
values(56,2004720,2004720,'2013-01-01','2100-01-01');
insert into spb_prig.prig_comp_lin(predpr,st1,st2,date_beg,date_end)
values(19,2004154,2004154,'2013-01-01','2100-01-01');
insert into spb_prig.prig_comp_lin(predpr,st1,st2,date_beg,date_end)
values(43,2004003,2004003,'2013-01-01','2100-01-01');
insert into spb_prig.prig_comp_lin(predpr,st1,st2,date_beg,date_end)
values(19,2004627,2004627,'2013-01-01','2100-01-01');
insert into spb_prig.prig_comp_lin(predpr,st1,st2,date_beg,date_end)
values(2,2004001,2004001,'2013-01-01','2100-01-01');
insert into spb_prig.prig_comp_lin(predpr,st1,st2,date_beg,date_end)
values(8,2004639,2004639,'2013-01-01','2100-01-01');
insert into spb_prig.prig_comp_lin(predpr,st1,st2,date_beg,date_end)
values(43,2004240,2004240,'2013-01-01','2100-01-01');
insert into spb_prig.prig_comp_lin(predpr,st1,st2,date_beg,date_end)
values(2,2004151,2004151,'2013-01-01','2100-01-01');
insert into spb_prig.prig_comp_lin(predpr,st1,st2,date_beg,date_end)
values(56,2004329,2004329,'2013-01-01','2100-01-01');
insert into spb_prig.prig_comp_lin(predpr,st1,st2,date_beg,date_end)
values(8,2005105,2005105,'2013-01-01','2100-01-01');
insert into spb_prig.prig_comp_lin(predpr,st1,st2,date_beg,date_end)
values(16,2004270,2004270,'2013-01-01','2100-01-01');
insert into spb_prig.prig_comp_lin(predpr,st1,st2,date_beg,date_end)
values(56,2004371,2004371,'2013-01-01','2100-01-01');
insert into spb_prig.prig_comp_lin(predpr,st1,st2,date_beg,date_end)
values(56,2004282,2004282,'2013-01-01','2100-01-01');
insert into spb_prig.prig_comp_lin(predpr,st1,st2,date_beg,date_end)
values(19,2004669,2004669,'2013-01-01','2100-01-01');
insert into spb_prig.prig_comp_lin(predpr,st1,st2,date_beg,date_end)
values(19,2004273,2004273,'2013-01-01','2100-01-01');
insert into spb_prig.prig_comp_lin(predpr,st1,st2,date_beg,date_end)
values(19,2004678,2004678,'2013-01-01','2100-01-01');
insert into spb_prig.prig_comp_lin(predpr,st1,st2,date_beg,date_end)
values(8,2005460,2005460,'2013-01-01','2100-01-01');
insert into spb_prig.prig_comp_lin(predpr,st1,st2,date_beg,date_end)
values(2,2004578,2004578,'2013-01-01','2100-01-01');
insert into spb_prig.prig_comp_lin(predpr,st1,st2,date_beg,date_end)
values(12,2004682,2004682,'2013-01-01','2100-01-01');
insert into spb_prig.prig_comp_lin(predpr,st1,st2,date_beg,date_end)
values(2,2004750,2004750,'2013-01-01','2100-01-01');

 
 select * from spb_prig.prig_comp_lin;
 
 
 

