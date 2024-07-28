

libname ml 'd:\mylib\poezda';
libname opt 'd:\mylib\optimiz_lokom';
libname mylib 'd:\mylib\prigorod';

/*dm 'afa c=ml.connects.link.frame';

dm 'afa c=ml.otcheti_vpt_prig.connect.frame';*/




rsubmit;libname pgt db2 authid=pgt;endrsubmit;libname pgt slibref=pgt server=proizvod;

rsubmit;libname tst db2 authid=tst;endrsubmit;libname tst slibref=tst server=otladka;


rsubmit;libname vpt db2 authid=vpt;endrsubmit;libname vpt slibref=vpt server=proizvod;

rsubmit;libname vpt db2 authid=vpt;endrsubmit;libname vpt slibref=vpt server=otladka;


rsubmit;libname xran db2 authid=xran;endrsubmit;libname xran slibref=xran server=proizvod;

/**********************************************************************************************/


/*Задача - построить оптимум, но не только по локомотивам, но одновременно и локомотивным бригадам */



/*зазача на решение коммивояжёра методом муравьёв*/
/*ЧАСТЬ ВТОРАЯ - ОПТИМИЗАЦИЯ РАБОТЫ ЛОКОМОТИВОВ ЭТИМ АЛГОРИТМОМ*/
%let speed=50;%let seed=1.00;
%let kol_depo=5;
%let kol_pzd=30;



/*исходные цены на работы*/
data cena;seed=round(&seed);do depo=1 to &kol_depo;
        call ranuni(seed,c);c_st=100*(c+5);/*цена (?простоя)жизни локомотива, за сутки*/
        call ranuni(seed,c);c_rst=2+c;/*цена холостого пробега, за 1км*/
        call ranuni(seed,c);c_gruz=10+15*c;/*цена грузового пробега, за 1км*/
        call ranuni(seed,c);c_scep=1.5*(c+1);/*цена одной переприцепки*/
        call ranuni(seed,c);c_br=2*(c+5);/*цена жизни лок.бригады, за сутки (её работа и холостой ход - входят в локомотив)*/
                output;end;drop c seed;run;
data cena;set cena;tb='5';run;


/*граф дороги - беру не только узловые станции, но и через каждые 50км - для остановок в пути */
data lin;set opt.graf_lin_str;where dat_end='31dec2095'd and dor=1;label kst=' ';run;
proc sql;create table lin as select *,count(*) as kol from lin group by kst;
        create table lin as select *,max(rast) as rst from lin group by kl order by dor,kl,rast;quit;

data lin;set lin;retain rr 0;if kol>1 or (rast=0 or rast=rst) or (rast-rr>50) then do;rr=rast;output;end;keep kl kst rast rst;run;
/*data lin;set lin;where kol>1 or (rast=0 or rast=rst);keep kl kst rast rst;run;*/
proc sort data=lin;by kl rast;run;

proc sql;create table st as select distinct kst from lin;quit;
data st;set st;st_n=_n_;call symput('kol_st',st_n);run;

/* список всех перегонов */

data pereg;set lin;st1=lag(kst);st2=kst;rs=rast-lag(rast);keep st1 st2 rs p;p=1;
        if lag(kl)=kl then output;run;
data pereg;set pereg;output;c=st1;st1=st2;st2=c;output;drop c p;run;
data pereg;set pereg;output;st2=st1;rs=0;output;run;
proc sort data=pereg nodup;by st1 st2 rs;run;

proc sql;create table pereg as select st1,st2,rs,b.st_n as n_st1,c.st_n as n_st2
        from pereg as a join st as b on st1=b.kst join st as c on st2=c.kst order by st1,st2;quit;
data pereg;set pereg;per_n=_n_;run;

/*матрица расстояний между станциями*/
%macro rast;
%let kolz=0;
proc sql;create table rast as select distinct a.kst as st1,b.kst as st2,abs(a.rast-b.rast) as rst
        from lin as a,lin as b where a.kl=b.kl /*and a.kst^=b.kst*/;quit;
%flag:;%let kolzp=&kolz;
proc sql;create table rast as select a.st1,b.st2,min(a.rst+b.rst) as rst
        from rast as a,rast as b where a.st2=b.st1 /*and a.st1^=b.st2*/ group by 1,2;
reset noprint;select count(*) into:kolz from rast;quit;
%if %sysevalf(&kolzp<&kolz) %then %goto flag;
%mend;
%rast;

proc sql;create table rast as select st1,st2,rst,b.st_n as n_st1,c.st_n as n_st2
        from rast as a join st as b on st1=b.kst join st as c on st2=c.kst order by st1,st2;quit;


/* задание локомотивных депо - 10 точек, и макс расстояния посчитать */
data depo;set st;r=ranuni(1);run;
proc sort data=depo;by r;run;
data depo;set depo;depo=_n_;if _n_<=&kol_depo then output;keep kst depo;run;


proc sql;create table depo as select * from rast,depo where st1=kst;
create table depo as select *,min(rst) as r from depo group by st2;
create table depo as select depo,st2,rst from depo where rst=r order by depo;
create table depo2 as select distinct depo,b.st2 from depo as a,pereg as b where a.st2=b.st1;
create table depo3 as select distinct depo,b.st2 from depo2 as a,pereg as b where a.st2=b.st1;quit;
data depo;set depo depo2 depo3;run;
proc sql;drop table depo2,depo3;
create table depo as select distinct depo,st2 as kst from depo;quit;





proc sql;create table depo_per as select b.depo,st1,st2,rs,n_st1,n_st2,per_n
        from pereg as a join depo as b on a.st1=b.kst
        join depo as c on b.depo=c.depo and a.st2=c.kst order by st1,st2,rs,depo;quit;

proc sql;create table pereg as select * from pereg where per_n in(select per_n from depo_per) order by st1,st2,rs;quit;
data pereg;set pereg;per_n=_n_;run;
data depo_per;set depo_per;drop per_n;run;
data depo_per;merge depo_per pereg;by st1 st2 rs;run;

/*ставлю максимальный холостой пробег не длиннее максимума(максимального перегона в данном депо, или 200км)*/
proc sql;create table depo_rast as select b.depo,st1,st2,a.rst,n_st1,n_st2
        from rast as a join depo as b on a.st1=b.kst
        join depo as c on b.depo=c.depo and a.st2=c.kst
                order by depo,st1,st2,rst;quit;
proc sql;create table depo_rast/*(drop=rs)*/ as select * from depo_rast as a,
        (select depo,max(rs) as rs from depo_per group by depo) as b
        where a.depo=b.depo /*and rst<=rs*/ order by depo,st1,st2,rst;quit;
data depo_rast;set depo_rast;where rst<=max(rs,200);drop rs;run;





