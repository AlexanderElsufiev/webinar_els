

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


/*������ - ��������� �������, �� �� ������ �� �����������, �� ������������ � ������������ �������� */


/* �������� ������ * /
data OPT.GRAF_LIN_STR;set ml.GRAF_LIN_STR;run;
/**/

/*������ �� ������� ����������� ������� ��������*/
/*����� ������ - ����������� ������ ����������� ���� ����������*/
%let speed=50;%let seed=1.00;
%let kol_depo=10;
%let kol_pzd=100;



/*�������� ���� �� ������*/
data cena;seed=round(&seed);do depo=1 to &kol_depo;
        call ranuni(seed,c);c_st=100*(c+5);/*���� (?�������)����� ����������, �� �����*/
        call ranuni(seed,c);c_rst=2+c;/*���� ��������� �������, �� 1��*/
        call ranuni(seed,c);c_gruz=10+15*c;/*���� ��������� �������, �� 1��*/
        call ranuni(seed,c);c_scep=1.5*(c+1);/*���� ����� ������������*/
        call ranuni(seed,c);c_br=10*(c+5);/*���� ����� ���.�������, �� ����� (� ������ � �������� ��� - ������ � ���������)*/
                output;end;drop c seed;run;


/*���� ������ - ���� �� ������ ������� �������, �� � ����� ������ 50�� - ��� ��������� � ���� */
data lin;set opt.graf_lin_str;where dat_end='31dec2095'd and dor=1;label kst=' ';run;
proc sql;create table lin as select *,count(*) as kol from lin group by kst;
        create table lin as select *,max(rast) as rst from lin group by kl order by dor,kl,rast;quit;

data lin;set lin;retain rr 0;if kol>1 or (rast=0 or rast=rst) or (rast-rr>50) then do;rr=rast;output;end;keep kl kst rast rst;run;
/*data lin;set lin;where kol>1 or (rast=0 or rast=rst);keep kl kst rast rst;run;*/
proc sort data=lin;by kl rast;run;

proc sql;create table st as select distinct kst from lin;quit;
data st;set st;st_n=_n_;call symput('kol_st',st_n);run;

/* ������ ���� ��������� */

data pereg;set lin;st1=lag(kst);st2=kst;rs=rast-lag(rast);keep st1 st2 rs p;p=1;
        if lag(kl)=kl then output;run;
data pereg;set pereg;output;c=st1;st1=st2;st2=c;output;drop c;run;
proc sort data=pereg nodup;by st1 st2 rs;run;

proc sql;create table pereg as select st1,st2,rs,b.st_n as n_st1,c.st_n as n_st2
        from pereg as a join st as b on st1=b.kst join st as c on st2=c.kst order by st1,st2;quit;
data pereg;set pereg;per_n=_n_;run;

/*������� ���������� ����� ���������*/
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


/* ������� ������������ ���� - 10 �����, � ���� ���������� ��������� */
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

/*������ ������������ �������� ������ �� ������� ������������� �������� � ������ ����*/
proc sql;create table depo_rast as select b.depo,st1,st2,a.rst,n_st1,n_st2
        from rast as a join depo as b on a.st1=b.kst
        join depo as c on b.depo=c.depo and a.st2=c.kst
                order by depo,st1,st2,rst;quit;
proc sql;create table depo_rast/*(drop=rs)*/ as select * from depo_rast as a,
        (select depo,max(rs) as rs from depo_per group by depo) as b
        where a.depo=b.depo /*and rst<=rs*/ order by depo,st1,st2,rst;quit;
data depo_rast;set depo_rast;where rst<=rs;drop rs;run;


/*����� ���������� ������� - �� � ��, �����=1�� �������. ����� ������� �������� �������=����� ���� ����. ���� ����� 50��.�.*/
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


data rasp3;set rasp2;retain tm;
        st1=lag(st3);st2=st3;rs=rst-lag(rst);tm1=tm;dt=rs/(24*&speed);tm2=tm+dt;dt=dt*ranuni(1);
        if dt<0.01 then dt=0.01;if dt>0.1 then dt=0.1;tm=tm2+dt;if rst=0 then tm=ranuni(1);mars_nm=_n_;
        if lag(mars)=mars then output; keep mars st1 st2 rs tm1 tm2 mars_nm;run;
data rasp3;set rasp3;flag:;if tm1>=1 then do;tm1=tm1-1;tm2=tm2-1;goto flag;end;run;

