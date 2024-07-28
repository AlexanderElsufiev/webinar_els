

libname ml 'd:/mylib/poezda';
libname mylib 'd:/mylib/prigorod';

dm 'afa c=ml.connects.link.frame';

dm 'afa c=ml.otcheti_vpt_prig.connect.frame';



rsubmit;libname pgt db2 authid=pgt;endrsubmit;libname pgt slibref=pgt server=proizvod;

rsubmit;libname tst db2 authid=tst;endrsubmit;libname tst slibref=tst server=otladka;


rsubmit;libname vpt db2 authid=vpt;endrsubmit;libname vpt slibref=vpt server=proizvod;

rsubmit;libname vpt db2 authid=vpt;endrsubmit;libname vpt slibref=vpt server=otladka;


rsubmit;libname xran db2 authid=xran;endrsubmit;libname xran slibref=xran server=proizvod;




rsubmit;libname exp3db db2 authid=exp3db;endrsubmit;libname exp3db slibref=exp3db server=proizvod;


rsubmit;libname exp3db db2 authid=exp3db;endrsubmit;libname exp3db slibref=exp3db server=otladka;

/**********************************************************************************************/

/* расшифровка воинских по дате продажи и отправления*/




data v;infile 'd:/voin_data.txt' delimiter='00'x;format st $200.;input st;l=length(st);
dt=mdy(substr(st,6,2)*1,substr(st,9,2)*1,substr(st,1,4)*1);format dt date9.;
sbil=substr(st,11,l-10)*1;if dt^=. then output;keep dt sbil;run;


proc gplot data=v; plot sbil*dt;run;quit;













/* связываться по почте с   Жанна М Акишева      */

/*
 11.27.08 JOB07573 $HASP165 MPEAMF   ENDED AT N1  MAXCC=0 CN(INTERNAL)

 12.03.21 JOB07579 $HASP165 MPEAMF   ENDED AT N1  MAXCC=0 CN(INTERNAL)
 ***
*/

/*результат сверки с Китаиным переводить в файл MPPAY_COMPARE.txt */

data b;infile 'd:/MPPAY_COMPARE 2021_11.txt' delimiter='00'x;format st $200.;input st;l=length(st);l=length(st);
                k=index(st,'КЛЮЧ "');if k>0 then output;run;
data b;set b;key=substr(st,k+6,32);p1=index(st,'A:');ll=index(substr(st,p1,l+1-p1),',')-3;
                kit=1*substr(st,p1+2,ll);p1=index(st,'B:');ns=1*substr(st,p1+2,ll);delt=1*substr(st,p1+2+ll,ll);
        format nbl $7. serr $4. nds_ skp_ $2. ost $16.;
        nbl=substr(key,1,7);serr=substr(key,9,4);nds_=substr(key,13,2);ost=substr(key,17,16);skp_=substr(key,15,2);
        ss='0123456789ABCDEF';drop /*st key*/ l k p1 ll ss;
        if skp_='FF' then skp=255;else skp=16*(index(ss,substr(skp_,1,1))-1)+(index(ss,substr(skp_,2,1))-1);run;

data b1(keep=nombl nds kit ns delt skp
 pr_d) prig(keep=stp sto stn nds kit ns delt st2_ skp st);
        format ser $2. NOMBL $10.;set ml.serv_simbol b;
        array s[256] $1.;retain s;
        delt=kit-ns;
        if ii^=. then do;s[ii+1]=c;drop c s1-s256;end;
if ii=. then do;array z[4];cc='0123456789ABCDEF';
        do i=1 to 4;c=substr(serr,i,1);do j=1 to 16;if c=substr(cc,j,1) then z[i]=j-1;end;end;
        p1=z1*16+z2;p2=z3*16+z4;ser=s[p1+1]||s[p2+1];
if nds_='F0' then nds=0;if nds_='F2' then nds=12;if nds_='F8' then nds=18;if nds_='D5' then nds=.;
nombl=ser||' '||nbl;
pr_d='-';pr_d=substr(ost,2,1);/*добавил 14.04.2016*/
        if substr(nbl,1,2)^='27' then output b1;else do;format stp sto stn $7. st2_ $3.;stp=nbl;
        sto=substr(ost,1,7);stn=substr(ost,9,7);st2_=serr;
        if substr(sto,1,2)='F0' then sto='***'||substr(sto,4,4);/*заплатка на ошибку, 28.10.2016*/
                output prig;end;end;run;

