
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
eval(parse('./scripts/new_program3.R', encoding="UTF-8"))

# старая версия eval(parse('./scripts/new_program4.R', encoding="UTF-8")) - другая фильтрация

#ДАЛЕЕ ВСЁ ДЛЯ НЕЙРОСЕТЕЙ







name='stat_doss'
name='sahalin';      #   
name='doss'; 
name='sapsan'
name='dann'



#агрегация месячных данных - сапсаны (сперва пасс, потом вагоны) и прочие (вагоны, потом пасс)
#   myPackage$trs.Data.aggregate_month(name)
#Экстракция данных в базу, всё что есть. Хранит историю продажи в kol_day дней
#   kol_day=c(0,30);myPackage$trs.tData.extract(name,kol_day) 
# ??? после добавления с 2_2018, множество ошибок за 06_2017г- пассажиров вдвое больше (кажется)
   




#выборка для нужного направления поездов
#Экстракция данных в базу, всё что есть по указанному направлению (станции начала и конца)
#  napr=list();napr$name='SPb-Murmansk';napr$sto=c(2004001:2004006);napr$stn=2004200
#  myPackage$trs.tData.extract_mars(napr) 





#выборка для нужного направления поездов
#  napr=list();napr$name='SPb_Mos_Anapa_Adler-Murmansk';
# napr$sto=c(2064150,2064188,2006004,2000001,2004003,2004006);napr$stn=2004200
#Экстракция данных в базу, всё что есть по указанному направлению (станции начала и конца)
# myPackage$trs.tData.extract_mars(napr) 



#  name='SPb-Murmansk'
name='SPb_Mos_Anapa_Adler-Murmansk';


neir=list();
vhod=list()
vhod$name=name
vhod$before=30 # за сколько дней должны быть прогнозы
vhod$max_time=60; vhod$max_time=10; #сколько секунд даётся на 1 настройку пула (или 1 нейросети в пуле)
#vhod$id=1;vhod$versia=0;vhod$pred_id=NA;vhod$pred_versia=NA;vhod$pred_error=NA

#vhod$y='kp0';  #vhod$y='pkm1'; #какое поле идёт в прогноз
#vhod$y='min_mest'; # ЗАМЕНИЛ! Мест не может быть более числа посад.мест, а пассажиры - запросто.
#vhod$y_ogr=c('Seats'); #  vhod$y_ogr=c('Seats_km')  # какое поле ограничивает
#vhod$min_err=5 #минимальная ошибка безразличия - либо число, либо 1% от (ограничитель либо (сам Y если нет ограничителя))
#vhod$y='plata0';vhod$y_ogr=NA;vhod$min_err=50000; #для прогноза суммы денег
#vhod$y='pkm0';vhod$y_ogr='Seats_km';vhod$min_err=3000; #для прогноза суммы денег 
#vhod$y='zan_mest';vhod$y_ogr=c('Seats');vhod$min_err=5 #прогноз пассажиров
vhod$y='kp0';vhod$y_ogr=c('Seats');vhod$min_err=5 #прогноз пассажиров


#кого принципиально можно в массив, на вход по данным, и вход по текущему значению (ограничение, цена...)
vhod$mas=c('Train','Type','Klass','First','Skor','First2','Skor2','Napr','pzd','weekday','day','week','mweek','month','rab_day','prazdn','nom_prazdn','hh_otp','hh_otp4')
vhod$xz=c('kp*','pkm*','plata*','rent*','scena*','FreeSeats','Seats','Seats_km','zan_mest','stan_%') # 
vhod$xs=paste('s_',vhod$xz,sep='')
vhod$xz=c(vhod$xz,'cena*') 

vhod$ostavl=c('Kol_vag')
vhod$proc_err=0.995;# vhod$proc_err=0.9

