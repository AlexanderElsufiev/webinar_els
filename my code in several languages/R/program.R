# Перед всеми запусками - все программы в раскладке UTF-8

#программа запускаемая на сервере


if (getwd()=="C:/Users/user/Documents"){  #если на локальной машине
  setwd("D:/RProjects/test")}


eval(parse('./scripts/passengers.R', encoding="UTF-8"))
eval(parse('./scripts/trainset.R', encoding="UTF-8"))
eval(parse('./scripts/neural.R', encoding="UTF-8"))
eval(parse('./scripts/neural2.R', encoding="UTF-8"))

# запуск самого R на сервере - команда R
# запуск программы на сервере - команда source('имя и путь программы.R')
# точный запуск  source('./scripts/program.R')  # вставка на сервере = shift insert
# sudo killall R - завершение всех R процессов

#  result <- data.frame(result, stringsAsFactors = FALSE)

# file 1.R
# program()

# file 2.R
# system("Rscript 1.R", wait = FALSE)

# из консоли
# Rscript 2.R



###############################################################################
#НАПОЛНЕНИЕ ИСХОДНЫМИ ДАННЫМИ

# name='sapsan'
  name='strela'

  name='sahalin'

#  name='spb_mos'


#ПАССАЖИРЫ и вагоны - сбор месячных данных
#  myPackage$trs.Data.aggregate_month(name)


#ПАССАЖИРЫ  апдейт суточными данными
# myPackage$trs.pData.update(name);
#ВАГОНЫ добавка посуточных данных. по фильтру Сахалин 
# myPackage$trs.wData.update(name)


#   shema=myPackage$trs.shema_dannih ()


#Экстракция данных
myPackage$trs.tData.extract2(name)

#входные данные для потока нейросетей
dannie=myPackage$trs.dannie_for_neir(name)






#ДООБУЧЕНИЕ ВСЕХ НЕЙРОСЕТЕЙ многократно
 vibor=data.frame(name=name)
 neural$all_neir_new_podnastr_many(dannie,60,vibor,2,razmnog=TRUE) 







#создание 45 исходных нейросетей
for (min_before in 1:45){
  max_vhod=3;if(min_before==45){max_vhod=2}
  #создание случайной нейросети. с ограничением по числу входов и миним запаздыванию
  neir=neural$trs.sozd_neir(dannie,max_vhod,min_before,ogran='-')
  neir$k$kol_neir=3 #увеличение объёма нейросети - сколько внутренних нейронов
  neir$k$best_sigma=5;# ограничитель средней точности прогноза

  neir=neural$neir.save_to_hist(neir,NULL);#запись без прогнозов
};rm(neir,min_before,max_vhod)




#ДООБУЧЕНИЕ ВСЕХ НЕЙРОСЕТЕЙ многократно
vibor=data.frame(name=name)
neural$all_neir_new_podnastr_many(dannie,60,vibor,2,razmnog=TRUE) 








#ГЛАВНОЕ - АНАЛИЗ ПРОГНОЗОВ. ТАБЛИЦА ИТОГОВЫХ ПРОГНОЗОВ - ПО НОВОМУ
prognoz_itogi=neural$prognoz_itogi_stat(name)
#график достигнутой точности
# prognoz_itogi=prognoz_itogi[(prognoz_itogi$progn>0),]
neural$prognoz_itogi_graf(prognoz_itogi)


neir_hist_sokr=myPackage$trs.dann_load('neiroset','sokr')
neir_hist_s=neir_hist_sokr[(neir_hist_sokr$activ==1),]


stat=myPackage$trs.dann_load('progn','stat')
progn=myPackage$trs.dann_load('progn','poln')
#dann_tip=myPackage$trs.dann_load('progn','dann_tip')
#shema=myPackage$trs.shema_dannih()

progn=progn[(progn$dann_tip==13)&(as.Date(progn$Date)>=as.Date('2016-01-02')),]

#по номеру нейросети возвращает из памяти саму нейросеть
neir=neural$get_neir_id(703)
#neir=neural$trs.sozd_neir_plus(dannie,neir,min_before=10); #увеличение нейросети случайное


neir$id=NULL;
vibor=neir$sozd$vibor
vibor[(vibor$vhod==0),'id_Train']=1
neir$sozd$vibor=vibor


#собственно подготовка данных, пока без оптимизации процесса подготовки
itog=neural$trs.sozd_neir_dann(dannie,neir);dann=itog$dann;neir=itog$neir;rm(itog)

#нормированние и массивы по новому, и инициализация всех параметров нейросети по необходимости
dann_n=neural$normir_dann(neir,dann);
neir=dann_n$neir;ddd=dann_n$dd;dd_all=dann_n$dd_all;rm(dann_n);

#    neir$sozd$vhod ;   neir$sozd$vibor ;  neir$mm

# rebro=neir$rebro;rebro[((rebro[,1]==-1)&(rebro[,3]==1)),3]=2;neir$rebro=rebro;


#настройка нейросети
#system.time(nastr=   neural$neir_nastr(ddd,neir,10))
system.time(neir <- neural$neir_nastr_new(ddd,neir,60))
sigma=neir$k$sigma;
#  neir$k$ogr_k=0.2   neir$k$alef=0.1

progn=neural$neir_prognoz(dd_all,neir);dd_prog=dd_all;dd_prog$z=progn$z;dd_prog$zp=progn$zp;
#dd_prog=subset(dd_prog, select = c(Train,Date,Type,Seats,y,z,zp));
#подсчёт итоговых отличий, независимой сверкой
zz=aggregate(x =list(err= (dd_prog$y-dd_prog$z)**2,col=1),by = list(dd_prog$dann,dd_prog$Train), FUN = "sum")
zz$sigma=(zz$err/zz$col)**0.5; #получилось хорошо - совпадает!
#график коррелляции 
plot (x=dd_prog$y,y=dd_prog$z,col=dd_prog$dann)