proc sql;create table b1 as select *,max(sum(case when kit=0 then 0 else 1 end),
        sum(case when ns=0 then 0 else 1 end)) as mx_kol,count(*) as kol,sum(delt) as ssdelt
        from b1 group by nombl;quit;

data b1;set b1;run;
proc sort data=b1;by nombl nds;run;

proc sql;create table b as select nombl,sum(kit) as kit,sum(ns) as ns
        from b1 group by 1 /*having kit^=ns*/ order by nombl;
create table b1_not as select * from b1 where nombl in(select nombl from b where kit=ns) order by nombl;quit;
data b;set b;where kit^=ns;delt=kit-ns;run;


proc sql;create table prig_ as select stp,sto,stn,sum(kit) as kit,sum(ns) as ns
        from prig group by 1,2,3 /*having kit^=ns*/ ;quit;
data prig_;set prig_;d=kit-ns;run;
proc sql;create table prig_stp as select stp,sum(kit) as kit,sum(ns) as ns,sum(d) as d,count(*) as kol
        from prig_ group by 1 /*having kit^=ns*/ ;
create table prig_ston as select sto,stn,sum(kit) as kit,sum(ns) as ns,sum(d) as d,count(*) as kol
        from prig_ group by 1,2 /*having kit^=ns*/ ;
create table prig_stop as select sto,stp,sum(kit) as kit,sum(ns) as ns,sum(d) as d,count(*) as kol
        from prig_ group by 1,2 /*having kit^=ns*/ ;
create table prig_sto as select sto,sum(kit) as kit,sum(ns) as ns,sum(d) as d,count(*) as kol
        from prig_ group by 1 /*having kit^=ns*/ order by kit ;
create table prig_stn as select stn,sum(kit) as kit,sum(ns) as ns,sum(d) as d,count(*) as kol
        from prig_ group by 1 /*having kit^=ns*/ order by kit ;
create table prig_s as select sum(kit) as kit,sum(ns) as ns,sum(d) as d,sum(abs(d)) as ad
        from prig_;quit;

proc sql;create table b1_sum as select skp,nds,sum(kit) as kit,sum(ns) as ns,sum(kit)-sum(ns) as delt from b1 group by 1,2;quit;
proc sql;create table b1_sum_i as select skp,nds,pr_d,sum(kit) as kit,sum(ns) as ns,sum(kit)-sum(ns) as delt from b1 group by 1,2,3;quit;
proc sql;create table b1_not_iloc as select nombl,skp,sum(kit) as kit,sum(ns) as ns,sum(kit)-sum(ns) as delt
        from b1 group by 1,2 having delt^=0;quit;


proc sql;create table b1(drop=sdelt) as select * from
        (select *,sum(delt) as sdelt from b1 group by nombl,skp,nds,pr_d) as a where sdelt^=0;quit;
proc sql;create table b1_bd(drop=sdelt) as select * from
        (select *,sum(delt) as sdelt from b1 group by nombl) as a where sdelt^=0;quit;

data b_isp;set b1;where /*kit^=0 and*/ ns^=0;delt=kit-ns;/*if delt^=250*round(delt/250) and delt^=123*round(delt/123)
         and delt^=437*round(delt/437)and delt^=752*round(delt/752)and delt^=435*round(delt/435)
        and delt^=135*round(delt/135)
        and delt^=433*round(delt/433)
        then output;*/run;



/* Итоговые расхождения  */
data itog;set b1 prig;label nombl='номер бланка' kit='возможно верные данные' ns='данные реестра' skp='код перевозчика' nds='%НДС'
        delt='расхождение' stp='ст.продажи' sto='ст.отправления' stn='ст.назначения';
        if stp^=. then nombl='пригород';delt=kit-ns;drop mx_kol kol st2_ sto stn stp;run;
data itog_;set itog;output;skp=9999;output;run;
data itog_;set itog_;output;nds=9999;output;run;
proc sql;create table itog_ as select skp,nds,'  ИТОГ      ' as nombl,sum(kit) as kit,sum(ns) as ns,sum(delt) as delt,count(*) as kol
        from itog_ group by 1,2,3;quit;
proc sql;create table itog_2 as select skp,nds,pr_d,'  ИТОГ      ' as nombl,sum(kit) as kit,sum(ns) as ns,sum(delt) as delt,count(*) as kol
        from itog group by 1,2,3,4;quit;