/*задаём расписание поездки - от и до, сутки=1ед времени. после каждого перегона стоянка=время пред езды. езда всюду 50км.ч.*/
data rasp;set rast;where rst>1000 and rst<1500 and st1<st2;r=ranuni(1);run;
proc sort data=rasp;by r;run;
data rasp;set rasp;mars=_n_;rast=rst;if _n_<=&kol_pzd then output;drop r rst;run;


proc sql;create table rasp2 as select mars,a.st1,a.st2,rast,b.st2 as st3,b.rst
        from rasp as a join rast as b on a.st1=b.st1 and rast>=b.rst
        join rast as c on a.st2=c.st1 and b.st2=c.st2 and b.rst+c.rst=rast order by mars,b.rst;quit;
data rasp3;set rasp2;st1=lag(st3);st2=st3;rs=rst-lag(rst);if lag(mars)=mars then output;keep mars st1 st2 rs;run;
proc sort data=rasp3 nodup;by st1 st2 rs;run;
data rasp3;merge rasp3 pereg;by st1 st2 rs;if per_n=. then output;run;
proc sql;create table rasp2 as select * from rasp2 where mars not in(select mars from rasp3) order by  mars,rst;
        drop table rasp3;quit;
data rasp2;set rasp2;output;mars=-mars;rst=round(rast-rst);c=st1;st1=st2;st2=c;output;drop c;run;
proc sort data=rasp2;by mars rst;run;

/*mars_nm сделан прерывающимся на 1 между поездами специально. чтобы знать: след^=пред+1 значит была переприцепка */
data rasp3;set rasp2;retain tm;
        st1=lag(st3);st2=st3;rs=rst-lag(rst);tm1=tm;dt=rs/(24*&speed);tm2=tm+dt;dt=dt*ranuni(1);
        if dt<0.01 then dt=0.01;if dt>0.1 then dt=0.1;tm=tm2+dt;if rst=0 then tm=ranuni(1);mars_nm=_n_;
                tm1=round(tm1*100000)/100000;tm2=round(tm2*100000)/100000;
        if lag(mars)=mars then output; keep mars st1 st2 rs tm1 tm2 mars_nm;run;
/*липовые работы - для пересадок локомотивных бригад*/
data rasp3;set rasp3;mars_nm=2*mars_nm-1;output;st1=st2;tm1=tm2;rs=0;mars_nm=mars_nm+1;output;run;
data rasp3;set rasp3;flag:;if tm1>=1 then do;tm1=tm1-1;tm2=tm2-1;goto flag;end;run;

proc sort data=rasp3;by st1 st2 rs mars;run;
data rasp3;merge rasp3 pereg;by st1 st2 rs;if mars^=. then output;run;


proc sort data=rasp3 out=raspis;by per_n tm1;run;
data raspis;set raspis;rasp=_n_;run;
proc sql;drop table rasp1,rasp2,rasp3;quit;

proc sort data=depo_per;by depo per_n;run;
proc sort data=depo_per out=per_depo;by per_n depo;run;




/*надо - для каждого депо составить таблицу всех возможных переходов от работы к работе, с потребными ресурсами */

proc sql;create table raspis_depo as select rasp,a.n_st1,a.n_st2,a.rs,tm1,tm2,a.per_n,depo,mars_nm,mars
        from raspis as a,depo_per as b where a.per_n=b.per_n order by rasp,depo;quit;
/*proc sort data=raspis_depo out=depo_raspis;by depo rasp;run;*/



/*исходные вероятности переходов*/
proc sort data=raspis out=ver;by mars mars_nm;run;
data ver;set ver;rasp1=lag(rasp);rasp2=rasp;per1=lag(per_n);per2=per_n;p=1;;
        if lag(mars)=mars then output;else do;if abs(mars)<=3 then do;rasp1=0;per1=0;output;end;end;
        keep rasp1 rasp2 p per1 per2;run;
proc sql;create table ver as select distinct rasp1,rasp2,per1,per2,c.depo
        from ver as a join per_depo as b on b.per_n=per1 or per1=0
        join per_depo as c on c.per_n=per2 and (b.depo=c.depo or per1=0)
        order by rasp1,rasp2,depo;run;
data ver;set ver;retain sp;p=1;drop per1 per2;
        if lag(rasp1)^=rasp1 or (lag(depo)^=depo and rasp1^=0) then sp=0;sp=sp+p;run;




/*ВСЁ В МАКРОПЕРЕМЕННЫЕ*/
proc sql;reset noprint;
select max(st_n) into:kol_st from st;
select count(*) into:kol_rast from rast;
select max(depo),max(per_n),count(*) into:kol_depo,:kol_per,:kol_dep_per from depo_per;
select max(rasp),count(*) into:kol_rasp,:kol_dep_rasp from raspis_depo;
select count(*) into:kol_dep_rast from depo_rast;
select count(*) into:kol_ver from ver;
quit;
%let kol_stp=%sysevalf(&kol_st+1);%let kol_depop=%sysevalf(&kol_depo+1);
%let kol_dep_per=%sysevalf(1*&kol_dep_per);
%let kol_per2=%sysevalf(&kol_per*2);
%let kol_per=%sysevalf(&kol_per*1);%let kol_perp=%sysevalf(&kol_per+1);
%let kol_dep_rasp2=%sysevalf(&kol_dep_rasp*2);
%let kol_dep_rasp=%sysevalf(&kol_dep_rasp*1);
%let kol_deprast=%sysevalf(&kol_depo*&kol_st*&kol_st);
%let kol_deprasp=%sysevalf(&kol_depo*&kol_rasp);%put &kol_deprasp;
%let kol_rast=%sysevalf(&kol_rast*1);
%let kol_rasp3=%sysevalf(&kol_rasp*3);%let kol_raspn=%sysevalf(&kol_rasp+2);
%let kol_rasp=%sysevalf(&kol_rasp*1);%let kol_raspp=%sysevalf(&kol_rasp+1);
%let kol_ver=%sysevalf(&kol_ver*1);
%let kol_depo=%sysevalf(&kol_depo*1);
%let max_rasp=%sysevalf(&kol_rasp*2);


data _null_;c=max(4,length(trim(left(&kol_rasp))));call symput('dl_rasp',trim(left(c)));run;

%put &kol_st &kol_stp &kol_depo &kol_depop &kol_per &kol_dep_per &kol_rasp &kol_dep_rasp &kol_dep_rast &kol_deprast &kol_rast /&dl_rasp/;
%let k_dpr=%sysevalf(&kol_depo*&kol_stp);%put &k_dpr;
%let k_dpr_=%sysevalf(&kol_dep_rast*2);%put &k_dpr_;



data depo_rast;set depo_rast;tb='1';nn=_n_;run;
proc sort data=depo_rast;by depo n_st1 rst n_st2;

/*data pereg;set pereg;tb='2';run;*/

