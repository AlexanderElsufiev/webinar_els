
# РАЗВИТИЕ ПРОГРАММЫ new_program_new, только before станет из нескольких запаздываний, и опора не new_program3 а new_program4

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
#eval(parse('./scripts/new_program3.R', encoding="UTF-8")) - заменил на копию, где before - разные значения
eval(parse('./scripts/new_program4.R', encoding="UTF-8"))





#Создать анализ по генетике - кошмар Дженкинса


gen=5; # количество мутировавших генов
nn=10000; #максимум размера популяции






genet=list()


genet$gen=2; # количество мутировавших генов
genet$nn=10000; #максимум размера популяции
genet$potom=10; #количество потомков от 1 пары
genet$pot_k=0.1; #коэф случайного перемешивания от упорядочивания, при спаривании
genet$step=0;
genet$k_best=1.05; # коэф улучшения
genet$xr_proc=0.01; # процент исходно мутантных хромосом
genet$dreif=0.01; #скорость дрейфа генов из хромосомы в хромосому

#ЧТЕНИЕ ИЗ БАЗЫ АГРЕГАТОВ ВО ФРЕЙМ +++
genet$pole <- function(xr,xr_,g) {
  # по номеру хромосомы, её парности и номера гена - номер поля в котором она записана.
  zn=((xr-1)*2+(xr_-1))*genet$gen+g
  return(zn)
  rm(r,xr_,g,zn)
}
# пример запуска zn=genet$pole(xr,xr_,g)








#установка данных
genet$init <- function() {
  org=c(1:genet$nn)
  dann=as.data.frame(org)
  
  kol_p=genet$gen*genet$gen*2
  for (i in c(1:kol_p)){dann[,paste('g',i,sep='')]=0}
  
  for (gn in c(1:genet$gen)){
    dann$z=runif(genet$nn)
    o=(dann$z<genet$xr_proc)
    dann$z=1;dann[o,'z']=2;
    dann$xr=round(runif(genet$nn)*genet$gen+0.5)
    dann$xr_=round(runif(genet$nn)*2+0.5)
    dann[,'nm']=paste('g',((dann$xr*2+dann$xr_-3)*genet$gen+gn),sep='')
    zn=unique(dann$nm)
    for (z in zn){
      o=(dann$nm==z);dann[o,z]=dann[o,'z']
    }
  }
  for (nm in c('z','xr','xr_','nm','org')){dann[,nm]=NULL}
  
  # выживаемость
  for (gn in c(1:genet$gen)){ # вычисление наличия каждого гена
    z=paste('k',gn,sep='');dann[,z]=0
    for (xr in c(1:genet$gen)){
      for (xr_ in c(1:2)){
        zn=((xr-1)*2+(xr_-1))*genet$gen+gn
        zn=paste('g',zn,sep='')
        dann[,z]=pmax(dann[,z],dann[,zn])
      }}}
  dann$vv=1;o=(dann$vv==1) #подсчёт коэф жизненной силы
  for (gn in c(1:genet$gen)){ 
    z=paste('k',gn,sep='');
    dann[(dann[,z]==0),'vv']=0
    o=(o&(dann[,z]==2));
    if (gn>1){dann[o,'vv']=dann[o,'vv']*genet$k_best }}
  
  dann$v=dann$vv*(-log(runif(genet$nn)))
  
  return(dann)
  rm(dann,gn,i,kol_p,nm,o,org,xr,xr_,z,zn)
}
# пример вызова dann=genet$init()

dann=genet$init()