data itog;set itog_ itog;format  kit ns delt nds skp 12. ;run;
proc sort data=itog;by skp nds nombl;run;
/*PROC DBLOAD DBMS=EXCEL DATA=itog;PATH="d:/Итог расхождений 2015_01";
PUTNAMES yes;LABEL;RESET ALL;LIMIT=0;LOAD;RUN;*/







proc sql;create table b1_plus as select * from b1_new where nombl not in (select nombl from b1);quit;




proc sql;create table prig



proc sql;create table bb as select distinct nombl from b1;quit;
DATA Bb;set bb;put nombl ',' @;run;



data _null_;set prig_;put stp sto stn;run;


data b1_bad;set b1;where nombl in('ГЖ 0613725');run;

data b1_new;set b1;where kit+delt^=0;run;
proc sql;create table b1_pr as select skp,dd,sum(delt) as delt,count(*) as kol from b1_new group by 1,2;quit;
data b1_pr;set b1_pr;where delt^=0;drop delt kol;run;
proc sql;create table b1_new as select * from b1_new as a join b1_pr as b on a.skp=b.skp and a.dd=b.dd
        order by skp,dd,nombl;quit;



/*proc sql;create table st as select distinct stn as st from prig_;quit;
data _null_;set st;s= "'"||st|| "',";put s @;if _n_=5*round(_n_/5) then put;run;*/





data b_bad;set b1;where nombl in('ЦБ 0059139','А  0008015');run;



/**/

data prig_isp;set prig_;ad=abs(d);run;
proc sql;create table prig_isp(drop=dd) as select *,sum(d) as dd from prig_isp group by stp having dd^=0;quit;
proc sql;create table prig_isp(drop=dd) as select *,sum(d) as dd from prig_isp group by sto having dd^=0;quit;
proc sql;create table prig_isp(drop=dd) as select *,sum(d) as dd from prig_isp group by stn having dd^=0;quit;
proc sql;create table prig_isp(drop=dd) as select *,sum(d) as dd from prig_isp group by stp,stn having dd^=0;quit;
proc sql;create table prig_isp(drop=dd) as select *,sum(d) as dd from prig_isp group by stp,sto having dd^=0;quit;
proc sql;create table prig_isp(drop=dd) as select *,sum(d) as dd from prig_isp group by sto,stn having dd^=0 order by sto,stn,stp;quit;
proc sql;create table prig_isp(drop=dd) as select *,sum(d) as dd from prig_isp group by ad having dd^=0;quit;
proc sql;create table prig_isp(drop=dd) as select *,sum(d) as dd from prig_isp group by ad,sto,stn having dd^=0;quit;
proc sort data=prig_isp;by sto stn stp;run;


proc sql;create table prig_isp_ as select sto,stn,sum(kit) as kit,sum(ns) as ns,sum(d) as dd
        from prig_isp group by sto,stn having dd^=0 order by kit;quit;


proc sql;create table prig_stpn as select *,sum(d) as dd,sum(abs(d)) as ad
        from prig_ group by stp,stn;quit;

data pr;set prig;ad=abs(delt);run;


data _null_;set prig_2;where d^=0;st="'"||stp||"',";put st @;run;

data _null_;set b1;where kol=1;nb="'"||nombl||"',";put nb @;run;

data b_isp_;set b_isp;where skp=0 and nds=0;run;
data b_isp_;set b1;where skp=0 ;run;

data prig_bad;set prig;where sto='2704600' and stn='2704840';run;


proc sql;create table b1_sver as select nombl,
        sum(case when nds=. then kit end) as kit_n,
        sum(case when nds=0 then kit end) as kit_0,
        sum(case when nds=12 then kit end) as kit_12,
        sum(case when nds=18 then kit end) as kit_18,
        sum(case when nds=. then ns end) as ns_n,
        sum(case when nds=0 then ns end) as ns_0,
        sum(case when nds=12 then ns end) as ns_12,
        sum(case when nds=18 then ns end) as ns_18
        from b1 group by 1;quit;


data b1_sver_;set b1_sver;where kit_12=ns_n

proc sql;create table b1_otch as select skp,nombl,
        sum(case when nds=0 then kit-ns else 0 end) as delt_0,
        sum(case when nds=12 then kit-ns else 0 end) as delt_12,
        sum(case when nds=18 then kit-ns else 0 end) as delt_18,
        sum(case when nds=. then kit-ns else 0 end) as delt_n
        from b1 group by 1,2
        order by skp,abs(delt_0),abs(delt_12),abs(delt_18),abs(delt_n),nombl;quit;
