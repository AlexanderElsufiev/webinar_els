
# РАЗВИТИЕ ПРОГРАММЫ new_program_new, только before станет из нескольких запаздываний, и опора не new_program3 а new_program4

# ИЗ СТАРОЙ ПРОГРАММЫ trainset, ЧТО ЕЩЁ НЕ ВЗЯТО - В ФАЙЛЕ "trainset - что ещё не взято"

if (getwd()=="C:/Users/user/Documents"){  #если на локальной машине - не отрабатывает пока
  setwd("D:/RProjects/test/") }

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


if (!require("digest")) {install.packages("digest")}
library("digest")


#программы работы с исходными данными
eval(parse('./scripts/new_program1.R', encoding="UTF-8"))
#eval(parse('./scripts/new_program3.R', encoding="UTF-8")) - заменил на копию, где before - разные значения
eval(parse('./scripts/new_program4.R', encoding="UTF-8"))

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





#выборка для нужного направления поездов
#  napr=list();napr$name='SPb-Mos'; napr$sto=c(2004001,2004003,2004006);napr$stn=2006004;
#Экстракция данных в базу, всё что есть по указанному направлению (станции начала и конца)
# myPackage$trs.tData.extract_mars(napr) 


#выборка для нужного направления поездов
#  napr=list();napr$name='DSAHALIN'; napr$sto=c(2068400,2068468,2068482);napr$stn=c(2068468,2068482,2068498);
#Экстракция данных в базу, всё что есть по указанному направлению (станции начала и конца)
#  myPackage$trs.tData.extract_mars(napr)


#  name='SPb-Murmansk'
#  name='SPb-Mos'
name='SPb_Mos_Anapa_Adler-Murmansk';
name='SAHALIN'

neir=list();
vhod=list()
vhod$name=name
vhod$before=c(7,30,60,90,180,360,NA) # за сколько дней должны быть прогнозы - теперь перечень дат!
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
vhod$version=1;# версия множества входов, 1=много, 2=мало(vhod$xz=c('Seats','Seats_km','stan_%'))
#vhod$xz=c('Seats','Seats_km','stan_%');vhod$version=2; # 
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


# neir$vhod$xz
# neir$vhod$version=2;

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
#   err=neuron$neir.rez_err(neir,2,1)  #график средних по хорошим
#   err=neuron$neir.rez_err(neir,'dat',0)  # график по дням

# график процесса настройки
errs=neir$errors;o=order(errs$dat_time);errs=errs[o,];errs$nn=(1:nrow(errs))
#mnn=max(errs$nn);errs=errs[(errs$nn>=mnn-1000),]
err=errs;err$t=1;merr=min(err[(!is.na(err$err)),'err'])
errs$err=errs$err_sr;errs$t=2;err=rbind(err,errs)
errs$err=errs$err2;errs$t=3;err=rbind(err,errs)
errs$err=errs$err_posled;errs$t=8;err=rbind(err,errs)
errs$err=errs$err_prog;errs$t=4;err=rbind(err,errs)
errs$err=errs$err_prog2;errs$t=5;err=rbind(err,errs)
err=err[(!is.na(err$err)),];err=err[(err$err<merr*1.7),];
plot(x=err$nn,y=err$err,col=err$t)

# plot(x=err$nn,y=err$err,col=err$nom)

err=neuron$neir.rez_err(neir,0,1)  # итоги всех запаздываний - на печать

# neir_old=neir

c=detectCores()


# график итогового соответствия прогноза и реалий
prognoz=myPackage$trs.dann_load('prognoz','') 
for (nm in unique(prognoz$yy)){  #  nm='pkm0'
  pr=prognoz[((prognoz$yy==nm)&(!is.na(prognoz$real))),]
  plot(x=pr$real,y=pr$zn,main=paste('yy=',nm,sep=''))       # ,col=err$t)
}







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




sts=unique(progn[,c('Sto','Stn','pzd')])

sts=unique(prognoz[,c('Sto','Stn','pzd')])

################################################################################


################################################################################

посмотреть итоги прогнозов всех


prognoz=myPackage$trs.dann_load('prognoz','') 


prognoz[(is.na(prognoz$before)),'before']=1000
prognoz[(is.na(prognoz$bef)),'bef']=1000

prognoz[(is.na(prognoz$version)),'version']=0


################################################################################
# проверка качества уже найденного

pr=prognoz[(!is.na(prognoz$real)),]

pr$real=as.numeric(as.character(pr$real))  
pr$zn=as.numeric(as.character(pr$zn))  
pr$name=as.character(pr$name)
pr$max_dat=as.Date(as.character(pr$max_dat))
pr$dat=as.Date(as.character(pr$dat))
pr$yy=as.character(pr$yy)