proc sort data=rasp3;by st1 st2 rs mars;run;
data rasp3;merge rasp3 pereg;by st1 st2 rs;if mars^=. then output;run;


proc sort data=rasp3 out=raspis;by per_n tm1;run;
data raspis;set raspis;rasp=_n_;run;
proc sql;drop table rasp1,rasp2,rasp3;quit;

proc sort data=depo_per;by depo per_n;run;
proc sort data=depo_per out=per_depo;by per_n depo;run;




/*���� - ��� ������� ���� ��������� ������� ���� ��������� ��������� �� ������ � ������, � ���������� ��������� */

proc sql;create table raspis_depo as select rasp,a.n_st1,a.n_st2,a.rs,tm1,tm2,a.per_n,depo,mars_nm
        from raspis as a,depo_per as b where a.per_n=b.per_n order by rasp,depo;quit;

/*���� �������������**/
proc sort data=raspis_depo out=depo_raspis;by depo rasp;run;
data depo_raspis;set depo_raspis;tb='6';nn=_n_;svrpos=nn;run;
/**/

/*�������� ����������� ���������*/
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




/*�Ѩ � ���������������*/
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


%put &kol_st &kol_stp &kol_depo &kol_depop &kol_per &kol_dep_per &kol_rasp &kol_dep_rasp &kol_dep_rast &kol_deprast &kol_rast;
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




data opt.resh;set opt.resh;/*keep variant rasp1 rasp2 depo stan1 stan2 nn rst rst_rab;*/
                length rasp1 rasp2 nn 4 depo stan1 stan2 rst rst_rab 3 variant 5;run;
data opt.resh_rez;set opt.resh_rez;length variant 5;format inn $1.;/*keep variant cena inn;*/run;








/* �������� ����� �� ������������, ��� ��������� */
/*�������� ������� ����� ������ ����� ���������, ��� ����������, ��� ������ �������*/


%let ver_sluc=0.01;%let koef_mar=1;
%macro step_lokom;/*���������� ������������*/

data _null_;k=round(&kol_rasp*&koef_mar);call symput('kol_ostavl',trim(left(k)));run;
%let kol_ost=%sysevalf(&kol_rasp*2);
%put &kol_ostavl;


%let kol_ver_d=1;%let kol_ver_n=1;%let kol_ver_dl=1;
/*��������� ������ ����������� ��� ����������� ���������� ������*/

/*data dt;tm=time();run;*/

proc sql;reset noprint;select case when v is null then 0 else v end  into :vv from
        (select max(variant) as v from opt.resh_rez /*where inn^='0'*/);quit;
%put &vv &kol_ost;

/*���� ��� ���� ����� �������*/
%if %sysevalf(&vv>=&kol_ost) %then %do;
proc sql;create table ver as select rasp1,depo,abs(rasp2) as rasp2,/*count(*)*/ sum(vkoef) as kol
        from opt.resh where rasp2^=0 group by 1,2,3 order by 1,2,3;quit;

%end;

/*���� ������� �� �� ����*/
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
        from raspis_depo as a,raspis_depo as b where a.depo=b.depo and a.n_st2=b.n_st1 order by 1,2,3;quit;
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

data ver;merge ver ver2 ver_;by rasp1 depo rasp2;if p=1 then kol=&kol_rasp/2;drop p sp;if kol=. then kol=1;run;
/**/



%end;

data ver;set ver;retain nom;
        if lag(rasp1)^=rasp1 or(lag(depo)^=depo and rasp1^=0) then do;nom+1;
                if rasp1=0 then nom=0;call symput('kol_ver_d',trim(left(nom)));end;run;
proc sql;create table ver as select *,sum(kol) as skol,count(*) as kk from ver group by nom order by nom,/*depo,*/-kol;
        reset noprint;select max(kk) into:kol_ver_dl from ver where rasp1^=0;
        select count(*) into:kol_ver_n from ver where rasp1=0;quit;
data ver;set ver;tb='7';keep rasp1 rasp2 depo kol tb nom;run;
data ver;set ver;if lag(nom)^=nom then nn=0;nn+1;run;

data _null_;if &kol_ver_n=0 then call symput('kol_ver_n',1);run;
%let kol_ver_n=%sysevalf(&kol_ver_n*1);
%let kol_ver_dl=%sysevalf(&kol_ver_dl*1);
%let kol_ver_dl4=%sysevalf(&kol_ver_dl*4);
%put &kol_ver_d &kol_ver_n /&kol_ver_dl/ &kol_ver_dl4;
%put &kol_rasp &kol_raspp &kol_raspn;