vhod$vne_zapazd=c('Seats','s_Seats','Seats_km','s_Seats_km') #какие входы можно брать до самой отправки, из будущего
vhod$dat=c('Date')
#vhod$errs=c('err_max','err_sr','err_80','err_95','err_50','err_90')
vhod$proc=c(100,80,95,50,90,NA)
###vhod$proc=NA
#vhod$errs=c('err_max','err_sr','err_80','err_95','err_50','err_90','err') #пробник - статистика лучших и по реальной ошибке err
neir$vhod=vhod;rm(vhod)

#по описанию нейросети, как по маске, прочитать данные, оставить лишь всё нужное
neir=neuron$neir.dann_first(neir)
neuron$dannie=neir$dann;neuron$mass=neir$mass;
neuron$vhod=neir$vhod;neuron$vhodi=neir$vhodi;rm(neir)


#  записать исходный neuron - только данные, без процедур
neuron$neir.neuron_to_hist('neuron')


     

######################################################################

if (is.null(neuron$dannie)) { # восстановление данных neuron из памяти 
  nn=neuron$neir.load_from_hist_sobstv('neuron')
  dd=nn$dannie;if (!is.null(dd)){neuron$dannie=dd}
  dd=nn$vhod;if (!is.null(dd)){neuron$vhod=dd}
  dd=nn$vhodi;if (!is.null(dd)){neuron$vhodi=dd}
  dd=nn$mass;if (!is.null(dd)){neuron$mass=dd}
  rm(nn,dd)
}
#   names(neuron)

#   neuron$vhod$name;neuron$vhod$max_dat;neuron$vhod$y;neuron$vhod$before;      neuron$vhod$max_dat  - до какой даты есть
######################################################################



     

#####################################################################
#создать внутреннюю структуру, которую далее заполнять данными
neir=neuron$neir.init_neir(kol_pol=0)



#НАДО - СОЗДАТЬ СИСТЕМУ ПОДСКАЗОК
#      neir=neuron$neir.podskazka(neir)

# чтение из памяти   neir=neuron$neir.load_from_hist('')   # neir2=neir
# чтение как есть. без привязки к новой базе  neir=neuron$neir.load_from_hist_sobstv('neir')

# слияние 2 нейросетей neir_old=neir #   neir2=neuron$neir.load_from_hist('');neir=neuron$neir.sliv(neir_old,neir2); rm(neir2)


#выбор, кого настраивать
nsets=neuron$neir.plus_nsets(neir,18)     #  nsets=1061   nsets=21215

#при необходимости рассчитать новые входные поля
neir=neuron$neir.dobavl_vhodi(neir,nsets) 

#подготовить данные для всех ядер процессора
neurs=neuron$neir.get_neurs(neir,nsets)
rm(nsets)







# показать объёмы сформированных данных
# for (neur in neurs){print(names(neur))
#   stat=neur$stat;print(paste(stat$min_kol,stat$kol_nastr,sep='-'))  }





gc()

