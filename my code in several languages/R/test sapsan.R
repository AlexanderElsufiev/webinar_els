


if (getwd()=="C:/Users/user/Documents"){  #если на локальной машине
  setwd("D:/RProjects/test")}


eval(parse('./scripts/passengers.R', encoding="UTF-8"))
eval(parse('./scripts/trainset.R', encoding="UTF-8"))
eval(parse('./scripts/neural.R', encoding="UTF-8"))
eval(parse('./scripts/neural2.R', encoding="UTF-8"))



###############################################################################
# ПОИСК ОТПУГИВАЮЩИХ ЦЕН ПО сАПСАНАМ, ЗА РАЗНЫЕ СРОКИ ДО ОТПРАВКИ. И ВРЕМЯ ОТПР, ДНИ НЕДЕЛИ...


name='spb_mos'

rez=myPackage$trs.dann_load(name,'ext')
rez=rez[(as.Date(rez$Date)>='2015-09-01')&(as.Date(rez$Date)<'2015-12-01'),]

rez=rez[(rez$Time<300),]
rez$h_otp=round(rez$Tm_otp/120)*2
rez=rez[(rez$Type!='-'),]
rez$poln=1;rez[(rez$kol_mest>rez$Seats*0.9),'poln']=2

rz=aggregate(x =list(vag= rez$Kol_vag),by = subset(rez,select=c('Date','Train')), FUN = "sum")
rz=rz[(rz$vag %in% c(10,20)),]
rez=merge(rez,rz,by=c('Date','Train'));rm(rz)

rezz=subset(rez,select=c('Date','Train','Type','Napr','h_otp','Seats','poln'))
rezz$Napr=rezz$Napr+1



rez_=myPackage$trs.dann_load(name,'ext1')
rez_=merge(rez_,rezz,by=c('Date','Train','Type'))


rez_kp=rez_[(rez_$name=='kp'),]
rez_cen=rez_[(rez_$name=='cena'),]
rez_st=rez_[(rez_$name=='stoim'),]


kp=NULL;
for (i in 0:40){
kp_=rez_kp;kp_$kp_old=kp_[,paste('zn',i+1,sep='')]
kp_$kp_prod=kp_[,paste('zn',i,sep='')]-kp_$kp_old

kp_=subset(kp_,select=c('Date','Train','Type','Seats','Napr','kp_old','kp_prod','poln'))

st_=rez_cen;st_$cena=st_[,paste('zn',i,sep='')]
st_$cena_old=st_[,paste('zn',i+1,sep='')]
st_=subset(st_,select=c('Date','Train','Type','cena','cena_old','h_otp'));
kp_=merge(kp_,st_,by=c('Date','Train','Type'))

st_=rez_st;st_$summa=st_[,paste('zn',i,sep='')]-st_[,paste('zn',i+1,sep='')]
st_=subset(st_,select=c('Date','Train','Type','summa'));
kp_=merge(kp_,st_,by=c('Date','Train','Type'))

kp_$day=i;kp=myPackage$sliv(kp,kp_);
}
rm(kp_,st_,rez_kp,rez_cen,i)

kp$cena=100*round(kp$cena/1000)
kp$cena_old=100*round(kp$cena_old/1000)

kp$wd=as.numeric(as.Date(kp$Date))
kp$wd=kp$wd-7*round(kp$wd/7)+4

#rez_s=rez_[(rez_$Date=='2015-10-08')&(rez_$Train=='0778А'),]





kp_=kp[(kp$Type=='С2С'),]


nm='Napr'

for (nm in c('Napr','poln','h_otp','day','wd','ed')){
kpp=kp_;kpp$kp=kpp$kp_prod;kpp$ed=1;
kpp$nm=nm;kpp$zn=kpp[,nm]
kpp=aggregate(x =subset(kpp,select=c('kp','summa')),by = subset(kpp,select=c('cena','nm','zn')), FUN = "sum")

plot(x=kpp$cena ,y=kpp$kp, col=kpp$zn,main=paste("KP param=",nm,sep=''),type='b')
plot(x=kpp$cena ,y=kpp$summa, col=kpp$zn,main=paste("Summa param=",nm,sep=''),type='b')

}

kpp=kpp[order(kpp$cena),];kol=nrow(kpp)
kpp$sm=0;kpp$skp=0;sm=0;skp=0;
for (i in 1:kol){sm=sm+kpp[i,'summa'];kpp[i,'sm']=sm;
  skp=skp+kpp[i,'kp'];kpp[i,'skp']=skp;}

