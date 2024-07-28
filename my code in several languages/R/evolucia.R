
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





################################################################################

################################################################################



################################################################################

################################################################################
# макросы
popul=list()


popul$pop_init <- function(){ # инициация всех начальных данных
  
  pop=list()
  pop$kol=1000;#Размер популяции, в штуках, потом может быть прийти к массе 
  pop$k_gen=10;pop$k_hrom=5;#количество генов и их носителей хромосом
  pop$k_rab=10 #количество разных работ, которые oбъект может выполнять
  pop$max_rab=5 #сколько максимум работ (из всех) доступны одному субъекту
  pop$k=pop$k_gen+pop$k_rab
  
  #расстановка генов по хромосомам
  gen=(1:pop$k_gen);xrom=as.data.frame(gen)
  xrom$xrom=round(xrom$gen*pop$k_hrom/pop$k_gen+0.49999)
  pop$xrom=xrom
  
  #  название некие
  # pop$nms=c(paste('g',(1:pop$k),sep=''),paste('r',(1:pop$k_gen),sep=''),'zn')
  
  
  #сама программа инициации
  n1=(0:pop$k);pr=as.data.frame(n1);
  pr$nm1=paste('g',pr$n1,sep='')    
  pr[(pr$n1>pop$k_gen),'nm1']=paste('r',pr[(pr$n1>pop$k_gen),'n1'] -pop$k_gen,sep='')    
  pr[(pr$n1==0),'nm1']='1'
  
  nrav=pr;
  nrav$nr=runif(nrow(nrav));nrav$vis=runif(nrow(nrav)); #коэффициенты нравятся и выживаемость
  nrav$rod=runif(nrow(nrav))-0.5; #коэф рождаемости детей у индивида
  pop$nrav=nrav
  
  
  pr_=pr;pr_$n2=pr_$n1;pr_$nm2=pr_$nm1;pr_$n1=NULL;pr_$nm1=NULL;
  pr=merge(pr,pr_)
  pr$pr=round((runif(nrow(pr))-0.5)*10) #коэф суммарная выживаемость организма в конкуренции
  pr=pr[(pr$n1<=pr$n2),] #сокращение матрицы почти в 2 раза
  o=((pr$n1==0)&(pr$n2>pop$k_gen))
  pr[o,'pr']=abs(pr[o,'pr'])
  
  pr=pr[(!((pr$n1==0)&(pr$n2==0))),]  #нулевая координата ни к чему
  pr=pr[(!(pr$pr==0)),]  #нулевые значения только отнимают время выислений
  pr$i=(1:nrow(pr))
  
  pop$pr=pr #таблица произведений (и просто значений приращения) от значений генов и привычек
  pop$tm=0
  
  
  # инициация исходных данных
  row=(1:pop$kol);dann=as.data.frame(row);
  for (i in (1:pop$k_gen)){# 2 экземпляра гена каждого типа
    dann[,paste('p',i,sep='')]=round(runif(pop$kol));
    dann[,paste('q',i,sep='')]=round(runif(pop$kol)) }
  
  
  dann$rr=0 # постановка, кто что умеет делать
  for (i in (1:pop$k_rab)){#кто что умеет делать
    nm=paste('r',i,sep='');
    dann[,nm]=round(0.6*runif(nrow(dann))*pmax(pmin(pop$max_rab-dann$rr,1),0))
    dann$rr=dann$rr+dann[,nm]
  }
  dann$rr=NULL
  pop$dann=dann
  
  return(pop)
  
  rm(o,pr,pr_,n1,pop,nrav,xrom,gen,row,dann,i,z,nm1,nm2,nm)
}
#   pop=popul$pop_init()





