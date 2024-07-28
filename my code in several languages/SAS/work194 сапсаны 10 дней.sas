

libname ml 'd:\mylib\poezda';
libname mylib 'd:\mylib\prigorod';

libname gr 'd:/mylib/grup_dannie';
libname neir 'd:/mylib/neiroset_new';


dm 'afa c=ml.neural.init_neiroset_macroses.frame';



dm 'afa c=ml.connects.link.frame';

dm 'afa c=ml.otcheti_vpt_prig.connect.frame';



dm 'afa c=ml.poezda.connect.frame';

rsubmit;libname pgt db2 authid=pgt;endrsubmit;libname pgt slibref=pgt server=proizvod;

rsubmit;libname pgt db2 authid=pgt;endrsubmit;libname pgt slibref=pgt server=otladka;
rsubmit;libname tst db2 authid=tst;endrsubmit;libname tst slibref=tst server=otladka;


rsubmit;libname vpt db2 authid=vpt;endrsubmit;libname vpt slibref=vpt server=proizvod;

rsubmit;libname vpt db2 authid=vpt;endrsubmit;libname vpt slibref=vpt server=otladka;


rsubmit;libname xran db2 authid=xran;endrsubmit;libname xran slibref=xran server=proizvod;

/**********************************************************************************************/
options notes source;




/*************************************************************************/



/* график расписания сапсанов*/


proc sql;create table rs as select napr,dtpzd,tmo,tmp,pzd,h1,h2,hh,sum(kol_mest) as kol_mest from dann group by 1,2,3,4,5,6,7,8;
        create table rs as select *,count(*) as kol from rs group by napr,dtpzd;quit;

/*   proc gplot data=rs;plot tmo*dtpzd;by napr;run;quit;    */


data rs;set rs;nn=_n_;dl=1;if kol_mest>700 then dl=2;run;


%let kk=100;
data rs_;set rs;array dt[&kk];array np[&kk];array tp[&kk];array nom[&kk];array d[&kk];retain dt np tp nom d kol 0;
        kol=kol+1;dt[kol]=dtpzd;np[kol]=napr;tp[kol]=tmp;nom[kol]=nn;d[kol]=dl;
        do ii=kol to 1 by -1;if dt[ii]<dtpzd-1 then do;
                do i=1 to kol-ii;dt[i]=dt[i+ii];np[i]=np[i+ii];tp[i]=tp[i+ii];nom[i]=nom[i+ii];d[i]=d[i+ii];end;
                kol=kol-ii;ii=1;end;end;
        do i=1 to kol;if np[i]=-napr and (dt[i]<dtpzd or tp[i]<tmo) and d[i]=dl then do;nn_=nom[i];/**/output;/**/
                do j=i to kol-1;dt[j]=dt[j+1];np[j]=np[j+1];tp[j]=tp[j+1];nom[j]=nom[j+1];d[j]=d[j+1];end;
                dt[kol]=0;np[kol]=0;tp[kol]=0;nom[kol]=0;d[kol]=0;
                kol=kol-1;i=kol;end;end;
        /**/keep nn nn_;/**/run;


proc sql;create table rs_2 as select * from rs as a left join rs_ as b on a.nn=b.nn;quit;
proc sql;create table rs_2 as select * from rs_2 as a left join
        (select nn as nn_,pzd as pzd_,dtpzd as dt,tmo as tmo_,tmp as tmp_,kol_mest as km from rs) as b on a.nn_=b.nn_
        order by nn;quit;




/****************************************************************************************/
/* получение итогового отчёта  */

%let serial=1;%corrgraf;

proc sort data=corr;by dtpzd napr h1;run;

data itog;set corr;where dtpzd>='01jan2015'd;keep h1 napr dtpzd kol_mest kol_pas progn pzd;
        kol_pas=x_;progn=y_;if yy_^=. then progn=yy_;progn=round(progn);run;






data itog_r1;set itog;kol_vag=1;kol_pas=min(kol_pas,kol_mest);
        if kol_mest>1000 then kol_vag=2;
        if kol_mest>1500 then kol_vag=3;
        if kol_mest>2000 then kol_vag=4;
        vag=kol_mest/kol_vag;
        prog='1';output;prog='0';progn=kol_pas;output;prog='-';progn=kol_pas;output;run;


