
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







   name='sahalin';      #   
   name='doss'; 
   name='sapsan'
   name='dann'
   name='stat_doss'


#агрегация месячных данных - сапсаны (сперва пасс, потом вагоны) и прочие (вагоны, потом пасс)
#   myPackage$trs.Data.aggregate_month(name)
#Экстракция данных в базу, всё что есть. Хранит историю продажи в kol_day дней
#   kol_day=1;myPackage$trs.tData.extract(name,kol_day) 
# ??? после добавления с 2_2018, множество ошибок за 06_2017г- пассажиров вдвое больше (кажется)
   

neir=list();
vhod=list()
vhod$name=name
vhod$before=30 # за сколько дней должны быть прогнозы
vhod$max_time=60; vhod$max_time=10; #сколько секунд даётся на 1 настройку пула (или 1 нейросети в пуле)
#vhod$id=1;vhod$versia=0;vhod$pred_id=NA;vhod$pred_versia=NA;vhod$pred_error=NA
vhod$y='kp1';  #vhod$y='pkm1'; #какое поле идёт в прогноз
vhod$y_ogr=c('Seats'); #  vhod$y_ogr=c('Seats_km')  # какое поле ограничивает
vhod$min_err=5 #минимальная ошибка безразличия - либо число, либо 1% от (ограничитель либо (сам Y если нет ограничителя))


#кого принципиально можно в массив, на вход по данным, и вход по текущему значению (ограничение, цена...)
vhod$mas=c('Train','Type','Klass','First','Skor','Napr','pzd','weekday','day','week','mweek','month','rab_day','prazdn','nom_prazdn','hh_otp','hh_otp4')
vhod$xz=c('kp1','pkm1','plata1','rent1','cena1','scena1','FreeSeats','Seats','Seats_km','kp7','kp14','kp21') # ,'prazdn'
vhod$xs=c('s_kp1','s_pkm1','s_plata1','s_rent1','s_cena1','s_scena1','s_FreeSeats','s_Seats','s_Seats_km')
vhod$ostavl=c('Kol_vag')
vhod$proc_err=0.995;# vhod$proc_err=0.9

vhod$vne_zapazd=c('Seats','s_Seats','Seats_km','s_Seats_km') #какие входы можно брать до самой отправки, из будущего
vhod$dat=c('Date')
#vhod$errs=c('err_max','err_sr','err_80','err_95','err_50','err_90')
vhod$proc=c(100,80,95,50,90,NA)
#vhod$errs=c('err_max','err_sr','err_80','err_95','err_50','err_90','err') #пробник - статистика лучших и по реальной ошибке err
neir$vhod=vhod;rm(vhod)

#по описанию нейросети, как по маске, прочитать данные, оставить лишь всё нужное
neir=neuron$neir.dann_first(neir)
neuron$dannie=neir$dann;neir$dann=NULL
#neuron$vozm_vibori=neir$vozm_vibori  #специфические данные, нужны лишь однажды
neuron$vhod=neir$vhod;neuron$vhodi=neir$vhodi;
neuron$mass=neir$mass;rm(neir)

#  записать исходный neuron - только данные, без процедур
# 
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

######################################################################

     

     

#####################################################################
#создать внутреннюю стректуру, которую далее заполнять данными
neir=neuron$neir.init_neir(kol_pol=0)



#НАДО - СОЗДАТЬ СИСТЕМУ ПОДСКАЗОК
#      neir=neuron$neir.podskazka(neir)

# чтение из памяти   neir=neuron$neir.load_from_hist('')   # neir2=neir

# слияние 2 нейросетей  #   neir=neuron$neir.sliv(neir1,neir2)


#выбор, кого настраивать
nsets=neuron$neir.plus_nsets(neir,18)     #  nsets=1061

#при необходимости рассчитать новые входные поля
neir=neuron$neir.dobavl_vhodi(neir,nsets) 

#подготовить данные для всех ядер процессора
neurs=neuron$neir.get_neurs(neir,nsets)
rm(nsets)







# показать объёмы сформированных данных
# for (neur in neurs){print(names(neur))
#   stat=neur$stat;print(paste(stat$min_kol,stat$kol_nastr,sep='-'))  }





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
    
    stopCluster(clust);
    rm(clust)  
    gc() # теоретически это очистка памяти от излишков, но не работает
    
    # запись в память, для разборки
    nnnnn=neir;nnnnn2=neurs
    print(paste('Конец',Sys.time(),sep=' '))
    ##     { neir=nnnnn;neurs=nnnnn2
    
    #  print(paste('mas0',nrow(as.data.frame(names(neir$all_mass))),sep='='))
    
    #запись итогов в память из результатов поднастройки
    neir=neuron$neir.zapis_neurs(neir,neurs) 
    
    #  print(paste('mas1',nrow(as.data.frame(names(neir$all_mass))),sep='='))
    
    #подчистка самих настроечных данных - удалить пустые и полностью настроенные
    neurs=neuron$neir.podchist_neurs(neir,neurs)
    
    #подсчёт, сколько осталось в настройке
    inn=0;in_nastr=0;#inns=c(cores)
    for (neur in neurs){
      inn=inn+1;v=(!is.null(neur))*1;#inns=c(inns,v)
      in_nastr=in_nastr+v
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
          neur=neurs[k];for (nn in neur){
            if (!is.null(nn)){neurs_=c(neurs_,neur) }
          }}
        neurs=neurs_;rm(neurs_,k,inn,neur,nn)
      }
    }
    #  print(paste('mas2',nrow(as.data.frame(names(neir$all_mass))),sep='='))
    
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



#warnings()
#In if (pp_[, nm] > 0) { ... :
#    the condition has length > 1 and only the first element will be used


# Прогнозы
progn=neuron$neir.prognoz(neir) 





# график качества итогов
err=neuron$neir.rez_err(neir,1) 
#   err=neuron$neir.rez_err(neir,2) 