### Прекращать работу - можно в промежутке между подписями Конец и Начало (3-20сек)
bad=FALSE
while (!bad){  
  # kol_dann=nrow(neir$dann)  # для проверки отсутствия ошибки
  
  i=0;bad=FALSE
  while ((i<10) & (!bad)){  
    i=i+1
    
    #подготовка кластеров для распараллеливания  
    print(paste('Начало',Sys.time(),sep=' '))
    cores=max(detectCores()-2,1) #число имеющихся в наличии ядер. одно оставляем в запасе
    clust <- makeCluster(getOption("cl.cores", cores)) #в кластер берём указанное число ядер
    clusterExport(clust, c("myPackage", "neuron")) #в кластер в каждое ядро экспортируем параметры
    
    #запустить настройку в паралл режиме   for (neur in neurs){}
    neurs <- parLapplyLB(cl = clust, fun = function(neur) {
      neur=neuron$neir.nastr_nset(neur)
      neur=neuron$neir.neur_stat(neur)
      return(neur)
    }, X = neurs)
    
    stopCluster(clust);rm(clust)  
    gc() # теоретически это очистка памяти от излишков, но не работает
    
    # запись в память, для разборки
    nnnnn=neir;nnnnn2=neurs
    print(paste('Конец',Sys.time(),sep=' '))
    ##     { neir=nnnnn;neurs=nnnnn2;  cores=max(detectCores()-2,1)
    
    #запись итогов в память из результатов поднастройки
    neir=neuron$neir.zapis_neurs(neir,neurs) 

    #подчистка самих настроечных данных - удалить пустые и полностью настроенные
    neurs=neuron$neir.podchist_neurs(neir,neurs)
    
    #подсчёт, сколько осталось в настройке
    inn=0;in_nastr=0;#inns=c(cores)
    for (neur in neurs){
      inn=inn+1;v=(!is.null(neur))*1;in_nastr=in_nastr+v
      }
    
    kol_plus=max(0,cores*3-in_nastr) # сколько надо добавить настроек
    
    print(paste(in_nastr,kol_plus,sep='---'))
    
    if (kol_plus>0){ #надо что-нибудь добавить
      
      # найти номера добавляемых в рассчёт сетей (kol_plus  штук)
      nsets=neuron$neir.plus_nsets(neir,kol_plus) 
      
      if (is.null(nsets)){ # если не осталорсь нерассмотренных - ввести новых
        #  добавить новые входы (5шт) и группы входов, и фильтры
        neir=neuron$neir.plus_vhodi(neir)
        # найти номера добавляемых в рассчёт сетей (kol_plus  штук)
        nsets=neuron$neir.plus_nsets(neir,kol_plus) 
      }
      
      
      if (!is.null(nsets)){
        #при необходимости рассчитать новые входные поля
        neir=neuron$neir.dobavl_vhodi(neir,nsets) 
        #подготовить данные для всех ядер процессора
        neurs_=neuron$neir.get_neurs(neir,nsets)
        #   if (in_nastr>0){neurs=c(neurs,neurs_)}else{neurs=neurs_}
        
        # объединение по другому - без пустых
        for (k in (1:inn)){  #  k=1
          neur=neurs[k];for (nn in neur){if (!is.null(nn)){neurs_=c(neurs_,neur) }
          }}
        neurs=neurs_;rm(neurs_,k,inn,neur,nn)
      }
    }

    # выяснить, не плохо ли
    fil=neir$all_filtr;stat=neir$all_stat
    st=stat[((!(stat$nset %in% fil$nset))&(stat$act!=3)),]
    bad=(nrow(st)>0)  #;print(bad)
    if (nrow(as.data.frame(names(neir$all_mass)))>11) {bad=TRUE}
    # if (kol_dann!=nrow(neir$dann)) {bad=TRUE}  # проверка отсутствия ошибки
  }
  print(bad)
  if(!bad){
    neir=neuron$neir.sokr_dann(neir) # сокращение данных, для уменьшения памяти
    neuron$neir.save_to_hist(neir); #запись в память   #neuron$neir.save_to_hist(neurs,'_neurs');
  }
}



gc()


#   progn_old=progn

# Прогнозы
progn=neuron$neir.prognoz(neir) #;  neir$progn=progn

neuron$neir.prognozi_save(neir)  #централизованная запись прогнозов 

#   prognoz=myPackage$trs.dann_load('prognoz','') 





# график качества итогов
err=neuron$neir.rez_err(neir,1)  # график лучших
#   err=neuron$neir.rez_err(neir,2)  #график средних по хорошим
#   err=neuron$neir.rez_err(neir,'dat')  # график по дням

# график процесса настройки
errs=neir$errors;o=order(errs$dat_time);errs=errs[o,];errs$nn=(1:nrow(errs))
err=errs;err$t=1;merr=min(err[(!is.na(err$err)),'err']);
errs$err=errs$err_sr;errs$t=2;err=rbind(err,errs)
errs$err=errs$err2;errs$t=3;err=rbind(err,errs)
errs$err=errs$err_posled;errs$t=8;err=rbind(err,errs)
errs$err=errs$err_prog;errs$t=4;err=rbind(err,errs)
errs$err=errs$err_prog2;errs$t=5;err=rbind(err,errs)
err=err[(!is.na(err$err)),];err=err[(err$err<merr*1.7),]
plot(x=err$nn,y=err$err,col=err$t)