PROC DBLOAD DBMS=EXCEL DATA=b1_otch;PATH="d:\расхождения по бланкам";
PUTNAMES yes;LABEL;RESET ALL;LIMIT=0;LOAD;RUN;

data b_bad;set b1;where delt=3723;run;

/*'рЕ 0892007'*/
data b_bad;set b1;where nombl like '%227863%';run;

data prig_bad;set prig_;where stp='2707726';run;


proc sql;create table st as select distinct stn as st from prig_;quit;
data _null_;set st;s="'"||trim(st)||"',";put s @;if _n_=5*round(_n_/5) then put;run;


data prig_sts;set prig_;kst=stp;p=1;output;kst=sto;p=2;output;kst=stn;p=3;output;keep kst p;run;
proc sql;create table prig_sts as select distinct p,kst from prig_sts;quit;
data _null_;set prig_sts;if lag(p)^=p then do;put;put;end;s="'"||kst||"',";put s @;run;


data prig_bad;set prig_;where stp in('2707700');run;
data prig_bad2;set prig_;where sto='2708000' and stn='2708893';run;


data prig_bad3;set prig_;where sto='2708000' and stn='2708895' and stp='2707702';run;


proc sql;create table b_not as select * from b1 where nombl not in(select nombl from b) order by nombl,nds,kit;quit;


/* выдача всех проблемных бланков небагажных */
data bb;set b1;bl=nombl;where skp^=99 /*and kol=2 and mx_kol=1*/;/** /where substr(nombl,1,2)='ЦА' and skp=0 and nds=12;/**/
        /**/output;nombl=substr(bl,1,2)||'*'||substr(bl,4,7);output;
        nombl=substr(bl,1,2)||substr(bl,4,7);output;/**/nombl=substr(bl,1,2)||'Ю'||substr(bl,4,7);output;
         /**/nombl=substr(bl,1,2)||'Я'||substr(bl,4,7);output;/**/nombl=substr(bl,1,2)||'И'||substr(bl,4,7);output;/**/
        keep bl nombl;run;
proc sort data=bb nodup;by bl nombl;run;
/* proc sql;create table bb as select * from bb where nombl not in(select nombl from mylib.prov_blanki) order by nombl;quit; */


/*блоки не более 15000записей - не справляется иначе */
dm 'clear log';
data _null_;set bb;if _n_>0000 and _n_<=10000 then do;s="'"||trim(nombl)||"',";put s @;if _n_=5*round(_n_/5) then put;end;run;





/* выдача только багажных проблемных бланков */
data bb;set b1;where skp=99 or length(trim(left(substr(nombl,1,2))))=1;
        bl=nombl;nombl=substr(bl,1,2)||substr(bl,4,7);output;
        keep nombl;run;
proc sort data=bb nodup;by nombl;run;
/* proc sql;create table bb as select * from bb where nombl not in(select nombl from mylib.prov_blanki) order by nombl;quit; */

dm 'clear log';
data _null_;set bb;if _n_>0000 and _n_<=10000 then do;s="'"||trim(nombl)||"',";put s @;if _n_=5*round(_n_/5) then put;end;run;



/*выдача списка пригородных разночтений для выборки*/
dm 'clear log';
data _null_;set prig_;  run;








/*только для удалений*/
data bb;set b1;bl=nombl;
 /**/output;nombl=substr(bl,1,2)||'*'||substr(bl,4,7);output;
        nombl=substr(bl,1,2)||substr(bl,4,7);output;/**/nombl=substr(bl,1,2)||'Ю'||substr(bl,4,7);output;
        /**/nombl=substr(bl,1,2)||'Я'||substr(bl,4,7);output;/**/nombl=substr(bl,1,2)||'И'||substr(bl,4,7);output;/**/
       nombl=substr(bl,1,2)||substr(bl,4,7);output;
        keep nombl;run;
proc sort data=bb nodup;by nombl;run;
/* proc sql;create table bb as select * from bb where nombl not in(select nombl from mylib.prov_blanki) order by nombl;quit; */

dm 'clear log';
data _null_;set bb;if _n_>60000 and _n_<=70000 then do;s="'"||trim(nombl)||"',";put s @;if _n_=5*round(_n_/5) then put;end;run;