# теперь разовое наследование
genet$nasled <- function(dann) {
  
  o=order(-dann$v);dann=dann[o,]
  dann$n=(1:nrow(dann))
  o=(dann$n==2*round(dann$n/2))
  dn1=dann[o,];dn2=dann[!o,] #родители 1 и 2
  
  pot=c(1:genet$potom)
  pot=as.data.frame(pot)
  dn1=merge(dn1,pot);dn2=merge(dn1,pot);
  o=order(dn1$pot,-dn1$v);dn1=dn1[o,]
  dn2$v=dn2$v+runif(nrow(dn2))*genet$pot_k
  o=order(dn2$pot,-dn2$v);dn2=dn2[o,]
  
  dn_=dn1; # дочерний инициализация
  nn=nrow(dn_)
  for (xr in c(1:genet$gen)) { 
    dn_$xr_=round(runif(nn)*2+0.5);o1=(dn_$xr_==1) #выборка по родителю 1
    dn_$xr_=round(runif(nn)*2+0.5);o2=(dn_$xr_==1) #выборка по родителю 2
    for (gn in c(1:genet$gen)){
      z1=genet$pole(xr,1,gn);z2=genet$pole(xr,2,gn)
      z1=paste('g',z1,sep='');z2=paste('g',z2,sep='');
      dn_[o1,z1]=dn1[o1,z1];dn_[!o1,z1]=dn1[!o1,z2] #хромосома по линии родителя 1
      dn_[o2,z2]=dn2[o2,z1];dn_[!o2,z2]=dn2[!o2,z2] #хромосома по линии родителя 2
    }}
  rm(dn1,dn2,xr,o1,o2,z1,z2)
  
  #мутации - перенос гена, у всех одинаково (только 1 аллель)
  gn=round(runif(1)*genet$gen+0.5)
  xr=round(runif(1)*genet$gen+0.5);xr_=round(runif(1)*2+0.5)
  z1=genet$pole(xr,xr_,gn);z1=paste('g',z1,sep='');
  xr=round(runif(1)*genet$gen+0.5);xr_=round(runif(1)*2+0.5)
  z2=genet$pole(xr,xr_,gn);z2=paste('g',z2,sep='');
  dn_$v=runif(nrow(dn_));o=(dn_$v<genet$dreif)
  dn_$vv=dn_[,z1];dn_[o,z1]=dn_[o,z2];dn_[o,z2]=dn_[o,'vv'];
  dn_$v=NULL;dn_$vv=NULL;
  rm(gn,xr,xr_,z1,z2)
  
  # выживаемость потомства
  for (gn in c(1:genet$gen)){ # вычисление наличия каждого гена
    z=paste('k',gn,sep='');dn_[,z]=0
    for (xr in c(1:genet$gen)){
      for (xr_ in c(1:2)){
        zn=((xr-1)*2+(xr_-1))*genet$gen+gn
        zn=paste('g',zn,sep='')
        dn_[,z]=pmax(dn_[,z],dn_[,zn])
      }}}
  
  dann=dn_
  dann$vv=1;o=(dann$vv==1) #подсчёт коэф жизненной силы
  for (gn in c(1:genet$gen)){ 
    z=paste('k',gn,sep='');
    dann[(dann[,z]==0),'vv']=0
    o=(o&(dann[,z]==2));
    if (gn>1){dann[o,'vv']=dann[o,'vv']*genet$k_best }}
  
  dann$v=dann$vv*(-log(runif(genet$nn)))
  
  for (nm in c('pot','xr_','n')){dann[,nm]=NULL}
  
  o=order(-dann$v);dann=dann[o,] #остачить не более ограничнной популяции
  dann$n=(1:nrow(dann));dann=dann[(dann$n<=genet$nn),]
  
  return(dann)
  rm(dn_,dann,pot,gn,nm,nn,o,xr,xr_,z,zn)
}
# пример вызова dn=genet$nasled(dann)




# теперь разовое наследование
genet$stat <- function(dann,step) {
  # статистика по наследникам
  dann$kol=1
  pol=c('vv',paste('k',c(1:genet$gen),sep='')  )
  st=aggregate(x=subset(dann,select=c('kol')),
               by=subset(dann,select=pol), FUN="sum" )
  st$step=step
  
  return(st)
  rm(dann,pol,st,step)
}




genet$potom=10
genet$gen=10
genet$pot_k=0.1; #коэф случайного перемешивания от упорядочивания, при спаривании
genet$xr_proc=0.02; # процент исходно мутантных хромосом
genet$dreif=0.001

dann=genet$init()
step=0
st=genet$stat(dann,step)
stat=st


for (tm in c(1:10)){
good=TRUE;kol_bad=0;
for (i in c(1:100)){
  if (good){
    dann=genet$nasled(dann)
    step=step+1
    st=genet$stat(dann,step)
    vv=nrow(as.data.frame(unique(st$vv)))
    kol_bad=kol_bad+1*(vv==1);if (vv>1){kol_bad=0}
    if (kol_bad==10) {good=FALSE}
    stat=rbind(stat,st)
    print(paste('step=',step,' kol_bad=',kol_bad,'  nrow=',vv, sep=''))
  }}


#ss=stat[(stat$vv>1),]
ss=stat

plot(x=ss$step,y=ss$kol)
}



# ПОСМОТРЕТЬ ЧАСТОТЫ ИТОГОВЫХ ХРОМОСОМ
gens=NULL
pol=c('xr',(paste('x',c(1:genet$gen),sep='')))
for (xr in c(1:genet$gen)){for (xr_ in c(1:2)){
  gen_=dann;gen_$xr=xr
  for (gn in c(1:genet$gen)){z=paste('x',gn,sep='')
    zz=paste('g',genet$pole(xr,xr_,gn),sep='')
    gen_[,z]=gen_[,zz]}
  gen_=gen_[,pol]
  if (is.null(gens)) {gens=gen_}
  gens=rbind(gens,gen_)
}};rm(gen_,xr,xr_,gn,z,zz)

gens$kol=1
gens=aggregate(x=subset(gens,select=c('kol')),
             by=subset(gens,select=pol), FUN="sum" )

gens$xs=0;
for (xr in c(1:genet$gen)){
  z=paste('x',xr,sep='')
  gens$xs=gens$xs+(gens[,z]==2)}



gens_pr=gens















rm(gen,gn,i,kol_p,nm,nn,o,org,xr,xr_,z,zn,dann,dn1,dn2,dn_,name,pot,dn,ss,st,stat,poll,step)