data itog_r1;set itog_r1;cena=3000;
do proc=0 to 100 by 5;mprib=-1000;vags=0;mkv=kol_vag+2;if pzd^='' then mkv=2;
do kv=1 to mkv;prib=min(progn,vag*kv)-proc*vag*kv/100;
        if prib>mprib then do;mprib=prib;vags=kv;end;end;
                if prog='-' then vags=kol_vag;
        d_vag=vags-kol_vag;/*is_mest=round(vag*vags);
        rez_pas=min(kol_pas,is_mest);prihod=rez_pas*cena;rashod=is_mest*cena*proc;
        pot_pas=kol_pas-rez_pas;*/
        output;end;drop mprib kv prib ;run;





proc sql;create table itog_r3 as select proc,prog,dtpzd,
        sum(case when napr=1 then d_vag else 0 end) as sd_vag1,
        sum(case when napr=-1 then d_vag else 0 end) as sd_vag2,
        sum(case when napr=1 then kol_vag else 0 end) as svag1,
        sum(case when napr=-1 then kol_vag else 0 end) as svag2
        from itog_r1 where prog^='-' group by proc,prog,dtpzd order by proc,prog,dtpzd;quit;
/*выбираем ближнее к 0 - если 1 знака, и=0 если разного знака. Но итого не более 14 составов */
data itog_r3;set itog_r3;if sd_vag1*sd_vag2<=0 then do;sd_vag1=0;sd_vag2=0;end;
        if sd_vag1<0 then do;if sd_vag2<sd_vag1 then sd_vag2=sd_vag1;else sd_vag1=sd_vag2;end;
        if sd_vag1>0 then do;if sd_vag2>sd_vag1 then sd_vag2=sd_vag1;else sd_vag1=sd_vag2;end;
        flag:;if sd_vag1>0 and (sd_vag1+svag1>14 or sd_vag2+svag2>14) then do;sd_vag1+(-1);sd_vag2+(-1);goto flag;end;
sd_vag=sd_vag1;keep proc prog dtpzd sd_vag;run;

proc sort data=itog_r1;by proc prog dtpzd;run;
data itog_r3;merge itog_r1 itog_r3;by proc prog dtpzd;sg=sign(sd_vag);
        if prog^='-' then do;prog=prog+2;output;end;run;
proc sql;create table itog_r3 as select * from itog_r3
        order by proc,prog,dtpzd,napr,d_vag*sg,(kol_mest-progn)*sg;quit;

data itog_r3;set itog_r3;retain izm 0;
        if lag(proc)^=proc or lag(prog)^=prog or lag(dtpzd)^=dtpzd or lag(napr)^=napr then izm=sd_vag;
        k=1;if izm=0 then k=0;d_vag_=d_vag*k;if izm*(izm-d_vag_)<0 then d_vag_=izm;
                izm=izm-d_vag_;
        drop k izm;run;
data itog_r3;set itog_r3;d_vag=d_vag_;vags=kol_vag+d_vag;drop d_vag_ sd_vag sg;run;











data itog_r2;set itog_r1 itog_r3;
        is_mest=round(vag*vags);
        rez_pas=min(kol_pas,is_mest);prihod=rez_pas*cena;rashod=is_mest*cena*proc/100;
        pot_pas=kol_pas-rez_pas;

        prihod_prog=0;if kol_pas>=kol_mest and progn>kol_pas and prog in('1','3') and d_vag>0 then
                prihod_prog=(min(is_mest,progn)-kol_pas)*cena;
        vag_plus=0;vag_min=0;if d_vag>0 then vag_plus=d_vag;else vag_min=-d_vag;run;


proc sql;create table stat as select proc,prog,sum(kol_mest) as kol_mest,sum(kol_pas) as kol_pas,
        sum(kol_vag) as kol_vag,sum(d_vag) as d_vag,sum(vag_plus) as vag_plus,sum(vag_min) as vag_min,
        sum(pot_pas) as pot_pas,
        sum(prihod)/1000000 as prihod,sum(rashod)/1000000 as rashod,sum(prihod_prog)/1000000 as prihod_prog
           from itog_r2 group by 1,2;quit;

