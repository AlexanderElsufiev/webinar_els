
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






#функции нейронов для нейросети, и их производных
neural=list();
neural$f2 <- function (v) {return ( v**2)}
neural$pr2 <- function (v) {return ( 2*v)}

neural$f1 <- function (v) {return ( abs(v))}
neural$pr1 <- function (v) {return ( sign(v))}

neural$f0 <- function (v) {return ( v)}
neural$pr0 <- function (v) {return ( 1)}

neural$f3 <- function (v) {return ( exp(v))}
neural$pr3 <- function (v) {return ( exp(v))}
neural$max_tip_neir=3






#Вычисление размера ошибки нейросети на данной настройке 
neural$neir.err <- function (str,vib,mas,dn,is_rez) {
  #Вначале параметры
  kol_x=vib$kol_x;kol_m=vib$kol_m;kol_neir=vib$kol_neiron
  kol_reb=max(str$rebro)
  #   str$zn=1;str[(is.na(str$vhod)),'zn']=0.3
  #сперва значение нейронов массивов
  if (kol_m>0) {for (i in (1:kol_m)){ #    i=1
    nm=paste('x',i+kol_x,sep='');nm_=paste('mm',i,sep='');nm_=vib[,nm_]
    dn[,nm]  = mas[dn[,nm_],'fun']}}
  
  #теперь работа по каждому ребру
  for (reb in (1:kol_reb)){   #   reb=0   reb=reb+1
    vhod=str[(str$rebro==reb),'vhod'];vih=str[(str$rebro==reb),'vih'];
    nm=paste('x',vih,sep='');nm_=paste('x',vhod,sep='')
    zn=str[(str$rebro==reb),'zn'];
    
    #вычисление значения на ребре
    if (is.na(vhod)) {
      nm_='y_ogr';v=(dn[,nm]>dn[,nm_]) #ограничитель
      dn[v,nm]=dn[v,nm_]+zn*(dn[v,nm]-dn[v,nm_]) 
    } else {    
      if (vhod==0) {dn[,nm]=zn} else {
        if (vhod<vih) {dn[,nm]=dn[,nm]+zn*dn[,nm_]} else{
          if (vhod==vih) { #функции нейронов
            if (zn==0) {dn[,nm]=neural$f0(dn[,nm])}
            if (zn==1) {dn[,nm]=neural$f1(dn[,nm])}
            if (zn==2) {dn[,nm]=neural$f2(dn[,nm])}
            if (zn==3) {dn[,nm]=neural$f3(dn[,nm])}
          }}}}
  }
  #nm=paste('x',kol_neir,sep=''); - должно остаться на выходе значение
  nm_='y'
  err=sum((dn[,nm]-dn[,nm_])**2)
  err_=list();err_$err=err;
  
  #если надо не только ошибку, но и данные на выход
  if (is_rez){
    vh=neural$vhodi;
    ogr=as.character(vh[(vh$tip %in% c('dat','ogr')),'nm_']) #поля на сохранение
    dn$zn=vib$max_y*dn[,nm]
    dn=subset(dn,select=c('row','yy',ogr,'rez','kol','neiroset','zn'))
    dn$err=abs(dn$yy-dn$zn)
    
    #количество настроечных полей
    koll=vib$kol_mas +nrow(str)  #  nrow(mas[(!is.na(mas$fun)),]) +
    #вычислить среднеквадратичное значения ошибок
    dn_=dn[(dn$kol==1),];
    if (nrow(dn_)>0){
      dn_$err2=dn_$err**2;dn_$err2r=dn_$err2*dn_$rez
      err=aggregate(x=subset(dn_,select=c('kol','err2','err2r','rez')),
                    by=subset(dn_,select='neiroset'), FUN="sum" )
      merr=aggregate(x=subset(dn_,select=c('err2r')),by=subset(dn_,select='neiroset'), FUN="max" )
      merr$merr=merr$err2r;merr$err2r=NULL
      err=merge(err,merr,by='neiroset')
      #среднекадратичное
      if (err$kol>koll){
        err$s_err=(err$err2/(err$kol-koll))**0.5}else{
          #теоретически - это мб только в корневой нейросети
          err$s_err=err$merr**0.5}
      # если ошибка (по результ) больше среднеквадр
      if ((err$s_err**2)*err$rez<err$err2r) {
        if (err$rez>koll){ # если достаточно строк, или мало - просто максимум
          err$s_err=(err$err2r/(err$rez-koll))**0.5}else{err$s_err=err$merr**0.5}
      }
      
      kol=err$kol;err=subset(err,select=c('neiroset','s_err'))
      dn=merge(dn,err,by='neiroset')
      
      #постановка ошибки 95% квантили 
      o=order((dn$kol==0),dn$err);dn=dn[o,]
      e95=dn[min(round((kol+1)*0.95),kol),'err']
      dn$err_95=e95
    }else{#редкий случай - прогнозы есть а настройки нет, и нейросеть самая первоначальная (oper==0)
      dn$s_err=NA;dn$err_95=NA
      
    }
    err_$dann=dn
    rm(dn_,merr,vh,e95,kol,koll,o,ogr)
  }
  return (err_)
  rm(dn,mas,str,vib,err,err_,i,is_rez,kol_m,kol_neir,kol_reb,kol_x,nm,nm_,reb,v,vhod,vih,zn)
  
}
#пример   rez=neural$neir.err(str,vib,mas,dn,is_rez=TRUE);








