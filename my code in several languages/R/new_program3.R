
# ИЗ СТАРОЙ ПРОГРАММЫ trainset, ЧТО ЕЩЁ НЕ ВЗЯТО - В ФАЙЛЕ "trainset - что ещё не взято"

if (getwd()=="C:/Users/user/Documents"){  #если на локальной машине - не отрабатывает пока
  setwd("D:/RProjects/test/")}

setwd("D:/RProjects/test") #устанавливает корневую рабочую директорию - в любой машине


if (!require("hash")) {install.packages("hash")}
library("hash")

if (!require("stringr")) {install.packages("stringr")}
library("stringr")

if (!require("plyr")) {install.packages("plyr")}
library("plyr")

if (!require("zoo")) {install.packages("zoo")}
library("zoo")

if (!require("data.table")) {install.packages("data.table")}
library("data.table")

eval(parse('./scripts/new_program1.R', encoding="UTF-8"))

library(digest) # библиотека ХЭШ-ФУНКЦИЯ   c=(1:10000);digest(c)

#ДАЛЕЕ ВСЁ ДЛЯ НЕЙРОСЕТЕЙ


#ВНАЧАЛЕ ПОДКЛЮЧИТЬ БИБЛИОТЕКУ ПАРАЛЛЕЛЬНЫХ ВЫЧИСЛЕНИЙ
if (!require("parallel")) {install.packages("parallel")};
library("parallel")


   
# постановка изначальных настроек для пробника нейросети
#neir=list();neir$vhod=list();neir$vhod$name='sahalin';neir$vhod$y='kp1' #какое поле идёт в прогноз

#кого принципиально можно в массив, на вход по данным, и вход по текущему значению (ограничение, цена...)
#neir$vhod$mas=c('Train','Type','Klass','','Skor','Napr','pzd','weekday','day')
#neir$vhod$xz=c('kp1','pkm1','plata1','rent1','cena1','FreeSeats','kp7','kp14','kp21')
#neir$vhod$y_ogr=c('Seats')
#neir$vhod$dat=c('Date')


#старое описание - оставил чтобы не было ошибки
neural=list();


#функции нейронов для нейросети, и их производных
neuron=list();
neuron$f0 <- function (v) {return ( v)}
neuron$pr0 <- function (v) {return ( 1)}

neuron$f1 <- function (v) {return ( abs(v))}
neuron$pr1 <- function (v) {return ( sign(v))}

neuron$f2 <- function (v) {return ( pmin(v**2,1000))}
neuron$pr2 <- function (v) {return ( 2*v)}

neuron$f3 <- function (v) {return ( pmin(exp(v),1000))}
neuron$pr3 <- function (v) {return ( pmin(exp(v),1000))}

neuron$f4 <- function (v) {return ( ((v/(abs(v)+1))+1)/2 )}
neuron$pr4 <- function (v) {return ( 0.5/(((abs(v)+1))**2) )}


neuron$max_tip_neir=4








#Вычисление размера ошибки нейросети на данной настройке 
neuron$neir.err <- function (str,vib,mas,dn,is_rez,vih_name=NA) {
  #Вначале параметры
  kol_x=vib$kol_x;kol_m=vib$kol_m;
  kol_reb=max(str$rebro)
  #сперва значение нейронов массивов
  if (kol_m>0) {for (i in (1:kol_m)){ #    i=1
    nm=paste('x',i+kol_x,sep='');nm_=paste('mm',i,sep='');
    dn[,nm]=mas[dn[,nm_],'fun']}}
  
  #теперь работа по каждому ребру
  for (reb in (1:kol_reb)){   #   reb=0   reb=reb+1
    vhod=str[(str$rebro==reb),'vhod'];vih=str[(str$rebro==reb),'vih'];
    nm=paste('x',vih,sep='');nm_=paste('x',vhod,sep='')
    zn=str[(str$rebro==reb),'zn'];
    
    #вычисление значения на ребре
    if (vhod==-1) {
      nm_='y_ogr';v=(dn[,nm]>dn[,nm_]) #ограничитель
      dn[v,nm]=dn[v,nm_]+zn*(dn[v,nm]-dn[v,nm_]) 
    } else {    
      if (vhod==0) {dn[,nm]=zn} else {
        if (vhod<vih) {dn[,nm]=dn[,nm]+zn*dn[,nm_]} else{
          if (vhod==vih) { #функции нейронов
            if (zn==0) {dn[,nm]=neuron$f0(dn[,nm])}
            if (zn==1) {dn[,nm]=neuron$f1(dn[,nm])}
            if (zn==2) {dn[,nm]=neuron$f2(dn[,nm])}
            if (zn==3) {dn[,nm]=neuron$f3(dn[,nm])}
            if (zn==4) {dn[,nm]=neuron$f4(dn[,nm])}
          }}}}
  }
  
  # рассчёт выходных данных  
  err_=list();
  
  if (!is_rez){
    if (neuron$vhod$kol_upr==0){ 
      dn$err=(pmax(abs(dn[,nm]-dn$y),dn$mer))**2 
    }else{dn$err=(dn[,nm]-dn$y)**2 }
    err_$err=sum(dn$err)
    if (!is.na(vih_name)) {
      dn_=dn[,c(vih_name,'err')]
      dn_=aggregate(x=subset(dn_,select=c('err')),by=subset(dn_,select=vih_name), FUN="sum" )
      err_$dn_=dn_
    }
    
  } else { #если итоговая проверка
    vh=neuron$vhodi;
    ogr=as.character(vh[(vh$tip %in% c('dat','ogr')),'nm_']) #поля на сохранение
    dn$zn=(vib$max_y-vib$min_y)*dn[,nm]+vib$min_y
    
    if (neuron$vhod$kol_upr==0){
      dn=subset(dn,select=c('row','yy',ogr,'dn','zn','min_err'))
      dn$err=pmax(abs(dn$yy-dn$zn),dn$min_err)
    }else{
      dn=subset(dn,select=c('row','yy',ogr,'dn','zn','upr'))
      dn$err=abs(dn$yy-dn$zn)}
    dn$nset=vib$nset
    
    
    #количество настроечных полей
    koll=vib$kol_param
    #вычислить среднеквадратичное значения ошибок
    dn_=dn[(dn$dn==1),c('dn','err')];
    proc=neuron$vhod$proc
    if (nrow(dn_)>0){
      dn_$err2=dn_$err**2;
      err_$error=sum(dn_$err**2);err_$kol=nrow(dn_)
      
      #среднекадратичное
      err_$err_sr=(err_$error/(err_$kol-koll))**0.5
      
      #постановка ошибки 95% квантили 
      o=order(dn_$err);dn_=dn_[o,]
      dn_$row=(1:nrow(dn_));dn_=dn_[(dn_$row>koll),];kol=nrow(dn_)
      for (pr in proc$proc){if (!is.na(pr)){
        nm=as.character(proc[((proc$proc==pr)&(!is.na(proc$proc))),'name'])
        err_[nm]=dn_[min(round((kol+1)*pr/100),kol),'err']
      }}
    } else{#редкий случай - прогнозы есть а настройки нет, и нейросеть самая первоначальная (oper==0)
      for (nm in proc$name){err_[nm]=NA}
      
    }
    err_$dann=dn;kol=1;o=1;pr=1
    rm(dn_,vh,kol,koll,o,ogr,proc,pr)
  }
  return (err_)
  rm(dn,mas,str,vib,err,err_,i,is_rez,kol_m,kol_reb,kol_x,nm,nm_,reb,v,vhod,vih,zn)
}
#пример   rez=neuron$neir.err(str,vib,pmas,dn,is_rez=TRUE);







#по описанию нейросети прочитать данные, оставить лишь всё нужное
neuron$neir.dann_first_old <- function(neir) {
  
  # постановка используемых ошибок-квантилей
  proc=neir$vhod$proc
  pr=as.data.frame(proc);pr$name=paste('err_',pr$proc,sep='')
  pr[(is.na(pr$proc)),'name']='err_sr'
  pr[(pr$proc==100)&(!is.na(pr$proc)),'name']='err_max'
  neir$vhod$proc=pr
  neir$vhod$errs=as.character(pr$name)
  rm(pr,proc)
  
  #номера поездов
  name=neir$vhod$name;nname=name;
  if (name=='sapsan') {name='doss'}
  pzd=myPackage$trs.dann_load(name,'pzd')
  if (nname=='sapsan') {
    pzd=pzd[((pzd$Stn %in% c('2004001','2006004'))&(pzd$Sto %in% c('2004001','2006004'))),]
  }
  neir$vhod$pzd=pzd
  
  #результат работы прочитать, из сохранённого, немного подработать
  dann=myPackage$trs.dann_load(name,'ext')
  dann=dann[(dann$pzd %in% pzd$pzd),]
  dann$pzd=abs(dann$pzd)
  
  #исправление 0 на '-'
  if ('Skor' %in% names(dann)){dann[(dann$Skor==0),'Skor']='-'}
  if ('First' %in% names(dann)){dann[(dann$First==0),'First']='-'}
  
  # список добавляемых функций от даты
  plus_dats=c('weekday','day','week','mweek','month','rab_day','prazdn','nom_prazdn')
  plus_time=c('hh_otp','hh_otp4')
  
  
  {# добавить поля часы отправления hh_otp и hh_otp4 - и сумму по каждым 4 часам, если более 1 оптравления
    dann$hh_otp=as.character(round((dann$Tm_otp-29.5)/60))
    dann$hh_otp4=as.character(round((dann$Tm_otp-119.5)/240))
    dann[(dann$Train=='-'),c('hh_otp','hh_otp4')]='-'
    dann[(is.na(dann$Tm_otp)),c('hh_otp','hh_otp4')]='-'
  }
  
  {# БЛОК ОБРАБОТКИ СПИСКА ПОЛЕЙ
    #сверить список возможных входов, и переназвать
    nm=c(neir$vhod$mas,plus_dats,plus_time);mas=unique(as.data.frame(nm))
    nm=neir$vhod$xz;xz=unique(as.data.frame(nm))
    nm=neir$vhod$y_ogr;y_ogr=unique(as.data.frame(nm))
    nm=neir$vhod$ostavl;ost=unique(as.data.frame(nm))
    if (nrow(y_ogr)==0){nm=NA;y_ogr=unique(as.data.frame(nm))}
    
    nm=neir$vhod$xs;xs=unique(as.data.frame(nm))
    nm=neir$vhod$vne_zapazd;vne=unique(as.data.frame(nm));vne$nom=0
    
    #из перечня полей взять существующие
    nm=names(dann);
    nm=c(nm,paste('s_',nm,sep=''),plus_dats) # к списку имеющихся добавить суммируемые и возм. плюс-даты
    nm=as.data.frame(nm);nm=unique(nm)
    
    mas=merge(nm,mas,by = c("nm"));mas$tip='mas'
    xz=merge(nm,xz,by = c("nm"));xz$tip='xz'
    xs=merge(nm,xs,by = c("nm"));xs$tip='xs'
    ost=merge(nm,ost,by = c("nm"));ost$tip='ost'
    
    if (nrow(y_ogr)>0){
      y_ogr$tip='ogr';y_ogr$nom=0;y_ogr$name='y_ogr';y_ogr=merge(nm,y_ogr,by = c("nm"))}
    
    for (z in nm$nm){xs[(xs$nm==paste('s_',z,sep='')),'ish']=z} # исходные названия для XS
    
    
    # проверить массивы на наличие разных полей
    for (nm in mas$nm){ if (!(nm %in% plus_dats)){ 
      #    nm='hh_otp4'  nm='Train'  nm='pzd'
      dn=subset(dann,select=nm)
      dn$kol=1;
      dn=aggregate(x=subset(dn,select='kol'),by=subset(dn,select=nm), FUN="sum" )
      dn=dn[(dn$kol>10),]
      dn=dn[(dn[,nm]!='-'),] #убрать все итоговые суммирования 
      if (nrow(dn)==1){mas=mas[(mas$nm!=nm),]}
    }}
    
    #упорядочить по алфавиту
    o=order(mas$nm);mas=mas[o,];mas$nom=(1:nrow(mas))
    o=order(xz$nm);xz=xz[o,];xz$nom=(1:nrow(xz))
    o=order(xs$nm);xs=xs[o,];xs$nom=(1:nrow(xs))
    o=order(ost$nm);ost=ost[o,];ost$nom=(1:nrow(ost))
    if (nrow(y_ogr)>0){
      o=order(y_ogr$nm);y_ogr=y_ogr[o,];y_ogr$nom=(1:nrow(y_ogr))}
    
    # кого оставить вне запаздываний
    vne=vne[((vne$nm %in% xz$nm)|(vne$nm %in% xs$nm)),]
    
    #вернуть - что именно получилось взять
    neir$vhod$mas=as.character(mas$nm);
    neir$vhod$xz=as.character(xz$nm);
    neir$vhod$xs=as.character(xs$nm);
    neir$vhod$y_ogr=as.character(y_ogr$nm);
    neir$vhod$ostavl=as.character(ost$nm);
    
    #статистики количеств полей   
    neir$vhod$kol_mas=nrow(mas);neir$vhod$kol_xz=nrow(xz);neir$vhod$kol_xs=nrow(xs);
    neir$vhod$kol_ogr=nrow(y_ogr)
    neir$vhod$kol_ost=nrow(ost)
    
    #добавления переназваний полей
    mas$nm_=paste("mas", mas$nom, sep = "")
    xz$nm_=paste("xz", xz$nom, sep = "")
    xs$nm_=paste("xs", xs$nom, sep = "")
    ost$nm_=ost$nm #=paste("ost", ost$nom, sep = "")
    
    if (nrow(y_ogr)>0){
      y_ogr$nm_=paste("ogr", y_ogr$nom, sep = "")}
  }
  
  
  #добавка суммирований по четырёхчасовым промежуткам (убрать час - оставить 4часа) - где они есть
  if ('hh_otp4' %in% mas$nm){  ##  ('hh_otp4' %in% neir$vhod$mas)
    #params=c("Seats","min_mest","kp1","rent1","pkm1","plata1","FreeSeats",'Kol_vag') #кого суммировать
    #paramm=c("Train","Type","pzd","Napr","hh_otp","hh_otp4","Date","First","Skor")
    # по кому суммировать
    paramm=c(neir$vhod$dat,as.character(mas[(!(mas$nm %in% plus_dats)),'nm']))
    #кого суммировать
    param_sum=unique(c(as.character(xz$nm),as.character(xs$ish)))
    
    dann_=dann[(dann$hh_otp4!='-'),]
    dann_[,c('Train','hh_otp','First','Skor')]='-';dann_$ed=1
    dann_=aggregate(x=subset(dann_,select=c(param_sum,'ed')),by=subset(dann_,select=paramm), FUN="sum" )
    
    if ('pzd' %in% paramm){
      pzd_=unique(dann_[(dann_$ed>1),'pzd']);
      dann_=dann_[(dann_$pzd %in% pzd_),]}
    
    dann_$ed=NULL;
    if (nrow(dann_)>0){
      dann_[,c('Time','Tm_otp','Rasst','cena1')]=0
      dann=myPackage$sliv(dann,dann_)
    }
    rm(dann_)
  }
  
  
  #добавка суммированное направление
  if ('Napr' %in% mas$nm){  #   ('Napr' %in% neir$vhod$mas)
    dann_=dann[(dann$Napr!='-'),]
    dann_[,c('Train','hh_otp','Napr','First','Skor')]='-';dann_$ed=1
    dann_=aggregate(x=subset(dann_,select=c(param_sum,'ed')),by=subset(dann_,select=paramm), FUN="sum" )
    
    if ('pzd' %in% paramm){
      pzd_=unique(dann_[(dann_$ed>1),'pzd']);
      dann_=dann_[(dann_$pzd %in% pzd_),]}
    dann_$ed=NULL;
    if (nrow(dann_)>0){
      dann_[,c('Time','Tm_otp','Rasst','cena1')]=0
      dann=myPackage$sliv(dann,dann_)
    }
    rm(dann_)
  }
  
  
  dann$yy=dann[,neir$vhod$y]; # постановка апроксимируемой переменной 
  # максимальная дата данных
  dat=as.character(neir$vhod$dat)
  max_dat=as.character(max(as.Date(dann[(!is.na(dann$yy)),dat])))
  neir$vhod$max_dat=max_dat
  
  
  
  if (nrow(xs)>0){ # добавление суммируемых переменных
    dann$row=(1:nrow(dann))
    paramm=as.character(mas[(!(mas$nm  %in% c(plus_dats,'First','Skor'))),'nm'])
    #paramm=c("Train","Type","pzd","Napr","hh_otp4") #поля разбиений
    res=subset(dann,select=c("Date","row",paramm,as.character(xs$ish)))
    for (nm in c('hh_otp','hh_otp4')){
      if (nm %in% paramm){
        res[(res$Train!='-'),nm]='-' # если есть поезд - навремя начхать для суммирования
      }}
    rr=unique(subset(res,select=paramm));rr$nom=(1:nrow(rr))
    res=merge(res,rr,by=paramm)
    for (nm in paramm){res[,nm]=NULL}#удалить поля разбиений - для скорости
    
    o=order(res$nom,res$Date);res=res[o,];
    max_n=nrow(res);res$ed=1;res$rw=(1:max_n)
    
    
    for (nm in xs$ish){#процедура накопит суммирования каждого поля   nm='Seats'
      #print(paste(nm,Sys.time(),sep='  '))
      nm_=as.character(xs[(xs$ish==nm),'nm'])
      res[,nm_]=res[,nm];res[(is.na(res[,nm_])),nm_]=0
      dns <- sapply(FUN = function(part) {
        znn=numeric(max_n);znn[part$rw]=part[,nm_]
        for (i in 1:(max_n-1)) {znn[i+1]=znn[i+1]+znn[i]}
        l <- c(znn) }, X=split(res,res$ed))
      res[,nm_]=dns;res[,nm]=NULL
      rm(dns)
    }
    res$rw=NULL;res$ed=NULL;
    res$Date=NULL;res$mas_nom=res$nom;res$nom=NULL
    dann=merge(dann,res,by='row')
    dann$row=NULL;
    rm(res,rr)
  }
  
  dann$ves=1;dann[(dann$Train=='-'),'ves']=0 #установка веса. 0=не идёт в прогноз, но возможно на вход
  
  {#номер строки - только с даты первых реальных данных
    min_date=min(as.Date(dann[(!is.na(dann$yy)),]$Date))
    o=(as.Date(dann$Date)<min_date)|(dann$ves==0)
    #dann0=dann[(as.Date(dann$Date)<min_date),]
    dann0=dann[o,];dann=dann[(!o),]
    o=order(is.na(dann$yy),dann$Date,dann$Train,dann$Type);dann=dann[o,];
    dann$row=(1:nrow(dann));dann0$row=NA
    dann=rbind(dann,dann0);rm(dann0)
    dann$dat=as.Date(dann[,neir$vhod$dat])}
  
  
  { # Блок рассчёта всех параметров по дате - месяцы, дни недели, даты, праздники...
    dt1=min(dann$dat);dt2=max(dann$dat);
    dat=as.Date((dt1-370):(dt2+750))
    dats=as.data.frame(dat)
    
    dats$day=yday(dats$dat);dats$year=year(dats$dat)
    
    #поиск високосных лет
    vis=aggregate(x=subset(dats,select=c('day')),by=subset(dats,select=c('year')), FUN="max" )
    vis$vis=0;vis[(vis$day==366),'vis']=1;vis$day=NULL
    
    dats=merge(dats,vis,by='year')
    o=((dats$vis==1)&(dats$day>60));dats[o,'day']=dats[o,'day']-1 #исправление високосного года
    dats$vis=NULL
    
    dats$month=month(dats$dat);dats$mday=mday(dats$dat)
    
    #праздники - ввести и расширить до (+-3)дня
    prazdn=c(1,2,3,4,5,6,7,54,67,121,129,163,308)
    prz=as.data.frame(prazdn);k=1;prz[1,'nom_prazdn']=k
    for (i in (2:nrow(prz))){
      if (prz[i,'prazdn']>prz[i-1,'prazdn']+1){k=k+1}
      prz[i,'nom_prazdn']=k}
    
    prz_=(-3:3);prz_=as.data.frame(prz_);prz=merge(prz,prz_)
    prz$day=prz$prazdn+prz$prz_;
    o=(prz$day<1);prz[o,'day']=prz[o,'day']+365
    prz=unique(subset(prz,select=c('day','nom_prazdn')))
    prz$prazdn=1;prz[(prz$day %in% prazdn),'prazdn']=2
    
    prz$nom_prazdn=prz$nom_prazdn*2+prz$prazdn-2
    dats=merge(dats,prz,by='day',all=TRUE)
    dats[(is.na(dats$prazdn)),c('prazdn','nom_prazdn')]=0
    
    ####### день недели и рабочие дни
    dats$weekday=as.numeric(dats$dat)-7*round(as.numeric(dats$dat)/7)+4 # день недели 1-7
    dats$rab_day=1*(dats$weekday<6)
    
    ####### номер недели в году и в месяце
    dats$week=week(dats$dat)
    dats$mweek=round(dats$mday/7) #вдруг есть стабильная динамика по месяцу
    dats$year=NULL;dats$mday=NULL #убрать ненужное
    
    dann=merge(dann,dats,by='dat')
  }
  
  
  {#смена названий столбцов
    if (nrow(mas)>0){
      for (i in 1:nrow(mas)){
        nm=as.character(mas[i,'nm']);nm_=as.character(mas[i,'nm_'])
        dann[,nm_]=dann[,nm]}}
    if (nrow(xz)>0){
      for (i in 1:nrow(xz)){
        nm=as.character(xz[i,'nm']);nm_=as.character(xz[i,'nm_'])
        dann[,nm_]=dann[,nm]}}
    if (nrow(xs)>0){
      for (i in 1:nrow(xs)){
        nm=as.character(xs[i,'nm']);nm_=as.character(xs[i,'nm_'])
        dann[,nm_]=dann[,nm]}}
    if (nrow(y_ogr)>0){
      for (i in 1:nrow(y_ogr)){  #   i=1
        nm=as.character(y_ogr[i,'nm']);nm_=as.character(y_ogr[i,'nm_'])
        dann[,nm_]=dann[,nm]}}
  }
  
  {#слить данные о полях в одну базу
    nm=c('yy','row','dat','mas_nom');pol=as.data.frame(nm);pol$nom=0;pol$nm_=pol$nm;pol$tip=pol$nm;
    pol$nm=c(neir$vhod$y,'row',neir$vhod$dat,NA)
    pol$name=c('y',NA,NA,NA);
    mas$name=paste('m',mas$nom,sep='');xz$name=NA;xs$name=NA;xs$ish=NULL;ost$name=NA
    
    pol=rbind(pol,mas,xz,xs,y_ogr,ost);
    # признак поля из даты
    pol$dat=NA;pol[(pol$nm_=='dat'),'dat']=1
    ddats=dats;ddats$dat=NULL;ddats=names(ddats) #все поля сформированные из даты
    # ddats=c('weekday','day','week','month','rab_day','prazdn','nom_prazdn','mweek')
    pol[(pol$nm %in% ddats),'dat']=1
    
    #поставить, кто вне запаздываний
    pol$zap_vne=NA;pol[(pol$nm %in% vne$nm)&(pol$tip %in% c('xz','xs')),'zap_vne']=1
    
    neir$vhodi=pol}
  
  
  #удаление всех лишних столбцов
  pol=c(as.character(pol$nm_),'ves')
  for (nm in names(dann)) {if (!(nm %in% pol)) {dann[,nm]=NULL}}
  
  
  {#пронумеровать массивы сквозной нумерацией
    vh=neir$vhodi;mas=vh[(vh$tip=='mas'),];mas$kol=NA
    dn_mas=dann;dn_mas$kol=1
    dn_mas=aggregate(x=subset(dn_mas,select=c('kol')),
                     by=subset(dn_mas,select=as.character(mas$nm_)), FUN="sum" )
    
    mass=unique(subset(mas,select=c('nm_','name')));mass$zn=NA;mass$nom=NA
    kol_mas=0;o=order(mas$nom);mas=mas[o,]
    
    
    
    for (nm in as.character(mas$nm_)){   ###  nm='mas7'
      dann[(is.na(dann[,nm])),nm]='-'  # добавка. спорно!!! ???
      zn=unique(subset(dn_mas,select=c(nm)));
      zn$zn=zn[,nm];
      o=order(zn$zn);zn=zn[o,]
      kol=nrow(zn);zn$nom=kol_mas+(1:kol);
      mas[(mas$nm_==nm),'kol']=kol
      name=mas[(mas$nm_==nm),'name']
      #сразу ввести в данные
      dann[,name]=NULL;
      dann=merge(dann,zn,by=nm)
      dann[,name]=dann$nom;dann$nom=NULL;dann$zn=NULL;
      # и так же в краткие суммы
      dn_mas[,name]=NULL;dn_mas=merge(dn_mas,zn,by=nm)
      dn_mas[,name]=dn_mas$nom;dn_mas$nom=NULL;dn_mas$zn=NULL;
      zn[,nm]=NULL;kol_mas=kol_mas+kol
      zz=mass[(mass$nm_==nm),];zz$zn=NULL;zz$nom=NULL
      zn=merge(zn,zz);mass=rbind(mass,zn)}
  }
  
  #запись в нейросеть списка значений массивов   
  mass=mass[(!is.na(mass$zn)),];neir$mass=mass 
  vh=vh[(vh$tip!='mas'),];if (is.null(vh$kol)){vh$kol=NA}
  vh=rbind(vh,mas);neir$vhodi=vh
  neir$vhod$kol_mass=nrow(mass)
  
  
  # добавить максимальные значения по числовым входам
  vh=neir$vhodi;xz=vh[(vh$tip %in% c('xz','yy','ogr')),];
  for (nm in xz$nm_){zn=max(abs(dann[(!is.na(dann[,nm])),nm]))
  vh[(vh$nm_==nm),'max']=zn }
  
  #на выход и ограничитель - одинаковые максимумы
  zn=max(vh[(vh$tip %in% c('yy','ogr')),'max'])
  vh[(vh$tip %in% c('yy','ogr')),'max']=zn
  neir$vhodi=vh;neir$vhod$max_y=zn
  
  #сокращение объёма памяти
  for (nm in c(mas$name,'row','mas_nom')){  dann[,nm]=as.integer(dann[,nm])  }
  for (nm in mas$nm_){dann[,nm]=NULL}
  dann=as.data.frame(as.data.table(dann)) 
  
  
  # расчёт исходных данных средних ошибок (прогноз=0)
  proc=neir$vhod$proc
  dn=dann
  dn=dn[((!is.na(dn$yy))&(!is.na(dn$row))),c('row','yy')]
  o=order(dn$yy);dn=dn[o,]
  kol=nrow(dn)
  for(pr in proc$proc){if (!is.na(pr)){
    k=round(kol*pr/100)
    zn=dn[k,'yy']
    proc[((proc$proc==pr)&(!is.na(proc$proc))),'zn']=zn
  }}
  zn=(sum(dn$yy**2)/kol)**0.5;proc[(proc$name=='err_sr'),'zn']=zn
  neir$vhod$proc=proc
  
  
  # постановка первой записи, которая вне промежутка собственно прогноза (макс_дата+before)
  dat=as.Date(neir$vhod$max_dat)
  before=neir$vhod$before
  dn=dann[(!is.na(dann$row)),]
  row=max(dn[((as.Date(dn$dat))<=dat+before),'row'])+1
  neir$vhod$row_before=row
  
  neir$dann=dann
  return(neir)
  pzd_=1
  rm(nm,nm_,pol,i,mas,xz,y_ogr,dann,dn_mas,mass,vh,xs,zz,kol,kol_mas,min_date,nname)
  rm(pzd,plus_dats,z,vne,name,o,paramm,param_sum,zn,neir,dats,prz,pzd_,plus_time)
  rm(prz_,vis,dat,ddats,dt1,dt2,k,max_dat,prazdn,max_n,dn,proc,pr,ost,before,row)
}
#Пример запуска
#neir=neuron$neir.dann_first_old(neir);dann=neir$dann;neir$dann=NULL;









#по описанию нейросети прочитать данные, оставить лишь всё нужное
neuron$neir.dann_first <- function(neir) {
  
  {# постановка используемых ошибок-квантилей
    proc=neir$vhod$proc
    pr=as.data.frame(proc);pr$name=paste('err_',pr$proc,sep='')
    pr[(is.na(pr$proc)),'name']='err_sr'
    pr[(pr$proc==100)&(!is.na(pr$proc)),'name']='err_max'
    neir$vhod$proc=pr
    neir$vhod$errs=as.character(pr$name)
    rm(pr,proc)}
  
  #номера поездов
  name=neir$vhod$name;nname=name;
  if (name=='sapsan') {name='doss'}
  pzd=myPackage$trs.dann_load(name,'pzd')
  if (nname=='sapsan') {
    pzd=pzd[((pzd$Stn %in% c('2004001','2006004'))&(pzd$Sto %in% c('2004001','2006004'))),]
  }
  if (!is.null(pzd)){neir$vhod$pzd=pzd}
  
  
  {#результат работы прочитать, из сохранённого, немного подработать
    dann=myPackage$trs.dann_load(name,'ext') #данные по поездам
    dann_sts=myPackage$trs.dann_load(paste(name,'sts',sep='_'),'ext')  # данные по маршрутам
    
    
    dann$Napr=2*(dann$pzd>0)-1;dann$pzd=abs(dann$pzd)
    if (!is.null(pzd)){dann=dann[(dann$pzd %in% pzd$pzd),]}
    #убрать заведомые неточности
    if ('min_mest' %in% names(dann)){
      dann[(dann$Seats<dann$min_mest)&(!is.na(dann$min_mest)),c('min_mest','kp0','pkm0')]=NA}
    if (!('dann' %in% names(dann))){dann$dann=1}
  }
  
  #исправление 0 на '-'
  for (nm in c('Skor','First','Skor2','First2')){  # nm='Skor2'
    if (nm %in% names(dann)){dann[(dann[,nm]==0),nm]='-'}
  }
  
  # список добавляемых функций от даты
  plus_dats=c('weekday','day','week','mweek','month','rab_day','prazdn','nom_prazdn')
  plus_time=c('hh_otp','hh_otp4')
  
  
  {# добавить поля часы отправления hh_otp и hh_otp4 - и сумму по каждым 4 часам, если более 1 оптравления
    if ('Tm_otp' %in% names(dann)){    
      dann$hh_otp=as.character(round((dann$Tm_otp-29.5)/60))
      dann$hh_otp4=as.character(round((dann$Tm_otp-119.5)/240))
      dann[(dann$Train=='-'),c('hh_otp','hh_otp4')]='-'
      dann[(is.na(dann$Tm_otp)),c('hh_otp','hh_otp4')]='-'
    }}
  
  {# БЛОК ОБРАБОТКИ СПИСКА ПОЛЕЙ
    { #сверить список возможных входов, и переназвать
      vhod=neir$vhod
      nm=c(vhod$mas,plus_dats,plus_time);nm=unique(as.data.frame(nm));nm$tip='mas'
      poll=nm
      nm=c(vhod$xz,NA);nm=unique(as.data.frame(nm));nm$tip='xz';poll=rbind(poll,nm)
      nm=c(vhod$ostavl,NA);nm=unique(as.data.frame(nm));nm$tip='ost';poll=rbind(poll,nm)
      nm=c(vhod$xs,NA);nm=unique(as.data.frame(nm));nm$tip='xs';poll=rbind(poll,nm)
      nm=c(vhod$y,NA);nm=unique(as.data.frame(nm));nm$tip='yy';poll=rbind(poll,nm)
      nm=c(vhod$y_ogr,NA);nm=unique(as.data.frame(nm));nm$tip='ogr';poll=rbind(poll,nm)
      
      nm=c(vhod$y_upr,NA);nm=unique(as.data.frame(nm));nm$tip='y_upr';poll=rbind(poll,nm)
      nm=c(vhod$upr_y,NA);nm=unique(as.data.frame(nm));nm$tip='upr_y';poll=rbind(poll,nm)
      poll=poll[(!is.na(poll$nm)),]
      #poll=rbind(mas,ost,xz,xs,y_ogr,y)
      rm(nm,vhod)
    }
    
    {# первичная обработка
      poll$nm=as.character((poll$nm));poll$nm_vh=poll$nm
      o=((poll$tip=='xs')&(substr(poll$nm,1,2)=='s_'))
      poll[o,'nm']=substr(poll[o,'nm'],3,max(nchar(poll$nm)))
      poll$pref='';poll[(poll$tip=='xs'),'pref']='s_'
      poll$nc=nchar(poll$nm)
      poll$suf=''
      o=(substr(poll$nm,poll$nc,poll$nc)=='*');poll[o,'suf']='*'
      poll[o,'nm']=substr(poll[o,'nm'],1,poll[o,'nc']-1)
      o=(substr(poll$nm,poll$nc,poll$nc)=='%');poll[o,'suf']='%'
      poll[o,'nm']=substr(poll[o,'nm'],1,poll[o,'nc']-1)
      poll$nc=nchar(poll$nm)
    }
    
    #из перечня полей взять существующие
    nms=c(names(dann),plus_dats) # к списку имеющихся добавить суммируемые и возм. плюс-даты
    if (!is.null(dann_sts)) {nms=c(names(dann),names(dann_sts),plus_dats)}
    
    nms=as.data.frame(nms);nms=unique(nms)
    nms$tab=2;nms[(nms$nms %in% names(dann)),'tab']=1
    nms[(nms$nms %in% plus_dats),'tab']=0
    
    {#полная склейка
      p=merge(poll,nms);p$nms=as.character(p$nms)
      p=p[(p$nm==substr(p$nms,1,p$nc)),]
      p$suf_=substr(p$nms,p$nc+1,nchar(p$nms))   # p$nc+10
      p=p[((p$suf_=='')|(p$suf %in% c('*','%'))),]
      o=(p$suf=='*');p[o,'bef']=as.numeric(p[o,'suf_'])
      p=p[((!is.na(p$bef))|(p$suf %in% c('','%'))),]
      p$suf_=NULL;p$nc=NULL
      p$nm=p$nms;p$nms=NULL
      p$nm_ish=p$nm
      p$nm=paste(p$pref,p$nm,sep='')
      poll=p;rm(p)
      poll[(is.na(poll$bef))&(poll$tip %in% c('xz','xs')),'bef']=0
    }
    
    # проверить массивы на наличие разных полей
    for (nm in poll[(poll$tip=='mas'),'nm'] ){ if (!(nm %in% plus_dats)){ 
      #    nm='hh_otp4'  nm='Train'  nm='pzd'
      dn=subset(dann,select=nm)
      dn$kol=1;
      dn=aggregate(x=subset(dn,select='kol'),by=subset(dn,select=nm), FUN="sum" )
      dn=dn[(dn$kol>10),]
      dn=dn[(dn[,nm]!='-'),] #убрать все итоговые суммирования 
      if (nrow(dn)==1) {poll=poll[((poll$tip!='mas')|(poll$nm!=nm)),]}
    }}
    
    {# нет поезда - убрать и seats_km во входах (но не ограничении)
      if (nrow(poll[(poll$nm_ish=='pzd'),])==0) {
        o=((poll$tip %in% c('xz','xs'))&(poll$nm_ish=='Seats_km'))
        poll=poll[(!o),]
      }}
    
    {#упорядочить по алфавиту
      o=order(poll$tip,poll$nm);poll=poll[o,];poll$nom=(1:nrow(poll))
      pp=aggregate(x=subset(poll,select='nom'),by=subset(poll,select='tip'), FUN="min" )
      pp$n=pp$nom;pp$nom=NULL;poll=merge(poll,pp,by='tip')
      poll$nom=poll$nom-poll$n+1;poll$n=NULL }
    
    
    if (FALSE)  {#вернуть - что именно получилось взять ???????
      neir$vhod$mas=as.character(mas$nm);
      neir$vhod$xz=as.character(xz$nm);
      neir$vhod$xs=as.character(xs$nm);
      neir$vhod$y_ogr=as.character(y_ogr$nm);
      neir$vhod$ostavl=as.character(ost$nm);}
    
    #статистики количеств полей - если конечно нужны   
    neir$vhod$kol_mas=nrow(poll[(poll$tip=='mas'),]);
    neir$vhod$kol_xz=nrow(poll[(poll$tip=='xz'),]);
    neir$vhod$kol_xs=nrow(poll[(poll$tip=='xs'),]);
    neir$vhod$kol_ogr=nrow(poll[(poll$tip=='ogr'),]);
    neir$vhod$kol_ost=nrow(poll[(poll$tip=='ost'),]);
    neir$vhod$kol_y=nrow(poll[(poll$tip=='yy'),]);
    neir$vhod$kol_upr=nrow(poll[(poll$tip=='upr_y'),]);
    
    #добавления переназваний полей
    poll$nm_=paste(poll$tip,poll$nom,sep='')
    o=(poll$tip=='mas')
    poll[o,'name']=paste('m',poll[o,'nom'],sep='')
    poll[(poll$tip=='yy'),'nm_']='yy'  # если конечно есть УУ
  }
  
  #добавка суммирований по четырёхчасовым промежуткам (убрать час - оставить 4часа) - где они есть
  #кого суммировать
  param_sum=unique(as.character(poll[((poll$tip %in% c('xz','xs'))&(poll$tab==1)),'nm_ish']))
  mas=poll[(poll$tip=='mas'),]
  # по кому суммировать
  paramm=c(neir$vhod$dat,as.character(mas[(!(mas$nm %in% plus_dats)),'nm']))
  
  if ('hh_otp4' %in% mas$nm) {  ##  ('hh_otp4' %in% neir$vhod$mas)
    dann_=dann[(dann$hh_otp4!='-'),]
    dann_[,c('Train','hh_otp','First','Skor')]='-';dann_$ed=1
    dann_=aggregate(x=subset(dann_,select=c(param_sum,'ed')),by=subset(dann_,select=paramm), FUN="sum" )
    
    if ('pzd' %in% paramm){ #берём только, если склейка чаще 70% возможных дат по поезду
      dt1=unique(dann_[,c('pzd','Date')])
      dt2=unique(dann_[(dann_$ed>1),c('pzd','Date')])
      dt1$k1=1;dt2$k2=1;
      dt1=aggregate(x=subset(dt1,select='k1'),by=subset(dt1,select='pzd'), FUN="sum" )
      dt2=aggregate(x=subset(dt2,select='k2'),by=subset(dt2,select='pzd'), FUN="sum" )
      dt1=merge(dt1,dt2,by='pzd')
      pzd_=unique(dt1[(dt1$k2>0.7*dt1$k1),'pzd']);
      dann_=dann_[(dann_$pzd %in% pzd_),]
      rm(dt1,dt2,pzd_)
    }
    
    if (nrow(dann_)>0){
      dann_$ed=NULL;
      dann=myPackage$sliv(dann,dann_) }
    rm(dann_)
  }
  
  if (('Napr' %in% mas$nm)){ #добавка суммированное направление - (если это не выборка по станции отпр-назн)
    dann_=dann
    for (nm in paramm){ 
      if (!(nm %in% c("Date","pzd","Type"))){
        if (nm %in% names(dann_)) {dann_=dann_[(dann_[,nm]!='-'),];dann_[,nm]='-'}}}
    
    #суммирование
    dann_$ed=1
    dann_=aggregate(x=subset(dann_,select=c(param_sum,'ed')),by=subset(dann_,select=paramm), FUN="sum" )
    # оставить поезда, где хоть раз в итог пошло более 1 строки
    if ('pzd' %in% paramm){
      pzd_=unique(dann_[(dann_$ed>1),'pzd']);
      dann_=dann_[(dann_$pzd %in% pzd_),]}
    
    if (nrow(dann_)>0){dann_$ed=NULL;dann_$dann=0
    for (nm in c('Time','Tm_otp','Rasst','cena0')){
      if (nm %in% names(dann)){dann_[,nm]=0}}
    dann=myPackage$sliv(dann,dann_)
    }
    rm(dann_)
  }
  
  
  
  
  {#объединить данные по поездам, и по направлениям
    nms='Date'
    for (nm in c("First","First2","pzd","Skor","Skor2","Train","Type","Napr")) {
      if (nm %in% names(dann)){ nms=c(nms,nm)
      if (!(nm %in% names(dann_sts))) {dann_sts[,nm]='-'}}}
    
    dann_sts[(dann_sts$Napr=='0'),'Napr']='-'
    #dann_=myPackage$sliv(dann,dann_sts)
    dann=merge(dann,dann_sts,by=nms,all='TRUE')
  }
  
  xs=poll[(poll$tip=='xs'),]
  if (nrow(xs)>0) { # добавление суммируемых переменных
    dann$row=(1:nrow(dann))
    paramm=as.character(mas[(!(mas$nm  %in% c(plus_dats,'First','Skor'))),'nm'])
    res=subset(dann,select=c("Date","row",paramm,as.character(xs$nm_ish)))
    for (nm in c('hh_otp','hh_otp4')){
      if (nm %in% paramm){
        res[(res$Train!='-'),nm]='-' # если есть поезд - на время начхать для суммирования
      }}
    rr=unique(subset(res,select=paramm));rr$nom=(1:nrow(rr))
    res=merge(res,rr,by=paramm)
    for (nm in paramm){res[,nm]=NULL}#удалить поля разбиений - для скорости
    
    o=order(res$nom,res$Date);res=res[o,];
    max_n=nrow(res);res$ed=1;res$rw=(1:max_n)
    
    
    for (nm in xs$nm_ish){#процедура накопит суммирования каждого поля   nm='kp0'
      #print(paste(nm,Sys.time(),sep='  '))
      nm_=as.character(xs[(xs$nm_ish==nm),'nm'])
      res[,nm_]=res[,nm];res[(is.na(res[,nm_])),nm_]=0
      dns <- sapply(FUN = function(part) {
        znn=numeric(max_n);znn[part$rw]=part[,nm_]
        for (i in 1:(max_n-1)) {znn[i+1]=znn[i+1]+znn[i]}
        l <- c(znn) }, X=split(res,res$ed))
      res[,nm_]=dns;res[,nm]=NULL
      rm(dns)
    }
    res$rw=NULL;res$ed=NULL;
    res$Date=NULL;res$mas_nom=res$nom;res$nom=NULL
    dann=merge(dann,res,by='row')
    dann$row=NULL;
    rm(res,rr)
  }
  
  
  dat=as.character(neir$vhod$dat)
  if (neir$vhod$kol_y>0){ # постановка апроксимируемой переменной 
    dann$yy=dann[,neir$vhod$y];
    # максимальная дата данных
    max_dat=as.character(max(as.Date(dann[(!is.na(dann$yy)),dat])))
    min_dat=as.character(min(as.Date(dann[(!is.na(dann$yy)),dat])))
  } 
  
  if (neir$vhod$kol_upr>0){ # постановка апроксимируемой переменной 
    upr_y=poll[(poll$tip=='upr_y'),'nm']
    upr_v=poll[(poll$tip=='y_upr'),'nm']
    
    dann[,'upr0']=(dann[,upr_y]-0.1*dann[,upr_v])
    dann[,'upr1']=(dann[,upr_y]+0.1*dann[,upr_v])
    o=((dann[,upr_y]>dann[,upr_v])&(!is.na(dann[,upr_y]))&(!is.na(dann[,upr_y])));
    dann[o,'upr1']=2*dann[o,upr_v];dann[o,'upr0']=dann[o,upr_y] 
    o=(is.na(dann[,upr_y]));dann[o,'upr1']=dann[o,upr_v]
    dann$upr0=round(pmax(dann$upr0,0))
    dann$upr1=round(dann$upr1)
    max_dat=as.character(max(as.Date(dann[(!is.na(dann$upr0)),dat])))
    min_dat=as.character(min(as.Date(dann[(!is.na(dann$upr0)),dat])))
  }
  # максимальная дата данных
  dat=as.character(neir$vhod$dat)
  #max_dat=as.character(max(as.Date(dann[(!is.na(dann$yy)),dat])))
  neir$vhod$max_dat=max_dat
  
  
  #установка веса. 0=не идёт в прогноз, но возможно на вход
  dann$ves=1;dann[(dann$Train=='-'),'ves']=0 # сумма по всем поездам - не прогнозируем
  dann[(dann$dann==0)&(!is.na(dann$dann)),'ves']=0 # что по построению вне прогноза
  dann$dann=NULL
  
  
  {#номер строки - только с даты первых реальных данных
    o=(as.Date(dann$Date)<min_dat)|(dann$ves==0)
    dann0=dann[o,];dann=dann[(!o),]
    if (neir$vhod$kol_y>0){
      o=order(is.na(dann$yy),dann$Date,dann$Train,dann$Type)}
    if (neir$vhod$kol_upr>0){
      o=order(is.na(dann$upr0),dann$Date,dann$Train,dann$Type)}
    dann=dann[o,];dann$row=(1:nrow(dann));dann0$row=NA
    dann=rbind(dann,dann0);rm(dann0)
    dann$dat=as.Date(dann[,neir$vhod$dat])
  }
  
  { # Блок рассчёта всех параметров по дате - месяцы, дни недели, даты, праздники...
    dt1=min(dann$dat);dt2=max(dann$dat);
    dat=as.Date((dt1-370):(dt2+750))
    dats=as.data.frame(dat)
    dats$day=yday(dats$dat);dats$year=year(dats$dat)
    
    #поиск високосных лет
    vis=aggregate(x=subset(dats,select=c('day')),by=subset(dats,select=c('year')), FUN="max" )
    vis$vis=0;vis[(vis$day==366),'vis']=1;vis$day=NULL
    
    dats=merge(dats,vis,by='year')
    o=((dats$vis==1)&(dats$day>60));dats[o,'day']=dats[o,'day']-1 #исправление високосного года
    dats$vis=NULL
    dats$month=month(dats$dat);dats$mday=mday(dats$dat)
    
    #праздники - ввести и расширить до (+-3)дня
    prazdn=c(1,2,3,4,5,6,7,54,67,121,129,163,308)
    prz=as.data.frame(prazdn);k=1;prz[1,'nom_prazdn']=k
    for (i in (2:nrow(prz))){
      if (prz[i,'prazdn']>prz[i-1,'prazdn']+1){k=k+1}
      prz[i,'nom_prazdn']=k}
    
    prz_=(-3:3);prz_=as.data.frame(prz_);prz=merge(prz,prz_)
    prz$day=prz$prazdn+prz$prz_;
    o=(prz$day<1);prz[o,'day']=prz[o,'day']+365
    prz=unique(subset(prz,select=c('day','nom_prazdn')))
    prz$prazdn=1;prz[(prz$day %in% prazdn),'prazdn']=2
    
    prz$nom_prazdn=prz$nom_prazdn*2+prz$prazdn-2
    dats=merge(dats,prz,by='day',all=TRUE)
    dats[(is.na(dats$prazdn)),c('prazdn','nom_prazdn')]=0
    
    ####### день недели и рабочие дни
    dats$weekday=as.numeric(dats$dat)-7*round(as.numeric(dats$dat)/7)+4 # день недели 1-7
    dats$rab_day=1*(dats$weekday<6)
    
    ####### номер недели в году и в месяце
    dats$week=week(dats$dat)
    dats$mweek=round(dats$mday/7) #вдруг есть стабильная динамика по месяцу
    dats$year=NULL;dats$mday=NULL #убрать ненужное
    
    dann=merge(dann,dats,by='dat')
    rm(prz,prz_,prazdn,dt1,dt2,dat,vis)
  }
  
  {#смена названий столбцов - кроме ограничений, вернул ost 
    for (nm_ in as.character(poll[(!(poll$tip %in% c('y_upr','upr_y'))),'nm_'])){
      nm=as.character(poll[(poll$nm_==nm_),'nm'])
      dann[,nm_]=dann[,nm]} }
  
  {#слить данные о полях в одну базу
    nm=c('row','dat','mas_nom');pol=as.data.frame(nm);pol$nom=0;pol$nm_=pol$nm;pol$tip=pol$nm;
    pol$nm=c('row',neir$vhod$dat,'mas_nom')
    pol$nm_ish=c(NA,neir$vhod$dat,NA)
    pol[,c('pref','suf')]=''
    
    pol=myPackage$sliv(pol,poll);
    # признак поля из даты
    pol$dat=NA;ddats=names(dats) #все поля сформированные из даты
    pol[(pol$nm %in% ddats),'dat']=1
    pol[(pol$tip=='dat'),'dat']=1
    
    #признак поля времени от поезда
    pol[(pol$nm %in% 'hh_otp4'),'tim']=1
    pol[(pol$nm %in% 'hh_otp'),'tim']=2
    pol[(pol$nm %in% c('First','Skor')),'tim']=3
    pol[(pol$nm %in% 'Train'),'tim']=0
    
    #поставить, кто вне запаздываний
    pol$zap_vne=NA;
    vne=as.character(neir$vhod$vne_zapazd)
    pol[(pol$nm %in% vne)&(pol$tip %in% c('xz','xs')),'zap_vne']=1
    neir$vhod$vne_zapazd=unique(as.character(pol[(!is.na(pol$zap_vne)),'nm']))
    neir$vhodi=pol
    rm(poll,ddats,vne)}
  
  
  #удаление всех лишних столбцов
  poll='ves'
  if (neir$vhod$kol_upr>0){poll=c(poll,'upr0','upr1')
  pol=pol[(!(pol$tip %in% c('y_upr','upr_y'))),]
  }
  poll=unique(c(as.character(pol$nm_),poll))
  for (nm in names(dann)) {if (!(nm %in% poll)) {dann[,nm]=NULL}}
  rm(nm,pol,poll)
  
  
  {#пронумеровать массивы сквозной нумерацией
    vh=neir$vhodi;mas=vh[(vh$tip=='mas'),];mas$kol=NA
    mass=unique(subset(mas,select=c('nm_','name')));
    mass$zn=NA;mass$nom=NA;mass$is=NA
    kol_mas=0;o=order(mas$nom);mas=mas[o,]
    
    for (nm in as.character(mas$nm_)){   ###  nm='mas1'
      dann[(is.na(dann[,nm])),nm]='-'  # добавка. спорно!!! ???
      dann$is=0;dann[(!is.na(dann$row)),'is']=1 #признак идёт в настройку - для массивов
      zn=unique(subset(dann,select=c(nm,'is'))); 
      zn=aggregate(x=subset(zn,select=c('is')),by=subset(zn,select=c(nm)), FUN="max" )
      zn$zn=zn[,nm];
      o=order(zn$zn);zn=zn[o,]
      kol=nrow(zn);zn$nom=kol_mas+(1:kol);
      mas[(mas$nm_==nm),'kol']=kol
      mas[(mas$nm_==nm),'kol_is']=sum(zn$is)
      name=mas[(mas$nm_==nm),'name']
      #сразу ввести в данные
      dann[,name]=NULL;dann$is=NULL
      dann=merge(dann,zn,by=nm)
      dann[,name]=dann$nom;dann$nom=NULL;dann$zn=NULL;dann$is=NULL
      zn[,nm]=NULL;kol_mas=kol_mas+kol
      zn$nm_=nm;zn$name=name;mass=rbind(mass,zn)
    }
    
    #запись в нейросеть списка значений массивов   
    mass=mass[(!is.na(mass$zn)),];neir$mass=mass 
    vh=vh[(vh$tip!='mas'),];if (!('kol' %in% names(vh))){vh$kol=NA}
    vh$kol_is=NA
    vh=rbind(vh,mas);
    neir$vhodi=vh
    neir$vhod$kol_mass=kol_mas
    rm(mass,kol_mas,kol,zn,nm,name)
  }
  
  # добавить максимальные значения по числовым входам
  vh=neir$vhodi;xz=vh[(vh$tip %in% c('xz','yy','ogr')),];
  for (nm in xz$nm_){zn=max(abs(dann[(!is.na(dann[,nm])),nm]))
  vh[(vh$nm_==nm),'max']=zn }
  
  
  #на выход и ограничитель - одинаковые максимумы
  if (neir$vhod$kol_y>0) {
    zn=max(vh[(vh$tip %in% c('yy','ogr')),'max'])
    vh[(vh$tip %in% c('yy','ogr')),'max']=zn
    neir$vhod$max_y=zn}
  if (neir$vhod$kol_upr>0) {
    vh[(vh$tip %in% c('y_upr','upr_y')),'max']=1}
  neir$vhodi=vh;
  
  #сокращение объёма памяти
  for (nm in c(mas$name,'row','mas_nom')){  dann[,nm]=as.integer(dann[,nm])  }
  for (nm in mas$nm_){dann[,nm]=NULL}
  dann=as.data.frame(as.data.table(dann)) 
  
  
  {# расчёт исходных данных средних ошибок (прогноз=0)
    proc=neir$vhod$proc;proc$zn=1
    if (neir$vhod$kol_y>0) {
      dn=dann
      dn=dn[((!is.na(dn$yy))&(!is.na(dn$row))),c('row','yy')]
      o=order(dn$yy);dn=dn[o,];kol=nrow(dn)
      for(pr in proc$proc){if (!is.na(pr)){
        k=round(kol*pr/100);zn=dn[k,'yy']
        proc[((proc$proc==pr)&(!is.na(proc$proc))),'zn']=zn
      }}
      zn=(sum(dn$yy**2)/kol)**0.5;proc[(proc$name=='err_sr'),'zn']=zn
    }
    neir$vhod$proc=proc
  }
  
  {# постановка первой записи, которая вне промежутка собственно прогноза (макс_дата+before)
    dat=as.Date(neir$vhod$max_dat)
    before=neir$vhod$before
    dn=dann[(!is.na(dann$row)),]
    row=max(dn[((as.Date(dn$dat))<=dat+before),'row'])+1
    neir$vhod$row_before=row
  }
  
  # если управление - поставить его на вход
  if (neir$vhod$kol_upr>0){
    vh=neir$vhodi;v=vh[(vh$tip=='row'),]
    v[,c('tip','nm_')]='yy';v$nm=NA;v$bef=0;vh=rbind(vh,v);
    v[,c('tip','nm_','nm')]='upr';vh=rbind(vh,v);
    neir$vhodi=vh;
  }
  
  {#выявить положительность значений
    dd=dann[(!is.na(dann$yy)),]
    neir$vhod$plus_dann=0
    if (min(dd$yy)>=0){neir$vhod$plus_dann=1}
  }
  
  neir$dann=dann
  return(neir)
  
  dann=1;dats=1;dn=1;mas=1;nms=1;pp=1;proc=1;pzd=1;vh=1;xs=1;xz=1;
  before=1;dat=1;i=1;k=1;kol=1;max_dat=1;max_n=1;dann_sts=1;
  min_date=1;nm=1;nm_=1;nname=1;o=1;param_sum=1;paramm=1;plus_dats=1;
  plus_time=1;pr=1;pzd_=1;row=1;zn=1;min_dat=1;upr_v=1;upr_y=1;v=1;poll=1;dd=1;
  
  rm(dann,dats,dn,mas,nms,pp,proc,pzd,vh,xs,xz,before,dat,i,k,kol,max_dat,max_n)
  rm(min_date,nm,nm_,nname,o,param_sum,paramm,plus_dats,plus_time,pr,pzd_,row,zn,dd)
  rm(min_dat,upr_v,upr_y,v,poll,neir,dann_sts)
  
}
#Пример запуска
#neir=neuron$neir.dann_first(neir);dann=neir$dann;neir$dann=NULL;












# собственно настройка одной нейросети по итерациям
neuron$neir.nastr_nset <- function (neur) {  
  if (!is.null(neur$dn)) {
    
    str=neur$str;vib=neur$stat;mas=neur$pmas;dnn=neur$dn #что понадобится
    vihod=(str$vhod==-1)
    # добавление в массивы нужного поля
    mass=neur$npols;mass=mass[(mass$tip=='mas'),]
    mass$name=mass$zn;mass=mass[,c('name','out')]
    if (is.null(mas$name)){
      ms=neuron$mass;ms$zn=ms$nom;ms=ms[,c('zn','name')]
      mas=merge(mas,ms,by='zn');rm(ms)}
    mas=merge(mas,mass,by='name',all=TRUE)
    mas$name=NULL
    
    #part=vib$part
    if (is.null(vib$error)){vib$error=NA}
    vib$error_pred=vib$error;
    mas_ish=mas[,c('zn','isp')]
    mas=mas[(mas$zn>0),];mas$isp=NULL  # c('zn','fun')
    vib$time_beg=as.character(Sys.time())
    dn=dnn[(dnn$dn==0),] #взять настроечные данные
    #dn_test=dnn[(dnn$dn==1),]
    if (is.null(vib$kol_step)){vib$kol_step=0}
    if (is.na(vib$kol_step)){vib$kol_step=0}
    
    max_time=max(vib$max_time,1) #хоть 1 секунду дать каждой настройке!
    is_rez=FALSE #нужны ли на выходе данные
    o=order(mas$zn);mas=mas[o,]   #mas=mas[mas$zn,] #это упорядочивание строк
    #mas=as.data.table(mas) 
    str$z=as.integer(str$vhod<str$vih);  #str[(is.na(str$vhod)),'z']=1
    step=0;tm_beg=as.double(Sys.time())
    
    
    
    # ДАЛЕЕ РАСЧЁТ В ЦИКЛЕ
    b_err=neuron$neir.err(str,vib,mas,dn,is_rez);
    
    #запомнили лучшие на данный момент параметры
    vib$error=b_err$err;#b_vib=vib;
    b_str=str;b_mas=mas;
    
    #направление изменения сгенерировать
    dmas=(runif(nrow(mas))-0.5);dstr=(runif(nrow(str))-0.5)
    
    end_proc=0;rad=vib$radius;vib$radius=NULL
    if (is.null(rad)){rad=0.1}
    if (is.na(rad)){rad=0.1}
    
    # print(step)
    
    kol_podnastr=0;iz_time=0  # за минуту даётся максимум 3 попытки, их считаем. Исх=0
    while((kol_podnastr<10)&(iz_time==0)){
      
      #пошагово случайное изменение параметров - обычная настройка
      while(end_proc==0){
        # убрать b_vib - просто не нужно, используемые параметры неизменны
        step=step+1;
        mas$fun=mas$fun+rad*dmas;
        
        str$zn=str$zn+str$z*rad*dstr
        
        #vihod=(str$vhod==-1)
        str[vihod,'zn']=min(max(str[vihod,'zn'],0.05),0.5)
        
        
        err=neuron$neir.err(str,vib,mas,dn,is_rez)
        
        if (err$err<b_err$err) {# хорошо - направление не изменяем, увеличиваем шаг
          b_err=err;rad=rad*1.5;
          #vib$error=b_err$err;
          #b_vib=vib;
          b_str=str;b_mas=mas;
        }else{
          rad=rad*0.9;#vib=b_vib;
          str=b_str;mas=b_mas;
          #направление изменения сгенерировать заново
          dmas=(runif(nrow(mas))-0.5);dstr=(runif(nrow(str))-0.5)}
        
        tm=as.double(Sys.time())
        if (step>10000){end_proc=1}
        if ((tm-tm_beg)>max_time){end_proc=1;iz_time=1}
        if (rad<0.00001){end_proc=1}
        
        
        #быстрая поднастройка по массиву
        if ((step==10*round(step/10))&(nrow(mass)>0)) {
          mass$r=runif(nrow(mass))
          o=order(mass$r);mass=mass[o,]
          vih_name=as.character(mass[1,'out'])
          
          #vib=b_vib;
          str=b_str;mas=b_mas;
          err=neuron$neir.err(str,vib,mas,dn,is_rez,vih_name)
          dn_1=err$dn_
          mas$fun=b_mas$fun+(runif(nrow(mas))-0.5)*rad*(mas$out==vih_name)*100
          err=neuron$neir.err(str,vib,mas,dn,is_rez,vih_name)
          dn_2=err$dn_;dn_2$err_=dn_2$err;
          dn_2$err=NULL
          dn_1=merge(dn_1,dn_2,by=vih_name)
          dn_1$de=dn_1$err-dn_1$err_
          dn_1=dn_1[(dn_1$de>0),]
          
          if (nrow(dn_1)>0){ #если есть улучшающее значение
            zn=dn_1[,vih_name]
            mas=mas[(mas$zn %in% zn),]
            b_mas=b_mas[(!(b_mas$zn %in% zn)),]
            b_mas=rbind(b_mas,mas)
            o=order(b_mas$zn);b_mas=b_mas[o,]
            b_err$err=b_err$err-sum(dn_1$de)
          }
          mas=b_mas
        }  #конец быстрой настройки массива
        
      }
      if (iz_time==0){kol_podnastr=kol_podnastr+1;rad=rad*10;end_proc=0}
    }
    
    #vib=b_vib;
    str=b_str;mas=b_mas;str$z=NULL;
    vib$radius=rad;vib$kol_podnastr=kol_podnastr
    vib$kol_step=vib$kol_step+step;vib$ttime=(tm-tm_beg);
    if (is.null(vib$all_time)){vib$all_time=0}
    vib$all_time=vib$all_time+vib$ttime
    vib$time=as.character(Sys.time())
    vib$err=b_err$err; 
    
    
    dn=dnn[(dnn$dn>0),] #тестовые и прогнозные данные
    err=neuron$neir.err(str,vib,mas,dn,is_rez=TRUE);
    
    neur$rezult=err$dann;err$dann=NULL;err$kol=NULL;
    for (nm in names(err)){vib[,nm]=err[nm]}
    
    vib$act=2
    # если ещё не стабилизирован - результаты не понадобятся  0.99 = neuron$vhod$proc_err
    if ((vib$error<vib$error_pred*neuron$vhod$proc_err)|(is.na(vib$error_pred))) {
      neur$rezult=NULL} else{vib$act=4}
    #на выход
    neur$str=str;neur$stat=vib;
    mas=merge(mas,mas_ish,by='zn');mas$out=NULL
    neur$pmas=mas 
    
    rm(b_mas,b_str,dn,mas,vib,b_err,dmas,dstr,end_proc,err,is_rez,max_time)
    rm(rad,step,tm,tm_beg,vihod,o,dnn,str,mas_ish,dn_1,dn_2,mass,iz_time)
    rm(kol_podnastr,nm,vih_name,zn)
  }
  return(neur)
  rm(neur)
}
# пример запуска   neur=neuron$neir.nastr_nset(neur)









# расчёт статистики по одной нейросети по новому - по каждому элем массивов
neuron$neir.neur_stat <- function (neur) {
  
  # исходник
  rez=neur$rezult
  if (!is.null(rez)){
    vh=neuron$vhodi;mas=vh[(vh$tip=='mas'),]
    dn=neuron$dannie;dn=dn[(!is.na(dn$row)),]
    dn=dn[,c('row',as.character(mas$name))]
    dn=dn[,c('row',as.character(mas$name))]
    rz=rez[,c('row','err')]
    if (neuron$vhod$kol_upr>0){
      dn0=dn;dn0$row=-dn0$row;dn=rbind(dn,dn0)
      o=order(dn$row);dn=dn[o,];rm(dn0,o)
    }
    rz=merge(rz,dn,by='row')
    
    # ошибки по каждому элементу массива
    rz$mm=0;rzz=rz[,c('mm','err')]
    for (nm in mas$name){
      rz$mm=rz[,nm];rr=rz[,c('mm','err')]
      rzz=rbind(rzz,rr)}
    rzz=rzz[(!is.na(rzz$err)),]
    
    # первичная статистика
    rzz$err2=rzz$err**2
    rzz$kol=1
    rr=aggregate(x=subset(rzz,select=c('err2','kol')),by=subset(rzz,select=mm), FUN="sum" )
    rzz$kol=NULL;rzz$err2=NULL
    
    # вычисление просто средних
    rr$err_sr=(rr$err2/(rr$kol-(rr$kol**0.5)))**0.5
    rr[(rr$kol<100),'err_sr']=NA;rr$err2=NULL
    
    pr=neuron$vhod$proc  # какие квантили нужны
    pr=pr[(!is.na(pr$proc)),]
    
    if (nrow(pr)>0){    # расчёт квантилей всех скопом
      
      o=order(rzz$mm,rzz$err);rzz=rzz[o,]
      rzz$n=(1:nrow(rzz))
      rr_=aggregate(x=subset(rzz,select=c('n')),by=subset(rzz,select=mm), FUN="min" )
      rr_$nn=rr_$n;rr_$n=NULL
      rzz=merge(rzz,rr_,by='mm')
      rzz$n=1+rzz$n-rzz$nn;rzz$nn=NULL
      
      proc=merge(rr,pr)
      proc=proc[(!is.na(proc$err_sr)),]
      proc$skol=round(proc$kol**0.5)
      proc$n=round((proc$kol-proc$skol)*proc$proc/100)+proc$skol
      proc=proc[,c('mm','name','n')]
      
      proc=merge(rzz,proc,by=c('mm','n'))
      proc$n=NULL
      
      for (nm in pr$name){ # приписывание каждой конкретной квантили
        pp=proc[(proc$name==nm),]
        pp[,nm]=pp$err
        pp=pp[,c('mm',nm)]
        rr=merge(rr,pp,by='mm',all=TRUE)
      }
    }
    
    #  теперь статистики вклинить в результаты
    
    rr_=rr[(rr$mm==0),];rr_$mm=NULL;rr_$kol=NULL
    rz=merge(rz,rr_)
    
    errs=neuron$vhod$errs # список названий всех ошибок
    rr_=rr[((rr$mm>0)&(!is.na(rr$err_sr))),]
    for (nm in errs){ # временное переименовывание всех ошибок
      nm_=paste(nm,'_',sep='')
      rr_[,nm_]=rr_[,nm];rr_[,nm]=NULL
    }
    rr_$kol=NULL
    
    # непосредственно склейка со всеми статистиками, и вычисление максимальной ошибки каждого типа
    for (nm in mas$name){
      rz$mm=rz[,nm];rz[,nm]=NULL
      rz=merge(rz,rr_,by='mm',all=TRUE)
      rz=rz[(!is.na(rz$row)),]
      for (en in errs){ # перебор всех статистик
        en_=paste(en,'_',sep='')
        o=((rz[,en]<rz[,en_])&(!is.na(rz[,en_])))
        rz[o,en]=rz[o,en_]
        rz[,en_]=NULL
      }}
    rz$mm=NULL;rz$err=NULL;rz=unique(rz)
    rez=merge(rez,rz,by='row')
    
    # запись обратно
    neur$rezult=rez
    # было ещё - запись в pmas значений статистик ошибок - убрал
    
    rm(dn,mas,pp,pr,proc,rr,rr_,rz,rzz,vh,en,en_,nm,nm_,o,errs)
  }
  return(neur)
  
  rm(neur,rez)
}
# пример запуска   neur=neuron$neir.neur_stat(neur)






#случайный выбор по пропорции из базы, по полю kol
neuron$neir.sluchaini_vibor <- function (dn) {  
  #изменить пропорциональность - возвести в квадрат
  #dn_mas$kol=dn_mas$kol**2
  #накопительные суммы - для пропорционального выбора
  sumk=0;dn$i=(1:nrow(dn));dn$kol0=0;dn$kol1=0;
  for (i in dn$i){dn[i,'kol0']=sumk;sumk=sumk+dn[i,'kol'];dn[i,'kol1']=sumk}
  rr=runif(1)*sumk;
  dn=dn[(dn$kol1>=rr)&(dn$kol0<=rr),]
  dn=dn[1,] #если вдруг на границе, и 2 записи сразу
  for (nm in c('i','kol0','kol1','kol')){dn[,nm]=NULL}
  return(dn)
  rm(dn,i,nm,rr,sumk)
}








# дополнение данных = плюс входы, которых ещё не было
neuron$neir.dann_vhod_plus <- function(dann,pol) {
  
  vh=neuron$vhodi;mas=vh[(vh$tip=='mas'),]
  #собственно добавление поля,входы = dann,vhod; плюс neir - от него нужны лишь neir$vhodi
  #dann$kol=NULL;ogr=vhod$ogr;vibor=vhod$vibor;vh=vhod$vhodi
  
  for (npol in pol$n_pol){  #  npol=1
    # прочесть описание. что брать
    ogr=pol[(pol$n_pol==npol),];out=as.character(ogr$out)
    get=as.character(ogr$get);tip=as.character(vh[(vh$nm_==get),'tip'])
    
    if (get=='upr'){
      #dann[,out]=as.numeric(dann[,get])
    }
    if (get!='upr'){
      #взять нужное поле, и когда оно есть в принципе
      dn=neuron$dannie;dn=dn[(!is.na(dn[,get])),]
      dn[,out]=as.numeric(dn[,get])
      
      #убрать уже лишние поля - хоть чуть быстрее будет!!!
      dn=subset(dn,select=c(as.character(mas$name),'dat','mas_nom',out)) 
      
      #взять это поле только когда это нужно (поезд, тип, класс, день недели...)
      for (nm in mas$name){if (!is.na(ogr[1,nm])){
        zn=as.character(ogr[1,nm]);if (zn>0){dn=dn[(dn[,nm]==zn),]}}}
      
      
      if (tip=='xs'){ # если поле=накопительная сумма, то поставить сумму за нужное число дней
        dn_=subset(dn,select=c('dat','mas_nom',out))
        dn_$out=dn_[,out];dn_[,out]=NULL
        zapazd=ogr$zapazd;dn_$dat=as.character(as.Date(dn_$dat)+zapazd)
        dn=merge(dn,dn_,by=c('mas_nom','dat'))
        dn[,out]=dn[,out]-dn$out
        dn$out=NULL;rm(dn_,zapazd)
      }
      #ввести запазд по времени
      dn$dat=as.character(as.Date(dn$dat)+ogr$before)
      
      #по кому склеивать - через ограничение, а не количества - правильнее!
      mas_=c();for (nm in mas$name){ 
        if (ogr[,nm]==0) {mas_=c(mas_,nm)}}
      dn=subset(dn, select = c('dat',mas_,out));#убрать всё лишнее
      dann[,out]=NULL;#если новое поле уже было - убрать
      dann=merge(dann,dn,by=c('dat',mas_),all=TRUE) #склейка данных с новым полем 
      dann=dann[(!is.na(dann$row)),]
    }
    # убрать поле, если менее 1000 строк
    #kol=nrow(dann[((!is.na(dann[,out]))&(!is.na(dann[,'yy']))),])
    #if (kol<1000){dann[,out]=NULL}
  }
  
  return(dann)
  dann=1;pol=1;mas=1;vh=1;mas_=1;dn=1;ogr=1;get=1;nm=1;npol=1;out=1;tip=1;zn=1;
  rm(dann,pol,mas,vh,mas_,dn,ogr,get,nm,npol,out,tip,zn)
}
#пример запуска   dann=neuron$neir.dann_vhod_plus(dann,pol)







#инициализация данных - если ещё не было
neuron$neir.init_dann <- function (neir) {
  
  vh=neir$vhodi;mas=vh[(vh$tip=='mas'),]
  dann=neir$dann
  #если данных ещё нет - создать
  if (is.null(dann)){
    yy='yy';if (neir$vhod$kol_upr>0){yy=c('upr1','upr0')}
    ogr=vh[(vh$tip %in% c('ogr','row','dat')),]
    ogr=as.character(ogr[,'nm_'])
    dann=neuron$dannie
    dann=dann[(!is.na(dann$row)),]
    
    pp=c(ogr,yy,as.character(mas$name))    
    dann=subset(dann,select=pp)  # ошибка
    #минимальная учитываемая ошибка = ошибка безразличия 
    if (neir$vhod$kol_upr==0) { # ошибка безразличия - только реальным данным
      if (neir$vhod$kol_ogr>0){
        dann$min_err=pmax(neir$vhod$min_err,round(dann$ogr1/100)) 
      }else {
        dann$min_err=pmax(neir$vhod$min_err,round(dann$yy/100)) } 
      dann[(is.na(dann$min_err)),'min_err']=neir$vhod$min_err;
      dann$min_err=as.integer(dann$min_err) }
    
    #раздвоение данных - ушло отсюда в самый конец
    neir$dann=dann
  }
  return(neir)
  dann=1;mas=1;vh=1;ogr=1;neir=1;yy=1;pp=1
  rm(dann,mas,vh,ogr,neir,yy,pp)
}
#пример запуска   neir=neuron$neir.init_dann(neir)






#при необходимости рассчитать новые входные поля, с удалением пока ненужных
neuron$neir.dobavl_vhodi <- function (neir,nsets) {
  
  # избавиться от случайной ошибки
  #if ((!is.null(neir$dann))&(neir$vhod$kol_upr>0)) {
  #  if (!('z_1' %in% names(neir$dann))) {neir$dann=NULL} }
  
  #если данных ещё нет - создать
  if (is.null(neir$dann)){ neir=neuron$neir.init_dann(neir)  }
  
  vh=neir$vhodi;mas=vh[(vh$tip=='mas'),]
  dann=neir$dann
  
  {# дополнение данных нужными полями - все сразу
    filtr=neir$all_filtr;
    
    # поиск кого не надо убивать, а остальных убрать
    stat=neir$all_stat;stat_=stat[(stat$act==1),]
    fil=filtr[((!(filtr$nset %in% stat$nset))|(filtr$nset %in% stat_$nset)),]
    npoll=unique(fil$n_poll);
    pols=neir$opis_pols;
    zn_all=unique(subset(pols,select='zn'));zn_all$k=1 # все возможные
    pols=pols[(pols$n_poll %in% npoll),]
    zn=unique(subset(pols,select='zn')) # все кто понадобятся
    zn_all=zn_all[(!(zn_all$zn %in% zn$zn)),] # все кто не понадобятся
    zn_all=zn_all[(zn_all$zn %in% names(dann)),] # всех кого удалить
    for (nm in zn_all$zn){dann[,nm]=NULL}
    
    # а теперь кого надо добавить
    fil=filtr[(filtr$nset %in% nsets),]
    pols=neir$opis_pols;pols=pols[(pols$n_poll %in% fil$n_poll),]
    pol=neir$opis_pol;
    pol=unique(pol[(pol$out %in% pols$zn),])
    #dann=neir$dann
    pol=pol[(!(pol$out %in% names(dann))),]
    
    if (nrow(pol)>0){ #запуск процедуры добавления полей
      dann=neuron$neir.dann_vhod_plus(dann,pol)
    }
    neir$dann=dann
    
  }
  return(neir)
  pols=1;pol=1;fil=1;vh=1;mas=1;dann=1;filtr=1;nsets=1;neir=1;stat=1;
  stat_=1;zn=1;zn_all=1;nm=1;
  rm(pols,pol,fil,vh,mas,dann,filtr,nsets,neir,stat,stat_,zn,zn_all,nm)
}
# пример    neir=neuron$neir.dobavl_vhodi(neir,nsets) 










#подготовить данные для всех ядер процессора
neuron$neir.get_neurs <- function (neir,nsets) {
  
  neurs=NULL;#koll=0
  neurs <- lapply(FUN = function(nset) {  #    for (nset in nsets){  # } # nset=45196    
    
    if (!is.na(nset)){
      umens=round(runif(1))  ;#  umens=0    
      
      vh=neir$vhodi;mas=vh[(vh$tip=='mas'),] # предварительно - массивы
      
      {# статистика нейросети - первичная информация
        stat=neir$all_stat
        stat=stat[(stat$nset==nset),]
        if (nrow(stat)==0){
          stat=as.data.frame(nset);
          stat$kol_x=0;stat$kol_m=0;stat$kol_mas=0;stat$kol_str=0
          stat$max_y=0;stat$min_y=0;stat$act='0'}
        if (is.null(stat$part)) {stat$part=NA}
        if (is.na(stat$part)) {
          stat$part=(runif(1)>0.5)*1;if (nset %in% c(0,1)){stat$part=nset} }
      }
      
      { #выбрать нужный фильтр данных
        fil=neir$all_filtr
        fil=fil[(fil$nset==nset),]
        npoll=fil[1,'n_poll']
        pols=neir$opis_pols;pols=pols[(pols$n_poll==npoll),]  }
      
      bad=0
      {# исправление ошибки 
        if (nrow(pols[(is.na(pols$nom_pol)),])>0) {bad=1}
      }
      {#первичная выборка данных
        dn=neir$dann;nms=names(dn)
        for (nm in pols$zn){ 
          if (nm %in% nms){
            dn=dn[(!is.na(dn[,nm])),]
            xx=as.character(pols[(pols$zn==nm),'out']);
            dn[,xx]=dn[,nm]}}
        
        upr=NULL
        if ((nrow(dn)>0)&(neir$vhod$kol_upr>0)){# разбивка данных по управлению
          dn0=dn[(!is.na(dn$upr0)),]
          dn$yy=1;dn$x1=dn$upr1;dn$upr=1;dn[(is.na(dn$upr0)),'yy']=NA
          if (nrow(dn0)>0){dn0$yy=0;dn0$x1=dn0$upr0;dn0$upr=0;dn=rbind(dn,dn0)}
          rm(dn0);dn$upr0=NULL;dn$upr1=NULL;upr='upr'
        }
        
        #фильтрация данных
        if (nrow(dn)>0){
          dn$vib=0;o=order(-fil$vib);fil=fil[o,];fil$k=(1:nrow(fil))
          for (k in fil$k){  #   k=2
            vib=fil[(fil$k==k),'vib'];dn_=dn;
            for (nm in mas$name){
              zn=fil[(fil$k==k),nm]
              if (zn>0){dn_=dn_[(dn_[,nm]==zn),]}}
            dn[(dn$row %in% dn_$row),'vib']=vib
          }
          dn=dn[(dn$vib==1),];
          dn$vib=NULL
          #  взять лишь нужные поля
          vhodi=as.character(vh[(vh$tip %in% c('row','dat','yy','ogr')),'nm_'])
          if (neir$vhod$kol_upr==0){vhodi=c(vhodi,'min_err')}
          pp=c(as.character(mas$name),vhodi,as.character(pols$out),upr)
          dn=subset(dn,select=pp)
        }
        if (nrow(dn)==0){bad=1}
      }
      
      neur=list() # создание собственно нейросети, которую (под)настраивать
      
      if (bad==0)  {#выявление входных параметров нейросетей всех - макс и мин
        param=neir$all_param
        param=param[(param$nset==nset),]
        # параметры данной нейросети - если не было - создать
        if (nrow(param)==0){
          vhodi=as.character(vh[(vh$tip %in% c('yy','ogr')),'nm_'])
          name=c(as.character(pols$out),vhodi)
          param=as.data.frame(name)  #  nm='yy'
          for (nm in name) {  #  nm='yy'
            dn_=dn[(!is.na(dn[,nm])),]
            max=0;min=0;if (nrow(dn_)>0){
              max=max(dn_[,nm]);min=min(dn_[,nm]);}
            o=(param$name==nm);param[o,'max']=max;param[o,'min']=min
          }
          name=vhodi
          o=(param$name %in% name)
          max=max(param[o,'max']);param[o,'max']=max
          min=min(param[o,'min']);min=min(min,0);param[o,'min']=min
          param$nset=nset;
        }
        param$max=as.numeric(param$max);param$min=as.numeric(param$min) # формат исправить
        neur$param=param # на всякий случай - потом сохранить в NEIR
        
        kol_ogr=neir$vhod$kol_ogr
        # афинное преобразование параметров входных данных 
        name=c(as.character(pols$out),'yy')
        for (nm in name) {
          o=(param$name==nm);max=param[o,'max'];min=param[o,'min'];
          if (max==min){bad==1}else{
            if (nm=='yy'){
              dn$y=(dn$yy-min)/(max-min)
              if (kol_ogr>0){dn$y_ogr=(dn$ogr1-min)/(max-min)}
              if (neir$vhod$kol_upr==0) {dn$mer=dn$min_err/(max-min)}
            } else {dn[,nm]=(dn[,nm]-min)/(max-min)}
          }}
      }
      
      { # список всех значений массивов
        pmas=neir$all_mass
        pmas=pmas[(pmas$nset==nset),]
        # если пуст список массивов по данной нейросети
        pmas_=neir$mass;pmas_$nset=nset;
        pmas_$zn=pmas_$nom;pmas_=pmas_[,c('nset','zn')]
        if (nrow(pmas)>0){
          pmas=merge(pmas,pmas_,by=c('nset','zn'),all=TRUE)
          pmas[(is.na(pmas$isp)),'isp']=0
        }else{
          pmas=pmas_;pmas$fun=1
        }
        #pmas[(!(pmas$name %in% npols$zn)),'fun']=NA #убрать варианты массива, по которым единственное значение
      }
      
      if (bad==0) { # посчитать количестна наблюдений на каждый элемент массива
        dn$part=abs(dn$row-round(dn$row/2)*2)
        dn[(is.na(dn$yy)),'part']=2
        part=stat$part
        dn_s=NULL
        dn$kol=1;dn$kol_part=(dn$part==part)*1
        for (nm in mas$name) {
          dn$zn=dn[,nm]
          dn_=aggregate(x=subset(dn,select=c('kol','kol_part')),by=subset(dn,select='zn'), FUN="sum" )
          if (is.null(dn_s)){dn_s=dn_}else{dn_s=rbind(dn_s,dn_)}
        }
        pmas$kol=NULL
        pmas=merge(pmas,dn_s,by='zn',all=TRUE)
        if (is.null(pmas$isp)){pmas$isp=1}
        o=((pmas$isp==2)&(!is.na(pmas$isp)));
        if (nrow(pmas[o,])>0){pmas[o,'isp']=1} # заново проверить - вдруг теперь данных хватит
        
        ### pmas$isp= 1=есть данн, в прогноз, 2=мало данных, настраивать но не прогноз
        ### 0=данных нет вообще, 3=данные есть, но не пошли на вход
        
        pmas[(is.na(pmas$kol_part)|(pmas$kol_part==0)),'isp']=0
        
        #добавка против ошибки, может и зря
        pmas=pmas[(!is.na(pmas$nset)),]
        
        o=((pmas$kol_part<10)&(!is.na(pmas$kol_part))&(pmas$isp==1));  # хотел ограничить минимум 10 наблюд
        if (nrow(pmas[o,])>0) {pmas[o,'isp']=2}   ##  pm=pmas[o,]
        
        #заплатка - появились новые значения массива
        o=((pmas$kol_part>=10)&(!is.na(pmas$kol_part))&(pmas$isp==0));
        if (nrow(pmas[o,])>0) {pmas[o,'isp']=1;pmas[o,'fun']=0}
        
        #заплатка - появились новые значения массива, но данных мало
        o=((pmas$kol_part>0)&(!is.na(pmas$kol_part))&(pmas$isp==0));
        if (nrow(pmas[o,])>0) {pmas[o,'isp']=2;pmas[o,'fun']=0}
        
        #подчистка возможно плохих - кому случайно поставили не ту ауктивность
        pp=neir$all_pols;pp=pp[(pp$nset==nset),]
        mass=neir$mass;mass=mass[(!(mass$name %in% pp$zn)),]
        
        if ((nrow(pp)>0)&(nrow(mass)>0)){
          o=(pmas$zn %in% mass$nom)
          pmas[o,'isp']=3;pmas[o,'fun']=NA}
        
        #вычистить лишние поля
        pmas$nm_=NULL;pmas$nom=NULL;
        pmas$kol=NULL;pmas$kol_part=NULL
        
        dn$dn=dn$part;# данные: 0=настройка, 1=тест,2=прогноз
        if (part==1){
          o=(dn$part<2);dn[o,'dn']=1-dn[o,'part']}
        dn$kol=NULL;dn$kol_part=NULL;dn$zn=NULL;dn$part=NULL
        
        if(nrow(dn[(dn$dn==0),])<=100) {bad=1} #настроечных минимум 100
        if(nrow(dn[(dn$dn==1),])<=100) {bad=1} #тестовых минимум 100
        if(nrow(dn[(dn$dn==2),])==0) {bad=1}
      }
      
      if (bad==0)  { 
        # список входов - числовые и массивы
        npols=neir$all_pols
        npols=npols[(npols$nset==nset),]
        mass=neir$mass;
        ms=mass[,c('nom','name')];ms$zn=ms$nom;ms$nom=NULL
        pmas$name=NULL;pmas=merge(pmas,ms,by='zn',all=TRUE)
        #если не было списков по даной нейросети
        if (nrow(npols)==0){
          # поставить - нет входов - значит без уменьшающих массивов всегда
          if (nrow(pols)==0){umens=0}
          
          npols=pols[,c('zn','out')];
          if (nrow(npols)==0){ zn=NA;npols=as.data.frame(zn);npols$out=NA }
          npols$tip='x';
          npols$nset=nset
          # поставить - нет входов - значит без уменьшающих массивов всегда
          if (nrow(pols)==0){umens=0}
          
          #число вариантов на вход массива
          mm=pmas;mm$kol=0;mm$kolm=0;
          mm[(mm$isp %in% c(1,2)),'kol']=1
          mm[(mm$isp %in% c(2,3)),'kolm']=1
          
          #mm=pmas[(pmas$isp %in% c(1,2)),];
          #mm$kol=1;
          mm=aggregate(x=subset(mm,select=c('kol','kolm')),by=subset(mm,select=c('name')), FUN="sum" )
          mm=mm[(mm$kol>1),] # если всего 1 вариант значения массива - убрать
          
          if (umens==0) {mm=mm[(mm$kolm==0),]} # удалить входы, уменьшающие настройку
          mm$kolm=NULL
          
          mm$r=runif(nrow(mm));o=order(mm$r);mm=mm[o,]
          kol=round( min(nrow(dn[(dn$dn==0),]),nrow(dn[(dn$dn==1),]))/10)-3-nrow(npols); # сколько оставляем вариантов на массивы
          #вычеркнуть, что точно не пройдёт по числу параметров и наблюдений - для одноэтажной нейросети
          npols$kol=0;npols$vhod=npols$out
          if (nrow(mm)>0){ # если есть хоть 1 элемент массива с разными значениями
            mm$tip='mas';mm$nset=nset
            for (nm in mm$name){
              k=mm[(mm$name==nm),'kol']
              if (kol>k+1){kol=kol-k-1}else{
                mm=mm[(mm$name!=nm),]}}
          }
          if (nrow(mm)>0){
            mm$r=NULL;mm$zn=mm$name;mm$name=NULL
            o=order(mm$zn);mm=mm[o,];
            mm$out=paste('mm',1:nrow(mm),sep='');
            mm$vhod=paste('x',(1:nrow(mm))+nrow(npols),sep='')
            npols=rbind(npols,mm)
          }
          { #кого не осталось в настройке - значение массива убить
            pmas[(!(pmas$name %in% npols$zn)& (pmas$isp>0)),'isp']=3
            pmas[(pmas$isp %in% c(0,3)),'fun']=NA
          }
          npols=npols[(!is.na(npols$zn)),]
          
        }
        neur$npols=npols  # на всякий случай
        
        { # вычеркнуть лишние данные из тестовой части, если есть. Рабочую не изменять
          pmas_b=pmas[(pmas$isp %in% c(0,2)),]
          pmas_b=pmas_b[(pmas_b$name %in% npols$zn),]
          for(nm in unique(pmas_b$name)){
            zn=pmas_b[(pmas_b$name==nm),'zn']
            dn=dn[((dn$dn==0)|(!(dn[,nm] %in% zn))),]
          }} 
        neur$pmas=pmas
        
        
        #список всех структур нейросетей
        str=neir$all_str
        str=str[(str$nset==nset),]
        if (nrow(str)==0){#если пуста структура нейросети
          kol=nrow(npols)
          vhod=(0:(kol+2))
          str=as.data.frame(vhod);str$nset=nset
          str$rebro=str$vhod+1;str$vih=kol+1;str$zn=0
          str[(str$vhod==str$vih),'zn']=round(runif(1)*(neuron$max_tip_neir+1)-0.5)
          if (neir$vhod$plus_dann==1){str[(str$vhod==str$vih),'zn']=pmax(1,str[(str$vhod==str$vih),'zn'])}
          o=(str$vhod>str$vih);str[o,'vhod']=-1;str[o,'zn']=0.1
          if (kol_ogr==0){str=str[!o,]} #если нет ограничителя
          if (neir$vhod$kol_upr>0) { # управление - фиксируем тип нейрона на выходе
            str[(str$vhod==max(str$vih)),'zn']=4
          }
          #all_str=rbind(all_str,str);neir$all_str=all_str
        }
        neur$str=str  
      }
      
      {# итоговая статистика нейросети
        ##if (((stat$kol_x+stat$kol_m)==0)|(stat$act==0)) {  старый вариант
        if (stat$act==0) {
          
          if (bad==0){
            stat$act='1'
            stat$kol_x=nrow(npols[(npols$tip=='x'),])
            stat$kol_m=nrow(npols[(npols$tip=='mas'),])
            stat$kol_mas=nrow(pmas[(!is.na(pmas$fun)),])
            stat$kol_str=nrow(str[(str$vhod!=str$vih),])
            o=(param$name=='yy');stat$max_y=param[o,'max'];stat$min_y=param[o,'min'] 
            stat$umens=umens
          }
          stat$kol_param=stat$kol_mas+stat$kol_str   #+stat$kol_x+stat$kol_m - это ошибочная добавка, уже учтены в kol_str
          stat$min_kol=stat$kol_param*10
        }
        stat$kol_dann=nrow(dn)
        stat$dann_nastr=nrow(dn[(dn$dn==0),])
        stat$dann_test=nrow(dn[(dn$dn==1),])
        stat$dann_progn=nrow(dn[(dn$dn==2),])
        stat$max_time=neuron$vhod$max_time
        #all_stat=myPackage$sliv(all_stat,stat);neir$all_stat=all_stat
      }
      neur$stat=stat
      
      if (bad==0) {# последняя подготовка данных
        #dn$kol=1-(is.na(dn$y))
        for (nm in npols[(npols$tip=='mas'),'zn']) {
          nm_=as.character(npols[(npols$zn==nm),'out']);dn[,nm_]=dn[,nm]}
        for (nm in mas$name){dn[,nm]=NULL}
        o=order(pmas$zn);pmas=pmas[o,]
        neur$dn=dn;}
      
      # если мало данных, или ничего не прогнозируем - обнулить
      if ((neur$stat$dann_nastr<neur$stat$min_kol)|
          (neur$stat$dann_test<neur$stat$min_kol)|
          (neur$stat$dann_progn==0)) {
        neur$param=NULL;neur$npols=NULL;neur$pmas=NULL;neur$str=NULL;neur$dn=NULL;
        neur$stat$act='0'
      }
      
    }# конец проверки на nset!=NA
    
    return (neur)}, X = (nsets))
  
  return(neurs)
  
  rm(neurs,nsets,neir)
}
#  пример запуска  neurs=neuron$neir.get_neurs(neir,nsets)









# график качества итогов, и результаты статистические
neuron$neir.rez_err <- function (neir,plot=0) {
  # plot=0=не рисовать, =1=рисовать лучшие, =2=рисовать среднее от хороших
  # график качества итогов
  err=NULL
  rez=neir$all_rezult
  # rez=rez[((rez$good>0)&(!is.na(rez$yy))),]
  rez=rez[(rez$good>0),]
  
  #добавка, что ещё не прогнозировано
  dn=neir$dann
  yy='yy'
  if (neir$vhod$kol_upr>0){yy=c('upr0','upr1')}
  
  dn=dn[,c('row',yy,'dat')];
  #до какой строки идёт прогноз не более чем на before
  #dat=max(as.Date(dn[(!is.na(dn$yy)),'dat']))
  dat=as.Date(neir$vhod$max_dat)
  before=neir$vhod$before
  row=neir$vhod$row_before
  if (is.null(row)) {row=min(dn[(as.Date(dn$dat)>dat+before),'row'])}
  
  row_bef=min(dn[(as.Date(dn$dat)>dat-2*before),'row'])
  
  if (plot=='dat'){ # график средних значений прогнозов и отклонений по дате
    rez1=rez[(rez$best==1)&(!is.na(rez$zn)),];
    rez1$z1=rez1$zn;#rez1=rez1[,c('row','z1','best','err_sr')]
    rez1=aggregate(x=subset(rez1,select=c('best','z1','err_sr')),
                   by=subset(rez1,select=c('row')), FUN="sum" )
    rez1$z1=rez1$z1/rez1$best;rez1$err_sr=rez1$err_sr/rez1$best
    
    rez2=rez[(!is.na(rez$zn)),];rez2$z2=rez2$zn*rez2$good
    rez2=aggregate(x=subset(rez2,select=c('good','z2')),
                   by=subset(rez2,select=c('row')), FUN="sum" )
    rez2$z2=rez2$z2/rez2$good
    
    rz=merge(rez1,rez2,by='row')
    rz=merge(rz,dn,by='row')
    rz=rz[(!is.na(rz$yy)),];
    rz$e1=(rz$z1-rz$yy)**2;rz$e2=(rz$z2-rz$yy)**2;
    rz$err_sr=rz$err_sr**2
    rz$kol=1
    rz=aggregate(x=subset(rz,select=c('yy','z1','z2','e1','e2','kol','err_sr')),
                 by=subset(rz,select=c('dat')), FUN="sum" )
    
    rz$yy=rz$yy/rz$kol;rz$z1=rz$z1/rz$kol;rz$z2=rz$z2/rz$kol
    rz$e1=(rz$e1/rz$kol)**0.5;rz$e2=(rz$e2/rz$kol)**0.5
    rz$err_sr=(rz$err_sr/rz$kol)**0.5
    rz$dat=as.Date(as.character(rz$dat))
    
    rz$t=1;rr=rz;rr$y=rr$yy
    rz$t=2;rz$y=rz$z1;rr=rbind(rr,rz)
    rz$t=3;rz$y=rz$z2;rr=rbind(rr,rz)
    rz$t=4;rz$y=rz$e1;rr=rbind(rr,rz)
    rz$t=5;rz$y=rz$e2;rr=rbind(rr,rz)
    rz$t=6;rz$y=rz$err_sr;rr=rbind(rr,rz)
    rr$dat=as.Date(as.character(rr$dat))
    
    plot(y=rr$y,x=rr$dat,col=rr$t)
    rm(rez1,rez2,rz,rr)
  }
  
  # dn=dn[(!is.na(dn$yy)),c('row','yy')];
  dn$dat=NULL
  if (!is.null(rez)) { # dn - те, где нет лучших прогнозов!
    rez_=rez[(rez$best>0),];
    dn=dn[(!(dn$row %in% rez_$row)),]}
  
  if (neir$vhod$kol_upr>0){dn$yy=NA;dn$upr0=NULL;dn$upr1=NULL}
  
  # по умолчанию
  proc=neir$vhod$proc
  if (nrow(dn)>0){
    dn$zn=0;dn$err=dn$yy
    for (nm in proc$name){zn=proc[(proc$name==nm),'zn'];dn[,nm]=zn}
    dn$nset=-1;dn$best=1;dn$good=1
    
    if (!is.null(rez)){ rez=rbind(rez,dn)}else{rez=dn}
  }
  rez$prg=1*(is.na(rez$yy))+(rez$row>=row)
  
  # основная часть работы
  rez$kol=1;rez_=rez[(rez$best>0),]
  
  if (plot==1) {
    if (neir$vhod$kol_ogr>0){
      dno=neir$dann;dno=dno[,c('row','ogr1')]
      rez_=merge(rez_,dno,by='row');rez_$og=1+1*(rez_$zn>rez_$ogr1)
      rm(dno)
    } else{rez_$og=1 } 
    rr=rez_[(!is.na(rez_$yy)),]
    plot(rr$yy,rr$zn,col=rr$og)
  }# все лучшие итоги - график
  
  
  # для получения среднего по лучшим
  k=aggregate(x=subset(rez_,select=c('kol')),
              by=subset(rez_,select=c('row')), FUN="sum" )
  rez_$kol=NULL;rez_=merge(rez_,k,by='row')
  
  nsets=unique(rez$nset)
  
  # для подсчёта корреляции
  rez_$err1=(rez_$err)/rez_$kol
  rez_$err2=(rez_$err**2)/rez_$kol
  rez_$yy2=(rez_$yy**2)/rez_$kol
  rez_$yy1=(rez_$yy)/rez_$kol
  rez_$y_z=(rez_$zn*rez_$yy)/rez_$kol
  rez_$zn2=(rez_$zn**2)/rez_$kol
  rez_$zn1=(rez_$zn)/rez_$kol
  
  # подсчёт правильности исполнения квантилей в реальности
  rez_$err_sr__=rez_$err_sr
  rez_$err=rez_$err**2/rez_$kol;
  rez_$err_sr=(rez_$err_sr**2)/rez_$kol
  rez_$kol=1/rez_$kol
  
  {#чтобы понять точность в последние 2*before дней
    rz=rez_[((!is.na(rez_$yy))&(rez_$row>=row_bef)),]
    rz$prg=5;rez_=rbind(rez_,rz);rm(rz)}
  
  err=aggregate(x=subset(rez_,select=c('kol','err','err_sr','err1','err2','yy1','yy2','y_z','zn1','zn2')),
                by=subset(rez_,select=c('best','prg')), FUN="sum" ) 
  
  err$sum_err=err$err
  for(nm in c('err_sr','err')){err[,nm]=(err[,nm]/err$kol)**0.5}
  
  err_prog=err[(err$prg==1),'err_sr']
  err_prog2=err[(err$prg==2),'err_sr']
  err_posled=err[(err$prg==5),'err_sr']
  if (nrow(err[(err$prg==2),])==0) {err_prog2=NA}
  err$err_prog=err_prog;err$err_prog2=err_prog2;err$err_posled=err_posled
  
  # err=err[(err$prg==0),];err$prg=NULL ### почему-то 0 записей
  o=order(err$prg);err=err[o,]
  err=err[1,];err$prg=NULL ### изменил - беру первую строку
  
  #корреляция
  d_y=(err$yy2/err$kol)-((err$yy1/err$kol)**2)
  dy=d_y**0.5
  d_z=(err$zn2/err$kol)-((err$zn1/err$kol)**2)
  dz=d_z**0.5
  e_yz=(err$y_z/err$kol)-((err$yy1/err$kol)*(err$zn1/err$kol))
  err$c_yz=e_yz/(dy*dz) # коррелляция, ковариация
  err$d_er=err$err/dz #отношение ошибки к дисперсии
  for(nm in c('yy1','yy2','y_z','zn1','zn2')){err[,nm]=NULL}
  
  {# добавить средние значения по всем просто хорошим, а не только лучшим
    err$sum_err2=NA;err$err2=NA
    rez=rez[(rez$prg==0),]
    rez$zn_=rez$zn*rez$good
    
    if (nrow(rez)>0){
      rez=aggregate(x=subset(rez,select=c('good','zn_')),
                    by=subset(rez,select=c('row','yy')), FUN="sum" )
      rez$zn=rez$zn_/rez$good
      
      if (neir$vhod$kol_upr==0){
        dd=neir$dann;dd=dd[,c('min_err','row')]
        if (is.null(dd)){rez$min_err=NA}else{rez=merge(rez,dd,by='row')} 
        rez$err=(pmax(abs(rez$yy-rez$zn),rez$min_err))**2
      }else{rez$err=(rez$yy-rez$zn)**2}
      
      err$sum_err2=sum(rez$err)
      err$err2=(err$sum_err2/err$kol)**0.5
      if (plot==2) {plot(rez$yy,rez$zn) }# все лучшие итоги - график
    }}
  
  # окончание
  err$dat_time=as.character(Sys.time())
  err$nsets=nrow(as.data.frame(nsets))
  err$best=NULL
  ee=err$err;rr=1000
  if (ee>100){rr=100}
  if (ee>1000){rr=10}
  if (ee>10000){rr=1}
  print(paste( ### 'errors: sum=',round(err$sum_err),'/',round(err$sum_err2),
    ' sred(best/good/dokaz/posl)=',round(err$err*rr)/rr,'/',round(err$err2*rr)/rr,
    '/',round(err$err_sr*rr)/rr,'/',round(err$err_posled*rr)/rr,
    ' prg1/2=',round(err$err_prog*rr)/rr,
    '/',round(err$err_prog2*rr)/rr,
    '/ corr/d_er=(',round(err$c_yz*100000)/1000,'/',round(err$d_er*100000)/1000,')',
    sep=''))
  
  return(err)
  zn=1;rr=1;c_yz=1;d_er=1;d_y=1;d_z=1;dy=1;dz=1;e_yz=1;o=1;yy=1;err_posled=1;row_bef=1;
  rm(k,rez,nm,nsets,plot,dd,dn,proc,zn,err,neir,rez_,before,dat,err_prog,err_prog2,row,rr,ee)
  rm(c_yz,d_er,d_y,d_z,dy,dz,e_yz,o,yy,err_posled,row_bef)
}
# ПРИМЕР ЗАПУСКА  err=neuron$neir.rez_err(neir) 






# выдать итоговые прогнозы по полученной настройке
neuron$neir.prognoz <- function (neir,all=0,okrugl=TRUE) {
  # all=1 - результаты всех настроек на всё прошлое; =0 - прогноз только на будущее
  # okrugl - результаты округлять до 3 значащих знаков средней ошибки данной строки!
  # исходник
  rez=neir$all_rezult;rez=rez[(rez$good>0),];
  if (all==0){ # если не нужно сравнение с реальными данными
    rez=rez[(is.na(rez$yy)),];rez$err=NULL;rez$yy=NULL  }
  
  vh=neir$vhodi;
  
  { # значения массивов в прогнозных точках, и мин. ошибка безразличия
    mas=vh[(vh$tip %in% c('mas')),];mas=mas[(is.na(mas$dat)),]
    
    dd=neir$dann;dd=dd[(!is.na(dd$row)),];
    if (all==0){
      max_dat=max(as.Date(dd[(!is.na(dd$yy)),'dat']))
      dd=dd[(is.na(dd$yy)),]
      dd=dd[(as.Date(dd$dat)>as.Date(max_dat)),] # удаление старых - поезд был, а пассажиров НОЛЬ (или забыли отменить продажу)
      rm(max_dat)
    }
    dd=subset(dd,select=c('row','dat','min_err',as.character(mas$name)))
    
    mass=neir$mass;mass=mass[,c('zn','nom')]
    
    for (nm in mas$name){  #  nm='m2'
      nm_=as.character(mas[(mas$name==nm),'nm'])
      #dd[,nm_]=dd[,nm];dd[,nm]=NULL
      dd$nom=dd[,nm];dd[,nm]=NULL
      dd=merge(dd,mass,by='nom')
      dd[,nm_]=dd$zn;dd$zn=NULL;dd$nom=NULL
      if (nm_ %in% c('First','Napr','pzd','Skor')){
        dd[,nm_]=as.integer(as.character(dd[,nm_]))}
    }
  }
  
  { # прогнозные - 1 реальный, +среднее лучшее, + макс-мин прогнозы
    rez$zn_=rez$zn*rez$good
    rez_=aggregate(x=subset(rez,select=c('good','zn_')),
                   by=subset(rez,select=c('row')), FUN="sum" )
    rez_$zn_sred=rez_$zn_/rez_$good;rez_=rez_[,c('row','zn_sred')]
    
    rez_min=aggregate(x=subset(rez,select=c('zn')),
                      by=subset(rez,select=c('row')), FUN="min" )
    rez_max=aggregate(x=subset(rez,select=c('zn')),
                      by=subset(rez,select=c('row')), FUN="max" )
    rez_min$zn_min=rez_min$zn;rez_min$zn=NULL
    rez_max$zn_max=rez_max$zn;rez_max$zn=NULL
    
    rez=rez[(rez$best==1),];rez$best=NULL #взять ТОЛЬКО лучшие. и среднее
    
    rez=merge(rez,rez_,by='row');
    rez=merge(rez,rez_min,by='row');
    rez=merge(rez,rez_max,by='row');
    
    rez_=aggregate(x=subset(rez,select=c('nset')),
                   by=subset(rez,select=c('row')), FUN="max" )
    rez=merge(rez,rez_,by=c('row','nset'))
    rez$zn_=NULL;rez$good=NULL
    
    rm(rez_,rez_max,rez_min)
  }
  # к прогнозам + значения массивов
  rez=merge(rez,dd,by='row')
  
  {#добавить поезда, если есть
    pzd=neir$vhod$pzd
    if (!is.null(pzd)){
      pzd$Napr=pzd$napr;pzd=unique(pzd[,c('pzd','Napr','Sto','Stn')])
      rez=merge(rez,pzd,by=c('pzd','Napr'))
    }}
  
  { 
    dd=neuron$dannie;dd=dd[(!is.na(dd$row)),]
    # ограничивающий фактор = число мест
    ogr=as.character(vh[(vh$tip=='ogr'),'nm'])
    ogr=vh[((vh$nm %in% ogr)&(vh$tip=='xz')),]  
    ost_=vh[(vh$tip=='ost'),]
    ost_=ost_[(ost_$nm_ %in% names(dd)),]
    ost=as.character(ost_$nm) # и если надор - что оставить на выход
    ost2=as.character(ost_$nm_) # и если надор - что оставить на выход
    
    if (all==0){dd=dd[(is.na(dd$yy)),]}
    nm=as.character(ogr$nm_);nm_=as.character(ogr$nm)
    dd[,nm_]=dd[,nm];dd=dd[,c(nm_,ost2,'row')]
    if (nrow(ost_)>0){
      for (i in (1:nrow(ost_))){  
        dd[,as.character(ost_[i,'nm'])]=dd[,as.character(ost_[i,'nm_'])]
      }}
    dd=dd[,c(nm_,ost,'row')]
    rez=merge(rez,dd,by='row')  
  }
  
  {#поставить значения запаздываний прогнозов
    vh=neir$vhodi;vh=vh[(vh$tip %in% c('xs','xz')),];vh=vh[(is.na(vh$zap_vne)),]
    pol=neir$opis_pol;pol$bef=pol$bef+pol$before;
    pol=pol[(pol$get %in% vh$nm_),];pol=pol[,c('n_pol','bef')]  
    
    poll=neir$opis_pols;poll=poll[,c('n_poll','n_pol')]
    poll=merge(poll,pol,by='n_pol')
    poll=aggregate(x=subset(poll,select=c('bef')),by=subset(poll,select='n_poll'), FUN="min" )
    
    fil=neir$all_filtr;fil=fil[,c('nset','n_poll')]
    fil=merge(fil,poll,by='n_poll')
    fil=fil[,c('nset','bef')]
    
    rez=merge(rez,fil,by='nset',all=TRUE)
    rez=rez[(!is.na(rez$row)),]
    rm(vh,pol,poll,fil)
  }
  
  
  rez$nset=NULL
  
  # определение полноты по прогнозу. >0 - нехватка мест, <0 - избыток мест
  if ('Seats' %in% names(rez)){
    rez$poln=(rez$zn_max>rez$Seats)+(rez$zn_sred>rez$Seats)+(rez$zn>rez$Seats)+(rez$zn_min>rez$Seats)
    rez$poln=rez$poln-(rez$zn_max<rez$Seats/2)-(rez$zn_sred<rez$Seats/2)-(rez$zn<rez$Seats/2)-(rez$zn_min<rez$Seats/2)
  }
  
  for (nm in c('First','First2','Skor','Skor2','min_err')){rez[,nm]=NULL} # удалить лишнее
  for (nm in names(rez)){ #убрать поляс единственным значением
    if (nrow(unique(subset(rez,select=nm)))==1) {rez[,nm]=NULL}}
  
  
  if (okrugl){#округление при необходимости
    proc=neir$vhod$proc  
    rez$k=exp(round((log(rez$err_sr)/log(10))-0.499)*log(10))/100
    for(nm in c(proc$name,'zn','zn_sred','zn_min','zn_max')){
      rez[,nm]=round(rez[,nm]/rez$k)*rez$k}
    rez$k=NULL  }
  
  
  return(rez)
  
  rez_=1;errs=1;errs_=1;ost_=1;ost2=1;i=1;proc=1;okrugl=1;pzd=1;
  rm(dd,mas,mass,ogr,rez,rez_,vh,errs,nm,nm_,errs_,all,neir,ost,ost_,ost2,i,proc,okrugl,pzd)
}
# ПРИМЕР ЗАПУСКА  progn=neuron$neir.prognoz(neir) 






neuron$neir.prognozi_save <- function (neir) {
  #централизованная запись прогнозов 
  progn=neuron$neir.prognoz(neir)# Прогнозы
  
  max_dat=neuron$vhod$max_dat
  name=neuron$vhod$name
  before=neuron$vhod$before
  yy=neuron$vhod$y
  
  progn$max_dat=max_dat
  progn$name=name
  progn$before=before
  progn$yy=yy
  
  prognoz=myPackage$trs.dann_load('prognoz','') 
  pp=unique(progn[,c('name','max_dat','before','yy')])
  pp$iz=1
  
  for (nm in c('name','max_dat','before','yy')){
    pp[,nm]=as.character(pp[,nm])
    prognoz[,nm]=as.character(prognoz[,nm])
  }
  
  if (!is.null(prognoz)){
    #всё кроме повтора текущего прогноза
    prognoz=merge(prognoz,pp,by=c('name','max_dat','before','yy'),all=TRUE)
    prognoz=prognoz[(is.na(prognoz$iz)),]
    prognoz$iz=NULL}
  
  prognoz=myPackage$sliv(prognoz,progn)
  myPackage$trs.Data_save(prognoz,'prognoz') #запись на диск прогнозов
  rm(max_dat,name,before,yy,pp,progn,prognoz,neir)
}
#пример запуска neuron$neir.prognozi_save(neir)





#запись итогов в память из результатов поднастройки
neuron$neir.zapis_neurs<- function (neir,neurs) {
  
  zap_rez=0 #количество перезаписанных результатов
  
  nom_nastr=1;
  if (!is.null(neir$errors)){nom_nastr=nrow(neir$errors)+1}
  
  # взять всё старое
  all_stat=neir$all_stat;all_str=neir$all_str;all_param=neir$all_param;
  all_pols=neir$all_pols;all_mass=neir$all_mass;
  all_rezult=neir$all_rezult;all_itogi=neir$all_itogi;
  
  # очистить список поднастраиваемых прямо сейчас - они просто годны в поднастройку
  if (nrow(all_stat)>0){
    all_stat[(all_stat$act==2),'act']=1 }  # было act==9
  
  nom_neur=0
  # непосредственно запись итогов    neur=nnn
  for (neur in neurs){   #    for (neur in neurs){ print(names(neur))}   names(neur)
    nom_neur=nom_neur+1
    
    if (!is.null(neur)){
      stat=neur$stat;nset=stat$nset
      #stat$act=2;#if (stat$act==1){stat$act=2} # признак - сейчас в поднастройке  # было {stat$act=9}
      if (is.null(neur$str)) {stat$act=3} #пуста структура -> поставить мусорную активность
      
      ############## ошибка - нет некот полей
      names=c('nset','error','time','radius','kol_step','ttime','all_time','kol_podnastr','time_beg')
      for (nm in names){if(!(nm %in% names(stat))) {stat[,nm]=NA}}
      
      #err_new=stat$error;err_pred=stat$error_pred
      all_stat=all_stat[(all_stat$nset!=nset),]
      all_stat=myPackage$sliv(all_stat,stat)
      if (stat$act %in% c(2,4)) {
        str=neur$str;param=neur$param;
        pols=neur$npols;mass=neur$pmas;mass$nset=nset;mass$is=NULL
        rez=neur$rezult;
        
        itog=stat[,names]
        
        if (!is.null(rez)){
          rez=rez[,c('row','yy','zn','err','nset',neuron$vhod$errs)]
          all_rezult=all_rezult[(all_rezult$nset!=nset),]
          all_rezult=myPackage$sliv(all_rezult,rez)
          zap_rez=zap_rez+1*nrow(rez) }
        
        all_str=all_str[(all_str$nset!=nset),]
        all_param=all_param[(all_param$nset!=nset),]
        all_pols=all_pols[(all_pols$nset!=nset),]
        all_mass=all_mass[(all_mass$nset!=nset),]
        
        
        all_str=myPackage$sliv(all_str,str)
        all_param=myPackage$sliv(all_param,param)
        all_pols=myPackage$sliv(all_pols,pols)
        all_mass=myPackage$sliv(all_mass,mass)
        all_mass=all_mass[(!is.na(all_mass$fun)),] #выкинуть лишнее, экономия памяти
        
        itog$nom_nastr=nom_nastr;itog$nom_neur=nom_neur
        all_itogi=myPackage$sliv(all_itogi,itog)
      }}
  }
  
  # окончательная запись в нейросеть собственно результатов настройки
  neir$all_stat=as.data.frame(as.data.table(all_stat));
  neir$all_rezult=as.data.frame(as.data.table(all_rezult));
  neir$all_str=as.data.frame(as.data.table(all_str));
  neir$all_param=as.data.frame(as.data.table(all_param));
  neir$all_pols=as.data.frame(as.data.table(all_pols));
  neir$all_mass=as.data.frame(as.data.table(all_mass));
  neir$all_itogi=as.data.frame(as.data.table(unique(all_itogi)));
  rm(all_stat,all_rezult,all_str,all_param,all_pols,all_mass,all_itogi)
  
  
  # выбрать статистику лучших и худших нейросетей - и только. 
  if (zap_rez>0) {
    neir=neuron$neir.kol_good_best(neir) }
  
  all_stat=neir$all_stat;all_itogi=neir$all_itogi;
  if (is.null(all_stat$kol_good)){all_stat[,c('kol_good','kol_best')]=0}
  all_stat[(is.na(all_stat$kol_good)),c('kol_good','kol_best')]=0
  
  
  #присоединяем результат падения размера ошибки
  all_stat$per=100*all_stat$error/all_stat$error_pred
  all_stat[(is.na(all_stat$per)),'per']=0 
  
  
  # полностью настроенные - плохие
  o=(all_stat$act==4)&(all_stat$kol_good==0) #&(all_stat$act==2)
  all_stat[o,'act']=3;   # признак - больше не настраивать    было =2
  
  
  ###??? отдельно надо ещё - если много хороший, но ни разу не лучший - что делать?
  
  # если ни разу не лучший, и очень мало хороший - удалить
  all_stat$act_=1
  o=((all_stat$act==4)&(all_stat$kol_best==0)&
       (all_stat$kol_good**2<all_stat$kol_dann))
  all_stat[o,'act_']=0
  o=order(all_stat$act_,all_stat$kol_good)
  all_stat=all_stat[o,]
  all_stat$nn=(1:nrow(all_stat))
  all_stat[((all_stat$act_==0)&(all_stat$nn<=10)),'act']=3
  all_stat[((all_stat$act_==0)&(all_stat$nn<=10)),'kol_good']=0
  all_stat$nn=NULL;all_stat$act_=NULL
  
  
  # окончательная запись в нейросеть
  all_stat$per=NULL;neir$all_stat=all_stat;
  
  #уменьшить фильтры, ежели плохо
  nsets=all_stat[(all_stat$act==0),]
  
  
  ### НЕ ПОМНЮ О ЧЁМ БЛОК - МОЖЕТ УДАЛИТЬ???
  if ((nrow(nsets)>0)&(FALSE)) { # если есть ненастраиваемые нейросети (возможно излишний фильтр)
    nsets=nsets$nset;filtr=neir$all_filtr  #   nsets=3   для пробы
    o=(filtr$nset %in% nsets);fil=filtr[o,];filtr=filtr[(!o),];bad=NA
    
    if (nrow(fil)>0){
      bad=aggregate(x=subset(fil,select=c('poln')),
                    by=subset(fil,select=c('nset','n_poll')), FUN="max" )
      bad=bad[(bad$poln==1),];
      #fil=fil[(fil$vib==1),];filtr=rbind(filtr,fil) # обратно больше не возвращаем!
      if (nrow(bad)>0){ # если есть, какие убрать группы входов
        bad=bad$n_poll
        filtr=filtr[(!(filtr$n_poll %in% bad)),] # плохо сочетание - больше не рассматриваем вообще
        pols=neir$opis_pols;poll=neir$opis_poll
        
        pols[(pols$n_poll %in% bad),'act']=0
        poll[(poll$n_poll %in% bad),'act']=0
        
        neir$opis_pols=pols;neir$opis_poll=poll    
        rm(pols,poll)
      }}
    neir$all_filtr=filtr
    rm(filtr,fil,bad)
  }
  
  
  #записать основные статистики - но только реальных нейросетей
  all_stat=neir$all_stat
  all_stat=all_stat[(all_stat$act>0),]
  neir$all_stat=all_stat;
  
  # выбрать лучшие и худшие нейросети. Худшие удалить, и из фильтров  
  neir=neuron$neir.best_rezults(neir)
  
  # итоговая ошибка, без графика
  err=neuron$neir.rez_err(neir);
  if (!is.null(err)){
    err$nom_nastr=nom_nastr
    neir$errors=myPackage$sliv(neir$errors,err)}
  
  return(neir)
  
  # для нормального удаления
  stat=1;nset=1;str=1;param=1;pols=1;rez=1;itog=1;mass=1;
  
  rm(all_stat,all_itogi,it,it_,neir,neurs,nsets,neur,o,stat,err)
  rm(itog,nset,param,pols,rez,str,nom_nastr,nom_neur,mass,zap_rez)
  
}
# пример запуска   neir=neuron$neir.zapis_neurs(neir,neurs) 








#создание хэш-функции. только не сразу, а с обработанного фрейма - сортировка полей
neuron$digest <- function (pp) {
  pp=as.data.frame(pp)
  pq=pp
  
  nm=names(pp);nms=as.data.frame(nm);nms$i=1;o=order(nms$nm);nms=nms[o,]
  if (nrow(pp)>0){
    pq$has=''
    for (nm in nms$nm){pq$has=paste(pq$has,nm,as.character(pp[,nm]),sep='/')
    }
    
    pq$i=1;o=order(pq$has);pq=pq[o,];
    has=''
    for (hh in pq$has){has=paste(has,hh,sep='//')}
  } else { #если нет строк
    has='';for (nm in nms$nm){has=paste(has,nm,sep=',/')} }
  
  
  has=digest(has)
  return(has)
  pq=1;rm(pp,nm,nms,o,p,hh,pq,has)
}
#пример запуска   has=neuron$digest(pol);








#создать столько входов. сколько сказано
neuron$neir.init_vhodi <- function (kol_pol=0) {
  vhodi=neuron$vhodi
  mas=vhodi[(vhodi$tip=='mas'),]
  xx=vhodi[((vhodi$tip %in% c('xz','xs'))|(vhodi$nm_=='upr')),]
  poll=NULL;
  
  if (kol_pol==0){
    {# придумать исходно все возм входы
      bef=neuron$vhod$before
      pp=xx;pp$before=bef;pp$get=pp$nm_;
      pp_=pp[(!is.na(pp$zap_vne)),];pp_$before=0;pp=rbind(pp,pp_)
      pp[(pp$tip=='xs'),'zapazd']=7
      pp=subset(pp,select=c('get','zapazd','before','bef'))
      pp$before=pmax(0,pp$before-pp$bef)
      pp[(pp$get=='upr'),'before']=0
      ppv=pp
      if (bef<364) {  #добавка входов год назад
        nm=as.character(vhodi[(vhodi$tip=='yy'),'nm'])
        nm=c(nm,paste('s_',nm,sep=''))
        pp_=xx[(xx$nm %in% nm)&(xx$tip!='yy'),]
        if (nrow(pp_)>0) {
          pp_$get=pp_$nm_;pp_$before=364;
          pp_$zapazd=7;pp_[(pp_$tip=='xz'),'zapazd']=NA
          pp_=pp_[,c('get','zapazd','before','bef')]
          pp=rbind(pp,pp_)}
      }
      bef_=round(bef/7)*7;if (bef_<bef){bef_=bef_+7}
      ppv$before=bef_;ppv=ppv[(ppv$get!='upr'),];pp=rbind(pp,ppv)
      ppv$before=ppv$before-ppv$bef;pp=rbind(pp,ppv)
      pp=unique(pp);rm(ppv,bef_)
    }
    
    for (nm in mas$name){#по умолчанию массив=0 (совпадение) кроме дат(=-1 не обращать внимания)
      pp[,nm]=0;if (!is.na(mas[(mas$name==nm),'dat'])){pp[,nm]=-1}}
    
    {# НАДО - ПРОВЕСТИ ПРОВЕРКИ, ЕСТЬ ЛИ ПО ПОЛЯМ ВОЗМОЖНОСТИ ПРЯМОЙ СКЛЕЙКИ (m*=0)?
      nms=as.character(unique(pp$get))
      mass=neuron$mass
      for (nnm in nms){ # nnm='xz25'
        dann=neuron$dannie;dann=dann[(!is.na(dann[,nnm])),]
        k=max(round(runif(1)*nrow(dann)),1)
        dann=dann[k,]
        for (nm in mas$name) { # nm='m6'
          if (is.na(mas[(mas$name==nm),'dat'])) {
            zn=dann[,nm];
            is=mass[(mass$nom==zn),'is']
            if (is==0){pp[(pp$get==nnm),nm]=zn}
          }}}
    }
    
    { #присоединить - по полю ограничения все возможные фиксации (не только 'ничего')
      xx_=xx[(!is.na(xx$zap_vne)),]
      if (nrow(xx_)>0){
        xx_$zapazd=NA;xx_[(xx_$tip=='xs'),'zapazd']=7
        xx_$get=xx_$nm_;xx_=xx_[,c('get','zapazd')]
        xx_$before=0;xx_$bef=0
        ms=mas[(is.na(mas$dat)),]
        mass=neuron$mass
        mass=mass[(mass$name %in% ms$name),]
        {# только итоги, либо не более 10 значений
          mass$k=1;  mass$k=mass$is
          mm=aggregate(x=subset(mass,select=c('k')),
                       by=subset(mass,select=c('name')), FUN="sum" )
          mass$k=NULL
          mass=merge(mass,mm,by='name');rm(mm)
          mass=mass[(mass$zn=='-')|(mass$k<10),]
          mass=mass[(mass$is==1),]
        }
        #последовательно проверять данные
        for(nom in mass$nom){  # nom=mass[1,'nom']
          nm=as.character(mass[(mass$nom==nom),'name'])
          dann=neuron$dannie
          dann=dann[(dann[,nm]==nom),]
          pp_=xx_
          for (nm in mas$name){
            if (!is.na(mas[(mas$name==nm),'dat'])){
              pp_[,nm]=-1
            }else{
              pp_[,nm]=0;zn=unique(dann[,nm])
              if (nrow(as.data.frame(zn))==1) {pp_[,nm]=zn}
            }}
          pp=rbind(pp,pp_)
        }}}
    pp=unique(pp)
    
    {# подразмножить по mas$tim
      mas_=mas[(!is.na(mas$tim)),]
      ms=as.character(mas_[(mas_$tim==0),'name']);mas_=mas_[(mas_$tim>0),]
      pps=pp[(pp[,ms]==0),]
      if (nrow(mas_)>0){
        for (tm in unique(mas_$tim)){
          pp_=pps;ms=mas_[(mas_$tim>=tm),]
          for (nm in ms$name){pp_[(pp_[,nm]==0),nm]=-1}
          pp=rbind(pp,pp_)
        }}}
    pp=unique(pp)
    
    
    {# хэши на каждую строку
      pp$nn=(1:nrow(pp))
      for (nn in pp$nn){
        pol=pp[(pp$nn==nn),];pol$nn=NULL
        has=neuron$digest(pol);pol$has=has  # хэш-функция
        poll=rbind(poll,pol) 
      }}
    
  } else{ # фиксированное число входов
    xx=xx[(xx$nm_!='upr'),]
    mass=neuron$mass
    for (nn in (1:kol_pol)){ #  nn=1
      #  случайный выбор входного параметра
      xx$r=runif(nrow(xx));o=order(xx$r);xx=xx[o,];
      xx_=xx[1,];
      get=as.character(xx_$nm_);
      tip=as.character(xx_$tip);bef=as.numeric(xx_$bef)
      pol=as.data.frame(get);pol$zapazd=NA
      if (tip=='xs'){pol$zapazd=round(runif(1)*neuron$vhod$before)+2}
      
      dann=neuron$dannie;dann=dann[(!is.na(dann[,get])),]
      k=max(round(runif(1)*nrow(dann)),1);dn=dann[k,] # случайный выбор - по кому делать маску
      
      for (nm in mas$name){ # nm='m9'
        zn=dn[,nm];if ((runif(1)<0.7)&(mass[(mass$nom==zn),'is']==1))  {zn=0}
        if (!is.na(mas[(mas$name==nm),'dat'])) {zn=-1}
        pol[,nm]=zn
        if (zn>0){dann=dann[(dann[,nm]==zn),]}}
      
      #проверить факты фильтров - если для поля всего 1 вариант - тоже в фильтр
      for (nm in mas$name){  #  nm='m2'
        zn=as.integer(pol[,nm])
        if (zn==0){
          dn=unique(dann[,nm]);dn=as.data.frame(dn)
          if (nrow(dn)==1){pol[,nm]=dn[1,'dn']}
        }}
      
      pol$bef=bef
      pol$before=max(0,neuron$vhod$before+round(runif(1)*30)-bef) #запаздывание
      if ((!is.na(vhodi[(as.character(vhodi$nm_)==pol$get),'zap_vne']))&(runif(1)<0.5)) {
        pol$before=round((runif(1)**2)*30) #запаздывание если любые сроки (число мест)
      }
      if ((neuron$vhod$before<364)&(runif(1)<0.3)){# подстановка даты с год назад
        pol$before=364+round(runif(1)*3)*7
      }
      
      {# подразмножить по mas$tim
        mas_=mas[(!is.na(mas$tim)),]
        ms=mas_[(mas_$tim==0),'name'];mas_=mas_[(mas_$tim>0),]
        if ((pol[,ms]==0)&(runif(1)>0.5)){
          mas_$r=runif(nrow(mas_));o=order(mas_$r);mas_=mas_[o,]
          tm=mas_[1,'tim'];mas_=mas_[(mas_$tim>=tm),]
          for (nm in mas_$name){pol[(pol[,nm]==0),nm]=-1}
        }}
      
      has=neuron$digest(pol);pol$has=has  # хэш-функция
      poll=rbind(poll,pol)
    }
  }
  
  dann=1;dn=1;mas=1;pol=1;vhodi=1;xx=1;get=1;kol_pol=1;nm=1;nn=1;
  o=1;tip=1;zn=1;has=1;xx_=1;bef=1;mass=1;ms=1;pp=1;pp_=1;nom=1;
  mas_=1;pps=1;nnm=1;tm=1;tms=1;is=1;k=1;nms=1;
  
  return(poll)
  rm(dann,dn,mas,pol,poll,vhodi,xx,get,kol_pol,nm,nn,o,tip,zn,has,xx_,bef,mass,ms)
  rm(mas_,pps,nnm,tm,tms,pp,pp_,nom,is,k,nms)
}
# пример запуска  pol=neuron$neir.init_vhodi(5) 







#создать внутреннюю стректуру, которую далее заполнять данными
neuron$neir.init_neir <- function (kol_pol=0) {
  
  neir=list()
  neir$mass=neuron$mass
  neir$vhod=neuron$vhod
  neir$vhodi=neuron$vhodi
  
  vhodi=neir$vhodi
  mas=vhodi[(vhodi$tip=='mas'),]
  xx=vhodi[(vhodi$tip %in% c('xz','xs')),]
  
  {#создание списка входов - с проверкой качества
    pol=neuron$neir.init_vhodi(kol_pol)  
    o=order((pol$get!='upr'));pol=pol[o,]
    kol_pol=nrow(pol);pol$n_pol=(1:kol_pol)
  }
  
  {#таблица созданий множеств входных данных  было kol_pol*3
    n_poll=(0:(kol_pol*10));poll=as.data.frame(n_poll)
    poll$pred_poll=0;poll$plus_pol=0;poll$kol_pol=0
    k=nrow(poll)
    poll$pred_poll=pmax(round(runif(k)*(poll$n_poll-1)),0)
    poll$plus_pol=round(runif(k)*kol_pol+0.5)
    
    if (neir$vhod$kol_upr>0){ # управляющий вход - всегда первый
      poll[(poll$pred_poll==0),'plus_pol']=1
    }
    #ДОБАВИТЬ И ВСЕ ЕДИНИЧНЫЕ ВХОДЫ
    pp=pol;pp$plus_pol=pp$n_pol;pp$kol_pol=0;pp=pp[,c('plus_pol','kol_pol')]
    pp$pred_poll=0;pp$n_poll=max(poll$n_poll)+(1:nrow(pp))
    poll=rbind(poll,pp)
  }
  
  { # создание расшифровок входов
    n_poll=0;pols=as.data.frame(n_poll);pols$n_pol=0;pols$nom_pol=0;
    for (n_poll in (1:max(poll$n_poll))){   #   n_poll=1
      pred=poll[(poll$n_poll==n_poll),'pred_poll']
      plus=poll[(poll$n_poll==n_poll),'plus_pol']
      
      pp=pols[(pols$n_poll==pred),]
      pp_=pp[(pp$nom_pol==0),]
      pp_$n_pol=plus;pp_$nom_pol=nrow(pp)
      pp=rbind(pp,pp_);pp$n_poll=n_poll
      
      pp_=pp;pp_$nom_pol=NULL;pp_=unique(pp_)
      if (nrow(pp)>nrow(pp_)) {pp$n_pol=0}
      pols=rbind(pols,pp)
    }
    pols=pols[(pols$n_pol>0),]
    
    pp=aggregate(x=subset(pols,select=c('nom_pol')),by=subset(pols,select=c('n_poll')), FUN="max" )
    
    poll=merge(poll,pp,by='n_poll',all=TRUE)
    poll$kol_pol=poll$nom_pol;poll$nom_pol=NULL
    poll[(poll$n_poll==0),'kol_pol']=0
    poll=poll[(!is.na(poll$kol_pol)),]
    
    {#оставить не слишком много вариантов
      o=order(poll$kol_pol,poll$n_poll);poll=poll[o,]
      poll$is=0;poll$n=(1:nrow(poll))
      poll[(poll$n<1000),'is']=1
      poll[(poll$kol_pol<5),'is']=1
      poll=poll[(poll$is==1),];poll$is=NULL;poll$n=NULL
      pols=pols[(pols$n_poll %in% poll$n_poll),]
    }
  }
  
  if (neir$vhod$kol_upr>0){ # управляющий вход - 0 входов нельзя
    poll=poll[(poll$kol_pol>0),] }
  
  pp=pol[,c('n_pol','has')]
  pols=merge(pols,pp,by='n_pol')
  
  {#  хэши на все выборки
    poll$has=NA
    for (npoll in poll$n_poll){  
      pp=pols[(pols$n_poll==npoll),];
      o=order(pp$has);pp=pp[o,];
      pp=unique(subset(pp,select='has'))
      pp=as.data.frame((as.data.table(pp)))
      has=neuron$digest(pp);
      if (has %in% poll$has) {
        poll=poll[(poll$n_poll!=npoll),];pols=pols[(pols$n_poll!=npoll),]}
      poll[(poll$n_poll==npoll),'has']=has
    }}
  
  #записать поля выбора данных
  pol$out=paste('z_',pol$n_pol,sep='')
  pols$zn=paste('z_',pols$n_pol,sep='')
  pols$out=paste('x',pols$nom_pol,sep='')
  
  poll$act=1;pols$act=1;pol$act=1
  neir$opis_pol=pol;neir$opis_poll=poll;neir$opis_pols=pols
  
  {# теперь ввести фильтрации
    n_poll=unique(poll$n_poll)
    filtr=as.data.frame(n_poll);filtr$vib=1
    for (nm in mas$name){ #ff[,nm]=pmax(ff[,nm],0);
      filtr[,nm]=0}
  }
  
  {#ввести номера нейросетей - по 2 на множество (пока что так)
    filtr$nset=filtr$n_poll+1
    ff=filtr;nset=max(ff$nset);ff$nset=ff$nset+nset
    filtr=rbind(filtr,ff)
    filtr$poln=1
    
    filtr$pred_nset=0;filtr$pred_row=NA;filtr$progr='000'
    {#добавить nset=0 part=0
      ff=filtr[(filtr$nset==1),];ff$nset=0;
      filtr=rbind(filtr,ff)
    }
    
    neir$all_filtr=filtr # для nset берём из n_poll, используя описанный фильтр
  }
  
  { # инициирование входных параметров нейросетей всех - макс и мин
    name='1';all_param=as.data.frame(name);
    all_param[ ,c('max','min','nset')]=0
    all_param=all_param[0,]
    neir$all_param=all_param}
  
  { # инициирование списка входов 
    all_pols=as.data.frame(nset);
    all_pols[,c('zn','out','tip','vhod')]='';all_pols$kol=0
    all_pols=all_pols[0,]
    neir$all_pols=all_pols}
  
  { # инициирование списка всех значений массивов
    nset=1;all_mass=as.data.frame(nset)
    all_mass$zn=1;all_mass$fun=1;
    all_mass=all_mass[0,];neir$all_mass=all_mass}
  
  { #инициализировать список всех структур нейросетей
    nset=1;all_str=as.data.frame(nset)
    all_str[,c('rebro','vhod','vih','zn')]=0
    all_str=all_str[0,];neir$all_str=all_str}
  
  { # создать итоговую таблицу параметров
    all_stat=as.data.frame(nset);
    all_stat[,c('error','kol_m','kol_x','kol_mas','kol_str')]=0
    all_stat=all_stat[0,];neir$all_stat=all_stat  }
  
  return(neir) 
  
  all_mass=1;all_param=1;all_pols=1;all_stat=1;all_str=1;ff=1;filtr=1;mas=1;pol=1;
  has=1;kol_pol=1;n_poll=1;name=1;neir=1;nm=1;npoll=1;nset=1;o=1;xx=1;pp_=1;k=1;
  plus=1;pred=1;poll=1;pols=1;pp=1;vhodi=1;
  
  rm(all_mass,all_param,all_pols,all_stat,all_str,ff,filtr,mas,pol,poll,pols)
  rm(pp,vhodi,has,kol_pol,n_poll,name,neir,nm,npoll,nset,o,xx,pp_,k,plus,pred)
}
# пример запуска  neir=neuron$neir.init_neir(kol_pol=5)












#подчистка самих настроечных данных - удалить пустые и полностью настроенные
neuron$neir.podchist_neurs <- function (neir,neurs) {
  stat=neir$all_stat;
  stat=stat[(stat$act %in% c(2)),] # список кого настраивать вообще, или прямо сейчас   было  c(1,9)
  nsets=stat$nset
  
  neurs <- lapply(FUN = function(neur) {  
    if (!is.null(neur)){
      if (!(neur$stat$nset %in% nsets)) {neur=NULL}}  
    if (!is.null(neur)){return (neur)}
  }, X = (neurs))
  
  return(neurs)
  rm(stat,nsets,neurs)
}
# пример запуска   neurs=neuron$neir.podchist_neurs(neir,neurs)




# найти номера добавляемых в рассчёт сетей (kol_plus  штук)
neuron$neir.plus_nsets <- function (neir,kol_plus) {
  
  nsets=NULL;o=1
  fil=neir$all_filtr;fil=fil[,c('n_poll','nset')];fil=unique(fil);
  stat=neir$all_stat;
  if (nrow(stat)>0){
    if (is.null(stat$kol_best)){stat$kol_best=0;stat$kol_good=0}
    stat=stat[,c('nset','act','kol_best','kol_good')]}
  fil=merge(fil,stat,by='nset',all=TRUE)
  if (!('act' %in% names(fil))){fil$act=NA;fil$kol_best=NA;fil$kol_good=NA}
  fil=fil[(is.na(fil$act))|(!(fil$act %in% c(2,3,4))),]
  
  if (nrow(fil)>0){ # есть ли ещё нерассмотренные нейросети
    o=order((is.na(fil$act)),(fil$n_poll>0),-fil$kol_best,-fil$kol_good,fil$nset);fil=fil[o,]
    fil$n=(1:nrow(fil));fil=fil[(fil$n<=kol_plus),]
    nsets=unique(subset(fil,select='nset'))
    nsets=fil$nset  }
  
  return(nsets)
  rm(nsets,stat,fil,o,neir,kol_plus)
}
# пример запуска   nsets=neuron$neir.plus_nsets(neir,kol_plus) 










#  добавить новые входы (5шт) и группы входов, и фильтры
neuron$neir.plus_vhodi <- function (neir) {
  
  { #корр фильтров - постановка родительских нейросетей по умолчанию
    fil=neir$all_filtr
    if (is.null(fil$pred_nset)){
      fil$pred_nset=0;fil$progr='0' }
    fil[(is.na(fil$pred_nset)),'pred_nset']=0
    if (nrow( fil[(is.na(fil$progr)),])>0){fil[(is.na(fil$progr)),'progr']='0'}
    if (is.null(fil$pred_row)) {fil$pred_row=NA}
    neir$all_filtr=fil;rm(fil)
  }
  
  
  {#Добавление новых нейросетей - самые лучшие сделать с усложнением!!!
    stat=neir$all_stat;fil=neir$all_filtr
    max_nset=max(fil$nset,stat$nset)
    st=stat[(stat$kol_best>0),]    
    st$kol=(pmin(st$dann_test,st$dann_nastr)-st$min_kol)/10
    
    str=neir$all_str;str=str[(str$nset %in% st$nset),]
    str_=str[(str$vhod==str$vih),]
    
    str_vih=aggregate(x=subset(str,select=c('vih')),
                      by=subset(str,select=c('nset')), FUN="max" )
    
    str_=merge(str,str_vih,by=c('nset','vih'))
    str_=str_[(str_$vhod>=0),];str_$koll=1
    str_s=aggregate(x=subset(str_,select=c('koll')),
                    by=subset(str_,select=c('nset')), FUN="sum" )
    
    st=merge(st,str_s,by='nset');st=st[(st$kol>st$koll),]
    o=order(-st$kol_best);st=st[o,]
    
    if (nrow(st)>20){st=st[(1:20),]} #взять максимум 20 штук лучших
    
    if (nrow(st)>0){# есть чего добавлять
      st$nset_=max_nset+(1:nrow(st))
      
      st$min_kol=st$min_kol+10*st$koll
      st$kol_str=st$kol_str+st$koll
      st$kol_param=st$kol_param+st$koll
      st$kol=NULL;st$koll=NULL;st_=st[,c('nset','nset_')]
      
      str_=merge(str,st_,by='nset')
      str_vih$z=1;str_=merge(str_,str_vih,by=c('nset','vih'),all=TRUE)
      str_=str_[(!is.na(str_$rebro)),]
      
      str_p=str_[(!is.na(str_$z)),]
      o=(str_p$vhod==-1);
      str_p[o,'vih']=str_p[o,'vih']+1
      str_p[o,'vhod']=str_p[o,'vih']-1
      str_p[o,'zn']=0
      o=(str_p$vhod==str_p$vih)
      
      #типы нейронов в промежуток = (2,3)
      str_p[o,'zn']=pmin(round(runif(nrow(str_p[o,]))*2+1.5),3)
      
      o=(!is.na(str_$z))
      str_[o,'vih']=str_[o,'vih']+1
      o=(!is.na(str_$z)&(str_$vih==str_$vhod+1))
      str_[o,'vhod']=str_[o,'vhod']+1
      
      str_=rbind(str_,str_p)
      str_$nset=str_$nset_
      str_$z=NULL;str_$nset_=NULL
      
      o=order(str_$nset,str_$vih,(str_$vhod==-1),str_$vhod)
      str_=str_[o,]
      str_$reb=(1:nrow(str_))
      str_r=aggregate(x=subset(str_,select=c('reb')),
                      by=subset(str_,select=c('nset')), FUN="min" )
      
      str_r$rb=str_r$reb;str_r$reb=NULL
      str_=merge(str_,str_r,by='nset')
      str_$rebro=str_$reb-str_$rb+1
      
      str_$reb=NULL;str_$rb=NULL
      
      # обратно добавить всё новое
      st$nset=st$nset_;st$nset_=NULL;st$act=1;
      st$kol_best=0;st$kol_good=0
      stat=rbind(stat,st)
      str=neir$all_str;str=rbind(str,str_)
      fil=neir$all_filtr;fil_=merge(fil,st_,by='nset')
      fil_$pred_nset=fil_$nset;fil_$progr='0.1'
      fil_$nset=fil_$nset_;fil_$nset_=NULL;fil=rbind(fil,fil_)
      mass=neir$all_mass;mass_=merge(mass,st_,by='nset')
      mass_$nset=mass_$nset_;mass_$nset_=NULL;mass=rbind(mass,mass_)
      
      npols=neir$all_pols;npols_=merge(npols,st_,by='nset')
      npols_$nset=npols_$nset_;npols_$nset_=NULL;npols=rbind(npols,npols_)
      
      #запись
      neir$all_stat=stat;
      neir$all_str=str
      neir$all_mass=mass;
      neir$all_filtr=fil
      neir$all_pols=npols
      rm(fil,fil_,mass,mass_,st_,str_p,str_r,npols,npols_)
    }
    rm(st,stat,str,str_,str_s,str_vih,max_nset,o)
  }
  print('plus_uslojn: 0.1')
  
  
  vh=neir$vhodi;mas=vh[(vh$tip=='mas'),]
  kol_pol=0;poll_=as.data.frame(kol_pol) ##########
  
  {  # попытка добавить симметричные нейросети - по другому настроечному множеству
    fil=neir$all_filtr;stat=neir$all_stat;fil$kol=1
    
    fil_=aggregate(x=subset(fil,select='kol'),by=subset(fil,select='nset'), FUN="sum" )
    
    fil_=unique(fil[,c('nset','n_poll')])
    st=unique(stat[,c('nset','part')])
    rez=merge(fil_,st,by='nset')
    rez$is=0;#rez$nset=NULL;
    rez=unique(rez)
    st=unique(stat[(stat$kol_best>0),c('nset','part')])
    st$part=1-st$part
    
    rez_=merge(fil_,st,by='nset')
    rez_$is=1;
    #rez_$pred_nset=rez_$nset;rez_$nset=NULL;
    rez_=unique(rez_)
    rez=rbind(rez,rez_)
    rez=aggregate(x=subset(rez,select=c('is','nset')),
                  by=subset(rez,select=c('n_poll','part')), FUN="min" )
    rez=rez[(rez$is==1),];
    rez$is=NULL
    
    nset=max(fil$nset,stat$nset)
    
    if (nrow(rez)>0){
      rez$pred_nset=rez$nset;rez$progr='0.2'
      rez$nset=(1:nrow(rez))+nset
      fil_=rez;fil_$part=NULL;fil_[,c('vib','poln')]=1;
      for (nm in mas$name){fil_[,nm]=0}
      st=rez;st$n_poll=NULL;st$act=0
      st$progr=NULL;st$pred_nset=NULL
      fil$kol=NULL;fil_$pred_row=NA
      fil=rbind(fil,fil_);
      stat=myPackage$sliv(stat,st)
      neir$all_stat=stat
      neir$all_filtr=fil
    }
    rm(fil,fil_,rez,rez_,st,stat,nset)
  }
  print('plus_simmetr: 0.2')
  
  
  poll=neir$opis_poll;pols=neir$opis_pols;pol=neir$opis_pol
  filtr=neir$all_filtr;
  stat=neir$all_stat;
  { ##исправляшка
    poll[(poll$n_poll==0),c('pred_poll','kol_pol','plus_pol')]=0   
    poll[(poll$n_poll==0),'act']=1
  }
  
  
  if (FALSE) { #уменьшение количеств строк по плохим нейросетям
    filtr=filtr[(filtr$nset %in% stat[(stat$act!=3),'nset']),]
    pols_=pols[(pols$n_poll %in% filtr$n_poll),]
    pol=pol[(pol$n_pol %in% pols_$n_pol),]
    pol_=pol;pol_$f=1;pol_=pol_[,c('n_pol','f')];
    pols_=merge(pols,pol_,by='n_pol',all=TRUE)
    pols_[(is.na(pols_$f)),'f']=0
    pols_=aggregate(x=subset(pols_,select=c('f')),by=subset(pols_,select='n_poll'), FUN="min" )
    pols_=pols_[(pols_$f==1),]
    pols=pols[(pols$n_poll %in% pols_$n_poll),]
    poll=poll[(poll$n_poll %in% pols_$n_poll),]
    rm(pol_,pols_)
    neir$opis_poll=poll;neir$opis_pols=pols;neir$opis_pol=pol
    neir$all_filtr=filtr
  }
  
  
  {# взять случайно 2 размножаемые нейросети, из лучших
    stat_=stat;stat_$kol=stat_$kol_best
    stat_=stat_[((!is.na(stat_$kol))&(stat_$kol>0)),]
    st=neuron$neir.sluchaini_vibor(stat_) 
    stat_=stat_[(stat_$nset!=st$nset),]
    st2=neuron$neir.sluchaini_vibor(stat_) 
    st=rbind(st,st2);
    nsets=st$nset
    rm(stat_,st,st2)
  }
  print('plus_vhodi: 1')
  
  { #  перед созданием наборов - добавить поля (10 штук)
    pol=neir$opis_pol
    pol_=neuron$neir.init_vhodi(10) 
    pol_=unique(pol_);pol_=pol_[(!(pol_$has %in% pol$has)),];
    pol_$n_pol=(max(pol$n_pol))+(1:nrow(pol_))
    pol_$out=paste('z',pol_$n_pol,sep='_');pol_$act=1
    pol=rbind(pol,pol_);rm(pol_)
    ###  neir$opis_pol=pol 
  }
  print('2')
  
  
  { # часть вторая - лучшие входы добавить в изменённом виде - убрать по 1 фильтру, или (before zapazd) кратны 7
    fil=filtr[(filtr$nset %in% stat[(stat$kol_best>0),'nset']),]  #все фильтры всех хороших нейросетей
    pols_=pols[(pols$n_poll %in% fil$n_poll),]
    pol_=pol[(pol$n_pol %in% pols_$n_pol),]
    
    #pol_2=pol_;
    for (npol in pol_$n_pol){ #  для каждого входа - по очереди вычеркнуть 1 из ограничений  npol=110
      pp=pol_[(pol_$n_pol==npol)&(!is.na(pol_$n_pol)),]
      pp$n_pol=NA;
      #mas$r=runif(nrow(mas));o=order(mas$r);mas=mas[o,]
      #k=0
      for (nm in mas$name){
        pp_=pp;if (pp_[,nm]>0) {pp_[,nm]=0;pol_=rbind(pol_,pp_)}}
      # И ещё - округления кратные 7 дням
      pp$before=max(round(pp$before/7)*7,neir$vhod$before)
      pol_=rbind(pol_,pp)
      if (!is.na(pp$zapazd)){
        pp$zapazd=round(pp$zapazd/7)*7;pol_=rbind(pol_,pp)}
    }
    pol_=pol_[(is.na(pol_$n_pol)),]
    pol_=pol_[(pol_$get!='upr'),]
    print('2.1')
    
    
    #теперь оставить нужные - по новизне хэш-функции
    if (nrow(pol_)>0) {
      pol_$n_pol=(1:nrow(pol_))
      pol_$out=NULL;pol_$act=NULL
      for (npol in pol_$n_pol){  #  npol=94
        pp=pol_[(pol_$n_pol==npol),];pp$n_pol=NULL;pp$has=NULL
        has=neuron$digest(pp);pp$has=has  # хэш-функция
        pp$n_pol=npol;
        
        if (!(has %in% pol$has)){
          pp$n_pol=(max(pol$n_pol))+1
          pp$out=paste('z',pp$n_pol,sep='_');pp$act=1
          pp$has=has
          pol=rbind(pol,pp);
        }}}
    neir$opis_pol=pol  # вот теперь запись в базу
  }
  print('3')
  
  
  { # новые наборы данных - отдельно новые поля. и отдельно комбинации всех лучших
    if (FALSE)    { 
      # создаём уйму новых сочетаний - возможно неправильных, или уже были
      # сперва просто новые
      poll_=subset(pol,select='n_pol')
      poll_$pred_poll=0;poll_$plus_pol=poll_$n_pol;poll_$n_pol=NULL;poll_$kol_pol=1
      poll_=poll_[(!(poll_$plus_pol %in% poll$plus_pol)),]
      plus_pol=subset(poll_,select='plus_pol') #запомнить всех новых
      
      # теперь комбинации хороших = (к каждой хорошей + любую составляющую от любой хорошей)
      pp=unique(subset(filtr[(filtr$nset %in% nsets),],select=c('n_poll','nset')))
      pp=poll[(poll$n_poll %in% pp$n_poll),c('n_poll','kol_pol')]
      ps=pols[(pols$n_poll %in% pp$n_poll),]
      ps=unique(subset(ps,select='n_pol'))
      pp=merge(pp,ps);pp$pred_poll=pp$n_poll;pp$plus_pol=pp$n_pol;
      pp$kol_pol=pp$kol_pol+1;pp$n_poll=NULL;pp$n_pol=NULL
      poll_=rbind(poll_,pp)  #оба вместе
      
      # теперь к каждой хорошей - каждую новую
      pp$plus_pol=NULL;pp=unique(pp);pp=merge(pp,plus_pol)
      poll_=rbind(poll_,pp)  #оба вместе
      
      poll_$z=(1:nrow(poll_));poll_$act=1  # первичная нумерация
    }
    print('3.1')
    
    
    { # новые придумать иначе - просто все варианты
      pp=unique(subset(filtr[(filtr$nset %in% nsets),],select=c('n_poll','nset')))
      pp_=pp
      pp=poll[(poll$n_poll %in% pp$n_poll),]
      pp$pred_poll=pp$n_poll;pp$kol_pol=pp$kol_pol+1;pp$has=NULL
      npol=subset(pol,select=c('n_pol','has'));npol$z=0
      pp=merge(pp,npol);
      pp$plus_pol=pp$n_pol
      if (nrow(pp)>0){pp$z=(1:nrow(pp))}
      pp$n_poll=NULL;pp$n_pol=NULL
      poll_=pp
    }
    print('3.2')
    
    
    {#рассчитаем, что туда входит
      ps=pols;ps$pred_poll=ps$n_poll;ps$n_poll=NULL;ps$act=NULL;ps$has=NULL
      #  сперва к чему добавляем
      ps=merge(ps,poll_,by='pred_poll');ps$has=NULL
      ps=subset(ps,select=c('z','n_pol','nom_pol','zn','out')) # z вместо n_poll
      ps=merge(ps,pol[,c('n_pol','has')],by='n_pol')
      
      if (nrow(poll_)>0){
        #  теперь что добавляем
        ps_=poll_;ps_$n_pol=ps_$plus_pol;ps_$nom_pol=ps_$kol_pol
        
        ps_$out=paste('x',ps_$kol_pol,sep='')
        ps_=subset(ps_,select=c('z','n_pol','nom_pol','out','has')) # z вместо n_poll
        pp=pol;pp$zn=pp$out;pp=pp[,c('n_pol','zn')]
        ps_=merge(ps_,pp,by='n_pol')
        # оба источника вместе
        ps=rbind(ps,ps_);}
      if (nrow(ps)>0){ps$act=1}
    }
    print('3.3')
    
    
    #ДОЛГИЙ БЛОК - А ИЗМЕНЯЕТ ТОЛЬКО N_POLL=0 - БЫЛО=NA
    # перерасчитать хэш функции - по одинак алгоритму - а почему раньше неправильно - не знаю!!!
    if (FALSE){
      for (npoll in poll$n_poll){ ##   npoll=2   npoll=3
        ps_=pols[(pols$n_poll==npoll),]
        #подсчёт хэш функции
        has=unique(ps_[,c('n_pol','has')])
        has$n_pol=NULL
        has=neuron$digest(has);
        # poll[(poll$n_poll==npoll),'has']=has # почему-то не отрабатывает, подставляет NA
        #   поэтому подставляем в 3 шага:
        o=(poll$n_poll==npoll)
        poll1=poll[o,];poll1$has=has;poll2=poll[(!o),]
        poll=rbind(poll1,poll2)
      }}
    print('3.4')
    
    
    #ОЧЕНЬ ДОЛГИЙ БЛОК!!!!!!!!
    #ищем уникальные варианты комбинаций входов. Те что новые - добавляем
    
    poll_$r=runif(nrow(poll_));o=order(poll_$r);poll_=poll_[o,];poll_$r=NULL
    #for (z in poll_$z){print(z)}
    poll_$has=NA
    
    new=0
    n_poll=max(poll$n_poll)
    for (z in poll_$z){   #  z=2
      if (new<200){ # ограничение максимум 100 новых
        ps_=ps[(ps$z==z),]
        #подсчёт хэш функции
        has=unique(ps_[,c('n_pol','has')])
        has$n_pol=NULL
        has=neuron$digest(has);
        # далее поставить. если таких не было  
        if (!(has %in% poll$has)){
          pp_=poll_[(poll_$z==z),];pp_$has=has
          n_poll=n_poll+1
          pp_$n_poll=n_poll;ps_$n_poll=n_poll;pp_$z=NULL;ps_$z=NULL
          poll=rbind(poll,pp_);pols=rbind(pols,ps_);new=new+1
        }}}
    print(paste('3.5  new=',new,sep=''))
    
    #сохранение
    poll=as.data.frame(as.data.table(poll));neir$opis_poll=poll
    pols=as.data.frame(as.data.table(pols));neir$opis_pols=pols
  }
  print('4')
  
  
  { # теперь создать фильтры
    { #добавить все новые варианты входов. без фильтров
      fil=poll[(!(poll$n_poll %in% filtr$n_poll)),]
      fil=fil[(fil$act==1),];
      if (nrow(fil)>0) {
        fil$vib=1
        fil=fil[,c('n_poll','vib'),]
        #vh=neir$vhodi;mas=vh[(vh$tip=='mas'),]
        for (nm in mas$name){fil[,nm]=0}
        # добавить число полей в выборке - для сортировки
        poll=poll[,c('n_poll','kol_pol')]
        fil=merge(fil,poll,by='n_poll')
        fil$r=runif(nrow(fil));
        o=order(fil$r);fil=fil[o,];fil$r=NULL;fil$kol_pol=NULL
        fil$nset=(1:nrow(fil));fil=fil[(fil$nset<=500),] #брать новых немного!!!
        mnset=max(fil$nset)
        fil$nset=max(filtr$nset)+(1:nrow(fil));fil$poln=1
        fil$pred_nset=0;fil$progr='4.1';fil$pred_row=NA
        filtr=rbind(filtr,fil); #добавлены все новые варианты входов. без фильтров
      }
    }
    print(paste('4.1 neww=',mnset,''))
    
    
    { # теперь из лучших нейросетей сделать подфильтры, неполные данные
      fil=filtr[(filtr$nset %in% nsets),];filtr2=filtr[0,]
      if (nrow(fil)>0){
        fil$pred_nset=fil$nset
        # если есть настроенные сети, которые можно подразмножить
        fil$poln=0;
        mnset=max(filtr$nset)
        rez=neir$all_rezult;rezz=NULL
        # для каждого размножаемого фильтра - выбрать точку данных, для дальнейшей работы
        for (nset in nsets){ #  на бодущее - переделать без цикла, чтобы быстрее работало
          rr=rez[(rez$nset==nset),];rr=rr[(!is.na(rr$yy)),]
          rr$r=runif(nrow(rr));o=order(rr$r);rr=rr[o,];rr=rr[1,c('nset','row')]
          if (is.null(rezz)){rezz=rr}  else {rezz=rbind(rezz,rr)}
        }
        rezz=rezz[(!is.na(rezz$nset)),]
        dn=neir$dann;dn=dn[(dn$row %in% rezz$row),]
        #по полученным примерам в каждую нейросеть по 1 новому фильтру добавить
        
        for (nset in rezz$nset){  #  Для каждой лучшей нейросети - 2 новых фильтра (фильтр, и всё кроме фильтра)  nset=16
          mas$r=runif(nrow(mas));o=order(mas$r);mas=mas[o,];k=0
          row=rezz[((rezz$nset==nset)&(!is.na(rezz$row))),'row']
          ff=fil[(fil$nset==nset),];
          ff$pred_row=row
          for (nm in mas$name){ #  nm='m1'
            z=max(ff[(ff$vib==1),nm]) # в плюсовой части этого фильтра ещё не было
            if ((z==0)&(k==0)){ # собственно новые фильтры
              z=unique(dn[(dn$row==row),nm]); # ошибка row=(NA,47161) - на выходе 2 значения
              if (!is.na(z)){
                #плюсовой фильтр - берём только z
                ff_=ff[(ff[,nm]==0),]; 
                if (nrow(ff_)>0){
                  k=1;ff_[,nm]=z;
                  mnset=mnset+1;ff_$nset=mnset;filtr2=rbind(filtr2,ff_) #просто фильтр
                }
                # минусовой фильтр - берём всё, кроме z
                ff_=ff[(ff$vib==1),];
                if (nrow(ff_)>0){
                  ff_[,nm]=z;ff_$vib=-1;ff_=rbind(ff_,ff);k=1 #признак. что по nset уже добавили фильтры
                  mnset=mnset+1;ff_$nset=mnset;filtr2=rbind(filtr2,ff_) # предыдущее минус фильтр
                }
              }
            }}
        }
      } # создали новые фильтры как подфильтрации старых лучших
      if (nrow(filtr2)>0) {
        filtr2$progr='4.2';filtr=rbind(filtr,filtr2) } #думал брать не все, а некоторые
    }
    print('4.2')
    
    {# ещё вариант - каждому лучшему - по 2 последующих с наследуемой фильтрацией, случайным образом
      fil=filtr[(filtr$nset %in% nsets),]
      poll=neir$opis_poll;
      poll=poll[(poll$pred_poll %in% fil$n_poll),]
      poll$new_poll=poll$n_poll;poll$n_poll=poll$pred_poll;
      poll=poll[,c('new_poll','n_poll')]
      fil_=merge(fil,poll,by='n_poll')
      fil_=unique(fil_[,c('new_poll','n_poll','nset')])
      fil_$r=runif(nrow(fil_));o=order(fil_$nset,fil_$r);fil_=fil_[o,]
      if (nrow(fil_)>0){
        fil_$r=(1:nrow(fil_))
        ff=aggregate(x=subset(fil_,select=c('r')),by=subset(fil_,select=c('nset')), FUN="min" )
        ff$rr=ff$r;ff$r=NULL
        fil_=merge(fil_,ff,by='nset')
        fil_=fil_[(fil_$r<fil_$rr+5),]
        fil_=fil_[,c('new_poll','nset')] # создали - какой старой нейросети какое новое сочетание входов
        fil_$nnset=mnset+(1:nrow(fil_))
        fil=merge(fil,fil_,by='nset')
        fil$n_poll=fil$new_poll;fil$new_poll=NULL
        fil$pred_nset=fil$nset;fil$nset=fil$nnset;fil$nnset=NULL
        fil$progr='4.3'
        filtr=rbind(filtr,fil) }
    }
    print('4.3')
    neir$all_filtr=as.data.frame(as.data.table(filtr))
  }
  print('5')
  
  
  {#РАССМОТРЕТЬ 5 ЛУЧШИХ НЕЙРОСЕТЕВЫХ ВХОДОВ, И СДЕЛАТЬ СЛАБЫЕ МУТАЦИИ, ВСЕ ВОЗМОЖНЫЕ
    
    stat=neir$all_stat
    stat=stat[(!is.na(stat$kol_x)),]
    stat=stat[(stat$kol_x>0),]  # было >1
    fil=neir$all_filtr
    fil=unique(fil[,c('n_poll','nset')])
    #fil=fil[(fil$nset %in% nsets),]
    stat=merge(fil,stat,by='nset')
    fil=aggregate(x=subset(stat,select=c('kol_best')),by=subset(stat,select='n_poll'), FUN="sum" ) 
    
    fil=fil[(fil$n_poll>0),]
    
    {# взять максимум 5 штук
      o=order(-fil$kol_best);fil=fil[o,];
      fil$nn=(1:nrow(fil));fil=fil[(fil$nn<=5),];fil$nn=NULL}
    
    stat=stat[(stat$n_poll %in% fil$n_poll),]
    o=order(stat$n_poll,-stat$kol_best);stat=stat[o,]
    stat$nn=(1:nrow(stat))
    o=aggregate(x=subset(stat,select=c('nn')),by=subset(stat,select='n_poll'), FUN="min" )
    stat=merge(stat,o,by=c('n_poll','nn'));stat$nn=NULL
    
    pols=neir$opis_pols;pols=pols[(pols$n_poll %in% fil$n_poll),]
    
    pol=neir$opis_pol
    pol=merge(pol,pols[,c('n_pol','nom_pol','n_poll')],by='n_pol')
    pol$ed=1
    
    xx=neir$vhodi;xx$get=xx$nm_;xx=xx[,c('get','tip','zap_vne','bef')]
    xx=xx[(xx$tip %in% c('xz','xs')),];xx$ed=1
    
    
    {#НАЙТИ ВСЕ ПОХОЖИЕ ЗАМЕНИТЕЛИ! - или поставить новых (слабые мутации)
      {# отличаются названием
        pol1=pol;pol1$get_=pol1$get;pol1$get=NULL;pol1$bef=NULL
        pol1=merge(pol1,xx,by='ed')
        pol1=pol1[(as.character(pol1$get)!=as.character(pol1$get_)),]
        pol1$get_=NULL}
      
      {# отличаются запаздыванием
        beff=c((1:7),14,21,28,neir$vhod$before,364)
        beff=c(beff,-beff);beff=as.data.frame(beff);beff$ed=1;beff=unique(beff)
        pol2=merge(pol,xx,by=c('ed','get','bef'))
        pol2=merge(pol2,beff,by='ed')
        pol2$before=pol2$before+pol2$beff;pol2$beff=NULL;rm(beff) }
      
      pol_=rbind(pol1,pol2)
      rm(pol1,pol2)
    }
    
    {#убрать теперь лишние строки
      o=(pol_$before<0);pol_[o,'before']=0
      o=((is.na(pol_$zap_vne))&(pol_$before<neir$vhod$before))
      pol_[o,'before']=neir$vhod$before
      pol_[(pol_$tip=='xz'),'zapazd']=NA
      pol_[((pol_$tip=='xs')&(is.na(pol_$zapazd))),'zapazd']=7
      for(nm in c('has','ed','n_pol','out','act','tip','zap_vne')) {pol_[,nm]=NULL}
      pol_=unique(pol_)}
    
    
    {#поставить хэши. и по ним новым присвоить номера входов
      pol_=pol_[(pol_$get!='upr'),]
      pol_$nn=(1:nrow(pol_))
      
      for (nn in pol_$nn){  #        nn=1
        pp=pol_[(pol_$nn==nn),]
        pp$nn=NULL;pp$nom_pol=NULL;pp$has=NULL;pp$n_poll=NULL  
        has=neuron$digest(pp)
        pol_[(pol_$nn==nn),'has']=has}
      
      {# найти старые номера входов, выявить новые
        polz=neir$opis_pol;max_npol=max(polz$n_pol)
        polz=unique(polz)
        
        has=unique(pol_[,c('has','get')])
        has$get=NULL;has$ed=1
        has=merge(has,polz[,c('has','n_pol')],all=TRUE)
        has=has[(!is.na(has$ed)),]
        has_=has[(is.na(has$n_pol)),]
        has=has[(!is.na(has$n_pol)),]
        
        if (nrow(has_)>0){
          has_$n_pol=(1:nrow(has_))+max_npol
          has=rbind(has,has_)}
        has$ed=NULL
        pol_=merge(pol_,has,by='has')
      }
      
      polv=pol_[(pol_$n_pol>max_npol),]
      if (nrow(polv)>0){
        polv$nn=NULL;polv$nom_pol=NULL;polv$act=1;polv$n_poll=NULL
        polv$out=paste('z',polv$n_pol,sep='_')
        polz=rbind(polz,polv)}
      neir$opis_pol=unique(polz)
      rm(polv,has,has_,polz)
    }
    # получили все изменения - теперь их попытаться проверить каждого по очереди
    
    
    {#проверить каждый вариант подстановки
      pols=neir$opis_pols
      poll=neir$opis_poll
      
      pol=pols[(pols$n_poll %in% fil$n_poll),]
      #pol$n_poll=NULL
      
      pol_$out=paste('x',pol_$nom_pol,sep='');
      pol_$zn=paste('z',pol_$n_pol,sep='_');pol_$act=1
      pol_=pol_[,c("nn","n_pol","nom_pol","has","zn","out","act",'n_poll') ]
      max_poll=max(poll$n_poll)
      
      for (nn in pol_$nn){   # nn=1
        polp=pol_[(pol_$nn==nn),];polp$nn=NULL
        pp=pol[(pol$n_poll %in% polp$n_poll),]
        
        pp=pp[(!(pp$nom_pol %in% polp$nom_pol)),]
        polp=rbind(pp,polp)
        has=polp[,c('has','act')];has$act=NULL
        has=neuron$digest(has)
        if (!(has %in% poll$has)){#новый вариант - добавить
          max_poll=max_poll+1
          polp$n_poll=max_poll
          pols=rbind(pols,polp)
          has=as.data.frame(has)
          has$n_poll=max_poll
          has$kol_pol=nrow(polp);has$act=1
          has$pred_poll=NA;has$plus_pol=NA
          poll=rbind(poll,has)
        }
      }
      neir$opis_pols=pols;neir$opis_poll=poll
    }
    
    {#теперь добавить в фильтры - инициировать нейрости
      fil=neir$all_filtr
      pp=poll[(!(poll$n_poll %in% fil$n_poll)),]
      vh=neir$vhodi  
      mas=vh[(vh$tip=='mas'),]
      pp=pp[,c('n_poll','act')]
      if (nrow(pp)>0){
        for (nm in mas$name){pp[,nm]=0}
        pp$act=NULL;pp$vib=1;pp$progr='5.0';pp$pred_row=NA;pp$poln=1
        o=order(-stat$kol_best);stat=stat[o,]
        nset=stat[1,'nset'];pp$pred_nset=nset
        nset=max(fil$nset)
        pp$nset=(1:nrow(pp))+nset
        fil=rbind(fil,pp)
        neir$all_filtr=fil  
      }
    }
  }
  print('5.0')
  
  {#убрать ошибку - непонятно откуда
    pols=neir$opis_pols
    pols=unique(pols)
    neir$opis_pols=pols}
  
  
  return(neir)
  pp_=1;plus_pol=1;new=1;poll1=1;poll2=1;npoll=1;bef=1;
  rm(fil,filtr,mas,pol,poll,pols,pp,pp_,ps,ps_,vh,has,n_poll,nm,o,poll_,stat,nsets,z)
  rm(dn,ff,ff_,rez,rezz,rr,k,mnset,nset,row,poll1,poll2,npoll,plus_pol,fil_,filtr2)
  rm(pol_,pols_,npol,new,kol_pol,bef,polp,xx,max_npol,max_poll,nn)
  
  rm(neir)    
}
#  пример запуска   neir=neuron$neir.plus_vhodi(neir)












#  добавить новые входы (5шт) и группы входов, и фильтры
neuron$neir.plus_vhodi_old <- function (neir) {
  
  poll=neir$opis_poll;pols=neir$opis_pols;pol=neir$opis_pol
  filtr=neir$all_filtr;
  stat=neir$all_stat;nsets=stat[(stat$act==4),'nset']
  
  #  перед созданием наборов - добавить поля (10 штук)
  { pol=neir$opis_pol
    pol_=neuron$neir.init_vhodi(10) 
    pol_=unique(pol_);pol_=pol_[(!(pol_$has %in% pol$has)),];
    pol_$n_pol=(max(pol$n_pol))+(1:nrow(pol_))
    pol_$out=paste('z',pol_$n_pol,sep='_');pol_$act=1
    pol=rbind(pol,pol_);rm(pol_)
    ###  neir$opis_pol=pol 
  }
  
  { # часть вторая - лучшие входы добавить в изменённом виде
    fil=filtr[(filtr$nset %in% nsets),]
    pols_=pols[(pols$n_poll %in% fil$n_poll),]
    pol_=pol[(pol$n_pol %in% pols_$n_pol),]
    vh=neir$vhodi;mas=vh[(vh$tip=='mas'),]
    #pol_2=pol_;
    for (npol in pol_$n_pol){ #  npol=1
      pp=pol_[(pol_$n_pol==npol)&(!is.na(pol_$n_pol)),]
      pp$n_pol=NA;
      #mas$r=runif(nrow(mas));o=order(mas$r);mas=mas[o,]
      #k=0
      for (nm in mas$name){pp_=pp
      if (pp_[,nm]>0) {
        pp_[,nm]=0;pol_=rbind(pol_,pp_)
      }}
      pp$before=max(round(pp$before/7)*7,neir$vhod$before)
      pol_=rbind(pol_,pp)
      if (!is.na(pp$zapazd)){
        pp$zapazd=round(pp$zapazd/7)*7;pol_=rbind(pol_,pp)}
    }
    pol_=pol_[(is.na(pol_$n_pol)),]
    
    #теперь оставить нужные
    if (nrow(pol_)>0) {
      pol_$n_pol=(1:nrow(pol_))
      pol_$out=NULL;pol_$act=NULL
      for (npol in pol_$n_pol){  #  npol=94
        pp=pol_[(pol_$n_pol==npol),];pp$n_pol=NULL;pp$has=NULL
        has=neuron$digest(pp);pp$has=has  # хэш-функция
        pp$n_pol=npol;
        
        if (!(has %in% pol$has)){
          pp$n_pol=(max(pol$n_pol))+1
          pp$out=paste('z',pp$n_pol,sep='_');pp$act=1
          pp$has=has
          pol=rbind(pol,pp);
        }}}
    neir$opis_pol=pol  # вот теперь запись в базу
  }
  
  
  
  { # новые наборы данных - отдельно новые поля. и отдельно комбинации всех лучших
    
    { # создаём уйму новых сочетаний - возможно неправильных, или уже были
      # сперва просто новые
      poll_=subset(pol,select='n_pol')
      poll_$pred_poll=0;poll_$plus_pol=poll_$n_pol;poll_$n_pol=NULL;poll_$kol_pol=1
      poll_=poll_[(!(poll_$plus_pol %in% poll$plus_pol)),]
      plus_pol=subset(poll_,select='plus_pol') #запомнить всех новых
      
      # теперь комбинации хороших = (к каждой хорошей + любую составляющую от любой хорошей)
      pp=unique(subset(filtr[(filtr$nset %in% nsets),],select=c('n_poll','nset')))
      pp=poll[(poll$n_poll %in% pp$n_poll),c('n_poll','kol_pol')]
      ps=pols[(pols$n_poll %in% pp$n_poll),]
      ps=unique(subset(ps,select='n_pol'))
      pp=merge(pp,ps);pp$pred_poll=pp$n_poll;pp$plus_pol=pp$n_pol;
      pp$kol_pol=pp$kol_pol+1;pp$n_poll=NULL;pp$n_pol=NULL
      poll_=rbind(poll_,pp)  #оба вместе
      
      # теперь к каждой хорошей - каждую новую
      pp$plus_pol=NULL;pp=unique(pp);pp=merge(pp,plus_pol)
      poll_=rbind(poll_,pp)  #оба вместе
      
      poll_$z=(1:nrow(poll_));poll_$act=1  # первичная нумерация
    }
    
    {#рассчитаем, что туда входит
      ps=pols;ps$pred_poll=ps$n_poll;ps$n_poll=NULL;ps$act=NULL
      #  сперва к чему добавляем
      ps=merge(ps,poll_,by='pred_poll')
      ps=subset(ps,select=c('z','n_pol','nom_pol','zn','out')) # z вместо n_poll
      #  теперь что добавляем
      ps_=poll_;ps_$n_pol=ps_$plus_pol;
      ps_$nom_pol=ps_$kol_pol;
      ps_$out=paste('x',ps_$kol_pol,sep='')
      ps_=subset(ps_,select=c('z','n_pol','nom_pol','out')) # z вместо n_poll
      pp=pol;pp$zn=pp$out;pp=pp[,c('n_pol','zn')]
      ps_=merge(ps_,pp,by='n_pol')
      # оба источника вместе
      ps=rbind(ps,ps_);ps$act=1
    }
    
    #ДОЛГИЙ БЛОК
    # перерасчитать хэш функции - по одинак алгоритму - а почему раньше неправильно - не знаю!!!
    for (npoll in poll$n_poll){ ##   npoll=2   npoll=3
      ps_=pols[(pols$n_poll==npoll),]
      #подсчёт хэш функции
      has=unique(ps_[,c('n_pol','zn')])
      has$zn=NULL
      has=neuron$digest(has);
      # poll[(poll$n_poll==npoll),'has']=has # почему-то не отрабатывает, подставляет NA
      #   поэтому подставляем в 3 шага:
      o=(poll$n_poll==npoll)
      poll1=poll[o,];poll1$has=has;poll2=poll[(!o),]
      poll=rbind(poll1,poll2)
    }
    
    
    
    #ОЧЕНЬ ДОЛГИЙ БЛОК!!!!!!!!
    #ищем уникальные варианты комбинаций входов. Те что новые - добавляем
    n_poll=max(poll$n_poll)
    for (z in poll_$z){   #  z=41
      ps_=ps[(ps$z==z),]
      #подсчёт хэш функции
      has=unique(ps_[,c('n_pol','zn')])
      has$zn=NULL
      has=neuron$digest(has);
      # далее поставить. если таких не было  
      if (!(has %in% poll$has)){
        pp_=poll_[(poll_$z==z),];pp_$has=has
        n_poll=n_poll+1
        pp_$n_poll=n_poll;ps_$n_poll=n_poll;pp_$z=NULL;ps_$z=NULL
        poll=rbind(poll,pp_);pols=rbind(pols,ps_)
      }}
    
    #сохранение
    poll=as.data.frame(as.data.table(poll));neir$opis_poll=poll
    pols=as.data.frame(as.data.table(pols));neir$opis_pols=pols
  }
  
  
  
  { # теперь создать фильтры
    {#добавить все новые варианты входов. без фильтров
      fil=poll[(!(poll$n_poll %in% filtr$n_poll)),]
      fil=fil[(fil$act==1),];fil$vib=1
      fil=fil[,c('n_poll','vib'),]
      vh=neir$vhodi;mas=vh[(vh$tip=='mas'),]
      for (nm in mas$name){fil[,nm]=0}
      # добавить число полей в выборке - для сортировки
      poll=poll[,c('n_poll','kol_pol')]
      fil=merge(fil,poll,by='n_poll')
      fil$r=runif(nrow(fil));
      o=order(fil$kol_pol,fil$r);fil=fil[o,];fil$r=NULL;fil$kol_pol=NULL
      fil$nset=max(filtr$nset)+(1:nrow(fil));fil$poln=1
      filtr=rbind(filtr,fil); #добавлены все новые варианты входов. без фильтров
    }
    
    {# теперь из лучших нейросетей сделать подфильтры, неполные данные
      fil=filtr[(filtr$nset %in% nsets),];filtr2=filtr[0,]
      if (nrow(fil)>0){ # если есть настроенные сети, которые можно подразмножить
        fil$poln=0;
        mnset=max(filtr$nset)
        rez=neir$all_rezult;rezz=NULL
        # для каждого размножаемого фильтра - выбрать точку данных, для дальнейшей работы
        for (nset in nsets){ #  на бодущее - переделать без цикла, чтобы быстрее работало
          rr=rez[(rez$nset==nset),];rr=rr[(!is.na(rr$yy)),]
          rr$r=runif(nrow(rr));o=order(rr$r);rr=rr[o,];rr=rr[1,c('nset','row')]
          if (is.null(rezz)){rezz=rr}  else {rezz=rbind(rezz,rr)}
        }
        dn=neir$dann;dn=dn[(dn$row %in% rezz$row),]
        #по полученным примерам в каждую нейросеть по 1 новому фильтру добавить
        
        for (nset in nsets){  #  Для каждой лучшей нейросети - 2 новых фильтра (фильтр, и всё кроме фильтра)
          mas$r=runif(nrow(mas));o=order(mas$r);mas=mas[o,];k=0
          row=rezz[(rezz$nset==nset),'row']
          ff=fil[(fil$nset==nset),];
          
          for (nm in mas$name){ #  nm='m1'
            z=max(ff[(ff$vib==1),nm]) # в плюсовой части этого фильтра ещё не было
            if ((z==0)&(k==0)){ # собственно новые фильтры
              z=dn[(dn$row==row),nm];
              #плюсовой фильтр - берём только z
              ff_=ff[(ff[,nm]==0),];ff_[,nm]=z
              mnset=mnset+1;ff_$nset=mnset;filtr2=rbind(filtr2,ff_) #просто фильтр
              # минусовой фильтр - берём всё, кроме z
              ff_=ff[(ff$vib==1),];ff_[,nm]=z;ff_$vib=-1;ff_=rbind(ff_,ff)
              mnset=mnset+1;ff_$nset=mnset;filtr2=rbind(filtr2,ff_) # предыдущее минус фильтр
              k=1 #признак. что по nset уже добавили фильтры
            }}}
      } # создали новые фильтры как подфильтрации старых лучших
      filtr=rbind(filtr,filtr2)  #думал брать не все, а некоторые
    }
    
    {# ещё вариант - каждому лучшему - по 2 последующих с наследуемой фильтрацией, случайным образом
      fil=filtr[(filtr$nset %in% nsets),]
      poll=neir$opis_poll;
      poll=poll[(poll$pred_poll %in% fil$n_poll),]
      poll$new_poll=poll$n_poll;poll$n_poll=poll$pred_poll;
      poll=poll[,c('new_poll','n_poll')]
      fil_=merge(fil,poll,by='n_poll')
      fil_=unique(fil_[,c('new_poll','n_poll','nset')])
      fil_$r=runif(nrow(fil_));o=order(fil_$nset,fil_$r);fil_=fil_[o,]
      if (nrow(fil_)>0){
        fil_$r=(1:nrow(fil_))
        ff=aggregate(x=subset(fil_,select=c('r')),by=subset(fil_,select=c('nset')), FUN="min" )
        ff$rr=ff$r;ff$r=NULL
        fil_=merge(fil_,ff,by='nset')
        fil_=fil_[(fil_$r<fil_$rr+5),]
        fil_=fil_[,c('new_poll','nset')] # создали - какой старой нейросети какое новое сочетание входов
        fil_$nnset=mnset+(1:nrow(fil_))
        fil=merge(fil,fil_,by='nset')
        fil$n_poll=fil$new_poll;fil$new_poll=NULL
        fil$nset=fil$nnset;fil$nnset=NULL
        filtr=rbind(filtr,fil) }
    }
    
    neir$all_filtr=as.data.frame(as.data.table(filtr))
  }
  
  return(neir)
  pp_=1
  rm(fil,filtr,mas,pol,poll,pols,pp,pp_,ps,ps_,vh,has,n_poll,neir,nm,o,poll_,stat,nsets,z)
  rm(dn,ff,ff_,rez,rezz,rr,k,mnset,nset,row,poll1,poll2,npoll,plus_pol,fil_,filtr2)
  rm(pol_,pols_,npol)
  
}
#  пример запуска   neir=neuron$neir.plus_vhodi (neir)







# выбрать статистику лучших и худших нейросетей - и только. 
neuron$neir.kol_good_best <- function(neir) {
  
  #errs_=neir$vhod$errs;
  #errs=c();for (nm in errs_){if (nm !='err'){errs=c(errs,nm)}} # всё кроме err
  errs=neir$vhod$proc;errs$zn=NULL
  errs=errs[(errs$name!='err'),]
  errs[(is.na(errs$proc)),'proc']=100
  
  rez=neir$all_rezult;stat=neir$all_stat
  
  # для ускорения - разделение данных
  if (is.null(rez$best)){rez$good=NA;rez$best=NA}
  rows=unique(rez[(is.na(rez$best)),'row'])
  o=(rez$row %in% rows);  ##  o=!o
  rez1=rez[(!o),];rez=rez[o,]
  
  if (nrow(rez)>0) { # блок расчёта good/best
    rez$good=0;rez$best=NULL;
    
    #вычисление nn один раз на все случаи
    o=order(rez$row);rez=rez[o,] # rez$err_sr - для случая одинаковости nm='err'  при минимальном отклонении
    rez$n=(1:nrow(rez))
    rr=aggregate(x=subset(rez,select=c('n')),by=subset(rez,select=c('row')), FUN="min" )
    rr$nn=rr$n;rr$n=NULL
    rez=merge(rez,rr,by='row');
    
    for (nm in errs$name){ # перебор всех статистик ошибки, рассчёт good    nm='err'
      proc=errs[(errs$name==nm),'proc']
      o=order(rez$row,rez[,nm],rez$nset);rez=rez[o,] 
      rez$n=(1:nrow(rez))
      rez$n=pmax(rez$nn-rez$n+3,0);
      rez$good=rez$good+proc*rez$n
    }
    rez$n=NULL;rez$nn=NULL;
    
    {#рассчёт best
      rr=aggregate(x=subset(rez,select=c('good')),by=subset(rez,select=c('row')), FUN="max" )
      rr$best=1
      rez=merge(rez,rr,by=c('row','good'),all=TRUE)
      rez[(is.na(rez$best)),'best']=0
    }
  }
  rez=rbind(rez,rez1)
  
  rezz=aggregate(x=subset(rez,select=c('good','best')),by=subset(rez,select=c('nset')), FUN="sum" )
  stat=merge(stat,rezz,by='nset',all=TRUE)
  o=(stat$act!=1)
  stat[o,'kol_good']=stat[o,'good'];stat[o,'kol_best']=stat[o,'best'];
  stat[(is.na(stat$kol_good)),c('kol_good','kol_best')]=0 # были и нету - всё по нулям
  stat$good=NULL;stat$best=NULL
  
  
  # уменьшить объём памяти
  rez=rez[(rez$good>0),]
  rez$nset=as.integer(rez$nset);rez$good=as.integer(rez$good);rez$row=as.integer(rez$row);
  rez=as.data.frame(as.data.table(rez))
  neir$all_rezult=rez;neir$all_stat=stat
  
  return(neir)
  rr=1
  rm(rez,rezz,rr,stat,errs,nm,o,rows,proc,neir,rez1)
}
#  пример запуска   neir=neuron$neir.kol_good_best(neir) 








# выбрать лучшие и худшие нейросети. Худшие удалить, и из фильтров
neuron$neir.best_rezults <- function(neir) {
  
  # выбрать статистику лучших и худших нейросетей - и только. 
  # neir=neuron$neir.kol_good_best(neir) 
  
  stat=neir$all_stat;
  nsets=as.integer(stat[(stat$act!=3),'nset'])
  
  #почистить таблицы результатов
  rez=neir$all_rezult;rez=rez[(rez$nset %in% nsets),]  
  neir$all_rezult=rez;
  
  # подчистить лишние строки по массивам
  mass=neir$all_mass;mass=mass[(mass$nset %in% nsets),]
  neir$all_mass=mass
  
  #в фильтры ещё проставить активности - по результатам выкидывания
  stat=stat[,c('nset','act')]
  filtr=neir$all_filtr;filtr=merge(filtr,stat,by='nset',all=TRUE);
  filtr=filtr[(!is.na(filtr$n_poll)),]
  fil=filtr[(!is.na(filtr$act)),]
  fil$bad=1*(fil$act==3)
  fil=aggregate(x=subset(fil,select=c('bad')),by=subset(fil,select=c('n_poll')), FUN="min" )
  
  #убрать лишние n_poll
  poll=neir$opis_poll
  poll=merge(poll,fil,by='n_poll',all=TRUE)
  poll[(is.na(poll$bad)),'bad']=0
  poll[(poll$bad==1),'act']=3;poll$bad=NULL
  neir$opis_poll=poll
  
  #если нейросеть ещё не смотрели - удалить заранее
  filtr=merge(filtr,fil,by='n_poll',all=TRUE)
  filtr[(is.na(filtr$bad)),'bad']=0
  filtr=filtr[((!is.na(filtr$act))|(filtr$bad==0)),]
  filtr$bad=NULL;filtr$act=NULL
  neir$all_filtr=filtr
  
  return(neir)
  rm(fil,filtr,poll,rez,stat,nsets,mass)
  
}
# пример запуска   neir=neuron$neir.best_rezults(neir) 







#запись на диск - на скору руку, без обработки
#neuron$neir.save_to_hist <- function(neir,nname='') {
#  #name='neiroset';vid='poln',nname=''
#  #dbPath <- myPackage$trs.file_adres(name,vid,nname)
#  dbPath=paste('./data/neuron/neir',nname,' .csv',sep='')
#  pack=myPackage$neir.pack(neir);
#  write.csv2(x = pack, file = dbPath, fileEncoding = "WINDOWS-1251") 
#}
# пример  neuron$neir.save_to_hist(neir);neuron$neir.save_to_hist(neurs,'_neurs');





#запись на диск - кусочками по каждому фрейму (кроме данных)
neuron$neir.save_to_hist <- function(neir,nname='neir') {
  
  stat=NULL;
  vh=neir$vhodi;
  vhodi=as.character(vh[(vh$tip %in% c('dat','row','ogr','yy'))&(!is.na(vh$nm)),'nm_'])
  if (neir$vhod$kol_upr==0){vhodi=c(vhodi,'min_err')}
  if (neir$vhod$kol_upr>0){vhodi=c(vhodi,'upr0','upr1')}
  mas=vh[(vh$tip=='mas'),]
  
  names=names(neir)
  for (nm in names){ #   nm="all_rezult"
    zz=neir[nm];for(dd in zz){};rm(zz)
    
    if (nm=='dann'){dd=dd[,c(as.character(mas$name),vhodi)]}
    
    if (nm=="all_rezult"){dd=dd[(dd$good>0),]} # отсекать все ненужные
    
    nm_=as.data.frame(nm);nm_$frame=1
    #если не фрейм - изменить
    if (!is.data.frame(dd)){
      nm_$frame=0
      pack=myPackage$neir.pack(dd);
      dd=as.data.frame(pack)
      dd$id=1
    }
    dbPath=paste('./data/neuron/',nname,'__',nm,'.csv',sep='')
    write.csv2(x = dd, file = dbPath, fileEncoding = "WINDOWS-1251") 
    
    if (is.null(stat)){stat=nm_}else{stat=rbind(stat,nm_)}
  }
  
  dbPath=paste('./data/neuron/',nname,'.csv',sep='')
  write.csv2(x = stat, file = dbPath, fileEncoding = "WINDOWS-1251") 
  
  rm(dd,nm_,nm,stat,dbPath,names,nname,pack,vh,mas,vhodi,neir)
}
# пример   neuron$neir.save_to_hist(neir,nname='_zzzzz')





#  записать исходный neuron - только данные, без процедур
neuron$neir.neuron_to_hist <- function(nname='') {
  
  if (nname!='neuron'){nname=paste('neuron',nname,sep='')}
  
  nn=list()
  dd=neuron$dannie;if (!is.null(dd)) {nn$dannie=dd}
  dd=neuron$vhod;if (!is.null(dd)) {nn$vhod=dd}
  dd=neuron$vhodi;if (!is.null(dd)) {nn$vhodi=dd}
  dd=neuron$mass;if (!is.null(dd)) {nn$mass=dd}
  
  neuron$neir.save_to_hist(nn,nname);
  rm(nn,nname,dd)
}
# пример запуска   neuron$neir.neuron_to_hist('neuron')








# просто чтение с диска 
neuron$neir.load_from_hist_sobstv <- function(nname='neir') {
  
  dbPath=paste('./data/neuron/',nname,'.csv',sep='')
  if (!is.null(dbPath)){if (file.exists(dbPath)){
    stat <- read.csv2(dbPath, header = TRUE,fileEncoding = "WINDOWS-1251")[, -1]
    if(ncol(stat)==0){
      stat <- read.csv(dbPath, header = TRUE,fileEncoding = "WINDOWS-1251")[, -1]}
  }}
  
  neir=list()
  for (nm in stat$nm){  # перебор всех составляющих
    
    dbPath=paste('./data/neuron/',nname,'__',nm,'.csv',sep='')
    if (!is.null(dbPath)){if (file.exists(dbPath)){
      # если файл реально существует
      dd <- read.csv2(dbPath, header = TRUE,fileEncoding = "WINDOWS-1251")[, -1]
      if(ncol(dd)==0){
        dd <- read.csv(dbPath, header = TRUE,fileEncoding = "WINDOWS-1251")[, -1]
      }
      
      if (stat[(stat$nm==nm),'frame']==0){ # если это не фрейм
        pack=as.character(dd$pack);dd=myPackage$neir.unpack(pack);rm(pack)
      }else{dd=as.data.frame(as.data.table(dd))  }
      
      if (nm=="dann"){neir$dann=dd}
      if (nm=="dannie"){neir$dannie=dd}
      if (nm=="mass"){neir$mass=dd}
      if (nm=="vhod"){neir$vhod=dd}
      if (nm=="vhodi"){neir$vhodi=dd}
      if (nm=="opis_pol"){neir$opis_pol=dd}
      if (nm=="opis_poll"){neir$opis_poll=dd}
      if (nm=="opis_pols"){neir$opis_pols=dd}
      if (nm=="all_filtr"){neir$all_filtr=dd}
      if (nm=="all_param"){neir$all_param=dd}
      if (nm=="all_pols"){neir$all_pols=dd}
      if (nm=="all_mass"){neir$all_mass=dd}
      if (nm=="all_str"){neir$all_str=dd}
      if (nm=="all_stat"){neir$all_stat=dd}
      if (nm=="all_rezult"){neir$all_rezult=dd}
      if (nm=="all_itogi"){neir$all_itogi=dd}
      if (nm=="errors"){neir$errors=dd}
      if (nm=="dann"){neir$dann=dd}
    }}
  }
  
  return(neir)
  rm(dd,stat,dbPath,name,neir,nm,nname)
}
# пример запуска   neir=neuron$neir.load_from_hist_sobstv('neuron') 






#чтение с диска именно нейросети - обратная к neuron$neir.save_to_hist
neuron$neir.load_from_hist <- function(nname='') {
  
  if (nname==''){nname='neir'}
  
  neir=neuron$neir.load_from_hist_sobstv(nname) #  просто чтение с диска 
  
  { # ликвидация ошибки
    mass=neir$all_mass
    mass=unique(mass[,c("nset","zn","fun","isp")])
    neir$all_mass=mass;rm(mass)
  }
  
  #далее обработка до состояния нейросети
  
  # исправил - активность обнулить всегда
  #if (is.null(neir$dann) | is.null(neir$all_rezult))
  {
    #исправление - всех сделать активными (=в настройку) кроме отвергнутых по качеству
    stat=neir$all_stat;
    stat[(stat$act %in% c(1,2)),'act']=1; #кто в момент записи был в настройке
    stat[((stat$kol_best>0)&(!is.na(stat$kol_best))),'act']=1; #кто был из числа лучших
    ##  stat[(stat$kol_x==0),'act']=1; убрал # если не было входов - чтобы не терять наблюдения хоть как-то
    stat[(stat$act==4),'act']=3; #кто ни разу не лучший - на вылет
    
    for (nm in neir$vhod$errs){if (nm!='err'){stat[(stat$act==3),nm]=NA}} #ПОЧИСТИТЬ СТАТИСТИКИ
    neir$all_stat=stat
  }
  
  {#Сравнение старых и новых данных
    dann=neuron$dannie;
    dann=dann[(!is.na(dann$row)),]
    dd=neir$dann;dd$min_err=NULL
    if (nrow(dann)!=nrow(dd)){neir$dann=NULL} # если данные дополнились - дальше вперёд
    yy='yy';if (neir$vhod$kol_upr>0){yy='upr0'}
    dd=dd[(!is.na(dd[,yy])),]
    dann=dann[(!is.na(dann[,yy])),]
    if (nrow(dann)!=nrow(dd)){ # если данные дополнились - новые реалии
      neir$dann=NULL
      # for (nm in neir$vhod$errs){if (nm!='err'){neir$all_stat[,nm]=NA}} #ПОЧИСТИТЬ СТАТИСТИКИ
    } 
    
    nms=names(dd);dd$ss='';dann$s=''
    for (nm in nms){ 
      if (!(nm %in% c('row','yy'))){
        dd$ss=paste(dd$ss,as.character(dd[,nm]),sep=',')
        dann$s=paste(dann$s,as.character(dann[,nm]),sep=',')
      }}
    dann=dann[,c('row','s')];
    dd=dd[,c('row','ss')]
    
    dd=merge(dd,dann,by='row')
    dd=dd[(dd$s!=dd$ss),]
    if (nrow(dd)>0){# если изменился порядок следования строк данных
      neir$dann=NULL;neir$all_rezult=NULL}
  }
  
  { #ОСТАЛОСЬ - СРАВНИТЬ СТРУКТУРУ МАССИВОВ
    vh1=neuron$vhodi;vh2=neir$vhodi
    vh=merge(vh1,vh2,by=c('nm','nom','nm_','tip'))
    
    if (nrow(vh)!=nrow(vh1)) { #менять надо всё!
      neir=neuron$neir.init_neir() } else{
        
        # теперь проверка одинаковости массивов
        mas1=neuron$mass;mas2=neir$mass;nms=names(mas1)
        mm=merge(mas1,mas2,by=nms)
        if (nrow(mm)!=nrow(mas1)){# реально надо менять
          mas1$nom_n=mas1$nom;mas1$nom=NULL
          mm=merge(mas1,mas2,by=c('nm_','name','zn','is'),all=TRUE)
          mm$zn=mm$nom;mm$nom=NULL 
          mass=neir$all_mass
          ms=mass[(mass$zn==1),];ms$fun=NULL;ms$zn=NULL;ms$is=NULL
          mass_=merge(mm,ms);mass_$nm_=NULL;mass_$isp=NULL;mass_$is=NULL
          mass_=merge(mass,mass_,by=c('nset','zn'),all=TRUE)
          
          ### pmas$isp= 1=есть данн, в прогноз, 2=мало данных, настраивать но не прогноз
          ### 0=данных нет вообще, 3=данные есть, но не пошли на вход
          ### временно $isp=NA не исправляю - смотрю что будет
          mass_[(is.na(mass_$isp)),'isp']=3
          
          ms=mass_[(!is.na(mass_$fun)),] ;ms$kol=1
          ms=aggregate(x=subset(ms,select=c('kol','fun')),
                       by=subset(ms,select=c('nset','name')), FUN="sum" )
          ms$ff=ms$fun/ms$kol;ms$fun=NULL;ms$kol=NULL;
          
          mass_=merge(mass_,ms,by=c('nset','name'),all=TRUE)
          o=((is.na(mass_$fun))&(!is.na(mass_$ff)))
          mass_[o,'fun']=mass_[o,'ff']
          mass_$zn=mass_$nom_n
          mass_$nom_n=NULL;mass_$ff=NULL;mass_$name=NULL
          neir$all_mass=mass_
          neir$mass=neuron$mass
          
          #а теперь ещё и в фильтрациях заменить
          fil=neir$all_filtr
          mm=mm[(!is.na(mm$zn)),c('zn','nom_n')]
          mm_=mm[(mm$zn==1),];
          mm_[,c('zn','nom_n')]=0;mm=rbind(mm,mm_)
          mm_[,c('zn','nom_n')]=-1;mm=rbind(mm,mm_)
          mm=unique(mm)
          vh=neir$vhodi;mas=vh[(vh$tip=='mas'),]
          for(nm in mas$name){
            fil$zn=fil[,nm]
            fil=merge(fil,mm,by='zn')
            fil[,nm]=fil$nom_n;fil$nom_n=NULL;fil$zn=NULL
          }
          neir$all_filtr=fil
          
          # теперь ещё и параметры выборки полей
          pol=neir$opis_pol
          for(nm in mas$name){
            pol$zn=pol[,nm]
            pol=merge(pol,mm,by='zn')
            pol[(pol$zn!=pol$nom_n),'has']=NA
            pol[,nm]=pol$nom_n;pol$nom_n=NULL;pol$zn=NULL
          }
          neir$opis_pol=pol
          
        }
        mass=1;mass_=1;ms=1
        rm(mas1,mas2,mm,mass,mass_,ms)
      }
  }
  neir$vhod$pzd=neuron$vhod$pzd
  
  
  # на случай, если в результате раньше был иной итог (до обновления данных)
  if (is.null(neir$dann)){ neir=neuron$neir.init_dann(neir)  }
  
  dn=neir$dann;rez=1
  if ((!is.null(dn))&(neir$vhod$kol_upr==0)){
    dn=dn[,c('row',yy)];
    dn$yy_=dn[,yy];dn[,yy]=NULL
    rez=neir$all_rezult
    if (!is.null(rez)){
      rez=merge(rez,dn,by='row')
      rez=rez[((rez$yy==rez$yy_)|((is.na(rez$yy))&(is.na(rez$yy_)))),]
      rez=rez[(!is.na(rez$row)),];rez$yy_=NULL;neir$all_rezult=rez}}
  
  
  if (neuron$vhod$before!=neir$vhod$before) { # если сменили срок запаздывания
    neir$vhod$before=neuron$vhod$before;bef=neuron$vhod$before
    pol=neir$opis_pol
    poll=neir$opis_poll
    pols=neir$opis_pols
    apols=neir$all_pols
    fil=neir$all_filtr
    param=neir$all_param
    mass=neir$all_mass
    str=neir$all_str
    stat=neir$all_stat
    itog=neir$all_itogi
    
    vh=neir$vhodi;vh=vh[(vh$tip %in% c('xz','xs'))&(!is.na(vh$zap_vne)),]
    pol[(pol$before+pol$bef<bef),'act']=0
    pol[(pol$get %in% vh$nm_),'act']=1
    pols[(pols$n_pol %in% pol[(pol$act==0),'n_pol']),'act']=0
    poll[(poll$n_poll %in% pols[(pols$act==0),'n_poll']),'act']=0
    pols[(pols$n_poll %in% poll[(poll$act==0),'n_poll']),'act']=0
    
    fil=fil[(fil$n_poll %in% poll[(poll$act>0),'n_poll']),]
    stat=stat[(stat$nset %in% fil$nset),]
    stat=stat[((stat$kol_good>0)|((stat$kol_x==0)&(stat$kol_dann>nrow(neir$dann)/10))),]
    stat$act=1
    fil=fil[(fil$nset %in% stat$nset),]
    poll=poll[(poll$n_poll %in% fil$n_poll),]
    pols=pols[(pols$n_poll %in% fil$n_poll),]
    pol=pol[(pol$n_pol %in% pols$n_pol),]
    apols=apols[(apols$nset %in% stat$nset),]
    mass=mass[(mass$nset %in% stat$nset),]
    param=param[(param$nset %in% stat$nset),]
    str=str[(str$nset %in% stat$nset),]
    itog=itog[(itog$nset %in% stat$nset),]
    
    neir$opis_pol=as.data.frame(as.data.table(pol))
    neir$opis_poll=as.data.frame(as.data.table(poll))
    neir$opis_pols=as.data.frame(as.data.table(pols))
    neir$all_pols=as.data.frame(as.data.table(apols))
    neir$all_filtr=as.data.frame(as.data.table(fil))
    neir$all_param=as.data.frame(as.data.table(param))
    neir$all_mass=as.data.frame(as.data.table(mass))
    neir$all_str=as.data.frame(as.data.table(str))
    neir$all_stat=as.data.frame(as.data.table(stat))
    neir$all_itogi=as.data.frame(as.data.table(itog))
    neir$all_rezult=NULL
    neir$vhod$row_before=neuron$vhod$row_before
    rm(apols,fil,itog,mass,param,pol,poll,pols,stat,str,vh,bef)
  }
  
  
  {#выявить положительность значений
    dn=neir$dann
    dn=dn[(!is.na(dn$yy)),]
    neir$vhod$plus_dann=0
    if (min(dn$yy)>=0){neir$vhod$plus_dann=1}
  }
  
  return(neir)
  rez=1;vh=1;vh1=1;vh2=1;fil=1;mm_=1;mas=1;o=1;pol=1;yy=1;dd=1;stat=1;nm=1;nname=1;dann=1;nms=1;dn=1;
  apols=1;fil=1;itog=1;mass=1;param=1;pol=1;poll=1;pols=1;stat=1;str=1;vh=1;bef=1;
  rm(dd,stat,neir,rez,nm,nname,dann,nms,vh,vh1,vh2,dn,fil,mm_,mas,o,pol,yy) 
  rm(apols,itog,mass,param,poll,pols,str,bef)
}   
# пример запуска   neir=neuron$neir.load_from_hist('')








#  активности
#  0=нет данных. либо не рассматривалось ещё
#  1=надо будет настраивать
#  2=сейчас находится в настройке (было=9)
#  3=вычеркнуто по качеству настройки
#  4=настроено, хорошее качество




















#################################################################################
# далее старые программы, на разборку

















# настройка по итерациям всех нейросетей множества - восстановление программы, возможны забытые фрагменты
neural$neir.nastr_all<- function (neir) { 
  neir$all_vibor$ttime=0 #обнуление текущих трат времени на настройку
  err_ish=neir$vhod$error
  dann=neir$dann;dann=dann[(dann$kol==1),] #прогнозные не нужны
  struct=neir$param_str;vibor=neir$all_vibor;pmas=neir$param_mas
  if (is.null(vibor$radius)){vibor$radius=0.1}
  vibor$radius=pmin(10*vibor$radius,0.1);vibor$max_y=neir$vhod$max_y
  max_time=neir$vhod$max_time #сколько осталось
  
  #сортировка - в каком порядке рассчитывать нейросети
  if (is.null(vibor$error_rez)){vibor$error_rez=NA;neir$all_vibor=vibor}
  o=order(!is.na(vibor$error_rez),-vibor$error_rez);vibor=vibor[o,]
  nsets=vibor[(!is.na(vibor$neiroset)),'neiroset']
  
  for (nm in c("max_time","time","kol_step","ttime","err_sr","err_95","error","error_rez","ss_err")){
    if (!(nm %in% names(vibor))){vibor[,nm]=NA} #инициировать поля, пока без значений
  }    
  
  #последовательно подстройка каждой нейросети
  for (nset in nsets){  #   nset=1
    str=struct[(struct$neiroset==nset),];
    vib=vibor[(!is.na(vibor$neiroset)),]
    vib=vib[(vib$neiroset==nset),]
    mas=pmas[(pmas$neiroset==nset),]
    dn=dann[(dann$neiroset==nset),]
    vib$max_time=max_time
    if (is.na(vib$time))  {vib$time=0}
    if (is.na(vib$kol_step)){vib$kol_step=0}
    
    if (nrow(dn)>10){ # проверка для случаев, когда первая нейросеть уже фактически пуста, но не убирается     
      #собственно настройка
      rez= neural$neir.nastr_nset(str,vib,mas,dn) 
      #вернуть значения
      vib=rez$vib;str=rez$str;mas=rez$mas
      vib$time=vib$time+vib$ttime
      
      #получить статистики
      rez=neural$neir.err(str,vib,mas,dn,is_rez=TRUE);
      dn=rez$dann
      dn$error=dn$err**2;dn$error_rez=dn$error*dn$rez;dn$ss_err=dn$rez*(dn$err_sr**2)
      
      err=aggregate(x=subset(dn,select=c('error','error_rez','ss_err')),
                    by=subset(dn,select=c('neiroset','err_sr','err_95')), FUN="sum" )
      vib$error=NULL;vib$error_rez=NULL;vib$ss_err=NULL;vib$err_sr=NULL;vib$err_95=NULL
      vib=merge(vib,err,by='neiroset')
      
      
      #запись итогов временно
      max_time=max_time-vib$ttime
      struct=rbind(struct[(struct$neiroset!=nset),],str)
      vibor=rbind(vibor[((vibor$neiroset!=nset)|(is.na(vibor$neiroset))),],vib)
      pmas=rbind(pmas[(pmas$neiroset!=nset),],mas)
    }
  }
  
  #нет нейросети - нет и ошибки, чтобы не суммировать
  vibor[(is.na(vibor$neiroset)),c('error_rez','ss_err','err_sr','err_95','error')]=0
  #общие статистики
  err=aggregate(x=subset(vibor,select=c('error_rez','ss_err','time','ttime','kol_step')),
                by=subset(vibor,select=c('max_y')), FUN="sum" )
  vibor$max_y=NULL
  
  #запись итогов постоянно
  neir$param_str=struct;neir$all_vibor=vibor;neir$param_mas=pmas
  
  #запись общих статистик
  vhod=neir$vhod;vhod$error=err$error_rez;vhod$ss_err=err$ss_err;
  vhod$time=err$time;vhod$ttime=err$ttime;vhod$step=err$kol_step;
  vhod$good=1;if (!is.null(err_ish)){if (!is.na(err_ish)){
    if (vhod$error>err_ish*0.99){vhod$good=0}}}
  if (nrow(neir$all_vibor)==1){vhod$good=0}
  
  vhod$dat_time=as.character(Sys.time()) #постановка даты и времени конца настройки
  neir$vhod=vhod
  
  return(neir)
  rm(dann,dn,err,mas,pmas,str,struct,vib,vibor,max_time,neir,nset,nsets,rez,vhod,nm,o,err_ish)
}
# пример   neir=neural$neir.nastr_all(neir)










# результат настройки по всему пулу нейросетей
neural$neir.rez_all <- function (neir) {
  
  #зазъединение нейросети и данных для неё
  dann=neir$dann;#neir$dann=NULL
  
  vibor=neir$all_vibor;vibor$max_y=neir$vhod$max_y # максимум, для статистики
  vibor=vibor[(!is.na(vibor$neiroset)),]
  
  nsets=unique(vibor$neiroset)
  mas_zn=neir$param_mas;struct=neir$param_str;
  mas_=mas_zn;mas_$neiroset=NULL;mas_$fun=NULL;mas_=unique(mas_)
  
  res=NULL
  # надо выбрать по очереди все нейросети
  for (nset in nsets) { #    nset=5
    vib=vibor[(vibor$neiroset==nset),];
    mas=mas_zn[(mas_zn$neiroset==nset),];
    o=order(mas$zn);mas=mas[o,] #сортировка нужна - иначе врёт
    str=struct[(struct$neiroset==nset),];
    dn=dann[(dann$neiroset==nset),]
    
    if (nrow(dn)>0){
      # собственно итоги по одной нейросети
      dnn=neural$neir.err(str,vib,mas,dn,is_rez=TRUE);
      dn=dnn$dann
      #приписка к предыдущим результатам
      if (is.null(res)){res=dn}else{res=rbind(res,dn)}
    }
  }
  res=res[(res$rez==1),];res$rez=NULL # только актуальные выходы
  return(res)
  rm(dann,dn,mas,mas_,mas_zn,res,str,struct,vib,vibor,nset,nsets,dnn,neir)
}
# пример запуска  result=neural$neir.rez_all(neir) 







#Запись нейросети в базу, увеличение номера версии
#запись нейросети в полную и сокращённую структуры, и плюс прогноз - сперва создать. потом записать
neural$neir.save_to_hist <- function(neir,nname='') {
  #nname=paste(neir$vhod$name,neir$vhod$before,sep='_')
  
  #взять старую историю нейросетей и сокращений, и прогнозов
  neir_hist=myPackage$trs.dann_load('neiroset','poln',nname)
  neir_hist_sokr=myPackage$trs.dann_load('neiroset','sokr',nname)
  results=myPackage$trs.dann_load('neiroset','results',nname)
  
  id=neir$vhod$id
  # если ID ещё неизвестен
  if (is.na(id)){
    if(is.null(neir_hist_sokr)){id=1}else{
      id=max(neir_hist_sokr$id)+1;if (is.na(id)){id=1}}
    neir$vhod$id=id}
  neir$vhod$versia=neir$vhod$versia+1;
  
  #результаты настройки
  result=NULL;
  if (!is.null(neir$dann)){
    result=neural$neir.rez_all(neir)
    result$id=neir$vhod$id}
  #разъединение нейросети и данных для неё
  dann=neir$dann;neir$dann=NULL
  
  #создание сокращения от нейросети
  neir_sokr=neir$vhod
  neir_sokr$mas=NULL;neir_sokr$xz=NULL;neir_sokr$xs=NULL
  neir_sokr=as.data.frame(neir_sokr)
  neir_sokr$activ=1;neir_sokr$kol=NA;
  
  #приписать сокращение (с активностью)
  if(is.null(neir_hist_sokr)){neir_hist_sokr=neir_sokr}else{
    #  neir_sokr$activ=activ;
    neir_hist_sokr[(neir_hist_sokr$id==id),'activ']='0';
    neir_hist_sokr=myPackage$sliv(neir_hist_sokr,neir_sokr) }
  
  #создание строки - запакованной нейросети
  neir_h=data.frame( id=array(id,1))
  neir_h$pack=myPackage$neir.pack(neir);
  
  #приписать запакованную нейросеть (если пусто - вписать)
  if(is.null(neir_hist)){neir_hist=neir_h}else{
    neir_hist=neir_hist[(neir_hist$id!=id),];
    neir_hist=rbind(neir_hist,neir_h)}
  
  #объединить результаты, без всяких уменьшений
  if (is.null(results)){results=result}else{
    results=results[(results$id!=id),]
    results$dat=as.Date(results$dat);result$dat=as.Date(result$dat)
    results=rbind(results,result)}
  
  #запись данных в директорию нейросетей
  myPackage$trs.Data_save(neir_hist,'neiroset','poln',TRUE,nname) 
  myPackage$trs.Data_save(neir_hist_sokr,'neiroset','sokr',TRUE,nname) 
  myPackage$trs.Data_save(results,'neiroset','results',TRUE,nname) 
  
  #    if (!(is.null(dann))){ # &(activ==1)){
  #      neir_progn=myPackage$trs.dann_load('progn','poln') #все старые прогнозы
  #      neir_stat=myPackage$trs.dann_load('progn','stat') #все старые прогнозы
  
  #      if (activ==1){
  #        progn=neural$neir_prognoz_narabot_stat(neir,dd_all) #наработка прогноза
  #        stat=progn$stat;progn=progn$progn
  #        neir_progn=neural$neir_progn_pripiska(neir_progn,progn)    #приписать прогнозы 
  #        neir_stat=neir_stat[(neir_stat$id!=id),]    
  #        neir_stat=myPackage$sliv(neir_stat,stat)
  #      } else{neir_progn=neir_progn[(neir_progn$id!=id),]
  #      neir_stat=neir_stat[(neir_stat$id!=id),]}
  #      myPackage$trs.Data_save(neir_progn,'progn','poln',TRUE) #запись прогнозов обратно
  #      myPackage$trs.Data_save(neir_stat,'progn','stat',TRUE) #запись статистики обратно
  #    }
  
  #обратно ввод данных в нейросеть
  neir$dann=dann
  
  return(neir)
  
  rm(neir_h,neir_hist,neir_hist_sokr,neir_sokr,results,dann,id,neir,nname,result)
}
#  пример запроса:  neir=neural$neir.save_to_hist(neir)






















# изменение нейросети путём усложнения
neural$neir.uslojn <- function (neir) {  
  
  {#создать все переменные, чтобы затем скопом убить
    get=1;iz=1;izmen=1;mas=1;og=1;ogr=1;vb=1;vh=1;vib=1;izm=1;kk=1;name=1;nm=1;o=1;op=1;oper=1;
    po=1;str=1;str_=1;strp=1;ogr1=1;ogr2=1;res=1;str2=1;kol=1;nset=1;z=1;}
  
  
  neir$dann=NULL
  neir$vhod$id_izm='-'
  vib=neir$all_vibor;ogr=neir$all_ogr
  vh=neir$vhodi;mas=vh[(vh$tip=='mas'),]
  
  # ошибки суммарные
  vib$kk=vib$error_rez;
  if (nrow(vib[(is.na(vib$kk)),])>0){vib[(is.na(vib$kk)),'kk']=0};vib$k=vib$kk
  o=order(-vib$oper);vib=vib[o,]
  for (op in vib$oper){
    o=(vib$oper==op);po=vib[o,'pred_oper'];kk=vib[o,'kk']
    if (po<op){vib[(vib$oper==po),'kk']=vib[(vib$oper==po),'kk']+kk}
  }
  vb=vib[,c('oper','kk')];ogr=merge(ogr,vb,by='oper')
  
  
  #перечень возможных изменений по склейке
  izm='skleika';izm=as.data.frame(izm);izm$neiroset=NA;izm$oper=NA;izm$name=NA;izm$kol=1
  izmen=izm;izmen$izm='-' #оставить вариант - ничего не делать
  
  #мутация ограничений по датам - кратно 7
  izm=izmen;izm$izm='mut_ogr_p7';izm$kol=max(vib$kk);izmen=rbind(izmen,izm)
  
  #все варианты склеек
  iz=izm;izm=izm[0,]
  for (op in ogr$oper){for(nm in mas$name){
    if ((ogr[(ogr$oper==op),nm]==0)&(!is.na(ogr[(ogr$oper==op),nm]))){
      iz$name=nm;iz$oper=op;iz$kol=ogr[(ogr$oper==op),'kk']
      izm=rbind(izm,iz)
    }}}
  #sum(izm$kol)
  if (nrow(izm)>0){izm$kol=izm$kol/nrow(izm)}
  izmen=rbind(izmen,izm)
  
  # пречень изменений по усложнению нейросети
  izm=vib[(!is.na(vib$neiroset)),];izm=izm[(izm$neiroset>1),]
  izm=izm[,c('neiroset','k')]
  if (nrow(izm)>0){
    izm$izm='neiroset';izm$name=NA;izm$oper=NA;
    izm$kol=izm$k/nrow(izm);izm$k=NULL
    izmen=rbind(izmen,izm)}
  
  # перечень изменений по изменению нейрона в нейросети
  if (nrow(izm)>0){izm$izm='mut_neir';izm$kol=2*izm$kol;izmen=rbind(izmen,izm)}
  
  # пречень изменений по раздвоению (было раздвоение на выборке - убрать)
  izm=vib[(vib$razdvoen==1),];izm=izm[(izm$oper>0),]
  izm=subset(izm,select=c('oper','kk'))
  if (nrow(izm)>0){
    izm$izm='razdvoen';izm$name=NA;izm$neiroset=NA;izm$kol=izm$kk/nrow(izm)
    izm$kk=NULL;izmen=rbind(izmen,izm)}
  
  #варианты мутации, по ограничениям
  if(nrow(ogr)>0){
    izm=NULL
    for (nm in mas$name){  
      og=subset(ogr,select=c('oper',nm,'kk'));og$zn=og[,nm];og[,nm]=NULL;
      og$name=nm
      if(is.null(izm)){izm=og}else{izm=rbind(izm,og)} }
    izm$izm='mut_ogr';izm$neiroset=NA;
    izm=izm[(izm$zn>0)&(!is.na(izm$zn)),];
    if (nrow(izm)>0) {
      izm$zn=NULL;izm$kol=5*izm$kk/nrow(izm);izm$kk=NULL
      izmen=rbind(izmen,izm)}}
  
  #вариант перепутать входы
  if(nrow(ogr)>1){
    izm=izmen[(izmen$izm=='-'),];izm$izm='ogr_random'
    izm$kol=max(vib$kk)
    izmen=rbind(izmen,izm) }
  
  #мутации, что именно идёт на выход - постановка первичных полей
  izm=subset(ogr,select=c('oper','get','kk'));
  if (nrow(izm)>0){
    vh=neir$vhodi;vh=vh[(vh$tip=='xz'),]
    if (nrow(vh)>0){
      get=subset(vh,select=c('nm_'));get$kol=1;get$name=get$nm_;get$nm_=NULL
      izm$izm='mut_get';izm$neiroset=NA;izm$kol=1
      izm=merge(izm,get,by='kol');
      izm=izm[(izm$get!=izm$name),];
      if (nrow(izm)>0){
        izm$get=NULL;izm$kol=10*izm$kk/nrow(izm);izm$kk=NULL
        izmen=rbind(izmen,izm)}}}
  
  #мутации, что именно идёт на выход - постановка суммируемых полей 
  izm=subset(ogr,select=c('oper','get','kk'));
  if (nrow(izm)>0){
    vh=neir$vhodi;vh=vh[(vh$tip=='xs'),]
    if (nrow(vh)>0){
      get=subset(vh,select=c('nm_'));get$kol=1;get$name=get$nm_;get$nm_=NULL
      izm$izm='mut_gets';izm$neiroset=NA;izm$kol=1
      izm=merge(izm,get,by='kol');izm=izm[(izm$get!=izm$name),];
      if (nrow(izm)>0){
        izm$get=NULL;izm$kol=10*izm$kk/nrow(izm);izm$kk=NULL
        izmen=rbind(izmen,izm)
      }}}
  
  #варианты мутации, по выборке
  izm=NULL
  for (nm in mas$name){
    og=subset(vib,select=c('oper',nm,'kk'));og$zn=og[,nm];og[,nm]=NULL;
    og$name=nm;
    if(is.null(izm)){izm=og}else{izm=rbind(izm,og)}
  }
  izm=izm[(izm$zn>0)&(!is.na(izm$zn)),];  
  if (nrow(izm)>0){
    izm$izm='mut_vib';izm$neiroset=NA;izm$zn=NULL;
    izm$kol=5*izm$kk/nrow(izm);izm$kk=NULL
    izmen=rbind(izmen,izm)}
  
  #### izmen_=izmen   izmen=izm[1,]
  #случайный выбор 1 изменения, пропорционально kol 
  izmen=neural$neir.sluchaini_vibor(izmen)
  izm=izmen$izm;neir$vhod$id_izm=izm;
  oper=izmen$oper;nset=izmen$neiroset;name=as.character(izmen$name); # nset=1
  vib=neir$all_vibor;ogr=neir$all_ogr;str=neir$param_str #исходные, без доп полей
  
  
  # если это - сделать даты запаздываний кратными 7
  if (izm=='mut_ogr_p7'){
    ogr$plus=pmax(round(ogr$plus/7)*7,neir$vhod$before);
    neir$all_ogr=ogr }
  
  # если это - склейка = изменение условия склейки выборки с данными 
  # То есть, вместо склейки по равенству, склейка без проверки
  if (izm=='skleika'){
    o=(ogr$oper==oper);ogr[o,name]=-1;ogr[o,c('min','max')]=NA
    neir$all_ogr=ogr }
  
  # если это - раздвоение - выделение данной нейросети больше не оставляет данных для поднастройки иными нейросетями
  if (izm=='razdvoen'){ 
    vib[(vib$oper==oper),'razdvoen']=0;neir$all_vibor=vib }
  
  # если это - усложнение нейросети
  if (izm=='neiroset'){ #увеличить нужную нейросеть
    #исходные данные
    str_=str[(str$neiroset==nset),]
    #Добавить нейрон новый
    z=max(str_$vih);str2=str_[(str_$vih==z),];
    o=(is.na(str2$vhod));str2[o,'vhod']=z;str2[o,'vih']=z+1;
    str2$zn=0;
    #постановка типа нейрона, случайно - кроме тривиального (=0)
    str2[(str2$vhod==str2$vih),'zn']=round(runif(1)*neural$max_tip_neir+0.5)
    #старые нейроны
    str_[(str_$vhod==z)&(!is.na(str_$vhod)),'vhod']=z+1
    str_[(str_$vih==z),'vih']=z+1
    str_=rbind(str_,str2)
    #пронумеровать нормально
    o=order(str_$vih,is.na(str_$vhod),str_$vhod);str_=str_[o,]
    str_$rebro=(1:nrow(str_))  
    
    #записать в полную структуру всех нейросетей
    str=str[(str$neiroset!=nset),];str=rbind(str,str_)
    #str=as.data.frame(as.data.table(str))
    neir$param_str=str
    # теперь изменить мин. количества записей на входе
    res=aggregate(x=subset(str,select=c('rebro','vih')),
                  by=subset(str,select=c('neiroset')), FUN="max" )
    vib=merge(vib,res,by='neiroset',all=TRUE) 
    vib$kol_str=vib$rebro;vib$kol_neiron=vib$vih;vib$rebro=NULL;vib$vih=NULL 
    vib$min_kol=10*(vib$kol_mas+vib$kol_str)
    neir$all_vibor=vib
  }
  
  # если мутация - изменение типа нейрона в нейросети
  if (izm=='mut_neir'){ 
    str_=str[(str$neiroset==nset),]
    o=((str_$vhod==str_$vih)&(!is.na(str_$vhod)))
    strp=str_[o,]
    strp$zn=round(runif(nrow(strp))*neural$max_tip_neir+0.5)#постановка случайного изменения
    str_=rbind(str_[(!o),],strp)
    o=order(str_$rebro);str_=str_[o,]
    #записать в полную структуру всех нейросетей
    str=str[(str$neiroset!=nset),];str=rbind(str,str_)
    neir$param_str=str
    # для порядка обработки - убить размер ошибки, и радиус увеличить
    vib=neir$all_vibor
    vib[((vib$neiroset==nset)&(!is.na(vib$neiroset))),c('error','error_rez','ss_err')]=NA
    vib[((vib$neiroset==nset)&(!is.na(vib$neiroset))),'radius']=0.1
    neir$all_vibor=vib
  }
  
  # если это - мутация выхода нейросети - СТАВИМ ДРУГУЮ ПЕРЕМЕННУЮ (СОВСЕМ ДРУГУЮ)############
  if (izm=='mut_get'){ 
    o=(ogr$oper==oper);ogr[o,c('min','max')]=NA
    ogr[o,'get']=name;ogr[o,'zapazd']=NA
    neir$all_ogr=ogr}
  
  # если это - мутация выхода нейросети - СТАВИМ ДРУГУЮ ПЕРЕМЕННУЮ (СОВСЕМ ДРУГУЮ)############
  if (izm=='mut_gets'){ 
    o=(ogr$oper==oper);ogr[o,c('min','max')]=NA
    ogr[o,'get']=name;ogr[o,'zapazd']=round(runif(1)*30+2)
    neir$all_ogr=ogr}
  
  # если это - мутация выбора данных - БОЛЬШЕ ПО ПОЛЮ НЕ ФИЛЬТРУЕМ, НО И НА ВХОД ОНО НЕ ПОПАДАЕТ
  if (izm=='mut_vib'){ 
    vib[(vib$oper==oper),name]=-1;neir$all_vibor=vib}
  
  # если это - мутация ограничения выхода - ПЕРЕМЕННАЯ БОЛЬШЕ НЕ ОГРАНИЧИВАЕТ. А ИДЁТ В ПАРАМЕТР СКЛЕЙКИ
  if (izm=='mut_ogr'){ 
    o=(ogr$oper==oper);ogr[o,c('min','max')]=NA
    ogr[o,name]=0;neir$all_ogr=ogr}
  
  # если это - перепутать входы в нейросети
  if ((izm=='ogr_random')&(nrow(ogr)>0)){ 
    kol=nrow(ogr)
    #разбить на подмножества   
    ogr1=subset(ogr,select=c('oper','out'))
    ogr2=subset(ogr,select = -c(oper,out))  
    ogr1$f=runif(kol);o=order(ogr1$f);ogr1=ogr1[o,];#одно перемешать
    ogr1$n=(1:kol);ogr2$n=(1:kol);ogr=merge(ogr1,ogr2,by='n')  
    ogr$n=NULL;ogr$f=NULL;neir$all_ogr=ogr;
  }
  
  return(neir)
  rm(get,iz,izmen,mas,og,ogr,vb,vh,vib,izm,kk,name,neir,nm,o,op,oper,po,str,str_,strp)
  rm(ogr1,ogr2,res,str2,kol,nset,z)
}
#пример запуска    neir=neural$neir.uslojn(neir)   








# добавка в пул нейросетей новой нейросети - может быть и излишней
neural$neir.plus_vhod <- function (neir) {  
  neir$dann=NULL   #сперва выкинуть из нейосети данные
  
  before=neir$vhod$before
  ogr=neir$all_ogr;vib=neir$all_vibor;vib$new=0
  if (is.null(vib$kol_x)){vib$kol_x=0}
  mas=neir$vhodi;mas=mas[(mas$tip=='mas'),]
  
  # из кого будем черпать данные
  #oper=round(max(vib$oper)*runif(1)) 
  # выборка случайно - пропорционально суммарной ошибке на результате
  vib_=subset(vib,select=c('oper','error_rez','neiroset'));vib_$kol=vib_$error_rez
  kol=mean(vib_$kol);# когда нет нейросети - и ошибки - заполнить средним значением
  o=(is.na(vib_$neiroset));if (nrow(vib_[o,])>0){vib_[o,'kol']=kol}
  vib_=neural$neir.sluchaini_vibor(vib_);oper=vib_$oper
  
  #максимальный номер нейросети
  vib_=vib[(!is.na(vib$neiroset)),];
  kol_neir=max(vib_$neiroset);  #min_kol=min(vib_$min_kol)
  
  #теперь - после какой операции вклинимся
  vib_=vib[(vib$oper==oper)|(vib$pred_oper==oper),]
  k=round(runif(1)*nrow(vib_)+0.5)
  po=vib_[k,'oper']; # именно после этой операции вводим новую  #    oper=0;po=1
  
  #фильтрация выбора, изначально что было (далее возможно усложнить)
  vb=vib[(vib$oper==oper),];
  for (nm in names(vb)){#почистить ненужные поля
    if (!(nm %in% c(as.character(mas$name),as.character(mas$nm_)))){
      vb[,nm]=NA}
    if (nm %in% c(as.character(mas$name))){
      vb[,nm]=max(0,vb[,nm])}
  }
  
  
  # постановка первичных значений параметров
  vb$new=1;vb$pred_oper=oper;vb$oper=po+1;vb$neiroset=kol_neir+1
  #vb[,c('time','kol_step')]=0;vb$radius=0.1
  vb$razdvoen=round(runif(1)) # новый вход: 1=раздваивать, 0= не раздваивать
  
  #ВСЁ ПО ОГРАНИЧИТЕЛЮ
  
  #выбрать, какую переменную пошлём на вход ограничителя
  xz=neir$vhodi;mas=xz[(xz$tip=='mas'),];xz=xz[(xz$tip %in% c('xz','xs')),]
  xz_=as.character(xz[(round(nrow(xz)*runif(1)+0.5 )),'nm_']) # изменил, =NA невозможно
  xz_t=as.character(xz[(xz$nm_==xz_),'tip'])
  
  #выбрать, как будем фильтровать вход
  dann=neural$dannie;dann=dann[(!is.na(dann[,xz_])),]
  i=round(runif(1)*nrow(dann)+0.5)
  og=dann[i,]
  nm=c(as.character(mas$name))  # ,as.character(mas$nm_)
  og=subset(og,select=nm)
  masd=mas;masd$r=runif(nrow(masd));o=order(masd$r);masd=masd[o,]
  kol=round(runif(1)*nrow(masd)+0.5) 
  
  mass=neir$mass
  for (i in (1:nrow(masd))){  
    nm=as.character(masd[i,'name']);nm_=as.character(masd[i,'nm_'])
    zn=og[,nm];zn=mass[(mass$nom==zn),'zn'];og[,nm_]=zn
    if ((i>kol)|(!is.na(masd[i,'dat']))){og[,nm]=0;og[,nm_]=NA;}
    if (!is.na(masd[i,'dat'])){og[,nm]=-1;og[,nm_]=NA;}
  }
  
  
  # поставить - что именно на вход (параметр)
  og$plus=before+round(runif(1)*30);
  og$zapazd=NA;if (xz_t=='xs') {og$zapazd=round(runif(1)*30+1); }
  og$kol_x=as.integer(vib[(vib$oper==oper),'kol_x'])+(1:nrow(og))
  og$get=xz_;og$out=paste('x',og$kol_x,sep='');og$max=NA;og$min=NA
  vb$kol_x=max(og$kol_x);og$kol_x=NULL
  og$oper=po+1
  og=og[(!is.na(og$get)),]
  
  #далее новые ограничитель и выборку устанавливаем в базу
  o=(vib$oper>po);vib[o,'oper']=vib[o,'oper']+1
  o=(vib$pred_oper>po);vib[o,'pred_oper']=vib[o,'pred_oper']+1
  vib=rbind(vib,vb)
  o=(ogr$oper>po);ogr[o,'oper']=ogr[o,'oper']+1    
  ogr=rbind(ogr,og);
  
  #ogr=as.data.frame(as.data.table(ogr))
  #vib=as.data.frame(as.data.table(vib))
  neir$all_ogr=ogr;neir$all_vibor=vib #запись в нейросеть выборок и ограничений входов
  
  #   # увеличение структуры - запись тривиальной сети
  #   str=neir$param_str
  #   kol_vh=vb$kol_m+vb$kol_x #число всех входов
  #   vhod=c((0:(kol_vh+1)),NA)
  #   str_=as.data.frame(vhod);str_$neiroset=vb$neiroset;str_$vih=kol_vh+1;str_$zn=0;
  #   str_[(is.na(str_$vhod)),'zn']=0.3;
  #   str_$rebro=(1:nrow(str_))
  #   str=rbind(str,str_);
  #   #str=as.data.frame(as.data.table(str))
  #   neir$param_str=str
  
  #   # рассчёт минимального числа входных наблюдений
  #   kol_mas=nrow(neir$mass)
  #   str=neir$param_str;
  #   reb=aggregate(x=subset(str,select=c('rebro')),by=subset(str,select=c('neiroset')), FUN="max" )
  #   reb$min_kol=10*(reb$rebro+kol_mas);reb$rebro=NULL
  #   vib=neir$all_vibor;
  #   vib$min_kol=NULL
  #   vib=merge(vib,reb,by=c('neiroset'),all=TRUE)
  #   neir$all_vibor=vib
  
  # постановка id
  if (!is.na(neir$vhod$id)){
    neir$vhod$pred_id=neir$vhod$id;neir$vhod$id=NA;
    if (!is.na(neir$vhod$error)){neir$vhod$pred_error=neir$vhod$error}
    neir$vhod$error=NA}
  neir$vhod$pred_versia=neir$vhod$versia
  neir$vhod$id_izm='plus'
  return(neir)
  rm(dann,mas,masd,og,ogr,vb,vib,xz,before,i,kol,kol_neir,neir,nm,o,oper,po,xz_,xz_t,k,vib_,mass,nm_,zn)
}
#пример запуска
# neir2=neural$neir.plus_vhod(neir)









# добавка в пул нейросетей новой нейросети - выбором из 100 штук
neural$neir.plus_vibor <- function (neir) {  
  
  #Наполнить нейросеть данными
  if (is.null(neir$dann)){neir=neural$neir.dannie_all(neir)}  
  
  # результат настройки по всему пулу нейросетей
  result=neural$neir.rez_all(neir);
  result=result[(result$kol==1),]
  dann=neir$dann
  dannie=neural$dannie
  
  mas=neir$vhodi;mas=mas[(mas$tip=='mas'),];
  masd=mas[(is.na(mas$dat)),]
  xz=neir$vhodi;xz=xz[(xz$tip %in% c('xz','xs')),]
  
  result=subset(result,select=c('neiroset','row','yy','zn','dat'))
  dann=subset(dann,select=c('neiroset','row',masd$name))
  result=merge(result,dann,by=c('neiroset','row'))
  
  
  ogg=NULL;before=neir$vhod$before
  #100 раз выбираем случайный входной вектор
  for (vvv in (1:20)){   #   vvv=1
    
    #выбрать, какую переменную пошлём на вход ограничителя
    xz_=as.character(xz[(round(nrow(xz)*runif(1)+0.5 )),'nm_']) # изменил, =NA невозможно
    xz_t=as.character(xz[(xz$nm_==xz_),'tip'])
    
    
    dn=dannie[(!is.na(dannie[,xz_])),]
    
    #выбрать случайный вариант
    i=round(runif(1)*nrow(dn)+0.5);i=min(max(i,1),nrow(dn));og=dn[i,]
    nm=c(as.character(mas$name),as.character(mas$nm_))
    og=subset(og,select=nm)
    mas$r=runif(nrow(mas));o=order(mas$r);mas=mas[o,];mas$r=NULL
    kol=round(runif(1)*nrow(mas)+0.5)
    
    for (i in (1:nrow(mas))){
      nm=as.character(mas[i,'name']);nm_=as.character(mas[i,'nm_'])
      dat=mas[i,'dat']
      if ((i>kol)|(!is.na(dat))){og[,nm]=0;og[,nm_]=NA;}
      if (!is.na(dat)){og[,nm]=-1;og[,nm_]=NA;}}
    
    # поставить - что именно на вход (параметр)
    og$plus=before+round(runif(1)*30);
    og$zapazd=NA;if (xz_t=='xs') {og$zapazd=round(runif(1)*30+1); }
    og$get=xz_;
    
    get=og$get;out='xx';tip=xz_t
    dn[,out]=as.numeric(dn[,get]);dn_=NULL
    dn=subset(dn,select=c('dat',masd$name,out,'mas_nom'))
    
    if (tip=='xs'){
      dn_=subset(dn,select=c('dat','mas_nom',out))
      dn_$out=dn_[,out];dn_[,out]=NULL
      zapazd=og$zapazd
      dn_$dat=dn_$dat+zapazd
      dn=merge(dn,dn_,by=c('mas_nom','dat'))
      dn[,out]=dn[,out]-dn$out
      dn$out=NULL;
    }
    #ввести запазд по времени
    dn$dat=as.Date(dn$dat)+og$plus
    
    #взять это поле только когда это нужно (поезд, тип, класс, день недели...)
    for (nm in masd$name){
      zn=as.character(og[,nm]);if (zn>0){dn=dn[(dn[,nm]==zn),]}}
    
    min_=min(dn$xx);max_=max(dn$xx)
    #афинное преобразование входа - до интервала (0,1)
    if (nrow(dn)>0){
      if (max_>min_) {dn[,out]=(dn[,out]-min_)/(max_-min_)}else{dn[,out]=0}}
    
    #какие возможные значения элементов массива - по каким полям далее склеивать (имеющим более 1 значения)?
    dn_mas=unique(subset(dn, select = as.character(masd$name)))
    
    #какие элементы массива бывают чаще 1 раза?
    masd$kol=0
    if(nrow(masd)>0){for (nm in masd$name){
      masd[(masd$name==nm),'kol']=nrow(unique(subset(dn_mas, select = nm)))  }}
    
    #списки нужных полей (чаще 1 раза)
    mas_=as.character(masd[(masd$kol>1),'name'])
    dn=subset(dn, select = c(out,'dat',mas_));
    
    #склеиваем данные (результат настройки) с новым вектором
    res=merge(result,dn,by=c('dat',mas_)) 
    
    # оставить лишь неразмножившиеся результаты склейки
    if (nrow(res)>0){
      res$kol=1;
      res_=aggregate(x=subset(res,select=c('kol')),by=subset(res,select=c('row')), FUN="sum" )
      mx=max(res$kol);if (mx>1){res=res[(res$row<0),]}#раздвоили хоть кого - убить всех
    }
    
    #делаем вектор xx перпендикулярным zn  
    if (nrow(res)>0){
      #оставить лишь нужное
      res=subset(res,select=c('neiroset','yy','zn','xx')) 
      res$kol=1;res$r=res$yy-res$zn;
      
      res$zn_x=res$zn*res$xx;res$zn2=res$zn**2
      res_=aggregate(x=subset(res,select=c('zn_x','zn2','zn','kol')),
                     by=subset(res,select=c('neiroset')), FUN="sum" )
      res_=res_[(res_$kol>100),]
      res_$k=res_$zn_x/res_$zn2;res_$ke=res_$zn/res_$zn2
      
      res=merge(res,res_[,c('neiroset','k','ke')],by='neiroset')
      if (nrow(res)>0){
        res$xx=res$xx-res$zn*res$k;res$k=NULL
        res$kol=res$kol-res$zn*res$ke;res$ke=NULL }}
    
    #делаем вектор xx перпендикулярным 1(=kol)
    if (nrow(res)>0){
      res$xx_kol=res$xx*res$kol;res$kol2=res$kol**2
      res_=aggregate(x=subset(res,select=c('xx_kol','kol2')),
                     by=subset(res,select=c('neiroset')), FUN="sum" )
      res_$k=res_$xx_kol/res_$kol2;
      
      res=merge(res,res_[,c('neiroset','k')],by='neiroset')
      res$xx=res$xx-res$kol*res$k;res$k=NULL}
    
    #ищем возможное уменьшение ошибки = (r*x)*(r*x)/(x*x)   
    if (nrow(res)>0){
      res$rx=res$r*res$xx;res$xx2=res$xx**2
      res_=aggregate(x=subset(res,select=c('rx','xx2')),
                     by=subset(res,select=c('neiroset')), FUN="sum" )
      res_$de=(res_$rx**2)/res_$xx2;
      o=order(-res_$de);res_=res_[o,];res_=res_[1,c('neiroset','de')]
      og=merge(og,res_)
      if (is.null(ogg)){ogg=og}else{ogg=rbind(ogg,og)}
    }
  }
  
  #################### берём лучший вариант, и добавляем в нейросеть
  if (!is.null(ogg)){#если есть хоть 1 вариант
    o=order(-ogg$de);ogg=ogg[o,];ogg=ogg[1,] # выбрать 1 лучший   
    neir$dann=NULL   #выкинуть из нейосети данные
    
    before=neir$vhod$before
    ogr=neir$all_ogr;vib=neir$all_vibor;vib$new=0
    if (is.null(vib$kol_x)){vib$kol_x=0}
    mas=neir$vhodi;mas=mas[(mas$tip=='mas'),]
    
    # из кого будем черпать данные
    nset=ogg$neiroset;oper=vib[((vib$neiroset==nset)&(!is.na(vib$neiroset))),'oper']  
    
    #максимальный номер нейросети
    kol_neir=max(vib[(!is.na(vib$neiroset)),'neiroset']);
    
    #теперь - после какой операции вклинимся
    vib_=vib[(vib$oper==oper)|(vib$pred_oper==oper),]
    k=round(runif(1)*nrow(vib_)+0.5)
    po=vib_[k,'oper']; # именно после этой операции вводим новую  #    oper=0;po=1
    
    #фильтрация выбора, изначально что было (далее возможно усложнить)
    vb=vib[(vib$oper==oper),];
    if (nrow(vb)>0){
      # постановка первичных значений параметров
      vb$new=0;  # было vb$new=2;
      vb$pred_oper=oper;vb$oper=po+1;vb$neiroset=kol_neir+1
      
      #vb[,c('time','kol_step')]=0;vb$radius=0.1
      vb$razdvoen=round(runif(1)) # новый вход: 1=раздваивать, 0= не раздваивать
      vb$kol_x=vb$kol_x+1
    }
    
    #ВСЁ ПО ОГРАНИЧИТЕЛЮ
    og=ogg;og$neiroset=NULL;og$de=NULL
    # поставить - что именно на вход (параметр)
    og$out=paste('x',vb$kol_x,sep='');og$max=NA;og$min=NA
    og$oper=po+1;og=og[(!is.na(og$get)),]
    
    #ВСЁ ПО СТРУКТУРЕ НЕЙРОСЕТИ
    str=neir$param_str;str_=str[(str$neiroset==nset),];
    vv=vb$kol_x #vb$kol_m+vb$kol_x #номер нового входа
    o=((str_$vhod>=vv)&(!is.na(str_$vhod)));
    str_[o,'vhod']=str_[o,'vhod']+1;str_$vih=str_$vih+1
    o=((str_$vhod==str_$vih)&(!is.na(str_$vhod)));
    str_2=str_[o,];str_2$vhod=vv;str_2$zn=0;str_=rbind(str_,str_2)
    o=order(str_$vih,str_$vhod);str_=str_[o,];str_$rebro=(1:nrow(str_))
    str_$neiroset=kol_neir+1
    str=rbind(str,str_)
    
    #всё по значениям массива
    mass=neir$param_mas;mass_=mass[(mass$neiroset==nset),]
    mass_$neiroset=kol_neir+1;mass=rbind(mass,mass_)
    
    
    #далее новые ограничитель и выборку устанавливаем в базу
    o=(vib$oper>po);if (nrow(vib[o,])>0){vib[o,'oper']=vib[o,'oper']+1}
    o=(vib$pred_oper>po);if (nrow(vib[o,])>0){vib[o,'pred_oper']=vib[o,'pred_oper']+1}
    vib=rbind(vib,vb)
    o=(ogr$oper>po);if (nrow(ogr[o,])>0){ogr[o,'oper']=ogr[o,'oper']+1}    
    ogr=rbind(ogr,og);
    
    #запись в нейросеть выборок и ограничений входов и параметров нейросети
    neir$all_ogr=ogr;neir$all_vibor=vib
    neir$param_str=str;neir$param_mas=mass
    
    # постановка id
    if (!is.na(neir$vhod$id)){
      neir$vhod$pred_id=neir$vhod$id;neir$vhod$id=NA;
      if (!is.na(neir$vhod$error)){neir$vhod$pred_error=neir$vhod$error}
      neir$vhod$error=NA}
    neir$vhod$pred_versia=neir$vhod$versia
    neir$vhod$id_izm='plus_vib'
  }
  return(neir)
  rm(dann,mas,masd,og,ogr,vb,vib,xz,before,i,kol,kol_neir,neir,nm,o,oper,po,xz_,xz_t,k,vib_)
  rm(dannie,dn,dn_,dn_mas,zapazd,ogg,res,res_,result,dat,get,mas_,max_,min_,mx,nm_,nset,out)
  rm(tip,vvv,zn,mass,mass_,str,str_,str_2,vv)
}
#пример запуска
# neir2=neural$neir.plus_vibor(neir)






#перенос генов из одной нейросети в другую 
neural$neir.perenos_gen <- function (neir) {
  
  if (!is.null(neir$neir_)){ # если забито, что и откуда надо взять
    #переработка входов
    neir_=neir$neir_;nset_=neir_$nset_
    
    #если вдруг список входов успел измениться
    neir_=neural$neir.podstroika(neir_)
    
    vib=neir$all_vibor;vib_=neir_$all_vibor;
    ogr=neir$all_ogr;ogr_=neir_$all_ogr;
    
    op=vib_[((vib_$neiroset==nset_)&(!is.na(vib_$neiroset))),'oper']
    if (op>0){
      vib_[(vib_$oper!=op),'neiroset']=NA
      vib_$isp=0
      
      while (op>0){
        o=(vib_$oper==op);vib_[o,'isp']=1;op=as.integer(vib_[o,'pred_oper'])}
      vib_=vib_[(vib_$isp==1),];vib_$isp=NULL
      
      o=order(vib_$oper);vib_=vib_[o,];plus=nrow(vib_)
      vib_$op=(1:plus)
      
      vv=vib_[,c('oper','op')]
      ogr_=merge(ogr_,vv,by='oper')
      
      ogr_$oper=ogr_$op;ogr_$op=NULL
      vib_$oper=vib_$op;vib_$pred_oper=vib_$op-1;vib_$op=NULL
      
      kol_neir=max(vib[(!is.na(vib$neiroset)),'neiroset'])
      vib_[(vib_$oper==plus),'neiroset']=kol_neir+1
      
      o=(vib$oper>0);vib[o,'oper']=vib[o,'oper']+plus
      o=(vib$pred_oper>0);vib[o,'pred_oper']=vib[o,'pred_oper']+plus
      
      vib=myPackage$sliv(vib,vib_)  #vib=rbind(vib,vib_)
      
      ogr$oper=ogr$oper+plus;ogr=rbind(ogr,ogr_)
      
      #массивы
      mass=neir$param_mas;mass_=neir_$param_mas;
      mass_=mass_[(mass_$neiroset==nset_),]
      mass_$neiroset=kol_neir+1;mass=rbind(mass,mass_)
      #собственно структура нейросети
      str=neir$param_str;str_=neir_$param_str;
      str_=str_[(str_$neiroset==nset_),]
      str_$neiroset=kol_neir+1;str=rbind(str,str_)
      
      
      #перенос результатов в нейросеть
      neir$all_ogr=ogr;neir$all_vibor=vib;neir$param_mas=mass;neir$param_str=str;
      neir$vhod$id_izm='perenos_gen'
      
      # постановка id
      if (!is.na(neir$vhod$id)){
        neir$vhod$pred_id=neir$vhod$id;neir$vhod$id=NA;
        if (!is.na(neir$vhod$error)){neir$vhod$pred_error=neir$vhod$error}
        neir$vhod$error=NA}
      neir$vhod$pred_versia=neir$vhod$versia;neir$vhod$good=1
      
      rm(mass,mass_,str,str_,vv,kol_neir,o,plus)}
    rm(ogr,ogr_,vib,vib_,neir_,nset_,op)
    
  }
  neir$neir_=NULL  
  return(neir)
  rm(neir)
}
#   пример  neir=neural$neir.perenos_gen(neir);







#усложнение нейросети - или всякие изменения, мутации, или добавка входа
neural$neir.plus_uslojn <- function (neir) {
  #если вдруг список входов успел измениться
  neir=neural$neir.podstroika(neir) 
  
  if (is.null(neir$vhod$good)){neir$vhod$good=1}
  if (neir$vhod$good==0){
    neir$vhod$id_izm='-';neir$dann=NULL
    if (runif(1)<0.3){neir=neural$neir.plus_vibor(neir)} #30% перебор нескольких вариантов, выбрать потенциально лучший
    if ((runif(1)<0.02)&(neir$vhod$id_izm=='-')){neir=neural$neir.perenos_gen(neir)} #перенести гены, если они есть
    if ((runif(1)<0.7)&(neir$vhod$id_izm=='-')){neir=neural$neir.uslojn(neir)} #попробовать усложнить - 50%
    if (neir$vhod$id_izm=='-'){
      neir=neural$neir.plus_vhod(neir)}# не усложнили - добавить нейросеть
    # постановка id
    if (!is.na(neir$vhod$id)){
      neir$vhod$pred_id=neir$vhod$id;neir$vhod$id=NA;
      if (!is.na(neir$vhod$error)){neir$vhod$pred_error=neir$vhod$error}
      neir$vhod$error=NA}
    neir$vhod$pred_versia=neir$vhod$versia;neir$vhod$good=1
  }
  neir$neir_=NULL;neir$dann=NULL;
  return(neir)
  rm(neir)
}
#  пример   neir=neural$neir.plus_uslojn(neir) 










#генерация описания нейросети
neural$neir.opis <- function(neir) {  #было  myPackage$trs.pack  
  vibor=neir$all_vibor;ogr=neir$all_ogr;str=neir$param_str
  names=c('pred_oper','neiroset','kol_m','kol_x','kol_neiron',names(ogr))
  for (nm in names(vibor)){if (!(nm %in% names)){vibor[,nm]=NULL}}
  
  str=str[(!is.na(str$vhod)),]
  o=(str$vhod<str$vih);str[o,'zn']=0
  str$vhod=as.integer(str$vhod)
  
  o=order(vibor$oper);vibor=vibor[o,]
  o=order(ogr$oper);ogr=ogr[o,]
  o=order(str$neiroset,str$rebro);str=str[o,]
  
  #упорядочивания полей во фреймах
  str=neural$neir.upor_frame(str)
  ogr=neural$neir.upor_frame(ogr)
  vibor=neural$neir.upor_frame(vibor)
  
  opis=list()
  opis$vibor=vibor;opis$ogr=ogr;opis$str=str
  #переход от структуры к строке
  opis=myPackage$neir.pack(opis)
  return(opis)}




#генерация описания нейросети
neural$neir.opis_ <- function(neir) {  #было  myPackage$trs.pack  
  vibor=neir$all_vibor;ogr=neir$all_ogr;str=neir$param_str
  names=c('pred_oper','neiroset','kol_m','kol_x','kol_neiron',names(ogr))
  for (nm in names(vibor)){if (!(nm %in% names)){vibor[,nm]=NULL}}
  
  str=str[(!is.na(str$vhod)),]
  o=(str$vhod<str$vih);str[o,'zn']=0
  str$vhod=as.integer(str$vhod)

  o=order(vibor$oper);vibor=vibor[o,]
  o=order(ogr$oper);ogr=ogr[o,]
  o=order(str$neiroset,str$rebro);str=str[o,]

  #упорядочивания полей во фреймах
  str=neural$neir.upor_frame(str)
  ogr=neural$neir.upor_frame(ogr)
  vibor=neural$neir.upor_frame(vibor)
  
  opis=list()
  opis$vibor=vibor;opis$ogr=ogr;opis$str=str
  #переход от структуры к строке
  #opis=myPackage$neir.pack(opis)
  return(opis)}




#упорядочивание столбцов фрейма по алфавиту  
neural$neir.upor_frame <- function(fr) {  #было  myPackage$trs.pack  
  name=trimws(names(fr))
  name=unique(as.data.frame(name));kol=nrow(name)
  name$i=1
  o=order(name$name);name=name[o,];name$i=(1:kol)

  for (i in (1:kol)){
    nm=as.character(name[(name$i==i),]$name)
    z=as.character(fr[,nm]);fr[,nm]=NULL;fr[,nm]=z}
  #fr=as.data.frame(as.data.table(fr))
  return(fr)}






# перенос генов  - взять "лучшие" элементы нейросетей, и записать в другой пул настройки в начале
neural$neir.perenos <- function (neir, itogi) {
  
  res=itogi$result;if (!is.null(res)){
    res$kol=1
    res=aggregate(x=subset(res,select=c('kol')),by=subset(res,select=c('id','neiroset')), FUN="sum" )
    res=res[(res$neiroset>1),] #не брать тривиальные варианты
    
    kol=nrow(res)
    if (kol>0){ #если есть вообще предыдущие итоги, нетривиальные
      i=min(max(round(runif(1)*kol+0.5),1),kol);res=res[i,];
      id_=res$id;nset=res$neiroset #узнали, кого именно надо приписать
      rm(kol,i,res);
      
      #взять параметры нужной нейросети
      vib=itogi$vibor;ogr=itogi$ogran
      vib=vib[(vib$id==id_),];ogr=ogr[(ogr$id==id_),]
      vib_=vib[(!is.na(vib$neiroset)),]
      oper=as.character(vib_[(vib_$neiroset==nset),'oper']);
      ogr_=ogr[(ogr$oper==oper),];vib_=vib[(vib$oper==oper),];
      while (oper>0) {oper=as.character(vib[(vib$oper==oper),'pred_oper']  )
      og=ogr[(ogr$oper==oper),];ogr_=rbind(ogr_,og);rm(og)}
      rm(ogr,vib) 
      
      #теперь, если в выборке не пустой парам, и = ограничению, то снять это ограничение
      if (runif(1)<0.5){#делать не всегда
        mas=neir$vhodi;mas=mas[(mas$tip=='mas'),]
        for (nm in mas$nm_){zn=vib_[,nm];if (!is.na(zn)){
          if (nrow(ogr_[(ogr_[,nm]==zn)&(!is.na(ogr_[,nm])),])>0){
            ogr_[(ogr_[,nm]==zn)&(!is.na(ogr_[,nm])),nm]=NA}}}}
      
      # подготовить для переноса
      ko=nrow(ogr_);if (ko>0){o=order(ogr_$oper);ogr_=ogr_[o,];ogr_$oper=(1:ko)}
      
      ogran=neir$all_ogr;vibor=neir$all_vibor
      v=vibor[(vibor$oper==0),];v$oper=NULL
      og=subset(ogr_,select=c(id,oper))
      v=merge(v,og);rm(og)
      v$neiroset=NULL;v$id=NULL;v$pred_oper=v$oper-1
      
      vib_$pred_oper=ko;ko=ko+1;vib_$oper=ko
      nset_new=max(vibor[(!is.na(vibor$neiroset)),'neiroset'])+1;
      vib_$neiroset=nset_new;vib_$time=0
      
      vib_$id=NULL
      if (ko>1){v$neiroset=NA;vib_=rbind(vib_,v)};
      rm(v)
      
      #Вставка новой нейросети в выборку и ограничения
      o=(vibor$oper>0);if (nrow(vibor[o,])>0){vibor[o,'oper']=vibor[o,'oper']+ko}
      o=(vibor$pred_oper>0);if (nrow(vibor[o,])>0){vibor[o,'pred_oper']=vibor[o,'pred_oper']+ko}
      vibor=rbind(vibor,vib_)
      
      o=(ogran$oper>0);if (nrow(ogran[o,])>0){ogran[o,'oper']=ogran[o,'oper']+ko}
      ogr_$id=NULL;ogran=rbind(ogran,ogr_)
      rm(ogr_,vib_)
      
      #теперь ещё структуру и массив добавить
      mas_=itogi$massiv;mas_=mas_[(mas_$id==id_),];mas_$id=NULL;
      mas_=mas_[(mas_$neiroset==nset),];mas_$neiroset=nset_new
      str_=itogi$struct;str_=str_[(str_$id==id_),];str_$id=NULL;
      str_=str_[(str_$neiroset==nset),];str_$neiroset=nset_new
      struct=neir$param_str;struct=rbind(struct,str_)
      massiv=neir$param_mas;massiv=rbind(massiv,mas_)
      rm(mas_,str_)
      
      # и наконец всё записать в нейросеть
      neir$param_str=struct;neir$param_mas=massiv;
      neir$all_ogr=ogran;neir$all_vibor=vibor;
      # постановка id
      if (!is.na(neir$vhod$id)){
        neir$vhod$pred_id=neir$vhod$id;neir$vhod$id=NA;
        if (!is.na(neir$vhod$error)){neir$vhod$pred_error=neir$vhod$error}
        neir$vhod$error=NA}
      neir$vhod$pred_versia=neir$vhod$versia
      neir$vhod$id_izm='perenos'
      
      rm(struct,massiv,ogran,vibor)
    }} #конец проверки на наличие предварителных результатов
  
  return(neir)}




# сделать именно мутацию - вместо входа другой вход, или другие ограничения, или запаздывание
neural$neir.mutacia_old <- function (neir) {
  #выбор кого мутировать
  ogr=neir$all_ogr;kol=nrow(ogr)
  i=min(max(round(runif(1)*kol+0.5),1),kol)
  if (i>0){ # начало мутации
    ogr$izm=0;ogr[i,'izm']=1;og=ogr[(ogr$izm==1),]
    mas=neir$vhodi;xz=mas[(mas$tip=='xz'),];mas=mas[(mas$tip=='mas'),]
    
    k=0;
    for (nm in mas$nm_){#послед проверка всех ограничений - массивов
      if (!is.na(og[,nm])){if (runif(1)<0.1){og[,nm]=NA;k=k+1}}} # любое поле мутирует с вер=0.1
    
    if (k==0){# нет мутации - мутируем вход
      xz$r=runif(nrow(xz));o=order(xz$r);xz=xz[o,];xz=as.character(xz[1,'nm_'])
      if ((runif(1)<0.7)&(og$get!=xz)){og$get=xz;k=k+1}}
    if (k==0){# нет мутации - мутируем запаздывание входа - макс за 365 дней + станд запазд
      og$plus=neir$vhod$before +min(round(-log(runif(1))*100),365)}
    
    #запись мутации обратно
    ogr=ogr[(ogr$izm==0),];ogr=rbind(ogr,og);ogr$izm=NULL
    neir$all_ogr=ogr 
    # постановка id
    if (!is.na(neir$vhod$id)){
      neir$vhod$pred_id=neir$vhod$id;neir$vhod$id=NA;
      if (!is.na(neir$vhod$error)){neir$vhod$pred_error=neir$vhod$error}
      neir$vhod$error=NA}
    neir$vhod$pred_versia=neir$vhod$versia
    neir$vhod$id_izm='mutacia'
  }
  return(neir)}








######################################################








#################################################






#плюс 1 вход - разбить данные на хорошие, где вход есть (мин 1000 записей), и где его нет - всё прочее
neural$neir.dann_vhod_plus <- function(dann,vhod) {
  #собственно добавление поля,входы = dann,vhod; плюс neir - от него нужны лишь neir$vhodi
  dann$kol=NULL;ogr=vhod$ogr;vibor=vhod$vibor;vh=vhod$vhodi
  dn=NULL;out=NULL
  # ввести новое входное поле
  if (nrow(ogr)>0) {
    out=ogr$out;get=ogr$get;#xout=paste('x',out,sep=''); 
    #maxz=as.integer(vh[(vh$nm_==get),'max']);
    tip=as.character(vh[(vh$nm_==get),'tip'])
    #взять нужное поле, и когда оно есть в принципе
    dn=neural$dannie;
    dn=dn[(!is.na(dn[,get])),]
    dn[,out]=as.numeric(dn[,get])
    
    #убрать уже лишние поля - хоть чуть быстрее будет!!!
    mas=vh[(vh$tip=='mas'),];dn=subset(dn,select=c(mas$name,'dat','mas_nom',out)) 
    
    #взять это поле только когда это нужно (поезд, тип, класс, день недели...)
    for (nm in mas$name){if (!is.na(ogr[1,nm])){
      zn=as.character(ogr[1,nm]);if (zn>0){dn=dn[(dn[,nm]==zn),]}}}
    
    if (tip=='xs'){ # если поле=накопительная сумма, то поставить сумму за нужное число дней
      dn_=subset(dn,select=c('dat','mas_nom',out))
      dn_$out=dn_[,out];dn_[,out]=NULL
      zapazd=ogr$zapazd;dn_$dat=dn_$dat+zapazd
      dn=merge(dn,dn_,by=c('mas_nom','dat'))
      dn[,out]=dn[,out]-dn$out
      dn$out=NULL;rm(dn_,zapazd)
    }
    #ввести запазд по времени
    dn$dat=as.Date(dn$dat)+ogr$plus
    
    
    #минимум-максимум - посчитать и ввести в ограничения
    min_=ogr$min;max_=ogr$max
    if (is.na(max_)){max_=0;min_=0
    if (nrow(dn)>0){ #после мутации может стать пустая выборка
      max_=max(dn[,out]);min_=min(dn[,out])}
    ogr$min=min_;ogr$max=max_}
    
    #если вход - тривиальная константа - просто изъять его
    if (min_==max_){dn=dn[0,]}
    
    #афинное преобразование входа - до интервала (0,1)
    if (nrow(dn)>0){dn[,out]=(dn[,out]-min_)/(max_-min_)}
    
    #по кому склеивать - через ограничение, а не количества - правильнее!
    mas_=c();for (nm in mas$name){ if (ogr[,nm]==0) {mas_=c(mas_,nm)}}
    
    dn=subset(dn, select = c(out,'dat',mas_));
  }#конец - если есть новые ограничительные входы
  
  
  #взять на склейку фильтрованные данные   i=1
  mas=vh[(vh$tip=='mas'),];
  dn_=dann[(dann$oper==vibor$pred_oper),];  #сразу взять лишь нужную операцию
  if (nrow(dn_)>0){
    dn_$oper=vibor$oper
    #применение фильтра   
    if (nrow(mas)>0){
      for (nm in mas$name){
        if (!is.na(vibor[1,nm])){
          zn=vibor[1,nm];if (zn>0) {dn_=dn_[(dn_[,nm]==zn),]}}}}
  }
  
  
  #склейка выбранных с новым полем 
  if (!is.null(out)){#если новое поле уже было - убрать
    dn_[,out]=NULL;dn_=merge(dn_,dn,by=c('dat',mas_)) }
  
  # оставить лишь неразмножившиеся результаты склейки
  if (nrow(dn_)>0){
    dn_$kol=1;
    dns=aggregate(x=subset(dn_,select=c('kol')),by=subset(dn_,select=c('row')), FUN="sum" )
    dn_$kol=NULL;mx=max(dns$kol);
    if (mx>1){dn_=dn_[(dn_$row<0),]}#раздвоили хоть кого - убить всех
    rm(dns,mx)}
  
  if (is.na(vibor$min_kol)){vibor$min_kol=(3+vibor$kol_x)*10} #наименьший возможный рассматриваемый минимум подвыборки
  
  
  #если новая выборка - поставить фильтр (случайным образом), и достаточно много записей
  masv=mas # заранее - если мимо этого блока пройти
  if ((vibor$new==1)&(nrow(dn_[(dn_$kk==1),])>=vibor$min_kol)) {
    
    {#рассчёт средних значений, для выделения лучших вариантов фильтраций, из dn_
      dn_2=dn_[(dn_$kk==1),];dns_=NULL
      #рассчёт сумм по каждому элементу массива
      for (nm in c(mas$name,'kk')){
        dns=aggregate(x=subset(dn_2,select=c('kk','yy')),by=subset(dn_2,select=nm), FUN="sum" )
        dns$name=nm;dns$zn=dns[,nm];dns[,nm]=NULL
        if (is.null(dns_)){dns_=dns}else{dns_=rbind(dns_,dns)} }
      #среднее значение, и отклонение от него
      dns_$ey=dns_$yy/dns_$kk;ey=dns_[(dns_$name=='kk'),'ey']
      dns_$kol_=abs(dns_$ey-ey);dns_$kol=dns_$kol_*dns_$kk+1
      dns_=dns_[(dns_$name!='kk'),]
    }
    
    #ищем, из кого искать выборку взятых переменных массива
    masv=mas
    for (nm in masv$name){
      masv[(masv$name==nm),'vib']=vibor[1,nm]} #факты наличия подвыборки
    masv=masv[(masv$vib==0),];masv$vib=NULL #только где нет ещё фильтрации
    #if (nrow(masv)>0){
    
    #выбрать. по кому фильтровать
    dns=neural$neir.sluchaini_vibor(dns_)#случайный выбор по пропорции из базы, по полю kol
    nm=dns$name;zn=dns$zn #сортируем по этому полю и этому значению
    
    #значение фильтра в исходных обозначениях
    mass=vhod$mass;
    zn_=as.character(mass[(mass$nom==zn),'zn']);
    nm_=as.character(mas[(mas$name==nm),'nm_']);
    #установить значение фильтрации - если на выходе достаточно записей
    dn_2=dn_[(dn_[,nm]==zn),]
    if (nrow(dn_2)>vibor$min_kol){ 
      vibor[,nm]=zn;vibor[,nm_]=zn_;dn_=dn_2
      masv=masv[(masv$name!=nm),];
    }
  }
  
  
  #если новая выборка - поставить минимальное количество наблюдений, и число входов-массивов
  if ((vibor$new>0)&(nrow(dn_[(dn_$kk==1),])>=vibor$min_kol)) {
    # если в данных есть лишь 1 вариант значения массива - его точно мимо входа
    masv_=masv; 
    for (nm in masv$name){
      k=nrow(as.data.frame(unique(dn_[,nm])))
      if ((k==1)&(vibor[,nm]==0)) {
        vibor[,nm]=-1;masv_=masv_[(masv_$name!=nm),]}}
    masv=masv_
    
    
    #выбрать, каккие массивы пойдут на вход, а на какие не хватит записей
    kol_m=0;kol_mas=0
    #сколько можно максимум параметров
    kol_par=nrow(dn_)/10;kol_par=kol_par-3-vibor$kol_x
    # ввести случайный порядок поиска
    if (nrow(masv)>0){masv=masv[order(runif(nrow(masv))),]}
    
    for (nm_ in masv$name){#постановка - кто не влез, не идёт во вход
      #print(nm_)
      k=masv[(masv$name==nm_),'kol']+1;
      if (k<kol_par){
        kol_par=kol_par-k;kol_m=kol_m+1;kol_mas=kol_mas+k-1}else{vibor[,nm_]=-1}}
    vibor$kol_m=kol_m;vibor$kol_mas=kol_mas
    vibor$min_kol=(3+vibor$kol_m+vibor$kol_x+vibor$kol_mas)*10
    
    vibor$new=0
  }
  #проверка на минимальное число записей - если меньше нужного то уничтожить
  if (!is.na(vibor$neiroset)){ # только если выход должен быть хоть какой-то
    if ((nrow(dn_)<vibor$min_kol) &(nrow(dn_)>0)) {dn_=dn_[(dn_$row<0),]}}
  
  #собственно результат
  rez=list();rez$dann=dn_;rez$vibor=vibor;rez$ogr=ogr
  return(rez)
  
  rm(dann,dn,dn_,dn_mas,mas,ogr,vh,vibor,get,mas_,nm,out,rez,vhod,zn,dn_2,dns,dns_,ey)
  rm(mass,masv,k,kol_m,kol_mas,kol_par,max_,min_,nm_,tip,zn_,masv_)
}
#пример запуска   result=neural$neir.dann_vhod_plus(dann,vhod)













####################
#  рекурсивный процесс формирования данных
neural$neir.dannie_rekurs <- function(dann,vhodi,vh_oper) {
  #print(paste('вход ',vh_oper,sep=''))
  ###dannie=neural$dannie
  dann_rez=NULL
  ogr=vhodi$ogr;vibor=vhodi$vibor;vh=vhodi$vhodi
  vib=vibor[(vibor$pred_oper==vh_oper),];vib=vib[(vib$pred_oper<vib$oper),]
  o=order(vib$oper);vib=vib[o,]
  #вспомогательное поле, в пределах процедуры
  dann$zan=0 # =1 - если row входит в послед нейросеть, и операция - с раздвоением
  # если операция без раздвоения (или прогноз) - строка просто вычёркивается из данных
  
  for (oper in vib$oper){ #  oper=19
    #print(paste('проверка',oper,'из',vh_oper,sep=' '))
    vibor=vhodi$vibor;ogr=vhodi$ogr #прочитать заново - иногда меняется в работе
    # сперва рассчитать новое множество по операции
    vhod=list();vhod$ogr=ogr[(ogr$oper==oper),];
    vhod$vibor=vibor[(vibor$oper==oper),];
    vhod$vhodi=vhodi$vhodi
    vhod$mass=vhodi$mass
    razdvoen=vibor[(vibor$oper==oper),'razdvoen']
    
    #получаем, что принципиально может пойти далее   
    dann_op=dann[(dann$zan==0),];dann_op$zan=NULL
    #print(paste('проверка',oper,' шаг 1',sep=' '))
    rez=neural$neir.dann_vhod_plus(dann_op,vhod) #добавление входной переменной
    #print(paste('проверка',oper,' шаг 2',sep=' '))
    dann_op=rez$dann;vib_n=rez$vibor;ogr_n=rez$ogr #??? что меняется в условии выборки
    ### nrow(dann_op);vib_n$min_kol
    
    vibor=rbind(vibor[(vibor$oper!=oper),],vib_n)
    ogr=rbind(ogr[(ogr$oper!=oper),],ogr_n)
    vhodi$vibor=vibor;vhodi$ogr=ogr
    
    # далее - надо разбивку по последующим уровням
    dann_rek=NULL
    if (nrow(dann_op)>0){
      rek=neural$neir.dannie_rekurs(dann_op,vhodi,oper)
      dann_rek=rek$dann;vhodi=rek$vhodi;
    }
    
    
    #определение оставшихся данных для послед разбиений
    if (!is.null(dann_rek)){#если выход непуст
      dann_rek=dann_rek[(!is.na(dann_rek$neiroset)),]
      dns=dann_rek[(dann_rek$rez==1),];
      dns=unique(subset(dns,select=c('row','rez')))
      
      if (nrow(dns)>0){
        dns$z=1;dns$rez=NULL
        dann=merge(dann,dns,by='row',all=TRUE)
        dann[(is.na(dann$z)),'z']=0
        #прогнозы по любому вычёркиваются
        dann=dann[(dann$kk==1)|(dann$z==0),]
        #простановка занятостей
        dann$zan=pmax(dann$zan,dann$z)
        # удаление строк. если без раздвоения;
        if (razdvoen==0){dann=dann[(dann$z==0),]}
        dann$z=NULL
      }
      #свалить результаты
      if (is.null(dann_rez)){dann_rez=dann_rek}else{
        dann_rez=myPackage$sliv(dann_rek,dann_rez)}
    }
    #print(paste('конец проверка',oper,'из',vh_oper,sep=' '))
  }#конец перебора всех выходов
  
  
  #print(paste('конец проверка из',vh_oper,'/nrow(dann)=',nrow(dann),sep=' '))
  if (nrow(dann)>0){
    #print(paste('приборка',vh_oper,sep=' '))
    # смотрим, что вообще осталось от данных
    dann$rez=pmin(dann$rez,1-dann$zan); dann$zan=NULL;
    sumk=sum(dann$kk)
    vibor=vhodi$vibor;vib=vibor[(vibor$oper==vh_oper),];
    # ogr=vhodi$ogr
    #если данных много - приписать к результату
    #print(paste('приборка.2',vh_oper,nrow(dann),vib$neiroset,sep=' '))
    #print(paste('приборка.2.2',nrow(dann),sep=' '))
    #print(paste('приборка.2.3',vib$neiroset,sep=' '))
    dann$oper=vh_oper;dann$neiroset=vib$neiroset
    #print(paste('приборка.3',vh_oper,sep=' '))
    
    
    if (vib$new>0){}else{
      #если мало данных, или итог не идёт в нейросеть - уничтожить данные 
      if (((sumk<vib$min_kol)&(vh_oper>0))|(is.na(vib$neiroset))) {
        dann=dann[(dann$oper==-1),]}}
    
  }
  #print(paste('приборка.4 vh_oper=',vh_oper,'vhodi$vibor$new:',sep=' '))
  #print(paste(vhodi$vibor$new,sep=' '))
  if (is.null(dann_rez)) {dann_rez=dann}else{
    dann_rez=myPackage$sliv(dann_rez,dann)}
  if (nrow(dann_rez)==0) {dann_rez=NULL}
  
  rez=list();rez$dann=dann_rez;rez$vhodi=vhodi
  return(rez)
  rm(dann,dann_op,dann_rez,ogr,vh,vib,vibor,o,oper,razdvoen,rez,sumk,vh_oper,vhod,vhodi)
  rm(dann_rek,dns,ogr_n,vib_n,rek)
}
# пример запуска  rek=neural$neir.dannie_rekurs(dann,vhodi,vh_oper) 






##############################################################################
# все входы типа массивов - пронумеровать (едино для всех нейросетей в настройке)
myPackage$neir.dann_mass <- function(neir,dannie) {
  # входные данные = neir,dannie
  
  vh=neir$vhodi;vh$name=NA;vh$kol_zn=NA
  mas=vh[(vh$tip=='mas'),];vh=vh[(vh$tip!='mas'),]
  mas$name=paste('m',mas$nom,sep='');
  
  mass=neir$mass #старые значения массивов, и по умолчанию - создать пустую
  if (is.null(mass)) {
    mass=subset(mas,select=c('nm_','nom'));mass$name='-';mass$zn='-'
    mass=mass[(mass$nom==0),];kol_mas=0;}
  kol_mas=nrow(mass)
  
  for (nom in mas$nom){
    nm_=as.character(mas[(mas$nom==nom),'nm_'])
    nm=as.character(mas[(mas$nom==nom),'name'])
    dn=unique(subset(dannie,select=c(nm_)));
    
    dn$name=nm;dn$nm_=nm_;dn$zn=as.character(dn[,nm_]);
    dn=merge(dn,mass,by=c('nm_','zn','name'),all=TRUE)
    dn=dn[(!is.na(dn[,nm_])),];kz=nrow(dn[(is.na(dn$nom)),])
    if (kz>0){dn[(is.na(dn$nom)),'nom']=(1:kz)+kol_mas}
    dn[,nm]=dn$nom
    pol=c(nm_,nm);dn_=subset(dn,select=pol)
    dannie=merge(dannie,dn_,by=nm_);dannie[,nm_]=NULL;
    dn[,nm_]=NULL;dn[,nm]=NULL;
    
    mass=unique(rbind(mass,dn));kol_mas=kol_mas+kz
  }
  vh=rbind(vh,mas);neir$vhodi=vh;neir$mass=mass
  
  result=list(dann=dannie,neir=neir)
  return(result)
}










#############################################################################
# исходя из постройки разбить все наблюдения на подмножества, и обработать массивы
neural$neir.dann_razbiv <- function(neir) {
  # на входе нейросеть (со всеми входами) и данные. На выходе они же (или только данные)
  
  dann=neural$dannie# входное и выходное множества - теперь разной мощности
  dann=dann[(!is.na(dann$row)),];dann$prg=0;dann[(is.na(dann$yy)),'prg']=1
  all_ogr=neir$all_ogr;all_vibor=neir$all_vibor;
  all_vibor$kol=NULL;all_vibor$skol=NULL;
  if (is.null(all_vibor$new)){all_vibor$new=0}
  if (is.null(all_vibor$kol_m)){all_vibor$kol_m=NA}
  if (is.null(all_vibor$kol_mas)){all_vibor$kol_mas=NA}
  
  #улучшить min_kol
  str=neir$param_str
  if (!is.null(str)){
    str=aggregate(x=subset(str,select=c('rebro')),by=subset(str,select=c('neiroset')), FUN="max" )
    str$kol_str=str$rebro;str$rebro=NULL
    all_vibor$kol_str=NULL
    all_vibor=merge(all_vibor,str,by='neiroset',all=TRUE)
    all_vibor$kol_mas=as.integer(all_vibor$kol_mas)
    all_vibor$min_kol=10*(all_vibor$kol_mas+all_vibor$kol_str)
  }
  
  #взять изначально только нужные поля данных
  vh=neir$vhodi;
  vh_=vh[(is.na(vh$name)),];vh_$name=vh_$nm_;
  vh_=vh_[(vh_$tip!='xz'),];vh_=vh_[(vh_$tip!='xs'),];vh_=vh_[(!is.na(vh_$nm)),]
  vh=vh[(!is.na(vh$name)),];vh=rbind(vh,vh_)
  zn=vh[(vh$tip=='yy'),'max'];ogr=as.character(vh[(vh$tip=='ogr'),'nm_'])
  dann$y=dann$yy/zn
  if (nrow(vh[(vh$tip=='ogr'),])>0)
  {nm=as.character(vh[(vh$tip=='ogr'),'name']);dann[,nm]=dann[,ogr]/zn}
  dann=subset(dann,select=c(as.character(vh$name),'yy',ogr))
  rm(vh,vh_,ogr,zn)
  # дополнить полями
  all_vibor$oper=as.integer(all_vibor$oper) #иногда на входе строковая переменная
  kol_oper=max(all_vibor$oper)+1; # с фиктивной послед опер - для предварит проверки
  dann$kk=1;dann[(is.na(dann$y)),'kk']=0;#признак - строка в настройку (1) или в прогноз (0)
  dann$rez=1 # признак - по данной записи суммируется итоговая ошибка, (1 значение row имеют несколько записей в разных нейросетях)
  dann$oper=0;dann$neiroset=NA
  
  #входные параметры
  vhodi=list();vhodi$ogr=all_ogr;vhodi$vibor=all_vibor;
  vhodi$vhodi=neir$vhodi;vhodi$mass=neir$mass;vh_oper=0
  
  #  рекурсивный процесс формирования данных
  rek=neural$neir.dannie_rekurs(dann,vhodi,vh_oper) 
  dann_rek=rek$dann;vhodi=rek$vhodi
  vibor=vhodi$vibor;neir$all_vibor=vibor # возвращены входы - изменение по новой выборке в части фильтра и массивов на вход
  neir$all_ogr=vhodi$ogr
  
  #поменять форматы на числовые
  ogr=neir$all_ogr;out=unique(ogr$out)
  for (nm in out){if(nm %in% names(dann_rek)){dann_rek[,nm]=as.numeric(dann_rek[,nm]) }}
  
  #удаление лишних полей из данных
  dann_rek$kol=dann_rek$kk;dann_rek$kk=NULL;dann_rek$oper=NULL
  
  #надо ненужные номера нейросетей удалить (сделать NA, а количества = нули)
  dn=dann_rek;dn$skol=1;dn$prg=1-dn$kol;
  dn=aggregate(x=subset(dn,select=c('kol','skol','prg','rez')),by=subset(dn,select=c('neiroset')), FUN="sum" )
  vibor=neir$all_vibor;vibor$kol=NULL;vibor$skol=NULL;vibor$rez=NULL;vibor$prg=NULL
  vibor=merge(vibor,dn,by=c('neiroset'),all=TRUE);
  
  vibor[(is.na(vibor$kol)),'kol']=-1 #избавиться от NA
  vibor[(is.na(vibor$min_kol)),'min_kol']=0 #избавиться от NA
  vibor[(vibor$kol<vibor$min_kol),'kol']=-1
  
  #удалить номера нейросетей, там где нет данных - кроме первой нейросети
  o=((vibor$kol==-1)&(vibor$oper>0));if (nrow(vibor[o,])>0){vibor[o,c('kol','skol','prg','rez','neiroset')]=NA}
  neir$all_vibor=vibor
  
  # вычеркнуть лишние операции, которые не выдают данных
  ogr=neir$all_ogr;vibor=neir$all_vibor;kol=1
  # собственно вычеркнуть лишние операции, которые не выдают данных
  while(kol>0){
    oper=as.character(vibor$pred_oper)
    vib=vibor[(!(vibor$oper %in% oper)),]  
    vib=vib[(is.na(vib$neiroset)),]  
    kol=nrow(vib);vibor=vibor[(!(vibor$oper %in% vib$oper)),] }
  
  # ввести новую нумерацию
  oper=subset(vibor, select = c('oper'));oper$k=1
  o=order(oper$oper);oper=oper[o,]
  oper$op=(1:nrow(oper))-1;oper$k=NULL
  # приклеить новую нумерацию
  ogr=merge(ogr,oper,by=c('oper'));ogr$oper=ogr$op;ogr$op=NULL
  vibor=merge(vibor,oper,by=c('oper'));vibor$oper=vibor$op;vibor$op=NULL
  oper$pred_oper=oper$oper;oper$oper=NULL
  vibor=merge(vibor,oper,by=c('pred_oper'));vibor$pred_oper=vibor$op;vibor$op=NULL
  neir$all_ogr=ogr;neir$all_vibor=vibor;
  
  #выкинуть из структуры описания лишних нейросетей
  str=neir$param_str
  if (!is.null(str)){
    vib=unique(subset(neir$all_vibor,select = c('neiroset')))
    str=merge(str,vib,by='neiroset')
    o=order(str$neiroset,str$rebro);str=str[o,]
    str=unique(str)
    #str=as.data.frame(as.data.table(str))
    neir$param_str=str}
  
  # сокращение объёма памяти
  for (nm in c('neiroset','rez','kol','row')){
    dann_rek[,nm]=as.integer((dann_rek[,nm]))}
  
  #итоговый вывод данных
  neir$dann=dann_rek
  return(neir)
  rm(all_ogr,all_vibor,dann,dann_rek,dn,ogr,oper,str,vib,vibor)
  rm(kol,kol_oper,nm,o,out,rek,vh_oper,vhodi,neir)
}
# пример запуска
# neir=neural$neir.dann_razbiv(neir,dann);dann_=neir$dann;neir$dann=NULL;






#правильная постановка числовых параметров данных и нейросети
neural$neir.dann_param <- function(neir) {
  i=1;reb=1; #### чтобы нормально удалить поля
  
  vh=neir$vhodi;vib=neir$all_vibor;ogr=neir$all_ogr;
  mass=neir$mass;mas=vh[(vh$tip=='mas'),]
  
  if (is.null(vib$kol_neiron)){vib$kol_neiron=NA}
  #постановки количеств входов X в нейросети
  vib$kol_x=0;
  for (oper in (0:(max(vib$oper))) ){  
    kol=nrow(ogr[(ogr$oper==oper),])
    po=vib[(vib$oper==oper),'pred_oper'];
    pkol=vib[(vib$oper==po),'kol_x'];
    vib[(vib$oper==oper),'kol_x']=(kol+pkol)}
  
  #поставить все возможные значения массива
  param=neir$param_mas;
  vib_=vib[(!is.na(vib$neiroset)),c('oper','neiroset')]
  param_=merge(mass,vib_);param_$zn=param_$nom
  param_=param_[,c('neiroset','zn')]
  if (is.null(param)){param=param_;param$fun=0}else{
    vib_=subset(vib_,select='neiroset')
    param=merge(param,param_,by=c('neiroset','zn'),all=TRUE)
    param=merge(param,vib_,by=c('neiroset'))}
  if (nrow(param[(is.na(param$fun)),])>0){param[(is.na(param$fun)),'fun']=0}
  neir$param_mas=param
  
  #постановки количеств входов M в нейросети
  for (oper in (0:(max(vib$oper))) ){  #  oper=0
    v=vib[(vib$oper==oper),];nset=v$neiroset
    if (!is.na(nset)){
      kol_m=0
      for (nm in mas$name){ 
        if (v[,nm]!=0){zn=mass[(mass$name==nm),'nom']
        param[(param$zn %in% zn)&(param$neiroset==nset),'fun']=NA}else{
          kol_m=kol_m+1;nm_=paste('mm',kol_m,sep='');
          vib[(vib$oper==oper),nm_]=nm;
        }}
      vib[(vib$oper==oper),'kol_m']=kol_m
      par=param[(param$neiroset==nset),]
      par=par[(!is.na(par$fun)),]
      vib[(vib$oper==oper),'kol_mas']=nrow(par)
    }}
  vib$kol_neiron=1+vib$kol_x+vib$kol_m
  # вернуть в нейросеть
  neir$all_vibor=vib;neir$param_mas=param
  
  #постановка структуры нейросети, если её нет - создать, для каждой нейросети по отдельности
  param=neir$param_str
  vib_=vib[(!is.na(vib$neiroset)),c('kol_neiron','neiroset')]
  nsets=vib_$neiroset
  neiroset=0;par=as.data.frame(neiroset);par$rebro=0;par$vhod=0;par$vih=0;par$zn=0;
  if (is.null(param)){param=par[(par$neiroset>0),]}     
  
  #перебор всех нейросетей, если нет структуры - создать
  for (nset in nsets){
    par_=param[(param$neiroset==nset),]
    if (nrow(par_)==0){
      par$neiroset=nset;reb=0;
      vib_=vib[((vib$neiroset==nset)&(!is.na(vib$neiroset))),]
      kol=vib_$kol_neiron;
      par$vih=kol
      for (i in (0:kol)){  
        reb=reb+1;par$vhod=i;par$rebro=reb;par_=rbind(par_,par)}   
      #поставить случайный тип нейрона, включая 0 тип
      par_[(par_$vhod==par_$vih),'zn']=round(runif(1)*(1+neural$max_tip_neir)-0.5)
      #ещё ребро - коэф ограничителя, если он вообще есть 
      reb=reb+1;par$vhod=NA;par$rebro=reb;par$zn=0.3;par_=rbind(par_,par);par$zn=0
      param=rbind(param,par_)
    }}
  
  #Если vhod=vih то это тип нейрона (целое число, 0=просто сумма)
  neir$param_str=param
  neir$all_vibor$new=NULL
  
  return(neir)
  rm(mas,mass,ogr,par,par_,param,param_,v,vh,vib,vib_,kol,kol_m,neir,neiroset)
  rm(nm,nm_,nset,nsets,oper,pkol,po,zn,i,reb)
}

#пример запуска
# neir=neural$neir.dann_param(neir) 








neural$neir.podstroika <- function(neir) {  
  if (!is.null(neir$param_mas)){ #если не новая пустая нейросеть
    
    vib=neir$all_vibor;ogr=neir$all_ogr;pmas=neir$param_mas # этих пересчитать!
    vh=neir$vhodi;mass=neir$mass #этих просто заменить  
    vhod=neural$vhodi
    
    {# проверка различия числовых входов
      xx=vh[(vh$tip %in% c('xz','xs')),];xx_=vhod[(vhod$tip %in% c('xz','xs')),]
      xx$get=xx$nm_;xx_$get_=xx_$nm_
      xx=merge(xx,xx_,by=c('nm','tip'));xx=xx[,c('get','get_')]
      xx$get=as.character(xx$get);xx$get_=as.character(xx$get_);
      
      # если сами входы отличаются
      if (nrow(xx[(!(xx$get==xx$get_)),])>0){
        ogr=merge(ogr,xx,by='get');ogr$get=ogr$get_;
        ogr$get_=NULL;neir$all_ogr=ogr}
      rm(xx,xx_)}
    
    # проверка массивов
    { # соответствие названий массивов. старых и новых
      mas=vh[(vh$tip=='mas'),];mas_=vhod[(vhod$tip=='mas'),]
      mas_$nm2=mas_$nm_;mas_$name2=mas_$name
      mas_=mas_[,c('nm','nm2','name2')]
      dmas=merge(mas,mas_,by='nm',all=TRUE)
      dmas=dmas[,c('nm_','name','nm2','name2')]
    }
    
    { # изменение количества входов массивов
      dmas$nom=as.integer(substr(dmas$name2,2,5))
      o=order(-dmas$nom);dmas=dmas[o,]
      
      # при изменении числа массивов на входе
      for (nm2 in dmas$nm2){  
        o=(dmas$nm2==nm2);
        nm=as.character(dmas[o,'nm_'])
        name=as.character(dmas[o,'name'])
        name2=as.character(dmas[o,'name2'])
        # в таблице входов (vib) и выборок (ogr)
        if (!is.na(nm)){
          ogr[,nm2]=ogr[,nm];ogr[,name2]=ogr[,name];
          vib[,nm2]=vib[,nm];vib[,name2]=vib[,name];}else{
            ogr[,nm2]=NA;ogr[,name2]=-1;
            vib[,nm2]=NA;vib[,name2]=-1}
        mm=paste('m',name2,sep='')
        if (!(mm %in% names(vib))){vib[,mm]=NA}
      }
    }
    
    { # изменение количества значений массивов
      dmas$nom=NULL
      mass=merge(mass,dmas,by=,c('nm_','name'))
      mass$nm_=mass$nm2;mass$name=mass$name2
      mass$nm2=NULL;mass$name2=NULL
      
      #изменения значений массива
      mass_=neural$mass;mass_$nom2=mass_$nom;mass_$nom=NULL
      dmass=merge(mass,mass_,by=c('nm_','name','zn'),all=TRUE)
      dmass=dmass[(!is.na(dmass$nom2)),]
      
      dmass=dmass[,c('nom','nom2','name')]
      dd=dmass[c(1,2),];dd$nom=(-1:0);dd$nom2=(-1:0);dd$name=''
      dmass=unique(rbind(dd,dmass));rm(dd)
      
      dmass_=dmass[,c('nom','nom2')]
      # при изменении количества значений массивов
      for (nm in dmas$name2){ 
        ogr$nom=ogr[,nm];ogr=merge(ogr,dmass_,by='nom');ogr[,nm]=ogr$nom2
        ogr$nom=NULL;ogr$nom2=NULL;
        vib$nom=vib[,nm];vib=merge(vib,dmass_,by='nom');vib[,nm]=vib$nom2
        vib$nom=NULL;vib$nom2=NULL;}
    }  
    
    { # пересчитать значения массивов - предварительно справочник
      dmass=dmass[(dmass$nom2>0),]
      nset=pmas;nset$id=1;nset=unique(nset[,c('neiroset','id')])
      dmass_=merge(dmass,nset);dmass_$id=NULL
      dmass_$zn=dmass_$nom;dmass_$nom=NULL
      
      # собственно пересчёт
      pmas=merge(pmas,dmass_,by=c('neiroset','zn'),all=TRUE)
      pmas=pmas[(!is.na(pmas$nom2)),] #чего теперь нет - выкинуть
      pmas$iz=1-(is.na(pmas$fun))
      
      pp=aggregate(x=subset(pmas,select=c('iz')),
                   by=subset(pmas,select=c('neiroset','name')), FUN="max" )
      pmas$iz=NULL;pmas=merge(pmas,pp,by=c('neiroset','name'))
      
      pmas[((pmas$iz==1)&(is.na(pmas$fun))),'fun']=0 #новое используемое значение - по умолчанию
      pmas$zn=pmas$nom2;pmas$nom2=NULL;pmas$iz=NULL;pmas$name=NULL
    }
    
    #внесение изменений обратно
    neir$all_vibor=vib;neir$all_ogr=ogr;neir$param_mas=pmas;
    neir$mass=neural$mass;neir$vhodi=neural$vhodi;
    # на всякий случай - первоописание тоже меняется
    neir$vhod$mas=neural$vhod$mas
    neir$vhod$xz=neural$vhod$xz
    neir$vhod$xs=neural$vhod$xs
    neir$vhod$y=neural$vhod$y
    neir$vhod$y_ogr=neural$vhod$y_ogr
    
    
    # если есть различия с прошлым
    if (is.null(neir$vhod$kol_mass)){neir$vhod$kol_mass=0}
    if ( (neir$vhod$kol_xz!=nrow(as.data.frame(neir$vhod$xz))) |
         (neir$vhod$kol_xs!=nrow(as.data.frame(neir$vhod$xs))) |
         (neir$vhod$kol_mas!=nrow(as.data.frame(neir$vhod$mas))) |
         (neir$vhod$kol_mass!=nrow(neir$mass)) ) {neir$vhod$good=1}
    
    # поставить количества параметров
    neir$vhod$kol_xz=nrow(as.data.frame(neir$vhod$xz))
    neir$vhod$kol_xs=nrow(as.data.frame(neir$vhod$xs))
    neir$vhod$kol_mas=nrow(as.data.frame(neir$vhod$mas))
    neir$vhod$kol_mass=nrow(neir$mass)
    
    rm(dmas,dmass,dmass_,mas,mas_,mass,mass_,nset,ogr,pmas,pp,vh,vib,mm,name,name2,nm,nm2,o,vhod)
  }
  return(neir)
  rm(neir)
}
#   пример   neir=neural$neir.podstroika(neir) 









#на основе нейросети и исх.данных построить связку нейросеть с данными, со всеми параметрами 
neural$neir.dannie_all <- function(neir) {  
  #если список входов успел измениться
  neir=neural$neir.podstroika(neir) 
  # исходя из постройки разбить все наблюдения на подмножества, и обработать массивы
  neir=neural$neir.dann_razbiv(neir)
  #правильная постановка числовых параметров данных и нейросети
  neir=neural$neir.dann_param(neir) 
  neir$vhod$kol_oper=max(neir$all_vibor$oper)
  
  neir$vhod$max_dat=neural$vhod$max_dat #постановка максимальной даты
  
  return(neir)
  rm(neir)
}
#пример neir=neural$neir.dannie_all(neir)





#####################

# из любой модели (вообще - любой list) - делает строку
myPackage$neir.pack <- function(model) {  #было  myPackage$trs.pack
  # Упаковывает обученную модель в бинарное представление
  # Args:  model: обученная модель
  # Returns:   упакованное бинарное представление
  # вместо UTF-8  поставил bytes
  locale <- Sys.getlocale("LC_COLLATE")
  if (Sys.getlocale("LC_COLLATE") == "en_US.UTF-8") {
    Sys.setlocale(locale = "en_US.ISO-8859-1")
  } else {
    Sys.setlocale(locale = "english")
  }
  l <- list("model" = model)
  f <- file(description = "")
  saveRDS(l, f, ascii = TRUE)
  result <- paste(readLines(f, encoding = "bytes"), collapse = "\n")
  close(f)
  Sys.setlocale(locale = locale)
  return (iconv(result, to = "UTF-8"))
}

# обратно, из строки делает list (модель)
myPackage$neir.unpack <- function(s) {     #было myPackage$trs.unpack
  # Распаковывает упакованную модель
  # Args:  s: бинарное представление упакованной модели
  # Returns:  распакованную модель
  locale <- Sys.getlocale("LC_COLLATE")
  if (Sys.getlocale("LC_COLLATE") == "en_US.UTF-8") {
    Sys.setlocale(locale = "en_US.ISO-8859-1")
  } else {
    Sys.setlocale(locale = "english")
  }
  if (typeof(s) != "character") {s <- as.character(s)}
  s <- iconv(s, from = "UTF-8")
  t <- textConnection(s, encoding = "bytes"); result <- readRDS(t);  close(t)
  rez=result$model
  Sys.setlocale(locale = locale)
  return (rez)
}








   
   
   
   
   
   
   
   

#агрегация месячных данных - сапсаны (сперва пасс, потом вагоны) и прочие (вагоны, потом пасс)
#   name='sahalin';
#   name='doss'; 
#   myPackage$trs.Data.aggregate_month(name)


#Экстракция данных в базу, всё что есть. Хранит историю продажи в kol_day дней
#   kol_day=1
#   name='sahalin';
#   myPackage$trs.tData.extract(name,kol_day) 



#постановка нейросети базовые параметры
#   neir=list();neir$vhod=list()
#   neir$vhod$name=name;neir$vhod$y='kp1' #какое поле идёт в прогноз
#кого принципиально можно в массив, на вход по данным, и вход по текущему значению (ограничение, цена...)
# neir$vhod$mas=c('Train','Type','Klass','First','Skor','Napr','pzd','weekday','day')
# neir$vhod$xz=c('kp1','pkm1','plata1','rent1','cena1','FreeSeats','kp7','kp14','kp21')
#neir$vhod$y_ogr=c('Seats');neir$vhod$dat=c('Date')
#по описанию нейросети прочитать данные, оставить лишь всё нужное
#   result=neural$neir.dann_first(neir)
#   neir=result$neir;dann=result$dann;rm(result)


   

#####################################################################
# попытка создать структуру нейросети нейросетей
# исходно нейросеть=1, опер=0

# dn_mas=neir$vozm_vibori;dn_mas$kol=NULL
# mas=neir$vhodi;mas=mas[(mas$tip=='mas'),]
# vibor=dn_mas[1,];vibor$oper=0;vibor$pred_oper=0;vibor$neiroset=1;all_vibor=vibor;

# ogr=dn_mas[8,];ogr$oper=1;
# vibor=ogr;vibor$pred_oper=0;vibor$neiroset=2
# ogr$get='xz3';ogr$out='x1';ogr$plus=30
# all_ogr=ogr;all_vibor=rbind(all_vibor,vibor);

# ogr=dn_mas[7,];ogr$oper=2;
# vibor=dn_mas[1,];vibor$oper=2;vibor$pred_oper=1;vibor$neiroset=3
# ogr$get='xz3';ogr$out='x2';ogr$plus=35
# all_ogr=rbind(all_ogr,ogr);all_vibor=rbind(all_vibor,vibor);

# all_vibor$min_kol=1000;neir$all_ogr=all_ogr;neir$all_vibor=all_vibor
# rm(ogr,vibor,mas,dn_mas,all_ogr,all_vibor)

# исходя из постройки разбить все наблюдения на подмножества, и обработать массивы
# res=neural$neir.dann_razbiv(neir,dann)
# dn_neir=res$dann;neir=res$neir;rm(res)



#оставление из результатов только заведомо лучших - ежели такие есть.
neural$neir.best_res <- function (res,best_res){
  if (!is.null(best_res)){
    res=res[(res$neiroset>1),]
    res=merge(res,best_res,by='row',all=TRUE)
    res=res[(res$kol==1),] #прогнозы на будущее отсекаем 
    res$k=0
    for (nm in c('err_sr','err_95')){   # убрал 'err'
      nm_=paste(nm,'_',sep='');
      o=((res[,nm]<=res[,nm_])|(is.na(res[,nm_])));
      res[o,'k']=1;res[,nm_]=NULL}
    res=res[(res$k==1),];res$k=NULL
  }
  return(res)
  rm(res,best_res,nm,nm_,o)
}
#пример   result=neural$neir.best_res(result,best_res)


















#процесс генетической настройки из исходной нейросети с параллельными вычислениями
neural$neir.nastroika_paral <- function (name,nname='') {  # time
  #kol_best_neir=1 #сколько лучших сохранять, и из них делать случайные выборки - кого хранить для взятия элементов генов
  
  #print('предварительный рассчёт данных')
  print('predvarit rassch`t dannih')
  itogi=list();
  #results=NULL;best_res=NULL# ??? хорошо бы их прочитать, предварительно записав
  
  #взять старую историю нейросетей и сокращений, и прогнозов
  neir_hist=myPackage$trs.dann_load('neiroset','poln',nname)
  neir_hist_sokr=myPackage$trs.dann_load('neiroset','sokr',nname)   
  results=myPackage$trs.dann_load('neiroset','results',nname) 
  
  if (is.null(neir_hist_sokr$dat_time)){neir_hist_sokr$dat_time=NA} # поле даты-времени ввести
  if (is.null(neir_hist_sokr$kol_mass)){neir_hist_sokr$kol_mass=NA} # поле число значений массивов
  if (is.null(neir_hist_sokr$max_dat)){neir_hist_sokr$max_dat='2017-06-01'} # до какой даты есть данные
  
  err_nm=c('err_95','err_sr') # убрал 'err' - кто идёт в best_res
  #обновление списка лучших значений по наблюдениям
  nhs=neir_hist_sokr;nhs=nhs[((nhs$activ=='1')&(nhs$name==name)),]   
  best_res=nhs[(nhs$good==0),c('id','activ')]
  best_res=merge(results,best_res,by='id')#ищем лишь по полностью настроенным, поднастраивать не будем
  
  best_res=aggregate(x=subset(best_res,select=err_nm),
                     by=subset(best_res,select=c('row')), FUN="min" )
  for (nm in err_nm){nm_=paste(nm,'_',sep='');
  best_res[,nm_]=best_res[,nm];best_res[,nm]=NULL}
  
  results$dat=as.Date(results$dat) #чтобы не было ошибки в форматах данных
  
  
  #выбор нужных id
  nhs=neir_hist_sokr;nhs=nhs[((nhs$activ=='1')&(nhs$name==name)),]   
  
  #если нет данных - создать их
  if (is.null(neural$vhod$name)){neural$vhod$name=NA}
  if ((is.null(neural$dannie))|(name!=neural$vhod$name)){
    #взять нейросеть 
    id=nhs[1,'id']
    neir=as.character(neir_hist[(neir_hist==id),'pack'])
    neir=myPackage$neir.unpack(neir);
    #по описанию нейросети, как по маске, прочитать данные, оставить лишь всё нужное
    neir=neural$neir.dann_first(neir)
    neural$dannie=neir$dann;neir$dann=NULL
    neural$vhod=neir$vhod;neural$vhodi=neir$vhodi
  }
  max_dat=neural$vhod$max_dat
  
  
  
  # бесконечный цикл - внешний. для попытки чистки памяти
  while (1==1){
    
    #подготовка кластеров для распараллеливания  
    cores=max(detectCores()-4,1) #число имеющихся в наличии ядер. одно оставляем в запасе
    clust <- makeCluster(getOption("cl.cores", cores)) #в кластер берём указанное число ядер
    clusterExport(clust, c("myPackage", "neural")) #в кластер в каждое ядро экспортируем параметры
    
    
    #print('начало настройки')
    print('nachalo nastroiki')
    #  цикл в 5 проходов, 15 минут
    for (eee in (1:5)){
      
      print(paste('nachalo_',Sys.time(),sep=''))
      #выбор нужных id
      nhs=neir_hist_sokr;
      max_id=max(nhs$id)#максимум вообще, мало ли что валяется 
      nhs=nhs[((nhs$activ=='1')&(nhs$name==name)),]   
      
      mkol=cores*3;  
      
      #сделать mkol записей пропорционально nhs$kol - кто пойдёт в поднастройку
      ord=subset(nhs,select=c('id','kol','good'))
      ord[(is.na(ord$kol)),'kol']=1 #исправление, когда нет kol
      kk=nrow(ord);ord$n=(1:kk);s=0;ord$z=1;
      for (i in (1:kk)){
        ord[(ord$n==i),'s1']=s;s=s+ord[(ord$n==i),'kol'];ord[(ord$n==i),'s2']=s}
      ss=runif(mkol)*s;ord_=as.data.frame(ss);ord_$z=1;ord_$ord=(1:mkol)
      ord=merge(ord,ord_,by='z')
      ord=ord[((ord$s1<=ord$ss)&(ord$ss<=ord$s2)),c('id','ord','good')]
      # получено - с возможными повторами неполностью настроенных
      ord_=aggregate(x=subset(ord,select=c('ord')),by=subset(ord,select=c('id')), FUN="min" )
      ord_$mord=ord_$ord;ord_$ord=NULL
      ord=merge(ord,ord_,by='id');rm(ord_)
      ord[(ord$mord<ord$ord),'good']=0;ord$mord=NULL #первый вход донастраиваем, прочие - изменяем
      
      
      #добавить переносы генов - что и из кого
      res=results[(!is.na(results$row)),]
      res$r=runif(nrow(res));o=order(res$r);res=res[o,]
      res$ord=(1:nrow(res))
      res=res[(res$ord<=mkol),]
      res$id_=res$id;res$nset_=res$neiroset
      res=res[,c('ord','id_','nset_')]
      ord=merge(ord,res,by='ord')
      
      
      
      #подготовить данные для всех ядер процессора
      neirs=NULL;#koll=0
      neirs <- lapply(FUN = function(ordr) {  #  ordr=1
        ord_=ord[(ord$ord==ordr),]
        id=ord_$id;good=ord_$good;id_=ord_$id_;nset_=ord_$nset_
        #взять нейросеть 
        neir=as.character(neir_hist[(neir_hist$id==id),'pack'])
        neir=myPackage$neir.unpack(neir);
        neir$vhod$good=good
        #neir=neural$neir.plus_uslojn(neir)
        neir$vhod$id_=max_id+ordr;
        #neir$vhod$versia=neir$vhod$versia+1;
        neir$best_res=best_res
        #теперь гены из другой нейросети - если понадобится
        neir_=as.character(neir_hist[(neir_hist==id_),'pack'])
        neir_=myPackage$neir.unpack(neir_);
        neir_$nset_=nset_
        neir$neir_=neir_
        return (neir)}, X = (1:mkol))
      
      
      #сохранить, что буду обрабатывать - на случай ошибки
      neir_new=neir_hist[0,]
      for (neir in neirs){
        #создание строки - запакованной нейросети
        id=neir$vhod$id
        neir_h=data.frame( id=array(id,1));
        neir$best_res=NULL 
        neir_h$pack=myPackage$neir.pack(neir);
        neir_new=rbind(neir_new,neir_h);#приписать и оставить данные о настройках
      }
      myPackage$trs.Data_save(neir_new,'neiroset','new',TRUE,nname) 
      rm(neir_new)
      
      #запустить усложнения/мутации в паралл режиме
      neirs <- parLapplyLB(cl = clust, fun = function(neir) {
        if (is.null(neir$vhod$max_dat)){neir$vhod$max_dat=''}
        if (neir$vhod$max_dat!=max_dat) {neir$vhod$good=1}
        neir=neural$neir.plus_uslojn(neir) #усложнение - если neir$vhod$good=0
        
        if (is.na(neir$vhod$id)){neir$vhod$id=neir$vhod$id_}
        neir$vhod$id_=NULL
        neir$vhod$versia=neir$vhod$versia+1;
        if (!is.na(neir$vhod$error)){neir$vhod$pred_error=neir$vhod$error}
        return(neir)
      }, X = neirs)
      
      
      #сохранить, что буду обрабатывать - на случай ошибки - вторично
      neir_new=neir_hist[0,]
      for (neir in neirs){
        #создание строки - запакованной нейросети
        id=neir$vhod$id
        neir_h=data.frame( id=array(id,1));
        neir$best_res=NULL 
        neir_h$pack=myPackage$neir.pack(neir);
        neir_new=rbind(neir_new,neir_h);#приписать и оставить данные о настройках
      }
      myPackage$trs.Data_save(neir_new,'neiroset','new',TRUE,nname) 
      rm(neir_new)
      
      print(paste('nachalo_2_',Sys.time(),sep=''))
      
      #запустить настройку в паралл режиме
      neirs <- parLapplyLB(cl = clust, fun = function(neir) {
        # привести данные к потребности нейросети
        tm=as.numeric(Sys.time())
        neir=neural$neir.dannie_all(neir)   
        tm=as.numeric(Sys.time())-tm
        mtm=neir$vhod$max_time
        neir$vhod$max_time=mtm-tm
        # настройка по итерациям всех нейросетей множества
        neir=neural$neir.nastr_all(neir) 
        neir$vhod$max_time=mtm
        # результат настройки по всему пулу нейросетей
        result=neural$neir.rez_all(neir)
        #сравнить с лучшими настройками (лучшими из окончательно настроенных)
        result=neural$neir.best_res(result,neir$best_res)
        neir$result=result
        neir$dann=NULL;neir$best_res=NULL;rm(result)
        return(neir)
      }, X = neirs)
      
      
      #обработка результатов параллельных вычислений
      nhs=neir_hist_sokr;print(Sys.time());#nhs$kol=NULL
      if (is.null(nhs$kol_oper)){nhs$kol_oper=NA}
      if (is.null(nhs$pred_error)){nhs$pred_error=NA}
      
      for (neir in neirs){  # if (neir$vhod$id==4693) (nnnnn=neir)}  neir=nnnnn
        id=neir$vhod$id;error=neir$vhod$error;versia=neir$vhod$versia
        #print(paste("нейросеть  ",id," ошибка=",error , sep = ""))
        print(paste("neiroset=  ",id,"/",versia," error=",error , sep = ""))
        res=neir$result;
        if (!is.null(results)){results=results[(results$id!=id),]}
        if (!is.null(res)){
          if (nrow(res)>0){
            res$dat=as.Date(res$dat)
            res$id=id;
            if (is.null(results)){results=res}else{results=rbind(results,res)}}}
        
        #добавить текущую нейросеть к списку в памяти, если надо
        vhod=neir$vhod;
        vhod$mas=NULL;vhod$xz=NULL;vhod$xs=NULL;
        vhod=as.data.frame(vhod);vhod$activ=1;vhod$kol=0
        #создание строки - запакованной нейросети
        neir_h=data.frame( id=array(id,1));
        neir$dann=NULL;neir$result=NULL  
        neir_h$pack=myPackage$neir.pack(neir);
        
        #приписать и оставить данные о настройках
        neir_hist=neir_hist[(neir_hist$id!=id),]
        neir_hist=rbind(neir_hist,neir_h);
        if (nrow(nhs[(nhs$id==id),])>0){nhs[(nhs$id==id),'activ']=0}
        nhs=rbind(nhs,vhod)
      };rm(neirs)
      
      
      #обновление списка лучших значений по наблюдениям
      #nhs=neir_hist_sokr;nhs=nhs[((nhs$activ=='1')&(nhs$name==name)),]   
      best_res=unique(nhs[((nhs$good==0)&(nhs$activ==1)),c('id','activ')])
      best_res=merge(results,best_res,by='id')#ищем лишь по полностью настроенным, поднастраивать не будем
      
      best_res=aggregate(x=subset(best_res,select=err_nm),
                         by=subset(best_res,select=c('row')), FUN="min" )
      for (nm in err_nm){
        nm_=paste(nm,'_',sep='');best_res[,nm_]=best_res[,nm];best_res[,nm]=NULL}
      
      
      #рассчёт статистики - кто чаще хорош, проверка по каждой точке настройки
      res=results[(results$kol==1),];#не прогнозы, а настройки
      res=merge(res,best_res,by='row',all=TRUE);res$kol=0;
      res=res[(!is.na(res$neiroset)),]
      for (nm in err_nm){# по каждому наблюд - насколько хорош по разным показателям из err_nm
        nm_=paste(nm,'_',sep='');
        o=(res[,nm]<=res[,nm_])|(is.na(res[,nm_]));res[o,'kol']=res[o,'kol']+1}
      #итог -  кто чаще хорош
      res=aggregate(x=subset(res,select=c('kol')),by=subset(res,select=c('id')), FUN="sum" )
      
      mkol=max(max(res$kol),20) #максимально возможная лучшесть
      #лучшие по суммарной статистике - должны остаться всяко, и причём в числе лучших!
      nhs_=nhs[(nhs$max_dat==max_dat),]
      o=order(nhs_$error);nhs_=nhs_[o,];id1=nhs_[1,'id']
      o=order(nhs_$ss_err);nhs_=nhs_[o,];id2=nhs_[1,'id'];rm(nhs_)
      res_=res[1,];res_$kol=mkol;res_$id=id1;res_=rbind(res_,res_);res_[2,'id']=id2
      res=res[(!(res$id %in% c(id1,id2))),]
      res=rbind(res,res_)
      
      
      #оставить лишь лучших
      res=res[(res$kol>0),]
      o=order(-res$kol);res=res[o,];res$n=(1:nrow(res))
      res=res[(res$n<=100),];res$n=NULL #выбираем 100 лучших 
      res$act=1;res$kol_=res$kol;res$kol=NULL
      res=unique(res)
      
      #вставить итоги в сохраняемую таблицу
      nhs=merge(nhs,res,by='id',all=TRUE)
      nhs[(is.na(nhs$act)),'activ']=0
      o=(nhs$activ==1);nhs[o,'kol']=nhs[o,'kol_'];nhs$act=NULL;nhs$kol_=NULL
      nhs[(!is.finite(nhs$error)),c('activ','kol')]=0 #на случай бесконечностей
      
      res=nhs[(nhs$activ==1),];res=unique(subset(res,select=c('id')))
      #оставляем лишь лучших
      results=merge(results,res,by='id')
      neir_hist=merge(neir_hist,res,by='id')
      neir_hist_sokr=nhs
      #итоговые размеры ошибок
      nhs=nhs[((nhs$activ==1)&(nhs$max_dat==max_dat)),];err1=min(nhs$error);err2=max(nhs$error)
      
      
      #Запись нейросети в базу, не каждый раз
      myPackage$trs.Data_save(neir_hist,'neiroset','poln',TRUE,nname) 
      myPackage$trs.Data_save(neir_hist_sokr,'neiroset','sokr',TRUE,nname) 
      myPackage$trs.Data_save(results,'neiroset','results',TRUE,nname) 
      
      #print(paste('записано:',err1,err2,sep=' '))
      print(paste('zapisano:',err1,err2,sep=' '))
      
      #  gc() # теоретически это очистка памяти от излишков, но не работает
    } #окончание бесконечного цикла
    
    
    stopCluster(clust)  
    gc() # теоретически это очистка памяти от излишков, но не работает
  }
}
#пример запуска   neural$neir.nastroika_paral(name='sahalin')





# выкинуть из dann лишние поля, сокращение объёма памяти
neuron$neir.sokr_dann <- function(neir) {
  
  zn=names(neir$dann)
  stat=neir$all_stat;filtr=neir$all_filtr;pols=neir$opis_pols;
  
  st=stat[(!is.na(stat$kol_best)),c('nset','kol_best','act')]
  
  st[(st$act==2),'kol_best']=pmax(1,st[(st$act==2),'kol_best'])
  
  st=merge(st,filtr,by='nset')
  st=aggregate(x=subset(st,select=c('kol_best')),by=subset(st,select=c('n_poll')), FUN="sum" )
  
  st=merge(st,pols,by='n_poll')
  
  st=aggregate(x=subset(st,select=c('kol_best')),by=subset(st,select=c('n_pol','zn')), FUN="sum" )
  st=st[(st$zn %in% zn),]
  st=st[(st$kol_best==0),]
  
  #собственно уменьшение числа колонок
  for (nm in st$zn){neir$dann[,nm]=NULL}
  
  # удаление лишних записей по ненужным нейросетям
  mas=neir$all_mass;str=neir$all_str
  stat=neir$all_stat
  ns=as.numeric(stat[((stat$act==3)&(stat$kol_x>=0)),'nset'])
  str=str[(!(str$nset %in% ns)),]
  mas=mas[(!(mas$nset %in% ns)),]
  neir$all_mass=mas;neir$all_str=str
  
  return(neir)
  filtr=1;pols=1;st=1;stat=1;nm=1;mas=1;str=1;stat=1;ns=1;zn=1;
  rm(filtr,pols,st,stat,nm,neir,mas,str,stat,ns,zn)
}
#  пример запуска   neir=neuron$neir.sokr_dann(neir)








#   сделать слияние двух нейросетей
neuron$neir.sliv <- function (neir1,neir2){  
  
  neir=list()
  {# всё что идёт прямым переносом
    neir$mass=neir1$mass
    neir$vhod=neir1$vhod;neir$vhodi=neir1$vhodi
    neir$errors=neir1$errors
    neir$dann=neir1$dann
    neir$all_itogi=neir1$all_itogi
    neir$all_rezult=neir1$all_rezult
  }
  
  {# данные по исходникам
    stat2=neir2$all_stat;stat2=stat2[(stat2$kol_best>0),]
    nsets=stat2$nset
    fil2=neir2$all_filtr;fil2=fil2[(fil2$nset %in% nsets),]
    pols2=neir2$all_pols;pols2=pols2[(pols2$nset %in% nsets),]
    opols2=neir2$opis_pols
    pol2=neir2$opis_pol
    poll2=neir2$opis_poll
    opols_=aggregate(x=subset(opols2,select=c('nom_pol')),by=subset(opols2,select=c('n_poll')), FUN="max" )
    opols_$kol_pol=opols_$nom_pol;opols_$nom_pol=NULL
    n_pol=opols2[(opols2$n_poll %in% fil2$n_poll),]
    n_pol=unique(n_pol$n_pol)
    opols2=opols2[(opols2$n_pol %in% n_pol),]
    
    opols_2=aggregate(x=subset(opols2,select=c('act')),by=subset(opols2,select=c('n_poll')), FUN="sum" )
    opols_=merge(opols_,opols_2,by='n_poll')
    opols_=opols_[(opols_$kol_pol==opols_$act),]
    n_poll=unique(opols_$n_poll)
    opols2=opols2[(opols2$n_poll %in% n_poll),]
    pol2=pol2[(pol2$n_pol %in% n_pol),]
    poll2=poll2[(poll2$n_poll %in% n_poll),]
    rm(opols_,opols_2)
  }
  
  { # первичная статистика
    stat1=neir1$all_stat
    fil1=neir1$all_filtr;fil1=fil1[(fil1$nset %in% stat1$nset),]
    max_nset=max(stat1$nset)+10
    stat2$nset=stat2$nset+max_nset
    stat=rbind(stat1,stat2)
    stat[(stat$act %in% c(2,4)),'act']=1
    neir$all_stat=stat;
    rm(stat1,stat2,stat)}
  
  {# первичные входные переменные
    pol1=neir1$opis_pol;
    pp=pol1;pp$n_pol1=pp$n_pol;pp=pp[,c('has','n_pol1')]
    pol2=merge(pol2,pp,by='has',all=TRUE);pol2=pol2[(!is.na(pol2$n_pol)),]
    max_npol=max(pol1$n_pol)
    pol2$n_pol2=pol2$n_pol+max_npol
    o=(is.na(pol2$n_pol1));pol2[o,'n_pol1']=pol2[o,'n_pol2']
    pol2$n_pol2=NULL
    pp=pol2[,c('n_pol','n_pol1')]
    pol2$n_pol=pol2$n_pol1;pol2$n_pol1=NULL
    pol2=pol2[(pol2$n_pol>max_npol),]
    pol=rbind(pol1,pol2)
    pol$out=paste('z_',as.character(pol$n_pol),sep='')
    neir$opis_pol=pol
    pol=pp;
    rm(pol1,pol2,pp)}
  
  {# создания списков полей
    poll2$n_pol=poll2$plus_pol
    poll2=merge(poll2,pol,by='n_pol')
    poll2$plus_pol=poll2$n_pol1
    poll2$n_pol1=NULL;poll2$n_pol=NULL
    poll1=neir1$opis_poll
    max_npoll=max(poll1$n_poll)
    
    poll2$n_poll=poll2$n_poll+max_npoll
    o=(poll2$pred_poll>0)
    poll2[o,'pred_poll']=poll2[o,'pred_poll']+max_npoll
    poll2$has=NA
    poll=rbind(poll1,poll2)
    neir$opis_poll=poll
    rm(poll,poll1,poll2)
  }
  
  {# установка описаний входов каждой нейросети, со статистикой количеств
    pols1=neir1$all_pols
    pp=pol;pp$zn=paste('z_',as.character(pp$n_pol),sep='')
    pp$zn1=paste('z_',as.character(pp$n_pol1),sep='')
    pp=pp[,c('zn','zn1')]
    pols2=merge(pols2,pp,by='zn',all=TRUE)
    pols2=pols2[(!is.na(pols2$tip)),]
    o=(!is.na(pols2$zn1));
    pols2_=pols2[o,];pols2=pols2[(!o),]
    pols2_$zn=pols2_$zn1
    pols2=rbind(pols2,pols2_)
    pols2$zn1=NULL
    pols2$nset=pols2$nset+max_nset
    pols=rbind(pols1,pols2)
    neir$all_pols=pols
    rm(pols1,pols2,pols2_,o,pp,pols)
  }
  
  {# описания комбинаций входов первично
    opols1=neir1$opis_pols
    opols2=merge(opols2,pol,by='n_pol')
    opols2$n_pol=opols2$n_pol1;opols2$n_pol1=NULL
    opols2$zn=paste('z_',as.character(opols2$n_pol),sep='')
    opols2$n_poll=opols2$n_poll+max_npoll
    opols=rbind(opols1,opols2)
    neir$opis_pols=opols
    rm(opols,opols1,opols2)
  }
  
  {# фильтры
    #fil1=neir1$all_filtr;
    fil2$nset=fil2$nset+max_nset
    o=(fil2$n_poll>0)
    fil2[o,'n_poll']=fil2[o,'n_poll']+max_npoll
    fil=rbind(fil1,fil2)
    neir$all_filtr=fil  
    rm(fil,fil1,fil2)
  }
  
  { #макс-мин значения параметров
    par1=neir1$all_param;par2=neir2$all_param
    par2=par2[(par2$nset %in% nsets),]
    par2$nset=par2$nset+max_nset
    par=rbind(par1,par2)
    neir$all_param=par
    rm(par,par1,par2)
  }
  
  { #постановки значений настроенных массивов
    mas1=neir1$all_mass;mas2=neir2$all_mass
    mas2=mas2[(mas2$nset %in% nsets),]
    mas2$nset=mas2$nset+max_nset
    mas=rbind(mas1,mas2)
    neir$all_mass=mas
    rm(mas,mas1,mas2)
  } 
  
  { # настроенные структуры нейросетей
    str1=neir1$all_str;str2=neir2$all_str
    str2=str2[(str2$nset %in% nsets),]
    str2$nset=str2$nset+max_nset
    str=rbind(str1,str2)
    neir$all_str=str
    rm(str,str1,str2)
  }
  
  return(neir)
  rm(pol,max_npol,max_npoll,max_nset,n_pol,n_poll,nsets,o,neir1,neir2,neir)
}

#пример запуска    neir=neuron$neir.sliv(neir1,neir2)











#НАДО - СОЗДАТЬ СИСТЕМУ ПОДСКАЗОК
neuron$neir.podskazka <- function(neir)
{
  ## старые исходники
  
  filtr=neir$all_filtr
  poll=neir$opis_poll;pols=neir$opis_pols;pol=neir$opis_pol
  
  #убрать всю наработку
  filtr=filtr[(filtr$n_poll==0),]
  poll=poll[(poll$n_poll==0),]
  pols=pols[(pols$n_poll==0),]
  
  vh=neir$vhodi
  mas=vh[(vh$tip=='mas'),]
  xx=vh[(vh$tip %in% c('xz','xs')),]
  xx$get=xx$nm_;xx=xx[,c('nm','get','tip')]
  
  { # поиск вариантов фильтраций в подсказку, все варианты, где хоть один из массивов (не дат) ='-'
    mas_=mas[(is.na(mas$dat)),]
    mas_=as.character(mas_$name)
    
    mass=neir$mass
    mass=mass[(mass$name %in% mas_),]
    mass=mass[(mass$zn=='-'),]
    
    dn=neuron$dannie;dn=unique(dn[,mas_]);dn$k=0
    for (nom in mass$nom){
      nm=as.character(mass[(mass$nom==nom),'name'])
      o=(dn[,nm]==nom);dn[o,'k']=1;dn[(!o),nm]=0
    }
    
    dn=unique(dn);dn$k=NULL
    for (nm in mas[(!is.na(mas$dat)),'name']){dn[,nm]=-1}
  }
  
  
  #А ТЕПЕРЬ СОЗДАТЬ КОМБИНАЦИЮ ПОЛЕЙ
  
  { ## 1- создать новые входы
    podskaz=c('kp1','Seats') # первично кто идёт в подсказку
    xx_=xx[(xx$nm %in% c( podskaz,paste('s',podskaz,sep='_'))),]
    
    before=neir$vhod$before
    before=c(before,364,365+before,0)
    before=c(before,round((before+3)/7)*7)
    before=unique(as.data.frame(before))
    
    pp=merge(xx_,before)
    
    #заблаговременно известны только места
    pp=pp[((pp$before>0)|(pp$nm %in% c('Seats','s_Seats'))),]
    
    pp$zapazd=7;pp[(pp$tip=='xz'),'zapazd']=NA
    pp$nm=NULL;pp$tip=NULL
    
    # добавление признаков выборки
    pp=merge(pp,dn)
    
    
    ## 2- приписать входам значения хэш-функций
    pp$has=NA;pp$nn=(1:nrow(pp))
    for (nn in pp$nn){
      pp_=pp[(pp$nn==nn),];pp_$has=NULL;pp_$nn=NULL
      has=neuron$digest(pp_);pp[(pp$nn==nn),'has']=has}
  }
  
  {## 3- найти, какие уже были, и новые добавить
    pol_=pol[,c('has','n_pol')]
    pp=merge(pp,pol_,by='has',all=TRUE)
    pp=pp[(!is.na(pp$nn)),]
    max_npol=max(pol$n_pol)
    
    o=(is.na(pp$n_pol));pp_=pp[o,];
    if (nrow(pp_)>0) {pp_$n_pol=(1:nrow(pp_))+max_npol}
    pp=pp[(!o),];pp=rbind(pp,pp_);pp$nn=NULL;pp$act=1
    pp$out=paste('z',pp$n_pol,sep='_')
  }
  
  # 4-запись в базу с новыми вариантами входных полей
  pp_=pp[(pp$n_pol>max_npol),]
  pol=rbind(pol,pp_)
  neir$opis_pol=pol
  
  
  ###теперь надо выбрать лучший порядок входа этих полей (=pp)
  
  
  # для случая огромного числа входов
  {
    {# построить входы в среднем по 10 штук, и задать их очерёдность
      pp_=pp[,c('n_pol','out','has')]
      z=(1:10);z=as.data.frame(z)
      pp_=merge(pp_,z);pp_$z=NULL
      pp_$nn=round(runif(nrow(pp_))*nrow(pp)+0.5)
      
      pp_=unique(pp_)
      pp_$i=runif(nrow(pp_))
      o=order(pp_$nn,pp_$i);pp_=pp_[o,]
      pp_$nom=(1:nrow(pp_))
      
      o=aggregate(x=subset(pp_,select='nom'),by=subset(pp_,select='nn'), FUN="min" )
      o$nnom=o$nom;o$nom=NULL
      pp_=merge(pp_,o,by='nn')
      pp_$nom_pol=pp_$nom+1-pp_$nnom
      pp_$nnom=NULL;pp_$i=NULL;pp_$nom=NULL
      pp_$zn=pp_$out;pp_$out=paste('x',pp_$nom_pol,sep='')
    }
    
    # теперь создать последовательности входов - дописать в структуру
    max_poll=max(poll$n_poll)
    for (nn in unique(pp_$nn)){
      n_poll=0;ppz=pp_[(pp_$nn==nn),];ppz$nn=NULL
      for (nom in (1:max(ppz$nom_pol))){ #  nom=5
        pred_poll=n_poll;
        ppf=ppz[(ppz$nom<=nom),]
        has=ppf[,c('has','out')];has$out=NULL;has=neuron$digest(has)
        if (has %in% poll$has){ # старое - опознать и без записи
          n_poll=poll[(poll$has==has),'n_poll']
        } else{ #если комбинация входов новая
          max_poll=max_poll+1
          n_poll=max_poll
          ppf$n_poll=n_poll;ppf$act=1
          pols=rbind(pols,ppf) # записал в pols
          ppf=ppz[(ppz$nom_pol==nom),]
          ppf$n_poll=n_poll
          ppf$pred_poll=pred_poll
          ppf$plus_pol=ppf$n_pol
          ppf$n_pol=NULL;ppf$out=NULL;ppf$nom_pol=NULL;ppf$zn=NULL
          ppf$has=has;ppf$kol_pol=nom;ppf$act=1
          poll=rbind(poll,ppf)
        }
      }
    }
    
    
    {#теперь пополнить количество нейросетей в настройку
      fil=poll[,c('n_poll','act')]
      fil=fil[(!(fil$n_poll %in% filtr$n_poll)),]
      max_nset=max(filtr$nset)
      fil$nset=max_nset+(1:nrow(fil))
      fil[,c('vib','poln')]=1;fil$act=NULL
      for (nm in mas$name){fil[,nm]=0}
      fil$pred_nset=0;fil$pred_row=NA;fil$progr='dob'
      filtr=rbind(filtr,fil)
    }
    
  }
  
  neir$all_filtr=filtr
  neir$opis_poll=poll;
  neir$opis_pols=pols
  
  return(neir)
  
  rm(before,fil,filtr,mas,nn,pol,pol_,poll,pols,pp,pp_,vh,xx,xx_)
  rm(has,max_npol,max_nset,max_poll,nm,o,dn,mass,ppf,ppz,z,mas_,n_poll)
  rm(nom,podskaz,pred_poll)
  
}
#пример  neir=neuron$neir.podskazka(neir)











##########################################################################
#нечто в поиске проблемы утечки памяти:
# install.packages("ggplot2") 
# install.packages("pryr") 
# install.packages("devtools")
# devtools::install_github("hadley/lineprof")
#  gc() - что-то показывает, и прекращает оборваный процесс по ядрам












   

