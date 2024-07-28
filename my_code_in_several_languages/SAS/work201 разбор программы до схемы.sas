

libname ml 'd:\mylib\poezda';
libname mylib 'd:\mylib\prigorod';

dm 'afa c=ml.connects.link.frame';

dm 'afa c=ml.otcheti_vpt_prig.connect.frame';

/*****************/
/* развитие программы  work152... */


rsubmit;libname pgt db2 authid=pgt;endrsubmit;libname pgt slibref=pgt server=proizvod;

rsubmit;libname tst db2 authid=tst;endrsubmit;libname tst slibref=tst server=otladka;


rsubmit;libname vpt db2 authid=vpt;endrsubmit;libname vpt slibref=vpt server=proizvod;

rsubmit;libname vpt db2 authid=vpt;endrsubmit;libname vpt slibref=vpt server=otladka;


rsubmit;libname xran db2 authid=xran;endrsubmit;libname xran slibref=xran server=proizvod;

/**********************************************************************************************/

/* разбор текстового файла программы, сделать блок схему всех процедур */

%let kol_file=1;
%let name1='D:/podstanovki_dlia_otladki/main.txt';





%let kol_file=1;
%let delet=('');%LET ISP=('MAIN_INT');

%let kol_file=2;
%let name1='D:/podstanovki_dlia_otladki/main_copy.txt';
%let name2='D:/podstanovki_dlia_otladki/m1.txt';
%let name3='D:/podstanovki_dlia_otladki/end of progr.txt';




%macro struct;
data file;if v='1' then output;file='11';run;
/* чтение файла побайтно */
%do nf=1 %to &kol_file;
data file&nf;infile &&name&nf recfm=n;
  format v $1.;input V $char1. @@;run;
data file;set file file&nf;if file='' then file=&nf;run;
%end;

/** / %mend;%struct;/**/


/*ПРИВЕСТИ К ЗАГЛАВНЫМ БУКВАМ*/
data file;set file;array c[255];retain c1-c255;
        alf='abcdefghijklmnopqrstuvwxyz';
        al2='ABCDEFGHIJKLMNOPQRSTUVWXYZ';
if _n_=1 then do;do i=1 to 255;c[i]=i;end;
        l=length(alf);do i=1 to l;c[rank(substr(alf,i,1))]=rank(substr(al2,i,1));end;end;
        v=byte(c[rank(v)]);keep v file;run;

/*разбивка на строки*/
data file;set file;c=rank(v);retain str 1 stb 0;if c=10 then do;str+1;stb=0;end;
        stb+1;if c in(9,10,13) then do;c=32;v=' ';end; drop c;run;

/*убрать закомментированные строки*/
data fd;set file;if lag(str)=str and lag(v)='-' and v='-' then output;
        if lag2(str)=str and lag2(v)='[' and lag(v)='#' and v=']' then output;keep str;run;
proc sql;create table fd as select distinct str from fd;
delete from file where str in(select str from fd);drop table fd;quit;
proc sort data=file;by str stb;run;

/*разделители , и ; оконтурить пробелами ТОЛЬКО ОСТОРОЖНЕЕ СО СКОБКОЙ*/
data file;set file;output;
        if v in(',',';','+','-','*','/','=','>','<',')','^','(') then do;v=' ';stb=stb-0.1;output;stb=stb+0.2;output;end;
        /*if v in('(') then do;v=' ';stb=stb+0.1;output;end;*/run;
proc sort data=file;by str stb;run;

data file;set file;retain blk 1;if v=';' then do;blk=blk+1;v=' ';end;run;

/*приборка лишних пробелов*/
data file;set file;retain t 0;if v="'" then t=1-t;
        p=1;if v=' ' and lag(v)=' ' then p=0;if p=1 then output;drop p t;run;

/*разбивка на слова*/
data fl;set file;format vv $50.;retain l t 0 vv;if v="'" then t=1-t;
        if v=' ' and l>0 and t=0 then do;vv=trim(left(vv));output;l=0;vv='';end;
        if l=0 then vv=v;else vv=substr(vv,1,l)||v;l=l+1;drop v l t;run;