proc sort data=depo_per;by depo per_n;run;
data depo_per;set depo_per;tb='3';nn_dp=_n_;run;
proc sort data=depo_per;by per_n depo;run;
data depo_per;set depo_per;nn_pd=_n_;run;


/*data raspis;set raspis;tb='4';run;*/
proc sort data=raspis_depo;by depo rasp;run;
data raspis_depo;set raspis_depo;nn_dr=_n_;/*svrpos=nn_dr;*/run;
proc sort data=raspis_depo;by rasp depo;run;
data raspis_depo;set raspis_depo;tb='4';nn_rd=_n_;run;

data cena;set cena;tb='5';run;
data ver;set ver;tb='6';nn=_n_;run;

data nil;tb='0';run;






proc sql;create table raspis_brig as select * from raspis_depo order by depo,n_st1,tm1;quit;








data opt.resh;set opt.resh;/*keep variant rasp1 rasp2 depo stan1 stan2 nn rst rst_rab;*/
                length rasp1 rasp2 nn 4 depo stan1 stan2 rst rst_rab 3 variant 5;run;
data opt.resh_rez;set opt.resh_rez;length variant 5;format inn $1.;/*keep variant cena inn;*/run;












/* алгоритм чисто по вероятностям, без блужданий */
/*Запрещён переход локом бригад между станциями, без локомотива, или подвоз попутно*/


%let ver_sluc=0.01;%let koef_mar=1;
%macro step_lokom;/*постановка вероятностей*/

data _null_;k=round(&kol_rasp*&koef_mar);call symput('kol_ostavl',trim(left(k)));run;
%let kol_ost=%sysevalf(&kol_rasp*2);
%put /&kol_ostavl/;/*сколько в итоге хороших решений нужно оставить*/


%let kol_ver_d=1;%let kol_ver_n=1;%let kol_ver_dl=1;
/*поставить полную случайность при изначальном отсутствии данных*/

/*data dt;tm=time();run;*/

proc sql;reset noprint;select case when v is null then 0 else v end  into :vv from
        (select max(variant) as v from opt.resh_rez /*where inn^='0'*/);quit;
%put &vv &kol_ost;

%if %sysevalf(&vv>=&kol_ost) %then %do;
proc sql;create table ver as select zz,rasp1,depo,abs(rasp2) as rasp2,/*count(*)*/ sum(vkoef) as kol
        from opt.resh where rasp2^=0 group by 1,2,3,4 order by 1,2,3,4;quit;

%end;

%else %do;
data ver;if rasp1=1 or rasp2=1 or depo=1 then output;run;
/** /data ver;set raspis_depo;rasp1=rasp;keep rasp1 depo n_st2;run;
PROC SQL;CREATE TABLE VER AS SELECT rasp1,a.depo,n_st1 from ver as a,depo_rast as b
        where a.depo=b.depo and a.n_st2=b.n_st2;quit;
data ver;set ver;output;rasp1=0;output;run;
proc sort data=ver nodup;by n_st1 depo rasp1;run;
proc sql;create table ver as select rasp1,a.depo,b.rasp as rasp2
        from ver as a,raspis_depo as b where a.n_st1=b.n_st1 and a.depo=b.depo
        order by rasp1,depo,rasp2;quit;
/** /data ver;set ver;tb='7';retain nom -1;
        if lag(rasp1)^=rasp1 or(lag(depo)^=depo and rasp1^=0) then do;nom+1;call symput('kol_ver_d',trim(left(nom)));end;
        kol=1;run;/**/


proc sql;create table ver2 as select distinct a.rasp as rasp1,b.rasp as rasp2,a.depo,&kol_rasp/20 as kol
        from raspis_depo as a,raspis_depo as b where a.depo=b.depo and a.n_st2=b.n_st1
                and not (a.n_st1^=a.n_st2 and b.n_st1^=b.n_st2) and not (a.n_st1=a.n_st2 and b.n_st1=b.n_st2)
                and not (a.n_st1^=a.n_st2 and a.mars^=b.mars)
order by 1,2,3;quit;
data ver2;set ver2;output;rasp1=0;output;run;
proc sort data=ver2 nodup;by rasp1 depo rasp2;run;


/**/proc sort data=raspis out=ver_;by mars mars_nm;run;
data ver_;set ver_;rasp1=lag(rasp);rasp2=rasp;per1=lag(per_n);per2=per_n;p=1;;
        if lag(mars)=mars then output;else do;if abs(mars)<=3 then do;rasp1=0;per1=0;output;end;end;
        keep rasp1 rasp2 p per1 per2;run;
proc sql;create table ver_ as select distinct rasp1,rasp2,per1,per2,c.depo
        from ver_ as a join per_depo as b on b.per_n=per1 or per1=0
        join per_depo as c on c.per_n=per2 and (b.depo=c.depo or per1=0)
        order by rasp1,rasp2,depo;run;
data ver_;set ver_;retain sp;p=1;drop per1 per2;
        if lag(rasp1)^=rasp1 or (lag(depo)^=depo and rasp1^=0) then sp=0;sp=sp+p;run;
proc sort data=ver_;by rasp1 depo rasp2;run;

data ver;merge ver ver2 ver_;by rasp1 depo rasp2;if p=1 then kol=&kol_rasp/2;drop p sp;if kol=. then kol=1;zz='lok';run;
%end;


proc sql;reset noprint;select count(*) into:kol_zap_brig from ver where zz='br';quit;
%put &kol_zap_brig;
%if %sysevalf(&isp_brig^=0 and &kol_zap_brig=0) %then %do;

proc sql;create table ver2 as select distinct a.rasp as rasp1,a.depo,b.rasp as rasp2,1 as kol,'br ' as zz
        from raspis_depo as a,raspis_depo as b
        where a.depo=b.depo and a.n_st1=b.n_st2 and b.n_st1=a.n_st2;quit;
data ver;set ver ver2;run;
%end;

/**/





data ver;set ver;retain nom;
        if lag(rasp1)^=rasp1 or(lag(depo)^=depo and rasp1^=0) then do;nom+1;
                if rasp1=0 then nom=0;call symput('kol_ver_d',trim(left(nom)));end;run;
proc sql;create table ver as select *,sum(kol) as skol,count(*) as kk from ver group by zz,nom order by zz,nom,/*depo,*/-kol;
        reset noprint;select max(kk) into:kol_ver_dl from ver where rasp1^=0;
        select count(*) into:kol_ver_n from ver where rasp1=0;quit;
data ver;set ver;tb='6';keep rasp1 rasp2 depo kol tb nom zz;run;
data ver;set ver;if lag(nom)^=nom then nn=0;nn+1;run;

