
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
# eval(parse('./scripts/new_program1.R', encoding="UTF-8"))
# eval(parse('./scripts/new_program3.R', encoding="UTF-8"))




# ПРОБНИК ОПТИМИЗАЦИИ ЗАДАЧИ КОММИВОЯЖЁРА


opt=list()

opt$kol=100 #количество вершин графа
opt$kol_dim=4 # размерность пространства

dim=(1:opt$kol_dim)
dim=as.data.frame(dim)
dim$nm=paste('d',dim$dim,sep='')
opt$dim=dim

# создать сами вершины, с дальнейшими расстояниями
ver=(1:opt$kol);ver=as.data.frame(ver)

for (nm in dim$nm){ver[,nm]=round(runif(opt$kol)*100)}

# вариант фиксированной структуры - для повторяемости
for(dd in dim$dim){
  nm=dim[(dim$dim==dd),'nm']
  ver[,nm]=round(sin(ver$ver*(10+dd))*100)}




#рассчтояния между вершинами (несимметричны)
dist=ver;dist$ed=1;dist=merge(dist,dist,by='ed')
dist$ver1=dist$ver.x;dist$ver2=dist$ver.y
dist$rast=dist$ver.x-dist$ver.y
for (nm in dim$nm){
  nm1=paste(nm,'.x',sep='');nm2=paste(nm,'.y',sep='')
  dist$rast=dist$rast+abs(dist[,nm1]-dist[,nm2])}


dist=dist[,c('ver1','ver2','rast')]
dist$rast=pmax(dist$rast,1);dist[(dist$ver1==dist$ver2),'rast']=0
opt$dist=dist
opt$max_resh=0;opt$stat=NULL;opt$stat_resh=NULL
opt$kol_resh=100

rm(dim,dist,ver,nm,nm1,nm2,dd)



dist=opt$dist
mr=max(dist$rast)/10
dist$kol=opt$kol_resh*mr/(dist$rast+mr)
opt$dist=dist


###########################################
# теперь хоть раз получить решение


#  dist$kol=0



