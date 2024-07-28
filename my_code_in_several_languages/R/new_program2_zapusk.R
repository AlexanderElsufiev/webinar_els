
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


#ВНАЧАЛЕ ПОДКЛЮЧИТЬ БИБЛИОТЕКУ ПАРАЛЛЕЛЬНЫХ ВЫЧИСЛЕНИЙ
if (!require("parallel")) {install.packages("parallel")};
library("parallel")

#программы работы с исходными данными
eval(parse('./scripts/new_program1.R', encoding="UTF-8"))
eval(parse('./scripts/new_program2.R', encoding="UTF-8"))


#ДАЛЕЕ ВСЁ ДЛЯ НЕЙРОСЕТЕЙ







name='sahalin';      # name='doss'; 

#агрегация месячных данных - сапсаны (сперва пасс, потом вагоны) и прочие (вагоны, потом пасс)
#   myPackage$trs.Data.aggregate_month(name)
#Экстракция данных в базу, всё что есть. Хранит историю продажи в kol_day дней
#   kol_day=1;myPackage$trs.tData.extract(name,kol_day) 

neir=list();
vhod=list()
vhod$name=name
vhod$before=30 # за сколько дней должны быть прогнозы
vhod$max_time=60 #сколько секунд даётся на 1 настройку пула (или 1 нейросети в пуле)
vhod$id=1;vhod$versia=0;vhod$pred_id=NA;vhod$pred_versia=NA;vhod$pred_error=NA
vhod$y='kp1' #какое поле идёт в прогноз

#кого принципиально можно в массив, на вход по данным, и вход по текущему значению (ограничение, цена...)
vhod$mas=c('Train','Type','Klass','First','Skor','Napr','pzd','weekday','day','week','mweek','month','rab_day','prazdn','nom_prazdn')
vhod$xz=c('kp1','pkm1','plata1','rent1','cena1','FreeSeats','kp7','kp14','kp21','Seats') # ,'prazdn'
vhod$xs=c('s_kp1','s_pkm1','s_plata1','s_rent1','s_cena1','s_FreeSeats','s_Seats')
vhod$y_ogr=c('Seats')
vhod$dat=c('Date')
neir$vhod=vhod;rm(vhod)

#по описанию нейросети, как по маске, прочитать данные, оставить лишь всё нужное
neir=neural$neir.dann_first(neir)
neural$dannie=neir$dann;neir$dann=NULL
neural$vozm_vibori=neir$vozm_vibori;neir$vozm_vibori=NULL #специфические данные, нужны лишь однажды
neural$vhod=neir$vhod;neural$vhodi=neir$vhodi;
neural$mass=neir$mass




# ХЭШ-ФУНКЦИЯ  library(digest)  c=(1:10000);digest(c)




#####################################################################
# попытка создать конкретную настройку, с сильной точностью

# структура: xz7= seats (364), xz2=freeseats (364), xz3=xz3=kp1 (30,364,35)




# создать структуру нейросети нейросетей
neir=list()
neir$vhod=neural$vhod;neir$vhodi=neural$vhodi;neir$mass=neural$mass

# исходно нейросеть=1, опер=0
max_oper=0;oper=0
mas=neir$vhodi;vhod=mas[(mas$tip=='xz'),];mas=mas[(mas$tip=='mas'),]

vibor=as.data.frame(oper);
for (nm in mas$name){vibor[,nm]=-1}#корневая нейросеть - без массивов (=-1)
for (nm in mas$nm_){vibor[,nm]=NA}
ogr=vibor;for (nm in mas$name){ogr[,nm]=0}

vibor$pred_oper=0;vibor$neiroset=1;
all_vibor=vibor;all_ogr=NULL

ogr$oper=0;ogr$get='xz3';ogr$out='x1';ogr$plus=30
all_ogr=ogr[0,]

all_vibor$min_kol=0;all_vibor$razdvoen=0;all_vibor$new=0

#поставить нужные входы
ogr$out='x1';ogr$get=vhod[(vhod$nm=='Seats'),'nm_'];ogr$plus=364;ogr$oper=ogr$oper+1
all_ogr=rbind(all_ogr,ogr)
ogr$out='x2';ogr$get=vhod[(vhod$nm=='FreeSeats'),'nm_'];ogr$plus=364;ogr$oper=ogr$oper+1
all_ogr=rbind(all_ogr,ogr)
ogr$out='x3';ogr$get=vhod[(vhod$nm=='kp1'),'nm_'];ogr$plus=30;ogr$oper=ogr$oper+1
all_ogr=rbind(all_ogr,ogr)
ogr$out='x4';ogr$get=vhod[(vhod$nm=='kp1'),'nm_'];ogr$plus=35;ogr$oper=ogr$oper+1
all_ogr=rbind(all_ogr,ogr)
ogr$out='x5';ogr$get=vhod[(vhod$nm=='kp1'),'nm_'];ogr$plus=364;ogr$oper=ogr$oper+1
all_ogr=rbind(all_ogr,ogr)