pr=pr[(pr$dat<=pr$max_dat+pr$before),]

pr$erp=(pr$real-pr$zn)**2
pr$kol=1

pr_=aggregate(x=subset(pr,select=c('erp','kol')),
              by=subset(pr,select=c('name','max_dat','before','version','yy')), FUN="sum" )

pr_$err=round(((pr_$erp/pr_$kol)**0.5)*100)/100


################################################################################


################################################################################










err=neir$errors
err[(is.na(err$before)),'before']=-1
er=err[(1:1),]

er=aggregate(x=subset(err,select=c('nom_nastr')),by=subset(err,select='before'), FUN="max" )

err_=merge(err,er,by=c('before','nom_nastr'))


err=neuron$neir.rez_err(neir,2)  #график средних по хорошим






################################################################################

################################################################################





################################################################################



################################################################################


 prognoz=myPackage$trs.dann_load('prognoz','') 


pr=prognoz[(!is.na(prognoz$version)),]

pr_=pr[(pr$row %in% (20272:20281)),]

pr_=pr[(pr$row==20272),]



pr_=prognoz[(prognoz$max_dat!='2020-01-24')&(prognoz$dat=='2020-02-25'),]
2019-07-17


pr_=prognoz[(prognoz$row==20812),]

pr_=prognoz[((prognoz$row==20272)&(prognoz$yy=='kp0')),]





################################################################################




################################################################################



# Прогнозы
progn=neuron$neir.prognoz(neir,all=1) #;  neir$progn=progn

progn$k=1

pr=aggregate(x=subset(progn,select=c('k')),
             by=subset(progn,select=c('before')), FUN="sum" )

pr=progn[(progn$before==30)&(!is.na(progn$before)),]


pr_=unique(pr[,c('Sto','Stn','Train','dat','k')])

pr_=aggregate(x=subset(pr_,select=c('k')),
             by=subset(pr_,select=c('Sto','Stn','Train')), FUN="sum" )


prr=pr[(pr$Train=='0293АА'),]

plot(x=prr$yy,y=prr$zn,col=prr$Type)


prr$dat=as.Date(as.character(prr$dat))
plot(y=prr$zn,x=prr$dat,col=prr$Type)
plot(y=prr$yy,x=prr$dat,col=prr$Type)
unique(prr$Type)


prr_=prr[(prr$dat=='2019-05-19'),]

prr_=prr[(prr$Type=='Л1'),]




pr_=unique(pr[,c('Sto','Stn')])
pr_$nn=(1:nrow(pr_))

pr=merge(pr,pr_,by=c('Sto','Stn'))

for (nn in pr_$nn){
  pp=pr_[(pr_$nn==nn),]
  st=paste(nn,pp$Sto,pp$Stn,sep='-')
  pp=pr[(pr$nn==nn),]
  pp$dat=as.Date(as.character(pp$dat))
  plot(x=pp$yy,y=pp$zn,col=pp$Type,main=st)
  #plot(y=pp$zn,x=pp$dat,col=pp$Type)
}


nn=8
unique(pp$Train)
plot(x=pp$yy,y=pp$zn,col=pp$Train,main=st)
for (tr in unique(pp$Train)){
  pt=pr[(pr$Train==tr),]
  plot(x=pt$yy,y=pt$zn,col=pt$Type,main=tr)
  plot(x=pt$dat,y=pt$zn,col=pt$Type,main=tr)
}

tr='0021ЧА'

plot(x=pt$dat,y=pt$zn,col=pt$Type,main=tr)

plot(x=pt$dat,y=pt$yy,col=pt$Type,main=tr)




################################################################################

# вывод части прогноза в таблицу

prognoz=myPackage$trs.dann_load('prognoz','') 

pr=prognoz
pr=pr[(pr$before==360)&(!is.na(pr$before)),]
pr=pr[(pr$max_dat=='2020-03-09'),] 
 
pr=pr[(pr$dat=='2020-04-14'),]

for (nm in c('name','before','bef','max_dat','real','poln','row','version','Seats_km','Seats')){pr[,nm]=NULL}


myPackage$trs.Data_save(pr,'prg') #запись на диск прогнозов


matrix=pr
name='prg'
vid='';first=TRUE;nname=''










#  neuron$neir.prognozi_save(neir)  #централизованная запись прогнозов 





################################################################################

################################################################################


# ВОПРОС - ПОЧЕМУ прогноз весны-лета 2020г за NA дней упал так сильно вниз??? Переобучение?