# график процесса настройки
errs=neir$errors;o=order(errs$dat_time);errs=errs[o,];errs$nn=(1:nrow(errs))
err=errs;err$t=1;merr=min(err$err);
errs$err=errs$err_sr;errs$t=2;err=rbind(err,errs)
errs$err=errs$err2;errs$t=3;err=rbind(err,errs)
errs$err=errs$err_prog;errs$t=4;err=rbind(err,errs)
errs$err=errs$err_prog2;errs$t=5;err=rbind(err,errs)
err=err[(!is.na(err$err)),]
#merr=min(err$err);
err=err[(err$err<merr*1.7),]
plot(x=err$nn,y=err$err,col=err$t)






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


# выдать итоговые прогнозы по полученной настройке
progn=neuron$neir.prognoz(neir,0) 
pzd=neir$vhod$pzd;pzd$pzd=abs(pzd$pzd)
progn=merge(progn,pzd,by=c('pzd','Napr'))


pzd_=unique(progn[,names(pzd)])



### записать прогноз в память
name=neir$vhod$name
dbPath=paste('./data/neuron/progn_',name,'.csv',sep='')
write.csv(x = progn, file = dbPath, fileEncoding = "WINDOWS-1251") 





prg=progn[(progn$pzd==6),]
prg=prg[(prg$Train!='-'),]
prg=prg[(prg$Type=='-'),]


prg$poln_=as.character((prg$yy>prg$Seats*0.95)-(prg$yy<prg$Seats/2));
prg[(is.na(prg$yy)),'poln_']='.'
prg$ed=1;
prg$seats_=(prg$Seats>800)*1

prg_stat=aggregate(x=subset(prg,select=c('ed')),
               by=subset(prg,select=c('poln','poln_','seats_')), FUN="sum" )




prg_=prg[((prg$hh_otp=='-')&(prg$hh_otp4!='-')&(prg$Type=='-')),]


pr=prg[(!is.na(prg$yy)),]




vh=neir$vhodi
mas=vh[(vh$tip=='mas'),]



################################################################################

dann=neuron$dannie


mass=neuron$mass
vh=neuron$vhodi

mass_=mass[(mass$name=='m11'),]

dann_=dann[(dann$m8==420),]
dann_=dann_[(dann_$m11==450),]
dann_=dann_[(dann_$m12==521),]


plot(dann_$dat,dann_$xz7,col=dann_$m5)

################################################################################




## посмотреть лучшую нейросеть
stat=neir$all_stat
filtr=neir$all_filtr
poll=neir$opis_poll;pols=neir$opis_pols;pol=neir$opis_pol

stat$proc_best=round(1000*stat$kol_best/stat$kol_dann)
#stat$bst=stat$kol_best*stat$proc_best
stat=stat[(stat$kol_x>0),]
o=order(-stat$kol_best);stat=stat[o,];stat_=stat[1,]

stat=stat[(stat$act!=3),]

# stat_=stat[(stat$nset==1201),]


filtr_=filtr[(filtr$nset %in% stat_$nset),]
pols_=pols[(pols$n_poll %in% filtr_$n_poll),]
pol_=pol[(pol$n_pol %in% pols_$n_pol),]

## картинка итогов лучшей нейросети
rez=neir$all_rezult
rez=rez[(rez$nset==stat_$nset),]
plot(rez$yy,rez$zn,col=(rez$best+1))

# а из чего лучшая нейросеть состоит?
vh=neir$vhodi
mas=vh[(vh$tip=='mas'),]
xx=vh[(vh$tip %in% c('xz','xs')),]
xx$get=xx$nm_;xx=xx[,c('nm','get')]
pol_=merge(pol_,xx,by='get')


#########
stat_s=stat[(stat$kol_best>0),]
stat_s$kol_b=stat_s$kol_best/stat_s$kol_x
stat_s=stat_s[,c('nset','kol_b')]

# filtr_2=filtr[(filtr$nset %in% stat_s$nset),]
filtr_2=merge(filtr,stat_s,by='nset')
filtr_2=filtr_2[,c('n_poll','kol_b')]
#pols_2=pols[(pols$n_poll %in% filtr_2$n_poll),]
pols_2=merge(pols,filtr_2,by='n_poll')
pols_2=aggregate(x=subset(pols_2,select=c('kol_b')),by=subset(pols_2,select='n_pol'), FUN="sum" )
#pol_2=pol[(pol$n_pol %in% pols_2$n_pol),]
pol_2=merge(pol,pols_2,by='n_pol')



#у кого ещё есть лучший вход
it=neir$all_itogi
it=it[(it$nset==stat_$nset),]
pols_3=pols[(pols$n_pol==88),]
filtr_3=filtr[(filtr$n_poll %in% pols_3$n_poll),]
stat_3=stat[(stat$nset %in% filtr_3$nset),]