data _null_;if &kol_ver_n=0 then call symput('kol_ver_n',1);run;
%let kol_ver_n=%sysevalf(&kol_ver_n*1);
%let kol_ver_dl=%sysevalf(&kol_ver_dl*1);
%let kol_ver_dl4=%sysevalf(&kol_ver_dl*&dl_rasp);
%put &kol_ver_d &kol_ver_n /&kol_ver_dl/ &kol_ver_dl4;
%let kol_st2=%sysevalf(&kol_st*2);
%let kol_rasp2=%sysevalf(&kol_rasp*2);
%let kol_rasp4=%sysevalf(&kol_rasp*4);
%put &kol_rasp &kol_raspp &kol_raspn;


%let maxx=-1;
proc sort data=opt.resh_rez out=maxx;by cena;where inn='1';run;
data _null_;set maxx;call symput('maxx',trim(left(cena)));run;
proc sql;drop table maxx;quit;

%if %sysevalf(&isp_brig^=0 and &kol_zap_brig=0) %then %do;%let maxx=-1;%end;
%put &maxx;

/*dm 'clear log';*/

%let kol_var=100;%let variant=0;
proc sql;reset noprint;select max(variant),1000 into:variant,:kol_var from opt.resh_rez;
        select count(*) into :count_ver from ver;quit;

data f;variant=&variant;kol_ver=&count_ver;run;
data opt.stat;set opt.stat f;run;
data dt;set dt;dt=min(max(time()-tm,0),50);call symput('dt',dt);run;
%put &variant &kol_var &count_ver &dt;

%put =&kol_ver_d=;



proc sql;drop table resh,resh_rez,resh_br;quit;
data resh(keep=variant rasp1 rasp2 depo stan1 stan2 nn rst rst_rab  /** /cena tm_beg tmend tm_end /**/ nnn tm1_ tm2_ tm3_ tm4_ zz)
        resh_rez(keep=variant cena cena_rst cena_rab cena_scep cena_tm cena_brig kol_brig inn err isp_brig)
                /*resh_br(keep=variant rasp1 rasp2 depo  tm1_ tm2_)*/;
        set depo_rast /*pereg*/ depo_per /*per_depo*/ /*raspis*/ /*depo_raspis*/ raspis_depo cena ver nil;
                array dz[&kol_st,&kol_st];retain dz1-dz&kol_rast -1;
        array dp[&kol_dep_per];array dp_[&kol_depop];retain dp1-dp&kol_dep_per dp_1-dp_&kol_depop;
        array pd[&kol_dep_per];array pd_[&kol_perp];retain pd1-pd&kol_dep_per pd_1-pd_&kol_perp;
        array ps[&kol_per,2];array pr[&kol_per];retain ps1-ps&kol_per2 pr1-pr&kol_per;
        array rt[&kol_rasp,3];array rp[&kol_dep_rasp];retain rt1-rt&kol_rasp3 rp1-rp&kol_rasp;
                array st_r[&kol_st,2];retain st_r1-st_r&kol_st2 0;/*диапазон расписаний с началом в данной станции*/

        array dm[&kol_dep_rasp];array dm_[&kol_depop];retain dm1-dm&kol_dep_rasp dm_1-dm_&kol_depop;
                array d[&kol_rasp,&kol_depo] $1.;retain d1-d&kol_deprasp '0';

                array cst[&kol_depo];array crst[&kol_depo];array cgruz[&kol_depo];array cscep[&kol_depo];array cbr[&kol_depo];
                        retain cst1-cst&kol_depo crst1-crst&kol_depo cgruz1-cgruz&kol_depo cscep1-cscep&kol_depo cbr1-cbr&kol_depo;

        array vr[&kol_ver_d] $&kol_ver_dl4..;array vk[&kol_ver_d] $&kol_ver_dl4..;
        array vnr[&kol_ver_n];array vnk[&kol_ver_n];array vnd[&kol_ver_n];
                array vnom[&kol_raspp];array vnomd[&kol_ver_d];array vnomk[&kol_ver_d];
        array bvr[&kol_ver_d] $&kol_ver_dl4..;array bvk[&kol_ver_d] $&kol_ver_dl4..;array bvks[&kol_ver_d];
                array vbr[&kol_raspp];array vbrd[&kol_ver_d];array vbrk[&kol_ver_d];

        retain vr1-vr&kol_ver_d  vk1-vk&kol_ver_d vnr1-vnr&kol_ver_n vnk1-vnk&kol_ver_n
                vnd1-vnd&kol_ver_n vnom1-vnom&kol_raspp vnomd1-vnomd&kol_ver_d vnomk1-vnomk&kol_ver_d
                bvr1-bvr&kol_ver_d bvk1-bvk&kol_ver_d bvks1-bvks&kol_ver_d vbr1-vbr&kol_raspp
                vbrd1-vbrd&kol_ver_d vbrk1-vbrk&kol_ver_d;
        array prasp[&kol_ver_dl];array pkol[&kol_ver_dl];retain prasp1-prasp&kol_ver_dl pkol1-pkol&kol_ver_dl;


                array rdd[&kol_dep_rasp];array rdp[&kol_dep_rasp];array rdr[&kol_raspp];
                        retain rdd1-rdd&kol_dep_rasp rdp1-rdp&kol_dep_rasp rdr1-rdr&kol_raspp;

                array rsv[&kol_rasp];array rsv_[&kol_rasp];/*свободные*/ retain rsv1-rsv&kol_rasp rsv_1-rsv_&kol_rasp;
        /*array rsd[&kol_rasp];array rsd_[&kol_rasp];/*свободные для депо* / retain rsd1-rsd&kol_rasp rsd_1-rsd_&kol_rasp;/**/

/*свободные для депо по другому*/
                array svdk[&kol_depo];array svdn[&kol_depo];array svdr[&kol_dep_rasp];
                array svr[&kol_raspp];array svrd[&kol_dep_rasp];array svrp[&kol_dep_rasp];
                retain svdk1-svdk&kol_depo svdn1-svdn&kol_depo svdr1-svdr&kol_dep_rasp
                        svr1-svr&kol_raspp svrd1-svrd&kol_dep_rasp svrp1-svrp&kol_dep_rasp;

        array depo_[&max_rasp];array rst_[&max_rasp];array rst_rab_[&max_rasp];array rasp1_[&max_rasp];
        array rasp2_[&max_rasp];array stan1_[&max_rasp];array stan2_[&max_rasp];array nnn_[&max_rasp] $1.;
                array tm_[&max_rasp,4];
if tb='1' then do;dz[n_st1,n_st2]=rst;end;
if tb='3' then do;/*pereg*/ps[per_n,1]=n_st1;ps[per_n,2]=n_st2;pr[per_n]=rs;
                /*depo_per*/dp[nn_dp]=per_n;if dp_[depo]=. then dp_[depo]=nn_dp;
                /*per_depo*/pd[nn_pd]=depo;if pd_[per_n]=. then pd_[per_n]=nn_pd;end;