vibor=all_vibor;vibor$oper=NULL;vibor$new=0
vibor=merge(vibor,subset(all_ogr,select='oper'))
vibor$pred_oper=vibor$oper-1
#for (nm in mas$name){vibor[,nm]=0}
all_vibor=rbind(all_vibor,vibor);all_vibor$neiroset=all_vibor$oper+1

for (nm in mas$name){# по кому не склеиваем
  if ((!is.na(mas[(mas$name==nm),'dat'])) | (mas[(mas$name==nm),'nm'] %in% c('First','Skor'))){
    all_ogr[,nm]=-1}}



neir$all_ogr=all_ogr
neir$all_vibor=all_vibor
neir$vhod$id_izm='sozd';neir$vhod$id=NA
rm(ogr,vibor,mas,all_ogr,all_vibor,max_oper,oper,nm)



#по описанию нейросети прочитать данные, оставить лишь всё нужное
#  result=neural$neir.dann_first(neir);neir=result$neir;dann=result$dann;rm(result)


#на основе нейросети и исх.данных построить связку нейросеть с данными, со всеми параметрами 
neir=neural$neir.dannie_all(neir)  

vib=neir$all_vibor;ogr=neir$all_ogr;dn_neir=neir$dann;vh=neir$vhodi





error_=neir$vhod$error
# настройка по итерациям всех нейросетей множества
neir=neural$neir.nastr_all(neir) 

# результат настройки по всему пулу нейросетей
result=neural$neir.rez_all(neir) 
result$big=as.integer(result$zn>result$ogr1)+1    
plot(result$yy,result$zn,col=result$neiroset)
error=neir$vhod$error

#проверка правильности значения ошибки
res=result[(!is.na(result$yy)),]
#error_=sum((res$yy-res$zn)**2)
err_sr=(error/nrow(res))**0.5














########################################################
#построить нерперывный процесс настройки



# создать структуру нейросети нейросетей
neir=list()
neir$vhod=neural$vhod;neir$vhodi=neural$vhodi;neir$mass=neural$mass

# исходно нейросеть=1, опер=0
max_oper=0;oper=0
mas=neir$vhodi;mas=mas[(mas$tip=='mas'),]

vibor=as.data.frame(oper);
for (nm in mas$name){vibor[,nm]=-1}#корневая нейросеть - без массивов (=-1)
for (nm in mas$nm_){vibor[,nm]=NA}
ogr=vibor;for (nm in mas$name){ogr[,nm]=0}

vibor$pred_oper=0;vibor$neiroset=1;
all_vibor=vibor;all_ogr=NULL

ogr$oper=1;ogr$get='xz3';ogr$out='x1';ogr$plus=30
all_ogr=ogr

all_vibor$min_kol=0;all_vibor$razdvoen=0;


neir$all_ogr=all_ogr[(all_ogr$oper<=max_oper),];
neir$all_vibor=all_vibor[(all_vibor$oper<=max_oper),]
neir$vhod$id_izm='sozd';neir$vhod$good=0;

rm(ogr,vibor,mas,all_ogr,all_vibor,max_oper,oper,nm)

####усложнить
#    neir=neural$neir.plus_uslojn(neir) 
# поставить новый вход по поиску лучшего
#   neir=neural$neir.plus_vibor(neir) 

#Наполнить нейросеть данными
neir=neural$neir.dannie_all(neir)  
#     vib=neir$all_vibor;ogr=neir$all_ogr   
#     vib$razdvoen=0;neir$all_vibor=vib


# настройка по итерациям всех нейросетей множества
error_=neir$vhod$error
neir=neural$neir.nastr_all(neir) 

# результат настройки по всему пулу нейросетей
result=neural$neir.rez_all(neir) 
result$big=as.integer(result$zn>result$ogr1)+1    
error=neir$vhod$error

# теперь надо ПОЛУЧИТЬ КАРТИНКУ КАЧЕСТВА НАСТРОЙКИ
plot(result$yy,result$zn,col=result$neiroset)
plot(result$ogr1,result$zn,col=result$neiroset)




#Запись нейросети в базу, увеличение номера версии
nname=''
neir=neural$neir.save_to_hist(neir)

nname=''


ogr=neir$all_ogr;vib=neir$all_vibor