plot(x=kpp$cena ,y=kpp$skp, col=kpp$zn,main=paste("SKP param=",nm,sep=''),type='b')
plot(x=kpp$cena ,y=kpp$sm, col=kpp$zn,main=paste("SM param=",nm,sep=''),type='b')









#натравить нейросеть на эти данные 


minc=aggregate(x =list(minc= kp_$cena),by = subset(kp_,select=c('Date','day')), FUN = "min")
maxc=aggregate(x =list(maxc= kp_$cena),by = subset(kp_,select=c('Date','day')), FUN = "max")
cc=merge(minc,maxc,by=c('Date','day'))


k=list(x=5,m=4,kol_neir=6,ogran=0)
neir=list(k=k)
neir$k$best_sigma=5;# ограничитель средней точности прогноза



#собственно подготовка данных, пока без оптимизации процесса подготовки
#itog=neural$trs.sozd_neir_dann(dannie,neir);dann=itog$dann;neir=itog$neir;rm(itog)

#unique(kp_$h_otp)

dann=merge(kp_,cc,by=c('Date','day'))
dann=dann[(dann$poln==1)&(dann$Napr==1)&(dann$h_otp==8),]
dann$y=dann$kp_prod
#dann$y=dann$cena
dann$x.1=dann$Seats
dann$x.2=dann$kp_old
dann$x.3=dann$Napr
dann$x.4=dann$cena-dann$cena_old
dann$x.5=dann$cena_old
dann$x.6=dann$minc
dann$x.7=dann$maxc
dann$m.1=dann$day
dann$m.2=dann$wd
dann$m.3=dann$h_otp
dann$m.4=as.numeric(as.Date(dann$Date)) -dann$wd

  
  

#нормированние и массивы по новому, и инициализация всех параметров нейросети по необходимости
dann_n=neural$normir_dann(neir,dann);
neir=dann_n$neir;ddd=dann_n$dd;dd_all=dann_n$dd_all;rm(dann_n);



for (i in 1:20){

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
plot (x=dd_prog$y,y=dd_prog$z,col=dd_prog$dann,main=paste("sigma=",sigma,sep=''))

neir=neural$neir_ispravl(neir,ddd)
}






mm=neir$mm;mm=mm[(mm$v1<4),]
plot (x=mm$v2,y=mm$v4,col=mm$v1)

mm=neir$mm;mm=mm[(mm$v1==4),]
plot (x=(mm$v2),y=mm$v4,col=mm$v1)


nm='xx.5'
## ГРАФИК ПРОГНОЗА ОТ ЦЕНЫ ПРИ СЛУЧАЙНОМ НАБЛЮДЕНИИ
dd=dd_all[c(10:20),];dd$col=1;dd_=dd
for (c in (0:100)/100){dd[,nm]=c;dd$col=2;dd$yy=NA;dd_=rbind(dd_,dd)}


progn=neural$neir_prognoz(dd_,neir);
dd_$z=progn$z;

dd_[(dd_$col==1),'z']=dd_[(dd_$col==1),'y']
#dd_prog=subset(dd_prog, select = c(Train,Date,Type,Seats,y,z,zp));
#подсчёт итоговых отличий, независимой сверкой
#график коррелляции 
plot (x=dd_[,nm],y=dd_$z,col=dd_$col,main=paste("SM param=",nm,sep=''))



neir$rebro





#proc=aggregate(x =subset(rez,select=c('kol_mest','Seats')),by = subset(rez,select=c('Type')), FUN = "sum")
#proc$proc=proc$kol_mest*100/proc$Seats



#### ПРОВЕРКА ОДНОГО КОНКРЕТНОГО ПОЕЗДА, или все сапсаны скопом

kpp=kp[(kp$Train %in% c('0771А','0773А'))&(kp$Date %in% c('2015-09-01','2015-09-13'))&(kp$Type=='С2С'),]




pData=myPackage$trs.dann_load(name,'pas')
mData=myPackage$trs.dann_load(name,'mar')
wData=myPackage$trs.dann_load(name,'vag')

mData$time=mData$Tm_prib-mData$Tm_otp
sapsan=mData[(mData$time<=300)&(!is.na(mData$time)),]
sapsan$h_otp=round(sapsan$Tm_otp/60)
sapsan=unique(subset(sapsan,select=c('Date','Train','h_otp')))