if tb='4' then do;/*raspis*/rt[rasp,1]=tm1;rt[rasp,2]=tm2;rt[rasp,3]=mars_nm;rp[rasp]=per_n;
                /*depo_raspis*/dm[nn_dr]=rasp;if dm_[depo]=. then dm_[depo]=nn_dr;d[rasp,depo]='1';
                /*raspis_depo*/rdd[nn_rd]=depo;rdp[nn_rd]=nn_dr/*svrpos*/;if rdr[rasp]=. then rdr[rasp]=nn_rd;
        /*+raspis*/if st_r[n_st1,1]=0 then st_r[n_st1,1]=rasp;st_r[n_st1,2]=rasp;/*диапазон расписаний с данной станции*/
end;

if tb='5' then do;cst[depo]=c_st;crst[depo]=c_rst;cgruz[depo]=c_gruz;cscep[depo]=c_scep;cbr[depo]=c_br;end;
if tb='6' then do;format ss $&dl_rasp..;
        if zz='lok' then do;
        if nom=0 then do;vnd[nn]=depo;vnk[nn]=kol;vnr[nn]=rasp2;end;
        else do;vnomd[nom]=depo;vnomk[nom]=nn;if vnom[rasp1]=. then vnom[rasp1]=nom;
                ss=trim(left(rasp2));
                        ff1:;if length(ss)<&dl_rasp then do;ss='0'||ss;goto ff1;end;rasp_=ss;
                ss=trim(left(kol));
                        ff2:;if length(ss)<&dl_rasp then do;ss='0'||ss;goto ff2;end;kol_=ss;
                if nn=1 then do;vr[nom]=rasp_;vk[nom]=kol_;end;
                        else do;vr[nom]=trim(vr[nom])||rasp_;vk[nom]=trim(vk[nom])||kol_;end;
                end;end;/*lok*/

        if zz='br' then do;
        vbrd[nom]=depo;vbrk[nom]=nn;if vbr[rasp1]=. then vbr[rasp1]=nom;
                ss=trim(left(rasp2));
                        bf1:;if length(ss)<&dl_rasp then do;ss='0'||ss;goto bf1;end;rasp_=ss;
                ss=trim(left(kol));
                        bf2:;if length(ss)<&dl_rasp then do;ss='0'||ss;goto bf2;end;kol_=ss;
                if nn=1 then do;bvr[nom]=rasp_;bvk[nom]=kol_;bvks[nom]=kol;end;
                        else do;bvr[nom]=trim(bvr[nom])||rasp_;bvk[nom]=trim(bvk[nom])||kol_;bvks[nom]=bvks[nom]+kol;end;
                end;/*br*/


end;


if tb='0' then do;seed=0;variant_=0;variant=&variant;time=0;time_lok=0;time_br=0;time_br0=0;time_br_sl=0;maxx=&maxx;put 'ВХОД';

/*приведение массивов в порядок*/
/*3*/dp_[&kol_depop]=&kol_dep_per+1;do depo=&kol_depo to 1 by -1;if dp_[depo]=. then dp_[depo]=dp_[depo+1];end;
        pd_[&kol_perp]=&kol_dep_per+1;do per=&kol_per to 1 by -1;if pd_[per]=. then pd_[per]=pd_[per+1];end;
/*4*/dm_[&kol_depop]=&kol_dep_rasp+1;do depo=&kol_depo to 1 by -1;if dm_[depo]=. then dm_[depo]=dm_[depo+1];end;
        rdr[&kol_raspp]=&kol_dep_rasp+1;do i=&kol_rasp to 1 by -1;if rdr[i]=. then rdr[i]=rdr[i+1];end;

/*6*/vnom[&kol_raspp]=&kol_ver_d+1;do i=&kol_rasp to 1 by -1;if vnom[i]=. then vnom[i]=vnom[i+1];end;
/*6*/vbr[&kol_raspp]=&kol_ver_d+1;do i=&kol_rasp to 1 by -1;if vbr[i]=. then vbr[i]=vbr[i+1];end;


/*работа*/put 'ВХОД2';
flag1:;/**/variant+1;variant_+1;_tm=time();err=0;
                depo=0;rasp1=0;nom=0;sv_rasp=&kol_rasp;nn=0;
        cena=0;cena_rst=0;cena_rab=0;cena_scep=0;cena_tm=0;cena_brig=0;
        do i=1 to &kol_rasp;rsv[i]=i;rsv_[i]=i;end;/*перечень всех ещё свободных расписаний*/

/*свободные для всех депо*/
do i=1 to &kol_depo;svdn[i]=dm_[i];svdk[i]=dm_[i+1]-dm_[i];end;
do i=1 to &kol_dep_rasp;svdr[i]=dm[i];end;
do i=1 to &kol_raspp;svr[i]=rdr[i];end;
do i=1 to &kol_dep_rasp;svrd[i]=rdd[i];svrp[i]=rdp[i];end;




flag2:;/*поиск очередного маршрута*/rasp2=0; nnn='0';
if depo=0 then do;call ranuni(seed,c);
        if c>=&ver_sluc then do;
        /*по вероятностям*/call ranuni(seed,c);
                skol=0;do i=1 to &kol_ver_n;if rsv_[vnr[i]]>0 then skol+vnk[i];end;sk=round(skol*c+0.5);
                if skol>0 then do;
                skol=0;do i=1 to &kol_ver_n;if rsv_[vnr[i]]>0 then skol+vnk[i];if sk<=skol then
                        do;rasp2=vnr[i];depo=vnd[i];goto fl;end;end;end;
        end;
        do;/*чисто случайно*/call ranuni(seed,c);
                                call ranuni(seed,c);i=round(c*sv_rasp+0.5);rasp2=rsv[i];
                per=rp[rasp2];call ranuni(seed,c);i1=pd_[per];i2=pd_[per+1];ii=round((i2-i1)*c-0.5);
                depo=pd[i1+ii];
                end;/*чисто случайно*/goto fl;
end;/*depo=0*/

else do;/*depo^=0*/
        if c>=&ver_sluc then do;
/*по вероятностям*/  /*put vnom[rasp1]= vnom[rasp1+1]=;*/
        nom=0;do i=vnom[rasp1] to vnom[rasp1+1]-1;if vnomd[i]=depo then nom=i;end;
        if nom=0 then goto fl;
        skol=0;koll=0;do i=1 to vnomk[nom];
                rasp=1*substr(vr[nom],(i-1)*&dl_rasp+1,&dl_rasp);if rsv_[rasp]>0 then do;
                        kol=1*substr(vk[nom],(i-1)*&dl_rasp+1,&dl_rasp);skol+kol;koll+1;prasp[koll]=rasp;
                        pkol[koll]=skol;end;end;
        sk=round(skol*c+0.5);
        if koll>0 then do;
        do i=1 to koll;if sk<=pkol[i] then do;nnn='1';rasp2=prasp[i];goto fl;end;
                end;end;/*по вероятностям*/
        end;

        /*вообще далее должно быть невозможно, ну либо конец маршрута!*/
        /*чисто случайно* /do; call ranuni(seed,c);i=round(c*svdk[depo]+0.5);rasp2=svdr[svdn[depo]+i-1];
                        goto fl;end;/*чисто случайно*/