name='sahalin';nname=paste(name,neural$vhod$before,sep='_')
#    name='doss'

#процесс генетической настройки из исходной нейросети
neural$neir.nastroika_paral(name)


gc()







####################################################
#просмотр лучшей нейросети
nname='';

#взять старую историю нейросетей и сокращений, и прогнозов
#nname=paste(name,neural$vhod$before,'',sep='_')
neir_hist=myPackage$trs.dann_load('neiroset','poln',nname)
neir_hist_sokr=myPackage$trs.dann_load('neiroset','sokr',nname)   


# выбрать лучший номер id
nhs=neir_hist_sokr;
nhs=nhs[(nhs$activ==1),]
o=order(nhs$error);nhs=nhs[o,];id=nhs[1,'id'];rm(o)

#nhs=nhs[(nhs$error>nhs$ss_err)&(nhs$activ==1),]
#  id=112;   #  nhs=nhs[(nhs$id==id),]

#взять нейросеть    names(neir)
neir=as.character(neir_hist[(neir_hist$id==id),'pack'])
neir=myPackage$neir.unpack(neir);
#   neir=neural$neir.plus_uslojn(neir)   neir=neural$neir.plus(neir)  
#   neir=neural$neir.plus_vibor(neir)
tm=as.numeric(Sys.time())
neir=neural$neir.dannie_all(neir)   
tm=as.numeric(Sys.time())-tm;print(tm)


vib=neir$all_vibor;ogr=neir$all_ogr;dn_neir=neir$dann;vh=neir$vhodi
str=neir$param_str;    mass=neir$param_mas
neir$vhod$max_dat

#  vib$razdvoen=0;neir$all_vibor=vib



#  str_=str[((str$vhod==str$vih)&(!is.na(str$vhod))),]
#  str[((str$vhod==str$vih)&(!is.na(str$vhod))&(str$zn==0) ),'zn']=2
#       neir$param_str=str

# настройка по итерациям всех нейросетей множества
error_=neir$vhod$error
neir=neural$neir.nastr_all(neir) 
#    vib=neir$all_vibor;ogr=neir$all_ogr
# результат настройки по всему пулу нейросетей
result=neural$neir.rez_all(neir) 
o=order(result$row);result=result[o,];rm(o)
#result$big=as.integer(result$zn>result$ogr1)+1    
error=neir$vhod$error
#res=result[(!is.na(result$yy)),]
err_sr=(error/nrow(result[(!is.na(result$yy)),]))**0.5

# теперь надо ПОЛУЧИТЬ КАРТИНКУ КАЧЕСТВА НАСТРОЙКИ
plot(result$yy,result$zn,col=result$neiroset)
neir$vhod$good



#  res=result[(!is.na(result$yy)),];error_sum=sum((res$yy-res$zn)**2)

result$big=as.integer(result$zn>result$ogr1)+1    
plot(result$yy,result$zn,col=result$big)
plot(result$ogr1,result$zn,col=result$big)

#Запись нейросети в базу, увеличение номера версии
neir=neural$neir.save_to_hist(neir)

neir$all_vibor$razdvoen=0  
neir=neural$neir.plus_uslojn(neir)


ogr=neir$all_ogr;
ogr$plus=7*round(ogr$plus/7)
ogr[(ogr$plus<30),'plus']=35
neir$all_ogr=ogr;neir$dann=NULL;neir$vhod$id=NA


vib[(vib$oper==1),'m5']=-1
neir$all_vibor=vib


neir$vhod$id=NA


for (nset in vib$neiroset){
  res=result[(result$neiroset==nset),]
  if (nrow(res)>0){
    plot(res$yy,res$zn,col=res$neiroset)}}


str=neir$param_str

str_=str[(str$vhod==str$vih)&(!is.na(str$vhod)),]
o=((str$vhod==str$vih)&(!is.na(str$vhod)))
str[o,'zn']=pmax(2,str[o,'zn'])

neir$param_str=str






nnnnn=neir

neir=nnnnn

######################################################################
# попытка перехода к параллельным вычислениям;

name='sahalin';nname=paste(name,'30','',sep='_')
#name='doss'

#процесс генетической настройки из исходной нейросети
neural$neir.nastroika_paral(name,nname)



gc()




####################################################################################