data fl;set fl;sl+1;drop str stb;run;
%let len=1;proc sql;reset noprint;select max(length(vv)) into:len from fl;quit;
%put &len;data fl;format vv $&len..;set fl;run;


%mend;

%struct;

/*разбивка на формулы по скобкам*/
%let err=0;%let mkol=0;
data _null_;set fl;retain mkol kol 0;if vv='(' then kol=kol+1;if vv=')' then kol=kol-1;
        if blk^=lag(blk) and kol^=0 then call symput('err','1');
        if kol>mkol then do;mkol=kol;call symput('mkol',trim(left(mkol+2)));end;run;
%put &err &mkol;
/*data fl_skob;set fl;array bg[&mkol];retain kol bg 0;
        if vv='(' then do;kol=kol+1;bg[kol]=sl;end;
        if vv=')' then do;skob_beg=bg[kol];skob_end=sl;output;kol=kol-1;end;
        keep skob_beg skob_end kol;run;*/

proc sort data=fl;by descending sl;run;
data fl;set fl;array bg[&mkol];retain skob_kol bg skob_end 0;
        if lag(blk)^=blk then do;skob_kol=1;bg[skob_kol]=sl;skob_end=sl;end;
        if vv=')' then do;skob_kol=skob_kol+1;bg[skob_kol]=sl;skob_end=sl;end;
        output;
        if vv='(' then do;skob_end=0;skob_kol=skob_kol-1;
                if skob_kol>0 then do;skob_end=bg[skob_kol];end;end;
        drop bg1-bg&mkol;run;

proc sort data=fl;by sl;run;
data fl;set fl;array bg[&mkol];retain kol bg skob_beg 0;
        if lag(blk)^=blk then do;kol=1;bg[kol]=sl;skob_beg=sl;end;
        if vv='(' then do;kol=kol+1;bg[kol]=sl;skob_beg=sl;end;
        output;
        if vv=')' then do;skob_beg=0;kol=kol-1;
                if kol>0 then do;skob_beg=bg[kol];end;end;
        drop bg1-bg&mkol kol;run;

/*номер формулы = номер первой строки её действия*/
data form;set fl;retain form form2 -1;
        if vv='(' then do;form2=skob_beg;vv='';output;vv='(';end;
        form=skob_beg;form2=.;
        output;drop skob_kol skob_beg skob_end file;run;

proc sort data=form;by form sl;run;











/*работа по update-ам*/

data up;set fl;if lag(blk)^=blk AND vv in('UPDATE') THEN OUTPUT;run;
proc sql;create table fl_UP as select * from fl where blk in(select blk from UP)
        order by sl;DROP TABLE UP;quit;

data fl_up;set fl_up;retain sk 0 z tab;
if lag(vv)='UPDATE' THEN tab=vv;
if index(vv,'(')>0 then sk=sk+1;
if vv in('UPDATE','SET','WHERE','ON','GROUP') and sk=0 THEN z=VV;output;if vv=')' then sk=sk-1;
if lag(blk)^=blk then tab='';run;

data fl_up;set fl_up;lv=lag(vv);drop lv;if lag(blk)^=blk then nom=0;
        if z='SET' and lag2(vv) in(',','SET') and vv='=' and sk=0 then do;pole=lv;nom+1;end;
        if z='SET' and vv=',' and sk=0 then pole='';
        if z='WHERE' THEN do;pole=z;nom=0;end;
        if lag(z)^=z then pole='';retain pole;run;

data fl_up;set fl_up;where pole^='';drop z;run;
data fl_up;set fl_up;retain z ;
if vv in('SELECT','FROM') /*and sk=0*/ THEN z=VV;if vv in('WHERE',')') THEN Z='';
if blk^=lag(blk) or pole^=lag(pole) then z='';
run;

data fl_up_fr;set fl_up;where z='FROM' and vv^=z;tab2=vv;drop vv sl sk z pole;run;
proc sort data=fl_up;by blk nom sl;where z^=vv and z^='FROM';run;
proc sort data=fl_up_fr;by blk nom;run;
data fl_up;merge fl_up fl_up_fr;by blk nom;run;