stat_2=stat[(stat$nset %in% c(335,(1318:1333)),]


pols_2=pols[(pols$n_pol==112),]
filtr_2=filtr[(filtr$n_poll %in% pols_2$n_poll),]
stat_2=stat[(stat$nset %in% filtr_2$nset),]

rez__=rez[(rez$nset==9501),]

rez_2=rez[(rez$row==716),]

# rez_=rez[(rez$nset==5),]


fil=filtr[(filtr$n_poll==5),]


stat_=stat[(!(stat$nset %in% filtr$nset)),]

poll_=poll[(!(poll$n_poll %in% filtr$n_poll)),]

dn=dann[(!is.na(dann$z_2)),]



it_=it[(it$nset==26),]



### рассмотреть вход одной конкретной нейросети


stat=neir$all_stat
filtr=neir$all_filtr
poll=neir$opis_poll;pols=neir$opis_pols;pol=neir$opis_pol

stat_=stat[(stat$nset==312),]


filtr_=filtr[(filtr$nset %in% stat_$nset),]
pols_=pols[(pols$n_poll %in% filtr_$n_poll),]
pol_=pol[(pol$n_pol %in% pols_$n_pol),]

zn=as.character(pols_[,'zn'])

dann=neir$dann
dann=dann[(dann$m6!=423),]
dann=dann[,c('row',zn)]
dann$k=0;dann$nm=''
for(nm in zn){
  dann$k=dann$k+1*(is.na(dann[,nm]))
  dann[(is.na(dann[,nm])),'nm']=nm
  }
dann$kk=1;
rez=aggregate(x=subset(dann,select='kk'),by=subset(dann,select=c('k','nm')), FUN="sum" )



poll=neir$opis_poll
poll=poll[(poll$n_poll==filtr_$n_poll),]


rm(dann_)

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




################################################################################

################################################################################



###############################################################################


################################################################################

################################################################################





################################################################################





################################################################################
################################################################################



################################################################################


################################################################################


# Прогнозы
progn=neuron$neir.prognoz(neir) 

prg=progn[(progn$Type!='-'),]

prg$vag=prg$Seats/prg$Kol_vag
prg$ubr_vag=1*(prg$zn_max<prg$Seats-prg$vag)+1*(prg$zn_max+prg$err_95<prg$Seats-prg$vag)
prg$ubr_vag=prg$ubr_vag+1*(prg$zn_max+prg$err_95<prg$Seats-2*prg$vag)

################################################################################

################################################################################

################################################################################

################################################################################


################################################################################


stat=neir$all_stat
stat=stat[(stat$min_kol>stat$dann_test),]


rez=neir$all_rezult

rez=rez[(!(rez$nset %in% stat$nset)),]
neir$all_rezult=rez


# график качества итогов
err=neuron$neir.rez_err(neir,1) 
#   err=neuron$neir.rez_err(neir,2) 

################################################################################

################################################################################


################################################################################

ОШИБКА
[1] "Начало 2018-07-23 15:19:48"
Error in checkForRemoteErrors(val) : 
  3 nodes produced errors; first error: undefined columns selected 


for (neur in neurs){
  neur=neuron$neir.nastr_nset(neur)
  neur=neuron$neir.neur_stat(neur)
  }

################################################################################


#   nnnnn_f=neur


dn=neur$dn
stat=neur$stat



stat=neir$all_stat
stat=stat[(stat$nset==431),]

fil=neir$all_filtr
fil=fil[(fil$nset==431),]

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

time=30;err=0.98
neuron$vhod$max_time=time
neir$vhod$max_time=time
neir$all_stat$max_time=time
neuron$vhod$proc_err=err
neir$vhod$proc_err=err
rm(time,err)


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


#выбор, кого настраивать
nsets=neuron$neir.plus_nsets(neir,18) 

nsets=15

#при необходимости рассчитать новые входные поля
neir=neuron$neir.dobavl_vhodi(neir,nsets) 

на этой основе - поставить оптимальный порядок входов, для максимизации числа записей



################################################################################

################################################################################

################################################################################

################################################################################

Теперь исследовать результаты по данной нейросети

## посмотреть лучшую нейросеть
stat=neir$all_stat
filtr=neir$all_filtr
poll=neir$opis_poll;pols=neir$opis_pols;pol=neir$opis_pol
vh=neir$vhodi;mas=vh[(vh$tip=='mas'),]


poll_=poll[(poll$kol_pol==22),]
np=min(poll_$n_poll)
poll_=poll[(poll$n_poll %in% c((np-21):np)),]

#nset=11967
#fil=filtr[(filtr$nset==nset),]
#pols_=pols[(pols$n_poll %in% fil$n_poll),]

pols_=pols[(pols$n_poll %in% poll_$n_poll),]
fil=filtr[(filtr$n_poll %in% pols_$n_poll),]

ff=fil[(fil$vib==-1),];fil=fil[(!(fil$nset %in% ff$nset)),]

for (nm in mas$name){fil=fil[(fil[,nm]==0),]}

stat_=stat[(stat$nset %in% fil$nset),]



stat_=stat[(stat$nset %in% fil$nset),]

o=order(-stat_$kol_best);stat_=stat_[o,]
stat_=stat_[1,]

fil=filtr[(filtr$nset==stat_$nset),]



rez=neir$all_rezult
rez_=rez[(rez$nset==stat_$nset),]


#    plot(rez_$yy,rez_$zn)


################################################################################

вопрос -= данные по аренде? - удалить из исходников (потом)!!!

Вопрос - почему даже изначально номера nset идут не подряд?



################################################################################


################################################################################

pol=neir$opis_pols


################################################################################





stat=neir$all_stat
stat=stat[(stat$kol_best>0),]



st=stat[(stat$nset %in%(7775:7797)),]

fil=neir$all_filtr
fil=fil[(fil$nset %in% stat$nset),]


fil=fil[(fil$nset %in% fil[(fil$poln==1),'nset']),]


stat_=stat[(stat$nset %in% fil$nset),]


################################################################################


################################################################################


stat=neir$all_stat
stat=stat[(stat$kol_best>0),]
st=stat[(stat$all_time<31),]

ПОДНАСТРОИТЬ ЗАДАННУЮ НЕЙРОСЕТЬ, ПОСМОТРЕТЬ ГРАФИК ПРОГНОЗА

nsets=5350


#при необходимости рассчитать новые входные поля
neir=neuron$neir.dobavl_vhodi(neir,nsets) 

#подготовить данные для всех ядер процессора
neurs=neuron$neir.get_neurs(neir,nsets)

for(neur in neurs){}

err=neur$stat$error
print(neur$stat$error)
while (is.null(neur$rezult)){
  neur=neuron$neir.nastr_nset(neur)
  print(neur$stat$error) }
rez=neur$rezult;plot(rez$yy,rez$zn)  
  
### сама поднастройка
for (i in (1:10)){
  neur=neuron$neir.nastr_nset(neur)
  print(neur$stat$error) }
  #    neur=neuron$neir.neur_stat(neur)
rez=neur$rezult;plot(rez$yy,rez$zn)







################################################################################


################################################################################


################################################################################


################################################################################



################################################################################


################################################################################

ПЕРВИЧНАЯ ОБРАБОТКА ДАННЫХ


name='dann'


#Экстракция данных в базу, всё что есть. Хранит историю продажи в kol_day дней
kol_day=1;myPackage$trs.tData.extract(name,kol_day) 


   


################################################################################

   




#Экстракция данных в базу, всё что есть. Хранит историю продажи в kol_day дней
myPackage$trs.tData.extract <- function(name,kol_day) {
  # Объединяет агрегированные базы данных о продажах
  # билетов и составности поездов в одну базу.
  # Args:
  #   extractor: метод объединения
  # Returns:
  #   объединенную базу, если extdbName = NULL
  
  if (name=='sapsan'){ name='doss' }
  
  #if (typeof(pData) == "character") {pData=myPackage$trs.pData.aggr.load(pData)}
  #if (typeof(mData) == "character") {mData=myPackage$trs.pData.aggr.load(paste(mData, "_mar", sep = ""))}
  #if (typeof(wData) == "character") {wData=myPackage$trs.wData.aggr.load(wData)}
  
  info=myPackage$trs.dann_load('info','rez') # ЧТО БЫЛО ПРОЧИТАНО РАНЬШЕ?
  info=info[(info$Database==name),]
  info=info[(info$kol_rez>0),]
  info=info[(info$ext!=1)|is.na(info$ext),]
  
  if (nrow(info)>0){
    # исходники
    pData=myPackage$trs.dann_load(name,'pas')
    mData=myPackage$trs.dann_load(name,'mar')
    wData=myPackage$trs.dann_load(name,'vag')
    pzd=myPackage$trs.dann_load(name,'pzd')  #прежний список поездов
    
    
    min_date=min(as.Date(info$min_date))-2 #пересчёт только того, что ещё не экстрагировалось!
    pData=pData[(as.Date(pData$Date)>=min_date),]
    mData=mData[(as.Date(mData$Date)>=min_date),]
    wData=wData[(as.Date(wData$Date)>=min_date),]
    
    pData$Klass=substr(pData$Klass,1,1);pData[(pData$Klass==pData$Type),'Klass']='-' 
    wData$Klass=substr(wData$Klass,1,1);wData[(wData$Klass==wData$Type),'Klass']='-' 
    
    if (name=='sahalin'){pData$Klass='-';wData$Klass='-'}
    
    if (name %in% c('sapsan','doss')){
      pData$Type=pData$Klass;pData$Klass='-';
      wData$Type=wData$Klass;wData$Klass='-'; }
    
    
    # собственно рассчёт истории заполнения каждого конкретного поезда
    res=myPackage$trs.tData.extractor(pData, mData, wData, pzd, kol_day) #СОБСТВЕННО НАРАБОТКА ДАННЫХ
    result=res$result;pzd=res$pzd;rm(res)
    
    if (name %in% c('sapsan','sahalin','doss')){result$Klass=NULL}
    
    min_date=min_date+2
    result=result[(as.Date(result$Date)>=min_date),]
    
    old_rez=myPackage$trs.dann_load(name,'ext')
    if (!is.null(old_rez)>0){
      old_rez=old_rez[(as.Date(old_rez$Date)<min_date),]
      result=myPackage$sliv(old_rez,result)}
    rm(old_rez)
    
    #запись в память
    myPackage$trs.Data_save(result, name,'ext',TRUE)
    myPackage$trs.Data_save(pzd, name,'pzd',TRUE)
    
    info=myPackage$trs.dann_load('info','rez')
    info[(info$Database==name),'ext']=1
    myPackage$trs.Data_save(info, 'info','rez',TRUE)
  }
  #return (result) 
  
  result=1;min_date=1;mData=1;pData=1;wData=1;pzd=1;
  
  rm(info,mData,pData,pzd,result,wData,kol_day,min_date,name)
}
#Экстракция данных в базу, всё что есть. Хранит историю продажи в kol_day дней
#   kol_day=1;   name='sahalin';
#   myPackage$trs.tData.extract(name,kol_day) 




























################################################################################
# статистики вагонов по поездам


pData=myPackage$trs.dann_load(name,'pas')
wData=myPackage$trs.dann_load(name,'vag')

wData$mon=month(wData$Date);wData$year=year(wData$Date)
pData$mon=month(pData$Date);pData$year=year(pData$Date)

by_=c('Skp','Train','year','mon')

pData$Pkm=as.numeric(pData$Pkm)
wData$Seats_km=as.numeric(wData$Seats_km)
wData$skm=as.numeric(wData$Seats*wData$Rasst)
wData$skm_f=as.numeric(wData$FreeSeats*wData$Rasst)
wData$vag_f=wData$FreeSeats*wData$Kol_vag/wData$Seats
wData$vag_f=pmax(round(wData$vag_f-0.8),0)
wData$vkm_f=as.numeric(wData$vag_f*wData$Rasst)
wData$vkm=as.numeric(wData$Kol_vag*wData$Rasst)




dn_w=aggregate(x=subset(wData,select=c('Seats','FreeSeats','Seats_km','Kol_vag','vkm','skm','skm_f','vag_f','vkm_f')),
             by=subset(wData,select=by_), FUN="sum" )

dn_p=aggregate(x=subset(pData,select=c('Cena','Pkm','Plata','Kol_pas')),
               by=subset(pData,select=by_), FUN="sum" )



dn=merge(dn_w,dn_p,by=by_)
dn$Plata=dn$Plata/10000000
dn$Cena=dn$Cena/10000000


dn$pl=(dn$Plata*dn$FreeSeats/(1+dn$Seats-dn$FreeSeats))

dn=dn[(dn$year<2018)|(dn$mon<10),]
dn=dn[(dn$year>2017)|(dn$mon>8),]

# select=c('Skp','year','mon')

dn_s=aggregate(x=subset(dn,select=c('pl','Plata','Seats','Seats_km','FreeSeats','Kol_pas','Pkm','Kol_vag','vkm','skm','skm_f','vag_f','vkm_f')),
               by=subset(dn,select=c('Skp')), FUN="sum" )

dn_s$pl=round(dn_s$pl)
dn_s$Plata=round(dn_s$Plata)

dn_s$k=round(100*dn_s$pl/dn_s$Plata)
dn_s$kv=round(100*dn_s$vag_f/dn_s$Kol_vag)
dn_s$kvkm=round(100*dn_s$vkm_f/dn_s$vkm)

dn_s$srst=dn_s$vkm/dn_s$Kol_vag

dn_s$kskm=round(100*dn_s$Pkm/dn_s$Seats_km)






###########################
станции с лишними вагонами???

wd=myPackage$trs.dann_load('dann','vag')

wd=wd[(substr(wd$Sto,1,2)=='20')&(substr(wd$Stn,1,2)=='20'),]

wd$vag_f=wd$FreeSeats*wd$Kol_vag/wd$Seats
wd$vag_f=pmax(round(wd$vag_f-0.8),0)
wd$vkm_f=as.numeric(wd$vag_f*wd$Rasst)
wd$Vag_km=as.numeric(wd$Vag_km)

wd=wd[(as.Date(wd$Date)<as.Date('2018-10-01')),]

wd$year=as.numeric(substr(as.character(wd$Date),1,4))

wd_stat=aggregate(x=subset(wd,select=c('vag_f','vkm_f','Kol_vag','Vag_km','Seats','FreeSeats')),
                  by=subset(wd,select=c('Skp','year')), FUN="sum" )

by=c('Skp','Type','Klass','year')



wd=wd[(wd$vag_f>0),]

wd_=aggregate(x=subset(wd,select=c('vag_f','Kol_vag','Vag_km')),
              by=subset(wd,select=c(by,'Sto','Stn','Date')), FUN="sum" )
wd_2=aggregate(x=subset(wd,select=c('Rasst')),
              by=subset(wd,select=c(by,'Sto','Stn','Date')), FUN="min" )
wd=merge(wd_,wd_2,by=c(by,'Sto','Stn','Date'))

#wd$vkm_f=wd$vag_f*wd$Rasst



# теперь - удаляем одновременно туда и обратно

wd_=wd;
wd_$st=wd_$Stn;wd_$Stn=wd_$Sto;wd_$Sto=wd_$st;wd_$st=NULL
wd_$vag=wd_$vag_f;wd_$vag_f=NULL


wd2=merge(wd,wd_,by=c(by,'Sto','Stn','Date','Rasst'))

wd2$v=pmin(wd2$vag,wd2$vag_f)
wd2$vkm=wd2$v*wd2$Rasst



wd2=aggregate(x=subset(wd2,select=c('v','vkm')),
              by=subset(wd2,select=c('Skp','year')), FUN="sum" )


wd_sr=merge(wd_stat,wd2,by=c('Skp','year'))

wd_sr$pr_vag=round(1000*wd_sr$v/wd_sr$Kol_vag)/10
wd_sr$pr_vkm=round(1000*wd_sr$vkm/wd_sr$Vag_km)/10
wd_sr$pr_seats=round(1000*wd_sr$FreeSeats/wd_sr$Seats)/10

wd_sr$pr_vag_f=round(1000*wd_sr$vag_f/wd_sr$Kol_vag)/10

wd_sr$sr_rst=round(wd_sr$vkm/wd_sr$v)


ww=rbind(wd,wd_)
rm(wd_)

wd$p=''
for(zn in by){wd$p=paste(wd$p,wd[,zn],sep='-');wd[,zn]=NULL}

# o=order(wd$p,wd$Sto,wd$Stn,wd$Date);wd=wd[o,]

wd$v=abs(wd$vag_f)
#wd_=aggregate(x=subset(wd,select=c('vag_f')),
#               by=subset(wd,select=c('p','st','Date')), FUN="sum" )

wd_=aggregate(x=subset(wd,select=c('vag_f','v')),
              by=subset(wd,select=c('p','Sto','Stn')), FUN="sum" )

wd_2=wd_[(abs(wd_$vag_f)<wd_$v/5),]


plot(wd_2$v,wd_2$vag_f)


################################################################################




###########################
пассажиры так и эдак

pas=myPackage$trs.dann_load('dann','pas')
spas=myPackage$trs.dann_load('dann','spas')



p=aggregate(x=subset(pas,select=c('Kol_pas')),
          by=subset(pas,select=c('Date','Train')), FUN="sum" )
ps=aggregate(x=subset(spas,select=c('Kol_pas')),
            by=subset(spas,select=c('Date','Train')), FUN="sum" )

ps$kp=ps$Kol_pas;ps$Kol_pas=NULL

pp=merge(p,ps,by=c('Date','Train'))

pp=pp[(pp$Kol_pas!=pp$kp),]
pp$k=1;
pp_=unique(pp[,c('Date','k')])   

####СОВПАДАЕТ


spas$Date=as.character(spas$Date)
min_d=min(spas$Date);max_d=max(spas$Date)
min_d=paste(substr(min_d,1,8),'31',sep='')
max_d=paste(substr(max_d,1,8),'00',sep='')

spas_=spas[(spas$Date>min_d)&(spas$Date<max_d),]
rm(spas_)











######################################################
######################################################
######################################################
пассажиры число мест по минимуму???


spas=myPackage$trs.dann_load('dann','spas')

spas$Date=as.character(spas$Date)

min_dt=min(spas$Date)
max_dt=max(spas$Date)
min_dt=paste(substr(min_dt,1,8),'99',sep='')

year=as.numeric(substr(min_dt,1,4))
max_dt=paste(as.character(year+1),substr(min_dt,5,15),sep='')

spas=spas[(spas$Date>min_dt)&(spas$Date<max_dt),]


spas$Skp=as.numeric(spas$Skp)

o=order(spas$Date,spas$Train,spas$Skp,spas$tp)
spas=spas[o,]


######################################################
######################################################
######################################################
# добавить вагоны

wd=myPackage$trs.dann_load('dann','vag')
wd$Date=as.character(wd$Date)
wd=wd[(wd$Date<'2018-08-99'),]

wd$tp=paste(wd$Type,wd$Klass,sep='')
wd$tab_nom=NULL;wd$Type=NULL;wd$Klass=NULL


wd=wd[(substr(as.character(wd$Sto),1,2)==20)&(substr(as.character(wd$Stn),1,2)==20),]

{# оставить лишь тех, где только 1 вариант станций отправления-назначения вагона
  wd$kol=1
  wd_=aggregate(x=subset(wd,select=c('kol')),
                by=subset(wd,select=c('Date','Train','tp')), FUN="sum" )
  wd_=wd_[(wd_$kol==1),];wd_$kol=NULL
  wd=merge(wd,wd_,by=c('Date','Train','tp'));wd$kol=NULL
  rm(wd_)
  }
#wd_=wd[(wd$Date=='2017-09-26')&(wd$Train=='0301НА')&(wd$tp=='П3П'),]

#  ww=wd;  #  wd=ww

# до занятости на 3/4
wd$svag1=wd$zan0+wd$zan1+wd$zan2 - round((wd$zan1+2*wd$zan2)/3 +0.49)
# до полной занятости
wd$svag2=wd$zan0+wd$zan1+wd$zan2 - round((wd$zan1+2*wd$zan2)/4 +0.49)

# до максимальной занятости по числу мест
wd$svag3=round(wd$FreeSeats/wd$max_seats-0.5)


wd$svag1=pmin(wd$svag1,wd$Kol_vag)
wd$svag2=pmin(wd$svag2,wd$Kol_vag)
wd$svag3=pmin(wd$svag3,wd$Kol_vag)

wd$zan0=NULL;wd$zan1=NULL;wd$zan2=NULL;wd$zan3=NULL;


o=order(wd$Date,wd$Train,wd$Skp,wd$tp)
wd=wd[o,]

################### слить вместе вагоны и пассажиры
if (FALSE){
  wd_=merge(wd,spas,by=c('Date','Train','Skp','tp'))
  wd_$svag4=pmax(round((wd_$Seats-wd_$mest)/wd_$max_seats-0.5),0)
  wd_$svag4=pmin(wd_$svag4,wd_$Kol_vag)
}






wd_sv=wd_
wd_sv$vkm=as.numeric(wd_sv$Kol_vag*wd_sv$Rasst)
wd_sv$svkm1=as.numeric(wd_sv$svag1*wd_sv$Rasst)
wd_sv$svkm2=as.numeric(wd_sv$svag2*wd_sv$Rasst)
wd_sv$svkm3=as.numeric(wd_sv$svag3*wd_sv$Rasst)
wd_sv$svkm4=as.numeric(wd_sv$svag4*wd_sv$Rasst)
wd_sv$year=substr(wd_sv$Date,1,4)
wd_sv$Type=substr(wd_sv$tp,1,1)


wd_tp=aggregate(x=subset(wd_sv,select=c('Kol_vag','svag1','svag2','svag3','svag4','vkm','svkm1','svkm2','svkm3','svkm4')),
                by=subset(wd_sv,select=c('Skp','Type')), FUN="sum" )
wd_tp=wd_tp[(wd_tp$Skp==1),]



wd_sv=aggregate(x=subset(wd_sv,select=c('Kol_vag','svag1','svag2','svag3','svag4','vkm','svkm1','svkm2','svkm3','svkm4')),
              by=subset(wd_sv,select=c('Skp','year')), FUN="sum" )

wd_=aggregate(x=subset(wd_sv,select=c('Kol_vag','svag1','svag2','svag3','svag4','vkm','svkm1','svkm2','svkm3','svkm4')),
                by=subset(wd_sv,select=c('Skp')), FUN="sum" )
wd_$year=NA
wd_sv=rbind(wd_sv,wd_);rm(wd_)





ww1=wd_sv
ww1=ww1[(ww1$Skp==1),]

#просто по вагонам

wd_sv=wd
wd_sv$vkm=as.numeric(wd_sv$Kol_vag*wd_sv$Rasst)
wd_sv$svkm1=as.numeric(wd_sv$svag1*wd_sv$Rasst)
wd_sv$svkm2=as.numeric(wd_sv$svag2*wd_sv$Rasst)
wd_sv$svkm3=as.numeric(wd_sv$svag3*wd_sv$Rasst)
wd_sv$year=substr(wd_sv$Date,1,4)

wd_sv$Type=substr(wd_sv$tp,1,1)

wd_tp=aggregate(x=subset(wd_sv,select=c('Kol_vag','svag1','svag2','svag3','vkm','svkm1','svkm2','svkm3')),
                by=subset(wd_sv,select=c('Skp','Type')), FUN="sum" )
wd_tp=wd_tp[(wd_tp$Skp==1),]


wd_sv=aggregate(x=subset(wd_sv,select=c('Kol_vag','svag1','svag2','svag3','vkm','svkm1','svkm2','svkm3')),
                by=subset(wd_sv,select=c('Skp','year')), FUN="sum" )




ww2=wd_sv
ww2=ww2[(ww2$Skp==1),]
 
ww=myPackage$sliv(ww1,ww2)  ##### в эксель!!!

ww$p_vkm1=round(1000*ww$svkm1/ww$vkm)/10
ww$p_vkm2=round(1000*ww$svkm2/ww$vkm)/10
ww$p_vkm3=round(1000*ww$svkm3/ww$vkm)/10
ww$p_vkm4=round(1000*ww$svkm4/ww$vkm)/10


ww$p_vag1=round(1000*ww$svag1/ww$Kol_vag)/10
ww$p_vag2=round(1000*ww$svag2/ww$Kol_vag)/10
ww$p_vag3=round(1000*ww$svag3/ww$Kol_vag)/10
ww$p_vag4=round(1000*ww$svag4/ww$Kol_vag)/10


ww$rst1=ww$svkm1/ww$svag1
ww$rst2=ww$svkm2/ww$svag2
ww$rst3=ww$svkm3/ww$svag3
ww$rst4=ww$svkm4/ww$svag4







################################################################################
################################################################################
#  теперь поиск минимума 


nm='svag3'  # по кому именно ищем оптимум

ww=wd[(wd$Skp==1),] # исходник - лишь вагоны
ww=ww[(ww$Rasst>=300),] # только не короткие
ww=ww[(ww$Kol_vag>0),] # в принципе наличие вагонов
ww$zn=ww[,nm]
ww=ww[(ww$zn>0),]
#for(nm in c('svag1','svag2','svag3','FreeSeats','Seats','Kol_vag','max_seats','Seats_km','Vag_km','Rasst')){
#  ww[,nm]=NULL }


ww$mr=paste(ww$Sto,ww$Stn,sep='-')
ww$napr=1
o=(ww$Sto>ww$Stn)
ww[o,'mr']=paste(ww[o,'Stn'],ww[o,'Sto'],sep='-')
ww[o,'napr']=2
ww$mr=paste(ww$mr,ww$tp,sep='-')

ww_rst=aggregate(x=subset(ww,select=c('Rasst')),
                  by=subset(ww,select=c('mr')), FUN="min" )


ww=aggregate(x=subset(ww,select=c('zn')),
             by=subset(ww,select=c('mr','Date','napr')), FUN="sum" )


##################################### в тот же день (vag0)

ww_r=ww

ww_r$zn1=0;ww_r$zn2=0;
o=(ww_r$napr==1)
ww_r[o,'zn1']=ww_r[o,'zn']
ww_r[(!o),'zn2']=ww_r[(!o),'zn']

ww_r=aggregate(x=subset(ww_r,select=c('zn1','zn2')),
              by=subset(ww_r,select=c('mr','Date')), FUN="sum" )

ww_r$vag0=pmin(ww_r$zn1,ww_r$zn2)


ww_r$zn1=ww_r$zn1-ww_r$vag0
ww_r$zn2=ww_r$zn2-ww_r$vag0
ww_r$Date=as.Date(ww_r$Date)


# теперь подсчёт с запаздыванием в 1 день   туда
ww_=ww_r;wws=ww_r;

ww_$Date=ww_$Date-1
ww_=ww_[,c('mr','Date','zn2')]
wws=wws[,c('mr','Date','zn1')]
ww_=merge(ww_,wws,by=c('mr','Date'))
ww_$vag1_1=pmin(ww_$zn1,ww_$zn2)
ww_$zn2=NULL;ww_$zn1=NULL

wws=ww_
wws$Date=wws$Date+1
wws$vag1_1_=wws$vag1_1;wws$vag1_1=NULL

ww_r=merge(ww_r,ww_,by=c('mr','Date'),all=TRUE)
ww_r=merge(ww_r,wws,by=c('mr','Date'),all=TRUE)

ww_r[(is.na(ww_r$vag1_1)),'vag1_1']=0
ww_r[(is.na(ww_r$vag1_1_)),'vag1_1_']=0

ww_r$zn1=ww_r$zn1-ww_r$vag1_1
ww_r$zn2=ww_r$zn2-ww_r$vag1_1_


# теперь подсчёт с запаздыванием в 1 день  обратно

ww_=ww_r;wws=ww_r;
ww_$Date=ww_$Date+1
ww_=ww_[,c('mr','Date','zn2')]
wws=wws[,c('mr','Date','zn1')]
ww_=merge(ww_,wws,by=c('mr','Date'))
ww_$vag1_2=pmin(ww_$zn1,ww_$zn2)
ww_$zn2=NULL;ww_$zn1=NULL

wws=ww_
wws$Date=wws$Date-1
wws$vag1_2_=wws$vag1_2;wws$vag1_2=NULL

ww_r=merge(ww_r,ww_,by=c('mr','Date'),all=TRUE)
ww_r=merge(ww_r,wws,by=c('mr','Date'),all=TRUE)

ww_r[(is.na(ww_r$vag1_2)),'vag1_2']=0
ww_r[(is.na(ww_r$vag1_2_)),'vag1_2_']=0

ww_r$zn1=ww_r$zn1-ww_r$vag1_2
ww_r$zn2=ww_r$zn2-ww_r$vag1_2_





# теперь подсчёт с запаздыванием в 2 дня   туда
ww_=ww_r;wws=ww_r;

ww_$Date=ww_$Date-2
ww_=ww_[,c('mr','Date','zn2')]
wws=wws[,c('mr','Date','zn1')]
ww_=merge(ww_,wws,by=c('mr','Date'))
ww_$vag2_1=pmin(ww_$zn1,ww_$zn2)
ww_$zn2=NULL;ww_$zn1=NULL

wws=ww_
wws$Date=wws$Date+2
wws$vag2_1_=wws$vag2_1;wws$vag2_1=NULL

ww_r=merge(ww_r,ww_,by=c('mr','Date'),all=TRUE)
ww_r=merge(ww_r,wws,by=c('mr','Date'),all=TRUE)

ww_r[(is.na(ww_r$vag2_1)),'vag2_1']=0
ww_r[(is.na(ww_r$vag2_1_)),'vag2_1_']=0

ww_r$zn1=ww_r$zn1-ww_r$vag2_1
ww_r$zn2=ww_r$zn2-ww_r$vag2_1_





# теперь подсчёт с запаздыванием в 2 дня   обратно
ww_=ww_r;wws=ww_r;

ww_$Date=ww_$Date+2
ww_=ww_[,c('mr','Date','zn2')]
wws=wws[,c('mr','Date','zn1')]
ww_=merge(ww_,wws,by=c('mr','Date'))
ww_$vag2_2=pmin(ww_$zn1,ww_$zn2)
ww_$zn2=NULL;ww_$zn1=NULL

wws=ww_
wws$Date=wws$Date-2
wws$vag2_2_=wws$vag2_2;wws$vag2_2=NULL

ww_r=merge(ww_r,ww_,by=c('mr','Date'),all=TRUE)
ww_r=merge(ww_r,wws,by=c('mr','Date'),all=TRUE)

ww_r[(is.na(ww_r$vag2_2)),'vag2_2']=0
ww_r[(is.na(ww_r$vag2_2_)),'vag2_2_']=0

ww_r$zn1=ww_r$zn1-ww_r$vag2_2
ww_r$zn2=ww_r$zn2-ww_r$vag2_2_

rm(ww_,wws)

############### подбивка итогов

ww_st=ww_r

ww_st$svob0=ww_st$vag0*2
ww_st$svob1=ww_st$vag1_1+ww_st$vag1_1_+ww_st$vag1_2+ww_st$vag1_2_+ww_st$svob0
ww_st$svob2=ww_st$vag2_1+ww_st$vag2_1_+ww_st$vag2_2+ww_st$vag2_2_+ww_st$svob1
ww_st$ost=ww_st$zn1+ww_st$zn2
ww_st$year=as.numeric(substr(ww_st$Date,1,4))
ww_st$mon=as.numeric(substr(ww_st$Date,6,7))

ww_st=aggregate(x=subset(ww_st,select=c('svob0','svob1','svob2','ost')),
              by=subset(ww_st,select=c('mr','year','mon')), FUN="sum" )

ww_st=merge(ww_st,ww_rst,by='mr')
ww_st$tp=substr(ww_st$mr,17,20)
ww_st$type=substr(ww_st$tp,1,1)

ww_st$spkm0=ww_st$svob0*ww_st$Rasst
ww_st$spkm1=ww_st$svob1*ww_st$Rasst
ww_st$spkm2=ww_st$svob2*ww_st$Rasst
ww_st$ost_pkm=ww_st$ost*ww_st$Rasst

ww_st_tp=aggregate(x=subset(ww_st,select=c('svob0','svob1','svob2','ost','spkm0','spkm1','spkm2','ost_pkm')),
                by=subset(ww_st,select=c('type')), FUN="sum" )




ww_st_tp=aggregate(x=subset(ww_st,select=c('Kol_vag','svob0','svob1','svob2','ost','pkm','spkm0','spkm1','spkm2','ost_pkm')),
                   by=subset(ww_st,select=c('type','mr')), FUN="sum" )


ww_st_tp$rst0=ww_st_tp$spkm0/ww_st_tp$svob0
ww_st_tp$rst1=ww_st_tp$spkm1/ww_st_tp$svob1
ww_st_tp$rst2=ww_st_tp$spkm2/ww_st_tp$svob2









################################### смотрим конкретное направление


ww_st=ww_r

ww_st$svob0=ww_st$vag0*2
ww_st$svob1=ww_st$vag1_1+ww_st$vag1_1_+ww_st$vag1_2+ww_st$vag1_2_+ww_st$svob0
ww_st$svob2=ww_st$vag2_1+ww_st$vag2_1_+ww_st$vag2_2+ww_st$vag2_2_+ww_st$svob1

ww_st=aggregate(x=subset(ww_st,select=c('svob0')),
                by=subset(ww_st,select=c('mr')), FUN="sum" )
ww_st=merge(ww_st,ww_rst,by='mr')

ww_st$st1=substr(ww_st$mr,1,7)
ww_st$st2=substr(ww_st$mr,9,15)
ww_st$tp=substr(ww_st$mr,17,19)
ww_st$Type=substr(ww_st$mr,17,17)


wd_st=aggregate(x=subset(wd,select=c('Kol_vag')),
                by=subset(wd,select=c('tp','Sto','Stn')), FUN="sum" )

wd_st$st1=pmin(wd_st$Sto,wd_st$Stn)
wd_st$st2=pmax(wd_st$Sto,wd_st$Stn)


wd_st=aggregate(x=subset(wd_st,select=c('Kol_vag')),
                by=subset(wd_st,select=c('tp','st1','st2')), FUN="sum" )

ww_st=merge(ww_st,wd_st,by=c('tp','st1','st2'))
ww_st=ww_st[(ww_st$Type %in% c('К','П')),]

ww_st=aggregate(x=subset(ww_st,select=c('Kol_vag','svob0')),
                by=subset(ww_st,select=c('Type','st1','st2','Rasst')), FUN="sum" )


ww_st$vag_k=0;ww_st$vag_p=0;
ww_st$svob_k=0;ww_st$svob_p=0;
o=(ww_st$Type=='К')
ww_st[o,'vag_k']=ww_st[o,'Kol_vag']
ww_st[o,'svob_k']=ww_st[o,'svob0']
o=(ww_st$Type=='П')
ww_st[o,'vag_p']=ww_st[o,'Kol_vag']
ww_st[o,'svob_p']=ww_st[o,'svob0']



ww_st_=aggregate(x=subset(ww_st,select=c('vag_k','vag_p','svob_k','svob_p')),
                by=subset(ww_st,select=c('st1','st2','Rasst')), FUN="sum" )




ww_st_=aggregate(x=subset(ww_st,select=c('vag_k','vag_p','svob_k','svob_p')),
                 by=subset(ww_st,select=c('Type')), FUN="sum" )
#######################



################### слить вместе вагоны и пассажиры - направления с наибольшей высвобождаемостью

  o=order(wd$Date,wd$Train,wd$Skp,wd$tp)
  wd=wd[o,]
  
  wd_=merge(wd,spas,by=c('Date','Train','Skp','tp'))
  
  wd_$mest_sv=pmax(wd_$Seats-wd_$mest,0)
  wd_=wd_[(wd_$svag3==0),]
  wd_=wd_[(wd_$FreeSeats<wd_$Seats/10),]
  
  wd__st=aggregate(x=subset(wd_,select=c('Seats','FreeSeats','mest_sv','mest','Kol_vag')),
                   by=subset(wd_,select=c('Sto','Stn','tp')), FUN="sum" )
  
wd__st$Type=substr(wd__st$tp,1,1)

wd__st$st1=pmin(wd__st$Sto,wd__st$Stn)
wd__st$st2=pmax(wd__st$Sto,wd__st$Stn)

wd__st=aggregate(x=subset(wd__st,select=c('Seats','FreeSeats','mest_sv','mest','Kol_vag')),
                 by=subset(wd__st,select=c('st1','st2','Type')), FUN="sum" )
wd__st$osvob=wd__st$mest_sv-wd__st$FreeSeats


################################################################################

################################################################################


################################################################################



name='stat_doss'


#агрегация месячных данных - сапсаны (сперва пасс, потом вагоны) и прочие (вагоны, потом пасс)
#   myPackage$trs.Data.aggregate_month(name)

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
rm(neir_sokr_,id,nneir,pred_v,xz_,loper,og,str_,vb,vb_,vvv,before,kol_vh,xout)
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
rm(pol1,pol2,pol2_1,pols1,pols2,stat1,stat2,max_nset,fil1,fil2,mass1,mass2,p1,vhodi2)
rm(str_r,str_s,str_vih,str_p,npols_,err_prog,err_prog2,dist,resh,stat_resh,vv_,ish,mdt)
rm(kol_resh,max_resh,n_resh,opt,ver,nnn,pq,umens,mnass,rez2_,rm,rezm,kol_dann,ppf,ppz,nums)
rm(max_poll,pred_poll,podskaz,plus_time,polz,nom_pol,polp,polsp,it1,shh_,shem,pat,kl,sum_mar,tab_nom)
rm(dn_s_,dn_w_,wd,wd_,by_,wd_2,wd_sr,wd_stat,wd2,pas,inf__,matr1,matr2,sh1,col,kol_rez2)

rm(rasp1,rasp2,mest,spas,sr,sts,ww,ww_,min_d,max_d,hass,rr_z,rasp3,rasp4,has2)



warnings()


rm(neir,neurs,nnnnn,nnnnn2)