popul$zn <- function(pop) { #значения жизненной силы
  dann=pop$dann
  nrav=pop$nrav
  
  #блок расчёта - кто вообще в принципе выживает, по не очень сильному расхождению генов
  {dann$vis=0
    for (i in (1:pop$k_gen)){
      z=nrav[(nrav$n1==i),'vis']
      dann$vis=dann$vis+z*abs(dann[,paste('p',i,sep='')]-dann[,paste('q',i,sep='')]) 
      dann[,paste('g',i,sep='')]=dann[,paste('p',i,sep='')]+dann[,paste('q',i,sep='')]
    }
    dann=dann[(dann$vis<=pop$k_gen*2),]}
  
  
  {#расчёт жизненной силы в зависимости от генов и умений, чтобы знать кто выживет в конкуренции
    dann$zn=5*runif(nrow(dann));pr=pop$pr;#dann$vozr=0;
    for (i in pr$i){ #цикл по всей матрице коэфициентов жизненной силы
      pr_=pr[(pr$i==i),]
      nm1=pr_$nm1;nm2=pr_$nm2;z=pr_$pr
      if (nm1=='1'){dann$zn=dann$zn+dann[,nm2]*z}else{
        dann$zn=dann$zn+dann[,nm1]*dann[,nm2]*z }
    }
    o=order(-dann$zn);dann=dann[o,]
    if (nrow(dann)>pop$kol){dann=dann[(1:pop$kol),]}
  }
  
  dann=as.data.table(dann)
  pop$dann=dann
  return(pop)
  rm(z,nm1,nm2,pr,dann,i,o,pr_,pop,nrav)
}
# pop=popul$zn(pop)





popul$razmnoj <- function(pop) { #размножение имеющейся популяции, разбивка на пары строго по выживаемости
  dann=as.data.frame(pop$dann)
  nrav=pop$nrav
  dann$i=(1:nrow(dann));dann$j=round(dann$i/2+0.1);dann$i=2*dann$j-dann$i
  dn0=dann[(dann$i==0),];dn1=dann[(dann$i==1),];dn1=dn1[(1:nrow(dn0)),]
  dn0$rod=runif(nrow(dn0));
  for (nm in nrav$nm1){if (nm!='1'){
    z=as.numeric(nrav[(nrav$nm1==nm),'rod'])
    dn0$rod=dn0$rod+z*abs(dn0[,nm]-dn1[,nm])
  }}
  dn0$rod=round(dn0$rod);dn1$rod=dn0$rod
  dn0=
  
  
}



popul$stat <- function(pop){# выдача статистики по популяции на данный момент
  dann=pop$dann
  tm=pop$tm;zn=as.data.frame(tm)
  zn$max=max(dann$zn);zn$min=min(dann$zn)
  zn$mean=sum(dann$zn)/pop$kol
  zn$obuch=pop$obuch
  stat=pop$stat;stat=rbind(stat,zn)
  stat=unique(stat);pop$stat=stat
  return(pop)
  rm(pop,dann,tm,zn,stat)
}
# popul$stat(pop)




popul$stat <- function(pop){# выдача статистики по популяции на данный момент
  
  dann=pop$dann
  nms=pop$nms
  dann$tm=pop$tm
  
  zn=aggregate(x=subset(dann,select=nms),by=subset(dann,select='tm'), FUN="sum" )
  zn$mean=zn$zn/pop$kol
  zn$zn=NULL
  zn$max=max(dann$zn);zn$min=min(dann$zn)
  zn$obuch=pop$obuch
  stat=pop$stat;stat=rbind(stat,zn);pop$stat=stat
  return(pop)
  rm(pop,dann,tm,zn,stat)
}
# popul$stat_big(pop)