data fl_up;SET fl_up;if sk=0 then tab2='';
        if tab2='' then do;nm=tab;output;end;
        if z='SELECT' THEN do;nm=tab2;output;end;
        if tab2^=' ' and z='' then do;nm=tab;output;nm=tab2;output;end;
        drop z tab2;run;
data fl_up;set fl_up;if nom=0 then pole='UPDATE';run;

proc sql;create table fl_up_ as select distinct blk,tab,nom,pole,pole as vv,tab as nm,file from fl_up where nom>0;quit;
data fl_up;set fl_up fl_up_;run;
proc sql;drop table fl_up_,fl_up_fr;quit;
proc sort data=fl_up;by blk nom sl;run;




/*работа по delet-ам*/
data del;set fl;if lag(blk)^=blk AND vv in('DELETE') THEN OUTPUT;run;
proc sql;create table fl_del as select * from fl where blk in(select blk from del)
        order by sl;DROP TABLE del;quit;

data fl_del;set fl_del;retain sk 0 z tab;
if lag2(vv)='DELETE' and lag(vv)='FROM' THEN tab=vv;
if index(vv,'(')>0 then sk=sk+1;
if vv in('UPDATE','SET','WHERE','ON','GROUP','DELETE','SELECT','FROM') /*and sk=0*/ THEN z=VV;
if vv='WHERE' and sk>0 THEN z='WHERE2';
if vv=')' then sk=sk-1;if vv=')' and sk=0 then z='WHERE';output;
if lag(blk)^=blk then tab='';
run;

data fl_del_fr;set fl_del;where z='FROM';
        if lag(blk)^=blk then tb=0;if vv=z then do;nn=-1;tb+1;end;      nn+1;drop sl sk z;run;
proc sql;create table fl_del_fr as select blk,tab,tb,
        max(case when nn=1 then vv end) as nm,max(case when nn=2 then vv end) as lb
        from fl_del_fr where nn>0 group by 1,2,3;quit;

data fl_del_wh;set fl_del;where z in('WHERE','SELECT','WHERE2');
        if z='SELECT' then z='WHERES';if z='WHERE' then z='WHERE1';pole=z;nom=0;drop z;run;



/**/%goto flag_end;/******/



/*работа по insert-ам */
/*data ins;set fl1;where vv in('INSERT','DELETE','UPDATE');run;)*/
data ins;set fl;if lag(blk)^=blk AND vv in('INSERT') THEN OUTPUT;run;
proc sql;create table fl_ins as select * from fl where blk in(select blk from ins)
        order by sl;DROP TABLE INS;quit;

data fl_ins;set fl_ins;if lag(blk)^=blk then sl_=0;sl_+1;k=index(vv,'(');
        if sl_=3 and k>0 then do;vv=substr(vv,1,k-1);output;vv='(';sl=sl+0.1;output;end;
        else output;drop k sl_;run;

data fl_ins;set fl_ins;retain sk 0 z tab;
        if lag(vv)='INTO' THEN tab=vv;
        if index(vv,'(')>0 then sk=sk+1;
        if vv in('SELECT','INSERT','FROM','WHERE','ON','GROUP','WITH') THEN z=VV;
        if vv in('LEFT','RIGHT','JOIN') THEN Z='FROM';
        output;if vv=')' then sk=sk-1;run;


/*обработка для WITH */
data fl_ins;set fl_ins;retain w;if lag(blk)^=blk then do;w=0;nw=0;end;if vv='WITH' then do;w=1;nw=0;end;
lv=lag(vv);l2v=lag2(vv);l3v=lag3(vv);
if w=1 and sk=1 and vv='SELECT' then do;nw+1;
        if lv='(' and l2v='AS' then tb=l3v;end;if w=1 and sk=0 and vv='SELECT' then do;nw=0;tb='';end;
        drop lv l2v l3v;retain tb;run;
data fl_ins;set fl_ins;if w=1 and tb^='' then tab=tb;if nw>0 then do;blk=blk-0.5+nw/100;sk=sk-1;end;drop nw tb w;
        if sk>=0 then output;run;