end;/*depo^=0*/



fl:;rst=0;/*put rasp2=;*/
fl_p:;rst_rab=0;tm1=0;tm2=0;
if rasp1^=0 and rasp2^=0 then do;/*блок - при ограничениях сделать rasp2=0*/
        per1=rp[rasp1];per2=rp[rasp2];st1=ps[per1,2];st2=ps[per2,1];rst=dz[st1,st2];
                /*конец цикла маршрута*/
                        if rst=-1 then do;rst=dz[st1,stan1];if rst=-1 then rst=1000;rasp2=0;goto fl_p;end;
        end;/*блок - при ограничениях сделать rasp2=0*/

if rasp2=0 then do;/*блок rasp2=0*/
        per1=rp[rasp1];st1=ps[per1,2];st2=stan1;rst=dz[st1,st2];if rst=-1 then rst=1000;
        end;/*блок rasp2=0*/



if rasp2^=0 then do;
/*оставшиеся свободные расписания*/
i=rsv_[rasp2];r_izm=rsv[sv_rasp];
        rsv[i]=r_izm;rsv[sv_rasp]=0;rsv_[r_izm]=i;rsv_[rasp2]=0;sv_rasp=sv_rasp-1;/* 0.2% */

/*оставшиеся для всех депо свободные расписания*/
do ii=svr[rasp2] to svr[rasp2+1]-1;dep=svrd[ii];pos=svrp[ii];
                /**/if abs(svdr[pos]-rasp2)>0.1 then do;put 'ошибка ' svdr[pos]= '<>' rasp2=;rr=svdr[0];end;
        dep_n=svdn[dep];dep_k=svdn[dep]+svdk[dep]-1;rsp=svdr[dep_k];svdr[pos]=rsp;
                do jj=svr[rsp] to svr[rsp+1]-1;if dep=svrd[jj] then do;svrp[jj]=pos;end;end;
        svdr[dep_k]=0;svdk[dep]=svdk[dep]-1;svrp[ii]=0;end;

end;



flag_param:;/*подсчёт результатов для локомотивов*/
/*параметры проезда по перегону*/mars_end=0;/*tm1_=tmend;*/tm1_=tm4_;if rasp1=0 then tm1_=0;tm2_=tm1_;tm3_=tm1_;
if rasp1=0 then do;stan1=ps[rp[rasp2],1];stan2=0;tm_beg=rt[rasp2,1];tmend=tm_beg;tm_end=tmend;
        rst_rab=0;rasp_ish=rasp2;end;
if rasp2=0 then do;mars_end=1;rasp2=rasp_ish;end;
if rasp1^=0 then do;rst_rab=pr[rp[rasp1]];tm1=rt[rasp1,1];tm2=rt[rasp1,2];tme=-ceil(-tmend);
                tm1=tm1+tme;tm2=tm2+tme;
        ff:;if tm1<tmend then do;tm1=tm1+1;tm2=tm2+1;goto ff;end;tmend=tm2;tm2_=tm2;tm3_=tm2_;end;


if rasp2^=0 then do;if rst>0 then do;tmend=tmend+rst/(24*&speed);tm3_=tmend;end;end;
if rasp2=0 or mars_end=1 then do;stan2=ps[rp[rasp2],1];tme=-ceil(-tmend);tm_end=tm_beg+tme;
        if tm_end<tmend then tm_end+1;end;

cena_rst=cena_rst+rst*crst[depo];cena_rab=cena_rab+rst_rab*cgruz[depo];
/*cena=cena+rst*crst[depo]+rst_rab*cgruz[depo];*/
if rasp1>0 and rasp2>0 then do;if rt[rasp1,3]+1^=rt[rasp2,3] then cena_scep=cena_scep+cscep[depo];end;
if mars_end=1 then cena_tm=cena_tm+(tm_end-tm_beg)*cst[depo];
tm4_=rt[abs(rasp2),1];ff3:;if tm4_<tm3_ then do;tm4_=tm4_+1;goto ff3;end;

nn+1;/** /output resh;/**/
rasp1_[nn]=rasp1;rasp2_[nn]=rasp2;if mars_end=1 then rasp2_[nn]=-rasp2;
        depo_[nn]=depo;stan1_[nn]=stan1;stan2_[nn]=stan2;
                rst_[nn]=rst;rst_rab_[nn]=rst_rab;nnn_[nn]=nnn;tm_[nn,1]=tm1_;tm_[nn,2]=tm2_;tm_[nn,3]=tm3_;
        tm_[nn,4]=tm4_;


if mars_end=1 then do;rasp2=0;end;
rasp1=rasp2;if rasp1=0 then depo=0;/*вывод результата одного перехода*/
/*переход на след уровень*/ if sv_rasp>0 then goto flag2;/**/
if sv_rasp=0 and rasp2^=0 then do;rasp1=rasp2;rasp2=0;goto fl;  goto flag_param;end;/*подсчёт результатов для локомотивов конец*/

time_lok=time_lok+max(time()-_tm,0);


%if %sysevalf(&isp_brig^=0) %then %do;
/*постановка маршрутов для бригад*/

/*входные параметры бригад*/
/**/array r_r[&kol_rasp];array r_d[&kol_rasp];array r_st[&kol_rasp,2];array r_t[&kol_rasp,4];
        array rrasp[&kol_rasp];array vrasp[&kol_rasp];
        /*список свободных расписаний для поиска - заполняется постоянно заново. и их вероятности*/
        array br_r[&kol_rasp,2];array br_d[&kol_rasp];array br_tm[&kol_rasp,2];
        array r_isp[&kol_rasp];
        retain r_r1-r_r&kol_rasp r_d1-r_d&kol_rasp r_st1-r_st&kol_rasp2 r_t1-r_t&kol_rasp4
                rrasp1-rrasp&kol_rasp vrasp1-vrasp&kol_rasp br_r1-br_r&kol_rasp2 br_d1-br_d&kol_rasp br_tm1-br_tm&kol_rasp2
                r_isp1-r_isp&kol_rasp;