popul$deti <- function(pop) { #генерация потомков
  pop$tm=pop$tm+1
  dann=as.data.frame(pop$dann)
  # дочерние потомки
  dann$r=runif(pop$kol)
  o=order(dann$r);dann=dann[o,];dann$r=NULL
  k=pop$kol;kk=round(k/2)
  p=dann[(1:kk),];m=dann[((kk+1):k),] # папы и мамы
  
  
  d1=p;d2=m;for (n in (1:pop$k_gen)){#наследования генов
    nm=paste('r',n,sep='');d1[,nm]=m[,nm];d2[,nm]=p[,nm]  }
  for (n in ((pop$k_gen+1):pop$k)){#наследования привычек
    nm=paste('g',n,sep='');
    d1[,nm]=p[,nm]+m[,nm];d2[,nm]=d1[,nm]}
  d=rbind(d1,d2)
  rm(p,m,d1,d2)
  
  
  #теперь мутагенез потомков по генам
  for (n in (1:pop$k_gen)){  
    nm=paste('g',n,sep='');nm_=paste('r',n,sep='');
    d$r=runif(k);o=(d$r<0.5)
    g=d[o,nm];d[o,nm]=d[o,nm_];d[o,nm_]=g
    o=(d$r<0.0001);
    d_=d[o,];d=d[(!o),]
    if (nrow(d_)>0){
      kk=nrow(d_)
      d_[,nm]=d_[,nm]+(2*round(runif(kk)))-1
      d_[,nm]=pmin(3,pmax(-3,d_[,nm]))  #ограничение на размер мутации
      d=rbind(d,d_)
    }
  }
  
  
  
  #теперь мутагенез потомков по привычкам, 50(60)%+-добавки от полезности привычки 
  pr=pop$pr
  d$r=NULL;d$zz=0
  for (n in ((pop$k_gen+1):(pop$k))){  # n=19
    nm=paste('g',n,sep='');
    d0=d[(d[,nm]==0),];d1=d[(d[,nm]>0),]
    if (nrow(d1)>0){
      d1$zz=40+10*d1[,nm] #2 родителей - исходно вероятность уже 60%
      for (nk in (0:n)){ #перебор генов и предыдущих привычек (последующие точно =0 покуда)  nk=1
        nmk=paste('g',nk,sep='');
        pp=pr[(pr$n1==n)&(pr$n2==nk),'pr']
        if (nk %in% c(0,n)){d1$zz=d1$zz+pp}else{d1$zz=d1$zz+pp*d1[,nmk]}
      }
      d1[,nm]=1*(d1$zz>100*runif(nrow(d1)))
      d=rbind(d0,d1)}
    #а теперь саму мутацию
    d[(runif(nrow(d))<0.0001),nm]=1
  }
  d$zz=NULL
  
  #здесь поставить взаимное обучение
  
  d=popul$zn(d) #значения жизненной силы детей
  pop$det=as.data.table(d)
  
  
  return(pop)
  d=1;dann=1;k=1;n=1;d_=1;nms=1;un=1;o=1;d0=1;d1=1;pr=1;stat=1;zn=1;nk=1;nmk=1;pp=1;g=1;kk=1;nm=1;nm_=1;
  rm(d,dann,k,n,d_,nms,un,o,d0,d1,pr,stat,zn,nk,nmk,pp,g,kk,nm,nm_)
  rm(pop)
}
#  pop=popul$deti(pop)






popul$evol <- function(pop) { #процесс эволюции
  dann=pop$dann
  
  for (nn in(1:pop$kkk)){
    pop=popul$deti(pop)
    det=pop$det
    dann$vozr=dann$vozr+1
    dann=rbind(dann,det)
    
    dann$z=(dann$zn-5*dann$vozr)*runif(nrow(dann))
    o=order(-dann$z)
    dann=dann[o,];dann=dann[(1:pop$kol),]
    dann$z=NULL
    pop$dann=dann
    pop=popul$stat(pop)  # выдача статистики по популяции на данный момент
  }
  return(pop)
  rm(det,dann,nn,o,pop)
}
#  pop=popul$evol(pop)





################################################################################

################################################################################


# Надо просчитать эволюцию стаи, и вне стаи


pop=popul$pop_init()  # инициация всех начальных данных
pop$obuch=1 #есть ли переобучение вне семьи


{
  pop=popul$dann(pop) #сделать данные с нуля, предыдущее записать в историю
  pop$kkk=100;#сколько итераций
    pop=popul$evol(pop) # сама эволюция
}


stat=pop$stat

pop$all_stat=NULL





for (pp in (1:10)){
print(paste('pp',pp,sep='='))

pop=popul$dann(pop) #сделать данные с нуля, предыдущее записать в историю
pop$kkk=100;
pop$obuch=1-pop$obuch


for (nn in (1:60)){
  #теперь процесс эволюции, указано сколько лет
  print(nn);
  pop=popul$evol(pop)
}


#график статистики новый
stat=pop$stat
st=stat;st$zn=1;st$v=st$max;stt=st
st=stat;st$zn=2;st$v=st$min;stt=rbind(stt,st)
st=stat;st$zn=3;st$v=st$mean;stt=rbind(stt,st)
plot(x=stt$tm,y=stt$v,col=stt$zn)

}