data fl_ins_fr;set fl_ins;where z='FROM';IF LAG(BLK)^=BLK THEN TB=0;
if vv in('FROM',',','JOIN') THEN do;TB+1;k=0;end;drop sl sk z k;
if vv not in('FROM',',','JOIN','LEFT','RIGHT','OUTER','AS','ON','UNION',')','ALL','(') THEN do;k+1;if k<3 then OUTPUT;end;run;
data nil;run;
data fl_ins_fr;set fl_ins_fr nil;retain lblk ltb nm lb ltab;
if lblk^=blk or ltb^=tb then do;if _n_^=1 then output;nm=vv;end;lb=vv;
lblk=blk;ltb=tb;ltab=tab;run;
data fl_ins_fr;set fl_ins_fr;tb=ltb;blk=lblk;tab=ltab;drop lblk ltb vv ltab;if lb=nm then lb='';run;




data fl_ins_str;set fl_ins;where z='INSERT' and sk=1;if lag(blk)^=blk then nom=0;pole_n=vv;
        retain nom 0;if vv in('(',',',')') then nom+1;else output;keep nom pole_n blk tab;run;






/*полное описание всех полей новых из старых*/
data fl_ins_vv;set fl_ins;where z='SELECT';if lag(blk)^=blk then nom=0;
        if vv in(',','SELECT') and sk=0 then nom+1;else output;run;
proc sql;create table fl_ins_vv as select *,max(sl) as msl,min(sl) as sl_
        from fl_ins_vv where vv^='DISTINCT' group by blk,nom order by sl;quit;
data fl_ins_vv;set fl_ins_vv;
        if sl=msl AND (lag(vv)='AS' or sl_=msl) then pole=vv;run;
proc sql;create table fl_ins_vv as select *,max(pole) as pole_
        from fl_ins_vv group by blk,nom order by sl;quit;
data fl_ins_vv;set fl_ins_vv;pole=pole_;IF NOT(sl>=msl-1 and sl_^=msl and pole^='') then output;
        drop pole_ msl sl_ z;run;



/* обработка условия where */
data fl_ins_wh;set fl_ins;where z in('WHERE','ON');nom=0;pole='WHERE';drop z;run;
/*объединение WHERE и просто SELECTа */
data fl_ins_vv;set fl_ins_vv fl_ins_wh fl_del_wh fl_up;run;


/*оставляем только голые зависимости от переменных*/
data fl_ins_vvf;set fl_ins_vv;
        if vv in('CASE','WHEN','THEN','ELSE','END','=','(',')','AND','NOT','IN','OR','IS','NULL','*','/','+','-',
        'ROUND','>','<',',','SUM','SUBSTR','DECIMAL','CONCAT','||','WHERE','BETWEEN','ON','SELECT','^','DISTINCT')
        or substr(vv,1,1) in("'",':') or index(vv,'(')>0 then vv='';p=1*vv;if p^=. then vv='';
        pole2=vv;nm_=nm;drop p sl sk vv nm;run;
proc sql;create table fl_ins_vvf as select distinct * from fl_ins_vvf;quit;
proc sql;create table fl_ins_vvf as select distinct *  from fl_ins_vvf as a left join fl_ins_str as b
        on a.blk=b.blk and a.nom=b.nom;quit;

data fl_ins_vvf;set fl_ins_vvf;IF NOM=0 THEN POLE_N=POLE;
        if pole='' then pole=pole_n;drop /*pole_n*/ POLE2 k;
k=index(pole,'.');if k>0 then pole=substr(pole,k+1,length(pole)-k);
k=index(pole2,'.');s_pole=pole2;s_pref='11111111';s_pref='';
        if k>0 then do;s_pref=substr(pole2,1,k-1);s_pole=substr(pole2,k+1,length(pole2)-k);end;run;
proc sql;create table fl_ins_vvf(drop=sp) as select *,max(s_pole) as sp
        from fl_ins_vvf group by blk,tab,nom,pole_n having s_pole^='' or s_pole=sp;quit;
        /*А ВОТ ТУТ БЫ ЕЩЁ ЧУТЬ ПРОВЕРИТЬ ПРАВИЛЬНОСТЬ ЗАПОЛНЕНИЯ НАЗВАНИЙ ПОЛЕЙ - ВРУЧНУЮ*/