# статистика улучшений по видам изменений
neir_hist_sokr=myPackage$trs.dann_load('neiroset','sokr',nname)   
nhs=neir_hist_sokr;
nhs=nhs[(nhs$max_dat==neural$vhod$max_dat),]
nhs$good=1*(nhs$error<nhs$pred_error);nhs[(is.na(nhs$pred_error)),'good']=0
nhs$k=1
nhs=nhs[(!is.na(nhs$dat_time)),]
o=order(nhs$dat_time,nhs$id);nhs=nhs[o,];er=nhs[1,]$error;nhs$ber=NULL
for (i in (1:nrow(nhs))){er=min(er,nhs[i,'error']);nhs[i,'ber']=er}
nhs$best=1*(nhs$error==nhs$ber)

stat=aggregate(x=subset(nhs,select=c('k','good','activ','best')),
               by=subset(nhs,select='id_izm'), FUN="sum" )



idd=nhs[(nhs$activ==1),'id']
nhs_=nhs[(nhs$id_izm=='mut_neir'),]

nhs_=nhs[(nhs$id %in% c(12432,12160)),]


################################################################################






######################################################################
#  если  ошибка

[1] "predvarit rassch`t dannih"
[1] "nachalo nastroiki"
[1] "nachalo_2017-10-10 16:01:57"
[1] "Save to : ./data/neir_hist/neir_new.csv"
Show Traceback

Rerun with Debug
Error in checkForRemoteErrors(val) : 
  3 nodes produced errors; first error: undefined columns selected 




neir_new=myPackage$trs.dann_load('neiroset','new',nname)

#когда знаем конкретный номер нейросети
id=86
neir=as.character(neir_new[(neir_new$id==id),'pack'])
neir=myPackage$neir.unpack(neir);

neir=neural$neir.plus_uslojn(neir)

neir=neural$neir.dannie_all(neir)  


neir=neural$neir.nastr_all(neir) 

result=neural$neir.rez_all(neir)


#поиск, на какой нейросети ошибка - не знаем номер

#подготовить данные для всех ядер процессора
neirs <- lapply(FUN = function(id) {  #  ordr=1
  neir=as.character(neir_new[(neir_new$id==id),'pack'])
  neir=myPackage$neir.unpack(neir);
  return (neir)}, X = (neir_new$id))




#запустить усложнения/мутации в паралл режиме

for (neir in neirs) {
  print(paste('id=',neir$vhod$id,sep=''))
  neir_=neural$neir.perenos_gen(neir)
  }

max_dat=neural$vhod$max_dat
for (neir in neirs) {
  print(paste('id=',neir$vhod$id,sep=''))
  if (is.null(neir$vhod$max_dat)){neir$vhod$max_dat=''}
  if (neir$vhod$max_dat!=max_dat) {neir$vhod$good=1}
  neir=neural$neir.plus_uslojn(neir) #усложнение - если neir$vhod$good=0
  
  if (is.na(neir$vhod$id)){neir$vhod$id=neir$vhod$id_}
  neir$vhod$id_=NULL
  neir$vhod$versia=neir$vhod$versia+1;
  if (!is.na(neir$vhod$error)){neir$vhod$pred_error=neir$vhod$error}
}








# если ошибка именно в процессе настройки
for (neir in neirs) {
  print(paste('id=',neir$vhod$id,sep=''))
  neir$vhod$max_time=10
  
  neir=neural$neir.dannie_all(neir)     
  print('1')
  # настройка по итерациям всех нейросетей множества
  neir=neural$neir.nastr_all(neir) 
  print('2')
  # результат настройки по всему пулу нейросетей
  result=neural$neir.rez_all(neir)
  print('3')
}


nnnnn=neir


neir=nnnnn


################################################################################
#поиск причины ошибки 

nnnnn=neir

neir=nnnnn
neir=neural$neir.plus_uslojn(neir) #усложнение - если neir$vhod$good=0


################################################################################




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







################################################################################
# ошибки в 2 процедурах:


neir=nnnnn
neir=neural$neir.plus_vibor(neir) - осталось


################################################################################





################################################################################






################################################################################






################################################################################





################################################################################

# ХЭШ-ФУНКЦИЯ 
library(digest) 

nn=digest(neir)

vib=neir$all_vibor

vv=vib[1,]
vv=rbind(vv,vv,vv)

v1=vv[1,];v2=vv[1,]
po=v2$pred_oper;v2$pred_oper=NULL;v2$pred_oper=po

z1=digest(v1);z2=digest(NULL);

################################################################################