_tm_br=time();
do i=1 to nn;r1=rasp1_[i];if r1>0 then do;r_r[r1]=abs(rasp2_[i]);r_d[r1]=depo_[i];
        zt=ROUND(tm_[i,1]-0.5+0.000000001);
        r_t[r1,1]=tm_[i,1]-zt;r_t[r1,2]=tm_[i,2]-zt;r_t[r1,3]=tm_[i,3]-zt;r_t[r1,4]=tm_[i,4]-zt;
        r_st[r1,1]=ps[rp[abs(rasp1_[i])],1];r_st[r1,2]=ps[rp[abs(rasp2_[i])],1];
end;end;
/*=0 свободна совсем, >0 занята уже (кто после неё), <0 занята и=первая в маршруте*/
do i=1 to &kol_rasp;r_isp[i]=0;end;
depo=0;kol_svob=&kol_rasp;cena_brig=0;kol_brig=0;n_br=0;rasp_ish=0;
time_br0=time_br0+max(time()-_tm,0);
/**/




fl_brig1:;
if depo=0 then do;/*постановка новой работы в бригады - первую вместо случайной!*/
        do i=rasp_ish+1 to &kol_rasp;if r_isp[i]=0 and r_d[i]>0 then do;
                        r_isp[i]=.;rasp1=i;rasp_ish=rasp1;depo=r_d[rasp1];br_beg=r_t[rasp1,1];br_end=br_beg;
                        r_d[rasp1]=0;kol_brig+1;goto fl_brig1;end;end;end;

n_st2=r_st[rasp1,2];/*где окончилась предыдущая работа*/rasp_beg=st_r[n_st2,1];rasp_end=st_r[n_st2,2];

if br_end-br_beg>1.5 then do;rasp2=rasp_ish;goto fl_brig3;end;/*если бригада долго работает, >1.5 суток*/

call ranuni(seed,c);if c<=&ver_sluc then goto brig_sluc;

/*по вероятностям*/call ranuni(seed,c);
        nom=0;do i=vbr[rasp1] to vbr[rasp1+1]-1;if vbrd[i]=depo then nom=i;end;
        if nom=0 then goto brig_sluc;
        skol=0;/*koll=0;*/kol_r=0;str_r=bvr[nom];str_v=bvk[nom];do i=1 to vbrk[nom];
                rasp=1*substr(str_r,(i-1)*&dl_rasp+1,&dl_rasp);/*if rsv_[rasp]>0 then do;*/
                if depo=r_d[rasp] and r_isp[rasp]<=0 and rasp^=rasp1 and rasp>=rasp_beg and rasp<=rasp_end then do
                        kol=1*substr(str_v,(i-1)*&dl_rasp+1,&dl_rasp);skol+kol;kol_r+1;
                                if kol_r=1 and c<skol/bvks[nom] then do;rasp2=rasp;goto fl_brig3;end;
                                rrasp[kol_r]=rasp;vrasp[kol_r]=skol;
                                end;end;
        sk=skol*c;
        if kol_r>0 then do;/*ii=1;ik=max(round(kol_r/5),1);if sk>vrasp[ik] then ii=ik+1;*/
        do i=/*ii*/1 to kol_r;if sk<=vrasp[i] then do;rasp2=rrasp[i];goto fl_brig3;end;
                end;end;/*по вероятностям*/

brig_sluc:;
/*постановка нового расписания чисто случайно*/
_tm_sl=time();
kol_r=0;do rrr=rasp_beg to rasp_end;
        if depo=r_d[rrr] and r_isp[rrr]<=0 and rrr^=rasp1 then do;kol_r+1;rrasp[kol_r]=rrr;end;end;
        if kol_r=0 then do;rasp2=rasp_ish;end;
                else do;call ranuni(seed,c);nom_r=round(kol_r*c+0.5);rasp2=rrasp[nom_r];end;
time_br_sl=time_br_sl+max(time()-_tm_sl,0);

fl_brig3:;
        br_er=r_t[rasp1,3];br_er2=r_t[rasp1,4];br_er3=r_t[rasp2,1];
fl_brig2:;if br_er<br_end then do;br_er+1;br_er2+1;goto fl_brig2;end;
                if br_er3<br_er then do;br_er3+1;goto fl_brig2;end;

        r_d[rasp2]=0;r_isp[rasp1]=rasp2;if rasp1=rasp_ish then r_isp[rasp1]=-rasp2;
        /*записать в массив*/n_br+1;br_r[n_br,1]=rasp1;br_r[n_br,2]=rasp2;br_d[n_br]=depo;
                br_tm[n_br,1]=br_end;
        br_end=br_er3;if rasp1=rasp2 then br_end+1;br_tm[n_br,2]=br_end;
        if rasp2=rasp_ish then do;/*цена времени*/;tm_brig=br_end-br_beg;cen_=tm_brig*cbr[depo];/*if rasp1=rasp2 then tm_brig+1*/;
                        if tm_brig>1 then cen_=cen_*(tm_brig**0.5);
                                cena_brig+cen_;depo=0;r_isp[rasp_ish]=abs(r_isp[rasp_ish]);end;
        kol_svob=kol_svob-1;rasp1=rasp2;rasp2=0;
        if kol_svob>0 then goto fl_brig1;


time_br=time_br+max(time()-_tm_br,0);
%end;



/*подсчёт результатов по бригадам*/
/*постановка маршрутов для бригад конец*/




/*вывод итогов, и переход к новому подсчёту */
cena=cena_rst+cena_rab+cena_scep+cena_tm+cena_brig;isp_brig=&isp_brig;
if maxx=-1 then maxx=2*cena;inn='0';if cena<=maxx then inn='1';
output resh_rez;
if maxx=-1 then maxx=2*cena;
if inn='1' then do;
        zz='lok';mnn=nn;do nn=1 to mnn;
        rasp1=rasp1_[nn];rasp2=rasp2_[nn];depo=depo_[nn];stan1=stan1_[nn];stan2=stan2_[nn];
        rst=rst_[nn];rst_rab=rst_rab_[nn];nnn=nnn_[nn];
        /*tm_beg=tm_b[nn];tm_end=tm_e[nn];*/tm1_=tm_[nn,1];tm2_=tm_[nn,2];tm3_=tm_[nn,3];tm4_=tm_[nn,4];
                output resh;end;
%if %sysevalf(&isp_brig^=0) %then %do;
        zz='br';do nn=1 to &kol_rasp;rasp1=br_r[nn,1];rasp2=br_r[nn,2];depo=br_d[nn];tm1_=br_tm[nn,1];tm2_=br_tm[nn,2];
                                output resh;end;%end;
end;
cena=ceil(cena);cena_rst=ceil(cena_rst);cena_rab=ceil(cena_rab);cena_scep=ceil(cena_scep);cena_tm=ceil(cena_tm);
time=time+max(time()-_tm,0);
if variant_=10*round(variant_/10) then
        put variant_= /*cena= '(' cena_rst= cena_rab= cena_scep= cena_tm= ')'*/ time= time_lok= time_br= /*time_br0=*/ time_br_sl=;