data prig_stp;set  prig_stp;s= "'"||stp||"',";put s @;
if _n_=round(_n_/6)*6 then put;run;


data prig_sto;set  prig_sto;s= "'"||substr(sto,4,4)||"',";put s @;
if _n_=round(_n_/7)*7 then put;run;

data prig_stn;set  prig_stn;s= "'"||stn||"',";put s @;
if _n_=round(_n_/6)*6 then put;run;



/*  data mylib.prov_blanki;set mylib.prov_blanki bb;run;
        proc sort data=mylib.prov_blanki nodup;by nombl;run;   */

proc sql;create table b1__ as select * from b1 where nombl in('ДИ 0230132','ДЕ 0353778','ДЕ 0353777');quit;



proc sql;create table b1_new as select * from b1 where nombl not in(select distinct nombl from b1_old);quit;



/*выборка пригорода, по посчитанным бланкам*/
proc sql;create table prig_prov as select * from prig_ as a,
        (select distinct sto,stp,d as dd from prig_stop where d^=0) as b
        where a.sto=b.sto and a.stp=b.stp;quit;

data pr;set prig_prov;/*where d=dd;*/
st= "or (substr(stanotp,4,4)='"||substr(sto,4,4)||"' and stannazn='"||stn||"' and stanfu='"||stp||"')";put st;run;
/** /data pr;set prig_ston;where kit<100000000;
st= "or (stanotp='"||sto||"' and stannazn='"||stn||"')";put st;run;
/**/


/*выборка пригорода, по потерянным бланкам, которых не найти перебором имеющихся в реестре*/
data pr;set prig_ston;
st= "or (substr(stanotp,4,4)='"||substr(sto,4,4)||"' and stannazn='"||stn||"')";put st;run;


/*************/






proc sql;create table b1_blan as select distinct nombl from b1 where skp=0;quit;
data _null_;set b1_blan; put nombl ',' @;run;


data _null_;set b1;if _n_<7 then put nombl;run;



Proc sql;create table prig_ston_ as select stn as st,sum(kit) as kit from prig_ston
        /*where sto in('2708900', '2708950', '2708000')*/ group by 1 order by 2;quit;

data _null_;set prig_ston_;if _n_>000 and _n_<=60000 then do;s="'"||trim(st)||"',";put s @;if _n_=5*round(_n_/5) then put;end;run;



data _null_;set b1;dd=ns-kit;put nombl nds kit ns dd;run;


/*proc sql;create table b1_put as select distinct nombl,skp,nds,kit,ns,delt from b1;quit;
data b1_put;set b1_put;label kit='A' ns='B';run;

proc sql;create table b1_put as select distinct * from prig_;quit;
data b1_put;set b1_put;label kit='A' ns='B';run;

PROC DBLOAD DBMS=EXCEL DATA=b1_put;PATH="d:/расхождения";
PUTNAMES yes;LABEL;RESET ALL;LIMIT=0;LOAD;RUN;
*/









/*а теперь другая программа - разобрать результат работы */
%let name_rez='D:/rezult.txt';
%macro rez;
/* чтение файла побайтно */
data file;infile &name_rez recfm=n;format v $1.;input V $char1. @@;if rank(v)=0 then v=' ';run;
/*разбиения на строки*/
data file;set file;retain str 1 stb del 0;length c stb 4;c=rank(v);if c in(13,10) then del=0;
        stb+1;if del=0 then output;if c=10 then do;str+1;stb=0;del=0;end;
        if stb=2 and v='-' and lag(v)='-' then del=1;drop del;run;
data nil;run;
data fl_;set file nil;retain lstr mstb 0;if lstr^=str then do;if lstr>0 then output;mstb=0;end;
        if c not in(32,13,10) then mstb=stb;lstr=str;keep lstr mstb;run;
data fl_;set fl_;str=lstr;drop lstr;run;

data file;merge file fl_;by str;if stb<mstb or c^=32 then output;drop mstb;run;

/*вывод в файл побайтно*/
data _null_;set file;file &name_rez delimiter=' '  lrecl=32767;vv=byte(13);if lag(c)=13 and c^=10 then put vv $1. @@;
        if lag(c)=13 and c=10 then put;if c not in(13,10) then put v $1. @@;run;
proc sql;drop table file,fl_,nil;quit;
%mend;


%rez;



data prig_rez;infile 'c:/prig rezult_ast.txt' delimiter='00'x;format st $200.;input st;l=length(st);l=length(st);
        if l=145 and substr(st,1,6)^='STANFU' then do;format stp sto_ stn_ $7. st2_ $3. nombl $15.;
