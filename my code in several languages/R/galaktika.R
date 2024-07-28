
##### ???????????? ???????????? ??????????????????

# ?????????????????????? ?? ?????????????????????????? ??????????????????

tt=list()


tt$n=10000



n=(1:tt$n)
d=as.data.frame(n)
d$p1=runif(1:tt$n)-0.5;d$p2=runif(1:tt$n)-0.5;d$p3=runif(1:tt$n)-0.5;
d$m=1;d[(d$n>tt$n/2),'m']=2
d$m=1+round(10*d$n/tt$n)
tt$d=d



#?????????????????????? ?????????????????????????? ?? ??????????????????????????????

d=tt$d;n=tt$n;nn=n/2
rez=NULL

for (tm in c(1:1000)){
  d$v=runif(1:n);
  o=order(d$v);d=d[o,]
  d$n=(1:n)
  
  d1=d[(d$n<=nn),];d2=d[(d$n>nn),]
  
  for (i in c(1:3)){
    zp=paste('p',i,sep='');zv=paste('v',i,sep='');zr=paste('r',i,sep='');
    d1[,zv]=(d1[,zp]*d1[,'m']+d2[,zp]*d2[,'m'])/(d1$m+d2$m)
    d1[,zr]=d1[,zp]-d1[zv]
  }
  
  d1$e=d1$r1**2+d1$r2**2+d1$r3**2
  d1$r1=runif(1:nn)-0.5;d1$r2=runif(1:nn)-0.5;d1$r3=runif(1:nn)-0.5;
  d1$ee=d1$r1**2+d1$r2**2+d1$r3**2
  d1$e=(d1$e/d1$ee)**0.5
  d1$r1=d1$r1*d1$e;d1$r2=d1$r2*d1$e;d1$r3=d1$r3*d1$e;
  
  for (i in c(1:3)){
    zp=paste('p',i,sep='');zv=paste('v',i,sep='');zr=paste('r',i,sep='');
    d1[,zp]=d1[,zv]+d1[,zr]
    d2[,zp]=d1[,zv]-d1[,zr]*d1$m/d2$m
  }
  
  d1=d1[,names(d2)]
  d=rbind(d1,d2)
  
  d$e=(d$p1**2+d$p2**2+d$p3**2)*d$m;d$kol=1
  dr=aggregate(x=subset(d,select=c('e','kol')),by=subset(d,select=c('m')), FUN="sum" )
  
  #dr_=dr;dr_$m=-1;
  #dr_=aggregate(x=subset(dr_,select=c('e')),by=subset(dr_,select=c('m')), FUN="sum" )
  #dr=rbind(dr,dr_)
  dr$tm=tm
  rez=rbind(rez,dr)
}

tt$d=d

rz=rez[(rez$m>0),]
rz$ee=rz$e/rz$kol

plot(x=rz$tm,y=rz$ee,col=rz$m)

rez[(rez$m==0),'m']=NA




dd=d
o=order(dd$e)
dd=dd[o,]
dd$n=(1:nrow(dd))
plot(x=dd$n,y=dd$e,col=dd$m)

dd=d
o=order(dd$m,dd$e)
dd=dd[o,]
dd$n=(1:nrow(dd))
dr=aggregate(x=subset(dd,select=c('n')),by=subset(dd,select=c('m')), FUN="min" )
dr$nn=dr$n;dr$n=NULL;dd=merge(dd,dr,by='m')
dd$n=dd$n+1-dd$nn;dd$nn=NULL

dr=aggregate(x=subset(dd,select=c('n')),by=subset(dd,select=c('m')), FUN="max" )
dr$nn=dr$n;dr$n=NULL

dd=merge(dd,dr,by='m')
dd$z=dd$n/dd$nn

plot(x=dd$z,y=dd$e,col=dd$m)














###############################################################################

## ???????????? ???????? ???? ???? ??????????, ???? ?? ??????????????????????! ?? ???????????????????????????? - ?? ??????????????.




tt=list();tt$n=1000