# собственно настройка одной нейросети по итерациям
neural$neir.nastr_nset <- function (str,vib,mas,dn) {  # было  neural$neir.nastr
  max_time=max(vib$max_time,1) #хоть 1 секунду дать каждой настройке!
  is_rez=FALSE #нужны ли на выходе данные
  o=order(mas$zn);mas=mas[o,]   #mas=mas[mas$zn,] #это упорядочивание строк
  #mas=as.data.table(mas) 
  str$z=as.integer(str$vhod<str$vih);str[(is.na(str$vhod)),'z']=1
  step=0;tm_beg=as.double(Sys.time())
  b_err=neural$neir.err(str,vib,mas,dn,is_rez);
  
  #запомнили лучшие на данный момент параметры
  vib$error=b_err$err;b_vib=vib;b_str=str;b_mas=mas;
  
  #направление изменения сгенерировать
  dmas=(runif(nrow(mas))-0.5);dstr=(runif(nrow(str))-0.5)
  
  end_proc=0;rad=vib$radius;vib$radius=NULL
  if (is.na(rad)){rad=0.1}
  #пошагово случайное изменение параметров
  while(end_proc==0){
    mas$fun=mas$fun+rad*dmas
    str$zn=str$zn+str$z*rad*dstr
    
    v=(is.na(str$vhod))
    str[v,'zn']=min(max(str[v,'zn'],0.05),0.5)
    
    step=step+1;
    err=neural$neir.err(str,vib,mas,dn,is_rez)
    
    if (err$err<b_err$err) {# хорошо - направление не изменяем, увеличиваем шаг
      b_err=err;rad=rad*1.5;
      vib$error=b_err$err;
      b_vib=vib;b_str=str;b_mas=mas;
    }else{
      rad=rad*0.9;vib=b_vib;str=b_str;mas=b_mas;
      #направление изменения сгенерировать заново
      dmas=(runif(nrow(mas))-0.5);dstr=(runif(nrow(str))-0.5)}
    
    tm=as.double(Sys.time())
    if (step>10000){end_proc=1}
    if ((tm-tm_beg)>max_time){end_proc=1}
    if (rad<0.00001){end_proc=1}
  }
  
  vib=b_vib;str=b_str;mas=b_mas;str$z=NULL;vib$radius=rad
  vib$kol_step=vib$kol_step+step;
  vib$ttime=(tm-tm_beg);
  #vib$error=NULL;vib$error_rez=NULL;vib$ss_err=NULL
  result=list(vib=vib, str=str, mas=mas) 
  return(result)
  rm(b_mas,b_str,b_vib,dn,mas,vib,b_err,dmas,dstr,end_proc,err,is_rez,max_time)
  rm(rad,result,step,tm,tm_beg,v,o)
  rm(str) #??? почему-то ругается при уничтожении, вне программы
}






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
  
  for (nm in c("max_time","time","kol_step","ttime","s_err","err_95","error","error_rez","ss_err")){
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
      dn$error=dn$err**2;dn$error_rez=dn$error*dn$rez;dn$ss_err=dn$rez*(dn$s_err**2)
      
      err=aggregate(x=subset(dn,select=c('error','error_rez','ss_err')),
                    by=subset(dn,select=c('neiroset','s_err','err_95')), FUN="sum" )
      vib$error=NULL;vib$error_rez=NULL;vib$ss_err=NULL;vib$s_err=NULL;vib$err_95=NULL
      vib=merge(vib,err,by='neiroset')
      
      
      #запись итогов временно
      max_time=max_time-vib$ttime
      struct=rbind(struct[(struct$neiroset!=nset),],str)
      vibor=rbind(vibor[((vibor$neiroset!=nset)|(is.na(vibor$neiroset))),],vib)
      pmas=rbind(pmas[(pmas$neiroset!=nset),],mas)
    }
  }
  
  #нет нейросети - нет и ошибки, чтобы не суммировать
  vibor[(is.na(vibor$neiroset)),c('error_rez','ss_err','s_err','err_95','error')]=0
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