while (TRUE){ #начала цикла циклов итераций
  
  # поиск лучших - один цикл итераций
  {
    kol_resh=opt$kol_resh
    dist=opt$dist 
    if (is.null(dist$kol)){dist$kol=kol_resh}
    
    if (is.null(opt$stat)){
      n_resh=0;stat=as.data.frame(n_resh);stat$rast=NA;stat_resh=NULL
    } else{
      stat=opt$stat;stat_resh=opt$stat_resh}
    max_resh=opt$max_resh
    
    if (max_resh>0) {# установка суммируемых количеств
      dist$kol=0.95*dist$kol
      #dd=stat_resh[(stat_resh$n_resh>max_resh-kol_resh),c('ver1','ver2')]
      dd=stat_resh[,c('ver1','ver2')]
      if (nrow(dd)>0){
        dd$kol=1
        dd=aggregate(x=subset(dd,select=c('kol')),by=subset(dd,select=c('ver1','ver2')), FUN="sum" )
        #dist$kol=NULL
        dist=merge(dist,dd,by=c('ver1','ver2'),all=TRUE)
        dist[(is.na(dist$kol.y)),'kol.y']=0
        dist$kol=dist$kol.x+dist$kol.y
        dist$kol.x=NULL;dist$kol.y=NULL
      }
    }
    
    opt$dist=dist
 #   if (max_resh<10*kol_resh){dist$kol=0}
    if (max_resh<10){dist$kol=0}
    
    
    print(paste('Начало',Sys.time(),sep=' '))
    for (n_resh in (max_resh+(1:kol_resh))){ # перебор возможных решений  n_resh=1
      
      #установить порядок выбора
      vv=dist
      vv=vv[(vv$ver1!=vv$ver2),]
      kz=nrow(vv)
      vv$r=-log(runif(kz))*vv$kol;vv$rr=runif(kz)
      o=order(vv$ver1,-vv$r,vv$rast,vv$rr);vv=vv[o,];vv$rr=NULL
      
      { # весь цикл поиска маршрута обхода графа
        ish=1 # исходная вершина, с которой начнём обход
        resh=vv[0,]
        ver=ish
        vv=vv[(vv$ver2!=ver),]
        
        while (nrow(vv)>0) {#установка одного очередного элемента
          
          o=(vv$ver1==ver);vv_=vv[o,];vv=vv[!o,]
          if (nrow(vv_)>0){vv_=vv_[1,]} else{
            vv_=vv[1,]
            vv_[,'rast']=NA
            vv_$ver2=vv_$ver1;vv_$ver1=ver
          }
          resh=rbind(resh,vv_)
          ver=vv_$ver2
          vv=vv[(vv$ver2!=ver),]
        }
        
        vv_$ver1=ver;vv_$ver2=ish;vv_$rast=NA
        resh=rbind(resh,vv_)
      }
      
      resh$r=NULL;resh$kol=NULL # ненужные поля
      # добавить по кому расстояния не точно знаем
      rr=resh[(is.na(resh$rast)),]
      rr$rast=NULL
      rr=merge(rr,dist,by=c('ver1','ver2'))
      rr$kol=NULL
      resh=resh[(!is.na(resh$rast)),]
      resh=rbind(resh,rr)
      
      resh$n_resh=n_resh
      stat_=stat[1,]
      stat_$n_resh=n_resh;stat_$rast=sum(resh$rast)
      stat=rbind(stat,stat_)
      if (!is.null(stat_resh)){stat_resh=rbind(stat_resh,resh)} else{stat_resh=resh}
    }
    
    opt$max_resh=max(stat$n_resh)
    
    {#оставить лишь оптимальные решения
      stat=stat[(!is.na(stat$rast)),]
      o=order(stat$rast)
      stat=stat[o,]
      if (nrow(stat)>10*kol_resh){stat=stat[(1:(10*kol_resh)),]}
      stat_resh=stat_resh[(stat_resh$n_resh %in% stat$n_resh),]
    }
    
    opt$stat=stat;opt$stat_resh=stat_resh
    print(paste('Конец',Sys.time(),'решения',opt$max_resh,'=>',
                min(stat$rast),'/',max(stat$rast),sep=' '))
  }
  
}#конец цикла циклов итераций










vv=opt$dist
o=order(vv$ver1,vv$rast);vv=vv[o,]
vv$n=(1:nrow(vv))
vv=vv[(vv$n<=(vv$ver1-1)*100+10),]
vv=vv[(vv$ver1!=vv$ver2),]




stat=opt$stat;stat_resh=opt$stat_resh

if (!is.null(stat_resh)) {# установка суммируемых количеств
dd=stat_resh[,c('ver1','ver2')]
dd$kol=1
dd=aggregate(x=subset(dd,select=c('kol')),by=subset(dd,select=c('ver1','ver2')), FUN="sum" )
dist$kol=NULL
dist=merge(dist,dd,by=c('ver1','ver2'),all=TRUE)
dist[(is.na(dist$kol)),'kol']=0
}







########### похоже, экспоненциальное распределение = то что надо
zz=(0:100)/100
zz=as.data.frame(zz)

for(z in zz$zz){
vv=(1:100000);vv=as.data.frame(vv)
vv$r1=z*-log(runif(nrow(vv)));
vv$r2=(1-z)*-log(runif(nrow(vv)));
vv$k=1*(vv$r1>vv$r2)
kk=sum(vv$k)
zz[(zz$zz==z),'pp']=kk/nrow(vv)
}

plot(zz$zz,zz$pp)






#######################




rm(ver,vv,vv_,zz,ish,kk,kol_resh,kz,max_resh,n_resh,d,dim,dist,resh,rr,stat,stat_,stat_resh)
rm(nm,nm1,nm2,o,rast,z,ver_,dd,mr)