data stat;format prg $22.;set stat;itog=prihod-rashod;retain itog_ 0;
        if lag(proc)^=proc then itog_=itog;
        dobavka=itog-itog_;dob_pr=round(1000*dobavka/itog_)/10;
prg='как есть';
if prog='0' then prg='идеально знаем';
if prog='1' then prg='прогноз ';
if prog='2' then prg='идеально знаем +распис';
if prog='3' then prg='прогноз +распис';

drop itog_ prog;
label proc='себестоимость %' kol_mest='общее число мест' kol_pas='число перевез пассажиров'
         kol_vag='общее число составов' d_vag='изменение числа составов'
        vag_plus='добавлено составов' vag_min='удалено составов' pot_pas='нехватка мест для пассажиров'
        prihod='приход млн.руб' rashod='расход' itog='финансовый итог' prihod_prog='прогнозируемый доп доход'
        dobavka='добавка относительно сейчас' dob_pr='доля добавки от текущего итога %'
        prg='вид результата';run;




PROC DBLOAD DBMS=EXCEL DATA=stat;PATH="d:\итог прогнозов Сапсаны поезда";
PUTNAMES yes;LABEL;RESET ALL;LIMIT=0;LOAD;RUN;



















/*************************************************************************/


/*удаление нейросети* /
%let neiroset=21;
proc sql;delete from gr.neiroset_name where neiroset=&neiroset;quit;
proc sql;delete from gr.prognoz where neiroset=&neiroset;quit;

/**/







/****восстановление нейросети ****************/
%let dat_obrez='01mar2015'd;
%let neiroset=12;


%let party=100;%vosst_neiroset;
/*   %graf_neiroset;   */
%put &keep;




/****Настройка нейросети ********************/
/*    %plot_mas;    */

%let max_time=300;/*время в секундах*/%let skor=0;/*признак скоростной настройки - кусочками/ или целиком - полным множеством */
/*  %nastroika;  /**/
%nastroika_pro;

/*%let corrgraf_plot=1;/*разовый признак - рисовать итог */
%let serial=1;%corrgraf;
proc gplot data=errs;plot (error)*shag;symbol i=none v=plus;where error<=30 and shag>000;run;quit;
 /*    %let pam=0;%let plus=6;%dob_v_neiroset;  %graf_neiroset;    /**/

/*Запись нейросети с прогнозами прогнозы*/
/** /%zapis_neir;/**/
%prognoz_zapis;

%put &kol_cat;
data neir.neiroset;set neir.neiroset;array cx[&kol_cat];array cy[&kol_cat];
        do i=1 to &kol_cat;cy[i]=cx[i];end;drop i;run;

/*******Создание новой нейросети***************/


%new_neiroset;
%let kol_day=10;
%let istok=1;%let podgotov=4;
%let vid_d=c;/* =d или =c  - числа или категории */%let cat0=5;
/*%let neiroset_name= нейросеть за &kol_day дней, продажа;*/
%let seria=h1;

%let v_e_tip=2;%let k_obrez=0.1;
%init_neiroset_name;

%let dat_obrez='01jan2015'd;
%let party=50;/*%числа данных в настроечном множестве*/
%sozd_dannie;
%sozd_neiroset;






proc gplot data=corr;plot (yy_ y_ x_ kol_mest)*x_/overlay;run;quit;


proc gplot data=corr;plot y_*x_=m1/overlay;run;quit;


proc gplot data=corr;plot d1*dtpzd/overlay;run;quit;


proc gplot data=istok;plot ( kp)*dtpzd=pzd/overlay;by tvk;symbol i=join;run;quit;
proc gplot data=mYlib.vendor_dann;plot max_cena*dtpzd/overlay;where tvk='С2';run;quit;




/**Подстройка всех нейросетей*/
%let max_time=1;%let dat_obrez='01mar2015'd;
%podnastr_all_neiroset;














/**********************************************************************************************/
options notes source;



%let keep=dtpzd napr h1 pzd kol_mest;
%put &keep;



/*отчёт по прогнозам*/



data prog dn dn_new;set gr.prognoz;
        if neiroset in(0,.) and istok^=. then output dn_new;
        else if y_^=. and x_=. then output prog;else output dn;run;



data neir;set gr.neiroset_name;where act='1';run;