#графики статистик всех
stat=pop$all_stat
st=stat;st$zn=1;st$v=st$max;stt=st
st=stat;st$zn=2;st$v=st$min;stt=rbind(stt,st)
st=stat;st$zn=3;st$v=st$mean;stt=rbind(stt,st)
for (obuch in c(0,1)){
st=stt[(stt$obuch==obuch),]
plot(x=st$tm,y=st$v,col=st$zn,main=paste('obuch',obuch,sep='='))}





################################################################################



for (n in (1:20)){
  nm=paste('g',n,sep='') 
  stat$ob=stat$obuch+1
    plot(y=stat[,nm],x=stat$tm, col=stat$ob,main=nm)
}




for (n in (1:10)){
  nm=paste('g',n,sep='')
  plot(y=stat[,nm],x=stat$tm,main=nm)
}


for (n in (11:20)){
  nm=paste('g',n,sep='')
  plot(y=stat[,nm],x=stat$tm,main=nm)
}


plot(y=stat$g20,x=stat$tm,main='g20')

? plot
################################################################################
#  шаг итерации - изменить обучение от родителей


popul$deti <- function(pop) { #генерация потомков
  pop$tm=pop$tm+1
  dann=as.data.frame(pop$dann)
  # дочерние потомки
  dann$r=runif(pop$kol)
  o=order(dann$r);dann=dann[o,];dann$r=NULL
  k=pop$kol;kk=round(k/2)
  p=dann[(1:kk),];m=dann[((kk+1):k),] # папы и мамы
  
  
  d1=p;d2=m;for (n in (1:pop$k_gen)){#наследования генов
    nm=paste('r',n,sep='');d1[,nm]=m[,nm];d2[,nm]=p[,nm]  }
  for (n in ((pop$k_gen+1):pop$k)){#наследования привычек
    nm=paste('g',n,sep='');
    d1[,nm]=p[,nm]+m[,nm];d2[,nm]=d1[,nm]}
  d=rbind(d1,d2)
  rm(p,m,d1,d2)
  
  
  #теперь мутагенез потомков по генам
  for (n in (1:pop$k_gen)){  
    nm=paste('g',n,sep='');nm_=paste('r',n,sep='');
    d$r=runif(k);o=(d$r<0.5)
    g=d[o,nm];d[o,nm]=d[o,nm_];d[o,nm_]=g
    o=(d$r<0.0001);
    d_=d[o,];d=d[(!o),]
    if (nrow(d_)>0){
      kk=nrow(d_)
      d_[,nm]=d_[,nm]+(2*round(runif(kk)))-1
      d_[,nm]=pmin(3,pmax(-3,d_[,nm]))  #ограничение на размер мутации
      d=rbind(d,d_)
    }
  }
  
  
  
  #теперь мутагенез потомков по привычкам, 50(60)%+-добавки от полезности привычки 
  pr=pop$pr
  d$r=NULL;d$zz=0
  for (n in ((pop$k_gen+1):(pop$k))){  # n=15
        nm=paste('g',n,sep='');
        d0=d[(d[,nm]==0),];d1=d[(d[,nm]>0),]
        if (nrow(d1)>0){
        d1$zz=40+10*d1[,nm] #2 родителей - исходно вероятность уже 60%
        for (nk in (0:n)){ #перебор генов и предыдущих привычек (последующие точно =0 покуда)  nk=1
          nmk=paste('g',nk,sep='');
          pp=pr[(pr$n1==n)&(pr$n2==nk),'pr']
          if (nk %in% c(0,n)){d1$zz=d1$zz+pp}else{d1$zz=d1$zz+pp*d1[,nmk]}
        }
        d1[,nm]=1*(d1$zz>100*runif(nrow(d1)))
        d=rbind(d0,d1)}
        #а теперь саму мутацию
        d[(runif(nrow(d))<0.0001),nm]=1
  }
  
  
  if (pop$obuch==1) {#здесь поставить взаимное обучение
    for (n in ((pop$k_gen+1):(pop$k))){  # n=15
      nm=paste('g',n,sep='');
      kk=sum(dann[,nm]) #число владеющих приёмом
      ver=(kk/pop$kol)**0.5 #вероятность неумеющему в принципе обучиться
      d$r=runif(nrow(d))
      o=((d$r<ver)&(d[,nm]==0))
      d0=d[o,];d1=d[(!o),] #кого обучаем (в принципе), и с кем нечего делать
      
      
      if (nrow(d0)>0){
        d0$zz=50 #2 родителей - исходно вероятность уже 60%
        for (nk in (0:n)){ #перебор генов и предыдущих привычек (последующие точно =0 покуда)  nk=1
          nmk=paste('g',nk,sep='');
          pp=pr[(pr$n1==n)&(pr$n2==nk),'pr']
          if (nk %in% c(0,n)){d0$zz=d0$zz+pp}else{d0$zz=d0$zz+pp*d0[,nmk]}
        }
        d0[,nm]=1*(d0$zz>100*runif(nrow(d0)))
        d=rbind(d0,d1)}
    }
  }
  d$zz=NULL;d$r=NULL
  
  
  
  d=popul$zn(d) #значения жизненной силы детей
  pop$det=as.data.table(d)
  
  
  return(pop)
  d=1;dann=1;k=1;n=1;d_=1;nms=1;un=1;o=1;d0=1;d1=1;pr=1;stat=1;zn=1;nk=1;nmk=1;pp=1;g=1;kk=1;nm=1;nm_=1;ver=1
  rm(d,dann,k,n,d_,nms,un,o,d0,d1,pr,stat,zn,nk,nmk,pp,g,kk,nm,nm_,ver)
  rm(pop)
}
#  pop=popul$deti(pop)