%let maxx=-1;
proc sort data=opt.resh_rez out=maxx;by cena;where inn='1';run;
data _null_;set maxx;call symput('maxx',trim(left(cena)));run;
proc sql;drop table maxx;quit;
%put &maxx;

dm 'clear log';

%let kol_var=100;%let variant=0;
proc sql;reset noprint;select max(variant),1000 into:variant,:kol_var from opt.resh_rez;
        select count(*) into :count_ver from ver;quit;

data f;variant=&variant;kol_ver=&count_ver;run;
data opt.stat;set opt.stat f;run;
data dt;set dt;dt=min(max(time()-tm,0),50);call symput('dt',dt);run;
%put &variant &kol_var &count_ver &dt &kol_ver_d &kol_ver_n;




proc sql;drop table resh,resh_rez;quit;
data resh(keep=variant rasp1 rasp2 depo stan1 stan2 nn rst rst_rab  /** /cena tm_beg tmend tm_end /**/ nnn)
        resh_rez(keep=variant cena cena_rst cena_rab cena_scep cena_tm inn);
        set depo_rast /*pereg*/ depo_per /*per_depo*/ /*raspis*/ /** /depo_raspis/**/
         raspis_depo cena ver nil;
                array dz[&kol_st,&kol_st];retain dz1-dz&kol_rast -1;
        array dp[&kol_dep_per];array dp_[&kol_depop];retain dp1-dp&kol_dep_per dp_1-dp_&kol_depop;
        array pd[&kol_dep_per];array pd_[&kol_perp];retain pd1-pd&kol_dep_per pd_1-pd_&kol_perp;
        array ps[&kol_per,2];array pr[&kol_per];retain ps1-ps&kol_per2 pr1-pr&kol_per;
        array rt[&kol_rasp,3];array rp[&kol_dep_rasp];retain rt1-rt&kol_rasp3 rp1-rp&kol_rasp;

        array dm[&kol_dep_rasp];array dm_[&kol_depop];retain dm1-dm&kol_dep_rasp dm_1-dm_&kol_depop;
                array d[&kol_rasp,&kol_depo] $1.;retain d1-d&kol_deprasp '0';

                array cst[&kol_depo];array crst[&kol_depo];array cgruz[&kol_depo];array cscep[&kol_depo];
                        retain cst1-cst&kol_depo crst1-crst&kol_depo cgruz1-cgruz&kol_depo cscep1-cscep&kol_depo;

        array vr[&kol_ver_d] $&kol_ver_dl4..;array vk[&kol_ver_d] $&kol_ver_dl4..;
        array vnr[&kol_ver_n];array vnk[&kol_ver_n];array vnd[&kol_ver_n];
                array vnom[&kol_raspp];array vnomd[&kol_ver_d];array vnomk[&kol_ver_d];
                retain vr1-vr&kol_ver_d  vk1-vk&kol_ver_d vnr1-vnr&kol_ver_n vnk1-vnk&kol_ver_n
                vnd1-vnd&kol_ver_n vnom1-vnom&kol_raspp vnomd1-vnomd&kol_ver_d vnomk1-vnomk&kol_ver_d;
        array prasp[&kol_ver_dl];array pkol[&kol_ver_dl];retain prasp1-prasp&kol_ver_dl pkol1-pkol&kol_ver_dl;


                array rdd[&kol_dep_rasp];array rdp[&kol_dep_rasp];array rdr[&kol_raspp];
                        retain rdd1-rdd&kol_dep_rasp rdp1-rdp&kol_dep_rasp rdr1-rdr&kol_raspp;

                array rsv[&kol_rasp];array rsv_[&kol_rasp];/*���������*/ retain rsv1-rsv&kol_rasp rsv_1-rsv_&kol_rasp;
        /*array rsd[&kol_rasp];array rsd_[&kol_rasp];/*��������� ��� ����* / retain rsd1-rsd&kol_rasp rsd_1-rsd_&kol_rasp;/**/

/*��������� ��� ���� �� �������*/
                array svdk[&kol_depo];array svdn[&kol_depo];array svdr[&kol_dep_rasp];
                array svr[&kol_raspp];array svrd[&kol_dep_rasp];array svrp[&kol_dep_rasp];
                retain svdk1-svdk&kol_depo svdn1-svdn&kol_depo svdr1-svdr&kol_dep_rasp
                        svr1-svr&kol_raspp svrd1-svrd&kol_dep_rasp svrp1-svrp&kol_dep_rasp;

        array depo_[&max_rasp];array rst_[&max_rasp];array rst_rab_[&max_rasp];array rasp1_[&max_rasp];
        array rasp2_[&max_rasp];array stan1_[&max_rasp];array stan2_[&max_rasp];array nnn_[&max_rasp] $1.;