rez=neir$all_rezult
rez=rez[(is.na(rez$before)),]
dn=neir$dann
dn=dn[,c('row','dat')]
rez=merge(rez,dn,by='row')

rez=rez[(rez$nomb2>-1),]
rez=rez[(!is.na(rez$yy)),]
rez$d=as.character(substr(rez$dat,1,7))
rez_=rez[(rez$d=='2020-04'),]
rez_$k=1

rz_=aggregate(x=subset(rez_,select=c('k')),by=subset(rez_,select='nset'), FUN="sum" )

rez_2=rez[(rez$nset==34413),]


# рассмотреть нейросеть 34413

st=neir$all_stat
st=st[(st$nset==34413),]
fil=neir$all_filtr
fil=fil[(fil$nset==34413),]

pol=neir$opis_pols
pol=pol[(pol$n_poll==fil$n_poll),]

pp=neir$opis_pol
pp=pp[(pp$n_pol %in% pol$n_pol),]

vh=neir$vhodi
vh=vh[(vh$tip %in% c('xz','xs')),]
vh_=vh[(vh$nm_ %in% pp$get),]



names(neir)


################################################################################

# посмотреть, какие входы вообще идут в хоть какие-то реальные нейросети?!

stat=neir$all_stat
stat=stat[(!is.na(stat$all_time)),]

fil=neir$all_filtr
fil=fil[(fil$nset %in% stat$nset),]

poll=neir$opis_pols
poll=poll[(poll$n_poll %in% fil$n_poll),]

pol=neir$opis_pol
pol=pol[(pol$n_pol %in% poll$n_pol),]

pol1=unique(pol[,c('get','zapazd','bef')])


pol2=unique(pol[,c(paste('m',c(1:16),sep=''))])

pp=NULL
for (i in c(1:16)){
  p=pol2;p$i=i;p$z=as.integer(p[,paste('m',i,sep='')])
  pp=rbind(pp,p)
}

pp=pp[,c('i','z')]
pp=unique(pp[(pp$z>0),])

mas=neir$mass
mas=mas[(mas$nom %in% pp$z),]

vh=neir$vhodi
vh=vh[(vh$nm_ %in% mas$nm_),]
vh=vh[,c('nm','nm_')]

mas=merge(mas,vh,by='nm_')





##################################################################################


##################################################################################


##################################################################################

# ОШИБКА!!!  Очень мало реальных данных по СПб-Москва всего 1538 строк!!! И ВООБЩЕ БЕЗ БУДУЩЕГО.
























name='SPb-Mos'


neir=list();
vhod=list()
vhod$name=name
vhod$before=c(7,30,60,90,180,360,NA) # за сколько дней должны быть прогнозы - теперь перечень дат!
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
vhod$version=1;# версия множества входов, 1=много, 2=мало(vhod$xz=c('Seats','Seats_km','stan_%'))
#vhod$xz=c('Seats','Seats_km','stan_%');vhod$version=2; # 
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




names(neir)


dn=neuron$dann

dn=dn[(!is.na(dn$row)),]







##################################################################################










name='SPb-Mos'

neir=list();
vhod=list()
vhod$name=name
vhod$before=c(7,30,60,90,180,360,NA) # за сколько дней должны быть прогнозы - теперь перечень дат!
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
vhod$version=1;# версия множества входов, 1=много, 2=мало(vhod$xz=c('Seats','Seats_km','stan_%'))
#vhod$xz=c('Seats','Seats_km','stan_%');vhod$version=2; # 
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


##################################################################################


dann=myPackage$trs.dann_load("SPb-Mos",'ext') #данные по поездам
dann_sts=myPackage$trs.dann_load(paste("SPb-Mos",'sts',sep='_'),'ext')  # данные по маршрутам


dd=dann
dd4=dd[((dd$pzd %in% c(4,-4))),]
dd=dd[(!(dd$pzd %in% c(4,-4))),]
dd_=dd[(dd$Train=='-'),]
dd=dd[(dd$Train!='-'),]















##################################################################################

ОШИБКА!!!
  
  
  
  #  name='SPb-Murmansk'
  #  name='SPb-Mos'
  name='SPb_Mos_Anapa_Adler-Murmansk';
  
  
  name='sahalin';      #   

#name='dann'


neir=list();
vhod=list()
vhod$name=name
vhod$before=c(7,30,60,90,180,360,NA) # за сколько дней должны быть прогнозы - теперь перечень дат!
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
vhod$version=1;# версия множества входов, 1=много, 2=мало(vhod$xz=c('Seats','Seats_km','stan_%'))
#vhod$xz=c('Seats','Seats_km','stan_%');vhod$version=2; # 
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