# neir_old=neir










# красивый график - по нейросетям
rez=neir$all_rezult;rez=rez[(rez$best>0),];rez=rez[(!is.na(rez$yy)),]
plot(rez$yy,rez$zn,col=rez$nset)
# по каждой составляющей - отдельный график
rez=neir$all_rezult;rez=rez[(!is.na(rez$yy)),];rez$b=rez$best+1
rezz=aggregate(x=subset(rez,select=c('good','best')),by=subset(rez,select=c('nset')), FUN="sum" )
rezz=rezz[(rezz$best>=100),]
for (nset in rezz$nset) {
  str=paste("nset=",nset,' best=',rezz[(rezz$nset==nset),'best'],sep='')
  rezn=rez[(rez$nset==nset),];plot(rezn$yy,rezn$zn,col=rezn$b,main=str)}



### несколько выбранных нейросетей результаты
rez=neir$all_rezult;#rez=rez[(rez$best>0),];
rez=rez[(rez$nset %in% c(312)),];
rez=rez[(!is.na(rez$yy)),];rez$b=rez$best+1
plot(rez$yy,rez$zn,col=rez$b)









# график - ошибка по реальному значению
rez=neir$all_rezult;rez=rez[(rez$best>0),];rez=rez[(!is.na(rez$yy)),]
plot(rez$yy,rez$err)




################################################################################


################################################################################

посмотреть итоги прогнозов всех


prognoz=myPackage$trs.dann_load('prognoz','') 

pr=prognoz[(prognoz$row==16545),]

pr$zn


################################################################################


################################################################################




################################################################################

################################################################################


################################################################################



################################################################################


################################################################################


################################################################################




################################################################################




################################################################################






################################################################################



################################################################################





name='dann'



#агрегация месячных данных - сапсаны (сперва пасс, потом вагоны) и прочие (вагоны, потом пасс)
myPackage$trs.Data.aggregate_month(name)


ПРЕДУПРЕЖДЕНИЕ

[1] "Vhod= 1266049  / Itog= 144854  zapisei"
[1] "Save to : ./data/dannie/info.csv"
Warning messages:
  1: In format.POSIXlt(as.POSIXlt(x), ...) :
  Reached total allocation of 8103Mb: see help(memory.size)
2: In format.POSIXlt(as.POSIXlt(x), ...) :
  Reached total allocation of 8103Mb: see help(memory.size)

gc()


help(memory.size)


memory.size()
memory.limit()

поработать с очисткой памяти!!!



################################################################################

################################################################################








################################################################################












################################################################################
























################################################################################

################################################################################

################################################################################


идёт ли в прогноз данные по станциям?


vh=neir$vhodi;vh=vh[(vh$suf=='%'),]
pol=neir$opis_pol;
pol=pol[(pol$get %in% vh$nm_),]
poll=neir$opis_pols;
poll=poll[(poll$n_pol %in% pol$n_pol),]
fil=neir$all_filtr;
fil=unique(fil[,c('nset','n_poll')])
stat=neir$all_stat;
stat=merge(stat,fil,by='nset')

stat$stan=0;stat[((stat$n_poll %in% poll$n_poll)),'stan']=1


st=aggregate(x=subset(stat,select=c('kol_good','kol_best')),
             by=subset(stat,select=c('stan')), FUN="sum" )




n_poll=unique(stat[(stat$kol_best>1),'n_poll'])
stat_=stat[(stat$n_poll %in% n_poll),]

stat_=stat[(stat$n_poll==10691),]


stat=stat[(stat$nset %in% c(3,61)),]
fil=fil[(fil$nset %in% stat$nset),]
poll=poll[(poll$n_poll %in% fil$n_poll),]
pol=pol[(pol$n_pol %in% poll$n_pol),]







mm=neir$all_pols
mm=mm[(mm$nset %in% stat_$nset),]


mm=neir$all_str
mm=mm[(mm$nset %in% stat_$nset),]

mass=neir$mass
mass=mass[(mass$name=='m5'),]