stp=substr(st,1,7);sto_=substr(st,25,7);stn_=substr(st,34,7);
        sbil=substr(st,44,16)*1;sbili=substr(st,63,16)*1;sp=substr(st,82,16)*1;susl=substr(st,107,10)*1;kol=substr(st,136,10)*1;
        nombl=substr(st,120,15);st2_=substr(stn_,5,3);sbil=sbil+sbili;
        output;end;drop st l  sbili sp susl;run;

proc sql;create table prig_rez as select *,count(*) as kolr,sum(sbil) as sumbil from prig_rez group by stp,st2_;quit;


proc sql;create table prig_sr as select * from prig as a,prig_rez as b where a.stp=b.stp and a.st2_=b.st2_;quit;



proc sql;create table prig_sr_b as select *,sum(kol) as kol_bil,count(*) as kol_zap
        from prig_sr where kit^=ns group by stp,st2_ having kol_zap=kol_bil order by kol_bil,stp,st2_;quit;

Proc sort data=prig_sr_b;by nombl;run;

data _null_;set prig_sr_b;format s $13.;
        s="'"||trim(left(nombl))||"',";put s @;if _n_=5*round(_n_/5) then put;run;




/*
обработка результатов запроса
  SELECT NOMBL,BIL,SUSL FROM                                            00010047
  (SELECT NOMBL,SUM(SBIL+SBILI+SP) AS BIL,SUM(SUSL) AS SUSL             00011047
    FROM ZREESTR2 GROUP BY NOMBL)AS A WHERE BIL<>0                      00012046
    ORDER BY NOMBL;
rezult_ast Казахи итог
*/


data rez;infile 'c:/rezult_ast Казахи итог.txt' delimiter='00'x;format st $80.;input st;l=length(st);l=length(st);
        retain iz 0;if substr(st,1,5)='NOMBL' then iz=1;
        if substr(st,1,4)='DSNE' then iz=2;ruc='1';ruc=substr(st,54,1);
        if iz=1 and l=54 and substr(st,1,5)^='NOMBL' then output;run;
data rez;set rez;format nombl $10.;nombl=substr(st,1,10);nombl=substr(nombl,1,2)||' '||substr(nombl,4,7);
        dn=1*substr(st,11,21);SUSL=1*substr(st,33,18);keep nombl dn susl ruc;run;

proc sql;create table rez_ as select nombl,sum(dn) as dn,sum(susl) as susl from rez group by 1;quit;

proc sql;create table sr as select * from b  as a,rez_ as b where a.nombl=b.nombl order by nombl;quit;
data sr;set sr;delt_=kit-dn;run;
data sr_b;set sr;where kit^=dn and kit^=dn+susl and kit^=dn-susl;run;





proc sql;create table rez_b as select * from rez as a,sr_b(keep=nombl kit delt_) as b where a.nombl=b.nombl;quit;
proc sql;create table rez_b as select *,count(*) as kol from rez_b group by nombl;quit;

data rez_b_;set rez_b;where ruc='Э' and kol=1;s="'"||nombl||"',";put s @;if _n_=5*round(_n_/5) then put;drop s;run;


%let nombl='АА 0004615','АА 0007468','ГВ 0005298';
%put &nombl;
data b_bad;set b1;where nombl in(&nombl);run;
data sr_bad;set SR;where nombl in(&nombl);run;



proc sql;create table b_ost as select * from b where nombl in(select nombl from rez)
        and nombl not in(select nombl from sr_b);quit;

proc sql;create table rez_ost as select * from rez where nombl in(select nombl from b_ost);quit;












































/*******************************/

data r1;infile 'd:/est_excel.txt' delimiter='00'x;format st $180.;input st;run;
data r1;set r1;format nombl $10.;nombl=substr(st,1,10);summ=substr(st,40,9)*1;ser='11';ser=nombl;
        bil=substr(st,12,9)*1;pl_s=substr(st,22,9)*1;serv=substr(st,32,7)*1;run;
proc sql;create table r2 as select ser,sum(bil+pl_s) as summ,count(*) as kol from r1 group by 1;quit;

proc sql;create table r3 as select sum(summ) as summ,sum(bil+pl_s) as sm from r1;quit;