if tb='1' then do;dz[n_st1,n_st2]=rst;end;
if tb='3' then do;ps[per_n,1]=n_st1;ps[per_n,2]=n_st2;pr[per_n]=rs;
                dp[nn_dp]=per_n;if dp_[depo]=. then dp_[depo]=nn_dp;
                pd[nn_pd]=depo;if pd_[per_n]=. then pd_[per_n]=nn_pd;end;

if tb='4' then do;/*raspis*/rt[rasp,1]=tm1;rt[rasp,2]=tm2;rt[rasp,3]=mars_nm;rp[rasp]=per_n;
                /*depo_raspis*/dm[nn_dr]=rasp;if dm_[depo]=. then dm_[depo]=nn_dr;d[rasp,depo]='1';
                /*raspis_depo*/rdd[nn_rd]=depo;rdp[nn_rd]=nn_dr/*svrpos*/;if rdr[rasp]=. then rdr[rasp]=nn_rd;end;

if tb='5' then do;cst[depo]=c_st;crst[depo]=c_rst;cgruz[depo]=c_gruz;cscep[depo]=c_scep;end;
/**/ if tb='6' then do;ss='1111';
        if nom=0 then do;vnd[nn]=depo;vnk[nn]=kol;vnr[nn]=rasp2;end;
        else do;vnomd[nom]=depo;vnomk[nom]=nn;if vnom[rasp1]=. then vnom[rasp1]=nom;
                ss=trim(left(rasp2));
                        ff1:;if length(ss)<4 then do;ss='0'||ss;goto ff1;end;rasp_=ss;
                ss=trim(left(kol));
                        ff2:;if length(ss)<4 then do;ss='0'||ss;goto ff2;end;kol_=ss;
                if nn=1 then do;vr[nom]=rasp_;vk[nom]=kol_;end;
                        else do;vr[nom]=trim(vr[nom])||rasp_;vk[nom]=trim(vk[nom])||kol_;end;
                end;end; /**/

if tb='0' then do;seed=0;variant_=0;variant=&variant;time=0;maxx=&maxx;put '����';

/*���������� �������� � �������*/
/*3*/dp_[&kol_depop]=&kol_dep_per+1;do depo=&kol_depo to 1 by -1;if dp_[depo]=. then dp_[depo]=dp_[depo+1];end;
        pd_[&kol_perp]=&kol_dep_per+1;do per=&kol_per to 1 by -1;if pd_[per]=. then pd_[per]=pd_[per+1];end;
/*7*/dm_[&kol_depop]=&kol_dep_rasp+1;do depo=&kol_depo to 1 by -1;if dm_[depo]=. then dm_[depo]=dm_[depo+1];end;
        rdr[&kol_raspp]=&kol_dep_rasp+1;do i=&kol_rasp to 1 by -1;if rdr[i]=. then rdr[i]=rdr[i+1];end;

/*9*/vnom[&kol_raspp]=&kol_ver_d+1;do i=&kol_rasp to 1 by -1;if vnom[i]=. then vnom[i]=vnom[i+1];end;


/*������*/put '����2';
flag1:;/**/variant+1;variant_+1;depo=0;rasp1=0;nom=0;sv_rasp=&kol_rasp;nn=0;_tm=time();
        cena=0;cena_rst=0;cena_rab=0;cena_scep=0;cena_tm=0;
        do i=1 to &kol_rasp;rsv[i]=i;rsv_[i]=i;end;/*�������� ���� ��� ��������� ����������*/

/*��������� ��� ���� ����*/
do i=1 to &kol_depo;svdn[i]=dm_[i];svdk[i]=dm_[i+1]-dm_[i];end;
do i=1 to &kol_dep_rasp;svdr[i]=dm[i];end;
do i=1 to &kol_raspp;svr[i]=rdr[i];end;
do i=1 to &kol_dep_rasp;svrd[i]=rdd[i];svrp[i]=rdp[i];end;