proc sql;create table err as select neiroset,count(*) as kol,sum((x_-y_)**2) as err
        from dn group by 1 ;quit;
data err;set err;s_err=err/kol;sigma=s_err**0.5;run;
proc sort data=err;by s_err;run;



%put &keep;
proc sort data=prog;by &keep;run;
data pr;set prog;keep &keep;run;
proc sort data=pr nodup;by &keep;run;
data pr;set pr;nn=_n_;run;

data pr;merge prog pr;by &keep;drop versia istok x_ nom;if yy_^=. then y_=yy_;drop yy_;run;


data dn_;set dn_new;keep &keep x_;run;
proc sort data=dn_ nodup;by &keep;run;


data pr;merge pr dn_;by &keep;if neiroset^=. and x_^=. then output;run;



/****************************************************************************************/
/* получение старого итогового отчёта  */

data itog;set pr;kol_pas=x_;progn=round(y_);drop x_ y_;mon=month(dtpzd);run;





data itog_r1;set itog;kol_vag=1;/*kol_pas=min(kol_pas,kol_mest);*/
        if kol_mest>1000 then kol_vag=2;
        if kol_mest>1500 then kol_vag=3;
        if kol_mest>2000 then kol_vag=4;
        vag=kol_mest/kol_vag;
        prog='1';output;prog='0';progn=kol_pas;output;prog='-';progn=kol_pas;output;run;


data itog_r1;set itog_r1;cena=3000;
do proc=0 to 100 by 5;mprib=-1000;vags=0;mkv=kol_vag+2;if pzd^='' then mkv=2;
do kv=1 to mkv;prib=min(progn,vag*kv)-proc*vag*kv/100;
        if prib>mprib then do;mprib=prib;vags=kv;end;end;
                if prog='-' then vags=kol_vag;
        d_vag=vags-kol_vag;/*is_mest=round(vag*vags);
        rez_pas=min(kol_pas,is_mest);prihod=rez_pas*cena;rashod=is_mest*cena*proc;
        pot_pas=kol_pas-rez_pas;*/
        output;end;drop mprib kv prib ;run;





proc sql;create table itog_r3 as select neiroset,proc,prog,dtpzd,mon,
        sum(case when napr=1 then d_vag else 0 end) as sd_vag1,
        sum(case when napr=-1 then d_vag else 0 end) as sd_vag2,
        sum(case when napr=1 then kol_vag else 0 end) as svag1,
        sum(case when napr=-1 then kol_vag else 0 end) as svag2
        from itog_r1 where prog^='-' group by 1,2,3,4,5 order by 1,2,3,4,5;quit;
/*выбираем ближнее к 0 - если 1 знака, и=0 если разного знака. Но итого не более 14 составов */
data itog_r3;set itog_r3;if sd_vag1*sd_vag2<=0 then do;sd_vag1=0;sd_vag2=0;end;
        if sd_vag1<0 then do;if sd_vag2<sd_vag1 then sd_vag2=sd_vag1;else sd_vag1=sd_vag2;end;
        if sd_vag1>0 then do;if sd_vag2>sd_vag1 then sd_vag2=sd_vag1;else sd_vag1=sd_vag2;end;
        flag:;if sd_vag1>0 and (sd_vag1+svag1>14 or sd_vag2+svag2>14) then do;sd_vag1+(-1);sd_vag2+(-1);goto flag;end;
        sd_vag=sd_vag1;keep neiroset proc prog dtpzd sd_vag;run;

proc sort data=itog_r1;by neiroset proc prog dtpzd;run;
data itog_r3;merge itog_r1 itog_r3;by neiroset proc prog dtpzd;sg=sign(sd_vag);
        if prog^='-' then do;prog=prog+2;output;end;run;
proc sql;create table itog_r3 as select * from itog_r3
        order by neiroset,proc,prog,dtpzd,napr,d_vag*sg,(kol_mest-progn)*sg;quit;

data itog_r3;set itog_r3;retain izm 0;
        if lag(neiroset)^=neiroset or lag(proc)^=proc or lag(prog)^=prog or lag(dtpzd)^=dtpzd or lag(napr)^=napr then izm=sd_vag;
        k=1;if izm=0 then k=0;d_vag_=d_vag*k;if izm*(izm-d_vag_)<0 then d_vag_=izm;
                izm=izm-d_vag_;
        drop k izm;run;
