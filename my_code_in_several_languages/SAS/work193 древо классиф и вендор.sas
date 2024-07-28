

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






/*************************************************************************************************************/
/*   Исходник для подачи в дерево классификаций */



data dann;set mylib.vendor_dann;where tvk like 'С%' and hh<5;tvk='00';pzd='00000';run;

proc sql;create table dann as select pzd,tvk,napr,h1,h2,hh,dtpzd,count(*) as kol,sum(kp) as kp,sum(plat) as plat,
        sum(kol_mest) as kol_mest
        from dann group by 1,2,3,4,5,6,7 order by 1,2,3,4,5,6,7;quit;
data dann;set dann;if kp=0 then cena=plat;else cena=round(plat/kp);run;
data dann;set dann;y1=kp;array p[16];
        p1=dtpzd*0;p2=1*substr(pzd,1,4);p3=weekday(dtpzd);p4=month(dtpzd);
        p5=h1;p6=h2;p7=hh;p8=napr;p9=substr(tvk,2,1);p10=cena*0;
        p11=lag7(kp);p12=lag7(kol_mest);
        p13=lag9(kp);p14=lag11(kp);p15=lag13(kp);p16=lag15(kp);
        if lag15(tvk)=tvk and lag15(napr)=napr and lag15(h1)=h1 and lag15(h2)=h2 and lag15(hh)=hh
        and lag15(PZD)=PZD then output;
        keep p1-p16 y1 dtpzd h1 napr;run;







/* собственно программа */


%let kol_p=16;
%let set=dann;
%let min_dlina=100;





%macro derevo;
data dn;set &set;nn+1;rez=1;run;
%let kol_rez=1;
data derevo;if rez=1 then output;run;


/**/
%flag:;
data dn_;set dn;array p[&kol_p];
       do i=1 to &kol_p;pp=p[i];output;end;
       keep y1 pp i rez;run;

proc sql;create table dn_ as select rez,i,pp,sum(y1) as sy,count(*) as kol
         from dn_ group by 1,2,3 order by 1,2,3;quit;
proc sql;create table dn_s as select rez,sum(sy) as ssy,sum(kol) as skol
     from dn_ where i=1 group by 1;quit;
data dn_;merge dn_ dn_s;by rez;run;

data dn_;set dn_;retain ss kk 0;if lag(i)^=i then do;ss=0;kk=0;end;
        ss=ss+sy;kk=kk+kol;ss_=ssy=ss;kk_=skol-kk;z1_=ss/kk;z2_=0;delt=0;
        if kk_>0 then do;z2_=ss_/kk_;delt=-kk*kk_*((z1_-z2_)**2)/skol;
        if kk>&min_dlina and kk_>&min_dlina then output;
        keep rez i pp delt;end;run;

proc sort data=dn_;by rez delt;run;
data dn_;set dn_;if lag(rez)^=rez then output;keep rez i pp;run;
%let kol=0;
data dn_;set dn_;retain kr &kol_rez;kr=kr+1;rez1=kr;kr=kr+1;rez2=kr;
        call symput('kol_rez',kr);call symput('kol',1);drop kr;run;
%put &kol_rez;
data derevo;set derevo dn_;run;

data dn;merge dn dn_;by rez;array p[&kol_p];
        if i^=. then do;if p[i]<=pp then rez=rez1;else rez=rez2;end;drop i pp rez1 rez2;run;
proc sort data=dn;by rez;run;
%if %sysevalf(&kol=1) %then %goto flag;
%mend;

%derevo;


proc sql;create table rez as select napr,h1,dtpzd,y1 as kp,rez
        from dn order by 1,2,3;quit;

proc gplot data=rez;plot kp*dtpzd=rez;by napr h1;symbol i=join v=plus;run;quit;


proc sql;create table rez2 as select rez,nn,y1 as kp
        from dn order by 1,2,3;quit;
data rez2;set rez2;nn2+1;run;

proc gplot data=rez2;plot kp*nn2=rez;run;quit;









/**/