flag2:;/*����� ���������� ��������*/rasp2=0; nnn='0';/*put '�� ' nn= rasp1= depo=;*/
if depo=0 then do;call ranuni(seed,c);
        if c>=&ver_sluc then do;
        /*�� ������������*/call ranuni(seed,c);
                skol=0;do i=1 to &kol_ver_n;if rsv_[vnr[i]]>0 then skol+vnk[i];end;sk=round(skol*c+0.5);
                if skol>0 then do;
                skol=0;do i=1 to &kol_ver_n;if rsv_[vnr[i]]>0 then skol+vnk[i];if sk<=skol then
                        do;rasp2=vnr[i];depo=vnd[i];goto fl;end;end;end;
        end;
        do;/*����� ��������*/call ranuni(seed,c);
                                call ranuni(seed,c);i=round(c*sv_rasp+0.5);rasp2=rsv[i];
                per=rp[rasp2];call ranuni(seed,c);i1=pd_[per];i2=pd_[per+1];ii=round((i2-i1)*c-0.5);
                depo=pd[i1+ii];
                end;/*����� ��������*/goto fl;
end;/*depo=0*/

else do;/*depo^=0*/
        if c>=&ver_sluc then do;
/*�� ������������*/  /*put vnom[rasp1]= vnom[rasp1+1]=;*/
        nom=0;do i=vnom[rasp1] to vnom[rasp1+1]-1;if vnomd[i]=depo then nom=i;end;
        if nom=0 then goto fl;
        skol=0;koll=0;do i=1 to vnomk[nom];
                rasp=1*substr(vr[nom],(i-1)*4+1,4);if rsv_[rasp]>0 then do;
                        kol=1*substr(vk[nom],(i-1)*4+1,4);skol+kol;koll+1;prasp[koll]=rasp;
                        pkol[koll]=skol;end;end;
        sk=round(skol*c+0.5);
        if koll>0 then do;
        do i=1 to koll;if sk<=pkol[i] then do;nnn='1';rasp2=prasp[i];goto fl;end;
                end;end;/*�� ������������*/
        end;

        /*������ ����� ������ ���� ����������, �� ���� ����� ��������!*/
        /*����� ��������* /do; call ranuni(seed,c);i=round(c*svdk[depo]+0.5);rasp2=svdr[svdn[depo]+i-1];
                        goto fl;end;/*����� ��������*/
end;/*depo^=0*/



fl:;rst=0;/*put rasp2=;*/
fl_p:;rst_rab=0;tm1=0;tm2=0;
if rasp1^=0 and rasp2^=0 then do;/*���� - ��� ������������ ������� rasp2=0*/
        per1=rp[rasp1];per2=rp[rasp2];st1=ps[per1,2];st2=ps[per2,1];rst=dz[st1,st2];
                /*����� ����� ��������*/
                        if rst=-1 then do;rst=dz[st1,stan1];if rst=-1 then rst=1000;rasp2=0;goto fl_p;end;
        end;/*���� - ��� ������������ ������� rasp2=0*/

if rasp2=0 then do;/*���� rasp2=0*/
        per1=rp[rasp1];st1=ps[per1,2];st2=stan1;rst=dz[st1,st2];if rst=-1 then rst=1000;
        end;/*���� rasp2=0*/



if rasp2^=0 then do;
/*���������� ��������� ����������*/
i=rsv_[rasp2];r_izm=rsv[sv_rasp];
        rsv[i]=r_izm;rsv[sv_rasp]=0;rsv_[r_izm]=i;rsv_[rasp2]=0;sv_rasp=sv_rasp-1;/* 0.2% */

/*���������� ��� ���� ���� ��������� ����������*/
do ii=svr[rasp2] to svr[rasp2+1]-1;dep=svrd[ii];pos=svrp[ii];
                /**/if abs(svdr[pos]-rasp2)>0.1 then do;put '������ ' svdr[pos]= '<>' rasp2=;rr=svdr[0];end;
        dep_n=svdn[dep];dep_k=svdn[dep]+svdk[dep]-1;rsp=svdr[dep_k];svdr[pos]=rsp;
                do jj=svr[rsp] to svr[rsp+1]-1;if dep=svrd[jj] then do;svrp[jj]=pos;end;end;
        svdr[dep_k]=0;svdk[dep]=svdk[dep]-1;svrp[ii]=0;end;

end;



flag_param:;/*GGGGGGGGGGGGGGGGGGGG*/
/*��������� ������� �� ��������*/mars_end=0;
if rasp1=0 then do;stan1=ps[rp[rasp2],1];stan2=0;tm_beg=rt[rasp2,1];tmend=tm_beg;tm_end=tmend;
        rst_rab=0;rasp_ish=rasp2;end;