data itog_r3;set itog_r3;d_vag=d_vag_;vags=kol_vag+d_vag;drop d_vag_ sd_vag sg;run;



data itog_r2;set itog_r1 itog_r3;
        is_mest=round(vag*vags);
        rez_pas=min(kol_pas,is_mest);prihod=rez_pas*cena;rashod=is_mest*cena*proc/100;
        pot_pas=kol_pas-rez_pas;
        prihod_prog=0;if kol_pas>=kol_mest and progn>kol_pas and prog in('1','3') and d_vag>0 then
                prihod_prog=(min(is_mest,progn)-kol_pas)*cena;
        vag_plus=0;vag_min=0;if d_vag>0 then vag_plus=d_vag;else vag_min=-d_vag;run;


proc sql;create table stat as select neiroset,proc,mon,prog,sum(kol_mest) as kol_mest,sum(kol_pas) as kol_pas,
        sum(kol_vag) as kol_vag,sum(d_vag) as d_vag,sum(vag_plus) as vag_plus,sum(vag_min) as vag_min,
        sum(pot_pas) as pot_pas,
        sum(prihod)/1000000 as prihod,sum(rashod)/1000000 as rashod,sum(prihod_prog)/1000000 as prihod_prog
           from itog_r2 group by 1,2,3,4 order by 1,2,3,4;quit;

proc sql;create table stat as select * from stat as a left join neir(keep=neiroset istok podgotov kol_day) as b
        on a.neiroset=b.neiroset order by neiroset,proc,mon,prog;quit;

data stat;format prg $22.;set stat;itog=prihod-rashod;retain itog_ 0;
        if lag(neiroset)^=neiroset or lag(proc)^=proc or lag(mon)^=mon then itog_=itog;
        dobavka=itog-itog_;dob_pr=round(1000*dobavka/itog_)/10;
prg='как есть';
if prog='0' then prg='идеально знаем';
if prog='1' then prg='прогноз ';
if prog='2' then prg='идеально знаем +распис';
if prog='3' then prg='прогноз +распис';

drop itog_ prog;
label proc='себестоимость %' kol_mest='общее число мест' kol_pas='число перевез пассажиров'
         kol_vag='общее число составов' d_vag='изменение числа составов'
        vag_plus='добавлено составов' vag_min='удалено составов' pot_pas='нехватка мест для пассажиров'
        prihod='приход млн.руб' rashod='расход' itog='финансовый итог' prihod_prog='прогнозируемый доп доход'
        dobavka='добавка относительно сейчас' dob_pr='доля добавки от текущего итога %'
        prg='вид результата';run;

data stat_;set stat;where podgotov^=2 and istok^=2;run;

/*
PROC DBLOAD DBMS=EXCEL DATA=stat;PATH="d:\итог прогнозов Сапсаны поезда";
PUTNAMES yes;LABEL;RESET ALL;LIMIT=0;LOAD;RUN;
  */









/**********************************************************************************************/

options notes source;

/*проверка. что происходит в мае, по разным прогнозам одновременно*/
%let keep=dtpzd napr h1 pzd kol_mest;
%put &keep;

data prog;set gr.prognoz;where dtpzd>='01may2015'd and pzd^='';run;
proc sort data=prog;by &keep neiroset;run;
data pr;set prog;keep &keep;run;
proc sort data=pr nodup;by &keep;run;

data pr;set pr; nn+1;run;
data prog;merge prog pr;by &keep;run;

proc sql;create table prog(drop=istok_) as select *,max(x_) as x,max(istok) as istok_
        from prog group by nn having istok_=1;quit;


proc sql;create table prog_ as select nn,max(x_) as x_,min(y_) as min_y,max(y_) as max_y,max(yy_) as max_yy,max(istok) as istok
        from prog group by nn having istok=1;quit;

/*proc gplot data=prog_;plot(x_ min_y max_y max_yy)*x_/overlay;run;quit;*/

proc sql;create table prog_2 as select neiroset,count(*) as kol,round(sum(x-y_)**2) as err
        from prog group by 1 order by err;quit;





/**/