rm(d_)




################################################################################

#ОБУЧЕНИЕ!!!

for (n in ((pop$k_gen+1):(pop$k))){#по каждому действию отдельно
  nm=as.character(paste('g',n,sep=''))
  dann=as.data.frame(dann)
  d=dann[,nm]
  d=dann[,'g20']
  dn_=dann[(dann[,nm]==1),]
  kk=nrow(dann[(dann[,nm]==1),])
}

nm='g20'



################################################################################

# исследование статистики

stat=pop$all_stat
#stat=stat[(stat$temp==2),]

st=stat;st$tm=st$tm-1000;st$mn=st$mean;st=st[,c('tm','mn','temp')]

st=merge(stat,st,by=c('temp','tm'))
st$k=st$mn/st$mean

#plot(y=st$mean,x=st$tm)
#plot(y=st$k,x=st$tm)

st_=st[(st$k<1.05),]

st_=aggregate(x=subset(st_,select=c('tm')),by=subset(st_,select='temp'), FUN="min" )
st_$tmf=st_$tm;st_$tm=NULL

st=merge(st,st_,by='temp')

st$kk=(st$tm>st$tmf)*1+1
plot(y=st$mean,x=st$tm,col=st$kk)

ss=st[(st$kk==2),]
plot(y=ss$k,x=ss$tm,col=ss$kk)




 











################################################################################
# старое ныне ненужное




popul$dann_init <- function(pop) { #инициация нулевых данных
  # сами данные о популяции
  if (is.null(pop$temp)){pop$temp=1};
  row=(1:pop$kol)
  dann=as.data.frame(row);
  for (n in (1:pop$k)){
    nm=paste('g',n,sep='');dann[,nm]=0 #доминантный ген, и привычки
    if (n<=pop$k_gen){nm=paste('r',n,sep='');dann[,nm]=0} # рецессивный ген
  };dann$row=NULL
  
  dann$tm=0
  dann=popul$zn(dann) #значения жизненной силы
  dann=as.data.table(dann)
  pop$dann=dann
  
  dann[,c('vozr')]=NULL
  dann=unique(dann)
  
  {#сохранение предыдущей наработки статистики
    stat=pop$stat
    stat$temp=pop$temp
    stats=pop$all_stats
    stats=as.data.frame(stats)
    if (is.null(stats)){stats=stat}else{stats=rbind(stats,stat)}
    if (ncol(stats)>1){pop$all_stats=stats}
  }
  
  pop$stat=NULL;pop$tm=0
  pop$temp=pop$temp+1
  return(pop)
  rm(row,dann,n,nm,pop,stat,stats)
}
# pop=popul$dann_init(pop)










################################################################################

################################################################################

warnings()



rm(d1,d2,dann,det,m,p,k,kk,n,nm,nn,o,rez,pop,un,d,dd,ddd,un_,v,nms,unk,s,st,stat,stats,stt,zn,row,temp,tm,ast,ss,st_,pp)
rm(d3,dr,rz,tt,u,c,dt,grav,i,time,zp,c,zr,zv,с)