/*добавить структуру тех таблиц, которые не описаны через шапку селекта*/
proc sql;create table fl_ins_str_ as select distinct blk,tab,nom,pole as pole_n
        from fl_ins_vvf where blk not in(select blk from fl_ins_str) and nom>0;quit;
data fl_ins_str;set fl_ins_str fl_ins_str_;run;
proc sql;drop table fl_ins_str_;quit;



/*добавить случаи "SELECT * " */
data fl_ins_vvf t(keep=blk);set fl_ins_vvf;if pole='*' and nom=1 then output t;else output fl_ins_vvf;run;
proc sql;create table t as select a.blk,a.tab,a.nm,file from fl_ins_fr as a,t as b where a.blk=b.blk;quit;
proc sql;create table t as select
        a.blk,a.tab,b.nom,pole_n as pole,pole_n,pole_n as s_pole, nm as s_pref,file
        from t as a,fl_ins_str as b where a.nm=b.tab;quit;
data fl_ins_vvf;set fl_ins_vvf t;run;
proc sql;drop table t;quit;
proc sort data=fl_ins_vvf nodup;by _all_;run;




/* для update результат where запихнуть в каждую из переменных */
data p;set fl_ins_vvf;where pole='UPDATE';drop nom pole pole_n;run;
proc sql;create table p as select * from p,(select distinct blk,nom,pole,pole_n from fl_ins_vvf where nom>0) as b
        where p.blk=b.blk;quit;
data fl_ins_vvf;set fl_ins_vvf p;run;
proc sql;drop table p;quit;



/* что-то по структуре - по работе с несколькими таблицами - откуда что берётся */
data fl_ins_fr;set fl_ins_fr fl_del_fr;run;
proc sql;create table struct as select distinct tab,pole_n from fl_ins_str;quit;
proc sql;create table struct as select distinct blk,a.tab,tb,nm,lb,pole_n
        from fl_ins_fr as a ,struct as b where b.tab=a.nm order by blk,tb,pole_n;quit;

proc sql;create table struct as select b.blk,b.tab,tb,nm,lb,pole_n,s_pref,s_pole
 from struct as a right join
        (select distinct blk,tab,s_pole,s_pref from fl_ins_vvf) as b
        on a.blk=b.blk and a.pole_n=b.s_pole and not (lb^='' and s_pref^='' and lb^=s_pref);quit;

proc sql;create table struct as select *
 from struct as a left join
        (select distinct blk,tb as tb_,nm as nm_,lb as lb_ from fl_ins_fr where index(nm,'.')>0) as b
        on a.blk=b.blk ;quit;
data struct;set struct;if tb=. and tb_^=. then do;tb=tb_;nm=nm_;lb=lb_;pole_n=s_pole;end;drop tb_ lb_ nm_;run;



proc sql;create table fl_ins_vvf(drop=lb s_pref pole_n) as select * from fl_ins_vvf as a left join struct as b
        on a.blk=b.blk and a.s_pole=b.s_pole and a.s_pref=b.s_pref order by blk,nom;quit;
data fl_ins_vvf;set fl_ins_vvf;p=0;if nm_^='' then do;nm=nm_;end;drop nm_;
        if nom=0 and pole='WHERE1' AND TB=2 THEN P=1;
        if nom=0 and pole='WHERES' AND TB=1 THEN P=1;
        if nom=0 then pole='WHERE';if p=0 then output;drop p tb;run;
proc sort data=fl_ins_vvf nodup;by _all_;run;





data fl_sost;set fl_ins_vvf;if s_pole='' then do;s_pole='-';nm='';end;run;
proc sort data=fl_sost nodup;by _all_;run;

/*удаление ненужных селектов*/
proc sql;delete from fl_sost where blk in(select blk from fl_ins_fr where nm in &delet);quit;

/*новая нумерация блоков*/
proc sort data=fl_sost;by blk nom;run;
data fl_sost;set fl_sost;if blk^=lag(blk) then bl+1;call symput('kol_bl',bl);run;%put &kol_bl;
/*proc sql;create table tabs as select distinct blk,tab from fl_ins_vvf;quit;*/