if variant_<&kol_var or time<2*&dt then goto flag1;

 end;/*tb='0'*/
length rasp1 rasp2 nn 4 depo stan1 stan2 rst rst_rab 3 variant 5;
/*keep variant rasp1 rasp2 depo stan1 stan2 cena*/;run;






data dt;tm=time();run;

data opt.resh_rez;set opt.resh_rez resh_rez;run;

proc sort data=opt.resh_rez nodup;by cena variant;run;
data opt.resh_rez;set opt.resh_rez;koef=max(0,(&kol_ostavl+1-_n_)*2/&kol_ostavl);length koef 3;
        if inn^='0' then kkk+1;if kkk>&kol_ostavl AND INN^='0' then inn='-';if inn^='1' then koef=0;drop kkk;run;
proc sort data=opt.resh_rez nodup;by variant;run;
data resh_rez;set opt.resh_rez;where inn='1';keep variant cena koef;run;
data opt.resh;merge opt.resh resh_rez;by variant;vkoef=koef;length vkoef 3;
        if cena^=. and depo^=. then output;drop cena koef;run;

data resh;merge resh resh_rez;by variant;vkoef=koef;length vkoef 3;
        if cena^=. and depo^=. then output;drop cena koef;run;
data opt.resh;set opt.resh resh;run;


%mend;




/*proc sql;create table stat as select inn,count(*) as kol from opt.resh_rez group by 1;quit;
%put &kol_ostavl &kol_rasp;*/



data opt.resh;set opt.resh;/*keep variant rasp1 rasp2 depo stan1 stan2 nn rst rst_rab vkoef;*/
                length rasp1 rasp2 nn 4 depo stan1 stan2 rst rst_rab vkoef 3 variant 5;run;
data opt.resh_rez;set opt.resh_rez;length variant 5;format inn $1.;/*keep variant cena inn;*/run;

%let koef_mar=0.3;
%macro lokom;
data dt;tm=time();run;%flag:;%step_lokom;

%goto flag;
%mend;

%let isp_brig=1;
%let koef_mar=0.3;/*какую часть от числа элементов расписания моггут составлять запоминаемые решения*/
%let ver_sluc=0.02;
%lokom;

%let min_variant=300000;%let max_cena=6000000000;

proc gplot data=opt.resh_rez;plot cena*variant=inn;/*where variant>&min_variant and cena<=&max_cena;*/run;quit;

proc gplot data=opt.resh_rez;plot cena_rst*variant=inn;where inn='1';run;quit;

proc gplot data=opt.resh_rez;plot (cena cena_rst cena_rab cena_scep cena_tm cena_brig kol_brig)*variant=inn;
        /**/where variant>&min_variant;/**/;run;quit;

proc gplot data=opt.stat;plot kol_ver*variant;where variant>&min_variant;run;quit;














/*data opt.resh_rez;set opt.resh_rez;where variant<=350000;run;*/

proc sql;create table ver as select rasp1,depo,abs(rasp2) as rasp2,rst,count(*) as kol
        from opt.resh where rasp2^=0 group by 1,2,3,4 order by rasp1,depo,-kol;quit;




/*data opt.resh;set opt.resh;if vkoef=. then vkoef=1;run;*/


proc sql;create table rr as select inn,count(*) as kol from opt.resh_rez group by 1;quit;








































%let kol_v=50;/*количество вершин*/

%let kol_prov=10000;/*количество проб проверок*/

data a;array ves[&kol_v,&kol_v];f=1;
        do i=1 to &kol_v;do j=i to &kol_v;
                ves[i,j]=0;if i<j then do;ves[i,j]=round(1000*ranuni(1)+1);ves[j,i]=ves[i,j];end;end;end;
        output;drop i j;run;



/*data b;do prov=1 to &kol_prov;do ver=1 to &kol_v;c=ranuni(1);output;end;end;run;
proc sort data=b;by prov c;run;
data b;set b;f=1;array posl[&kol_v];retain posl nn;if lag(prov)^=prov then nn=0;nn+1;
        posl[nn]=ver;if nn=&kol_v then output;drop c nn ver;run;*/


data f;seed=0;do i=1 to 10;call ranuni(seed,c);output;end;run;



data verp;kol=1;do ver1=1 to &kol_v;do ver2=1 to &kol_v;if ver1^=ver2 then output;end;end;run;


data nil;run;
data b;set verp nil;array kk[&kol_v,&kol_v];retain kk 0;array posl[&kol_v];array is[&kol_v];array k_[&kol_v];array v_[&kol_v];
f=1;seed=0;if ver1^=. then do;kk[ver1,ver2]=kol;end;
else do;do i=1 to &kol_v;do j=1 to &kol_v;if i^=j then kk[i,j]+0.1;end;end;
        do prov=1 to &kol_prov;
        do i=1 to &kol_v;is[i]=0;posl[i]=0;end;
posl[1]=1;is[1]=1;
do i=1 to &kol_v-1;v1=posl[i];tt=0;sk=0;
        do v=1 to &kol_v;if is[v]=0 and kk[v1,v]>0 then do;tt+1;k_[tt]=kk[v1,v];v_[tt]=v;sk+k_[tt];end;end;
        call ranuni(seed,c);z=sk*c;v=0;
        do j=1 to tt;if z<=k_[j] then do;v=v_[j];j=tt;end;else do;z=z-k_[j];end;end;
        if v=0 then v=v_[tt];
        posl[i+1]=v;is[v]=1;
end;/*i*/

output;end;end;keep posl1-posl&kol_v prov f;
run;





data c(keep=prov vess) d(keep=vess ver1 ver2 prov);merge a b;by f;array posl[&kol_v];array ves[&kol_v,&kol_v];
vess=0;do i=1 to &kol_v-1;vess=vess+ves[posl[i],posl[i+1]];end;
                vess=vess+ves[posl[&kol_v],posl[1]];output c;
do i=1 to &kol_v-1;ver1=posl[i];ver2=posl[i+1];output d;end;
                ver1=posl[&kol_v];ver2=posl[1];output d;run;

proc sort data=c;by vess;run;
data cc;set c;if _n_<=10 then output;run;
proc sql;create table cc as select * from cc,b where cc.prov=b.prov order by vess;quit;

proc sort data=d;by vess prov;run;
data d;set d;if lag(prov)^=prov then nn+1;if nn<=&kol_prov/10 then output;drop nn;run;

proc sql;create table dd as select ver1,ver2,count(*) as kol,
        sum(1/vess)/count(*) as f1,sum(1/(vess**2))/count(*) as f2
        from d group by 1,2 order by ver1,-f1;quit;


data verp;set dd;keep ver1 ver2 kol;run;































/**/