#случайный выбор по пропорции из базы, по полю kol
neural$neir.sluchaini_vibor <- function (dn_mas) {  
  #изменить пропорциональность - возвести в квадрат
  #dn_mas$kol=dn_mas$kol**2
  #накопительные суммы - для пропорционального выбора
  sumk=0;dn_mas$i=(1:nrow(dn_mas));dn_mas$kol0=0;dn_mas$kol1=0;
  for (i in dn_mas$i){dn_mas[i,'kol0']=sumk;sumk=sumk+dn_mas[i,'kol'];dn_mas[i,'kol1']=sumk}
  rr=runif(1)*sumk;
  dn_mas=dn_mas[(dn_mas$kol1>=rr)&(dn_mas$kol0<=rr),]
  dn_mas=dn_mas[1,] #если вдруг на границе, и 2 записи сразу
  for (nm in c('i','kol0','kol1','kol')){dn_mas[,nm]=NULL}
  return(dn_mas)}













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






#по описанию нейросети прочитать данные, оставить лишь всё нужное
neural$neir.dann_first <- function(neir) {
  #результат работы прочитать, из сохранённого, немного подработать
  dann=myPackage$trs.dann_load(neir$vhod$name,'ext')
  dann$yy=dann[,neir$vhod$y]
  
  dat=as.character(neir$vhod$dat)
  max_dat=as.character(max(as.Date(dann[(!is.na(dann$yy)),dat])))
  neir$vhod$max_dat=max_dat
  
  
  { # добавление суммируемых переменных
    params=c("Seats","min_mest","kp1","rent1","pkm1","plata1","FreeSeats") #кого суммировать
    paramm=c("Train","Type","pzd","Napr") #поля разбиений
    res=subset(dann,select=c("Date",paramm,params))
    
    rr=unique(subset(res,select=paramm));rr$nom=(1:nrow(rr))
    res=merge(res,rr,by=paramm)
    for (nm in paramm){res[,nm]=NULL}#удалить поля разбиений - для скорости
    
    for (nm in params){#процедура накопит суммирования каждого поля
      nm_=paste('s_',nm,sep='');
      if (nm_ %in% neir$vhod$xs){
        rs=subset(res,select=c('Date','nom',nm))
        rs=rs[(!is.na(rs[,nm])),];o=order(rs$nom,rs$Date);rs=rs[o,]
        rs[,nm_]=0;ss=0;
        for (i in (1:nrow(rs))){ss=ss+rs[i,nm];rs[i,nm_]=ss}# собственно накопительное суммирование
        rs[,nm]=NULL;res[,nm]=NULL
        res=merge(res,rs,by=c('Date','nom'),all=TRUE)
      }else{res[,nm]=NULL}
    }
    
    res=merge(res,rr,by='nom');res$mas_nom=res$nom;res$nom=NULL
    dann=merge(dann,res,by=c('Date',paramm))
  }
  
  
  #номер строки - только с даты первых реальных данных
  min_date=min(as.Date(dann[(!is.na(dann$yy)),]$Date))
  dann0=dann[(as.Date(dann$Date)<min_date),]
  dann=dann[(as.Date(dann$Date)>=min_date),]
  o=order(is.na(dann$yy),dann$Date,dann$Train,dann$Type);dann=dann[o,];
  dann$row=(1:nrow(dann));dann0$row=NA
  dann=rbind(dann,dann0);rm(dann0)
  
  
  
  dann$dat=as.Date(dann[,neir$vhod$dat])
  
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
  
  
  #сверить список возможных входов, и переназвать
  nm=neir$vhod$mas;mas=unique(as.data.frame(nm))
  nm=neir$vhod$xz;xz=unique(as.data.frame(nm))
  nm=neir$vhod$y_ogr;y_ogr=unique(as.data.frame(nm))
  nm=neir$vhod$xs;xs=unique(as.data.frame(nm))
  
  #из перечня полей взять существующие
  nm=names(dann);nm=as.data.frame(nm)
  mas=merge(nm,mas,by = c("nm"));mas$tip='mas'
  xz=merge(nm,xz,by = c("nm"));xz$tip='xz'
  xs=merge(nm,xs,by = c("nm"));xs$tip='xs'
  y_ogr=merge(nm,y_ogr,by = c("nm"));y_ogr$tip='ogr'
  
  #упорядочить по алфавиту
  o=order(mas$nm);mas=mas[o,];mas$nom=(1:nrow(mas))
  o=order(xz$nm);xz=xz[o,];xz$nom=(1:nrow(xz))
  o=order(xs$nm);xs=xs[o,];xs$nom=(1:nrow(xs))
  o=order(y_ogr$nm);y_ogr=y_ogr[o,];y_ogr$nom=(1:nrow(y_ogr));
  
  #вернуть - что именно получилось взять
  neir$vhod$mas=as.character(mas$nm);
  neir$vhod$xz=as.character(xz$nm);
  neir$vhod$xs=as.character(xs$nm);
  neir$vhod$y_ogr=as.character(y_ogr$nm);
  
  #статистики количеств полей   
  neir$vhod$kol_mas=nrow(mas);neir$vhod$kol_xz=nrow(xz);neir$vhod$kol_xs=nrow(xs);
  neir$vhod$kol_ogr=nrow(y_ogr)
  
  #смена названий столбцов
  if (nrow(mas)>0){mas$nm_=paste("mas", mas$nom, sep = "")
  for (i in 1:nrow(mas)){
    nm=as.character(mas[i,'nm']);nm_=as.character(mas[i,'nm_'])
    dann[,nm_]=dann[,nm];
  }}
  if (nrow(xz)>0){xz$nm_=paste("xz", xz$nom, sep = "")
  for (i in 1:nrow(xz)){
    nm=as.character(xz[i,'nm']);nm_=as.character(xz[i,'nm_'])
    dann[,nm_]=dann[,nm];
  }}
  if (nrow(xs)>0){xs$nm_=paste("xs", xs$nom, sep = "")
  for (i in 1:nrow(xs)){
    nm=as.character(xs[i,'nm']);nm_=as.character(xs[i,'nm_'])
    dann[,nm_]=dann[,nm];
  }}
  if (nrow(y_ogr)>0){y_ogr$nm_=paste("ogr", y_ogr$nom, sep = "")
  for (i in 1:nrow(y_ogr)){  #   i=1
    nm=as.character(y_ogr[i,'nm']);nm_=as.character(y_ogr[i,'nm_'])
    dann[,nm_]=dann[,nm];
  }}
  
  #слить данные о полях в одну базу
  nm=c('yy','row','dat','mas_nom');pol=as.data.frame(nm);pol$nom=0;pol$nm_=pol$nm;pol$tip=pol$nm;
  pol$nm=c(neir$vhod$y,'row',neir$vhod$dat,NA)
  pol$name=c('y',NA,NA,NA);
  mas$name=paste('m',mas$nom,sep='');xz$name=NA;xs$name=NA;y_ogr$name='y_ogr'
  pol=rbind(pol,mas,xz,xs,y_ogr);
  # признак поля из даты
  pol$dat=NA;pol[(pol$nm_=='dat'),'dat']=1
  ddats=dats;ddats$dat=NULL;ddats=names(ddats) #все поля сформированные из даты
  # ddats=c('weekday','day','week','month','rab_day','prazdn','nom_prazdn','mweek')
  pol[(pol$nm %in% ddats),'dat']=1
  
  #удаление всех лишних столбцов
  neir$vhodi=pol;pol=as.character(pol$nm_)
  for (nm in names(dann)) {if (!(nm %in% pol)) {dann[,nm]=NULL}}
  
  
  #пронумеровать массивы сквозной нумерацией
  vh=neir$vhodi;mas=vh[(vh$tip=='mas'),];mas$kol=NA
  dn_mas=dann;dn_mas$kol=1
  dn_mas=aggregate(x=subset(dn_mas,select=c('kol')),
                   by=subset(dn_mas,select=as.character(mas$nm_)), FUN="sum" )
  mass=unique(subset(mas,select=c('nm_','name')));mass$zn=NA;mass$nom=NA
  kol_mas=0;o=order(mas$nom);mas=mas[o,]
  for (nm in mas$nm_){
    zn=unique(subset(dn_mas,select=c(nm)));
    zn$zn=zn[,nm];
    o=order(zn$zn);zn=zn[o,]
    kol=nrow(zn);zn$nom=kol_mas+(1:kol);
    mas[(mas$nm_==nm),'kol']=kol
    name=mas[(mas$nm_==nm),'name']
    #сразу ввести в данные
    dann[,name]=NULL;dann=merge(dann,zn,by=nm)
    dann[,name]=dann$nom;dann$nom=NULL;dann$zn=NULL;
    # и так же в краткие суммы
    dn_mas[,name]=NULL;dn_mas=merge(dn_mas,zn,by=nm)
    dn_mas[,name]=dn_mas$nom;dn_mas$nom=NULL;dn_mas$zn=NULL;
    zn[,nm]=NULL;kol_mas=kol_mas+kol
    zz=mass[(mass$nm_==nm),];zz$zn=NULL;zz$nom=NULL
    zn=merge(zn,zz);mass=rbind(mass,zn)   }
  
  #запись в нейросеть   
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
  for (nm in c(mas$name,'row','mas_nom')){dann[,nm]=as.integer(dann[,nm])}
  for (nm in mas$nm_){dann[,nm]=NULL}
  dann=as.data.frame(as.data.table(dann)) 
  
  
  neir$dann=dann
  return(neir)
  rm(nm,nm_,pol,i,mas,xz,y_ogr,dann,dn_mas,mass,res,rr,rs,vh,xs,zz,kol,kol_mas,min_date)
  rm(name,o,paramm,params,ss,zn,neir,dats,prz,prz_,vis,dat,ddats,dt1,dt2,k,max_dat,prazdn)
  
}
#Пример запуска
#neir=myPackage$neir.dann_first(neir);dann=neir$dann;neir$dann=NULL;






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
    for (nm in c('s_err','err_95')){   # убрал 'err'
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
  
  err_nm=c('err_95','s_err') # убрал 'err' - кто идёт в best_res
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


















##########################################################################
#нечто в поиске проблемы утечки памяти:
# install.packages("ggplot2") 
# install.packages("pryr") 
# install.packages("devtools")
# devtools::install_github("hadley/lineprof")
#  gc() - что-то показывает, и прекращает оборваный процесс по ядрам










   