#запись нейросети в базу истории нейросети, и полную и сокращённую
neir=neural$neir.save_to_hist(neir,NULL);#запись без прогнозов - не ставит глухую активность!

neir=neural$neir.save_to_hist(neir,dd_all);#запись с прогнозами























#по номеру нейросети возвращает из памяти саму нейросеть
neir=neural$get_neir_id(706)
#neir=neural$trs.sozd_neir_plus(dannie,neir,min_before=10); #увеличение нейросети случайное




#собственно подготовка данных, пока без оптимизации процесса подготовки
itog=neural$trs.sozd_neir_dann(dannie,neir);dann=itog$dann;neir=itog$neir;rm(itog)

#нормированние и массивы по новому, и инициализация всех параметров нейросети по необходимости
dann_n=neural$normir_dann(neir,dann);
neir=dann_n$neir;ddd=dann_n$dd;dd_all=dann_n$dd_all;rm(dann_n);



#настройка нейросети
#system.time(nastr<-   neural$neir_nastr(ddd,neir,10))
system.time(neir<-neural$neir_nastr_new(ddd,neir,60))
sigma=neir$k$sigma;
#  neir$k$ogr_k=0.2

progn=neural$neir_prognoz(dd_all,neir);dd_prog=dd_all;dd_prog$z=progn$z;dd_prog$zp=progn$zp;
#dd_prog=subset(dd_prog, select = c(Train,Date,Type,Seats,y,z,zp));
#подсчёт итоговых отличий, независимой сверкой
zz=aggregate(x =list(err= (dd_prog$y-dd_prog$z)**2,col=1),by = list(dd_prog$dann,dd_prog$Train), FUN = "sum")
zz$sigma=(zz$err/zz$col)**0.5; #получилось хорошо - совпадает!
#график коррелляции 
plot (x=dd_prog$y,y=dd_prog$z,col=dd_prog$dann)



progn=neural$neir_prognoz_narabot_stat(neir,dd_all) #наработка прогноза
stat=progn$stat;progn=progn$progn
stat=merge(stat,dannie$dann_tip,by='dann_tip')


dann_tip=myPackage$trs.dann_load('progn','dann_tip')
tip_=dann_tip[(dann_tip$dann_tip %in% stat$dann_tip),]
tip_2=dann_tip[(dann_tip$dann_tip %in% c(22,40,41,45)),]

#    neir$sozd$vhod ;   neir$sozd$vibor ;  neir$mm



plot (x=dd_prog$Date,y=dd_prog$z,col=dd_prog$dann)




ps=myPackage$trs.dann_load('progn','stat')
ps=ps[(ps$dann_tip %in% c(10,13)),]





















# ПРОВЕРКА КОНКРЕТНОЙ НЕЙРОСЕТИ НА ПЕРЕОБУЧАЕМОСТЬ



nh=myPackage$trs.dann_load('neiroset','sokr')
nh=nh[(nh$activ==1)&(nh$before>=10)&(!is.na(nh$before))&(nh$lend>1000)&(nh$best>0),]

3288,4015,3928,4038


#по номеру нейросети возвращает из памяти саму нейросеть
neir=neural$get_neir_id(4038)
#neir=neural$trs.sozd_neir_plus(dannie,neir,min_before=10); #увеличение нейросети случайное
z=NULL
neir$mm[,'v4']=0
r=neir$rebro;r[(r[,1]!=-1),3]=0;neir$rebro=r;rm(r)

#собственно подготовка данных, пока без оптимизации процесса подготовки
itog=neural$trs.sozd_neir_dann(dannie,neir);dann=itog$dann;neir=itog$neir;rm(itog)

dann$dann=runif(nrow(dann))
dann[(dann$dann>0.8),'dann']=2
dann[(dann$dann<1),'dann']=1
dann[is.na(dann$y),'dann']=0



#нормированние и массивы по новому, и инициализация всех параметров нейросети по необходимости
dann_n=neural$normir_dann(neir,dann);
neir=dann_n$neir;ddd=dann_n$dd;dd_all=dann_n$dd_all;rm(dann_n);



#настройка нейросети
#system.time(nastr<-   neural$neir_nastr(ddd,neir,10))
system.time(neir<-neural$neir_nastr_new(ddd,neir,60))
sigma=neir$k$sigma;
#  neir$k$ogr_k=0.2

progn=neural$neir_prognoz(dd_all,neir);dd_prog=dd_all;dd_prog$z=progn$z;dd_prog$zp=progn$zp;
#dd_prog=subset(dd_prog, select = c(Train,Date,Type,Seats,y,z,zp));
#подсчёт итоговых отличий, независимой сверкой
zz=aggregate(x =list(err= (dd_prog$y-dd_prog$z)**2,col=1),by = list(dd_prog$dann,dd_prog$Train), FUN = "sum")
zz$sigma=(zz$err/zz$col)**0.5; #получилось хорошо - совпадает!
#график коррелляции 
plot (x=dd_prog$y,y=dd_prog$z,col=dd_prog$dann)

zz$f=0;z=myPackage$sliv(z,zz);z$f=z$f+1;







# neir$sozd$vhod
r=neir$rebro;r[(r[,1]!=-1),3]=0;neir$rebro=r;rm(r)

neir$mm[,'v4']=0



names(neir)