vh=neir$vhodi
mas=vh[(vh$tip=='mas'),]

names(neir)

ff=fil[(fil$n_poll==10691),]


################################################################################

поднастройка тех, кто даёт максимальные ошибки


stat=neir$all_stat
st=stat[(stat$kol_best>0),]
merr=min(st$err_max)

stat[((stat$kol_best>0)&(stat$err_max>5*merr)),'act']=1

neir$all_stat=stat

################################################################################



neir$vhod$before

neuron$vhod$before

################################################################################
Выяснить - какие данные по станциям вообще пошли в прогнозы?




идёт ли в прогноз данные по станциям?


vh=neir$vhodi;mas=vh[(vh$tip=='mas'),];vh=vh[(vh$suf=='%'),]
pol=neir$opis_pol;
pol=pol[(pol$get %in% vh$nm_),]
poll=neir$opis_pols;
poll=poll[(poll$n_pol %in% pol$n_pol),]
fil=neir$all_filtr;
fil=unique(fil[,c('nset','n_poll')])
stat=neir$all_stat;
stat=merge(stat,fil,by='nset')

stat$stan=0;stat[((stat$n_poll %in% poll$n_poll)),'stan']=1
stat$kb=0;stat[(stat$kol_best>10),'kb']=1;stat$kol=1

st=aggregate(x=subset(stat,select=c('kol_good','kol_best','kol')),
             by=subset(stat,select=c('stan','kb')), FUN="sum" )




st=stat[(stat$kol_dann>100)&((stat$n_poll %in% poll$n_poll)),]
poll_=poll[(poll$n_poll %in% st$n_poll),]

pol_=pol[(pol$n_pol %in% poll_$n_pol),]

mass=neir$mass;mass$k=0
pp=pol_
for (nm in mas$name){if(!is.na(mas[(mas$name==nm),'dat'])){pp[,nm]=NULL}else
  {mass[(mass$nom %in% pp[,nm]),'k']=1}}

pol_=pol[(pol$n_pol==563),]

poll_=poll_[(poll_$n_pol==563),]
poll_=poll[(poll$n_poll==12974),]

stat_=stat[(stat$n_poll==12974),]



dann=neuron$dannie
dann=dann[(!is.na(dann[,as.character(pol_$get)])),]
mass=neir$mass;mass$k=0
for (nm in mas$name){
  zn=as.numeric(pol_[,nm])
  if (zn>0){dann=dann[(dann[,nm]==zn),];dann[,nm]=0}
  if (zn<0){dann[,nm]=-1}
}
for (nm in mas$name){
  zn=as.numeric(pol_[,nm])
  if (zn==0){mass[(mass$nom %in% dann[,nm]),'k']=1}
}

pol2=pol_

pol2=pol2[(pol2$m9 %in% c(425:434)),]
pol2=pol2[(pol2$before %in% c(350:390)),]
pol2=pol2[(pol2$get=='xz8'),]


poll_=poll[(poll$n_pol==1925),]

poll_=poll[(poll$n_poll==13222),]

stat_=stat[(stat$n_poll==13222),]

################################################################################





stat=neir$all_stat;
stat=stat[(stat$kol_best>0),]

st=aggregate(x=subset(stat,select=c('kol_good','kol_best')),
             by=subset(stat,select=c('kol_x')), FUN="sum" )
st$k=st$kol_good/st$kol_best




исправить нейросети тип 0 нейрон

str=neir$all_str
str[((str$vhod==str$vih)&(str$zn==0)),'zn']=1
neir$all_str=str



################################################################################

#установка неотрицательных нейронов выхода

str=neir$all_str
str[((str$vhod==str$vih)&(str$zn==0)),'zn']=1
neir$all_str=str


stat=neir$all_stat
stat[(stat$act!=3),'act']=1
neir$all_stat=stat




################################################################################


# Прогнозы
progn=neuron$neir.prognoz(neir) #;  neir$progn=progn

prognoz=myPackage$trs.dann_load('prognoz','') 