/**/%goto flag_end;/******/
/*первоначальный рассчёт использования столбцов*/
proc sql;create table isp as select distinct blk as blk_,nm as tab,s_pole as pole,'1' as isp from fl_sost;
create table fl_sost(drop=blk_) as select distinct * from fl_sost as a left join isp as b
        on a.tab=b.tab and a.pole=b.pole and blk<blk_ order by blk,nom,s_pole;
drop table isp;quit;
data fl_sost;set fl_sost;if isp='' then isp='0';if nom=0 then isp='2';if index(tab,'.')>0 OR TAB IN &ISP then isp='3';run;
%put &kol_bl;
/** / %goto flag_end;/******/


/*рассчёт состава столбцов*/
%macro a;
data fl_sostav;set fl_sost;if bl=1 then output;drop isp;run;

%do bl=2 %to &kol_bl;
data t;set fl_sost;where bl=&bl;run;
proc sql;create table t as select distinct t.blk,t.bl,t.tab,t.nom,t.pole,t.s_pole,t.nm,b.s_pole as s_pole2,b.nm as nm2
        from t left join fl_sostav as b on t.nm=b.tab and t.s_pole=b.pole;quit;
data t;set t;if nm2^='' then do;s_pole=s_pole2;nm=nm2;end;drop s_pole2 nm2;run;

data fl_sostav;set fl_sostav t;run;proc sql;drop table t;quit;
%end;

proc sort data=fl_sostav nodup;by _all_;run;
proc sql;create table fl_sostav as select *,max(blk) as mblk from fl_sostav group by tab;quit;
data fl_sostav;set fl_sostav;blk=mblk;drop mblk bl nom;run;
proc sort data=fl_sostav nodup;by _all_;run;
proc sql;create table fl_sostav as select *,count(*) as kol
        from fl_sostav group by blk,tab,pole;quit;


data fl_sost_;set fl_sost;where bl=&kol_bl;run;

%let bl=%sysevalf(&kol_bl-1);
%do bl=%sysevalf(&kol_bl-1) %to 1 %by -1;%put bl=/&bl/;
data t;set fl_sost;where bl=&bl;run;
proc sql;create table t as select *
        from t left join (select nm as tab,s_pole as pole,max(isp) as misp from fl_sost_ group by 1,2) as b
        on t.tab=b.tab and t.pole=b.pole;quit;
data t;set t;/*if nom=0 or index(tab,'.')>0 then do;isp='2';misp='2';end;
        if misp='' then misp='0';
        if isp='2' and misp in('0','1') then isp='1';*/ if isp='1' and misp>='2' then isp='2';drop misp;run;
data fl_sost_;set t fl_sost_;run;
proc sql;drop table t;quit;
%end;

data fl_sost;set fl_sost_;run;
proc sort data=fl_sost nodup;by _all_;run;
proc sort data=fl_sostav nodup;by _all_;run;
%mend;%a;

proc sql;drop table file,fl,fl_ins,fl_ins_fr,fl_ins_str,fl_ins_vv,fl_ins_vvf,fl_sost_,fl_up,nil,struct,
        fl_ins_wh,fl_del_wh,fl_del_fr,fl_del;quit;

proc sql;create table fl_sost as select * from fl_sost as a left join
        (select distinct tab,pole,isp as isp_ from fl_sost where isp='2') as b
        on a.tab=b.tab and a.pole=b.pole order by 1,2,3,4,5,6;quit;
data fl_sost;set fl_sost;if isp_='2' then isp='2';drop isp_;run;

%flag_end:;
%mend;


/*
isp=
0 - никуда не пошло
1 - пошло, но не до конца
2 - пошло до конца
3 - момент непосредственно постановки в базу
*/


/*плохо смотрит reest1 из (mnree1 left join .bagm) */







%let kol_file=1;
%let delet=('');%LET ISP=('MAIN_INT');

%let name1='C:\Users\mp_elsufievam\Desktop\интернет\m_int.txt';