data rv;infile 'd:/ast_excel.txt' delimiter='00'x;format st $180.;input st;l=length(st);l=length(st);run;
data rv;set rv;format nombl $10.;nombl=substr(st,1,10);sumv=substr(st,18,17)*1;koll=substr(st,4,13)*1;ser='11';ser=nombl;
        retain nn 0;if ser='--' then nn+1;IF SER='DS' THEN NN=-10;if nn>=3  and st^='SER' AND SER^='--' then output;keep ser sumv koll;run;

proc sort data=rv;by ser;run;


data rr;merge r2 rv;by ser;d=summ-sumv;if summ^=sumv then output;run;


data r1_;set r1;where ser='ВШ';run;
proc sort data=r1_;by st;run;


data r1___;set r1;where st like '%ВШ%455998%';run;





/***********************************************************************************************/
/*пригород по расстояниям*/

rsubmit;
proc sql;create table agr_rst as select year,month,chp,arn,rasst,par_name,sum(param) as param
        from expolap.prig_agr_rasst where vid_lgt='all' and par_name in('plata','s_pot') and dorp=1
        group by 1,2,3,4,5,6;quit;
        endrsubmit;



proc sql;create table agr_rst as select year,month,min(round(rasst/10)*10,150) as rasst,par_name,sum(param) as param
        from workpro.agr_rst where chp=23
        group by 1,2,3,4;quit;


proc sql;create table agr_rst as select year,month,rasst,
        sum(case when par_name='plata' then param else 0 end) as plata,
        sum(case when par_name='s_pot' then param else 0 end) as s_pot
        from agr_rst group by 1,2,3;quit;

data agr_rst;set agr_rst;dt=mdy(month,28,year);dohod=(plata+s_pot)/10000000;format dt date9.;run;

proc sort data=agr_rst;by rasst dt;run;


proc gplot data=agr_rst;plot dohod*dt;by rasst;symbol i=join;where dt>'01jan2010'd;run;quit;






data rd;set expolap.prig_agregati_read;where spr_name='prig_day_otp';run;
proc sort data=rd;by dtdok;run;








/***********************************************/




data pr_kzx;infile 'd:/приг 07_2014 1пачка.txt' delimiter='00'x;format st $200.;input st;l=length(st);l=length(st);
format dt_ nombl  $10.;
s='1';s=substr(st,11,1);r=rank(s);ii=0;t=0;
do i=1 to l;if substr(st,i,1)=s then do;t+1;zz=substr(st,ii+1,i-ii-1);
        if t=1 then dt_=zz;
        if t=2 then zak=1*zz;
        if t=3 then summ=1*zz;
        if t=4 then nombl=zz;ii=i;end;end;
format dt date9.;dt=mdy(substr(dt_,6,2),substr(dt_,9,2),2014);mes=month(dt);keep dt nombl zak summ mes dt_ ;run;

proc sql;create table pr_kzx_sum as select mes,sum(summ) as summ,count(*) as kol from pr_kzx group by 1;quit;


data pr_moi;infile 'd:/приг 07_2014 2пачка мои.txt' delimiter='00'x;format st $200.;input st;format dt date9. nombl $10.;
if substr(st,1,4)='2014' then do;dt=mdy(substr(st,6,2),substr(st,9,2),2014);
        zak=1*substr(st,12,9);nombl=substr(st,24,10);sbil=substr(st,36,17)*1;mes=month(dt);
        nombl=substr(nombl,1,3)||substr(nombl,5,6);output;end;drop st;run;



proc sql;create table pr_sr as select max(a.mes,b.mes) as mes,max(a.dt,b.dt) as dt format date9.,
        case when a.nombl is not null then a.nombl else b.nombl end as nombl,max(a.zak,b.zak) as zak,
        sbil,summ from pr_kzx as a full join pr_moi as b
        on a.nombl=b.nombl and a.dt=b.dt and a.mes=b.mes and a.zak=b.zak;quit;

data pr_sr_;set pr_sr;where nombl like '%ДГ%776925%';run;


data pr_sr_;set pr_sr;where mes=6 and sbil^=summ;if sbil=. then sbil=0;if summ=. then summ=0;run;


proc sql;create table pr_sr_ as select nombl,dt,zak,sum(sbil) as sbil,sum(summ) as summ from pr_sr group by 1,2,3 having sbil^=summ;quit;

proc sql;creaTE TABLE PR_KZX_ AS SELECT mes,sum(summ) as summ from pr_kzx group by 1;quit;





























/**/