#     Ошибка в `[.data.frame`(dd, , nm) :undefined columns selected 







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
    if (nm %in% names(dann)){dann[((dann[,nm]==0)|(is.na(dann[,nm]))),nm]='-'}
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
      dt1$k1=1;
      dt1=aggregate(x=subset(dt1,select='k1'),by=subset(dt1,select='pzd'), FUN="sum" )
      if (nrow(dt2)>0) {dt2$k2=1;
      dt2=aggregate(x=subset(dt2,select='k2'),by=subset(dt2,select='pzd'), FUN="sum" )
      dt1=merge(dt1,dt2,by='pzd') } else {dt1$k2=0}
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
        if (nm %in% names(dann_)) {
          dann_=dann_[(dann_[,nm]!='-'),];
          if (nrow(dann_)>0) {dann_[,nm]='-'}
        }}}
    
    #суммирование
    if (nrow(dann_)>0){dann_$ed=1
    dann_=aggregate(x=subset(dann_,select=c(param_sum,'ed')),by=subset(dann_,select=paramm), FUN="sum" )
    # оставить поезда, где хоть раз в итог пошло более 1 строки
    if ('pzd' %in% paramm){
      pzd_=unique(dann_[(dann_$ed>1),'pzd']);
      dann_=dann_[(dann_$pzd %in% pzd_),]}}
    
    if (nrow(dann_)>0){dann_$ed=NULL;dann_$dann=0
    for (nm in c('Time','Tm_otp','Rasst','cena0')){
      if (nm %in% names(dann)){dann_[,nm]=0}}
    dann=myPackage$sliv(dann,dann_)
    }
    rm(dann_)
  }
  
  if (!is.null(dann_sts))  {#объединить данные по поездам, и по направлениям, если таковые есть
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
    kol_dat=nrow(unique(as.data.frame(dann[(!is.na(dann$yy)),dat])))
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
  neir$vhod$min_dat=min_dat
  neir$vhod$kol_dat=kol_dat
  
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
  
  dann_prog=dann   ######### сохранить данные для постановки в ПРОГНОЗ
  
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
    before=unique(neir$vhod$before)
    before=as.data.frame(before);
    before$row=NA;before$dat=NA
    dn=dann[(!is.na(dann$row)),]
    for (bef in before$before){ if (!is.na(bef)){
      row=max(dn[((as.Date(dn$dat))<=dat+bef),'row'])+1
      before[((before$before==bef)&(!is.na(before$before))),'row']=row
      before[((before$before==bef)&(!is.na(before$before))),'dat']=as.Date(dat+bef+1)
    }}
    before$dat=as.Date(before$dat)
    {#постановка порядковых номеров    
      o=order((!(is.na(before$before))),-before$before)
      before=before[o,]
      before$nom=(1:nrow(before))
      if (is.na(before[1,'before'])){before$nom=before$nom-1}
    }
    neir$vhod$before=before
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
  
  
  
  
  
  
#  ОШИБКА!!!
  
  
  
  
  {# соединение данных и прогнозов
    prognoz=myPackage$trs.dann_load('prognoz','') 
    
    dann=dann_prog[(!is.na(dann_prog$row)),];dann$row=NULL
    dann$name=neir$vhod$name
    nmp=names(prognoz);nmd=names(dann)
    nms=NULL
    vh=neir$vhodi
    vh=vh[(vh$tip %in% c('xz','xs','ost')),]
    for (nm in nmp){if (nm %in% nmd){
      if (!(nm %in% vh$nm)){nms=c(nms,nm)}}}
    
    yy=unique(as.character(prognoz$yy));dn=NULL
    for (nm in yy){if (nm %in%  names(dann)){
      dd=dann;dd$real=dd[,nm];dd$yy=nm;dn=rbind(dn,dd);rm(dd)  }}
    
    dn=dn[,c(nms,'real')];dn=dn[(!is.na(dn$real)),]
    
    prognoz$str=(1:nrow(prognoz))
    for (nm in nms){
      prognoz[,nm]=as.character(prognoz[,nm])
      dn[,nm]=as.character(dn[,nm])
    }
    
    pr=prognoz;pr$real=NULL
    pr=merge(pr,dn,by=c(nms))
    
    pr_=pr;
    if (nrow(pr_)>0){ # Если хоть кому-то есть что дописать
      pr_$kol=1
      pr_=aggregate(x=subset(pr_,select=c('kol')),by=subset(pr_,select=c('str')), FUN="sum" )
      pr_=pr_[(pr_$kol==1),]
      pr=merge(pr,pr_,by='str');pr$kol=NULL
      
      prognoz=merge(prognoz,pr_,by='str',all=TRUE)
      prognoz=prognoz[(is.na(prognoz$kol)),];prognoz$kol=NULL
      
      if (!('real' %in% names(prognoz))) {prognoz$real=NA}
      prognoz=rbind(prognoz,pr);prognoz$str=NULL
      
      myPackage$trs.Data_save(prognoz,'prognoz') #запись на диск прогнозов
    }
  }
  
  return(neir)
  
  dann=1;dats=1;dn=1;mas=1;nms=1;pp=1;proc=1;pzd=1;vh=1;xs=1;xz=1;
  before=1;dat=1;i=1;k=1;kol=1;max_dat=1;max_n=1;dann_sts=1;
  min_date=1;nm=1;nm_=1;nname=1;o=1;param_sum=1;paramm=1;plus_dats=1;
  plus_time=1;pr=1;pzd_=1;row=1;zn=1;min_dat=1;upr_v=1;upr_y=1;v=1;poll=1;dd=1;bef=1;
  dann_prog=1;pr_=1;prognoz=1;nmd=1;nmp=1;yy=1;kol_dat=1;pol=1;
  
  rm(dann,dats,dn,mas,nms,pp,proc,pzd,vh,xs,xz,before,dat,i,k,kol,max_dat,max_n)
  rm(min_date,nm,nm_,nname,o,param_sum,paramm,plus_dats,plus_time,pr,pzd_,row,zn,dd)
  rm(min_dat,kol_dat,upr_v,upr_y,v,poll,neir,dann_sts,bef,dann_prog,pr_,prognoz,nmd,nmp,yy,pol)
  
}
#Пример запуска
#neir=neuron$neir.dann_first(neir);dann=neir$dann;neir$dann=NULL;