%let kol_file=2;
%let name1='D:/podstanovki_dlia_otladki/main_copy.txt';
%let name2='D:/podstanovki_dlia_otladki/m1.txt';
%let name3='D:/podstanovki_dlia_otladki/end of progr.txt';

%struct;


data sostav_carr;set fl_sostav;run;
data sostav_carr_ish;set fl_sost;run;
proc sql;create table sostav_carr_isp as select distinct isp,/*blk,*/tab,/*nom,*/pole,min(nom) as nom
        from sostav_carr_ish group by tab,pole order by 1,2,4;quit;
proc sql;create table sostav_carr_isp2 as select distinct isp,blk,tab,nom,pole from sostav_carr_ish;quit;


%let kol_file=1;
%let delet=('MNBAG');%let delet=('');%LET ISP=('');
%LET ISP=('MAIN11');
%let name1='C:\Documents and Settings\mp_els\Рабочий стол\АБД\окончательно для работы\main\main_0.txt';
%struct;
data sostav_main;set fl_sostav;run;
data sostav_main_ish;set fl_sost;run;
proc sql;create table sostav_main_isp as select distinct isp,/*blk,*/tab,/*nom,*/pole from sostav_main_ish;quit;
proc sql;create table sostav_main_isp2 as select distinct isp,blk,tab,nom,pole from sostav_main_ish;quit;













%let delet=('MNBAG');%let delet=('');%LET ISP=('');
/*%LET ISP=('MAIN11');*/
%let kol_file=7;
%let name1='D:/podstanovki_dlia_otladki/main.txt';
%let name2='D:/podstanovki_dlia_otladki/m1.txt';
%let name3='D:/podstanovki_dlia_otladki/m2.txt';
%let name4='D:/podstanovki_dlia_otladki/m3.txt';
%let name5='D:/podstanovki_dlia_otladki/m4.txt';
%let name6='D:/podstanovki_dlia_otladki/m5.txt';
%let name7='D:/podstanovki_dlia_otladki/m6.txt';
%struct;
data sostav_main;set fl_sostav;run;
data sostav_main_ish;set fl_sost;run;
proc sql;create table sostav_main_isp as select distinct isp,/*blk,*/tab,/*nom,*/pole from sostav_main_ish;quit;
proc sql;create table sostav_main_isp2 as select distinct isp,blk,tab,nom,pole from sostav_main_ish;quit;












proc sql;create table sostav_main_isp3 as select distinct tab,pole,min(isp) as isp1,max(isp) as isp2
        from sostav_main_isp group by 1,2;quit;





data main;set sostav_main;where tab='MAIN11';
        if substr(nm,1,6)=':LSCH.' then nm='EXPBD.'||SUBSTR(NM,7,LENGTH(NM)-6);run;
data carr;set sostav_carr;where tab in('CARRUCH','EXPEST.PRMAIN');
        if substr(nm,1,6)=':LSCH.' then nm='EXPBD.'||SUBSTR(NM,7,LENGTH(NM)-6);run;

proc sql;create table main_ as select * from main as a left join
        (select distinct s_pole,nm,'1' as isp from carr) as b
        on a.s_pole=b.s_pole and a.nm=b.nm;
create table main_(drop=misp) as select *,max(isp) as misp
        from main_ group by pole having misp='1' order by pole,nm,s_pole;quit;

proc sql;create table carr as select * from carr as a left join
        (select distinct s_pole,nm,'1' as inn from main_) as b
        on a.s_pole=b.s_pole and a.nm=b.nm order by pole,nm,s_pole;



proc sql;create table carr_isp as select distinct nm,s_pole,inn,tab from carr;quit;














































































data agr;set expolap.prig_agregati2;where year=2012 and month=9 and kst=2007867 and par_name in('plata','s_pot','bag_plat');run;

proc sql;create table agr_ as select par_name,sum(param) as param from agr group by 1;quit;




data prig;set pgt.pg10;where dtdok='28sep2012'd and stp=2007867;run;





rsubmit;proc sql;update expolap.prig_daily2 set lgt=9
         where dtdok='08oct2012'd and str=28 and vid=2 and lgt=11;quit;




/**/