n=(1:tt$n)
d=as.data.frame(n)
d$p1=runif(1:tt$n)-0.5;d$p2=runif(1:tt$n)-0.5;d$p3=runif(1:tt$n)-0.5;
d$h=runif(1:tt$n)
d$m=1;d[(d$n>tt$n/2),'m']=2
#d$m=1+round(10*d$n/tt$n)
tt$d=d

{# ???????????????? ???????????? ?????????????????? ???????????????? ?????????????????????? ??????????????????????????
  n=(1:(3*tt$n))
  un=as.data.frame(n)
  un$z1=runif(nrow(un));un$z2=runif(nrow(un));
  un$v=(-log(un$z1)*2)**0.5
  un$vv=un$v*sin(2*pi*un$z2)
  un$v2=un$v*cos(2*pi*un$z2)
  
  un$n=(1:nrow(un));u=un;u$vv=u$v2;un=rbind(u,un);rm(u)
  un=un[,c('n','vv')]
  un$n=(1:nrow(un))
  un$k=round(un$n/(2*tt$n)+0.499999);un$n=un$n-2*tt$n*un$k
  u2=un[(un$k==2),];u3=un[(un$k==3),];un=un[(un$k==1),]
  un$e1=un$vv;u2$e2=u2$vv;u3$e3=u3$vv;
  u2$k=NULL;u3$k=NULL;u2$vv=NULL;u3$vv=NULL;un$k=NULL;un$vv=NULL;
  un=merge(un,u2,by=c('n'));un=merge(un,u3,by=c('n'));
  un$n=NULL;rm(u2,u3)
  tt$un=un
}

#?????????????????????? ?????????????????????????? ?? ??????????????????????????????/ ???????????????????????? ???????????????? - ???? 1 ????????????????????!

d=tt$d;n=tt$n;nn=n/2;dt=0.01;grav=-1;time=0
rez=NULL


#e=sum((d$p1**2+d$p2**2+d$p3**2)*d$m/2-d$h*grav*d$m)



for (tm in c(1:20000)){
  time=time+dt
  
  {# ????????????????????
    o=(d$h+d$p1*dt+dt*dt*grav/2<0)
    if (nrow(d[o,])>0) {d[o,'p1']=-d[o,'p1'] }
    d$h=d$h+d$p1*dt+dt*dt*grav/2;d$p1=d$p1+dt*grav;
    o=(d$h<0)
    if (nrow(d[o,])>0) {d[o,'h']=-d[o,'h'];d[o,'p1']=-d[o,'p1'] }
  }
  
  
  { #?????? ?? ?????? ??????????????????????
  o=order(d$h);d=d[o,];d$n=(1:n);d$nn=abs(d$n-2*round(d$n/2))}
  
  d1=d[(d$nn==0),];d2=d[(d$nn==1),]
  o=(abs(d1$h-d2$h)<0.001)
  d3=rbind(d1[(!o),],d2[(!o),]) # ?????????????????? ?????????????????????????????? - ???? ??????????????????
  d1=d1[o,];d2=d2[o,]
  
  
  for (i in c(1:3)){ # ???????????? ?????????????? ???????????????? ?? ??????????, ?? ???????????????? ????????????????????
    zp=paste('p',i,sep='');zv=paste('v',i,sep='');zr=paste('r',i,sep='');
    d1[,zv]=(d1[,zp]*d1[,'m']+d2[,zp]*d2[,'m'])/(d1$m+d2$m)
    d1[,zr]=d1[,zp]-d1[zv]
  }
  { # ???????? ?? ?????? ?????????????? ?????????? ??????????
    d1$e=d1$r1**2+d1$r2**2+d1$r3**2;kk=nrow(d1)
    un$v=runif(nrow(un));o=order(un$v);un=un[o,];u=un[(1:kk),]
    
    d1$r1=u$e1;d1$r2=u$e2;d1$r3=u$e3;
    d1$ee=d1$r1**2+d1$r2**2+d1$r3**2
    d1$e=(d1$e/d1$ee)**0.5
    d1$r1=d1$r1*d1$e;d1$r2=d1$r2*d1$e;d1$r3=d1$r3*d1$e;
  }
  
  for (i in c(1:3)){ # ???????????????? ???????????????? ?????????? ????????????????????
    zp=paste('p',i,sep='');zv=paste('v',i,sep='');zr=paste('r',i,sep='');
    d1[,zp]=d1[,zv]+d1[,zr]
    d2[,zp]=d1[,zv]-d1[,zr]*d1$m/d2$m
  }
  
  d1=d1[,names(d2)];d=rbind(d1,d2,d3);d$nn=NULL # ?????????? ????????????
  
  
  { # ????????????????????
  d$e=(d$p1**2+d$p2**2+d$p3**2)*d$m/2;d$kol=1
  d$ep=d$e-d$h*grav*d$m
  dr=aggregate(x=subset(d,select=c('e','kol','h','ep')),by=subset(d,select=c('m')), FUN="sum" )
  dr$time=time;rez=rbind(rez,dr)}
}