pData=merge(pData,sapsan,by=c('Date','Train'))

mar=mData[(mData$Train %in% c('0771А','0773А'))&(mData$Date %in% c('2015-09-01','2015-09-13')),]
vag=wData[(wData$Train %in% c('0771А','0773А'))&(wData$Date %in% c('2015-09-01','2015-09-13')),]

 
pd=pData[(pData$Train %in% c('0771А','0773А'))
         #&(pData$Date %in% c('2015-09-01','2015-09-13'))
         &(substr(as.character(pData$Date),1,7)>='2015-09')
        ,]

         
pd=pd[(pd$Klass=='2С'),]



pd=subset(pd,select=c('Train','Date','Before','Cena','Kol_pas'))
pd=pd[order(pd$Train,pd$Date,-pd$Before,-pd$Cena),]

pd$kpp=pd$Kol_pas;pd$kpm=0;
pd[(pd$Kol_pas<0),'kpp']=0
pd[(pd$Kol_pas<0),'kpm']=pd[(pd$Kol_pas<0),'Kol_pas']
pd$Kol_pas=NULL
pd$cen=pd$Cena

tr='';cen=0;dt=''
for ( i in 1:nrow(pd)){
  if(pd[i,'cen']==0){
    if ((pd[i,'Date']==dt)&(pd[i,'Train']==tr)){pd[i,'cen']=cen}
      }
  dt=pd[i,'Date'];tr=pd[i,'Train'];cen=pd[i,'cen'];
}


pd=aggregate(x =subset(pd,select=c('kpp','kpm')),
              by = subset(pd,select=c('Train','Date','Before','cen')), FUN = "sum")

pd=pd[order(pd$Train,pd$Date,-pd$Before),]

tr='';skp=0;dt='';pd$skp=0
for ( i in 1:nrow(pd)){
    if ((pd[i,'Date']!=dt)|(pd[i,'Train']!=tr)){skp=0}
    skp=skp+pd[i,'kpp']+pd[i,'kpm']
    pd[i,'skp']=skp
  dt=pd[i,'Date'];tr=pd[i,'Train'];
}



pd=pd[order(pd$Train,pd$Date,-pd$Before),]

pd$tr=paste(substr(pd$Train,4,4),substr(pd$Date,10,10),sep='')
pd$tr=substr(pd$Train,4,4)
pd_=pd[order(pd$Date,-pd$Before,pd$Train),]




#plot (y=pd$cen,x=pd$Before,col=pd$tr)

#plot (y=pd$skp,x=pd$Before,col=pd$tr)

plot (y=pd$cen,x=pd$skp,col=pd$tr)




#### ВСЕ САПСАНЫ СКОПОМ
Klass=unique(pData$Klass)
Klass
Klass=c('СС','2С')
pd=pData[(pData$Train %in% c('0771А','0773А'))
         #&(pData$Date %in% c('2015-09-01','2015-09-13'))
         #&(substr(as.character(pData$Date),1,7)>='2015-09')
         ,]

pData$dt=as.numeric(pData$Date);pData$wd=pData$dt-7*round(pData$dt/7)+4;pData$dt=NULL



col_='Train'
col_='h_otp'
col_=c('wd','Train')

for (col_ in c('Train','h_otp','wd')){
for (kl in Klass){
pd=pData;pd$Date=as.Date(as.character(pd$Date));
if (kl!='СС'){pd=pd[(pd$Klass==kl),]}
#pd$Train='-';pd$h_otp=1
#pd$Date=pd$Date-pd$wd
pd=aggregate(x =subset(pd,select=c('Kol_pas','Stoim')),
             by = subset(pd,select=c(col_,'Date')), FUN = "sum")
pd$cen=pd$Stoim/pd$Kol_pas
#pd$tr=substr(pd$Train,4,4)
plot (y=pd$cen,x=pd$Date,col=pd[,col_],main=paste(" Cena: Color=",col_,", klass=",kl,sep=''))
plot (y=pd$Kol_pas,x=pd$Date,col=pd[,col_],main=paste("KP: Color=",col_,", klass=",kl,sep=''))
plot (y=pd$Stoim,x=pd$Date,col=pd[,col_],main=paste("Stoim: Color=",col_,", klass=",kl,sep=''))

#axis(side = 1, at = as.Date(pretty(as.numeric(pd$Date), n = 20)))
#axis(side = 1, at = pretty(pd$Date, n = 5))

}}


pd=pData[(pData$Klass=='СС'),]