if rasp2=0 then do;mars_end=1;rasp2=rasp_ish;end;
if rasp1^=0 then do;rst_rab=pr[rp[rasp1]];tm1=rt[rasp1,1];tm2=rt[rasp1,2];tme=-ceil(-tmend);
                tm1=tm1+tme;tm2=tm2+tme;
        ff:;if tm1<tmend then do;tm1=tm1+1;tm2=tm2+1;goto ff;end;tmend=tm2;end;


if rasp2^=0 then do;if rst>0 then do;tmend=tmend+rst/(24*&speed);end;end;
if rasp2=0 or mars_end=1 then do;stan2=ps[rp[rasp2],1];tme=-ceil(-tmend);tm_end=tm_beg+tme;
        if tm_end<tmend then tm_end+1;end;

cena_rst=cena_rst+rst*crst[depo];cena_rab=cena_rab+rst_rab*cgruz[depo];
/*cena=cena+rst*crst[depo]+rst_rab*cgruz[depo];*/
if rasp1>0 and rasp2>0 then do;if rt[rasp1,3]+1^=rt[rasp2,3] then cena_scep=cena_scep+cscep[depo];end;
if mars_end=1 then cena_tm=cena_tm+(tm_end-tm_beg)*cst[depo];

nn+1;/** /output resh;/**/
rasp1_[nn]=rasp1;rasp2_[nn]=rasp2;if mars_end=1 then rasp2_[nn]=-rasp2;
        depo_[nn]=depo;stan1_[nn]=stan1;stan2_[nn]=stan2;
                rst_[nn]=rst;rst_rab_[nn]=rst_rab;nnn_[nn]=nnn;

if mars_end=1 then do;rasp2=0;end;
rasp1=rasp2;if rasp1=0 then depo=0;/*����� ���������� ������ ��������*/
/*������� �� ���� �������*/ if sv_rasp>0 then goto flag2;/**/
if sv_rasp=0 and rasp2^=0 then do;rasp1=rasp2;rasp2=0;goto fl;  goto flag_param;end;/*GGGGGGGGGGGGGGGG*/

cena=cena_rst+cena_rab+cena_scep+cena_tm;
if maxx=-1 then maxx=2*cena;inn='0';if cena<=maxx then inn='1';
output resh_rez;
if maxx=-1 then maxx=2*cena;
if inn='1' then do;mnn=nn;do nn=1 to mnn;
rasp1=rasp1_[nn];rasp2=rasp2_[nn];depo=depo_[nn];stan1=stan1_[nn];stan2=stan2_[nn];
        rst=rst_[nn];rst_rab=rst_rab_[nn];nnn=nnn_[nn];
                output resh;end;end;
cena=ceil(cena);cena_rst=ceil(cena_rst);cena_rab=ceil(cena_rab);cena_scep=ceil(cena_scep);cena_tm=ceil(cena_tm);
time=time+max(time()-_tm,0);
if variant_=10*round(variant_/10) then
        put variant_= /*cena= '(' cena_rst= cena_rab= cena_scep= cena_tm= ')'*/ time=;


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
data dt;tm=time();run;
%flag:;
%step_lokom;
%goto flag;
%mend;

%let koef_mar=0.3;/*����� ����� �� ����� ��������� ���������� ������ ���������� ������������ �������*/
%let ver_sluc=0.02;
%lokom;

%let min_variant=0000;%let max_cena=6000000000;

proc gplot data=opt.resh_rez;plot cena*variant=inn;/*where variant>&min_variant and cena<=&max_cena;*/run;quit;

proc gplot data=opt.resh_rez;plot cena*variant=inn;where inn='1';run;quit;

proc gplot data=opt.resh_rez;plot (cena_rst cena_rab cena_scep cena_tm)*variant=inn;
        where variant>&min_variant;;run;quit;

proc gplot data=opt.stat;plot kol_ver*variant;where variant>&min_variant;run;quit;





/*data opt.resh_rez;set opt.resh_rez;where variant<=350000;run;*/

proc sql;create table ver as select rasp1,depo,abs(rasp2) as rasp2,rst,count(*) as kol
        from opt.resh where rasp2^=0 group by 1,2,3,4 order by rasp1,depo,-kol;quit;




/*data opt.resh;set opt.resh;if vkoef=. then vkoef=1;run;*/


proc sql;create table rr as select inn,count(*) as kol from opt.resh_rez group by 1;quit;








































%let kol_v=50;/*���������� ������*/

%let kol_prov=10000;/*���������� ���� ��������*/

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