rz=aggregate(x=subset(rez,select=c('ep')),by=subset(rez,select=c('time')), FUN="sum" )

rz=rez[(rez$m>0),]
rz$se=rz$e/rz$kol
rz$sep=rz$ep/rz$kol
rz$sh=rz$h/rz$kol

plot(x=rz$time,y=rz$se,col=rz$m)

plot(x=rz$time,y=rz$sep,col=rz$m)

plot(x=rz$time,y=rz$sh,col=rz$m)






###############################################################################################
# ВЫЧИСЛЕНИЕ ГРАВИТАЦИИ ТОНКОГО КОЛЬЦА

kk=1.1; # отношение радиусов внешнего и внутреннего края кольца

nn=100 #на сколько элементов разбивка окружности
n=(1:nn);d=as.data.frame(n)
d$y=sin(pi*d$n/nn);d$x=cos(pi*d$n/nn);d$mas=1/(nn+1)
n=(1:10);dd=as.data.frame(n);dd$n=2**(-dd$n)
dd$mas=dd$n/(nn+1);dd$y=sin(pi*dd$n/nn);dd$x=cos(pi*dd$n/nn)
d=rbind(d,dd)


mm=100 #разбивка самого пространства
nx=(-mm:mm);p=as.data.frame(nx);pp=p;pp$nz=pp$nx;pp$nx=NULL
p=merge(p,pp);rm(nx)

p$px=kk^(p$nx);p[(p$nx==-mm),'px']=0
p$pz=kk^(p$nz);p[(p$nz==-mm),'pz']=0


zz=merge(d,p)
zz$r=((zz$x-zz$px)**2+zz$y**2+zz$pz**2)**0.5
zz$s=zz$mas/zz$r

zz=aggregate(x=subset(zz,select=c('s')),
             by=subset(zz,select=c('nx','nz')), FUN="sum" )

zz$s=pmin(zz$s,1.55)  #исправление точки бесконечности

#z_=zz[(zz$nz %in% c(0,-100)),];plot(y=z_$s,x=z_$nx)
#z_=zz[(zz$nx %in% c(0,1,-1)),];plot(y=z_$s,x=z_$nz)


z_=zz[(zz$nz %in% c(0)),];plot(y=z_$s,x=z_$nx)





#  вопрос - где вообще гравитация отличается он точечной более 1%???

zz$r=(kk^(2*zz$nx)+kk^(2*zz$nz))^0.5;
zz$pr=zz$r*zz$s
zz_=zz[(abs(zz$pr-1)>0.0001),]



###############################################################################################
# теперь посчитать хоть какой-то газ
# масса солнца = 2*10^30 кг
# расстояния - в миллионах км, скорость - в км/сек
# плотность1 в кг на кубометр, исходно 10^-6 (1миллиграм на кубометр)
# плотность2 в  на кубический миллионокилометр,
# гравитационная постоянная = 10^-10 ньютон*метр_кв/кг_кв