# удаление всех лишних переменных
rm(dann,aggrdb,shema,cols,dbPath, form,tmp,text,matrix,file,filePath,files,path,vid,srok,name,info,matrix_mar,first)
rm(format,kol_mar,kol_rez,kol_zap,mm,cen,mar,pass,rawdb,by,ll,SDcols,mar_,pass_,marb,sh,sh_,she,mar_pzd,dn)
rm(min_dat,max_dat,vcd_rus,matrix_,files_,shemi,fl,i,kol_f,ksh,l,len,pr,s,z,f,ff,kol,p,pp,sp,maro,maro_,marp,by_t)
rm(marshr,mData,pData,wData,mr,rst,rst_o,rst_n,iz,max_rst,min_date,o,kol_mest,mesta,pd,res,result,vag,max_n)
rm(mrst,nn,rr,tr,kol_day,mesta_,result_,kd,kdd,old_rez,st,kp,pzd,tm,m,r,min_mest,Date,ii,zap,max_date)
rm(pzd_,pzd_2,mDt,wData_,r1,r2,ddd,mas,x,xx,xz,d,f_y,neir_y,nm,nm_,dann_,dd,pol,dn_mas,get,out,plus)
rm(neir,neir_,dann_is,dann_oth,dn_,dns,mas_,dd_,dn_mas_,dn1,dn2,ogr,tb,kol_vozm,pole,zn,dn_vib,ogr_z)
rm(all_ogr,all_vibor,vibor,vhod,kol_oper,oper,po,op,min_kol,all_vibor_,dann_2,k,kk,max_op,op_pred,pred_p)
rm(vib,vib_,kol_,dn_neir,dannie,mass,vh,vh_,kol_mas,kz,nom,dn_neir2,nset,nsets,oper_,pkol)
rm(par,par_,param,vy,kol_x,neiroset,nm1,nm2,y,zn_,dnn,reb,param_m,mas_zn,str,struct,kol_m,kol_neir)
rm(err,kol_reb,v,vih,b_mas,b_str,b_vib,b_err,end_proc,max_time,rad,step,tm_beg,zz)
rm(neir_hist,neir_hist_sokr,neir_vozm_vibori,error,max_oper,model,err_sr,s_err,neir_h,neir_sokr)
rm(neir_sokr_,id,nneir,pred_v,xz_,loper,og,str_,vb,vb_,vvv,before,kol_vh,neir2,xout)
rm(dann_ish,dn_neir3,ogr3,vibor2,vibor3,neir_ish,neir3,ogr2,ogr2_,ogr3_,vibor2_,vibor3_,str3)
rm(str2,v2_1,v2_2,names,opis,opis_,opis2,fr,name_,ogr_,vibor_,op2,z1,z2,neir_d,vozm_vibori)
rm(result2,error2,struct2,vib2,ns,masd,str_ish,vib_ish,vhod2,vib_pred,error_,kol_best,neir_bad)
rm(ogr_bad,vib_bad,tt,ttime,neir2_ish,time,ogran,vibori,ids,massiv,id_,ko,nset_new,razdvoen,vh_oper)
rm(dann_ish2,dann3,inn,vibor_n,it,vhod_ish,neir_ish2,ogr_ish,bef,y_ogr,dns_,op_prg,sumk,maxz,mx)
rm(dann_op,dann_rezz,dann_rezz_,dann0_ish,dann1_ish,dann2_ish,dann3_ish,dann_rek,dann_rez,kkk,vhodi)
rm(param_,err_rez,dn_2,maxx,pmas,izmen,izm,er,results,itogi,pack,dn6,res_,kol_best_neir,max_id,max_kol_neir)
rm(bad,dn_rez,e95,is_rez,vh_max,err_,clust,cores,nhs,ord,id1,id2,mkol,ordr,neirs,err_nm,best_res,err1,err2)
rm(merr,koll,ogr1,dmas,sel,neir_new,n,aa,vh_m,datm,dmm,dmm_,dmm_2,dn_222,mmm,dn_m,mask,masv,vib_n,kol_par)
rm(kol_z,rek,rez,str_iz,dstr,dn___,dn_5,dn_6,vvvv,mass_,e,mas4,mas4_,dann_op_,ey,res2,rs,xs,paramm,params,ss)
rm(xz_t,max_,min_,tip,ogr_n,ord_,nhs_,s_er,results_,izmen_,stat,masv_,dat,de,ogg,ogg_,br,eee,zapazd)
rm(err_ish,good,versia,res1,nh,nh_,act,error_1,pi,neirs_,str_2,strp,t,dt1,dt2,prazdn,dir,nname)
rm(s_error,s_error_95,s_error_rez,s_error_ss,ss_err,vv,nset_,nn1,nn2,dats,dats_,prz,prz_,vis,ddats)
rm(ff_,File,kol_0,kol_1,inf,info_,max_tab_nom,matr,matr_,raspis,dmass,x_,dmass_,pmas_,name2)
rm(error_sum,error_sum_,kol_r,kol_r_,max_dat_,poll,c,h,hh)
#rm(myPackage)