nm=names(prognoz);nm2=names(progn)
nm_=c()
for (nn in nm){if (!(nn %in% nm2)){nm_=c(nm_,nn)}}

pr=prognoz[,nm_]








################################################################################




################################################################################



################################################################################







################################################################################


################################################################################


# низкая скорость настройки - может быть запаздывания плохи?

stat=neir$all_stat
stat=stat[(stat$act==4)&(stat$kol_best>0),c('nset','kol_best')]


fil=neir$all_filtr;fil=unique(fil[,c('nset','n_poll')])
fil=merge(fil,stat,by='nset')


pols=neir$opis_pols
pols=pols[(pols$n_poll %in% fil$n_poll),]
pols_=aggregate(x=subset(pols,select=c('act')),by=subset(pols,select='n_poll'), FUN="sum" )
pols=pols[,c('n_poll','n_pol')]
pols=merge(pols,pols_,by='n_poll')
pols=merge(pols,fil,by='n_poll')
pols$kol_best=pols$kol_best/pols$act
pols_=aggregate(x=subset(pols,select=c('kol_best')),by=subset(pols,select='n_pol'), FUN="sum" )


pol=neir$opis_pol
pol=merge(pol,pols_,by='n_pol')

pol$k=1
pol_=aggregate(x=subset(pol,select=c('k','kol_best')),by=subset(pol,select='before'), FUN="sum" )













################################################################################


################################################################################


################################################################################

################################################################################