kosm=p[((p$nx<=80)&(p$nx>=-20)&(p$nz<=80)&(p$nz>=-20)),]
kosm$px2=kk*kosm$px;kosm$pz2=kk*kosm$pz
kosm[(kosm$nx==min(kosm$nx)),'px']=0
kosm[(kosm$nz==min(kosm$nz)),'pz']=0
kosm$ro=10^-6; # плотность
kosm[(kosm$nx==max(kosm$nx)),'ro']=0
kosm[(kosm$nz==max(kosm$nz)),'ro']=0
kosm$t=10 # температура в кельвинах
kosm$vy=pi*(kosm$px2^2-kosm$px^2)*(kosm$pz2-kosm$pz)
kosm$mas=kosm$ro*kosm$v*(10^27)
kosm$vx=0;kosm$vz=0;

mm=sum(kosm$mas) # суммарная масса всего

kosm$vy=kosm$px2/2 #скорость орбитальная, в метрах в секунду
kosm$p=kosm$ro/2*8.3*kosm$t #давление паскалей на кв.метр

# основная плотность= 2грам на моль,=0.002кг на моль (водород)
#p*v=NI*R*T NI=ЧИСЛО МОЛЕЙ  R=8.3Дж/моль*К  T=температура в кельвинах

## вычислить гравитационный потенциал в каждой точке


#центральный слой
ks=kosm[(kosm$nz==-20),]

#вычисление нужной для данного слоя гравитационной плотности
zz_=zz;
#zz_=zz[(zz$nx==0),]
#v=(-80:-1);vv=as.data.frame(vv);zz_=merge(zz_,vv)
#zz_$nx=zz_$vv;zz_$vv=NULL
#zz_=rbind(zz_,zz)
zz_$nx_=zz_$nx;zz_$nz_=zz_$nz;zz_$nx=NULL;zz_$nz=NULL

ks_=merge(ks,zz_)
# ks_$nzn=ks_$nx+ks_$nz_;ks_$nxn=ks_$nx+ks_$nx_; # исходник!!!
ks_$nz=ks_$nx+ks_$nz_;ks_$nx=ks_$nx+ks_$nx_;
ks_$nzn=ks_$nx+ks_$nz_;

ks_$gr=ks_$mas*ks_$s*(6.67*10^-11)*(10^-18)/ks_$px2

ks_=aggregate(x=subset(ks_,select=c('gr')),
             by=subset(ks_,select=c('nx','nz')), FUN="sum" )

ks_=ks_[(ks_$nx %in% kosm$nx),]
ks_=ks_[(ks_$nz %in% kosm$nz),]

gr=ks_[(ks_$nz %in% c(-20,0,50,80)),];plot(gr$nx,gr$gr)





#какой-нибудь из периферийных слоёв
nz=unique(kosm$nz)
nz=12

ks=kosm[(kosm$nz==nz),]

#вычисление нужной для данного слоя гравитационной плотности
zz_=zz;
#zz_=zz[(zz$nx==0),]
#v=(-80:-1);vv=as.data.frame(vv);zz_=merge(zz_,vv)
#zz_$nx=zz_$vv;zz_$vv=NULL
#zz_=rbind(zz_,zz)
zz_$nx_=zz_$nx;zz_$nz_=zz_$nz;zz_$nx=NULL;zz_$nz=NULL

ks_=merge(ks,zz_)
ks_$nxn=ks_$nx+ks_$nx_;
#ks_$nx=pmax(ks_$nx,0);ks_$nx=pmin(ks_$nx,100);
ks_$nzn=ks_$nz_;

ks_$gr=ks_$mas*ks_$s*(6.67*10^-11)*(10^-18)/ks_$px2

ks_=aggregate(x=subset(ks_,select=c('gr')),
              by=subset(ks_,select=c('nx','nz')), FUN="sum" )

ks_=ks_[(ks_$nx %in% kosm$nx),]
ks_=ks_[(ks_$nz %in% kosm$nz),]

gr=ks_[(ks_$nz %in% c(-20,0)),];plot(gr$nx,gr$gr)









######################################

rm(d,d1,d2,d3,dr,rez,rz,tt,u,un,dt,grav,i,kk,n,o,nn,time,tm,v,zp,zr,zv)
rm(dd,kosm,p,pp,z,z_,zz,zz_,m,mm,nx,gr,ks,ks_,vv,nz)