##################################################################################





















##################################################################################

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
rm(pol1,pol2,pol2_1,pols1,pols2,stat1,stat2,max_nset,fil1,fil2,mass1,mass2,p1,vhodi2,old,dd4)
rm(str_r,str_s,str_vih,str_p,npols_,err_prog,err_prog2,dist,resh,stat_resh,vv_,ish,mdt,pd_)
rm(kol_resh,max_resh,n_resh,opt,ver,nnn,pq,umens,mnass,rez2_,rm,rezm,kol_dann,ppf,ppz,nums,pr_,nmd,nmp)
rm(max_poll,pred_poll,podskaz,plus_time,polz,nom_pol,polp,polsp,it1,shh_,shem,pat,kl,sum_mar,tab_nom)
rm(dn_s_,dn_w_,wd,wd_,by_,wd_2,wd_sr,wd_stat,wd2,pas,inf__,matr1,matr2,sh1,col,kol_rez2,matrix__)
rm(rasp1,rasp2,mest,spas,sr,sts,ww,ww_,min_d,max_d,hass,rr_z,rasp3,rasp4,has2,rasp,wag,train,train2,dann_prog)
rm(rr1,rr1_b,rr2,rr2_b,rr2_,srr2,wag_b,inf_p,kday,kday_,rs1,rs2,max_pol,sum_pol,pz,pzd_ish,pzd1,pzd2,m1,m2,m1_,m2_)
rm(bf,rezb,s0,s1,da,f1,f2,upr_y,upr_v,upr,dann0,ppv,yy,rezult,dn0,fl_,rasp2_,dno,pm,ee,pol2_,str__,rows)
rm(c_yz,d_y,d_z,dy,dz,e_yz,prg,beff,dp,dp_,dt,dnp,vidi,inf_bad,matr_itog,matr_old,vvvvv,vag0,poln,pols_f,is,nnm)
rm(mars,Murm_SPb,n1,n2,sahalin,max_dt,napr,dd__,ost_,ost2,okrugl,a,stan,sto,stn,mrs,mars_,sst,pas0,ff1,pol_old)
rm(vo,vo1,vo2,vx,vx1,vx2,vx1_,prognoz,err_posled,row_bef,stan_,mk,kol_is,dann_sts,apols,iss,param2,nset2,pph,ppp_)
rm(neir_old,kol_dat,mm2,mmh,rh1,rh2,polls)
rm(d,d1,d2,d3,dr,rez,rz,tt,u,un,dt,grav,i,kk,n,o,nn,time,tm,v,zp,zr,zv)
rm(dd,kosm,p,pp,z,z_,zz,zz_,m,mm,nx,gr,ks,ks_,vv,nz,c,с)



warnings()


rm(neir,neurs,nnnnn,nnnnn2,neuron,neural,myPackage)

rm(neir2)