# удаление всех лишних переменных
rm(dann,aggrdb,shema,cols,dbPath, form,tmp,text,matrix,file,filePath,files,path,vid,srok,name,info,matrix_mar,first)
rm(format,kol_mar,kol_rez,kol_zap,mm,cen,mar,pass,rawdb,by,ll,SDcols,mar_,pass_,marb,sh,sh_,she,mar_pzd,dn)
rm(min_dat,max_dat,vcd_rus,matrix_,files_,shemi,fl,i,kol_f,ksh,l,len,pr,s,z,f,ff,kol,p,pp,sp,maro,maro_,marp,by_t)
rm(marshr,mData,pData,wData,mr,rst,rst_o,rst_n,iz,max_rst,min_date,o,kol_mest,mesta,pd,res,result,vag,max_n)
rm(mrst,nn,rr,tr,kol_day,mesta_,result_,kd,kdd,old_rez,st,kp,pzd,tm,m,r,min_mest,Date,ii,zap,max_date)
rm(pzd_,pzd_2,mDt,wData_,r1,r2,ddd,mas,x,xx,xz,d,f_y,neir_y,nm,nm_,dann_,dd,pol,dn_mas,get,out,plus)
rm(neir_,dann_is,dann_oth,dn_,dns,mas_,dd_,dn_mas_,dn1,dn2,ogr,tb,kol_vozm,pole,zn,dn_vib,ogr_z)
rm(all_ogr,all_vibor,vibor,vhod,kol_oper,oper,po,op,min_kol,all_vibor_,dann_2,k,kk,max_op,op_pred,pred_p)
rm(vib,vib_,kol_,dn_neir,dannie,mass,vh,vh_,kol_mas,kz,nom,dn_neir2,nset,nsets,oper_,pkol)
rm(par,par_,param,vy,kol_x,neiroset,nm1,nm2,y,zn_,dnn,reb,param_m,mas_zn,str,struct,kol_m,kol_neir)
rm(err,kol_reb,v,vih,b_mas,b_str,b_vib,b_err,end_proc,max_time,rad,step,tm_beg,zz)
rm(neir_hist,neir_hist_sokr,neir_vozm_vibori,error,max_oper,model,err_sr,s_err,neir_h,neir_sokr)
rm(neir_sokr_,id,nneir,pred_v,xz_,loper,og,str_,vb,vb_,vvv,before,kol_vh,xout,dnk,mb)
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
rm(error_sum,error_sum_,kol_r,kol_r_,max_dat_,poll,c,h,hh,filtr,pols,has,kol_pol,n_pol,n_poll)
rm(npol,npoll,fil,pol_,nset_m,all_mass,nset_p,all_param,all_pols,max,min,neur_,neur,neurs_)
rm(all_nset,all_str,stat,npols,pmass,er_,all_itogi,all_rezult,all_stat,rez_,kol_nastr,pols__,rez1,rez2,mnset,row)
rm(kol_ost,itog,kol_plus,pp_,ps_,ps,psh,in_nastr,stat_,stat_2,filtr_,rez_2,rezz,rr_,errs,it_,poll_,fil_,kol_fil)
rm(iz_time,kol_podnastr,poll__,poll2,poll1,plot,nsets_,nn_,plus_pol,fil2,filtr2,fil_2,row_,pols_)
rm(nms,pol_2,has_,has_2,pps,hhhh,ppp,rezn,it2,filtr_2,filtr_3,pols_2,pols_3,stat_3,sd,serr)
rm(progn,dann__,ddd_,dn__,dd_2,pdz_ish,mas1,mas1_,mas2,mas2_,mass_2,mm_,ms,ms_,vh1,vh2,part,stat_s)
rm(dann1,dd1,mas_new,mas_old,rez_3,rez_4,errs_,pf,xx_,bef_,pred,cc,inns,nom_nastr,itt,itt_,pl,st_)
rm(mas_s,rz,rz_,nm_day,ff_s,stat__,kol_ogr,nom_neur,vozm,en,en_,rzz,rrm,zap_rez,proc,all)
rm(rez_min,rez_max,ost,dn_s,vne,param_sum,plus_dats,pmas_b,dn_test,mas_ish,err_pr,m14,np)
rm(dn_1,dn_1_,vih_name,vihod,stat_old,neur_bad,zn_all,zn_del,new,max_npol,max_npoll,dn_p,dn_w)
rm(pol1,pol2,pol2_1,pols1,pols2,stat1,stat2,max_nset,fil1,fil2,mass1,mass2,p1,vhodi2,old)
rm(str_r,str_s,str_vih,str_p,npols_,err_prog,err_prog2,dist,resh,stat_resh,vv_,ish,mdt,pd_)
rm(kol_resh,max_resh,n_resh,opt,ver,nnn,pq,umens,mnass,rez2_,rm,rezm,kol_dann,ppf,ppz,nums)
rm(max_poll,pred_poll,podskaz,plus_time,polz,nom_pol,polp,polsp,it1,shh_,shem,pat,kl,sum_mar,tab_nom)
rm(dn_s_,dn_w_,wd,wd_,by_,wd_2,wd_sr,wd_stat,wd2,pas,inf__,matr1,matr2,sh1,col,kol_rez2,matrix__)
rm(rasp1,rasp2,mest,spas,sr,sts,ww,ww_,min_d,max_d,hass,rr_z,rasp3,rasp4,has2,rasp,wag,train,train2)
rm(rr1,rr1_b,rr2,rr2_b,rr2_,srr2,wag_b,inf_p,kday,kday_,rs1,rs2,max_pol,sum_pol,pz,pzd_ish)
rm(bf,rezb,s0,s1,da,f1,f2,upr_y,upr_v,upr,dann0,ppv,yy,rezult,dn0,fl_,rasp2_,dno,pm,ee,pol2_,str__)
rm(c_yz,d_y,d_z,dy,dz,e_yz,prg,beff,dp,dp_,dt,dnp,vidi,inf_bad,matr_itog,matr_old,vvvvv,vag0,poln,pols_f)
rm(mars,Murm_SPb,n1,n2,sahalin,max_dt,napr,dd__,ost_,ost2,okrugl,a,stan,sto,stn,mrs,mars_,sst,pas0,ff1,pol_old)
rm(vo,vo1,vo2,vx,vx1,vx2,vx1_,prognoz,err_posled,row_bef,stan_,mk,kol_is,dann_sts,apols,iss,param2,nset2,pph,ppp_)



warnings()


rm(neir,neurs,nnnnn,nnnnn2,neuron,neural,myPackage)

rm(neir2)



